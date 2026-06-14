#-------------------------------------------------------------------------------
# * [ACE] Khas Ultra Graphics - Graphics Menu Add-on
#-------------------------------------------------------------------------------
# * By Nilo K. (Khas)
# * Version: 1.00
# * Released on: 08/01/2015
#
# Blog: arcthunder.blogspot.com
# Facebook: facebook.com/khasarc
# Twitter: twitter.com/arcthunder
# Youtube: youtube.com/c/khasarc
#
#-------------------------------------------------------------------------------
# * Terms of Use
#-------------------------------------------------------------------------------
# Please read the terms of use included with this script. 
# The Khas Ultra Lighting requires the purchase of a license to be used.
# 
#-------------------------------------------------------------------------------
# * Requirements
#-------------------------------------------------------------------------------
# 1. Khas Core Library
#    Place the "Khas Core Library" script before this add-on.
#
# 2. Khas Graphics Library
#    Place the "Khas Graphics Library" script before this add-on.
#
# 3. Khas Ultra Lighting
#    Place the "Khas Ultra Lighting" script before this add-on.
#
#-------------------------------------------------------------------------------
# * Instructions
#-------------------------------------------------------------------------------
# This script adds a "Graphics" option to the default menu. If you are using
# a custom menu, just add an option to call Scene_Graphics in order to open
# the Graphics Settings.
#
#-------------------------------------------------------------------------------
# * Requirements
#-------------------------------------------------------------------------------
=begin
unless $khas_graphics && $khas_graphics[:ultra_lighting] >= 1.0
  warning = Sprite.new
  warning.bitmap = Bitmap.new(Graphics.width,Graphics.height)
  warning.bitmap.fill_rect(0,0,Graphics.width,Graphics.height,Color.new(255,255,255))
  warning.bitmap.font = Font.new("Verdana", 32)
  warning.bitmap.font.bold = true
  warning.bitmap.font.outline = false
  warning.bitmap.font.color.set(255,144,9)
  warning.bitmap.draw_text(0,Graphics.height/2-32,Graphics.width,32,"PLEASE INSTALL",1)
  warning.bitmap.draw_text(0,Graphics.height/2,Graphics.width,32,"KHAS ULTRA LIGHTING 1.0",1)
  while !Input.trigger?(:C)
    Input.update
    Graphics.update
  end
  warning.bitmap.dispose
  warning.dispose
  exit
end

#-------------------------------------------------------------------------------
# * Version
#-------------------------------------------------------------------------------

$khas_graphics[:graphics_menu] = 1.0

#-------------------------------------------------------------------------------
# * Window MenuCommand
#-------------------------------------------------------------------------------

class Window_MenuCommand < Window_Command
  
  alias kul_add_original_commands add_original_commands
  
  def add_original_commands
    kul_add_original_commands
    add_command("Graphics", :graphics)
  end
  
end

#-------------------------------------------------------------------------------
# * Scene Menu
#-------------------------------------------------------------------------------
 
class Scene_Menu < Scene_MenuBase
  
  alias kul_create_command_window create_command_window
  
  def create_command_window
    kul_create_command_window
    @command_window.set_handler(:graphics, method(:command_graphics))
  end
  
  def command_graphics
    SceneManager.call(Scene_Graphics)
  end
  
end

#-------------------------------------------------------------------------------
# * End
#-------------------------------------------------------------------------------
=end