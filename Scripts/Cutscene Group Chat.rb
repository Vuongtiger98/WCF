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
  PHONE_WIDTH  = 350
  PHONE_HEIGHT = 450
  PHONE_X = (Graphics.width - PHONE_WIDTH) / 2
  PHONE_Y = (Graphics.height - PHONE_HEIGHT) / 2

  BACKGROUND_FILE = "MessageBackground"

  HEADER_H = 52
  FOOTER_H = 74

  CONTENT_X = 12
  CONTENT_Y = HEADER_H + 6
  CONTENT_W = PHONE_WIDTH - 24
  CONTENT_H = PHONE_HEIGHT - HEADER_H - FOOTER_H - 12

  AVATAR_SIZE = 28
  LEFT_AVATAR_X  = 10
  RIGHT_AVATAR_X = PHONE_WIDTH - 10 - AVATAR_SIZE

  LEFT_BUBBLE_X = LEFT_AVATAR_X + AVATAR_SIZE + 8
  RIGHT_BUBBLE_RIGHT = RIGHT_AVATAR_X - 8

  MAX_BUBBLE_W = 168
  MIN_BUBBLE_W = 56
  BUBBLE_PAD_X = 12
  BUBBLE_PAD_Y = 8
  LINE_H = 22
  NAME_H = 18
  NAME_GAP = 2
  ENTRY_GAP = 10
  BLOCK_GAP = 12

  IMAGE_MAX_W = 150
  IMAGE_MAX_H = 118

  CHOICE_X = 16
  CHOICE_W = PHONE_WIDTH - 32
  CHOICE_H = 32
  CHOICE_GAP = 8

  HEADER_BG = Color.new(0, 0, 0, 140)
  FOOTER_BG = Color.new(0, 0, 0, 70)
  DIM_COLOR = Color.new(0, 0, 0, 120)

  LEFT_BUBBLE_COLOR  = Color.new(248, 248, 248, 232)
  RIGHT_BUBBLE_COLOR = Color.new(42, 155, 255, 224)

  NAME_COLOR   = Color.new(255, 255, 255)
  SYSTEM_COLOR = Color.new(240, 240, 240)
  SHADOW_COLOR = Color.new(0, 0, 0, 160)

  LEFT_TEXT_COLOR  = Color.new(24, 24, 24)
  RIGHT_TEXT_COLOR = Color.new(255, 255, 255)

  CHOICE_COLOR = Color.new(248, 248, 248, 235)
  CHOICE_SELECTED_COLOR = Color.new(170, 210, 255, 235)
  CHOICE_TEXT_COLOR = Color.new(20, 20, 20)

  TITLE_SIZE  = 24
  SUB_SIZE    = 16
  NAME_SIZE   = 18
  TEXT_SIZE   = 20
  SYSTEM_SIZE = 18
  CHOICE_SIZE = 20
  
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

  def initialize
    @title = "Chat"
    @subtitle = ""
    @actors = {}
    @entries = []
    @choices = []
    @choice_branches = {}
    @required_choice = false
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
    SceneManager.call(Scene_SimplePhoneChat)
  end

  def self.result
    $game_temp.group_chat_result
  end
end

