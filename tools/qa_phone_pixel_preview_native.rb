# encoding: UTF-8
# Native RGSS rendering in an isolated copy; command-driven, no physical input.
module Graphics
  def self.update; self.frame_count+=1; end
  def self.transition(*); self.brightness=255; end
  def self.freeze; end
  def self.wait(n); n.times {update}; end
  def self.fadeout(*); end
end
module Input
  def self.update; end
  def self.trigger?(*); false; end
  def self.repeat?(*); false; end
  def self.press?(*); false; end
  def self.dir4; 0; end
  def self.dir8; 0; end
end
module PixelPreviewQA
  class << self; attr_accessor :started,:checks; end
  self.checks=0
  def self.log(text)
    File.open('pixel-preview.log','ab'){|file|file.write(text.to_s+"\r\n")}
  end
  def self.assert(condition,message)
    raise message unless condition
    self.checks+=1;log('PASS '+message)
  end
  def self.shot(name)
    image=Graphics.snap_to_bitmap;image.save('captures/'+name+'.png');image.dispose
  end
  def self.run(scene)
    assert(Font.exist?('VT323'),'bundled VT323 is available without a Windows install')
    assert(scene.phone_pixel_preview?,'home uses the pixel prototype')
    original=Marshal.dump([PhoneMenu::CONTACTS.to_a,$game_config.phone_group_chats])
    scene.instance_variable_set(:@selected_index,4)
    scene.update_icon_animation
    scene.instance_variable_get(:@icon_sprites).each do |sprite|
      assert(sprite.zoom_x==1.0 && sprite.zoom_y==1.0,'app icon remains at integer scale')
    end
    scene.instance_variable_set(:@animation_frame,10)
    scene.update_icon_animation
    assert(scene.instance_variable_get(:@icon_sprites)[4].zoom_x==1.0,'selection never stretches pixel icons')
    shot('01-home')
    scene.command_contacts
    shot('02-messages-list')
    entries=scene.pmgc_entries
    index=entries.index{|entry|entry[:kind]==:group && !entry[:messages].empty?}
    assert(!!index,'preview uses an existing game transcript')
    scene.instance_variable_set(:@contact_index,[index-2,0].max)
    scene.instance_variable_set(:@selected_contact,[index,2].min)
    scene.instance_variable_set(:@in_message_view,true)
    scene.instance_variable_set(:@message_index,0)
    scene.show_contact_details
    shot('03-conversation')
    entry=scene.pmgc_current_entry
    long_index=entry[:messages].index do |row|
      message=scene.pmgc_normal_message_to_hash(row)
      message[:type]!=:image && scene.pmgc_wrap_text(message[:text],0).size>=3
    end
    if long_index
      scene.instance_variable_set(:@message_index,long_index)
      scene.show_contact_details
      shot('04-long-message')
    end
    lines=scene.pmgc_wrap_text('Hải Quỳ, Shylvie, Giáng sinh: Ắ Ằ Ẳ Ẵ Ặ Ấ Ề Ễ Ộ Ớ Ỡ Ự Ỳ Ỹ. '*20,0)
    lines.each{|line|assert(scene.simple_text_width(line,17)<=194,'Vietnamese line fits its text area')}
    assert(Marshal.dump([PhoneMenu::CONTACTS.to_a,$game_config.phone_group_chats])==original,'drawing does not rewrite conversations or save state')
    scene.instance_variable_set(:@gallery_screen,true)
    assert(!scene.phone_pixel_preview?,'Gallery retains its current theme during review')
    scene.instance_variable_set(:@gallery_screen,false)
    scene.close_contacts_screen
    shot('05-return-home')
    scene.dispose_phone_menu_sprites
    assert(scene.instance_variable_get(:@icon_sprites).all?{|sprite|sprite.disposed?&&sprite.bitmap.disposed?},'owned pixel icons are disposed')
    assert(!Cache.load_bitmap('Graphics/PhoneMenu/','Contact_Quy').disposed?,'shared artwork survives disposal')
    File.open('completion.marshal','wb'){|file|file.write(Marshal.dump({:complete=>true,:checks=>checks,:font=>WCFPhonePixel.font,:transcript=>entry[:id]}))}
    log('COMPLETE checks='+checks.to_s)
    SceneManager.exit
  end
end
class << SceneManager
  alias pixel_preview_qa_run run
  def run
    pixel_preview_qa_run
  rescue Exception=>error
    PixelPreviewQA.log('FAIL '+error.class.to_s+': '+error.message+"\r\n"+error.backtrace.join("\r\n"))
    exit
  end
  def first_scene_class
    DataManager.setup_new_game
    WCFTestHub.prepare(:market_prep,:variables=>{42=>3,43=>3})
    $game_map.setup(3);$game_player.moveto(4,4)
    Scene_Map
  end
end
class Scene_Map
  alias pixel_preview_qa_start start
  def start
    pixel_preview_qa_start
    return if PixelPreviewQA.started
    PixelPreviewQA.started=true
    SceneManager.snapshot_for_background
    SceneManager.call(Scene_Menu)
  end
end
class Scene_Menu
  alias pixel_preview_qa_post_start post_start
  def post_start
    pixel_preview_qa_post_start
    30.times{update_opening_animation}
    PixelPreviewQA.run(self)
  end
end
