# encoding: UTF-8
# Isolated native save + UI command QA. No keyboard/mouse automation.
module Graphics
  def self.update; self.frame_count+=1; end
  def self.transition(*); self.brightness=255; end
  def self.freeze; end
  def self.wait(n); n.times {update}; end
  def self.fadeout(*); end
end
module Input
  class << self; attr_accessor :qa_key; end
  def self.update; end
  def self.trigger?(key); @qa_key==key; end
  def self.repeat?(key); trigger?(key); end
  def self.press?(*); false; end
  def self.dir4; 0; end
  def self.dir8; 0; end
end
module UnreadNativeQA
  class << self; attr_accessor :started,:done,:checks; end
  self.checks=0
  def self.log(text)
    File.open('unread-native.log','ab') {|f|f.write(text.to_s+"\r\n")}
  end
  def self.assert(ok,text)
    raise text unless ok
    self.checks+=1; log('PASS '+text)
  end
  def self.shot(name)
    bmp=Graphics.snap_to_bitmap; bmp.save('captures/'+name+'.png'); bmp.dispose
  end
  def self.key(scene,key,list=false)
    Input.qa_key=key
    list ? scene.update_contact_selection : scene.update_message_view
    scene.update_phone_unread
  ensure
    Input.qa_key=nil
  end
  def self.read_end(scene,kind,id)
    500.times do
      break unless $game_config.phone_unread?(kind,id)
      key(scene,:DOWN)
    end
    assert(!$game_config.phone_unread?(kind,id),'read to actual final page clears only that thread')
  end
  def self.run(scene)
    PhoneMenu::CONTACTS.clear
    $game_config.clear_phone_group_chats
    PhoneMenu::CONTACTS[1]=['Momo','Má của Hải Quỳ.',[]]
    PhoneMenu::CONTACTS[2]=['Popo','Ba của Hải Quỳ.',[]]
    15.times {|i|$game_config.add_message(1,'Tin nhắn mới thứ '+(i+1).to_s)}
    $game_config.add_message(1,'Tin dài cần đọc tới phần cuối, dấu tiếng Việt vẫn đủ. '*55)
    $game_config.add_message(2,'Tin ngắn đọc được ngay.')
    scene.update_phone_unread
    badge=scene.instance_variable_get(:@phone_unread_badge)
    assert(badge.visible,'unread dot is visible on main Messages icon')
    shot('01-main-unread')
    scene.command_contacts
    shot('02-chat-list-unread')
    key(scene,:C,true)
    assert($game_config.phone_unread?(:normal,1),'opening a long conversation does not clear unread')
    shot('03-new-message-boundary')
    key(scene,:B)
    assert($game_config.phone_unread?(:normal,1),'leaving early keeps unread')
    key(scene,:DOWN,true)
    key(scene,:C,true)
    assert(!$game_config.phone_unread?(:normal,2),'short visible conversation is read')
    assert($game_config.phone_unread?(:normal,1),'reading second thread preserves first unread')
    key(scene,:B)
    key(scene,:UP,true)
    key(scene,:C,true)
    # Reach the last long message but stop on its first part.
    15.times {key(scene,:DOWN)}
    assert($game_config.phone_unread?(:normal,1),'first part of last long message is not enough')
    shot('04-long-first-part')
    read_end(scene,:normal,1)
    shot('05-long-final-part')
    key(scene,:B)
    key(scene,:B,true)
    assert(!badge.visible,'icon dot disappears when all threads are read')
    shot('06-main-read')
    $game_config.add_message(1,'Lại có một tin mới!')
    scene.update_phone_unread
    assert(badge.visible,'script add_message brings icon dot back')
    shot('07-new-arrival')
    assert(DataManager.save_game(0),'save A with new incoming message')
    DataManager.setup_new_game
    assert(PhoneMenu::CONTACTS.empty? && $game_config.phone_unread_count==0,'New Game has its own empty phone state')
    PhoneMenu::CONTACTS[2]=['Popo','Bản lưu B',[]]
    $game_config.add_message(2,'Chỉ có ở save B')
    assert(DataManager.save_game(1),'save B independently')
    assert(DataManager.load_game(0),'load save A')
    assert(PhoneMenu::CONTACTS[1][2][-1][1]=='Lại có một tin mới!','A restores its own conversation')
    assert($game_config.phone_unread?(:normal,1),'A restores unread state')
    scene.update_phone_unread
    shot('08-loaded-A')
    last=PhoneMenu::CONTACTS[1][2][-1][2]
    $game_config.phone_mark_read(:normal,1,last)
    assert(DataManager.save_game(0),'save A after reading')
    assert(DataManager.load_game(1),'load B after reading A')
    assert(!PhoneMenu::CONTACTS[1] && PhoneMenu::CONTACTS[2][2][-1][1]=='Chỉ có ở save B','B never inherits A contact data')
    assert($game_config.phone_unread?(:normal,2),'reading A did not clear B unread')
    assert(DataManager.load_game(0) && $game_config.phone_unread_count==0,'A read state survives a real save/load')
    PhoneGroupChatSave.add_text(:quy,'Tôi gửi đi',:right)
    PhoneGroupChatSave.add_choice_result('Tôi chọn rồi',1)
    assert($game_config.phone_unread_count==0,'own messages and choices do not notify')
    PhoneGroupChatSave.add_image(:leo,'CG22')
    PhoneGroupChatSave.add_system('Có thông báo mới trong nhóm')
    scene.update_phone_unread
    assert(badge.visible && $game_config.phone_unread_count==2,'group image and system entry notify')
    scene.command_contacts
    key(scene,:DOWN,true); key(scene,:DOWN,true)
    key(scene,:C,true)
    shot('09-group-image-unread')
    read_end(scene,:group,:wanderer_group)
    key(scene,:B); key(scene,:B,true)
    assert(!badge.visible,'badge clears after reading group images and notices')
    # Replacing a transcript with equal length still detects different content.
    rows=[{:type=>:text,:sender=>:leo,:text=>'Phiên bản một',:side=>nil}]
    $game_config.replace_phone_transcript(:wanderer_group,rows,{0=>true})
    $game_config.replace_phone_transcript(:wanderer_group,rows,{})
    assert($game_config.phone_unread_count==0,'same archive never becomes new again')
    rows[0][:text]='Phiên bản hai'
    $game_config.replace_phone_transcript(:wanderer_group,rows,{})
    assert($game_config.phone_unread_count==1,'changed equal-length archive is new')
    WCFTestHub.prepare(:market_prep,:variables=>{42=>3,43=>3})
    assert($game_config.phone_unread_count==0,'Test Hub restores historical chat as read')
    File.open('completion.marshal','wb') {|f|f.write(Marshal.dump({:checks=>checks,:complete=>true}))}
    log('COMPLETE checks='+checks.to_s)
    self.done=true
    SceneManager.exit
  end
end
class << SceneManager
  alias unread_qa_run run
  def run
    unread_qa_run
  rescue Exception => e
    UnreadNativeQA.log('FAIL '+e.class.to_s+': '+e.message+"\r\n"+e.backtrace.join("\r\n"))
    exit
  end
  def first_scene_class
    DataManager.setup_new_game
    WCFTestHub.prepare(:silverwing)
    $game_map.setup(3); $game_player.moveto(4,4)
    Scene_Map
  end
end
class Scene_Map
  alias unread_qa_start start
  def start
    unread_qa_start
    return if UnreadNativeQA.started
    UnreadNativeQA.started=true
    SceneManager.snapshot_for_background
    SceneManager.call(Scene_Menu)
  end
end
class Scene_Menu
  alias unread_qa_post_start post_start
  def post_start
    unread_qa_post_start
    30.times {update_opening_animation}
    UnreadNativeQA.run(self)
  end
end
