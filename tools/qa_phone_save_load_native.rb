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
      WCFSaveNativeQA.snapshot(self,'02-save-detail')
    when 41
      @ps_mode,@ps_pending,@ps_choice=:confirm,:save,0
      @ps_preview=WCFPhoneSaveRecord.capture
      ps_redraw
      WCFSaveNativeQA.snapshot(self,'03-overwrite')
    when 44
      WCFSaveNativeQA.confirm_key(self,:C)
      WCFSaveNativeQA.assert(WCFPhoneSaveStore.read(0)[:record][:recipient]=='Shylvie','overwrite Shylvie keeps selected recipient')
      WCFSaveNativeQA.snapshot(self,'04-saved')
    when 47
      @ps_index,@ps_mode=4,:list
      ps_redraw
      WCFSaveNativeQA.snapshot(self,'05-empty-and-corrupt')
    when 50
      @ps_index,@ps_mode,@ps_pending,@ps_choice=1,:confirm,:delete,0
      ps_redraw
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
      @ps_index,@ps_mode,@ps_pending,@ps_choice=0,:confirm,:load,0
      ps_redraw
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
[Scene_Item,Scene_System].each do |type|
  type.class_eval do
    alias wcf_qa_app_update update
    def update
      wcf_qa_app_update
      @qa_app_frames=(@qa_app_frames||0)+1
      return_scene if @qa_app_frames==30
    end
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
