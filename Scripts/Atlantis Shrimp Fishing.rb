#==============================================================================
# ** Atlantis Shrimp Fishing
#------------------------------------------------------------------------------
#  Minigame cau tom ca phe Atlantis, rut gon tu y tuong Galv Fishing.
#
#  Script calls:
#    atlantis_shrimp_fishing
#    atlantis_shrimp_result   # 10 = thanh cong, -1 = thoat
#==============================================================================

module AtlantisShrimpFishing
  TARGET = 10

  SHRIMP_GRAPHIC = "shrimp"
  FISH_GRAPHICS = ["fish1", "fish2"]
  NORMAL_ROD_GRAPHIC = "rod"
  MAGIC_ROD_GRAPHIC = "rod_gold" # Placeholder cho truong phep Hai Quy

  BGM = "Town1"
  CAST_SE = ["Wind4", 80, 100]
  SPLASH_SE = ["Dive", 80, 120]
  BITE_SE = ["Blow5", 75, 145]
  CATCH_SE = ["Up4", 90, 110]
  THROW_SE = ["Miss", 75, 110]
  LINE_BREAK_SE = ["Break", 80, 105]
  WARNING_SE = ["Decision2", 70, 125]
  EXPLODE_SE = ["Blow6", 80, 110]
  BEAM_SE = ["se_player_beam", 85, 100]
  CHANGE_ROD_SE = ["Equip1", 75, 110]
  COMPLETE_SE = ["Item3", 90, 110]

  SURFACE_Y = 176
  FLOOR_MARGIN = 30
  FISHER_X_MARGIN = 42
  FISHER_Y = 164
  POND_LEFT = 20
  POND_RIGHT_MARGIN = 80

  SHRIMP_COUNT = 4
  FISH_COUNT = 7
  RESPAWN_DELAY = 75

  # Moi con tom co moc chin vang ngau nhien.
  BLACK_MIN = 80
  BLACK_MAX = 175
  YELLOW_MIN = 55
  YELLOW_MAX = 105

  # Khi tom da chuyen do, hai moc nay luon co dinh.
  RED_WARNING_FRAMES = 72
  RED_FLASH_START = 24

  CAST_FRAMES = 24
  REEL_SPEED = 3.1
  SINK_SPEED = 0.75
  BAIT_DETECT = 74
  BAIT_TAKE = 9
  BEAM_WARNING = 24
  BEAM_ACTIVE = 18
  BEAM_COOLDOWN = 65
  BEAM_WIDTH = 156
  BEAM_TARGET_X_RATIO = 0.30
  BEAM_TARGET_Y_RATIO = 0.74

  TEXT_COLOR = Color.new(255, 255, 255)
  GOLD_COLOR = Color.new(255, 220, 60)
  RED_COLOR = Color.new(255, 70, 55)

  module_function

  def play_se(data)
    RPG::SE.new(data[0], data[1], data[2]).play
  end
end

module Cache
  def self.gfish(filename)
    load_bitmap("Graphics/GFish/", filename)
  end
end

class Game_Temp
  attr_accessor :atlantis_shrimp_result
end

class Game_Interpreter
  def atlantis_shrimp_fishing
    $game_temp.atlantis_shrimp_result = 0
    SceneManager.call(Scene_AtlantisShrimpFishing)
    Fiber.yield
  end

  def atlantis_shrimp_result
    $game_temp.atlantis_shrimp_result || 0
  end
end

