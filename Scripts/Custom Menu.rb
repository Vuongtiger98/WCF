#########################################################################
# Custom_PhoneMenu + Phone Gallery
# Replaces old phone background selection with Mog-style picture gallery
#
# Put this BELOW Mog Picture Gallery
#
# Required:
#   In MOG_PICTURE_GALLERY script set:
#   PICTURE_GALLERY_MENU_COMMAND = false
#
# Notes:
# - The old phone background changing system is removed.
# - The old :backgrounds menu slot is now a custom :gallery screen.
# - Gallery unlocks use Mog's $game_system.gallery[id]
# - Locked thumbnail uses Graphics/Gallery/0
#########################################################################

module PhoneMenu
  BACKGROUND = "PhoneBackground"
  MESSAGE_BACKGROUND = "MessageBackground"

  ICON_ITEMS = "ItemsIcon"
  ICON_SAVE = "SaveIcon"
  ICON_LOAD = "LoadIcon"
  ICON_SETTINGS = "SettingsIcon"
  ICON_CONTACTS = "ContactsIcon"
  ICON_GALLERY = "BackgroundsIcon"   # reuse your old icon file
  ICON_CONTACT_PREFIX = "Contact_"
  ICON_MAIN_CHARACTER = "MainCharacterIcon"

  SELECT_SE = "Decision1"

  # Match the 350x480 phone artwork without stretching its proportions.
  PHONE_WIDTH = 336
  PHONE_HEIGHT = 460
  PHONE_X = (Graphics.width - PHONE_WIDTH) / 2
  PHONE_Y = (Graphics.height - PHONE_HEIGHT) / 2

  BLACK_RECT_WIDTH = PHONE_WIDTH - 24
  BLACK_RECT_HEIGHT = PHONE_HEIGHT - 32
  BLACK_RECT_X = PHONE_X + (PHONE_WIDTH - BLACK_RECT_WIDTH) / 2
  BLACK_RECT_Y = PHONE_Y + (PHONE_HEIGHT - BLACK_RECT_HEIGHT) / 2

  ICON_WIDTH = 64
  ICON_HEIGHT = 64
  ICON_SPACING_X = 32
  ICON_SPACING_Y = 28
  ICON_START_X = PHONE_X + 72
  ICON_START_Y = PHONE_Y + 270
  ICON_DISPLAY_SIZE = 50
  ICON_SCALE = 1.06
  ICON_IDLE_OPACITY = 235
  APP_CARD_W = 84
  APP_CARD_H = 84
  APP_LABELS = ["Túi đồ", "Lưu game", "Tải game", "Cài đặt", "Tin nhắn", "Thư viện"]
  UI_FONT = ["Segoe UI", "Arial"]
  UI_WORDS = {
    "Cloudy"=>"Nhiều mây", "Clear"=>"Trời quang", "Indoors"=>"Trong nhà", "Snowy"=>"Tuyết rơi",
    "Calendar"=>"Lịch", "Status"=>"Pin", "Battery"=>"còn lại", "December"=>"Tháng 12",
    "Christmas"=>"Giáng sinh", "Home"=>"Ở nhà", "Old Book Shop"=>"Tiệm sách cũ",
    "Christmas Party"=>"Tiệc Giáng sinh"
  }

  MAIN_OVERLAY_OPACITY = 172
  SUB_OVERLAY_OPACITY = 218
  MESSAGE_OVERLAY_OPACITY = 224
  GALLERY_OVERLAY_OPACITY = 218

  CONTACT_ICON_X = PHONE_X + 36
  CONTACT_ICON_Y = PHONE_Y + 104
  CONTACT_SPACING = 94
  CONTACT_NAME_X_OFFSET = 56
  CONTACT_NAME_Y_OFFSET = 4
  CONTACT_INFO_X = PHONE_X
  CONTACT_INFO_Y = PHONE_Y
  MAX_CONTACTS_DISPLAYED = 3

  # Message layout
  CONTACT_MESSAGE_Y = PHONE_Y + 96
  MESSAGE_BOTTOM_LIMIT = PHONE_Y + PHONE_HEIGHT - 46
  MESSAGE_SPACING = 10
  MESSAGE_LINE_SPACING = 22
  MESSAGE_ICON_SIZE = 28
  MESSAGE_MAX_WIDTH = 218
  MESSAGE_MIN_WIDTH = 76
  MESSAGE_PADDING_X = 12
  MESSAGE_PADDING_Y = 10
  MESSAGE_LEFT_ICON_X = PHONE_X + 24
  MESSAGE_LEFT_BUBBLE_X = PHONE_X + 60
  MESSAGE_RIGHT_ICON_X = PHONE_X + PHONE_WIDTH - 24 - MESSAGE_ICON_SIZE
  MESSAGE_RIGHT_BUBBLE_RIGHT = MESSAGE_RIGHT_ICON_X - 8
  MAX_MESSAGE_CHARS_PER_LINE = 21

  # Gallery layout
  GALLERY_MAX_PICTURES = ($imported && $imported[:mog_picture_gallery]) ? MOG_PICTURE_GALLERY::MAX_PICTURES : 40
  GALLERY_COLUMNS = 2
  GALLERY_ROWS = 2
  GALLERY_PER_PAGE = GALLERY_COLUMNS * GALLERY_ROWS
  GALLERY_THUMB_W = 128
  GALLERY_THUMB_H = 84
  GALLERY_START_X = PHONE_X + 30
  GALLERY_START_Y = PHONE_Y + 100
  GALLERY_SPACING_X = 20
  GALLERY_SPACING_Y = 24
  GALLERY_LABEL_H = 36

  ANIMATION_DURATION = 20
  SLIDE_DURATION = 30
  FADE_DURATION = 30

  MENU_COMMANDS = [
    :item,
    :save,
    :load,
    :system,
    :contacts,
    :gallery
  ]

  CONTACTS = {
  }
end

#==============================================================================
# DataManager
#==============================================================================
module DataManager
  class << self
    alias phone_menu_init init
    alias phone_menu_create_game_objects create_game_objects
    alias phone_menu_make_save_contents make_save_contents
    alias phone_menu_extract_save_contents extract_save_contents
  end

  def self.init
    phone_menu_init
    $game_config = Game_Config.new
    $phone_menu_selected_index = 0
  end

  def self.create_game_objects
    phone_menu_create_game_objects
    $game_config = Game_Config.new
    $phone_menu_selected_index = 0
  end

  def self.make_save_contents
    contents = phone_menu_make_save_contents
    contents[:phone_config] = $game_config
    contents
  end

  def self.extract_save_contents(contents)
    phone_menu_extract_save_contents(contents)
    $game_config = contents[:phone_config] || Game_Config.new
  end
end

#==============================================================================
# Game_Config
#==============================================================================
class Game_Config
  attr_accessor :phone_widget_weather_title
  attr_accessor :phone_widget_weather_time
  attr_accessor :phone_widget_weather_temp
  attr_accessor :phone_widget_weather_sub
  attr_accessor :phone_widget_small_left_title
  attr_accessor :phone_widget_small_left_big
  attr_accessor :phone_widget_small_left_sub
  attr_accessor :phone_widget_small_right_title
  attr_accessor :phone_widget_small_right_big
  attr_accessor :phone_widget_small_right_sub
  attr_accessor :phone_timeline_stage

  def initialize
    reset_phone_widgets
  end

  def reset_phone_widgets
    @phone_widget_weather_title = "Cloudy"
    @phone_widget_weather_time  = "21 Dec • 08:45"
    @phone_widget_weather_temp  = "23°"
    @phone_widget_weather_sub   = "Wind 12 km/h"
    @phone_widget_small_left_title = "Calendar"
    @phone_widget_small_left_big   = "21"
    @phone_widget_small_left_sub   = "December"
    @phone_widget_small_right_title = "Status"
    @phone_widget_small_right_big   = "87%"
    @phone_widget_small_right_sub   = "Battery"
    @phone_timeline_stage = :prologue
  end

  def set_phone_weather(title, time_text, temp_text, sub_text)
    @phone_widget_weather_title = title.to_s
    @phone_widget_weather_time  = time_text.to_s
    @phone_widget_weather_temp  = temp_text.to_s
    @phone_widget_weather_sub   = sub_text.to_s
  end

  def set_phone_left_widget(title, big_text, sub_text)
    @phone_widget_small_left_title = title.to_s
    @phone_widget_small_left_big   = big_text.to_s
    @phone_widget_small_left_sub   = sub_text.to_s
  end

  def set_phone_right_widget(title, big_text, sub_text)
    @phone_widget_small_right_title = title.to_s
    @phone_widget_small_right_big   = big_text.to_s
    @phone_widget_small_right_sub   = sub_text.to_s
  end

  def add_message(contact_id, message, sender = :contact)
    return unless PhoneMenu::CONTACTS[contact_id]
    PhoneMenu::CONTACTS[contact_id][2] << [sender, message]
  end

  def add_messages(contact_id, messages)
    return unless PhoneMenu::CONTACTS[contact_id]
    messages.each do |message, sender|
      PhoneMenu::CONTACTS[contact_id][2] << [sender, message]
    end
  end
end

#==============================================================================
# Script Call Helpers
#==============================================================================
module PhoneMenuScript
  def self.set_weather(title, time_text, temp_text, sub_text)
    return unless $game_config
    $game_config.set_phone_weather(title, time_text, temp_text, sub_text)
  end

  def self.set_left_widget(title, big_text, sub_text)
    return unless $game_config
    $game_config.set_phone_left_widget(title, big_text, sub_text)
  end

  def self.set_right_widget(title, big_text, sub_text)
    return unless $game_config
    $game_config.set_phone_right_widget(title, big_text, sub_text)
  end

  def self.reset_widgets
    return unless $game_config
    $game_config.reset_phone_widgets
  end

  def self.advance_timeline(stage)
    PhoneTimeline.advance(stage)
  end

  def self.force_timeline(stage)
    PhoneTimeline.apply(stage, true)
  end
end

#==============================================================================
# Phone Timeline
#------------------------------------------------------------------------------
# Story-controlled clock. Presets only move forward, so revisiting an older map
# cannot rewind the phone date/time or restore battery accidentally.
#==============================================================================
module PhoneTimeline
  ORDER = [
    :prologue, :city, :bus, :atlantis_gate, :home, :book_shop,
    :christmas_gift
  ]

  PRESETS = {
    :prologue => {
      :weather => ["Cloudy", "21 Dec • 08:45", "23°", "Wind 12 km/h"],
      :calendar => ["Calendar", "21", "December"],
      :battery => ["Status", "87%", "Battery"]
    },
    :city => {
      :weather => ["Cloudy", "21 Dec • 17:35", "21°", "Wind 15 km/h"],
      :calendar => ["Calendar", "21", "December"],
      :battery => ["Status", "54%", "Battery"]
    },
    :bus => {
      :weather => ["Cloudy", "21 Dec • 18:05", "20°", "Wind 14 km/h"],
      :calendar => ["Calendar", "21", "December"],
      :battery => ["Status", "48%", "Battery"]
    },
    :atlantis_gate => {
      :weather => ["Clear", "21 Dec • 19:00", "18°", "Atlantis"],
      :calendar => ["Calendar", "21", "December"],
      :battery => ["Status", "43%", "Battery"]
    },
    :home => {
      :weather => ["Indoors", "21 Dec • 19:20", "22°", "Home"],
      :calendar => ["Calendar", "21", "December"],
      :battery => ["Status", "38%", "Battery"]
    },
    :book_shop => {
      :weather => ["Indoors", "21 Dec • 20:10", "18°", "Old Book Shop"],
      :calendar => ["Calendar", "21", "December"],
      :battery => ["Status", "31%", "Battery"]
    },
    :christmas_gift => {
      :weather => ["Snowy", "25 Dec • 19:00", "17°", "Christmas Party"],
      :calendar => ["Calendar", "25", "Christmas"],
      :battery => ["Status", "76%", "Battery"]
    }
  }

  def self.advance(stage)
    apply(stage, false)
  end

  def self.apply(stage, force = false)
    return false unless $game_config
    key = stage.to_sym
    data = PRESETS[key]
    return false unless data
    current = $game_config.phone_timeline_stage
    current_index = ORDER.index(current && current.to_sym) || -1
    target_index = ORDER.index(key)
    return false unless target_index
    return false if !force && target_index < current_index
    $game_config.set_phone_weather(*data[:weather])
    $game_config.set_phone_left_widget(*data[:calendar])
    $game_config.set_phone_right_widget(*data[:battery])
    $game_config.phone_timeline_stage = key
    true
  end
end

