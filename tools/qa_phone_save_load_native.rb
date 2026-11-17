# encoding: UTF-8
# Isolated native RGSS harness: installed into a copied pack only by the builder.
# It never runs a route or sends keyboard / mouse input.
# Hidden RGSS windows suspend Graphics.update while unfocused. Render the actual
# native bitmaps directly instead, and run the same scene logic without that wait.
module Graphics
  def self.update; end
  def self.transition(*args); @qa_last_transition=args; end
  def self.qa_last_transition; @qa_last_transition; end
  def self.freeze
    parts=WCFSaveNativeQA.handoff_parts
    if parts
      WCFSaveNativeQA.assert(parts.all? { |part| part.visible && !part.disposed? },
        'freeze still contains visible phone before cleanup')
      WCFSaveNativeQA.handoff_parts=nil
    end
  end
  def self.fadeout(*args); end
end
module Input
  class << self; attr_accessor :qa_trigger; end
  def self.update; end
  def self.trigger?(key); @qa_trigger==key; end
  def self.repeat?(*args); false; end
  def self.press?(*args); false; end
end
module Audio
  class << self
    attr_reader :qa_bgm_args
    alias wcf_settings_qa_bgm_play bgm_play
    def bgm_play(*args)
      @qa_bgm_args=args
      wcf_settings_qa_bgm_play(*args)
    end
  end
end
module WCFSaveNativeQA
  class << self; attr_accessor :phase,:handoff_parts; end
  def self.log(value)
    File.open('save-load-qa.txt','ab') { |file| file.write(value.to_s+"\r\n") }
  end
  def self.assert(value,message)
    raise message unless value
    log('PASS '+message)
  end
  def self.snapshot(scene,name)
    shot=Bitmap.new(Graphics.width,Graphics.height)
    shot.fill_rect(shot.rect,Color.new(8,12,24))
    [:@background_sprite,:@ps_overlay,:@ps_panel].each do |name|
      sprite=scene.instance_variable_get(name)
      if name == :@ps_panel
        shot.blt(Scene_File::PS_X,Scene_File::PS_Y,sprite.bitmap,sprite.bitmap.rect)
      else
        cache=scene.instance_variable_get(:@qa_rotated) || {}
        scene.instance_variable_set(:@qa_rotated,cache)
        rotated=cache[name]
        unless rotated
          source=sprite.bitmap
          rotated=Bitmap.new(source.height,source.width)
          source.width.times do |x|
            source.height.times { |y| rotated.set_pixel(y,source.width-1-x,source.get_pixel(x,y)) }
          end
          cache[name]=rotated
        end
        shot.blt(Scene_File::PS_X,Scene_File::PS_Y,rotated,rotated.rect)
      end
    end
    assert(shot.save(name+'.png'),'snapshot '+name)
    shot.dispose
  end
  def self.confirm_key(scene,key)
    Input.qa_trigger=key
    scene.ps_update_actions
  ensure
    Input.qa_trigger=nil
  end
  def self.settings_key(scene,key)
    Input.qa_trigger=key
    scene.wsp_update_input
  ensure
    Input.qa_trigger=nil
  end
  def self.library_key(scene,key)
    Input.qa_trigger=key
    scene.lib_update_input
  ensure
    Input.qa_trigger=nil
  end
  def self.library_snapshot(scene,name)
    shot=Bitmap.new(Graphics.width,Graphics.height)
    shot.fill_rect(shot.rect,Color.new(8,12,24))
    if scene.instance_variable_get(:@lib_mode)==:full
      source=scene.instance_variable_get(:@lib_full).bitmap
      shot.blt(0,0,source,source.rect)
    else
      [:@background_sprite,:@lib_overlay].each do |key|
        sprite=scene.instance_variable_get(key)
        cache=scene.instance_variable_get(:@qa_library_rotated) || {}
        scene.instance_variable_set(:@qa_library_rotated,cache)
        rotated=cache[key]
        unless rotated
          source=sprite.bitmap
          rotated=Bitmap.new(source.height,source.width)
          source.width.times do |x|
            source.height.times { |y| rotated.set_pixel(y,source.width-1-x,source.get_pixel(x,y)) }
          end
          cache[key]=rotated
        end
        shot.blt(Scene_ItemLibrary::LIB_X,Scene_ItemLibrary::LIB_Y,rotated,rotated.rect)
      end
      panel=scene.instance_variable_get(:@lib_panel)
      shot.blt(panel.x,panel.y,panel.bitmap,panel.bitmap.rect)
    end
    assert(shot.save(name+'.png'),'snapshot '+name)
    shot.dispose
  end
  def self.settings_snapshot(scene,name)
    shot=Bitmap.new(Graphics.width,Graphics.height)
    shot.fill_rect(shot.rect,Color.new(8,12,24))
    [:@background_sprite,:@wsp_overlay,:@wsp_panel].each do |key|
      sprite=scene.instance_variable_get(key)
      shot.blt(sprite.x,sprite.y,sprite.bitmap,sprite.bitmap.rect)
    end
    assert(shot.save(name+'.png'),'snapshot '+name)
    shot.dispose
  end
