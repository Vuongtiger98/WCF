# frozen_string_literal: true

# Exercise real transition methods; no Game.exe, keyboard input, or native UI.
require_relative 'test_phone_menu_layout'

class Scene_Item; end unless defined?(Scene_Item)
class Scene_ItemLibrary; attr_accessor :wcf_phone_origin; end unless defined?(Scene_ItemLibrary)
class Scene_Save; end unless defined?(Scene_Save)
class Scene_Load; end unless defined?(Scene_Load)
class Scene_System; end unless defined?(Scene_System)
module SceneManager
  def self.call(type); @called=type; @scene=type.new; end
  def self.called; @called; end
  def self.scene; @scene; end
end
class Scene_Save; attr_accessor :wcf_phone_origin; end
class Scene_Load; attr_accessor :wcf_phone_origin; end
module Sound
  def self.play_cancel; end
end

class PhoneAnimationBase < Scene_Menu
  def start
    @background_sprite=surface(PhoneMenu::PHONE_Y)
    @phone_backdrop=surface(0)
  end
  def post_start; @base_post_started=true; end
  def update; end
end

class PhoneAnimationScene < PhoneAnimationBase
  source=File.read(ENV.fetch('WCF_PHONE_ANIMATION_SOURCE',File.join(ROOT,'Scripts/Custom Menu.rb')),encoding:'UTF-8')
  [:start,:post_start,:update,:update_opening_animation,:update_closing_animation,:start_closing,
   :leave_phone_scene,:hide_phone_base_sprites,:create_black_rectangle,:show_menu_sprites,:hide_menu_sprites].each do |name|
    class_eval(method_source(source,name),'Phone transition source')
  end
  attr_reader :input_updates,:returned,:base_post_started

  def initialize
    @animation_frame=@animation_timer=@phone_slide_offset=0
    @animation_state=:opening
    @selected_index=0
    @contacts_screen=@gallery_screen=false
    @input_updates=@returned=0
    @background_sprite=surface(PhoneMenu::PHONE_Y)
    @overlay=surface(PhoneMenu::PHONE_Y)
    @main_panel=surface(PhoneMenu::PHONE_Y)
    @phone_backdrop=surface(0)
    create_foreground
    create_black_rectangle
    hide_menu_sprites
    phone_apply_slide_offset(Graphics.height-PhoneMenu::PHONE_Y)
  end

  def surface(y)
    sprite=Sprite.new
    sprite.bitmap=Bitmap.new(PhoneMenu::PHONE_WIDTH,PhoneMenu::PHONE_HEIGHT)
    sprite.x=PhoneMenu::PHONE_X
    sprite.y=y
    sprite
  end

  def update_main_menu; @input_updates+=1; end
  def phone_menu_return_scene; @returned+=1; end
  def create_overlay; @overlay=surface(PhoneMenu::PHONE_Y); end
  def create_main_panel; @main_panel=surface(PhoneMenu::PHONE_Y); end
  def create_command_window; end
end

