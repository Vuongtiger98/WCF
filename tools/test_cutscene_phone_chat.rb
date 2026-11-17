# Shared theme, full-text reading, branch state and bitmap ownership regression.
require_relative 'test_phone_menu_layout'
module RPG
  class SE
    def initialize(*); end
    def play; end
  end
end
module Input
  class << self; attr_accessor :key; end
  def self.trigger?(key); @key==key; end
  def self.repeat?(key); trigger?(key); end
end
module Sound
  class << self; attr_accessor :buzzers; end
  def self.play_ok; end
  def self.play_cancel; end
  def self.play_cursor; end
  def self.play_buzzer; self.buzzers=(buzzers || 0)+1; end
end
module SceneManager
  class << self; attr_accessor :scene,:returned; end
  def self.background_bitmap; @background ||= Bitmap.new(640,480); end
  def self.snapshot_for_background; end
  def self.call(type); @scene=type.new; end
  def self.scene_is?(type); @scene.is_a?(type); end
  def self.return; self.returned=true; end
end
class Color
  def set(r,g,b,a=255); @red,@green,@blue,@alpha=r,g,b,a; end
end
class Rect
  def set(x,y,w,h); self.x,self.y,self.width,self.height=x,y,w,h; end
end
class Sprite
  def color; @color ||= Color.new; end
  def src_rect; @src_rect ||= Rect.new(0,0,bitmap.width,bitmap.height); end
end
class Game_Interpreter
  def command_355; GroupChatPreset.leo_shop_choice; end
end
load File.expand_path('../Scripts/Cutscene Group Chat.rb',__dir__)
class Scene_SimplePhoneChat
  include WCFPhoneDrawing
  class_eval(method_source(script_source('Custom Menu'),:apply_choice,-1))
end
class Game_SimplePhoneChat
  attr_accessor :selected_choice_value,:selected_choice_text,:selected_branch_entries
