# frozen_string_literal: true

# Offline behavior/work-count tests. Native RGSS/KGL are represented by spies;
# counters show eliminated work, not an estimate of laptop FPS.
require 'minitest/autorun'
require 'ostruct'

ROOT = File.expand_path('..', __dir__)
BASELINE = ARGV.delete('--baseline')
def script_source(name)
  folder = BASELINE ? 'Data/codex_backup_performance_20261115' : 'Scripts'
  File.read(File.join(ROOT, folder, name + '.rb'), encoding: 'UTF-8')
end

def method_source(source, name, occurrence = 0)
  found = []
  visit = lambda do |node|
    return unless node.is_a?(RubyVM::AbstractSyntaxTree::Node)
    found << node if node.type == :DEFN && node.children[0] == name
    node.children.each do |child|
      if child.is_a?(Array)
        child.each { |item| visit.call(item) }
      else
        visit.call(child)
      end
    end
  end
  visit.call(RubyVM::AbstractSyntaxTree.parse(source))
  node = found.sort_by(&:first_lineno).fetch(occurrence)
  source.lines[(node.first_lineno - 1)..(node.last_lineno - 1)].join
end

class Color
  attr_accessor :red, :green, :blue, :alpha
  def initialize(r=0,g=0,b=0,a=255); @red,@green,@blue,@alpha=r,g,b,a; end
end
class SpyBitmap
  class << self
    attr_accessor :created
  end
  self.created = 0
  attr_accessor :stamp
  attr_reader :font, :clears, :fills, :width, :height, :draws, :last_stretch
  def initialize(width=32, height=32)
    self.class.created += 1
    @width,@height = width,height
    @font = OpenStruct.new
    @clears = @fills = 0
    @draws = []
    @disposed = false
    @stamp = :source
  end
  def clear; @clears += 1; end
  def fill_rect(*); @fills += 1; end
  def set_pixel(*); end
  def draw_text(x,y,w,h,text,align=0); @draws << [x,y,w,h,text,align,text_size(text).width]; end
  def rect; Rect.new(0,0,width,height); end
  def stretch_blt(rect,source,source_rect); @last_stretch=rect; end
  def text_size(text); OpenStruct.new(width: text.scan(/\P{M}\p{M}*/).size * (@font.size || 20) / 2); end
  def dispose; @disposed = true; end
  def disposed?; @disposed; end
  def _dump(_depth); raise TypeError, 'Native Bitmap cannot be marshalled'; end
  def clone
    other = self.class.new(width, height)
    other.stamp = stamp
    other
  end
end
Bitmap = SpyBitmap
Rect = Struct.new(:x,:y,:width,:height)
class Sprite
  attr_accessor :bitmap, :x, :y, :z, :opacity, :visible, :ox, :oy, :zoom_x, :zoom_y
  def initialize
    @x=@y=@z=@ox=@oy=0
    @zoom_x=@zoom_y=1.0
    @opacity=255
    @visible=true
  end
  def dispose; @disposed = true; end
  def disposed?; !!@disposed; end
end

module Graphics
  def self.width; 640; end
  def self.height; 480; end
end
eval(script_source('Custom Menu')[/^module PhoneMenu.*?^end/m], TOPLEVEL_BINDING, 'PhoneMenu configuration')
module Cache
  def self.load_bitmap(_folder, _name); @shared ||= Bitmap.new; end
end
class Scene_Menu
  source = script_source('Custom Menu')
  [:draw_main_panel,:refresh_main_panel,:simple_text_width,:create_foreground,
   :icon_bitmap_name,:make_circle_highlight,:fill_round_rect,:draw_filled_circle,
   :dispose_sprite_array,:dispose_phone_menu_sprites].each do |name|
    class_eval(method_source(source, name), 'Custom Menu.rb')
  end
  class_eval(method_source(source, :phone_panel_values), 'Custom Menu.rb') unless BASELINE
  unless BASELINE
    [:phone_text,:phone_card,:phone_footer,:phone_widget_label].each do |name|
      class_eval(method_source(source,name),'Custom Menu.rb')
    end
  end
end
class Game_Map
  source = script_source('Game_Map')
  [:events_xy,:events_xy_nt,:any_event_starting?,:setup_starting_map_event].each do |name|
    class_eval(method_source(source, name), 'Game_Map.rb')
  end
end
class CountingEvents < Hash
  attr_reader :values_calls
  def values
    @values_calls = (@values_calls || 0) + 1
    super
  end
end
class EventSpy
  attr_accessor :x,:y,:through,:starting
  attr_reader :id
  def initialize(id,x,y); @id,@x,@y=id,x,y; @starting=false; end
  def pos?(x,y); @x == x && @y == y; end
  def pos_nt?(x,y); !@through && pos?(x,y); end
  def list; [:test]; end
  def clear_starting_flag; @starting=false; end
end
module Graphics_Core
  Screen_Width=640; Screen_Height=480