#==============================================================================
# ** Scene_SimplePhoneChat
#==============================================================================
class Scene_SimplePhoneChat < Scene_Base
  def start
    super
    @chat = $game_temp.group_chat_data || Game_SimplePhoneChat.new
    @active_entries = @chat.entries.clone
    @visible_count = 0
    @scroll_y = 0
    @choice_active = false
    @choice_index = 0
    @branch_used = false
    @measure_bitmap = Bitmap.new(1, 1)

    create_dim
    create_phone_background
    create_message_layer
    create_header_layer
    create_footer_layer
    create_choice_layer
    refresh_header
    refresh_footer
    refresh_messages
    refresh_choices
  end

  def terminate
    # SceneManager resumes the map only after this scene terminates. Commit the
    # chosen entry one final time here so late method overrides cannot leave a
    # route variable unset even though the player visibly made a choice.
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

  def update
    super
    if @choice_active
      update_choice_input
    else
      update_message_input
    end
  end

  #--------------------------------------------------------------------------
  # Create
  #--------------------------------------------------------------------------
  def create_dim
    @dim = Sprite.new
    @dim.bitmap = Bitmap.new(Graphics.width, Graphics.height)
    @dim.bitmap.fill_rect(0, 0, Graphics.width, Graphics.height, SimplePhoneChat::DIM_COLOR)
    @dim.z = 1
  end

  def create_phone_background
    @phone_bg = Sprite.new
    @phone_bg.x = SimplePhoneChat::PHONE_X
    @phone_bg.y = SimplePhoneChat::PHONE_Y
    @phone_bg.z = 10
    src = Cache.load_bitmap("Graphics/PhoneMenu/", SimplePhoneChat::BACKGROUND_FILE)
    @phone_bg.bitmap = Bitmap.new(SimplePhoneChat::PHONE_WIDTH, SimplePhoneChat::PHONE_HEIGHT)
    @phone_bg.bitmap.stretch_blt(@phone_bg.bitmap.rect, src, src.rect)
  end

  def create_message_layer
    @message_layer = Sprite.new
    @message_layer.x = SimplePhoneChat::PHONE_X + SimplePhoneChat::CONTENT_X
    @message_layer.y = SimplePhoneChat::PHONE_Y + SimplePhoneChat::CONTENT_Y
    @message_layer.z = 20
    @message_layer.bitmap = Bitmap.new(SimplePhoneChat::CONTENT_W, SimplePhoneChat::CONTENT_H)
  end

  def create_header_layer
    @header_layer = Sprite.new
    @header_layer.x = SimplePhoneChat::PHONE_X
    @header_layer.y = SimplePhoneChat::PHONE_Y
    @header_layer.z = 30
    @header_layer.bitmap = Bitmap.new(SimplePhoneChat::PHONE_WIDTH, SimplePhoneChat::HEADER_H)
  end

  def create_footer_layer
    @footer_layer = Sprite.new
    @footer_layer.x = SimplePhoneChat::PHONE_X
    @footer_layer.y = SimplePhoneChat::PHONE_Y + SimplePhoneChat::PHONE_HEIGHT - SimplePhoneChat::FOOTER_H
    @footer_layer.z = 30
    @footer_layer.bitmap = Bitmap.new(SimplePhoneChat::PHONE_WIDTH, SimplePhoneChat::FOOTER_H)
  end

  def create_choice_layer
    @choice_layer = Sprite.new
    @choice_layer.x = SimplePhoneChat::PHONE_X
    @choice_layer.y = SimplePhoneChat::PHONE_Y
    @choice_layer.z = 40
    @choice_layer.bitmap = Bitmap.new(SimplePhoneChat::PHONE_WIDTH, SimplePhoneChat::PHONE_HEIGHT)
    @choice_layer.visible = false
  end

  #--------------------------------------------------------------------------
  # Input
  #--------------------------------------------------------------------------
  def update_message_input
    if Input.trigger?(:C)
      if @visible_count < @active_entries.size
        entry = @active_entries[@visible_count]
        play_message_se(entry)
        @visible_count += 1
        refresh_messages
      elsif need_start_choices?
        @choice_active = true
        @choice_index = 0
        Sound.play_ok
        refresh_footer
        refresh_choices
      else
        return_scene
      end
    elsif Input.trigger?(:B)
      # A required-choice chat must not be closable before a choice has been
      # committed. Previously B could close the chat while it was still
      # revealing messages, leaving its route variable at 0.
      if @chat.required_choice && !@branch_used
        Sound.play_buzzer
      else
        return_scene
      end
    end
  end
  
  def play_message_se(entry)
    return unless entry

    # system message
    if entry[:type] == :system
      SimplePhoneChat::MESSAGE_SE.play
      return
    end

    # actor-specific sound
    if entry[:actor] && SimplePhoneChat::ACTOR_SE[entry[:actor]]
      SimplePhoneChat::ACTOR_SE[entry[:actor]].play
    else
      SimplePhoneChat::MESSAGE_SE.play
    end
  end

  def update_choice_input
    if Input.trigger?(:UP)
      @choice_index = (@choice_index - 1) % @chat.choices.size
      Sound.play_cursor
      refresh_choices
    elsif Input.trigger?(:DOWN)
      @choice_index = (@choice_index + 1) % @chat.choices.size
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