end

class << SceneManager
  alias wcf_save_qa_run run
  def run
    WCFSaveNativeQA.log('BOOT ruby='+RUBY_VERSION)
    wcf_save_qa_run
  rescue Exception => error
    WCFSaveNativeQA.log('FAIL '+error.class.to_s+': '+error.message.to_s)
    WCFSaveNativeQA.log(error.backtrace.join("\r\n"))
    exit
  end
  def first_scene_class
    DataManager.setup_new_game
    $game_party.gain_item($data_items[18],1)
    DataManager.setup_new_game
    WCFSaveNativeQA.assert(WCFItemLibrary.unlocked?('item:18') && $game_party.item_number($data_items[18])==0,
      'item discoveries survive a real New Game without giving the item back')
    WCFTestHub.prepare(:market_prep,:variables=>{42=>3,43=>2})
    $game_map.setup(37)
    $game_player.moveto(11,7)
    WCFSaveNativeQA.assert(WCFPhoneSaveStore.write(0),'write first save through Yanfly')
    WCFTestHub.prepare(:jewel_party,:variables=>{57=>4})
    $game_map.setup(38)
    WCFSaveNativeQA.assert(WCFPhoneSaveStore.write(1),'write Christmas stone save')
    # Exercise fallback for saves made before the new metadata was present.
    legacy=DataManager.make_save_header
    legacy.delete(:wcf_phone_save)
    File.open(DataManager.make_filename(2),'wb') do |file|
      Marshal.dump(legacy,file)
      Marshal.dump(DataManager.make_save_contents,file)
    end
    WCFSaveNativeQA.assert(WCFPhoneSaveStore.read(2)[:record][:recipient]=='Hakase','read legacy Yanfly header')
    WCFSaveNativeQA.assert(DataManager.load_game(2) && $game_variables[57]==4,'load legacy save contents')
    File.open(DataManager.make_filename(4),'wb') { |file| file.write('invalid save fixture') }
    DataManager.setup_new_game
    WCFTestHub.prepare(:market_prep,:variables=>{42=>3,43=>3})
    $game_map.setup(37)
    $game_player.moveto(11,7)
    Scene_Title
  end
end

