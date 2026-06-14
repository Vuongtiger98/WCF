#------------------------------------------------------------------------------#
#  Galv's Double Message
#------------------------------------------------------------------------------#
#  For: RPGMAKER VX ACE
#  Version 0.5
#------------------------------------------------------------------------------#
#  2012-11-30 - version 0.5 - incomplete release
#------------------------------------------------------------------------------#
#  This was an attempt at being able to show two messages at once. I couldn't
#  work out how to do it how I wanted and decided to give up. It is usable in
#  it's current state, though. The current problems are:
#  - you cannot skip through the text while displaying the double message
#  - you have to add double message text with script calls which is painful and
#  could be hard for beginners.
#------------------------------------------------------------------------------#
#  INSTRUCTIONS:
#  Put below materials, above main.
#  To create a double message, use this SCRIPT CALL before a normal message:
#
#------------------------------------------------------------------------------#
#  msg("Text goes in here","Face Name", face_position)
#------------------------------------------------------------------------------#
#
#  - "Face Name" is the name of the faceset you want a face from, eg "Actor1"
#  - face_position is where in that faceset the face you want is. 0 is first
#  - "Test goes in here" - this is where it's painful as the script box is very
#    small. Each new line in the script box is a new line in the message box
#    unless you create multiple strings and add them together.
#
#------------------------------------------------------------------------------#
 
#------------------------------------------------------------------------------#
#  EXAMPLE 1
#------------------------------------------------------------------------------#
#
#  msg("This is the text that would appear
#  in the script box. As the script box is
#  small, it wraps, which will also make
#  it wrap in the message window.",
#  "Actor1", 0)
#
#-- Appears as ----------------------------------------------------------------#
#   ________
#  |        |   This is the text that would appear
#  |  face  |   in the script box. As the script box is
#  |        |   small, it wraps, which will also make
#  |________|   it wrap in the message window.
#
#------------------------------------------------------------------------------#
 
#------------------------------------------------------------------------------#
#  EXAMPLE 2  - multiple strings added together so line breaks aren't used
#------------------------------------------------------------------------------#
#  msg("This is the text that would appear" +
#  "in the script box.
#  As the script box is small, it wraps," +
#  "which will also make
#  it wrap in the message window.",
#  "Actor1", 0)
#
#-- Appears as ----------------------------------------------------------------#
#   ________
#  |        |   This is the text that would appear in the script box.
#  |  face  |   As the script box is small, it wraps, which will also make
#  |        |   it wrap in the message window.
#  |________|   
#
#------------------------------------------------------------------------------#
 
#------------------------------------------------------------------------------#
#  MESSAGE CODES
#------------------------------------------------------------------------------#
#  Most normal message codes work, but in a scrip call you need to put 2 slashes
#  eg. \\c[1]
#  Also, \\n will create a new line the same as a return.
#------------------------------------------------------------------------------#
 
#------------------------------------------------------------------------------#
#  NOTES:
#------------------------------------------------------------------------------#
#  A double message will only ever appear when a real message is called.
#  A double message will only disappear when a real message does. If you add
#  wait of 10 between messages, you can remove the double message and add a new
#  one if required. See demo for examples of this in use.
#------------------------------------------------------------------------------#
#  REMEMBER: This is not finished and I plan to come back to it later when I
#  have possibly start to understand why the issues I was having were happening.
#------------------------------------------------------------------------------#
 
($imported ||= {})["Galvs_Double_Message"] = true
module Galv_Msgs
 
#------------------------------------------------------------------------------#
#  SCRIPT SETTINGS
#------------------------------------------------------------------------------#  
 
  DISABLE_SKIP_SWITCH = 1   # Turn switch ON to disable skipping messages
                            # skipping is always disabled when using 2 mesasges
 
#------------------------------------------------------------------------------#
#  END SCRIPT SETTINGS
#------------------------------------------------------------------------------#  
 
