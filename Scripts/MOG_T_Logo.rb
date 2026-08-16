#==============================================================================
# MOG Title Multilogo - Wonder Christmas Fiesta patch
#==============================================================================
# Startup order:
#   1. Salt_Pebbles flies in, pauses at screen centre and plays a temporary SE.
#   2. Logo_0, Logo_1, ... use the original MOG fade sequence.
#==============================================================================
module MOG_MLOGOS
  FILE_NAME = "Logo_"
  MASCOT_FILE = "Salt_Pebbles"
  MASCOT_SE = "cute-squeak-1"
  MASCOT_FLY_DURATION = 60
  MASCOT_HOLD_DURATION = 45
  MASCOT_FADE_DURATION = 20
  LOGO_DURATION = 30
  SKIP_BUTTON = true
end

$imported = {} if $imported.nil?
$imported[:mog_title_multilogo] = true

class Scene_Title < Scene_Base
  alias mog_t_logo_main main
  def main
    execute_tlogo if $logo_enabled.nil?
    mog_t_logo_main
  end

  def execute_tlogo
    $logo_enabled = true
    Graphics.transition(transition_speed)
    logo = M_Logo.new
    loop do
      Input.update
      logo.update
      Graphics.update
      break if logo.phase == 1
    end
    logo.dispose
  end
end

class M_Logo
  include MOG_MLOGOS
  attr_accessor :phase

  def initialize
    @phase = 0
    @stage = :mascot
    @frame = 0
    @logo_index = 0
    @logos = []
    999.times do |index|
      begin
        @logos << Cache.title1(FILE_NAME + index.to_s)
      rescue
        break
      end
    end
    @sprite = Sprite.new
    @sprite.z = 999
    show_mascot
  end

  def show_mascot
    @sprite.bitmap = Cache.title1(MASCOT_FILE)
    centre_sprite
    @sprite.x = -(@sprite.bitmap.width / 2)
    @sprite.opacity = 0
    @sprite.angle = 0
    @mascot_se_played = false
  end

  def show_logo
    bitmap = @logos[@logo_index]
    unless bitmap
      @phase = 1
      return
    end
    @sprite.bitmap = bitmap
    centre_sprite
    @sprite.angle = 0
    @sprite.opacity = 0
    @frame = 0
  end

  def centre_sprite
    @sprite.ox = @sprite.bitmap.width / 2
    @sprite.oy = @sprite.bitmap.height / 2
    @sprite.x = Graphics.width / 2
    @sprite.y = Graphics.height / 2
  end

  def update
    update_skip
    return if @phase == 1
    @frame += 1
    @stage == :mascot ? update_mascot : update_logo
  end

  def update_mascot
    fly_duration = [MASCOT_FLY_DURATION, 1].max
    hold_end = fly_duration + [MASCOT_HOLD_DURATION, 1].max
    end_frame = hold_end + [MASCOT_FADE_DURATION, 1].max
    if @frame <= fly_duration
      # Ease-out cubic: fast outside the screen, then gently stops at centre.
      progress = @frame.to_f / fly_duration
      eased = 1.0 - (1.0 - progress) ** 3
      start_x = -(@sprite.bitmap.width / 2)
      target_x = Graphics.width / 2
      @sprite.x = start_x + ((target_x - start_x) * eased)
      @sprite.opacity = [@frame * 12, 255].min
      if @frame == fly_duration && !@mascot_se_played
        Audio.se_play("Audio/SE/" + MASCOT_SE, 90, 100)
        @mascot_se_played = true
      end
    elsif @frame <= hold_end
      @sprite.x = Graphics.width / 2
      @sprite.opacity = 255
    else
      @sprite.opacity = [255 - ((@frame - hold_end) * 255 / MASCOT_FADE_DURATION), 0].max
    end
    return if @frame < end_frame
    @stage = :logos
    show_logo
  end

  def update_logo
    hold_end = 30 + [LOGO_DURATION, 5].max
    end_frame = hold_end + 60
    if @frame <= 30
      @sprite.opacity = [@frame * 9, 255].min
    elsif @frame <= hold_end
      @sprite.opacity = 255
    else
      @sprite.opacity = [255 - ((@frame - hold_end) * 5), 0].max
    end
    return if @frame < end_frame
    @logo_index += 1
    show_logo
  end

  def update_skip
    return unless SKIP_BUTTON
    return unless Input.trigger?(:C) || Input.trigger?(:B)
    @phase = 1
  end

  def dispose
    Graphics.freeze
    @sprite.dispose unless @sprite.disposed?
  end
end

class Scene_Base
  alias mog_t_mlogos_terminate terminate
  def terminate
    mog_t_mlogos_terminate
    unless SceneManager.scene_is?(Scene_Title) || SceneManager.scene_is?(Scene_Load)
      $logo_enabled = nil
    end
  end
end

class << SceneManager
  alias mog_t_mlogos_first_scene_class first_scene_class
  def first_scene_class
    $logo_enabled = nil
    mog_t_mlogos_first_scene_class
  end
end
