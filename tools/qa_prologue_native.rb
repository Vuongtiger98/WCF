# encoding: UTF-8
# Isolated RGSS command test. Logical Input drives the real player, choices and
# message waits. Only native presentation/focus waits are bypassed. Snapshots
# still come from Graphics.snap_to_bitmap; event execution/rendering is real.
module PrologueQA
  class << self
    attr_accessor :frame,:key,:direction,:pause_age,:current,:messages,:balloons,
      :last_pause,:office_queue,:task,:task_age,:task_started,:visited,:maps,
      :choice_seen,:transfers,:case_id,:arrival_age,:last_map,:exit_cancelled
  end
  self.frame=0; self.messages=[]; self.balloons={}; self.maps=[]
  self.visited=[]; self.transfers=[]; self.pause_age=0; self.task_age=0
  self.choice_seen=[]
  self.case_id=File.read('case.txt').to_i; self.arrival_age=0
  def self.log(value)
    File.open('native.log','ab') { |f|f.write(value.to_s+"\r\n") }
  end
  def self.write(name,value)
    File.open(name,'wb') { |f|f.write(Marshal.dump(value)) }
  end
  def self.shot(name)
    bmp=Graphics.snap_to_bitmap; bmp.save('captures/'+name+'.png'); bmp.dispose
  end
  def self.renderer
    s=SceneManager.scene
    set=s && s.instance_variable_get(:@spriteset)
    set && set.instance_variable_get(:@map_effects)
  end
  def self.point(x,y)
    r=renderer
    r && $game_map.effects.active? ? r.wcf_screen_point(x,y) : [x,y]
  end
  def self.rect(v); [v.x,v.y,v.width,v.height]; end
  def self.sprite_rect(s)
    vp=s.viewport; vx=vp ? vp.rect.x-vp.ox : 0; vy=vp ? vp.rect.y-vp.oy : 0
    x=s.x+vx-s.ox*s.zoom_x; y=s.y+vy-s.oy*s.zoom_y
    pts=[[x,y],[x+s.width*s.zoom_x,y],[x,y+s.height*s.zoom_y],[x+s.width*s.zoom_x,y+s.height*s.zoom_y]].map {|a,b|point(a,b)}
    xs=pts.map {|p|p[0]}; ys=pts.map {|p|p[1]}
    [xs.min,ys.min,xs.max-xs.min,ys.max-ys.min]
  end
  def self.state
    p=$game_player; m=$game_map
    {:frame=>frame,:map=>m.map_id,:player=>[p.x,p.y,p.direction],:sprite=>p.character_name,
      :transparent=>p.transparent,:through=>p.through,:movable=>p.movable?,
      :camera=>[m.display_x,m.display_y],:zoom=>[m.effects.zoom_x,m.effects.zoom_y],
      :angle=>m.effects.angle,
      :kul=>[:@a,:@r,:@g,:@b,:@ta,:@alpha_timer,:@lighting].inject({}) {|h,k|h[k]=m.shadows.instance_variable_get(k);h},
      :brightness=>m.screen.brightness,:switch2=>$game_switches[2],
      :stop_player=>Switch.stop_player_movement,:stop_npc=>Switch.stop_npc_movement}
  end
  def self.finish(ok,reason)
    write('messages.marshal',messages); write('balloons.marshal',balloons.values)
    write('completion.marshal',state.merge(:complete=>ok,:reason=>reason,:messages=>messages.size,
      :maps=>maps,:visited=>visited,:transfers=>transfers,:choices=>choice_seen,
      :phone_unread=>$game_config.phone_unread_count,
      :group_unread=>!!$game_config.phone_unread?(:group,:wanderer_group),
      :phone_groups=>$game_config.phone_group_chats.inject({}) { |h,pair|h[pair[0]]=pair[1][:messages].size;h }))
    log((ok ? 'COMPLETE ' : 'TIMEOUT ')+reason+' '+state.inspect)
    shot('completion'); SceneManager.exit
  end
  # BFS uses the actual Game_Player collision rules. No mid-route teleport or
  # through flag is used to make an interaction succeed.
  def self.path_to(goals)
    start=[$game_player.x,$game_player.y]; queue=[[start,nil]]; seen={start=>true}
    until queue.empty?
      pos,first=queue.shift
      goal=goals.find {|g|g[0]==pos}
      return [first,goal[1]] if goal
      [2,4,6,8].each do |d|
        next unless $game_player.passable?(pos[0],pos[1],d)
        dest=[$game_map.round_x_with_direction(pos[0],d),$game_map.round_y_with_direction(pos[1],d)]
        # Do not route the prop survey through the authored plant bad ending.
        next if $game_map.map_id==3 && [18,64].any? {|id|e=$game_map.events[id];e && e.x==dest[0] && e.y==dest[1]}
        next if seen[dest]; seen[dest]=true; queue << [dest,first || d]
      end
    end
    nil
  end
  def self.interact(eid)
    e=$game_map.events[eid]
    goals=e.normal_priority? ? [[2,0,-1],[4,1,0],[6,-1,0],[8,0,1]].map {|d,dx,dy|[[e.x+dx,e.y+dy],d]} : [[[e.x,e.y],nil]]
    result=path_to(goals)
    unless result
      visited << {:map=>$game_map.map_id,:event=>eid,:result=>'unreachable'}
      log('UNREACHABLE '+eid.to_s); return :unreachable
    end
    if result[0]
      self.direction=result[0]
    elsif result[1] && $game_player.direction!=result[1]
      self.direction=result[1]
    else
      self.key=:C; return :pressed
    end
    :moving
  end
  def self.input
    self.key=nil; self.direction=0
    scene=SceneManager.scene
    win=scene && scene.instance_variable_get(:@message_window)
    self.pause_age=win && win.pause ? pause_age+1 : 0
    if scene.is_a?(Scene_SimplePhoneChat)
      self.key=:C if frame%12==0
      return
    end
    return unless scene.is_a?(Scene_Map)
    choice=win && win.instance_variable_get(:@choice_window)
    if choice && choice.active
      if $game_map.map_id==10
        choice.select(case_id)
      elsif $game_map.map_id==69
        choice.select(0)
      elsif $game_map.map_id==3
        # Exercise the exit cancellation once before committing to leave.
        choice.select(exit_cancelled ? 0 : 1)
      end
      if frame%12==0
        self.key=:C
        self.exit_cancelled=true if $game_map.map_id==3
      end
      return
    end
    if win && win.pause
      self.key=:C if pause_age>=45 && pause_age%15==0
      return
    end
    return if $game_message.busy? || $game_map.interpreter.running? || $game_player.moving? || !$game_player.movable?
    if $game_map.map_id==69
      interact(2)
    elsif $game_map.map_id==3 && $game_self_switches[[3,3,'A']]
      self.office_queue ||= (case_id==1 ? [25,25,22] : case_id==0 ? [6,7,8,9,10,11,12,13,14,15,16,17,19,21,23,24,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,22,27] : [])
      if task_started
        visited << {:map=>3,:event=>task,:result=>'completed'}
        self.task=nil; self.task_started=false; self.task_age=0
      end
      if !task && !office_queue.empty?
        self.task=office_queue.shift
      end
      if task
        result=interact(task)
        self.task_age+=1
        if result==:unreachable
          self.task=nil; self.task_age=0
        elsif result==:pressed
          self.task_started=true
        end
      else
        result=path_to([[[0,7],nil],[[0,8],nil]])
        self.direction=result[0] if result
      end
    end
  end
  def self.observe(scene)
    m=$game_map
    if last_map!=m.map_id
      self.last_map=m.map_id; maps << m.map_id
      log('MAP '+state.inspect)
    end
    sprites=scene.instance_variable_get(:@spriteset).instance_variable_get(:@character_sprites)
    win=scene.instance_variable_get(:@message_window)
    if win.pause && current && pause_age==12 && last_pause!=current[:id]
      self.last_pause=current[:id]
      row=current.merge(state)
      row[:text]=$game_message.all_text; row[:face]=[$game_message.face_name,$game_message.face_index]
      row[:window]=rect(win); row[:pop]=win.instance_variable_get(:@pop_message_id)
      r=renderer; row[:source_viewport]=rect(sprites[0].viewport.rect); row[:effect_viewport]=rect(r.wcf_output_rect)
      tag=win.instance_variable_get(:@bubble_sprite)
      row[:bubble_x]=tag.x+tag.width/2.0 if tag && row[:pop]
      if row[:pop]
        target=row[:pop]==0 ? $game_player : m.events[row[:pop]]
        s=sprites.find {|sp|sp.instance_variable_get(:@character).equal?(target)}
        vp=s.viewport
        row[:anchor]=point(s.x+vp.rect.x-vp.ox,s.y+vp.rect.y-vp.oy)
      end
      bg=win.instance_variable_get(:@wcf_pop_backdrop)
      row[:backdrop]=!!(bg && bg.visible)
      messages << row
      log('MESSAGE '+row.inspect)
      shot('message_%03d' % row[:id])
      write('messages.marshal',messages)
    end
    sprites.each do |s|
      b=s.instance_variable_get(:@balloon_sprite); next unless b && !b.disposed?
      char=s.instance_variable_get(:@character); target=char.equal?($game_player) ? -1 : char.id
      id=s.instance_variable_get(:@balloon_id); key=[m.map_id,target,id]
      box=sprite_rect(b); vp=renderer && m.effects.active? ? renderer.wcf_output_rect : b.viewport.rect
      clip=rect(vp)
      data=balloons[key] ||= {:map=>m.map_id,:target=>target,:type=>id,:frames=>0,:clipped=>0,:min_y=>9999}
      data[:frames]+=1; data[:min_y]=[data[:min_y],box[1]].min
      if box[0]<clip[0]-0.1 || box[1]<clip[1]-0.1 || box[0]+box[2]>clip[0]+clip[2]+0.1 || box[1]+box[3]>clip[1]+clip[3]+0.1
        data[:clipped]+=1
      end
    end
    destination=[19,13,22,20][case_id]
    if m.map_id==destination && maps.include?(10)
      self.arrival_age+=1
      # An arrival cutscene can continue straight into another map. Its first
      # readable pause is a valid bus handoff; free roam requires movable?.
      readable=win.pause && pause_age>=12 && m.screen.brightness==255 && m.shadows.opacity<255
      idle=!m.interpreter.running? && !$game_message.busy? && $game_player.movable?
      if arrival_age>120 && (readable || idle)
        result=path_to([[[ $game_player.x,$game_player.y+1],nil],[[ $game_player.x+1,$game_player.y],nil],[[ $game_player.x-1,$game_player.y],nil],[[ $game_player.x,$game_player.y-1],nil]])
        return finish(!!result && m.screen.brightness>0,'bus destination '+destination.to_s)
      end
    end
    log('PROGRESS '+state.inspect) if frame%1200==0
    finish(false,'frame limit') if frame>42000
  end
