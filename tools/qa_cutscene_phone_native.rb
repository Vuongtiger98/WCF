# encoding: UTF-8
# Native RGSS command QA only; injected into a copied pack, never production.
module Graphics
  def self.update; self.frame_count+=1; end
  def self.transition(*); self.brightness=255; end
  def self.freeze; end
  def self.wait(frames); frames.times {update}; end
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
module ChatNativeQA
  CASES = [[:christmas_test,0],[:market_recipient,0],[:market_recipient,1],
    [:market_recipient,2],[:market_recipient,3],[:leo_shop_choice,0],
    [:leo_shop_choice,1],[:leo_shop_choice,2],[:noodle_recipient,0],
    [:shylvie_jewel_invite,0],[:atlantis_chase_ending,0],[:long_text,0],[:event_wait,2],
    [:partial_text,0],[:partial_revealed,0],[:unopened,0]]
  class << self; attr_accessor :index,:pending,:rows,:counts,:phase,:long_pages; end
  self.index=0; self.pending=false; self.rows=[]; self.counts={}; self.long_pages=[]
  def self.log(text)
    File.open('chat-native.log','ab') { |f|f.write(text.to_s+"\r\n") }
  end
  def self.assert(ok,text)
    raise text unless ok
    log('PASS '+text)
  end
  def self.shot(name)
    bmp=Graphics.snap_to_bitmap; bmp.save('captures/'+name+'.png'); bmp.dispose
  end
  def self.press(scene,key,choice=false)
    Input.qa_key=key
    choice ? scene.update_choice_input : scene.update_message_input
  ensure
    Input.qa_key=nil
  end
  def self.begin_case
    preset,target=CASES[index]
    self.counts={}; self.phase=nil
    $game_variables[42]=3
    if [:long_text,:partial_text,:partial_revealed,:unopened].include?(preset)
      chat=Game_SimplePhoneChat.new
      chat.title='Leo'; chat.subtitle='Kiểm tra tin nhắn dài'
      chat.add_actor(:leo,'Leo','Contact_Leo')
      first=preset==:partial_revealed ? 'Tin đã xem đầy đủ' : ("Hải Quỳ cần đọc đủ tin nhắn, cả những dấu tiếng Việt.\n\n"*25)
      chat.add_text(:leo,first)
      chat.add_text(:leo,'Chưa xem tin tiếp theo')
      GroupChat.start(chat)
    elsif preset==:event_wait
      $game_variables[90]=0
      list=[RPG::EventCommand.new(355,0,['GroupChatPreset.leo_shop_choice']),
        RPG::EventCommand.new(355,0,['PhoneGroupChatSave.save_current_cutscene(:wanderer_group)']),
        RPG::EventCommand.new(355,0,['$game_variables[90]=GroupChat.result']),
        RPG::EventCommand.new]
      $game_map.interpreter.setup(list,0)
      $game_map.interpreter.update
      assert($game_variables[90]==0,'event has not read a result before chat opens')
    else
      GroupChatPreset.send(preset)
    end
    self.pending=true
    log('CASE '+index.to_s+' '+preset.to_s)
  end
  def self.tick(scene)
    chat=scene.instance_variable_get(:@chat)
    preset,target=CASES[index]
    anim=scene.instance_variable_get(:@chat_animation)
    if anim==:opening
      if scene.instance_variable_get(:@chat_animation_timer)==15 && index==0
        shot('00-opening')
      end
      return
    end
    return if anim==:closing
    if preset==:unopened || ([:partial_text,:partial_revealed].include?(preset) && scene.instance_variable_get(:@visible_count)==1)
      press(scene,:B)
      return
    end
    if !counts[:opened]
      counts[:opened]=true
      assert(scene.instance_variable_get(:@phone_bg).y==PhoneMenu::PHONE_Y,'phone is aligned after opening')
      assert(Scene_Menu.instance_method(:phone_text).owner==WCFPhoneDrawing,'menu shares drawing module')
      assert(scene.method(:phone_text).owner==WCFPhoneDrawing,'cutscene shares drawing module')
      assert($game_variables[90]==0,'event stays suspended while chat is visible') if preset==:event_wait
    end
    if scene.instance_variable_get(:@choice_active)
      unless counts[:choice]
        counts[:choice]=true
        target.times {press(scene,:DOWN,true)}
        shot('%02d-choices' % index)
        top=scene.instance_variable_get(:@choice_top)
        assert(96+scene.chat_message_height<top,'choices do not cover the message viewport')
        if chat.required_choice
          press(scene,:B,true)
          assert(scene.instance_variable_get(:@chat_animation)==:idle,'required choice cannot close with X')
        end
      end
      press(scene,:C,true)
      choice=chat.choices[target]
      assert($game_temp.group_chat_result==choice[:value],'choice result retained')
      if choice[:variable]
        assert($game_variables[choice[:variable][0]]==choice[:variable][1],'route variable retained')
      end
      assert(chat.selected_choice_value==choice[:value],'selected transcript branch retained')
      return
    end
    before=scene.instance_variable_get(:@visible_count)
    if preset==:long_text && before==1
      long_pages << scene.instance_variable_get(:@scroll_y)
      shot('11-long-page-'+long_pages.size.to_s) if long_pages.size<=2
    end
    if index==0 && before>0 && !counts[before]
      counts[before]=true
      entry=chat.entries[before-1]
      shot('01-image') if entry && entry[:type]==:image
      shot('01-conversation') if before==8
    end
    # Real input handlers page a long entry before revealing the next one.
    press(scene,:C)
  end
  def self.finish_case
    chat=$game_temp.group_chat_data
    preset,target=CASES[index]
    if preset==:event_wait
      $game_map.interpreter.update
      assert($game_variables[90]==3,'next real interpreter command sees selected route')
      assert($game_config.phone_group_chats[:wanderer_group][:messages].size==6,'event saves history after selected branch')
    end
    PhoneGroupChatSave.save_current_cutscene(:wanderer_group)
    saved=$game_config.phone_group_chats[:wanderer_group][:messages]
    expected=chat.entries.size
    expected+=1+chat.selected_branch_entries.size if chat.selected_choice_value
    assert(saved.size==expected,'saved full transcript including selected branch')
    unread=[:partial_text,:unopened].include?(preset) ? 2 : preset==:partial_revealed ? 1 : 0
    assert($game_config.phone_unread_count==unread,'only fully viewed cutscene entries are read')
    if preset==:long_text
      assert(long_pages.size>2 && long_pages.first==0 && long_pages.last>0,'long message paged from beginning')
      assert(chat.entries[0][:text].include?("\n\n"),'original explicit newlines retained')
    end
    rows << {:preset=>preset,:choice=>target,:saved=>saved.size,:unread=>unread}
    self.index+=1
    self.pending=false
  end
