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

  CHASE_DURATION = 3600
  QTE_MIN_DELAY = 60
  QTE_MAX_DELAY = 100
  QTE_WINDOW = 110
  MAX_DANGER = 4
  CHASE_SWITCH_STARTED = 35
  CHASE_SWITCH_CLEARED = 36

  MONSTER_FRAME_WIDTH = 298
  MONSTER_FRAME_HEIGHT = 313
  MONSTER_CHASE_FRAMES = 6
  MONSTER_BOUND_FRAMES = 26
  CHASE_MONSTER_DRAW_Y = 40
  CHASE_END_DISTANCE = 2.75

  QTE_INPUTS = [[:C, "Z"], [:B, "X"], [:A, "SHIFT"],
    [:UP, "↑"], [:DOWN, "↓"]]
  QTE_LENGTH = 3
end

# Monster.png and Monster1.png are 4x7 animation atlases, not RPG Maker
# character sheets. Keep the map event as an invisible anchor and render the
# correct atlas frame through this overlay.
class AtlantisMonsterDisplay
  include AtlantisMirrorRoute

  def initialize(viewport,event,mode=:chase)
    @event=event
    @sprite=Sprite.new(viewport)
    @sprite.ox=MONSTER_FRAME_WIDTH/2
    @sprite.oy=MONSTER_FRAME_HEIGHT
    @sprite.zoom_x=@sprite.zoom_y=0.42
    # The pursuer stays behind the player instead of being drawn over her.
    @sprite.z=99
    set_mode(mode)
  end

  def set_mode(mode)
    @mode=mode
    @tick=0
    @frame=0
    @frame_count=mode==:bound ? MONSTER_BOUND_FRAMES : MONSTER_CHASE_FRAMES
    @loop=mode!=:bound
    @sprite.bitmap=Cache.character(mode==:bound ? "Monster" : "Monster1")
    refresh_frame
  end

  def refresh_frame
    column=@frame%4
    row=@frame/4
    @sprite.src_rect.set(column*MONSTER_FRAME_WIDTH,row*MONSTER_FRAME_HEIGHT,
      MONSTER_FRAME_WIDTH,MONSTER_FRAME_HEIGHT)
  end

  def update
    if @shattered
      @sprite.visible = false
      return
    end
    @tick+=1
    if @tick%7==0
      if @loop
        @frame=(@frame+1)%@frame_count
      elsif @frame<@frame_count-1
        @frame+=1
      end
      refresh_frame
    end
    @sprite.x=@event.screen_x
    draw_y = $game_map.map_id == CHASE_MAP_ID ? CHASE_MONSTER_DRAW_Y : 8
    @sprite.y=@event.screen_y+draw_y
    viewport = @sprite.viewport
    offset_x = viewport ? viewport.rect.x - viewport.ox : 0
    offset_y = viewport ? viewport.rect.y - viewport.oy : 0
    pop_x = @sprite.x + offset_x
    pop_y = @sprite.y + offset_y
    @event.instance_variable_set(:@pop_message_screen_x, pop_x)
    @event.instance_variable_set(:@pop_message_baseline_y, pop_y)
    @event.instance_variable_set(:@pop_message_top_y,
      pop_y - MONSTER_FRAME_HEIGHT * @sprite.zoom_y)
    @sprite.opacity=@event.opacity
    @sprite.visible=!@event.transparent
  end

  def shatter(duration=90)
    return if @shattered || @sprite.disposed?
    @shattered = true
    @sprite.visible = false
    bitmap = @sprite.bitmap
    viewport = @sprite.viewport
    return unless bitmap && viewport
    # RGSS3's Viewport does not implement Sprite#disposed?. Touch a harmless
    # property instead and treat an RGSS disposed-object error as unavailable.
    begin
      viewport.rect
    rescue
      return
    end
    scale = @sprite.zoom_x
    source_x = @sprite.src_rect.x
    source_y = @sprite.src_rect.y
    left = @sprite.x - MONSTER_FRAME_WIDTH * scale / 2.0
    top = @sprite.y - MONSTER_FRAME_HEIGHT * scale
    shards = []
    cell_w = 30
    cell_h = 31
    10.times do |column|
      10.times do |row|
        next if rand(100) < 38
        local_x = column * cell_w
        local_y = row * cell_h
        width = [cell_w, MONSTER_FRAME_WIDTH - local_x].min
        height = [cell_h, MONSTER_FRAME_HEIGHT - local_y].min
        next if width <= 0 || height <= 0
        shard = Sprite.new(viewport)
        shard.bitmap = bitmap
        shard.src_rect.set(source_x + local_x, source_y + local_y,
          width, height)
        shard.ox = width / 2
        shard.oy = height / 2
        shard.zoom_x = shard.zoom_y = scale
        shard.x = left + (local_x + width / 2.0) * scale
        shard.y = top + (local_y + height / 2.0) * scale
        shard.z = @sprite.z + 1
        angle = Math.atan2(shard.y - @sprite.y + 55,
          shard.x - @sprite.x) + (rand - 0.5) * 0.7
        speed = 1.2 + rand * 2.7
        shards << [shard, Math.cos(angle) * speed,
          Math.sin(angle) * speed - 0.8, (rand - 0.5) * 0.14]
      end
    end
    duration.times do |frame|
      shards.each do |data|
        shard, vx, vy, spin = data
        shard.x += vx
        shard.y += vy + frame * 0.025
        shard.angle += spin * 10
        shard.opacity = 255 * (duration - frame) / duration
      end
      Fiber.yield
    end
  ensure
    shards.each {|data| data[0].dispose unless data[0].disposed? } if shards
  end

  def dispose
    @event.instance_variable_set(:@pop_message_screen_x, nil)
    @event.instance_variable_set(:@pop_message_baseline_y, nil)
    @event.instance_variable_set(:@pop_message_top_y, nil)
    @sprite.dispose unless @sprite.disposed?
  end
