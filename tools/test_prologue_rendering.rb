# Regression tests for shared map effects, balloons and pop readability.
require_relative 'test_performance_optimizations'
module SceneManager
  class << self; attr_accessor :scene; end
end
class Viewport
  attr_accessor :rect,:ox,:oy,:visible
  def initialize(rect); @rect=rect; @ox=@oy=0; @visible=false; end
end
class Sprite
  attr_accessor :viewport,:width,:height
end
class EffectRendererProbe
  source=script_source('Map effects')
  [:update,:wcf_screen_point,:wcf_source_vector,:wcf_source_viewport?,:wcf_output_rect].each {|name|class_eval(method_source(source,name))}
  attr_reader :refreshes,:disposals
  def initialize(source_rect,output_rect,data)
    @map_viewports=[Viewport.new(source_rect)]; @viewport=Viewport.new(output_rect)
    @data=data; @effects_bitmaps=[:existing]; @effects_sprites=[OpenStruct.new(wave_phase:0)]
    @refreshes=@disposals=0
  end
  def refresh_sprites; end
  def refresh_bitmaps; @refreshes+=1; end
  def refresh_pixelize; end
  def refresh_back; end
  def update_effects(*); end
  def dispose(*); @disposals+=1; @viewport.visible=false; end
end
class BalloonProbe
  source=script_source('Sprite_Character')
  [:wcf_keep_balloon_in_view,:wcf_clamp_balloon_rect,:wcf_balloon_target_visible?].each {|name|class_eval(method_source(source,name))}
  attr_accessor :x,:y,:ox,:oy,:width,:height,:zoom_x,:zoom_y
  def initialize(balloon)
    @balloon_sprite=balloon; @x=balloon.x; @y=balloon.y+48
    @ox=16; @oy=48; @width=32; @height=48; @zoom_x=@zoom_y=1.0
  end
end
class PopBackdropProbe
  source=script_source('Pop Message')
  class_eval(method_source(source,:update_wcf_pop_backdrop))
  class_eval(method_source(source,:dispose))
  attr_accessor :visible,:openness,:width,:height,:x,:y,:z
  attr_reader :disposed
  def initialize
    @visible=true; @openness=255; @width=400; @height=120; @x=100; @y=80; @z=200
  end
  def wcf_pop_readability_dispose; @disposed=true; end
end
class PrologueRenderingTest < Minitest::Test
  def setup
    # Inherited performance tests also use $game_map. Start with an isolated
    # scene/map instead of depending on the randomized order of test classes.
    SceneManager.scene=nil; $game_map=nil
  end
  def data
    d=OpenStruct.new(active?:true,refresh_motion_blur?:false,refresh_bitmap?:false,
      tilemap_wave_sync:0,blur_animation_offset:0,zoom_x:1.3,zoom_y:1.3,
      x:320,y:240,ox:320,oy:240,angle:0,mirror:false)
    def d.tilemap_wave_sync(*); 0; end
    d
  end
  def teardown
    SceneManager.scene=nil; $game_map=nil
  end
  def test_transfer_resizes_even_when_snapshot_refresh_is_frozen
    r=EffectRendererProbe.new(Rect.new(0,0,640,480),Rect.new(48,32,544,416),data)
    r.update
    assert_equal [0,0,640,480],r.wcf_output_rect.to_a
    assert_equal 1,r.refreshes
    r.update
    assert_equal 1,r.refreshes
  end
  def test_inactive_small_map_transfer_is_synchronized_before_reactivation
    d=data; d[:active?]=false
    r=EffectRendererProbe.new(Rect.new(48,32,544,416),Rect.new(0,0,640,480),d)
    r.update
    assert_equal [48,32,544,416],r.wcf_output_rect.to_a
    assert_equal 0,r.refreshes
    d[:active?]=true; r.update
    assert_equal 1,r.refreshes
  end
  def test_point_and_vector_include_viewport_and_invert_zoom_rotation_mirror
    d=data; d.angle=31; d.mirror=true
    r=EffectRendererProbe.new(Rect.new(48,32,544,416),Rect.new(48,32,544,416),d)
    center=r.wcf_screen_point(320,240)
    assert_equal [368.0,272.0],center
    p=r.wcf_screen_point(400,210)
    v=r.wcf_source_vector(p[0]-center[0],p[1]-center[1])
    assert_in_delta 80,v[0],0.001
    assert_in_delta(-30,v[1],0.001)
  end
  def test_positive_rgss_angle_turns_a_right_hand_point_up
    d=data; d.angle=90
    r=EffectRendererProbe.new(Rect.new(48,32,544,416),Rect.new(48,32,544,416),d)
    x,y=r.wcf_screen_point(400,240)
    assert_in_delta 368,x,0.001
    assert_in_delta 168,y,0.001
  end
  def balloon(vp,x,y)
    b=Sprite.new; b.viewport=vp; b.x=x; b.y=y; b.ox=16; b.oy=32; b.width=b.height=32; b
  end
  def test_balloon_is_clamped_to_source_and_zoomed_output_without_moving_actor
    d=data
    r=EffectRendererProbe.new(Rect.new(0,0,640,480),Rect.new(0,0,640,480),d)
    vp=r.instance_variable_get(:@map_viewports)[0]
    b=balloon(vp,320,20)
    SceneManager.scene=OpenStruct.new
    set=Object.new; set.instance_variable_set(:@map_effects,r)
    SceneManager.scene.instance_variable_set(:@spriteset,set)
    $game_map=OpenStruct.new(effects:d)
    BalloonProbe.new(b).wcf_keep_balloon_in_view
    p=r.wcf_screen_point(b.x-b.ox,b.y-b.oy)
    assert_operator b.y-b.oy,:>=,0
    assert_operator p[1],:>=,1.9
    assert_equal 320,b.x
  end
  def test_balloon_works_on_small_map_without_active_effects
    vp=Viewport.new(Rect.new(48,32,544,416)); b=balloon(vp,0,0)
    BalloonProbe.new(b).wcf_keep_balloon_in_view
    assert_operator b.x+48-b.ox,:>=,50
    assert_operator b.y+32-b.oy,:>=,34
  end
  def test_offscreen_character_balloon_is_not_pulled_onto_the_screen
    vp=Viewport.new(Rect.new(0,0,640,480)); b=balloon(vp,800,100)
    BalloonProbe.new(b).wcf_keep_balloon_in_view
    assert_equal [800,100],[b.x,b.y]
  end
  def test_empty_parallax_anchor_still_gets_a_visible_balloon
    vp=Viewport.new(Rect.new(0,0,640,480)); b=balloon(vp,320,4)
    p=BalloonProbe.new(b); p.width=p.height=p.ox=p.oy=0
    p.x=320; p.y=20; p.wcf_keep_balloon_in_view
    assert_operator b.y-b.oy,:>=,2
  end
  def test_player_pop_zero_owns_one_backdrop_and_cleans_it_up
    w=PopBackdropProbe.new; w.instance_variable_set(:@pop_message_id,0)
    w.update_wcf_pop_backdrop
    bg=w.instance_variable_get(:@wcf_pop_backdrop)
    assert bg.visible
    assert_equal [108,88,199],[bg.x,bg.y,bg.z]
    20.times {w.update_wcf_pop_backdrop}
    assert_same bg,w.instance_variable_get(:@wcf_pop_backdrop)
    w.instance_variable_set(:@pop_message_id,nil); w.update_wcf_pop_backdrop
    refute bg.visible
    w.dispose
    assert bg.disposed?
    assert bg.bitmap.disposed?
    assert w.disposed
  end
end
