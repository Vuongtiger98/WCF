#-------------------------------------------------------------------------------
# * [ACE] Khas Ultra Graphics - Item Lantern Add-on
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
# Please read the Ultra Lighting guide! It's a pdf file inside the demo folder.
#
#-------------------------------------------------------------------------------
# * Light Core (configuration)
#-------------------------------------------------------------------------------

module Light_Core
  
  # LANTERN KEY
  # Key used to activate the lantern.
  # :L -> Keyboard Q
  # :R -> Keyboard W
  # :X -> Keyboard A
  # :Y -> Keyboard S
  Lantern_Key = :L
  
  # LANTERN SWITCH
  # Switch that must be ON in order to use the lantern key.
  Lantern_Sw = 19
  
  # LANTERN POPUP (position)
  # X coordinate
  LPP_X = 32
  # Y coordinate
  LPP_Y = 360
  # Z coordinate
  LPP_Z = 100
  
  # LANTERN POPUP (font)
  # Font name
  LPP_Font = "Vani"
  # Font size
  LPP_Size = 20
  # Font bold
  LPP_Bold = false
  # Font italic
  LPP_Italic = false
  # Font outline
  LPP_Outline = false
  
end

#-------------------------------------------------------------------------------
# * Requirements
#-------------------------------------------------------------------------------

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

$khas_graphics[:item_lantern] = 1.0


#-------------------------------------------------------------------------------
# * RPG Item
#-------------------------------------------------------------------------------

class RPG::Item
  
  def light_id
    if @light_id.nil?
      @note.each_line do |line|
        if line.khas_command?
          if line.khas_command == "light"
            @light_id = line.khas_value
            return @light_id
          end
        end
      end
      @light_id = 0
    end
    @light_id
  end
  
end

#-------------------------------------------------------------------------------
# * Game Player
#-------------------------------------------------------------------------------

class Game_Player < Game_Character
  
  alias kull_update update
  
  def update
    kull_update
    refresh_lantern if Input.trigger?(Lantern_Key) && $game_switches[Lantern_Sw]
  end
  
  def refresh_lantern
    return if $game_map.interpreter.running?
    $game_map.lantern_popup.dispose if $game_map.lantern_popup
    $game_map.lantern_popup = nil
    light_items = []
    for item in $game_party.items
      light_items << item if item.light_id.is_a?(String)
    end
    if light_items.empty?
      drop_light
      return
    end
    clight = nil
    if carrying_light?
      clight = @light.id
      drop_light
    end
    light_items.uniq! { |item| item.light_id }
    li = light_items.index { |item| item.light_id == clight }
    if li
      if (li + 1) < light_items.size
        $game_map.lantern_popup = Lantern_Popup.new(light_items[li+1])
        give_light(light_items[li+1].light_id)
      end
    else
      $game_map.lantern_popup = Lantern_Popup.new(light_items[0])
      give_light(light_items[0].light_id)
    end
  end
  
end

#-------------------------------------------------------------------------------
# * Game Map
#-------------------------------------------------------------------------------

class Game_Map
  
  attr_accessor :lantern_popup
  
end

#-------------------------------------------------------------------------------
# * Lantern Popup
#-------------------------------------------------------------------------------

class Lantern_Popup
  
  def initialize(item)
    @item = item
    @timer = 14
    restore
  end
  
  def dispose
    return unless @popup
    @popup.dispose
    @popup = nil
  end
  
  def restore
    @popup = Sprite_Lantern.new(@item)
  end
  
  def update
    if @timer < 0
      @popup.opacity = 255 + @timer*7
      if @popup.opacity <= 0
        @popup.dispose
        $game_map.lantern_popup = nil
      end
    end
    @timer -= 1
  end
  
end

#-------------------------------------------------------------------------------
# * Sprite Lantern
#-------------------------------------------------------------------------------

class Sprite_Lantern < Sprite
  
  include Light_Core
  
  def initialize(item)
    super(nil)
    self.x = LPP_X
    self.y = LPP_Y
    self.z = LPP_Z
    self.bitmap = Bitmap.new(192, 24)
    self.bitmap.font = Font.new(LPP_Font, LPP_Size)
    self.bitmap.font.bold = LPP_Bold
    self.bitmap.font.italic = LPP_Italic
    self.bitmap.font.outline = LPP_Outline
    self.bitmap.draw_text(32,0,160,24,item.name)
    rect = Rect.new(item.icon_index % 16 * 24, item.icon_index / 16 * 24, 24, 24)
    self.bitmap.blt(0, 0, Cache.system("Iconset"), rect)
  end
  
  def dispose
    return if disposed?
    self.bitmap.dispose
    super
  end
  
end

#-------------------------------------------------------------------------------
# * Spriteset Map
#-------------------------------------------------------------------------------

class Spriteset_Map
  
  alias kulf_initialize initialize
  alias kulf_update update
  alias kulf_dispose dispose
  
  def initialize
    $game_map.lantern_popup.restore if $game_map.lantern_popup
    kulf_initialize
  end
  
  def update
    kulf_update
    $game_map.lantern_popup.update if $game_map.lantern_popup
  end
  
  def dispose
    kulf_dispose
    $game_map.lantern_popup.dispose if $game_map.lantern_popup
  end
  
end

#-------------------------------------------------------------------------------
# * End
#-------------------------------------------------------------------------------