end

# Plays the bespoke three-sheet cage sequence used by the owner-first Abyss
# ending.  The first cracks deliberately carry more hold time; once the seal
# gives way, the remaining drawings accelerate to make the collapse feel
# heavy instead of uniformly mechanical.
def atlantis_play_cage_break(event_id)
  event = $game_map.events[event_id]
  return unless event
  directions = [2, 4, 6, 8]
  sequence = []
  [42, 38, 34, 30, 26, 22, 18, 15, 12, 10, 8, 7].each_with_index do |hold, frame|
    sequence << ["$Cage_1", frame, hold]
  end
  [6, 5, 5, 4, 4, 3, 3, 3, 2].each_with_index do |hold, frame|
    sequence << ["$Cage_2", frame, hold]
  end
  [3, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2].each_with_index do |hold, frame|
    sequence << ["$Cage_3", frame, hold]
  end
  current_sheet = nil
  sequence.each do |sheet, frame, hold|
    if sheet != current_sheet
      event.set_graphic(sheet, 0)
      current_sheet = sheet
    end
    event.set_direction(directions[frame / 3])
    event.instance_variable_set(:@pattern, frame % 3)
    event.instance_variable_set(:@original_pattern, frame % 3)
    event.instance_variable_set(:@anime_count, 0)
    hold.times { Fiber.yield }
  end
  event.opacity = 0
end