#==============================================================================
# Scene_Menu
#==============================================================================
class Scene_Menu < Scene_MenuBase
  alias phone_menu_return_scene return_scene

  def start
    @phone_menu_disposed = false
    # SceneManager.return restarts the same menu instance after an app. Keep
    # this on that instance: a later New Game / new menu must still slide in.
    @phone_resume_from_app = @phone_app_suspended == true
    @phone_app_suspended = false
    super
    @animation_frame = 0
    @selected_index = $phone_menu_selected_index || 0
    @contacts_screen = false
    @gallery_screen = false
    @selected_contact = 0
    @contact_index = 0
    @message_index = 0
    @in_message_view = false

    @gallery_page = 0
    @gallery_index = 0
    @gallery_full_view = false
    @gallery_full_picture_id = 0

    @animation_state = :opening
    @animation_timer = 0

    create_overlay
    create_black_rectangle
    create_foreground
    create_main_panel
    create_command_window

    hide_menu_sprites
    @background_sprite.y = PhoneMenu::PHONE_Y
    @phone_slide_offset = 0
    phone_apply_slide_offset(Graphics.height - PhoneMenu::PHONE_Y) unless @phone_resume_from_app
  end

  def terminate
    super
    dispose_phone_menu_sprites
  end

  #--------------------------------------------------------------------------
  # Background
  #--------------------------------------------------------------------------
  def create_background
    @phone_backdrop = Sprite.new
    source = SceneManager.background_bitmap
    @phone_backdrop.bitmap = source ? source.clone : Bitmap.new(Graphics.width, Graphics.height)
    @phone_backdrop.color.set(8, 12, 24, 190)
    @phone_backdrop.z = 10
    @background_sprite = Sprite.new
    @background_sprite.x = PhoneMenu::PHONE_X
    @background_sprite.y = Graphics.height
    @background_sprite.z = 50
    @background_sprite.visible = false
    refresh_phone_background(PhoneMenu::BACKGROUND)
  end

  def refresh_phone_background(filename)
    @background_sprite.bitmap.dispose if @background_sprite.bitmap && !@background_sprite.bitmap.disposed?
    bitmap = Cache.load_bitmap("Graphics/PhoneMenu/", filename)
    @background_sprite.bitmap = Bitmap.new(PhoneMenu::PHONE_WIDTH, PhoneMenu::PHONE_HEIGHT)
    @background_sprite.bitmap.stretch_blt(@background_sprite.bitmap.rect, bitmap, bitmap.rect)
  end

  def restore_current_background
    refresh_phone_background(PhoneMenu::BACKGROUND)
  end

  #--------------------------------------------------------------------------
  # Overlay
  #--------------------------------------------------------------------------
  def create_overlay
    @overlay = Sprite.new
    @overlay.bitmap = Bitmap.new(PhoneMenu::PHONE_WIDTH, PhoneMenu::PHONE_HEIGHT)
    @overlay.x = PhoneMenu::PHONE_X
    @overlay.y = PhoneMenu::PHONE_Y
    @overlay.z = 70
    set_overlay_opacity(PhoneMenu::MAIN_OVERLAY_OPACITY)
  end

  def set_overlay_opacity(value)
    return unless @overlay && @overlay.bitmap
    @overlay.bitmap.clear
    fill_round_rect(@overlay.bitmap, 12, 16, PhoneMenu::PHONE_WIDTH - 24,
      PhoneMenu::PHONE_HEIGHT - 32, 18, Color.new(9, 14, 28, value))
  end

  #--------------------------------------------------------------------------
  # Black rectangle
  #--------------------------------------------------------------------------
  def create_black_rectangle
    @black_rectangle = Sprite.new
    @black_rectangle.bitmap = Bitmap.new(PhoneMenu::BLACK_RECT_WIDTH, PhoneMenu::BLACK_RECT_HEIGHT)
    @black_rectangle.bitmap.fill_rect(0, 0, PhoneMenu::BLACK_RECT_WIDTH, PhoneMenu::BLACK_RECT_HEIGHT, Color.new(0, 0, 0))
    @black_rectangle.x = PhoneMenu::BLACK_RECT_X
    @black_rectangle.y = PhoneMenu::BLACK_RECT_Y
    @black_rectangle.z = 300
    @black_rectangle.opacity = 0
    @black_rectangle.visible = false
  end

  #--------------------------------------------------------------------------
  # Helpers
  #--------------------------------------------------------------------------
  def dispose_sprite_array(array)
    return unless array
    array.each do |s|
      next unless s
      s.bitmap.dispose if s.bitmap && !s.bitmap.disposed?
      s.dispose unless s.disposed?
    end
  end

  def create_text_bitmap(width, height, size, color)
    bmp = Bitmap.new(width, height)
    bmp.font.size = size
    bmp.font.color = color
    bmp.font.outline = false
    bmp
  end

  def simple_text_width(text, size = 20)
    # A menu measures many lines while scrolling. Reuse the measuring surface.
    if !@phone_measure_bitmap || @phone_measure_bitmap.disposed?
      @phone_measure_bitmap = Bitmap.new(1, 1)
    end
    temp = @phone_measure_bitmap
    temp.font.name = PhoneMenu::UI_FONT
    temp.font.bold = false
    temp.font.size = size
    temp.font.outline = false
    w = temp.text_size(text.to_s).width
    w
  end

  def fill_round_rect(bitmap, x, y, width, height, radius, color)
    return if width <= 0 || height <= 0
    radius = [radius, width / 2, height / 2].min
    bitmap.fill_rect(x + radius, y, width - radius * 2, height, color)
    bitmap.fill_rect(x, y + radius, width, height - radius * 2, color)
    draw_filled_circle(bitmap, x + radius, y + radius, radius, color)
    draw_filled_circle(bitmap, x + width - radius - 1, y + radius, radius, color)
    draw_filled_circle(bitmap, x + radius, y + height - radius - 1, radius, color)
    draw_filled_circle(bitmap, x + width - radius - 1, y + height - radius - 1, radius, color)
  end

  def draw_filled_circle(bitmap, cx, cy, radius, color)
    (-radius..radius).each do |dy|
      dx = Math.sqrt(radius * radius - dy * dy).to_i
      bitmap.fill_rect(cx - dx, cy + dy, dx * 2 + 1, 1, color)
    end
  end

  def make_round_rect_bitmap(width, height, radius, color)
    bmp = Bitmap.new(width, height)
    fill_round_rect(bmp, 0, 0, width, height, radius, color)
    bmp
  end

  def make_circle_highlight(size)
    bmp = Bitmap.new(size, size)
    center = size / 2
    radius = center - 2
    (0...size).each do |x|
      (0...size).each do |y|
        dx = x - center
        dy = y - center
        dist = Math.sqrt(dx * dx + dy * dy)
        next unless dist <= radius
        alpha = [[(radius - dist) * 7, 0].max, 110].min
        bmp.set_pixel(x, y, Color.new(255, 255, 255, alpha))
      end
    end
    bmp
  end

  def phone_text(bitmap, x, y, width, height, text, size = 16, color = nil, align = 0, bold = false)
    bitmap.font.name = PhoneMenu::UI_FONT
    bitmap.font.size = size
    bitmap.font.bold = bold
    bitmap.font.italic = false
    bitmap.font.shadow = false
    bitmap.font.outline = false
    bitmap.font.color = color || Color.new(245, 246, 255)
    value = text.to_s
    if bitmap.text_size(value).width > width
      clusters = value.scan(/\P{M}\p{M}*/)
      clusters.pop while !clusters.empty? && bitmap.text_size(clusters.join + "…").width > width
      value = clusters.join + "…"
    end
    bitmap.draw_text(x, y, width, height, value, align)
  end

  def phone_widget_label(value)
    text = value.to_s
    return PhoneMenu::UI_WORDS[text] if PhoneMenu::UI_WORDS.has_key?(text)
    text = text.sub(/\A(\d+) Dec\b/, '\\1/12')
    text.sub(/\AWind (\d+) km\/h\z/, 'Gió \\1 km/h')
  end

  def phone_card(bitmap, x, y, width, height, selected = false)
    edge = selected ? Color.new(174, 186, 255, 235) : Color.new(119, 140, 181, 65)
    fill_round_rect(bitmap, x, y, width, height, 12, edge)
    fill_round_rect(bitmap, x + 1, y + 1, width - 2, height - 2, 11,
      selected ? Color.new(53, 66, 111, 240) : Color.new(18, 28, 47, 220))
  end

  def phone_footer(bitmap, text)
    bitmap.fill_rect(28, PhoneMenu::PHONE_HEIGHT - 42, PhoneMenu::PHONE_WIDTH - 56, 1,
      Color.new(183, 198, 231, 44))
    phone_text(bitmap, 24, PhoneMenu::PHONE_HEIGHT - 35, PhoneMenu::PHONE_WIDTH - 48, 18,
      text, 12, Color.new(202, 212, 235), 1)
  end

  def phone_fit_bitmap(target, source, available_height = nil, upscale = true)
    target.clear
    target.fill_rect(target.rect, Color.new(10, 16, 28))
    available_height ||= target.height
    scale = [target.width.to_f / source.width, available_height.to_f / source.height].min
    scale = [scale, 1.0].min unless upscale
    width = [(source.width * scale).round, 1].max
    height = [(source.height * scale).round, 1].max
    rect = Rect.new((target.width - width) / 2, (available_height - height) / 2, width, height)
    target.stretch_blt(rect, source, source.rect)
  end

  def phone_locked_thumbnail(bitmap)
    bitmap.fill_rect(bitmap.rect, Color.new(13, 21, 36))
    x, y = bitmap.width / 2, bitmap.height / 2
    fill_round_rect(bitmap, x - 11, y - 23, 22, 29, 10, Color.new(151, 170, 214))
    fill_round_rect(bitmap, x - 7, y - 19, 14, 22, 7, Color.new(13, 21, 36))
    fill_round_rect(bitmap, x - 18, y - 6, 36, 28, 6, Color.new(102, 124, 176))
    draw_filled_circle(bitmap, x, y + 5, 3, Color.new(17, 27, 46))
    bitmap.fill_rect(x - 1, y + 6, 3, 8, Color.new(17, 27, 46))
  end

  #--------------------------------------------------------------------------
  # Contact message helpers
  #--------------------------------------------------------------------------
  def message_bubble_info(sender, message, contact_id)
    is_main = sender == :main
    wrapped_lines = wrap_text(message, PhoneMenu::MAX_MESSAGE_CHARS_PER_LINE)

    longest = 0
    wrapped_lines.each do |line|
      w = simple_text_width(line, 20)
      longest = w if w > longest
    end

    bubble_width = [[longest + PhoneMenu::MESSAGE_PADDING_X * 2, PhoneMenu::MESSAGE_MIN_WIDTH].max,
                    PhoneMenu::MESSAGE_MAX_WIDTH].min
    bubble_height = wrapped_lines.size * PhoneMenu::MESSAGE_LINE_SPACING + PhoneMenu::MESSAGE_PADDING_Y * 2

    if is_main
      bubble_x = PhoneMenu::MESSAGE_RIGHT_BUBBLE_RIGHT - bubble_width
      icon_x = PhoneMenu::MESSAGE_RIGHT_ICON_X
    else
      icon_x = PhoneMenu::MESSAGE_LEFT_ICON_X
      bubble_x = PhoneMenu::MESSAGE_LEFT_BUBBLE_X
    end

    {
      :sender => sender,
      :message => message,
      :is_main => is_main,
      :wrapped_lines => wrapped_lines,
      :bubble_width => bubble_width,
      :bubble_height => bubble_height,
      :bubble_x => bubble_x,
      :icon_x => icon_x,
      :contact_id => contact_id
    }
  end

  def build_visible_message_infos(messages, contact_id, start_index)
    infos = []
    y_offset = 0
    index = start_index

    while index < messages.size
      sender, message = messages[index]
      info = message_bubble_info(sender, message, contact_id)
      next_bottom = PhoneMenu::CONTACT_MESSAGE_Y + y_offset + info[:bubble_height]
      break if next_bottom > PhoneMenu::MESSAGE_BOTTOM_LIMIT && !infos.empty?
      break if next_bottom > PhoneMenu::MESSAGE_BOTTOM_LIMIT
      info[:y] = PhoneMenu::CONTACT_MESSAGE_Y + y_offset
      infos << info
      y_offset += info[:bubble_height] + PhoneMenu::MESSAGE_SPACING
      index += 1
    end

    infos
  end

  #--------------------------------------------------------------------------
  # Main icons
  #--------------------------------------------------------------------------
  def create_foreground
    @icon_sprites = []
    @highlight_sprites = []
    # All six highlights have identical pixels; opacity belongs to each sprite.
    @phone_highlight_bitmap = Bitmap.new(PhoneMenu::APP_CARD_W, PhoneMenu::APP_CARD_H)
    fill_round_rect(@phone_highlight_bitmap, 0, 0, PhoneMenu::APP_CARD_W, PhoneMenu::APP_CARD_H,
      12, Color.new(179, 191, 255, 235))
    fill_round_rect(@phone_highlight_bitmap, 2, 2, PhoneMenu::APP_CARD_W - 4, PhoneMenu::APP_CARD_H - 4,
      10, Color.new(148, 162, 250, 30))

    PhoneMenu::MENU_COMMANDS.each_with_index do |sym, index|
      col = index % 3
      row = index / 3
      x = PhoneMenu::ICON_START_X + col * (PhoneMenu::ICON_WIDTH + PhoneMenu::ICON_SPACING_X)
      y = PhoneMenu::ICON_START_Y + row * (PhoneMenu::ICON_HEIGHT + PhoneMenu::ICON_SPACING_Y)

      highlight = Sprite.new
      highlight.bitmap = @phone_highlight_bitmap
      highlight.x = x - PhoneMenu::APP_CARD_W / 2
      highlight.y = y - 32
      highlight.z = 89
      highlight.opacity = 0
      highlight.visible = false
      @highlight_sprites << highlight

      sprite = Sprite.new
      sprite.bitmap = Cache.load_bitmap("Graphics/PhoneMenu/", icon_bitmap_name(sym)).clone
      sprite.ox = sprite.bitmap.width / 2
      sprite.oy = sprite.bitmap.height / 2
      sprite.x = x
      sprite.y = y
      sprite.zoom_x = sprite.zoom_y = PhoneMenu::ICON_DISPLAY_SIZE.to_f / sprite.bitmap.width
      sprite.z = 100
      sprite.opacity = PhoneMenu::ICON_IDLE_OPACITY
      sprite.visible = false
      @icon_sprites << sprite
    end
  end

  def icon_bitmap_name(symbol)
    case symbol
    when :item     then PhoneMenu::ICON_ITEMS
    when :save     then PhoneMenu::ICON_SAVE
    when :load     then PhoneMenu::ICON_LOAD
    when :system   then PhoneMenu::ICON_SETTINGS
    when :contacts then PhoneMenu::ICON_CONTACTS
    when :gallery  then PhoneMenu::ICON_GALLERY
    else ""
    end
  end

  #--------------------------------------------------------------------------
  # Main widget panel
  #--------------------------------------------------------------------------
  def create_main_panel
    @main_panel = Sprite.new
    @main_panel.bitmap = Bitmap.new(PhoneMenu::PHONE_WIDTH, PhoneMenu::PHONE_HEIGHT)
    @main_panel.x = PhoneMenu::PHONE_X
    @main_panel.y = PhoneMenu::PHONE_Y
    @main_panel.z = 85
    @main_panel.visible = false
    draw_main_panel
  end

  def draw_main_panel
    bmp = @main_panel.bitmap
    bmp.clear
    muted = Color.new(187, 201, 226)
    phone_text(bmp, 24, 26, 194, 28, "Điện thoại", 22, nil, 0, true)
    phone_text(bmp, 214, 30, 98, 20, "WANDERER", 11, Color.new(186, 193, 244), 2)

    phone_card(bmp, 24, 64, 288, 82)
    phone_text(bmp, 38, 74, 156, 24, phone_widget_label($game_config.phone_widget_weather_title), 17, nil, 0, true)
    phone_text(bmp, 38, 106, 166, 20, phone_widget_label($game_config.phone_widget_weather_time), 13, muted)
    phone_text(bmp, 212, 72, 84, 34, $game_config.phone_widget_weather_temp, 30, nil, 2, true)
    phone_text(bmp, 198, 112, 100, 18, phone_widget_label($game_config.phone_widget_weather_sub), 11, muted, 2)

    phone_card(bmp, 24, 156, 138, 58)
    phone_card(bmp, 174, 156, 138, 58)
    phone_text(bmp, 36, 162, 114, 18, phone_widget_label($game_config.phone_widget_small_left_title), 12, muted)
    phone_text(bmp, 36, 180, 40, 28, $game_config.phone_widget_small_left_big, 24, nil, 0, true)
    phone_text(bmp, 80, 188, 70, 18, phone_widget_label($game_config.phone_widget_small_left_sub), 12, muted)
    phone_text(bmp, 186, 162, 114, 18, phone_widget_label($game_config.phone_widget_small_right_title), 12, muted)
    phone_text(bmp, 186, 180, 62, 28, $game_config.phone_widget_small_right_big, 24, nil, 0, true)
    phone_text(bmp, 248, 188, 52, 18, phone_widget_label($game_config.phone_widget_small_right_sub), 12, muted, 2)

    phone_text(bmp, 28, 218, 280, 18, "ỨNG DỤNG", 11, muted)
    PhoneMenu::MENU_COMMANDS.each_with_index do |command, index|
      x = PhoneMenu::ICON_START_X - PhoneMenu::PHONE_X +
        (index % 3) * (PhoneMenu::ICON_WIDTH + PhoneMenu::ICON_SPACING_X)
      y = PhoneMenu::ICON_START_Y - PhoneMenu::PHONE_Y +
        (index / 3) * (PhoneMenu::ICON_HEIGHT + PhoneMenu::ICON_SPACING_Y)
      phone_card(bmp, x - PhoneMenu::APP_CARD_W / 2, y - 32,
        PhoneMenu::APP_CARD_W, PhoneMenu::APP_CARD_H)
      phone_text(bmp, x - 42, y + 27, 84, 20, PhoneMenu::APP_LABELS[index], 13, nil, 1)
    end
    phone_footer(bmp, "Mũi tên: chọn   Z: mở   X: đóng")
    @phone_panel_snapshot = phone_panel_values.map { |value| value.dup }
    @phone_panel_bitmap = bmp
  end

  def phone_panel_values
    config = $game_config
    values = [config.phone_widget_weather_title, config.phone_widget_weather_time,
     config.phone_widget_weather_temp, config.phone_widget_weather_sub,
     config.phone_widget_small_left_title, config.phone_widget_small_left_big,
     config.phone_widget_small_left_sub, config.phone_widget_small_right_title,
     config.phone_widget_small_right_big, config.phone_widget_small_right_sub]
    values.map { |value| value.to_s }
  end

  def refresh_main_panel
    return unless @main_panel && @main_panel.bitmap
    return if @phone_panel_bitmap.equal?(@main_panel.bitmap) &&
      @phone_panel_snapshot == phone_panel_values
    draw_main_panel
  end

  #--------------------------------------------------------------------------
  # Window command
  #--------------------------------------------------------------------------
  def create_command_window
    @command_window = Window_PhoneMenu.new
    @command_window.set_handler(:item, method(:command_item))
    @command_window.set_handler(:save, method(:command_save))
    @command_window.set_handler(:load, method(:command_load))
    @command_window.set_handler(:system, method(:command_system))
    @command_window.set_handler(:contacts, method(:command_contacts))
    @command_window.set_handler(:gallery, method(:command_gallery))
    @command_window.set_handler(:cancel, method(:start_closing))
    @command_window.deactivate
  end

  #--------------------------------------------------------------------------
  # Update
  #--------------------------------------------------------------------------
  def update
    super
    refresh_main_panel unless @contacts_screen || @gallery_screen
    if @animation_state == :opening
      update_opening_animation
    elsif @animation_state == :closing
      update_closing_animation
    elsif @contacts_screen
      update_contacts_screen
    elsif @gallery_screen
      update_gallery_screen
    else
      update_main_menu
    end
    @animation_frame += 1
  end

  def update_opening_animation
    @animation_timer += 1

    progress = [@animation_timer.to_f / PhoneMenu::SLIDE_DURATION, 1.0].min
    eased = 1.0 - (1.0 - progress) ** 3
    phone_apply_slide_offset((Graphics.height - PhoneMenu::PHONE_Y) * (1.0 - eased))

    if progress >= 1.0
      phone_apply_slide_offset(0)
      @black_rectangle.opacity = 0
      @black_rectangle.visible = false
      if @contacts_screen
        show_contacts_sprites
      elsif @gallery_screen
        show_gallery_sprites
      else
        show_menu_sprites
      end
      @animation_state = :idle
      @animation_timer = 0
    end
  end

  def update_closing_animation
    @animation_timer += 1
    progress = [@animation_timer.to_f / PhoneMenu::SLIDE_DURATION, 1.0].min
    eased = progress ** 3
    phone_apply_slide_offset((Graphics.height - PhoneMenu::PHONE_Y) * eased)

    if progress >= 1.0
      @black_rectangle.visible = false
      dispose_phone_menu_sprites
      phone_menu_return_scene
    end
  end

  # Move every visible part of the phone as one unit. New gallery/contact/group
  # sprites are picked up automatically, so patches cannot leave pieces behind.
  def phone_apply_slide_offset(offset)
    offset = offset.round
    previous = @phone_slide_offset || 0
    delta = offset - previous
    return if delta == 0
    phone_visual_sprites.each { |sprite| sprite.y += delta }
    @phone_slide_offset = offset
  end

  def phone_visual_sprites
    sprites = []
    instance_variables.each do |name|
      next if name == :@black_rectangle || name == :@phone_backdrop
      phone_collect_sprites(instance_variable_get(name), sprites)
    end
    sprites.uniq
  end

  def phone_collect_sprites(value, output)
    if value.is_a?(Sprite)
      output << value unless value.disposed?
    elsif value.is_a?(Array)
      value.each { |item| phone_collect_sprites(item, output) }
    elsif value.is_a?(Hash)
      value.each_value { |item| phone_collect_sprites(item, output) }
    end
  end

  def start_closing
    Sound.play_cancel
    $phone_menu_selected_index = @selected_index
    @animation_state = :closing
    @animation_timer = 0
  end

  #--------------------------------------------------------------------------
  # Main menu
  #--------------------------------------------------------------------------
  def update_main_menu
    update_icon_animation
    update_input
  end

  def update_icon_animation
    @icon_sprites.each_with_index do |sprite, index|
      selected = index == @selected_index
      progress = (@animation_frame % PhoneMenu::ANIMATION_DURATION).to_f / PhoneMenu::ANIMATION_DURATION
      pulse = selected ? 1.0 + (PhoneMenu::ICON_SCALE - 1.0) * Math.sin(progress * Math::PI) : 1.0
      scale = PhoneMenu::ICON_DISPLAY_SIZE.to_f / [sprite.bitmap.width, sprite.bitmap.height].max
      sprite.zoom_x = sprite.zoom_y = scale * pulse
      sprite.opacity = selected ? 255 : PhoneMenu::ICON_IDLE_OPACITY
      @highlight_sprites[index].opacity = selected ? 255 : 0
    end
  end

  def update_input
    if Input.repeat?(:LEFT)
      @selected_index = (@selected_index - 1) % PhoneMenu::MENU_COMMANDS.size
      $phone_menu_selected_index = @selected_index
      RPG::SE.new(PhoneMenu::SELECT_SE).play
    elsif Input.repeat?(:RIGHT)
      @selected_index = (@selected_index + 1) % PhoneMenu::MENU_COMMANDS.size
      $phone_menu_selected_index = @selected_index
      RPG::SE.new(PhoneMenu::SELECT_SE).play
    elsif Input.repeat?(:UP)
      @selected_index = (@selected_index - 3) % PhoneMenu::MENU_COMMANDS.size
      $phone_menu_selected_index = @selected_index
      RPG::SE.new(PhoneMenu::SELECT_SE).play
    elsif Input.repeat?(:DOWN)
      @selected_index = (@selected_index + 3) % PhoneMenu::MENU_COMMANDS.size
      $phone_menu_selected_index = @selected_index
      RPG::SE.new(PhoneMenu::SELECT_SE).play
    elsif Input.trigger?(:C)
      @command_window.select_symbol(PhoneMenu::MENU_COMMANDS[@selected_index])
      @command_window.process_ok
    elsif Input.trigger?(:B)
      start_closing
    end
  end

  def show_menu_sprites
    @main_panel.visible = true if @main_panel
    @icon_sprites.each { |s| s.visible = true } if @icon_sprites
    @highlight_sprites.each { |s| s.visible = true } if @highlight_sprites
  end

  def hide_menu_sprites
    @main_panel.visible = false if @main_panel
    @icon_sprites.each { |s| s.visible = false } if @icon_sprites
    @highlight_sprites.each { |s| s.visible = false } if @highlight_sprites
  end

  def hide_phone_base_sprites
    @background_sprite.visible = false if @background_sprite
    @overlay.visible = false if @overlay
    @main_panel.visible = false if @main_panel
    @black_rectangle.visible = false if @black_rectangle
    hide_menu_sprites
    hide_contacts_sprites if @contacts_screen
    hide_gallery_sprites if @gallery_screen
  end

  #--------------------------------------------------------------------------
  # Commands
  #--------------------------------------------------------------------------
  def leave_phone_scene(scene_class)
    $phone_menu_selected_index = @selected_index
    @phone_app_suspended = true
    # Scene_Base#terminate freezes the last visible frame before cleanup.
    # Destroying the phone here makes that transition start from an empty frame.
    # Let our existing terminate hook dispose the scene after the freeze.
    SceneManager.call(scene_class)
    child = SceneManager.scene
    child.wcf_phone_origin = :phone if child.respond_to?(:wcf_phone_origin=)
  end

  def command_item
    leave_phone_scene(Scene_Item)
  end

  def command_save
    leave_phone_scene(Scene_Save)
  end

  def command_load
    leave_phone_scene(Scene_Load)
  end

  def command_system
    leave_phone_scene(Scene_System)
  end

  def command_contacts
    $phone_menu_selected_index = @selected_index
    hide_menu_sprites
    open_contacts_screen
  end

  def command_gallery
    $phone_menu_selected_index = @selected_index
    hide_menu_sprites
    open_gallery_screen
  end

  #--------------------------------------------------------------------------
  # Post start
  #--------------------------------------------------------------------------
  def post_start
    @selected_index = $phone_menu_selected_index || 0
    @animation_state = @phone_resume_from_app ? :idle : :opening
    @animation_timer = 0
    phone_apply_slide_offset(@phone_resume_from_app ? 0 : Graphics.height - PhoneMenu::PHONE_Y)
    @background_sprite.visible = true
    @overlay.visible = true
    @black_rectangle.opacity = 0
    @black_rectangle.visible = false
    show_menu_sprites
    update_icon_animation
    super
  end

  #--------------------------------------------------------------------------
  # Contacts
  #--------------------------------------------------------------------------
  def open_contacts_screen
    @contacts_screen = true
    @gallery_screen = false
    @selected_contact = 0
    @contact_index = 0
    @message_index = 0
    @in_message_view = false
    set_overlay_opacity(PhoneMenu::SUB_OVERLAY_OPACITY)
    create_contacts_sprites
    refresh_contacts
    @animation_state = :idle
    @animation_timer = 0
    @background_sprite.y = PhoneMenu::PHONE_Y
    @overlay.y = PhoneMenu::PHONE_Y
    @background_sprite.visible = true
    @overlay.visible = true
    @black_rectangle.opacity = 0
    @black_rectangle.visible = false
    show_contacts_sprites
  end

  def update_contacts_screen
    return unless @animation_state == :idle
    if @in_message_view
      update_message_view
    else
      update_contact_selection
    end
  end

  def update_contact_selection
    max_index = [0, PhoneMenu::CONTACTS.size - PhoneMenu::MAX_CONTACTS_DISPLAYED].max
    if Input.repeat?(:UP)
      if @selected_contact > 0
        @selected_contact -= 1
      elsif @contact_index > 0
        @contact_index -= 1
        @selected_contact = 0
      end
      RPG::SE.new(PhoneMenu::SELECT_SE).play
      refresh_contacts
    elsif Input.repeat?(:DOWN)
      if @selected_contact < PhoneMenu::MAX_CONTACTS_DISPLAYED - 1 &&
         @selected_contact + @contact_index < PhoneMenu::CONTACTS.size - 1
        @selected_contact += 1
      elsif @contact_index < max_index
        @contact_index += 1
        @selected_contact = [PhoneMenu::MAX_CONTACTS_DISPLAYED - 1,
                             PhoneMenu::CONTACTS.size - @contact_index - 1].min
      end
      RPG::SE.new(PhoneMenu::SELECT_SE).play
      refresh_contacts
    elsif Input.trigger?(:C)
      return if PhoneMenu::CONTACTS.empty?
      @in_message_view = true
      show_contact_details
    elsif Input.trigger?(:B)
      close_contacts_screen
    end
  end

  def update_message_view
    return if PhoneMenu::CONTACTS.empty?
    data = PhoneMenu::CONTACTS[PhoneMenu::CONTACTS.keys[@selected_contact + @contact_index]]
    messages = data[2]
    last_start_index = [messages.size - 1, 0].max

    if Input.repeat?(:UP) && @message_index > 0
      @message_index -= 1
      RPG::SE.new(PhoneMenu::SELECT_SE).play
      show_contact_details
    elsif Input.repeat?(:DOWN)
      next_index = @message_index + 1
      if next_index <= last_start_index
        test_infos = build_visible_message_infos(messages, PhoneMenu::CONTACTS.keys[@selected_contact + @contact_index], next_index)
        if !test_infos.empty?
          @message_index = next_index
          RPG::SE.new(PhoneMenu::SELECT_SE).play
          show_contact_details
        end
      end
    elsif Input.trigger?(:B)
      @in_message_view = false
      @message_index = 0
      set_overlay_opacity(PhoneMenu::SUB_OVERLAY_OPACITY)
      restore_current_background
      refresh_contacts
      show_contacts_sprites
    end
  end

  def wrap_text(text, max_chars)
    words = text.to_s.split(" ")
    lines = []
    current_line = ""

    words.each do |word|
      if current_line.empty?
        if word.length > max_chars
          while word.length > max_chars
            lines << word[0...max_chars]
            word = word[max_chars..-1]
          end
          current_line = word
        else
          current_line = word
        end
      elsif (current_line.length + word.length + 1) <= max_chars
        current_line += " " + word
      else
        lines << current_line
        if word.length > max_chars
          while word.length > max_chars
            lines << word[0...max_chars]
            word = word[max_chars..-1]
          end
          current_line = word
        else
          current_line = word
        end
      end
    end

    lines << current_line unless current_line.empty?
    lines = [""] if lines.empty?
    lines
  end

  def create_contacts_sprites
    dispose_sprite_array(@contact_sprites)
    dispose_sprite_array(@contact_names)
    dispose_sprite_array(@contact_panels)
    dispose_sprite_array(@contact_messages)

    if @contact_info
      @contact_info.bitmap.dispose if @contact_info.bitmap && !@contact_info.bitmap.disposed?
      @contact_info.dispose unless @contact_info.disposed?
    end

    @contact_sprites = []
    @contact_names = []
    @contact_panels = []
    @contact_messages = []

    @contact_info = Sprite.new
    @contact_info.bitmap = Bitmap.new(PhoneMenu::PHONE_WIDTH, PhoneMenu::PHONE_HEIGHT)
    @contact_info.x = PhoneMenu::PHONE_X
    @contact_info.y = PhoneMenu::PHONE_Y
    @contact_info.z = 150
    @contact_info.visible = false

    start_index = [@contact_index, 0].max
    end_index = [start_index + PhoneMenu::MAX_CONTACTS_DISPLAYED - 1, PhoneMenu::CONTACTS.size - 1].min
    contacts = PhoneMenu::CONTACTS.to_a[start_index..end_index] || []

    contacts.each_with_index do |(id, data), index|
      panel = Sprite.new
      panel.bitmap = make_round_rect_bitmap(282, 64, 12, Color.new(0, 0, 0, 86))
      panel.x = PhoneMenu::PHONE_X + 24
      panel.y = PhoneMenu::CONTACT_ICON_Y + index * PhoneMenu::CONTACT_SPACING - 4
      panel.z = 96
      panel.visible = false
      @contact_panels << panel

      sprite = Sprite.new
      sprite.bitmap = Cache.load_bitmap("Graphics/PhoneMenu/", "#{PhoneMenu::ICON_CONTACT_PREFIX}#{id}")
      sprite.x = PhoneMenu::CONTACT_ICON_X
      sprite.y = PhoneMenu::CONTACT_ICON_Y + index * PhoneMenu::CONTACT_SPACING
      sprite.z = 100
      sprite.visible = false
      @contact_sprites << sprite

      name_sprite = Sprite.new
      name_sprite.bitmap = create_text_bitmap(220, 32, 24, Color.new(255, 255, 255))
      name_sprite.bitmap.font.bold = true
      name_sprite.bitmap.draw_text(0, 0, 220, 32, data[0])
      name_sprite.x = PhoneMenu::CONTACT_ICON_X + PhoneMenu::CONTACT_NAME_X_OFFSET
      name_sprite.y = sprite.y + PhoneMenu::CONTACT_NAME_Y_OFFSET
      name_sprite.z = 101
      name_sprite.visible = false
      @contact_names << name_sprite
    end
  end

  def refresh_contacts
    restore_current_background
    set_overlay_opacity(PhoneMenu::SUB_OVERLAY_OPACITY)
    create_contacts_sprites

    @contact_info.bitmap.clear
    draw_contacts_header

    if @selected_contact && !@in_message_view && !PhoneMenu::CONTACTS.empty?
      data = PhoneMenu::CONTACTS[PhoneMenu::CONTACTS.keys[@selected_contact + @contact_index]]
      @contact_info.bitmap.font.size = 18
      @contact_info.bitmap.font.color = Color.new(242, 242, 242)
      @contact_info.bitmap.font.outline = false
      @contact_info.bitmap.draw_text(18, 56, PhoneMenu::PHONE_WIDTH - 36, 24,
        "Information: #{data[1]}")
    end

    @contact_panels.each_with_index do |sprite, index|
      sprite.bitmap.dispose if sprite.bitmap && !sprite.bitmap.disposed?
      color = (index == @selected_contact) ? Color.new(110, 150, 255, 96) : Color.new(0, 0, 0, 86)
      sprite.bitmap = make_round_rect_bitmap(282, 64, 12, color)
      sprite.visible = true
    end

    @contact_sprites.each_with_index do |sprite, index|
      sprite.zoom_x = sprite.zoom_y = (index == @selected_contact ? 1.05 : 1.0)
      sprite.visible = true
    end

    @contact_names.each_with_index do |sprite, index|
      sprite.opacity = (index == @selected_contact ? 255 : 220)
      sprite.visible = true
    end

    @contact_info.visible = true
  end

  def draw_contacts_header
    bmp = @contact_info.bitmap
    phone_text(bmp, 24, 26, 222, 30, "Tin nhắn", 22, nil, 0, true)
    entries = @pmgc_entries || []
    phone_text(bmp, 24, 60, 288, 20, "#{entries.size} cuộc trò chuyện", 13, Color.new(187, 201, 226))
    phone_footer(bmp, "↑↓: chọn   Z: xem   X: quay lại")
  end

  def get_sender_icon(sender, contact_id)
    if sender == :main
      PhoneMenu::ICON_MAIN_CHARACTER
    elsif sender.to_s.start_with?("contact")
      contact_num = sender.to_s.gsub("contact", "").to_i
      if PhoneMenu::CONTACTS[contact_num]
        "#{PhoneMenu::ICON_CONTACT_PREFIX}#{contact_num}"
      else
        "#{PhoneMenu::ICON_CONTACT_PREFIX}#{contact_id}"
      end
    else
      "#{PhoneMenu::ICON_CONTACT_PREFIX}#{contact_id}"
    end
  end

  def show_contact_details
    return if PhoneMenu::CONTACTS.empty?

    set_overlay_opacity(PhoneMenu::MESSAGE_OVERLAY_OPACITY)
    refresh_phone_background(PhoneMenu::MESSAGE_BACKGROUND)

    @contact_panels.each { |s| s.visible = false } if @contact_panels
    @contact_sprites.each { |s| s.visible = false } if @contact_sprites
    @contact_names.each { |s| s.visible = false } if @contact_names

    @contact_info.bitmap.clear
    @contact_info.visible = true

    contact_id = PhoneMenu::CONTACTS.keys[@selected_contact + @contact_index]
    data = PhoneMenu::CONTACTS[contact_id]
    bmp = @contact_info.bitmap
    fill_round_rect(bmp, 8, 8, PhoneMenu::PHONE_WIDTH - 16, 48, 10, Color.new(0, 0, 0, 135))
    bmp.font.size = 24
    bmp.font.bold = true
    bmp.font.color = Color.new(255, 255, 255)
    bmp.font.outline = false
    bmp.draw_text(0, 10, PhoneMenu::PHONE_WIDTH, 24, data[0], 1)
    bmp.font.bold = false
    bmp.font.size = 16
    bmp.draw_text(0, 32, PhoneMenu::PHONE_WIDTH, 18, "Messages", 1)

    dispose_sprite_array(@contact_messages)
    @contact_messages = []

    messages = data[2]
    infos = build_visible_message_infos(messages, contact_id, @message_index)

    infos.each do |info|
      bubble_y = info[:y]
      icon_y = bubble_y + info[:bubble_height] - PhoneMenu::MESSAGE_ICON_SIZE

      bubble_color = info[:is_main] ? Color.new(42, 155, 255, 222) : Color.new(248, 248, 248, 228)
      text_color = info[:is_main] ? Color.new(255, 255, 255) : Color.new(25, 25, 25)

      bubble_sprite = Sprite.new
      bubble_sprite.bitmap = make_round_rect_bitmap(info[:bubble_width], info[:bubble_height], 14, bubble_color)
      bubble_sprite.x = info[:bubble_x]
      bubble_sprite.y = bubble_y
      bubble_sprite.z = 99
      bubble_sprite.visible = true
      @contact_messages << bubble_sprite

      icon_sprite = Sprite.new
      icon_sprite.bitmap = Cache.load_bitmap("Graphics/PhoneMenu/", get_sender_icon(info[:sender], info[:contact_id]))
      icon_sprite.x = info[:icon_x]
      icon_sprite.y = icon_y
      icon_sprite.z = 101
      scale = PhoneMenu::MESSAGE_ICON_SIZE.to_f / [icon_sprite.bitmap.width, icon_sprite.bitmap.height].max
      icon_sprite.zoom_x = scale
      icon_sprite.zoom_y = scale
      icon_sprite.visible = true
      @contact_messages << icon_sprite

      info[:wrapped_lines].each_with_index do |line, line_index|
        text_sprite = Sprite.new
        text_sprite.bitmap = Bitmap.new(info[:bubble_width] - PhoneMenu::MESSAGE_PADDING_X * 2, 24)
        text_sprite.bitmap.font.size = 20
        text_sprite.bitmap.font.color = text_color
        text_sprite.bitmap.font.outline = false
        text_sprite.bitmap.draw_text(0, 0, info[:bubble_width] - PhoneMenu::MESSAGE_PADDING_X * 2, 24,
          line, info[:is_main] ? 2 : 0)
        text_sprite.x = info[:bubble_x] + PhoneMenu::MESSAGE_PADDING_X
        text_sprite.y = bubble_y + PhoneMenu::MESSAGE_PADDING_Y + line_index * PhoneMenu::MESSAGE_LINE_SPACING
        text_sprite.z = 102
        text_sprite.visible = true
        @contact_messages << text_sprite
      end
    end
  end

  def show_contacts_sprites
    @contact_panels.each { |s| s.visible = !@in_message_view } if @contact_panels
    @contact_sprites.each { |s| s.visible = !@in_message_view } if @contact_sprites
    @contact_names.each { |s| s.visible = !@in_message_view } if @contact_names
    @contact_messages.each { |s| s.visible = @in_message_view } if @contact_messages
    @contact_info.visible = true if @contact_info
  end

  def hide_contacts_sprites
    @contact_panels.each { |s| s.visible = false } if @contact_panels
    @contact_sprites.each { |s| s.visible = false } if @contact_sprites
    @contact_names.each { |s| s.visible = false } if @contact_names
    @contact_messages.each { |s| s.visible = false } if @contact_messages
    @contact_info.visible = false if @contact_info
  end

  def close_contacts_screen
    restore_current_background
    set_overlay_opacity(PhoneMenu::MAIN_OVERLAY_OPACITY)

    dispose_sprite_array(@contact_sprites)
    dispose_sprite_array(@contact_names)
    dispose_sprite_array(@contact_panels)
    dispose_sprite_array(@contact_messages)

    if @contact_info
      @contact_info.bitmap.dispose if @contact_info.bitmap && !@contact_info.bitmap.disposed?
      @contact_info.dispose unless @contact_info.disposed?
    end

    @contacts_screen = false
    @in_message_view = false
    @message_index = 0
    @contact_index = 0
    @selected_contact = 0
    @contact_sprites = []
    @contact_names = []
    @contact_panels = []
    @contact_messages = []
    @contact_info = nil

    @animation_state = :idle
    @animation_timer = 0
    @background_sprite.y = PhoneMenu::PHONE_Y
    @overlay.y = PhoneMenu::PHONE_Y
    @background_sprite.visible = true
    @overlay.visible = true
    @black_rectangle.opacity = 0
    @black_rectangle.visible = false
    show_menu_sprites
  end

  #--------------------------------------------------------------------------
  # Dispose
  #--------------------------------------------------------------------------
  def dispose_phone_menu_sprites
    return if @phone_menu_disposed
    @phone_menu_disposed = true

    if @phone_measure_bitmap && !@phone_measure_bitmap.disposed?
      @phone_measure_bitmap.dispose
    end
    @phone_measure_bitmap = nil
    @phone_panel_snapshot = nil
    @phone_panel_bitmap = nil
    @phone_wrap_cache = nil

    if @phone_backdrop
      @phone_backdrop.bitmap.dispose if @phone_backdrop.bitmap && !@phone_backdrop.bitmap.disposed?
      @phone_backdrop.dispose unless @phone_backdrop.disposed?
      @phone_backdrop = nil
    end

    dispose_sprite_array(@icon_sprites)
    dispose_sprite_array(@highlight_sprites)
    dispose_sprite_array(@contact_sprites)
    dispose_sprite_array(@contact_names)
    dispose_sprite_array(@contact_panels)
    dispose_sprite_array(@contact_messages)
    dispose_sprite_array(@gallery_panels)
    dispose_sprite_array(@gallery_thumbs)
    dispose_sprite_array(@gallery_labels)

    if @background_sprite
      @background_sprite.bitmap.dispose if @background_sprite.bitmap && !@background_sprite.bitmap.disposed?
      @background_sprite.dispose unless @background_sprite.disposed?
    end

    if @overlay
      @overlay.bitmap.dispose if @overlay.bitmap && !@overlay.bitmap.disposed?
      @overlay.dispose unless @overlay.disposed?
    end

    if @main_panel
      @main_panel.bitmap.dispose if @main_panel.bitmap && !@main_panel.bitmap.disposed?
      @main_panel.dispose unless @main_panel.disposed?
    end

    if @black_rectangle
      @black_rectangle.bitmap.dispose if @black_rectangle.bitmap && !@black_rectangle.bitmap.disposed?
      @black_rectangle.dispose unless @black_rectangle.disposed?
    end

    if @contact_info
      @contact_info.bitmap.dispose if @contact_info.bitmap && !@contact_info.bitmap.disposed?
      @contact_info.dispose unless @contact_info.disposed?
    end

    if @gallery_info
      @gallery_info.bitmap.dispose if @gallery_info.bitmap && !@gallery_info.bitmap.disposed?
      @gallery_info.dispose unless @gallery_info.disposed?
    end

    if @gallery_full_sprite
      @gallery_full_sprite.bitmap.dispose if @gallery_full_sprite.bitmap && !@gallery_full_sprite.bitmap.disposed?
      @gallery_full_sprite.dispose unless @gallery_full_sprite.disposed?
    end
  end
