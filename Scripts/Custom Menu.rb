#########################################################################
# Custom_PhoneMenu
# Smartphone-themed in-game menu screen
#-----------------------------------------------------------------------#
# Conflict Level: DESTRUCTIVE (overrides default menu behavior)
#########################################################################

module PhoneMenu
  # Image file names in Graphics/PhoneMenu
  BACKGROUND = "PhoneBackground"           # Default background
  MESSAGE_BACKGROUND = "MessageBackground" # Background for message view
  ICON_ITEMS = "ItemsIcon"                # Items app icon
  ICON_SAVE = "SaveIcon"                 # Save app icon
  ICON_LOAD = "LoadIcon"                 # Load app icon
  ICON_SETTINGS = "SettingsIcon"         # Settings app icon (System Options)
  ICON_CONTACTS = "ContactsIcon"         # Contacts app icon
  ICON_BACKGROUNDS = "BackgroundsIcon"   # Backgrounds app icon
  ICON_CONTACT_PREFIX = "Contact_"       # Prefix for contact icons (e.g., Contact_1)
  ICON_MESSAGE_CONTACT = "MessageBubble_Contact" # Contact message bubble (32x32 solid color)
  ICON_MESSAGE_MAIN = "MessageBubble_Main"       # Main character message bubble (32x32 solid color)
  ICON_MAIN_CHARACTER = "MainCharacterIcon"      # Main character icon
  ICON_HIGHLIGHT = "IconHighlight"       # Highlight effect for selected icon
  ICON_LOCK = "LockIcon"                 # Lock icon for locked backgrounds

  # Sound effect for icon selection
  SELECT_SE = "Decision1"                # Sound effect file in Audio/SE

  # Phone background dimensions and position
  PHONE_WIDTH = 350                     # Phone background width
  PHONE_HEIGHT = 450                    # Phone background height
  PHONE_X = (Graphics.width - PHONE_WIDTH) / 2 # Centered X (145)
  PHONE_Y = (Graphics.height - PHONE_HEIGHT) / 2  # Centered Y (40)

  # Black rectangle for on/off effect
  BLACK_RECT_WIDTH = 330                # Black rectangle width
  BLACK_RECT_HEIGHT = 430               # Black rectangle height
  BLACK_RECT_X = PHONE_X + (PHONE_WIDTH - BLACK_RECT_WIDTH) / 2  # Centered on phone (155)
  BLACK_RECT_Y = PHONE_Y + (PHONE_HEIGHT - BLACK_RECT_HEIGHT) / 2 # Centered on phone (50)

  # Icon positions (grid layout for 6 icons, relative to phone background)
  ICON_WIDTH = 64                       # Icon width
  ICON_HEIGHT = 64                      # Icon height
  ICON_SPACING = 20                     # Space between icons
  ICON_START_X = PHONE_X + 50           # Starting X relative to phone
  ICON_START_Y = PHONE_Y + 240          # Starting Y relative to phone
  ICON_SCALE = 1.2                      # Scale factor when selected

  # Contacts screen settings
  CONTACT_GROUP_X_OFFSET = 0            # X offset for entire contact group (icons and names)
  CONTACT_GROUP_Y_OFFSET = 0            # Y offset for entire contact group (icons and names)
  CONTACT_ICON_X = PHONE_X + 50         # Base X position for contact icons
  CONTACT_ICON_Y = PHONE_Y + 100        # Base Y position for contact icons
  CONTACT_SPACING = 80                  # Vertical spacing between contacts
  CONTACT_NAME_X_OFFSET = 80            # Name offset from icon (X)
  CONTACT_NAME_Y_OFFSET = 0             # Name offset from icon (Y)
  CONTACT_INFO_X = 30                   # Base X position for contact info text
  CONTACT_INFO_Y = PHONE_Y + 50         # Base Y position for contact info
  CONTACT_MESSAGE_Y = PHONE_Y + 150     # Base Y position for messages
  MESSAGE_SPACING = 40                  # Vertical spacing between messages
  MESSAGE_LINE_SPACING = 24             # Vertical spacing between wrapped lines of a message
  MESSAGE_ICON_SIZE = 32                # Size of message icons
  MESSAGE_TEXT_WIDTH = 250              # Width of message text area
  MESSAGE_X_LEFT = CONTACT_ICON_X + MESSAGE_ICON_SIZE + 10  # Left-aligned message X
  MESSAGE_X_RIGHT = PHONE_X + PHONE_WIDTH - MESSAGE_TEXT_WIDTH - MESSAGE_ICON_SIZE - 10  # Right-aligned message X
  MESSAGE_GROUP_X_OFFSET = 0            # X offset for entire message group (bubble, icon, text)
  MESSAGE_GROUP_Y_OFFSET = 0            # Y offset for entire message group (bubble, icon, text)
  MAX_MESSAGES_DISPLAYED = 5            # Maximum number of messages shown at once
  MAX_CONTACTS_DISPLAYED = 3            # Maximum number of contacts shown at once
  MAX_MESSAGE_CHARS_PER_LINE = 30       # Maximum characters per line for word wrapping

  # Background selection screen settings
  BACKGROUND_GROUP_X_OFFSET = 0         # X offset for entire background group (previews, names, lock icons)
  BACKGROUND_GROUP_Y_OFFSET = 0         # Y offset for entire background group (previews, names, lock icons)
  BACKGROUND_PREVIEW_X = PHONE_X + 50   # Base X position for background previews
  BACKGROUND_PREVIEW_Y = PHONE_Y + 100  # Base Y position for background previews
  BACKGROUND_SPACING = 100              # Vertical spacing between previews
  BACKGROUND_PREVIEW_WIDTH = 120        # Width of preview thumbnails
  BACKGROUND_PREVIEW_HEIGHT = 80        # Height of preview thumbnails
  BACKGROUND_NAME_X_OFFSET = 140        # Name offset from preview (X)
  BACKGROUND_NAME_Y_OFFSET = 0          # Name offset from preview (Y)
  BACKGROUND_INFO_X_OFFSET = 0          # X offset for requirement text
  BACKGROUND_INFO_Y_OFFSET = 90         # Y offset for requirement text
  LOCK_ICON_SIZE = 32                   # Size of lock icon
  MAX_BACKGROUNDS_DISPLAYED = 3         # Maximum number of backgrounds shown at once

  # Animation settings
  ANIMATION_DURATION = 20               # Frames for icon scale animation
  SLIDE_DURATION = 30                   # Frames for slide animation (0.5s at 60 FPS)
  FADE_DURATION = 30                    # Frames for black rectangle fade (0.5s)

  # Menu commands
  MENU_COMMANDS = [
    :item,
    :save,
    :load,
    :system,  # Maps to Yanfly's System Options (Scene_System)
    :contacts,
    :backgrounds
  ]

  # Contact data (example, can be updated via events)
  # Format: [character_id, name, lore, [[sender, message]]]
  CONTACTS = {
  }

  # Background data (example)
  # Format: [id, filename, name, requirement]
  BACKGROUNDS = {
    :default => ["PhoneBackground", "Default", "Available from start"],
    :phone1 => ["PhoneBackground1", "image", "Tìm ra fanart của Hải Quỳ"],
    :phone2 => ["PhoneBackground2", "2", "Tìm ra hình của cụ Quỳ"]
  }
