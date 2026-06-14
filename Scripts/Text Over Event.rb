# =============================================================================
# TheoAllen - Simple Text Over Event
# Version : 1.0
# Contact : www.rpgmakerid.com (or) http://theolized.blogspot.com
# (This script documentation is written in informal indonesian language)
# =============================================================================
($imported ||= {})[:Theo_TextEvent] = true
# =============================================================================
# CHANGE LOGS:
# -----------------------------------------------------------------------------
# 2013.06.09 - Finished script
# =============================================================================
=begin

  Introduction:
This script only displays text above an event.

How to use:
Place it below Materials but above Main.
Write <text: anything> in the event’s name if you want the text to be displayed.

TERMS OF USE:
Give me credit, TheoAllen. If you edit or improve my script and make it cooler, 
that’s fine—I’m okay with it. Just don’t claim it as your own. 
If you want to use it for commercial purposes, don’t forget to share some 
of the freebies/profits with me.

=end
# =============================================================================
# Konfigurasi kecil2an :
# =============================================================================
module THEO
  module MAP
    
    # Lebar window yg diisi text
    WINDOW_WIDTH = 200
    
    # Size font
    FONT_SIZE   = 17
    
    # Warnanya (red,green,blue
    FONT_COLOR  = Color.new(255,130,255)
    
    # Posisi offset dari koordinat y
    OFFSET_Y    = 0
    
  end
end
# =============================================================================
# Batas konfigurasi
# =============================================================================
module THEO
  module MAP
    module REGEXP
      
      TEXT = /<(?:TEXT|text):(.*)>/i
      
    end
  end
end


class Window_CharText < Window_Base
  
  include THEO::MAP
  
  def initialize(char,text)
    @char = char
    @text = text
    super(0,0,window_width,window_height)
    self.opacity = 0
    contents.font.size = FONT_SIZE
    update_placement
    refresh
  end
  
  def update_placement
    return unless @char
    self.x = @char.screen_x - self.width/2
    self.y = @char.screen_y - 20 - self.height - OFFSET_Y
  end
  
  def update
    super
    update_placement
  end
  
  def refresh
    contents.clear
    draw_text(0,0,contents.width,FONT_SIZE,@text,1)
  end
  
  def window_width
    WINDOW_WIDTH
  end
  
  def window_height
    return FONT_SIZE + standard_padding*2
  end
  
end

class Game_Event < Game_Character
  
  def name
    @event.name
  end
  
end

class Scene_Map < Scene_Base
  
  include THEO::MAP
  
  alias pre_text_over_event_start start
  def start
    pre_text_over_event_start
    create_text_event_windows
  end
  
  def create_text_event_windows
    @event_text_windows = []
    $game_map.events.values.each do |event|
      case event.name
      when REGEXP::TEXT
        text = $1.to_s
        @event_text_windows.push(Window_CharText.new(event,text))
      end
    end
  end
  
  alias pre_update_window_text update
  def update
    pre_update_window_text
    update_text_window
  end
  
  def update_text_window
    @event_text_windows.each {|w| w.update}
  end
  
  alias pre_text_event_terminate terminate
  def termminate
    pre_text_event_terminate
    dispose_text_event_windows
  end
  
  def dispose_text_event_windows
    @event_text_windows.each {|w| w.dispose}
  end
  
  alias text_event_post_transfer post_transfer
  def post_transfer
    dispose_text_event_windows
    create_text_event_windows
    text_event_post_transfer
  end
  
end