end

#==============================================================================
# Window_PhoneMenu
#==============================================================================
class Window_PhoneMenu < Window_Command
  def initialize
    super(0, 0)
    self.opacity = 0
    self.back_opacity = 0
    self.contents_opacity = 0
    deactivate
  end

  def window_width
    1
  end

  def window_height
    1
  end

  def make_command_list
    PhoneMenu::MENU_COMMANDS.each do |sym|
      add_command("", sym, true)
    end
  end
end
#==============================================================================
# ** Unified Phone Menu
#------------------------------------------------------------------------------
# Custom phone menu + global/gallery upgrade + saved group-chat integration.
# Generated from the three previously separate scripts.
#==============================================================================

#==============================================================================
# ** Global Gallery Unlocks for MOG Picture Gallery
#------------------------------------------------------------------------------
# Makes gallery unlocks shared across all save files.
#
# Use same script calls:
#   enable_picture(1)
#   disable_picture(1)
#   picture_gallery
#
# Global gallery file:
#   Save/GlobalGallery.rvdata2
#==============================================================================

module GlobalGallery
  FILE_NAME = "Save/GlobalGallery.rvdata2"

  def self.load
    if File.exist?(FILE_NAME)
      File.open(FILE_NAME, "rb") { |file| Marshal.load(file) }
    else
      []
    end
  rescue
    []
  end

  def self.save(data)
    Dir.mkdir("Save") unless Dir.exist?("Save")
    File.open(FILE_NAME, "wb") { |file| Marshal.dump(data, file) }
  end

  def self.unlock(id)
    data = load
    already_unlocked = !!data[id]
    data[id] = true
    save(data)
    apply_to_game_system
    WCFEventNotice.cg_unlocked if !already_unlocked &&
      defined?(WCFEventNotice)
  end

  def self.lock(id)
    data = load
    data[id] = false
    save(data)
    apply_to_game_system
  end

  def self.apply_to_game_system
    return unless $game_system
    $game_system.gallery = load
  end
end

#==============================================================================
# ** DataManager
#==============================================================================
module DataManager
  class << self
    alias global_gallery_create_game_objects create_game_objects
    alias global_gallery_extract_save_contents extract_save_contents
  end

  def self.create_game_objects
    global_gallery_create_game_objects
    GlobalGallery.apply_to_game_system
  end

  def self.extract_save_contents(contents)
    global_gallery_extract_save_contents(contents)
    GlobalGallery.apply_to_game_system
  end
end

#==============================================================================
# ** Scene_Load
#==============================================================================
class Scene_Load < Scene_File
  alias global_gallery_on_load_success on_load_success

  def on_load_success
    global_gallery_on_load_success
    GlobalGallery.apply_to_game_system
  end
end

#==============================================================================
# ** Game_Interpreter
#==============================================================================
class Game_Interpreter
  def enable_picture(id, value = true)
    if value
      GlobalGallery.unlock(id)
    else
      GlobalGallery.lock(id)
    end
  end

  def disable_picture(id, value = false)
    GlobalGallery.lock(id)
  end
end
#==============================================================================
# ** Phone Menu Gallery Upgrade - Corrected Version
#------------------------------------------------------------------------------
# Paste BELOW your current Custom_PhoneMenu script
# Replace the previous gallery upgrade patch completely
#
# Required files in Graphics/PhoneMenu/
#   Cursor.png
#   Button.png
#==============================================================================

