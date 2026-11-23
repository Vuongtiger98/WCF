# encoding: UTF-8
# Drives real Game_Player action dispatch, interpreter and pop renderer.
# The disposable runner redirects database reads; saves stay in its own CWD.
module NPCReactionQA
  class << self
    attr_accessor :checks,:tick,:advance,:scene,:case_name,:captures
  end
  self.checks=0;self.tick=0;self.advance=false;self.captures=[]
  def self.log(text);File.open('native.log','ab'){|f|f.write(text.to_s+"\r\n")};end
  def self.assert(value,label)
    raise label unless value
    self.checks+=1;log('PASS '+label)
  end
  def self.map(id)
    self.scene.terminate if scene
    self.scene=nil
    SceneManager.instance_variable_set(:@scene,Scene_Base.new)
    $game_map.setup(id)
    $game_map.events.values.each{|e|e.erase if e.trigger_in?([3,4])}
    $game_map.interpreter.clear
    $game_map.starting_events.clear if $game_map.respond_to?(:starting_events)
    $game_temp.clear_common_event
    $game_player.transparent=false;$game_system.menu_disabled=false
    $game_map.shadows.hide;$game_map.shadows.set_opacity(0)
    $game_map.screen.start_fadein(1)
    self.scene=Scene_Map.new
    SceneManager.instance_variable_set(:@scene,scene)
    scene.start
  end
  def self.form(id)
    TransformMagic.apply(id)
    $game_map.refresh
  end
  def self.place(id)
    event=$game_map.events.fetch(id)
    if event.normal_priority?
      $game_player.moveto(event.x,event.y+1)
      $game_player.set_direction(8)
    else
      $game_player.moveto(event.x,event.y)
      $game_player.set_direction(8)
    end
    $game_player.center($game_player.x,$game_player.y)
  end
  def self.action(id,label)
    self.case_name=label
    place(id)
    started=$game_player.check_action_event
    unless started
      event=$game_map.events[id]
      log('DISPATCH '+{:map=>$game_map.map_id,:event=>id,:target=>[event.x,event.y],
        :normal=>event.normal_priority?,:empty=>event.empty?,:player=>[$game_player.x,$game_player.y,$game_player.direction],
        :here=>$game_map.events_xy($game_player.x,$game_player.y).map{|e|e.id},
        :there=>$game_map.events_xy(event.x,event.y).map{|e|e.id},:busy=>$game_map.interpreter.running?}.inspect)
    end
    assert(started,'action button starts '+label)
    assert(!NPCFormReaction.action?,'manual dispatch scope is cleared')
    $game_map.interpreter.instance_variable_get(:@list)
  end
  def self.drain(capture=false)
    self.advance=true
    count=0;seen=[]
    begin
      self.tick+=1;scene.update;count+=1
      window=scene.instance_variable_get(:@message_window)
      if window.pause && window.openness==255 && $game_message.has_text?
        signature=$game_message.all_text
        unless seen.include?(signature)
          seen<<signature
          assert(window.x>=0 && window.y>=0 && window.x+window.width<=Graphics.width && window.y+window.height<=Graphics.height,'pop stays inside screen for '+case_name)
          target=window.instance_variable_get(:@pop_message_id)
          if signature =~ /\\bm\[/i
            assert(target && (target==0 || $game_map.events[target]),'pop resolves a real speaker')
          else
            assert(target.nil?,'normal authored message clears the pop anchor')
          end
          if capture
            file=case_name+'-'+seen.size.to_s+'.png'
            bmp=Graphics.snap_to_bitmap;bmp.save('captures/'+file);bmp.dispose
            captures<<file
          end
        end
      end
    end while ($game_map.interpreter.running? || $game_message.busy? || $game_message.visible ||
      ($game_map.respond_to?(:starting_events) && !$game_map.starting_events.empty?)) && count<1200
    self.advance=false
    assert(count<1200,'dialogue completes without blocking '+case_name)
    assert(!seen.empty?,'real message renderer displayed '+case_name)
    8.times{self.tick+=1;scene.update}
  end
  def self.generated?(list)
    list[0].code==355 && list[0].parameters[0].start_with?('NPCFormReaction.commit(')
  end
  def self.run
    log('BOOT Ruby '+RUBY_VERSION)
    DataManager.init;DataManager.setup_new_game
    TransformMagic::FORMS.keys.each{|id|TransformMagic.unlock(id,false)}
    $game_switches[48]=true;$game_switches[82]=true
    map(38)
    [[:leo,5],[:shylvie,3],[:kohi,4],[:hakase,6]].each do |role,event_id|
      TransformMagic::FORMS.keys.each do |id|
        form(id)
        list=action(event_id,role.to_s+'-'+id.to_s)
        assert(generated?(list),'shared script supplies '+role.to_s+'/'+id.to_s)
        before=$game_variables[4]
        drain(true)
        assert($game_variables[4]==before,'reaction preserves current form')
        assert(NPCFormReaction.state[:seen][[role,id]],'first encounter saved for '+role.to_s+'/'+id.to_s)
      end
    end
    form(:diana)
    list=action(18,'diana-self')
    assert(generated?(list),'empty Diana event becomes interactable through script')
    drain(true)
    map(3)
    [[:gamemerr,27,:alpha],[:sanic,22,:beta]].each do |id,event_id,role|
      form(id);list=action(event_id,role.to_s)
      assert(generated?(list),'Silverwing hitbox resolves '+role.to_s)
      assert(list.any?{|c|c.code==213 && c.parameters[0]==(role==:alpha ? 5 : 4)},'balloon uses baked NPC anchor')
      drain(true)
    end
    map(19)
    TransformMagic::FORMS.keys.each do |id|
      form(id);original=$game_map.events[18].list
      first=action(18,'generic-'+id.to_s)
      assert(generated?(first),'generic NPC gets shared pool')
      drain(true)
      second=action(18,'generic-second-'+id.to_s)
      assert(generated?(second),'second interaction stays in the transformed dialogue pool')
      assert(second.select{|c|c.code==401}.map{|c|c.parameters} != first.select{|c|c.code==401}.map{|c|c.parameters},'second reaction uses different approved text')
      drain
      assert(generated?(action(18,'generic-repeat-'+id.to_s)),'later interaction can react again')
      drain
      TransformMagic.revert;$game_map.refresh
      assert(action(18,'generic-normal-'+id.to_s).equal?(original),'normal dialogue returns after reverting the actual sprite')
      drain
    end
    $game_variables[56]=2;$game_switches[72]=true
    map(58);form(:sanic)
    $game_switches[81]=false;$game_variables[82]=0;$game_map.refresh
    alias_list=$game_map.events[21].list
    list=action(21,'karin-hitbox')
    assert(generated?(list),'secondary hitbox intercepts before forwarding')
    assert(list.any?{|c|c.code==401 && c.parameters[0].include?('\\bm[20]')},'Karin pop uses controller anchor 20')
    drain(true)
    assert(!$game_switches[81] && $game_variables[82]==0,'reaction does not advance cafe pages')
    assert(generated?(action(20,'karin-controller-repeat')),'another hitbox still uses transformed reactions')
    drain
    assert(!$game_switches[81] && $game_variables[82]==0,'repeated transformed reaction cannot advance original pages')
    TransformMagic.revert;$game_map.refresh
    assert(action(21,'karin-original').equal?(alias_list),'original dialogue returns only after form revert')
    drain
    assert($game_switches[81],'authored Karin conversation still advances its switch')
    $game_variables[55]=4;$game_map.refresh
    data=NPCFormReaction.profile($game_map.events[22])
    # The configured dialogue page determines who speaks, never hitbox position.
    assert([25,26].include?(data[:anchor]),'paired cafe NPC resolves its current page speaker')
    map(13);form(:riu)
    [97,98].each do |id|
      event=$game_map.events[id]
      page=event.instance_variable_get(:@event).pages[3]
      assert(!event.conditions_met?(page),'old fish page cannot override shared system')
    end
    $game_variables[2]=2;$game_map.refresh
    original=$game_map.events[97].list
    $game_temp.nfr_action_depth=1
    list=NPCFormReaction.interaction_list($game_map.interpreter,original,97)
    $game_temp.nfr_action_depth=0
    assert(list.equal?(original),'gift-route transfer keeps its original event list')
    saved=Marshal.load(Marshal.dump($game_system))
    assert(saved.npc_form_reactions[:seen][[:diana,:diana]],'reaction history survives real RGSS Marshal')
    saved.instance_variable_get(:@npc_form_reactions)[:base_next]={[:shylvie,:riu]=>true}
    $game_system=saved
    $game_variables[2]=0;$game_variables[3]=0;$game_map.refresh
    assert(generated?(action(98,'old-save-continuous-riu')),'obsolete saved alternation flag cannot restore normal dialogue')
    drain(true)
    assert(!$game_system.npc_form_reactions.key?(:base_next),'obsolete turn flag is removed from existing save state')
    assert(Game_System.new.npc_form_reactions[:seen].empty?,'new game does not inherit reaction history')
    scene.terminate;self.scene=nil
    File.open('result.marshal','wb'){|f|f.write(Marshal.dump({:complete=>true,:checks=>checks,:captures=>captures,:ruby=>RUBY_VERSION}))}
    log('COMPLETE checks='+checks.to_s)
  rescue Exception=>error
    log('FAIL '+error.class.to_s+': '+error.message+"\r\n"+error.backtrace.join("\r\n"))
  end
end
module Graphics
  def self.update;self.frame_count+=1;end
end
module Input
  def self.trigger?(key);NPCReactionQA.advance && key==:C && NPCReactionQA.tick%8==0;end
  def self.repeat?(key);trigger?(key);end
  def self.press?(key);trigger?(key);end
  def self.dir4;0;end
  def self.dir8;0;end
end