end

#======================================================================
# DataManager
#======================================================================
module DataManager
  class << self
    alias data_manager_init_phone_menu init
    alias data_manager_create_game_objects_phone_menu create_game_objects
    alias data_manager_make_save_contents_phone_menu make_save_contents
    alias data_manager_extract_save_contents_phone_menu extract_save_contents
  end

  #--------------------------------------------------------------------------
  # ● Initialize module
  #--------------------------------------------------------------------------
  def self.init
    data_manager_init_phone_menu
    $game_config = Game_Config.new
    $phone_menu_selected_index = 0
    p "DataManager initialized with Game_Config"
  end

  #--------------------------------------------------------------------------
  # ● Create game objects
  #--------------------------------------------------------------------------
  def self.create_game_objects
    data_manager_create_game_objects_phone_menu
    $game_config = Game_Config.new
    $phone_menu_selected_index = 0
  end

  #--------------------------------------------------------------------------
  # ● Make save contents
  #--------------------------------------------------------------------------
  def self.make_save_contents
    contents = data_manager_make_save_contents_phone_menu
    contents[:phone_config] = $game_config
    contents
  end

  #--------------------------------------------------------------------------
  # ● Extract save contents
  #--------------------------------------------------------------------------
  def self.extract_save_contents(contents)
    data_manager_extract_save_contents_phone_menu(contents)
    $game_config = contents[:phone_config] || Game_Config.new
    $game_config.current_background = :default unless PhoneMenu::BACKGROUNDS.key?($game_config.current_background)
  end
end

#======================================================================
# Game_Config (for managing messages and backgrounds)
#======================================================================
class Game_Config
  attr_accessor :unlocked_backgrounds
  attr_accessor :current_background

  #--------------------------------------------------------------------------
  # ● Initialize
  #--------------------------------------------------------------------------
  def initialize
    @unlocked_backgrounds = [:default] # Default background is always unlocked
    @current_background = :default
    p "Game_Config initialized"
  end

  #--------------------------------------------------------------------------
  # ● Add a message to a contact
  #--------------------------------------------------------------------------
  def add_message(contact_id, message, sender = :contact)
    PhoneMenu::CONTACTS[contact_id][2] << [sender, message] if PhoneMenu::CONTACTS[contact_id]
  end

  #--------------------------------------------------------------------------
  # ● Add multiple messages to a contact
  #--------------------------------------------------------------------------
  def add_messages(contact_id, messages)
    return unless PhoneMenu::CONTACTS[contact_id]
    messages.each do |message, sender|
      PhoneMenu::CONTACTS[contact_id][2] << [sender, message]
    end
  end

  #--------------------------------------------------------------------------
  # ● Unlock a background
  #--------------------------------------------------------------------------
  def unlock_background(background_id)
    @unlocked_backgrounds << background_id unless @unlocked_backgrounds.include?(background_id)
    @current_background = :default unless PhoneMenu::BACKGROUNDS.key?(@current_background)
  end
end