module PhoneMenu
  GALLERY_PICTURE_NAMES = {
    1 => "Hải Quỳ rời Silver Wing", 2 => "Kẹp hình con dơi",
    3 => "Kẹp hình khiên", 4 => "Kẹp hình chìa khóa",
    5 => "Kẹp hình hạt cà phê", 6 => "Hải Quỳ bị vùi trong tuyết",
    7 => "Bully Quỳ bị vùi trong tuyết", 8 => "Hakase quấn khăn",
    9 => "Ending — Rượt đuổi",
    10 => "Máy pha cà phê — Leo",
    11 => "Máy pha cà phê — Kohi",
    12 => "Máy pha cà phê — Shylvie",
    13 => "Máy pha cà phê — Hakase",
    14 => "Dao và chảo — Leo", 15 => "Dao và chảo — Kohi",
    16 => "Dao và chảo — Shylvie", 17 => "Dao và chảo — Hakase",
    18 => "Đồ len — Leo", 19 => "Đồ len — Kohi",
    20 => "Đồ len — Shylvie", 21 => "Đồ len — Hakase",
    22 => "Bộ phá khóa — Leo", 23 => "Bộ phá khóa — Kohi",
    24 => "Bộ phá khóa — Shylvie", 25 => "Bộ phá khóa — Hakase",
    26 => "Hakase đóng băng khăn", 27 => "Tai nạn của Hakase",
    28 => "Hải Quỳ thức dậy", 29 => "Bộ đồ đầu tiên",
    30 => "Bộ đồ thứ hai", 31 => "Trang phục Giáng sinh",
    32 => "Shylvie và chiếc khiên", 33 => "Hải Quỳ quàng khăn cho Shylvie",
    34 => "Leo và thanh kiếm", 35 => "Kohi và những thanh gỗ",
    36 => "Một phen hốt hoảng", 37 => "Kohi và ly nước I",
    38 => "Kohi và ly nước II", 39 => "Hakase ôm Leo",
    40 => "Hải Quỳ ăn", 41 => "Hải Quỳ và Bully Quỳ",
    42 => "Áo khoác Leo tặng Hakase", 43 => "Áo khoác tàng hình",
    44 => "Bánh kem vị cam", 45 => "Bao tay Hakase tặng Shylvie",
    46 => "Bao tay Kohi tặng Hakase", 47 => "Bộ móc len",
    48 => "Bút vàng", 49 => "Cà phê thường", 50 => "Cà phê Atlantis",
    51 => "Cà phê Luminous", 52 => "Combo dao và chảo",
    53 => "Congo Tourmaline", 54 => "Viên đá tặng Shylvie",
    55 => "Đèn Hakase", 56 => "Cà phê Diamond",
    57 => "Dụng cụ phá khóa", 58 => "Gậy phép thuật",
    59 => "Giá đỡ kiếm", 60 => "Kệ gỗ chưa lắp",
    61 => "Khăn tặng Shylvie", 62 => "Khăn tặng Hakase",
    63 => "Khăn tặng Kohi", 64 => "Khăn tặng Leo",
    65 => "Khiên rỉ sét", 66 => "Kiếm cách", 67 => "Kirby",
    68 => "Knuckles plushie", 69 => "Mặt nạ đá", 70 => "Máy ép cam",
    71 => "Mì Bully Quỳ", 72 => "Mì Hải Quỳ", 73 => "Nhựa",
    74 => "Ốp lưng điện thoại", 75 => "Purple Garnet",
    76 => "Rainbow Fluorite", 77 => "Sapphire", 78 => "Búp bê Tails",
    79 => "Túi đeo chéo", 80 => "Váy tặng Shylvie", 81 => "Váy tặng Hải Quỳ",
    82 => "Album nhà kho I", 83 => "Album nhà kho II",
    84 => "Album nhà kho III", 85 => "Album nhà kho IV"
}
  GALLERY_PICTURE_FILES = {
    1 => "CG1", 2 => "CG2", 3 => "CG3", 4 => "CG4",
    5 => "CG5", 6 => "CG6", 7 => "CG7", 8 => "CG8",
    9 => "EDRuotDuoi",
    10 => "ED_MKT_COFFEE_LEO", 11 => "ED_MKT_COFFEE_KOHI",
    12 => "ED_MKT_COFFEE_SHYLVIE", 13 => "ED_MKT_COFFEE_HAKASE",
    14 => "ED_MKT_COOKWARE_LEO", 15 => "ED_MKT_COOKWARE_KOHI",
    16 => "ED_MKT_COOKWARE_SHYLVIE", 17 => "ED_MKT_COOKWARE_HAKASE",
    18 => "ED_MKT_KNITTING_LEO", 19 => "ED_MKT_KNITTING_KOHI",
    20 => "ED_MKT_KNITTING_SHYLVIE", 21 => "ED_MKT_KNITTING_HAKASE",
    22 => "ED_MKT_LOCK_LEO", 23 => "ED_MKT_LOCK_KOHI",
    24 => "ED_MKT_LOCK_SHYLVIE", 25 => "ED_MKT_LOCK_HAKASE",
    26 => "CG9", 27 => "CG10", 28 => "CG11", 29 => "CG12",
    30 => "CG13", 31 => "CG14", 32 => "CG15", 33 => "CG16",
    34 => "CG17", 35 => "CG18", 36 => "CG19", 37 => "CG20",
    38 => "CG21", 39 => "CG22", 40 => "CG23", 41 => "CG24",
    42 => "Aokhoacleotanghakase", 43 => "Aokhoactanghinh",
    44 => "Banhkemcam", 45 => "Baotayhakasetangcv",
    46 => "Baotaykohitanghakase", 47 => "Bomoclen", 48 => "Butvang",
    49 => "Caphe", 50 => "capheatlantis", 51 => "CapheLuminous",
    52 => "Combodaochao", 53 => "CongoTourmaline", 54 => "Datangcv",
    55 => "Denhakase", 56 => "DiamondCoffee", 57 => "Dungcuphakhoa",
    58 => "Gayphepthuat", 59 => "Giadokiem", 60 => "Kegochualap",
    61 => "Khancv", 62 => "Khanhakase", 63 => "Khankohi",
    64 => "Khanleo", 65 => "Khienriset", 66 => "Kiemcach",
    67 => "Kirby", 68 => "Knucklesplushie", 69 => "Matnada",
    70 => "Mayepcam", 71 => "Mibullyquy", 72 => "Mihaiquy",
    73 => "Nhua", 74 => "Oplung", 75 => "PurpleGarnet",
    76 => "RainbowFluorite", 77 => "Sapphire", 78 => "Tailsdoll",
    79 => "Tuideocheo", 80 => "VayCV", 81 => "VayQuy",
    82 => "Album_1", 83 => "Album_2", 84 => "Album_3", 85 => "Album_4"
  }
  GALLERY_PICTURE_SOURCES = Hash[(1..8).to_a.concat((26..85).to_a).map { |id| [id, :pictures] }]
  GALLERY_CURSOR_FILE = "Cursor"
  GALLERY_BUTTON_FILE = "Button"

  GALLERY_ROTATE_DURATION = 18
  GALLERY_ROTATE_ANGLE = 90
  GALLERY_ZOOM_RATE = 1.5
  GALLERY_SCROLL_SPEED = 8

  GALLERY_VIEW_X = 0
  GALLERY_VIEW_Y = 0
  GALLERY_VIEW_W = Graphics.width
  GALLERY_VIEW_H = Graphics.height
end

module WCFGalleryScene
  PICTURE_SLOT = 19

  def self.screen
    if $game_party && $game_party.in_battle
      $game_troop && $game_troop.screen
    else
      $game_map && $game_map.screen
    end
  end

  def self.show(id)
    filename = PhoneMenu::GALLERY_PICTURE_FILES[id]
    return unless filename && PhoneMenu::GALLERY_PICTURE_SOURCES[id] == :pictures
    target = screen
    return unless target
    hide
    GlobalGallery.unlock(id)
    source = Cache.picture(filename)
    if filename =~ /\ACG(?:[1-9]|1[0-9]|2[0-4])\z/ &&
        source.width == 544 && source.height == 416
      WCFFramedCG.show(filename, source)
      @framed = true
      return
    end
    target.pictures[PICTURE_SLOT].show(filename, 1,
      Graphics.width / 2, Graphics.height / 2, 100, 100, 255, 0)
  end

  def self.hide
    target = screen
    target.pictures[PICTURE_SLOT].erase if target
    WCFFramedCG.hide if defined?(WCFFramedCG) && @framed
    @framed = false
  end

  def self.hold(frames)
    frames.to_i.times { Fiber.yield }
  end
end

#==============================================================================
# ** WCFFramedCG
#------------------------------------------------------------------------------
# Presents legacy 544x416 CGs at their native size, centered inside the
# 640x480 game window with a solid black matte behind them.  The dedicated
# viewport keeps the artwork above the map but below Window_Message.
#==============================================================================

module WCFFramedCG
  VIEWPORT_Z = 50

  def self.show(filename, source = nil)
    source ||= Cache.picture(filename)
    # Compose the matte and CG before exposing any sprite. Keeping both pixels
    # in one bitmap prevents a refresh from showing only the black backdrop
    # while the CG is created or removed.
    canvas = Bitmap.new(Graphics.width, Graphics.height)
    canvas.fill_rect(canvas.rect, Color.new(0, 0, 0))
    x = (Graphics.width - source.width) / 2
    y = (Graphics.height - source.height) / 2
    canvas.blt(x, y, source, source.rect)
    hide
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = VIEWPORT_Z
    @picture = Sprite.new(@viewport)
    @picture.bitmap = canvas
    @picture.x = 0
    @picture.y = 0
  end

  def self.hide
    if @picture
      bitmap = @picture.bitmap
      @picture.dispose unless @picture.disposed?
      bitmap.dispose if bitmap && !bitmap.disposed?
      @picture = nil
    end
    # Clean up an instance created by the older two-sprite implementation if
    # a save/test session hot-reloaded this script.
    if @backdrop
      bitmap = @backdrop.bitmap
      @backdrop.dispose unless @backdrop.disposed?
      bitmap.dispose if bitmap && !bitmap.disposed?
      @backdrop = nil
    end
    if @viewport
      # RGSS3's Viewport does not expose Sprite#disposed?. Probe a harmless
      # property so this remains safe if the scene already disposed it.
      begin
        @viewport.rect
        @viewport.dispose
      rescue
      end
      @viewport = nil
    end
  end
end

#==============================================================================
# ** WCFDiaryReader
#------------------------------------------------------------------------------
# Full-screen reader for the illustrated diary/letter pages used in Map026.
# The event interpreter calls this module directly and yields once per frame, so
# the map scene, lighting and event state remain intact behind the reader.
#==============================================================================

module WCFDiaryReader
  BOOKS = {
    :aira_child => ["Aira_Child_Diary", (1..9).map { |i| i.to_s }],
    :aira_old => ["Aira_Old_Diary",
      (1..13).map { |i| "Forgotten_Diary_#{i}" }],
    :dahria_last => ["Dahria_Last_Letter",
      ["Dahria_Last_Letter", "Dahria_Last_Letter1",
       "Dahria_Last_Letter2"]],
    :storage_album => ["", ["Album_1", "Album_2", "Album_3", "Album_4"],
      [82, 83, 84, 85]]
  }

  def self.read(book_id)
    book = BOOKS[book_id]
    return unless book
    folder, pages, gallery_ids = book
    return if pages.empty?
    (gallery_ids || []).each { |id| GlobalGallery.unlock(id) }

    background = Sprite.new
    background.bitmap = Bitmap.new(Graphics.width, Graphics.height)
    background.bitmap.fill_rect(background.bitmap.rect, Color.new(0, 0, 0))
    background.z = 500

    page_sprite = Sprite.new
    page_sprite.z = 501

    header = Sprite.new
    header.bitmap = Bitmap.new(Graphics.width, 28)
    header.bitmap.fill_rect(header.bitmap.rect, Color.new(0, 0, 0, 150))
    header.bitmap.font.size = 18
    header.bitmap.font.bold = true
    header.z = 502

    footer = Sprite.new
    footer.bitmap = Bitmap.new(Graphics.width, 28)
    footer.bitmap.fill_rect(footer.bitmap.rect, Color.new(0, 0, 0, 170))
    footer.bitmap.font.size = 17
    footer.bitmap.draw_text(0, 0, Graphics.width, 28,
      "←/→/Z: Lật trang    Shift: Ẩn UI    X: Đóng", 1)
    footer.y = Graphics.height - 28
    footer.z = 502

    index = 0
    refresh_page(folder, pages, index, page_sprite, header)
    loop do
      Fiber.yield
      if Input.repeat?(:RIGHT) || Input.trigger?(:C)
        if index < pages.size - 1
          index += 1
          Sound.play_cursor
          refresh_page(folder, pages, index, page_sprite, header)
        else
          Sound.play_buzzer
        end
      elsif Input.repeat?(:LEFT)
        if index > 0
          index -= 1
          Sound.play_cursor
          refresh_page(folder, pages, index, page_sprite, header)
        else
          Sound.play_buzzer
        end
      elsif Input.trigger?(:A)
        visible = !header.visible
        header.visible = visible
        footer.visible = visible
        Sound.play_cursor
      elsif Input.trigger?(:B)
        Sound.play_cancel
        break
      end
    end
  ensure
    [footer, header, page_sprite, background].compact.each do |sprite|
      sprite.bitmap.dispose if sprite.bitmap && !sprite.bitmap.disposed?
      sprite.dispose unless sprite.disposed?
    end
  end

  def self.refresh_page(folder, pages, index, sprite, header)
    path = folder.empty? ? "Graphics/Pictures/" : "Graphics/Pictures/#{folder}/"
    source = Cache.load_bitmap(path, pages[index])
    old_bitmap = sprite.bitmap
    bitmap = Bitmap.new(Graphics.width, Graphics.height)
    scale = [Graphics.width.to_f / source.width,
             Graphics.height.to_f / source.height].min
    width = (source.width * scale).round
    height = (source.height * scale).round
    x = (Graphics.width - width) / 2
    y = (Graphics.height - height) / 2
    bitmap.stretch_blt(Rect.new(x, y, width, height), source, source.rect)
    sprite.bitmap = bitmap
    old_bitmap.dispose if old_bitmap && !old_bitmap.disposed?

    header.bitmap.clear
    header.bitmap.fill_rect(header.bitmap.rect, Color.new(0, 0, 0, 150))
    header.bitmap.font.size = 18
    header.bitmap.font.bold = true
    header.bitmap.draw_text(0, 0, Graphics.width, 28,
      "Trang #{index + 1} / #{pages.size}", 1)
  end
end

