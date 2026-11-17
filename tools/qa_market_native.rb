# encoding: UTF-8
# Appended after the prologue observer in a disposable RGSS copy only.
module MarketQA
  CONFIG=Marshal.load(File.binread('market-case.marshal'))
  TARGETS=[nil,'Leo','Kohi','Shylvie','Hakase']
  class << self
    attr_accessor :pause_id,:last_recorded,:job,:job_queue,:market_ready,:party_ready,
      :last_map,:idle_age,:shot_count,:states,:issues,:jobs_done,:events_started,
      :phases,:phase_key,:coffee_stubbed,:menu_step,:menu_age,:menu_before
  end
  self.pause_id=0;self.shot_count=0;self.states=[];self.issues=[];self.jobs_done=[]
  self.events_started=[];self.phases=[];self.idle_age=0;self.menu_age=0
  def self.log(text);PrologueQA.log(text);end
  def self.write(name,data);PrologueQA.write(name,data);end
  def self.state
    result=PrologueQA.state
    result.merge(:gift=>$game_variables[42],:target=>$game_variables[43],:stage=>$game_variables[44],
      :hint=>$game_variables[41],:coffee=>$game_switches[52],:prep=>$game_variables[83],
      :party_free=>$game_switches[48],:party_done=>$game_switches[45],:end_unlock=>$game_switches[46],
      :parallax=>$game_map.parallax_name,:ram=>$game_party.item_number($data_items[18]))
  end
  def self.issue(code,details={})
    key=[code,details[:map] || $game_map.map_id,details[:event],details[:command]]
    return if issues.any? {|row|row[:key]==key}
    row={:key=>key,:code=>code,:frame=>PrologueQA.frame,:state=>state,:details=>details}
    issues << row;log('ISSUE '+row.inspect)
    shot('issue_'+issues.size.to_s) if SceneManager.scene_is?(Scene_Map)
  end
  def self.shot(tag)
    return if shot_count>=110
    self.shot_count+=1
    PrologueQA.shot('%02d_%s'%[shot_count,tag.gsub(/[^a-zA-Z0-9_-]/,'_')])
  end
  def self.finish(complete,reason)
    return if @finished
    @finished=true
    current=state
    expected=2+(CONFIG[:gift]-1)*4+CONFIG[:target]-1
    if complete
      issue('WRONG_ROUTE_STATE',:expected=>[CONFIG[:gift],CONFIG[:target],expected]) unless
        current[:gift]==CONFIG[:gift] && current[:target]==CONFIG[:target] && current[:hint]==expected && current[:end_unlock]
    end
    data=current.merge(:config=>CONFIG,:complete=>complete,:reason=>reason,:maps=>PrologueQA.maps,
      :choices=>PrologueQA.choice_seen,:jobs=>jobs_done,:issues=>issues,:pauses=>PrologueQA.messages.size,
      :coffee_stubbed=>!!coffee_stubbed,:title_background=>HAIQUY_TITLE.ending_background,
      :phone=>$game_config.phone_group_chats.inject({}) {|h,p|h[p[0]]=p[1][:messages];h})
    write('completion.marshal',data);write('messages.marshal',PrologueQA.messages)
    write('states.marshal',states);write('phases.marshal',phases)
    log((complete ? 'COMPLETE ' : 'BLOCKED ')+reason+' '+current.inspect)
    shot('completion')
    SceneManager.exit
  end
  def self.interact(eid)
    e=$game_map.events[eid]
    return :unreachable unless e && e.list && e.list.size>1
    trigger=e.instance_variable_get(:@trigger)
    if trigger==1 || trigger==2
      # A transfer may place the player directly on its return trigger.
      # Touch fires on a new step, so walk off before approaching it again.
      if $game_player.x==e.x && $game_player.y==e.y
        direction=[8,4,6,2].find {|d|$game_player.passable?(e.x,e.y,d)}
        PrologueQA.direction=direction if direction
        return direction ? :moving : :unreachable
      end
      result=PrologueQA.path_to([[[e.x,e.y],nil]])
      if result && result[0]
        PrologueQA.direction=result[0];return :moving
      end
      return result ? :on_touch : :unreachable
    end
    goals=if e.normal_priority?
      [[2,0,-1],[4,1,0],[6,-1,0],[8,0,1]].inject([]) do |a,(d,dx,dy)|
        a << [[e.x+dx,e.y+dy],d]
        a << [[e.x+dx*2,e.y+dy*2],d] if $game_map.counter?(e.x+dx,e.y+dy)
        a
      end
    else
      [[[e.x,e.y],nil]]
    end
    result=PrologueQA.path_to(goals)
    return :unreachable unless result
    if result[0]
      PrologueQA.direction=result[0]
    elsif result[1] && $game_player.direction!=result[1]
      PrologueQA.direction=result[1]
    else
      PrologueQA.key=:C;return :pressed
    end
    :moving
  end
  def self.started(eid)
    events_started << {:map=>$game_map.map_id,:event=>eid,:frame=>PrologueQA.frame}
    job[:started]=true if job && job[:map]==$game_map.map_id && job[:event]==eid
  end
  def self.plan_market
    self.market_ready=true
    self.job_queue=[]
    if CONFIG[:survey]
      $game_map.events.keys.sort.each do |id|
        e=$game_map.events[id];next unless e.list && e.list.size>1 && e.instance_variable_get(:@trigger)==0
        next if [3,41].include?(id)
        job_queue << {:map=>19,:event=>id,:kind=>:preview,:optional=>true}
      end
      job_queue << {:map=>19,:event=>32+CONFIG[:gift],:kind=>:continue_shopping}
    end
    job_queue << {:map=>19,:event=>32+CONFIG[:gift],:kind=>:buy}
    log('MARKET_JOBS '+job_queue.inspect)
  end
  def self.plan_party
    self.party_ready=true
    self.job_queue=[]
    if CONFIG[:survey]
      [3,4,6,5].each {|eid|job_queue << {:map=>38,:event=>eid,:kind=>:decline_game,:optional=>true}}
      # Real in/out transfers, retaining the same office variant.
      [[110,42,2],[111,43,2],[112,44,2],[113,45,2],[114,46,2],
       [115,14,2],[130,62,2],[131,63,2]].each do |door,map,exit|
        next if map==63 && CONFIG[:skip_crafting]
        job_queue << {:map=>38,:event=>door,:kind=>:enter_room,:destination=>map,:optional=>true}
        job_queue << {:map=>map,:event=>exit,:kind=>:exit_room,:destination=>38,:optional=>true}
      end
      (8..17).each {|eid|job_queue << {:map=>38,:event=>eid,:kind=>:ram,:optional=>true}}
      job_queue << {:map=>38,:kind=>:menu,:optional=>true}
    end
    job_queue << {:map=>38,:event=>5,:kind=>:begin_party,:destination=>39}
    log('PARTY_JOBS '+job_queue.inspect)
  end
  def self.complete_job(result)
    return unless job
    row=job.merge(:result=>result,:after=>state)
    jobs_done << row;log('JOB '+row.inspect)
    if [:preview,:continue_shopping].include?(job[:kind])
      if job[:kind]==:preview && job[:before] && [row[:after][:gift],row[:after][:target],row[:after][:stage]]!=job[:before]
        issue('CANCEL_CHANGED_ROUTE',:event=>job[:event],:before=>job[:before])
      end
    end
    self.job=nil
  end
  def self.run_jobs
    if job && job[:map]!=$game_map.map_id
      if job[:destination]==$game_map.map_id || job[:kind]==:buy
        complete_job('transferred')
      elsif job[:optional]
        complete_job('unexpected_map')
      else
        return finish(false,'Unexpected map during '+job.inspect)
      end
    end
    return if $game_message.busy? || $game_map.interpreter.running? || $game_player.moving? || !$game_player.movable?
    if job && job[:started]
      complete_job('completed')
    end
    self.job=job_queue.shift if !job && job_queue && !job_queue.empty?
    return unless job
    if job[:map]!=$game_map.map_id
      issue('ROOM_SEQUENCE_BLOCKED',:event=>job[:event],:expected=>job[:map])
      complete_job('not_reached');return
    end
    if job[:kind]==:menu
      self.menu_step=0;self.menu_age=0;self.menu_before=state
      PrologueQA.key=:B;return
    end
    job[:before] ||= [$game_variables[42],$game_variables[43],$game_variables[44]]
    job[:age]=(job[:age] || 0)+1
    result=interact(job[:event])
    if result==:unreachable || job[:age]>1800
      issue('INTERACTION_UNREACHABLE',:event=>job[:event],:job=>job[:kind],:optional=>!!job[:optional])
      return finish(false,'Cannot reach mandatory interaction') unless job[:optional]
      complete_job('unreachable')
    end
  end
  def self.choice_index(choices)
    if $game_map.map_id==69 && CONFIG[:start]=='hubprep'
      return choices.index(TARGETS[CONFIG[:target]]) || choices.index('Chọn người nhận') || 0
    end
    return choices.index('Đi tới checkpoint') || 0 if $game_map.map_id==69
    return choices.index('Tới siêu thị') || 0 if $game_map.map_id==10
    if $game_map.map_id==40
      return choices.index(CONFIG[:coffee]=='atlantis' ? 'Đi câu tôm' : 'Dùng cà phê thường') || 0
    end
    if choices.include?('Thanh toán luôn')
      return choices.index(job && job[:kind]==:continue_shopping ? 'Đi chọn tiếp' : 'Thanh toán luôn')
    end
    if choices.include?('Bắt đầu bữa tiệc') && job && job[:kind]==:begin_party
      return choices.index('Bắt đầu bữa tiệc')
    end
    if job && [:buy,:continue_shopping].include?(job[:kind]) && $game_map.map_id==19
      return 0
    end
    choices.index {|text|text =~ /Thử đi tìm|Thôi|Không|Hủy|Huỷ|Lần khác/} || choices.size-1
  end
  def self.drive_chat(scene)
    return unless PrologueQA.frame%6==0
    if scene.instance_variable_get(:@choice_active)
      chat=scene.instance_variable_get(:@chat)
      wanted=chat.choices.index {|choice|choice[:text]==TARGETS[CONFIG[:target]]}
      unless wanted
        issue('UNEXPECTED_CHAT_CHOICE',:choices=>chat.choices.map {|choice|choice[:text]})
        wanted=0
      end
      current=scene.instance_variable_get(:@choice_index)
      PrologueQA.key=current==wanted ? :C : :DOWN
    else
      PrologueQA.key=:C
    end
  end
  def self.drive_menu(scene)
    self.menu_age+=1
    if menu_step==0 && scene.is_a?(Scene_Menu)
      return unless scene.instance_variable_get(:@animation_state)==:idle
      # Exercise the actual phone library app, then return to the live map.
      scene.instance_variable_set(:@selected_index,0)
      PrologueQA.key=:C;self.menu_step=1
    elsif menu_step==1 && scene.is_a?(Scene_ItemLibrary)
      return if scene.instance_variable_get(:@lib_rotation_mode)
      PrologueQA.key=:B;self.menu_step=2
    elsif menu_step==2 && scene.is_a?(Scene_Menu)
      return unless scene.instance_variable_get(:@animation_state)==:idle
      scene.instance_variable_set(:@selected_index,1)
      PrologueQA.key=:C;self.menu_step=3
    elsif menu_step==3 && scene.is_a?(Scene_Save)
      return if scene.instance_variable_get(:@ps_rotation_mode) || PrologueQA.frame%6!=0
      mode=scene.instance_variable_get(:@ps_mode)
      notice=scene.instance_variable_get(:@ps_notice).to_s
      if mode==:list && notice.include?('Đã lưu thành công')
        @menu_save_index=scene.instance_variable_get(:@ps_index)
        log('MENU_SAVED slot='+@menu_save_index.to_s)
        PrologueQA.key=:B;self.menu_step=4
      else
        PrologueQA.key=:C
      end
    elsif menu_step==4 && scene.is_a?(Scene_Menu)
      return unless scene.instance_variable_get(:@animation_state)==:idle
      scene.instance_variable_set(:@selected_index,3)
      PrologueQA.key=:C;self.menu_step=5
    elsif menu_step==5 && scene.is_a?(Scene_System)
      return unless PrologueQA.frame%6==0
      unless @menu_settings_changes
        scene.wsp_move(4)
        @menu_settings_changes=0
      end
      if @menu_settings_changes<2
        PrologueQA.key=:C
        @menu_settings_changes+=1
      else
        PrologueQA.key=:B;self.menu_step=6
      end
    elsif menu_step==6 && scene.is_a?(Scene_Menu)
      return unless scene.instance_variable_get(:@animation_state)==:idle
      scene.instance_variable_set(:@selected_index,2)
      PrologueQA.key=:C;self.menu_step=7
    elsif menu_step==7 && scene.is_a?(Scene_Load)
      return if scene.instance_variable_get(:@ps_rotation_mode) || PrologueQA.frame%6!=0
      scene.instance_variable_set(:@ps_index,@menu_save_index) if scene.instance_variable_get(:@ps_mode)==:list
      PrologueQA.key=:C
    elsif menu_step==7 && scene.is_a?(Scene_Map)
      after=state
      issue('MENU_CHANGED_PLAYER',:before=>menu_before,:after=>after) unless after[:player]==menu_before[:player]
      log('MENU_ROUNDTRIP '+after.inspect)
      self.menu_step=nil
      complete_job('library_save_settings_load_roundtrip')
    elsif menu_age>1000
      issue('MENU_TIMEOUT',:scene=>scene.class.to_s)
      finish(false,'Phone roundtrip timeout')
    end
  end
  def self.input
    PrologueQA.key=nil;PrologueQA.direction=0
    return if @finished
    scene=SceneManager.scene
    win=scene && scene.instance_variable_get(:@message_window)
    PrologueQA.pause_age=win && win.pause ? PrologueQA.pause_age+1 : 0
    return drive_menu(scene) unless menu_step.nil?
    return drive_chat(scene) if scene.is_a?(Scene_SimplePhoneChat)
    return unless scene.is_a?(Scene_Map)
    choice=win && win.instance_variable_get(:@choice_window)
    if choice && choice.active
      wanted=choice_index($game_message.choices)
      if PrologueQA.frame%6==0
        PrologueQA.key=choice.index==wanted ? :C : :DOWN
      end
      return
    end
    if win && win.pause
      PrologueQA.key=:C if PrologueQA.pause_age>=18 && PrologueQA.pause_age%6==0
      return
    end
    if ['room63','cashier'].include?(CONFIG[:start])
      return if $game_message.busy? || $game_map.interpreter.running? || $game_player.moving?
      @probe_age=(@probe_age || 0)+1
      if @probe_age==1
        eid=CONFIG[:start]=='room63' ? 2 : 5
        event=$game_map.events[eid]
        around=[[2,0,-1],[4,1,0],[6,-1,0],[8,0,1]].map do |d,dx,dy|
          x,y=event.x+dx,event.y+dy
          {:x=>x,:y=>y,:direction=>d,:player_passable_into_event=>$game_player.passable?(x,y,d),
            :counter=>$game_map.counter?(x,y),:tile_passages=>[2,4,6,8].map {|dir|$game_map.passable?(x,y,dir)},
            :event_tile_passages=>[2,4,6,8].map {|dir|$game_map.passable?(event.x,event.y,dir)}}
        end
        goals=event.normal_priority? ? around.map {|r|[[r[:x],r[:y]],r[:direction]]} : [[[event.x,event.y],nil]]
        @probe={:initial=>state,:event=>[eid,event.x,event.y,event.instance_variable_get(:@priority_type),event.instance_variable_get(:@trigger)],
          :path_to_event=>PrologueQA.path_to(goals),:around=>around,:attempts=>[]}
        write('boundary-probe.marshal',@probe);shot('boundary_initial')
      end
      if @probe_age%30==1
        d=[4,8,2,6][(@probe_age/30)%4]
        @probe[:attempts] << {:before=>[$game_player.x,$game_player.y],:input=>d,:frame=>PrologueQA.frame}
        PrologueQA.direction=d
      end
      PrologueQA.key=:C if [15,45].include?(@probe_age)
      if @probe_age>=150
        @probe[:final]=state;@probe[:event_starts]=events_started
        write('boundary-probe.marshal',@probe);shot('boundary_final')
        return finish(false,'Boundary diagnostic only; not a route-completion case')
      end
      return
    end
    if $game_map.map_id==69
      return if $game_message.busy? || $game_map.interpreter.running? || $game_player.moving?
      interact(CONFIG[:start]=='hubprep' ? 15+CONFIG[:gift] : 4)
    elsif $game_map.map_id==19
      return unless !$game_message.busy? && !$game_map.interpreter.running? && $game_player.movable?
      plan_market unless market_ready
      run_jobs
    elsif $game_map.map_id==38 && $game_switches[48]
      return unless !$game_message.busy? && !$game_map.interpreter.running? && $game_player.movable?
      plan_party unless party_ready
      run_jobs
    elsif (job || (job_queue && !job_queue.empty?)) && ![19,38].include?($game_map.map_id)
      run_jobs
    end
  end
  def self.observe(scene)
    return if @finished
    m=$game_map
    if last_map!=m.map_id
      self.last_map=m.map_id;PrologueQA.maps << m.map_id
      log('MAP '+state.inspect);shot('map_'+m.map_id.to_s)
      complete_job('transferred') if job && job[:destination]==m.map_id
      if [37,38,39].include?(m.map_id) && [$game_variables[42],$game_variables[43]]!=[CONFIG[:gift],CONFIG[:target]]
        issue('WRONG_ROUTE_ON_TRANSFER',:expected=>[CONFIG[:gift],CONFIG[:target]])
      end
    end
    win=scene.instance_variable_get(:@message_window)
    if win.pause && PrologueQA.current && PrologueQA.pause_age>=4 && last_recorded!=pause_id
      self.last_recorded=pause_id
      row=PrologueQA.current.merge(state).merge(:pause=>pause_id,:text=>$game_message.all_text,
        :face=>[$game_message.face_name,$game_message.face_index],:window=>PrologueQA.rect(win),
        :pop=>win.instance_variable_get(:@pop_message_id))
      bg=win.instance_variable_get(:@wcf_pop_backdrop)
      row[:backdrop]=!!(bg && bg.visible)
      framed=WCFFramedCG.instance_variable_get(:@picture)
      row[:framed_cg]=!!(framed && !framed.disposed?)
      row[:pictures]=[]
      $game_map.screen.pictures.each do |picture|
        row[:pictures] << [picture.number,picture.name] unless picture.name.to_s.empty?
      end
      if row[:pop]
        sprites=scene.instance_variable_get(:@spriteset).instance_variable_get(:@character_sprites)
        target=row[:pop]==0 ? $game_player : m.events[row[:pop]]
        sprite=sprites.find {|s|s.instance_variable_get(:@character).equal?(target)}
        tag=win.instance_variable_get(:@bubble_sprite)
        if sprite && tag
          vp=sprite.viewport
          row[:anchor]=PrologueQA.point(sprite.x+vp.rect.x-vp.ox,sprite.y+vp.rect.y-vp.oy)
          row[:bubble_x]=tag.x+tag.width/2.0
          row[:anchor_error]=(row[:bubble_x]-row[:anchor][0]).abs
          if (0..Graphics.width).include?(row[:anchor][0]) && row[:anchor_error]>3
            issue('POP_ANCHOR_MISMATCH',:event=>row[:event],:command=>row[:command],:error=>row[:anchor_error])
          end
        end
      end
      PrologueQA.messages << row
      log('MESSAGE '+row.inspect)
      x,y,w,h=row[:window]
      issue('MESSAGE_OUTSIDE_SCREEN',:event=>row[:event],:command=>row[:command],:window=>row[:window]) if
        x<0 || y<0 || x+w>Graphics.width || y+h>Graphics.height
      issue('STALE_POP_BACKGROUND',:event=>row[:event],:command=>row[:command]) unless row[:backdrop]==!!row[:pop]
      text=row[:text]
      if @message_shots.nil? || !@message_shots[m.map_id] || row[:framed_cg] || !row[:pictures].empty? || text =~ /chôn vùi|đánh thức|Aria|Aira.*đánh thức|ngủ ngon|đắp tuyết/
        @message_shots ||= {};@message_shots[m.map_id]=true;shot('message_'+row[:id].to_s)
      end
    end
    chars=[[-1,$game_player]]+[2,3,4,5,6,18].map {|id|[id,m.events[id]]}
    char_state=chars.select {|id,char|char}.map {|id,char|[id,char.character_name,char.x,char.y,char.transparent,char.direction,char.pattern]}
    layers=[]
    (m.layers[m.map_id] || []).each_with_index do |params,id|
      layers << [id,params[0],params[3],params[4]] if params.is_a?(Array)
    end
    key=[m.map_id,m.parallax_name,char_state.map {|c|c[0,5]},layers,$game_switches[48],$game_switches[82]]
    if phase_key!=key
      if layers!=@previous_layers || m.parallax_name!=@previous_parallax
        shot('layer_phase_'+phases.size.to_s) if [37,38].include?(m.map_id)
      end
      @previous_layers=layers;@previous_parallax=m.parallax_name
      self.phase_key=key
      phases << state.merge(:characters=>char_state,:layers=>layers)
    end
    if !$game_message.busy? && !m.interpreter.running? && $game_player.movable?
      self.idle_age+=1
      if idle_age==4
        row=state;states << row;log('FREE '+row.inspect)
        issue('FREE_ROAM_BLACK',:brightness=>row[:brightness],:kul=>row[:kul]) if row[:brightness]==0 || m.shadows.opacity>=250
        issue('FREE_ROAM_PLAYER_HIDDEN') if row[:transparent]
      end
    else
      self.idle_age=0
    end
    if PrologueQA.frame%1800==0
      log('PROGRESS '+state.inspect+' job='+job.inspect)
      write('messages.marshal',PrologueQA.messages);write('phases.marshal',phases)
    end
    interpreter=m.interpreter
    progress=[m.map_id,$game_player.x,$game_player.y,interpreter.instance_variable_get(:@index),
      PrologueQA.messages.size,job && job[:kind]]
    if @last_progress!=progress
      @last_progress=progress;@progress_frame=PrologueQA.frame
    elsif PrologueQA.frame-(@progress_frame || 0)>3600
      issue('NO_PROGRESS',:interpreter=>interpreter.instance_variables.map {|key|[key,interpreter.instance_variable_get(key).to_s[0,120]]})
      finish(false,'No logical progress for 3600 frames')
    end
    finish(false,'Logical frame limit') if PrologueQA.frame>180000
  end