end
class << SceneManager
  alias chat_qa_run run
  def run
    chat_qa_run
  rescue Exception => e
    ChatNativeQA.log('FAIL '+e.class.to_s+': '+e.message+"\r\n"+e.backtrace.join("\r\n"))
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
  alias chat_qa_start start
  def start
    chat_qa_start
    ChatNativeQA.finish_case if ChatNativeQA.pending
    if ChatNativeQA.index==ChatNativeQA::CASES.size
      File.open('completion.marshal','wb') {|f|f.write(Marshal.dump(ChatNativeQA.rows))}
      ChatNativeQA.shot('12-returned-to-map')
      ChatNativeQA.log('COMPLETE cases='+ChatNativeQA.rows.size.to_s)
      SceneManager.exit
    else
      ChatNativeQA.begin_case
    end
  end
end
class Scene_SimplePhoneChat
  alias chat_qa_update update
  def update
    chat_qa_update
    ChatNativeQA.tick(self)
  end
  alias chat_qa_terminate terminate
  def terminate
    owned=chat_parts+[@dim]
    cached=Cache.load_bitmap('Graphics/PhoneMenu/',PhoneMenu::MESSAGE_BACKGROUND)
    chat_qa_terminate
    ChatNativeQA.assert(owned.all? {|s|s.disposed? && s.bitmap.disposed?},'all owned chat sprites and bitmaps disposed')
    ChatNativeQA.assert(!cached.disposed?,'cached phone artwork survives')
  end
end