class Scene_File
  alias wcf_qa_file_post_start post_start
  def post_start
    wcf_qa_file_post_start
    from_phone=@wcf_phone_origin==:phone
    expected=from_phone ? 0 : 10
    WCFSaveNativeQA.assert(Graphics.qa_last_transition==[expected],
      from_phone ? 'phone app has no second engine fade' : 'title load keeps normal engine transition')
    WCFSaveNativeQA.assert(@ps_overlay_alpha==(from_phone ? PhoneMenu::MAIN_OVERLAY_OPACITY : 240),
      'first file frame uses matching overlay alpha')
  end
  alias wcf_save_qa_update update
  def update
    wcf_save_qa_update
    @qa_frame=(@qa_frame||0)+1
    return wcf_qa_load_steps if is_a?(Scene_Load)
    case @qa_frame
    when 35
      @ps_index=0
      ps_redraw
      WCFSaveNativeQA.snapshot(self,'01-save-list')
    when 38
      @ps_mode=:actions
      ps_redraw
      WCFSaveNativeQA.assert(ps_actions.map { |option| option[1] }==[:save,:delete,:back],
        'save action first and Back last')
      WCFSaveNativeQA.snapshot(self,'02-save-detail')
    when 41
      @ps_mode,@ps_pending,@ps_choice=:confirm,:save,0
      @ps_preview=WCFPhoneSaveRecord.capture
      ps_redraw
      color=@ps_panel.bitmap.get_pixel(27,300)
      WCFSaveNativeQA.assert(color.red > color.green && color.green > color.blue,
        'overwrite keyboard guide has an amber accent')
      WCFSaveNativeQA.snapshot(self,'03-overwrite')
    when 44
      WCFSaveNativeQA.confirm_key(self,:C)
      WCFSaveNativeQA.assert(WCFPhoneSaveStore.read(0)[:record][:recipient]=='Shylvie','overwrite Shylvie keeps selected recipient')
      WCFSaveNativeQA.snapshot(self,'04-saved')
    when 47
      @ps_index,@ps_mode=4,:list
      ps_redraw
      WCFSaveNativeQA.snapshot(self,'05-empty-and-corrupt')
      @ps_index,@ps_mode,@ps_pending=5,:confirm,:save
      @ps_preview=WCFPhoneSaveRecord.capture
      ps_redraw
      color=@ps_panel.bitmap.get_pixel(27,300)
      WCFSaveNativeQA.assert(color.green > color.red && color.green > color.blue,
        'new save keyboard guide has a green accent')
      WCFSaveNativeQA.snapshot(self,'05b-new-save-confirm')
    when 50
      @ps_index,@ps_mode,@ps_pending,@ps_choice=1,:confirm,:delete,0
      ps_redraw
      color=@ps_panel.bitmap.get_pixel(27,300)
      WCFSaveNativeQA.assert(color.red > color.green*1.5 && color.red > color.blue*1.5,
        'delete keyboard guide has a red accent')
      WCFSaveNativeQA.snapshot(self,'06-delete-confirm')
    when 51
      WCFSaveNativeQA.confirm_key(self,:B)
      WCFSaveNativeQA.assert(File.exist?(DataManager.make_filename(1)),'X cancels deletion directly')
    when 53
      return_scene
    end
  end
  def wcf_qa_load_steps
    if WCFSaveNativeQA.phase == :title_load
      if @qa_frame == 1
        WCFSaveNativeQA.assert(@ps_rotation_mode.nil? && @background_sprite.angle==90 && @ps_panel.visible,
          'title load opens directly in landscape without rotation')
        WCFSaveNativeQA.snapshot(self,'00-title-load')
      elsif @qa_frame == 3
        return_scene
        WCFSaveNativeQA.assert(@ps_rotation_mode.nil? && @background_sprite.angle==90,
          'title load returns directly without portrait rotation')
      end
      return
    end
    if WCFSaveNativeQA.phase == :load_back
      return_scene if @qa_frame == 35
      return
    end
    case @qa_frame
    when 35
      @ps_index=0
      ps_redraw
      WCFSaveNativeQA.snapshot(self,'07-load-list')
    when 38
      @ps_index,@ps_mode,@ps_choice=0,:actions,0
      ps_redraw
      WCFSaveNativeQA.assert(ps_actions.map { |option| option[1] }==[:load,:delete,:back],
        'load action first and Back last')
      WCFSaveNativeQA.snapshot(self,'07b-load-detail')
      @ps_index,@ps_mode,@ps_pending,@ps_choice=0,:confirm,:load,0
      ps_redraw
      color=@ps_panel.bitmap.get_pixel(27,300)
      WCFSaveNativeQA.assert(color.blue > color.red && color.blue > color.green,
        'load keyboard guide has a blue accent')
      WCFSaveNativeQA.snapshot(self,'08-load-confirm')
    when 41
      WCFSaveNativeQA.confirm_key(self,:C)
    end
  end
  alias wcf_qa_dispose_background dispose_background
  def dispose_background
    owned=Array(@ps_owned_sprites).dup
    if @ps_rotation_frame == PS_ROTATION_FRAMES && !@ps_panel.visible
      WCFSaveNativeQA.assert(@background_sprite.angle==0,'rotate back to portrait before return')
    end
    cache=instance_variable_get(:@qa_rotated) || {}
    cache.each_value { |bitmap| bitmap.dispose }
    wcf_qa_dispose_background
    WCFSaveNativeQA.assert(owned.all? { |sprite| sprite.disposed? && sprite.bitmap.disposed? },'dispose owned phone surfaces')
    art=Cache.load_bitmap('Graphics/PhoneMenu/',PhoneMenu::BACKGROUND)
    WCFSaveNativeQA.assert(!art.disposed?,'keep cached phone artwork')
  end
end