class Scene_Menu < Scene_MenuBase
  #--------------------------------------------------------------------------
  # Gallery helpers
  #--------------------------------------------------------------------------
  def gallery_picture_name(picture_id)
    PhoneMenu::GALLERY_PICTURE_NAMES[picture_id] || "Ảnh #{picture_id}"
  end

  def gallery_page_max
    total = PhoneMenu::GALLERY_MAX_PICTURES
    max = (total.to_f / PhoneMenu::GALLERY_PER_PAGE).ceil
    max = 1 if max < 1
    max
  end

  def gallery_picture_id_from_index(page, index)
    page * PhoneMenu::GALLERY_PER_PAGE + index + 1
  end

  def gallery_picture_unlocked?(picture_id)
    return false if picture_id <= 0
    return false unless $game_system
    !!$game_system.gallery[picture_id]
  end

  def gallery_enabled_count
    count = 0
    1.upto(PhoneMenu::GALLERY_MAX_PICTURES) do |i|
      count += 1 if gallery_picture_unlocked?(i)
    end
    count
  end

  def gallery_thumbnail_bitmap(picture_id)
    filename = gallery_picture_unlocked?(picture_id) ? picture_id.to_s : "0"
    Cache.gallery(filename)
  rescue
    Cache.gallery("0")
  end

  def gallery_picture_bitmap(picture_id)
    Cache.gallery(picture_id.to_s)
  rescue
    nil
  end

  #--------------------------------------------------------------------------
  # Open gallery
  #--------------------------------------------------------------------------
  def open_gallery_screen
    @gallery_screen = true
    @contacts_screen = false
    @gallery_page = 0
    @gallery_index = 0
    @gallery_full_view = false
    @gallery_full_picture_id = 0
    @gallery_zoomed = false
    @gallery_zoom_x = 0
    @gallery_zoom_y = 0
    @gallery_transition_mode = nil
    @gallery_transition_count = 0
    @gallery_cursor_anim = 0

    set_overlay_opacity(PhoneMenu::GALLERY_OVERLAY_OPACITY)
    create_gallery_sprites
    create_gallery_cursor
    create_gallery_button
    refresh_gallery
    @animation_state = :idle
    @animation_timer = 0
    @background_sprite.y = PhoneMenu::PHONE_Y
    @overlay.y = PhoneMenu::PHONE_Y
    @background_sprite.visible = true
    @overlay.visible = true
    @black_rectangle.opacity = 0
    @black_rectangle.visible = false
    show_gallery_sprites
  end

  #--------------------------------------------------------------------------
  # Create gallery sprites
  #--------------------------------------------------------------------------
  def create_gallery_sprites
    dispose_gallery_grid_sprites

    if @gallery_info
      @gallery_info.bitmap.dispose if @gallery_info.bitmap && !@gallery_info.bitmap.disposed?
      @gallery_info.dispose unless @gallery_info.disposed?
    end

    if @gallery_full_sprite
      @gallery_full_sprite.bitmap.dispose if @gallery_full_sprite.bitmap && !@gallery_full_sprite.bitmap.disposed?
      @gallery_full_sprite.dispose unless @gallery_full_sprite.disposed?
    end

    if @gallery_transition_sprite
      @gallery_transition_sprite.bitmap.dispose if @gallery_transition_sprite.bitmap && !@gallery_transition_sprite.bitmap.disposed?
      @gallery_transition_sprite.dispose unless @gallery_transition_sprite.disposed?
    end

    @gallery_panels = []
    @gallery_thumbs = []
    @gallery_labels = []

    @gallery_info = Sprite.new
    @gallery_info.bitmap = Bitmap.new(PhoneMenu::PHONE_WIDTH, PhoneMenu::PHONE_HEIGHT)
    @gallery_info.x = PhoneMenu::PHONE_X
    @gallery_info.y = PhoneMenu::PHONE_Y
    @gallery_info.z = 150
    @gallery_info.visible = false

    @gallery_full_sprite = Sprite.new
    @gallery_full_sprite.bitmap = Bitmap.new(PhoneMenu::GALLERY_VIEW_W, PhoneMenu::GALLERY_VIEW_H)
    @gallery_full_sprite.x = PhoneMenu::GALLERY_VIEW_X
    @gallery_full_sprite.y = PhoneMenu::GALLERY_VIEW_Y
    @gallery_full_sprite.z = 400
    @gallery_full_sprite.visible = false

    @gallery_transition_sprite = Sprite.new
    @gallery_transition_sprite.bitmap = Bitmap.new(PhoneMenu::PHONE_WIDTH, PhoneMenu::PHONE_HEIGHT)
    @gallery_transition_sprite.ox = PhoneMenu::PHONE_WIDTH / 2
    @gallery_transition_sprite.oy = PhoneMenu::PHONE_HEIGHT / 2
    @gallery_transition_sprite.x = PhoneMenu::PHONE_X + PhoneMenu::PHONE_WIDTH / 2
    @gallery_transition_sprite.y = PhoneMenu::PHONE_Y + PhoneMenu::PHONE_HEIGHT / 2
    @gallery_transition_sprite.z = 390
    @gallery_transition_sprite.visible = false
  end

  def dispose_gallery_grid_sprites
    dispose_sprite_array(@gallery_panels)
    dispose_sprite_array(@gallery_thumbs)
    dispose_sprite_array(@gallery_labels)
    @gallery_panels = []
    @gallery_thumbs = []
    @gallery_labels = []
  end

  def rebuild_gallery_grid
    dispose_gallery_grid_sprites
    start_id = @gallery_page * PhoneMenu::GALLERY_PER_PAGE + 1
    PhoneMenu::GALLERY_PER_PAGE.times do |index|
      picture_id = start_id + index
      break if picture_id > PhoneMenu::GALLERY_MAX_PICTURES
      x = PhoneMenu::GALLERY_START_X + (index % PhoneMenu::GALLERY_COLUMNS) *
        (PhoneMenu::GALLERY_THUMB_W + PhoneMenu::GALLERY_SPACING_X)
      y = PhoneMenu::GALLERY_START_Y + (index / PhoneMenu::GALLERY_COLUMNS) *
        (PhoneMenu::GALLERY_THUMB_H + PhoneMenu::GALLERY_LABEL_H + PhoneMenu::GALLERY_SPACING_Y)
      panel = Sprite.new
      panel.bitmap = Bitmap.new(PhoneMenu::GALLERY_THUMB_W + 12,
        PhoneMenu::GALLERY_THUMB_H + PhoneMenu::GALLERY_LABEL_H + 16)
      phone_card(panel.bitmap, 0, 0, panel.bitmap.width, panel.bitmap.height, index == @gallery_index)
      panel.x, panel.y, panel.z, panel.visible = x - 6, y - 6, 96, false
      @gallery_panels << panel

      thumb = Sprite.new
      thumb.bitmap = Bitmap.new(PhoneMenu::GALLERY_THUMB_W, PhoneMenu::GALLERY_THUMB_H)
      if gallery_picture_unlocked?(picture_id)
        source = gallery_thumbnail_bitmap(picture_id)
        phone_fit_bitmap(thumb.bitmap, source)
        source.dispose unless source.disposed?
      else
        phone_locked_thumbnail(thumb.bitmap)
      end
      thumb.x, thumb.y, thumb.z, thumb.visible = x, y, 100, false
      @gallery_thumbs << thumb

      label = Sprite.new
      label.bitmap = Bitmap.new(PhoneMenu::GALLERY_THUMB_W, PhoneMenu::GALLERY_LABEL_H)
      text = gallery_picture_unlocked?(picture_id) ? gallery_picture_name(picture_id) : "Chưa mở khóa"
      phone_text(label.bitmap, 2, 0, PhoneMenu::GALLERY_THUMB_W - 4, 18, text, 13, nil, 1, true)
      phone_text(label.bitmap, 2, 18, PhoneMenu::GALLERY_THUMB_W - 4, 16,
        "#%02d" % picture_id, 11, Color.new(177, 192, 221), 1)
      label.x, label.y, label.z, label.visible = x, y + PhoneMenu::GALLERY_THUMB_H + 4, 101, false
      @gallery_labels << label
    end
  end

  #--------------------------------------------------------------------------
  # Mog-like cursor
  #--------------------------------------------------------------------------
  def create_gallery_cursor
    dispose_gallery_cursor
    @gallery_cursor_bitmap_left = Bitmap.new(16, 22)
    @gallery_cursor_bitmap_right = Bitmap.new(16, 22)
    phone_text(@gallery_cursor_bitmap_left, 0, 0, 16, 22, "‹", 22, Color.new(190, 201, 255), 1)
    phone_text(@gallery_cursor_bitmap_right, 0, 0, 16, 22, "›", 22, Color.new(190, 201, 255), 1)
    @gallery_cursor_left = Sprite.new
    @gallery_cursor_left.bitmap = @gallery_cursor_bitmap_left
    @gallery_cursor_left.x, @gallery_cursor_left.y = PhoneMenu::PHONE_X + 26, PhoneMenu::PHONE_Y + 56
    @gallery_cursor_left.z, @gallery_cursor_left.visible = 220, false
    @gallery_cursor_right = Sprite.new
    @gallery_cursor_right.bitmap = @gallery_cursor_bitmap_right
    @gallery_cursor_right.x, @gallery_cursor_right.y = PhoneMenu::PHONE_X + PhoneMenu::PHONE_WIDTH - 42, PhoneMenu::PHONE_Y + 56
    @gallery_cursor_right.z, @gallery_cursor_right.visible = 220, false
    @gallery_cursor_anim = 0
  end

  def dispose_gallery_cursor
    if @gallery_cursor_left
      @gallery_cursor_left.dispose unless @gallery_cursor_left.disposed?
      @gallery_cursor_left = nil
    end
    if @gallery_cursor_right
      @gallery_cursor_right.dispose unless @gallery_cursor_right.disposed?
      @gallery_cursor_right = nil
    end
    if @gallery_cursor_bitmap_left
      @gallery_cursor_bitmap_left.dispose unless @gallery_cursor_bitmap_left.disposed?
      @gallery_cursor_bitmap_left = nil
    end
    if @gallery_cursor_bitmap_right
      @gallery_cursor_bitmap_right.dispose unless @gallery_cursor_bitmap_right.disposed?
      @gallery_cursor_bitmap_right = nil
    end
  end

  def update_gallery_cursor_animation
    return unless @gallery_cursor_left && @gallery_cursor_right && @gallery_screen
    return if @gallery_full_view || @gallery_transition_mode
    @gallery_cursor_left.visible = @gallery_cursor_right.visible = gallery_page_max > 1
  end

  #--------------------------------------------------------------------------
  # Mog-like button help
  #--------------------------------------------------------------------------
  def create_gallery_button
    dispose_gallery_button
    @gallery_button_cw = Graphics.width
    @gallery_button_ch = 32
    @gallery_button_bitmap = Bitmap.new(@gallery_button_cw, @gallery_button_ch)
    @gallery_button = Sprite.new
    @gallery_button.bitmap = @gallery_button_bitmap
    @gallery_button.x, @gallery_button.y = 0, Graphics.height - @gallery_button_ch
    @gallery_button.z, @gallery_button.visible = 420, false
    refresh_gallery_button(false)
  end

  def dispose_gallery_button
    if @gallery_button
      @gallery_button.dispose unless @gallery_button.disposed?
      @gallery_button = nil
    end
    if @gallery_button_bitmap
      @gallery_button_bitmap.dispose unless @gallery_button_bitmap.disposed?
      @gallery_button_bitmap = nil
    end
    if @gallery_button_image
      @gallery_button_image.dispose unless @gallery_button_image.disposed?
      @gallery_button_image = nil
    end
  end

  def refresh_gallery_button(scroll_mode = false)
    return unless @gallery_button_bitmap
    bitmap = @gallery_button_bitmap
    bitmap.clear
    bitmap.fill_rect(bitmap.rect, Color.new(9, 14, 28, 230))
    text = scroll_mode ? "Mũi tên: di chuyển   Q/W: thu nhỏ   Z/X: quay lại" :
      "Q/W: phóng to   Z/X: quay lại"
    phone_text(bitmap, 16, 4, bitmap.width - 32, 24, text, 13, nil, 1)
  end

  #--------------------------------------------------------------------------
  # Refresh gallery
  #--------------------------------------------------------------------------
  def refresh_gallery
    return if @gallery_info.nil? || @gallery_info.disposed?
    rebuild_gallery_grid
    bmp = @gallery_info.bitmap
    bmp.clear
    phone_text(bmp, 24, 26, 190, 30, "Thư viện", 22, nil, 0, true)
    phone_text(bmp, 212, 32, 100, 20, "#{gallery_enabled_count}/#{PhoneMenu::GALLERY_MAX_PICTURES} ảnh",
      12, Color.new(187, 201, 226), 2)
    phone_text(bmp, 44, 56, PhoneMenu::PHONE_WIDTH - 88, 22,
      "Trang #{@gallery_page + 1} / #{gallery_page_max}", 13, Color.new(187, 201, 226), 1)
    [@gallery_panels, @gallery_thumbs, @gallery_labels].each do |sprites|
      sprites.each { |sprite| sprite.visible = true }
    end
    picture_id = gallery_picture_id_from_index(@gallery_page, @gallery_index)
    title = gallery_picture_unlocked?(picture_id) ? gallery_picture_name(picture_id) : "Khám phá câu chuyện để mở ảnh"
    phone_text(bmp, 24, 388, 288, 24, title, 13, nil, 1)
    phone_footer(bmp, "Mũi tên: chọn   Z: xem   X: quay lại")
    @gallery_info.visible = true
    @gallery_full_sprite.visible = false if @gallery_full_sprite
    @gallery_button.visible = false if @gallery_button
  end

  #--------------------------------------------------------------------------
  # Full picture preparation
  #--------------------------------------------------------------------------
  def prepare_gallery_full_bitmap(picture_id)
    bitmap = gallery_picture_bitmap(picture_id)
    return if bitmap.nil?
    @gallery_full_sprite.zoom_x = @gallery_full_sprite.zoom_y = 1.0
    @gallery_full_sprite.x, @gallery_full_sprite.y = PhoneMenu::GALLERY_VIEW_X, PhoneMenu::GALLERY_VIEW_Y
    phone_fit_bitmap(@gallery_full_sprite.bitmap, bitmap, Graphics.height - 32, false)
    bitmap.dispose unless bitmap.disposed?
    @gallery_zoomed = false
    @gallery_zoom_x = @gallery_zoom_y = 0
  end

  #--------------------------------------------------------------------------
  # Snapshot phone for rotate animation
  #--------------------------------------------------------------------------
  def capture_phone_snapshot
    snap = Graphics.snap_to_bitmap
    @gallery_transition_sprite.bitmap.clear
    src = Rect.new(PhoneMenu::PHONE_X, PhoneMenu::PHONE_Y, PhoneMenu::PHONE_WIDTH, PhoneMenu::PHONE_HEIGHT)
    @gallery_transition_sprite.bitmap.blt(0, 0, snap, src)
    snap.dispose
  end

  #--------------------------------------------------------------------------
  # Open full view
  #--------------------------------------------------------------------------
  def show_gallery_full(picture_id)
    return unless gallery_picture_unlocked?(picture_id)

    @gallery_full_picture_id = picture_id
    prepare_gallery_full_bitmap(picture_id)
    capture_phone_snapshot

    @gallery_transition_count = 0
    @gallery_transition_mode = :opening
    @gallery_full_view = true

    @gallery_transition_sprite.angle = 0
    @gallery_transition_sprite.zoom_x = 1.0
    @gallery_transition_sprite.zoom_y = 1.0
    @gallery_transition_sprite.x = PhoneMenu::PHONE_X + PhoneMenu::PHONE_WIDTH / 2
    @gallery_transition_sprite.y = PhoneMenu::PHONE_Y + PhoneMenu::PHONE_HEIGHT / 2
    @gallery_transition_sprite.opacity = 255
    @gallery_transition_sprite.visible = true

    @gallery_panels.each { |s| s.visible = false } if @gallery_panels
    @gallery_thumbs.each { |s| s.visible = false } if @gallery_thumbs
    @gallery_labels.each { |s| s.visible = false } if @gallery_labels
    @gallery_cursor_left.visible = false if @gallery_cursor_left
    @gallery_cursor_right.visible = false if @gallery_cursor_right
    @gallery_info.visible = false if @gallery_info
    @gallery_button.visible = false if @gallery_button
  end

  def close_gallery_full
    @gallery_full_view = false
    @gallery_transition_mode = nil
    @gallery_transition_count = 0
    @gallery_full_picture_id = 0
    @gallery_zoomed = false
    @gallery_zoom_x = 0
    @gallery_zoom_y = 0
    @gallery_full_sprite.visible = false if @gallery_full_sprite
    @gallery_transition_sprite.visible = false if @gallery_transition_sprite
    refresh_gallery
    show_gallery_sprites
  end

  #--------------------------------------------------------------------------
  # Zoom + scroll
  #--------------------------------------------------------------------------
  def update_gallery_zoom_scroll
    return unless @gallery_zoomed

    max_x = ((PhoneMenu::GALLERY_VIEW_W * PhoneMenu::GALLERY_ZOOM_RATE) - PhoneMenu::GALLERY_VIEW_W).to_i
    max_y = ((PhoneMenu::GALLERY_VIEW_H * PhoneMenu::GALLERY_ZOOM_RATE) - PhoneMenu::GALLERY_VIEW_H).to_i

    @gallery_zoom_x += PhoneMenu::GALLERY_SCROLL_SPEED if Input.press?(:RIGHT)
    @gallery_zoom_x -= PhoneMenu::GALLERY_SCROLL_SPEED if Input.press?(:LEFT)
    @gallery_zoom_y += PhoneMenu::GALLERY_SCROLL_SPEED if Input.press?(:DOWN)
    @gallery_zoom_y -= PhoneMenu::GALLERY_SCROLL_SPEED if Input.press?(:UP)

    @gallery_zoom_x = 0 if @gallery_zoom_x < 0
    @gallery_zoom_y = 0 if @gallery_zoom_y < 0
    @gallery_zoom_x = max_x if @gallery_zoom_x > max_x
    @gallery_zoom_y = max_y if @gallery_zoom_y > max_y

    @gallery_full_sprite.x = -@gallery_zoom_x
    @gallery_full_sprite.y = -@gallery_zoom_y
  end

  def toggle_gallery_zoom
    if @gallery_zoomed
      @gallery_zoomed = false
      @gallery_zoom_x = 0
      @gallery_zoom_y = 0
      @gallery_full_sprite.zoom_x = 1.0
      @gallery_full_sprite.zoom_y = 1.0
      @gallery_full_sprite.x = 0
      @gallery_full_sprite.y = 0
      refresh_gallery_button(false)
    else
      @gallery_zoomed = true
      @gallery_zoom_x = ((PhoneMenu::GALLERY_VIEW_W * PhoneMenu::GALLERY_ZOOM_RATE) - PhoneMenu::GALLERY_VIEW_W) / 2
      @gallery_zoom_y = ((PhoneMenu::GALLERY_VIEW_H * PhoneMenu::GALLERY_ZOOM_RATE) - PhoneMenu::GALLERY_VIEW_H) / 2
      @gallery_full_sprite.zoom_x = PhoneMenu::GALLERY_ZOOM_RATE
      @gallery_full_sprite.zoom_y = PhoneMenu::GALLERY_ZOOM_RATE
      @gallery_full_sprite.x = -@gallery_zoom_x
      @gallery_full_sprite.y = -@gallery_zoom_y
      refresh_gallery_button(true)
    end
  end

  #--------------------------------------------------------------------------
  # Rotate transition
  #--------------------------------------------------------------------------
  def update_gallery_transition
    return unless @gallery_transition_mode

    @gallery_transition_count += 1
    t = @gallery_transition_count.to_f / PhoneMenu::GALLERY_ROTATE_DURATION
    t = 1.0 if t > 1.0

    if @gallery_transition_mode == :opening
      start_x = PhoneMenu::PHONE_X + PhoneMenu::PHONE_WIDTH / 2
      start_y = PhoneMenu::PHONE_Y + PhoneMenu::PHONE_HEIGHT / 2
      end_x = Graphics.width / 2
      end_y = Graphics.height / 2

      @gallery_transition_sprite.x = start_x + (end_x - start_x) * t
      @gallery_transition_sprite.y = start_y + (end_y - start_y) * t
      @gallery_transition_sprite.angle = PhoneMenu::GALLERY_ROTATE_ANGLE * t
      @gallery_transition_sprite.zoom_x = 1.0 + 0.8 * t
      @gallery_transition_sprite.zoom_y = 1.0 + 0.8 * t
      @gallery_transition_sprite.opacity = 255 - (255 * t * 0.40).to_i

      if @gallery_transition_count >= PhoneMenu::GALLERY_ROTATE_DURATION
        @gallery_transition_mode = nil
        @gallery_transition_sprite.visible = false
        @gallery_full_sprite.visible = true
        @gallery_button.visible = true if @gallery_button
        refresh_gallery_button(false)
      end
    end
  end

  #--------------------------------------------------------------------------
  # Gallery selection
  #--------------------------------------------------------------------------
  def update_gallery_selection
    items_this_page = [PhoneMenu::GALLERY_PER_PAGE,
      PhoneMenu::GALLERY_MAX_PICTURES - @gallery_page * PhoneMenu::GALLERY_PER_PAGE].min
    items_this_page = 0 if items_this_page < 0

    if Input.repeat?(:LEFT)
      if (@gallery_index % PhoneMenu::GALLERY_COLUMNS) > 0
        @gallery_index -= 1
      else
        @gallery_page -= 1
        @gallery_page = gallery_page_max - 1 if @gallery_page < 0
        items_this_page = [PhoneMenu::GALLERY_PER_PAGE,
          PhoneMenu::GALLERY_MAX_PICTURES - @gallery_page * PhoneMenu::GALLERY_PER_PAGE].min
        @gallery_index = [items_this_page - 1, 0].max
      end
      RPG::SE.new(PhoneMenu::SELECT_SE).play
      refresh_gallery
    elsif Input.repeat?(:RIGHT)
      if (@gallery_index % PhoneMenu::GALLERY_COLUMNS) < PhoneMenu::GALLERY_COLUMNS - 1 &&
         (@gallery_index + 1) < items_this_page
        @gallery_index += 1
      else
        @gallery_page += 1
        @gallery_page = 0 if @gallery_page >= gallery_page_max
        @gallery_index = 0
      end
      RPG::SE.new(PhoneMenu::SELECT_SE).play
      refresh_gallery
    elsif Input.repeat?(:UP)
      if @gallery_index - PhoneMenu::GALLERY_COLUMNS >= 0
        @gallery_index -= PhoneMenu::GALLERY_COLUMNS
      else
        @gallery_page -= 1
        @gallery_page = gallery_page_max - 1 if @gallery_page < 0
        items_this_page = [PhoneMenu::GALLERY_PER_PAGE,
          PhoneMenu::GALLERY_MAX_PICTURES - @gallery_page * PhoneMenu::GALLERY_PER_PAGE].min
        @gallery_index = [items_this_page - 1, 0].max
      end
      RPG::SE.new(PhoneMenu::SELECT_SE).play
      refresh_gallery
    elsif Input.repeat?(:DOWN)
      if @gallery_index + PhoneMenu::GALLERY_COLUMNS < items_this_page
        @gallery_index += PhoneMenu::GALLERY_COLUMNS
      else
        @gallery_page += 1
        @gallery_page = 0 if @gallery_page >= gallery_page_max
        @gallery_index = 0
      end
      RPG::SE.new(PhoneMenu::SELECT_SE).play
      refresh_gallery
    elsif Input.trigger?(:L)
      @gallery_page -= 1
      @gallery_page = gallery_page_max - 1 if @gallery_page < 0
      @gallery_index = 0
      RPG::SE.new(PhoneMenu::SELECT_SE).play
      refresh_gallery
    elsif Input.trigger?(:R)
      @gallery_page += 1
      @gallery_page = 0 if @gallery_page >= gallery_page_max
      @gallery_index = 0
      RPG::SE.new(PhoneMenu::SELECT_SE).play
      refresh_gallery
    elsif Input.trigger?(:C)
      picture_id = gallery_picture_id_from_index(@gallery_page, @gallery_index)
      if picture_id <= PhoneMenu::GALLERY_MAX_PICTURES && gallery_picture_unlocked?(picture_id)
        Sound.play_ok
        show_gallery_full(picture_id)
      else
        Sound.play_buzzer
      end
    elsif Input.trigger?(:B)
      close_gallery_screen
    end
  end

  #--------------------------------------------------------------------------
  # Full view update
  #--------------------------------------------------------------------------
  def update_gallery_full_view
    if Input.trigger?(:B) || Input.trigger?(:C)
      Sound.play_cancel
      close_gallery_full
      return
    end

    if Input.trigger?(:L) || Input.trigger?(:R)
      Sound.play_cursor
      toggle_gallery_zoom
    end

    update_gallery_zoom_scroll
  end

  #--------------------------------------------------------------------------
  # Update gallery screen
  #--------------------------------------------------------------------------
  def update_gallery_screen
    return unless @animation_state == :idle

    update_gallery_cursor_animation

    if @gallery_transition_mode
      update_gallery_transition
      return
    end

    if @gallery_full_view
      update_gallery_full_view
    else
      update_gallery_selection
    end
  end

  #--------------------------------------------------------------------------
  # Show/hide gallery sprites
  #--------------------------------------------------------------------------
  def show_gallery_sprites
    if @gallery_full_view
      @gallery_panels.each { |s| s.visible = false } if @gallery_panels
      @gallery_thumbs.each { |s| s.visible = false } if @gallery_thumbs
      @gallery_labels.each { |s| s.visible = false } if @gallery_labels
      @gallery_full_sprite.visible = true if @gallery_full_sprite
      @gallery_info.visible = false if @gallery_info
      @gallery_cursor_left.visible = false if @gallery_cursor_left
      @gallery_cursor_right.visible = false if @gallery_cursor_right
      @gallery_button.visible = true if @gallery_button
    else
      @gallery_panels.each { |s| s.visible = true } if @gallery_panels
      @gallery_thumbs.each { |s| s.visible = true } if @gallery_thumbs
      @gallery_labels.each { |s| s.visible = true } if @gallery_labels
      @gallery_full_sprite.visible = false if @gallery_full_sprite
      @gallery_info.visible = true if @gallery_info
      visible = gallery_page_max > 1
      @gallery_cursor_left.visible = visible if @gallery_cursor_left
      @gallery_cursor_right.visible = visible if @gallery_cursor_right
      @gallery_button.visible = false if @gallery_button
    end
  end

  def hide_gallery_sprites
    @gallery_panels.each { |s| s.visible = false } if @gallery_panels
    @gallery_thumbs.each { |s| s.visible = false } if @gallery_thumbs
    @gallery_labels.each { |s| s.visible = false } if @gallery_labels
    @gallery_full_sprite.visible = false if @gallery_full_sprite
    @gallery_transition_sprite.visible = false if @gallery_transition_sprite
    @gallery_info.visible = false if @gallery_info
    @gallery_cursor_left.visible = false if @gallery_cursor_left
    @gallery_cursor_right.visible = false if @gallery_cursor_right
    @gallery_button.visible = false if @gallery_button
  end

  #--------------------------------------------------------------------------
  # Close gallery
  #--------------------------------------------------------------------------
  def close_gallery_screen
    restore_current_background
    set_overlay_opacity(PhoneMenu::MAIN_OVERLAY_OPACITY)

    dispose_gallery_grid_sprites

    if @gallery_info
      @gallery_info.bitmap.dispose if @gallery_info.bitmap && !@gallery_info.bitmap.disposed?
      @gallery_info.dispose unless @gallery_info.disposed?
      @gallery_info = nil
    end

    if @gallery_full_sprite
      @gallery_full_sprite.bitmap.dispose if @gallery_full_sprite.bitmap && !@gallery_full_sprite.bitmap.disposed?
      @gallery_full_sprite.dispose unless @gallery_full_sprite.disposed?
      @gallery_full_sprite = nil
    end

    if @gallery_transition_sprite
      @gallery_transition_sprite.bitmap.dispose if @gallery_transition_sprite.bitmap && !@gallery_transition_sprite.bitmap.disposed?
      @gallery_transition_sprite.dispose unless @gallery_transition_sprite.disposed?
      @gallery_transition_sprite = nil
    end

    dispose_gallery_cursor
    dispose_gallery_button

    @gallery_screen = false
    @gallery_full_view = false
    @gallery_full_picture_id = 0
    @gallery_zoomed = false
    @gallery_zoom_x = 0
    @gallery_zoom_y = 0
    @gallery_page = 0
    @gallery_index = 0
    @gallery_transition_mode = nil
    @gallery_transition_count = 0

    @animation_state = :idle
    @animation_timer = 0
    @background_sprite.y = PhoneMenu::PHONE_Y
    @overlay.y = PhoneMenu::PHONE_Y
    @background_sprite.visible = true
    @overlay.visible = true
    @black_rectangle.opacity = 0
    @black_rectangle.visible = false
    show_menu_sprites
  end

  #--------------------------------------------------------------------------
  # Extend dispose
  #--------------------------------------------------------------------------
  alias phone_gallery_upgrade_corrected_dispose_phone_menu_sprites dispose_phone_menu_sprites
  def dispose_phone_menu_sprites
    return if @phone_menu_disposed
    phone_gallery_upgrade_corrected_dispose_phone_menu_sprites

    dispose_gallery_cursor
    dispose_gallery_button

    if @gallery_transition_sprite
      @gallery_transition_sprite.bitmap.dispose if @gallery_transition_sprite.bitmap && !@gallery_transition_sprite.bitmap.disposed?
      @gallery_transition_sprite.dispose unless @gallery_transition_sprite.disposed?
      @gallery_transition_sprite = nil
    end
  end