def apply_choice
  choice = @chat.choices[@choice_index]
  return unless choice

  value = commit_choice_side_effects(choice)

  @branch_used = true
  @choice_active = false

  branch_entries = @chat.choice_branches[value] || []
  @active_entries += branch_entries

  Sound.play_ok
  refresh_footer
  refresh_choices
end

  #--------------------------------------------------------------------------
  # Refresh
  #--------------------------------------------------------------------------
  def refresh_header
    bmp = @header_layer.bitmap
    bmp.clear
    draw_round_rect(bmp, 0, 0, SimplePhoneChat::PHONE_WIDTH, SimplePhoneChat::HEADER_H, 12, SimplePhoneChat::HEADER_BG)

    draw_shadow_text(bmp, 0, 4, SimplePhoneChat::PHONE_WIDTH, 24,
      @chat.title, 1, SimplePhoneChat::TITLE_SIZE, true, Color.new(255,255,255))

    draw_shadow_text(bmp, 0, 25, SimplePhoneChat::PHONE_WIDTH, 18,
      @chat.subtitle, 1, SimplePhoneChat::SUB_SIZE, false, Color.new(245,245,245))
  end

  def refresh_footer
    bmp = @footer_layer.bitmap
    bmp.clear
    return if @choice_active
    bmp.fill_rect(0, 0, SimplePhoneChat::PHONE_WIDTH, SimplePhoneChat::FOOTER_H, SimplePhoneChat::FOOTER_BG)
  end

  def refresh_choices
    bmp = @choice_layer.bitmap
    bmp.clear
    if !@choice_active
      @choice_layer.visible = false
      return
    end

    @choice_layer.visible = true
    count = @chat.choices.size
    total_h = count * SimplePhoneChat::CHOICE_H + (count - 1) * SimplePhoneChat::CHOICE_GAP
    start_y = SimplePhoneChat::PHONE_HEIGHT - 16 - total_h

    @chat.choices.each_with_index do |choice, i|
      y = start_y + i * (SimplePhoneChat::CHOICE_H + SimplePhoneChat::CHOICE_GAP)
      color = (i == @choice_index) ? SimplePhoneChat::CHOICE_SELECTED_COLOR : SimplePhoneChat::CHOICE_COLOR
      draw_round_rect(bmp, SimplePhoneChat::CHOICE_X, y, SimplePhoneChat::CHOICE_W,
        SimplePhoneChat::CHOICE_H, 8, color)

      bmp.font.size = SimplePhoneChat::CHOICE_SIZE
      bmp.font.bold = true
      bmp.font.outline = false
      bmp.font.color = SimplePhoneChat::CHOICE_TEXT_COLOR
      bmp.draw_text(SimplePhoneChat::CHOICE_X, y + 2, SimplePhoneChat::CHOICE_W,
        SimplePhoneChat::CHOICE_H, choice[:text], 1)
    end
  end

  def refresh_messages
    bmp = @message_layer.bitmap
    bmp.clear

    data = build_visible_draw_data
    @scroll_y = data[:scroll_y]
    draw_entries_to_bitmap(bmp, data[:entries], @scroll_y)
  end

  #--------------------------------------------------------------------------
  # Drawing data
  #--------------------------------------------------------------------------
  def build_visible_draw_data
    visible_entries = @active_entries[0, @visible_count] || []
    draw_entries = []
    y = 0

    visible_entries.each do |entry|
      layout = build_entry_layout(entry, y)
      draw_entries << layout
      y += layout[:height] + SimplePhoneChat::BLOCK_GAP
    end

    total_h = y
    scroll_y = [total_h - SimplePhoneChat::CONTENT_H, 0].max

    {
      :entries => draw_entries,
      :scroll_y => scroll_y
    }
  end

  def build_entry_layout(entry, start_y)
    case entry[:type]
    when :text
      build_text_layout(entry, start_y)
    when :image
      build_image_layout(entry, start_y)
    when :system
      build_system_layout(entry, start_y)
    else
      { :type => :none, :y => start_y, :height => 0 }
    end
  end

  def build_text_layout(entry, start_y)
    actor = @chat.actor(entry[:actor])
    lines = wrap_text(entry[:text], SimplePhoneChat::MAX_BUBBLE_W - SimplePhoneChat::BUBBLE_PAD_X * 2)

    longest = 0
    lines.each do |line|
      w = text_width(line, SimplePhoneChat::TEXT_SIZE)
      longest = w if w > longest
    end

    bubble_w = [[longest + SimplePhoneChat::BUBBLE_PAD_X * 2, SimplePhoneChat::MIN_BUBBLE_W].max,
                SimplePhoneChat::MAX_BUBBLE_W].min
    bubble_h = lines.size * SimplePhoneChat::LINE_H + SimplePhoneChat::BUBBLE_PAD_Y * 2
    total_h = SimplePhoneChat::NAME_H + SimplePhoneChat::NAME_GAP + bubble_h

    if entry[:side] == :right
      avatar_x = SimplePhoneChat::RIGHT_AVATAR_X - SimplePhoneChat::CONTENT_X
      bubble_x = SimplePhoneChat::RIGHT_BUBBLE_RIGHT - bubble_w - SimplePhoneChat::CONTENT_X
      name_x = bubble_x
      align = 2
      bubble_color = SimplePhoneChat::RIGHT_BUBBLE_COLOR
      text_color = SimplePhoneChat::RIGHT_TEXT_COLOR
    else
      avatar_x = SimplePhoneChat::LEFT_AVATAR_X - SimplePhoneChat::CONTENT_X
      bubble_x = SimplePhoneChat::LEFT_BUBBLE_X - SimplePhoneChat::CONTENT_X
      name_x = bubble_x
      align = 0
      bubble_color = SimplePhoneChat::LEFT_BUBBLE_COLOR
      text_color = SimplePhoneChat::LEFT_TEXT_COLOR
    end

    {
      :type => :text,
      :actor => actor,
      :lines => lines,
      :y => start_y,
      :height => total_h,
      :avatar_x => avatar_x,
      :bubble_x => bubble_x,
      :name_x => name_x,
      :bubble_w => bubble_w,
      :bubble_h => bubble_h,
      :align => align,
      :bubble_color => bubble_color,
      :text_color => text_color
    }
  end

  def build_image_layout(entry, start_y)
  actor = @chat.actor(entry[:actor])
  src = Cache.load_bitmap("Graphics/Pictures/", entry[:image])
  w, h = fit_rect(src.width, src.height, SimplePhoneChat::IMAGE_MAX_W, SimplePhoneChat::IMAGE_MAX_H)
  total_h = SimplePhoneChat::NAME_H + SimplePhoneChat::NAME_GAP + h

  if entry[:side] == :right
    avatar_x = SimplePhoneChat::RIGHT_AVATAR_X - SimplePhoneChat::CONTENT_X
    image_x = SimplePhoneChat::RIGHT_BUBBLE_RIGHT - w - SimplePhoneChat::CONTENT_X
    name_x = image_x
    align = 2
  else
    avatar_x = SimplePhoneChat::LEFT_AVATAR_X - SimplePhoneChat::CONTENT_X
    image_x = SimplePhoneChat::LEFT_BUBBLE_X - SimplePhoneChat::CONTENT_X
    name_x = image_x
    align = 0
  end

  {
    :type => :image,
    :actor => actor,
    :picture => entry[:image],
    :y => start_y,
    :height => total_h,
    :avatar_x => avatar_x,
    :image_x => image_x,
    :image_w => w,
    :image_h => h,
    :name_x => name_x,
    :align => align
  }