class AtlantisMonsterManager
  def initialize(scene)
    spriteset=scene.instance_variable_get(:@spriteset)
    viewport=spriteset && spriteset.instance_variable_get(:@viewport1)
    @displays={}
    $game_map.events.each_value do |event|
      source=event.instance_variable_get(:@event)
      next unless source && source.name =~ /ABYSS-(?:SHADOW|MONSTER)/
      @displays[event.id]=AtlantisMonsterDisplay.new(viewport,event,:chase)
    end
  end

  def update
    @displays.each_value(&:update)
  end

  def set_mode(event_id,mode)
    display=@displays[event_id]
    display.set_mode(mode.to_sym) if display
  end

  def shatter(event_id,duration=90)
    display=@displays[event_id]
    display.shatter(duration) if display
  end

  def dispose
    @displays.each_value(&:dispose)
    @displays.clear
  end
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
    @obstacle_bag = []
    @encounters_seen = 0
    @finished = false
    @disposed = false
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
    @old_monster_through = @monster &&
      @monster.instance_variable_get(:@through)
    $game_system.menu_disabled = true
    $game_player.moveto(10, $game_player.y)
    $game_player.set_direction(2)
    configure_runner($game_player)
    if @monster
      @monster.moveto($game_player.x,
        ($game_player.y - 4) % $game_map.height)
      @monster.set_direction(2)
      @monster.instance_variable_set(:@through, true)
      configure_runner(@monster)
    end
    create_hud
    hide_obstacles
    update_chase_camera
    update_monster_anchor
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
    update_monster_anchor
    if @qte
      update_qte
    else
      @next_qte -= 1
      start_qte if @next_qte <= 0
    end
    finish_chase if @timer >= CHASE_DURATION &&
      @encounters_seen >= @obstacles.size && !@qte && !@active_obstacle
    refresh_hud if Graphics.frame_count % 6 == 0
  end

  def update_auto_run
    unless $game_player.moving?
      $game_player.move_straight(2)
    end
  end

  def update_chase_camera
    # Enhanced Camera can retain a previous focus target. Follow Player's
    # interpolated coordinate explicitly so she cannot leave the viewport.
    $game_map.set_display_pos($game_player.real_x - 10,
      $game_player.real_y - 8)
  end

  def configure_runner(character)
    character.instance_variable_set(:@move_speed, 5)
    character.instance_variable_set(:@move_frequency, 6)
    character.instance_variable_set(:@step_anime, true)
  end

  def start_qte
    @qte = Array.new(QTE_LENGTH) { QTE_INPUTS[rand(QTE_INPUTS.size)] }
    @qte_index = 0
    @qte_timer = QTE_WINDOW
    @obstacle_bag = @obstacles.shuffle if @obstacle_bag.empty?
    @active_obstacle = @obstacle_bag.shift
    @encounters_seen += 1 if @active_obstacle
    if @active_obstacle
      @active_obstacle.transparent = false
      @active_obstacle.give_light(CLONE_LIGHT_ID)
      @active_obstacle.balloon_id = 1
      @active_obstacle.moveto($game_player.x,
        ($game_player.y + 10) % $game_map.height)
      @active_obstacle.set_direction(8)
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
    target_y = ($game_player.y + offset) % $game_map.height
    @active_obstacle.moveto($game_player.x,target_y)
    @active_obstacle.set_direction(8)
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
    $game_player.set_direction(2)
    char_effect(0, "Swing")
    @active_obstacle.moveto($game_player.x,
      ($game_player.y + 2) % $game_map.height) if @active_obstacle
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
    dx, dy = [[-8,-5],[8,-5],[-10,1],[10,1],[-7,6],[7,6]][rand(6)]
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

  def update_monster_anchor
    return unless @monster
    progress = [@timer.to_f / CHASE_DURATION, 1.0].min
    distance = 4.0 - (4.0 - CHASE_END_DISTANCE) * progress
    target_y = $game_map.round_y(($game_player.y - distance).floor)
    target_real_y = $game_player.real_y - distance
    # Copy the same interpolated motion source used by the camera. Directly
    # setting @real_y preserves sub-tile movement; moveto would snap per tile.
    @monster.instance_variable_set(:@x, $game_player.x)
    @monster.instance_variable_set(:@real_x, $game_player.real_x)
    @monster.instance_variable_set(:@y, target_y)
    @monster.instance_variable_set(:@real_y, target_real_y)
    @monster.set_direction(2)
  end

  def caught
    @finished = true
    @monster.moveto($game_player.x,
      ($game_player.y - 1) % $game_map.height)
    RPG::SE.new("Monster3", 90, 80).play
    $game_map.screen.start_shake(10, 8, 45)
    dispose
    SceneManager.goto(Scene_Gameover)
  end

  def finish_chase
    @finished = true
    $game_switches[CHASE_SWITCH_CLEARED] = true
    hide_obstacles
    @monster.transparent = true if @monster
    $game_player.drop_light
    # Keep the chase darkness intact until Scene_Map's black transfer begins.
    # Brightening KUL here exposes one fully lit frame before fadeout.
    $game_map.shadows.set_opacity(185)
    RPG::SE.new("Saint5", 80, 110).play
    dispose
    $game_player.reserve_transfer(REVEAL_MAP_ID, 4, 4, 2)
    $game_temp.fade_type = 0
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
    return if @disposed
    @disposed = true
    char_effect(0, "Clear") if @action_kind
    $game_system.menu_disabled = @old_menu_disabled unless @old_menu_disabled.nil?
    @old_menu_disabled = nil
    restore_runner($game_player, @old_player_speed, @old_player_frequency,
      @old_player_step_anime)
    restore_runner(@monster, @old_monster_speed, @old_monster_frequency,
      @old_monster_step_anime) if @monster
    @monster.instance_variable_set(:@through, @old_monster_through) if
      @monster && !@old_monster_through.nil?
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
    @atlantis_route_map_id = $game_map.map_id
    setup_atlantis_route_managers
  end

  def setup_atlantis_route_managers
    if $game_map.map_id == AtlantisMirrorRoute::MIRROR_MAP_ID
      @atlantis_mirror_manager = AtlantisMirrorManager.new(self)
    end
    if [25,29,34].include?($game_map.map_id)
      @atlantis_monster_manager=AtlantisMonsterManager.new(self)
    end
  end

  def dispose_atlantis_route_managers
    @atlantis_mirror_manager.dispose if @atlantis_mirror_manager
    @atlantis_mirror_manager = nil
    @atlantis_monster_manager.dispose if @atlantis_monster_manager
    @atlantis_monster_manager = nil
    @atlantis_chase_manager.dispose if @atlantis_chase_manager
    @atlantis_chase_manager = nil
  end

  def refresh_atlantis_route_managers
    return if @atlantis_route_map_id == $game_map.map_id
    # VX Ace transfers maps inside the existing Scene_Map. Any manager that
    # keeps Game_Event references must therefore be rebound explicitly.
    dispose_atlantis_route_managers
    @atlantis_route_map_id = $game_map.map_id
    setup_atlantis_route_managers
  end

  alias wcf_atlantis_mirror_update update
  def update
    wcf_atlantis_mirror_update
    refresh_atlantis_route_managers
    @atlantis_mirror_manager.update if @atlantis_mirror_manager
    @atlantis_chase_manager.update if @atlantis_chase_manager
    # Chase updates the event's interpolated anchor first; render afterwards
    # so the large monster atlas never trails one frame behind Hải Quỳ.
    @atlantis_monster_manager.update if @atlantis_monster_manager
  end

  alias wcf_atlantis_mirror_terminate terminate
  def terminate
    dispose_atlantis_route_managers
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

  def atlantis_monster_mode(event_id,mode)
    @atlantis_monster_manager.set_mode(event_id,mode) if @atlantis_monster_manager
  end

  def atlantis_monster_shatter(event_id,duration=90)
    @atlantis_monster_manager.shatter(event_id,duration) if
      @atlantis_monster_manager
  end