class AtlantisFishingCreature
  include AtlantisShrimpFishing

  attr_accessor :x, :y, :vx, :vy, :state, :sprite
  attr_reader :kind, :graphic, :ripe_state, :struggle_direction

  def initialize(kind)
    @kind = kind
    @graphic = kind == :shrimp ? SHRIMP_GRAPHIC : FISH_GRAPHICS[rand(FISH_GRAPHICS.size)]
    reset_position
    @state = :swim
    @sprite = nil
    @anim_timer = rand(32)
    @anim_index = rand(4)
    @state_timer = 0
    @ripe_timer = 0
    @struggle_direction = :away
    @struggle_timer = 0
    randomize_ripening
  end

  def reset_position
    left = POND_LEFT + 20
    right = Graphics.width - POND_RIGHT_MARGIN
    @x = left + rand([right - left, 1].max)
    @y = SURFACE_Y + 35 + rand([Graphics.height - FLOOR_MARGIN - SURFACE_Y - 35, 1].max)
    @vx = (0.45 + rand * 0.75) * (rand(2) == 0 ? -1 : 1)
    @vy = (rand - 0.5) * 0.35
  end

  def randomize_ripening
    @yellow_start = BLACK_MIN + rand(BLACK_MAX - BLACK_MIN + 1)
    @red_start = @yellow_start + YELLOW_MIN + rand(YELLOW_MAX - YELLOW_MIN + 1)
  end

  def alive?
    @state != :dead
  end

  def targetable?
    @state == :swim || @state == :chase
  end

  def hooked?
    @state == :hooked
  end

  def update(scene)
    case @state
    when :swim
      update_swim
      look_for_bait(scene)
    when :chase
      update_chase(scene)
    when :hooked
      update_hooked(scene)
    when :throw_back
      update_throw_back
    when :explode
      update_explode(scene)
    end
    update_sprite
  end

  def update_swim
    @x += @vx
    @y += @vy
    left = POND_LEFT
    right = Graphics.width - POND_RIGHT_MARGIN
    if @x < left
      @x = left
      @vx = @vx.abs
    elsif @x > right
      @x = right
      @vx = -@vx.abs
    end
    top = SURFACE_Y + 18
    bottom = Graphics.height - FLOOR_MARGIN
    if @y < top
      @y = top
      @vy = @vy.abs
    elsif @y > bottom
      @y = bottom
      @vy = -@vy.abs
    end
    if rand(120) == 0
      @vx = (0.4 + rand * 0.9) * (rand(2) == 0 ? -1 : 1)
      @vy = (rand - 0.5) * 0.55
    end
  end

  def look_for_bait(scene)
    return unless scene.bait_active?
    return if scene.hooked_creature
    dx = scene.bait_x - @x
    dy = scene.bait_y - @y
    @state = :chase if dx * dx + dy * dy <= BAIT_DETECT * BAIT_DETECT
  end

  def update_chase(scene)
    unless scene.bait_active? && !scene.hooked_creature
      @state = :swim
      return
    end
    dx = scene.bait_x - @x
    dy = scene.bait_y - @y
    dist = Math.sqrt(dx * dx + dy * dy)
    if dist <= BAIT_TAKE
      consume_bait(scene)
      return
    end
    speed = @kind == :shrimp ? 1.3 : 1.7
    @vx = dx / [dist, 0.01].max * speed
    @vy = dy / [dist, 0.01].max * speed
    @x += @vx
    @y += @vy
  end

  def consume_bait(scene)
    if @kind == :shrimp
      @state = :hooked
      @ripe_timer = 0
      randomize_ripening
      randomize_struggle(true)
      scene.hook_creature(self)
      AtlantisShrimpFishing.play_se(BITE_SE)
    else
      scene.consume_bait
      scene.on_fish_ate_coffee
      start_explosion(scene)
    end
  end

  def update_hooked(scene)
    @x = scene.bait_x
    @y = scene.bait_y
    @ripe_timer += 1
    update_struggle
    scene.on_shrimp_color(:yellow) if @ripe_timer == @yellow_start
    if @ripe_timer == @red_start
      AtlantisShrimpFishing.play_se(WARNING_SE)
      scene.on_shrimp_color(:red)
    end
    if @ripe_timer >= @red_start + RED_WARNING_FRAMES
      scene.consume_bait
      scene.clear_hook(self)
      start_explosion(scene)
    end
  end

  def randomize_struggle(first = false)
    if first
      @struggle_direction = rand(2) == 0 ? :away : :toward
    else
      @struggle_direction = @struggle_direction == :away ? :toward : :away
    end
    @struggle_timer = 34 + rand(58)
  end

  def update_struggle
    @struggle_timer -= 1
    randomize_struggle if @struggle_timer <= 0
  end

  def struggle_force
    [0.75 + @ripe_timer * 0.014, 4.2].min
  end

  def ripe_state
    return :black if @ripe_timer < @yellow_start
    return :yellow if @ripe_timer < @red_start
    :red
  end

  def throw_back
    @state = :throw_back
    @state_timer = 34
    @vx = -2.2 - rand * 1.2
    @vy = -3.5
  end

  def update_throw_back
    @x += @vx
    @y += @vy
    @vy += 0.28
    @state_timer -= 1
    if @state_timer <= 0 || @y > Graphics.height + 20
      reset_position
      @state = :swim
      @ripe_timer = 0
    end
  end

  def start_explosion(scene)
    return if @state == :explode || @state == :dead
    @state = :explode
    @state_timer = 28
    scene.flash_creature(self)
    AtlantisShrimpFishing.play_se(EXPLODE_SE)
  end

  def update_explode(scene)
    @state_timer -= 1
    if @state_timer == 17
      scene.spawn_explosion(@x, @y, @graphic)
      @sprite.visible = false if @sprite
    elsif @state_timer <= 0
      @state = :dead
    end
  end

  def update_sprite
    return unless @sprite
    @anim_timer += 1
    if @anim_timer >= 8
      @anim_timer = 0
      @anim_index = (@anim_index + 1) % 4
    end
    cw = @sprite.bitmap.width / 4
    @sprite.src_rect.set(@anim_index * cw, 0, cw, @sprite.bitmap.height)
    @sprite.x = @x
    @sprite.y = @y
    @sprite.mirror = @vx > 0

    case @state
    when :hooked
      case ripe_state
      when :black
        @sprite.color.set(0, 0, 0, 155)
      when :yellow
        pulse = 115 + (Graphics.frame_count % 24 - 12).abs * 5
        @sprite.color.set(255, 215, 35, [pulse, 190].min)
      when :red
        pulse = (Graphics.frame_count / 4) % 2 == 0 ? 210 : 90
        @sprite.color.set(255, 35, 25, pulse)
      end
    when :explode
      pulse = (Graphics.frame_count / 2) % 2 == 0 ? 230 : 30
      @sprite.color.set(255, 30, 20, pulse)
      zoom = 1.0 + (28 - @state_timer) * 0.018
      @sprite.zoom_x = zoom
      @sprite.zoom_y = zoom
      @sprite.x = @x + rand(5) - 2
      @sprite.y = @y + rand(5) - 2
    else
      @sprite.color.set(0, 0, 0, 0)
      @sprite.zoom_x = 1.0
      @sprite.zoom_y = 1.0
    end
  end