end

  def build_system_layout(entry, start_y)
    {
      :type => :system,
      :text => entry[:text],
      :y => start_y,
      :height => 24
    }
  end

  #--------------------------------------------------------------------------
  # Draw entries
  #--------------------------------------------------------------------------
  def draw_entries_to_bitmap(bitmap, entries, scroll_y)
    entries.each do |layout|
      y = layout[:y] - scroll_y
      next if y + layout[:height] < 0
      next if y > SimplePhoneChat::CONTENT_H
      case layout[:type]
      when :text
        draw_text_entry(bitmap, layout, y)
      when :image
        draw_image_entry(bitmap, layout, y)
      when :system
        draw_system_entry(bitmap, layout, y)
      end
    end
  end

  def draw_text_entry(bitmap, layout, y)
    bubble_y = y + SimplePhoneChat::NAME_H + SimplePhoneChat::NAME_GAP
    avatar_y = bubble_y + layout[:bubble_h] - SimplePhoneChat::AVATAR_SIZE

    draw_avatar(bitmap, layout[:actor][:avatar], layout[:avatar_x], avatar_y)

    draw_shadow_text(bitmap, layout[:name_x], y, 170, SimplePhoneChat::NAME_H,
      layout[:actor][:name], layout[:align], SimplePhoneChat::NAME_SIZE, true, SimplePhoneChat::NAME_COLOR)

    draw_round_rect(bitmap, layout[:bubble_x], bubble_y,
      layout[:bubble_w], layout[:bubble_h], 14, layout[:bubble_color])

    bitmap.font.size = SimplePhoneChat::TEXT_SIZE
    bitmap.font.bold = false
    bitmap.font.outline = false
    bitmap.font.color = layout[:text_color]

    text_x = layout[:bubble_x] + SimplePhoneChat::BUBBLE_PAD_X
    text_y = bubble_y + SimplePhoneChat::BUBBLE_PAD_Y
    text_w = layout[:bubble_w] - SimplePhoneChat::BUBBLE_PAD_X * 2

    layout[:lines].each_with_index do |line, i|
      bitmap.draw_text(text_x, text_y + i * SimplePhoneChat::LINE_H,
        text_w, SimplePhoneChat::LINE_H, line, layout[:align])
    end
  end

  def draw_image_entry(bitmap, layout, y)
    image_y = y + SimplePhoneChat::NAME_H + SimplePhoneChat::NAME_GAP
    avatar_y = image_y + layout[:image_h] - SimplePhoneChat::AVATAR_SIZE

    draw_avatar(bitmap, layout[:actor][:avatar], layout[:avatar_x], avatar_y)

    draw_shadow_text(bitmap, layout[:name_x], y, 170, SimplePhoneChat::NAME_H,
      layout[:actor][:name], layout[:align], SimplePhoneChat::NAME_SIZE, true, SimplePhoneChat::NAME_COLOR)

    src = Cache.load_bitmap("Graphics/Pictures/", layout[:picture])
    bitmap.stretch_blt(Rect.new(layout[:image_x], image_y, layout[:image_w], layout[:image_h]),
      src, src.rect)
  end

  def draw_system_entry(bitmap, layout, y)
    draw_shadow_text(bitmap, 0, y, SimplePhoneChat::CONTENT_W, 24,
      "Notice: #{layout[:text]}", 1, SimplePhoneChat::SYSTEM_SIZE, true, SimplePhoneChat::SYSTEM_COLOR)
  end

  def draw_avatar(bitmap, filename, x, y)
    src = Cache.load_bitmap("Graphics/PhoneMenu/", filename)
    bitmap.stretch_blt(Rect.new(x, y, SimplePhoneChat::AVATAR_SIZE, SimplePhoneChat::AVATAR_SIZE),
      src, src.rect)
  end

  #--------------------------------------------------------------------------
  # Utility
  #--------------------------------------------------------------------------
  def draw_shadow_text(bitmap, x, y, w, h, text, align, size, bold, color)
    bitmap.font.size = size
    bitmap.font.bold = bold
    bitmap.font.outline = false
    bitmap.font.color = SimplePhoneChat::SHADOW_COLOR
    bitmap.draw_text(x + 1, y + 1, w, h, text, align)
    bitmap.font.color = color
    bitmap.draw_text(x, y, w, h, text, align)
  end

  def wrap_text(text, max_width)
    words = text.to_s.split(/\s+/)
    return [""] if words.empty?
    lines = []
    line = ""

    words.each do |word|
      test = line.empty? ? word : "#{line} #{word}"
      if text_width(test, SimplePhoneChat::TEXT_SIZE) <= max_width
        line = test
      else
        if line.empty?
          lines << word
          line = ""
        else
          lines << line
          line = word
        end
      end
    end
    lines << line unless line.empty?
    lines
  end

  def text_width(text, size)
    @measure_bitmap.font.size = size
    @measure_bitmap.font.bold = false
    @measure_bitmap.font.outline = false
    @measure_bitmap.text_size(text.to_s).width
  end

  def fit_rect(w, h, max_w, max_h)
    scale = [max_w.to_f / w, max_h.to_f / h, 1.0].min
    [(w * scale).to_i, (h * scale).to_i]
  end

  def draw_round_rect(bitmap, x, y, w, h, r, color)
    r = [r, w / 2, h / 2].min
    bitmap.fill_rect(x + r, y, w - r * 2, h, color)
    bitmap.fill_rect(x, y + r, w, h - r * 2, color)
    draw_circle(bitmap, x + r, y + r, r, color)
    draw_circle(bitmap, x + w - r - 1, y + r, r, color)
    draw_circle(bitmap, x + r, y + h - r - 1, r, color)
    draw_circle(bitmap, x + w - r - 1, y + h - r - 1, r, color)
  end

  def draw_circle(bitmap, cx, cy, r, color)
    (-r..r).each do |dy|
      dx = Math.sqrt(r * r - dy * dy).to_i
      bitmap.fill_rect(cx - dx, cy + dy, dx * 2 + 1, 1, color)
    end
  end

  #--------------------------------------------------------------------------
  # Dispose
  #--------------------------------------------------------------------------
  def dispose_chat
    @measure_bitmap.dispose if @measure_bitmap && !@measure_bitmap.disposed?

    if @dim
      @dim.bitmap.dispose if @dim.bitmap && !@dim.bitmap.disposed?
      @dim.dispose unless @dim.disposed?
    end
    if @phone_bg
      @phone_bg.bitmap.dispose if @phone_bg.bitmap && !@phone_bg.bitmap.disposed?
      @phone_bg.dispose unless @phone_bg.disposed?
    end
    if @message_layer
      @message_layer.bitmap.dispose if @message_layer.bitmap && !@message_layer.bitmap.disposed?
      @message_layer.dispose unless @message_layer.disposed?
    end
    if @header_layer
      @header_layer.bitmap.dispose if @header_layer.bitmap && !@header_layer.bitmap.disposed?
      @header_layer.dispose unless @header_layer.disposed?
    end
    if @footer_layer
      @footer_layer.bitmap.dispose if @footer_layer.bitmap && !@footer_layer.bitmap.disposed?
      @footer_layer.dispose unless @footer_layer.disposed?
    end
    if @choice_layer
      @choice_layer.bitmap.dispose if @choice_layer.bitmap && !@choice_layer.bitmap.disposed?
      @choice_layer.dispose unless @choice_layer.disposed?
    end
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
    chat.add_branch_text(1, :quy, "Là Leo!", :right)
    chat.add_branch_text(1, :leo, "Hả? Là tui á? Bà chắc chưa á?")
    chat.add_branch_text(1, :quy, "Như đinh đóng cột! Mọi người tiếp tục vòng tặng nhé! Tớ sủi đây, hihi!", :right)
    chat.add_branch_text(2, :quy, "Là Kohi!!", :right)
    chat.add_branch_text(2, :shylvie, "Ui! Hóng quá!")
    chat.add_branch_text(2, :leo, "Bà chắc sẽ tặng Kohi chưa?")
    chat.add_branch_text(2, :quy, "Như đinh đóng cột! Mọi người tiếp tục vòng tặng nhé! Tớ sủi đây, hihi!", :right)
    chat.add_branch_text(3, :quy, "Là Shylvie", :right)
    chat.add_branch_text(3, :shylvie, "Ôi vinh dự thế!!")
    chat.add_branch_text(3, :quy, "Vậy là không muốn được tặng hả?", :right)
    chat.add_branch_text(3, :shylvie, "Ừ đúng rồi đó~ Không muốn được tặng đó")
    chat.add_branch_text(3, :quy, "Thì thôi~", :right)
    chat.add_branch_text(3, :leo, "Bà chắc sẽ tặng Shylvie chưa?")
    chat.add_branch_text(3, :quy, "Chắc chắn rồi. Mọi người tiếp tục vòng tặng nhé. Tớ đi đây.", :right)
    chat.add_branch_text(4, :quy, "Là Hakase!", :right)
    chat.add_branch_text(4, :hakase, "Yatta!! Vui quá!! Hóng quà à nghen!!")
    chat.add_branch_text(4, :leo, "Bà chắc sẽ tặng Hakase chưa?")
    chat.add_branch_text(4, :quy, "Chắc chắn rồi. Mọi người tiếp tục vòng tặng nhé. Tớ đi đây.", :right)
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