end

#==============================================================================
# ** Phone Menu Saved Group Chat Patch
#------------------------------------------------------------------------------
# For current Custom_PhoneMenu + Gallery version
# Put BELOW:
# 1. Custom_PhoneMenu + Phone Gallery
# 2. Simple Cutscene Phone Chat
#
# Required group icon:
#   Graphics/PhoneMenu/Contact_WandererGroup.png
#
# Script calls:
#   PhoneGroupChatSave.save_current_cutscene(:wanderer_group)
#   PhoneGroupChatSave.add_text(:leo, "Có tin mới nè.")
#   PhoneGroupChatSave.add_image(:hakase, "CG22")
#   PhoneGroupChatSave.add_system("Leo left the chat")
#==============================================================================

module PhoneGroupChat
  DEFAULT_GROUP_ID = :wanderer_group

  GROUPS = {
    :wanderer_group => {
      :name => "Wanderer Office",
      :info => "Christmas planning",
      :avatar => "Contact_WandererGroup",
      :members => {
        :quy     => ["Quỳ",      "Contact_Quy"],
        :leo     => ["Leo",      "Contact_Leo"],
        :kohi    => ["Kohi",     "Contact_Kohi"],
        :hakase  => ["Hakase",   "Contact_Hakase"],
        :shylvie => ["Shylvie",  "Contact_Shylvie"]
      }
    }
  }
end

#==============================================================================
# ** Game_Config patch
#==============================================================================

class Game_Config
  attr_accessor :phone_group_chats

  alias pmgc_initialize initialize
  def initialize
    pmgc_initialize
    @phone_group_chats ||= {}
  end

  def phone_group_chats
    @phone_group_chats ||= {}
  end

  def ensure_group_chat(group_id)
    group_id = group_id.to_sym
    return phone_group_chats[group_id] if phone_group_chats[group_id]

    setup = PhoneGroupChat::GROUPS[group_id]
    if setup
      phone_group_chats[group_id] = {
        :name => setup[:name],
        :info => setup[:info],
        :avatar => setup[:avatar],
        :members => setup[:members],
        :messages => []
      }
    else
      phone_group_chats[group_id] = {
        :name => group_id.to_s,
        :info => "",
        :avatar => "Contact_#{group_id}",
        :members => {},
        :messages => []
      }
    end
    phone_group_chats[group_id]
  end

  def clear_group_chat(group_id)
    ensure_group_chat(group_id)[:messages].clear
  end

  def add_group_text(group_id, sender, text, side = nil)
    ensure_group_chat(group_id)[:messages] << {
      :type => :text,
      :sender => sender,
      :text => text.to_s,
      :side => side
    }
  end

  def add_group_image(group_id, sender, image, side = nil)
    ensure_group_chat(group_id)[:messages] << {
      :type => :image,
      :sender => sender,
      :image => image.to_s,
      :side => side
    }
  end

  def add_group_system(group_id, text)
    ensure_group_chat(group_id)[:messages] << {
      :type => :system,
      :text => text.to_s
    }
  end

  def add_group_choice(group_id, text, value)
    ensure_group_chat(group_id)[:messages] << {
      :type => :choice,
      :text => text.to_s,
      :value => value
    }
  end

  def add_group_choice_result(group_id, text, value = nil)
    ensure_group_chat(group_id)[:messages] << {
      :type => :choice_result,
      :text => text.to_s,
      :value => value
    }
  end
end

#==============================================================================
# ** PhoneGroupChatSave
#==============================================================================

#==============================================================================
# ** PhoneGroupChatSave
#------------------------------------------------------------------------------
# Replace the old PhoneGroupChatSave module with this version.
#==============================================================================

module PhoneGroupChatSave
  def self.group_id(id = nil)
    id || PhoneGroupChat::DEFAULT_GROUP_ID
  end

  def self.add_text(sender, text, side = nil, id = nil)
    $game_config.add_group_text(group_id(id), sender, text, side)
    WCFEventNotice.new_message if defined?(WCFEventNotice)
  end

  def self.add_image(sender, image, side = nil, id = nil)
    $game_config.add_group_image(group_id(id), sender, image, side)
    WCFEventNotice.new_message if defined?(WCFEventNotice)
  end

  def self.add_system(text, id = nil)
    $game_config.add_group_system(group_id(id), text)
    WCFEventNotice.new_message if defined?(WCFEventNotice)
  end

  def self.add_choice_result(text, value = nil, id = nil)
    $game_config.add_group_choice_result(group_id(id), text, value)
    WCFEventNotice.new_message if defined?(WCFEventNotice)
  end

  def self.clear(id = nil)
    $game_config.clear_group_chat(group_id(id))
  end

  def self.save_entry(gid, entry)
    case entry[:type]
    when :text
      $game_config.add_group_text(gid, entry[:actor], entry[:text], entry[:side])
    when :image
      $game_config.add_group_image(gid, entry[:actor], entry[:image], entry[:side])
    when :system
      $game_config.add_group_system(gid, entry[:text])
    end
  end
end
#==============================================================================
# ** Scene_Menu Group Chat Display Patch
#==============================================================================

class Scene_Menu < Scene_MenuBase
  alias pmgc_create_contacts_sprites create_contacts_sprites
  alias pmgc_refresh_contacts refresh_contacts
  alias pmgc_update_contact_selection update_contact_selection
  alias pmgc_update_message_view update_message_view
  alias pmgc_show_contact_details show_contact_details

  def pmgc_entries
    list = []

    PhoneMenu::CONTACTS.each do |id, data|
      list << {
        :kind => :normal,
        :id => id,
        :name => data[0],
        :info => data[1],
        :avatar => "#{PhoneMenu::ICON_CONTACT_PREFIX}#{id}",
        :members => {},
        :messages => data[2]
      }
    end

    if $game_config && $game_config.phone_group_chats
      $game_config.phone_group_chats.each do |id, data|
        list << {
          :kind => :group,
          :id => id,
          :name => data[:name],
          :info => data[:info],
          :avatar => data[:avatar],
          :members => data[:members] || {},
          :messages => data[:messages] || []
        }
      end
    end

    list
  end

  def pmgc_current_entry
    @pmgc_entries = pmgc_entries
    @pmgc_entries[@selected_contact + @contact_index]
  end

  def create_contacts_sprites
    @pmgc_entries = pmgc_entries
    dispose_sprite_array(@contact_sprites)
    dispose_sprite_array(@contact_names)
    dispose_sprite_array(@contact_panels)
    dispose_sprite_array(@contact_messages)
    if @contact_info
      @contact_info.bitmap.dispose if @contact_info.bitmap && !@contact_info.bitmap.disposed?
      @contact_info.dispose unless @contact_info.disposed?
    end
    @contact_sprites, @contact_names, @contact_panels, @contact_messages = [], [], [], []
    @contact_info = Sprite.new
    @contact_info.bitmap = Bitmap.new(PhoneMenu::PHONE_WIDTH, PhoneMenu::PHONE_HEIGHT)
    @contact_info.x, @contact_info.y, @contact_info.z = PhoneMenu::PHONE_X, PhoneMenu::PHONE_Y, 150
    @contact_info.visible = false
    entries = @pmgc_entries[[@contact_index, 0].max, PhoneMenu::MAX_CONTACTS_DISPLAYED] || []
    entries.each_with_index do |entry, index|
      y = PhoneMenu::CONTACT_ICON_Y + index * PhoneMenu::CONTACT_SPACING
      panel = Sprite.new
      panel.bitmap = Bitmap.new(288, 84)
      phone_card(panel.bitmap, 0, 0, 288, 84, index == @selected_contact)
      panel.x, panel.y, panel.z, panel.visible = PhoneMenu::PHONE_X + 24, y, 96, false
      @contact_panels << panel

      sprite = Sprite.new
      sprite.bitmap = Cache.load_bitmap("Graphics/PhoneMenu/", entry[:avatar]).clone
      sprite.zoom_x = sprite.zoom_y = 44.0 / [sprite.bitmap.width, sprite.bitmap.height].max
      sprite.x, sprite.y, sprite.z, sprite.visible = PhoneMenu::CONTACT_ICON_X, y + 20, 100, false
      @contact_sprites << sprite

      name_sprite = Sprite.new
      name_sprite.bitmap = Bitmap.new(208, 76)
      phone_text(name_sprite.bitmap, 0, 0, 200, 25, entry[:name], 18, nil, 0, true)
      phone_text(name_sprite.bitmap, 0, 26, 200, 18, entry[:info], 12, Color.new(183, 197, 225))
      last = (entry[:messages] || []).last
      last = pmgc_normal_message_to_hash(last) if last
      preview = !last ? "Chưa có tin nhắn" : last[:type] == :image ? "[Hình ảnh]" : last[:text]
      phone_text(name_sprite.bitmap, 0, 47, 200, 20, preview.to_s.gsub(/\s+/, " "), 13, Color.new(220, 228, 246))
      name_sprite.x, name_sprite.y, name_sprite.z = PhoneMenu::PHONE_X + 92, y + 4, 101
      name_sprite.visible = false
      @contact_names << name_sprite
    end
  end

  def refresh_contacts
    restore_current_background
    set_overlay_opacity(PhoneMenu::SUB_OVERLAY_OPACITY)
    create_contacts_sprites
    @contact_info.bitmap.clear
    draw_contacts_header
    if @pmgc_entries.empty?
      phone_text(@contact_info.bitmap, 24, 180, 288, 30, "Chưa có cuộc trò chuyện", 17, nil, 1)
    end
    [@contact_panels, @contact_sprites, @contact_names].each do |sprites|
      sprites.each { |sprite| sprite.visible = true }
    end
    @contact_info.visible = true
  end

  def update_contact_selection
    @pmgc_entries = pmgc_entries
    max_index = [0, @pmgc_entries.size - PhoneMenu::MAX_CONTACTS_DISPLAYED].max

    if Input.repeat?(:UP)
      if @selected_contact > 0
        @selected_contact -= 1
      elsif @contact_index > 0
        @contact_index -= 1
        @selected_contact = 0
      end
      RPG::SE.new(PhoneMenu::SELECT_SE).play
      refresh_contacts
    elsif Input.repeat?(:DOWN)
      if @selected_contact < PhoneMenu::MAX_CONTACTS_DISPLAYED - 1 &&
         @selected_contact + @contact_index < @pmgc_entries.size - 1
        @selected_contact += 1
      elsif @contact_index < max_index
        @contact_index += 1
        @selected_contact = [PhoneMenu::MAX_CONTACTS_DISPLAYED - 1,
                             @pmgc_entries.size - @contact_index - 1].min
      end
      RPG::SE.new(PhoneMenu::SELECT_SE).play
      refresh_contacts
    elsif Input.trigger?(:C)
      return if @pmgc_entries.empty?
      @in_message_view = true
      @message_index = 0
      show_contact_details
    elsif Input.trigger?(:B)
      close_contacts_screen
    end
  end

  def update_message_view
    entry = pmgc_current_entry
    return unless entry
    messages = entry[:messages] || []
    current = messages[@message_index]
    current = pmgc_normal_message_to_hash(current) if current
    offset = @message_line_offset || 0
    if Input.repeat?(:UP)
      if offset > 0 && current
        @message_line_offset = [offset - pmgc_page_lines(current), 0].max
      elsif @message_index > 0
        @message_index -= 1
        @message_line_offset = 0
      else
        return
      end
      Sound.play_cursor
      show_contact_details
    elsif Input.repeat?(:DOWN)
      if current && current[:type] != :image &&
          offset + pmgc_page_lines(current) < pmgc_wrap_text(current[:text], 0).size
        @message_line_offset = offset + pmgc_page_lines(current)
      elsif @message_index < messages.size - 1
        @message_index += 1
        @message_line_offset = 0
      else
        return
      end
      Sound.play_cursor
      show_contact_details
    elsif Input.trigger?(:B)
      @in_message_view = false
      @message_index = @message_line_offset = 0
      refresh_contacts
      show_contacts_sprites
    end
  end

  def pmgc_normal_message_to_hash(message)
    return message if message.is_a?(Hash)
    sender, text = message
    {
      :type => :text,
      :sender => sender,
      :text => text.to_s,
      :side => sender == :main ? :right : :left
    }
  end

  def pmgc_sender_name(entry, sender)
    return "Quỳ" if sender == :main || sender == :quy
    return entry[:members][sender][0] if entry[:members] && entry[:members][sender]
    return entry[:name] if entry[:kind] == :normal
    sender.to_s
  end

  def pmgc_sender_avatar(entry, sender, fallback_id = nil)
    return PhoneMenu::ICON_MAIN_CHARACTER if sender == :main
    if entry[:members] && entry[:members][sender]
      return entry[:members][sender][1]
    end
    return "Contact_Quy" if sender == :quy
    return "#{PhoneMenu::ICON_CONTACT_PREFIX}#{fallback_id}" if fallback_id
    "#{PhoneMenu::ICON_CONTACT_PREFIX}#{sender}"
  end

  def pmgc_main_message?(message)
    message[:side] == :right || message[:sender] == :main || message[:sender] == :quy
  end

  def pmgc_shadow_text(bitmap, x, y, w, h, text, align = 0)
    old_color = bitmap.font.color
    bitmap.font.outline = false
    bitmap.font.color = Color.new(0, 0, 0, 160)
    bitmap.draw_text(x + 1, y + 1, w, h, text, align)
    bitmap.font.color = old_color
    bitmap.draw_text(x, y, w, h, text, align)
  end

  def pmgc_wrap_text(text, max_chars)
    # Fit the actual font, including Vietnamese accents, rather than a character count.
    width = PhoneMenu::MESSAGE_MAX_WIDTH - PhoneMenu::MESSAGE_PADDING_X * 2
    @phone_wrap_cache ||= {}
    key = [text.to_s.dup, width]
    return @phone_wrap_cache[key] if @phone_wrap_cache.has_key?(key)
    lines = []
    text.to_s.split("\n", -1).each do |paragraph|
      current = ""
      paragraph.split(/[ \t]+/).each do |word|
        candidate = current.empty? ? word : current + " " + word
        if simple_text_width(candidate, 17) <= width
          current = candidate
          next
        end
        lines << current unless current.empty?
        current = ""
        word.scan(/\P{M}\p{M}*/).each do |cluster|
          if !current.empty? && simple_text_width(current + cluster, 17) > width
            lines << current
            current = ""
          end
          current += cluster
        end
      end
      lines << current
    end
    result = lines.empty? ? [""] : lines
    @phone_wrap_cache.shift if @phone_wrap_cache.size >= 32
    @phone_wrap_cache[key] = result
  end

  def pmgc_message_height(message)
    return 146 if message[:type] == :image
    lines = message[:_phone_lines] || pmgc_wrap_text(message[:text], 0)
    case message[:type]
    when :system, :choice, :choice_result
      lines.size * 20 + 16
    else
      lines.size * PhoneMenu::MESSAGE_LINE_SPACING + PhoneMenu::MESSAGE_PADDING_Y * 2 + 22
    end
  end

  def pmgc_page_lines(message)
    height = PhoneMenu::MESSAGE_BOTTOM_LIMIT - PhoneMenu::CONTACT_MESSAGE_Y
    notice = [:system, :choice, :choice_result].include?(message[:type])
    [(height - (notice ? 16 : 42)) / (notice ? 20 : PhoneMenu::MESSAGE_LINE_SPACING), 1].max
  end

  def pmgc_visible_messages(messages, start_index)
    result = []
    y = PhoneMenu::CONTACT_MESSAGE_Y
    i = start_index
    while i < messages.size
      msg = pmgc_normal_message_to_hash(messages[i])
      if i == start_index && msg[:type] != :image
        lines = pmgc_wrap_text(msg[:text], 0)
        limit = pmgc_page_lines(msg)
        if lines.size > limit
          msg = msg.dup
          msg[:_phone_lines] = lines[(@message_line_offset || 0), limit] || [""]
          msg[:_phone_continued] = true
        end
      end
      height = pmgc_message_height(msg)
      break if y + height > PhoneMenu::MESSAGE_BOTTOM_LIMIT
      result << [msg, y]
      break if msg[:_phone_continued]
      y += height + PhoneMenu::MESSAGE_SPACING
      i += 1
    end
    result
  end

  def show_contact_details
    entry = pmgc_current_entry
    return unless entry
    cursor = [@selected_contact + @contact_index, @message_index]
    @message_line_offset = 0 unless @phone_message_cursor == cursor
    @phone_message_cursor = cursor
    set_overlay_opacity(PhoneMenu::MESSAGE_OVERLAY_OPACITY)
    refresh_phone_background(PhoneMenu::MESSAGE_BACKGROUND)
    [@contact_panels, @contact_sprites, @contact_names].each do |sprites|
      sprites.each { |sprite| sprite.visible = false } if sprites
    end
    bmp = @contact_info.bitmap
    bmp.clear
    phone_card(bmp, 24, 24, 288, 54)
    phone_text(bmp, 36, 28, 264, 27, entry[:name], 20, nil, 1, true)
    subtitle = "Lịch sử trò chuyện"
    current = (entry[:messages] || [])[@message_index]
    if current
      current = pmgc_normal_message_to_hash(current)
      if current[:type] != :image
        count = pmgc_wrap_text(current[:text], 0).size
        limit = pmgc_page_lines(current)
        subtitle = "Tin nhắn dài · phần #{@message_line_offset / limit + 1}/#{(count.to_f / limit).ceil}" if count > limit
      end
    end
    phone_text(bmp, 36, 55, 264, 18, subtitle, 12, Color.new(187, 201, 226), 1)
    phone_footer(bmp, "↑↓: cuộn   X: danh bạ")
    @contact_info.visible = true
    dispose_sprite_array(@contact_messages)
    @contact_messages = []
    messages = entry[:messages] || []
    if messages.empty?
      phone_text(bmp, 24, 180, 288, 30, "Chưa có tin nhắn", 17, nil, 1)
    end
    pmgc_visible_messages(messages, @message_index).each do |message, y|
      case message[:type]
      when :system, :choice, :choice_result
        color = message[:type] == :system ? Color.new(209, 220, 245) : Color.new(255, 224, 164)
        pmgc_draw_center_notice(message[:text], y, color, message[:_phone_lines])
      when :image
        pmgc_draw_image_message(entry, message, y)
      else
        pmgc_draw_text_message(entry, message, y)
      end
    end
  end

  def pmgc_draw_center_notice(text, y, color, lines = nil)
    lines ||= pmgc_wrap_text(text, 0)
    sprite = Sprite.new
    sprite.bitmap = Bitmap.new(272, lines.size * 20 + 16)
    fill_round_rect(sprite.bitmap, 0, 0, sprite.bitmap.width, sprite.bitmap.height, 10, Color.new(26, 37, 58, 230))
    lines.each_with_index do |line, index|
      phone_text(sprite.bitmap, 12, 8 + index * 20, 248, 20, line, 14, color, 1)
    end
    sprite.x, sprite.y, sprite.z = PhoneMenu::PHONE_X + 32, y, 110
    @contact_messages << sprite
  end

  def pmgc_draw_image_message(entry, message, y)
    sender = message[:sender]
    is_main = pmgc_main_message?(message)
    avatar = pmgc_sender_avatar(entry, sender, entry[:id])
    name = pmgc_sender_name(entry, sender)

    pic = Cache.load_bitmap("Graphics/Pictures/", message[:image])
    max_w = 150
    max_h = 110
    scale = [max_w.to_f / pic.width, max_h.to_f / pic.height, 1.0].min
    img_w = (pic.width * scale).to_i
    img_h = (pic.height * scale).to_i

    img_x = is_main ? PhoneMenu::MESSAGE_RIGHT_BUBBLE_RIGHT - img_w : PhoneMenu::MESSAGE_LEFT_BUBBLE_X
    icon_x = is_main ? PhoneMenu::MESSAGE_RIGHT_ICON_X : PhoneMenu::MESSAGE_LEFT_ICON_X

    name_sprite = pmgc_name_sprite(name, img_x, y, is_main, img_w)
    @contact_messages << name_sprite

    img_sprite = Sprite.new
    img_sprite.bitmap = Bitmap.new(img_w, img_h)
    img_sprite.bitmap.stretch_blt(img_sprite.bitmap.rect, pic, pic.rect)
    img_sprite.x = img_x
    img_sprite.y = y + 22
    img_sprite.z = 100
    @contact_messages << img_sprite

    icon_sprite = pmgc_icon_sprite(avatar, icon_x, img_sprite.y + img_h - PhoneMenu::MESSAGE_ICON_SIZE)
    @contact_messages << icon_sprite
  end

  def pmgc_draw_text_message(entry, message, y)
    sender = message[:sender]
    is_main = pmgc_main_message?(message)
    lines = message[:_phone_lines] || pmgc_wrap_text(message[:text], 0)
    longest = lines.map { |line| simple_text_width(line, 17) }.max || 0
    bubble_w = [[longest + PhoneMenu::MESSAGE_PADDING_X * 2, PhoneMenu::MESSAGE_MIN_WIDTH].max,
      PhoneMenu::MESSAGE_MAX_WIDTH].min
    bubble_h = lines.size * PhoneMenu::MESSAGE_LINE_SPACING + PhoneMenu::MESSAGE_PADDING_Y * 2
    bubble_x = is_main ? PhoneMenu::MESSAGE_RIGHT_BUBBLE_RIGHT - bubble_w : PhoneMenu::MESSAGE_LEFT_BUBBLE_X
    icon_x = is_main ? PhoneMenu::MESSAGE_RIGHT_ICON_X : PhoneMenu::MESSAGE_LEFT_ICON_X
    @contact_messages << pmgc_name_sprite(pmgc_sender_name(entry, sender), bubble_x, y, is_main, bubble_w)
    bubble = Sprite.new
    bubble.bitmap = make_round_rect_bitmap(bubble_w, bubble_h, 12,
      is_main ? Color.new(78, 96, 159, 248) : Color.new(230, 236, 249, 248))
    bubble.x, bubble.y, bubble.z = bubble_x, y + 22, 99
    lines.each_with_index do |line, index|
      phone_text(bubble.bitmap, PhoneMenu::MESSAGE_PADDING_X,
        PhoneMenu::MESSAGE_PADDING_Y + index * PhoneMenu::MESSAGE_LINE_SPACING,
        bubble_w - PhoneMenu::MESSAGE_PADDING_X * 2, 22, line, 17,
        is_main ? Color.new(255, 255, 255) : Color.new(25, 37, 59))
    end
    @contact_messages << bubble
    @contact_messages << pmgc_icon_sprite(pmgc_sender_avatar(entry, sender, entry[:id]),
      icon_x, bubble.y + bubble_h - PhoneMenu::MESSAGE_ICON_SIZE)
  end

  def pmgc_name_sprite(name, x, y, is_main, width = PhoneMenu::MESSAGE_MAX_WIDTH)
    sprite = Sprite.new
    sprite.bitmap = Bitmap.new(width, 22)
    phone_text(sprite.bitmap, 0, 0, width, 20, name, 13, Color.new(199, 211, 237), is_main ? 2 : 0, true)
    sprite.x, sprite.y, sprite.z = x, y, 102
    sprite
  end

  def pmgc_icon_sprite(filename, x, y)
    sprite = Sprite.new
    sprite.bitmap = Cache.load_bitmap("Graphics/PhoneMenu/", filename).clone
    sprite.x, sprite.y, sprite.z = x, y, 101
    scale = PhoneMenu::MESSAGE_ICON_SIZE.to_f / [sprite.bitmap.width, sprite.bitmap.height].max
    sprite.zoom_x = sprite.zoom_y = scale
    sprite
  end