end

class AtlantisFishingParticle < Sprite
  def initialize(viewport, x, y, color)
    super(viewport)
    self.bitmap = Bitmap.new(4 + rand(5), 3 + rand(5))
    self.bitmap.fill_rect(self.bitmap.rect, color)
    self.x = x
    self.y = y
    self.ox = bitmap.width / 2
    self.oy = bitmap.height / 2
    self.z = 80
    @vx = rand * 5.0 - 2.5
    @vy = rand * 4.0 - 3.5
    @life = 30 + rand(20)
  end

  def update
    super
    self.x += @vx
    self.y += @vy
    @vy += 0.14
    self.angle += @vx * 5
    @life -= 1
    self.opacity = [@life * 7, 255].min
  end

  def dead?
    @life <= 0
  end

  def dispose
    bitmap.dispose if bitmap && !bitmap.disposed?
    super
  end
end

class Scene_AtlantisShrimpFishing < Scene_Base
  include AtlantisShrimpFishing

  attr_reader :bait_x, :bait_y, :hooked_creature

  def start
    super
    @old_bgm = RPG::BGM.last
    create_viewports
    create_backgrounds
    create_fisher
    create_rod
    create_bait
    create_beam
    create_struggle_indicator
    create_emotion_bubble
    create_ui
    @creatures = []
    @particles = []
    @caught = 0
    @rod_mode = :normal
    @phase = :idle
    @power = 0.0
    @power_dir = 1.0
    @respawn_timer = 0
    @message = "Kéo lên 10 tôm vào thời điểm chúng chuyển màu vàng."
    @message_timer = 180
    @beam_timer = 0
    @beam_cooldown = 0
    @finished = false
    spawn_pond
    RPG::BGM.new(BGM, 75, 100).play unless BGM.empty?
    refresh_ui
  end

  def terminate
    super
    RPG::BGM.stop
    @old_bgm.replay if @old_bgm
    dispose_all
  end

  def update
    super
    update_input
    update_power
    update_fishing
    update_creatures
    update_particles
    update_beam
    update_respawn
    update_message
    update_struggle_indicator
    update_emotion_bubble
    update_rod_sprite
    update_bait_sprite
  end

  def create_viewports
    @viewport_bg = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport_bg.z = 0
    @viewport_main = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport_main.z = 20
    @viewport_ui = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport_ui.z = 100
  end

  def create_backgrounds
    @under = Sprite.new(@viewport_bg)
    @under.bitmap = Cache.gfish("under0")
    @under.x = Graphics.width - @under.bitmap.width + 65
    @under.y = Graphics.height - @under.bitmap.height
    @flow = Sprite.new(@viewport_bg)
    @flow.bitmap = Cache.gfish("flow0")
    @flow.opacity = 105
    @over = Sprite.new(@viewport_main)
    @over.bitmap = Cache.gfish("over0")
    @over.x = Graphics.width - @over.bitmap.width
    @over.y = 0
    @over.z = 60
  end

  def create_fisher
    @fisher = Sprite.new(@viewport_main)
    @fisher.bitmap = Cache.character($game_player.character_name)
    name = $game_player.character_name
    sign = name[/^[\!\$]./]
    @fisher_cw = sign && sign.include?("$") ? @fisher.bitmap.width / 3 : @fisher.bitmap.width / 12
    @fisher_ch = sign && sign.include?("$") ? @fisher.bitmap.height / 4 : @fisher.bitmap.height / 8
    index = $game_player.character_index
    sx = (index % 4 * 3 + 1) * @fisher_cw
    sy = (index / 4 * 4 + 1) * @fisher_ch
    @fisher.src_rect.set(sx, sy, @fisher_cw, @fisher_ch)
    @fisher.ox = @fisher_cw / 2
    @fisher.oy = @fisher_ch
    @fisher.x = Graphics.width - FISHER_X_MARGIN
    @fisher.y = FISHER_Y
    @fisher.z = 70
  end

  def create_rod
    @rod = Sprite.new(@viewport_main)
    @rod_name = nil
    @rod_pattern = 0
    @rod_anim = 0
    setup_rod_bitmap
  end

  def setup_rod_bitmap
    name = @rod_mode == :magic ? MAGIC_ROD_GRAPHIC : NORMAL_ROD_GRAPHIC
    return if @rod_name == name
    @rod.bitmap = Cache.gfish(name)
    @rod_name = name
    @rod_cw = @rod.bitmap.width / 4
    @rod_ch = @rod.bitmap.height / 4
    @rod.ox = @rod_cw / 2
    @rod.oy = @rod_ch
    @rod.x = Graphics.width - 48
    @rod.y = FISHER_Y + 35
    @rod.z = 69
  end

  def create_bait
    @bait = Sprite.new(@viewport_main)
    @bait.bitmap = Cache.gfish("bait_yellow")
    @bait_cw = @bait.bitmap.width / 4
    @bait_ch = @bait.bitmap.height
    @bait.ox = @bait_cw / 2
    @bait.oy = @bait_ch / 2
    @bait.visible = false
    @bait.z = 55
  end

  def create_beam
    @beam = Sprite.new(@viewport_main)
    source_x = Graphics.width - 72
    source_y = FISHER_Y - 14
    target_x = (Graphics.width * BEAM_TARGET_X_RATIO).to_i
    target_y = (Graphics.height * BEAM_TARGET_Y_RATIO).to_i
    dx = target_x - source_x
    dy = target_y - source_y
    @beam_length = Math.sqrt(dx * dx + dy * dy).to_i
    # RGSS rotates Sprite clockwise with an inverted screen Y axis.
    @beam_angle = -Math.atan2(dy, dx) * 180.0 / Math::PI
    @beam.bitmap = Bitmap.new(@beam_length, BEAM_WIDTH)
    @beam.ox = 0
    @beam.oy = BEAM_WIDTH / 2
    @beam.x = source_x
    @beam.y = source_y
    @beam.angle = @beam_angle
    @beam.z = 75
    @beam.visible = false
  end

  def create_struggle_indicator
    @struggle_indicator = Sprite.new(@viewport_main)
    @struggle_indicator.bitmap = Bitmap.new(132, 30)
    @struggle_indicator.ox = 66
    @struggle_indicator.oy = 30
    @struggle_indicator.z = 90
    @struggle_indicator.visible = false
    @last_struggle_direction = nil
  end

  def create_emotion_bubble
    @emotion = Sprite.new(@viewport_ui)
    @emotion.bitmap = Cache.system("Balloon2")
    @emotion.ox = 16
    @emotion.oy = 32
    @emotion.x = Graphics.width - FISHER_X_MARGIN
    @emotion.y = FISHER_Y - @fisher_ch - 5
    @emotion.z = 140
    @emotion.visible = false
    @emotion_timer = 0
    @emotion_row = 0
  end

  def create_ui
    @ui = Sprite.new(@viewport_ui)
    @ui.bitmap = Bitmap.new(Graphics.width, 86)
    @ui.y = 0
    @message_sprite = Sprite.new(@viewport_ui)
    @message_sprite.bitmap = Bitmap.new(Graphics.width, 48)
    @message_sprite.y = Graphics.height - 50
    @message_sprite.z = 120
  end

  def refresh_ui
    b = @ui.bitmap
    b.clear
    b.fill_rect(0, 0, Graphics.width, 82, Color.new(0, 20, 35, 175))
    b.font.name = Font.default_name
    b.font.size = 24
    b.font.bold = true
    b.font.color = GOLD_COLOR
    b.draw_text(18, 5, 310, 32, "Cà phê Atlantis: #{@caught}/#{TARGET}")
    b.font.size = 18
    b.font.bold = false
    b.font.color = TEXT_COLOR
    rod_text = @rod_mode == :normal ? "Cần câu tôm" : "Găng tay của Hải Quỳ"
    b.draw_text(Graphics.width - 330, 8, 315, 24, "Z: Thả mồi / Kéo về / Bắn beam", 2)
    if @phase == :idle && @rod_mode == :normal
      width = 180
      x = Graphics.width - 205
      y = 62
      b.fill_rect(x, y, width, 8, Color.new(30, 45, 55, 220))
      b.fill_rect(x, y, (width * @power).to_i, 8, GOLD_COLOR)
    end
  end

  def show_message(text, frames)
    @message = text
    @message_timer = frames
    refresh_message
  end

  def refresh_message
    b = @message_sprite.bitmap
    b.clear
    return if @message_timer <= 0 || @message.to_s.empty?
    b.fill_rect(40, 4, Graphics.width - 80, 38, Color.new(0, 0, 0, 185))
    b.font.size = 20
    b.font.color = TEXT_COLOR
    b.draw_text(52, 7, Graphics.width - 104, 30, @message, 1)
  end

  def update_input
    if @finished
      return_scene if Input.trigger?(:C) || Input.trigger?(:B)
      return
    end
    if Input.trigger?(:B)
      $game_temp.atlantis_shrimp_result = -1
      return_scene
      return
    end
    if Input.trigger?(:A) && @phase == :idle && @beam_cooldown <= 0
      @rod_mode = @rod_mode == :normal ? :magic : :normal
      setup_rod_bitmap
      AtlantisShrimpFishing.play_se(CHANGE_ROD_SE)
      show_message(@rod_mode == :normal ? "Đã đổi sang cần câu." : "Găng tay: bắn beam dọn biển sạch sẽ.", 90)
      refresh_ui
    end
    return unless Input.trigger?(:C)
    if @rod_mode == :magic
      fire_beam if @phase == :idle && @beam_cooldown <= 0
    elsif @phase == :idle
      cast_bait
    end
  end

  def update_power
    return unless @phase == :idle && @rod_mode == :normal
    @power += @power_dir * 0.018
    if @power >= 1.0
      @power = 1.0
      @power_dir = -1.0
    elsif @power <= 0.12
      @power = 0.12
      @power_dir = 1.0
    end
    refresh_ui if Graphics.frame_count % 2 == 0
  end

  def cast_bait
    @phase = :casting
    @cast_timer = CAST_FRAMES
    @bait_start_x = Graphics.width - 70
    @bait_start_y = SURFACE_Y - 30
    distance = 120 + @power * (Graphics.width - 245)
    @bait_target_x = [[Graphics.width - 70 - distance, POND_LEFT + 10].max, Graphics.width - 100].min
    @bait_target_y = SURFACE_Y
    @bait_x = @bait_start_x
    @bait_y = @bait_start_y
    @bait.visible = true
    AtlantisShrimpFishing.play_se(CAST_SE)
  end

  def update_fishing
    case @phase
    when :casting
      @cast_timer -= 1
      t = 1.0 - @cast_timer.to_f / CAST_FRAMES
      @bait_x = @bait_start_x + (@bait_target_x - @bait_start_x) * t
      @bait_y = @bait_start_y + (@bait_target_y - @bait_start_y) * t - Math.sin(t * Math::PI) * 70
      if @cast_timer <= 0
        @phase = :fishing
        @bait_x = @bait_target_x
        @bait_y = SURFACE_Y
        AtlantisShrimpFishing.play_se(SPLASH_SE)
      end
    when :fishing
      if @hooked_creature
        update_hooked_reel(Input.press?(:C))
      elsif Input.press?(:C)
        reel_bait
      else
        @bait_y = [@bait_y + SINK_SPEED, Graphics.height - FLOOR_MARGIN].min
      end
    end
  end

  def reel_bait
    target_x = Graphics.width - 68
    dx = target_x - @bait_x
    dy = SURFACE_Y - @bait_y
    dist = Math.sqrt(dx * dx + dy * dy)
    if dist <= REEL_SPEED + 1
      @bait_x = target_x
      @bait_y = SURFACE_Y
      resolve_reel
    else
      @bait_x += dx / dist * REEL_SPEED
      @bait_y += dy / dist * REEL_SPEED
    end
  end

  def update_hooked_reel(pulling)
    target_x = Graphics.width - 68
    target_y = SURFACE_Y
    dx = target_x - @bait_x
    dy = target_y - @bait_y
    dist = Math.sqrt(dx * dx + dy * dy)
    if dist <= 0.01
      resolve_reel
      return
    end
    ux = dx / dist
    uy = dy / dist
    force = @hooked_creature.struggle_force
    motion = pulling ? REEL_SPEED : 0.0
    if @hooked_creature.struggle_direction == :away
      motion -= force * (pulling ? 1.0 : 1.85)
    else
      # Ke ca khong bam, tom van lao ve Hai Quy. Bam keo se cong don toc do
      # va rat de keo len khi tom con den.
      motion += force * (pulling ? 1.15 : 0.72)
    end
    @bait_x += ux * motion
    @bait_y += uy * motion
    @bait_y += SINK_SPEED * 0.35 unless pulling
    @bait_x = [[@bait_x, POND_LEFT].max, Graphics.width - 68].min
    @bait_y = [[@bait_y, SURFACE_Y].max, Graphics.height - FLOOR_MARGIN].min

    new_dx = target_x - @bait_x
    new_dy = target_y - @bait_y
    resolve_reel if Math.sqrt(new_dx * new_dx + new_dy * new_dy) <= REEL_SPEED + 1

    if @hooked_creature && @hooked_creature.struggle_direction == :away &&
       (@bait_x <= POND_LEFT + 1 || @bait_y >= Graphics.height - FLOOR_MARGIN - 1)
      escaped_shrimp
    end
  end

  def escaped_shrimp
    shrimp = @hooked_creature
    return unless shrimp
    show_message("Tôm giật đứt dây câu rồi chạy mất!", 100)
    show_emotion(3, 70)
    AtlantisShrimpFishing.play_se(LINE_BREAK_SE)
    shrimp.throw_back
    clear_hook(shrimp)
    consume_bait
  end

  def resolve_reel
    if @hooked_creature
      shrimp = @hooked_creature
      case shrimp.ripe_state
      when :black
        show_message("Hạt cà phê chưa chín. Hải Quỳ vứt tôm trở về biển!", 110)
        show_emotion(2, 75)
        AtlantisShrimpFishing.play_se(THROW_SE)
        shrimp.throw_back
      when :yellow
        @caught += 1
        show_message("Bắt được tôm vàng! Tôm nhả ra cà phê Atlantis #{@caught}/#{TARGET}.", 110)
        AtlantisShrimpFishing.play_se(CATCH_SE)
        show_emotion(5, 80)
        shrimp.state = :dead
        shrimp.sprite.visible = false if shrimp.sprite
        complete_game if @caught >= TARGET
      when :red
        show_message("Kéo lên muộn, tôm nổ banh xác.", 75)
        show_emotion(3, 75)
        shrimp.start_explosion(self)
      end
      clear_hook(shrimp)
    end
    consume_bait
    @phase = :idle unless @finished
    @respawn_timer = RESPAWN_DELAY
    refresh_ui
  end

  def bait_active?
    @phase == :fishing && @bait.visible
  end

  def hook_creature(creature)
    @hooked_creature = creature
    @last_struggle_direction = nil
    show_emotion(0, 60)
    @message_timer = 0
    refresh_message
  end

  def on_shrimp_color(color)
    case color
    when :yellow
      show_emotion(0, 50)
    when :red
      show_emotion(3, RED_WARNING_FRAMES)
    end
  end

  def on_fish_ate_coffee
    show_emotion(1, 65) unless @phase == :beam
  end

  def clear_hook(creature)
    @hooked_creature = nil if @hooked_creature == creature
  end

  def consume_bait
    @bait.visible = false
    @phase = :idle unless @finished
    @hooked_creature = nil
    @respawn_timer = RESPAWN_DELAY if @respawn_timer <= 0
  end

  def update_creatures
    @creatures.each { |creature| creature.update(self) }
  end

  def spawn_pond
    dispose_creatures
    @creatures = []
    SHRIMP_COUNT.times { add_creature(:shrimp) }
    FISH_COUNT.times { add_creature(:fish) }
  end

  def add_creature(kind)
    creature = AtlantisFishingCreature.new(kind)
    sprite = Sprite_Base.new(@viewport_main)
    sprite.bitmap = Cache.gfish(creature.graphic)
    sprite.ox = sprite.bitmap.width / 8
    sprite.oy = sprite.bitmap.height / 2
    sprite.z = 30
    creature.sprite = sprite
    @creatures << creature
  end

  def update_respawn
    @beam_cooldown -= 1 if @beam_cooldown > 0
    return if @finished
    living_shrimp = @creatures.count { |c| c.alive? && c.kind == :shrimp }
    living_fish = @creatures.count { |c| c.alive? && c.kind == :fish }
    @respawn_timer -= 1 if @respawn_timer > 0
    return unless @respawn_timer <= 0
    add_creature(:shrimp) while living_shrimp < SHRIMP_COUNT && (living_shrimp += 1)
    add_creature(:fish) while living_fish < FISH_COUNT && (living_fish += 1)
  end

  def flash_creature(creature)
    creature.sprite.flash(Color.new(255, 35, 25, 220), 28) if creature.sprite
  end

  def spawn_explosion(x, y, graphic)
    colors = graphic == SHRIMP_GRAPHIC ?
      [Color.new(235, 95, 70), Color.new(255, 210, 45), Color.new(90, 45, 35)] :
      [Color.new(245, 55, 45), Color.new(255, 145, 40), Color.new(75, 50, 65)]
    12.times { @particles << AtlantisFishingParticle.new(@viewport_main, x, y, colors[rand(colors.size)]) }
  end

  def update_particles
    @particles.each(&:update)
    dead = @particles.select(&:dead?)
    dead.each do |particle|
      particle.dispose
      @particles.delete(particle)
    end
  end

  def fire_beam
    @beam_timer = BEAM_WARNING + BEAM_ACTIVE
    @beam_cooldown = BEAM_COOLDOWN
    @beam.visible = true
    @phase = :beam
    show_emotion(1, BEAM_WARNING + BEAM_ACTIVE + 24)
    show_message("Găng tay của Hải Quỳ đang nạp năng lượng...", 70)
  end

  def update_beam
    return if @beam_timer <= 0
    @beam_timer -= 1
    b = @beam.bitmap
    b.clear
    if @beam_timer > BEAM_ACTIVE
      draw_beam_warning(b)
      @beam.opacity = 80 + (Graphics.frame_count % 12) * 12
    else
      if @beam_timer == BEAM_ACTIVE
        AtlantisShrimpFishing.play_se(BEAM_SE)
        @creatures.each do |creature|
          creature.start_explosion(self) if creature.alive?
        end
      end
      draw_beam_cone(b)
      @beam.opacity = 255
    end
    if @beam_timer <= 0
      @beam.visible = false
      @phase = :idle
      @respawn_timer = RESPAWN_DELAY
      show_message("Đám tôm cá cũ trong biển đã bị dọn sạch sẽ.", 100)
    end
  end

  def draw_beam_warning(bitmap)
    center = BEAM_WIDTH / 2
    @beam_length.times do |x|
      ratio = x.to_f / [@beam_length - 1, 1].max
      half = 3 + (BEAM_WIDTH * 0.46 * ratio).to_i
      bitmap.fill_rect(x, center - half, 1, 2, Color.new(255, 70, 60, 220))
      bitmap.fill_rect(x, center + half - 1, 1, 2, Color.new(255, 70, 60, 220))
    end
  end

  def draw_beam_cone(bitmap)
    center = BEAM_WIDTH / 2
    @beam_length.times do |x|
      ratio = x.to_f / [@beam_length - 1, 1].max
      outer = 5 + (BEAM_WIDTH * 0.47 * ratio).to_i
      middle = 3 + (outer * 0.72).to_i
      core = 2 + (outer * 0.34).to_i
      bitmap.fill_rect(x, center - outer, 1, outer * 2,
        Color.new(255, 205, 35, 65))
      bitmap.fill_rect(x, center - middle, 1, middle * 2,
        Color.new(255, 230, 75, 185))
      bitmap.fill_rect(x, center - core, 1, core * 2,
        Color.new(255, 255, 225, 255))
    end
  end

  def update_message
    return if @message_timer <= 0
    @message_timer -= 1
    refresh_message if @message_timer == 0
  end

  def update_struggle_indicator
    shrimp = @hooked_creature
    unless shrimp && shrimp.hooked?
      @struggle_indicator.visible = false
      @last_struggle_direction = nil
      return
    end
    direction = shrimp.struggle_direction
    if direction != @last_struggle_direction
      b = @struggle_indicator.bitmap
      b.clear
      b.fill_rect(0, 2, 132, 25, Color.new(0, 0, 0, 175))
      b.font.size = 18
      b.font.bold = true
      if direction == :away
        b.font.color = Color.new(255, 90, 70)
        b.draw_text(0, 2, 132, 24, "<<<", 1)
      else
        b.font.color = Color.new(90, 255, 150)
        b.draw_text(0, 2, 132, 24, ">>>", 1)
      end
      @last_struggle_direction = direction
    end
    @struggle_indicator.x = shrimp.x
    @struggle_indicator.y = shrimp.y - 15
    @struggle_indicator.visible = true
  end

  def show_emotion(row, frames = 60)
    @emotion_row = [[row, 0].max, 9].min
    @emotion_timer = frames
    @emotion.visible = true
    update_emotion_frame
  end

  def update_emotion_bubble
    return unless @emotion.visible
    @emotion_timer -= 1
    if @emotion_timer <= 0
      @emotion.visible = false
      return
    end
    update_emotion_frame
  end

  def update_emotion_frame
    frame = [(Graphics.frame_count / 6) % 8, 7].min
    @emotion.src_rect.set(frame * 32, @emotion_row * 32, 32, 32)
  end

  def update_rod_sprite
    @rod_anim += 1
    if @rod_anim >= 8
      @rod_anim = 0
      @rod_pattern = (@rod_pattern + 1) % 4
    end
    action = case @phase
             when :casting then 3
             when :fishing then Input.press?(:C) ? 1 : 2
             when :beam then 3
             else 0
             end
    @rod.src_rect.set(@rod_pattern * @rod_cw, action * @rod_ch, @rod_cw, @rod_ch)
  end

  def update_bait_sprite
    return unless @bait.visible
    frame = (Graphics.frame_count / 8) % 4
    @bait.src_rect.set(frame * @bait_cw, 0, @bait_cw, @bait_ch)
    @bait.x = @bait_x
    @bait.y = @bait_y
  end

  def complete_game
    @finished = true
    @phase = :complete
    $game_temp.atlantis_shrimp_result = @caught
    AtlantisShrimpFishing.play_se(COMPLETE_SE)
    show_message("Đã đủ cà phê, nhấn Z quay lại quán cà phê hoặc câu thêm nữa.", 999999)
  end

  def dispose_creatures
    return unless @creatures
    @creatures.each do |creature|
      sprite = creature.sprite
      sprite.dispose if sprite && !sprite.disposed?
    end
  end

  def dispose_all
    dispose_creatures
    @particles.each { |particle| particle.dispose unless particle.disposed? }
    [@under, @flow, @over, @fisher, @rod, @bait].each do |sprite|
      sprite.dispose if sprite && !sprite.disposed?
    end
    [@beam, @ui, @message_sprite, @struggle_indicator].each do |sprite|
      next unless sprite
      sprite.bitmap.dispose if sprite.bitmap && !sprite.bitmap.disposed?
      sprite.dispose unless sprite.disposed?
    end
    @emotion.dispose if @emotion && !@emotion.disposed?
    [@viewport_bg, @viewport_main, @viewport_ui].each do |viewport|
      viewport.dispose if viewport
    end
  end
