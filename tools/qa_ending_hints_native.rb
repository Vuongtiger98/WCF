# encoding: UTF-8
# All 28 real hint autorun pages in an isolated RGSS copy, including dirty entry.
module EndingHintQA
  LIMIT=File.file?('hint-count.txt') ? File.read('hint-count.txt').to_i : 28
  class << self
    attr_accessor :hint,:frame,:current,:serial,:pause_age,:seen,:messages,:rows,:key,:entry
  end
  self.hint=0;self.frame=0;self.serial=0;self.pause_age=0
  self.messages=[];self.rows=[];self.seen={}
  def self.log(text)
    File.open('hint-native.log','ab'){|file|file.write(text.to_s+"\r\n")}
  end
  def self.assert(value,text)
    raise "Hint #{hint}: #{text}" unless value
  end
  def self.shot(name)
    image=Graphics.snap_to_bitmap
    image.save('captures/'+('%02d_'%hint)+name+'.png');image.dispose
  end
  def self.prepare
    self.hint+=1
    self.current=nil;self.pause_age=0;self.seen={}
    DataManager.setup_new_game
    HAIQUY_TITLE.clear_ending_background
    $game_variables[41]=hint
    # Simulate different source routes: disabled/full/clear KUL, a carried
    # maze lamp, old camera distortion and a leftover screen tint/fade.
    $game_switches[17]=$game_switches[18]=hint%2==0
    $game_player.give_light('maze_player_amber')
    $game_map.shadows.set_color(90,40,20)
    $game_map.shadows.set_opacity(hint%2==0 ? 0 : 255)
    $game_map.shadows.hide
    $game_map.effects.set_angle(31)
    $game_map.effects.set_zoom(150,0,false)
    $game_map.screen.start_tone_change(Tone.new(80,30,10,40),0)
    $game_map.screen.start_fadeout(1);$game_map.screen.update
    $game_map.setup(36);$game_player.moveto(8,7)
    $game_map.autoplay
    assert(!$game_player.carrying_light?,'source player light removed before spriteset')
    assert($game_map.shadows.opacity==255 && $game_map.shadows.instance_variable_get(:@lighting),'black KUL installed at map entry')
    assert($game_map.screen.brightness==255,'screen fade reset under the black KUL mask')
    self.entry={:hint=>hint,:first_frame=>frame,:initial_opacity=>$game_map.shadows.opacity}
    log('BEGIN '+hint.to_s)
  end
  def self.input
    self.key=nil
    scene=SceneManager.scene
    return unless scene.is_a?(Scene_Map)
    window=scene.instance_variable_get(:@message_window)
    self.pause_age=window && window.pause ? pause_age+1 : 0
    self.key=:C if pause_age>=20 && pause_age%4==0
  end
  def self.observe(scene)
    assert(frame-entry[:first_frame]<5000,'scene finished within the frame bound')
    window=scene.instance_variable_get(:@message_window)
    return unless current && window.pause && pause_age>=12 && !seen[serial]
    seen[serial]=true
    target=window.instance_variable_get(:@pop_message_id)
    expected=$game_message.face_name.empty? ? 0 : 2
    rect=[window.x,window.y,window.width,window.height]
    assert(target==expected,'all dialogue uses the correct pop anchor')
    assert(rect[0]>=0 && rect[1]>=0 && rect[0]+rect[2]<=Graphics.width && rect[1]+rect[3]<=Graphics.height,'pop stays inside the game screen')
    assert($game_map.shadows.opacity==185,'consistent dialogue lighting')
    assert($game_map.events[2].carrying_light?,'actor key light is present')
    assert(($game_map.effects.zoom_x-1.1).abs<0.001,'gentle zoom is consistent')
    assert($game_map.screen.brightness==255,'no inherited screen black during dialogue')
    bubble=window.instance_variable_get(:@bubble_sprite)
    assert(!!bubble && bubble.visible==(expected==2),'off-screen voice never points at Bully Quy')
    assert(RPG::BGM.last.name=='sad magic','approved hint BGM is active')
    actor=$game_map.events[2]
    anchor_x,base_y,top_y=window.pop_message_anchor(actor)
    assert((anchor_x-Graphics.width/2).abs<2,'actor is centred without relocating the event')
    mask=$game_map.shadows.bitmap.get_pixel(anchor_x.to_i,((base_y+top_y)/2).to_i)
    assert(mask.red<100 && mask.green<100,'spotlight actually illuminates the rendered actor')
    messages<<{:hint=>hint,:command=>current,:target=>target,:rect=>rect,:face=>$game_message.face_name,
      :face_index=>$game_message.face_index,:opacity=>$game_map.shadows.opacity,:zoom=>$game_map.effects.zoom_x}
    if seen.size==1 || (expected==0 && !seen[:voice])
      shot(expected==0 ? 'voice' : 'pop') if [1,2,18,19,21,22,24,25,28].include?(hint)
      seen[:voice]=true if expected==0
    end
  end
  def self.finish
    count=messages.count{|row|row[:hint]==hint}
    list=$data_map_hint_pages[hint-1].list
    expected=list.count{|cmd|cmd.code==101}
    assert(count==expected,'every Show Text was observed')
    assert($game_map.shadows.opacity==255,'hint ends under black before Title')
    assert($game_map.lights.empty?,'all hint lights are cleaned')
    assert(!$game_map.effects.active?,'camera effects are cleaned')
    assert(WCFEndingHint::VOICE_ANCHORS.all?{|name|$game_player.instance_variable_get(name).nil?},'voice anchors are cleaned')
    title_script=list.select{|cmd|[355,655].include?(cmd.code)}.map{|cmd|cmd.parameters[0]}.join("\n")
    artwork=title_script[/HAIQUY_TITLE\.set_ending_background\("([^"]+)"\)/,1]
    assert(HAIQUY_TITLE.ending_background==artwork,'authored Title artwork retained')
    rows<<entry.merge(:messages=>count,:title=>artwork,:complete=>true,:frames=>frame-entry[:first_frame])
    log('PASS '+rows[-1].inspect)
    File.open('messages.marshal','wb'){|file|file.write(Marshal.dump(messages))}
    File.open('completion.marshal','wb'){|file|file.write(Marshal.dump({:complete=>hint==LIMIT,:rows=>rows,:messages=>messages.size}))}
  end