end
module Graphics
  def self.update; PrologueQA.frame+=1; self.frame_count+=1; end
  def self.transition(*args); self.brightness=255; end
  def self.freeze; end
  def self.wait(frames); frames.times {update}; end
  def self.fadeout(frames); wait(frames); self.brightness=0; end
  def self.fadein(frames); wait(frames); self.brightness=255; end
end
module Input
  def self.update
    # Window_Selectable flushes Input inside process_ok, before its handler.
    # A second update in one frame must not select the next choice for it.
    if @prologue_input_frame==PrologueQA.frame
      PrologueQA.key=nil
      return
    end
    @prologue_input_frame=PrologueQA.frame
    PrologueQA.input
  end
  def self.trigger?(key); PrologueQA.key==key; end
  def self.press?(*args); false; end
  def self.repeat?(key); trigger?(key); end
  def self.dir4; PrologueQA.direction || 0; end
  def self.dir8; dir4; end
end
class << SceneManager
  alias prologue_qa_run run
  def run
    PrologueQA.log('BOOT RGSS '+RUBY_VERSION)
    prologue_qa_run
  rescue Exception => error
    PrologueQA.log('FAIL '+error.class.to_s+': '+error.message+"\r\n"+error.backtrace.join("\r\n"))
    PrologueQA.write('failure.marshal',{:error=>error.message,:backtrace=>error.backtrace})
    exit
  end
end
class Scene_Title
  alias prologue_qa_update update
  def update
    prologue_qa_update
    command_new_game if @command_window.active && PrologueQA.frame>45
  end
end
class Game_Interpreter
  alias prologue_qa_command_101 command_101
  def command_101
    PrologueQA.current={:id=>(PrologueQA.current ? PrologueQA.current[:id]+1 : 1),:event=>@event_id,:command=>@index,:message_map=>@map_id}
    prologue_qa_command_101
  end
  alias prologue_qa_command_201 command_201
  def command_201
    PrologueQA.transfers << {:frame=>PrologueQA.frame,:from=>@map_id,:event=>@event_id,:parameters=>@params.dup}
    prologue_qa_command_201
  end
end
class Scene_Map
  alias prologue_qa_update update
  def update
    prologue_qa_update
    PrologueQA.observe(self)
  end
end
class Window_ChoiceList
  alias prologue_qa_call_ok_handler call_ok_handler
  def call_ok_handler
    PrologueQA.choice_seen << {:map=>$game_map.map_id,:index=>index,:text=>$game_message.choices[index]}
    prologue_qa_call_ok_handler
  end
end