class Scene_Title
  # Title navigation is tested; audio playback is unrelated to this harness.
  def play_title_music; end
  alias wcf_qa_title_post_start post_start
  def post_start
    wcf_qa_title_post_start
    @qa_title_frames=0
    if WCFSaveNativeQA.phase == :title_load
      WCFSaveNativeQA.assert(true,'returned to title after cold load')
      WCFSaveNativeQA.phase=:title_after
    elsif WCFSaveNativeQA.phase.nil?
      WCFSaveNativeQA.phase=:title_initial
    end
  end
  alias wcf_qa_title_update update
  def update
    wcf_qa_title_update
    @qa_title_frames=(@qa_title_frames||0)+1
    return unless @qa_title_frames==40
    if WCFSaveNativeQA.phase == :title_initial
      WCFSaveNativeQA.phase=:title_load
      command_continue
    elsif WCFSaveNativeQA.phase == :title_after
      WCFSaveNativeQA.phase=nil
      SceneManager.call(Scene_Menu)
    end
  end
end

class Scene_Menu
  alias wcf_qa_leave_phone_scene leave_phone_scene
  def leave_phone_scene(type)
    parts=phone_visual_sprites.select { |part| part.visible && part.opacity > 0 }
    wcf_qa_leave_phone_scene(type)
    WCFSaveNativeQA.assert(!parts.empty? && parts.all? { |part| part.visible && !part.disposed? },
      'phone remains visible after app call '+type.to_s)
    WCFSaveNativeQA.handoff_parts=parts
  end
  alias wcf_qa_menu_post_start post_start
  def post_start
    wcf_qa_menu_post_start
    @qa_home_frames=0
    phase=WCFSaveNativeQA.phase
    if phase.nil?
      WCFSaveNativeQA.assert(@animation_state==:opening,'fresh phone still slides in')
      WCFSaveNativeQA.phase=:initial
    else
      WCFSaveNativeQA.assert(@animation_state==:idle && @phone_slide_offset==0,
        'resume phone without slide after '+phase.to_s)
      WCFSaveNativeQA.phase={:save=>:after_save,:item=>:after_item,
        :system=>:after_system,:load_back=>:after_load}[phase]
    end
  end
  alias wcf_qa_menu_update update
  def update
    wcf_qa_menu_update
    @qa_home_frames+=1
    return unless @qa_home_frames==40
    case WCFSaveNativeQA.phase
    when :initial
      WCFSaveNativeQA.phase=:save
      command_save
    when :after_save
      WCFSaveNativeQA.phase=:item
      command_item
    when :after_item
      WCFSaveNativeQA.phase=:system
      command_system
    when :after_system
      command_contacts
      close_contacts_screen
      WCFSaveNativeQA.assert(@animation_state==:idle,'contacts return without slide')
      command_gallery
      close_gallery_screen
      WCFSaveNativeQA.assert(@animation_state==:idle,'gallery return without slide')
      WCFSaveNativeQA.phase=:load_back
      command_load
    when :after_load
      WCFSaveNativeQA.phase=:load_final
      command_load
    end
  end
