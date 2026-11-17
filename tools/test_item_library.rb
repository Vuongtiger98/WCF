# frozen_string_literal: true
require_relative 'test_phone_settings'
ROOT_LIBRARY_TEST=File.expand_path('..',__dir__)
source=File.read(File.join(ROOT_LIBRARY_TEST,'Scripts/Custom Menu.rb'),encoding:'UTF-8').gsub("\r\n","\n")
source.scan(/^module PhoneMenu.*?^end/m).select { |code|
  code.include?('GALLERY_PICTURE_NAMES') || code.include?('ITEM_PICTURE_IDS')
}.each { |code| eval(code,TOPLEVEL_BINDING,'Item registry') }
module RPG
  class LibraryItemFixture
    attr_accessor :id,:name,:icon_index,:description
    def initialize(id,name); @id,@name,@icon_index,@description=id,name,84,'Thanh Ram, khá là có giá trị'; end
  end
  class Item < LibraryItemFixture; end
  class Weapon < LibraryItemFixture; end
  class Armor < LibraryItemFixture; end
end
class Game_Party
  def initialize; @items={}; end
  def gain_item(item,amount,include_equip=false)
    @items[item]=[item_number(item)+amount,0].max if item
    :original_gain_result
  end
  def item_number(item); @items[item] || 0; end
  def all_items; @items.keys.select { |item| item_number(item)>0 }; end
end
class Game_Picture
  def show(*args); @name=args[0]; :original_show_result; end
end
eval(source[/^module GlobalGallery\n.*?^end/m],TOPLEVEL_BINDING,'GlobalGallery')
first=source.index("module WCFItemLibrary\n")
last=source.index("module WCFGalleryScene\n",first)
eval(source[first...last],TOPLEVEL_BINDING,'Item collection hooks')
class Scene_MenuBase
  def start; create_background; end
end
class ItemLibrarySceneProbe < Scene_ItemLibrary
  attr_reader :returned
  def wcf_library_return_scene; @returned=true; end
end
module Cache
  def self.picture(name)
    raise 'Missing item image '+name unless File.file?(File.join(ROOT_LIBRARY_TEST,'Graphics/Pictures',name+'.png'))
    @library_images ||= {}
    @library_images[name] ||= Bitmap.new(544,416)
  end
  def self.system(name); @library_icons ||= Bitmap.new(384,384); end