end

#==============================================================================
# ** Group Chat Choice Result Save Fix
#------------------------------------------------------------------------------
# Put this BELOW:
# 1. Simple Cutscene Phone Chat
# 2. Phone Menu Saved Group Chat Patch
#==============================================================================

class Game_SimplePhoneChat
  attr_accessor :selected_choice_value
  attr_accessor :selected_choice_text
  attr_accessor :selected_branch_entries
end

class Scene_SimplePhoneChat < Scene_Base
  def apply_choice
    choice = @chat.choices[@choice_index]
    return unless choice

    # This patch is loaded after the base phone-chat scene. Delegate all route
    # state side effects to the shared helper instead of reimplementing only a
    # subset of them.
    value = commit_choice_side_effects(choice)

    @chat.selected_choice_value = value
    @chat.selected_choice_text = choice[:text]
    @chat.selected_branch_entries = @chat.choice_branches[value] || []

    @branch_used = true
    @choice_active = false

    @active_entries += @chat.selected_branch_entries

    Sound.play_ok
    refresh_footer
    refresh_choices
  end
end

module PhoneGroupChatSave
  def self.save_current_cutscene(id = nil)
    gid = group_id(id)
    chat = $game_temp.group_chat_data
    return unless chat

    group = $game_config.ensure_group_chat(gid)
    group[:messages].clear

    if chat.respond_to?(:actors)
      chat.actors.each do |actor_id, data|
        group[:members][actor_id] = [data[:name], data[:avatar]]
      end
    end

    if chat.respond_to?(:entries)
      chat.entries.each do |entry|
        save_entry(gid, entry)
      end
    end

    WCFEventNotice.new_message if defined?(WCFEventNotice)

    result = nil
    result = chat.selected_choice_value if chat.respond_to?(:selected_choice_value)
    result = GroupChat.result if result.nil? && defined?(GroupChat) && GroupChat.respond_to?(:result)
    result = $game_temp.group_chat_result if result.nil?

    return unless result

    choice_text = nil
    choice_text = chat.selected_choice_text if chat.respond_to?(:selected_choice_text)
    if choice_text.nil? && chat.respond_to?(:choices)
      chosen = chat.choices.find { |c| c[:value] == result }
      choice_text = chosen[:text] if chosen
    end

    choice_text ||= result.to_s

    $game_config.add_group_choice_result(
      gid,
      "Quỳ chọn: #{choice_text}",
      result
    )

    branch_entries = []
    if chat.respond_to?(:selected_branch_entries) && chat.selected_branch_entries
      branch_entries = chat.selected_branch_entries
    elsif chat.respond_to?(:choice_branches) && chat.choice_branches[result]
      branch_entries = chat.choice_branches[result]
    end

    branch_entries.each do |entry|
      save_entry(gid, entry)
    end
  end
end
#==============================================================================
# WCF Phone Save / Load
# Narrative save cards. Keep this section in Custom Menu after the gallery hooks.
# No new script slot, map edits, or changes to save contents / load-success hooks.
#==============================================================================
module WCFPhoneSaveRecord
  VERSION = 1
  RECIPIENTS = {1=>"Leo", 2=>"Kohi", 3=>"Shylvie", 4=>"Hakase"}
  MARKET_GIFTS = {1=>"Máy pha cà phê", 2=>"Dao và chảo", 3=>"Khăn len", 4=>"Bộ phá khóa"}
  LEO_GIFTS = {1=>["Cà phê Luminous", "Kohi"],
    2=>["Khiên", "Shylvie"], 3=>["Áo choàng tàng hình", "Hakase"]}
  JEWEL_GIFTS = {1=>["Purple Garnet", "Leo"], 2=>["Kim cương cà phê", "Kohi"],
    3=>["Congo Tourmaline", "Shylvie"], 4=>["Rainbow Fluorite", "Hakase"]}
  LOCATIONS = {
    3=>"Văn phòng Silverwing", 6=>"Thành phố", 10=>"Xe buýt",
    13=>"Văn phòng Wanderer", 14=>"Bếp Wanderer", 15=>"Phòng tắm Wanderer",
    17=>"Hành lang Silverwing", 19=>"Siêu thị", 20=>"Quán mì cay",
    21=>"Atlantis", 22=>"Nhà Hải Quỳ", 23=>"Tiệm sách Atlantis",
    24=>"Bãi rác trong ký ức", 25=>"Atlantis", 26=>"Phòng kho nhà Hải Quỳ",
    28=>"Mê cung gương Atlantis", 29=>"Hành lang Atlantis", 34=>"Mê cung gương Atlantis",
    35=>"Phòng Hải Quỳ", 36=>"Sau câu chuyện", 37=>"Phòng Hải Quỳ",
    38=>"Văn phòng Wanderer", 39=>"Văn phòng Wanderer", 40=>"Atlantis",
    41=>"Phòng Hải Quỳ ở nhà", 42=>"Phòng Hải Quỳ", 43=>"Phòng Shylvie",
    44=>"Phòng Leo", 45=>"Phòng Hakase", 46=>"Phòng Kohi", 47=>"Phòng Hải Quỳ",
    48=>"Văn phòng Wanderer", 49=>"Phòng Hải Quỳ", 50=>"Bên ngoài Wanderer",
    51=>"Phòng Hải Quỳ", 52=>"Văn phòng Wanderer", 53=>"Atlantis",
    54=>"Văn phòng Wanderer", 55=>"Atlantis", 56=>"Trạm xe buýt",
    57=>"Tiệm ma pháp", 58=>"Cà phê Luminous", 59=>"Cửa hàng vũ khí",
    60=>"Phòng Hải Quỳ", 61=>"Phòng họp Wanderer", 62=>"Phòng họp Wanderer",
    63=>"Phòng chế tạo Wanderer", 64=>"Tiệm đá phong thủy", 65=>"Phòng Hải Quỳ",
    66=>"Văn phòng Wanderer", 67=>"Bếp Wanderer", 69=>"Test Hub"
  }
  PHASES = {3=>"Một ngày ở Silverwing", 6=>"Trên đường về", 10=>"Chuyến xe buýt",
    13=>"Tìm quà Giáng sinh", 17=>"Rời Silverwing", 19=>"Chọn quà ở siêu thị",
    20=>"Mì cay cho Leo", 21=>"Đến Atlantis", 22=>"Về nhà", 23=>"Tiệm sách Atlantis",
    24=>"Ký ức", 25=>"Sau cuộc rượt đuổi", 26=>"Khám phá phòng kho",
    28=>"Mê cung gương", 29=>"Cuộc rượt đuổi", 34=>"Giữa vòng vây",
    35=>"Đêm muộn", 36=>"Sau câu chuyện", 37=>"Chuẩn bị quà",
    38=>"Tiệc Giáng sinh", 39=>"Sáng hôm sau", 40=>"Tìm cà phê Atlantis",
    47=>"Chuẩn bị quà", 48=>"Tiệc Giáng sinh", 49=>"Chuẩn bị quà",
    50=>"Sau bữa tiệc", 51=>"Chuẩn bị quà", 52=>"Sau bữa tiệc",
    53=>"Tại Atlantis", 54=>"Tìm Hải Quỳ", 55=>"Giải cứu Hải Quỳ",
    56=>"Đi mua quà", 57=>"Khám phá tiệm ma pháp", 58=>"Ghé cà phê Luminous",
    59=>"Chọn quà ở cửa hàng vũ khí", 60=>"Chuẩn bị quà",
    64=>"Chọn đá phong thủy", 65=>"Chuẩn bị quà", 66=>"Tiệc Giáng sinh",
    67=>"Sáng hôm sau", 69=>"Điểm bắt đầu thử nghiệm"}

  def self.number(variables, id)
    value = variables && variables[id]
    value.is_a?(Numeric) ? value.to_i : 0
  end

  def self.on?(switches, id)
    switches && switches[id] == true
  end

  def self.route(switches, variables, map_id)
    choices = []
    choices << "Siêu thị" if [44,45,46].any? { |id| on?(switches,id) }
    choices << "Mì cay" if on?(switches,55) || on?(switches,57)
    choices << "Sách dịch chuyển" if on?(switches,61) || on?(switches,65)
    choices << "Sách Ma Vương" if on?(switches,66) || on?(switches,69)
    choices << "Chủ tiệm sách" if on?(switches,70) || on?(switches,71)
    choices << "Gợi ý của Leo" if on?(switches,72) || on?(switches,75)
    choices << "Gợi ý của Shylvie" if on?(switches,76) || on?(switches,79)
    return choices.first if choices.size == 1
    return "Chưa xác định" if choices.size > 1
    return "Thử nghiệm" if map_id == 69
    return "Phòng kho" if on?(switches,42) || [24,25,26,28,29,34,35].include?(map_id)
    return "Atlantis" if on?(switches,30) || [21,22,23,41].include?(map_id)
    "Chưa chọn"
  end

  def self.gift(switches, variables, map_id = 0)
    candidates = []
    if on?(switches, 44) || on?(switches, 45) || on?(switches, 46)
      name = MARKET_GIFTS[number(variables, 42)]
      recipient = RECIPIENTS[number(variables, 43)]
      candidates << [name, recipient, on?(switches, 45)] if name && recipient
    end
    if on?(switches, 55) || on?(switches, 57)
      candidates << ["Mì cay", "Leo", on?(switches, 57)]
    end
    if on?(switches, 61) || on?(switches, 65)
      candidates << ["Sách dịch chuyển", "Shylvie",
        on?(switches, 65) || number(variables, 52) >= 5]
    end
    if on?(switches, 66) || on?(switches, 69)
      candidates << ["Sách Ma Vương Cổ Đại", "Hakase",
        on?(switches, 69) || number(variables, 53) >= 5]
    end
    if on?(switches, 72) || on?(switches, 75)
      pair = LEO_GIFTS[number(variables, 55)]
      # Shops 57/58 also use stage 2 for free exploration before checkout.
      stage = number(variables, 56)
      bought = stage >= 3 || (stage >= 2 && ![56,57,58].include?(map_id))
      candidates << [pair[0], pair[1], on?(switches, 75)] if pair && bought
    end
    if on?(switches, 76) || on?(switches, 79)
      pair = JEWEL_GIFTS[number(variables, 57)]
      candidates << [pair[0], pair[1], on?(switches, 79) || number(variables, 58) >= 4] if
        pair && number(variables, 58) >= 2
    end
    # A stale/debug save with competing routes must never claim a guessed gift.
    candidates.size == 1 ? candidates.first : nil
  end

  def self.describe(map, switches, variables, playtime = "—")
    map_id = map && map.respond_to?(:map_id) ? map.map_id : 0
    location = LOCATIONS[map_id]
    if !location && map && map.respond_to?(:display_name)
      location = map.display_name.to_s.strip
    end
    location = "Địa điểm chưa xác định" if !location || location.empty?
    title = PHASES[map_id]
    if [14,15,42,43,44,45,46,61,62,63].include?(map_id)
      christmas = [48,58,62,67,73,77].any? { |id| on?(switches,id) }
      title = christmas ? "Tiệc Giáng sinh" : "Khám phá Wanderer"
      title = "Nấu mì cay" if map_id == 14 && on?(switches,55) && number(variables,51) == 3
    end
    title ||= map_id == 41 ? "Về nhà" : "Hành trình của Hải Quỳ"
    chosen = gift(switches, variables, map_id)
    result = {:version=>VERSION, :map_id=>map_id, :location=>location,
      :title=>title, :route=>route(switches,variables,map_id), :playtime=>playtime.to_s,
      :gift=>"", :recipient=>"", :given=>false}
    if chosen
      result[:gift], result[:recipient], result[:given] = chosen
    end
    result
  end

  def self.capture
    playtime = $game_system ? $game_system.playtime_s : "—"
    result = describe($game_map, $game_switches, $game_variables, playtime)
    result[:saved_at] = Time.now.to_i
    result
  end

  def self.from_header(header)
    stored = header[:wcf_phone_save]
    if stored.is_a?(Hash) && stored[:version] == VERSION &&
        [:title,:location,:playtime,:gift,:recipient].all? { |key| stored[key].is_a?(String) } &&
        (stored[:saved_at].nil? || stored[:saved_at].is_a?(Integer))
      # Read plain metadata only. Never look at the currently running route.
      result = stored.dup
      result[:route] = route(header[:switches],header[:variables],stored[:map_id]) unless
        result[:route].is_a?(String) && !result[:route].empty?
      return result
    end
    describe(header[:map], header[:switches], header[:variables], header[:playtime_s] || "—")
  end

  def self.gift_text(record)
    return "Đang tìm quà Giáng sinh" if record[:gift].to_s.empty? &&
      [10,13,19,20,23,56,57,58,59,64].include?(record[:map_id])
    return "" if record[:gift].to_s.empty?
    prefix = record[:given] ? "Đã tặng: " : ""
    "#{prefix}#{record[:gift]} → #{record[:recipient]}"
  end
end

module DataManager
  class << self
    alias wcf_phone_make_save_header make_save_header
  end
  def self.make_save_header
    header = wcf_phone_make_save_header
    header[:wcf_phone_save] = WCFPhoneSaveRecord.capture
    header
  end
end

module WCFPhoneSaveStore
  # Yanfly headers contain complete game objects. Retain only plain card data,
  # and read only the visible slots when changing page.
  def self.read(index)
    path = DataManager.make_filename(index)
    return {:state=>:empty} unless File.exist?(path)
    header = DataManager.load_header(index)
    return {:state=>:invalid} unless header.is_a?(Hash)
    record = WCFPhoneSaveRecord.from_header(header)
    record[:saved_at] ||= File.mtime(path).to_i
    {:state=>:ready, :record=>record}
  rescue StandardError
    {:state=>:invalid}
  end

  def self.write(index)
    path = DataManager.make_filename(index)
    backup = path + ".phone-backup"
    # The stock rescue deletes a failed save. Preserve an occupied slot first.
    return false if File.exist?(backup)
    previous = File.exist?(path)
    if previous
      bytes = File.binread(path)
      File.open(backup, "wb") { |file| file.write(bytes) }
    end
    success = begin
      DataManager.save_game(index)
    rescue StandardError
      false
    end
    if !success && previous
      File.open(path, "wb") { |file| file.write(File.binread(backup)) }
    end
    File.delete(backup) if previous && File.exist?(backup)
    success
  rescue StandardError
    # A restore failure leaves the backup on disk for recovery.
    false
  end

  def self.delete(index)
    DataManager.delete_save_file(index)
    !File.exist?(DataManager.make_filename(index))
  rescue StandardError
    false
  end
end

