require_relative 'test_cutscene_phone_chat'
source=script_source('Custom Menu')
eval(source[/^module PhoneGroupChat\n.*?^end/m],TOPLEVEL_BINDING,'Phone group definitions')
source.scan(/^class Game_Config\n.*?^end/m).each {|code|eval(code,TOPLEVEL_BINDING,'Game_Config')}
source.scan(/^module PhoneGroupChatSave\n.*?^end/m).each {|code|eval(code,TOPLEVEL_BINDING,'PhoneGroupChatSave')}
class UnreadMenuProbe < Scene_Menu
  source=script_source('Custom Menu')
  [:pmgc_entries,:pmgc_current_entry,:show_contact_details,:update_message_view,
   :pmgc_draw_center_notice,:pmgc_draw_image_message,:create_contacts_sprites,
   :refresh_contacts,:show_contacts_sprites].each do |name|
    class_eval(method_source(source,name,-1))
  end
  def initialize
    @contacts_screen=@in_message_view=true; @animation_state=:idle
    @selected_contact=@contact_index=@message_index=@message_line_offset=0
    @contact_info=Sprite.new; @contact_info.bitmap=Bitmap.new(336,460)
    @contact_panels=[]; @contact_sprites=[]; @contact_names=[]; @contact_messages=[]
  end
  def restore_current_background; end
  def refresh_phone_background(*); end
  def set_overlay_opacity(*); end
  def draw_contacts_header; end
