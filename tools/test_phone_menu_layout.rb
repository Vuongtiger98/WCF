# frozen_string_literal: true

# Run the real layout/wrapping methods with native drawing represented by spies.
require_relative 'test_performance_optimizations'
raise 'UI tests target the current layout' if BASELINE

class Scene_Menu
  source=script_source('Custom Menu')
  source.scan(/^module PhoneMenu.*?^end/m).select { |code|
    code.include?('GALLERY_PICTURE_NAMES') || code.include?('ITEM_PICTURE_IDS')
  }.each { |code| eval(code,TOPLEVEL_BINDING,'Gallery registry') }
  [:update_icon_animation,:phone_visual_sprites,:phone_collect_sprites,:phone_apply_slide_offset,
   :pmgc_wrap_text,:pmgc_message_height,:pmgc_page_lines,:pmgc_visible_messages,
   :pmgc_normal_message_to_hash,:pmgc_main_message?,:pmgc_name_sprite,:pmgc_icon_sprite,
   :pmgc_draw_text_message,:pmgc_sender_name,:pmgc_sender_avatar,:phone_fit_bitmap,
   :rebuild_gallery_grid,:dispose_gallery_grid_sprites,:make_round_rect_bitmap,:phone_locked_thumbnail,
   :gallery_picture_ids,:gallery_picture_id_from_index,
   :phone_new_boundary?,:phone_message_new?,:phone_thread_unread?,:phone_unread_state,:update_phone_unread].each do |name|
    class_eval(method_source(source,name,-1),'Custom Menu layout')
  end
  def gallery_thumbnail_bitmap(id); Bitmap.new(300,400); end
  def gallery_picture_unlocked?(id); false; end
  def gallery_picture_name(id); "Ảnh #{id}"; end
end