end

class Game_Interpreter
  CLONE_GRAB_SLOTS = [[-1,-1],[0,-1],[1,-1],[-1,0],[1,0],
    [-1,1],[0,1],[1,1],[0,0],[-1,0],[1,0]]

  def atlantis_paulie_high_drop(event_id=3)
    event = $game_map.events[event_id]
    scene = SceneManager.scene
    spriteset = scene.instance_variable_get(:@spriteset) rescue nil
    viewport = spriteset && spriteset.instance_variable_get(:@viewport1)
    return unless event && viewport
    original_oy = viewport.oy
    event.opacity = 0
    overlay = Sprite.new
    overlay.bitmap = Cache.character("$OniOnii_landing")
    frame_w = overlay.bitmap.width / 3
    frame_h = overlay.bitmap.height / 4
    overlay.ox = frame_w / 2
    overlay.oy = frame_h
    overlay.x = Graphics.width / 2
    overlay.y = -frame_h
    overlay.z = 450
    overlay.src_rect.set(0, 0, frame_w, frame_h)
    overlay.visible = false
    camera_rise = 400
    begin
      # Camera rises far above the confrontation; map characters leave frame.
      48.times do |frame|
        rate = (frame + 1) / 48.0
        eased = rate * rate * (3.0 - 2.0 * rate)
        viewport.oy = original_oy - (camera_rise * eased).round
        Fiber.yield
      end
      # Paulie falls into the high shot while looping row 1's three frames.
      overlay.visible = true
      72.times do |frame|
        rate = (frame + 1) / 72.0
        overlay.y = -frame_h + (175 + frame_h) * rate
        overlay.src_rect.set((frame / 6 % 3) * frame_w, 0,
          frame_w, frame_h)
        Fiber.yield
      end
      # Hold the high-altitude shot to sell the unusually long drop.
      72.times do |frame|
        overlay.src_rect.set((frame / 7 % 3) * frame_w, 0,
          frame_w, frame_h)
        Fiber.yield
      end
      final_x = event.screen_x + viewport.rect.x - viewport.ox
      final_y = event.screen_y + viewport.rect.y - original_oy
      start_y = overlay.y
      # Paulie and camera descend together back to Hải Quỳ and the monster.
      72.times do |frame|
        rate = (frame + 1) / 72.0
        eased = rate * rate * (3.0 - 2.0 * rate)
        viewport.oy = original_oy - (camera_rise * (1.0 - eased)).round
        overlay.x = Graphics.width / 2 + (final_x - Graphics.width / 2) * eased
        overlay.y = start_y + (final_y - start_y) * eased
        overlay.src_rect.set((frame / 5 % 3) * frame_w, 0,
          frame_w, frame_h)
        Fiber.yield
      end
      viewport.oy = original_oy
      overlay.visible = false
      event.set_graphic("$OniOnii_landing", 0)
      event.opacity = 255
      # Uses the dynamic preset backed by Graphics/Lights/small.png so the
      # light follows Paulie during the rest of the confrontation.
      event.give_light("cutscene_actor")
      event.animation_id = 138
      RPG::SE.new("Earth4", 85, 105).play
      $game_map.screen.start_shake(6, 7, 22)
      # Finish rows 2-4 after impact; row 1 was the aerial loop.
      [4,6,8].each do |direction|
        (0..2).each do |pattern|
          event.set_direction(direction)
          event.instance_variable_set(:@pattern, pattern)
          5.times { Fiber.yield }
        end
      end
      character_sprites = spriteset.instance_variable_get(:@character_sprites)
      event_sprite = character_sprites && character_sprites.find do |sprite|
        sprite.instance_variable_get(:@character).equal?(event)
      end
      Fiber.yield
      Fiber.yield while event_sprite && event_sprite.animation?
      event.set_graphic("$OniOnii", 0)
      event.set_direction(2)
      event.instance_variable_set(:@pattern, 1)
    ensure
      begin
        viewport.oy = original_oy if viewport
      rescue
      end
      overlay.dispose if overlay && !overlay.disposed?
    end
  end


  def atlantis_paulie_rejoin_player(event_id=3)
    event = $game_map.events[event_id]
    return unless event
    target_x = [$game_player.x + 2, $game_map.width - 1].min
    target_y = $game_player.y
    event.jump(target_x - event.x, target_y - event.y)
    Fiber.yield while event.jumping?
    event.set_direction(4)
    $game_player.set_direction(6)
  end

  def atlantis_monster_shatter_and_fade(event_id=2,duration=90)
    # Map025 deliberately leaves Map Effects disabled. KUL alone darkens the
    # scene while the monster breaks apart; the normal event Fadeout follows.
    $game_map.shadows.set_opacity(255, duration)
    scene = SceneManager.scene
    scene.atlantis_monster_shatter(event_id, duration) if
      scene.respond_to?(:atlantis_monster_shatter)
  end

  def atlantis_event_teleport(event_id, animation_id=116)
    event = $game_map.events[event_id]
    return unless event
    scene = SceneManager.scene
    spriteset = scene.instance_variable_get(:@spriteset) rescue nil
    character_sprites = spriteset &&
      spriteset.instance_variable_get(:@character_sprites)
    event_sprite = character_sprites && character_sprites.find do |sprite|
      sprite.instance_variable_get(:@character).equal?(event)
    end
    # Paulie has already teleported; leave only the spell effect at his last
    # position instead of keeping the character visible under animation 116.
    event.opacity = 0
    event.animation_id = animation_id
    # Wait for Sprite_Character to consume animation_id, not merely for the
    # Game_Event flag. This prevents opacity changing before the first frame.
    12.times do
      break if event_sprite && event_sprite.animation?
      Fiber.yield
    end
    if event_sprite && event_sprite.animation?
      Fiber.yield while event_sprite.animation?
    else
      animation = $data_animations[animation_id]
      wait_frames = animation ? animation.frame_max * 4 + 1 : 45
      wait_frames.times { Fiber.yield }
    end
    event.opacity = 0
  end

  def atlantis_clone_grab(event_id, slot_index)
    event = $game_map.events[event_id]
    return unless event
    offset = CLONE_GRAB_SLOTS[slot_index % CLONE_GRAB_SLOTS.size]
    target_x = $game_player.x + offset[0]
    target_y = $game_player.y + offset[1]
    commands = [RPG::MoveCommand.new(29, [5]),
      RPG::MoveCommand.new(30, [6]), RPG::MoveCommand.new(37)]
    (event.y - target_y).times { commands << RPG::MoveCommand.new(4) }
    (target_y - event.y).times { commands << RPG::MoveCommand.new(1) }
    (event.x - target_x).times { commands << RPG::MoveCommand.new(2) }
    (target_x - event.x).times { commands << RPG::MoveCommand.new(3) }
    commands << RPG::MoveCommand.new(25)
    commands << RPG::MoveCommand.new(0)
    route = RPG::MoveRoute.new
    route.repeat = false
    route.skippable = true
    route.wait = false
    route.list = commands
    event.force_move_route(route)
  end

  def wait_for_atlantis_clone_grab(first_id=3,last_id=13)
    loop do
      moving = (first_id..last_id).any? do |id|
        event = $game_map.events[id]
        event && (event.move_route_forcing || event.moving?)
      end
      break unless moving
      Fiber.yield
    end
  end

  def atlantis_blast_clones(first_id=3,last_id=13)
    animation = $data_animations.compact.find do |entry|
      entry.name =~ /(Burst|Explosion|Light|Holy|Thunder|Blow)/i
    end
    offsets = [[-8,-5],[8,-5],[-10,0],[10,0],[-7,6],[7,6]]
    (first_id..last_id).each_with_index do |id,index|
      event = $game_map.events[id]
      next unless event
      event.animation_id = animation ? animation.id : 1
      char_effect(id, "Spin")
      dx,dy = offsets[index % offsets.size]
      event.jump(dx,dy)
    end
    RPG::SE.new("sfx_smash", 90, 95).play
    $game_map.screen.start_shake(9, 8, 32)
    32.times { Fiber.yield }
    (first_id..last_id).each do |id|
      event = $game_map.events[id]
      next unless event
      char_effect(id, "Clear")
      event.drop_light
      event.opacity = 0
    end
  end

  def atlantis_monster_enter(event_id=2)
    event = $game_map.events[event_id]
    return unless event
    event.moveto($game_player.x, 0)
    event.opacity = 255
    event.instance_variable_set(:@through, true)
    event.give_light("red")
    char_effect(event_id, "Appear")
    commands = [RPG::MoveCommand.new(29, [4]),
      RPG::MoveCommand.new(30, [6]), RPG::MoveCommand.new(37)]
    5.times { commands << RPG::MoveCommand.new(1) }
    commands << RPG::MoveCommand.new(0)
    route = RPG::MoveRoute.new
    route.repeat = false
    route.skippable = true
    route.wait = false
    route.list = commands
    event.force_move_route(route)
    while event.move_route_forcing || event.moving?
      Fiber.yield
    end
  end

  def mirror_maze_randomize(event_id = @event_id)
    return unless SceneManager.scene_is?(Scene_Map)
    SceneManager.scene.mirror_maze_randomize(event_id)
  end

  def start_atlantis_chase(monster_id = 2, obstacle_ids = [3, 4, 5, 6, 7, 8])
    return unless SceneManager.scene_is?(Scene_Map)
    SceneManager.scene.start_atlantis_chase(monster_id, obstacle_ids)
  end


  def atlantis_monster_mode(event_id=2,mode=:chase)
    return unless SceneManager.scene_is?(Scene_Map)
    SceneManager.scene.atlantis_monster_mode(event_id,mode)
  end
end
