#==============================================================================
# MOG Title Name - Wonder Christmas Fiesta title-state patch
#==============================================================================
module HAIQUY_TITLE
  EASTER_EGG_FILE = "HaiQuy.txt"
  EASTER_EGG_TEXT = "Anizoa Drosallie  Hexacoral  Dahria  Actini"
  NORMAL_BACKGROUNDS = ["Title_Screen_1", "Title_Screen_2"]
  GLITCH_BACKGROUNDS = ["Title_Screen_3", "Title_Screen_4"]
  GLITCH_INTERVAL = 180
  GLITCH_DURATION = 24

  @ending_background = nil

  # Session-only title override used immediately after an ending. Normal
  # startup continues to use the easter/glitch title rules above.
  def self.set_ending_background(filename)
    @ending_background = filename.to_s
  end

  def self.ending_background
    @ending_background
  end

  def self.clear_ending_background
    @ending_background = nil
  end

  def self.easter_egg?
    File.exist?(EASTER_EGG_FILE)
  end

  # Script call: HAIQUY_TITLE.create_easter_egg
  def self.create_easter_egg
    File.open(EASTER_EGG_FILE, "wb") { |file| file.write(EASTER_EGG_TEXT) }
    true
  rescue
    false
  end

  # Script call: HAIQUY_TITLE.delete_easter_egg
  def self.delete_easter_egg
    File.delete(EASTER_EGG_FILE) if File.exist?(EASTER_EGG_FILE)
    true
  rescue
    false
  end
end

module EndingPresentation
  def self.show_gallery(filename, hold_frames = 180)
    sprite = Sprite.new
    sprite.z = 9999
    sprite.bitmap = Cache.load_bitmap("Graphics/Gallery/", filename.to_s)
    sprite.ox = sprite.bitmap.width / 2
    sprite.oy = sprite.bitmap.height / 2
    sprite.x = Graphics.width / 2
    sprite.y = Graphics.height / 2
    sprite.zoom_x = Graphics.width.to_f / sprite.bitmap.width
    sprite.zoom_y = Graphics.height.to_f / sprite.bitmap.height
    sprite.opacity = 0
    30.times do
      sprite.opacity += 9
      Graphics.update
      Input.update
    end
    elapsed = 0
    while elapsed < hold_frames
      Graphics.update
      Input.update
      elapsed += 1
      break if elapsed >= 45 && (Input.trigger?(:C) || Input.trigger?(:B))
    end
    30.times do
      sprite.opacity -= 9
      Graphics.update
      Input.update
    end
  ensure
    sprite.dispose if sprite && !sprite.disposed?
  end
end

module MOG_TITLE_NAME
  X_POS = Graphics.width / 2
  Y_POS = Graphics.height / 2
  WAVE_EFFECT = false
  WAVE_POWER = 5
  WAVE_SPEED = 2
  FILE_NAME = "Title name"
end

$imported = {} if $imported.nil?
$imported[:mog_title_name] = true

class Scene_Title < Scene_Base
  alias haiquy_title_create_background create_background
  def create_background
    @haiquy_ending_title = !HAIQUY_TITLE.ending_background.to_s.empty?
    @haiquy_easter_title = HAIQUY_TITLE.easter_egg?
    @haiquy_glitch_frame = 0
    @haiquy_glitch_index = 0
    @sprite1 = Sprite.new
    @sprite2 = Sprite.new
    if @haiquy_ending_title
      @sprite1.bitmap = Cache.load_bitmap("Graphics/Gallery/", HAIQUY_TITLE.ending_background)
      @sprite2.bitmap = Bitmap.new(1, 1)
      @sprite2.opacity = 0
    elsif @haiquy_easter_title
      name = HAIQUY_TITLE::NORMAL_BACKGROUNDS[rand(HAIQUY_TITLE::NORMAL_BACKGROUNDS.size)]
      @sprite1.bitmap = Cache.title1(name)
      @sprite2.bitmap = Bitmap.new(1, 1)
      @sprite2.opacity = 0
    else
      @sprite1.bitmap = Cache.title1(HAIQUY_TITLE::GLITCH_BACKGROUNDS[0])
      @sprite2.bitmap = Cache.title1(HAIQUY_TITLE::GLITCH_BACKGROUNDS[1])
      @sprite2.opacity = 0
    end
    center_sprite(@sprite1)
    center_sprite(@sprite2)
  end

  # Always draw the supplied title image, regardless of the Database option
  # "Draw Game Title". That option only applies to VX Ace's text title.
  def create_foreground
    @foreground_sprite = Sprite.new
    @foreground_sprite.z = 100
    draw_game_title
  end

  def draw_game_title
    @foreground_sprite.bitmap = Cache.title1(MOG_TITLE_NAME::FILE_NAME)
    @foreground_sprite.opacity = 0
    @foreground_sprite.ox = @foreground_sprite.bitmap.width / 2
    @foreground_sprite.oy = @foreground_sprite.bitmap.height / 2
    @foreground_sprite.x = MOG_TITLE_NAME::X_POS + (MOG_TITLE_NAME::WAVE_POWER / 2)
    @foreground_sprite.y = MOG_TITLE_NAME::Y_POS
    return unless MOG_TITLE_NAME::WAVE_EFFECT
    @foreground_sprite.wave_amp = MOG_TITLE_NAME::WAVE_POWER
    @foreground_sprite.wave_length = @foreground_sprite.bitmap.width
    @foreground_sprite.wave_speed = 100 + 100 * MOG_TITLE_NAME::WAVE_SPEED
  end

  alias mog_t_foreground_sprite_update update
  def update
    mog_t_foreground_sprite_update
    @foreground_sprite.opacity += 3
    @foreground_sprite.update
    update_haiquy_glitch_title unless @haiquy_easter_title || @haiquy_ending_title
  end

  def update_haiquy_glitch_title
    @haiquy_glitch_frame += 1
    interval = HAIQUY_TITLE::GLITCH_INTERVAL
    duration = HAIQUY_TITLE::GLITCH_DURATION
    return if @haiquy_glitch_frame < interval
    phase = @haiquy_glitch_frame - interval
    if phase == 0
      @sprite2.opacity = 0
    elsif phase < duration
      @sprite2.opacity = phase.even? ? 220 : 80
      offset = phase % 5 - 2
      @sprite1.x = Graphics.width / 2 + offset
      @sprite2.x = Graphics.width / 2 - offset
      @sprite1.tone.set(phase.even? ? 35 : -20, -15, phase.even? ? -25 : 30, 0)
    else
      old = @sprite1.bitmap
      @sprite1.bitmap = @sprite2.bitmap
      @sprite2.bitmap = old
      @sprite1.opacity = 255
      @sprite2.opacity = 0
      @sprite1.x = Graphics.width / 2
      @sprite2.x = Graphics.width / 2
      @sprite1.tone.set(0, 0, 0, 0)
      @sprite2.tone.set(0, 0, 0, 0)
      @haiquy_glitch_index = 1 - @haiquy_glitch_index
      @haiquy_glitch_frame = 0
    end
  end
end
