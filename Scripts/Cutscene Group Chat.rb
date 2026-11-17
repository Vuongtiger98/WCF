#==============================================================================
# ** Simple Cutscene Phone Chat
#------------------------------------------------------------------------------
#  RGSS3 / RPG Maker VX Ace
#------------------------------------------------------------------------------
#  Replace old cutscene chat script with this one.
#
#  Features:
#   - Phone-style cutscene chat
#   - Text / image / system notice
#   - Multiple avatars
#   - Press Z to reveal next message
#   - Choices at the end
#   - Branch messages continue in the same chat
#   - Simpler layered rendering for better stability
#==============================================================================

module SimplePhoneChat
  # Layout and colors are shared with Custom Menu through WCFPhoneDrawing.
  MESSAGE_SE = RPG::SE.new("Cursor2", 80, 100)   # default message sound

  # Optional per character sound
  ACTOR_SE = {
    :quy => RPG::SE.new("SendText", 80, 100),
    :leo => RPG::SE.new("ReceiveText", 80, 100),
    :kohi => RPG::SE.new("ReceiveText", 80, 100),
    :hakase => RPG::SE.new("ReceiveText", 80, 100),
    :shylvie => RPG::SE.new("ReceiveText", 80, 100)
  }
  
end


#==============================================================================
# ** Game_Temp
#==============================================================================
class Game_Temp
  attr_accessor :group_chat_data
  attr_accessor :group_chat_result
end

#==============================================================================
# ** Game_SimplePhoneChat
#==============================================================================
class Game_SimplePhoneChat
  attr_accessor :title
  attr_accessor :subtitle
  attr_reader   :actors
  attr_reader   :entries
  attr_reader   :choices
  attr_reader   :choice_branches
  attr_accessor :required_choice
  attr_reader :phone_read_entries

  def initialize
    @title = "Chat"
    @subtitle = ""
    @actors = {}
    @entries = []
    @choices = []
    @choice_branches = {}
    @required_choice = false
    @phone_read_entries = {}
  end

  def add_actor(id, name, avatar_filename)
    @actors[id] = {
      :name   => name.to_s,
      :avatar => avatar_filename.to_s
    }
  end

  def actor(id)
    @actors[id]
  end

  def add_text(actor_id, text, side = :left)
    @entries << {
      :type  => :text,
      :actor => actor_id,
      :text  => text.to_s,
      :side  => side
    }
  end

  def add_image(actor_id, picture_filename, side = :left)
    @entries << {
      :type  => :image,
      :actor => actor_id,
      :image => picture_filename.to_s,
      :side  => side
    }
  end

  def add_system(text)
    @entries << {
      :type => :system,
      :text => text.to_s
    }
  end

  def add_choice(text, value, options = {})
  @choices << {
    :text => text.to_s,
    :value => value,
    :switch => options[:switch],
    :variable => options[:variable]
  }
  @choice_branches[value] ||= []
end

  def add_branch_text(choice_value, actor_id, text, side = :left)
    @choice_branches[choice_value] ||= []
    @choice_branches[choice_value] << {
      :type  => :text,
      :actor => actor_id,
      :text  => text.to_s,
      :side  => side
    }
  end

  def add_branch_image(choice_value, actor_id, picture_filename, side = :left)
    @choice_branches[choice_value] ||= []
    @choice_branches[choice_value] << {
      :type  => :image,
      :actor => actor_id,
      :image => picture_filename.to_s,
      :side  => side
    }
  end

  def add_branch_system(choice_value, text)
    @choice_branches[choice_value] ||= []
    @choice_branches[choice_value] << {
      :type => :system,
      :text => text.to_s
    }
  end
end

#==============================================================================
# ** GroupChat
#==============================================================================
module GroupChat
  def self.start(chat)
    scene = SceneManager.scene
    message_window = scene.instance_variable_get(:@message_window) rescue nil
    if message_window &&
        message_window.respond_to?(:force_clear_pop_message_visuals)
      message_window.force_clear_pop_message_visuals
    end
    $game_temp.group_chat_data = chat
    $game_temp.group_chat_result = nil
    SceneManager.snapshot_for_background
    SceneManager.call(Scene_SimplePhoneChat)
  end

  def self.result
    $game_temp.group_chat_result
  end
end

#==============================================================================
# ** Scene_SimplePhoneChat
#==============================================================================
class Game_Interpreter
  alias wcf_phone_chat_command_355 command_355
  def command_355
    result = wcf_phone_chat_command_355
    # SceneManager.call schedules a scene; it does not suspend this event.
    # Save-history / route commands must read the answer after chat returns.
    Fiber.yield while SceneManager.scene_is?(Scene_SimplePhoneChat)
    result
  end
end