end
class Scene_ItemLibrary
  alias wcf_qa_library_update update
  def update
    wcf_qa_library_update
    return if @lib_rotation_mode
    @qa_library_frames=(@qa_library_frames||0)+1
    case @qa_library_frames
    when 2
      WCFSaveNativeQA.assert(@lib_entries.size==45,'item library registers 44 pictures plus RAM')
      WCFSaveNativeQA.assert(!@lib_entries.any? { |entry| entry[:key]=='item:17' },'KUL test lantern absent from library')
      WCFSaveNativeQA.assert(@background_sprite.angle==90 && @lib_panel.bitmap.width==460 && @lib_panel.bitmap.height==336,
        'library opens as landscape phone with 18 cells')
      WCFSaveNativeQA.library_snapshot(self,'13-library-locked')
      WCFSaveNativeQA.library_key(self,:C)
      WCFSaveNativeQA.assert(@lib_mode==:grid,'locked items cannot be opened')
    when 4
      WCFGalleryScene.show(2)
      WCFGalleryScene.hide
      Game_Picture.new(99).show('CG3',0,0,0,100,100,255,0)
      GlobalGallery.unlock(75)
      $game_party.gain_item($data_items[18],1)
      $game_party.gain_item($data_items[18],-1)
      $game_party.gain_item($data_items[17],1)
      WCFSaveNativeQA.assert(!WCFItemLibrary.unlocked?('item:17'),'receiving KUL test lantern does not discover it')
      $game_party.gain_item($data_items[17],-1)
      WCFSaveNativeQA.assert(WCFItemLibrary.unlocked?('picture:cg2') && WCFItemLibrary.unlocked?('picture:cg3'),
        'both framed CG and direct Picture discover items')
      WCFSaveNativeQA.assert(!GlobalGallery.load[2] && !GlobalGallery.load[75],
        'new gift discoveries do not unlock Gallery slots')
      ids=Scene_Menu.new.gallery_picture_ids
      WCFSaveNativeQA.assert(ids.size==41 && (ids & PhoneMenu::ITEM_PICTURE_IDS).empty?,
        'Gallery contains only 41 scene and ending images with original IDs')
      # Populate the isolated QA collection to inspect all thumbnail crops.
      PhoneMenu::ITEM_PICTURE_IDS.each { |id| WCFItemLibrary.encounter_picture(PhoneMenu::GALLERY_PICTURE_FILES[id]) }
      @lib_entries=WCFItemLibrary.entries
      # Verify real RGSS font metrics, including Vietnamese, at the menu's
      # actual description width and size. Render every approved card.
      @lib_entries.each_with_index do |entry,index|
        WCFSaveNativeQA.assert(!entry[:description].empty?,'description present '+entry[:key])
        bitmap=@lib_panel.bitmap
        bitmap.font.name,bitmap.font.size,bitmap.font.bold=PhoneMenu::UI_FONT,17,false
        lines=['']
        entry[:description].split(/\s+/).each do |word|
          trial=lines[-1].empty? ? word : lines[-1]+' '+word
          if bitmap.text_size(trial).width<=170 || lines[-1].empty?
            lines[-1]=trial
          else
            lines << word
          end
        end
        WCFSaveNativeQA.assert(lines.size<=7 && lines.all? { |line| bitmap.text_size(line).width<=170 },
          'description fits 170px and 7 lines '+entry[:key]+' lines='+lines.size.to_s)
        @lib_index=index;@lib_mode=:detail
        lib_redraw
        WCFSaveNativeQA.library_snapshot(self,'item-%02d-detail'%(index+1))
      end
      @lib_mode=:grid;@lib_index=0
      lib_redraw
      WCFSaveNativeQA.library_snapshot(self,'14-library-grid')
      @lib_index=18
      lib_redraw
      WCFSaveNativeQA.library_snapshot(self,'14b-library-page-two')
      @lib_index=36
      lib_redraw
      WCFSaveNativeQA.library_snapshot(self,'14c-library-page-three')
      @lib_index=0
      lib_redraw
    when 6
      WCFSaveNativeQA.library_key(self,:C)
      WCFSaveNativeQA.assert(@lib_mode==:detail,'item Z opens descriptive card')
      WCFSaveNativeQA.library_snapshot(self,'15-library-detail')
    when 8
      WCFSaveNativeQA.library_key(self,:C)
      WCFSaveNativeQA.assert(@lib_mode==:full && @lib_full.visible,'item Z opens full image')
      WCFSaveNativeQA.library_snapshot(self,'16-library-full')
    when 10
      WCFSaveNativeQA.library_key(self,:B)
      WCFSaveNativeQA.library_key(self,:B)
      @lib_index=@lib_entries.index { |entry| entry[:key]=='item:18' }
      lib_redraw
      WCFSaveNativeQA.library_snapshot(self,'17-library-ram-grid')
      WCFSaveNativeQA.library_key(self,:C)
      WCFSaveNativeQA.library_snapshot(self,'18-library-ram-detail')
      WCFSaveNativeQA.assert($game_party.item_number($data_items[18])==0,
        'viewing library never grants or consumes gameplay items')
    when 12
      WCFItemLibrary.instance_variable_set(:@keys,nil)
      WCFSaveNativeQA.assert(WCFItemLibrary.unlocked?('picture:cg2'),'item discoveries reload from their own disk file')
      WCFSaveNativeQA.assert(DataManager.load_game(0),'load pre-discovery save during library test')
      WCFSaveNativeQA.assert(WCFItemLibrary.unlocked?('picture:cg2') && WCFItemLibrary.unlocked?('item:18'),
        'loading an earlier save preserves global item discoveries')
    when 16
      return_scene
    end
  end
  alias wcf_qa_library_dispose dispose_background
  def dispose_background
    owned=@lib_owned.dup
    WCFSaveNativeQA.assert(@background_sprite.angle==0,'library rotates back to portrait before return')
    cache=instance_variable_get(:@qa_library_rotated) || {}
    cache.each_value { |bitmap| bitmap.dispose }
    wcf_qa_library_dispose
    WCFSaveNativeQA.assert(owned.all? { |sprite| sprite.disposed? && sprite.bitmap.disposed? },
      'library disposes owned phone and full-image surfaces')
  end