#======================================================================
# Scene_Menu class
#----------------------------------------------------------------------#
# Custom smartphone-themed menu with app icons, contacts, and backgrounds
#======================================================================
class Scene_Menu < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ● Start processing
  #--------------------------------------------------------------------------
  def start
    super
    create_background
    create_black_rectangle
    create_foreground
    create_command_window
    @animation_frame = 0
    @selected_index = $phone_menu_selected_index || 0
    @contacts_screen = false
    @backgrounds_screen = false
    @selected_contact = nil
    @message_index = 0
    @in_message_view = false
    @selected_background = 0
    @background_index = 0
    @animation_state = :opening
    @animation_timer = 0
    @from_external_scene = true # Track if entering from outside menu
    hide_menu_sprites
  end

  #--------------------------------------------------------------------------
  # ● Create background
  #--------------------------------------------------------------------------
  def create_background
    @background_sprite = Sprite.new
    @background_sprite.x = PhoneMenu::PHONE_X
    @background_sprite.y = Graphics.height # Start at bottom for opening animation
    @background_sprite.z = 50
    @background_sprite.visible = false # Hide until animation starts
    background_id = $game_config.current_background || :default
    background_id = :default unless PhoneMenu::BACKGROUNDS.key?(background_id)
    @current_background_id = background_id # Store for restoring later
    background_data = PhoneMenu::BACKGROUNDS[background_id]
    filename = background_data.is_a?(Array) ? background_data[0] : PhoneMenu::BACKGROUNDS[:default][0]
    p "create_background: background_id = #{background_id}, filename = #{filename}"
    raise "Invalid background filename for #{background_id}: #{filename}" unless filename.is_a?(String)
    bitmap = Cache.load_bitmap("Graphics/PhoneMenu/", filename)
    @background_sprite.bitmap = Bitmap.new(PhoneMenu::PHONE_WIDTH, PhoneMenu::PHONE_HEIGHT)
    @background_sprite.bitmap.stretch_blt(@background_sprite.bitmap.rect, bitmap, bitmap.rect)
  end

  #--------------------------------------------------------------------------
  # ● Create black rectangle for on/off effect
  #--------------------------------------------------------------------------
  def create_black_rectangle
    @black_rectangle = Sprite.new
    @black_rectangle.bitmap = Bitmap.new(PhoneMenu::BLACK_RECT_WIDTH, PhoneMenu::BLACK_RECT_HEIGHT)
    @black_rectangle.bitmap.fill_rect(0, 0, PhoneMenu::BLACK_RECT_WIDTH, PhoneMenu::BLACK_RECT_HEIGHT, Color.new(0, 0, 0))
    @black_rectangle.x = PhoneMenu::BLACK_RECT_X
    @black_rectangle.y = PhoneMenu::BLACK_RECT_Y
    @black_rectangle.z = 200
    @black_rectangle.opacity = 255
  end

  #--------------------------------------------------------------------------
  # ● Create foreground (app icons)
  #--------------------------------------------------------------------------
  def create_foreground
    @icon_sprites = []
    @highlight_sprites = []
    PhoneMenu::MENU_COMMANDS.each_with_index do |sym, index|
      sprite = Sprite.new
      sprite.bitmap = Cache.load_bitmap("Graphics/PhoneMenu/", icon_bitmap_name(sym))
      sprite.x = PhoneMenu::ICON_START_X + (index % 3) * (PhoneMenu::ICON_WIDTH + PhoneMenu::ICON_SPACING)
      sprite.y = PhoneMenu::ICON_START_Y + (index / 3) * (PhoneMenu::ICON_HEIGHT + PhoneMenu::ICON_SPACING)
      sprite.z = 100
      sprite.visible = false
      @icon_sprites << sprite

      highlight = Sprite.new
      highlight.bitmap = Cache.load_bitmap("Graphics/PhoneMenu/", PhoneMenu::ICON_HIGHLIGHT)
      highlight.x = sprite.x
      highlight.y = sprite.y
      highlight.opacity = (index == @selected_index) ? 255 : 0
      highlight.z = 90
      highlight.visible = false
      @highlight_sprites << highlight
    end
  end

  #--------------------------------------------------------------------------
  # ● Get icon bitmap name
  #--------------------------------------------------------------------------
  def icon_bitmap_name(symbol)
    case symbol
    when :item then PhoneMenu::ICON_ITEMS
    when :save then PhoneMenu::ICON_SAVE
    when :load then PhoneMenu::ICON_LOAD
    when :system then PhoneMenu::ICON_SETTINGS # Maps to System Options
    when :contacts then PhoneMenu::ICON_CONTACTS
    when :backgrounds then PhoneMenu::ICON_BACKGROUNDS
    end
  end

  #--------------------------------------------------------------------------
  # ● Create command window
  #--------------------------------------------------------------------------
  def create_command_window
    @command_window = Window_PhoneMenu.new
    @command_window.set_handler(:item, method(:command_item))
    @command_window.set_handler(:save, method(:command_save))
    @command_window.set_handler(:load, method(:command_load))
    @command_window.set_handler(:system, method(:command_system))
    @command_window.set_handler(:contacts, method(:command_contacts))
    @command_window.set_handler(:backgrounds, method(:command_backgrounds))
    @command_window.set_handler(:cancel, method(:start_closing))
    @command_window.deactivate
  end

  #--------------------------------------------------------------------------
  # ● Update
  #--------------------------------------------------------------------------
  def update
    super
    if @animation_state == :opening
      update_opening_animation
    elsif @animation_state == :closing
      update_closing_animation
    elsif @contacts_screen
      update_contacts_screen
    elsif @backgrounds_screen
      update_backgrounds_screen
    else
      update_main_menu
    end
    @animation_frame += 1
  end

  #--------------------------------------------------------------------------
  # ● Update opening animation
  #--------------------------------------------------------------------------
  def update_opening_animation
    return unless @from_external_scene # Skip animation for internal transitions
    @animation_timer += 1
    @background_sprite.visible = true
    # Slide background from y=480 to y=40 (0.5s = 30 frames)
    if @animation_timer <= PhoneMenu::SLIDE_DURATION
      progress = @animation_timer.to_f / PhoneMenu::SLIDE_DURATION
      @background_sprite.y = Graphics.height - (Graphics.height - PhoneMenu::PHONE_Y) * progress
    else
      @background_sprite.y = PhoneMenu::PHONE_Y
    end
    # Fade black rectangle from opacity 255 to 0 (0.5s = 30 frames)
    if @animation_timer <= PhoneMenu::FADE_DURATION
      @black_rectangle.opacity = 255 * (1.0 - @animation_timer.to_f / PhoneMenu::FADE_DURATION)
    else
      @black_rectangle.opacity = 0
      @black_rectangle.visible = false
      # Show appropriate sprites
      if @contacts_screen
        show_contacts_sprites
      elsif @backgrounds_screen
        show_backgrounds_sprites
      else
        show_menu_sprites
      end
      @animation_state = :idle
      @animation_timer = 0
      @from_external_scene = false # Reset after animation
    end
  end

  #--------------------------------------------------------------------------
  # ● Update closing animation
  #--------------------------------------------------------------------------
  def update_closing_animation
    @animation_timer += 1
    # Fade black rectangle from opacity 0 to 255 (0.5s = 30 frames)
    if @animation_timer <= PhoneMenu::FADE_DURATION
      @black_rectangle.visible = true
      @black_rectangle.opacity = 255 * (@animation_timer.to_f / PhoneMenu::FADE_DURATION)
    else
      @black_rectangle.opacity = 255
      @black_rectangle.visible = false # Hide after fade completes
    end
    # Slide background from y=40 to y=480 (0.5s = 30 frames) after fade
    if @animation_timer >= PhoneMenu::FADE_DURATION
      slide_progress = (@animation_timer - PhoneMenu::FADE_DURATION).to_f / PhoneMenu::SLIDE_DURATION
      @background_sprite.y = PhoneMenu::PHONE_Y + (Graphics.height - PhoneMenu::PHONE_Y) * slide_progress
    end
    # Complete closing
    if @animation_timer >= PhoneMenu::FADE_DURATION + PhoneMenu::SLIDE_DURATION
      @black_rectangle.visible = false
      p "Disposing sprites before scene transition"
      dispose_sprites
      super_return_scene
    end
  end

  #--------------------------------------------------------------------------
  # ● Start closing animation
  #--------------------------------------------------------------------------
  def start_closing
    p "Starting closing animation"
    Sound.play_cancel
    $phone_menu_selected_index = @selected_index
    hide_menu_sprites
    hide_contacts_sprites if @contacts_screen
    hide_backgrounds_sprites if @backgrounds_screen
    @animation_state = :closing
    @animation_timer = 0
  end

  #--------------------------------------------------------------------------
  # ● Alias for return_scene to avoid recursion
  #--------------------------------------------------------------------------
  alias super_return_scene return_scene

  #--------------------------------------------------------------------------
  # ● Update main menu
  #--------------------------------------------------------------------------
  def update_main_menu
    update_icon_animation
    update_input
  end

  #--------------------------------------------------------------------------
  # ● Update icon animation
  #--------------------------------------------------------------------------
  def update_icon_animation
    @icon_sprites.each_with_index do |sprite, index|
      if index == @selected_index
        progress = (@animation_frame % PhoneMenu::ANIMATION_DURATION).to_f / PhoneMenu::ANIMATION_DURATION
        scale = 1.0 + (PhoneMenu::ICON_SCALE - 1.0) * Math.sin(progress * Math::PI)
        sprite.zoom_x = sprite.zoom_y = scale
        @highlight_sprites[index].opacity = 255
      else
        sprite.zoom_x = sprite.zoom_y = 1.0
        @highlight_sprites[index].opacity = 0
      end
    end
  end

  #--------------------------------------------------------------------------
  # ● Update input for main menu
  #--------------------------------------------------------------------------
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

  #--------------------------------------------------------------------------
  # ● Show menu sprites
  #--------------------------------------------------------------------------
  def show_menu_sprites
    @icon_sprites.each { |s| s.visible = true } if @icon_sprites
    @highlight_sprites.each { |s| s.visible = true } if @highlight_sprites
  end

  #--------------------------------------------------------------------------
  # ● Hide menu sprites
  #--------------------------------------------------------------------------
  def hide_menu_sprites
    @icon_sprites.each { |s| s.visible = false } if @icon_sprites
    @highlight_sprites.each { |s| s.visible = false } if @highlight_sprites
  end

  #--------------------------------------------------------------------------
  # ● Command handlers
  #--------------------------------------------------------------------------
  def command_item
    $phone_menu_selected_index = @selected_index
    hide_menu_sprites
    @from_external_scene = false
    SceneManager.call(Scene_Item)
  end

  def command_save
    $phone_menu_selected_index = @selected_index
    hide_menu_sprites
    @from_external_scene = false
    SceneManager.call(Scene_Save)
  end

  def command_load
    $phone_menu_selected_index = @selected_index
    hide_menu_sprites
    @from_external_scene = false
    SceneManager.call(Scene_Load)
  end

  def command_system
    $phone_menu_selected_index = @selected_index
    hide_menu_sprites
    @from_external_scene = false
    SceneManager.call(Scene_System)
  end

  def command_contacts
    $phone_menu_selected_index = @selected_index
    hide_menu_sprites
    open_contacts_screen
  end

  def command_backgrounds
    $phone_menu_selected_index = @selected_index
    hide_menu_sprites
    open_backgrounds_screen
  end

  #--------------------------------------------------------------------------
  # ● Post start (restore sprites and selected index)
  #--------------------------------------------------------------------------
  def post_start
    super
    @selected_index = $phone_menu_selected_index || 0
    # Track previous scene to determine if coming from a non-menu scene
    prev_scene = SceneManager.instance_variable_get(:@stack).last
    @from_external_scene = prev_scene && ![Scene_Item, Scene_Save, Scene_Load, Scene_System, Scene_Map].include?(prev_scene.class)
    if @from_external_scene
      @animation_state = :opening
      @animation_timer = 0
      @background_sprite.y = Graphics.height
      @background_sprite.visible = false
      @black_rectangle.opacity = 255
      @black_rectangle.visible = true
      hide_menu_sprites
    else
      @animation_state = :idle
      @animation_timer = 0
      @background_sprite.y = PhoneMenu::PHONE_Y
      @background_sprite.visible = true
      @black_rectangle.opacity = 0
      @black_rectangle.visible = false
      show_menu_sprites
    end
  end

  #--------------------------------------------------------------------------
  # ● Open contacts screen
  #--------------------------------------------------------------------------
  def open_contacts_screen
    p "Opening contacts screen"
    @contacts_screen = true
    @backgrounds_screen = false
    @selected_contact = 0
    @contact_index = 0
    @message_index = 0
    @in_message_view = false
    create_contacts_sprites
    @animation_state = :idle
    @animation_timer = 0
    @background_sprite.y = PhoneMenu::PHONE_Y
    @background_sprite.visible = true
    @black_rectangle.opacity = 0
    @black_rectangle.visible = false
    show_contacts_sprites
  end

  #--------------------------------------------------------------------------
  # ● Update contacts screen
  #--------------------------------------------------------------------------
  def update_contacts_screen
    if @animation_state == :idle
      if @in_message_view
        update_message_view
      else
        update_contact_selection
      end
    end
  end

  #--------------------------------------------------------------------------
  # ● Update contact selection
  #--------------------------------------------------------------------------
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
      if @selected_contact < PhoneMenu::MAX_CONTACTS_DISPLAYED - 1 && @selected_contact + @contact_index < PhoneMenu::CONTACTS.size - 1
        @selected_contact += 1
      elsif @contact_index < max_index
        @contact_index += 1
        @selected_contact = [PhoneMenu::MAX_CONTACTS_DISPLAYED - 1, PhoneMenu::CONTACTS.size - @contact_index - 1].min
      end
      RPG::SE.new(PhoneMenu::SELECT_SE).play
      refresh_contacts
    elsif Input.trigger?(:C)
      @in_message_view = true
      show_contact_details
    elsif Input.trigger?(:B)
      p "Returning to main menu from contacts"
      close_contacts_screen
    end
  end

  #--------------------------------------------------------------------------
  # ● Update message view
  #--------------------------------------------------------------------------
  def update_message_view
    data = PhoneMenu::CONTACTS[PhoneMenu::CONTACTS.keys[@selected_contact + @contact_index]]
    # Calculate total height of displayed messages for scrolling
    total_height = 0
    start_index = [@message_index, 0].max
    end_index = [start_index + PhoneMenu::MAX_MESSAGES_DISPLAYED - 1, data[2].size - 1].min
    data[2][start_index..end_index].each do |message_data|
      sender, message = message_data
      wrapped_lines = wrap_text(message, PhoneMenu::MAX_MESSAGE_CHARS_PER_LINE)
      total_height += [1, wrapped_lines.size].max * PhoneMenu::MESSAGE_LINE_SPACING
    end
    max_index = [0, data[2].size - PhoneMenu::MAX_MESSAGES_DISPLAYED].max
    if Input.repeat?(:UP) && @message_index > 0
      @message_index -= 1
      RPG::SE.new(PhoneMenu::SELECT_SE).play
      show_contact_details
    elsif Input.repeat?(:DOWN) && @message_index < max_index
      @message_index += 1
      RPG::SE.new(PhoneMenu::SELECT_SE).play
      show_contact_details
    elsif Input.trigger?(:B)
      p "Returning to main menu from message view"
      close_contacts_screen
    end
  end

  #--------------------------------------------------------------------------
  # ● Word wrap text
  #--------------------------------------------------------------------------
  def wrap_text(text, max_chars)
    words = text.split(' ')
    lines = []
    current_line = ''
    words.each do |word|
      if current_line.empty?
        if word.length > max_chars
          # Split long word
          while word.length > max_chars
            lines << word[0...max_chars]
            word = word[max_chars..-1]
          end
          current_line = word
        else
          current_line = word
        end
      elsif (current_line.length + word.length + 1) <= max_chars
        current_line += ' ' + word
      else
        lines << current_line
        if word.length > max_chars
          # Split long word
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
    lines
  end

  #--------------------------------------------------------------------------
  # ● Create contacts sprites
  #--------------------------------------------------------------------------
  def create_contacts_sprites
    p "Creating contact sprites"
    # Dispose existing contact-related sprites
    @contact_sprites.each { |s| s.bitmap.dispose if s.bitmap && !s.bitmap.disposed?; s.dispose if !s.disposed? } if @contact_sprites
    @contact_names.each { |s| s.bitmap.dispose if s.bitmap && !s.bitmap.disposed?; s.dispose if !s.disposed? } if @contact_names
    @contact_messages.each { |s| s.bitmap.dispose if s.bitmap && !s.bitmap.disposed?; s.dispose if !s.disposed? } if @contact_messages
    @contact_info.bitmap.dispose if @contact_info && @contact_info.bitmap && !@contact_info.bitmap.disposed?
    @contact_info.dispose if @contact_info && !@contact_info.disposed?

    # Initialize arrays
    @contact_sprites = []
    @contact_names = []
    @contact_messages = []

    # Create contact_info sprite
    @contact_info = Sprite.new
    @contact_info.bitmap = Bitmap.new(PhoneMenu::PHONE_WIDTH, PhoneMenu::PHONE_HEIGHT)
    @contact_info.x = PhoneMenu::PHONE_X
    @contact_info.y = PhoneMenu::PHONE_Y
    @contact_info.z = 150
    @contact_info.visible = false

    # Create contact icons and names for up to MAX_CONTACTS_DISPLAYED
    start_index = [@contact_index, 0].max
    end_index = [start_index + PhoneMenu::MAX_CONTACTS_DISPLAYED - 1, PhoneMenu::CONTACTS.size - 1].min
    p "Creating contacts: start_index = #{start_index}, end_index = #{end_index}, total contacts = #{PhoneMenu::CONTACTS.size}"
    
    contacts = PhoneMenu::CONTACTS.to_a[start_index..end_index] || []
    contacts.each_with_index do |(id, data), index|
      sprite = Sprite.new
      sprite.bitmap = Cache.load_bitmap("Graphics/PhoneMenu/", "#{PhoneMenu::ICON_CONTACT_PREFIX}#{id}")
      sprite.x = PhoneMenu::CONTACT_ICON_X + PhoneMenu::CONTACT_GROUP_X_OFFSET
      sprite.y = PhoneMenu::CONTACT_ICON_Y + index * PhoneMenu::CONTACT_SPACING + PhoneMenu::CONTACT_GROUP_Y_OFFSET
      sprite.z = 100
      sprite.visible = false
      @contact_sprites << sprite

      name_sprite = Sprite.new
      name_sprite.bitmap = Bitmap.new(200, 32)
      name_sprite.bitmap.font.size = 24
      name_sprite.bitmap.draw_text(0, 0, 200, 32, data[0])
      name_sprite.x = PhoneMenu::CONTACT_ICON_X + PhoneMenu::CONTACT_NAME_X_OFFSET + PhoneMenu::CONTACT_GROUP_X_OFFSET
      name_sprite.y = sprite.y + PhoneMenu::CONTACT_NAME_Y_OFFSET
      name_sprite.z = 100
      name_sprite.visible = false
      @contact_names << name_sprite
    end
    p "Created #{@contact_sprites.size} contact sprites and #{@contact_names.size} name sprites"
  end

  #--------------------------------------------------------------------------
  # ● Refresh contacts display
  #--------------------------------------------------------------------------
  def refresh_contacts
    p "Refreshing contacts, in_message_view = #{@in_message_view}"
    # Restore original background
    background_id = @current_background_id || :default
    background_id = :default unless PhoneMenu::BACKGROUNDS.key?(background_id)
    background_data = PhoneMenu::BACKGROUNDS[background_id]
    filename = background_data.is_a?(Array) ? background_data[0] : PhoneMenu::BACKGROUNDS[:default][0]
    @background_sprite.bitmap.dispose if @background_sprite.bitmap && !@background_sprite.bitmap.disposed?
    bitmap = Cache.load_bitmap("Graphics/PhoneMenu/", filename)
    @background_sprite.bitmap = Bitmap.new(PhoneMenu::PHONE_WIDTH, PhoneMenu::PHONE_HEIGHT)
    @background_sprite.bitmap.stretch_blt(@background_sprite.bitmap.rect, bitmap, bitmap.rect)
    p "Restored background to #{filename} in refresh_contacts"

    # Recreate contact sprites if returning from message view or scrolling
    create_contacts_sprites

    @contact_sprites.each_with_index do |sprite, index|
      sprite.zoom_x = sprite.zoom_y = (index == @selected_contact) ? PhoneMenu::ICON_SCALE : 1.0
      sprite.visible = !@in_message_view
    end
    @contact_names.each_with_index { |sprite, index| sprite.visible = !@in_message_view }
    @contact_messages.each { |sprite| sprite.visible = false } if @contact_messages
    @contact_info.bitmap.clear
    @contact_info.visible = true
    if @selected_contact && !@in_message_view
      data = PhoneMenu::CONTACTS[PhoneMenu::CONTACTS.keys[@selected_contact + @contact_index]]
      @contact_info.bitmap.font.size = 20
      @contact_info.bitmap.draw_text(PhoneMenu::CONTACT_INFO_X, PhoneMenu::CONTACT_INFO_Y - PhoneMenu::PHONE_Y, PhoneMenu::PHONE_WIDTH, 32, "Lore: #{data[1]}")
    end
    p "Contact sprites visibility set, count = #{@contact_sprites.size}"
  end

  #--------------------------------------------------------------------------
  # ● Get sender icon filename
  #--------------------------------------------------------------------------
  def get_sender_icon(sender, contact_id)
    if sender == :main
      PhoneMenu::ICON_MAIN_CHARACTER
    elsif sender.to_s.start_with?("contact")
      contact_num = sender.to_s.gsub("contact", "").to_i
      if PhoneMenu::CONTACTS[contact_num]
        "#{PhoneMenu::ICON_CONTACT_PREFIX}#{contact_num}"
      else
        # Fallback to current contact's icon if sender not found
        "#{PhoneMenu::ICON_CONTACT_PREFIX}#{contact_id}"
      end
    else
      # Default to current contact's icon for backward compatibility
      "${PhoneMenu::ICON_CONTACT_PREFIX}#{contact_id}"
    end
  end

  #--------------------------------------------------------------------------
  # ● Show contact details (messages)
  #--------------------------------------------------------------------------
  def show_contact_details
    p "Showing contact details for contact #{PhoneMenu::CONTACTS.keys[@selected_contact + @contact_index]}"
    # Set message background
    @background_sprite.bitmap.dispose if @background_sprite.bitmap && !@background_sprite.bitmap.disposed?
    bitmap = Cache.load_bitmap("Graphics/PhoneMenu/", PhoneMenu::MESSAGE_BACKGROUND)
    @background_sprite.bitmap = Bitmap.new(PhoneMenu::PHONE_WIDTH, PhoneMenu::PHONE_HEIGHT)
    @background_sprite.bitmap.stretch_blt(@background_sprite.bitmap.rect, bitmap, bitmap.rect)
    p "Set background to #{PhoneMenu::MESSAGE_BACKGROUND} in show_contact_details"

    @contact_sprites.each { |s| s.visible = false } if @contact_sprites
    @contact_names.each { |s| s.visible = false } if @contact_names
    @contact_info.bitmap.clear
    @contact_info.visible = true
    data = PhoneMenu::CONTACTS[PhoneMenu::CONTACTS.keys[@selected_contact + @contact_index]]
    @contact_info.bitmap.font.size = 20
    @contact_info.bitmap.draw_text(PhoneMenu::CONTACT_INFO_X, PhoneMenu::CONTACT_INFO_Y - PhoneMenu::PHONE_Y, PhoneMenu::PHONE_WIDTH, 32, "Messages with #{data[0]}")
    
    @contact_messages.each { |s| s.bitmap.dispose if s.bitmap && !s.bitmap.disposed?; s.dispose if !s.disposed? } if @contact_messages
    @contact_messages = []
    start_index = [@message_index, 0].max
    end_index = [start_index + PhoneMenu::MAX_MESSAGES_DISPLAYED - 1, data[2].size - 1].min
    y_offset = 0
    message_count = 0

    data[2][start_index..end_index].each_with_index do |message_data, index|
      break if message_count >= PhoneMenu::MAX_MESSAGES_DISPLAYED
      sender, message = message_data
      is_main = sender == :main
      bubble_bitmap = Cache.load_bitmap("Graphics/PhoneMenu/", is_main ? PhoneMenu::ICON_MESSAGE_MAIN : PhoneMenu::ICON_MESSAGE_CONTACT)
      icon_bitmap = Cache.load_bitmap("Graphics/PhoneMenu/", get_sender_icon(sender, PhoneMenu::CONTACTS.keys[@selected_contact + @contact_index]))

      # Word wrap the message
      wrapped_lines = wrap_text(message, PhoneMenu::MAX_MESSAGE_CHARS_PER_LINE)
      line_count = [1, wrapped_lines.size].max
      bubble_height = line_count * PhoneMenu::MESSAGE_LINE_SPACING

      # Message bubble (stretched to cover all wrapped lines)
      bubble_sprite = Sprite.new
      bubble_sprite.bitmap = Bitmap.new(PhoneMenu::MESSAGE_TEXT_WIDTH, bubble_height)
      bubble_sprite.bitmap.stretch_blt(bubble_sprite.bitmap.rect, bubble_bitmap, Rect.new(0, 0, 32, 32))
      bubble_sprite.x = (is_main ? PhoneMenu::MESSAGE_X_RIGHT : PhoneMenu::MESSAGE_X_LEFT) + PhoneMenu::MESSAGE_GROUP_X_OFFSET
      bubble_sprite.y = PhoneMenu::CONTACT_MESSAGE_Y + y_offset + PhoneMenu::MESSAGE_GROUP_Y_OFFSET
      bubble_sprite.z = 99  # Behind text and icon
      bubble_sprite.visible = true
      @contact_messages << bubble_sprite

      # Message icon
      icon_sprite = Sprite.new
      icon_sprite.bitmap = icon_bitmap
      icon_sprite.x = (is_main ? PhoneMenu::MESSAGE_X_RIGHT + PhoneMenu::MESSAGE_TEXT_WIDTH + 5 : PhoneMenu::CONTACT_ICON_X) + PhoneMenu::MESSAGE_GROUP_X_OFFSET
      icon_sprite.y = PhoneMenu::CONTACT_MESSAGE_Y + y_offset + PhoneMenu::MESSAGE_GROUP_Y_OFFSET
      icon_sprite.z = 100
      scale = PhoneMenu::MESSAGE_ICON_SIZE.to_f / [icon_bitmap.width, icon_bitmap.height].max
      icon_sprite.zoom_x = scale
      icon_sprite.zoom_y = scale
      icon_sprite.visible = true
      @contact_messages << icon_sprite

      # Message text (multiple lines if wrapped)
      wrapped_lines.each_with_index do |line, line_index|
        text_sprite = Sprite.new
        text_sprite.bitmap = Bitmap.new(PhoneMenu::MESSAGE_TEXT_WIDTH, 32)
        text_sprite.bitmap.font.size = 20
        text_sprite.bitmap.draw_text(0, 0, PhoneMenu::MESSAGE_TEXT_WIDTH, 32, line, is_main ? 2 : 0)
        text_sprite.x = (is_main ? PhoneMenu::MESSAGE_X_RIGHT : PhoneMenu::MESSAGE_X_LEFT + PhoneMenu::MESSAGE_ICON_SIZE + 5) + PhoneMenu::MESSAGE_GROUP_X_OFFSET
        text_sprite.y = PhoneMenu::CONTACT_MESSAGE_Y + y_offset + (line_index * PhoneMenu::MESSAGE_LINE_SPACING) + PhoneMenu::MESSAGE_GROUP_Y_OFFSET
        text_sprite.z = 100
        text_sprite.visible = true
        @contact_messages << text_sprite
      end

      # Update y_offset for next message
      y_offset += bubble_height + PhoneMenu::MESSAGE_SPACING
      message_count += 1
    end
    p "Created #{@contact_messages.size} message sprites"
  end

  #--------------------------------------------------------------------------
  # ● Show contacts sprites
  #--------------------------------------------------------------------------
  def show_contacts_sprites
    @contact_sprites.each { |s| s.visible = true } if @contact_sprites
    @contact_names.each { |s| s.visible = !@in_message_view } if @contact_names
    @contact_messages.each { |s| s.visible = true } if @contact_messages && @in_message_view
    @contact_info.visible = true if @contact_info
    p "Showing contact sprites, count = #{@contact_sprites.size}, in_message_view = #{@in_message_view}"
  end

  #--------------------------------------------------------------------------
  # ● Hide contacts sprites
  #--------------------------------------------------------------------------
  def hide_contacts_sprites
    @contact_sprites.each { |s| s.visible = false } if @contact_sprites
    @contact_names.each { |s| s.visible = false } if @contact_names
    @contact_messages.each { |s| s.visible = false } if @contact_messages
    @contact_info.visible = false if @contact_info
    p "Hiding contact sprites"
  end

  #--------------------------------------------------------------------------
  # ● Close contacts screen
  #--------------------------------------------------------------------------
  def close_contacts_screen
    p "Closing contacts screen"
    # Restore original background
    background_id = @current_background_id || :default
    background_id = :default unless PhoneMenu::BACKGROUNDS.key?(background_id)
    background_data = PhoneMenu::BACKGROUNDS[background_id]
    filename = background_data.is_a?(Array) ? background_data[0] : PhoneMenu::BACKGROUNDS[:default][0]
    @background_sprite.bitmap.dispose if @background_sprite.bitmap && !@background_sprite.bitmap.disposed?
    bitmap = Cache.load_bitmap("Graphics/PhoneMenu/", filename)
    @background_sprite.bitmap = Bitmap.new(PhoneMenu::PHONE_WIDTH, PhoneMenu::PHONE_HEIGHT)
    @background_sprite.bitmap.stretch_blt(@background_sprite.bitmap.rect, bitmap, bitmap.rect)
    p "Restored background to #{filename} in close_contacts_screen"

    # Dispose all contact-related sprites
    @contact_sprites.each { |s| s.bitmap.dispose if s.bitmap && !s.bitmap.disposed?; s.dispose if !s.disposed? } if @contact_sprites
    @contact_names.each { |s| s.bitmap.dispose if s.bitmap && !s.bitmap.disposed?; s.dispose if !s.disposed? } if @contact_names
    @contact_messages.each { |s| s.bitmap.dispose if s.bitmap && !s.bitmap.disposed?; s.dispose if !s.disposed? } if @contact_messages
    @contact_info.bitmap.dispose if @contact_info && @contact_info.bitmap && !@contact_info.bitmap.disposed?
    @contact_info.dispose if @contact_info && !@contact_info.disposed?

    # Reset contact-related variables
    @contacts_screen = false
    @in_message_view = false
    @message_index = 0
    @contact_index = 0
    @selected_contact = 0
    @contact_sprites = []
    @contact_names = []
    @contact_messages = []
    @contact_info = nil

    @animation_state = :idle
    @animation_timer = 0
    @background_sprite.y = PhoneMenu::PHONE_Y
    @background_sprite.visible = true
    @black_rectangle.opacity = 0
    @black_rectangle.visible = false
    show_menu_sprites
    p "Contact screen closed, all sprites disposed"
  end

  #--------------------------------------------------------------------------
  # ● Open backgrounds screen
  #--------------------------------------------------------------------------
  def open_backgrounds_screen
    p "Opening backgrounds screen"
    @backgrounds_screen = true
    @contacts_screen = false
    @selected_background = 0
    @background_index = 0
    create_backgrounds_sprites
    @animation_state = :idle
    @animation_timer = 0
    @background_sprite.y = PhoneMenu::PHONE_Y
    @background_sprite.visible = true
    @black_rectangle.opacity = 0
    @black_rectangle.visible = false
    show_backgrounds_sprites
    refresh_backgrounds
  end

  #--------------------------------------------------------------------------
  # ● Update backgrounds screen
  #--------------------------------------------------------------------------
  def update_backgrounds_screen
    if @animation_state == :idle
      max_index = [0, PhoneMenu::BACKGROUNDS.size - PhoneMenu::MAX_BACKGROUNDS_DISPLAYED].max
      if Input.repeat?(:UP)
        if @selected_background > 0
          @selected_contact -= 1
        elsif @background_index > 0
          @background_index -= 1
          @selected_background = 0
        end
        RPG::SE.new(PhoneMenu::SELECT_SE).play
        p "Scrolling up: background_index = #{@background_index}, selected_background = #{@selected_background}"
        refresh_backgrounds
      elsif Input.repeat?(:DOWN)
        if @selected_background < PhoneMenu::MAX_BACKGROUNDS_DISPLAYED - 1 && @selected_background + @background_index < PhoneMenu::BACKGROUNDS.size - 1
          @selected_background += 1
        elsif @background_index < max_index
          @background_index += 1
          @selected_background = [PhoneMenu::MAX_BACKGROUNDS_DISPLAYED - 1, PhoneMenu::BACKGROUNDS.size - @background_index - 1].min
        end
        RPG::SE.new(PhoneMenu::SELECT_SE).play
        p "Scrolling down: background_index = #{@background_index}, selected_background = #{@selected_background}"
        refresh_backgrounds
      elsif Input.trigger?(:C)
        index = @selected_background + @background_index
        if index < PhoneMenu::BACKGROUNDS.size
          background_id = PhoneMenu::BACKGROUNDS.keys[index]
          p "Attempting to select background: index = #{index}, id = #{background_id}"
          if background_id && $game_config.unlocked_backgrounds.include?(background_id)
            $game_config.current_background = background_id
            @current_background_id = background_id # Update stored background ID
            @background_sprite.bitmap.dispose if @background_sprite && @background_sprite.bitmap
            bitmap = Cache.load_bitmap("Graphics/PhoneMenu/", PhoneMenu::BACKGROUNDS[background_id][0])
            @background_sprite.bitmap = Bitmap.new(PhoneMenu::PHONE_WIDTH, PhoneMenu::PHONE_HEIGHT)
            @background_sprite.bitmap.stretch_blt(@background_sprite.bitmap.rect, bitmap, bitmap.rect)
            RPG::SE.new(PhoneMenu::SELECT_SE).play
            p "Background applied: #{background_id}"
          else
            Sound.play_buzzer
            p "Background locked or invalid: id = #{background_id}"
          end
        else
          Sound.play_buzzer
          p "Invalid background index: #{index}"
        end
      elsif Input.trigger?(:B)
        p "Returning to main menu from backgrounds"
        close_backgrounds_screen
      end
    end
  end

  #--------------------------------------------------------------------------
  # ● Create backgrounds sprites
  #--------------------------------------------------------------------------
  def create_backgrounds_sprites
    @background_sprites = []
    @background_names = []
    @lock_sprites = []
    # Initialize @background_info only if it doesn't exist or is disposed
    unless @background_info && !@background_info.disposed?
      @background_info = Sprite.new
      @background_info.bitmap = Bitmap.new(PhoneMenu::PHONE_WIDTH, PhoneMenu::PHONE_HEIGHT)
      @background_info.x = PhoneMenu::PHONE_X
      @background_info.y = PhoneMenu::PHONE_Y
      @background_info.z = 150
      @background_info.visible = false
    end

    start_index = [@background_index, 0].max
    end_index = [start_index + PhoneMenu::MAX_BACKGROUNDS_DISPLAYED - 1, PhoneMenu::BACKGROUNDS.size - 1].min
    p "Creating backgrounds: start_index = #{start_index}, end_index = #{end_index}, total backgrounds = #{PhoneMenu::BACKGROUNDS.size}"
    
    backgrounds = PhoneMenu::BACKGROUNDS.to_a[start_index..end_index] || []
    backgrounds.each_with_index do |(id, data), index|
      filename = data.is_a?(Array) ? data[0] : PhoneMenu::BACKGROUNDS[:default][0]
      p "create_backgrounds_sprites: id = #{id}, filename = #{filename}"
      raise "Invalid background filename for #{id}: #{filename}" unless filename.is_a?(String)
      # Preview sprite
      sprite = Sprite.new
      bitmap = Cache.load_bitmap("Graphics/PhoneMenu/", filename)
      sprite.bitmap = Bitmap.new(PhoneMenu::BACKGROUND_PREVIEW_WIDTH, PhoneMenu::BACKGROUND_PREVIEW_HEIGHT)
      sprite.bitmap.stretch_blt(sprite.bitmap.rect, bitmap, bitmap.rect)
      sprite.x = PhoneMenu::BACKGROUND_PREVIEW_X + PhoneMenu::BACKGROUND_GROUP_X_OFFSET
      sprite.y = PhoneMenu::BACKGROUND_PREVIEW_Y + index * PhoneMenu::BACKGROUND_SPACING + PhoneMenu::BACKGROUND_GROUP_Y_OFFSET
      sprite.z = 100
      sprite.visible = true
      @background_sprites << sprite

      # Name sprite
      name_sprite = Sprite.new
      name_sprite.bitmap = Bitmap.new(200, 32)
      name_sprite.bitmap.font.size = 24
      name_sprite.bitmap.draw_text(0, 0, 200, 32, data[1])
      name_sprite.x = PhoneMenu::BACKGROUND_PREVIEW_X + PhoneMenu::BACKGROUND_NAME_X_OFFSET + PhoneMenu::BACKGROUND_GROUP_X_OFFSET
      name_sprite.y = sprite.y + PhoneMenu::BACKGROUND_NAME_Y_OFFSET
      name_sprite.z = 100
      name_sprite.visible = true
      @background_names << name_sprite

      # Lock sprite
      lock_sprite = Sprite.new
      lock_sprite.bitmap = Cache.load_bitmap("Graphics/PhoneMenu/", PhoneMenu::ICON_LOCK)
      lock_sprite.x = (PhoneMenu::BACKGROUND_PREVIEW_X + (PhoneMenu::BACKGROUND_PREVIEW_WIDTH - PhoneMenu::LOCK_ICON_SIZE) / 2) + PhoneMenu::BACKGROUND_GROUP_X_OFFSET
      lock_sprite.y = sprite.y + (PhoneMenu::BACKGROUND_PREVIEW_HEIGHT - PhoneMenu::LOCK_ICON_SIZE) / 2
      lock_sprite.z = 110
      lock_sprite.visible = !$game_config.unlocked_backgrounds.include?(id)
      scale = PhoneMenu::LOCK_ICON_SIZE.to_f / [lock_sprite.bitmap.width, lock_sprite.bitmap.height].max
      lock_sprite.zoom_x = scale
      lock_sprite.zoom_y = scale
      @lock_sprites << lock_sprite
    end
    p "Created #{@background_sprites.size} background sprites"
  end

  #--------------------------------------------------------------------------
  # ● Show backgrounds sprites
  #--------------------------------------------------------------------------
  def show_backgrounds_sprites
    @background_sprites.each { |s| s.visible = true } if @background_sprites
    @background_names.each { |s| s.visible = true } if @background_names
    @lock_sprites.each_with_index do |s, index|
      background_id = PhoneMenu::BACKGROUNDS.keys[@background_index + index]
      s.visible = !$game_config.unlocked_backgrounds.include?(background_id) if background_id
    end if @lock_sprites
    @background_info.visible = true if @background_info
  end

  #--------------------------------------------------------------------------
  # ● Hide backgrounds sprites
  #--------------------------------------------------------------------------
  def hide_backgrounds_sprites
    @background_sprites.each { |s| s.visible = false } if @background_sprites
    @background_names.each { |s| s.visible = false } if @background_names
    @lock_sprites.each { |s| s.visible = false } if @lock_sprites
    @background_info.visible = false if @background_info
  end

  #--------------------------------------------------------------------------
  # ● Refresh backgrounds display
  #--------------------------------------------------------------------------
  def refresh_backgrounds
    p "Refreshing backgrounds: background_index = #{@background_index}, selected_background = #{@selected_background}"
    @background_sprites.each { |s| s.bitmap.dispose; s.dispose } if @background_sprites
    @background_names.each { |s| s.bitmap.dispose; s.dispose } if @background_names
    @lock_sprites.each { |s| s.bitmap.dispose; s.dispose } if @lock_sprites
    @background_sprites = []
    @background_names = []
    @lock_sprites = []
    
    # Clear @background_info bitmap instead of disposing it
    @background_info.bitmap.clear if @background_info && @background_info.bitmap && !@background_info.bitmap.disposed?
    @background_info.visible = true
    
    create_backgrounds_sprites

    @background_sprites.each_with_index do |sprite, index|
      sprite.zoom_x = sprite.zoom_y = (index == @selected_background) ? PhoneMenu::ICON_SCALE : 1.0
    end
    @background_names.each_with_index { |sprite, index| sprite.opacity = (index == @selected_background) ? 255 : 128 }
    
    background_id = PhoneMenu::BACKGROUNDS.keys[@selected_background + @background_index] if (@selected_background + @background_index) < PhoneMenu::BACKGROUNDS.size
    if background_id
      data = PhoneMenu::BACKGROUNDS[background_id]
      @background_info.bitmap.font.size = 20
      text = $game_config.unlocked_backgrounds.include?(background_id) ? "Unlocked" : "Locked: #{data[2]}"
      @background_info.bitmap.draw_text(PhoneMenu::BACKGROUND_INFO_X_OFFSET, PhoneMenu::BACKGROUND_PREVIEW_Y - PhoneMenu::PHONE_Y + PhoneMenu::BACKGROUND_INFO_Y_OFFSET, PhoneMenu::PHONE_WIDTH, 32, text)
    end
  end

  #--------------------------------------------------------------------------
  # ● Close backgrounds screen
  #--------------------------------------------------------------------------
  def close_backgrounds_screen
    p "Closing backgrounds screen"
    @backgrounds_screen = false
    @background_sprites.each { |s| s.bitmap.dispose; s.dispose } if @background_sprites
    @background_names.each { |s| s.bitmap.dispose; s.dispose } if @background_names
    @lock_sprites.each { |s| s.bitmap.dispose; s.dispose } if @lock_sprites
    # Dispose @background_info properly
    if @background_info
      @background_info.bitmap.dispose if @background_info.bitmap && !@background_info.bitmap.disposed?
      @background_info.dispose if !@background_info.disposed?
      @background_info = nil
    end
    @background_sprites = []
    @background_names = []
    @lock_sprites = []
    @animation_state = :idle
    @animation_timer = 0
    @background_sprite.y = PhoneMenu::PHONE_Y
    @background_sprite.visible = true
    @black_rectangle.opacity = 0
    @black_rectangle.visible = false
    show_menu_sprites
  end

  #--------------------------------------------------------------------------
  # ● Dispose sprites
  #--------------------------------------------------------------------------
  def dispose_sprites
    p "Disposing all sprites"
    @background_sprite.bitmap.dispose if @background_sprite && @background_sprite.bitmap && !@background_sprite.bitmap.disposed?
    @background_sprite.dispose if @background_sprite && !@background_sprite.disposed?
    @black_rectangle.bitmap.dispose if @black_rectangle && @black_rectangle.bitmap && !@black_rectangle.bitmap.disposed?
    @black_rectangle.dispose if @black_rectangle && !@black_rectangle.disposed?
    @icon_sprites.each { |s| s.bitmap.dispose if s.bitmap && !s.bitmap.disposed?; s.dispose if !s.disposed? } if @icon_sprites
    @highlight_sprites.each { |s| s.bitmap.dispose if s.bitmap && !s.bitmap.disposed?; s.dispose if !s.disposed? } if @highlight_sprites
    @contact_sprites.each { |s| s.bitmap.dispose if s.bitmap && !s.bitmap.disposed?; s.dispose if !s.disposed? } if @contact_sprites
    @contact_names.each { |s| s.bitmap.dispose if s.bitmap && !s.bitmap.disposed?; s.dispose if !s.disposed? } if @contact_names
    @contact_messages.each { |s| s.bitmap.dispose if s.bitmap && !s.bitmap.disposed?; s.dispose if !s.disposed? } if @contact_messages
    @background_sprites.each { |s| s.bitmap.dispose if s.bitmap && !s.bitmap.disposed?; s.dispose if !s.disposed? } if @background_sprites
    @background_names.each { |s| s.bitmap.dispose if s.bitmap && !s.bitmap.disposed?; s.dispose if !s.disposed? } if @background_names
    @lock_sprites.each { |s| s.bitmap.dispose if s.bitmap && !s.bitmap.disposed?; s.dispose if !s.disposed? } if @lock_sprites
    if @contact_info
      @contact_info.bitmap.dispose if @contact_info.bitmap && !@contact_info.bitmap.disposed?
      @contact_info.dispose if !@contact_info.disposed?
    end
    if @background_info
      @background_info.bitmap.dispose if @background_info.bitmap && !@background_info.bitmap.disposed?
      @background_info.dispose if !@background_info.disposed?
    end
  end
end

#======================================================================
# Window_PhoneMenu class
#======================================================================
class Window_PhoneMenu < Window_Command
  #--------------------------------------------------------------------------
  # ● Initialize
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0)
    self.opacity = 0
    self.back_opacity = 0
    create_contents
  end

  #--------------------------------------------------------------------------
  # ● Create command list
  #--------------------------------------------------------------------------
  def make_command_list
    PhoneMenu::MENU_COMMANDS.each do |sym|
      add_command("", sym, true)
    end
  end
end