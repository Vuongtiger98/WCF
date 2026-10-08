#==============================================================================
# ** Atlantis Mirror Maze + Chase (playtest implementation)
#==============================================================================

module AtlantisMirrorRoute
  MIRROR_MAP_ID = 28
  CHASE_MAP_ID  = 29
  REVEAL_MAP_ID = 25
  MONSTER_MAP_IDS = [25, 29, 34, 53, 55]

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
  MONSTER_SCALE = 0.72
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
    # The atlas was previously rendered too close to normal character size.
    # Use the same larger scale in the encirclement, chase and confrontation.
    @sprite.zoom_x=@sprite.zoom_y=MONSTER_SCALE
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
  include CHARACTER_EX_EFFECTS_COMMAND

  MAX_DAZE = 4
  MAX_ACTIVE_CLONES = 2
  HIT_GRACE = 90
  CLONE_LIFETIME = 1200
  BARREL_RANGE = 1
  MAZE_START_X = 5
  MAZE_START_Y = 3
  BOULDER_EVENT_ID = 28
  BOULDER_TRIGGER_ID = 29
  BOULDER_END_ID = 37
  GAUNTLET_DOOR_IDS = [38, 39]
  GAUNTLET_BUTTON_ID = 47
  GAUNTLET_TRIGGER_IDS = [48, 49]
  HARD_SPIKE_CYCLE = 144
  HARD_SPIKE_PATTERNS = [
    [0, 18, 36, 54, 72, 90, 108, 126, 0],
    [0, 72, 18, 90, 36, 108, 54, 126, 72],
    [0, 54, 108, 18, 72, 126, 36, 90, 0]
  ]
  CLONE_GRAPHICS = {
    20 => "$Clone12", 21 => "$Clone13", 22 => "$Clone14",
    23 => "$Clone15", 24 => "$Clone16", 25 => "$Clone17"
  }

  def initialize(scene)
    @scene = scene
    @map_id = $game_map.map_id
    @map_effects = $game_map.effects
    @displays = {}
    @mirror_events = {}
    @clone_events = {}
    @spikes = {}
    @boulder = nil
    @boulder_trigger = nil
    @boulder_end = nil
    @gauntlet_doors = []
    @gauntlet_button = nil
    @gauntlet_triggers = []
    @clones = {}
    @daze = 0
    @daze_impact_timer = 0
    @daze_relax_started = false
    @spawn_serial = 0
    @hit_grace = 0
    @recovery_stage = nil
    @recovery_timer = 0
    @old_menu_disabled = nil
    @spike_cycle_origin = Graphics.frame_count
    @disposed = false
    spriteset = scene.instance_variable_get(:@spriteset)
    viewport = spriteset && spriteset.instance_variable_get(:@viewport1)
    $game_map.events.each_value do |event|
      source_event = event.instance_variable_get(:@event)
      next unless source_event
      if source_event.name =~ /^MIRROR-/
        @displays[event.id] = AtlantisMirrorDisplay.new(viewport, event)
        @mirror_events[event.id] = event
      elsif source_event.name.include?("WCF-MAZE-MIRROR")
        # The remade map already draws its mirrors with $Mirror character
        # sheets, so keep those authored sprites instead of stacking the old
        # guong overlay on top of them.
        @mirror_events[event.id] = event
      end
    end
    CLONE_GRAPHICS.keys.each do |event_id|
      @clone_events[event_id] = $game_map.events[event_id]
    end
    prepare_clone_anchors
    prepare_spikes
    prepare_boulder
    prepare_spike_gauntlet
    create_danger_overlay
  end

  def update
    @displays.each_value(&:update)
    @hit_grace -= 1 if @hit_grace > 0
    update_recovery
    update_daze_relaxation
    update_danger_overlay
    update_boulder
    update_spike_gauntlet
    return if recovering?
    update_spikes
    return if recovering? || gauntlet_cinematic?
    @clones.keys.each { |event_id| update_clone(event_id) }
  end

  def randomize(event_id)
    display = @displays[event_id]
    if display
      display.randomize
      display.flash
    end
    RPG::SE.new("Darkness2", 65, 120).play
  end

  # Called by the new floor sensors. The old one-shot scare choreography has
  # deliberately been removed: the mirror now warns the player, then releases
  # a real roaming clone from its own tile.
  def spawn(mirror_id, clone_id, kind, sensor_id)
    return if @disposed
    hide_clone(clone_id) if @clones[clone_id]
    while @clones.size >= MAX_ACTIVE_CLONES
      oldest_id = @clones.min_by { |_id, data| data[:serial] }[0]
      hide_clone(oldest_id)
    end
    mirror = @mirror_events[mirror_id]
    clone = @clone_events[clone_id]
    sensor = $game_map.events[sensor_id]
    return unless mirror && clone && sensor
    kind = kind.to_sym
    # The sensor only decides *when* the scare begins.  Its authored position
    # must never become the clone's landing position: designers are free to
    # move/copy sensors farther down the corridor without making a clone spawn
    # on top of the player.
    target = clone_landing(sensor, mirror)
    return unless target
    stop_clone(clone)
    clone.moveto(mirror.x, mirror.y)
    clone.set_graphic(CLONE_GRAPHICS[clone_id] || "$Clone12", 0)
    clone.set_direction(direction_from_delta(target[0] - mirror.x,
      target[1] - mirror.y))
    clone.instance_variable_set(:@pattern, 1)
    clone.instance_variable_set(:@move_speed, kind == :pursuer ? 4 : 3)
    clone.instance_variable_set(:@move_frequency, 6)
    clone.instance_variable_set(:@walk_anime, true)
    clone.instance_variable_set(:@step_anime, true)
    clone.instance_variable_set(:@through, true)
    clone.opacity = 0
    clone.give_light("atlantis_clone")
    mirror.give_light(kind == :watcher ? "atlantis_eerie_violet" :
      "atlantis_eerie_blue")
    mirror.balloon_id = kind == :watcher ? 2 : 1
    randomize(mirror_id)
    @spawn_serial += 1
    @clones[clone_id] = {
      :kind => kind, :stage => :warning, :timer => 22,
      :life => CLONE_LIFETIME, :mirror_id => mirror_id,
      :target_x => target[0], :target_y => target[1],
      :path_tick => 0, :watched => false, :serial => @spawn_serial
    }
  end

  def clone_touch(event_id)
    state = @clones[event_id]
    return false unless state && state[:stage] == :active
    return false unless increase_daze(:clone)
    hide_clone(event_id)
    true
  end

  def increase_daze(source)
    return false if @hit_grace > 0 || recovering? || gauntlet_cinematic?
    @hit_grace = HIT_GRACE
    @daze = [@daze + 1, MAX_DAZE].min
    pitch = case source
    when :spike then 120
    when :boulder then 70
    else 75 + @daze * 8
    end
    RPG::SE.new("Darkness2", 75, pitch).play
    $game_player.balloon_id = @daze >= MAX_DAZE ? 11 : 6
    color = case source
    when :spike then Color.new(235, 45, 30, 175)
    when :boulder then Color.new(255, 120, 35, 210)
    else Color.new(120, 80, 190, 165)
    end
    $game_map.screen.start_flash(color, 20)
    # Keep the physical jolt strong but brief; the map effect below performs
    # the longer, smooth relaxation instead of sustaining a harsh shake.
    shake_power = [[5 + @daze, 9].min, 6].max
    $game_map.screen.start_shake(shake_power, 9, 10 + @daze * 2)
    start_daze_impact(source)
    begin_recovery if @daze >= MAX_DAZE
    true
  end

  def update_clone(event_id)
    state = @clones[event_id]
    clone = @clone_events[event_id]
    return hide_clone(event_id) unless state && clone
    case state[:stage]
    when :warning
      state[:timer] -= 1
      emerge_clone(clone, state) if state[:timer] <= 0
    when :landing
      activate_clone(clone, state) unless clone.jumping?
    when :active
      state[:life] -= 1
      return hide_clone(event_id) if state[:life] <= 0
      barrel = nearby_lit_barrel(clone)
      return explode_clone(event_id, barrel) if barrel
      return if clone_reached_player?(clone) && clone_touch(event_id)
      update_watcher(clone, state) if state[:kind] == :watcher
    when :exploding
      state[:timer] -= 1
      clone.opacity = [state[:timer] * 14, 255].min
      hide_clone(event_id) if state[:timer] <= 0
    end
  end

  def emerge_clone(clone, state)
    clone.opacity = 255
    execute_char_effect(clone, "Appear")
    RPG::SE.new("Darkness2", 70, state[:kind] == :watcher ? 85 : 115).play
    $game_map.screen.start_shake(3, 6, 14)
    clone.jump(state[:target_x] - clone.x, state[:target_y] - clone.y)
    state[:stage] = :landing
  end

  def activate_clone(clone, state)
    clone.instance_variable_set(:@through, false)
    clone.instance_variable_set(:@priority_type, 1)
    clone.instance_variable_set(:@trigger, 2)
    clone.turn_toward_player
    state[:stage] = :active
    if state[:kind] == :pursuer
      clone.setup_chase($game_player, 12)
    else
      stop_clone(clone)
      clone.balloon_id = 2
    end
    mirror = @mirror_events[state[:mirror_id]]
    mirror.drop_light if mirror
  end

  def update_watcher(clone, state)
    watched = player_looking_at?(clone)
    if watched
      if !state[:watched]
        clone.balloon_id = 3
        state[:watched] = true
      end
      stop_forced_route(clone)
      return
    end
    state[:watched] = false
    state[:path_tick] -= 1
    return if state[:path_tick] > 0 || clone.moving? ||
      clone.move_route_forcing
    state[:path_tick] = 18
    clone.goto_character($game_player, true)
  end

  def player_looking_at?(clone)
    dx = clone.x - $game_player.x
    dy = clone.y - $game_player.y
    return false if dx.abs + dy.abs > 10
    case $game_player.direction
    when 2 then dy > 0 && dy.abs >= dx.abs
    when 4 then dx < 0 && dx.abs >= dy.abs
    when 6 then dx > 0 && dx.abs >= dy.abs
    when 8 then dy < 0 && dy.abs >= dx.abs
    else false
    end
  end

  def nearby_lit_barrel(clone)
    $game_map.events.values.find do |event|
      source = event.instance_variable_get(:@event)
      next false unless source && source.name.include?("WCF-MAZE-BARREL")
      next false if $game_self_switches[[@map_id, event.id, "A"]]
      (event.x - clone.x).abs + (event.y - clone.y).abs <= BARREL_RANGE
    end
  end

  def explode_clone(event_id, barrel)
    return unless barrel
    state = @clones[event_id]
    clone = @clone_events[event_id]
    return unless state && clone && state[:stage] == :active
    $game_self_switches[[@map_id, barrel.id, "A"]] = true
    barrel.drop_light
    barrel.refresh
    stop_clone(clone)
    clone.instance_variable_set(:@through, true)
    state[:stage] = :exploding
    state[:timer] = 18
    execute_char_effect(clone, "Spin")
    RPG::SE.new("sfx_smash", 85, 110).play
    $game_map.screen.start_flash(Color.new(255, 150, 55, 180), 18)
    $game_map.screen.start_shake(7, 8, 24)
    @daze = [@daze - 1, 0].max
    @daze_impact_timer = 0
    @daze_relax_started = false
    apply_daze_effects
  end

  def clone_reached_player?(clone)
    dx = $game_player.x - clone.x
    dy = $game_player.y - clone.y
    distance = dx.abs + dy.abs
    return true if distance == 0
    return false unless distance == 1
    direction = if dx > 0
      6
    elsif dx < 0
      4
    elsif dy > 0
      2
    else
      8
    end
    $game_map.passable?(clone.x, clone.y, direction) &&
      $game_map.passable?($game_player.x, $game_player.y, 10 - direction)
  end

  def clone_landing(_sensor, mirror)
    reserved = @clones.values.map do |state|
      [state[:target_x], state[:target_y]]
    end
    # Prefer the tile directly in front of the mirror graphic, then try the
    # other three adjacent tiles.  Never fall back to the sensor tile.
    directions = [mirror.direction, 2, 4, 6, 8].uniq
    candidates = directions.map do |direction|
      [$game_map.round_x_with_direction(mirror.x, direction),
       $game_map.round_y_with_direction(mirror.y, direction)]
    end
    # A sensor may release two clones from the same mirror.  Diagonal cells
    # still touch the mirror graphic and provide additional valid exits where
    # the parallax corridor leaves only one cardinal tile open.
    candidates.concat([[-1, -1], [1, -1], [-1, 1], [1, 1]].map do |dx, dy|
      [mirror.x + dx, mirror.y + dy]
    end)
    candidates.uniq!
    candidates.find do |x, y|
      next false unless $game_map.valid?(x, y)
      next false unless $game_map.check_passage(x, y, 0x0f)
      next false if reserved.include?([x, y])
      # Leave at least one tile of reaction distance.  This also prevents a
      # newly emerged clone from immediately invoking the contact handler.
      next false if (x - $game_player.x).abs +
        (y - $game_player.y).abs <= 1
      $game_map.events_xy_nt(x, y).none? { |event| event.normal_priority? }
    end
  end

  def direction_from_delta(dx, dy)
    return dx > 0 ? 6 : 4 if dx.abs > dy.abs
    dy > 0 ? 2 : 8
  end

  def stop_forced_route(clone)
    clone.process_route_end if clone.move_route_forcing
  end

  def stop_clone(clone)
    clone.instance_variable_set(:@target_object, nil)
    stop_forced_route(clone)
  end

  def hide_clone(event_id)
    state = @clones.delete(event_id)
    clone = @clone_events[event_id]
    return unless clone
    stop_clone(clone)
    execute_char_effect(clone, "Clear")
    clone.drop_light
    clone.opacity = 0
    clone.set_graphic("", 0)
    clone.instance_variable_set(:@through, true)
    clone.instance_variable_set(:@step_anime, false)
    if state
      mirror = @mirror_events[state[:mirror_id]]
      mirror.drop_light if mirror
    end
  end

  def prepare_clone_anchors
    CLONE_GRAPHICS.keys.each do |event_id|
      clone = @clone_events[event_id]
      next unless clone
      stop_clone(clone)
      clone.drop_light
      clone.opacity = 0
      clone.set_graphic("", 0)
      clone.instance_variable_set(:@through, true)
    end
  end

  def prepare_spikes
    spike_events = $game_map.events.values.select do |event|
      source = event.instance_variable_get(:@event)
      page = source && source.instance_variable_get(:@pages).first
      graphic = page && page.instance_variable_get(:@graphic)
      graphic && graphic.instance_variable_get(:@character_name) == "!Other1" &&
        graphic.instance_variable_get(:@character_index) == 4
    end.sort_by { |event| event.x }
    spike_events.each_with_index do |event, index|
      event.instance_variable_set(:@direction_fix, false)
      event.instance_variable_set(:@through, true)
      event.instance_variable_set(:@pattern, 1)
      event.give_light("maze_spike_dim")
      @spikes[event.id] = {:offset => index * 20, :active => false,
        :latched => false, :light => :dim, :event => event}
    end
  end

  def update_spikes
    @spikes.each do |event_id, state|
      event = state[:event]
      next unless event
      if @gauntlet_hard_spikes
        phase = (Graphics.frame_count - @spike_cycle_origin +
          state[:hard_offset].to_i) % HARD_SPIKE_CYCLE
        direction, active = case phase
        when 0...30    then [2, false]
        when 30...42   then [4, true]
        when 42...54   then [6, true]
        when 54...102  then [8, true]
        when 102...114 then [6, true]
        when 114...126 then [4, true]
        else [2, false]
        end
      else
        phase = (Graphics.frame_count - @spike_cycle_origin +
          state[:offset]) % 180
        direction, active = case phase
        when 0...60    then [2, false]
        when 60...72   then [4, true]
        when 72...84   then [6, true]
        when 84...126  then [8, true]
        when 126...138 then [6, true]
        when 138...150 then [4, true]
        else [2, false]
        end
      end
      event.set_direction(direction)
      event.instance_variable_set(:@pattern, 1)
      state[:active] = active
      light = phase >= 60 && phase < 150 ? :warning : :dim
      if light != state[:light]
        event.drop_light
        event.give_light(light == :warning ? "maze_spike_warning" :
          "maze_spike_dim")
        state[:light] = light
      end
      if active && $game_player.pos?(event.x, event.y)
        state[:latched] = true if !state[:latched] && increase_daze(:spike)
      else
        state[:latched] = false
      end
    end
  end

  def prepare_boulder
    @boulder = $game_map.events[BOULDER_EVENT_ID]
    @boulder_trigger = $game_map.events[BOULDER_TRIGGER_ID]
    @boulder_end = $game_map.events[BOULDER_END_ID]
    return unless @boulder && @boulder_trigger && @boulder_end
    @boulder_origin = [@boulder.x, @boulder.y]
    @last_player_position = [$game_player.x, $game_player.y]
    reset_boulder_state
  end

  def reset_boulder_state
    return unless @boulder
    execute_char_effect(@boulder, "Clear")
    @boulder.drop_light
    @boulder.moveto(@boulder_origin[0], @boulder_origin[1]) if
      @boulder_origin
    @boulder.opacity = 0
    @boulder.animation_id = 0
    @boulder.instance_variable_set(:@through, true)
    @boulder.instance_variable_set(:@priority_type, 1)
    @boulder.instance_variable_set(:@direction_fix, false)
    @boulder.instance_variable_set(:@walk_anime, true)
    @boulder.instance_variable_set(:@step_anime, true)
    @boulder.set_direction(4)
    @boulder_state = :idle
    @boulder_hit_player = false
  end

  def start_boulder
    return unless @boulder && @boulder_state == :idle
    @boulder_state = :rolling
    @boulder.opacity = 255
    @boulder.instance_variable_set(:@move_speed,
      $game_player.real_move_speed)
    @boulder.give_light("maze_boulder_warning")
    @boulder.set_direction(4)
    RPG::SE.new("Earth4", 75, 90).play
    $game_map.screen.start_shake(3, 6, 18)
  end

  def update_boulder
    return unless @boulder && @boulder_trigger && @boulder_end
    previous_player = @last_player_position || [$game_player.x,
      $game_player.y]
    case @boulder_state
    when :idle
      start_boulder if $game_player.pos?(@boulder_trigger.x,
        @boulder_trigger.y)
    when :rolling
      previous_boulder = [@boulder.x, @boulder.y]
      @boulder.instance_variable_set(:@move_speed,
        $game_player.real_move_speed)
      @boulder.move_straight(4) unless @boulder.moving?
      if !@boulder_hit_player && boulder_hits_player?(previous_boulder,
                                                     previous_player)
        @boulder_hit_player = true
        @hit_grace = 0
        @daze = MAX_DAZE - 1
        increase_daze(:boulder)
      end
      shatter_boulder if @boulder.pos?(@boulder_end.x, @boulder_end.y)
    when :shattering
      @boulder_shatter_timer -= 1
      @boulder.opacity = [@boulder_shatter_timer * 7, 255].min
      finish_boulder if @boulder_shatter_timer <= 0
    end
    @last_player_position = [$game_player.x, $game_player.y]
  end

  def boulder_hits_player?(previous_boulder, previous_player)
    return true if @boulder.pos?($game_player.x, $game_player.y)
    previous_boulder[0] == $game_player.x &&
      previous_boulder[1] == $game_player.y &&
      @boulder.x == previous_player[0] &&
      @boulder.y == previous_player[1]
  end

  def shatter_boulder
    return unless @boulder_state == :rolling
    @boulder_state = :shattering
    @boulder_shatter_timer = 40
    @boulder.animation_id = 126
    execute_char_effect(@boulder, "Spin")
    RPG::SE.new("sfx_smash", 90, 95).play
    $game_map.screen.start_flash(Color.new(220, 190, 140, 150), 16)
    $game_map.screen.start_shake(7, 8, 24)
  end

  def finish_boulder
    execute_char_effect(@boulder, "Clear")
    @boulder.drop_light
    @boulder.opacity = 0
    @boulder_state = :spent
  end

  def prepare_spike_gauntlet
    @gauntlet_doors = GAUNTLET_DOOR_IDS.map do |event_id|
      $game_map.events[event_id]
    end.compact
    @gauntlet_button = $game_map.events[GAUNTLET_BUTTON_ID]
    @gauntlet_triggers = GAUNTLET_TRIGGER_IDS.map do |event_id|
      $game_map.events[event_id]
    end.compact
    @gauntlet_old_menu_disabled = nil
    reset_spike_gauntlet
  end

  def reset_spike_gauntlet
    unlock_gauntlet_input
    @gauntlet_state = :idle
    @gauntlet_timer = 0
    @gauntlet_hard_spikes = false
    @gauntlet_pattern_index = nil
    @spikes.each_value { |state| state[:hard_offset] = nil }
    @gauntlet_doors.each do |door|
      execute_char_effect(door, "Clear")
      door.drop_light
      door.opacity = 255
      door.instance_variable_set(:@direction_fix, false)
      door.instance_variable_set(:@priority_type, 1)
      door.instance_variable_set(:@through, true)
      door.set_direction(8)
    end
    return unless @gauntlet_button
    execute_char_effect(@gauntlet_button, "Clear")
    @gauntlet_button.drop_light
    @gauntlet_button.opacity = 0
    @gauntlet_button.instance_variable_set(:@direction_fix, false)
    @gauntlet_button.instance_variable_set(:@priority_type, 0)
    @gauntlet_button.instance_variable_set(:@through, true)
    @gauntlet_button.set_direction(2)
  end

  def update_spike_gauntlet
    return unless @gauntlet_doors.length == GAUNTLET_DOOR_IDS.length &&
      @gauntlet_button &&
      @gauntlet_triggers.length == GAUNTLET_TRIGGER_IDS.length
    case @gauntlet_state
    when :idle
      begin_spike_gauntlet if @gauntlet_triggers.any? do |trigger|
        $game_player.pos?(trigger.x, trigger.y)
      end
    when :closing
      update_door_animation(false)
    when :camera_to_button
      advance_gauntlet_timer(:camera_back_from_button) do
        focus_gauntlet_camera($game_player, 42)
      end
    when :camera_back_from_button
      advance_gauntlet_timer(:active) { unlock_gauntlet_input }
    when :active
      begin_gauntlet_button_press if gauntlet_button_pressed?
    when :pressing
      update_button_animation
    when :camera_to_door
      advance_gauntlet_timer(:opening) do
        @gauntlet_timer = 18
        RPG::SE.new("sfx_doorlock", 80, 115).play
      end
    when :opening
      update_door_animation(true)
    when :camera_back_from_door
      advance_gauntlet_timer(:complete) { unlock_gauntlet_input }
    end
  end

  def begin_spike_gauntlet
    lock_gauntlet_input
    $game_player.balloon_id = 1
    @gauntlet_state = :closing
    @gauntlet_timer = 18
    @gauntlet_doors.each do |door|
      door.instance_variable_set(:@through, false)
      door.give_light("maze_door_lock")
    end
    RPG::SE.new("sfx_doorlock", 85, 90).play
    $game_map.screen.start_shake(3, 7, 16)
  end

  def update_door_animation(opening)
    direction = case @gauntlet_timer
    when 18 then opening ? 4 : 6
    when 12 then opening ? 6 : 4
    when 6  then opening ? 8 : 2
    end
    @gauntlet_doors.each { |door| door.set_direction(direction) } if direction
    @gauntlet_timer -= 1
    return unless @gauntlet_timer <= 0
    if opening
      finish_opening_gauntlet
    else
      reveal_gauntlet_button
    end
  end

  def reveal_gauntlet_button
    select_hard_spike_pattern
    @gauntlet_button.opacity = 255
    @gauntlet_button.instance_variable_set(:@priority_type, 1)
    @gauntlet_button.instance_variable_set(:@through, false)
    @gauntlet_button.set_direction(2)
    @gauntlet_button.give_light("maze_button_target")
    execute_char_effect(@gauntlet_button, "Appear")
    @gauntlet_button.balloon_id = 1
    RPG::SE.new("Decision2", 75, 125).play
    focus_gauntlet_camera(@gauntlet_button, 48)
    @gauntlet_state = :camera_to_button
    @gauntlet_timer = 60
  end

  def select_hard_spike_pattern
    @gauntlet_pattern_index = rand(HARD_SPIKE_PATTERNS.length)
    pattern = HARD_SPIKE_PATTERNS[@gauntlet_pattern_index]
    @spikes.values.each_with_index do |state, index|
      state[:hard_offset] = pattern[index % pattern.length]
      state[:latched] = false
    end
    @spike_cycle_origin = Graphics.frame_count
    @gauntlet_hard_spikes = true
  end

  def gauntlet_button_pressed?
    return false unless Input.trigger?(:C)
    return true if $game_player.pos?(@gauntlet_button.x,
      @gauntlet_button.y)
    x = $game_map.round_x_with_direction($game_player.x,
      $game_player.direction)
    y = $game_map.round_y_with_direction($game_player.y,
      $game_player.direction)
    @gauntlet_button.pos?(x, y)
  end

  def begin_gauntlet_button_press
    lock_gauntlet_input
    @gauntlet_state = :pressing
    @gauntlet_timer = 18
    RPG::SE.new("Decision2", 85, 90).play
  end

  def update_button_animation
    direction = case @gauntlet_timer
    when 18 then 4
    when 12 then 6
    when 6  then 8
    end
    @gauntlet_button.set_direction(direction) if direction
    @gauntlet_timer -= 1
    return unless @gauntlet_timer <= 0
    @gauntlet_button.drop_light
    @gauntlet_button.instance_variable_set(:@through, true)
    focus_gauntlet_camera(@gauntlet_doors.first, 48)
    @gauntlet_state = :camera_to_door
    @gauntlet_timer = 60
  end

  def finish_opening_gauntlet
    @gauntlet_doors.each do |door|
      door.drop_light
      door.instance_variable_set(:@through, true)
      door.set_direction(8)
    end
    focus_gauntlet_camera($game_player, 42)
    @gauntlet_state = :camera_back_from_door
    @gauntlet_timer = 54
  end

  def advance_gauntlet_timer(next_state)
    @gauntlet_timer -= 1
    return unless @gauntlet_timer <= 0
    @gauntlet_state = next_state
    @gauntlet_timer = next_state.to_s.include?("camera_back") ? 54 : 0
    yield if block_given?
  end

  def focus_gauntlet_camera(character, frames)
    $game_map.ms_ecam_target = nil
    $game_map.ms_ecam_ignore_player = true
    $game_map.ms_ecam_go_to(character.x, character.y, frames)
  end

  def lock_gauntlet_input
    if @gauntlet_old_menu_disabled.nil?
      @gauntlet_old_menu_disabled = $game_system.menu_disabled
    end
    $game_system.menu_disabled = true
  end

  def unlock_gauntlet_input
    unless @gauntlet_old_menu_disabled.nil?
      $game_system.menu_disabled = @gauntlet_old_menu_disabled
    end
    @gauntlet_old_menu_disabled = nil
    $game_map.ms_ecam_target = nil
    $game_map.ms_ecam_ignore_player = false
  end

  def gauntlet_cinematic?
    [:closing, :camera_to_button, :camera_back_from_button, :pressing,
     :camera_to_door, :opening, :camera_back_from_door].include?(
       @gauntlet_state)
  end

  def input_locked?
    recovering? || gauntlet_cinematic?
  end

  def create_danger_overlay
    @danger_overlay = Sprite.new
    @danger_overlay.bitmap = Bitmap.new(Graphics.width, Graphics.height)
    18.times do |index|
      alpha = 210 - index * 11
      color = Color.new(220, 0, 15, [alpha, 20].max)
      @danger_overlay.bitmap.fill_rect(index * 2, index * 2,
        Graphics.width - index * 4, 2, color)
      @danger_overlay.bitmap.fill_rect(index * 2,
        Graphics.height - index * 2 - 2,
        Graphics.width - index * 4, 2, color)
      @danger_overlay.bitmap.fill_rect(index * 2, index * 2,
        2, Graphics.height - index * 4, color)
      @danger_overlay.bitmap.fill_rect(Graphics.width - index * 2 - 2,
        index * 2, 2, Graphics.height - index * 4, color)
    end
    @danger_overlay.z = 180
    @danger_overlay.blend_type = 1
    @danger_overlay.opacity = 0
  end

  def update_danger_overlay
    return unless @danger_overlay && !@danger_overlay.disposed?
    if recovering?
      @danger_overlay.opacity = $game_map.screen.brightness
    elsif @daze == MAX_DAZE - 1
      pulse = (Math.sin(Graphics.frame_count / 11.0) + 1.0) / 2.0
      @danger_overlay.opacity = (115 + pulse * 105).to_i
    else
      @danger_overlay.opacity = 0
    end
  end

  # Each hit has a short, forceful camera impact.  After twelve frames the
  # effect eases back to a mild state that still communicates the accumulated
  # daze count without leaving the player under constant heavy distortion.
  def start_daze_impact(source)
    @daze_impact_timer = 54
    @daze_relax_started = false
    effects = @map_effects
    effects.active = true
    effects.refresh_rate = 60
    strength = [@daze, 3].min
    strength += 1 if source == :boulder
    effects.setup_blur(4, 1, 0, 5)
    effects.set_gaussian_blur([strength - 1, 0].max, 5)
    effects.set_radial_blur(1 + strength, 5)
    effects.set_zoom_blur(103 + strength * 3, 5)
    effects.set_wave(3 + strength * 2, 120, 420, 5)
    effects.set_tone(-12 * strength, -8 * strength, -5 * strength,
      12 * strength, 5)
    effects.set_color(24 * strength, 0, 8 * strength,
      18 * strength, 5)
  end

  def update_daze_relaxation
    return unless @daze_impact_timer && @daze_impact_timer > 0
    @daze_impact_timer -= 1
    if !@daze_relax_started && @daze_impact_timer <= 42
      @daze_relax_started = true
      apply_daze_effects(36)
    end
  end

  def apply_daze_effects(duration = 24)
    effects = @map_effects
    effects.active = true
    effects.refresh_rate = 60
    case @daze
    when 0
      effects.set_wave(0, 180, 360, duration)
      effects.set_tone(0, 0, 0, 0, duration)
      effects.set_color(0, 0, 0, 0, duration)
      effects.set_gaussian_blur(0, duration)
      effects.set_radial_blur(0, duration)
      effects.set_zoom_blur(100, duration)
    when 1
      effects.set_wave(0, 180, 300, duration)
      effects.set_tone(-4, -3, -1, 6, duration)
      effects.set_color(8, 0, 3, 4, duration)
      effects.set_gaussian_blur(0, duration)
      effects.set_radial_blur(0, duration)
      effects.set_zoom_blur(100, duration)
    when 2
      effects.set_wave(1, 175, 320, duration)
      effects.set_tone(-8, -6, -3, 12, duration)
      effects.set_color(14, 0, 5, 8, duration)
      effects.set_gaussian_blur(0, duration)
      effects.set_radial_blur(0, duration)
      effects.set_zoom_blur(101, duration)
    else
      effects.set_wave(1, 170, 340, duration)
      effects.set_tone(-12, -8, -5, 18, duration)
      effects.set_color(20, 0, 6, 12, duration)
      effects.set_gaussian_blur(0, duration)
      effects.set_radial_blur(0, duration)
      effects.set_zoom_blur(101, duration)
    end
  end

  def recovering?
    !@recovery_stage.nil?
  end

  def begin_recovery
    return if recovering?
    @recovery_stage = :falling
    @recovery_timer = 24
    @fall_start_angle = $game_player.angle
    @old_menu_disabled = $game_system.menu_disabled
    $game_system.menu_disabled = true
    $game_player.straighten
    $game_map.screen.start_shake(10, 8, 32)
  end

  def update_recovery
    return unless recovering?
    case @recovery_stage
    when :falling
      @recovery_timer -= 1
      progress = (24 - @recovery_timer) / 24.0
      $game_player.angle = @fall_start_angle + 90.0 * progress
      return unless @recovery_timer <= 0
      $game_player.angle = @fall_start_angle + 90.0
      @recovery_stage = :fadeout
      @recovery_timer = 48
      $game_map.screen.start_fadeout(48)
    when :fadeout
      @recovery_timer -= 1
      return unless @recovery_timer <= 0
      reset_maze_state
      @recovery_stage = :fadein
      @recovery_timer = 48
      $game_map.screen.start_fadein(48)
    when :fadein
      @recovery_timer -= 1
      return unless @recovery_timer <= 0
      @recovery_stage = nil
      $game_system.menu_disabled = @old_menu_disabled unless
        @old_menu_disabled.nil?
      @old_menu_disabled = nil
    end
  end

  def reset_maze_state
    @clones.keys.each { |event_id| hide_clone(event_id) }
    @spawn_serial = 0
    @hit_grace = 0
    $game_map.events.each_value do |event|
      source = event.instance_variable_get(:@event)
      next unless source
      if source.name.include?("WCF-MAZE-CLONE-SPAWN-SENSOR")
        $game_self_switches[[@map_id, event.id, "A"]] = false
        event.refresh
      elsif source.name.include?("WCF-MAZE-BARREL")
        $game_self_switches[[@map_id, event.id, "A"]] = false
        event.refresh
        event.give_light("maze_barrel_fire")
      elsif source.name.include?("WCF-MAZE-MIRROR")
        event.drop_light
      end
    end
    @spike_cycle_origin = Graphics.frame_count
    @spikes.each_value do |state|
      event = state[:event]
      next unless event
      state[:active] = false
      state[:latched] = false
      state[:light] = :dim
      event.instance_variable_set(:@direction_fix, false)
      event.set_direction(2)
      event.instance_variable_set(:@pattern, 1)
      event.drop_light
      event.give_light("maze_spike_dim")
    end
    reset_spike_gauntlet
    reset_boulder_state
    @last_player_position = [MAZE_START_X, MAZE_START_Y]
    @daze = 0
    @daze_impact_timer = 0
    @daze_relax_started = false
    apply_daze_effects
    execute_char_effect($game_player, "Clear")
    $game_player.drop_light
    $game_player.give_light("maze_player_amber")
    $game_player.moveto(MAZE_START_X, MAZE_START_Y)
    $game_player.set_direction(2)
    $game_player.center(MAZE_START_X, MAZE_START_Y)
    $game_map.screen.start_flash(Color.new(0, 0, 0, 0), 1)
    $game_map.screen.start_shake(0, 0, 1)
  end

  def reset_daze_effects
    return unless @map_effects
    @daze_impact_timer = 0
    @daze_relax_started = false
    effects = @map_effects
    effects.set_wave(0, 180, 360, 1)
    effects.set_tone(0, 0, 0, 0, 1)
    effects.set_color(0, 0, 0, 0, 1)
    effects.set_gaussian_blur(0, 1)
    effects.set_radial_blur(0, 1)
    effects.set_zoom_blur(100, 1)
  end

  def dispose
    return if @disposed
    @disposed = true
    if recovering?
      execute_char_effect($game_player, "Clear")
      $game_system.menu_disabled = @old_menu_disabled unless
        @old_menu_disabled.nil?
    end
    @clones.keys.each { |event_id| hide_clone(event_id) }
    @spikes.each_value do |state|
      event = state[:event]
      event.drop_light if event
    end
    @boulder.drop_light if @boulder
    @gauntlet_doors.each { |door| door.drop_light } if @gauntlet_doors
    @gauntlet_button.drop_light if @gauntlet_button
    unlock_gauntlet_input
    reset_daze_effects
    @displays.each_value(&:dispose)
    @displays.clear
    if @danger_overlay
      @danger_overlay.bitmap.dispose if @danger_overlay.bitmap &&
        !@danger_overlay.bitmap.disposed?
      @danger_overlay.dispose unless @danger_overlay.disposed?
      @danger_overlay = nil
    end
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
    if AtlantisMirrorRoute::MONSTER_MAP_IDS.include?($game_map.map_id)
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

  def atlantis_mirror_spawn(mirror_id, clone_id, kind, sensor_id)
    @atlantis_mirror_manager.spawn(mirror_id, clone_id, kind, sensor_id) if
      @atlantis_mirror_manager
  end

  def atlantis_mirror_clone_touch(event_id)
    @atlantis_mirror_manager.clone_touch(event_id) if
      @atlantis_mirror_manager
  end

  def atlantis_mirror_recovering?
    @atlantis_mirror_manager && @atlantis_mirror_manager.input_locked?
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

