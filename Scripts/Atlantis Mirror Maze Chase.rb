#==============================================================================
# ** Atlantis Mirror Maze + Chase (playtest implementation)
#==============================================================================

module AtlantisMirrorRoute
  MIRROR_MAP_ID = 28
  CHASE_MAP_ID  = 29
  REVEAL_MAP_ID = 25

  MIRROR_ATLAS = "guong"
  # Pink eye mirror only. The old 94px crop also included its neighbour.
  MIRROR_RECT = Rect.new(670, 158, 54, 128)
  REFLECTIONS = [
    ["!$HaiQuy", 0],
    ["!$HaiQuy_Diana", 0],
    ["!$HaiQuy_GiangSinh", 0],
    ["$HaiQuyAtHome_Base", 0],
    ["$HaiQuyGlitch_Base", 0]
  ]

  CHASE_DURATION = 1800
  QTE_MIN_DELAY = 90
  QTE_MAX_DELAY = 155
  QTE_WINDOW = 110
  MAX_DANGER = 4
  CHASE_SWITCH_STARTED = 35
  CHASE_SWITCH_CLEARED = 36

  QTE_INPUTS = [[:C, "Z"], [:B, "X"], [:A, "SHIFT"],
    [:UP, "↑"], [:DOWN, "↓"]]
  QTE_LENGTH = 3
end

class AtlantisMirrorDisplay
  include AtlantisMirrorRoute

  def initialize(viewport, event)
    @event = event
    @frame = Sprite.new(viewport)
    @frame.bitmap = Cache.load_bitmap("Graphics/Characters/", MIRROR_ATLAS)
    @frame.src_rect.set(MIRROR_RECT.x, MIRROR_RECT.y,
      MIRROR_RECT.width, MIRROR_RECT.height)
    @frame.ox = MIRROR_RECT.width / 2
    @frame.oy = MIRROR_RECT.height
    @frame.zoom_x = 0.78
    @frame.zoom_y = 0.78
    @frame.z = 165

    @reflection = Sprite.new(viewport)
    @reflection.z = 160
    @reflection.opacity = 205
    @reflection.mirror = true
    randomize
    update
  end

  def randomize
    data = REFLECTIONS[rand(REFLECTIONS.size)]
    @character_name = data[0]
    @character_index = data[1]
    @reflection.bitmap = Cache.character(@character_name)
    sign = @character_name[/^[\!\$]./]
    if sign && sign.include?("$")
      @cw = @reflection.bitmap.width / 3
      @ch = @reflection.bitmap.height / 4
    else
      @cw = @reflection.bitmap.width / 12
      @ch = @reflection.bitmap.height / 8
    end
    sx = (@character_index % 4 * 3 + 1) * @cw
    sy = (@character_index / 4 * 4 + 0) * @ch
    @reflection.src_rect.set(sx, sy, @cw, @ch)
    @reflection.ox = @cw / 2
    @reflection.oy = @ch
    @reflection.color.set(55, 75, 105, 75)
  end

  def update
    x = @event.screen_x
    y = @event.screen_y + 15
    @frame.x = x
    @frame.y = y
    @reflection.x = x
    @reflection.y = y - 19
    scale = [30.0 / [@cw, 1].max, 0.9].min
    @reflection.zoom_x = scale
    @reflection.zoom_y = scale
    visible = !$game_map.events[@event.id].nil?
    @frame.visible = visible
    @reflection.visible = visible
  end

  def flash
    @frame.flash(Color.new(180, 100, 255, 180), 24)
    @reflection.flash(Color.new(255, 255, 255, 210), 24)
  end

  def dispose
    @frame.dispose unless @frame.disposed?
    @reflection.dispose unless @reflection.disposed?
  end
end

