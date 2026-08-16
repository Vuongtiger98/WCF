#==============================================================================
# ** Character Petting Minigame
#==============================================================================

module CattoPetting
  DEMO_BGM = ["Theme2", 75, 100]

  BODY_IMAGE = "Body"
  HEAD_IMAGE = "Head"
  BITE_IMAGE = "Bite"
  HAND_IMAGE = "Hand"

  SCORE_TEXT      = "Điểm số"
  RETRY_TEXT      = "Chơi lại nhé?"
  RETRY_YES_TEXT  = "Chơi lại"
  RETRY_NO_TEXT   = "Bỏ cuộc"

  MOVE_SPEED = 5
  START_X    = 320
  START_Y    = 240

  SCREEN_MIN_X = 0
  SCREEN_MIN_Y = 0
  SCREEN_MAX_X = 639
  SCREEN_MAX_Y = 479

  HAND_OX = 320
  HAND_OY = 240

  BODY_CHECK_RADIUS = 10
  BODY_WHITE_THRESHOLD = 245

  HAND_SWIPE_ANGLE_LEFT  = -8
  HAND_SWIPE_ANGLE_RIGHT = 8
  HAND_SWIPE_SPEED       = 0.45
  HAND_STOP_DECAY        = 0.35

  SCORE_PER_MOVE   = 1
  DIFF_STEP_SCORE  = 80

  SAFE_MIN_FRAMES  = 90
  SAFE_MAX_FRAMES  = 160
  SAFE_MIN_LIMIT   = 26
  SAFE_MAX_LIMIT   = 58

  HEAD_MIN_FRAMES  = 36
  HEAD_MAX_FRAMES  = 62
  HEAD_MIN_LIMIT   = 18
  HEAD_MAX_LIMIT   = 32

  REACT_MIN_FRAMES = 20
  REACT_MAX_FRAMES = 34
  REACT_MIN_LIMIT  = 8
  REACT_MAX_LIMIT  = 14

  BITE_FOCUS_X     = 320
  BITE_FOCUS_Y     = 240
  BITE_ZOOM_START  = 1.0
  BITE_ZOOM_END    = 2.4
  BITE_ZOOM_FRAMES = 36

  SCORE_TEXT_SIZE = 28
  RETRY_TEXT_SIZE = 28
  RETRY_CMD_SIZE  = 28

  RETRY_BOX_X      = 210
  RETRY_BOX_Y      = 205
  RETRY_BOX_WIDTH  = 220
  RETRY_BOX_HEIGHT = 110
  RETRY_CMD1_Y     = 40
  RETRY_CMD2_Y     = 66

  SE_PET     = "zapsplat"
  SE_WARNING = "cute-squeak-1"
  SE_BITE    = "earape-undertale"
  SE_CONFIRM = "Decision1"
  SE_CANCEL  = "Cancel2"
  SE_CURSOR  = "Cursor2"

  # How long one wiping SE should be treated as still playing.
  # Increase if your zapsplat sound is long.
  PET_SE_DURATION_FRAMES = 30
  PET_SE_VOLUME = 55
  PET_SE_PITCH  = 100

  RESULT_VARIABLE_ID = 0
end