class Game_Player < Game_Character
  alias wcf_atlantis_mirror_movable movable?
  def movable?
    scene = SceneManager.scene
    return false if scene.respond_to?(:atlantis_mirror_recovering?) &&
      scene.atlantis_mirror_recovering?
    wcf_atlantis_mirror_movable
  end
end

class Game_Interpreter
  CLONE_GRAB_SLOTS = [[-1,-1],[0,-1],[1,-1],[-1,0],[1,0],
    [-1,1],[0,1],[1,1],[0,0],[-1,0],[1,0]]

  def atlantis_mirror_spawn(mirror_id, clone_id, kind = :pursuer,
                            sensor_id = @event_id)
    source = $game_map.events[@event_id]
    source_data = source && source.instance_variable_get(:@event)
    sensor_id = @event_id if source_data &&
      source_data.name.include?("WCF-MAZE-CLONE-SPAWN-SENSOR")
    scene = SceneManager.scene
    scene.atlantis_mirror_spawn(mirror_id, clone_id, kind, sensor_id) if
      scene.respond_to?(:atlantis_mirror_spawn)
  end

  def atlantis_mirror_clone_touch(event_id = @event_id)
    scene = SceneManager.scene
    scene.atlantis_mirror_clone_touch(event_id) if
      scene.respond_to?(:atlantis_mirror_clone_touch)
  end

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
      # The atlas contains exactly two aerial frames followed by six landing
      # frames. Keep only the first two frames looping during the fall.
      overlay.visible = true
      72.times do |frame|
        rate = (frame + 1) / 72.0
        overlay.y = -frame_h + (175 + frame_h) * rate
        overlay.src_rect.set((frame / 6 % 2) * frame_w, 0,
          frame_w, frame_h)
        Fiber.yield
      end
      # Hold the high-altitude shot to sell the unusually long drop.
      72.times do |frame|
        overlay.src_rect.set((frame / 7 % 2) * frame_w, 0,
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
        overlay.src_rect.set((frame / 5 % 2) * frame_w, 0,
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
      # Play the six remaining non-empty atlas cells exactly once. The first
      # landing frame is row 1 / column 3; the last is row 3 / column 2.
      [[2,2], [4,0], [4,1], [4,2], [6,0], [6,1]].each do |direction, pattern|
        event.set_direction(direction)
        event.instance_variable_set(:@pattern, pattern)
        5.times { Fiber.yield }
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

  # After the other clones are blown away, one survivor walks back into the
  # shot.  Keeping this on an existing clone event avoids reintroducing the
  # abyss-monster overlay before the chase begins.
  def atlantis_clone_jumpscare_approach(event_id=3)
    event = $game_map.events[event_id]
    return unless event
    char_effect(event_id, "Clear")
    event.moveto($game_player.x, [$game_player.y - 6, 0].max)
    event.set_direction(2)
    event.instance_variable_set(:@through, true)
    event.opacity = 255
    event.give_light("atlantis_clone")
    char_effect(event_id, "Appear")
    commands = [RPG::MoveCommand.new(29, [3]),
      RPG::MoveCommand.new(30, [6]), RPG::MoveCommand.new(37)]
    4.times { commands << RPG::MoveCommand.new(1) }
    commands << RPG::MoveCommand.new(0)
    route = RPG::MoveRoute.new
    route.repeat = false
    route.skippable = true
    route.wait = false
    route.list = commands
    event.force_move_route(route)
    Fiber.yield while event.move_route_forcing || event.moving?
  end

  # Graphics/Pictures/Jumpscare.png is a 3x3 atlas containing eight authored
  # 640x480 frames; the ninth cell is intentionally blank.  Render the atlas
  # directly so RPG Maker does not display the entire 1920x1440 sheet at once.
  def atlantis_play_jumpscare(picture_name="Jumpscare")
    viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    viewport.z = 999
    sprite = Sprite.new(viewport)
    sprite.bitmap = Cache.picture(picture_name)
    frame_width = sprite.bitmap.width / 3
    frame_height = sprite.bitmap.height / 3
    sprite.x = (Graphics.width - frame_width) / 2
    sprite.y = (Graphics.height - frame_height) / 2
    sprite.z = 999
    RPG::SE.new("Monster3", 90, 82).play
    begin
      8.times do |frame|
        column = frame % 3
        row = frame / 3
        sprite.src_rect.set(column * frame_width, row * frame_height,
          frame_width, frame_height)
        hold = frame < 3 ? 6 : (frame < 6 ? 5 : 10)
        hold.times do |tick|
          if frame >= 4
            sprite.x = (Graphics.width - frame_width) / 2 + (tick.even? ? -3 : 3)
          end
          Fiber.yield
        end
      end
      12.times { Fiber.yield }
    ensure
      sprite.dispose if sprite && !sprite.disposed?
      # VX Ace's Viewport exposes #dispose but not #disposed?. This must stay
      # unconditional to avoid the same NoMethodError seen in earlier CG code.
      viewport.dispose if viewport
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
