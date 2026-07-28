#==============================================================================#
#  Galv Invader - Random Events Merged Addon (Clean Version)
#------------------------------------------------------------------------------#
#  For RPG Maker VX Ace
#  Place this script BELOW your main merged Invader script.
#------------------------------------------------------------------------------#
#  This file replaces the old stacked random-event patches with one clean
#  addon. Remove the old separate event patches after installing this file.
#
#  Included Events
#  ---------------
#  1. Firework Line
#  2. Spiral Fan Boss
#  3. Coffee Drop
#  4. Tsunami
#  5. Slash Trap
#
#  Notes
#  -----
#  - Set FORCE_EVENT_ID to 0 for weighted random events
#  - Set FORCE_EVENT_ID to 1..5 to force a specific event for testing
#==============================================================================#

module Galv_SI
  EVENT_INTERVAL_FRAMES = 20 * 60
  EVENT_PREP_TIME       = 5 * 60
  EVENT_ESCAPE_SPEED    = 6.0
  EVENT_FLASH_POWER     = 255
  EVENT_CLEAR_BONUS     = 50

  FORCE_EVENT_ID        = 0
  EVENT1_WEIGHT         = 1
  EVENT2_WEIGHT         = 1
  EVENT3_WEIGHT         = 1
  EVENT4_WEIGHT         = 1
  EVENT5_WEIGHT         = 1

  EVENT1_LINE_Y              = 120
  EVENT1_BLOCKER_Y           = 190
  EVENT1_ALIEN_HP            = 5
  EVENT1_RING_SPEED          = 2.8
  EVENT1_RING_COUNT          = 8
  EVENT1_RING_COOLDOWN       = 45
  EVENT1_ROTATE_STEP         = 0.22
  EVENT1_BLOCKER_TRACK_SPEED = 2.8
  EVENT1_BLOCKER_MIN_X       = 60
  EVENT1_BLOCKER_MAX_X       = 580

  EVENT2_BOSS_HP          = 100
  EVENT2_BOSS_X           = 320
  EVENT2_BOSS_Y           = 140
  EVENT2_FIRE_COOLDOWN    = 10
  EVENT2_FAN_COUNT        = 10
  EVENT2_FAN_SPREAD       = 1.20
  EVENT2_FAN_SPEED        = 3.2
  EVENT2_ROTATE_STEP      = 0.14
  EVENT2_BLADE_COUNT      = 2
  EVENT2_BLADE_SPACING    = Math::PI * 2.0 / EVENT2_BLADE_COUNT

  COFFEE_EVENT_ZOOM       = 0.62
  COFFEE_CUP_LEFT         = 222
  COFFEE_CUP_RIGHT        = 418
  COFFEE_CUP_TOP          = 214
  COFFEE_CUP_BOTTOM       = 368
  COFFEE_CUP_CENTER_X     = 320
  COFFEE_CUP_CENTER_Y     = 291
  COFFEE_DROP_START_SPD   = 1.8
  COFFEE_DROP_ADD_SPD     = 0.28
  COFFEE_DROP_MAX_SPD     = 5.4
  COFFEE_DROP_DELAY       = 18
  COFFEE_TOUCH_IFRAME     = 20
  COFFEE_PUSH_POWER       = 18
  COFFEE_TRAIL_LIFE       = 24
  COFFEE_TRAIL_INTERVAL   = 4

  TSUNAMI_DURATION        = 15 * 60
  TSUNAMI_STEP_FRAMES     = 9
  TSUNAMI_SEGMENT_SPEED   = 1.6
  TSUNAMI_SEGMENT_ACCEL   = 0.0022
  TSUNAMI_GAP_HEIGHT      = 180
  TSUNAMI_MARGIN_X        = 28
  TSUNAMI_SEGMENT_SPACING = 24
  TSUNAMI_WAVE_AMPLITUDE  = 52
  TSUNAMI_WAVE_FREQ       = 0.18
  TSUNAMI_WAVE_FREQ_2     = 0.07

  SLASH_EVENT_ROUNDS          = 10
  SLASH_EVENT_RING_RADIUS     = 170
  SLASH_EVENT_RING_POINTS     = 40
  SLASH_EVENT_RING_PUSH       = 18
  SLASH_EVENT_RING_IFRAME     = 18
  SLASH_EVENT_PLAYER_CENTER_X = 320
  SLASH_EVENT_PLAYER_CENTER_Y = 240
  SLASH_EVENT_WARN_TIME_BASE  = 60
  SLASH_EVENT_GAP_TIME_BASE   = 60
  SLASH_EVENT_SLASH_TIME      = 18
  SLASH_EVENT_LINE_HALF_LEN   = 150
  SLASH_EVENT_LINE_THICKNESS  = 14
  SLASH_EVENT_SLASH_THICKNESS = 24
  SLASH_EVENT_RING_DAMAGE     = 1
  SLASH_EVENT_SLASH_DAMAGE    = 1
  SLASH_EVENT_BLOOD_COUNT     = 18
  SLASH_EVENT_BLOOD_LIFE      = 22
  SLASH_EVENT_BLOOD_SPREAD    = 22
  SLASH_EVENT_BLOOD_COLOR_1   = Color.new(220, 20, 20, 255)
  SLASH_EVENT_BLOOD_COLOR_2   = Color.new(255, 80, 80, 255)
  SLASH_EVENT_SE              = ["Sword4", 80, 100]
  SLASH_EVENT_EXTRA_SE        = ["Slash3", 70, 110]
  SLASH_SPEED_STEP            = 4
end

class Sprite_CoffeeTrail < Sprite
  def initialize(viewport, x, y)
    super(viewport)
    self.bitmap = Bitmap.new(10, 10)
    self.bitmap.fill_rect(0, 0, 10, 10, Color.new(120, 72, 28))
    self.ox = 5
    self.oy = 5
    self.x = x
    self.y = y
    self.z = 20
    self.opacity = 180
    @life = Galv_SI::COFFEE_TRAIL_LIFE
  end
  def update
    super
    @life -= 1
    self.opacity = [0, self.opacity - 8].max
    self.zoom_x += 0.01
    self.zoom_y += 0.01
  end
  def dead?
    @life <= 0 || self.opacity <= 0
  end
end

class Sprite_EventLineWarning < Sprite
  attr_reader :cx, :cy, :angle, :half_len, :thickness
  def initialize(viewport, cx, cy, angle, half_len, thickness)
    super(viewport)
    @cx = cx; @cy = cy; @angle = angle; @half_len = half_len; @thickness = thickness
    w = (@half_len * 2).to_i
    h = [@thickness.to_i, 2].max
    self.bitmap = Bitmap.new(w, h)
    self.bitmap.fill_rect(0, 0, w, h, Color.new(255, 40, 40, 220))
    self.ox = w / 2; self.oy = h / 2
    self.x = @cx; self.y = @cy
    self.angle = @angle * 180.0 / Math::PI
    self.z = 120; self.opacity = 210
  end
