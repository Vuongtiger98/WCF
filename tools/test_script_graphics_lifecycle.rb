# frozen_string_literal: true

# Behavioral regression checks against the real edited methods with minimal
# RGSS stand-ins. This does not simulate KUL, rendering, audio, or Game.exe.
require 'ostruct'
require 'minitest/autorun'
require 'zlib'

class FakeBitmap
  attr_reader :dispose_count
  def initialize
    @dispose_count = 0
  end
  def dispose
    raise 'bitmap disposed twice' if disposed?
    @dispose_count += 1
  end
  def disposed?; @dispose_count > 0; end
  def width; raise 'disposed bitmap' if disposed?; 128; end
  def height; width; end
end

class Sprite
  attr_accessor :bitmap
  def dispose; @disposed = true; end
  def disposed?; !!@disposed; end
end
class Plane < Sprite; end
module DekitaParticles; end
module Cache
  def self.layers(_name); @shared ||= FakeBitmap.new; end
end
module SceneManager
  class << self
    def call(_scene); end
    def goto(_scene); end
    def scene_is?(_scene); false; end
  end
end
class Scene_Battle; end
class Game_Temp
  def initialize; end
end
class Game_System
  def initialize; end
end
class Game_Map
  def setup(_id); end
end
class Scene_Base
  def terminate; end
end
class Sprite_Base < Sprite
  @@_reference_count = {}
  def dispose_animation; end
  def self.test_references(bitmap, count); @@_reference_count[bitmap] = count; end
end

root = File.expand_path('..', __dir__)
baseline = ARGV.delete('--baseline')
archive = baseline && Marshal.load(File.binread(File.join(root, 'Data/codex_backup_scripts_review_20261030/Scripts.rvdata2')))
read_script = lambda do |name|
  if archive
    Zlib::Inflate.inflate(archive.find { |e| e[1].strip == name.strip }[2]).force_encoding('UTF-8')
  else
    File.read(File.join(root, 'Scripts', name + '.rb'), encoding: 'UTF-8')
  end
end
source = read_script.call("Galv's Layer Graphics")
eval(source[source.index('class Layer_Graphic < Plane')..-1], TOPLEVEL_BINDING, 'Layer_Graphic')
source = read_script.call('Particles')
first = source.index('class Particle_Core < Sprite')
last = source.index('class Particle_Spriteset', first)
eval(source[first...last], TOPLEVEL_BINDING, 'Particle_Core')
eval(read_script.call('anti-animation lag'), TOPLEVEL_BINDING, 'anti-animation lag')

class ScriptGraphicsLifecycleTest < Minitest::Test
  def setup
    $game_map = OpenStruct.new(layers: {0=>[]}, display_x: 3, display_y: 7)
    $game_temp = Game_Temp.new
    $game_system = Game_System.new
  end

  def test_disposing_one_layer_preserves_another_using_the_same_cached_bitmap
    bitmap = FakeBitmap.new
    first = Layer_Graphic.allocate
    first.bitmap = bitmap
    first.instance_variable_set(:@id, 2)
    first.instance_variable_set(:@movedx, 11)
    first.instance_variable_set(:@movedy, 23)
    second = Layer_Graphic.allocate
    second.bitmap = bitmap
    first.dispose
    first.dispose
    assert first.disposed?
    assert_equal 128, second.bitmap.width
    assert_equal 0, bitmap.dispose_count
    assert_equal [11,23], $game_map.layers[0][2]
  end

  def test_layer_yoffset_uses_vertical_camera_position
    layer = Layer_Graphic.allocate
    layer.instance_variable_set(:@id, 2)
    layer.instance_variable_set(:@layers, {2=>['same',0,0,255,0,0,4,6]})
    assert_equal 12, layer.xoffset
    assert_equal 42, layer.yoffset
  end

  def test_layer_refresh_restores_saved_movement_instead_of_reading_layer_zero
    $game_map.layers[0][2] = [11.5,23.5]
    layer = Layer_Graphic.allocate
    layer.instance_variable_set(:@id, 2)
    layer.instance_variable_set(:@layers, {0=>['unrelated'],2=>['same']})
    layer.init_settings
    assert_equal 11.5, layer.instance_variable_get(:@movedx)
    assert_equal 23.5, layer.instance_variable_get(:@movedy)
  end

  def test_disposing_a_particle_preserves_the_cached_bitmap_and_is_idempotent
    bitmap = FakeBitmap.new
    particle = Particle_Core.allocate
    particle.bitmap = bitmap
    particle.dispose
    particle.dispose
    assert particle.disposed?
    assert_equal 128, bitmap.width
    assert_equal 0, bitmap.dispose_count
  end

  def test_animation_cleanup_before_new_game_does_not_require_game_temp
    $game_temp = nil
    SceneManager.dispose_animation_garbage
  end

  def test_queued_animation_reused_by_an_active_sprite_is_not_disposed
    bitmap = FakeBitmap.new
    Sprite_Base.test_references(bitmap, 1)
    $game_temp.animation_garbage = [bitmap,bitmap]
    SceneManager.dispose_animation_garbage
    assert_equal 128, bitmap.width
    assert_equal [bitmap], $game_temp.animation_garbage
    Sprite_Base.test_references(bitmap, 0)
    SceneManager.dispose_animation_garbage
    assert bitmap.disposed?
    assert_equal 1, bitmap.dispose_count
    assert_nil $game_temp.animation_garbage
  end

  def test_animation_cleanup_tolerates_previously_disposed_entries
    bitmap = FakeBitmap.new
    bitmap.dispose
    $game_temp.animation_garbage = [nil,bitmap]
    SceneManager.dispose_animation_garbage
    assert_equal 1, bitmap.dispose_count
    assert_nil $game_temp.animation_garbage
  end
end