end
class ItemGalleryProbe
  [:gallery_picture_ids,:gallery_page_max,:gallery_picture_id_from_index,:gallery_enabled_count,:gallery_picture_unlocked?].each do |name|
    code=File.read(File.join(ROOT_LIBRARY_TEST,'Scripts/Custom Menu.rb'),encoding:'UTF-8').gsub("\r\n","\n")
    class_eval(code[/^  def #{name}\b.*?^  end/m])
  end
end
class ItemLibraryTest < Minitest::Test
  def setup
    @before_dir=Dir.pwd
    @dir=Dir.mktmpdir('wcf-library-')
    Dir.chdir(@dir)
    WCFItemLibrary.instance_variable_set(:@keys,nil)
    $game_system=OpenStruct.new(gallery:[])
    $game_party=Game_Party.new
    $data_items=[]
    $data_items[17]=RPG::Item.new(17,'lantern')
    $data_items[18]=RPG::Item.new(18,'Ram')
    $data_weapons=[]; $data_armors=[]
    Input.press
  end
  def teardown
    @scene.dispose_background if @scene
    Dir.chdir(@before_dir)
    FileUtils.remove_entry(@dir)
    WCFItemLibrary.instance_variable_set(:@keys,nil)
    Input.press
  end
  def reload_collection
    WCFItemLibrary.instance_variable_set(:@keys,nil)
    WCFItemLibrary.bootstrap
  end
  def scene
    @scene=ItemLibrarySceneProbe.new
    @scene.wcf_phone_origin=:phone
    @scene.start
    Scene_ItemLibrary::LIB_ROTATION_FRAMES.times { @scene.lib_update_rotation }
    @scene
  end
  def press(key)
    Input.press(key)
    @scene.lib_update_input
  ensure
    Input.press
  end
  def test_picture_encounters_are_permanent_and_only_write_on_first_discovery
    assert_equal :original_show_result,Game_Picture.new.show('CG2',0,0,0,100,100,255,0)
    assert WCFItemLibrary.unlocked?('picture:cg2')
    bytes=File.binread(WCFItemLibrary::FILE_NAME)
    refute WCFItemLibrary.encounter_picture('CG2.png')
    assert_equal bytes,File.binread(WCFItemLibrary::FILE_NAME)
    $game_system=OpenStruct.new(gallery:[])
    $game_party=Game_Party.new
    reload_collection
    assert WCFItemLibrary.unlocked?('picture:cg2')
    refute WCFItemLibrary.encounter_picture('CG1')
    refute WCFItemLibrary.unlocked?('picture:cg1')
  end
  def test_positive_item_gain_discovers_it_but_loss_never_relocks_it
    ram=$data_items[18]
    assert_equal :original_gain_result,$game_party.gain_item(ram,1)
    assert WCFItemLibrary.unlocked?('item:18')
    $game_party.gain_item(ram,-1)
    assert_equal 0,$game_party.item_number(ram)
    reload_collection
    assert WCFItemLibrary.unlocked?('item:18')
    $game_party.gain_item($data_items[17],-1)
    refute WCFItemLibrary.unlocked?('item:17')
    $game_party.gain_item(nil,1)
  end
  def test_unknown_database_items_only_enter_the_catalog_when_encountered
    $data_items[1]=RPG::Item.new(1,'Potion')
    refute WCFItemLibrary.entries.any? { |entry| entry[:key]=='item:1' }
    $game_party.gain_item($data_items[1],1)
    assert WCFItemLibrary.entries.any? { |entry| entry[:key]=='item:1' }
    assert_equal 46,WCFItemLibrary.entries.size
  end
  def test_all_gift_images_are_excluded_from_gallery_without_renumbering_cgs
    probe=ItemGalleryProbe.new
    assert_equal 41,probe.gallery_picture_ids.size
    assert_empty probe.gallery_picture_ids & PhoneMenu::ITEM_PICTURE_IDS
    assert_equal [1,6,7,8],4.times.map { |index| probe.gallery_picture_id_from_index(0,index) }
    assert_equal 85,probe.gallery_picture_id_from_index(10,0)
    assert_nil probe.gallery_picture_id_from_index(10,1)
    PhoneMenu::ITEM_PICTURE_IDS.each do |id|
      assert File.file?(File.join(ROOT_LIBRARY_TEST,'Graphics/Pictures',PhoneMenu::GALLERY_PICTURE_FILES[id]+'.png'))
    end
    assert_equal 45,WCFItemLibrary.entries.size
  end
  def test_kul_lantern_stays_out_of_the_library_even_after_gain_or_legacy_discovery
    Dir.mkdir('Save')
    File.binwrite(WCFItemLibrary::FILE_NAME,Marshal.dump({version:1,keys:['item:17','item:18','picture:cg2']}))
    reload_collection
    assert WCFItemLibrary.unlocked?('item:18')
    assert WCFItemLibrary.unlocked?('picture:cg2')
    refute WCFItemLibrary.unlocked?('item:17')
    assert_equal :original_gain_result,$game_party.gain_item($data_items[17],1)
    assert_equal 1,$game_party.item_number($data_items[17])
    refute WCFItemLibrary.unlock('item:17')
    refute WCFItemLibrary.encounter_item($data_items[17])
    assert_nil WCFItemLibrary.database_entry('item:17')
    refute WCFItemLibrary.entries.any? { |entry| entry[:key]=='item:17' }
    assert_equal 45,WCFItemLibrary.entries.size
    $data_weapons[17]=RPG::Weapon.new(17,'Test sword')
    $game_party.gain_item($data_weapons[17],1)
    assert WCFItemLibrary.unlocked?('weapon:17')
  end
  def test_every_default_item_has_its_approved_description
    entries=WCFItemLibrary.entries
    assert_equal 45,entries.size
    entries.each do |entry|
      refute_empty entry[:description],entry[:key]
      refute_equal 'Vật phẩm đã gặp trong hành trình.',entry[:description],entry[:key]
    end
    assert_equal 'Bánh phô mai cam',entries.find { |entry| entry[:key]=='picture:banhkemcam' }[:name]
    assert_equal 'Kim cương hình hạt cà phê',entries.find { |entry| entry[:key]=='picture:diamondcoffee' }[:name]
    assert_equal 'Váy tặng Hải Quỳ',entries.find { |entry| entry[:key]=='picture:vayquy' }[:name]
  end
  def test_equipment_discoveries_use_distinct_database_keys
    $data_weapons[1]=RPG::Weapon.new(1,'Sword')
    $data_armors[1]=RPG::Armor.new(1,'Shield')
    $game_party.gain_item($data_weapons[1],1)
    $game_party.gain_item($data_armors[1],1)
    assert WCFItemLibrary.unlocked?('weapon:1')
    assert WCFItemLibrary.unlocked?('armor:1')
    refute WCFItemLibrary.unlocked?('item:1')
    assert_equal ['Shield','Sword'],WCFItemLibrary.entries.last(2).map { |entry| entry[:name] }
  end
  def test_gallery_unlock_routes_gifts_to_collection_and_keeps_scene_cgs_in_gallery
    GlobalGallery.unlock(2)
    assert WCFItemLibrary.unlocked?('picture:cg2')
    refute GlobalGallery.load[2]
    GlobalGallery.unlock(42)
    assert WCFItemLibrary.unlocked?('picture:aokhoacleotanghakase')
    refute GlobalGallery.load[42]
    GlobalGallery.unlock(1)
    assert GlobalGallery.load[1]
    assert_equal 1,ItemGalleryProbe.new.gallery_enabled_count
  end
  def test_existing_global_gift_unlocks_migrate_without_unlocking_other_items
    data=[]; data[3]=true; data[75]=true; data[1]=true
    GlobalGallery.save(data)
    reload_collection
    assert WCFItemLibrary.unlocked?('picture:cg3')
    assert WCFItemLibrary.unlocked?('picture:purplegarnet')
    refute WCFItemLibrary.unlocked?('picture:cg2')
    assert GlobalGallery.load[1]
  end
  def test_damaged_primary_recovers_backup_and_preserves_it_on_next_write
    WCFItemLibrary.encounter_picture('CG2')
    WCFItemLibrary.encounter_picture('CG3')
    File.binwrite(WCFItemLibrary::FILE_NAME,'broken')
    reload_collection
    assert WCFItemLibrary.unlocked?('picture:cg2')
    WCFItemLibrary.encounter_picture('CG4')
    assert WCFItemLibrary.read_store(WCFItemLibrary::FILE_NAME+'.bak')['picture:cg2']
    reload_collection
    assert WCFItemLibrary.unlocked?('picture:cg4')
  end
  def test_failed_storage_keeps_game_running_and_retries_after_directory_is_fixed
    File.binwrite('Save','blocked path')
    WCFItemLibrary.encounter_picture('CG2')
    assert WCFItemLibrary.persistence_error?
    assert WCFItemLibrary.unlocked?('picture:cg2')
    File.delete('Save')
    WCFItemLibrary.encounter_picture('CG2')
    refute WCFItemLibrary.persistence_error?
    reload_collection
    assert WCFItemLibrary.unlocked?('picture:cg2')
  end
  def test_locked_items_cannot_be_opened_and_viewing_does_not_unlock_them
    scene
    press(:C)
    assert_equal :grid,@scene.instance_variable_get(:@lib_mode)
    assert_empty WCFItemLibrary.instance_variable_get(:@keys)
    press(:B)
    refute @scene.returned
    Scene_ItemLibrary::LIB_ROTATION_FRAMES.times { @scene.lib_update_rotation }
    assert @scene.returned
  end
  def test_grid_detail_full_view_paging_cleanup_and_no_item_consumption
    $game_party.gain_item($data_items[18],1)
    WCFItemLibrary.encounter_picture('CG2')
    scene
    initial=@scene.instance_variable_get(:@lib_panel).bitmap.clears
    600.times { @scene.lib_update_input }
    assert_equal initial,@scene.instance_variable_get(:@lib_panel).bitmap.clears
    press(:C)
    assert_equal :detail,@scene.instance_variable_get(:@lib_mode)
    press(:C)
    assert @scene.instance_variable_get(:@lib_full).visible
    press(:B); press(:B)
    100.times { press(:R) }
    assert_equal 44,@scene.instance_variable_get(:@lib_index)
    press(:C)
    assert_equal :detail,@scene.instance_variable_get(:@lib_mode)
    assert_equal 1,$game_party.item_number($data_items[18])
    surfaces=@scene.instance_variable_get(:@lib_owned).dup
    @scene.dispose_background
    assert surfaces.all? { |sprite| sprite.disposed? && sprite.bitmap.disposed? }
    refute Cache.picture('CG2').disposed?
  end
  def test_landscape_rotation_blocks_input_and_returns_to_portrait_before_leaving
    @scene=ItemLibrarySceneProbe.new
    @scene.wcf_phone_origin=:phone
    @scene.start
    frame=@scene.instance_variable_get(:@background_sprite)
    panel=@scene.instance_variable_get(:@lib_panel)
    assert_equal [460,336],[panel.bitmap.width,panel.bitmap.height]
    assert_equal 0,frame.angle
    refute panel.visible
    press(:RIGHT)
    assert_equal 0,@scene.instance_variable_get(:@lib_index)
    Scene_ItemLibrary::LIB_ROTATION_FRAMES.times do
      @scene.lib_update_rotation
      radians=frame.angle*Math::PI/180.0
      width=(PhoneMenu::PHONE_WIDTH*Math.cos(radians).abs+PhoneMenu::PHONE_HEIGHT*Math.sin(radians).abs)*frame.zoom_x
      height=(PhoneMenu::PHONE_WIDTH*Math.sin(radians).abs+PhoneMenu::PHONE_HEIGHT*Math.cos(radians).abs)*frame.zoom_y
      assert_operator width,:<=,Graphics.width-20+0.001
      assert_operator height,:<=,Graphics.height-20+0.001
    end
    assert_equal 90,frame.angle
    assert panel.visible
    press(:B)
    refute panel.visible
    refute @scene.returned
    Scene_ItemLibrary::LIB_ROTATION_FRAMES.times { @scene.lib_update_rotation }
    assert_equal 0,frame.angle
    assert @scene.returned
  end
  def test_six_column_navigation_and_close_up_thumbnail_sources_fit_cells
    PhoneMenu::ITEM_PICTURE_IDS.first(18).each do |id|
      WCFItemLibrary.encounter_picture(PhoneMenu::GALLERY_PICTURE_FILES[id])
    end
    scene
    bitmap=@scene.instance_variable_get(:@lib_panel).bitmap
    assert_equal 18,bitmap.images.size
    bitmap.images.each do |dest,source,src|
      assert_operator dest.width,:<=,54
      assert_operator dest.height,:<=,54
      assert_operator dest.x,:>=,30
      assert_operator dest.x+dest.width,:<=,432
      assert_operator dest.y,:>=,74
      assert_operator dest.y+dest.height,:<=,264
      assert_operator src.width,:<,source.width
      assert_operator src.height,:<,source.height
    end
    press(:DOWN)
    assert_equal 6,@scene.instance_variable_get(:@lib_index)
    press(:RIGHT)
    assert_equal 7,@scene.instance_variable_get(:@lib_index)
    press(:UP)
    assert_equal 1,@scene.instance_variable_get(:@lib_index)
    press(:R)
    assert_equal 19,@scene.instance_variable_get(:@lib_index)
    press(:L)
    assert_equal 1,@scene.instance_variable_get(:@lib_index)
  end
end