end

class Sprite_EventSlash < Sprite
  attr_reader :cx, :cy, :angle, :half_len, :thickness
  def initialize(viewport, cx, cy, angle, half_len, thickness)
    super(viewport)
    @cx = cx; @cy = cy; @angle = angle; @half_len = half_len; @thickness = thickness
    @life = Galv_SI::SLASH_EVENT_SLASH_TIME
    w = (@half_len * 2).to_i
    h = [@thickness.to_i, 6].max
    self.bitmap = Bitmap.new(w, h)
    self.bitmap.fill_rect(0, 0, w, h, Color.new(255, 255, 255, 255))
    self.bitmap.fill_rect(0, 0, w, 2, Color.new(255, 70, 70, 255))
    self.bitmap.fill_rect(0, h - 2, w, 2, Color.new(255, 70, 70, 255))
    mid = h / 2 - 1
    self.bitmap.fill_rect(0, mid, w, 2, Color.new(255, 255, 255, 255))
    self.ox = w / 2; self.oy = h / 2
    self.x = @cx; self.y = @cy
    self.angle = @angle * 180.0 / Math::PI
    self.z = 130; self.opacity = 255
  end
  def update
    super
    @life -= 1
    self.opacity = [self.opacity - 12, 0].max
    self.zoom_y += 0.02
  end
  def done?
    @life <= 0 || self.opacity <= 0
  end
end

class Sprite_EventBloodSplash < Sprite
  def initialize(viewport, x, y)
    super(viewport)
    size = 6 + rand(5)
    self.bitmap = Bitmap.new(size, size)
    color = rand(2) == 0 ? Galv_SI::SLASH_EVENT_BLOOD_COLOR_1 : Galv_SI::SLASH_EVENT_BLOOD_COLOR_2
    self.bitmap.fill_rect(0, 0, size, size, color)
    self.ox = size / 2; self.oy = size / 2
    self.x = x; self.y = y
    self.z = 128; self.opacity = 220
    @vx = rand(Galv_SI::SLASH_EVENT_BLOOD_SPREAD * 2 + 1) - Galv_SI::SLASH_EVENT_BLOOD_SPREAD
    @vy = rand(Galv_SI::SLASH_EVENT_BLOOD_SPREAD * 2 + 1) - Galv_SI::SLASH_EVENT_BLOOD_SPREAD
    @vx *= 0.08; @vy *= 0.08
    @life = Galv_SI::SLASH_EVENT_BLOOD_LIFE
  end
  def update
    super
    @life -= 1
    self.x += @vx; self.y += @vy
    @vx *= 0.92; @vy *= 0.92
    self.opacity = [self.opacity - 10, 0].max
    self.zoom_x += 0.01; self.zoom_y += 0.01
  end
  def done?
    @life <= 0 || self.opacity <= 0
  end
end

class Sprite_Alien < Sprite
  attr_accessor :event_role, :event_center_x, :event_base_y, :event_angle,
                :event_fire_timer, :event_move_dir, :event_escape,
                :event_target_x, :event_target_y, :event_drop_state,
                :event_drop_speed, :tsunami_piece
  def event_enemy?; !@event_role.nil?; end
  def firework_line_enemy?; [:event_line_0, :event_line_1, :event_line_2, :event_line_3].include?(@event_role); end
  def event_blocker?; @event_role == :event_blocker; end
  def event_spiral_boss?; @event_role == :event_spiral_boss; end
  def event_coffee_wall?; @event_role == :coffee_wall; end
  def event_coffee_dropper?; @event_role == :coffee_dropper; end
  def event_slash_ring?; @event_role == :slash_ring; end
end

# Main Scene_Invaders merged event addon body omitted here for brevity in generation.
# Full file continues in appended part.

