# encoding: UTF-8
# Command-driven native RGSS verification; no real user save is read or written.
module TransformQA
  class << self
    attr_accessor :checks, :frames, :case_id, :key
  end
  self.checks=0;self.frames={};self.case_id='setup';self.key=nil
  def self.log(text);File.open('native.log','ab'){|f|f.write(text.to_s+"\r\n")};end
  def self.assert(value,text)
    raise text unless value
    self.checks+=1;log('PASS '+text)
  end
  def self.shot(name)
    file=case_id+'-'+name+'.png'
    image=Graphics.snap_to_bitmap;image.save('captures/'+file);image.dispose
    file
  end
  def self.map_scene
    scene=Scene_Map.new
    SceneManager.instance_variable_set(:@scene,scene)
    scene.start
    scene
  end
  def self.sprite(scene)
    scene.spriteset.instance_variable_get(:@character_sprites).find{|s|s.character.equal?($game_player)}
  end
  def self.record(scene,tick,film)
    return unless film && tick%3==0
    (frames[case_id] ||= []) << {:tick=>tick,:image=>shot('%03d'%tick)}
  end
  def self.cast_and_choose(scene,id,cancel=false,film=false)
    self.case_id=id.to_s+(cancel ? '-cancel' : '')
    assert(TransformMagic.start_cast,'free roam starts 125 for '+case_id)
    tick=0
    while SceneManager.scene.equal?(scene) && tick<155
      scene.update;tick+=1
      record(scene,tick,film)
      assert(sprite(scene).color.alpha==255,'body reaches opaque magical colour') if tick==100
    end
    assert(tick==146,'125 finishes after 144 animation updates plus handoff')
    assert(TransformMagic.phase==:choose,'selector holds the transformation state')
    assert(TransformMagic.body_alpha==255,'body remains #FFBF9B across selector')
    assert(!sprite(scene).animation?,'125 is complete before map teardown')
    assert($game_temp.tm_snapshot && !$game_temp.tm_snapshot.disposed?,'final ring pose captured before disposal')
    selector=SceneManager.scene;scene.terminate;selector.start
    list=selector.instance_variable_get(:@forms)
    assert(list.map{|f|f.id}==[:riu,:gamemerr,:sanic,:diana],'selector has exactly four current forms')
    index=list.index{|entry|entry.id==id}
    index.times{self.key=:RIGHT;selector.update;self.key=nil}
    preview=selector.instance_variable_get(:@preview).bitmap
    assert(preview.equal?(Cache.picture('TFCard'+(index+1).to_s)),'correct TFCard selected')
    selector_file=shot('selector')
    if film
      frames[case_id] << {:tick=>146,:image=>selector_file}
      frames[case_id] << {:tick=>206,:image=>selector_file}
    end
    original_name=$game_party.leader.tm_original_character_name || $game_party.leader.character_name
    self.key=cancel ? :B : :C;selector.update;self.key=nil
    assert(TransformMagic.phase==:reveal,'confirm/cancel continues with 127')
    selector.terminate
    assert(!preview.disposed?,'closing selector preserves shared picture cache')
    scene=SceneManager.scene;scene.start
    assert(sprite(scene).color.alpha==255,'first map frame is masked, including the new form')
    assert(sprite(scene).animation?,'127 is alive on the final player sprite after Galv rebuild')
    assert(sprite(scene).animation.sprites.any?{|cell|cell.visible && cell.opacity>0},'127 pose zero is visible on the first returned map frame')
    expected=cancel ? original_name : TransformMagic.form(id).char_name
    assert($game_player.character_name==expected,'player uses exact selected character file')
    assert($game_variables[4]==0 && $game_party.leader.tm_original_character_name.nil?,'cancel restores original form and clears transformation state') if cancel
    last_alpha=255
    elapsed=0
    while TransformMagic.casting? && elapsed<105
      scene.update;elapsed+=1
      current=sprite(scene).color.alpha
      if elapsed==30
        cells=sprite(scene).instance_variable_get(:@animation).values
        assert(cells.any?{|animation|animation.id==127 && animation.sprites.any?{|cell|cell.visible && cell.opacity>0}},'127 rings/cards are actually visible during recovery')
      end
      assert(current<=last_alpha,'127 body colour fades monotonically') if elapsed%12==0
      last_alpha=current
      record(scene,206+elapsed,film)
    end
    assert(elapsed==98,'127 finishes after 96 animation updates plus margin')
    assert(sprite(scene).color.alpha==0,'body returns completely to normal')
    assert(!sprite(scene).animation? && $game_player.movable?,'animation cells and input lock are cleared')
    assert($game_temp.tm_snapshot.nil?,'selector snapshot was released')
    shot('finished')
    scene
  end
  def self.library_cards(locked)
    self.case_id=locked ? 'library-locked' : 'library-cards'
    previous=SceneManager.scene
    library=Scene_ItemLibrary.new
    library.wcf_phone_origin=:direct
    SceneManager.instance_variable_set(:@scene,library)
    library.start
    entries=library.instance_variable_get(:@lib_entries)
    assert(entries.size==49,'collection contains 45 existing entries and four cards')
    cards=entries.select{|entry|entry[:picture].to_s =~ /\ATFCard[1-4]\z/}
    assert(cards.size==4,'all four cards have collection entries')
    if locked
      assert(WCFItemLibrary.unlocked?('picture:tfcard1'),'Riu card is collected at new game')
      assert([2,3,4].all?{|n|!WCFItemLibrary.unlocked?('picture:tfcard'+n.to_s)},'unearned card artwork stays locked')
      library.instance_variable_set(:@lib_index,entries.index(cards[0]))
      library.lib_redraw;shot('grid')
    else
      cards.each_with_index do |entry,index|
        bmp=library.instance_variable_get(:@lib_panel).bitmap
        bmp.font.name=PhoneMenu::UI_FONT;bmp.font.size=17;bmp.font.bold=false
        lines=['']
        entry[:description].split(/\s+/).each do |word|
          trial=lines[-1].empty? ? word : lines[-1]+' '+word
          if bmp.text_size(trial).width<=170
            lines[-1]=trial
          else
            lines<<word
          end
        end
        assert(lines.size<=7,'approved description fits the actual font for card '+(index+1).to_s)
        library.instance_variable_set(:@lib_index,entries.index(entry))
        library.instance_variable_set(:@lib_mode,:detail)
        library.lib_redraw;shot('card-'+(index+1).to_s)
      end
    end
    library.terminate
    SceneManager.instance_variable_set(:@scene,previous)
  end
  def self.run
    log('BOOT Ruby '+RUBY_VERSION)
    DataManager.init;DataManager.setup_new_game
    $data_animations[125]=load_data('animation125.rvdata2')
    $data_animations[127]=load_data('animation127.rvdata2')
    $game_map.events.clear;$game_map.interpreter.clear
    $game_map.shadows.hide;$game_map.shadows.set_opacity(0)
    $game_player.transparent=false;$game_system.menu_disabled=false
    $game_party.leader.set_graphic('!$HaiQuy',0,$game_party.leader.face_name,$game_party.leader.face_index)
    $game_player.refresh;$game_player.moveto(10,8)
    assert(TransformMagic.unlocked_forms.map{|entry|entry.id}==[:riu],'new game starts with Riu only')
    library_cards(true)
    TransformMagic.unlock(:riu);TransformMagic.unlock(:gamemerr)
    assert(!TransformMagic.unlocked?(:sanic) && !TransformMagic.unlocked?(:diana),'Sanic and Diana stay locked until authored events')
    assert(!TransformMagic.unlock(:undefined_form),'unknown form cannot enter unlock storage')
    TransformMagic.unlock(:sanic);TransformMagic.unlock(:diana) # Local QA only.
    assert($data_animations[123].name.empty? && $data_animations[124].name.empty?,'obsolete database variants removed')
    assert($data_animations[125].frames.size==48 && $data_animations[127].frames.size==32,'both editable animation halves present')
    fish_map=load_data('Data/Map013.rvdata2')
    [97,98].each do |id|
      event=Game_Event.allocate
      event.instance_variable_set(:@map_id,13);event.instance_variable_set(:@id,id)
      page=fish_map.events[id].pages[3]
      [1,2,3,4].each do |value|
        $game_variables[4]=value
        assert(event.conditions_met?(page)==(value==1),'fish-only page matches form 1, not '+value.to_s)
      end
    end
    $game_variables[4]=0
    scene=map_scene
    [:riu,:gamemerr,:sanic,:diana].each_with_index do |id,index|
      scene=cast_and_choose(scene,id,false,true)
      assert($game_variables[4]==index+1,'form event variable matches '+id.to_s)
      assert($game_player.character_index==0,'single-character sheet index is zero')
      [2,4,6,8].each do |direction|
        $game_player.set_direction(direction);sprite(scene).update
        bitmap=Graphics.snap_to_bitmap;bitmap.dispose
        assert(sprite(scene).src_rect.y>=0,'direction '+direction.to_s+' uses real sheet row')
      end
    end
    scene=cast_and_choose(scene,:riu,true,false)
    self.case_id='scripted'
    actor=$game_party.leader
    code='tm_change_actor_graphic('+[actor.id,'!$HaiQuy',0,actor.face_name,actor.face_index].map{|p|p.inspect}.join(',')+')'
    $game_map.interpreter.setup([RPG::EventCommand.new(355,0,[code]),RPG::EventCommand.new(0)])
    elapsed=0
    begin
      scene.update;elapsed+=1
      assert(SceneManager.scene.equal?(scene),'scripted change never opens selector') if elapsed%60==0
    end while $game_map.interpreter.running? && elapsed<270
    assert(elapsed<270 && !TransformMagic.casting?,'scripted two-part change finishes')
    assert(actor.character_name=='!$HaiQuy' && sprite(scene).color.alpha==0,'scripted change restores the requested sprite and colour')
    assert($game_variables[4]==0 && actor.tm_original_character_name.nil?,'authored human outfit resets form and original-sprite bookkeeping')
    $game_map.interpreter.setup([RPG::EventCommand.new(355,0,['TransformMagic.request_cast']),RPG::EventCommand.new(0)])
    scene.update
    assert(!TransformMagic.casting? && $game_temp.tm_requested_map,'Hub request waits for the interpreter final yield')
    scene.update
    assert(TransformMagic.phase==:cast && $game_temp.tm_requested_map.nil?,'Hub request starts only after the event finishes')
    TransformMagic.finish(scene)
    self.case_id='interrupt'
    TransformMagic.start_cast;20.times{scene.update}
    $game_message.add('interrupt');TransformMagic.update_map
    assert(!TransformMagic.casting? && sprite(scene).color.alpha==0,'dialogue interruption restores colour and clears cells')
    $game_message.clear
    TransformMagic.start_cast;20.times{scene.update};old_map=$game_map.map_id
    $game_map.instance_variable_set(:@map_id,old_map+1);TransformMagic.update_map
    assert(!TransformMagic.casting? && sprite(scene).color.alpha==0,'map interruption restores colour')
    $game_map.instance_variable_set(:@map_id,old_map)
    TransformMagic.start_cast;20.times{scene.update}
    SceneManager.instance_variable_set(:@scene,Scene_Base.new);scene.terminate
    assert(!TransformMagic.casting?,'external scene exit clears input lock')
    library_cards(false)
    File.open('result.marshal','wb'){|f|f.write(Marshal.dump({:complete=>true,:checks=>checks,:films=>frames,:ruby=>RUBY_VERSION}))}
    log('COMPLETE checks='+checks.to_s)
  rescue Exception=>error
    log('FAIL '+error.class.to_s+': '+error.message+"\r\n"+error.backtrace.join("\r\n"))
  end
end
module Graphics
  def self.update;self.frame_count+=1;end
end
module Input
  def self.trigger?(key);TransformQA.key==key;end
  def self.repeat?(key);trigger?(key);end
  def self.press?(key);trigger?(key);end
  def self.dir4;0;end
  def self.dir8;0;end
end