class Scene_CattoPetting < Scene_Base
  include CattoPetting

  def start
    $game_system.save_bgm
    super
    create_main_sprites
    create_ui
    create_retry_objects
    init_game
    RPG::BGM.new(DEMO_BGM[0], DEMO_BGM[1], DEMO_BGM[2]).play
  end

  def terminate
    super
    dispose_catto_all
    RPG::BGM.stop
    $game_system.replay_bgm
  end

  def init_game
    stop_all_se

    @score = 0
    @phase = :safe
    @phase_count = random_safe_duration
    @reaction_count = 0
    @hand_x = START_X
    @hand_y = START_Y
    @earned_any_score = false
    @zoom_frame = 0
    @retry_index = 0
    @hand_swipe_phase = 0.0
    @hand_swiping = false

    @pet_se_timer = 0
    @pet_se_active = false

    @body_sprite.visible = true
    @body_sprite.opacity = 255
    @body_sprite.zoom_x = 1.0
    @body_sprite.zoom_y = 1.0
    @body_sprite.ox = 0
    @body_sprite.oy = 0
    @body_sprite.x = 0
    @body_sprite.y = 0

    @head_sprite.visible = false
    @head_sprite.opacity = 255
    @head_sprite.zoom_x = 1.0
    @head_sprite.zoom_y = 1.0
    @head_sprite.ox = 0
    @head_sprite.oy = 0
    @head_sprite.x = 0
    @head_sprite.y = 0

    setup_bite_sprite_default

    @flash_sprite.opacity = 0

    @retry_box.visible = false
    @retry_cursor.visible = false
    refresh_retry_texts(false)

    @hand_sprite.visible = true
    @hand_sprite.angle = 0
    @hand_sprite.opacity = 255
    update_hand_position

    refresh_score
  end

  def create_main_sprites
    @body_sprite = Sprite.new
    @body_sprite.bitmap = Cache.load_bitmap("Graphics/Catto/", BODY_IMAGE)
    @body_sprite.x = 0
    @body_sprite.y = 0
    @body_sprite.z = 10

    @head_sprite = Sprite.new
    @head_sprite.bitmap = Cache.load_bitmap("Graphics/Catto/", HEAD_IMAGE)
    @head_sprite.x = 0
    @head_sprite.y = 0
    @head_sprite.z = 20
    @head_sprite.visible = false

    @bite_sprite = Sprite.new
    @bite_sprite.bitmap = Cache.load_bitmap("Graphics/Catto/", BITE_IMAGE)
    @bite_sprite.z = 30
    @bite_sprite.visible = false

    @hand_sprite = Sprite.new
    @hand_sprite.bitmap = Cache.load_bitmap("Graphics/Catto/", HAND_IMAGE)
    @hand_sprite.ox = HAND_OX
    @hand_sprite.oy = HAND_OY
    @hand_sprite.z = 100

    @flash_sprite = Sprite.new
    @flash_sprite.bitmap = Bitmap.new(Graphics.width, Graphics.height)
    @flash_sprite.bitmap.fill_rect(0, 0, Graphics.width, Graphics.height, Color.new(255,255,255))
    @flash_sprite.z = 200
    @flash_sprite.opacity = 0
  end

  def create_ui
    @score_sprite = Sprite.new
    @score_sprite.bitmap = Bitmap.new(Graphics.width, 48)
    @score_sprite.x = 0
    @score_sprite.y = 6
    @score_sprite.z = 300
  end

  def create_retry_objects
    @retry_box = Sprite.new
    @retry_box.bitmap = Bitmap.new(RETRY_BOX_WIDTH, RETRY_BOX_HEIGHT)
    @retry_box.x = RETRY_BOX_X
    @retry_box.y = RETRY_BOX_Y
    @retry_box.z = 500
    draw_retry_box

    @retry_cursor = Sprite.new
    @retry_cursor.bitmap = Bitmap.new(24, 24)
    c = @retry_cursor.bitmap
    c.fill_rect(0, 10, 18, 4, Color.new(255,255,255))
    c.fill_rect(14, 6, 4, 4, Color.new(255,255,255))
    c.fill_rect(18, 10, 4, 4, Color.new(255,255,255))
    c.fill_rect(14, 14, 4, 4, Color.new(255,255,255))
    @retry_cursor.z = 510

    @retry_title_sprite = Sprite.new
    @retry_title_sprite.bitmap = Bitmap.new(RETRY_BOX_WIDTH, 32)
    @retry_title_sprite.x = RETRY_BOX_X
    @retry_title_sprite.y = RETRY_BOX_Y + 8
    @retry_title_sprite.z = 510

    @retry_yes_sprite = Sprite.new
    @retry_yes_sprite.bitmap = Bitmap.new(RETRY_BOX_WIDTH, 32)
    @retry_yes_sprite.x = RETRY_BOX_X
    @retry_yes_sprite.y = RETRY_BOX_Y + RETRY_CMD1_Y
    @retry_yes_sprite.z = 510

    @retry_no_sprite = Sprite.new
    @retry_no_sprite.bitmap = Bitmap.new(RETRY_BOX_WIDTH, 32)
    @retry_no_sprite.x = RETRY_BOX_X
    @retry_no_sprite.y = RETRY_BOX_Y + RETRY_CMD2_Y
    @retry_no_sprite.z = 510
  end

  def draw_retry_box
    bmp = @retry_box.bitmap
    bmp.clear
    bmp.fill_rect(0, 0, RETRY_BOX_WIDTH, RETRY_BOX_HEIGHT, Color.new(0, 0, 0, 180))
    bmp.fill_rect(0, 0, RETRY_BOX_WIDTH, 2, Color.new(120, 180, 255))
    bmp.fill_rect(0, RETRY_BOX_HEIGHT - 2, RETRY_BOX_WIDTH, 2, Color.new(120, 180, 255))
    bmp.fill_rect(0, 0, 2, RETRY_BOX_HEIGHT, Color.new(120, 180, 255))
    bmp.fill_rect(RETRY_BOX_WIDTH - 2, 0, 2, RETRY_BOX_HEIGHT, Color.new(120, 180, 255))
  end

  def refresh_retry_texts(visible = true)
    [@retry_title_sprite, @retry_yes_sprite, @retry_no_sprite].each do |s|
      s.visible = visible
      s.bitmap.clear
    end

    @retry_title_sprite.bitmap.font.size = RETRY_TEXT_SIZE
    draw_text_shadow(@retry_title_sprite.bitmap, 0, 0, RETRY_BOX_WIDTH, 32, RETRY_TEXT, 1)

    @retry_yes_sprite.bitmap.font.size = RETRY_CMD_SIZE
    @retry_no_sprite.bitmap.font.size  = RETRY_CMD_SIZE

    yes_color = (@retry_index == 0 ? Color.new(255,255,255) : Color.new(180,180,180))
    no_color  = (@retry_index == 1 ? Color.new(255,255,255) : Color.new(180,180,180))

    draw_text_shadow_colored(@retry_yes_sprite.bitmap, 0, 0, RETRY_BOX_WIDTH, 32, RETRY_YES_TEXT, 1, yes_color)
    draw_text_shadow_colored(@retry_no_sprite.bitmap, 0, 0, RETRY_BOX_WIDTH, 32, RETRY_NO_TEXT, 1, no_color)

    @retry_cursor.visible = visible
    @retry_cursor.x = RETRY_BOX_X + 18
    @retry_cursor.y = RETRY_BOX_Y + (@retry_index == 0 ? RETRY_CMD1_Y + 4 : RETRY_CMD2_Y + 4)
  end

  def update
    super
    update_pet_se_timer

    case @phase
    when :safe
      update_safe_phase
    when :warning
      update_warning_phase
    when :bite
      update_bite_phase
    when :retry
      update_retry_phase
    end

    update_hand_motion
    update_flash
  end

  def update_safe_phase
    moved, on_body = update_hand_input
    gained = update_score_gain(moved, on_body)

    @earned_any_score = true if gained
    return unless @earned_any_score

    @phase_count -= 1
    enter_warning_phase if @phase_count <= 0
  end

  def update_warning_phase
    moved, on_body = update_hand_input

    if @reaction_count > 0
      @reaction_count -= 1
    elsif moved && on_body
      trigger_bite_game_over
      return
    end

    @phase_count -= 1
    return_to_safe_phase if @phase_count <= 0
  end

  def update_bite_phase
    stop_pet_se

    @zoom_frame += 1

    if @zoom_frame == 1
      @body_sprite.visible = false
      @head_sprite.visible = false
      @hand_sprite.visible = false
      @bite_sprite.visible = true
      @flash_sprite.opacity = 200
    end

    t = [@zoom_frame.to_f / BITE_ZOOM_FRAMES, 1.0].min
    zoom = BITE_ZOOM_START + (BITE_ZOOM_END - BITE_ZOOM_START) * ease_out_cubic(t)
    @bite_sprite.zoom_x = zoom
    @bite_sprite.zoom_y = zoom

    open_retry_menu if @zoom_frame >= BITE_ZOOM_FRAMES + 12
  end

  def update_retry_phase
    stop_pet_se

    if Input.trigger?(:UP) || Input.trigger?(:DOWN)
      @retry_index = 1 - @retry_index
      RPG::SE.new(SE_CURSOR, 80, 100).play
      refresh_retry_texts(true)
    elsif Input.trigger?(:C)
      @retry_index == 0 ? command_retry_yes : command_retry_no
    end
  end

  def update_hand_input
    dx = 0
    dy = 0
    dx -= MOVE_SPEED if Input.press?(:LEFT)
    dx += MOVE_SPEED if Input.press?(:RIGHT)
    dy -= MOVE_SPEED if Input.press?(:UP)
    dy += MOVE_SPEED if Input.press?(:DOWN)

    moved = (dx != 0 || dy != 0)

    unless moved
      @hand_swiping = false
      stop_pet_se
      return [false, on_body_area?(@hand_x, @hand_y)]
    end

    @hand_x += dx
    @hand_y += dy
    clamp_hand_to_screen
    update_hand_position

    on_body = on_body_area?(@hand_x, @hand_y)

    if on_body
      @hand_swiping = true
      play_pet_se_once
    else
      @hand_swiping = false
      stop_pet_se
    end

    [true, on_body]
  end

  def clamp_hand_to_screen
    @hand_x = [[@hand_x, SCREEN_MIN_X].max, SCREEN_MAX_X].min
    @hand_y = [[@hand_y, SCREEN_MIN_Y].max, SCREEN_MAX_Y].min
  end

  def update_hand_position
    @hand_sprite.x = @hand_x
    @hand_sprite.y = @hand_y
  end

  def update_hand_motion
    return unless @phase == :safe || @phase == :warning

    if @hand_swiping && on_body_area?(@hand_x, @hand_y)
      @hand_swipe_phase += HAND_SWIPE_SPEED
      mid = (HAND_SWIPE_ANGLE_LEFT + HAND_SWIPE_ANGLE_RIGHT) / 2.0
      amp = (HAND_SWIPE_ANGLE_RIGHT - HAND_SWIPE_ANGLE_LEFT) / 2.0
      @hand_sprite.angle = mid + Math.sin(@hand_swipe_phase) * amp
    else
      @hand_swipe_phase = 0.0
      @hand_sprite.angle *= HAND_STOP_DECAY
      @hand_sprite.angle = 0 if @hand_sprite.angle.abs < 0.5
    end
  end

  def update_score_gain(moved, on_body)
    return false unless moved
    return false unless on_body

    @score += SCORE_PER_MOVE
    refresh_score
    true
  end

  def on_body_area?(x, y)
    r = BODY_CHECK_RADIUS
    return true if body_pixel?(x, y)
    return true if body_pixel?(x - r, y)
    return true if body_pixel?(x + r, y)
    return true if body_pixel?(x, y - r)
    return true if body_pixel?(x, y + r)
    return true if body_pixel?(x - r, y - r)
    return true if body_pixel?(x + r, y - r)
    return true if body_pixel?(x - r, y + r)
    return true if body_pixel?(x + r, y + r)
    false
  end

  def body_pixel?(x, y)
    bmp = @body_sprite.bitmap
    return false unless bmp
    return false if x < 0 || y < 0 || x >= bmp.width || y >= bmp.height

    c = bmp.get_pixel(x, y)
    return false if c.alpha <= 20

    if c.red >= BODY_WHITE_THRESHOLD &&
       c.green >= BODY_WHITE_THRESHOLD &&
       c.blue >= BODY_WHITE_THRESHOLD
      return false
    end

    true
  end

  def difficulty_level
    @score / DIFF_STEP_SCORE
  end

  def current_safe_min
    [SAFE_MIN_FRAMES - difficulty_level * 6, SAFE_MIN_LIMIT].max
  end

  def current_safe_max
    [SAFE_MAX_FRAMES - difficulty_level * 8, SAFE_MAX_LIMIT].max
  end

  def current_head_min
    [HEAD_MIN_FRAMES - difficulty_level * 2, HEAD_MIN_LIMIT].max
  end

  def current_head_max
    [HEAD_MAX_FRAMES - difficulty_level * 3, HEAD_MAX_LIMIT].max
  end

  def current_react_min
    [REACT_MIN_FRAMES - difficulty_level * 2, REACT_MIN_LIMIT].max
  end

  def current_react_max
    [REACT_MAX_FRAMES - difficulty_level * 2, REACT_MAX_LIMIT].max
  end

  def random_safe_duration
    min = current_safe_min
    max = current_safe_max
    min + rand(max - min + 1)
  end

  def random_head_duration
    min = current_head_min
    max = current_head_max
    min + rand(max - min + 1)
  end

  def random_reaction_duration
    min = current_react_min
    max = current_react_max
    min + rand(max - min + 1)
  end

  def enter_warning_phase
    stop_pet_se

    @phase = :warning
    @phase_count = random_head_duration
    @reaction_count = random_reaction_duration

    @body_sprite.visible = false
    @head_sprite.visible = true

    @hand_swiping = false
    @hand_sprite.angle = 0
    @flash_sprite.opacity = 70

    RPG::SE.new(SE_WARNING, 90, 100).play
  end

  def return_to_safe_phase
    stop_pet_se

    @phase = :safe
    @phase_count = random_safe_duration
    @reaction_count = 0

    @head_sprite.visible = false
    @body_sprite.visible = true
  end

  def trigger_bite_game_over
    stop_all_se
    @phase = :bite
    @zoom_frame = 0
    setup_bite_sprite_focus
    save_result_variable
    RPG::SE.new(SE_BITE, 100, 100).play
  end

  def open_retry_menu
    return unless @phase == :bite
    @phase = :retry
    @retry_index = 0
    @retry_box.visible = true
    refresh_retry_texts(true)
  end

  def command_retry_yes
    stop_all_se
    RPG::SE.new(SE_CONFIRM, 80, 100).play
    init_game
  end

  def command_retry_no
    stop_all_se
    RPG::SE.new(SE_CANCEL, 80, 100).play
    return_scene
  end

  def setup_bite_sprite_default
    @bite_sprite.visible = false
    @bite_sprite.opacity = 255
    @bite_sprite.zoom_x = 1.0
    @bite_sprite.zoom_y = 1.0
    @bite_sprite.ox = 0
    @bite_sprite.oy = 0
    @bite_sprite.x = 0
    @bite_sprite.y = 0
  end

  def setup_bite_sprite_focus
    @bite_sprite.visible = true
    @bite_sprite.opacity = 255
    @bite_sprite.ox = BITE_FOCUS_X
    @bite_sprite.oy = BITE_FOCUS_Y
    @bite_sprite.x = BITE_FOCUS_X
    @bite_sprite.y = BITE_FOCUS_Y
    @bite_sprite.zoom_x = BITE_ZOOM_START
    @bite_sprite.zoom_y = BITE_ZOOM_START
  end

  def refresh_score
    bmp = @score_sprite.bitmap
    bmp.clear
    bmp.font.size = SCORE_TEXT_SIZE
    draw_text_shadow(bmp, 16, 0, 320, 36, "#{SCORE_TEXT}: #{@score}", 0)
  end

  def draw_text_shadow(bitmap, x, y, w, h, text, align = 0)
    bitmap.font.color = Color.new(0, 0, 0)
    bitmap.draw_text(x + 2, y + 2, w, h, text, align)
    bitmap.font.color = Color.new(255, 255, 255)
    bitmap.draw_text(x, y, w, h, text, align)
  end

  def draw_text_shadow_colored(bitmap, x, y, w, h, text, align, main_color)
    bitmap.font.color = Color.new(0, 0, 0)
    bitmap.draw_text(x + 2, y + 2, w, h, text, align)
    bitmap.font.color = main_color
    bitmap.draw_text(x, y, w, h, text, align)
  end

  #--------------------------------------------------------------------------
  # Pet SE Control
  #--------------------------------------------------------------------------
  def play_pet_se_once
    return if @pet_se_active
    return if @pet_se_timer > 0

    RPG::SE.new(SE_PET, PET_SE_VOLUME, PET_SE_PITCH).play
    @pet_se_active = true
    @pet_se_timer = PET_SE_DURATION_FRAMES
  end

  def update_pet_se_timer
    return unless @pet_se_timer && @pet_se_timer > 0

    @pet_se_timer -= 1
    if @pet_se_timer <= 0
      @pet_se_timer = 0
      @pet_se_active = false
    end
  end

  def stop_pet_se
    return unless @pet_se_active || (@pet_se_timer && @pet_se_timer > 0)

    Audio.se_stop
    @pet_se_active = false
    @pet_se_timer = 0
  end

  def stop_all_se
    Audio.se_stop
    @pet_se_active = false
    @pet_se_timer = 0
  end

  def update_flash
    @flash_sprite.opacity = [@flash_sprite.opacity - 10, 0].max if @phase != :bite
  end

  def ease_out_cubic(t)
    1 - (1 - t) ** 3
  end

  def save_result_variable
    $game_variables[RESULT_VARIABLE_ID] = @score if RESULT_VARIABLE_ID > 0
  end

  def dispose_catto_all
    stop_all_se

    [
      @body_sprite, @head_sprite, @bite_sprite, @hand_sprite,
      @flash_sprite, @score_sprite, @retry_box, @retry_cursor,
      @retry_title_sprite, @retry_yes_sprite, @retry_no_sprite
    ].each do |sprite|
      next unless sprite
      sprite.bitmap.dispose if sprite.bitmap && !sprite.bitmap.disposed?
      sprite.dispose unless sprite.disposed?
    end
  end
end