module WCFPhoneSaveDrawing
  def ps_wrapped(bitmap, x, y, width, text, size, line_height, max_lines, color = nil, bold = false)
    bitmap.font.name, bitmap.font.size, bitmap.font.bold = PhoneMenu::UI_FONT,size,bold
    words = text.to_s.split(/\s+/)
    lines = [""]
    words.each_with_index do |word,index|
      trial = lines[-1].empty? ? word : lines[-1]+" "+word
      if bitmap.text_size(trial).width <= width || lines[-1].empty?
        lines[-1] = trial
      elsif lines.size < max_lines
        lines << word
      else
        lines[-1] += " "+words[index..-1].join(" ")
        break
      end
    end
    lines.each_with_index do |line,index|
      ps_text(bitmap,x,y+index*line_height,width,line_height,line,size,color,0,bold)
    end
  end

  def ps_round(bitmap, x, y, w, h, radius, color)
    radius = [radius, w / 2, h / 2].min
    bitmap.fill_rect(x + radius, y, w - radius * 2, h, color)
    bitmap.fill_rect(x, y + radius, w, h - radius * 2, color)
    [[x+radius,y+radius], [x+w-radius-1,y+radius],
      [x+radius,y+h-radius-1], [x+w-radius-1,y+h-radius-1]].each do |cx,cy|
      (-radius..radius).each do |dy|
        dx = Math.sqrt(radius * radius - dy * dy).to_i
        bitmap.fill_rect(cx-dx,cy+dy,dx*2+1,1,color)
      end
    end
  end

  def ps_text(bitmap, x, y, w, h, text, size = 14, color = nil, align = 0, bold = false)
    bitmap.font.name = PhoneMenu::UI_FONT
    bitmap.font.size, bitmap.font.bold = size, bold
    bitmap.font.italic = bitmap.font.shadow = bitmap.font.outline = false
    bitmap.font.color = color || Color.new(245,246,255)
    value = text.to_s
    if bitmap.text_size(value).width > w
      clusters = value.scan(/\P{M}\p{M}*/)
      clusters.pop while !clusters.empty? && bitmap.text_size(clusters.join + "…").width > w
      value = clusters.join + "…"
    end
    bitmap.draw_text(x,y,w,h,value,align)
  end

  def ps_card(bitmap, x, y, w, h, selected = false)
    ps_round(bitmap,x,y,w,h,12,selected ? Color.new(174,186,255) : Color.new(119,140,181,65))
    ps_round(bitmap,x+1,y+1,w-2,h-2,11,
      selected ? Color.new(53,66,111,245) : Color.new(18,28,47,235))
  end
end

class Scene_File < Scene_MenuBase
  include WCFPhoneSaveDrawing
  attr_writer :wcf_phone_origin
  PS_PER_PAGE = 2
  PS_WIDTH = 460
  PS_HEIGHT = 336
  PS_X = (Graphics.width - PS_WIDTH) / 2
  PS_Y = (Graphics.height - PS_HEIGHT) / 2
  PS_ROTATION_FRAMES = 24

  alias wcf_phone_file_update update
  alias wcf_phone_file_return return_scene

  def create_background
    @ps_owned_sprites = []
    @ps_backdrop = ps_sprite(Graphics.width,Graphics.height,10)
    source = SceneManager.background_bitmap
    @ps_backdrop.bitmap.blt(0,0,source,source.rect) if source
    @ps_backdrop.color.set(8,12,24,190)
    @background_sprite = ps_sprite(PhoneMenu::PHONE_WIDTH,PhoneMenu::PHONE_HEIGHT,50)
    art = Cache.load_bitmap("Graphics/PhoneMenu/",PhoneMenu::BACKGROUND)
    @background_sprite.bitmap.stretch_blt(@background_sprite.bitmap.rect,art,art.rect)
    @background_sprite.ox = PhoneMenu::PHONE_WIDTH / 2
    @background_sprite.oy = PhoneMenu::PHONE_HEIGHT / 2
    @background_sprite.x, @background_sprite.y = Graphics.width / 2,Graphics.height / 2
    @ps_overlay = ps_sprite(PhoneMenu::PHONE_WIDTH,PhoneMenu::PHONE_HEIGHT,60)
    @ps_overlay.ox = PhoneMenu::PHONE_WIDTH / 2
    @ps_overlay.oy = PhoneMenu::PHONE_HEIGHT / 2
    @ps_overlay.x, @ps_overlay.y = Graphics.width / 2,Graphics.height / 2
    @ps_overlay_alpha = nil
    ps_apply_overlay_alpha(@wcf_phone_origin == :phone ? PhoneMenu::MAIN_OVERLAY_OPACITY : 240)
  end

  def transition_speed
    # Rotation provides the transition for phone apps. A second engine fade
    # would replace the frozen home screen with a dark blank phone first.
    @wcf_phone_origin == :phone ? 0 : super
  end

  def ps_apply_overlay_alpha(value)
    value = value.round
    return if @ps_overlay_alpha == value
    @ps_overlay_alpha = value
    @ps_overlay.bitmap.clear
    ps_round(@ps_overlay.bitmap,12,16,PhoneMenu::PHONE_WIDTH-24,
      PhoneMenu::PHONE_HEIGHT-32,18,Color.new(9,14,28,value))
  end

  def ps_sprite(w,h,z)
    sprite = Sprite.new
    sprite.bitmap = Bitmap.new(w,h)
    sprite.z = z
    @ps_owned_sprites << sprite
    sprite
  end

  def dispose_background
    Array(@ps_owned_sprites).each do |sprite|
      sprite.bitmap.dispose if sprite.bitmap && !sprite.bitmap.disposed?
      sprite.dispose unless sprite.disposed?
    end
    @ps_owned_sprites = []
    # This project's viewport wrapper does not expose disposed?. Clear our own
    # reference after disposal so cleanup is safe on both RGSS and the wrapper.
    @ps_clip.dispose if @ps_clip
    @ps_clip = nil
  end

  def create_all_windows
    # Sprite UI replaces all four Yanfly windows; its save/load callbacks stay.
    @ps_clip = Viewport.new(PS_X+16,PS_Y+12,PS_WIDTH-32,PS_HEIGHT-24)
    @ps_clip.z = 100
    @ps_panel = ps_sprite(PS_WIDTH,PS_HEIGHT,0)
    @ps_panel.viewport = @ps_clip
    @ps_panel.x, @ps_panel.y = -16,-12
    @ps_index = [[first_savefile_index.to_i,0].max,DataManager.savefile_max-1].min
    @ps_cache = {}
    @ps_mode, @ps_choice, @ps_notice, @ps_notice_timer = :list,0,"",0
    @ps_rotation_mode = @wcf_phone_origin == :phone ? :opening : nil
    @ps_rotation_frame = 0
    @ps_panel.visible = !@ps_rotation_mode
    ps_set_angle(@ps_rotation_mode ? 0 : 90)
    ps_redraw
  end

  def ps_loading?
    is_a?(Scene_Load)
  end

  def ps_slot(index = @ps_index)
    @ps_cache[index] ||= WCFPhoneSaveStore.read(index)
  end

  def ps_page
    @ps_index / PS_PER_PAGE
  end

  def update
    wcf_phone_file_update
    if @ps_rotation_mode
      ps_update_rotation
      return
    end
    if @ps_notice_timer > 0
      @ps_notice_timer -= 1
      if @ps_notice_timer == 0
        @ps_notice = ""
        ps_redraw
      end
    end
    if @ps_mode == :list
      ps_update_list
    else
      ps_update_actions
    end
  end

  def ps_set_angle(angle)
    radians = angle * Math::PI / 180.0
    width = PhoneMenu::PHONE_WIDTH * Math.cos(radians).abs + PhoneMenu::PHONE_HEIGHT * Math.sin(radians).abs
    height = PhoneMenu::PHONE_WIDTH * Math.sin(radians).abs + PhoneMenu::PHONE_HEIGHT * Math.cos(radians).abs
    scale = [1.0,(Graphics.width-20).to_f/width,(Graphics.height-20).to_f/height].min
    [@background_sprite,@ps_overlay].each do |sprite|
      sprite.angle = angle
      sprite.zoom_x = sprite.zoom_y = scale
    end
  end

  def ps_update_rotation
    @ps_rotation_frame += 1
    progress = [@ps_rotation_frame.to_f / PS_ROTATION_FRAMES,1.0].min
    eased = progress * progress * (3.0-2.0*progress)
    closing = @ps_rotation_mode == :closing
    ps_set_angle(90.0 * (closing ? 1.0-eased : eased))
    unless closing
      ps_apply_overlay_alpha(PhoneMenu::MAIN_OVERLAY_OPACITY +
        (240-PhoneMenu::MAIN_OVERLAY_OPACITY)*eased)
    end
    return unless progress >= 1.0
    @ps_rotation_mode = nil
    if closing
      wcf_phone_file_return
    else
      @ps_panel.visible = true
    end
  end

  def return_scene
    return if @ps_rotation_mode
    # Title/direct callers never showed a portrait phone. Return directly in
    # landscape; only a phone app needs the matching rotation back to portrait.
    return wcf_phone_file_return unless @wcf_phone_origin == :phone
    @ps_panel.visible = false
    @ps_rotation_mode, @ps_rotation_frame = :closing,0
  end

  def ps_update_list
    if Input.trigger?(:B)
      Sound.play_cancel
      return return_scene
    end
    return ps_open_actions if Input.trigger?(:C)
    step = 0
    step = 1 if Input.repeat?(:DOWN)
    step = -1 if Input.repeat?(:UP)
    step = PS_PER_PAGE if Input.trigger?(:RIGHT) || Input.trigger?(:R)
    step = -PS_PER_PAGE if Input.trigger?(:LEFT) || Input.trigger?(:L)
    return if step == 0
    old = @ps_index
    @ps_index = [[@ps_index+step,0].max,DataManager.savefile_max-1].min
    if old != @ps_index
      Sound.play_cursor
      ps_redraw
    end
  end

  def ps_open_actions
    slot = ps_slot
    if ps_loading? && slot[:state] == :empty
      Sound.play_buzzer
      ps_notice("Bản lưu này chưa có dữ liệu.")
      return
    end
    @ps_mode, @ps_choice = :actions,0
    Sound.play_ok
    ps_redraw
  end

  def ps_actions
    slot = ps_slot
    actions = [["Quay lại",:back]]
    if ps_loading?
      actions << ["Tiếp tục bản lưu này",:load] if slot[:state] == :ready
    elsif !$game_system.save_disabled
      actions << [slot[:state] == :empty ? "Tạo bản lưu" : "Ghi đè bản lưu",:save]
    end
    actions << ["Xóa bản lưu",:delete] unless slot[:state] == :empty
    actions
  end

  def ps_update_actions
    if Input.trigger?(:B)
      Sound.play_cancel
      @ps_mode, @ps_choice = :list,0
      ps_redraw
      return
    end
    # Confirmation buttons are fixed keyboard shortcuts, not another list.
    # The Z which opens this screen ends in the actions branch below; a fresh
    # Z press confirms on a later update, while X above always cancels first.
    if @ps_mode == :confirm
      ps_execute(@ps_pending) if Input.trigger?(:C)
      return
    end
    max = ps_actions.size
    change = Input.repeat?(:DOWN) || Input.repeat?(:RIGHT) ? 1 : 0
    change = -1 if Input.repeat?(:UP) || Input.repeat?(:LEFT)
    if change != 0
      @ps_choice = (@ps_choice+change) % max
      Sound.play_cursor
      ps_redraw
    end
    return unless Input.trigger?(:C)
    if @ps_choice == 0
      Sound.play_cancel
      @ps_mode = :list
      ps_redraw
    else
      action = ps_actions[@ps_choice][1]
      @ps_pending = action
      @ps_preview = WCFPhoneSaveRecord.capture if action == :save
      @ps_mode, @ps_choice = :confirm,0
      Sound.play_ok
      ps_redraw
    end
  end

  def ps_execute(action)
    case action
    when :save
      # Recheck permissions at execution, as well as when listing actions.
      success = !$game_system.save_disabled && WCFPhoneSaveStore.write(@ps_index)
      on_save_success if success
      ps_finish_action(success,"Đã lưu thành công: Bản lưu %02d." % (@ps_index+1),"Không lưu được. Kiểm tra file lưu.")
    when :load
      if ps_slot[:state] == :ready && DataManager.load_game(@ps_index)
        # Preserve MOG weather, Yanfly limits and GlobalGallery alias chains.
        on_load_success
      else
        ps_finish_action(false,"","Không tải được bản lưu này.")
      end
    when :delete
      success = WCFPhoneSaveStore.delete(@ps_index)
      Sound.play_ok if success
      ps_finish_action(success,"Đã xóa bản lưu.","Không xóa được bản lưu này.")
    end
  end

  def ps_finish_action(success, message, error)
    Sound.play_buzzer unless success
    @ps_cache.delete(@ps_index)
    @ps_mode, @ps_choice = :list,0
    ps_notice(success ? message : error)
  end

  def ps_notice(text)
    @ps_notice, @ps_notice_timer = text,180
    ps_redraw
  end

  def ps_redraw
    bmp = @ps_panel.bitmap
    bmp.clear
    title = ps_loading? ? "Tiếp tục hành trình" : "Lưu hành trình"
    if @ps_mode == :confirm && @ps_pending == :save
      title = ps_slot[:state] == :empty ? "Tạo Bản lưu %02d" : "Ghi đè Bản lưu %02d?"
      title = title % (@ps_index+1)
    end
    if @ps_mode == :confirm && @ps_pending != :save
      title = (@ps_pending == :load ? "Tải Bản lưu %02d?" : "Xóa Bản lưu %02d?") % (@ps_index+1)
    end
    ps_text(bmp,28,18,304,30,title,24,nil,0,true)
    subtitle = @ps_notice.empty? ? "WANDERER · BẢN LƯU" : @ps_notice
    if @ps_mode != :list && @ps_notice.empty? && ps_slot[:record] && ps_slot[:record][:saved_at]
      stamp = Time.at(ps_slot[:record][:saved_at]).strftime("%d/%m/%Y %H:%M")
      subtitle = "Bản hiện có lưu lúc #{stamp}"
    end
    ps_text(bmp,28,49,404,20,subtitle,15,Color.new(187,201,226))
    if @ps_mode == :list
      ps_draw_list(bmp)
    else
      ps_draw_detail(bmp)
    end
    return if @ps_mode == :confirm && @ps_pending == :save
    bmp.fill_rect(28,294,404,1,Color.new(183,198,231,44))
    footer = if @ps_mode == :list
      "↑↓ Chọn  ←→ Trang  Z Mở  X Về"
    elsif @ps_mode == :confirm
      "Z Xác nhận   X Hủy"
    else
      "↑↓ Chọn   Z Mở   X Quay lại"
    end
    ps_text(bmp,28,299,404,22,footer,15,Color.new(202,212,235),1)
  end

  def ps_draw_list(bmp)
    first = ps_page * PS_PER_PAGE
    PS_PER_PAGE.times do |row|
      id = first+row
      break if id >= DataManager.savefile_max
      y = 74+row*108
      ps_card(bmp,26,y,408,104,id == @ps_index)
      slot = ps_slot(id)
      ps_text(bmp,38,y+2,236,22,"Bản lưu %02d" % (id+1),19,nil,0,true)
      if slot[:state] == :ready
        record = slot[:record]
        ps_text(bmp,330,y+2,92,22,record[:playtime],16,Color.new(187,201,226),2)
        ps_text(bmp,38,y+25,384,19,"Route: #{record[:route]}",17)
        ps_text(bmp,38,y+44,384,19,"Mốc truyện: #{record[:title]}",18,nil)
        ps_text(bmp,38,y+63,384,19,"Vị trí hiện tại: #{record[:location]}",17,Color.new(204,216,240))
        gift = WCFPhoneSaveRecord.gift_text(record)
        ps_text(bmp,38,y+82,384,20,gift.empty? ? "" : "Quà: #{gift}",17,Color.new(219,214,255))
      else
        label = slot[:state] == :empty ? "Chưa có bản lưu" : "Không đọc được bản lưu"
        color = slot[:state] == :empty ? Color.new(155,171,201) : Color.new(255,184,170)
        ps_text(bmp,38,y+44,384,24,label,19,color,1)
      end
    end
    pages = (DataManager.savefile_max+PS_PER_PAGE-1)/PS_PER_PAGE
    ps_text(bmp,336,21,96,24,"#{ps_page+1} / #{pages}",18,Color.new(187,201,226),2)
  end

  def ps_draw_record(bmp, record, x, width, label)
    y = 78
    ps_card(bmp,x,y,width,198)
    ps_text(bmp,x+12,y+4,width-24,16,label,14,Color.new(187,201,226))
    ps_text(bmp,x+12,y+21,width-24,19,"Route: #{record[:route]}",16)
    ps_wrapped(bmp,x+12,y+41,width-24,"Mốc: #{record[:title]}",19,19,2,nil,true)
    ps_text(bmp,x+12,y+80,width-24,16,"Vị trí hiện tại:",15,Color.new(187,201,226))
    ps_text(bmp,x+12,y+96,width-24,20,record[:location],width < 220 ? 16 : 18,Color.new(204,216,240))
    gift = record[:gift].to_s
    gift = WCFPhoneSaveRecord.gift_text(record) if gift.empty?
    ps_wrapped(bmp,x+12,y+117,width-24,gift.empty? ? "" : "Quà: #{gift}",17,19,2,Color.new(219,214,255))
    unless record[:recipient].to_s.empty?
      label = record[:given] ? "Đã tặng: #{record[:recipient]}" : "Người nhận: #{record[:recipient]}"
      avatar_width = width >= 250 ? 24 : 0
      ps_text(bmp,x+12,y+155,width-24-avatar_width,20,label,16,Color.new(204,216,240))
      if width >= 250 && WCFPhoneSaveRecord::RECIPIENTS.values.include?(record[:recipient])
        avatar = Cache.load_bitmap("Graphics/PhoneMenu/","Contact_#{record[:recipient]}")
        bmp.stretch_blt(Rect.new(x+width-32,y+155,20,20),avatar,avatar.rect)
      end
    end
    ps_text(bmp,x+12,y+177,width-24,18,"Đã chơi: #{record[:playtime]}",14,Color.new(187,201,226))
  end

  def ps_draw_empty(bmp, slot, x, width, label)
    ps_card(bmp,x,78,width,198)
    ps_text(bmp,x+12,88,width-24,22,label,18,nil,0,true)
    text = slot[:state] == :empty ? "Chưa có bản lưu" : "Dữ liệu không đọc được"
    ps_wrapped(bmp,x+12,132,width-24,text,20,25,3,Color.new(187,201,226))
  end

  def ps_button(bmp, x, y, width, height, label, selected, danger = false)
    ps_card(bmp,x,y,width,height,selected)
    color = danger ? Color.new(255,184,170) : nil
    lines = height > 40 ? 2 : 1
    ps_wrapped(bmp,x+12,y+5,width-24,label,18,22,lines,color,selected)
  end

  def ps_draw_detail(bmp)
    slot = ps_slot
    record = slot[:record]
    confirming_save = @ps_mode == :confirm && @ps_pending == :save
    if confirming_save
      if record
        ps_draw_record(bmp,record,26,198,"Đang có · Bản lưu %02d" % (@ps_index+1))
      else
        ps_draw_empty(bmp,slot,26,198,"Bản lưu %02d" % (@ps_index+1))
      end
      ps_draw_record(bmp,@ps_preview,236,198,"Sẽ lưu")
      save_label = slot[:state] == :empty ? "Lưu (Z)" : "Ghi đè (Z)"
      ps_button(bmp,26,282,198,36,"Hủy (X)",false)
      ps_button(bmp,236,282,198,36,save_label,false)
    else
      if record
        ps_draw_record(bmp,record,26,252,"Bản lưu %02d" % (@ps_index+1))
      else
        ps_draw_empty(bmp,slot,26,252,"Bản lưu %02d" % (@ps_index+1))
      end
      if @ps_mode == :confirm
        warning = if @ps_pending == :delete
          "Xóa vĩnh viễn bản lưu này?"
        elsif @wcf_phone_origin == :phone
          "Tiến độ chưa lưu sẽ bị thay thế."
        else
          "Tiếp tục từ bản lưu này?"
        end
        ps_wrapped(bmp,300,83,124,warning,17,22,4,Color.new(219,214,255))
        ps_button(bmp,290,178,144,40,"Hủy (X)",false)
        label = @ps_pending == :load ? "Tải (Z)" : "Xóa (Z)"
        ps_button(bmp,290,236,144,40,label,false,@ps_pending == :delete)
      else
        ps_actions.each_with_index do |option,index|
          label = {:back=>"Quay lại",:load=>"Tiếp tục",:save=>"Tạo bản lưu",:delete=>"Xóa bản lưu"}[option[1]]
          label = "Ghi đè" if option[1] == :save && slot[:state] != :empty
          ps_button(bmp,290,78+index*66,144,52,label,index == @ps_choice,option[1] == :delete)
        end
      end
    end
  end
end
