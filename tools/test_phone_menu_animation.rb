# frozen_string_literal: true

# Exercise real transition methods; no Game.exe, keyboard input, or native UI.
require_relative 'test_phone_menu_layout'

class Scene_Item; end unless defined?(Scene_Item)
class Scene_Save; end unless defined?(Scene_Save)
class Scene_Load; end unless defined?(Scene_Load)
class Scene_System; end unless defined?(Scene_System)
module SceneManager; end
module Sound
  def self.play_cancel; end
end

class PhoneAnimationBase < Scene_Menu
  def post_start; @base_post_started=true; end
  def update; end
end

class PhoneAnimationScene < PhoneAnimationBase
  source=File.read(ENV.fetch('WCF_PHONE_ANIMATION_SOURCE',File.join(ROOT,'Scripts/Custom Menu.rb')),encoding:'UTF-8')
  [:post_start,:update,:update_opening_animation,:update_closing_animation,:start_closing,
   :create_black_rectangle,:show_menu_sprites,:hide_menu_sprites].each do |name|
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

  def test_opening_from_map_and_each_subscene_always_starts_offscreen
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
end