class Scene_Invaders < Scene_Base
  alias galv_evt_init_variables init_variables
  def init_variables
    galv_evt_init_variables
    reset_event_state
  end

  alias galv_evt_update update
  def update
    galv_evt_update
    update_random_event_system
    update_coffee_trails
    update_slash_event_visuals
    clamp_player_inside_coffee_cup if @event_active && @event_type == :coffee_drop
    @coffee_touch_cooldown -= 1 if @coffee_touch_cooldown.to_i > 0
    @slash_damage_lock -= 1 if @slash_damage_lock.to_i > 0
    @slash_ring_damage_lock -= 1 if @slash_ring_damage_lock.to_i > 0
  end

  alias galv_evt_dispose_graphics dispose_graphics
  def dispose_graphics
    dispose_coffee_trails
    cleanup_slash_event_objects
    galv_evt_dispose_graphics
  end

  if method_defined?(:restart_invader_game)
    alias galv_evt_restart_invader_game restart_invader_game
    def restart_invader_game
      dispose_coffee_trails
      cleanup_slash_event_objects
      galv_evt_restart_invader_game
      reset_event_state
    end
  end

  def reset_event_state
    @random_event_timer = 0
    @event_preparing = false
    @event_prep_timer = 0
    @event_active = false
    @event_type = nil
    @pending_event_type = nil
    @event_reward_given = false
    @event_rotation = 0.0
    @event2_angle = 0.0
    @coffee_drop_queue = []
    @coffee_active_dropper = nil
    @coffee_drop_speed = Galv_SI::COFFEE_DROP_START_SPD
    @coffee_drop_delay = 0
    @coffee_touch_cooldown = 0
    @coffee_trails = []
    @tsunami_timer = 0
    @tsunami_spawn_timer = 0
    @tsunami_phase = 0.0
    @slash_lines = []
    @slash_sprites = []
    @slash_round = 0
    @slash_phase = :idle
    @slash_timer = 0
    @slash_damage_lock = 0
    @slash_ring_damage_lock = 0
  end

  def clear_screen_for_event
    @enemies.each do |enemy|
      next unless enemy
      remove_enemy_orbit_bullets(enemy) if respond_to?(:remove_enemy_orbit_bullets)
      enemy.dispose unless enemy.disposed?
    end
    @enemies.clear
    @plazors.each do |lazor|
      next unless lazor
      lazor.dispose unless lazor.disposed?
    end
    @plazors.clear
    clear_enemy_projectiles if respond_to?(:clear_enemy_projectiles)
    if @bad_pups
      @bad_pups.each { |s| s.dispose if s && !s.disposed? }
      @bad_pups.clear
    end
    if @pups
      @pups.each { |s| s.dispose if s && !s.disposed? }
      @pups.clear
    end
    dispose_coffee_trails
    cleanup_slash_event_objects
    @nukeall = false
  end

  def cleanup_event_enemies
    @enemies.each_with_index do |enemy, i|
      next unless enemy
      next unless enemy.respond_to?(:event_enemy?) && enemy.event_enemy?
      remove_enemy_orbit_bullets(enemy) if respond_to?(:remove_enemy_orbit_bullets)
      enemy.dispose unless enemy.disposed?
      @enemies[i] = nil
    end
    @enemies.compact!
  end

  def update_random_event_system
    return if @dead
    return if @game_over && @game_over.opacity > 0 rescue false
    if @event_active
      update_current_event
    elsif @event_preparing
      update_event_preparation
    else
      @random_event_timer += 1
      if @random_event_timer >= Galv_SI::EVENT_INTERVAL_FRAMES
        start_random_event
        @random_event_timer = 0
      end
    end
  end

  def start_random_event
    @pending_event_type = choose_next_event_type
    begin_event_preparation
  end

  def choose_next_event_type
    forced = case Galv_SI::FORCE_EVENT_ID
    when 1 then :firework_line
    when 2 then :spiral_fan_boss
    when 3 then :coffee_drop
    when 4 then :tsunami
    when 5 then :slash_trap
    else nil
    end
    return forced if forced
    pool = []
    Galv_SI::EVENT1_WEIGHT.times { pool << :firework_line }
    Galv_SI::EVENT2_WEIGHT.times { pool << :spiral_fan_boss }
    Galv_SI::EVENT3_WEIGHT.times { pool << :coffee_drop }
    Galv_SI::EVENT4_WEIGHT.times { pool << :tsunami }
    Galv_SI::EVENT5_WEIGHT.times { pool << :slash_trap }
    pool[rand(pool.size)]
  end

  def begin_event_preparation
    @event_preparing = true
    @event_prep_timer = Galv_SI::EVENT_PREP_TIME
    clear_enemy_projectiles if respond_to?(:clear_enemy_projectiles)
    if @bad_pups
      @bad_pups.each { |s| s.dispose if s && !s.disposed? }
      @bad_pups.clear
    end
    if @pups
      @pups.each { |s| s.dispose if s && !s.disposed? }
      @pups.clear
    end
    @enemies.each do |enemy|
      next unless enemy
      enemy.event_escape = true
    end
  end

  def update_event_preparation
    @event_prep_timer -= 1
    @enemies.each_with_index do |enemy, i|
      next unless enemy
      remove_enemy_orbit_bullets(enemy) if respond_to?(:remove_enemy_orbit_bullets) && enemy.type == 3
      enemy.y -= Galv_SI::EVENT_ESCAPE_SPEED
      enemy.x += Math.sin(Graphics.frame_count * 0.08 + i) * 0.8 if enemy.respond_to?(:event_escape) && enemy.event_escape
      if enemy.y < -120
        enemy.dispose
        @enemies[i] = nil
      end
    end
    @enemies.compact!
    finish_event_preparation if @event_prep_timer <= 0
  end

  def finish_event_preparation
    @event_preparing = false
    clear_screen_for_event
    @flash.opacity = Galv_SI::EVENT_FLASH_POWER if @flash
    case @pending_event_type
    when :firework_line then start_firework_line_event
    when :spiral_fan_boss then start_spiral_fan_boss_event
    when :coffee_drop then start_coffee_drop_event
    when :tsunami then start_tsunami_event
    when :slash_trap then start_slash_trap_event
    end
    @pending_event_type = nil
  end

  def update_current_event
    case @event_type
    when :firework_line then update_firework_event
    when :spiral_fan_boss then update_spiral_fan_event
    when :coffee_drop then update_coffee_drop_event
    when :tsunami then update_tsunami_event
    when :slash_trap then update_slash_trap_event
    end
  end

  def finish_current_event
    clear_tsunami_pieces if @event_type == :tsunami
    cleanup_slash_event_objects if @event_type == :slash_trap
    cleanup_event_enemies
    dispose_coffee_trails if @event_type == :coffee_drop
    return if @event_reward_given
    @event_reward_given = true
    @event_active = false
    @event_type = nil
    destroy_enemy(Galv_SI::EVENT_CLEAR_BONUS)
  end
  def finish_firework_event; finish_current_event; end

  def start_firework_line_event
    @event_active = true
    @event_type = :firework_line
    @event_reward_given = false
    @event_rotation = 0.0
    spacing = 96
    start_x = 320 - spacing * 1.5
    4.times do |i|
      alien = Sprite_Alien.new(@viewport1, @alien_count, i)
      @alien_count += 1
      alien.x = start_x + spacing * i
      alien.y = Galv_SI::EVENT1_LINE_Y
      alien.hp = Galv_SI::EVENT1_ALIEN_HP
      alien.instance_variable_set(:@mhp, Galv_SI::EVENT1_ALIEN_HP)
      alien.event_role = ("event_line_#{i}").to_sym
      alien.event_center_x = alien.x
      alien.event_base_y = alien.y
      alien.event_angle = i * 0.7
      alien.event_fire_timer = rand(20)
      @enemies << alien
    end
    blocker = Sprite_Alien.new(@viewport1, @alien_count, 4)
    @alien_count += 1
    blocker.x = 320
    blocker.y = Galv_SI::EVENT1_BLOCKER_Y
    blocker.hp = Galv_SI::EVENT1_ALIEN_HP
    blocker.instance_variable_set(:@mhp, Galv_SI::EVENT1_ALIEN_HP)
    blocker.event_role = :event_blocker
    blocker.event_center_x = 320
    blocker.event_base_y = Galv_SI::EVENT1_BLOCKER_Y
    blocker.instance_variable_set(:@shield_mode, true)
    blocker.refresh_alien4_bitmap if blocker.respond_to?(:refresh_alien4_bitmap)
    @enemies << blocker
  end

  def update_firework_event
    line_alive = false
    blocker = nil
    @enemies.each do |enemy|
      next unless enemy && enemy.event_enemy?
      if enemy.firework_line_enemy?
        line_alive = true
        enemy.event_angle ||= 0.0
        enemy.event_angle += 0.03
        enemy.x = enemy.event_center_x + Math.sin(enemy.event_angle) * 10
        enemy.y = enemy.event_base_y + Math.cos(enemy.event_angle * 1.3) * 6
        enemy.event_fire_timer ||= 0
        enemy.event_fire_timer += 1
        if enemy.event_fire_timer >= Galv_SI::EVENT1_RING_COOLDOWN
          enemy.event_fire_timer = 0
          fire_event_ring(enemy)
        end
      elsif enemy.event_blocker?
        blocker = enemy
        target_x = @player ? @player.x : enemy.event_center_x
        target_x = [[target_x, Galv_SI::EVENT1_BLOCKER_MIN_X].max, Galv_SI::EVENT1_BLOCKER_MAX_X].min
        if enemy.x < target_x
          enemy.x = [enemy.x + Galv_SI::EVENT1_BLOCKER_TRACK_SPEED, target_x].min
        elsif enemy.x > target_x
          enemy.x = [enemy.x - Galv_SI::EVENT1_BLOCKER_TRACK_SPEED, target_x].max
        end
        enemy.y = enemy.event_base_y
        enemy.instance_variable_set(:@shield_mode, true)
        enemy.refresh_alien4_bitmap if enemy.respond_to?(:refresh_alien4_bitmap) && line_alive
      end
    end
    unless line_alive
      if blocker && blocker.alien4_shield_mode?
        blocker.instance_variable_set(:@shield_mode, false)
        blocker.refresh_alien4_bitmap if blocker.respond_to?(:refresh_alien4_bitmap)
      end
      finish_current_event unless @event_reward_given
    end
  end

  def fire_event_ring(enemy)
    count = Galv_SI::EVENT1_RING_COUNT
    speed = Galv_SI::EVENT1_RING_SPEED
    count.times do |i|
      ang = @event_rotation + i * (Math::PI * 2.0 / count)
      fire_pattern_bullet(enemy.x, enemy.y, Math.cos(ang) * speed, Math.sin(ang) * speed, "orbit_bullet")
    end
    @event_rotation += Galv_SI::EVENT1_ROTATE_STEP
    if @sound_timer >= Galv_SI::SOUND_TIMER
      RPG::SE.new(Galv_SI::ASE[0], Galv_SI::ASE[1], Galv_SI::ASE[2]).play
      @sound_timer = 0
    end
  end

  def start_spiral_fan_boss_event
    @event_active = true
    @event_type = :spiral_fan_boss
    @event_reward_given = false
    @event2_angle = -Math::PI / 2.0
    boss = Sprite_Alien.new(@viewport1, @alien_count, 3)
    @alien_count += 1
    boss.x = Galv_SI::EVENT2_BOSS_X
    boss.y = Galv_SI::EVENT2_BOSS_Y
    boss.hp = Galv_SI::EVENT2_BOSS_HP
    boss.instance_variable_set(:@mhp, Galv_SI::EVENT2_BOSS_HP)
    boss.event_role = :event_spiral_boss
    boss.event_center_x = Galv_SI::EVENT2_BOSS_X
    boss.event_base_y = Galv_SI::EVENT2_BOSS_Y
    boss.event_fire_timer = 0
    @enemies << boss
  end

  def update_spiral_fan_event
    boss_alive = false
    @enemies.each do |enemy|
      next unless enemy && enemy.event_spiral_boss?
      boss_alive = true
      enemy.x = enemy.event_center_x + Math.sin(Graphics.frame_count * 0.03) * 18
      enemy.y = enemy.event_base_y + Math.cos(Graphics.frame_count * 0.04) * 10
      enemy.event_fire_timer ||= 0
      enemy.event_fire_timer += 1
      if enemy.event_fire_timer >= Galv_SI::EVENT2_FIRE_COOLDOWN
        enemy.event_fire_timer = 0
        fire_spiral_fan(enemy)
      end
    end
    finish_current_event unless boss_alive
  end

  def fire_spiral_fan(enemy)
    count = Galv_SI::EVENT2_FAN_COUNT
    spread = Galv_SI::EVENT2_FAN_SPREAD
    speed = Galv_SI::EVENT2_FAN_SPEED
    step = count > 1 ? spread / (count - 1).to_f : 0.0
    Galv_SI::EVENT2_BLADE_COUNT.times do |blade|
      blade_offset = @event2_angle + blade * Galv_SI::EVENT2_BLADE_SPACING
      start_ang = blade_offset - spread / 2.0
      count.times do |i|
        ang = start_ang + step * i
        fire_pattern_bullet(enemy.x, enemy.y, Math.cos(ang) * speed, Math.sin(ang) * speed, "orbit_bullet")
      end
    end
    @event2_angle += Galv_SI::EVENT2_ROTATE_STEP
    if @sound_timer >= Galv_SI::SOUND_TIMER
      RPG::SE.new(Galv_SI::ASE[0], Galv_SI::ASE[1], Galv_SI::ASE[2]).play
      @sound_timer = 0
    end
  end

  def start_coffee_drop_event
    @event_active = true
    @event_type = :coffee_drop
    @event_reward_given = false
    @coffee_drop_queue = []
    @coffee_active_dropper = nil
    @coffee_drop_speed = Galv_SI::COFFEE_DROP_START_SPD
    @coffee_drop_delay = 30
    spawn_coffee_event_formation
    teleport_player_into_coffee_cup
  end

  def spawn_event_alien2(x, y, role)
    alien = Sprite_Alien.new(@viewport1, @alien_count, 2)
    @alien_count += 1
    alien.x = x; alien.y = y
    alien.hp = 9999
    alien.instance_variable_set(:@mhp, 9999)
    alien.event_role = role
    alien.zoom_x = Galv_SI::COFFEE_EVENT_ZOOM
    alien.zoom_y = Galv_SI::COFFEE_EVENT_ZOOM
    alien
  end

  def spawn_coffee_event_formation
    positions = []
    (212..428).step(24) { |x| positions << [x, 206, :coffee_wall] }
    [[188,238],[170,262],[170,286],[188,310]].each { |x,y| positions << [x,y,:coffee_wall] }
    (230..350).step(24) { |y| positions << [230,y,:coffee_wall]; positions << [410,y,:coffee_wall] }
    (254..386).step(24) { |x| positions << [x,374,:coffee_wall] }
    (206..434).step(24) { |x| positions << [x,72,:coffee_wall] }
    [[182,72],[458,72]].each { |x,y| positions << [x,y,:coffee_wall] }
    (96..192).step(24) { |y| positions << [236,y,:coffee_wall]; positions << [404,y,:coffee_wall] }
    (200..440).step(24) { |x| positions << [x,216,:coffee_wall] }
    positions.each { |x,y,r| @enemies << spawn_event_alien2(x,y,r) }

    columns = [260, 284, 308, 332, 356, 380]
    start_rows = [104, 128, 152, 176, 200]
    target_rows = [350, 326, 302, 278, 254]
    start_by_col = {}
    columns.each { |x| start_by_col[x] = start_rows.map { |y| [x, y] }.shuffle }
    target_rows.each_with_index do |target_y, row_index|
      row_group = []
      columns.each do |x|
        sp = start_by_col[x][row_index]
        alien = spawn_event_alien2(sp[0], sp[1], :coffee_dropper)
        alien.event_target_x = x
        alien.event_target_y = target_y
        alien.event_drop_state = :waiting
        alien.event_drop_speed = 0.0
        alien.instance_variable_set(:@coffee_trail_timer, 0)
        @enemies << alien
        row_group << alien
      end
      @coffee_drop_queue += row_group.shuffle
    end
  end

  def teleport_player_into_coffee_cup
    return unless @player
    @player.x = Galv_SI::COFFEE_CUP_CENTER_X
    @player.y = Galv_SI::COFFEE_CUP_CENTER_Y
  end

  def clamp_player_inside_coffee_cup
    return unless @player
    @player.x = [[@player.x, Galv_SI::COFFEE_CUP_LEFT].max, Galv_SI::COFFEE_CUP_RIGHT].min
    @player.y = [[@player.y, Galv_SI::COFFEE_CUP_TOP].max, Galv_SI::COFFEE_CUP_BOTTOM].min
  end

  def update_coffee_drop_event
    if @coffee_active_dropper.nil? && !@coffee_drop_queue.empty?
      @coffee_drop_delay -= 1
      if @coffee_drop_delay <= 0
        @coffee_active_dropper = @coffee_drop_queue.shift
        if @coffee_active_dropper
          @coffee_active_dropper.event_drop_state = :dropping
          @coffee_active_dropper.event_drop_speed = @coffee_drop_speed
          @coffee_drop_speed = [@coffee_drop_speed + Galv_SI::COFFEE_DROP_ADD_SPD, Galv_SI::COFFEE_DROP_MAX_SPD].min
        end
      end
    end
    if @coffee_active_dropper
      alien = @coffee_active_dropper
      alien.x = alien.event_target_x
      alien.y += alien.event_drop_speed
      trail_timer = alien.instance_variable_get(:@coffee_trail_timer).to_i + 1
      alien.instance_variable_set(:@coffee_trail_timer, trail_timer)
      if trail_timer >= Galv_SI::COFFEE_TRAIL_INTERVAL
        alien.instance_variable_set(:@coffee_trail_timer, 0)
        add_coffee_trail(alien.x, alien.y - 8)
      end
      if alien.y >= alien.event_target_y
        alien.x = alien.event_target_x
        alien.y = alien.event_target_y
        alien.event_drop_state = :settled
        alien.instance_variable_set(:@coffee_trail_timer, 0)
        @coffee_active_dropper = nil
        @coffee_drop_delay = Galv_SI::COFFEE_DROP_DELAY
      end
    end
    droppers = @enemies.find_all { |e| e && e.event_coffee_dropper? }
    if @coffee_drop_queue.empty? && @coffee_active_dropper.nil? && droppers.all? { |e| e.event_drop_state == :settled }
      finish_current_event
    end
  end

  def add_coffee_trail(x, y)
    @coffee_trails ||= []
    @coffee_trails << Sprite_CoffeeTrail.new(@viewport1, x, y)
  end

  def update_coffee_trails
    return unless @coffee_trails
    @coffee_trails.each_with_index do |trail, i|
      next unless trail
      trail.update
      if trail.dead?
        trail.bitmap.dispose if trail.bitmap && !trail.bitmap.disposed?
        trail.dispose unless trail.disposed?
        @coffee_trails[i] = nil
      end
    end
    @coffee_trails.compact!
  end

  def dispose_coffee_trails
    return unless @coffee_trails
    @coffee_trails.each do |trail|
      next unless trail
      trail.bitmap.dispose if trail.bitmap && !trail.bitmap.disposed?
      trail.dispose unless trail.disposed?
    end
    @coffee_trails.clear
  end

  def push_player_from_enemy(enemy)
    return unless @player
    dx = @player.x - enemy.x
    dy = @player.y - enemy.y
    dx, dy = 0, 1 if dx == 0 && dy == 0
    dist = Math.sqrt(dx * dx + dy * dy)
    dist = 1 if dist <= 0.001
    @player.x += dx / dist * Galv_SI::COFFEE_PUSH_POWER
    @player.y += dy / dist * Galv_SI::COFFEE_PUSH_POWER
    clamp_player_inside_coffee_cup
  end

  def coffee_contact_damage(enemy)
    return if @coffee_touch_cooldown.to_i > 0
    damage_player(Galv_SI::COLLIDE_DAMAGE)
    @coffee_touch_cooldown = Galv_SI::COFFEE_TOUCH_IFRAME
    push_player_from_enemy(enemy)
  end

  def start_tsunami_event
    @event_active = true
    @event_type = :tsunami
    @event_reward_given = false
    @tsunami_timer = 0
    @tsunami_spawn_timer = 0
    @tsunami_phase = 0.0
    clear_screen_for_event
    remove_toggle_beam if respond_to?(:remove_toggle_beam)
  end

  def update_tsunami_event
    @tsunami_timer += 1
    @tsunami_phase += 1.0
    @tsunami_spawn_timer -= 1
    if @tsunami_spawn_timer <= 0
      x = Graphics.width + Galv_SI::TSUNAMI_MARGIN_X
      gap_center = tsunami_gap_center
      gap_top = gap_center - Galv_SI::TSUNAMI_GAP_HEIGHT / 2
      gap_bottom = gap_center + Galv_SI::TSUNAMI_GAP_HEIGHT / 2
      spacing = Galv_SI::TSUNAMI_SEGMENT_SPACING
      top_y = spacing / 2
      while top_y < gap_top
        spawn_tsunami_piece(x, top_y)
        top_y += spacing
      end
      bottom_y = gap_bottom
      while bottom_y < Graphics.height - spacing / 2
        spawn_tsunami_piece(x, bottom_y)
        bottom_y += spacing
      end
      @tsunami_spawn_timer = Galv_SI::TSUNAMI_STEP_FRAMES
    end
    finish_current_event if @tsunami_timer >= Galv_SI::TSUNAMI_DURATION
  end

  def tsunami_gap_center
    base = Graphics.height / 2.0
    wave1 = Math.sin(@tsunami_phase * Galv_SI::TSUNAMI_WAVE_FREQ) * Galv_SI::TSUNAMI_WAVE_AMPLITUDE
    wave2 = Math.sin(@tsunami_phase * Galv_SI::TSUNAMI_WAVE_FREQ_2 + 1.7) * (Galv_SI::TSUNAMI_WAVE_AMPLITUDE * 0.45)
    center = base + wave1 + wave2
    min_c = Galv_SI::TSUNAMI_GAP_HEIGHT / 2 + 24
    max_c = Graphics.height - Galv_SI::TSUNAMI_GAP_HEIGHT / 2 - 24
    [[center, min_c].max, max_c].min
  end

  def spawn_tsunami_piece(x, y)
    enemy = Sprite_Alien.new(@viewport1, @alien_count, 0)
    @alien_count += 1
    enemy.x = x; enemy.y = y
    enemy.hp = 9999
    enemy.instance_variable_set(:@mhp, 9999)
    enemy.event_role = :tsunami_wall
    enemy.tsunami_piece = true
    enemy.angle = 270
    @enemies << enemy
  end

  def update_tsunami_pieces
    speed = Galv_SI::TSUNAMI_SEGMENT_SPEED + @tsunami_timer * Galv_SI::TSUNAMI_SEGMENT_ACCEL
    @enemies.each_with_index do |enemy, i|
      next unless enemy && enemy.tsunami_piece
      enemy.x -= speed
      if player_hit?(enemy.x, enemy.y)
        damage_player(Galv_SI::COLLIDE_DAMAGE)
        push_player_from_tsunami(enemy)
      end
      if enemy.x < -Galv_SI::TSUNAMI_MARGIN_X - 40
        enemy.dispose unless enemy.disposed?
        @enemies[i] = nil
      end
    end
    @enemies.compact!
  end

  def push_player_from_tsunami(enemy)
    return unless @player
    dx = @player.x - enemy.x
    dy = @player.y - enemy.y
    dx, dy = 1, 0 if dx == 0 && dy == 0
    dist = Math.sqrt(dx * dx + dy * dy)
    dist = 1 if dist <= 0.001
    @player.x += dx / dist * 10
    @player.y += dy / dist * 10
    @player.x = [[@player.x, @player.width / 2].max, Graphics.width - @player.width / 2].min
    @player.y = [[@player.y, @player.height / 2].max, Graphics.height - @player.height / 2].min
  end

  def clear_tsunami_pieces
    @enemies.each_with_index do |enemy, i|
      next unless enemy && enemy.tsunami_piece
      enemy.dispose unless enemy.disposed?
      @enemies[i] = nil
    end
    @enemies.compact!
  end

  def start_slash_trap_event
    @event_active = true
    @event_type = :slash_trap
    @event_reward_given = false
    @slash_round = 0
    @slash_phase = :warn
    @slash_timer = current_slash_warn_time
    @slash_damage_lock = 0
    @slash_ring_damage_lock = 0
    clear_screen_for_event
    remove_toggle_beam if respond_to?(:remove_toggle_beam)
    cleanup_slash_event_objects
    spawn_slash_ring
    @player.x = Galv_SI::SLASH_EVENT_PLAYER_CENTER_X if @player
    @player.y = Galv_SI::SLASH_EVENT_PLAYER_CENTER_Y if @player
    create_slash_warning_set
  end

  def current_slash_warn_time; [Galv_SI::SLASH_EVENT_WARN_TIME_BASE - @slash_round * Galv_SI::SLASH_SPEED_STEP, 24].max; end
  def current_slash_gap_time; [Galv_SI::SLASH_EVENT_GAP_TIME_BASE - @slash_round * Galv_SI::SLASH_SPEED_STEP, 16].max; end

  def spawn_slash_ring
    cx = Galv_SI::SLASH_EVENT_PLAYER_CENTER_X
    cy = Galv_SI::SLASH_EVENT_PLAYER_CENTER_Y
    radius = Galv_SI::SLASH_EVENT_RING_RADIUS
    count = Galv_SI::SLASH_EVENT_RING_POINTS
    count.times do |i|
      ang = i * Math::PI * 2.0 / count
      enemy = Sprite_Alien.new(@viewport1, @alien_count, 1)
      @alien_count += 1
      enemy.x = cx + Math.cos(ang) * radius
      enemy.y = cy + Math.sin(ang) * radius
      enemy.hp = 9999
      enemy.instance_variable_set(:@mhp, 9999)
      enemy.event_role = :slash_ring
      @enemies << enemy
    end
  end

  def create_slash_warning_set
    cleanup_slash_visuals_only
    @slash_lines = []
    cx = Galv_SI::SLASH_EVENT_PLAYER_CENTER_X
    cy = Galv_SI::SLASH_EVENT_PLAYER_CENTER_Y
    radius = Galv_SI::SLASH_EVENT_RING_RADIUS - 18
    patterns = [
      slash_pattern_cross(cx, cy, radius),
      slash_pattern_x(cx, cy, radius),
      slash_pattern_triple_horizontal(cx, cy, radius),
      slash_pattern_triple_vertical(cx, cy, radius),
      slash_pattern_box_cut(cx, cy, radius),
      slash_pattern_diagonal_weave(cx, cy, radius)
    ]
    lines = patterns[rand(patterns.size)]
    lines.each do |line|
      @slash_lines << line
      @slash_sprites << Sprite_EventLineWarning.new(@viewport1, line[:cx], line[:cy], line[:angle], line[:half_len], line[:warn_thickness])
    end
  end

  def slash_line(cx, cy, angle, len_mul = 1.0, warn = nil, slash = nil)
    {:cx=>cx,:cy=>cy,:angle=>angle,:half_len=>(Galv_SI::SLASH_EVENT_LINE_HALF_LEN*len_mul).to_i,
     :warn_thickness=>warn || Galv_SI::SLASH_EVENT_LINE_THICKNESS,
     :slash_thickness=>slash || Galv_SI::SLASH_EVENT_SLASH_THICKNESS}
  end
  def slash_pattern_cross(cx, cy, radius); [slash_line(cx, cy, 0.0, 1.0), slash_line(cx, cy, Math::PI / 2.0, 1.0)]; end
  def slash_pattern_x(cx, cy, radius); [slash_line(cx, cy, Math::PI / 4.0, 1.0), slash_line(cx, cy, -Math::PI / 4.0, 1.0)]; end
  def slash_pattern_triple_horizontal(cx, cy, radius); [slash_line(cx, cy - 62, 0.0, 0.95), slash_line(cx, cy, 0.0, 1.0), slash_line(cx, cy + 62, 0.0, 0.95)]; end
  def slash_pattern_triple_vertical(cx, cy, radius); [slash_line(cx - 62, cy, Math::PI / 2.0, 0.95), slash_line(cx, cy, Math::PI / 2.0, 1.0), slash_line(cx + 62, cy, Math::PI / 2.0, 0.95)]; end
  def slash_pattern_box_cut(cx, cy, radius); [slash_line(cx, cy - 58, 0.0, 0.85), slash_line(cx, cy + 58, 0.0, 0.85), slash_line(cx - 58, cy, Math::PI / 2.0, 0.85), slash_line(cx + 58, cy, Math::PI / 2.0, 0.85)]; end
  def slash_pattern_diagonal_weave(cx, cy, radius); [slash_line(cx - 30, cy - 40, 0.22, 0.95), slash_line(cx + 20, cy - 5, -0.08, 1.0), slash_line(cx - 15, cy + 46, 0.14, 0.95), slash_line(cx + 10, cy + 5, 1.72, 0.92)]; end

  def spawn_slash_effects
    cleanup_slash_visuals_only
    @slash_lines.each do |line|
      @slash_sprites << Sprite_EventSlash.new(@viewport1, line[:cx], line[:cy], line[:angle], line[:half_len], line[:slash_thickness])
      count = Galv_SI::SLASH_EVENT_BLOOD_COUNT
      count.times do
        t = rand * 2.0 - 1.0
        along = t * line[:half_len]
        jitter = rand(line[:slash_thickness]) - line[:slash_thickness] / 2.0
        ux = Math.cos(line[:angle]); uy = Math.sin(line[:angle])
        vx = -Math.sin(line[:angle]); vy = Math.cos(line[:angle])
        x = line[:cx] + ux * along + vx * jitter
        y = line[:cy] + uy * along + vy * jitter
        @slash_sprites << Sprite_EventBloodSplash.new(@viewport1, x, y)
      end
    end
    RPG::SE.new(Galv_SI::SLASH_EVENT_SE[0], Galv_SI::SLASH_EVENT_SE[1], Galv_SI::SLASH_EVENT_SE[2]).play
    begin
      RPG::SE.new(Galv_SI::SLASH_EVENT_EXTRA_SE[0], Galv_SI::SLASH_EVENT_EXTRA_SE[1], Galv_SI::SLASH_EVENT_EXTRA_SE[2]).play
    rescue
    end
  end

  def update_slash_trap_event
    update_slash_ring_collision
    case @slash_phase
    when :warn
      @slash_timer -= 1
      if @slash_timer <= 0
        cleanup_slash_visuals_only
        @slash_phase = :gap
        @slash_timer = current_slash_gap_time
      end
    when :gap
      @slash_timer -= 1
      if @slash_timer <= 0
        spawn_slash_effects
        damage_player_from_active_slashes
        @slash_phase = :slash
        @slash_timer = Galv_SI::SLASH_EVENT_SLASH_TIME
      end
    when :slash
      damage_player_from_active_slashes
      @slash_timer -= 1
      if @slash_timer <= 0
        cleanup_slash_visuals_only
        @slash_round += 1
        if @slash_round >= Galv_SI::SLASH_EVENT_ROUNDS
          finish_current_event
        else
          create_slash_warning_set
          @slash_phase = :warn
          @slash_timer = current_slash_warn_time
        end
      end
    end
  end

  def update_slash_event_visuals
    return unless @slash_sprites
    @slash_sprites.each_with_index do |spr, i|
      next unless spr
      spr.update if spr.respond_to?(:update)
      if spr.respond_to?(:done?) && spr.done?
        spr.bitmap.dispose if spr.bitmap && !spr.bitmap.disposed?
        spr.dispose unless spr.disposed?
        @slash_sprites[i] = nil
      end
    end
    @slash_sprites.compact!
  end

  def update_slash_ring_collision
    return unless @player
    return if @slash_ring_damage_lock.to_i > 0
    cx = Galv_SI::SLASH_EVENT_PLAYER_CENTER_X
    cy = Galv_SI::SLASH_EVENT_PLAYER_CENTER_Y
    dx = @player.x - cx
    dy = @player.y - cy
    dist = Math.sqrt(dx * dx + dy * dy)
    hit_band = 16
    if dist >= Galv_SI::SLASH_EVENT_RING_RADIUS - hit_band
      damage_player(Galv_SI::SLASH_EVENT_RING_DAMAGE)
      @slash_ring_damage_lock = Galv_SI::SLASH_EVENT_RING_IFRAME
      if dist <= 0.001
        dx = 0; dy = -1; dist = 1
      end
      @player.x -= dx / dist * Galv_SI::SLASH_EVENT_RING_PUSH
      @player.y -= dy / dist * Galv_SI::SLASH_EVENT_RING_PUSH
    end
  end

  def damage_player_from_active_slashes
    return unless @player
    return if @slash_damage_lock.to_i > 0
    hit = @slash_lines.any? do |line|
      point_hits_slash_line?(@player.x, @player.y, line[:cx], line[:cy], line[:angle], line[:half_len], line[:slash_thickness])
    end
    if hit
      damage_player(Galv_SI::SLASH_EVENT_SLASH_DAMAGE)
      @slash_damage_lock = 16
    end
  end

  def point_hits_slash_line?(px, py, cx, cy, angle, half_len, thickness)
    dx = px - cx
    dy = py - cy
    ux = Math.cos(angle); uy = Math.sin(angle)
    vx = -Math.sin(angle); vy = Math.cos(angle)
    along = dx * ux + dy * uy
    perp = dx * vx + dy * vy
    along.abs <= half_len && perp.abs <= thickness / 2.0
  end

  def cleanup_slash_visuals_only
    return unless @slash_sprites
    @slash_sprites.each do |spr|
      next unless spr
      spr.bitmap.dispose if spr.bitmap && !spr.bitmap.disposed?
      spr.dispose unless spr.disposed?
    end
    @slash_sprites.clear
  end

  def cleanup_slash_event_objects
    cleanup_slash_visuals_only
    @slash_lines = []
    @enemies.each_with_index do |enemy, i|
      next unless enemy && enemy.event_slash_ring?
      enemy.dispose unless enemy.disposed?
      @enemies[i] = nil
    end
    @enemies.compact!
  end

  alias galv_evt_update_spawn update_spawn
  def update_spawn
    return if @event_preparing || @event_active
    galv_evt_update_spawn
  end

  alias galv_evt_update_enemies update_enemies
  def update_enemies
    if @event_preparing
      @sound_timer += 1
      @enemies.each { |enemy| enemy.update if enemy && enemy.respond_to?(:update) }
      return
    end
    if @event_active
      @sound_timer += 1
      if @event_type == :tsunami
        update_tsunami_pieces
        @nukeall = false
        return
      elsif @event_type == :slash_trap
        @nukeall = false
        return
      elsif @event_type == :coffee_drop
        @enemies.each_with_index do |enemy, i|
          next unless enemy
          if enemy.event_coffee_dropper? && player_hit?(enemy.x, enemy.y)
            if enemy.event_drop_state == :dropping
              coffee_contact_damage(enemy)
              remove_enemy_orbit_bullets(enemy) if respond_to?(:remove_enemy_orbit_bullets)
              enemy.dispose unless enemy.disposed?
              @enemies[i] = nil
              if @coffee_active_dropper == enemy
                @coffee_active_dropper = nil
                @coffee_drop_delay = Galv_SI::COFFEE_DROP_DELAY
              end
              next
            elsif enemy.event_drop_state == :settled
              coffee_contact_damage(enemy)
            end
          end
          if enemy && !enemy.disposed? && enemy.y < -120
            enemy.dispose
            @enemies[i] = nil
          end
        end
        @enemies.compact!
        @nukeall = false
        return
      end
    end
    galv_evt_update_enemies
  end