class AtlantisMirrorManager
  def initialize(scene)
    @scene = scene
    @displays = {}
    spriteset = scene.instance_variable_get(:@spriteset)
    viewport = spriteset && spriteset.instance_variable_get(:@viewport1)
    $game_map.events.each_value do |event|
      source_event = event.instance_variable_get(:@event)
      next unless source_event && source_event.name =~ /^MIRROR-/
      @displays[event.id] = AtlantisMirrorDisplay.new(viewport, event)
    end
  end

  def update
    @displays.each_value(&:update)
  end

  def randomize(event_id)
    display = @displays[event_id]
    return unless display
    display.randomize
    display.flash
    RPG::SE.new("Darkness2", 65, 120).play
  end

  def dispose
    @displays.each_value(&:dispose)
    @displays.clear
  end
end

class AtlantisChaseManager
  include AtlantisMirrorRoute
  include CHARACTER_EX_EFFECTS_COMMAND

  CLONE_LIGHT_ID = "atlantis_clone"

  def initialize(scene, monster_id, obstacle_ids)
    @scene = scene
    @monster = $game_map.events[monster_id]
    @obstacles = obstacle_ids.map { |id| $game_map.events[id] }.compact
    @timer = 0
    @danger = 0
    @qte = nil
    @qte_index = 0
    @qte_timer = 0
    @next_qte = QTE_MIN_DELAY + rand(QTE_MAX_DELAY - QTE_MIN_DELAY + 1)
    @active_obstacle = nil
    @finished = false
    @move_tick = 0
    @action_timer = 0
    @action_kind = nil
    @old_menu_disabled = $game_system.menu_disabled
    @old_player_speed = $game_player.move_speed
    @old_player_frequency = $game_player.move_frequency
    @old_player_step_anime = $game_player.step_anime
    @old_monster_speed = @monster && @monster.move_speed
    @old_monster_frequency = @monster && @monster.move_frequency
    @old_monster_step_anime = @monster && @monster.step_anime
    $game_system.menu_disabled = true
    $game_player.moveto($game_player.x, 7)
    configure_runner($game_player)
    configure_runner(@monster) if @monster
    create_hud
    hide_obstacles
    update_monster_position
  end

  def create_hud
    @hud = Sprite.new
    @hud.z = 500
    @hud.bitmap = Bitmap.new(Graphics.width, 112)
    @hud.y = 12
    refresh_hud
  end

  def update
    return if @finished
    @timer += 1
    update_player_action
    update_auto_run
    update_chase_camera
    update_monster_position
    if @qte
      update_qte
    else
      @next_qte -= 1
      start_qte if @next_qte <= 0
    end
    finish_chase if @timer >= CHASE_DURATION
    refresh_hud if Graphics.frame_count % 6 == 0
  end

  def update_auto_run
    unless $game_player.moving?
      $game_player.move_straight(6)
    end
  end

  def configure_runner(character)
    character.instance_variable_set(:@move_speed, 5)
    character.instance_variable_set(:@move_frequency, 6)
    character.instance_variable_set(:@step_anime, true)
  end

  def update_chase_camera
    # Keep Hải Quỳ on the left third of the screen. On a horizontal loop map
    # this also keeps the pursuing monster behind her instead of wrapping to
    # the right edge, and leaves roughly ten tiles of reaction space ahead.
    $game_map.set_display_pos($game_player.x - 5, $game_player.y - 6)
  end

  def start_qte
    @qte = Array.new(QTE_LENGTH) { QTE_INPUTS[rand(QTE_INPUTS.size)] }
    @qte_index = 0
    @qte_timer = QTE_WINDOW
    @active_obstacle = @obstacles[rand(@obstacles.size)]
    if @active_obstacle
      @active_obstacle.transparent = false
      @active_obstacle.give_light(CLONE_LIGHT_ID)
      @active_obstacle.balloon_id = 1
      @active_obstacle.moveto(($game_player.x + 10) % $game_map.width,
        $game_player.y)
      @active_obstacle.set_direction(4)
    end
    RPG::SE.new("Decision2", 75, 120).play
    refresh_hud
  end

  def update_qte
    @qte_timer -= 1
    update_obstacle_approach
    pressed = QTE_INPUTS.find { |entry| Input.trigger?(entry[0]) }
    if pressed
      if pressed[0] == @qte[@qte_index][0]
        @qte_index += 1
        RPG::SE.new("Cursor1", 70, 110 + @qte_index * 5).play
        qte_success if @qte_index >= @qte.size
      else
        qte_failure
      end
    elsif @qte_timer <= 0
      qte_failure
    end
  end

  def update_obstacle_approach
    return unless @active_obstacle
    # The runner never stops, so a map-fixed obstacle would pass behind her
    # before the sequence ended. Keep it ahead while gradually closing in.
    offset = 3 + (7 * @qte_timer / QTE_WINDOW.to_f).round
    target_x = ($game_player.x + offset) % $game_map.width
    @active_obstacle.moveto(target_x, $game_player.y)
    @active_obstacle.set_direction(4)
  end

  def qte_success
    RPG::SE.new("sfx_smash", 85, 105).play
    $game_player.balloon_id = 1
    start_player_attack
    @danger -= 1 if @danger > 0 && rand(2) == 0
    clear_qte(true)
  end

  def start_player_attack
    @action_timer = 36
    @action_kind = :attack
    $game_player.set_direction(6)
    char_effect(0, "Swing")
    @active_obstacle.moveto(($game_player.x + 2) % $game_map.width,
      $game_player.y) if @active_obstacle
    knock_obstacle_away
  end

  def update_player_action
    return if @action_timer <= 0
    @action_timer -= 1
    return unless @action_timer == 0
    char_effect(0, "Clear")
    if @active_obstacle
      char_effect(@active_obstacle.id, "Clear")
      @active_obstacle.drop_light
      @active_obstacle.transparent = true
    end
    @active_obstacle = nil
    @action_kind = nil
  end

  def knock_obstacle_away
    return unless @active_obstacle
    animation = $data_animations.compact.find do |entry|
      entry.name =~ /(Hit|Blow|Smash|Slash|Fire)/i
    end
    @active_obstacle.animation_id = animation ? animation.id : 1
    RPG::SE.new("se_enemy_destroy", 80, 110).play
    $game_map.screen.start_shake(4, 6, 16)
    char_effect(@active_obstacle.id, "Spin")
    dx, dy = [[10, -4], [12, 0], [10, 4], [-7, -4], [-7, 4]][rand(5)]
    @active_obstacle.jump(dx, dy)
  end

  def qte_failure
    @danger += 1
    $game_player.balloon_id = (@danger >= MAX_DANGER ? 11 : 6)
    RPG::SE.new("Damage3", 85, 95).play
    $game_map.screen.start_shake(7, 7, 25)
    if @danger >= MAX_DANGER
      caught
    else
      clear_qte
    end
  end

  def clear_qte(keep_obstacle = false)
    unless keep_obstacle
      if @active_obstacle
        @active_obstacle.drop_light
        @active_obstacle.transparent = true
      end
      @active_obstacle = nil
    end
    @qte = nil
    @qte_index = 0
    @qte_timer = 0
    @next_qte = QTE_MIN_DELAY + rand(QTE_MAX_DELAY - QTE_MIN_DELAY + 1)
    refresh_hud
  end

  def hide_obstacles
    @obstacles.each do |event|
      event.drop_light
      event.transparent = true
    end
  end

  def update_monster_position
    return unless @monster
    distance = [4 - (@danger / 2), 2].max
    @monster.moveto(($game_player.x - distance) % $game_map.width,
      $game_player.y)
    @monster.set_direction(6)
  end

  def caught
    @finished = true
    @monster.moveto(($game_player.x - 1) % $game_map.width,
      $game_player.y)
    RPG::SE.new("Monster3", 90, 80).play
    $game_map.screen.start_shake(10, 8, 45)
    dispose
    SceneManager.goto(Scene_Gameover)
  end

  def finish_chase
    @finished = true
    $game_switches[CHASE_SWITCH_CLEARED] = true
    hide_obstacles
    $game_player.drop_light
    $game_map.shadows.set_opacity(0, 30)
    RPG::SE.new("Saint5", 80, 110).play
    dispose
    $game_player.reserve_transfer(REVEAL_MAP_ID, 4, 4, 2)
  end

  def refresh_hud
    return unless @hud && @hud.bitmap
    b = @hud.bitmap
    b.clear
    b.fill_rect(12, 0, Graphics.width - 24, 96, Color.new(0, 0, 0, 175))
    b.font.size = 20
    b.font.color = Color.new(255, 255, 255)
    remaining = [(CHASE_DURATION - @timer) / 60, 0].max
    b.draw_text(28, 7, 250, 28, "Thoát khỏi nó: #{remaining}s")
    b.font.color = Color.new(255, 95, 75)
    b.draw_text(Graphics.width - 260, 7, 230, 28,
      "Nguy hiểm: #{@danger}/#{MAX_DANGER}", 2)
    if @qte
      b.font.size = 24
      b.font.bold = true
      b.font.color = Color.new(255, 225, 70)
      sequence = @qte.map { |entry| entry[1] }.join("  >  ")
      b.draw_text(20, 42, Graphics.width - 40, 42,
        "ĐÁNH: #{sequence}  (#{@qte_index}/#{@qte.size})", 1)
      width = Graphics.width - 120
      b.fill_rect(60, 86, width, 6, Color.new(50, 50, 50))
      b.fill_rect(60, 86, (width * @qte_timer / QTE_WINDOW.to_f).to_i,
        6, Color.new(255, 80, 65))
    else
      b.font.size = 18
      b.font.color = Color.new(190, 210, 230)
      b.draw_text(20, 48, Graphics.width - 40, 28,
        "Tiếp tục chạy...", 1)
    end
  end

  def dispose
    char_effect(0, "Clear") if @action_kind
    $game_system.menu_disabled = @old_menu_disabled unless @old_menu_disabled.nil?
    @old_menu_disabled = nil
    restore_runner($game_player, @old_player_speed, @old_player_frequency,
      @old_player_step_anime)
    restore_runner(@monster, @old_monster_speed, @old_monster_frequency,
      @old_monster_step_anime) if @monster
    return unless @hud
    @hud.bitmap.dispose if @hud.bitmap && !@hud.bitmap.disposed?
    @hud.dispose unless @hud.disposed?
    @hud = nil
  end

  def restore_runner(character, speed, frequency, step_anime)
    character.instance_variable_set(:@move_speed, speed) unless speed.nil?
    character.instance_variable_set(:@move_frequency, frequency) unless frequency.nil?
    character.instance_variable_set(:@step_anime, step_anime) unless step_anime.nil?
  end
