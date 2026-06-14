#==============================================================================
# 
# ▼ Yanfly Engine Ace - Command Window Icons v1.00
# -- Last Updated: 2011.12.11
# -- Level: Normal
# -- Requires: n/a
# 
#==============================================================================

$imported = {} if $imported.nil?
$imported["YEA-CommandWindowIcons"] = true

#==============================================================================
# ▼ Updates
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# 2011.12.11 - Started Script and Finished.
# 
#==============================================================================
# ▼ Introduction
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# Here's a script that allows you to allocate icons to each of your commands
# provided that the text for the command matches the icon in the script. There
# are, however, some scripts that this won't be compatible with and it's due
# to them using unique way of drawing out their commands. This script does not
# maintain compatibility for those specific scripts.
# 
#==============================================================================
# ▼ Instructions
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# To install this script, open up your script editor and copy/paste this script
# to an open slot below ▼ Materials/素材 but above ▼ Main. Remember to save.
# 
# Go to the module and match the text under ICON_HASH with a proper Icon ID.
# You can find an icon's ID by opening up the icon select window in the RPG
# Maker VX Ace database and look in the lower left corner.
# 
#==============================================================================
# ▼ Compatibility
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script is made strictly for RPG Maker VX Ace. It is highly unlikely that
# it will run with RPG Maker VX without adjusting.
# 
#==============================================================================

module YEA
  module COMMAND_WINDOW_ICONS
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Icon Hash -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # This hash controls all of the icon data for what's used with each text
    # item. Any text items without icons won't display icons. The text has to
    # match with the hash (case sensitive) to display icons.
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    ICON_HASH ={
    # Matching Text   => Icon ID,
      "Chơi mới"      => 224,    # Title scene.
      "Chơi tiếp"      => 230,    # Title scene.
      "Thoát"      => 368,    # Title scene. Game End scene.
      
      "Fight"         => 386,    # Battle scene.
      "Escape"        => 328,    # Battle scene.
      "Attack"        => 824,    # Battle scene.
      "Guard"         => 826,    # Battle scene.
      
      "Special Skill" => 1769,    # Skill scene. Battle scene.
      "Magic"         => 136,    # Skill scene. Battle scene.
      
      "Special"       => 1769,    # Menu scene. Skill
      "Learn Skills"  => 324,    # Menu scene. Skill
      "TP Mode"       => 506,    # Menu scene. Skill
      "Primary"       => 708,    # Menu scene. Class
      "Subclass"      => 710,    # Menu scene. Class
      "Đồ dùng"         => 1339,    # Menu scene. Item scene. Battle scene.
      "Đồ quan trọng"   => 1971,
      "Skills"        => 816,    # Menu scene.
      "Equipment"     => 820,    # Menu scene.
      "Class"         => 1574,   # Menu scene.
      "Status"        => 399,    # Menu scene.
      "Formation"     => 137,    # Menu scene.
      "Relationship"  => 712,    # Menu scene.
      "Graphics"      => 692,    # Menu scene.
      "Lưu"          => 822,    # Menu scene.
      "Cài đặt"        => 827,    # Menu scene.
      "Gallery"        =>141,
      
      
      "Weapons"       => 467,    # Item scene.
      "Armours"       => 609,    # Item scene.
      "Key Items"     =>  83,    # Item scene.
      "Nguyên liệu"   =>  1385,
      
      "Dụng cụ"       =>  185,
      
      "Màn hình chính"      => 224,    # Game End scene.
      "Hủy bỏ"        => 119,    # Game End scene.
    } # Do not remove this.
    
  end # COMMAND_WINDOW_ICONS
end # YEA

#==============================================================================
# ▼ Editting anything past this point may potentially result in causing
# computer damage, incontinence, explosion of user's head, coma, death, and/or
# halitosis so edit at your own risk.
#==============================================================================

#==============================================================================
# ■ Window_Command
#==============================================================================

class Window_Command < Window_Selectable
  
  #--------------------------------------------------------------------------
  # new method: use_icon?
  #--------------------------------------------------------------------------
  def use_icon?(text)
    return YEA::COMMAND_WINDOW_ICONS::ICON_HASH.include?(text)
  end
  
  #--------------------------------------------------------------------------
  # new method: command_icon
  #--------------------------------------------------------------------------
  def command_icon(text)
    return YEA::COMMAND_WINDOW_ICONS::ICON_HASH[text]
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: draw_item
  #--------------------------------------------------------------------------
  def draw_item(index)
    enabled = command_enabled?(index)
    change_color(normal_color, enabled)
    rect = item_rect_for_text(index)
    text = command_name(index)
    if use_icon?(text)
      draw_icon_text(rect.clone, text, alignment, enabled)
    else
      draw_text(rect, text, alignment)
    end
  end
  
  #--------------------------------------------------------------------------
  # new method: draw_icon_text
  #--------------------------------------------------------------------------
  def draw_icon_text(rect, text, alignment, enabled)
    cw = text_size(text).width
    icon = command_icon(text)
    draw_icon(icon, rect.x, rect.y, enabled)
    rect.x += 24
    rect.width -= 24
    draw_text(rect, text, alignment)
  end
  
end # Window_Command

#==============================================================================
# 
# ▼ End of File
# 
#==============================================================================