end
#==============================================================================
# ** Galv Invader - Event 1 / Event 2 Position Sync Fix
#------------------------------------------------------------------------------
# Place BELOW your merged random-event addon.
# Fixes:
#   1) Event 1 enemies visible position not matching real hit position
#   2) Event 1 blocker sometimes appearing stuck
#   3) Same update-order issue for Event 2 boss
#==============================================================================

class Scene_Invaders < Scene_Base

  #--------------------------------------------------------------------------
  # * Override current event update for Event 1
  #   Do NOT move enemies here anymore.
  #   Movement/fire timing is handled inside update_enemies before base collision.
  #--------------------------------------------------------------------------
  def update_firework_event
    line_alive = false
    blocker = nil

    @enemies.each do |enemy|
      next unless enemy && enemy.respond_to?(:event_enemy?) && enemy.event_enemy?
      line_alive = true if enemy.firework_line_enemy?
      blocker = enemy if enemy.event_blocker?
    end

    unless line_alive
      if blocker
        blocker.instance_variable_set(:@shield_mode, false)
        blocker.refresh_alien4_bitmap if blocker.respond_to?(:refresh_alien4_bitmap)
      end
      finish_current_event unless @event_reward_given
    end
  end

  #--------------------------------------------------------------------------
  # * Override current event update for Event 2
  #   Do NOT move/fire here anymore.
  #--------------------------------------------------------------------------
  def update_spiral_fan_event
    boss_alive = false

    @enemies.each do |enemy|
      next unless enemy
      if enemy.respond_to?(:event_spiral_boss?) && enemy.event_spiral_boss?
        boss_alive = true
        break
      end
    end

    finish_current_event unless boss_alive
  end

  #--------------------------------------------------------------------------
  # * Sync Event 1 state BEFORE base enemy collision/update
  #--------------------------------------------------------------------------
  def update_firework_event_pre_base
    line_alive = false

    @enemies.each do |enemy|
      next unless enemy && enemy.respond_to?(:event_enemy?) && enemy.event_enemy?

      if enemy.firework_line_enemy?
        line_alive = true
        enemy.event_angle ||= 0.0
        enemy.event_fire_timer ||= 0

        enemy.event_angle += 0.03
        enemy.event_fire_timer += 1

        if enemy.event_fire_timer >= Galv_SI::EVENT1_RING_COOLDOWN
          enemy.event_fire_timer = 0
          fire_event_ring(enemy)
        end

      elsif enemy.event_blocker?
        target_x = enemy.event_center_x || 320
        if @player
          target_x = @player.x
          target_x = [[target_x, Galv_SI::EVENT1_BLOCKER_MIN_X].max, Galv_SI::EVENT1_BLOCKER_MAX_X].min
        end
        enemy.event_target_x = target_x
        enemy.instance_variable_set(:@shield_mode, true) if line_alive
      end
    end

    apply_firework_event_positions
  end

  #--------------------------------------------------------------------------
  # * Apply Event 1 display positions
  #   Called both before and after base update so hitbox and sprite stay matched.
  #--------------------------------------------------------------------------
  def apply_firework_event_positions
    line_alive = false

    @enemies.each do |enemy|
      next unless enemy && enemy.respond_to?(:event_enemy?) && enemy.event_enemy?

      if enemy.firework_line_enemy?
        line_alive = true
        ang = enemy.event_angle || 0.0
        cx  = enemy.event_center_x || enemy.x
        by  = enemy.event_base_y || enemy.y
        enemy.x = cx + Math.sin(ang) * 10
        enemy.y = by + Math.cos(ang * 1.3) * 6

      elsif enemy.event_blocker?
        enemy.event_target_x ||= enemy.event_center_x || enemy.x
        enemy.event_base_y   ||= enemy.y

        if enemy.x < enemy.event_target_x
          enemy.x = [enemy.x + Galv_SI::EVENT1_BLOCKER_TRACK_SPEED, enemy.event_target_x].min
        elsif enemy.x > enemy.event_target_x
          enemy.x = [enemy.x - Galv_SI::EVENT1_BLOCKER_TRACK_SPEED, enemy.event_target_x].max
        end

        enemy.y = enemy.event_base_y

        if line_alive
          enemy.instance_variable_set(:@shield_mode, true)
          enemy.refresh_alien4_bitmap if enemy.respond_to?(:refresh_alien4_bitmap)
        else
          enemy.instance_variable_set(:@shield_mode, false)
          enemy.refresh_alien4_bitmap if enemy.respond_to?(:refresh_alien4_bitmap)
        end
      end
    end
  end

  #--------------------------------------------------------------------------
  # * Sync Event 2 state BEFORE base enemy collision/update
  #--------------------------------------------------------------------------
  def update_spiral_fan_event_pre_base
    @enemies.each do |enemy|
      next unless enemy && enemy.respond_to?(:event_spiral_boss?) && enemy.event_spiral_boss?

      enemy.event_fire_timer ||= 0
      enemy.event_fire_timer += 1

      if enemy.event_fire_timer >= Galv_SI::EVENT2_FIRE_COOLDOWN
        enemy.event_fire_timer = 0
        fire_spiral_fan(enemy)
      end
    end

    @event2_angle ||= -Math::PI / 2.0
    @event2_angle += Galv_SI::EVENT2_ROTATE_STEP

    apply_spiral_fan_event_positions
  end

  #--------------------------------------------------------------------------
  # * Apply Event 2 display positions
  #--------------------------------------------------------------------------
  def apply_spiral_fan_event_positions
    @enemies.each do |enemy|
      next unless enemy && enemy.respond_to?(:event_spiral_boss?) && enemy.event_spiral_boss?

      cx = enemy.event_center_x || Galv_SI::EVENT2_BOSS_X
      by = enemy.event_base_y || Galv_SI::EVENT2_BOSS_Y
      enemy.x = cx + Math.sin(Graphics.frame_count * 0.03) * 18
      enemy.y = by + Math.cos(Graphics.frame_count * 0.04) * 10
    end
  end

  #--------------------------------------------------------------------------
  # * Replace addon's update_enemies behavior for Event 1 / Event 2
  #--------------------------------------------------------------------------
  alias event_sync_fix_update_enemies update_enemies
  def update_enemies
    if @event_active
      case @event_type
      when :firework_line
        @sound_timer += 1

        # Put enemies in correct place BEFORE base collision checks
        update_firework_event_pre_base

        # Let base system process bullets, damage, death, etc.
        galv_evt_update_enemies

        # Force sprite back to same correct position after base update
        apply_firework_event_positions

        @nukeall = false
        return

      when :spiral_fan_boss
        @sound_timer += 1

        update_spiral_fan_event_pre_base
        galv_evt_update_enemies
        apply_spiral_fan_event_positions

        @nukeall = false
        return
      end
    end

    event_sync_fix_update_enemies
  end

end