end

class Scene_Map < Scene_Base
  alias wcf_atlantis_mirror_start start
  def start
    wcf_atlantis_mirror_start
    if $game_map.map_id == AtlantisMirrorRoute::MIRROR_MAP_ID
      @atlantis_mirror_manager = AtlantisMirrorManager.new(self)
    end
  end

  alias wcf_atlantis_mirror_update update
  def update
    wcf_atlantis_mirror_update
    @atlantis_mirror_manager.update if @atlantis_mirror_manager
    @atlantis_chase_manager.update if @atlantis_chase_manager
  end

  alias wcf_atlantis_mirror_terminate terminate
  def terminate
    @atlantis_mirror_manager.dispose if @atlantis_mirror_manager
    @atlantis_mirror_manager = nil
    @atlantis_chase_manager.dispose if @atlantis_chase_manager
    @atlantis_chase_manager = nil
    wcf_atlantis_mirror_terminate
  end

  def mirror_maze_randomize(event_id)
    @atlantis_mirror_manager.randomize(event_id) if @atlantis_mirror_manager
  end

  def start_atlantis_chase(monster_id, obstacle_ids)
    @atlantis_chase_manager.dispose if @atlantis_chase_manager
    @atlantis_chase_manager = AtlantisChaseManager.new(self,
      monster_id, obstacle_ids)
  end
end

class Game_Interpreter
  def mirror_maze_randomize(event_id = @event_id)
    return unless SceneManager.scene_is?(Scene_Map)
    SceneManager.scene.mirror_maze_randomize(event_id)
  end

  def start_atlantis_chase(monster_id = 2, obstacle_ids = [3, 4, 5, 6, 7])
    return unless SceneManager.scene_is?(Scene_Map)
    SceneManager.scene.start_atlantis_chase(monster_id, obstacle_ids)
  end
end