class Scene_SimplePhoneChat < Scene_Base
  def start
    super
    @chat = $game_temp.group_chat_data || Game_SimplePhoneChat.new
    @active_entries = @chat.entries.clone
    @chat_disposed = false
    @chat_slide_offset = 0
    @chat_base_y = {}
    @visible_count = @scroll_y = @choice_index = 0
    @choice_active = @branch_used = false
    @entry_layout_cache = {}
    @choice_rows = []
    @phone_seen_ranges = {}
    @phone_read_view = nil
    create_dim
    create_phone_background
    @message_layer = chat_sprite(288, chat_content_height, 110, 24, 96)
    @header_layer = chat_sprite(PhoneMenu::PHONE_WIDTH, PhoneMenu::PHONE_HEIGHT, 120)
    @footer_layer = chat_sprite(PhoneMenu::PHONE_WIDTH, PhoneMenu::PHONE_HEIGHT, 120)
    @choice_layer = chat_sprite(PhoneMenu::PHONE_WIDTH, PhoneMenu::PHONE_HEIGHT, 130)
    refresh_header
    refresh_messages
    refresh_choices
    @chat_animation = :opening
    @chat_animation_timer = 0
    chat_slide(Graphics.height - PhoneMenu::PHONE_Y)
  end

  def chat_sprite(w, h, z, x = 0, y = 0)
    sprite = Sprite.new
    sprite.bitmap = Bitmap.new(w, h)
    sprite.x, sprite.y, sprite.z = PhoneMenu::PHONE_X+x, PhoneMenu::PHONE_Y+y, z
    sprite
  end

  def create_dim
    @dim = Sprite.new
    source = SceneManager.background_bitmap
    @dim.bitmap = source ? source.clone : Bitmap.new(Graphics.width, Graphics.height)
    @dim.color.set(8, 12, 24, 190)
    @dim.z = 10
  end

  def create_phone_background
    @phone_bg = chat_sprite(PhoneMenu::PHONE_WIDTH, PhoneMenu::PHONE_HEIGHT, 50)
    source = Cache.load_bitmap('Graphics/PhoneMenu/', PhoneMenu::MESSAGE_BACKGROUND)
    @phone_bg.bitmap.stretch_blt(@phone_bg.bitmap.rect, source, source.rect)
    @chat_overlay = chat_sprite(PhoneMenu::PHONE_WIDTH, PhoneMenu::PHONE_HEIGHT, 70)
    fill_round_rect(@chat_overlay.bitmap, 12, 16, PhoneMenu::PHONE_WIDTH-24,
      PhoneMenu::PHONE_HEIGHT-32, 18, Color.new(9,14,28,PhoneMenu::MESSAGE_OVERLAY_OPACITY))
  end

  def chat_parts
    [@phone_bg,@chat_overlay,@message_layer,@header_layer,@footer_layer,@choice_layer].compact
  end

  def chat_slide(offset)
    # RGSS Sprite positions are integers. Always place from a fixed baseline;
    # accumulating fractional deltas drifts apart during the slide.
    chat_parts.each do |sprite|
      @chat_base_y[sprite] ||= sprite.y
      sprite.y = @chat_base_y[sprite]+offset.round
    end
    @chat_slide_offset = offset.round
  end

  def update_chat_animation
    @chat_animation_timer += 1
    progress = [@chat_animation_timer.to_f/PhoneMenu::SLIDE_DURATION,1.0].min
    distance = Graphics.height-PhoneMenu::PHONE_Y
    chat_slide(distance * (@chat_animation == :opening ? (1.0-progress)**3 : progress**3))
    return unless progress >= 1.0
    if @chat_animation == :closing
      SceneManager.return
    else
      @chat_animation = :idle
      @chat_animation_timer = 0
    end
  end

  def return_scene
    return if @chat_animation == :closing
    @chat_animation = :closing
    @chat_animation_timer = 0
  end

  def update
    super
    track_phone_read_entries if @chat_animation == :idle
    if @chat_animation != :idle
      update_chat_animation
    elsif @choice_active
      update_choice_input
    else
      update_message_input
    end
    track_phone_read_entries if @chat_animation == :idle
  end

  # Accumulate visible ranges so a long entry is read only after every part
  # has been on screen. Revealing an entry alone is not enough.
  def track_phone_read_entries
    height = chat_message_height
    view = [@visible_count,@scroll_y,height]
    return if @phone_read_view == view
    @phone_read_view = view
    chat_draw_data[:entries].each_with_index do |row,index|
      top = [@scroll_y-row[:y],0].max
      bottom = [@scroll_y+height-row[:y],row[:height]].min
      next unless bottom > top
      entry = @active_entries[index]
      key = entry.object_id
      next if @chat.phone_read_entries[key]
      spans = (@phone_seen_ranges[key] ||= [])
      spans << [top,bottom]
      merged = []
      spans.sort_by { |range|range[0] }.each do |range|
        if !merged.empty? && merged[-1][1] >= range[0]
          merged[-1][1] = [merged[-1][1],range[1]].max
        else
          merged << range.dup
        end
      end
      @phone_seen_ranges[key] = merged
      @chat.phone_read_entries[key] = true if merged[0][0] == 0 && merged[0][1] >= row[:height]
    end
  end

  def terminate
    if @branch_used && @chat && @chat.choices[@choice_index]
      commit_choice_side_effects(@chat.choices[@choice_index])
    end
    super
    dispose_chat
  end

  def commit_choice_side_effects(choice)
    return unless choice
    value = choice[:value]
    $game_temp.group_chat_result = value
    $game_switches[choice[:switch]] = true if choice[:switch]
    if choice[:variable]
      var_id, var_value = choice[:variable]
      $game_variables[var_id] = var_value
    end
    value
  end

  def update_message_input
    if Input.repeat?(:UP) || Input.repeat?(:DOWN)
      @scroll_y += Input.repeat?(:UP) ? -44 : 44
      refresh_messages
    elsif Input.trigger?(:C)
      if @scroll_y < chat_max_scroll
        @scroll_y = [@scroll_y+chat_message_height-22,chat_max_scroll].min
        refresh_messages
      elsif @visible_count < @active_entries.size
        entry = @active_entries[@visible_count]
        play_message_se(entry)
        @visible_count += 1
        data = chat_draw_data
        last = data[:entries].last
        # Start a long message at its beginning; Z pages through it before
        # revealing another entry. Original transcript strings stay intact.
        @scroll_y = last && last[:height] > chat_message_height ? last[:y] : chat_max_scroll
        refresh_messages
        refresh_header
      elsif need_start_choices?
        @choice_active = true
        @choice_index = 0
        Sound.play_ok
        refresh_choices
      else
        return_scene
      end
    elsif Input.trigger?(:B)
      if @chat.required_choice && !@branch_used
        Sound.play_buzzer
      else
        return_scene
      end
    end
  end

  def play_message_se(entry)
    return unless entry
    sound = entry[:type] == :system ? SimplePhoneChat::MESSAGE_SE :
      (SimplePhoneChat::ACTOR_SE[entry[:actor]] || SimplePhoneChat::MESSAGE_SE)
    sound.play
  end

  def update_choice_input
    if Input.trigger?(:UP) || Input.trigger?(:DOWN)
      @choice_index = (@choice_index+(Input.trigger?(:UP) ? -1 : 1)) % @chat.choices.size
      Sound.play_cursor
      refresh_choices
    elsif Input.trigger?(:C)
      apply_choice
    elsif Input.trigger?(:B)
      if @chat.required_choice
        Sound.play_buzzer
      else
        Sound.play_cancel
        return_scene
      end
    end
  end

  def need_start_choices?
    !@branch_used && !@chat.choices.empty?
  end

  # Custom Menu's later override also saves the selected transcript branch.
  def apply_choice
    choice = @chat.choices[@choice_index]
    return unless choice
    commit_choice_side_effects(choice)
    @branch_used = true
    @choice_active = false
    @active_entries += @chat.choice_branches[choice[:value]] || []
    Sound.play_ok
    refresh_choices
  end

  def refresh_header
    bmp = @header_layer.bitmap
    bmp.clear
    phone_card(bmp,24,24,288,54)
    phone_text(bmp,36,28,264,27,@chat.title,20,nil,1,true)
    subtitle = @chat.subtitle.to_s
    subtitle = 'Trò chuyện' if subtitle.empty?
    phone_text(bmp,36,55,264,18,subtitle,12,Color.new(187,201,226),1)
  end

  def refresh_footer
    return unless @footer_layer
    bmp = @footer_layer.bitmap
    bmp.clear
    if @choice_active
      hint = '↑↓: chọn   Z: xác nhận'
    elsif @scroll_y < chat_max_scroll
      hint = '↑↓: cuộn   Z: đọc tiếp'
    elsif @visible_count < @active_entries.size
      hint = '↑↓: xem lại   Z: tin tiếp'
    elsif need_start_choices?
      hint = '↑↓: xem lại   Z: trả lời'
    else
      hint = '↑↓: xem lại   Z / X: trở lại'
    end
    hint += '   X: đóng' if !@choice_active && !@chat.required_choice &&
      @visible_count < @active_entries.size
    phone_footer(bmp,hint)
  end

  def chat_content_height
    PhoneMenu::MESSAGE_BOTTOM_LIMIT-PhoneMenu::CONTACT_MESSAGE_Y
  end

  def chat_message_height
    @choice_active && @choice_top ? [@choice_top-96-10,44].max : chat_content_height
  end

  def refresh_choices
    bmp = @choice_layer.bitmap
    bmp.clear
    @choice_layer.visible = @choice_active
    if @choice_active
      first = [[@choice_index-1,0].max,[@chat.choices.size-3,0].max].min
      rows = @chat.choices[first,3].each_with_index.map do |choice,i|
        lines = phone_wrap_text(choice[:text],264,16)
        {:index=>first+i,:lines=>lines,:height=>[lines.size*20+16,38].max}
      end
      while rows.size > 1 && rows.inject(0) { |sum,r|sum+r[:height]+8 } > 200
        rows.last[:index] == @choice_index ? rows.shift : rows.pop
      end
      @choice_rows = rows
      total = rows.inject(22) { |sum,r|sum+r[:height]+8 }
      @choice_top = PhoneMenu::PHONE_HEIGHT-46-total
      phone_text(bmp,24,@choice_top,288,20,
        "Chọn câu trả lời · #{@choice_index+1}/#{@chat.choices.size}",12,Color.new(202,212,235))
      y = @choice_top+22
      rows.each do |row|
        phone_card(bmp,24,y,288,row[:height],row[:index]==@choice_index)
        row[:lines].each_with_index do |line,i|
          phone_text(bmp,36,y+8+i*20,264,20,line,16)
        end
        y += row[:height]+8
      end
      @scroll_y = chat_max_scroll
    else
      @choice_top = nil
      @choice_rows = []
    end
    refresh_messages
  end

  def chat_max_scroll
    [chat_draw_data[:height]-chat_message_height,0].max
  end

  def refresh_messages
    bmp = @message_layer.bitmap
    bmp.clear
    @message_layer.src_rect.set(0,0,288,chat_message_height)
    @scroll_y = [[@scroll_y,0].max,chat_max_scroll].min
    chat_draw_data[:entries].each do |layout|
      y = layout[:y]-@scroll_y
      next if y+layout[:height] < 0 || y > chat_message_height
      case layout[:type]
      when :text then draw_text_entry(bmp,layout,y)
      when :image then draw_image_entry(bmp,layout,y)
      when :system then draw_system_entry(bmp,layout,y)
      end
    end
    if @visible_count == 0
      phone_text(bmp,0,80,288,24,'Z để xem tin nhắn',16,Color.new(187,201,226),1)
    end
    refresh_footer
  end

  def chat_draw_data
    y = 0
    rows = (@active_entries[0,@visible_count] || []).map do |entry|
      # Layout once per entry; revealing later messages does not measure all
      # previous paragraphs again. This cache belongs to this scene only.
      cached = @entry_layout_cache[entry.object_id] ||= build_entry_layout(entry)
      row = cached.merge(:y=>y)
      y += row[:height]+PhoneMenu::MESSAGE_SPACING
      row
    end
    {:entries=>rows,:height=>[y-PhoneMenu::MESSAGE_SPACING,0].max}
  end

  def build_entry_layout(entry)
    type = entry[:type]
    row = {:type=>type,:actor=>@chat.actor(entry[:actor]) || {:name=>'',:avatar=>'Contact_Quy'},
      :right=>entry[:side]==:right}
    if type == :system
      lines = phone_wrap_text(entry[:text],248,14)
      return row.merge(:lines=>lines,:height=>lines.size*20+16)
    end
    if type == :image
      src = Cache.load_bitmap('Graphics/Pictures/',entry[:image])
      scale = [150.0/src.width,110.0/src.height,1.0].min
      width,height = [(src.width*scale).to_i,1].max,[(src.height*scale).to_i,1].max
      row.merge!(:picture=>entry[:image],:width=>width,:body_height=>height)
    else
      lines = phone_wrap_text(entry[:text],PhoneMenu::MESSAGE_MAX_WIDTH-24,17)
      longest = lines.map { |line|simple_text_width(line,17) }.max || 0
      width = [[longest+24,PhoneMenu::MESSAGE_MIN_WIDTH].max,PhoneMenu::MESSAGE_MAX_WIDTH].min
      row.merge!(:lines=>lines,:width=>width,:body_height=>lines.size*22+20)
    end
    row[:x] = row[:right] ? PhoneMenu::MESSAGE_RIGHT_BUBBLE_RIGHT-PhoneMenu::PHONE_X-24-row[:width] : 36
    row[:height] = row[:body_height]+22
    row
  end

  def draw_text_entry(bmp,row,y)
    draw_sender(bmp,row,y)
    fill_round_rect(bmp,row[:x],y+22,row[:width],row[:body_height],12,
      row[:right] ? Color.new(78,96,159,248) : Color.new(230,236,249,248))
    row[:lines].each_with_index do |line,i|
      phone_text(bmp,row[:x]+12,y+32+i*22,row[:width]-24,22,line,17,
        row[:right] ? Color.new(255,255,255) : Color.new(25,37,59))
    end
  end

  def draw_sender(bmp,row,y)
    phone_text(bmp,row[:x],y,row[:width],20,row[:actor][:name],13,
      Color.new(199,211,237),row[:right] ? 2 : 0,true)
    src = Cache.load_bitmap('Graphics/PhoneMenu/',row[:actor][:avatar])
    x = row[:right] ? PhoneMenu::MESSAGE_RIGHT_ICON_X-PhoneMenu::PHONE_X-24 : 0
    bmp.stretch_blt(Rect.new(x,y+row[:height]-28,28,28),src,src.rect)
  end

  def draw_image_entry(bmp,row,y)
    draw_sender(bmp,row,y)
    src = Cache.load_bitmap('Graphics/Pictures/',row[:picture])
    bmp.stretch_blt(Rect.new(row[:x],y+22,row[:width],row[:body_height]),src,src.rect)
  end

  def draw_system_entry(bmp,row,y)
    fill_round_rect(bmp,8,y,272,row[:height],10,Color.new(26,37,58,230))
    row[:lines].each_with_index do |line,i|
      phone_text(bmp,20,y+8+i*20,248,20,line,14,Color.new(209,220,245),1)
    end
  end

  def dispose_chat
    return if @chat_disposed
    @chat_disposed = true
    (chat_parts+[@dim]).compact.each do |sprite|
      sprite.bitmap.dispose if sprite.bitmap && !sprite.bitmap.disposed?
      sprite.dispose unless sprite.disposed?
    end
    @phone_measure_bitmap.dispose if @phone_measure_bitmap && !@phone_measure_bitmap.disposed?
    @phone_measure_bitmap = nil
    @phone_wrap_cache = @entry_layout_cache = nil
    @chat_base_y = nil
  end
