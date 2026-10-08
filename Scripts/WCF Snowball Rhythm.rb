#==============================================================================
# ** WCF Snowball Rhythm
#------------------------------------------------------------------------------
# Christmas snowball duel: defend against incoming direction-marked snowballs,
# then enter an Audition-style arrow sequence to throw one back.
#==============================================================================

module WCF_SNOWBALL
  PLAYER_HP       = 100
  ENEMY_HP        = 100
  PERFECT_WINDOW  = 12
  MISS_DAMAGE     = 8
  RESULT_VARIABLE = 45
  WINS_VARIABLE   = 46
  ALL_CLEAR_SWITCH = 49

  OPPONENTS = {
    3 => ["Shylvie", "$Shylvie_giangsinh", 88, 7],
    4 => ["Kohi",    "$Kohi_giangsinh",    72, 9],
    5 => ["Leo",     "$Leo_giangsinh",     66, 8],
    6 => ["Hakase",  "$Hakasa_GiangSinh",  80, 8]
  }

  KEYS = [:LEFT, :DOWN, :UP, :RIGHT]
  INPUTS = {
    :LEFT => Input::LEFT, :DOWN => Input::DOWN,
    :UP => Input::UP, :RIGHT => Input::RIGHT
  }
  ARROWS = {:LEFT => "←", :DOWN => "↓", :UP => "↑", :RIGHT => "→"}
  # Rows in $Snow_Attack / $Snow_Defend, from top to bottom:
  # Shylvie, Leo, Hakase, Kohi.
  SNOW_ACTION_ROWS = {3 => 0, 5 => 1, 6 => 2, 4 => 3}
  SNOW_IDLE_SHEETS = {
    3 => "$CV_Snow_Idle", 4 => "$Kohi_Snow_Idle",
    5 => "$Leo_Snow_Idle", 6 => "$Hakase_Snow_idle"
  }
  SNOW_IDLE_ALT_SHEETS = {
    3 => "$CV_Snow_Idle_1", 4 => "$Kohi_Snow_Idle_1",
    5 => "$Leo_Snow_Idle_1", 6 => "$Hakase_Snow_idle_1"
  }

  class << self
    attr_accessor :opponent_id

    def start(opponent_id)
      self.opponent_id = OPPONENTS.has_key?(opponent_id) ? opponent_id : 5
      SceneManager.call(Scene_WCFSnowballRhythm)
    end

    def record_win(opponent_id)
      return unless OPPONENTS.has_key?(opponent_id)
      bit = 1 << (opponent_id - 3)
      $game_variables[WINS_VARIABLE] |= bit
      $game_switches[ALL_CLEAR_SWITCH] = all_cleared?
    end

    def defeated?(opponent_id)
      bit = 1 << (opponent_id - 3)
      ($game_variables[WINS_VARIABLE] & bit) != 0
    end

    def all_cleared?
      ($game_variables[WINS_VARIABLE] & 0x0F) == 0x0F
    end
  end
end

#==============================================================================
# ** Wanderer Christmas layer cutscenes
#------------------------------------------------------------------------------
# The authored images are full-map transparent layers (1440x1344), not
# character sheets.  Each vignette owns its KUL transition: camera movement,
# sprite changes and layer cleanup happen behind black.  The painted action is
# the only map image exposed, and the helper returns to black so dialogue can
# continue without briefly showing the live staging underneath.
#==============================================================================
class Game_Interpreter
  WCF_WANDERER_LAYER_SCENES = {
    :prepare => {
      :frames => ["Wanderer_Party_prepare"],
      :focus => [15, 25], :holds => [90], :loops => 1
    },
    :snowbuild => {
      :frames => ["Wanderer_Party_snowbuild_2",
        "Wanderer_Party_snowbuild_1"],
      :focus => [34, 23], :holds => [10, 10], :loops => 10
    },
    :snowkitchen => {
      :frames => (1..5).map {|id| "Wanderer_Party_snowkitchen_#{id}" },
      :focus => [30, 16], :holds => [8, 8, 8, 8, 24], :loops => 1
    },
    :snowmeet => {
      :frames => (1..5).map {|id| "Wanderer_Party_snowmeet#{id}" },
      :focus => [21, 34], :holds => [8, 8, 8, 8, 24], :loops => 1
    },
    :phuchoi => {
      :frames => ["Wanderer_Party_phuchoi"] +
        (1..6).map {|id| "Wanderer_Party_phuchoi_#{id}" },
      :focus => [18, 24], :holds => [8, 8, 8, 8, 8, 8, 24], :loops => 1
    }
  }

  # $HaiQuy_Snowman contains two painted rows in the first half of a padded
  # 3x4-style canvas: snowman poses in logical row 1 and normal Hải Quỳ in
  # logical row 2. The buried overlay must crop one quarter of the full canvas
  # height; using one half exposes both painted rows at once.
  def wcf_snowman_buried_begin(event_id = 2)
    wcf_snowman_buried_hide
    event = $game_map.events[event_id]
    return unless event
    $game_temp.instance_variable_set(:@wcf_snowman_buried_event_id, event_id)
    followers = $game_player.followers
    @wcf_snowman_followers_visible = followers.visible
    followers.visible = false
    followers.refresh
    # The buried pose replaces both possible Hải Quỳ renderers on Map038:
    # the player and the NPC anchor. Transparency alone is not sufficient
    # because a player refresh can restore the normal character sprite while
    # the custom snowman overlay is still active.
    $game_player.set_graphic("", 0)
    $game_player.transparent = true
    event.set_graphic("", 0)
    event.transparent = true
    scene = SceneManager.scene
    spriteset = scene.respond_to?(:spriteset) ? scene.spriteset : nil
    viewport = spriteset ? spriteset.instance_variable_get(:@viewport1) : nil
    sprite = Sprite.new(viewport)
    sprite.bitmap = Cache.character("$HaiQuy_Snowman")
    sprite.z = event.screen_z + 2
    @wcf_snowman_buried_sprite = sprite
    @wcf_snowman_buried_event = event
    wcf_snowman_buried_frame(0)
    wcf_snowman_buried_update_position
  end

  def wcf_snowman_buried_frame(frame)
    sprite = @wcf_snowman_buried_sprite
    return unless sprite && !sprite.disposed? && sprite.bitmap
    bitmap = sprite.bitmap
    left = bitmap.width * frame / 3
    right = bitmap.width * (frame + 1) / 3
    frame_width = right - left
    frame_height = bitmap.height / 4
    sprite.src_rect.set(left, 0, frame_width, frame_height)
    sprite.ox = frame_width / 2
    sprite.oy = frame_height
  end

  def wcf_snowman_buried_update_position
    sprite = @wcf_snowman_buried_sprite
    event = @wcf_snowman_buried_event
    return unless sprite && !sprite.disposed? && event
    # A page refresh or another cutscene command must never restore either
    # normal Hải Quỳ renderer while the custom snowman overlay is active.
    $game_player.set_graphic("", 0) unless $game_player.character_name.empty?
    $game_player.transparent = true
    event.set_graphic("", 0) unless event.character_name.empty?
    event.transparent = true
    sprite.x = event.screen_x
    sprite.y = event.screen_y
    sprite.z = event.screen_z + 2
  end

  def wcf_snowman_buried_animate
    return unless @wcf_snowman_buried_sprite
    [[0, 8], [1, 18], [2, 36]].each do |frame, duration|
      wcf_snowman_buried_frame(frame)
      duration.times do
        wcf_snowman_buried_update_position
        Fiber.yield
      end
    end
  end

  def wcf_snowman_buried_hide
    sprite = @wcf_snowman_buried_sprite
    sprite.dispose if sprite && !sprite.disposed?
    @wcf_snowman_buried_sprite = nil
    @wcf_snowman_buried_event = nil
    $game_temp.instance_variable_set(:@wcf_snowman_buried_event_id, nil) if $game_temp
    unless @wcf_snowman_followers_visible.nil?
      followers = $game_player.followers
      followers.visible = @wcf_snowman_followers_visible
      followers.refresh
      @wcf_snowman_followers_visible = nil
    end
  end

  # Restore the authored Map038 free-roam composition after a snow-rescue
  # cutscene. Coordinates come from the current map data, so editor changes to
  # event positions remain authoritative. Call this only after the route's
  # free-roam switch has been enabled and its event pages have refreshed.
  def wcf_wanderer_restore_free_roam
    return unless $game_map.map_id == 38
    wcf_snowman_buried_hide
    cast = {
      3 => ["$Shylvie_giangsinh", 0],
      4 => ["$Kohi_giangsinh", 0],
      5 => ["$Leo_giangsinh", 0],
      6 => ["$Hakasa_GiangSinh", 0]
    }
    cast.each do |id, graphic|
      event = $game_map.events[id]
      source = event && event.instance_variable_get(:@event)
      next unless event && source
      event.moveto(source.x, source.y)
      event.set_graphic(graphic[0], graphic[1])
      page = event.instance_variable_get(:@page)
      if page
        event.instance_variable_set(:@through, page.through)
        event.instance_variable_set(:@direction_fix, page.direction_fix)
        event.instance_variable_set(:@walk_anime, page.walk_anime)
        event.instance_variable_set(:@step_anime, page.step_anime)
        event.set_direction(page.graphic.direction)
      end
      event.opacity = 255
      event.transparent = false
    end
    anchor = $game_map.events[2]
    source = anchor && anchor.instance_variable_get(:@event)
    if anchor && source
      anchor.moveto(source.x, source.y)
      anchor.set_graphic("", 0)
      anchor.transparent = true
      anchor.instance_variable_set(:@through, true)
      $game_player.moveto(source.x, source.y)
    end
    $game_player.set_graphic("!$HaiQuy_GiangSinh", 0)
    $game_player.transparent = false
    $game_player.instance_variable_set(:@through, false)
    $game_player.instance_variable_set(:@direction_fix, false)
    $game_player.instance_variable_set(:@walk_anime, true)
    $game_player.instance_variable_set(:@step_anime, false)
    $game_player.set_direction(2)
  end

  def wcf_wanderer_layer_scene(kind)
    return unless $game_map.map_id == 38
    scene = WCF_WANDERER_LAYER_SCENES[kind.to_sym]
    return unless scene
    characters = [$game_player]
    characters.concat((2..6).map {|id| $game_map.events[id] }.compact)
    old_visibility = characters.map {|character| character.transparent }
    $game_map.shadows.set_color(0, 0, 0)
    $game_map.shadows.show
    $game_map.shadows.set_opacity(255)
    wcf_snowman_buried_hide if [:snowmeet, :snowkitchen].include?(kind.to_sym)
    characters.each {|character| character.transparent = true }
    ms_pro_cam_ignore_player(true)
    ms_pro_cam_center_at(scene[:focus][0], scene[:focus][1], 20)
    ms_pro_cam_wait_for_scrolling
    begin
      first = scene[:frames][0]
      layer(38, 2, [first, 0, 0, 255, 180, 0, 0, 0])
      refresh_layers
      $game_map.shadows.set_opacity(0, 24)
      24.times { Fiber.yield }
      scene[:loops].times do |loop_index|
        scene[:frames].each_with_index do |name, index|
          unless loop_index == 0 && index == 0
            layer(38, 2, [name, 0, 0, 255, 180, 0, 0, 0])
            refresh_layers
          end
          scene[:holds][index].times { Fiber.yield }
        end
      end
      $game_map.shadows.set_opacity(255, 24)
      24.times { Fiber.yield }
    ensure
      $game_map.shadows.set_opacity(255)
      del_layer(38, 2)
      characters.each_with_index do |character, index|
        character.transparent = old_visibility[index]
      end
      ms_pro_cam_center_at(14, 21, 20)
      ms_pro_cam_wait_for_scrolling
    end
  end
