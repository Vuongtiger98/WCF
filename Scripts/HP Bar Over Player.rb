
# =============================================================================
# TheoAllen - HP Bar Over Player
# Version : 1.0
# Contact : www.rpgmakerid.com (or) http://theolized.blogspot.com
# (This script documentation is written in informal indonesian language)
# =============================================================================
($imported ||= {})[:Theo_MapHP] = true
# =============================================================================
# Change Logs:
# -----------------------------------------------------------------------------
# 2013.10.28 - Finished script
# =============================================================================
=begin

  Perkenalan :
  Script ini ngebikin kamu bisa nampilin HP Bar diatas player
  
  Cara penggunaan :
  Pasang script ini dibawah material namun diatas main
  Gunakan script call berikut untuk memunculkan / mematikan HP bar
  - $game_party.maphp = true (ON)
  - $game_party.maphp = false (OFF)
  
  Terms of use :
  Credit gw, TheoAllen. Kalo semisal u bisa ngedit2 script gw trus jadi lebih
  keren, terserah. Ane bebasin. Asal ngga ngeklaim aja. Kalo semisal mau
  dipake buat komersil, jangan lupa, gw dibagi gratisannya.  

=end
# =============================================================================
# Konfigurasi :
# =============================================================================
=begin
module Theo
  module MapHP
    
  # -------------------------------------------------------------------------
  # Berdasar apakah maksimal HP ditampilkan pada bar?
  # 0 - Leader
  # 1 - Battle Members
  # 2 - All Members  
  # -------------------------------------------------------------------------
    Mode = 2
  # -------------------------------------------------------------------------
    
  # -------------------------------------------------------------------------
  # Setting untuk ukuran HP Bar
  # -------------------------------------------------------------------------
    Width   = 60    # Lebar
    Height  = 5     # Tinggi
  # -------------------------------------------------------------------------
  
  # -------------------------------------------------------------------------
  # Setting untuk warna HP Bar
  # Isi dengan Color.new(merah, hijau, biru)
  # Masing2 attribut warna maksimal nilainya adalah 255
  # -------------------------------------------------------------------------
    BackColor   = Color.new(0,0,0)        # Warna background
    FillColor1  = Color.new(0,0,255)   # Warna gradient samping kiri
    FillColor2  = Color.new(255,0,0)   # Warna gradient samping kanan
  # -------------------------------------------------------------------------
  
  # -------------------------------------------------------------------------
  # Alterasi / Perubahan 
  # -------------------------------------------------------------------------
    AlterSpeed  = 1   # Kecepatan bar berubah nilai (minimal: 1)
    FadeSpeed   = 48  # Kecepatan fadeout/fadein saat bar dimatikan atau
  #                     dihidupkan
  # -------------------------------------------------------------------------
  
  end
end
# =============================================================================
# Akhir dari konfigurasi
# =============================================================================
class Game_Party
  attr_accessor :maphp
  
  alias theo_maphp_init initialize
  def initialize
    theo_maphp_init
    @maphp = true
  end
  
  def maphp_members
    (Theo::MapHP::Mode == 1 ? battle_members : all_members)
  end
  
  def mhp
    maphp_members.inject(0) do |r, actor|
      r += actor.mhp
    end
  end
  
  def hp
    maphp_members.inject(0) do |r, actor|
      r += actor.hp
    end
  end
  
  def hp_rate
    hp / mhp.to_f
  end
  
end

class HP_Background < Sprite
  include Theo::MapHP
  @@bitmap_graphic = nil
  
  def initialize(viewport)
    super(viewport)
    self.opacity = ($game_party.maphp ? 255 : 0)
    set_bitmap
    update
  end
  
  def set_bitmap
    unless @@bitmap_graphic
      self.bitmap = Bitmap.new(Width + 2, Height + 2)
      bitmap.fill_rect(bitmap.rect, BackColor)
      @@bitmap_graphic = bitmap
    else
      self.bitmap = @@bitmap_graphic
    end
    self.ox = bitmap.width/2
    self.oy = bitmap.height
  end
  
  def update
    super
    update_placement
    update_visibility
  end
  
  def update_placement
    self.x = $game_player.screen_x
    self.y = $game_player.screen_y - 35
  end
  
  def update_visibility
    self.opacity += $game_party.maphp ? FadeSpeed : -FadeSpeed
  end
  
end

class HP_Fill < Sprite
  include Theo::MapHP
  @@bitmap_graphic = nil
  
  def initialize(viewport)
    super(viewport)
    self.opacity = ($game_party.maphp ? 255 : 0)
    set_bitmap
    determine_method
    update
  end
  
  def set_bitmap
    unless @@bitmap_graphic
      self.bitmap = Bitmap.new(Width,Height)
      bitmap.gradient_fill_rect(bitmap.rect, FillColor1, FillColor2)
      @@bitmap_graphic = bitmap
    else
      self.bitmap = @@bitmap_graphic
    end
    self.ox = bitmap.width/2
    self.oy = bitmap.height
  end
  
  def determine_method
    @method = (Mode == 0) ? method(:party_leader) : method(:whole_party)
  end
  
  def update
    super
    update_placement
    update_src_rect
    update_visibility
  end
  
  def update_placement
    self.x = $game_player.screen_x
    self.y = $game_player.screen_y - 36
  end
  
  def update_src_rect
    rate = @method.call
    if src_rect.width < rate
      src_rect.width = [src_rect.width + AlterSpeed,rate].min
    elsif src_rect.width > rate
      src_rect.width = [src_rect.width - AlterSpeed,rate].max
    end
  end
  
  def update_visibility
    self.opacity += $game_party.maphp ? FadeSpeed : -FadeSpeed
  end
  
  def whole_party
    bitmap.width * $game_party.hp_rate
  end
  
  def party_leader
    bitmap.width * $game_party.leader.hp_rate
  end
  
end

class HP_Bar
  
  def initialize(viewport)
    @hp_bg = HP_Background.new(viewport)
    @hp_fill = HP_Fill.new(viewport)
    @hp_fill.z = 150
  end
  
  def update
    @hp_bg.update
    @hp_fill.update
  end
  
  def dispose
    @hp_bg.dispose
    @hp_fill.dispose
  end
  
end

class Scene_Map < Scene_Base
  
  alias theo_maphp_start start
  def start
    theo_maphp_start
    @hp_bar = HP_Bar.new(@viewport)
  end
  
  alias theo_maphp_update update
  def update
    theo_maphp_update
    @hp_bar.update
  end
  
  alias theo_maphp_terminate terminate
  def terminate
    theo_maphp_terminate
    @hp_bar.dispose
  end
  
end

=end