end
class << SceneManager
  alias market_qa_first_scene_class first_scene_class
  def first_scene_class
    mode=MarketQA::CONFIG[:start]
    return market_qa_first_scene_class unless ['room63','cashier'].include?(mode)
    DataManager.setup_new_game
    if mode=='room63'
      WCFTestHub.prepare(:market_party,:variables=>{42=>3,43=>3,44=>4},:switches=>{48=>true,50=>false})
      $game_variables[49]=38
      $game_map.setup(63)
      $game_player.moveto(5,10)
    else
      WCFTestHub.prepare(:market,:switches=>{44=>false,50=>false})
      $game_map.setup(19)
      $game_player.moveto(16,21)
    end
    $game_player.set_direction(8)
    $game_map.shadows.set_opacity(0)
    Scene_Map
  end
end
module PrologueQA
  def self.input;MarketQA.input;end
  def self.observe(scene);MarketQA.observe(scene);end
end
class Game_System
  alias market_qa_initialize initialize
  def initialize
    market_qa_initialize
    set_instantmsg(MarketQA::CONFIG[:instant])
  end
end
class Game_Event
  alias market_qa_start start
  def start
    market_qa_start
    MarketQA.started(@id) if @starting
  end
end
class Window_Message
  alias market_qa_input_pause input_pause
  def input_pause
    MarketQA.pause_id+=1
    market_qa_input_pause
  end
end
class Game_Interpreter
  def atlantis_shrimp_fishing
    MarketQA.coffee_stubbed=true
    $game_temp.atlantis_shrimp_result=10
    MarketQA.log('SIMULATED_MINIGAME_RESULT atlantis_shrimp_result=10')
  end
end
class Scene_Title
  alias market_qa_title_update update
  def update
    if PrologueQA.maps.include?(36)
      MarketQA.finish(true,'Reached ending and Title')
    else
      market_qa_title_update
    end
  end
end