end
class PhoneUnreadTest < Minitest::Test
  def setup
    $game_config=Game_Config.new; $game_temp=Game_Temp.new
    $game_variables=Hash.new(0); $game_switches=Hash.new(false)
    Input.key=nil
  end
  def teardown
    @menu.dispose_phone_menu_sprites if @menu
    @chat_scene.dispose_chat if @chat_scene
    Input.key=nil
  end
  def register_contact(id=1)
    PhoneMenu::CONTACTS[id]=['Momo','Má của Hải Quỳ',[]]
  end
  def test_normal_contact_registry_and_unread_state_are_isolated_per_save
    register_contact; $game_config.add_message(1,'Tin A')
    saved=Marshal.dump($game_config)
    $game_config=Game_Config.new
    assert PhoneMenu::CONTACTS.empty?
    assert_equal 0,$game_config.phone_unread_count
    register_contact; $game_config.add_message(1,'Tin B')
    b=$game_config
    $game_config=Marshal.load(saved)
    assert_equal 'Tin A',PhoneMenu::CONTACTS[1][2][0][1]
    assert $game_config.phone_unread?(:normal,1)
    row=PhoneMenu::CONTACTS[1][2][-1]
    $game_config.phone_mark_read(:normal,1,row[2])
    assert_equal 0,$game_config.phone_unread_count
    $game_config=b
    assert_equal 'Tin B',PhoneMenu::CONTACTS[1][2][0][1]
    assert_equal 1,$game_config.phone_unread_count
  end
  def test_incoming_text_image_and_system_notify_but_own_messages_do_not
    register_contact
    $game_config.add_messages(1,[['Gửi đi',:main],['Tin mới',:contact]])
    PhoneGroupChatSave.add_text(:quy,'Tôi gửi',:right)
    PhoneGroupChatSave.add_choice_result('Tôi chọn',2)
    assert_equal 1,$game_config.phone_unread_count
    PhoneGroupChatSave.add_image(:leo,'CG22')
    PhoneGroupChatSave.add_system('Leo đã vào nhóm')
    assert_equal 3,$game_config.phone_unread_count
  end
  def test_read_watermark_does_not_clear_an_arrival_that_has_not_been_drawn
    PhoneGroupChatSave.add_text(:leo,'Một')
    old=$game_config.phone_group_chats[:wanderer_group][:messages][-1][:_phone_id]
    PhoneGroupChatSave.add_text(:leo,'Hai')
    $game_config.phone_mark_read(:group,:wanderer_group,old)
    assert_equal 1,$game_config.phone_unread_count
  end
  def test_reimport_same_history_keeps_ids_and_changed_same_length_is_new
    rows=[{type: :text,sender: :leo,text:'Một',side: nil}]
    $game_config.replace_phone_transcript(:wanderer_group,rows,{})
    id=$game_config.phone_group_chats[:wanderer_group][:messages][0][:_phone_id]
    $game_config.phone_mark_read(:group,:wanderer_group,id)
    $game_config.replace_phone_transcript(:wanderer_group,rows,{})
    assert_equal id,$game_config.phone_group_chats[:wanderer_group][:messages][0][:_phone_id]
    assert_equal 0,$game_config.phone_unread_count
    rows[0][:text]='Đã thay đổi'
    $game_config.replace_phone_transcript(:wanderer_group,rows,{})
    assert_equal 1,$game_config.phone_unread_count
    refute_equal id,$game_config.phone_group_chats[:wanderer_group][:messages][0][:_phone_id]
  end
  def test_clearing_and_readding_a_chat_does_not_reuse_a_read_id
    PhoneGroupChatSave.add_text(:leo,'Một')
    first=$game_config.phone_group_chats[:wanderer_group][:messages][0][:_phone_id]
    PhoneGroupChatSave.clear
    assert_equal 0,$game_config.phone_unread_count
    PhoneGroupChatSave.add_text(:leo,'Một')
    last=$game_config.phone_group_chats[:wanderer_group][:messages][0][:_phone_id]
    assert_operator last,:>,first
    assert_equal 1,$game_config.phone_unread_count
  end
  def test_group_template_is_not_mutated_by_checkpoint_or_another_save
    group=$game_config.ensure_group_chat('wanderer_group')
    group[:members].clear
    refute_empty PhoneGroupChat::GROUPS[:wanderer_group][:members]
    PhoneGroupChatSave.add_text(:leo,'Tin mới',nil,'wanderer_group')
    assert $game_config.phone_unread?(:group,'wanderer_group')
    assert $game_config.phone_unread?(:group,:wanderer_group)
  end
  def test_long_preview_uses_bounded_font_measurements
    bmp=Bitmap.new(288,24)
    calls=0; original=bmp.method(:text_size)
    bmp.define_singleton_method(:text_size) {|value|calls+=1;original.call(value)}
    Scene_Menu.new.phone_text(bmp,0,0,180,22,'Tiếng Việt'.unicode_normalize(:nfd)*2000,17)
    assert_operator calls,:<=,20
    assert_operator bmp.draws.last[-1],:<=,180
    assert bmp.draws.last[4].end_with?('…')
  end
  def test_short_chat_is_read_when_its_end_is_visible_and_new_add_notifies_again
    register_contact; $game_config.add_message(1,'Tin mới')
    @menu=UnreadMenuProbe.new
    @menu.show_contact_details
    assert_equal 1,$game_config.phone_unread_count
    @menu.update_phone_unread
    assert_equal 0,$game_config.phone_unread_count
    $game_config.add_message(1,'Tin tiếp theo')
    assert_equal 1,$game_config.phone_unread_count
  end
  def test_long_last_message_stays_unread_until_last_part_is_visible
    register_contact
    $game_config.add_message(1,'Đọc đủ nội dung tin nhắn dài. '*100)
    @menu=UnreadMenuProbe.new; @menu.show_contact_details; @menu.update_phone_unread
    assert_equal 1,$game_config.phone_unread_count
    assert_nil @menu.instance_variable_get(:@phone_read_candidate)
    500.times do
      break if $game_config.phone_unread_count==0
      Input.key=:DOWN; @menu.update_message_view; @menu.update_phone_unread
    end
    assert_equal 0,$game_config.phone_unread_count
    assert_operator @menu.instance_variable_get(:@message_line_offset),:>,0
  end
  def test_leaving_early_and_reading_another_thread_keeps_original_unread
    register_contact; register_contact(2)
    20.times {|i|$game_config.add_message(1,"Tin #{i}")}
    $game_config.add_message(2,'Tin của ba')
    @menu=UnreadMenuProbe.new; @menu.show_contact_details; @menu.update_phone_unread
    assert $game_config.phone_unread?(:normal,1)
    @menu.instance_variable_set(:@selected_contact,1)
    @menu.instance_variable_set(:@message_index,0)
    @menu.show_contact_details; @menu.update_phone_unread
    refute $game_config.phone_unread?(:normal,2)
    assert $game_config.phone_unread?(:normal,1)
  end
  def test_cutscene_revealed_but_unread_long_message_keeps_badge_after_archiving
    chat=Game_SimplePhoneChat.new
    chat.add_actor(:leo,'Leo','Contact_Leo')
    chat.add_text(:leo,'Tin nhắn rất dài, chưa đọc hết. '*80)
    chat.add_text(:leo,'Chưa xem tin này')
    $game_temp.group_chat_data=chat
    @chat_scene=Scene_SimplePhoneChat.new; @chat_scene.start
    30.times {@chat_scene.update}
    Input.key=:C; @chat_scene.update_message_input; Input.key=nil
    @chat_scene.track_phone_read_entries
    PhoneGroupChatSave.save_current_cutscene
    assert_equal 2,$game_config.phone_unread_count
    200.times do
      break if @chat_scene.instance_variable_get(:@scroll_y)==@chat_scene.chat_max_scroll
      Input.key=:C; @chat_scene.update_message_input; Input.key=nil
      @chat_scene.track_phone_read_entries
    end
    PhoneGroupChatSave.save_current_cutscene
    assert_equal 1,$game_config.phone_unread_count
    Input.key=:C; @chat_scene.update_message_input; Input.key=nil
    @chat_scene.track_phone_read_entries
    PhoneGroupChatSave.save_current_cutscene
    assert_equal 0,$game_config.phone_unread_count
  end
  def test_idle_cutscene_does_not_rescan_read_coverage_every_frame
    GroupChatPreset.shylvie_jewel_invite
    @chat_scene=SceneManager.scene; @chat_scene.start
    30.times {@chat_scene.update}
    Input.key=:C; @chat_scene.update_message_input; Input.key=nil
    @chat_scene.track_phone_read_entries
    calls=0; original=@chat_scene.method(:chat_draw_data)
    @chat_scene.define_singleton_method(:chat_draw_data) {calls+=1;original.call}
    100.times {@chat_scene.update}
    assert_equal 0,calls
  end
end