end

#==============================================================================
# ** GroupChatPreset
#------------------------------------------------------------------------------
# Event script call:
#   GroupChatPreset.christmas_test
#==============================================================================

module GroupChatPreset
  def self.setup_wanderer_members(chat)
    chat.add_actor(:quy,      "Quỳ",      "Contact_Quy")
    chat.add_actor(:leo,      "Leo",      "Contact_Leo")
    chat.add_actor(:kohi,     "Kohi",     "Contact_Kohi")
    chat.add_actor(:hakase,   "Hakase",   "Contact_Hakase")
    chat.add_actor(:shylvie,  "Shylvie",  "Contact_Shylvie")
  end

  def self.christmas_test
    chat = Game_SimplePhoneChat.new
    chat.title = "Wanderer Office"
    chat.subtitle = "Christmas planning"

    setup_wanderer_members(chat)

    chat.add_text(:leo, "Ủa, mấy nay có ai liên lạc được với Quỳ không??")
    chat.add_text(:shylvie, "Chịu, chả biết bà ấy đi đâu.")
    chat.add_text(:kohi, "Tui không thấy Quỳ onl luôn ấy.")
    chat.add_text(:hakase, "Tôi cũng vậy.")
    chat.add_image(:hakase, "CG22")

    chat.add_text(:leo, "Hừm. Vậy mọi người tính giáng sinh năm nay tổ chức như thế nào?")
    chat.add_text(:kohi, "Ồ, bên mình có tổ chức giáng sinh mỗi năm luôn hả?")
    chat.add_text(:leo, "Có chứ! Giáng sinh năm ngoái bọn tui đóng giả làm ông già Noel để đi tặng quà cho khách hàng ấy.")
    chat.add_text(:shylvie, "Nói đúng hơn là đột nhập trái phép đó. Năm ngoái Leo suýt nữa bị bắt được, may mà ổng biến thành dơi nên trốn kịp.")
    chat.add_text(:leo, "Nè, tại ai vậy hả?? Nếu lúc đó ông không đạp tui xuống đột ngột thì đâu có chuyện đó.")
    chat.add_text(:hakase, "Nhí nhí mọi người, cho tôi hỏi cái.")
    chat.add_text(:leo, "Sao thế?")
    chat.add_text(:shylvie, "Hả, hỏi gì.")
    chat.add_text(:hakase, "Bọn mình…có khách hàng hả?")
    chat.add_text(:kohi, "Trời má trùng hợp ghê, cũng đang tính hỏi. Đến giờ tôi vẫn chưa hiểu văn phòng của mình có công việc gì luôn.")
    chat.add_text(:shylvie, "Ờm….Bà biết đó, ờm...")
    chat.add_text(:leo, "Giải quyết yêu cầu của khách hàng đến từ đa chiều không gian khác nhau. Lúc thì điều tra án mạng, lúc thì điều tra chân tướng sự kiện bất thường. Có lúc thì đi bảo vệ, giải cứu dân thường hoặc là đi thanh trừng quái vật.")
    chat.add_text(:shylvie, "Không biết lý do vì sao mà dạo gần đây bọn tôi toàn nhận được yêu cầu đi thanh trừng quái vật nên là không muốn để mọi người đi. Vì mọi người chưa được rèn luyện lẫn trang bị phù hợp nên là không thể để mọi người mạo hiểm được.")
    chat.add_text(:leo, "Đa phần công việc thanh trừng quái vật bọn tui toàn để cho Hải Quỳ giải quyết thôi. Bả bắn tia năng lượng một phát là xong ngay ấy mà.")
    chat.add_text(:shylvie, "Và…đó cũng là vấn đề mà bọn tôi đang nhức đầu đây,")
    chat.add_text(:kohi, "Hả? Sao lại nhức đầu?")
    chat.add_text(:hakase, "Đừng nói là bả bắn beam xuyên không gian nhé?")
    chat.add_text(:leo, "Nah, không phải đâu.")
    chat.add_text(:shylvie, "Để du hành sang chiều không gian khác, tôi cùng với cựu thành viên đã chế tạo ra một trang bị, một chiếc vòng tay có gắn la bàn, giúp cho người du hành có thể thích ứng kịp thời với quy luật sống ở chiều không gian đấy.")
    chat.add_text(:shylvie, "Mỗi chiều không gian sẽ có quy luật sống riêng, cũng như là quy luật và trật tự ma pháp riêng.")
    chat.add_text(:shylvie, "Và Hải Quỳ…Ở một số chiều không gian, ma lực của bả vượt xa cả quy luật ở đó. Dẫn đến việc trang bị bị quá tải và hỏng liên tục.")
    chat.add_text(:leo, "Yeah. Bọn tui cố sửa chữa để kịp cho các yêu cầu tiếp theo nhưng không kịp. Thế nên bọn tui đành cho bả mượn trang bị của bọn tui lẫn các trang bị dự phòng. Đó cũng là lý do mà tui vẫn chưa giao nhiệm vụ nào cho hai người đó.")
    chat.add_text(:hakase, "Trời má, ghê dữ vậy hả.")
    chat.add_text(:kohi, "Bả làm hỏng hết luôn?")
    chat.add_text(:shylvie, "Chứ sao nữa. Hỏng hết. Có cái không còn sửa được luôn.")
    chat.add_text(:leo, "Ồ, nói ra mới nhớ. Tần suất hoạt động của Quái Vật Vực Sâu tăng lên đáng kể những tháng cuối năm nhỉ. Năm ngoái cũng vậy, tui nhớ là đến tận những ngày gần cuối năm bả mới ló mặt đến Văn Phòng Wanderer đó. Chả lẽ năm nay cũng vậy??")
    chat.add_text(:hakase, "Có lẽ nào…")

    chat.add_system("Hải Quỳ join the chat")

    chat.add_text(:quy, "Ông cũng để ý nhỉ. Cơ mà tui đã giải quyết xong hết rồi, tui đoán vậy.", :right)
    chat.add_text(:leo, "Quỳ! Cuối cùng bà cũng onl! Ý bà giải quyết xong hết rồi là sao?")
    chat.add_text(:quy, "Thì tui làm hết nhiệm vụ cấp trên giao cho và được nghỉ lễ trước cả mấy bạn ở Silver Wing luôn đấy. Khen tui cái coi.", :right)
    chat.add_text(:shylvie, "Trời ơi, Ma pháp thiếu nữ Hải Quỳ toàn năng tài giỏi quá trời ơi, làm hết việc luôn cơ!! Đỉnh cao đỉnh cao!!")
    chat.add_text(:quy, "Tui đánh ông giờ. Khen hay là khịa đấy.", :right)
    chat.add_text(:shylvie, "Tùy bà nghĩ thôi, lmao.")
    chat.add_text(:quy, "Để tôi đoán nhé, ông tính hỏi tui về hoạt động Noel năm nay hả?", :right)
    chat.add_text(:leo, "Ừ.")
    chat.add_text(:quy, "Năm nay tui muốn mọi người sẽ tặng quà theo vòng cho nhau!", :right)
    chat.add_text(:kohi, "Ý Quỳ là sao á?")
    chat.add_text(:shylvie, "Nghe…rất gì và này nọ…? Nói rõ hơn đi.")
    chat.add_text(:quy, "Thì giả sử tui tặng cho Leo, Leo sẽ tặng cho Shylvie, Shylvie tặng Kohi và Kohi tặng Hakase.", :right)
    chat.add_text(:hakase, "Nghe thú vị thế!")
    chat.add_text(:leo, "À à, tui hiểu ý bà rồi. Là tặng theo vòng tròn, người cuối cùng sẽ tặng cho bà đúng không?")
    chat.add_text(:quy, "Yeh, nó đó!! Tui sẽ là người bắt đầu!", :right)
    chat.add_text(:kohi, "À. Thế thì Quỳ chuẩn bị quà sớm rồi thông báo người tiếp theo nhé để bọn tôi chuẩn bị quà kịp!! Tại nay cũng là 21 rồi đó!")
 
    chat.add_choice("Đi siêu thị", 1)
    chat.add_choice("Đi về nhà", 2)

    chat.add_branch_text(1, :quy, "Tôi đi mua quà ngay đây", :right)
    chat.add_branch_text(1, :kohi, "Ok, hẹn gặp lại bà sau")

    chat.add_branch_text(2, :quy, "Tôi nghĩ thêm cái đã", :right)
    chat.add_branch_text(2, :kohi, "nhớ nhắn sớm nhé")
    GroupChat.start(chat)
  end
