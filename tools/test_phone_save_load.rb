# frozen_string_literal: true

# Runs production save-card / input / storage code without launching Game.exe.
require 'minitest/autorun'
require 'ostruct'
require 'tmpdir'

module Graphics
  def self.width; 640; end
  def self.height; 480; end
end
Color = Struct.new(:red,:green,:blue,:alpha) do
  def initialize(r=0,g=0,b=0,a=255); super; end
  def set(*values); self.red,self.green,self.blue,self.alpha=values; end
end
Rect = Struct.new(:x,:y,:width,:height)
class Bitmap
  attr_reader :width,:height,:font,:draws,:clears,:images
  def initialize(w,h)
    @width,@height,@font=w,h,OpenStruct.new
    @draws,@images,@clears=[],[],0
  end
  def text_size(text); Rect.new(0,0,text.scan(/\P{M}\p{M}*/).size*(@font.size||14)*0.56,20); end
  def rect; Rect.new(0,0,width,height); end
  def clear; @clears+=1; @draws.clear; @images.clear; end
  def fill_rect(*); end
  def draw_text(x,y,w,h,text,align=0); @draws << [x,y,w,h,text,align,text_size(text).width]; end
  def blt(*); end
  def stretch_blt(dest,source,src); @images << [dest,source,src]; end
  def dispose; @disposed=true; end
  def disposed?; !!@disposed; end
end
class Sprite
  attr_accessor :bitmap,:x,:y,:z,:viewport,:color,:angle,:ox,:oy,:zoom_x,:zoom_y,:visible
  def initialize
    @x=@y=@z=@angle=@ox=@oy=0
    @zoom_x=@zoom_y=1.0
    @visible=true
    @color=Color.new
  end
  def dispose; @disposed=true; end
  def disposed?; !!@disposed; end
end
class Viewport
  attr_accessor :z
  attr_reader :was_disposed
  def initialize(*rect); @rect=rect; end
  # The game's native viewport wrapper lacks disposed?.
  def dispose; @was_disposed=true; end
end
module Cache
  def self.load_bitmap(folder,name)
    raise "Missing asset #{name}" unless File.file?(File.join(__dir__,'..',folder,name+'.png'))
    @cache ||= {}
    @cache[name] ||= Bitmap.new(350,480)
  end
end
module Input
  def self.press(*keys); @keys=keys; end
  def self.trigger?(key); Array(@keys).include?(key); end
  def self.repeat?(key); trigger?(key); end
end
module Sound
  def self.method_missing(name,*); (@sounds||=[]) << name; end
  def self.sounds; @sounds||=[]; end
  def self.clear; @sounds=[]; end
end
module SceneManager
  def self.background_bitmap; @background ||= Bitmap.new(640,480); end
end
class Scene_MenuBase
  def transition_speed; 10; end
end
class Scene_File < Scene_MenuBase
  attr_reader :returned,:loaded,:save_callbacks
  def first_savefile_index; 0; end
  def update; end
  def return_scene; @returned=true; end
  def on_load_success; @loaded=(@loaded||0)+1; end
  def on_save_success; @save_callbacks=(@save_callbacks||0)+1; end
end
class Scene_Save < Scene_File; end
class Scene_Load < Scene_File; end
module DataManager
  class << self
    attr_accessor :folder,:load_calls,:saved,:load_result,:save_result,:save_raises
  end
  self.load_calls=0
  def self.make_save_header; {:characters=>[], :playtime_s=>'01:02:03'}; end
  def self.make_filename(index); File.join(folder,"Save%02d.rvdata2" % (index+1)); end
  def self.savefile_max; 24; end
  def self.load_header(index)
    self.load_calls+=1
    Marshal.load(File.binread(make_filename(index))) rescue nil
  end
  def self.save_game(index)
    self.saved=index
    if save_raises
      File.delete(make_filename(index)) if File.exist?(make_filename(index))
      raise 'Simulated I/O exception'
    end
    unless save_result
      File.delete(make_filename(index)) if File.exist?(make_filename(index))
      return false
    end
    File.open(make_filename(index),'wb') { |file| file.write(Marshal.dump(make_save_header)) }
    true
  end
  def self.load_game(index); self.saved=index; load_result; end
  def self.delete_save_file(index); File.delete(make_filename(index)) rescue nil; end