end
module Light_Core; end
module Light_Cache
  @cache={}
  def self.[](key); @cache[key] ||= Bitmap.new(128,128); end
end
module KGL
  class << self
    attr_accessor :clones, :bound
    def clone(target,source); self.clones=(clones || 0)+1; target.stamp=source.stamp; end
    def bindShadowbuffer(bitmap); self.bound=bitmap; end
  end
end
class Virtual_Char
  attr_accessor :real_x,:real_y,:direction
end
source = script_source('KUL Graphics')
first = source.index("class Light_Source\r\n") || source.index("class Light_Source\n")
last = source.index('unless Light_Core::Enable_Shadows',first)
eval(source[first...last],TOPLEVEL_BINDING,'Light_Source')
first = source.index('class Light_MKSource < Light_Source')
last = source.index('unless Light_Core::Enable_Shadows',first)
eval(source[first...last],TOPLEVEL_BINDING,'Light_MKSource')
class CasterSpy
  attr_accessor :wcf_shadow_revision
  attr_reader :calls
  def initialize; @wcf_shadow_revision=0; @calls=0; end
  def shadow(light)
    @calls += 1
    KGL.bound.stamp = [light.x,light.y,light.h,light.char.direction,wcf_shadow_revision]
  end
end
class LightMapSpy
  attr_accessor :casters
  attr_reader :height_queries
  def initialize; @casters=CasterSpy.new; @height_queries=0; end
  def screen; @screen ||= OpenStruct.new(shake: 0); end
  def adjust_x(x); x; end
  def adjust_y(y); y; end
  def local_height(*); @height_queries += 1; 2; end
end
class Weather_EX
  class_eval(method_source(script_source('MOG_Weather_EX'), :dispose_weather),'MOG_Weather_EX.rb')
end
class Scene_Base
  attr_reader :terminated
  def start; end
  def update; end
  def terminate; @terminated=true; end
end
class Scene_Map < Scene_Base
  def post_transfer; end
end
module THEO; module MAP; end; end
source = script_source('Text Over Event')
eval(source[source.index('class Scene_Map < Scene_Base')..-1], TOPLEVEL_BINDING,'Text Over Event.rb')
class WindowSpy
  attr_reader :updates
  def update; @updates=(@updates || 0)+1; end
  def dispose; @disposed=true; end
  def disposed?; !!@disposed; end
end