end

# Ending Atlantis — route rượt đuổi. Kept as a reusable preset so the map
# event only starts the cutscene and then stores the exact conversation log.
module GroupChatPreset
  # Supermarket route scene 5. The choice writes Variable 43 (MKT_TARGET),
  # allowing the map event to resume only after the phone scene closes.
  def self.market_recipient
    chat = Game_SimplePhoneChat.new
    chat.title = "Wanderer Office"
    chat.subtitle = "The chosen one"
    chat.required_choice = true
    setup_wanderer_members(chat)
    chat.add_text(:quy, "Mọi người ơi, tui đã quyết định được giáng sinh này sẽ tặng quà cho ai rồi.", :right)
    chat.add_text(:shylvie, "Ai thế? Là tôi hả?!")
    chat.add_text(:hakase, "Ai vậy?")
    chat.add_text(:kohi, "Ai rứa?")
    chat.add_choice("Leo", 1, :variable => [43, 1])
    chat.add_choice("Kohi", 2, :variable => [43, 2])
    chat.add_choice("Shylvie", 3, :variable => [43, 3])
    chat.add_choice("Hakase", 4, :variable => [43, 4])

    gift = $game_variables ? $game_variables[42].to_i : 1
    chat.add_branch_text(1, :quy, "Là Leo!", :right)
    chat.add_branch_text(1, :leo, "Hả? Là tui á? Bà chắc chưa á?")
    chat.add_branch_text(1, :quy, "Như đinh đóng cột! Mọi người tiếp tục vòng tặng nhé! Tớ sủi đây, hihi!", :right)

    if gift == 2 || gift == 4
      chat.add_branch_text(2, :quy, "Là Kohi", :right)
      chat.add_branch_text(2, :kohi, "Oa!! Hóng quá!!")
      chat.add_branch_text(2, :quy, "Kohi hóng như vậy sao?! Cơ mà Mọi người tiếp tục vòng tặng nhé! Tớ sủi đây, hihi!", :right)
    else
      chat.add_branch_text(2, :quy, "Là Kohi!!", :right)
      chat.add_branch_text(2, :shylvie, "Ui! Hóng quá!")
      chat.add_branch_text(2, :leo, "Bà chắc sẽ tặng Kohi chưa?")
      chat.add_branch_text(2, :quy, "Như đinh đóng cột! Mọi người tiếp tục vòng tặng nhé! Tớ sủi đây, hihi!", :right)
    end

    chat.add_branch_text(3, :quy, "Là Shylvie", :right)
    chat.add_branch_text(3, :shylvie, "Ôi vinh dự thế!!")
    if gift == 4
      chat.add_branch_text(3, :quy, "Phải vinh dự chứ! Tui cá chắc chưa ai tặng ông món này luôn!", :right)
      chat.add_branch_text(3, :shylvie, "Gì, nghe hoành tráng vậy? Tò mò ghê.")
    else
      chat.add_branch_text(3, :quy, "Vậy là không muốn được tặng hả?", :right)
      chat.add_branch_text(3, :shylvie, "Ừ đúng rồi đó~ Không muốn được tặng đó")
      chat.add_branch_text(3, :quy, "Thì thôi~", :right)
    end
    chat.add_branch_text(3, :leo, "Bà chắc sẽ tặng Shylvie chưa?")
    chat.add_branch_text(3, :quy, "Chắc chắn rồi. Mọi người tiếp tục vòng tặng nhé. Tớ đi đây.", :right)
    chat.add_branch_text(4, :quy, "Là Hakase đó!", :right)
    chat.add_branch_text(4, :hakase, "Yatta!! Vui quá!! Hóng quà à nghen!!")
    chat.add_branch_text(4, :leo, "Bà chắc sẽ tặng Hakase chưa?")
    chat.add_branch_text(4, :quy, "Chắc chắn rồi!! Tớ đi đây, gặp lại mấy cậu sau!!", :right)
    GroupChat.start(chat)
  end

  # Route mì cay: người nhận được kịch bản cố định là Leo, nên đoạn chat này
  # không mở menu chọn người như route siêu thị.
  def self.noodle_recipient
    chat = Game_SimplePhoneChat.new
    chat.title = "Wanderer Office"
    chat.subtitle = "The chosen one"
    setup_wanderer_members(chat)
    chat.add_text(:quy, "Mọi người ơi, tui đã quyết định được giáng sinh này sẽ tặng quà cho ai rồi.", :right)
    chat.add_text(:shylvie, "Ai thế? Là tôi hả?!")
    chat.add_text(:hakase, "Ai vậy?")
    chat.add_text(:kohi, "Ai rứa?")
    chat.add_text(:quy, "Là Leo.", :right)
    chat.add_text(:shylvie, "Ui! Hóng quá!")
    chat.add_text(:leo, "Bà chắc sẽ tặng tôi chưa?")
    chat.add_text(:quy, "Như đinh đóng cột! Mọi người tiếp tục vòng tặng nhé! Tớ sủi đây, hihi!", :right)
    GroupChat.start(chat)
  end

  # Route hỏi Leo: tin nhắn riêng tại trạm xe buýt.  Lựa chọn được ghi vào
  # Variable 55 để event map chuyển đến đúng cửa hàng sau khi giao diện điện
  # thoại đóng lại.
  def self.leo_shop_choice
    chat = Game_SimplePhoneChat.new
    chat.title = "Leo"
    chat.subtitle = "Tin nhắn riêng"
    chat.required_choice = true
    chat.add_actor(:quy, "Hải Quỳ", "Contact_Quy")
    chat.add_actor(:leo, "Leo", "Contact_Leo")
    chat.add_text(:leo, "Hải Quỳ, bà tính đi đâu mua đồ vậy?")
    chat.add_text(:quy, "Tôi đang tính đi ra siêu thị hoặc là về Atlantis để mua á. Sao vậy?", :right)
    chat.add_text(:leo, "Bà có muốn tôi giới thiệu bà đến mấy cửa hàng mà tôi quen ở các chiều không gian khác không? Họ có mấy món mà các thành viên khác sẽ thích đấy.")
    chat.add_text(:quy, "Tuyệt vời ông mặt trời!! Vậy ông gửi cho tui tọa độ của…", :right)
    chat.add_choice("Cửa hàng cà phê", 1, :variable => [55, 1])
    chat.add_choice("Cửa hàng vũ khí", 2, :variable => [55, 2])
    chat.add_choice("Cửa tiệm dụng cụ ma pháp", 3, :variable => [55, 3])
    chat.add_branch_text(1, :leo, "Ờ, đợi xíu!")
    chat.add_branch_text(2, :leo, "Ờ, đợi xíu!")
    chat.add_branch_text(3, :leo, "Ờ, đợi xíu!")
    GroupChat.start(chat)
  end

  # Route hỏi Shylvie: tin nhắn riêng dẫn Hải Quỳ tới tiệm đá phong thủy.
  # Event lưu lại cutscene này vào điện thoại sau khi giao diện đóng.
  def self.shylvie_jewel_invite
    chat = Game_SimplePhoneChat.new
    chat.title = "Shylvie"
    chat.subtitle = "Tin nhắn riêng"
    chat.add_actor(:quy, "Hải Quỳ", "Contact_Quy")
    chat.add_actor(:shylvie, "Shylvie", "Contact_Shylvie")
    chat.add_text(:shylvie, "Hải Quỳ, bà có muốn tạt ngang qua cửa tiệm bán đá phong thủy không?")
    chat.add_text(:quy, "Shylvie nhiệt tình giới thiệu quá nên chắc là có.", :right)
    chat.add_text(:shylvie, "Để tui gửi tọa độ cho.")
    chat.add_text(:quy, "Ừ, gửi tọa độ lẹ lên!", :right)
    GroupChat.start(chat)
  end

  def self.atlantis_chase_ending
    chat = Game_SimplePhoneChat.new
    chat.title = "Wanderer Office"
    chat.subtitle = "Không thể dự tiệc"
    setup_wanderer_members(chat)

    chat.add_text(:quy, "Mọi người ơi…", :right)
    chat.add_text(:leo, "Sao vậy Quỳ? Có chuyện gì vậy?")
    chat.add_text(:quy, "E là giáng sinh lần này…tui không tham gia được.", :right)
    chat.add_text(:hakase, "Hả! Sao đột ngột vậy?")
    chat.add_text(:kohi, "Sao lại không tham gia?")
    chat.add_text(:quy, "Đại khái là tui bị úp sọt…!", :right)
    chat.add_text(:quy, "Giờ đang phải dưỡng thương…!", :right)
    chat.add_text(:shylvie, "Cái gì? Bà bị úp sọt? Khó tin thế?")
    chat.add_text(:quy, "Úp sọt thật mà.", :right)
    chat.add_text(:quy, "Tui bị úp sọt bởi quái vật vực sâu có khả năng cải trang.", :right)
    chat.add_text(:quy, "Chuyện kể ra thì dài lắm!", :right)
    chat.add_text(:quy, "Nhưng tóm cái quần lại là tui không tham gia chung với mọi người được!", :right)
    chat.add_text(:leo, "Không sao!")
    chat.add_text(:kohi, "Cứ nghỉ ngơi cho khỏe đã!")
    chat.add_text(:hakase, "Aww, không lần này thì lần khác!!")
    chat.add_text(:shylvie, "Quan trọng là sức khỏe.")
    chat.add_text(:shylvie, "Không tham gia trực tiếp được thì tham gia gián tiếp được mà, đúng không?")
    chat.add_text(:leo, "Ừ ha!")
    chat.add_text(:leo, "Triển đi!!")
    chat.add_text(:quy, "Mọi người…!!", :right)
    GroupChat.start(chat)
  end
end