end
class CutscenePhoneChatTest < Minitest::Test
  def setup
    $game_temp=Game_Temp.new; $game_variables=Hash.new(0); $game_switches=Hash.new(false)
    Input.key=nil; SceneManager.returned=false
  end
  def teardown
    @scene.dispose_chat if @scene
    Input.key=nil
  end
  def start(preset=:market_recipient)
    GroupChatPreset.send(preset)
    @scene=SceneManager.scene
    @scene.start
    30.times {@scene.update}
    @scene
  end
  def press(key,choice=false)
    Input.key=key
    choice ? @scene.update_choice_input : @scene.update_message_input
  ensure
    Input.key=nil
  end
  def show_all
    500.times do
      break if @scene.instance_variable_get(:@visible_count)==@scene.instance_variable_get(:@active_entries).size &&
        @scene.instance_variable_get(:@scroll_y)==@scene.chat_max_scroll
      press(:C)
    end
  end
  def test_cutscene_and_history_share_drawing_font_wrap_and_phone_dimensions
    start
    assert_equal WCFPhoneDrawing,Scene_SimplePhoneChat.instance_method(:phone_text).owner
    assert_includes Scene_Menu.ancestors,WCFPhoneDrawing
    bg=@scene.instance_variable_get(:@phone_bg)
    assert_equal [336,460],[bg.bitmap.width,bg.bitmap.height]
    assert_equal [PhoneMenu::PHONE_X,PhoneMenu::PHONE_Y],[bg.x,bg.y]
    text="Ôi, những ngày cuối năm\n\n"+('tiếngViệt'.unicode_normalize(:nfd)*20)
    assert_equal Scene_Menu.new.pmgc_wrap_text(text,0),@scene.phone_wrap_text(text,194,17)
  end
  def test_opening_closing_move_all_phone_parts_together_and_keep_backdrop_fixed
    start
    home=@scene.chat_parts.map {|s|s.y}
    backdrop=@scene.instance_variable_get(:@dim)
    @scene.return_scene
    15.times {@scene.update}
    offsets=@scene.chat_parts.zip(home).map {|s,y|s.y-y}
    assert offsets.all? {|x|x==offsets.first}
    assert_operator offsets.first,:>,0
    assert_equal 0,backdrop.y
    refute SceneManager.returned
    15.times {@scene.update}
    assert SceneManager.returned
  end
  def test_long_message_starts_at_top_and_z_pages_before_revealing_next_entry
    chat=Game_SimplePhoneChat.new
    chat.add_actor(:quy,'Hải Quỳ','Contact_Quy')
    original='Hải Quỳ đọc đầy đủ tin nhắn có dấu. '*70
    chat.add_text(:quy,original,:right); chat.add_text(:quy,'Tin sau',:right)
    $game_temp.group_chat_data=chat
    @scene=Scene_SimplePhoneChat.new; @scene.start; 30.times {@scene.update}
    press(:C)
    assert_equal 0,@scene.instance_variable_get(:@scroll_y)
    assert_operator @scene.chat_max_scroll,:>,@scene.chat_content_height
    press(:C)
    assert_equal 1,@scene.instance_variable_get(:@visible_count)
    assert_operator @scene.instance_variable_get(:@scroll_y),:>,0
    show_all
    assert_equal 2,@scene.instance_variable_get(:@visible_count)
    assert_equal original,chat.entries[0][:text]
  end
  def test_required_choices_keep_switch_variable_and_selected_branch_side_effects
    start
    $game_temp.group_chat_data.choices[3][:switch]=99
    show_all; press(:B)
    refute SceneManager.returned
    assert_equal 0,$game_variables[43]
    press(:C)
    assert @scene.instance_variable_get(:@choice_active)
    3.times {press(:DOWN,true)}
    press(:C,true)
    assert_equal 4,$game_variables[43]
    assert $game_switches[99]
    assert_equal 4,$game_temp.group_chat_result
    assert_equal 4,$game_temp.group_chat_data.selected_choice_value
    assert_same $game_temp.group_chat_data.choice_branches[4],$game_temp.group_chat_data.selected_branch_entries
    refute @scene.instance_variable_get(:@choice_active)
  end
  def test_four_choice_list_scrolls_to_last_option_without_covering_messages
    start; show_all; press(:C)
    3.times {press(:DOWN,true)}
    rows=@scene.instance_variable_get(:@choice_rows)
    assert_includes rows.map {|r|r[:index]},3
    top=@scene.instance_variable_get(:@choice_top)
    assert_operator 96+@scene.chat_message_height,:<,top
    assert_operator top+rows.sum {|r|r[:height]+8}+22,:<=,PhoneMenu::PHONE_HEIGHT-46
  end
  def test_each_preset_uses_the_same_scene_and_has_full_width_message_layouts
    [:christmas_test,:market_recipient,:noodle_recipient,:leo_shop_choice,:shylvie_jewel_invite,:atlantis_chase_ending].each do |preset|
      @scene.dispose_chat if @scene
      start(preset); show_all
      @scene.chat_draw_data[:entries].each do |row|
        next if row[:type]==:system
        assert_operator row[:x],:>=,0
        assert_operator row[:x]+row[:width],:<=,288
        next unless row[:lines]
        row[:lines].each {|line|assert_operator @scene.simple_text_width(line,17),:<=,row[:width]-24}
      end
    end
  end
  def test_script_event_waits_for_chat_before_reading_its_route_result
    result=nil
    event=Fiber.new {Game_Interpreter.new.command_355; result=$game_variables[55]}
    event.resume
    assert_nil result
    @scene=SceneManager.scene; @scene.start; 30.times {@scene.update}
    show_all; press(:C)
    2.times {press(:DOWN,true)}
    press(:C,true)
    assert_nil result
    SceneManager.scene=Scene_Map.new
    event.resume
    assert_equal 3,result
  end
  def test_disposal_preserves_cached_artwork_and_shared_background
    start(:christmas_test); show_all
    cached=Cache.load_bitmap('Graphics/PhoneMenu/','MessageBackground')
    background=SceneManager.background_bitmap
    parts=@scene.chat_parts+[@scene.instance_variable_get(:@dim)]
    measure=@scene.instance_variable_get(:@phone_measure_bitmap)
    @scene.dispose_chat; @scene.dispose_chat
    assert parts.all? {|s|s.disposed? && s.bitmap.disposed?}
    assert measure.disposed?
    refute cached.disposed?
    refute background.disposed?
  end
end