end
class Scene_System
  alias wcf_qa_settings_update update
  def update
    wcf_qa_settings_update
    @qa_settings_frames=(@qa_settings_frames||0)+1
    case @qa_settings_frames
    when 3
      WCFSaveNativeQA.assert(@wsp_panel.bitmap.width==336 && @wsp_panel.bitmap.height==460,
        'settings use portrait phone canvas')
      WCFSaveNativeQA.assert(@command_window.nil? && @help_window.nil?,
        'settings replace default Yanfly windows')
      WCFSaveNativeQA.assert(transition_speed==0,'settings enter from phone without extra fade')
      WCFSaveNativeQA.settings_snapshot(self,'09-settings-audio')
    when 5
      original=RPG::BGM.last
      RPG::BGM.new('bedroom',80,100).play(8000)
      before=RPG::BGM.last.pos
      volume=$game_system.volume(:bgm)
      wsp_change(-1)
      WCFSaveNativeQA.assert($game_system.volume(:bgm)==volume-1,'settings change real Yanfly BGM volume')
      args=Audio.qa_bgm_args
      WCFSaveNativeQA.assert((args[1].to_f-80*(volume-1)*0.01).abs < 0.1,
        'new BGM volume reaches audio backend')
      WCFSaveNativeQA.assert(args[3]>=before && args[3]-before<500,
        'BGM adjustment retains playback position')
      $game_system.volume_change(:bgm,1)
      original.name.empty? ? RPG::BGM.stop : original.play(original.pos)
      wsp_move(3)
      wsp_toggle(:autodash,false)
      WCFSaveNativeQA.assert(!$game_system.autodash?,'settings update real autodash option')
      wsp_move(1)
      WCFSaveNativeQA.settings_key(self,:C)
      WCFSaveNativeQA.assert($game_system.instantmsg?,'settings update real instant-message option')
      WCFSaveNativeQA.settings_snapshot(self,'09b-settings-text-instant')
      wsp_toggle(:instantmsg,false)
      WCFSaveNativeQA.settings_snapshot(self,'09c-settings-text-gradual')
    when 8
      wsp_move(7-@wsp_index)
      WCFSaveNativeQA.settings_snapshot(self,'10-settings-system')
    when 10
      wsp_move(5-@wsp_index)
      WCFSaveNativeQA.settings_key(self,:C)
      WCFSaveNativeQA.assert(@wsp_pending==:to_title,'settings require confirmation before title')
      WCFSaveNativeQA.settings_snapshot(self,'11-settings-title-confirm')
    when 12
      WCFSaveNativeQA.settings_key(self,:B)
      WCFSaveNativeQA.assert(@wsp_pending.nil? && @wsp_index==5,'X cancels title and preserves row')
      wsp_move(1)
      WCFSaveNativeQA.settings_key(self,:C)
      WCFSaveNativeQA.assert(@wsp_pending==:shutdown,'settings require confirmation before shutdown')
      WCFSaveNativeQA.settings_snapshot(self,'12-settings-exit-confirm')
    when 14
      WCFSaveNativeQA.settings_key(self,:B)
      WCFSaveNativeQA.assert(@wsp_pending.nil?,'X cancels shutdown')
    when 18
      surfaces=@wsp_owned.dup
      return_scene
      @qa_settings_surfaces=surfaces
    end
  end
  alias wcf_qa_settings_dispose dispose_background
  def dispose_background
    wcf_qa_settings_dispose
    WCFSaveNativeQA.assert(Array(@qa_settings_surfaces).all? { |sprite| sprite.disposed? && sprite.bitmap.disposed? },
      'settings dispose owned phone surfaces')
  end
end
class Scene_Load
  alias wcf_qa_load_success on_load_success
  def on_load_success
    wcf_qa_load_success
    WCFSaveNativeQA.assert($game_variables[43]==3,'load selected Shylvie route')
    WCFSaveNativeQA.assert($game_config && $game_config.phone_group_chats,'restore phone configuration')
    WCFSaveNativeQA.assert($game_map.map_id==37,'load preparation map')
    WCFSaveNativeQA.log('COMPLETE')
    SceneManager.exit
  end
end