end

source=File.read(File.join(__dir__,'../Scripts/Custom Menu.rb'),encoding:'UTF-8')
eval(source[/^module PhoneMenu.*?^end/m],TOPLEVEL_BINDING,'PhoneMenu config')
section=source.index("module WCFPhoneSaveRecord\n") || source.index("module WCFPhoneSaveRecord\r\n")
raise 'Save/Load implementation missing' unless section
eval(source[section..-1],TOPLEVEL_BINDING,'Custom Menu save/load')

class PhoneSaveLoadTest < Minitest::Test
  def setup
    @dir=Dir.mktmpdir('wcf-phone-save-')
    DataManager.folder=@dir
    DataManager.load_calls=0
    DataManager.saved=nil
    DataManager.save_result=DataManager.load_result=true
    DataManager.save_raises=false
    $game_map=OpenStruct.new(map_id:37,display_name:'Internal preparation variant 65')
    $game_system=OpenStruct.new(playtime_s:'01:42:18',save_disabled:false)
    $game_switches=Hash.new(false)
    $game_variables=Hash.new(0)
    $game_switches[44]=true
    $game_variables.merge!(42=>3,43=>3,44=>2)
    Input.press
    Sound.clear
    @scenes=[]
  end
  def teardown
    @scenes.each(&:dispose_background)
    FileUtils.remove_entry(@dir)
  end
  def record(map_id=37, switches=$game_switches, variables=$game_variables)
    WCFPhoneSaveRecord.describe(OpenStruct.new(map_id:map_id,display_name:'Internal map'),switches,variables,'01:42:18')
  end
  def put(index,header)
    File.binwrite(DataManager.make_filename(index),Marshal.dump(header))
  end
  def scene(type=Scene_Save)
    obj=type.new
    obj.wcf_phone_origin=:phone
    @scenes << obj
    obj.create_background
    obj.create_all_windows
    Scene_File::PS_ROTATION_FRAMES.times { obj.update }
    obj
  end
  def press(obj,*keys)
    Input.press(*keys)
    obj.update
    Input.press
  end
  def text(obj)
    obj.instance_variable_get(:@ps_panel).bitmap.draws.map { |draw| draw[4] }.join("\n")
  end
  def choose_action(obj,ordinal=1)
    press(obj,:C)
    ordinal.times { press(obj,:DOWN) }
    press(obj,:C)
  end
  def confirm(obj)
    press(obj,:C)
  end
  def test_all_sixteen_supermarket_combinations_keep_gift_and_recipient_independent
    WCFPhoneSaveRecord::MARKET_GIFTS.each do |gift_id,gift|
      WCFPhoneSaveRecord::RECIPIENTS.each do |target_id,target|
        vars={42=>gift_id,43=>target_id}
        item=record(37,{44=>true},vars)
        assert_equal [gift,target,false],[item[:gift],item[:recipient],item[:given]]
        item=record(39,{45=>true},vars)
        assert item[:given]
        assert_includes WCFPhoneSaveRecord.gift_text(item),target
      end
    end
  end
  def test_leo_advice_is_not_the_recipient_and_shop_exploration_is_not_a_purchase
    {1=>['Cà phê Luminous','Kohi'],2=>['Khiên','Shylvie'],3=>['Áo choàng tàng hình','Hakase']}.each do |branch,pair|
      item=record(37,{72=>true},{55=>branch,56=>3})
      assert_equal pair,[item[:gift],item[:recipient]]
      assert_empty record(57,{72=>true},{55=>branch,56=>2})[:gift]
      assert_empty record(58,{72=>true},{55=>branch,56=>2})[:gift]
    end
  end
  def test_all_stones_and_other_routes_describe_only_confirmed_choices
    WCFPhoneSaveRecord::JEWEL_GIFTS.each do |branch,pair|
      assert_empty record(64,{76=>true},{57=>branch,58=>1})[:gift]
      item=record(37,{76=>true},{57=>branch,58=>2})
      assert_equal pair,[item[:gift],item[:recipient]]
      refute item[:given]
      assert record(67,{76=>true},{57=>branch,58=>4})[:given]
    end
    assert_equal 'Leo',record(14,{55=>true},{51=>3})[:recipient]
    assert_equal 'Nấu mì cay',record(14,{55=>true},{51=>3})[:title]
    assert_equal 'Sách dịch chuyển',record(37,{61=>true},{52=>2})[:gift]
    assert_equal 'Hakase',record(37,{66=>true},{53=>2})[:recipient]
    assert_empty record(28,{35=>true},{30=>8})[:gift]
    assert_equal 'Mê cung gương',record(28)[:title]
  end
  def test_ambiguous_or_incomplete_state_does_not_invent_a_recipient
    assert_empty record(37,{44=>true},{42=>3,43=>0})[:gift]
    assert_empty record(37,{44=>true,55=>true},{42=>3,43=>3})[:gift]
  end
  def test_header_snapshot_is_frozen_to_the_save_not_current_live_state
    header=DataManager.make_save_header
    assert_equal 'Shylvie',header[:wcf_phone_save][:recipient]
    refute header[:wcf_phone_save].values.any? { |v| v.is_a?(Bitmap) }
    put(0,header)
    $game_variables[43]=2
    assert_equal 'Shylvie',WCFPhoneSaveStore.read(0)[:record][:recipient]
    assert_equal 'Kohi',WCFPhoneSaveRecord.capture[:recipient]
  end
  def test_old_yanfly_header_uses_its_own_map_switches_and_variables
    put(0,{map:OpenStruct.new(map_id:38),switches:{44=>true},variables:{42=>3,43=>4},playtime_s:'02:03:04'})
    item=WCFPhoneSaveStore.read(0)
    assert_equal :ready,item[:state]
    assert_equal 'Hakase',item[:record][:recipient]
    assert_equal 'Tiệc Giáng sinh',item[:record][:title]
    assert_equal '02:03:04',item[:record][:playtime]
    assert_kind_of Integer,item[:record][:saved_at]
  end
  def test_empty_corrupt_and_old_minimal_headers_are_distinct
    assert_equal :empty,WCFPhoneSaveStore.read(0)[:state]
    File.binwrite(DataManager.make_filename(0),'not Marshal data')
    assert_equal :invalid,WCFPhoneSaveStore.read(0)[:state]
    put(1,{characters:[],playtime_s:'00:10:00'})
    assert_equal 'Hành trình của Hải Quỳ',WCFPhoneSaveStore.read(1)[:record][:title]
  end
  def test_backup_restores_previous_file_after_stock_save_failure_or_exception
    [false,true].each do |raises|
      path=DataManager.make_filename(0)
      File.binwrite(path,'original-save-bytes')
      DataManager.save_result=false
      DataManager.save_raises=raises
      refute WCFPhoneSaveStore.write(0)
      assert_equal 'original-save-bytes',File.binread(path)
      refute File.exist?(path+'.phone-backup')
    end
  end
  def test_backup_is_not_overwritten_when_recovery_file_already_exists
    path=DataManager.make_filename(0)
    File.binwrite(path,'original')
    File.binwrite(path+'.phone-backup','recovery')
    refute WCFPhoneSaveStore.write(0)
    assert_equal 'original',File.binread(path)
    assert_equal 'recovery',File.binread(path+'.phone-backup')
    assert_nil DataManager.saved
  end
  def test_save_succeeds_and_cleans_backup_without_changing_slot_count
    put(0,DataManager.make_save_header)
    assert WCFPhoneSaveStore.write(0)
    assert_equal 24,DataManager.savefile_max
    refute File.exist?(DataManager.make_filename(0)+'.phone-backup')
    assert_equal 'Shylvie',WCFPhoneSaveStore.read(0)[:record][:recipient]
  end
  def test_load_scene_rejects_empty_slot_and_calls_existing_load_success_once
    obj=scene(Scene_Load)
    press(obj,:C)
    assert_nil obj.loaded
    assert_equal :list,obj.instance_variable_get(:@ps_mode)
    put(0,DataManager.make_save_header)
    obj.instance_variable_get(:@ps_cache).clear
    choose_action(obj)
    assert_equal 0,obj.instance_variable_get(:@ps_choice)
    assert_nil obj.loaded
    confirm(obj)
    assert_equal 1,obj.loaded
  end
  def test_save_and_overwrite_require_explicit_confirmation_and_update_the_card
    old=record(38,{44=>true},{42=>3,43=>2})
    put(0,{wcf_phone_save:old})
    obj=scene
    choose_action(obj)
    assert_includes text(obj),'Đang có'
    assert_includes text(obj),'Sẽ lưu'
    assert_includes text(obj),'Kohi'
    assert_includes text(obj),'Shylvie'
    assert_nil DataManager.saved
    confirm(obj)
    assert_equal 1,obj.save_callbacks
    assert_equal 'Shylvie',WCFPhoneSaveStore.read(0)[:record][:recipient]
    assert_includes text(obj),'Đã lưu thành công: Bản lưu 01.'
  end
  def test_cancel_at_both_levels_never_saves_deletes_or_loads
    put(0,DataManager.make_save_header)
    before=File.binread(DataManager.make_filename(0))
    obj=scene
    press(obj,:C)
    press(obj,:C) # Default action is Back.
    choose_action(obj)
    press(obj,:B) # X directly cancels the confirmation.
    assert_equal before,File.binread(DataManager.make_filename(0))
    assert_nil DataManager.saved
    press(obj,:B)
    refute obj.returned
    Scene_File::PS_ROTATION_FRAMES.times { obj.update }
    assert obj.returned
  end
  def test_deletion_is_secondary_and_only_runs_after_confirmation
    put(0,DataManager.make_save_header)
    obj=scene
    choose_action(obj,2)
    assert File.exist?(DataManager.make_filename(0))
    confirm(obj)
    refute File.exist?(DataManager.make_filename(0))
    assert_includes text(obj),'Chưa có bản lưu'
  end
  def test_disabled_save_and_failed_load_stay_in_the_ui
    $game_system.save_disabled=true
    obj=scene
    assert_equal [:back],obj.ps_actions.map(&:last)
    put(0,DataManager.make_save_header)
    obj=scene(Scene_Load)
    DataManager.load_result=false
    choose_action(obj)
    confirm(obj)
    assert_nil obj.loaded
    assert_includes text(obj),'Không tải được'
  end
  def test_opening_blocks_input_and_pagination_has_eight_pages_with_no_idle_io
    24.times { |i| put(i,DataManager.make_save_header) }
    obj=Scene_Save.new
    obj.wcf_phone_origin=:phone
    @scenes << obj
    obj.create_background
    obj.create_all_windows
    Input.press(:C)
    Scene_File::PS_ROTATION_FRAMES.times { obj.update }
    Input.press
    assert_equal :list,obj.instance_variable_get(:@ps_mode)
    assert_equal Scene_File::PS_PER_PAGE,DataManager.load_calls
    bmp=obj.instance_variable_get(:@ps_panel).bitmap
    count=bmp.clears
    600.times { obj.update }
    assert_equal Scene_File::PS_PER_PAGE,DataManager.load_calls
    assert_equal count,bmp.clears
    pages=DataManager.savefile_max/Scene_File::PS_PER_PAGE
    (pages-1).times { press(obj,:RIGHT) }
    assert_includes text(obj),"#{pages} / #{pages}"
    assert_includes text(obj),'Bản lưu 24'
    assert_equal 24,DataManager.load_calls
    press(obj,:RIGHT)
    assert_equal 23,obj.instance_variable_get(:@ps_index)
    assert_equal 24,DataManager.load_calls
  end
  def test_every_screen_stays_inside_phone_and_does_not_show_internal_stats
    3.times { |i| put(i,DataManager.make_save_header) }
    obj=scene
    [lambda {},lambda { press(obj,:C) },lambda { press(obj,:DOWN); press(obj,:C) }].each do |change|
      change.call
      bmp=obj.instance_variable_get(:@ps_panel).bitmap
      bmp.draws.each do |x,y,w,h,value,align,measured|
        assert_operator x,:>=,12
        assert_operator y,:>=,16
        assert_operator x+w,:<=,Scene_File::PS_WIDTH-16
        assert_operator y+h,:<=,Scene_File::PS_HEIGHT-12
        assert_operator measured,:<=,w
      end
      refute_match(/LV1|0G|LEO_MAGIC|Tổng số lưu|XXX/,text(obj))
    end
  end
  def test_cleanup_owns_all_surfaces_and_preserves_cached_art_and_map_snapshot
    obj=scene
    sprites=obj.instance_variable_get(:@ps_owned_sprites).dup
    clip=obj.instance_variable_get(:@ps_clip)
    art=Cache.load_bitmap('Graphics/PhoneMenu/',PhoneMenu::BACKGROUND)
    backdrop=SceneManager.background_bitmap
    obj.dispose_background
    sprites.each { |sprite| assert sprite.disposed?; assert sprite.bitmap.disposed? }
    assert clip.was_disposed
    refute art.disposed?
    refute backdrop.disposed?
    obj.dispose_background
  end
  def test_incomplete_metadata_falls_back_without_crashing_the_browser
    put(0,{wcf_phone_save:{version:1,title:'Broken',saved_at:'invalid'},
      map:OpenStruct.new(map_id:28),playtime_s:'00:30:00'})
    assert_equal 'Mê cung gương',WCFPhoneSaveStore.read(0)[:record][:title]
    obj=scene
    press(obj,:C)
    assert_includes text(obj),'Mê cung gương'
  end
  def test_landscape_rotates_about_center_and_fits_the_screen_at_every_frame
    obj=Scene_Save.new
    obj.wcf_phone_origin=:phone
    @scenes << obj
    obj.create_background
    obj.create_all_windows
    frame=obj.instance_variable_get(:@background_sprite)
    overlay=obj.instance_variable_get(:@ps_overlay)
    panel=obj.instance_variable_get(:@ps_panel)
    refute panel.visible
    assert_equal 0,frame.angle
    previous=-1
    Scene_File::PS_ROTATION_FRAMES.times do
      obj.update
      assert_operator frame.angle,:>=,previous
      previous=frame.angle
      radians=frame.angle*Math::PI/180
      w=(336*Math.cos(radians).abs+460*Math.sin(radians).abs)*frame.zoom_x
      h=(336*Math.sin(radians).abs+460*Math.cos(radians).abs)*frame.zoom_y
      assert_operator w,:<=,Graphics.width-20+0.001
      assert_operator h,:<=,Graphics.height-20+0.001
      assert_equal [320,240],[frame.x,frame.y]
      assert_equal frame.angle,overlay.angle
      assert_equal frame.zoom_x,overlay.zoom_x
    end
    assert_equal 90,frame.angle
    assert_in_delta 1,frame.zoom_x,0.001
    assert panel.visible
    assert_equal [460,336],[panel.bitmap.width,panel.bitmap.height]
    obj.return_scene
    refute panel.visible
    refute obj.returned
    Scene_File::PS_ROTATION_FRAMES.times { obj.update }
    assert_equal 0,frame.angle
    assert_in_delta 1,frame.zoom_x,0.001
    assert obj.returned
  end
  def test_title_load_starts_in_landscape_and_returns_immediately_without_rotating
    obj=Scene_Load.new
    @scenes << obj
    obj.create_background
    obj.create_all_windows
    frame=obj.instance_variable_get(:@background_sprite)
    assert_nil obj.instance_variable_get(:@ps_rotation_mode)
    assert_equal 90,frame.angle
    assert obj.instance_variable_get(:@ps_panel).visible
    press(obj,:B)
    assert obj.returned
    assert_equal 90,frame.angle
    assert_nil obj.instance_variable_get(:@ps_rotation_mode)
  end

  def test_route_labels_are_independent_from_story_phase_and_saved_metadata
    assert_equal 'Atlantis',record(22,{30=>true},{})[:route]
    assert_equal 'Về nhà',record(22,{30=>true},{})[:title]
    assert_equal 'Siêu thị',record(37,{44=>true},{42=>3,43=>3})[:route]
    assert_equal 'Gợi ý của Leo',record(37,{72=>true},{55=>1,56=>3})[:route]
    assert_equal 'Phòng kho',record(28,{42=>true},{})[:route]
    assert_equal 'Chưa xác định',record(37,{44=>true,55=>true},{})[:route]
    old=record(22,{30=>true},{})
    old.delete(:route)
    put(0,{wcf_phone_save:old,switches:{30=>true},variables:{}})
    $game_switches[44]=true
    assert_equal 'Atlantis',WCFPhoneSaveStore.read(0)[:record][:route]
  end

  def test_title_load_confirmation_does_not_warn_about_nonexistent_unsaved_progress
    put(0,DataManager.make_save_header)
    obj=Scene_Load.new
    @scenes << obj
    obj.create_background
    obj.create_all_windows
    choose_action(obj)
    assert_includes text(obj).gsub(/\s+/,' '),'Tiếp tục từ bản lưu này?'
    refute_includes text(obj),'Tiến độ chưa lưu'
    assert_nil DataManager.saved
  end

  def test_phone_file_transition_skips_default_fade_but_title_keeps_it
    phone=scene
    assert_equal 0,phone.transition_speed
    title=Scene_Load.new
    assert_equal 10,title.transition_speed
  end

  def test_opening_matches_home_dimming_then_darkens_gradually_without_changing_return
    obj=Scene_Save.new
    obj.wcf_phone_origin=:phone
    @scenes << obj
    obj.create_background
    obj.create_all_windows
    assert_equal PhoneMenu::MAIN_OVERLAY_OPACITY,obj.instance_variable_get(:@ps_overlay_alpha)
    previous=PhoneMenu::MAIN_OVERLAY_OPACITY
    Scene_File::PS_ROTATION_FRAMES.times do
      obj.update
      value=obj.instance_variable_get(:@ps_overlay_alpha)
      assert_operator value,:>=,previous
      assert_operator value-previous,:<=,6
      previous=value
    end
    assert_equal 240,previous
    obj.return_scene
    Scene_File::PS_ROTATION_FRAMES.times do
      obj.update
      assert_equal 240,obj.instance_variable_get(:@ps_overlay_alpha)
    end
    assert obj.returned
  end

  def test_confirmation_ignores_arrows_and_z_confirms_without_selecting_a_button
    put(0,DataManager.make_save_header)
    obj=scene
    choose_action(obj)
    assert_equal :confirm,obj.instance_variable_get(:@ps_mode)
    assert_nil DataManager.saved, 'The Z which opens confirmation must not also execute it'
    before=text(obj)
    Sound.clear
    [:DOWN,:RIGHT,:UP,:LEFT].each { |key| press(obj,key) }
    assert_equal before,text(obj)
    assert_nil DataManager.saved
    refute_includes Sound.sounds,:play_cursor
    press(obj,:C)
    assert_equal 0,DataManager.saved
    assert_equal 1,obj.save_callbacks
  end

  def test_x_cancels_each_confirmation_even_if_z_is_pressed_at_the_same_time
    [[:save,Scene_Save,1],[:load,Scene_Load,1],[:delete,Scene_Save,2]].each do |action,type,ordinal|
      put(0,DataManager.make_save_header)
      before=File.binread(DataManager.make_filename(0))
      obj=scene(type)
      choose_action(obj,ordinal)
      assert_equal action,obj.instance_variable_get(:@ps_pending)
      press(obj,:B,:C)
      assert_equal :list,obj.instance_variable_get(:@ps_mode)
      assert_equal before,File.binread(DataManager.make_filename(0))
      assert_nil DataManager.saved
      assert_nil obj.loaded
    end
  end

  def test_save_names_are_explicit_and_confirmation_has_no_arrow_selection_hint
    put(0,DataManager.make_save_header)
    obj=scene
    assert_includes text(obj),'Bản lưu 01'
    refute_match(/\bÔ\s+\d|vào ô/,text(obj))
    choose_action(obj)
    assert_includes text(obj),'Ghi đè Bản lưu 01?'
    assert_includes text(obj),'Đang có · Bản lưu 01'
    assert_includes text(obj),'Hủy (X)'
    assert_includes text(obj),'Ghi đè (Z)'
    refute_match(/[↑↓←→]/,text(obj))
  end

  def test_all_phone_hints_use_z_x_and_save_details_have_explicit_field_labels
    source=File.read(File.join(__dir__,'../Scripts/Custom Menu.rb'),encoding:'UTF-8')
    refute_match(/\b(?:Enter|Esc)\b/,source)
    put(0,DataManager.make_save_header)
    obj=scene
    assert_includes text(obj),'Route:'
    assert_includes text(obj),'Mốc truyện:'
    assert_includes text(obj),'Vị trí hiện tại:'
    press(obj,:C)
    assert_includes text(obj),'Route:'
    assert_includes text(obj),'Vị trí hiện tại:'
    assert_includes text(obj),'Người nhận:'
  end
end