class PerformanceOptimizationsTest < Minitest::Test
  WIDGETS=[:weather_title,:weather_time,:weather_temp,:weather_sub,:small_left_title,
    :small_left_big,:small_left_sub,:small_right_title,:small_right_big,:small_right_sub]
  def setup
    $game_config=OpenStruct.new
    WIDGETS.each { |key| $game_config.send("phone_widget_#{key}=", key.to_s.dup) }
    $game_map=LightMapSpy.new
    $kgs=OpenStruct.new(static: true)
    KGL.clones=0
  end
  def phone
    menu=Scene_Menu.new
    panel=Sprite.new
    panel.bitmap=Bitmap.new(350,640)
    menu.instance_variable_set(:@main_panel,panel)
    [menu,panel.bitmap]
  end
  def light(klass=Light_Source, directional=false)
    l=klass.new
    keys=directional ? {2=>'a',4=>'b',6=>'c',8=>'d'} : 'a'
    l.set_light('test',keys)
    l.set_pos(4.0,5.0,2)
    l.set_offset([0,0])
    l.set_mode(false,true)
    l
  end

  def test_phone_panel_does_not_redraw_600_identical_frames
    menu,bmp=phone
    600.times { menu.refresh_main_panel }
    puts "WORK|phone_600_frames|panel_draws=#{bmp.clears}|fill_calls=#{bmp.fills}"
    assert_equal 1,bmp.clears
  end
  def test_phone_panel_detects_changes_and_in_place_string_edits
    menu,bmp=phone
    menu.refresh_main_panel
    $game_config.phone_widget_weather_title << '!'
    menu.refresh_main_panel
    assert_equal 2,bmp.clears
    $game_config.phone_widget_small_right_big='99%'
    menu.refresh_main_panel
    assert_equal 3,bmp.clears
    replacement=Bitmap.new
    menu.instance_variable_get(:@main_panel).bitmap=replacement
    menu.refresh_main_panel
    assert_equal 1,replacement.clears
  end
  def test_text_measurement_reuses_and_disposes_one_surface
    menu=Scene_Menu.new
    before=Bitmap.created
    200.times { assert_equal 40,menu.simple_text_width('test',20) }
    assert_equal 1,Bitmap.created-before
    surface=menu.instance_variable_get(:@phone_measure_bitmap)
    menu.dispose_phone_menu_sprites
    assert surface.disposed?
  end
  def test_menu_highlights_share_identical_pixels_but_independent_opacity
    menu=Scene_Menu.new
    menu.create_foreground
    sprites=menu.instance_variable_get(:@highlight_sprites)
    assert_equal 6,sprites.length
    assert_equal 1,sprites.map(&:bitmap).map(&:object_id).uniq.length
    sprites[0].opacity=100
    assert_equal 0,sprites[1].opacity
    menu.dispose_phone_menu_sprites
    assert sprites.all?(&:disposed?)
  end
  def test_event_queries_are_live_ordered_and_do_not_copy_all_events
    map=Game_Map.allocate
    events=CountingEvents.new
    events[9]=EventSpy.new(9,3,4)
    events[2]=EventSpy.new(2,3,4)
    events[2].through=true
    map.instance_variable_set(:@events,events)
    assert_equal [9,2],map.events_xy(3,4).map(&:id)
    assert_equal [9],map.events_xy_nt(3,4).map(&:id)
    events[9].x=7
    assert_empty map.events_xy_nt(3,4)
    events[2].through=false
    assert_equal [2],map.events_xy_nt(3,4).map(&:id)
    interpreter=OpenStruct.new
    def interpreter.setup(list,id); self.last_id=id; end
    map.instance_variable_set(:@interpreter,interpreter)
    events[9].starting=events[2].starting=true
    assert map.any_event_starting?
    assert_equal events[9],map.setup_starting_map_event
    assert_equal 9,interpreter.last_id
    assert events[2].starting
    map.setup_starting_map_event
    refute map.any_event_starting?
    assert_nil map.setup_starting_map_event
    puts "WORK|event_queries|full_event_array_copies=#{events.values_calls || 0}"
    assert_equal 0,events.values_calls || 0
  end
  def test_stationary_dynamic_shadow_reuses_mask_for_600_frames
    l=light
    600.times { l.refresh_xyh; l.dbmp }
    puts "WORK|kul_stationary_600_frames|mask_builds=#{$game_map.casters.calls}|clones=#{KGL.clones}"
    assert_equal 1,$game_map.casters.calls
    assert_equal 1,KGL.clones
  end
  def test_shadow_updates_every_moving_frame
    l=light
    120.times do
      l.char.real_x+=0.05
      l.refresh_xyh
      assert_equal l.x,l.dbmp.stamp[0]
    end
    assert_equal 120,$game_map.casters.calls
  end
  def test_shadow_invalidates_for_direction_geometry_restore_and_height
    l=light
    l.dbmp
    l.char.direction=4
    l.dbmp
    assert_equal 2,$game_map.casters.calls
    $game_map.casters.wcf_shadow_revision+=1
    l.dbmp
    assert_equal 3,$game_map.casters.calls
    l.instance_variable_set(:@h,7)
    l.dbmp
    assert_equal 4,$game_map.casters.calls
    l.restore
    l.dbmp
    assert_equal 5,$game_map.casters.calls
    $game_map.casters=CasterSpy.new
    l.dbmp
    assert_equal 1,$game_map.casters.calls
  end
  def test_directional_light_switches_image_and_invalidates_cache
    l=light(Light_MKSource,true)
    first=l.dbmp
    10.times { assert_same first,l.dbmp }
    l.char.direction=4
    l.refresh_xyh
    second=l.dbmp
    refute_same first,second
    assert_equal 2,$game_map.casters.calls
    l.char.direction=2
    l.refresh_xyh
    assert_same first,l.dbmp
    assert_equal 3,$game_map.casters.calls
  end
  def test_height_sampling_only_reads_each_point_once
    l=light
    before=$game_map.height_queries
    l.refresh_xyh
    assert_equal 2,$game_map.height_queries-before
  end
  def test_disposed_lights_can_be_saved_loaded_and_rebuild_their_shadow
    [light,light(Light_MKSource,true)].each do |source|
      source.dbmp
      source.dispose
      restored=Marshal.load(Marshal.dump(source))
      assert_equal source.char.real_x,restored.char.real_x
      assert_nil restored.instance_variable_get(:@bitmap)
      restored.restore
      before=$game_map.casters.calls
      refute restored.dbmp.disposed?
      assert_equal before+1,$game_map.casters.calls
    end
  end
  def test_weather_cleanup_preserves_a_texture_used_by_another_particle
    texture=Bitmap.new
    sprites=2.times.map { s=Sprite.new; s.bitmap=texture; s }
    weather=Weather_EX.allocate
    weather.instance_variable_set(:@wp,sprites[0])
    weather.dispose_weather
    weather.dispose_weather
    refute sprites[1].bitmap.disposed?
    assert sprites[0].disposed?
  end
  def test_event_labels_are_disposed_on_each_scene_exit
    10.times do
      scene=Scene_Map.new
      windows=[WindowSpy.new,WindowSpy.new]
      scene.instance_variable_set(:@event_text_windows,windows.dup)
      scene.terminate
      assert windows.all?(&:disposed?)
      assert scene.terminated
      scene.dispose_text_event_windows
      scene.update_text_window
    end
  end
end