end

# Hide the standard player/event renderers at the Sprite layer as well as at
# the Game_Character layer. This closes the one-frame/page-refresh gap that
# could expose normal Hải Quỳ underneath the custom snowman sprite.
class Sprite_Character < Sprite_Base
  alias wcf_snowman_guard_update update
  def update
    wcf_snowman_guard_update
    event_id = $game_temp &&
      $game_temp.instance_variable_get(:@wcf_snowman_buried_event_id)
    event = event_id && $game_map ? $game_map.events[event_id] : nil
    # Some saves/projects can still have a follower or compatibility sprite
    # carrying Hải Quỳ's graphic. While the buried overlay is active, every
    # standard Hải Quỳ character renderer must be hidden, not only the direct
    # player and E2 instances.
    name = @character ? @character.character_name.to_s : ""
    hai_quy_graphic = !!(name =~ /HaiQuy|Hai_Quy|Base_HQ/i)
    guarded = event_id &&
      (@character.equal?($game_player) || (event && @character.equal?(event)) ||
       hai_quy_graphic)
    if guarded
      @wcf_snowman_forced_hidden = true
      self.visible = false
    elsif @wcf_snowman_forced_hidden
      @wcf_snowman_forced_hidden = false
      self.visible = true
    end
  end
end

class Scene_WCFSnowballRhythm < Scene_Base
  PLAYER_X = 104
  ENEMY_X  = Graphics.width - 104
  GROUND_Y = Graphics.height - 38

  def start
    super
    @old_bgm = RPG::BGM.last
    RPG::BGM.new("Battle1", 75, 100).play
    @opponent_id = WCF_SNOWBALL.opponent_id || 5
    @opponent = WCF_SNOWBALL::OPPONENTS[@opponent_id]
    @player_hp = WCF_SNOWBALL::PLAYER_HP
    @enemy_hp = WCF_SNOWBALL::ENEMY_HP
    @round = 0
    @perfects = @misses = 0
    @state = :ready
    @state_timer = 80
    @owned_sprites = []
    @effects = []
    @snowflakes = []
    @balloons = []
    @attack_buttons = []
    @animation_sprites = []
    create_background
    create_hud
    create_characters
    create_supporters
    create_snowfall
    set_banner("CHUẨN BỊ!", "Bấm phím mũi tên trên cầu tuyết khi nó gần chạm Hải Quỳ.")
  end

  def terminate
    super
    clear_projectile
    clear_attack_buttons
    clear_finisher_balls
    clear_pattern_notes
    @effects.each { |effect| dispose_custom_sprite(effect[:sprite]) }
    @snowflakes.each { |flake| dispose_custom_sprite(flake) }
    @balloons.each do |balloon|
      balloon[:sprite].dispose unless balloon[:sprite].disposed?
    end
    @animation_sprites.each do |sprite|
      bitmap = sprite.bitmap
      sprite.dispose unless sprite.disposed?
      bitmap.dispose if bitmap && !bitmap.disposed?
    end
    if @orbit_balls
      @orbit_balls.each { |ball| dispose_custom_sprite(ball[:sprite]) }
    end
    [@background, @hud, @banner, @snow_pile].each do |sprite|
      dispose_custom_sprite(sprite)
    end
    @owned_sprites.each { |sprite| sprite.dispose unless sprite.disposed? }
    @old_bgm.replay if @old_bgm
  end

  def update
    super
    update_snowfall
    update_balloons
    update_effects
    update_character_pose
    update_animation_sprites
    case @state
    when :ready         then update_ready
    when :defense       then update_defense
    when :pattern_defense then update_pattern_defense
    when :deflect       then update_deflect
    when :attack_intro  then update_attack_intro
    when :attack_input  then update_attack_input
    when :player_throw  then update_player_throw
    when :shylvie_return then update_shylvie_return
    when :leo_slash     then update_leo_slash
    when :hakase_orbit  then update_hakase_orbit
    when :hakase_push   then update_hakase_push
    when :enemy_finisher then update_enemy_finisher
    when :player_finisher then update_player_finisher
    when :result        then update_result
    end
    locked = [:result, :enemy_finisher, :player_finisher].include?(@state)
    finish_battle(0, "ĐÃ DỪNG TRẬN") if Input.trigger?(Input::B) && !locked
  end

  def create_background
    bitmap = Bitmap.new(Graphics.width, Graphics.height)
    12.times do |i|
      bitmap.fill_rect(0, i * 32, Graphics.width, 32,
        Color.new(18 + i * 4, 45 + i * 6, 78 + i * 7))
    end
    bitmap.fill_rect(0, 350, Graphics.width, Graphics.height - 350,
                     Color.new(224, 239, 249))
    bitmap.fill_rect(0, 350, Graphics.width, 4, Color.new(255, 255, 255))
    @background = custom_sprite(bitmap, 0)
  end

  def create_hud
    @hud = custom_sprite(Bitmap.new(Graphics.width, 92), 80)
    @banner_bitmap = Bitmap.new(Graphics.width, 68)
    @banner = custom_sprite(@banner_bitmap, 82)
    @banner.y = 92
    refresh_hud
  end

  def refresh_hud
    bitmap = @hud.bitmap
    bitmap.clear
    bitmap.fill_rect(0, 0, Graphics.width, 92, Color.new(6, 22, 42, 225))
    bitmap.fill_rect(0, 88, Graphics.width, 4, Color.new(96, 185, 235, 220))
    bitmap.font.size = 22
    bitmap.font.bold = true
    bitmap.font.color = Color.new(220, 238, 255)
    bitmap.draw_text(18, 8, 230, 28, "Hải Quỳ")
    bitmap.draw_text(Graphics.width - 248, 8, 230, 28, @opponent[0], 2)
    draw_hp_bar(bitmap, 18, 42, 230, @player_hp, Color.new(55, 190, 235))
    draw_hp_bar(bitmap, Graphics.width - 248, 42, 230, @enemy_hp,
                Color.new(245, 105, 135))
    bitmap.font.size = 17
    bitmap.font.bold = false
    bitmap.draw_text(255, 12, 130, 24, "LƯỢT #{@round}", 1)
    bitmap.draw_text(235, 43, 170, 24,
      "PERFECT #{@perfects}   MISS #{@misses}", 1)
  end

  def draw_hp_bar(bitmap, x, y, width, hp, color)
    bitmap.fill_rect(x, y, width, 18, Color.new(20, 30, 54))
    fill = ((width - 4) * hp / 100.0).to_i
    bitmap.fill_rect(x + 2, y + 2, fill, 14, color)
    bitmap.font.size = 15
    bitmap.font.color = Color.new(255, 255, 255)
    bitmap.draw_text(x, y - 1, width, 20, "#{hp}/100", 1)
  end

  def set_banner(title, subtitle = "")
    bitmap = @banner_bitmap
    bitmap.clear
    bitmap.fill_rect(0, 0, Graphics.width, 68, Color.new(0, 0, 0, 115))
    bitmap.font.bold = true
    bitmap.font.size = 26
    bitmap.font.color = Color.new(255, 226, 90)
    bitmap.draw_text(0, 3, Graphics.width, 32, title, 1)
    bitmap.font.bold = false
    bitmap.font.size = 17
    bitmap.font.color = Color.new(225, 240, 255)
    bitmap.font.size -= 1 while bitmap.font.size > 12 &&
      bitmap.text_size(subtitle).width > Graphics.width - 20
    bitmap.draw_text(0, 35, Graphics.width, 26, subtitle, 1)
  end

  def character_sprite(name, x, y, mirror)
    sprite = Sprite.new
    sprite.bitmap = Cache.character(name)
    single = name[0, 1] == "$" || name[0, 2] == "!$"
    columns = single ? 3 : 12
    rows = single ? 4 : 8
    width = sprite.bitmap.width / columns
    height = sprite.bitmap.height / rows
    sprite.src_rect.set(width, 0, width, height)
    sprite.ox = width / 2
    sprite.oy = height
    sprite.x = x
    sprite.y = y
    sprite.mirror = mirror
    sprite.z = 30
    @owned_sprites << sprite
    sprite
  end

  def create_characters
    @player_home = [PLAYER_X, GROUND_Y]
    @enemy_home = [ENEMY_X, GROUND_Y]
    @player_sprite = character_sprite("!$HaiQuy_GiangSinh", PLAYER_X, GROUND_Y, false)
    @enemy_sprite = character_sprite(@opponent[1], ENEMY_X, GROUND_Y, true)
    @snow_pile = custom_sprite(Bitmap.new(180, 200), 35)
    @snow_pile.ox = 90
    @snow_pile.oy = 200
    @snow_pile.x = PLAYER_X
    @snow_pile.y = GROUND_Y + 8
    refresh_snow_pile
    @pose_timer = 0
    @enemy_hit_timer = 0
    @enemy_pose_timer = 0
  end

  def create_supporters
    @supporters=[]
    @supporter_last_player_hp=@player_hp
    @supporter_damage_reaction=0
    create_supporter_platform
    ids=[3,4,5,6].reject { |id| id==@opponent_id }
    positions=[Graphics.width/2-82,Graphics.width/2,Graphics.width/2+82]
    ids.each_with_index do |id,index|
      sprite=character_sprite(WCF_SNOWBALL::SNOW_IDLE_SHEETS[id],
        positions[index],276,false)
      sprite.z=18
      @supporters << {:id=>id,:sprite=>sprite,:tick=>index*7,
        :last_pose=>nil}
    end
    update_supporters
  end

  def create_supporter_platform
    width=318; height=76
    bitmap=Bitmap.new(width,height)
    # Back wall and posts keep the audience visually outside the snow field.
    bitmap.fill_rect(8,10,width-16,50,Color.new(45,58,78,235))
    bitmap.fill_rect(12,14,width-24,42,Color.new(70,88,112,235))
    7.times do |i|
      x=18+i*46
      bitmap.fill_rect(x,15,5,42,Color.new(35,48,68,245))
    end
    # Snow-covered balcony deck.
    bitmap.fill_rect(0,56,width,13,Color.new(118,80,55,255))
    bitmap.fill_rect(0,53,width,7,Color.new(245,252,255,255))
    bitmap.fill_rect(8,69,18,7,Color.new(76,49,38,255))
    bitmap.fill_rect(width-26,69,18,7,Color.new(76,49,38,255))
    @supporter_platform=custom_sprite(bitmap,16)
    @supporter_platform.x=(Graphics.width-width)/2
    @supporter_platform.y=220
  end

  def supporter_pose(id)
    player_low=@player_hp<=35
    enemy_low=@enemy_hp<=35
    base=WCF_SNOWBALL::SNOW_IDLE_SHEETS[id]
    alt=WCF_SNOWBALL::SNOW_IDLE_ALT_SHEETS[id]
    if @player_hp<=0
      return [alt,0,[0,1]] if id==6
      return [alt,0,[2]] if id==3 && @opponent_id==4
      return [base,1,[0,1]]
    end
    if @enemy_hp<=0
      return [alt,0,[0]] if id==3 && [5,6].include?(@opponent_id)
      return [base,2,[0,1]] if id==4 && @opponent_id==3
    end
    # Leo's single special pose reacts briefly when Hải Quỳ has just taken a
    # full hit, rather than being mixed into a vertical animation sequence.
    return [alt,1,[0]] if id==5 && @supporter_damage_reaction.to_i>0
    if player_low
      case id
      when 3 then @opponent_id==4 ? [alt,0,[1]] : [base,1,[0,1]]
      when 4 then @opponent_id==3 ? [alt,0,[0,1]] : [base,0,[0,1]]
      when 5 then [base,1,[0,1]]
      else        [base,1,[0,1]]
      end
    elsif enemy_low
      case id
      when 3 then [base,@opponent_id==4 ? 2 : 3,[0,1]]
      when 4
        if [5,6].include?(@opponent_id)
          @player_hp>=WCF_SNOWBALL::PLAYER_HP ?
            [base,3,[0,1]] : [alt,1,[0,1]]
        else
          [base,1,[0,1]]
        end
      when 5
        @opponent_id==6 ? [alt,0,[0,1]] : [base,3,[0,1]]
      else
        [base,[3,4].include?(@opponent_id) ? 2 : 3,[0,1]]
      end
    else
      [base,0,[0,1]]
    end
  end

  def update_supporters
    return unless @supporters
    if @player_hp<@supporter_last_player_hp
      @supporter_damage_reaction=40
    elsif @supporter_damage_reaction.to_i>0
      @supporter_damage_reaction-=1
    end
    @supporter_last_player_hp=@player_hp
    @supporters.each do |data|
      data[:tick]+=1
      sheet,row,columns=supporter_pose(data[:id])
      columns=Array(columns)
      column=columns[(data[:tick]/16)%columns.size]
      pose=[sheet,row,column]
      next if pose==data[:last_pose]
      sprite=data[:sprite]
      sprite.bitmap=Cache.character(sheet) if data[:sheet]!=sheet
      data[:sheet]=sheet
      width=sprite.bitmap.width/3; height=sprite.bitmap.height/4
      sprite.src_rect.set(column*width,row*height,width,height)
      data[:last_pose]=pose
    end
  end

  def create_snowfall
    28.times do
      size = 2 + rand(4)
      bitmap = Bitmap.new(size, size)
      bitmap.fill_rect(bitmap.rect, Color.new(255, 255, 255, 190))
      sprite = custom_sprite(bitmap, 5)
      sprite.x = rand(Graphics.width)
      sprite.y = 92 + rand(Graphics.height - 92)
      sprite.instance_variable_set(:@fall_speed, 1 + rand(3))
      @snowflakes << sprite
    end
  end

  def update_snowfall
    @snowflakes.each do |sprite|
      sprite.y += sprite.instance_variable_get(:@fall_speed)
      if sprite.y > Graphics.height
        sprite.y = 92
        sprite.x = rand(Graphics.width)
      end
    end
  end

  def show_balloon(target, balloon_id)
    @balloons.delete_if do |balloon|
      next false unless balloon[:target] == target
      balloon[:sprite].dispose unless balloon[:sprite].disposed?
      true
    end
    sheet_name = balloon_id <= 10 ? "Balloon1" : "Balloon2"
    row = (balloon_id - 1) % 10
    bitmap = Cache.system(sheet_name)
    width = bitmap.width / 8
    height = bitmap.height / 10
    sprite = Sprite.new
    sprite.bitmap = bitmap
    sprite.src_rect.set(0, row * height, width, height)
    sprite.ox = width / 2
    sprite.oy = height
    sprite.z = 116
    @balloons << {:sprite => sprite, :target => target, :tick => 0,
                  :row => row, :width => width, :height => height}
  end

  def update_balloons
    @balloons.delete_if do |balloon|
      balloon[:tick] += 1
      frame = balloon[:tick] / 8
      if frame >= 8
        balloon[:sprite].dispose unless balloon[:sprite].disposed?
        true
      else
        target = balloon[:target] == :player ? @player_sprite : @enemy_sprite
        balloon[:sprite].src_rect.set(frame * balloon[:width],
          balloon[:row] * balloon[:height], balloon[:width], balloon[:height])
        balloon[:sprite].x = target.x
        balloon[:sprite].y = target.y - target.src_rect.height * target.zoom_y - 8
        false
      end
    end
  end

  def update_ready
    @state_timer -= 1
    begin_defense if @state_timer <= 0
  end

  def begin_defense
    @round += 1
    @balls_left = @opponent[3] + [@round - 1, 3].min
    @burst_remaining = 0
    if @opponent_id == 6 && @round.odd?
      begin_hakase_orbit
      return
    end
    begin_pattern_defense
  end

  def begin_pattern_defense
    clear_projectile
    clear_pattern_notes
    @state = :pattern_defense
    @pattern_frame = 0
    @pattern_notes = []
    @pattern_schedule, @pattern_name = build_defense_pattern
    @pattern_end = @pattern_schedule.map { |note| note[:time] }.max.to_i + 105
    set_banner("PHÒNG THỦ", "")
    show_balloon(:enemy, 12)
    refresh_hud
  end

  def build_defense_pattern
    count = [5 + @round, 10].min
    keys = WCF_SNOWBALL::KEYS
    pattern = [:singles, :jacks, :trills, :stairs, :stream][rand(5)]
    notes = []
    case pattern
    when :singles
      count.times { |i| notes << {:time=>1+i*52, :keys=>[keys[rand(4)]]} }
      name = ""
    when :jacks
      key=keys[rand(4)]
      count.times { |i| notes << {:time=>1+i*25, :keys=>[key]} }
      name = ""
    when :trills
      pair=keys.shuffle[0,2]
      count.times { |i| notes << {:time=>1+i*25, :keys=>[pair[i%2]]} }
      name = ""
    when :stairs
      stair=[:LEFT,:DOWN,:UP,:RIGHT,:UP,:DOWN]
      count.times { |i| notes << {:time=>1+i*29, :keys=>[stair[i%stair.size]]} }
      name = ""
    else
      count.times { |i| notes << {:time=>1+i*20, :keys=>[keys[rand(4)]]} }
      name = ""
    end
    [notes,name]
  end

  def spawn_pattern_note(data)
    group={:keys=>data[:keys],:age=>0.0,:duration=>78,:speed=>1.0,
           :resolved=>false,:miss_announced=>false,:buffered=>false,
           :sprites=>[],:rings=>[]}
    spacing=42
    data[:keys].each_with_index do |key,index|
      sprite=custom_sprite(make_snowball_bitmap(key,38),50)
      sprite.ox=sprite.oy=19
      sprite.x=ENEMY_X-22
      sprite.y=GROUND_Y-72+(index-(data[:keys].size-1)/2.0)*spacing
      group[:sprites] << sprite
      ring=custom_sprite(make_timing_ring_bitmap(58,Color.new(115,225,255)),54)
      ring.ox=ring.oy=29; ring.x=sprite.x; ring.y=sprite.y
      group[:rings] << ring
    end
    @pattern_notes << group
    perform_enemy_throw
  end

  def update_pattern_defense
    @pattern_frame += 1
    @pattern_schedule.each { |data| spawn_pattern_note(data) if data[:time] == @pattern_frame }
    @pattern_notes.each do |note|
      next if note[:resolved]
      note[:age] += note[:speed]
      progress=[note[:age]/note[:duration].to_f,1.0].min
      note[:sprites].each_with_index do |sprite,index|
        start_y=GROUND_Y-72+(index-(note[:sprites].size-1)/2.0)*42
        sprite.x=ENEMY_X-22+(PLAYER_X+25-ENEMY_X+22)*progress
        sprite.y=start_y-Math.sin(progress*Math::PI)*45
        ring=note[:rings][index]
        ring.x=sprite.x; ring.y=sprite.y
        perfect_start=1.0-WCF_SNOWBALL::PERFECT_WINDOW/note[:duration].to_f
        target_scale=38.0/58.0
        scale=1.8-(1.8-target_scale)*(progress/perfect_start)
        scale=[scale,0.50].max
        ring.zoom_x=ring.zoom_y=scale
        if note[:miss_announced]
          ring.color.set(255,65,75,180)
        elsif progress>=perfect_start
          ring.color.set(255,210,40,120)
        end
      end
    end
    @pattern_notes.each do |note|
      next if note[:resolved] || note[:miss_announced] || !note[:buffered]
      remaining=note[:duration]-note[:age]
      resolve_pattern_perfect(note) if remaining <= WCF_SNOWBALL::PERFECT_WINDOW
    end
    keys=triggered_directions
    unless keys.empty?
      # Strict head-of-line judging: one input may inspect and mutate exactly
      # one projectile. It can never skip the leading ball to reach a later
      # arrow, even when several timing windows overlap.
      target=@pattern_notes.select do |note|
        !note[:resolved] && !note[:miss_announced] &&
          note[:duration]-note[:age] > 0
      end.min_by { |note| note[:duration]-note[:age] }
      if target
        remaining=target[:duration]-target[:age]
        correct=keys.sort_by(&:to_s)==target[:keys].sort_by(&:to_s)
        if correct && remaining<=WCF_SNOWBALL::PERFECT_WINDOW
          resolve_pattern_perfect(target)
        elsif correct && remaining<=WCF_SNOWBALL::PERFECT_WINDOW+5
          target[:buffered]=true
          target[:rings].each { |ring| ring.color.set(255,225,70,140) }
        else
          target[:miss_announced]=true
          target[:buffered]=false
          target[:speed]=3.0
          @misses+=1
          target[:rings].each { |ring| ring.color.set(255,65,75,180) }
          show_judge("MISS",Color.new(255,82,92))
          show_balloon(:player,11)
        end
      end
    end
    @pattern_notes.each do |note|
      next if note[:resolved] || note[:age] < note[:duration]
      note[:resolved]=true
      @player_hp=[@player_hp-WCF_SNOWBALL::MISS_DAMAGE,0].max
      note[:sprites].each { |s| spawn_snow_splash(PLAYER_X+15,s.y,9); dispose_custom_sprite(s) }
      note[:rings].each { |s| dispose_custom_sprite(s) }
      unless note[:miss_announced]
        @misses+=1; show_judge("MISS",Color.new(255,82,92)); show_balloon(:player,11)
      end
      RPG::SE.new("Damage1",85,100).play
      @player_sprite.color.set(255,70,70,170); @pose_timer=14
      refresh_snow_pile; refresh_hud
      return start_enemy_finisher if @player_hp<=0
    end
    if @pattern_frame >= @pattern_end && @pattern_notes.all? { |n| n[:resolved] }
      clear_pattern_notes
      begin_attack_intro
    end
  end

  def resolve_pattern_perfect(note)
    return if note[:resolved] || note[:miss_announced]
    note[:resolved]=true
    award_perfect
    note[:sprites].each { |s| spawn_snow_splash(s.x,s.y,12); dispose_custom_sprite(s) }
    note[:rings].each { |s| dispose_custom_sprite(s) }
    show_judge("PERFECT!",Color.new(255,226,65))
    show_balloon(:player,12); perform_dodge(note[:keys][0],true)
    RPG::SE.new("Evasion1",85,115).play
  end

  def clear_pattern_notes
    return unless @pattern_notes
    @pattern_notes.each do |note|
      note[:sprites].each { |s| dispose_custom_sprite(s) unless s.disposed? }
      note[:rings].to_a.each { |s| dispose_custom_sprite(s) unless s.disposed? }
    end
    @pattern_notes.clear
  end

  def spawn_enemy_snowball
    clear_projectile
    @ball_key = choose_defense_key
    if @burst_remaining > 0
      @burst_remaining -= 1
      @fast_follow = true
    elsif @balls_left >= 2 && rand(100) < burst_chance
      extra = @opponent_id == 4 ? 2 + rand(2) : 1 + rand(2)
      @burst_remaining = [extra, @balls_left - 1].min
      @fast_follow = true
    else
      @fast_follow = false
    end
    speed_variation = rand(23) - 11
    speed_variation -= 7 if @fast_follow
    speed_variation -= 5 if @opponent_id == 5
    @ball_total = [@opponent[2] - (@round - 1) * 2 + speed_variation, 46].max
    @ball_arc, ball_size = enemy_ball_style
    @ball_size=ball_size
    @ball_frame = 0
    @pending_contact = nil
    @buffered_defense=false
    @miss_announced = false
    @miss_speedup = 1
    @projectile = custom_sprite(make_snowball_bitmap(@ball_key, ball_size), 45)
    @projectile.ox = @projectile.oy = ball_size / 2
    @projectile.x = ENEMY_X - 22
    @projectile.y = GROUND_Y - 42
    @projectile_ring=custom_sprite(make_timing_ring_bitmap(ball_size+20,Color.new(115,225,255)),54)
    @projectile_ring.ox=@projectile_ring.oy=(ball_size+20)/2
    perform_enemy_throw
  end

  def burst_chance
    @opponent_id == 4 ? 65 : 42
  end

  def enemy_ball_style
    case @opponent_id
    when 3 then [55 + rand(40), 54]                 # Shylvie: chắc, dễ đọc
    when 4 then [30 + rand(65), 44 + rand(14)]     # Kohi: dồn dập
    when 5 then [24 + rand(32), 42]                # Leo: thấp và nhanh
    else        [20 + rand(110), [34, 50, 70][rand(3)]] # Hakase: hỗn loạn
    end
  end

  def defense_trait_text
    ""
  end

  def choose_defense_key
    key = if @opponent_id == 5 && @last_ball_key && rand(3) == 0
      @last_ball_key == :LEFT ? :RIGHT : :LEFT
    elsif @opponent_id == 4 && @last_ball_key && rand(4) == 0
      @last_ball_key
    else
      WCF_SNOWBALL::KEYS[rand(4)]
    end
    @last_ball_key = key
    key
  end

  def update_defense
    @ball_frame += @miss_speedup
    progress = [@ball_frame / @ball_total.to_f, 1.0].min
    @projectile.x = ENEMY_X - 22 + (PLAYER_X + 25 - ENEMY_X + 22) * progress
    @projectile.y = GROUND_Y - 42 - Math.sin(progress * Math::PI) * @ball_arc
    if @projectile_ring
      @projectile_ring.x=@projectile.x; @projectile_ring.y=@projectile.y
      perfect_start=1.0-WCF_SNOWBALL::PERFECT_WINDOW/@ball_total.to_f
      target_scale=@ball_size.to_f/(@ball_size+20)
      scale=1.8-(1.8-target_scale)*(progress/perfect_start)
      @projectile_ring.zoom_x=@projectile_ring.zoom_y=[scale,0.48].max
      if @miss_announced
        @projectile_ring.color.set(255,65,75,180)
      elsif progress>=perfect_start
        @projectile_ring.color.set(255,210,40,120)
      end
    end
    if @buffered_defense && @ball_total-@ball_frame<=WCF_SNOWBALL::PERFECT_WINDOW
      @buffered_defense=false
      judge_defense(@ball_key)
      return if @state != :defense
    end
    pressed = pressed_direction
    judge_defense(pressed) if pressed && !@pending_contact
    resolve_snow_contact(@pending_contact || :miss) if
      @state == :defense && @ball_frame >= @ball_total
  end

  def judge_defense(key)
    remaining = @ball_total - @ball_frame
    if key == @ball_key && remaining.abs <= WCF_SNOWBALL::PERFECT_WINDOW
      award_perfect
      dispose_custom_sprite(@projectile_ring) if @projectile_ring
      @projectile_ring=nil
      show_judge("PERFECT!", Color.new(255, 226, 65))
      show_balloon(:player, 12)
      perform_dodge(key, true)
      RPG::SE.new("Evasion1", 85, 115).play
      begin_deflect
    elsif key == @ball_key && remaining > WCF_SNOWBALL::PERFECT_WINDOW &&
          remaining <= WCF_SNOWBALL::PERFECT_WINDOW + 5
      @buffered_defense=true
      @projectile_ring.color.set(255,225,70,140) if @projectile_ring
    else
      @buffered_defense=false
      @pending_contact = :miss
      @miss_speedup = 3
      unless @miss_announced
        @miss_announced = true
        @misses += 1
        show_judge("MISS", Color.new(255, 82, 92))
        show_balloon(:player, 11)
        refresh_hud
      end
    end
  end

  def resolve_snow_contact(result)
    return unless @state == :defense
    dispose_custom_sprite(@projectile_ring) if @projectile_ring
    @projectile_ring=nil
    @misses += 1 unless @miss_announced
    @player_hp = [@player_hp - WCF_SNOWBALL::MISS_DAMAGE, 0].max
    show_judge("MISS", Color.new(255, 82, 92)) unless @miss_announced
    show_balloon(:player, 11) unless @miss_announced
    RPG::SE.new("Damage1", 85, 100).play
    spawn_snow_splash(PLAYER_X + 18, GROUND_Y - 38,
                      18)
    @player_sprite.color.set(255, 70, 70, 170)
    @pose_timer = 14
    refresh_snow_pile
    refresh_hud
    if @player_hp <= 0
      start_enemy_finisher
    else
      @state = :deflect
      @deflect_timer = @fast_follow ? 8 : 14
      @deflect_kind = :impact
    end
  end

  def begin_deflect
    @state = :deflect
    @deflect_timer = @fast_follow ? 9 : 18
    @deflect_kind = :away
  end

  def update_deflect
    @deflect_timer -= 1
    if @projectile
      if @deflect_kind == :away
        @projectile.x += 8
        @projectile.y -= 7
        @projectile.angle += 18
      else
        @projectile.zoom_x += 0.08
        @projectile.zoom_y += 0.08
        @projectile.opacity -= 14
      end
    end
    return unless @deflect_timer <= 0
    @balls_left -= 1
    if @balls_left > 0
      @state = :defense
      spawn_enemy_snowball
    else
      begin_attack_intro
    end
  end

  def begin_attack_intro
    clear_projectile
    restore_enemy_character if @shylvie_throw_active
    @state = :attack_intro
    @state_timer = 55
    subtitle=case @opponent_id
    when 3 then "Chuẩn bị phản đòn cầu tuyết của Shylvie"
    when 4 then "Nhập đúng ít nhất 50% chuỗi trước khi hết thời gian"
    when 5 then "Chuẩn bị đối phó các nhát chém không gian của Leo"
    when 6 then "Chuẩn bị đấu ma lực với Hakase"
    else ""
    end
    set_banner("PHẢN CÔNG!",subtitle)
  end

  def update_attack_intro
    @state_timer -= 1
    begin_attack_input if @state_timer <= 0
  end

  def begin_attack_input
    return begin_shylvie_return if @opponent_id == 3
    return begin_leo_slash if @opponent_id == 5
    return begin_hakase_push if @opponent_id == 6
    @attack_sequence = []
    # Kohi's sequence length varies inside a gradually expanding range.  This
    # keeps consecutive turns from becoming mechanically longer every time.
    min_notes = [5 + ((@round - 1) / 2), 8].min
    max_notes = [7 + ((@round - 1) / 2), 12].min
    length = min_notes + rand(max_notes - min_notes + 1)
    build_attack_sequence(length)
    @attack_index = 0
    # Give time according to the actual random sequence length. Difficulty
    # still rises, but the time-per-note no longer collapses after a few turns.
    round_pressure = [(@round - 1) * 3, 24].min
    @attack_timer_max = [180 + length * 18 - round_pressure, 240].max
    @attack_timer = @attack_timer_max
    create_attack_buttons
    @state = :attack_input
    show_balloon(:player, 12)
    set_banner("NÉM TRẢ", "")
  end

  def build_attack_sequence(length)
    length.times { @attack_sequence << WCF_SNOWBALL::KEYS[rand(4)] }
  end

  def attack_trait_text
    ""
  end

  def create_attack_buttons
    clear_attack_buttons
    spacing = [52, (Graphics.width - 40) / @attack_sequence.size].min
    total = spacing * @attack_sequence.size
    start_x = (Graphics.width - total) / 2 + spacing / 2
    @attack_sequence.each_with_index do |key, index|
      sprite = custom_sprite(make_button_bitmap(key, :waiting), 70)
      sprite.ox = sprite.oy = 23
      sprite.x = start_x + index * spacing
      sprite.y = 242
      @attack_buttons << sprite
    end
    @timer_bitmap = Bitmap.new(Graphics.width - 120, 16)
    @timer_sprite = custom_sprite(@timer_bitmap, 70)
    @timer_sprite.x = 60
    @timer_sprite.y = 292
    refresh_attack_buttons
  end

  def refresh_attack_buttons
    @attack_buttons.each_with_index do |sprite, index|
      sprite.bitmap.clear
      state = index < @attack_index ? :done : (index == @attack_index ? :current : :waiting)
      draw_button(sprite.bitmap, @attack_sequence[index], state)
    end
    refresh_attack_timer
  end

  def refresh_attack_timer
    return unless @timer_bitmap && !@timer_bitmap.disposed?
    @timer_bitmap.clear
    @timer_bitmap.fill_rect(0, 0, @timer_bitmap.width, 16, Color.new(20, 32, 54, 220))
    ratio = [[@attack_timer.to_f / @attack_timer_max, 0.0].max, 1.0].min
    width = ((@timer_bitmap.width - 4) * ratio).to_i
    color = @attack_timer < 70 ? Color.new(255, 80, 85) : Color.new(75, 215, 245)
    @timer_bitmap.fill_rect(2, 2, width, 12, color)
  end

  def update_attack_input
    @attack_timer -= 1
    keys = triggered_directions
    if !keys.empty?
      expected = Array(@attack_sequence[@attack_index])
      if keys.sort_by(&:to_s) == expected.sort_by(&:to_s)
        @attack_index += 1
        RPG::SE.new("Cursor2", 75, 115).play
        show_judge("OK!", Color.new(105, 235, 255))
        if @attack_index >= @attack_sequence.size
          begin_player_throw(:perfect)
          return
        end
        refresh_attack_buttons
      else
        begin_player_throw(attack_partial_result)
        return
      end
    end
    if @attack_timer <= 0
      begin_player_throw(attack_partial_result)
      return
    end
    refresh_attack_timer
  end

  def attack_partial_result
    @attack_index * 2 >= @attack_sequence.size ? :good : :miss
  end

  def begin_player_throw(result)
    @attack_result = result
    @attack_success = result != :miss
    clear_attack_buttons
    @state = :player_throw
    @throw_timer = 48
    size = result == :perfect ? 66 : (result == :good ? 40 : 30)
    @projectile = custom_sprite(make_snowball_bitmap(nil, size), 50)
    @projectile.ox = @projectile.oy = @projectile.bitmap.width / 2
    @projectile.x = PLAYER_X + 24
    @projectile.y = GROUND_Y - 45
    perform_throw_pose
    start_enemy_snow_action("$Snow_Defend",48) if @attack_success
    play_animation_at(153, PLAYER_X + 18, GROUND_Y - 42)
    if result == :perfect
      show_judge("PERFECT!", Color.new(255, 226, 65))
      show_balloon(:player, 12)
      set_banner("PERFECT!", "Hải Quỳ ném một quả cầu tuyết khổng lồ")
    elsif result == :good
      show_judge("GOOD", Color.new(90, 225, 255))
      show_balloon(:player, 1)
      set_banner("GOOD", "Hải Quỳ ném một quả cầu tuyết bé")
    else
      show_judge("MISS", Color.new(255, 82, 92))
      set_banner("NÉM TRƯỢT!", "Hải Quỳ ngắm lệch tỉ độ")
    end
    pitch = result == :perfect ? 118 : (result == :good ? 100 : 82)
    RPG::SE.new("Attack3", 85, pitch).play
  end

  def update_player_throw
    @throw_timer -= 1
    progress = (48 - @throw_timer) / 48.0
    target_x = @attack_success ? ENEMY_X : Graphics.width + 80
    @projectile.x = PLAYER_X + 24 + (target_x - PLAYER_X - 24) * progress
    arc = @attack_result == :perfect ? 96 : (@attack_success ? 72 : 145)
    @projectile.y = GROUND_Y - 45 - Math.sin(progress * Math::PI) * arc
    @projectile.angle -= 14
    return unless @throw_timer <= 0
    if @attack_success
      damage = if @attack_result == :perfect
        14 + [@perfects / [@round, 1].max, 6].min
      else
        good_counter_damage
      end
      @enemy_hp = [@enemy_hp - damage, 0].max
      @enemy_sprite.color.set(255, 70, 70, 170)
      @enemy_hit_timer = 14
      perform_enemy_hit(@attack_result)
      show_balloon(:enemy, @attack_result == :perfect ? 11 : 6)
      show_judge("-#{damage} HP", Color.new(255, 225, 70), :enemy)
      RPG::SE.new("Damage2", 85, 95).play
      refresh_hud
    end
    clear_projectile
    if @enemy_hp <= 0
      start_player_finisher
    else
      @state = :ready
      @state_timer = 70
      set_banner("LƯỢT TIẾP THEO", "Đối thủ đang chuẩn bị tuyết")
    end
  end

  def good_counter_damage
    case @opponent_id
    when 3 then 5
    when 4 then 8
    when 6 then 7
    else 8
    end
  end

  def perform_dodge(key, perfect)
    @pose_timer = 13
    distance = perfect ? 28 : 17
    case key
    when :LEFT  then @player_sprite.x = PLAYER_X - distance
    when :RIGHT then @player_sprite.x = PLAYER_X + distance
    when :UP    then @player_sprite.y = GROUND_Y - distance
    when :DOWN
      @player_sprite.zoom_y = perfect ? 0.54 : 0.72
      @player_sprite.y = GROUND_Y + 4
    end
  end

  def perform_throw_pose
    @pose_timer = 18
    @player_sprite.x = PLAYER_X + 18
    @player_sprite.angle = -10
  end

  def perform_enemy_throw
    @enemy_pose_timer = 15
    @enemy_sprite.x = ENEMY_X - 15
    @enemy_sprite.y = GROUND_Y + 2
    @enemy_sprite.angle = -12
    @enemy_sprite.zoom_x = 1.08
    @enemy_sprite.zoom_y = 0.94
    start_enemy_snow_action("$Snow_Attack",18)
    play_animation_at(152, ENEMY_X - 18, GROUND_Y - 42)
  end

  def perform_enemy_hit(result)
    restore_enemy_character if @enemy_action_active || @shylvie_throw_active
    @enemy_pose_timer = result == :perfect ? 24 : 15
    distance = result == :perfect ? 28 : 15
    @enemy_sprite.x = ENEMY_X + distance
    @enemy_sprite.y = GROUND_Y - (result == :perfect ? 13 : 5)
    @enemy_sprite.angle = result == :perfect ? 22 : 11
    @enemy_sprite.zoom_x = result == :perfect ? 0.88 : 0.95
    @enemy_sprite.zoom_y = result == :perfect ? 1.12 : 1.05
    start_enemy_snow_action("$Snow_Defend",@enemy_pose_timer)
  end

  def update_character_pose
    update_enemy_snow_action
    update_supporters
    if @pose_timer > 0
      @pose_timer -= 1
      if @pose_timer <= 0
        @player_sprite.x, @player_sprite.y = @player_home
        @player_sprite.zoom_x = @player_sprite.zoom_y = 1.0
        @player_sprite.angle = 0
        @player_sprite.color.set(0, 0, 0, 0)
      end
    end
    if @enemy_hit_timer > 0
      @enemy_hit_timer -= 1
      @enemy_sprite.color.set(0, 0, 0, 0) if @enemy_hit_timer <= 0
    end
    if @enemy_pose_timer > 0
      @enemy_pose_timer -= 1
      if @enemy_pose_timer <= 0
        @enemy_sprite.x, @enemy_sprite.y = @enemy_home
        @enemy_sprite.angle = 0
        @enemy_sprite.zoom_x = @enemy_sprite.zoom_y = 1.0
      end
    end
  end

  def start_enemy_snow_action(sheet,duration)
    bitmap=Cache.character(sheet)
    @enemy_sprite.bitmap=bitmap
    @enemy_sprite.mirror=false
    @enemy_action_width=bitmap.width/3
    @enemy_action_height=bitmap.height/4
    @enemy_action_row=WCF_SNOWBALL::SNOW_ACTION_ROWS[@opponent_id]
    @enemy_action_timer=duration
    @enemy_action_duration=duration
    @enemy_action_active=true
    @enemy_sprite.ox=@enemy_action_width/2
    @enemy_sprite.oy=@enemy_action_height
    @enemy_sprite.src_rect.set(0,@enemy_action_row*@enemy_action_height,
      @enemy_action_width,@enemy_action_height)
  end

  def update_enemy_snow_action
    return unless @enemy_action_active
    elapsed=@enemy_action_duration-@enemy_action_timer
    column=[elapsed/5,1].min
    @enemy_sprite.src_rect.set(column*@enemy_action_width,
      @enemy_action_row*@enemy_action_height,
      @enemy_action_width,@enemy_action_height)
    @enemy_action_timer-=1
    restore_enemy_character if @enemy_action_timer<=0
  end

  def start_shylvie_throw_animation
    bitmap=Cache.character("$CV_Throw")
    @enemy_sprite.bitmap=bitmap
    @enemy_sprite.mirror=false
    @shylvie_throw_width=bitmap.width/3
    @shylvie_throw_height=bitmap.height/4
    @enemy_sprite.ox=@shylvie_throw_width/2
    @enemy_sprite.oy=@shylvie_throw_height
    @shylvie_throw_frames=[[0,1],[0,2],[1,2],[2,2]]
    @shylvie_throw_timer=20
    @shylvie_throw_active=true
    @enemy_sprite.src_rect.set(0,@shylvie_throw_height,
      @shylvie_throw_width,@shylvie_throw_height)
  end

  def update_shylvie_throw_animation
    return unless @shylvie_throw_timer.to_i > 0
    elapsed=20-@shylvie_throw_timer
    frame=[elapsed/5,@shylvie_throw_frames.size-1].min
    column,row=@shylvie_throw_frames[frame]
    @enemy_sprite.src_rect.set(column*@shylvie_throw_width,
      row*@shylvie_throw_height,@shylvie_throw_width,@shylvie_throw_height)
    @shylvie_throw_timer-=1
    if @shylvie_throw_timer<=0
      # Keep the final throwing pose between tightly spaced Stream/Jack notes;
      # switching to idle for one frame caused the visible flicker.
      restore_enemy_character unless @state==:pattern_defense
    end
  end

  def restore_enemy_character
    bitmap=Cache.character(@opponent[1])
    @enemy_sprite.bitmap=bitmap
    @enemy_sprite.mirror=true
    single=@opponent[1][0,1]=="$" || @opponent[1][0,2]=="!$"
    width=bitmap.width/(single ? 3 : 12)
    height=bitmap.height/(single ? 4 : 8)
    @enemy_sprite.src_rect.set(width,0,width,height)
    @enemy_sprite.ox=width/2
    @enemy_sprite.oy=height
    @shylvie_throw_timer=0
    @shylvie_throw_active=false
    @enemy_action_timer=0
    @enemy_action_active=false
  end

  def start_enemy_finisher
    clear_projectile
    clear_attack_buttons
    @state = :enemy_finisher
    @finisher_timer = 0
    @burial_level = 0
    @finisher_balls = []
    show_balloon(:enemy, 5)
    show_balloon(:player, 11)
    set_banner("FINISHER!", "Đối thủ chuẩn bị một núi tuyết…")
  end

  def spawn_finisher_ball
    size = 30 + rand(25)
    sprite = custom_sprite(make_snowball_bitmap(nil, size), 50)
    sprite.ox = sprite.oy = size / 2
    duration = 20 + rand(15)
    @finisher_balls << {
      :sprite => sprite, :frame => 0, :duration => duration,
      :arc => 25 + rand(80), :offset => rand(35) - 17
    }
  end

  def update_enemy_finisher
    @finisher_timer += 1
    spawn_finisher_ball if @finisher_timer <= 150 && @finisher_timer % 6 == 0
    @finisher_balls.delete_if do |ball|
      ball[:frame] += 1
      progress = [ball[:frame] / ball[:duration].to_f, 1.0].min
      sprite = ball[:sprite]
      sprite.x = ENEMY_X - 20 + (PLAYER_X - ENEMY_X + 20) * progress
      sprite.y = GROUND_Y - 45 - Math.sin(progress * Math::PI) * ball[:arc] + ball[:offset]
      if progress >= 1.0
        spawn_snow_splash(PLAYER_X, GROUND_Y - 38, 7 + rand(7))
        @burial_level = [@burial_level + 5, 100].min
        refresh_finisher_snowman
        RPG::SE.new("Damage1", 60, 90 + rand(25)).play
        dispose_custom_sprite(sprite)
        true
      else
        false
      end
    end
    if @finisher_timer == 170
      @burial_level = 100
      refresh_finisher_snowman
      set_banner("HẢI QUỲ ĐÃ THÀNH NGƯỜI TUYẾT!", "…ít nhất cũng có thể dùng trang trí Giáng sinh")
      RPG::SE.new("Applause1", 80, 115).play
    elsif @finisher_timer == 205
      show_finish_title("FATALITY", Color.new(205, 25, 25), 62)
      set_banner("FATALITY", "")
      RPG::SE.new("Darkness4", 90, 75).play
    elsif @finisher_timer == 267
      show_finish_title("#{@opponent[0].upcase} WINS", Color.new(255, 218, 72), 70)
      set_banner("#{@opponent[0].upcase} WINS", "Hải Quỳ bị chôn vùi trong tuyết")
      RPG::SE.new("Applause1", 85, 100).play
    elsif @finisher_timer >= 345
      finish_battle(-1, "HẢI QUỲ ĐÃ THÀNH NGƯỜI TUYẾT!")
    end
  end

  def start_player_finisher
    clear_projectile
    clear_attack_buttons
    @state = :player_finisher
    @finisher_timer = 0
    @finisher_player_x = @player_sprite.x.to_f
    @finisher_player_y = @player_sprite.y.to_f
    @finisher_enemy_x = @enemy_sprite.x.to_f
    @finisher_enemy_y = @enemy_sprite.y.to_f
    @snow_pile.visible = false
    show_balloon(:player, 12)
    show_balloon(:enemy, 1)
    set_banner("HẢI QUỲ FINISHER!", "")
    RPG::SE.new("Wind5", 85, 125).play
  end

  def spawn_blue_afterimage
    rect = @player_sprite.src_rect
    bitmap = Bitmap.new(rect.width, rect.height)
    bitmap.blt(0, 0, @player_sprite.bitmap, rect)
    sprite = custom_sprite(bitmap, 27)
    sprite.ox = rect.width / 2
    sprite.oy = rect.height
    sprite.x = @finisher_player_x
    sprite.y = @finisher_player_y
    sprite.zoom_x = @player_sprite.zoom_x
    sprite.zoom_y = @player_sprite.zoom_y
    sprite.color.set(30, 155, 255, 190)
    sprite.opacity = 190
    @effects << {:sprite => sprite, :life => 110, :kind => :afterimage,
                 :world_x => @finisher_player_x, :world_y => @finisher_player_y}
  end

  def update_player_finisher
    @finisher_timer += 1
    if @finisher_timer <= 24
      spawn_blue_afterimage if @finisher_timer % 3 == 0
      progress = @finisher_timer / 24.0
      @finisher_player_x = PLAYER_X + (ENEMY_X + 48 - PLAYER_X) * progress
      @finisher_player_y = GROUND_Y - Math.sin(progress * Math::PI) * 24
      apply_finisher_camera(0.0, 1.0)
    elsif @finisher_timer == 25
      spawn_blue_afterimage
      set_banner("…", "")
    elsif @finisher_timer <= 48
      apply_finisher_camera(0.0, 1.0)
    elsif @finisher_timer <= 72
      progress = (@finisher_timer - 48) / 24.0
      apply_finisher_camera(progress, 1.0 + 0.45 * progress)
    elsif @finisher_timer <= 84
      apply_finisher_camera(1.0, 1.45)
    elsif @finisher_timer == 85
      apply_finisher_camera(1.0, 1.45)
      show_smash_effect
      spawn_snow_splash(@enemy_sprite.x, @enemy_sprite.y - 35, 30)
      @enemy_sprite.color.set(100, 190, 255, 180)
      RPG::SE.new("Damage5", 95, 115).play
    elsif @finisher_timer <= 105
      apply_finisher_camera(1.0, 1.45)
    elsif @finisher_timer <= 129
      progress = (@finisher_timer - 105) / 24.0
      apply_finisher_camera(1.0 - progress, 1.45 - 0.45 * progress)
    elsif @finisher_timer == 130
      reset_finisher_camera
      set_banner("KNOCKOUT!", "Hải Quỳ đấm bay đối thủ")
    elsif @finisher_timer < 178
      @finisher_enemy_x -= 14
      @finisher_enemy_y -= 10
      @enemy_sprite.x = @finisher_enemy_x
      @enemy_sprite.y = @finisher_enemy_y
      @enemy_sprite.angle -= 28
      @enemy_sprite.zoom_x += 0.014
      @enemy_sprite.zoom_y += 0.014
    elsif @finisher_timer == 178
      show_finish_title("FATALITY", Color.new(205, 25, 25), 62)
      set_banner("FATALITY", "")
      RPG::SE.new("Darkness4", 90, 75).play
    elsif @finisher_timer == 240
      show_finish_title("HẢI QUỲ WINS", Color.new(255, 218, 72), 70)
      set_banner("HẢI QUỲ WINS", "Một chiến thắng áp đảo")
      RPG::SE.new("Applause1", 85, 110).play
    elsif @finisher_timer >= 318
      finish_battle(1, "HẢI QUỲ CHIẾN THẮNG!")
    end
  end

  def apply_finisher_camera(focus_progress, zoom)
    camera_x = Graphics.width / 2.0 + (410 - Graphics.width / 2.0) * focus_progress
    camera_y = Graphics.height / 2.0 + (314 - Graphics.height / 2.0) * focus_progress
    @background.ox = camera_x
    @background.oy = camera_y
    @background.x = Graphics.width / 2
    @background.y = Graphics.height / 2
    @background.zoom_x = @background.zoom_y = zoom
    @player_sprite.x = Graphics.width / 2 + (@finisher_player_x - camera_x) * zoom
    @player_sprite.y = Graphics.height / 2 + (@finisher_player_y - camera_y) * zoom
    @enemy_sprite.x = Graphics.width / 2 + (@finisher_enemy_x - camera_x) * zoom
    @enemy_sprite.y = Graphics.height / 2 + (@finisher_enemy_y - camera_y) * zoom
    @player_sprite.zoom_x = @player_sprite.zoom_y = zoom
    @enemy_sprite.zoom_x = @enemy_sprite.zoom_y = zoom
    @effects.each do |effect|
      next unless effect[:kind] == :afterimage
      effect[:sprite].x = Graphics.width / 2 + (effect[:world_x] - camera_x) * zoom
      effect[:sprite].y = Graphics.height / 2 + (effect[:world_y] - camera_y) * zoom
      effect[:sprite].zoom_x = effect[:sprite].zoom_y = zoom
    end
  end

  def reset_finisher_camera
    @background.ox = @background.oy = 0
    @background.x = @background.y = 0
    @background.zoom_x = @background.zoom_y = 1.0
    @player_sprite.x = @finisher_player_x
    @player_sprite.y = @finisher_player_y
    @enemy_sprite.x = @finisher_enemy_x
    @enemy_sprite.y = @finisher_enemy_y
    @player_sprite.zoom_x = @player_sprite.zoom_y = 1.0
    @enemy_sprite.zoom_x = @enemy_sprite.zoom_y = 1.0
  end

  def show_smash_effect
    flash_bitmap = Bitmap.new(Graphics.width, Graphics.height)
    flash_bitmap.fill_rect(flash_bitmap.rect, Color.new(140, 220, 255, 170))
    flash = custom_sprite(flash_bitmap, 108)
    @effects << {:sprite => flash, :life => 18, :kind => :flash}

    bitmap = Bitmap.new(380, 120)
    bitmap.font.size = 58
    bitmap.font.bold = true
    bitmap.font.outline = true
    bitmap.font.color = Color.new(255, 80, 55)
    bitmap.draw_text(bitmap.rect, "SMASH!!", 1)
    sprite = custom_sprite(bitmap, 120)
    sprite.ox = 190
    sprite.oy = 60
    sprite.x = Graphics.width / 2
    sprite.y = Graphics.height / 2 - 15
    sprite.zoom_x = sprite.zoom_y = 0.18
    sprite.angle = -9
    @effects << {:sprite => sprite, :life => 70, :kind => :smash}
  end

  def show_finish_title(text, color, life)
    bitmap = Bitmap.new(Graphics.width, 100)
    bitmap.font.size = text == "FATALITY" ? 58 : 44
    bitmap.font.bold = true
    bitmap.font.outline = true
    bitmap.font.color = color
    bitmap.draw_text(bitmap.rect, text, 1)
    sprite = custom_sprite(bitmap, 125)
    sprite.ox = Graphics.width / 2
    sprite.oy = 50
    sprite.x = Graphics.width / 2
    sprite.y = Graphics.height / 2 - 22
    sprite.zoom_x = sprite.zoom_y = 1.65
    sprite.opacity = 0
    @effects << {:sprite => sprite, :life => life, :max_life => life,
                 :kind => :finish_title}
  end

  def show_judge(text, color, target = :player)
    bitmap = Bitmap.new(190, 46)
    bitmap.font.size = 28
    bitmap.font.bold = true
    bitmap.font.outline = true
    bitmap.font.color = color
    bitmap.draw_text(bitmap.rect, text, 1)
    sprite = custom_sprite(bitmap, 90)
    sprite.ox = 95
    sprite.x = target == :enemy ? ENEMY_X : PLAYER_X
    sprite.y = GROUND_Y - 115
    @effects << {:sprite => sprite, :life => 42, :kind => :text}
  end

  def spawn_snow_splash(x, y, amount)
    amount.times do
      size = 3 + rand(7)
      bitmap = Bitmap.new(size, size)
      bitmap.fill_rect(bitmap.rect,
        Color.new(225 + rand(31), 238 + rand(18), 255, 235))
      sprite = custom_sprite(bitmap, 65)
      sprite.ox = sprite.oy = size / 2
      sprite.x = x + rand(17) - 8
      sprite.y = y + rand(13) - 6
      @effects << {
        :sprite => sprite, :life => 32 + rand(18), :kind => :snow,
        :vx => (rand(81) - 40) / 10.0,
        :vy => -(18 + rand(40)) / 10.0,
        :gravity => 0.18 + rand(8) / 100.0
      }
    end
  end

  def refresh_snow_pile
    return unless @snow_pile
    bitmap = @snow_pile.bitmap
    bitmap.clear
    lost = WCF_SNOWBALL::PLAYER_HP - @player_hp
    return if lost <= 0
    width = [46 + (lost * 0.42).to_i, 88].min
    height = [5 + (lost * 0.13).to_i, 18].min
    draw_snow_ellipse(bitmap, 90, 196 - height / 2, width / 2,
                      height / 2, Color.new(232, 244, 252, 248))
    blob_count = 1 + lost / 35
    blob_count.times do |index|
      radius = 7 + lost / 28 + rand(3)
      bx = 90 + (index.even? ? -1 : 1) * (10 + index * 9)
      by = 190 - rand(5)
      draw_snow_ellipse(bitmap, bx, by, radius, [radius / 2, 3].max,
                        Color.new(245, 250, 255, 250))
    end
  end

  def refresh_finisher_snowman
    bitmap = @snow_pile.bitmap
    bitmap.clear
    level = [[@burial_level, 0].max, 100].min
    draw_snow_ellipse(bitmap, 90, 190, 65, 10 + level / 8,
                      Color.new(230, 243, 252, 252))
    lower = [level, 45].min
    draw_snow_ellipse(bitmap, 90, 174 - lower / 2, 20 + lower / 2,
                      [lower, 4].max, Color.new(240, 249, 255, 255))
    if level > 28
      middle = [level - 28, 42].min
      draw_snow_ellipse(bitmap, 90, 115 - middle / 2, 16 + middle / 3,
                        [middle, 4].max, Color.new(246, 252, 255, 255))
    end
    if level > 65
      head = [level - 65, 35].min
      draw_snow_ellipse(bitmap, 90, 62, 13 + head / 3,
                        10 + head / 3, Color.new(250, 254, 255, 255))
    end
    if level >= 100
      coal = Color.new(35, 42, 50)
      bitmap.fill_rect(80, 55, 6, 6, coal)
      bitmap.fill_rect(99, 55, 6, 6, coal)
      bitmap.fill_rect(89, 77, 6, 6, coal)
      bitmap.fill_rect(89, 112, 6, 6, coal)
      bitmap.fill_rect(89, 137, 6, 6, coal)
      bitmap.fill_rect(90, 65, 18, 4, Color.new(245, 135, 45))
    end
    @player_sprite.opacity = [255 - level * 3, 0].max
  end

  def draw_snow_ellipse(bitmap, cx, cy, rx, ry, color)
    return if rx <= 0 || ry <= 0
    (-ry..ry).each do |dy|
      ratio = 1.0 - (dy * dy).to_f / (ry * ry)
      half = (rx * Math.sqrt([ratio, 0.0].max)).to_i
      bitmap.fill_rect(cx - half, cy + dy, half * 2 + 1, 1, color)
    end
  end

  def update_effects
    @effects.delete_if do |effect|
      effect[:life] -= 1
      if effect[:kind] == :snow
        effect[:sprite].x += effect[:vx]
        effect[:sprite].y += effect[:vy]
        effect[:vy] += effect[:gravity]
        effect[:sprite].angle += effect[:vx] * 4
        effect[:sprite].opacity = [effect[:life] * 9, 255].min
      elsif effect[:kind] == :split
        effect[:sprite].x += effect[:vx]
        effect[:sprite].y += effect[:vy]
        effect[:vy] += 0.25
        effect[:sprite].angle += effect[:vx] * 5
        effect[:sprite].opacity = [effect[:life] * 10, 255].min
      elsif effect[:kind] == :ring
        effect[:sprite].zoom_x *= 0.91
        effect[:sprite].zoom_y = effect[:sprite].zoom_x
        effect[:sprite].opacity = [effect[:life] * 11, 255].min
      elsif effect[:kind] == :slash
        effect[:sprite].zoom_x *= 0.96
        effect[:sprite].zoom_y *= 0.9
        effect[:sprite].opacity = [effect[:life] * 11,255].min
      elsif effect[:kind] == :afterimage
        effect[:sprite].opacity = [effect[:life] * 7, 180].min
      elsif effect[:kind] == :smash
        effect[:sprite].zoom_x += (1.18 - effect[:sprite].zoom_x) * 0.22
        effect[:sprite].zoom_y = effect[:sprite].zoom_x
        effect[:sprite].angle *= 0.9
        effect[:sprite].opacity = [effect[:life] * 8, 255].min
      elsif effect[:kind] == :finish_title
        age = effect[:max_life] - effect[:life]
        effect[:sprite].zoom_x += (1.0 - effect[:sprite].zoom_x) * 0.2
        effect[:sprite].zoom_y = effect[:sprite].zoom_x
        if age < 10
          effect[:sprite].opacity = [age * 28, 255].min
        elsif effect[:life] < 14
          effect[:sprite].opacity = effect[:life] * 18
        else
          effect[:sprite].opacity = 255
        end
      elsif effect[:kind] == :flash
        effect[:sprite].opacity = [effect[:life] * 10, 170].min
      else
        effect[:sprite].y -= 0.7
        effect[:sprite].opacity = [effect[:life] * 7, 255].min
      end
      if effect[:life] <= 0
        dispose_custom_sprite(effect[:sprite])
        true
      else
        false
      end
    end
  end

  def finish_battle(result, title)
    return if @state == :result
    clear_projectile
    clear_attack_buttons
    clear_finisher_balls
    clear_pattern_notes
    $game_variables[WCF_SNOWBALL::RESULT_VARIABLE] = result
    WCF_SNOWBALL.record_win(@opponent_id) if result > 0
    @state = :result
    @state_timer = 0
    subtitle = result == 0 ? "Z/Enter hoặc X/Esc: quay lại" : "Z/Enter: quay lại bữa tiệc giáng sinh"
    set_banner(title, subtitle)
    RPG::SE.new(result > 0 ? "Applause1" : "Cancel1", 80, 100).play
  end

  def update_result
    @state_timer += 1
    return unless @state_timer > 20
    SceneManager.return if Input.trigger?(Input::C) || Input.trigger?(Input::B)
  end

  def pressed_direction
    WCF_SNOWBALL::KEYS.each do |key|
      return key if Input.trigger?(WCF_SNOWBALL::INPUTS[key])
    end
    nil
  end

  def triggered_directions
    WCF_SNOWBALL::KEYS.select { |key| Input.trigger?(WCF_SNOWBALL::INPUTS[key]) }
  end

  def held_directions
    WCF_SNOWBALL::KEYS.select { |key| Input.press?(WCF_SNOWBALL::INPUTS[key]) }
  end

  def directions_held?
    !held_directions.empty?
  end

  def make_snowball_bitmap(key, size)
    bitmap = Bitmap.new(size, size)
    center = size / 2
    radius = center - 3
    (-radius..radius).each do |dy|
      half = Math.sqrt(radius * radius - dy * dy).to_i
      shade = 235 + ((dy + radius) * 20 / [radius * 2, 1].max)
      bitmap.fill_rect(center - half, center + dy, half * 2 + 1, 1,
                       Color.new(shade, [shade + 6, 255].min, 255))
    end
    if key
      bitmap.font.size = [size - 18, 22].max
      bitmap.font.bold = true
      bitmap.font.outline = true
      bitmap.font.color = Color.new(35, 98, 180)
      bitmap.draw_text(bitmap.rect, WCF_SNOWBALL::ARROWS[key], 1)
    end
    bitmap
  end

  def make_timing_ring_bitmap(size,color)
    bitmap=Bitmap.new(size,size)
    center=size/2; radius=center-3
    120.times do |i|
      angle=i*Math::PI*2/120
      x=center+Math.cos(angle)*radius
      y=center+Math.sin(angle)*radius
      bitmap.fill_rect(x.to_i-1,y.to_i-1,3,3,color)
    end
    bitmap
  end

  def make_button_bitmap(key, state)
    bitmap = Bitmap.new(46, 46)
    draw_button(bitmap, key, state)
    bitmap
  end

  def draw_button(bitmap, key, state)
    colors = {
      :waiting => Color.new(45, 95, 175),
      :current => Color.new(255, 190, 45),
      :done => Color.new(45, 205, 135)
    }
    color = colors[state]
    center = 23
    20.downto(1) do |radius|
      alpha = 150 + (20 - radius) * 5
      (-radius..radius).each do |dy|
        half = Math.sqrt(radius * radius - dy * dy).to_i
        bitmap.fill_rect(center - half, center + dy, half * 2 + 1, 1,
          Color.new(color.red, color.green, color.blue, alpha))
      end
    end
    keys = Array(key)
    bitmap.font.size = keys.size > 1 ? 17 : 27
    bitmap.font.bold = true
    bitmap.font.outline = true
    bitmap.font.color = Color.new(255, 255, 255)
    bitmap.draw_text(bitmap.rect, keys.map { |item| WCF_SNOWBALL::ARROWS[item] }.join, 1)
  end

  #--------------------------------------------------------------------------
  # Unique opponent mechanics
  #--------------------------------------------------------------------------
  def begin_shylvie_return
    clear_attack_buttons
    @state = :shylvie_return
    @return_hits = 0
    @return_direction = :to_enemy
    @return_progress = 0.0
    @return_key = WCF_SNOWBALL::KEYS[rand(4)]
    @projectile = custom_sprite(make_snowball_bitmap(nil, 34), 52)
    @projectile.ox = @projectile.oy = 17
    @projectile.x = PLAYER_X + 24
    @projectile.y = GROUND_Y - 48
    perform_throw_pose
    play_animation_at(153, PLAYER_X + 18, GROUND_Y - 42)
    set_banner("PHẢN ĐÒN", "Phản PERFECT cho tới khi Shylvie không đỡ nổi")
  end

  def update_shylvie_return
    speed = 0.018 + @return_hits * 0.005
    @return_progress += speed
    from = @return_direction == :to_enemy ? PLAYER_X + 24 : ENEMY_X - 24
    target = @return_direction == :to_enemy ? ENEMY_X - 24 : PLAYER_X + 24
    @projectile.x = from + (target - from) * @return_progress
    @projectile.y = GROUND_Y - 48 - Math.sin(@return_progress * Math::PI) * 58
    if @return_ring
      @return_ring.x=@projectile.x; @return_ring.y=@projectile.y
      target=@return_size.to_f/(@return_size+20)
      scale=1.8-(1.8-target)*(@return_progress/0.78)
      @return_ring.zoom_x=@return_ring.zoom_y=[scale,0.50].max
      @return_ring.color.set(255,210,40,120) if @return_progress>=0.78
    end
    if @return_direction == :to_player
      pressed = pressed_direction
      if pressed
        if pressed == @return_key && @return_progress >= 0.78
          award_perfect
          @return_hits += 1
          show_judge("PERFECT!", Color.new(255,226,65))
          show_balloon(:player,12)
          reflect_shylvie_ball(:to_enemy)
          return
        else
          @misses += 1
          show_judge("MISS", Color.new(255,82,92))
        end
      end
    end
    return unless @return_progress >= 1.0
    if @return_direction == :to_enemy
      if @return_hits >= 4
        damage_unique_enemy(14, :perfect)
        end_unique_attack
      else
        start_enemy_snow_action("$Snow_Defend",18)
        play_animation_at(150, ENEMY_X - 20, GROUND_Y - 48)
        show_balloon(:enemy, 12)
        reflect_shylvie_ball(:to_player)
      end
    else
      @player_hp = [@player_hp - 6, 0].max
      spawn_snow_splash(PLAYER_X + 15, GROUND_Y - 38, 16)
      refresh_hud
      @player_hp <= 0 ? start_enemy_finisher : end_unique_attack
    end
  end

  def reflect_shylvie_ball(direction)
    @return_direction = direction
    @return_progress = 0.0
    @return_key = WCF_SNOWBALL::KEYS[rand(4)]
    size = 34 + @return_hits * 9
    dispose_custom_sprite(@projectile)
    dispose_custom_sprite(@return_ring) if @return_ring
    @return_ring=nil
    key = direction == :to_player ? @return_key : nil
    @projectile = custom_sprite(make_snowball_bitmap(key, size), 52)
    @projectile.ox = @projectile.oy = size / 2
    @return_size=size
    @projectile.x = direction == :to_player ? ENEMY_X - 24 : PLAYER_X + 24
    @projectile.y = GROUND_Y - 48
    if direction==:to_player
      @return_ring=custom_sprite(make_timing_ring_bitmap(size+20,Color.new(115,225,255)),54)
      @return_ring.ox=@return_ring.oy=(size+20)/2
      @return_ring.x=@projectile.x; @return_ring.y=@projectile.y
    end
    play_animation_at(direction == :to_player ? 152 : 153, @projectile.x, @projectile.y)
  end

  def begin_leo_slash
    clear_attack_buttons
    @state = :leo_slash
    @slash_timer = 210
    @slash_count = 0
    @slash_key = WCF_SNOWBALL::KEYS[rand(4)]
    @slash_window = false
    @slash_failed = false
    @projectile = custom_sprite(make_snowball_bitmap(nil, 52), 50)
    @projectile.ox = @projectile.oy = 26
    @projectile.x = PLAYER_X + 24; @projectile.y = GROUND_Y - 50
    perform_throw_pose; play_animation_at(153, PLAYER_X + 18, GROUND_Y - 42)
    start_enemy_snow_action("$Snow_Defend",210)
    set_banner("NHÁT CHÉM KHÔNG GIAN", "Bấm phím ngay khi phím hiện ra để cast phép bảo vệ cầu tuyết khỏi lưỡi kiếm của Leo")
  end

  def update_leo_slash
    @slash_timer -= 1
    progress = (210 - @slash_timer) / 210.0
    @projectile.x = PLAYER_X + 24 + (ENEMY_X - PLAYER_X - 48) * progress
    @projectile.y = GROUND_Y - 50 - Math.sin(progress * Math::PI) * 48
    if [165, 120, 75, 30].include?(@slash_timer)
      @slash_key = WCF_SNOWBALL::KEYS[rand(4)]
      @slash_window = true; @slash_deadline = 32
      show_qte_key(@slash_key, @projectile.x, @projectile.y - 48)
      show_time_ring(@projectile.x, @projectile.y, Color.new(255,45,55))
      show_red_slash(@projectile.x,@projectile.y)
      RPG::SE.new("Slash1",90,90+rand(20)).play
    end
    if @slash_window
      @slash_deadline -= 1
      key = pressed_direction
      if key
        if key == @slash_key
          @slash_count += 1; @slash_window = false
          award_perfect
          @projectile.y += rand(2) == 0 ? -22 : 22
          show_judge("PERFECT!", Color.new(255,226,65))
          show_balloon(:player,12); RPG::SE.new("Evasion1",82,125).play
          perform_dodge(key,true)
        else
          @slash_failed = true
        end
      elsif @slash_deadline <= 0
        @slash_failed = true
      end
      if @slash_failed
        play_animation_at(150, @projectile.x, @projectile.y)
        split_snowball(@projectile.x, @projectile.y)
        clear_projectile
        end_unique_attack
        return
      end
    end
    return unless @slash_timer <= 0
    damage_unique_enemy(@slash_count >= 4 ? 15 : 0, :perfect)
    end_unique_attack
  end

  def begin_hakase_orbit
    clear_projectile
    @state = :hakase_orbit
    @orbit_timer = 75 + rand(90)
    @orbit_angle = 0.0
    @orbit_balls = []
    6.times do |i|
      key = WCF_SNOWBALL::KEYS[rand(4)]
      sprite = custom_sprite(make_snowball_bitmap(nil, 34), 48)
      sprite.ox = sprite.oy = 17
      @orbit_balls << {:sprite=>sprite, :key=>key, :offset=>i * Math::PI / 3}
    end
    play_animation_at(151, ENEMY_X, GROUND_Y - 45)
    set_banner("MA PHÁP TUYẾT", "Các quả cầu tuyết sẽ có tốc độ và kích cỡ ngẫu nhiên!")
  end

  def update_hakase_orbit
    @orbit_timer -= 1
    @orbit_angle += 0.075
    @orbit_balls.each do |ball|
      angle = @orbit_angle + ball[:offset]
      ball[:sprite].x = ENEMY_X + Math.cos(angle) * 76
      ball[:sprite].y = GROUND_Y - 58 + Math.sin(angle) * 48
    end
    return unless @orbit_timer <= 0
    ball = @orbit_balls.shift
    @orbit_balls.each { |b| dispose_custom_sprite(b[:sprite]) }
    @orbit_balls.clear
    @projectile = ball[:sprite]
    @ball_key = ball[:key]
    # Reveal the arrow only when the random orbit stops.
    dispose_custom_sprite(@projectile)
    @projectile = custom_sprite(make_snowball_bitmap(@ball_key, 38), 50)
    @projectile.ox = @projectile.oy = 19
    @projectile.x = ENEMY_X - 22; @projectile.y = GROUND_Y - 48
    @ball_total = 34; @ball_frame = 0; @ball_arc = 35; @pending_contact=nil; @miss_announced=false; @miss_speedup=1
    @state = :defense
    perform_enemy_throw
  end

  def begin_hakase_push
    clear_attack_buttons
    @state = :hakase_push
    @push_power = 50.0
    @push_velocity = 0.0
    @push_hold_frames = 0
    @push_elapsed = 0
    @push_key = WCF_SNOWBALL::KEYS[rand(4)]
    @push_change = 72
    @projectile = custom_sprite(make_snowball_bitmap(@push_key, 58), 50)
    @projectile.ox = @projectile.oy = 29
    @projectile.x = Graphics.width / 2; @projectile.y = GROUND_Y - 70
    @attack_sequence=[@push_key]; @attack_index=0
    @attack_timer=@push_power; @attack_timer_max=100
    create_attack_buttons
    @attack_buttons[0].x=@projectile.x
    @attack_buttons[0].y=@projectile.y-68
    @timer_sprite.y=318 if @timer_sprite
    start_enemy_snow_action("$Snow_Defend",9999)
    play_animation_at(151, Graphics.width / 2, GROUND_Y - 70)
    set_banner("ĐẤU MA LỰC", "Giữ đúng phím để đẩy cầu tuyết về phía Hakase")
  end

  def update_hakase_push
    @push_elapsed += 1
    @push_change -= 1
    if @push_change <= 0
      @push_key = WCF_SNOWBALL::KEYS[rand(4)]
      @attack_sequence[0]=@push_key; @push_change=60+rand(31)
      @push_hold_frames=0
      old_bitmap=@projectile.bitmap
      @projectile.bitmap=make_snowball_bitmap(@push_key,58)
      old_bitmap.dispose if old_bitmap && !old_bitmap.disposed?
      refresh_attack_buttons
      show_time_ring(@projectile.x,@projectile.y,Color.new(110,100,255))
    end
    held=held_directions
    if held.size==1 && held[0]==@push_key
      @push_hold_frames += 1
      # The longer the correct direction is held, the faster the ball moves.
      acceleration=0.055+[ @push_hold_frames*0.0015, 0.09 ].min
      @push_velocity=[@push_velocity+acceleration,2.8].min
    else
      @push_hold_frames=0
      # Hakase begins gently. His pressure grows during a long struggle and
      # starts slightly stronger in later rounds.
      round_force=[@round-1,5].min*0.004
      time_force=[@push_elapsed/600.0*0.025,0.035].min
      base_force=0.018+round_force+time_force
      acceleration=held.empty? ? base_force : base_force*2.25
      @push_velocity=[@push_velocity-acceleration,-2.4].max
    end
    @push_velocity *= 0.985
    @push_power += @push_velocity
    @push_power=[[ @push_power,0.0].max,100.0].min
    push_left=PLAYER_X+35
    push_right=ENEMY_X-35
    @projectile.x=push_left+(push_right-push_left)*(@push_power/100.0)
    @projectile.zoom_x=@projectile.zoom_y=0.45+@push_power/100.0
    if @attack_buttons[0]
      @attack_buttons[0].x=@projectile.x
      @attack_buttons[0].y=@projectile.y-68
    end
    @attack_timer=@push_power; refresh_attack_timer
    if @push_power >= 100
      clear_attack_buttons
      show_judge("PERFECT!",Color.new(255,226,65))
      award_perfect
      damage_unique_enemy(15,:perfect)
      end_unique_attack
    elsif @push_power <= 0
      clear_attack_buttons
      show_judge("MISS",Color.new(255,82,92))
      @misses+=1
      @player_hp=[@player_hp-WCF_SNOWBALL::MISS_DAMAGE,0].max
      spawn_snow_splash(PLAYER_X+18,GROUND_Y-38,18)
      RPG::SE.new("Damage1",85,100).play
      refresh_snow_pile; refresh_hud
      return start_enemy_finisher if @player_hp<=0
      end_unique_attack
    end
  end

  def damage_unique_enemy(damage, result)
    return if damage <= 0
    @enemy_hp=[@enemy_hp-damage,0].max
    perform_enemy_hit(result); spawn_snow_splash(ENEMY_X-18,GROUND_Y-38,20)
    @enemy_sprite.color.set(255,70,70,170); @enemy_hit_timer=14
    show_balloon(:enemy,result==:perfect ? 11 : 6)
    show_judge("-#{damage} HP",Color.new(255,225,70),:enemy)
    RPG::SE.new("Damage2",85,95).play
    refresh_hud
  end

  def award_perfect
    @perfects+=1
    @player_hp=[@player_hp+3,WCF_SNOWBALL::PLAYER_HP].min
    refresh_hud
  end

  def end_unique_attack
    restore_enemy_character if @enemy_action_active || @shylvie_throw_active
    clear_projectile
    clear_attack_buttons
    if @enemy_hp <= 0
      start_player_finisher
    else
      @state=:ready; @state_timer=65
      set_banner("LƯỢT TIẾP THEO","Đối thủ đang chuẩn bị tuyết")
    end
  end

  def split_snowball(x,y)
    [-1,1].each do |dir|
      sprite=custom_sprite(make_snowball_bitmap(nil,28),55)
      sprite.ox=sprite.oy=14; sprite.x=x; sprite.y=y
      @effects << {:sprite=>sprite,:life=>28,:kind=>:split,:vx=>dir*7,:vy=>-4}
    end
  end

  def show_qte_key(key,x,y)
    sprite=custom_sprite(make_button_bitmap(key,:current),115)
    sprite.ox=sprite.oy=23; sprite.x=x; sprite.y=y
    @effects << {:sprite=>sprite,:life=>28,:kind=>:text}
  end

  def show_red_slash(x,y)
    bitmap=Bitmap.new(280,34)
    bitmap.fill_rect(0,10,280,14,Color.new(255,25,35,235))
    bitmap.fill_rect(0,15,280,4,Color.new(255,220,220,255))
    sprite=custom_sprite(bitmap,112); sprite.ox=140; sprite.oy=17
    sprite.x=x; sprite.y=y; sprite.angle=-35+rand(71)
    sprite.zoom_x=sprite.zoom_y=1.35
    @effects << {:sprite=>sprite,:life=>24,:kind=>:slash}
  end

  def show_time_ring(x,y,color)
    bitmap=Bitmap.new(96,96)
    96.times do |i|
      angle=i*Math::PI*2/96
      px=48+Math.cos(angle)*42; py=48+Math.sin(angle)*42
      bitmap.fill_rect(px.to_i,py.to_i,3,3,color)
    end
    sprite=custom_sprite(bitmap,110); sprite.ox=sprite.oy=48; sprite.x=x; sprite.y=y
    sprite.zoom_x=sprite.zoom_y=1.8
    @effects << {:sprite=>sprite,:life=>36,:kind=>:ring}
  end

  def play_animation_at(animation_id,x,y)
    animation=$data_animations[animation_id] rescue nil
    return unless animation
    sprite=Sprite_Base.new
    sprite.bitmap=Bitmap.new(1,1); sprite.x=x; sprite.y=y; sprite.z=108
    sprite.start_animation(animation,false)
    @animation_sprites << sprite
  end

  def update_animation_sprites
    @animation_sprites.delete_if do |sprite|
      sprite.update
      unless sprite.animation?
        bitmap=sprite.bitmap; sprite.dispose; bitmap.dispose if bitmap && !bitmap.disposed?
        true
      else
        false
      end
    end
  end

  def custom_sprite(bitmap, z)
    sprite = Sprite.new
    sprite.bitmap = bitmap
    sprite.z = z
    sprite
  end

  def dispose_custom_sprite(sprite)
    return unless sprite
    bitmap = sprite.bitmap
    sprite.dispose unless sprite.disposed?
    bitmap.dispose if bitmap && !bitmap.disposed?
  end

  def clear_projectile
    dispose_custom_sprite(@projectile) if @projectile
    dispose_custom_sprite(@projectile_ring) if @projectile_ring
    dispose_custom_sprite(@return_ring) if @return_ring
    @projectile = nil
    @projectile_ring = nil
    @return_ring = nil
  end

  def clear_attack_buttons
    @attack_buttons.each { |sprite| dispose_custom_sprite(sprite) }
    @attack_buttons.clear
    dispose_custom_sprite(@timer_sprite) if @timer_sprite
    @timer_sprite = nil
    @timer_bitmap = nil
  end

  def clear_finisher_balls
    return unless @finisher_balls
    @finisher_balls.each { |ball| dispose_custom_sprite(ball[:sprite]) }
    @finisher_balls.clear
  end
end