end

#==============================================================================
# ** Shrimp-style map event burst
#------------------------------------------------------------------------------
#  Reuses the red flash + debris language of the fishing minigame on map events.
#  Script call: shrimp_style_event_explosion(EVENT_ID)
#==============================================================================

class ShrimpStyleMapParticle < Sprite
  def initialize(viewport, x, y, color, scale = 1.0)
    super(viewport)
    size = ((4 + rand(6)) * scale).to_i
    size = 3 if size < 3
    self.bitmap = Bitmap.new(size, size)
    self.bitmap.fill_rect(self.bitmap.rect, color)
    self.x = x
    self.y = y
    self.ox = size / 2
    self.oy = size / 2
    self.z = 250
    @vx = (rand * 6.4 - 3.2) * scale
    @vy = (rand * 5.0 - 4.3) * scale
    @gravity = 0.16 + rand * 0.08
    @life = 34 + rand(24)
  end

  def update
    super
    self.x += @vx
    self.y += @vy
    @vy += @gravity
    self.angle += @vx * 7
    @life -= 1
    self.opacity = [@life * 7, 255].min
  end

  def finished?
    @life <= 0
  end

  def dispose
    bitmap.dispose if bitmap && !bitmap.disposed?
    super
  end
end

class ShrimpStyleMapBurst
  COLORS = [
    Color.new(255, 35, 25), Color.new(255, 80, 35),
    Color.new(255, 145, 35), Color.new(120, 20, 20)
  ]

  def initialize(scene, event_id)
    @scene = scene
    @event = $game_map.events[event_id]
    @timer = 0
    @particles = []
    @burst_done = false
    @sprite = find_character_sprite
    @base_x = @sprite ? @sprite.x : (@event ? @event.screen_x : 0)
    @base_y = @sprite ? @sprite.y : (@event ? @event.screen_y : 0)
    @base_zoom_x = @sprite ? @sprite.zoom_x : 1.0
    @base_zoom_y = @sprite ? @sprite.zoom_y : 1.0
    @sprite.flash(Color.new(255, 25, 20, 230), 20) if @sprite
  end

  def find_character_sprite
    return nil unless @event
    spriteset = @scene.instance_variable_get(:@spriteset)
    return nil unless spriteset
    sprites = spriteset.instance_variable_get(:@character_sprites) || []
    sprites.find { |sprite| sprite.instance_variable_get(:@character) == @event }
  end

  def viewport
    spriteset = @scene.instance_variable_get(:@spriteset)
    spriteset && spriteset.instance_variable_get(:@viewport1)
  end

  def update
    @timer += 1
    update_charge if @timer <= 18
    burst if @timer == 19
    @particles.each(&:update)
    dead = @particles.select(&:finished?)
    dead.each do |particle|
      particle.dispose
      @particles.delete(particle)
    end
  end

  def update_charge
    return unless @sprite
    growth = 1.0 + @timer * 0.018
    @sprite.zoom_x = @base_zoom_x * growth
    @sprite.zoom_y = @base_zoom_y * growth
    @sprite.x = @base_x + rand(7) - 3
    @sprite.y = @base_y + rand(7) - 3
    pulse = (@timer / 2) % 2 == 0 ? 220 : 80
    @sprite.color.set(255, 25, 20, pulse)
  end

  def burst
    @burst_done = true
    x = @event ? @event.screen_x : @base_x
    y = @event ? @event.screen_y - 16 : @base_y - 16
    scale = [@base_zoom_x, @base_zoom_y, 1.0].max
    22.times do
      @particles << ShrimpStyleMapParticle.new(
        viewport, x + rand(17) - 8, y + rand(17) - 8,
        COLORS[rand(COLORS.size)], scale)
    end
    @event.transparent = true if @event
    @sprite.visible = false if @sprite
    AtlantisShrimpFishing.play_se(AtlantisShrimpFishing::EXPLODE_SE)
    $game_map.screen.start_shake(7, 7, 28)
  end

  def finished?
    @burst_done && @particles.empty?
  end

  def dispose
    @particles.each { |particle| particle.dispose unless particle.disposed? }
    @particles.clear
  end
end

class Scene_Map < Scene_Base
  alias wcf_shrimp_burst_update update
  def update
    wcf_shrimp_burst_update
    return unless @wcf_shrimp_bursts
    @wcf_shrimp_bursts.each(&:update)
    finished = @wcf_shrimp_bursts.select(&:finished?)
    finished.each do |burst|
      burst.dispose
      @wcf_shrimp_bursts.delete(burst)
    end
  end

  alias wcf_shrimp_burst_terminate terminate
  def terminate
    if @wcf_shrimp_bursts
      @wcf_shrimp_bursts.each(&:dispose)
      @wcf_shrimp_bursts.clear
    end
    wcf_shrimp_burst_terminate
  end

  def start_shrimp_style_event_explosion(event_id)
    @wcf_shrimp_bursts ||= []
    @wcf_shrimp_bursts << ShrimpStyleMapBurst.new(self, event_id)
  end
end

class Game_Interpreter
  def shrimp_style_event_explosion(event_id = @event_id)
    return unless SceneManager.scene_is?(Scene_Map)
    SceneManager.scene.start_shrimp_style_event_explosion(event_id)
  end
end