class PhoneMenuLayoutTest < Minitest::Test
  def setup
    @menu=Scene_Menu.new
  end

  def bounds(sprite)
    x=sprite.x-sprite.ox*sprite.zoom_x
    y=sprite.y-sprite.oy*sprite.zoom_y
    [x,y,x+sprite.bitmap.width*sprite.zoom_x,y+sprite.bitmap.height*sprite.zoom_y]
  end

  def test_phone_matches_artwork_ratio_and_is_centered_on_the_game_screen
    assert_in_delta 350.0/480,PhoneMenu::PHONE_WIDTH.to_f/PhoneMenu::PHONE_HEIGHT,0.003
    assert_equal Graphics.width/2,PhoneMenu::PHONE_X+PhoneMenu::PHONE_WIDTH/2
    assert_equal Graphics.height/2,PhoneMenu::PHONE_Y+PhoneMenu::PHONE_HEIGHT/2
    assert_operator PhoneMenu::PHONE_Y,:>,0
  end

  def test_every_icon_stays_centered_inside_its_card_at_maximum_pulse
    @menu.create_foreground
    @menu.instance_variable_set(:@selected_index,0)
    @menu.instance_variable_set(:@animation_frame,PhoneMenu::ANIMATION_DURATION/2)
    @menu.update_icon_animation
    icons=@menu.instance_variable_get(:@icon_sprites)
    cards=@menu.instance_variable_get(:@highlight_sprites)
    icons.zip(cards).each do |icon,card|
      a,b=bounds(icon),bounds(card)
      assert_operator a[0],:>,b[0]
      assert_operator a[1],:>,b[1]
      assert_operator a[2],:<,b[2]
      assert_operator a[3],:<=,icon.y+27
      assert_equal icon.bitmap.width/2,icon.ox
      assert_equal icon.bitmap.height/2,icon.oy
    end
  end

  def test_menu_disposal_keeps_cached_app_icons_available_for_reopening
    cached=Cache.load_bitmap('Graphics/PhoneMenu/','ItemsIcon')
    @menu.create_foreground
    refute_same cached,@menu.instance_variable_get(:@icon_sprites).first.bitmap
    @menu.dispose_phone_menu_sprites
    refute cached.disposed?
  end

  def test_custom_widget_text_fits_and_localization_does_not_modify_saved_data
    $game_config=OpenStruct.new
    PerformanceOptimizationsTest::WIDGETS.each do |name|
      $game_config.send("phone_widget_#{name}=",'Nội dung rất dài có dấu tiếng Việt '*5)
    end
    panel=Sprite.new
    panel.bitmap=Bitmap.new(PhoneMenu::PHONE_WIDTH,PhoneMenu::PHONE_HEIGHT)
    @menu.instance_variable_set(:@main_panel,panel)
    before=$game_config.phone_widget_weather_title.dup
    @menu.draw_main_panel
    panel.bitmap.draws.each do |x,y,w,h,text,align,measured|
      assert_operator x,:>=,0
      assert_operator y,:>=,0
      assert_operator x+w,:<=,PhoneMenu::PHONE_WIDTH
      assert_operator y+h,:<=,PhoneMenu::PHONE_HEIGHT
      assert_operator measured,:<=,w
    end
    assert_equal before,$game_config.phone_widget_weather_title
    assert_equal '25/12 • 19:00',@menu.phone_widget_label('25 Dec • 19:00')
    assert_equal 'Gió 12 km/h',@menu.phone_widget_label('Wind 12 km/h')
  end

  def test_vietnamese_text_keeps_blank_lines_and_combining_accents_when_wrapped
    text="Ôi, những ngày cuối năm nhiều công việc sổ sách quá!!\n\n"+
      ('giángsinh'.unicode_normalize(:nfd)*12)
    lines=@menu.pmgc_wrap_text(text,21)
    assert_includes lines,''
    assert_equal text.gsub(/\s+/,''),lines.join.gsub(/\s+/,'')
    lines.each do |line|
      assert_operator @menu.simple_text_width(line,17),:<=,
        PhoneMenu::MESSAGE_MAX_WIDTH-PhoneMenu::MESSAGE_PADDING_X*2
      refute_match(/\A\p{M}/,line)
    end
  end

  def test_every_part_of_a_long_message_remains_readable_without_overflow
    message={type: :text,sender: :quy,text: 'Hải Quỳ đọc đầy đủ nội dung tin nhắn này. '*80}
    original=Marshal.dump(message)
    lines=@menu.pmgc_wrap_text(message[:text],0)
    page_size=@menu.pmgc_page_lines(message)
    read=[]
    0.step(lines.size-1,page_size) do |offset|
      @menu.instance_variable_set(:@message_line_offset,offset)
      visible=@menu.pmgc_visible_messages([message],0)
      assert_equal 1,visible.size
      part,y=visible.first
      refute_empty part[:_phone_lines]
      assert_operator y+@menu.pmgc_message_height(part),:<=,PhoneMenu::MESSAGE_BOTTOM_LIMIT
      read.concat(part[:_phone_lines])
    end
    assert_equal lines,read
    assert_equal original,Marshal.dump(message)
  end

  def test_wrapping_cache_is_bounded_and_detects_in_place_message_edits
    text='Nội dung có dấu tiếng Việt.'.dup
    first=@menu.pmgc_wrap_text(text,0)
    assert_same first,@menu.pmgc_wrap_text(text,0)
    text << ' Bổ sung một dòng mới.'
    refute_same first,@menu.pmgc_wrap_text(text,0)
    50.times { |index| @menu.pmgc_wrap_text("Tin nhắn thứ #{index}",0) }
    assert_operator @menu.instance_variable_get(:@phone_wrap_cache).size,:<=,32
  end

  def test_outgoing_sender_name_aligns_with_the_bubble_instead_of_the_phone_edge
    @menu.instance_variable_set(:@contact_messages,[])
    entry={kind: :normal,id: 1,name:'Momo',members:{}}
    @menu.pmgc_draw_text_message(entry,{type: :text,sender: :main,text:'Vâng, con biết rồi.'},PhoneMenu::CONTACT_MESSAGE_Y)
    name,bubble,icon=@menu.instance_variable_get(:@contact_messages)
    assert_equal bounds(name)[2],bounds(bubble)[2]
    assert_operator bounds(bubble)[2],:<,bounds(icon)[0]
    assert_operator bounds(name)[0],:>=,PhoneMenu::PHONE_X+24
  end

  def test_gallery_cards_and_their_labels_leave_space_for_caption_and_footer
    @menu.instance_variable_set(:@gallery_page,0)
    @menu.instance_variable_set(:@gallery_index,0)
    @menu.rebuild_gallery_grid
    cards=@menu.instance_variable_get(:@gallery_panels)
    labels=@menu.instance_variable_get(:@gallery_labels)
    assert_equal 4,cards.size
    cards.zip(labels).each do |card,label|
      c,l=bounds(card),bounds(label)
      assert_operator c[0],:>=,PhoneMenu::PHONE_X+20
      assert_operator c[2],:<=,PhoneMenu::PHONE_X+PhoneMenu::PHONE_WIDTH-20
      assert_operator l[3],:<=,c[3]
      assert_operator c[3],:<,PhoneMenu::PHONE_Y+388
    end
    assert_operator bounds(cards[0])[3],:<,bounds(cards[2])[1]
  end

  def test_landscape_and_portrait_images_fit_without_stretching
    [[544,416],[300,400],[1200,240]].each do |width,height|
      source=Bitmap.new(width,height)
      target=Bitmap.new(128,84)
      @menu.phone_fit_bitmap(target,source)
      rect=target.last_stretch
      assert_operator rect.x,:>=,0
      assert_operator rect.y,:>=,0
      assert_operator rect.x+rect.width,:<=,target.width
      assert_operator rect.y+rect.height,:<=,target.height
      # Integer target pixels may round a uniform scale by half a pixel.
      assert_in_delta rect.width.to_f/width,rect.height.to_f/height,0.5/[width,height].min
    end
  end

  def test_slide_moves_all_phone_parts_together_and_keeps_the_map_backdrop_fixed
    phone=Sprite.new
    phone.y=PhoneMenu::PHONE_Y
    backdrop=Sprite.new
    @menu.instance_variable_set(:@background_sprite,phone)
    @menu.instance_variable_set(:@phone_backdrop,backdrop)
    @menu.phone_apply_slide_offset(73)
    assert_equal PhoneMenu::PHONE_Y+73,phone.y
    assert_equal 0,backdrop.y
    @menu.phone_apply_slide_offset(0)
    assert_equal PhoneMenu::PHONE_Y,phone.y
  end

  def test_full_image_keeps_native_cg_size_and_leaves_room_for_controls
    target=Bitmap.new(640,480)
    @menu.phone_fit_bitmap(target,Bitmap.new(544,416),448,false)
    rect=target.last_stretch
    assert_equal [544,416],[rect.width,rect.height]
    assert_equal 48,rect.x
    assert_operator rect.y+rect.height,:<=,448
  end
end