end
module Graphics
  def self.update;EndingHintQA.frame+=1;self.frame_count+=1;end
  def self.transition(*);self.brightness=255;end
  def self.freeze;end
  def self.wait(n);n.times{update};end
  def self.fadeout(n);wait(n);self.brightness=0;end
  def self.fadein(n);wait(n);self.brightness=255;end
end
module Input
  def self.update
    if @hint_input_frame==EndingHintQA.frame
      EndingHintQA.key=nil;return
    end
    @hint_input_frame=EndingHintQA.frame;EndingHintQA.input
  end
  def self.trigger?(key);EndingHintQA.key==key;end
  def self.repeat?(key);trigger?(key);end
  def self.press?(key);key==:C;end
  def self.dir4;0;end
  def self.dir8;0;end
end
class << SceneManager
  alias hint_qa_run run
  def run
    hint_qa_run
  rescue Exception=>error
    EndingHintQA.log('FAIL '+error.class.to_s+': '+error.message+"\r\n"+error.backtrace.join("\r\n"))
    exit
  end
  def first_scene_class
    $data_map_hint_pages=load_data('Data/Map036.rvdata2').events[1].pages
    EndingHintQA.prepare
    Scene_Map
  end
end
class Game_Interpreter
  alias hint_qa_stage_start wcf_ending_hint_start
  def wcf_ending_hint_start
    hint_qa_stage_start
    EndingHintQA.assert($game_map.events[2].light.opacity==0,'spotlight begins dark')
  end
  alias hint_qa_stage_reveal wcf_ending_hint_reveal
  def wcf_ending_hint_reveal
    hint_qa_stage_reveal
    EndingHintQA.assert($game_map.events[2].light.opacity==255,'spotlight fades all the way in')
  end
  alias hint_qa_stage_fade wcf_ending_hint_fade_out
  def wcf_ending_hint_fade_out
    hint_qa_stage_fade
    EndingHintQA.assert($game_map.events[2].light.opacity==0,'spotlight fades out before removal')
    EndingHintQA.assert($game_map.shadows.opacity==255,'ending fade completes')
    image=Graphics.snap_to_bitmap
    pixel=image.get_pixel(Graphics.width/2,Graphics.height/2-16)
    EndingHintQA.assert(pixel.red<3 && pixel.green<3 && pixel.blue<3,'actor is visually black before cleanup')
    image.save('captures/'+('%02d_'%EndingHintQA.hint)+'fade-end.png') if [1,18,24].include?(EndingHintQA.hint)
    image.dispose
  end
  alias hint_qa_command_101 command_101
  def command_101
    EndingHintQA.current=@index;EndingHintQA.serial+=1
    hint_qa_command_101
  end
end
class Scene_Map
  alias hint_qa_update update
  def update
    hint_qa_update
    EndingHintQA.observe(self)
  end
end
class Scene_Title
  alias hint_qa_start start
  def start
    hint_qa_start
    EndingHintQA.finish
    if EndingHintQA.hint==EndingHintQA::LIMIT
      $game_map.setup(21)
      EndingHintQA.assert($game_map.name_display,'map name setting restored outside the hint stage')
      viewports=Spriteset_Map.allocate
      viewports.create_viewports;viewports.update_viewport_sizes
      rect=viewports.instance_variable_get(:@viewport1).rect
      expected_x=[(Graphics.width-$game_map.width*32)/2,0].max
      EndingHintQA.assert(rect.x==expected_x && rect.width==[Graphics.width,$game_map.width*32].min,'normal map viewport rules remain unchanged')
      viewports.dispose_viewports
      EndingHintQA.log('COMPLETE hints='+EndingHintQA::LIMIT.to_s+' messages='+EndingHintQA.messages.size.to_s)
      SceneManager.exit
    else
      EndingHintQA.prepare
      SceneManager.goto(Scene_Map)
    end
  end
end