end # don't touch
 
 
class Window_Message2 < Window_Base
  def initialize
    super(0, 0, window_width, window_height)
    self.z = 200
    self.openness = 0
    clear_instance_variables
  end
 
  def window_width
    Graphics.width
  end
 
  def window_height
    fitting_height(visible_line_number)
  end
   
  def clear_instance_variables
    @fiber2 = nil
    @background = 0
    @position2 = 0
  end
 
  def visible_line_number
    return 4
  end
 
  def update
    super
    update_close if !$game_message.visible
    self.visible = false if $game_message.remove2 == true
    update_fiber
  end
   
  def update_close
    return if self.openness <= 0
    self.openness -= 48
  end
   
  def update_fiber
    if @fiber2
      @fiber2.resume
    elsif $game_message.visible && !$game_message.scroll_mode
      @fiber2 = Fiber.new { fiber_main }
      @fiber2.resume
        else
      $game_message.visible = false
      $game_message.clear
      $game_message.clear2
    end
  end
 
  def fiber_main
    update_background
    update_placement
    loop do
      process_all_text if $game_message.texts2 != ""
      $game_message.clear2
      Fiber.yield
      break unless $game_message.busy?
    end
    close
    Fiber.yield
    @fiber2 = nil
  end
 
  def update_background
    @background = $game_message.background
    self.opacity = @background == 0 ? 255 : 0
  end
   
  def update_placement
    case $game_message.position
    when 2
      @position2 = 0
    when 0
      @position2 = 2
    end
    self.y = @position2 * (Graphics.height - height) / 2
  end
   
  def process_all_text
    $game_message.disable_skip = true
    open
    text = convert_escape_characters($game_message.texts2)
    pos = {}
    new_page(text, pos)
    process_character(text.slice!(0, 1), text, pos) until $game_message.texts2 == ""
  end
 
  def text_continue?
    $game_message.texts2 != ""
  end
 
  def wait(duration)
    duration.times { Fiber.yield }
  end
 
  # Crash caused when show fast enabled. Disabled it.
  #def update_show_fast
  #  @show_fast = true if Input.trigger?(:C)
  #end
 
  def wait_for_one_character
    #update_show_fast
    Fiber.yield #unless @show_fast
  end
 
  def new_page(text, pos)
    contents.clear
    draw_face($game_message.face_name2, $game_message.face_index2, 0, 0)
    reset_font_settings
    pos[:x] = new_line_x
    pos[:y] = 0
    pos[:new_x] = new_line_x
    pos[:height] = calc_line_height(text)
  end
 
  def new_line_x
    $game_message.face_name2 == "" ? 0 : 112
  end
   
  def process_character(c, text, pos)
    case c
    when "\n"
      process_new_line(text, pos)
    when "\f"
      process_new_page(text, pos)
    when "\e"
      process_escape_character(obtain_escape_code(text), text, pos)
    else
      process_normal_character(c, pos)
    end
  end
 
  def process_normal_character(c, pos)
    text_width = text_size(c).width
    draw_text(pos[:x], pos[:y], text_width * 2, pos[:height], c)
    pos[:x] += text_width
    wait_for_one_character
  end
   
  def process_new_line(text, pos)
    @line_show_fast = false
    super
    if need_new_page?(text, pos)
      input_pause
      new_page(text, pos)
    end
  end
 
  def need_new_page?(text, pos)
    pos[:y] + pos[:height] > contents.height && !text.empty?
  end
 
  def process_new_page(text, pos)
    text.slice!(/^\n/)
    input_pause
    new_page(text, pos)
  end
 
  def process_draw_icon(icon_index, pos)
    super
    wait_for_one_character
  end
 
  def process_escape_character(code, text, pos)
    case code.upcase
    when '$'
      @gold_window.open
    when '.'
      wait(15)
    when '|'
      wait(60)
    when '!'
      input_pause
    when '>'
      @line_show_fast = true
    when '<'
      @line_show_fast = false
    when '^'
      @pause_skip = true
    else
      super
    end
  end
 
  def input_pause
    self.pause = true
    wait(10)
    #Fiber.yield until Input.trigger?(:B) || Input.trigger?(:C)
    Fiber.yield until $game_message.btn_pressed
    #Input.update
    self.pause = false
    $game_message.btn_pressed = false
  end
 
end # Window_Message2 < Window_Base
 
 
class Game_Message
  attr_accessor :texts2
  attr_accessor :face_name2
  attr_accessor :face_index2
  attr_accessor :remove2
  attr_accessor :disable_skip
  attr_accessor :btn_pressed
 
  alias galv_messages_message_initialize initialize
  def initialize
    galv_messages_message_initialize
    @remove2 = false
    clear2
  end
   
  def clear2
    @texts2 = ""
    @face_name2 = ""
    @face_index2 = 0
    @disable_skip = false
    @btn_pressed = false
  end
end # Game_Message
 
 
class Game_Interpreter
  def msg(texts, face_name, face_index)
    $game_message.texts2 = texts
    $game_message.face_name2 = face_name
    $game_message.face_index2 = face_index
  end
end # Game_Interpreter
 
 
class Scene_Map
  alias galv_messages_map_create_message_window create_message_window
  def create_message_window
    galv_messages_map_create_message_window
    @message_window2 = Window_Message2.new
  end
end # Scene_Map
 
 
class Window_Message < Window_Base
   
  alias galv_messages_window_wait_for_one_character wait_for_one_character
  def wait_for_one_character
    return Fiber.yield if $game_message.disable_skip || $game_switches[Galv_Msgs::DISABLE_SKIP_SWITCH]
    galv_messages_window_wait_for_one_character
  end
   
  alias galv_messages_window_close_and_wait close_and_wait
  def close_and_wait
    $game_message.clear2
    galv_messages_window_close_and_wait
  end
   
  alias galv_messages_window_input_pause input_pause
  def input_pause
    galv_messages_window_input_pause
    $game_message.btn_pressed = true
  end
   
end # Window_Message < Window_Base