class PhoneMenuAnimationTest < Minitest::Test
  def setup
    $game_config=OpenStruct.new
    PerformanceOptimizationsTest::WIDGETS.each { |key| $game_config.send("phone_widget_#{key}=",key.to_s) }
    $phone_menu_selected_index=2
    SceneManager.instance_variable_set(:@stack,[Scene_Map.new])
  end

  def sprite(scene,name); scene.instance_variable_get(name); end
  def state(scene); scene.instance_variable_get(:@animation_state); end

  def test_fresh_menu_starts_offscreen_without_an_app_resume_marker_regardless_of_caller
    [Scene_Map.new,Scene_Item.new,Scene_Save.new,Scene_Load.new,Scene_System.new].each do |previous|
      SceneManager.instance_variable_set(:@stack,[previous])
      scene=PhoneAnimationScene.new
      refute sprite(scene,:@black_rectangle).visible, 'No stationary black plate during scene transition'
      scene.post_start
      assert scene.base_post_started
      assert_equal :opening,state(scene)
      assert_equal Graphics.height,sprite(scene,:@background_sprite).y
      assert sprite(scene,:@main_panel).visible
      assert sprite(scene,:@icon_sprites).all?(&:visible)
      assert_equal 2,scene.instance_variable_get(:@selected_index)
    end
  end

  def test_whole_phone_slides_in_and_finishes_at_its_original_alignment
    scene=PhoneAnimationScene.new
    scene.post_start
    before=scene.phone_visual_sprites.to_h { |part| [part,part.y] }
    15.times { scene.update }
    assert_equal :opening,state(scene)
    offset=scene.instance_variable_get(:@phone_slide_offset)
    assert_operator offset,:>,0
    assert_operator offset,:<,Graphics.height-PhoneMenu::PHONE_Y
    delta=offset-(Graphics.height-PhoneMenu::PHONE_Y)
    before.each { |part,y| assert_equal y+delta,part.y }
    assert_equal 0,sprite(scene,:@phone_backdrop).y
    15.times { scene.update }
    assert_equal :idle,state(scene)
    assert_equal 0,scene.instance_variable_get(:@phone_slide_offset)
    assert_equal PhoneMenu::PHONE_Y,sprite(scene,:@background_sprite).y
    assert_equal PhoneMenu::PHONE_Y,sprite(scene,:@main_panel).y
    refute sprite(scene,:@black_rectangle).visible
  end

  def test_input_is_ignored_until_the_opening_animation_is_complete
    scene=PhoneAnimationScene.new
    scene.post_start
    30.times { scene.update }
    assert_equal 0,scene.input_updates
    scene.update
    assert_equal 1,scene.input_updates
  end

  def test_closing_still_slides_out_then_disposes_and_returns_once
    scene=PhoneAnimationScene.new
    scene.post_start
    30.times { scene.update }
    parts=scene.phone_visual_sprites
    scene.start_closing
    15.times { scene.update }
    assert_equal :closing,state(scene)
    assert_equal 0,scene.returned
    assert_operator sprite(scene,:@background_sprite).y,:>,PhoneMenu::PHONE_Y
    15.times { scene.update }
    assert_equal Graphics.height-PhoneMenu::PHONE_Y,scene.instance_variable_get(:@phone_slide_offset)
    assert_equal 1,scene.returned
    assert parts.all?(&:disposed?)
    assert scene.instance_variable_get(:@phone_menu_disposed)
  end

  def test_real_start_resumes_same_menu_from_each_app_without_sliding_again
    [Scene_ItemLibrary,Scene_Save,Scene_Load,Scene_System].each do |type|
      scene=PhoneAnimationScene.new
      scene.start
      scene.post_start
      assert_equal :opening,state(scene)
      30.times { scene.update }
      scene.leave_phone_scene(type)
      assert_equal type,SceneManager.called
      assert_equal :phone,SceneManager.scene.wcf_phone_origin if SceneManager.scene.respond_to?(:wcf_phone_origin)
      assert scene.instance_variable_get(:@phone_app_suspended)
      # Real Scene_Base freezes the visible frame before terminate cleans it.
      scene.dispose_phone_menu_sprites
      scene.start
      scene.post_start
      assert_equal :idle,state(scene)
      assert_equal 0,scene.instance_variable_get(:@phone_slide_offset)
      assert_equal PhoneMenu::PHONE_Y,sprite(scene,:@background_sprite).y
      refute scene.instance_variable_get(:@phone_app_suspended)
      refute scene.instance_variable_get(:@phone_menu_disposed)
      before=scene.input_updates
      scene.update
      assert_equal before+1,scene.input_updates
    end
  end

  def test_a_new_menu_after_abandoning_an_app_still_slides_in
    old=PhoneAnimationScene.new
    old.start
    old.leave_phone_scene(Scene_Save)
    fresh=PhoneAnimationScene.new
    fresh.start
    fresh.post_start
    assert_equal :opening,state(fresh)
    assert_equal Graphics.height,sprite(fresh,:@background_sprite).y
  end

  def test_switching_apps_keeps_the_rendered_phone_until_scene_termination
    [Scene_Save,Scene_Load,Scene_ItemLibrary,Scene_System].each do |type|
      scene=PhoneAnimationScene.new
      scene.start
      scene.post_start
      30.times { scene.update }
      shown=scene.phone_visual_sprites.select { |part| part.visible && part.opacity > 0 }
      refute_empty shown
      scene.leave_phone_scene(type)
      assert shown.all? { |part| part.visible && !part.disposed? },
        'Do not hide/dispose the phone before Scene_Base freezes its last frame'
      refute scene.instance_variable_get(:@phone_menu_disposed)
      scene.dispose_phone_menu_sprites
      assert shown.all?(&:disposed?)
    end
  end
end
