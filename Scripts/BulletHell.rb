#==============================================================================#
#  Christmas Fiesta - Invader Mini Game (Merged Custom Version)
#------------------------------------------------------------------------------#
#  For: RPG Maker VX Ace
#  Base: Galv's Invader Mini Game
#  Custom merged version for this project
#------------------------------------------------------------------------------#
#  This version is no longer the old "random survival shooter" style.
#  It has been rebuilt into a more pattern-based arcade / bullet hell style.
#
#  Main Features
#  -------------
#  - 3 player weapon types with power levels up to 6
#  - Penetrating Lazor level 6 can become a toggle beam
#  - Pattern-based enemy movement and shooting
#  - All 5 enemy types can spawn from the start, with weighted early balance
#  - Enemy gimmicks and special abilities by alien type
#  - Powerups, bonus shields, nuke item, score, and high score support
#  - Alien2 global speed aura with red screen tint feedback
#  - Alien4 / Alien4S reflection state with reflected bullet graphic
#
#------------------------------------------------------------------------------#
#  CONTROLS
#------------------------------------------------------------------------------#
#  Left / Right / Up / Down
#      Move the ship (diagonal movement supported)
#
#  Z / Enter / Space
#      Fire current weapon
#
#  If using Penetrating Lazor Lv6:
#      Press shoot once to turn beam ON
#      Press shoot again to turn beam OFF
#
#  A
#      Use held item (currently nuke)
#
#  X / Esc
#      Exit the mini game
#
#------------------------------------------------------------------------------#
#  PLAYER WEAPONS
#------------------------------------------------------------------------------#
#  Weapon Type 0 : Lazors
#      Standard forward shots.
#      Higher levels increase shot count.
#      Level 6 fires 6 lazors.
#
#  Weapon Type 1 : Lazor Ball
#      Multi-direction projectile weapon.
#      Level 6 still fires 5 balls, and each can bounce once after first hit.
#
#  Weapon Type 2 : Penetrating Lazor
#      Piercing shot weapon.
#      Level 6 becomes a toggle beam that continuously destroys enemies
#      in a line above the player until turned off.
#
#------------------------------------------------------------------------------#
#  POWERUPS
#------------------------------------------------------------------------------#
#  Shield
#      Fully restores player shields.
#      If shields are already full, adds bonus shields instead.
#
#  Zzzz
#      Reduces current enemy spawn/shoot pressure by half.
#      It does NOT fully reset the game anymore.
#
#  Nuke
#      Stored item. Press A to destroy all enemies currently on screen.
#
#  Lazors
#      Switches to Lazor weapon, or increases Lazor level if already equipped.
#
#  Lazor Ball
#      Switches to Lazor Ball weapon, or increases its level if already equipped.
#
#  Penetrating Lazor
#      Switches to Penetrating Lazor, or increases its level if already equipped.
#
#------------------------------------------------------------------------------#
#  ENEMY TYPES
#------------------------------------------------------------------------------#
#  Alien0
#      Basic enemy.
#      On death, splits into 2 smaller mini alien0.
#
#  Alien1
#      Drops a bad item on death.
#      The bad item reverses player controls for a short time if picked up.
#
#  Alien2
#      Supports other enemies.
#      While at least one alien2 is alive, other enemies move faster.
#      The screen gets a slight red tint while this aura is active.
#
#  Alien3
#      Advanced enemy.
#      Keeps 3 orbiting bullets around itself using orbit_bullet.png.
#
#  Alien4 / Alien4S
#      Alternates between normal and shield-reflect state.
#      In Alien4S state, most player shots are reflected back at the player.
#      Reflected bullets use elazor_reflect.png.
#      Penetrating Lazor Lv6 beam is not reflected.
#
#------------------------------------------------------------------------------#
#  REQUIRED GRAPHICS
#------------------------------------------------------------------------------#
#  Graphics/Invaders/backdrop.png
#  Graphics/Invaders/alien0.png
#  Graphics/Invaders/alien1.png
#  Graphics/Invaders/alien2.png
#  Graphics/Invaders/alien3.png
#  Graphics/Invaders/alien4.png
#  Graphics/Invaders/alien4S.png
#  Graphics/Invaders/lazor.png
#  Graphics/Invaders/lazor_ball.png
#  Graphics/Invaders/lazor_pen.png
#  Graphics/Invaders/elazor.png
#  Graphics/Invaders/elazor_reflect.png
#  Graphics/Invaders/orbit_bullet.png
#  Graphics/Invaders/powerup_bad.png
#  plus your normal powerup / explosion / UI graphics used by the base script
#
#------------------------------------------------------------------------------#
#  SCRIPT CALL
#------------------------------------------------------------------------------#
#  SceneManager.call(Scene_Invaders)
#------------------------------------------------------------------------------#

($imported ||= {})["Galv_Invaders"] = true
module Galv_SI

#------------------------------------------------------------------------------#
#  SCRIPT SETTINGS
#------------------------------------------------------------------------------#

  #--------------------------------------------------------------------------#
  # PLAYER / GAMEFLOW
  #--------------------------------------------------------------------------#

  PLAYER_SHIELDS = 10     # Base shield amount before game over
  MAX_SHOTS      = 15     # Max normal player projectiles on screen at once
  MAX_GUN_LEVEL    = 6
  MAX_GUN_LEVEL_EX = MAX_GUN_LEVEL
  Max_Gun_Level    = MAX_GUN_LEVEL

  SCORE_VAR      = 19     # Game variable used for current score
  HIGH_SCORE_VAR = 20     # Game variable used for saved high score

  SHIP_SPEED       = 5    # Player move speed
  LAZOR_SPEED      = 5    # Standard player shot speed
  PENETRATE_SPEED  = 4    # Moving penetrate shot speed before Lv6 beam mode

  LAZOR_DAMAGE     = 1    # Damage to player from enemy bullets / reflected shots
  COLLIDE_DAMAGE   = 1    # Damage to player from colliding with enemy

  DESTROY_PUPS     = false  # If true, player shots can destroy normal powerups

  #--------------------------------------------------------------------------#
  # PLAYER WEAPON / BEAM SETTINGS
  #--------------------------------------------------------------------------#

  TOGGLE_BEAM_WIDTH   = 80   # Actual hitbox width of Penetrating Lazor Lv6 beam
  TOGGLE_BEAM_VIS_X   = 3.0   # Beam graphic horizontal scale
  TOGGLE_BEAM_VIS_Y   = 24.0  # Beam graphic vertical scale
  BEAM_TOP_OFFSET     = 8     # Vertical offset so beam appears from top of ship

  #--------------------------------------------------------------------------#
  # ENEMY CORE BALANCE
  #--------------------------------------------------------------------------#

  ENEMY_BASE_HP       = 1     # HP for all main enemy types 0..4
  ENEMY_BASE_SCORE    = 2     # Score gained for killing a normal enemy

  # Spawn pacing by game time
  START_SPAWN_MIN     = 80
  START_SPAWN_MAX     = 120

  MID_SPAWN_MIN       = 60
  MID_SPAWN_MAX       = 90

  LATE_SPAWN_MIN      = 42
  LATE_SPAWN_MAX      = 68

  END_SPAWN_MIN       = 30
  END_SPAWN_MAX       = 52

  # Max enemy count on screen by game time
  START_ENEMY_CAP     = 7
  MID_ENEMY_CAP       = 10
  LATE_ENEMY_CAP      = 13
  END_ENEMY_CAP       = 16

  SPLIT_MIN_TIME      = 10    # Alien0 starts splitting only after this many seconds

  #--------------------------------------------------------------------------#
  # ENEMY MOVEMENT / PATTERN TUNING
  #--------------------------------------------------------------------------#

  PATTERN_MARGIN      = 96

  SINE_FREQ           = 0.05
  SINE_AMP_0          = 36
  SINE_AMP_1          = 52
  SINE_AMP_2          = 68
  SINE_AMP_3          = 84

  ORBIT_RADIUS_MIN    = 28
  ORBIT_RADIUS_MAX    = 56
  ORBIT_SPEED_MIN     = 0.05
  ORBIT_SPEED_MAX     = 0.09
  ORBIT_DRIFT_Y       = 0.18

  ZIGZAG_SWITCH_MIN   = 24
  ZIGZAG_SWITCH_MAX   = 42
  ZIGZAG_LANE_STEP    = 80

  DIVE_PAUSE          = 18
  DIAGONAL_SLOTS      = 5

  #--------------------------------------------------------------------------#
  # ENEMY SPECIAL ABILITIES
  #--------------------------------------------------------------------------#

  MINI_ALIEN_SCALE    = 0.65  # Alien0 split child size
  MINI_ALIEN_SPEED    = 1.7   # Alien0 split child speed

  CONFUSE_FRAMES      = 180   # Alien1 bad item reverse-controls duration
  BAD_PUP_SPEED       = 2     # Falling speed of alien1 bad item

  ALIEN2_AURA_MULT    = 1.35  # Speed multiplier applied while any alien2 is alive
  AURA_TINT_OPACITY   = 40    # Red screen tint opacity during alien2 aura

  ORBIT_RADIUS        = 34    # Alien3 orbit bullet radius
  ORBIT_SPEED         = 0.06  # Alien3 orbit bullet rotation speed
  ORBIT_CONTACT_DMG   = 1     # Damage if player touches alien3 orbit bullet

  ALIEN4_SWAP_TIME    = 180   # Frames before alien4 swaps alien4 <-> alien4S

  #--------------------------------------------------------------------------#
  # ENEMY SHOT PATTERNS
  #--------------------------------------------------------------------------#

  BULLET_SPEED_SLOW   = 2.8
  BULLET_SPEED_MED    = 3.6
  BULLET_SPEED_FAST   = 4.8

  SHOT_AIMED_COOLDOWN  = 70
  SHOT_SPREAD_COOLDOWN = 90
  SHOT_RING_COOLDOWN   = 110
  SHOT_LINE_COOLDOWN   = 80
  SHOT_STREAM_COOLDOWN = 28

  ELAZOR_SPEED         = 5    # Base enemy bullet speed fallback

  #--------------------------------------------------------------------------#
  # POWERUPS / ITEM BALANCE
  #--------------------------------------------------------------------------#

  RESET_PUP           = 80    # Seconds between Zzzz powerup appearances
  RESET_RATIO         = 0.5   # Zzzz now halves current pressure instead of full reset
  POWERUP_CHANCE      = 994   # Lower = more frequent normal powerup spawn

  #--------------------------------------------------------------------------#
  # SOUND
  #--------------------------------------------------------------------------#

  SE   = ["Attack2",60,150]    # Player Lazor
  SE1  = ["Heal5",60,160]      # Player Lazor Ball
  SE2  = ["Attack3",60,140]    # Player Penetrating Lazor / beam toggle
  NSE  = ["Explosion3",80,100] # Nuke

  PSE  = ["Damage5",60,150]    # Player damaged
  KSE  = ["Explosion7",60,100] # Player destroyed

  BSE  = ["Down4",80,150]      # Bonus shield gain
  PUSE = ["Item1",80,150]      # Powerup obtained

  ASE  = ["Attack2",80,110]    # Enemy shooting / reflect sound
  DSE  = ["Fire3",40,150]      # Enemy destroyed

  SOUND_TIMER = 5              # Prevents enemy shot sound spam

  #--------------------------------------------------------------------------#
  # MUSIC
  #--------------------------------------------------------------------------#

  BGM_LIST = [
    ["Battle2",80,100],
    ["Battle3",80,100],
    ["Battle4",80,100]
  ]

#------------------------------------------------------------------------------#
#  END OF SCRIPT SETTINGS
#------------------------------------------------------------------------------#
end

#-------------------------------------------------------------------------------
#  CACHE
#-------------------------------------------------------------------------------

module Cache
  def self.space(filename)
    load_bitmap("Graphics/Invaders/", filename)
  end
end # module Cache

#-------------------------------------------------------------------------------
#  SCENE
#-------------------------------------------------------------------------------

class Scene_Invaders < Scene_Base
  def start
    $game_system.save_bgm
    super
    SceneManager.clear
    Graphics.freeze
    initialize_game
  end

  def initialize_game
    play_bgm
    init_variables
    create_backdrop
    create_sprites
    create_stats
  end

  def play_bgm
    m = Galv_SI::BGM_LIST[rand(Galv_SI::BGM_LIST.count)]
    RPG::BGM.new(m[0],m[1],m[2]).play
  end

  def init_variables
    @nukeall = false
    @sound_timer = Galv_SI::SOUND_TIMER
    @enemy_wave = 1
    @guns = 1
    @gun_type = 0
    @bonus_shields = 0
    @reset_pup = Galv_SI::RESET_PUP * 60
    @player_shields = Galv_SI::PLAYER_SHIELDS
    $game_variables[Galv_SI::SCORE_VAR] = 0
    @plazors = []
    @elazors = []
    @enemies = []
    @explodes = []
    @pups = []
    @spawn_timer = rand(Galv_SI::SPAWN_SPEED)
    @ticker = 100
    @game_time = 0
    @alien_count = 0
    @pups_count = 0
    @difficulty = 0.to_f
    @shoot_difficulty = 0.to_f
    @dead = false
  end

  def create_backdrop
    @backdrop = Plane.new
    @backdrop.bitmap = Cache.space("backdrop")
    @backdrop.z = -1
    @flash = Sprite.new
    @flash.bitmap = Bitmap.new(Graphics.width,Graphics.height)
    @flash.bitmap.fill_rect(@flash.bitmap.rect,Color.new(255,255,255))
    @flash.z = 2000
    @flash.opacity = 0
  end

  def create_sprites
    @player = Sprite_Player.new(@viewport1)
    @item_held = Sprite.new
    @item_held.x = Graphics.width / 4 + 40
    @item_held.y = 15
    @item_held.z = 100
  end

  def draw_item_held
    @item_held.bitmap.dispose if @item_held.bitmap
    @item_held.opacity = 255
    return @item_held.opacity = 0 if @item.nil?
    @item_held.bitmap = Cache.space("item_" + @item.to_s)
  end

  def create_stats
    @score_window = Window_InvaderScore.new
    @score_window
  end

  def play_time
    @game_time / 60
  end

  def update
    update_flash
    @game_time += 1
    @reset_pup -= 1
    super
    update_backdrop
    update_player
    update_splosions
    update_plazors
    update_elazors
    update_enemies
    update_pups
    if !@dead
      update_spawn
    else
      update_game_over
    end
  end

  def update_flash
    @flash.opacity -= 3 if @flash.opacity > 0
  end

  def update_backdrop
    @backdrop.oy -= 1
  end

  def update_spawn
    if @spawn_timer <= 0
      t = alien_type
      @enemies << Sprite_Alien.new(@viewport1, @alien_count, t)
      @alien_count += 1
      @spawn_timer = 50 + rand(Galv_SI::SPAWN_SPEED) / 2 - @difficulty
    end
    @ticker -= 1
    if @ticker <= 0
      @difficulty += 1
      @shoot_difficulty += 0.2
      @ticker = 100
    end
    @spawn_timer -= 1
  end

  def alien_type
    t = play_time
    if t < Galv_SI::LEVEL2
      return 0
    elsif t < Galv_SI::LEVEL3
      r = rand(100)
      return r < 50 ? 0 : 1
    elsif t < Galv_SI::LEVEL4
      r = rand(100)
      return r < 33 ? 0 : r < 66 ? 1 : 2
    else
      r = rand(100)
      return r < 25 ? 0 : r < 50 ? 1 : r < 75 ? 2 : 3
    end
  end

  def update_player
    @player.update
    update_player_actions
  end

  def init_game_over
    RPG::BGM.fade(10)
    @game_over = Sprite.new
    @game_over.bitmap = Cache.space("game-over")
    @game_over.opacity = 0
    @game_over.z = 500
  end

  def update_game_over
    @game_over.opacity += 3
    if @game_over.opacity >= 255 && Input.trigger?(:C)
      dispose_graphics
      initialize_game
    end
  end

  def update_player_actions
    if Input.trigger?(:C) && !@dead
      return if Galv_SI::MAX_SHOTS * @guns <= @plazors.count
      player_shoot
    end
    if Input.trigger?(:B)
      SceneManager.goto(Scene_Map)
    end
    if Input.trigger?(:X) && @item && !@dead
      @nukeall = true
      RPG::SE.new(Galv_SI::NSE[0],Galv_SI::NSE[1],Galv_SI::NSE[2]).play
      @difficulty *= 0.75
      @flash.opacity = 225
      @item = nil
      draw_item_held
    end
  end

  def player_shoot
    case @gun_type
    when 0  # Normal Lazers
      RPG::SE.new(Galv_SI::SE[0],Galv_SI::SE[1],Galv_SI::SE[2]).play
      case @guns
      when 1
        @plazors << Sprite_Lazor.new(@viewport1,@player.x,@player.y)
      when 2
        2.times { |i|
          @plazors << Sprite_Lazor.new(@viewport1,@player.x - 20 + i * 40,@player.y)
        }
      when 3
        3.times { |i|
          @plazors << Sprite_Lazor.new(@viewport1,@player.x - 20 + i * 20,@player.y)
        }
      when 4
        4.times { |i|
          @plazors << Sprite_Lazor.new(@viewport1,@player.x - 30 + i * 20,@player.y)
        }
      when 5
        5.times { |i|
          @plazors << Sprite_Lazor.new(@viewport1,@player.x - 30 + i * 15,@player.y)
        }
      end
    when 1  # Lazor Ball
      RPG::SE.new(Galv_SI::SE1[0],Galv_SI::SE1[1],Galv_SI::SE1[2]).play
      case @guns
      when 1
        @plazors << Sprite_Lazor.new(@viewport1,@player.x,@player.y,1,0)
      when 2
        2.times { |i|
          @plazors << Sprite_Lazor.new(@viewport1,@player.x,@player.y,1,1 + i)
        }
      when 3,4,5
        @guns.times { |i|
          @plazors << Sprite_Lazor.new(@viewport1,@player.x,@player.y,1,i)
        }
      end
    when 2  # Penetrating Lazor
      RPG::SE.new(Galv_SI::SE2[0],Galv_SI::SE2[1],Galv_SI::SE2[2]).play
      @plazors << Sprite_Lazor.new(@viewport1, @player.x, @player.y, 2, 0, @guns)
    end
  end

  def update_plazors
    @plazors.each_with_index { |lazor,i|
      lazor.update
      if lazor.y < -10
        lazor.dispose
        @plazors.delete_at(i)
      end
    }
  end

  def update_elazors
    @elazors.compact!
    @elazors.each_with_index { |lazor,i|
      next unless lazor
      lazor.update(@player.x, @player.y)
      if lazor.y > Graphics.height || lazor.y < -Graphics.height
        lazor.dispose
        @elazors[i] = nil
      elsif player_hit?(lazor.x,lazor.y)
        damage_player(Galv_SI::LAZOR_DAMAGE)
        lazor.dispose
        @elazors[i] = nil
      end
    }
  end

  def update_enemies
    @sound_timer += 1
    @enemies.each_with_index { |enemy,i|
      next if enemy.nil?
      enemy.update
      if enemy_hit?(enemy) || @nukeall
        enemy.hp -= @nukeall ? enemy.mhp : 1
        if enemy.hp <= 0
          destroy_enemy(enemy.mhp)
          @explodes << Sprite_Splosion.new(@viewport1,enemy.x,enemy.y)
          enemy.dispose
          @enemies[i] = nil
        else
          RPG::SE.new(Galv_SI::PSE[0],Galv_SI::PSE[1],Galv_SI::PSE[2]).play
          enemy.flash(Color.new(255,155,155),20)
        end
      elsif player_hit?(enemy.x,enemy.y)
        destroy_enemy(enemy.mhp)
        @explodes << Sprite_Splosion.new(@viewport1,enemy.x,enemy.y)
        enemy.dispose
        @enemies[i] = nil
        damage_player(Galv_SI::COLLIDE_DAMAGE)
      elsif rand(1000) > (Galv_SI::SHOOT_CHANCE - @shoot_difficulty)
        if @sound_timer >= Galv_SI::SOUND_TIMER
          RPG::SE.new(Galv_SI::ASE[0],Galv_SI::ASE[1],Galv_SI::ASE[2]).play
          @sound_timer = 0
        end
        enemy_shoot(enemy)
      end
    }
    @nukeall = false
  end

  def enemy_shoot(enemy)
    case enemy.type
    when 0 # alien0: single elazor
      @elazors << Sprite_ELazor.new(@viewport1, enemy.x, enemy.y)
    when 1 # alien1: two elazors in a cone
      2.times { |i|
        @elazors << Sprite_ELazor.new(@viewport1, enemy.x, enemy.y, 1 + i)
      }
    when 2 # alien2: three elazors in a cone
      3.times { |i|
        @elazors << Sprite_ELazor.new(@viewport1, enemy.x, enemy.y, i)
      }
    when 3 # alien3: four tracking elazors
      [-60, -20, 20, 60].each { |offset|
        @elazors << Sprite_ELazor.new(@viewport1, enemy.x + offset, enemy.y, 0, 1, enemy.y)
      }
    end
  end

  def update_pups
    if @reset_pup <= 0
      @pups << Sprite_Powerup.new(@viewport1,@pups_count,999)
      @reset_pup = (Galv_SI::RESET_PUP + @enemy_wave) * 60
    end
    if rand(1000) > Galv_SI::POWERUP_CHANCE && !@dead
      @pups << Sprite_Powerup.new(@viewport1,@pups_count,rand(5))
      @pups_count += 1
    end
    @pups.each_with_index { |pup,i|
      next if pup.nil?
      pup.update
      if enemy_hit?(pup,false) && Galv_SI::DESTROY_PUPS
        RPG::SE.new(Galv_SI::DSE[0],Galv_SI::DSE[1],Galv_SI::DSE[2]).play
        @explodes << Sprite_Splosion.new(@viewport1,pup.x,pup.y)
        pup.dispose
        @pups[i] = nil
      elsif player_hit?(pup.x,pup.y)
        do_powerup(pup.type)
        pup.dispose
        @pups[i] = nil
      end
    }
  end

  def do_powerup(type)
    @player.flash(Color.new(155,255,155),20)
    case type
    when 0 # Shield Restore
      RPG::SE.new(Galv_SI::BSE[0],Galv_SI::BSE[1],Galv_SI::BSE[2]).play
      if @player_shields == Galv_SI::PLAYER_SHIELDS
        if @bonus_shields < Galv_SI::PLAYER_SHIELDS
          @bonus_shields += 1
        end
      else
        @player_shields = Galv_SI::PLAYER_SHIELDS
      end
      @score_window.refresh(@player_shields.to_f,@bonus_shields)
    when 1 # Gun Type: 0 (Normal Lazor)
      RPG::SE.new(Galv_SI::PUSE[0],Galv_SI::PUSE[1],Galv_SI::PUSE[2]).play
      if @gun_type != 0
        @gun_type = 0
      elsif @guns < Galv_SI::Max_Gun_Level
        @guns += 1
      end
    when 2 # Gun Type: 1 (Lazor Ball)
      RPG::SE.new(Galv_SI::PUSE[0],Galv_SI::PUSE[1],Galv_SI::PUSE[2]).play
      if @gun_type != 1
        @gun_type = 1
      elsif @guns < Galv_SI::Max_Gun_Level
        @guns += 1
      end
    when 3
      RPG::SE.new(Galv_SI::PUSE[0],Galv_SI::PUSE[1],Galv_SI::PUSE[2]).play
      @item = "nuke"
      draw_item_held
    when 4 # Gun Type: 2 (Penetrating Lazor)
      RPG::SE.new(Galv_SI::PUSE[0],Galv_SI::PUSE[1],Galv_SI::PUSE[2]).play
      if @gun_type != 2
        @gun_type = 2
      elsif @guns < Galv_SI::Max_Gun_Level
        @guns += 1
      end
    when 999 # Reset
      RPG::SE.new(Galv_SI::PUSE[0],Galv_SI::PUSE[1],Galv_SI::PUSE[2]).play
      @difficulty *= Galv_SI::RESET_AMOUNT
      @enemy_wave += 1
    end
  end

  def damage_player(amount)
    RPG::SE.new(Galv_SI::PSE[0],Galv_SI::PSE[1],Galv_SI::PSE[2]).play
    @player.flash(Color.new(255,155,155),20)
    if @bonus_shields > 0
      @bonus_shields = [@bonus_shields - amount,0].max
    else
      @player_shields -= amount
    end
    @score_window.refresh(@player_shields.to_f,@bonus_shields)
    destroy_player if @player_shields <= 0
  end

  def destroy_enemy(score)
    RPG::SE.new(Galv_SI::DSE[0],Galv_SI::DSE[1],Galv_SI::DSE[2]).play
    $game_variables[Galv_SI::SCORE_VAR] += score
    if $game_variables[Galv_SI::SCORE_VAR] > $game_variables[Galv_SI::HIGH_SCORE_VAR]
      $game_variables[Galv_SI::HIGH_SCORE_VAR] += score
    end
    @score_window.refresh(@player_shields.to_f,@bonus_shields)
  end

  def destroy_player
    @player_shields = 0
    @explodes << Sprite_Splosion.new(@viewport1,@player.x,@player.y,2)
    @player.opacity = 0
    @player.x = -100
    RPG::SE.new(Galv_SI::KSE[0],Galv_SI::KSE[1],Galv_SI::KSE[2]).play
    @score_window.refresh(@player_shields.to_f,@bonus_shields)
    init_game_over
    @dead = true
  end

  def update_splosions
    @explodes.each_with_index { |ex,i|
      ex.update
      if ex.finished?
        ex.dispose
        @explodes.delete_at(i)
      end
    }
  end

  def player_hit?(x,y)
    if x.between?(@player.x - player_width / 6, @player.x + player_width / 6) &&
       y.between?(@player.y - player_height / 2, @player.y + player_height / 2)
      return true
    end
    return false
  end

  def enemy_hit?(enemy, kill = true)
    @plazors.each_with_index { |lazor,i|
      half_lw = lazor.hit_width / 2.0
      half_lh = lazor.hit_height / 2.0
      half_ew = enemy.width / 2.0
      half_eh = enemy.height / 2.0
      if (lazor.x - half_lw < enemy.x + half_ew) &&
         (lazor.x + half_lw > enemy.x - half_ew) &&
         (lazor.y - half_lh < enemy.y + half_eh) &&
         (lazor.y + half_lh > enemy.y - half_eh)
        if kill && !lazor.penetrating
          lazor.dispose
          @plazors.delete_at(i)
        end
        return true
      end
    }
    false
  end

  def player_width
    @player.bitmap.width
  end
  def player_height
    @player.bitmap.height
  end

  def terminate
    super
    SceneManager.snapshot_for_background
    dispose_graphics
    $game_system.replay_bgm
  end

  def dispose_graphics
    @item_held.bitmap.dispose if @item_held.bitmap
    @plazors.each { |object| object.dispose if object }
    @elazors.each { |object| object.dispose if object }
    @enemies.each { |object| object.dispose if object }
    @explodes.each { |object| object.dispose if object }
    @pups.each { |object| object.dispose if object }
    @backdrop.bitmap.dispose
    @backdrop.dispose
    @player.bitmap.dispose
    @player.dispose
    if @game_over
      @game_over.bitmap.dispose
      @game_over.dispose
    end
    @score_window.dispose
  end
end # Scene_Invaders < Scene_Base

#-------------------------------------------------------------------------------
#  PLAYER SPRITE
#-------------------------------------------------------------------------------

class Sprite_Player < Sprite
  def initialize(viewport)
    super(viewport)
    init_position
  end

  def init_position
    setup_player_image
  end

  def dispose
    super
  end

  def update
    super
    update_src_rect
    update_position
  end

  def setup_player_image
    @cell = 1
    self.bitmap = Cache.space("player")
    @cw = bitmap.width / 3
    self.src_rect.set(@cell * @cw, 0, @cw, height)
    self.ox = @cw / 2
    self.oy = height
    self.x = Graphics.width / 2
    self.y = Graphics.height / 2  # Center vertically for free movement
  end

  def width
    self.bitmap.width / 3
  end
  def height
    self.bitmap.height
  end

  def update_src_rect
    @cell = 1 if @cell > 3
    sx = @cell * @cw
    self.src_rect.set(sx, 0, @cw, height)
  end

  def update_position
    # Initialize movement deltas
    dx = 0
    dy = 0

    # Check horizontal inputs
    if Input.press?(:LEFT) && !Input.press?(:RIGHT)
      @cell = 0  # Tilt left
      dx -= Galv_SI::SHIP_SPEED
    elsif Input.press?(:RIGHT) && !Input.press?(:LEFT)
      @cell = 2  # Tilt right
      dx += Galv_SI::SHIP_SPEED
    else
      @cell = 1  # Center sprite
    end

    # Check vertical inputs
    if Input.press?(:UP) && !Input.press?(:DOWN)
      dy -= Galv_SI::SHIP_SPEED
    elsif Input.press?(:DOWN) && !Input.press?(:UP)
      dy += Galv_SI::SHIP_SPEED
    end

    # Normalize diagonal movement to maintain consistent speed
    if dx != 0 && dy != 0
      factor = 1.0 / Math.sqrt(2)  # Approximately 0.707
      dx *= factor
      dy *= factor
    end

    # Update position with boundary checks
    self.x += dx
    self.y += dy

    # Ensure player stays within screen bounds
    self.x = [[self.x, width / 2].max, Graphics.width - width / 2].min
    self.y = [[self.y, height / 2].max, Graphics.height - height / 2].min
  end
end # Sprite_Player < Sprite

#-------------------------------------------------------------------------------
#  LAZOR SPRITES
#-------------------------------------------------------------------------------

class Sprite_Lazor < Sprite
  attr_reader :hit_width
  attr_reader :hit_height
  attr_reader :penetrating

  def initialize(viewport,x,y,type = 0,dir = 0, level = 1)
    super(viewport)
    self.x = x
    self.y = y - 20
    @type = type
    @dir = dir
    @level = level
    @penetrating = (@type == 2)
    setup_lazor_image
  end

  def dispose
    super
  end

  def update
    super
    update_position
  end

  def setup_lazor_image
    case @type
    when 0
      self.bitmap = Cache.space("lazor")
      @hit_width = 0
      @hit_height = 0
    when 1
      self.bitmap = Cache.space("lazor_ball")
      @hit_width = 0
      @hit_height = 0
    when 2
      self.bitmap = Cache.space("lazor_pen")
      self.zoom_x = 1 + 0.2 * (@level - 1 + 2)  # Increase width with level
      self.zoom_y = 1
      @hit_width = bitmap.width * self.zoom_x
      @hit_height = 0  # Approximate as thin vertically for hit detection
    end
    self.ox = bitmap.width / 2
    self.oy = bitmap.height / 2
  end

  def update_position
    if @type == 2
      self.y -= Galv_SI::PENETRATE_SPEED
    else
      self.y -= Galv_SI::LAZOR_SPEED
      case @dir
      when 1
        self.x -= Galv_SI::LAZOR_SPEED.to_f / 4
      when 2
        self.x += Galv_SI::LAZOR_SPEED.to_f / 4 + 1
      when 3
        self.x -= Galv_SI::LAZOR_SPEED
      when 4
        self.x += Galv_SI::LAZOR_SPEED
      end
    end
  end
end # Sprite_Lazor < Sprite

#-------------------------------------------------------------------------------
#  ENEMY LAZOR SPRITES
#-------------------------------------------------------------------------------

class Sprite_ELazor < Sprite
  def initialize(viewport, x, y, dir = 0, type = 0, enemy_y = 0)
    super(viewport)
    self.x = x
    self.y = y - 20
    @dir = dir
    @type = type
    @enemy_y = enemy_y
    @move_state = @type == 1 ? 0 : 2 # 0: initial move, 1: pause, 2: tracking
    @initial_move_timer = @type == 1 ? 30 : 0 # 0.5 seconds at 60 FPS
    @pause_timer = @type == 1 ? 60 : 0 # 1 second pause at 60 FPS
    @move_x = 0
    @move_y = 0
    @speed = @type == 1 ? Galv_SI::ELAZOR_SPEED * 3 : Galv_SI::ELAZOR_SPEED # 15 for tracking
    setup_lazor_image
  end

  def dispose
    super
  end

  def update(player_x, player_y)
    super()
    update_position(player_x, player_y)
  end

  def setup_lazor_image
    self.bitmap = Cache.space("elazor")
    self.ox = bitmap.width / 2
    self.oy = bitmap.height / 2
  end

  def update_position(player_x, player_y)
    case @move_state
    when 0 # Initial downward movement
      self.y += Galv_SI::ELAZOR_SPEED
      @initial_move_timer -= 1
      if @initial_move_timer <= 0
        @move_state = 1
        self.y = @enemy_y + 100 # Align at fixed y position
      end
    when 1 # Pause
      @pause_timer -= 1
      if @pause_timer <= 0
        @move_state = 2
        # Calculate direction vector to player
        dx = player_x - self.x
        dy = player_y - self.y
        distance = Math.sqrt(dx**2 + dy**2)
        if distance > 0
          @move_x = dx / distance * @speed
          @move_y = dy / distance * @speed
        else
          @move_x = 0
          @move_y = @speed
        end
      end
    when 2 # Tracking or normal movement
      if @type == 1
        self.x += @move_x
        self.y += @move_y
      else
        self.y += @speed
        case @dir
        when 1
          self.x -= Galv_SI::ELAZOR_SPEED.to_f / 4
        when 2
          self.x += Galv_SI::ELAZOR_SPEED.to_f / 4 + 1
        when 3
          self.x -= Galv_SI::ELAZOR_SPEED
        when 4
          self.x += Galv_SI::ELAZOR_SPEED
        end
      end
    end
  end

  def type
    @type
  end
end # Sprite_ELazor < Sprite

#-------------------------------------------------------------------------------
#  ALIEN SPRITES
#-------------------------------------------------------------------------------

class Sprite_Alien < Sprite
  attr_accessor :hp
  attr_reader :mhp
  attr_reader :type

  def initialize(viewport,id,type = 0)
    super(viewport)
    @type = type
    @id = id
    @move = true   # true is right, false is left
    @ticker = 0
    setup_enemy
    init_position
  end

  def init_position
    self.x = rand(Graphics.width)
    self.y = @type == 3 ? 50 : -10
  end

  def dispose
    super
  end

  def update
    super
    update_move
  end

  def update_move
    case @move
    when true  # Right
      self.x += 1 * (@ticker * 0.06) if self.x <= Graphics.width
    when false # Left
      self.x -= 1 * (@ticker * 0.06) if self.x > 0
    end
    @ticker -= 1
    self.y += @speed
    if @ticker <= 0
      @move = self.x < Graphics.width / 2 ? true : false
      @ticker = rand(90)
    end
  end

  def setup_enemy
    self.bitmap = Cache.space("alien" + @type.to_s)
    self.ox = bitmap.width / 2
    self.oy = bitmap.height / 2

    case @type
    when 0
      @hp = Galv_SI::LEVEL1_HP
      @speed = Galv_SI::LEVEL1_DOWN_SPEED
    when 1
      @hp = Galv_SI::LEVEL2_HP
      @speed = Galv_SI::LEVEL2_DOWN_SPEED
    when 2
      @hp = Galv_SI::LEVEL3_HP
      @speed = Galv_SI::LEVEL3_DOWN_SPEED
    when 3
      @hp = Galv_SI::LEVEL4_HP
      @speed = Galv_SI::LEVEL4_DOWN_SPEED
    end
    @mhp = @hp
  end

  def width
    self.bitmap.width
  end
  def height
    self.bitmap.height
  end
end # Sprite_Alien < Sprite

#-------------------------------------------------------------------------------
#  EXPLOSION SPRITES
#-------------------------------------------------------------------------------

class Sprite_Splosion < Sprite
  def initialize(viewport,x,y,zoom = 1)
    super(viewport)
    self.x = x
    self.y = y
    @timer = 10
    setup_explosion_image(zoom)
  end

  def dispose
    super
  end

  def update
    super
    wait_for_timer
  end

  def setup_explosion_image(zoom)
    self.bitmap = Cache.space("explode")
    self.ox = bitmap.width / 2
    self.oy = bitmap.height / 2
    self.zoom_x = zoom
    self.zoom_y = zoom
  end

  def wait_for_timer
    @finished = true if @timer <= 0
    @timer -= 1
  end

  def finished?
    @finished
  end
end # Sprite_Splosion < Sprite

#-------------------------------------------------------------------------------
#  POWERUP SPRITES
#-------------------------------------------------------------------------------

class Sprite_Powerup < Sprite
  attr_reader :type

  def initialize(viewport,id,type)
    super(viewport)
    @id = id
    @type = type            # 0 heal   1 lazor  2 lazorball  3 nuke  4 penetrate  999 reset
    @speed = rand(1) + 1
    setup_image(type)
    init_position
  end

  def init_position
    self.x = rand(Graphics.width)
    self.y = -10
  end

  def dispose
    super
  end

  def update
    super
    update_move
  end

  def update_move
    self.y += @speed
  end

  def setup_image(type)
    self.bitmap = Cache.space("powerup" + type.to_s)
    self.ox = bitmap.width / 2
    self.oy = bitmap.height / 2
  end

  def width
    self.bitmap.width
  end
  def height
    self.bitmap.height
  end
end # Sprite_Powerup < Sprite

#-------------------------------------------------------------------------------
#  SCORE WINDOW
#-------------------------------------------------------------------------------

class Window_InvaderScore < Window_Base
  def initialize
    super(0, 0, Graphics.width, Graphics.height)
    self.opacity = 0
    refresh
  end

  def refresh(shields = Galv_SI::PLAYER_SHIELDS.to_f,bonus_shields = 0)
    contents.clear
    draw_score("Score: ", score, 4, 0, contents.width - 8, 2)
    draw_score("Best: ", high_score, -(Graphics.width / 2) + 70, 0, contents.width - 8, 2)
    draw_shields(shields, 4, 0)
    draw_bonus_shields(bonus_shields)
  end

  def draw_shields(shields, x, y, width = Graphics.width / 4)
    draw_gauge(x, y, width, shields / Galv_SI::PLAYER_SHIELDS.to_f, text_color(1),
    text_color(4))
  end

  def draw_bonus_shields(x,width = Graphics.width / 4)
    w = width * x / Galv_SI::PLAYER_SHIELDS.to_f
    rect = Rect.new(4, 0, w, 12)
    contents.fill_rect(rect, text_color(1))
  end

  def score
    $game_variables[Galv_SI::SCORE_VAR]
  end
  def high_score
    $game_variables[Galv_SI::HIGH_SCORE_VAR]
  end

  def draw_score(value, unit, x, y, width, align)
    cx = text_size(unit).width
    draw_text(x, y, width - cx - 2, line_height, value, align)
    draw_text(x, y, width, line_height, unit, align)
  end

  def open
    refresh
    super
  end
end # Window_InvaderScore < Window_Base


#------------------------------------------------------------------------------
#  Player reverse control debuff
#------------------------------------------------------------------------------
class Sprite_Player < Sprite
  def update_position
    dx = 0
    dy = 0
    reverse = $galv_invader_reverse_controls_frames.to_i > 0

    if Input.press?(:LEFT) && !Input.press?(:RIGHT)
      @cell = reverse ? 2 : 0
      dx += reverse ? Galv_SI::SHIP_SPEED : -Galv_SI::SHIP_SPEED
    elsif Input.press?(:RIGHT) && !Input.press?(:LEFT)
      @cell = reverse ? 0 : 2
      dx += reverse ? -Galv_SI::SHIP_SPEED : Galv_SI::SHIP_SPEED
    else
      @cell = 1
    end

    if Input.press?(:UP) && !Input.press?(:DOWN)
      dy += reverse ? Galv_SI::SHIP_SPEED : -Galv_SI::SHIP_SPEED
    elsif Input.press?(:DOWN) && !Input.press?(:UP)
      dy += reverse ? -Galv_SI::SHIP_SPEED : Galv_SI::SHIP_SPEED
    end

    if dx != 0 && dy != 0
      factor = 1.0 / Math.sqrt(2)
      dx *= factor
      dy *= factor
    end

    self.x += dx
    self.y += dy
    self.x = [[self.x, width / 2].max, Graphics.width - width / 2].min
    self.y = [[self.y, height / 2].max, Graphics.height - height / 2].min
  end
end

#------------------------------------------------------------------------------
#  Player shots
#------------------------------------------------------------------------------
class Sprite_Lazor < Sprite
  attr_reader :hit_width
  attr_reader :hit_height
  attr_reader :penetrating
  attr_reader :type
  attr_reader :level

  def initialize(viewport, x, y, type = 0, dir = 0, level = 1)
    super(viewport)
    self.x = x
    self.y = y - 20
    @type = type
    @dir = dir
    @level = level
    @penetrating = (@type == 2)
    @bounce_used = false
    @custom_vx = nil
    @custom_vy = nil
    setup_lazor_image
  end

  def beam?
    @type == 2 && @level.to_i >= 6
  end

  def beam_level6?
    beam?
  end

  def bounce_ball?
    @type == 1 && @level.to_i >= 6
  end

  def reflectable_by_alien4?
    !beam?
  end

  def setup_lazor_image
    case @type
    when 0
      self.bitmap = Cache.space("lazor")
      @hit_width = bitmap.width
      @hit_height = bitmap.height
    when 1
      self.bitmap = Cache.space("lazor_ball")
      @hit_width = bitmap.width
      @hit_height = bitmap.height
    when 2
      self.bitmap = Cache.space("lazor_pen")
      self.ox = bitmap.width / 2
      if beam?
        self.oy = bitmap.height
        self.zoom_x = Galv_SI::TOGGLE_BEAM_VIS_X
        self.zoom_y = Galv_SI::TOGGLE_BEAM_VIS_Y
        self.opacity = 220
        @hit_width = Galv_SI::TOGGLE_BEAM_WIDTH
        @hit_height = Graphics.height
        @penetrating = true
        self.z = 150
        return
      else
        self.oy = bitmap.height / 2
        self.zoom_x = 1 + 0.2 * (@level - 1 + 2)
        self.zoom_y = 1
        @hit_width = bitmap.width * self.zoom_x
        @hit_height = bitmap.height
      end
    end
    self.ox = bitmap.width / 2
    self.oy = bitmap.height / 2 if self.oy.nil?
  end

  def update
    super
    if beam?
      self.opacity = 210 + rand(46)
    else
      update_position
    end
  end

  def update_position
    if @custom_vx && @custom_vy
      self.x += @custom_vx
      self.y += @custom_vy
      return
    end

    if @type == 2
      self.y -= Galv_SI::PENETRATE_SPEED
    else
      self.y -= Galv_SI::LAZOR_SPEED
      case @dir
      when 1
        self.x -= Galv_SI::LAZOR_SPEED.to_f / 4
      when 2
        self.x += Galv_SI::LAZOR_SPEED.to_f / 4 + 1
      when 3
        self.x -= Galv_SI::LAZOR_SPEED
      when 4
        self.x += Galv_SI::LAZOR_SPEED
      end
    end
  end

  def expired?
    false
  end

  def out_of_bounds?
    return false if beam?
    margin = 64
    self.x < -margin || self.x > Graphics.width + margin ||
    self.y < -margin || self.y > Graphics.height + margin
  end

  def on_enemy_hit
    return false if @penetrating
    if bounce_ball? && !@bounce_used
      @bounce_used = true
      set_random_bounce_vector
      return false
    end
    true
  end

  def set_random_bounce_vector
    speed = Galv_SI::LAZOR_SPEED
    angle_deg = 210 + rand(121)
    angle = angle_deg * Math::PI / 180.0
    @custom_vx = Math.cos(angle) * speed
    @custom_vy = Math.sin(angle) * speed
  end

  def beam_hit_enemy?(enemy)
    return false unless beam?
    enemy_half_w = enemy.width / 2.0
    enemy_half_h = enemy.height / 2.0
    beam_left   = self.x - @hit_width / 2.0
    beam_right  = self.x + @hit_width / 2.0
    beam_top    = 0
    beam_bottom = self.y
    enemy_left   = enemy.x - enemy_half_w
    enemy_right  = enemy.x + enemy_half_w
    enemy_top    = enemy.y - enemy_half_h
    enemy_bottom = enemy.y + enemy_half_h
    beam_left < enemy_right && beam_right > enemy_left &&
      beam_top < enemy_bottom && beam_bottom > enemy_top
  end
end

#------------------------------------------------------------------------------
#  Extra sprites
#------------------------------------------------------------------------------
class Sprite_BadPowerup < Sprite
  def initialize(viewport, x, y)
    super(viewport)
    self.bitmap = Cache.space("powerup_bad")
    self.ox = bitmap.width / 2
    self.oy = bitmap.height / 2
    self.x = x
    self.y = y
    @speed = Galv_SI::BAD_PUP_SPEED
  end

  def update
    super
    self.y += @speed
  end

  def width
    bitmap.width
  end

  def height
    bitmap.height
  end
end

class Sprite_PatternBullet < Sprite
  def initialize(viewport, x, y, vx, vy, graphic = "elazor")
    super(viewport)
    self.bitmap = Cache.space(graphic)
    self.ox = bitmap.width / 2
    self.oy = bitmap.height / 2
    self.x = x
    self.y = y
    @vx = vx
    @vy = vy
  end

  def update(player_x = nil, player_y = nil)
    super()
    self.x += @vx
    self.y += @vy
  end
end

class Sprite_ReflectedLazor2 < Sprite_PatternBullet
  def initialize(viewport, x, y, source_type = 0)
    speed = case source_type
    when 1
      Galv_SI::BULLET_SPEED_FAST
    when 2
      Galv_SI::BULLET_SPEED_MED
    else
      Galv_SI::BULLET_SPEED_MED
    end
    super(viewport, x, y, 0, speed, "elazor_reflect")
  end
end

class Sprite_OrbitBullet < Sprite
  attr_reader :owner

  def initialize(viewport, owner, angle_offset)
    super(viewport)
    self.bitmap = Cache.space("orbit_bullet")
    self.ox = bitmap.width / 2
    self.oy = bitmap.height / 2
    @owner = owner
    @angle = angle_offset
    update_position
  end

  def update
    super
    @angle += Galv_SI::ORBIT_SPEED
    update_position
  end

  def update_position
    return if @owner.nil? || @owner.disposed?
    self.x = @owner.x + Math.cos(@angle) * Galv_SI::ORBIT_RADIUS
    self.y = @owner.y + Math.sin(@angle) * Galv_SI::ORBIT_RADIUS
  end
end

#------------------------------------------------------------------------------
#  Alien overhaul
#------------------------------------------------------------------------------
class Sprite_Alien < Sprite
  attr_accessor :hp
  attr_accessor :speed_mul
  attr_reader :mhp
  attr_reader :type
  attr_reader :pattern_name

  def initialize(viewport, id, type = 0)
    super(viewport)
    @type = type
    @id = id
    @speed_mul = 1.0
    @mini = false
    @request_shot = nil
    @pattern_timer = 0
    @pattern_phase = 0
    @shot_timer = 0
    @anchor_x = 0
    @anchor_y = 0
    @base_x = 0
    @base_y = 0
    @theta = 0.0
    @theta_speed = 0.0
    @amp = 0
    @freq = 0.0
    @lane_target_x = 0
    @shield_mode = false
    @swap_timer = Galv_SI::ALIEN4_SWAP_TIME
    setup_enemy
    init_position
    setup_pattern
  end

  def init_position
    self.x = rand(Graphics.width - 80) + 40
    self.y = -20 - rand(50)
  end

  def setup_enemy
    self.bitmap = Cache.space(@type == 4 ? "alien4S" : "alien" + @type.to_s)
    self.ox = bitmap.width / 2
    self.oy = bitmap.height / 2
    @hp = Galv_SI::ENEMY_BASE_HP
    @mhp = @hp
    @base_speed = case @type
    when 0 then 1.20
    when 1 then 1.35
    when 2 then 1.10
    when 3 then 1.05
    when 4 then 1.00
    else        1.20
    end
  end

  def make_mini(side = -1)
    @mini = true
    self.zoom_x = Galv_SI::MINI_ALIEN_SCALE
    self.zoom_y = Galv_SI::MINI_ALIEN_SCALE
    @hp = 1
    @mhp = 1
    @pattern_name = :split_dive
    @pattern_timer = 0
    @vx = side * 1.8
    @vy = Galv_SI::MINI_ALIEN_SPEED
  end

  def mini?
    @mini
  end

  def alien4_shield_mode?
    @type == 4 && @shield_mode
  end

  def request_shot(type)
    @request_shot = type
  end

  def consume_shot_request
    shot = @request_shot
    @request_shot = nil
    shot
  end

  def setup_pattern
    case @type
    when 0
      @pattern_name = [:sine, :swoop].sample
    when 1
      @pattern_name = [:diagonal_line, :zigzag].sample
    when 2
      @pattern_name = [:sine, :anchor_hover].sample
    when 3
      @pattern_name = :orbit_anchor
    when 4
      @pattern_name = [:orbit_anchor, :zigzag, :anchor_hover].sample
    else
      @pattern_name = :sine
    end

    case @pattern_name
    when :sine
      @base_x = [[self.x, 48].max, Graphics.width - 48].min
      @amp = 36 + rand(34)
      @freq = 0.03 + rand * 0.02
    when :swoop
      @anchor_x = rand(Graphics.width - 120) + 60
      @anchor_y = rand(90) + 80
      @pattern_phase = 0
    when :diagonal_line
      side = rand(2) == 0 ? -1 : 1
      slot = @id % 5
      if side < 0
        self.x = -40 - slot * 28
        @vx = 2.2
      else
        self.x = Graphics.width + 40 + slot * 28
        @vx = -2.2
      end
      self.y = -20 - slot * 28
      @vy = 1.7
    when :zigzag
      @lane_target_x = rand(Graphics.width - 80) + 40
      @zig_timer = 24 + rand(20)
    when :anchor_hover
      @anchor_x = rand(Graphics.width - 120) + 60
      @anchor_y = rand(90) + 70
      @pattern_phase = 0
    when :orbit_anchor
      @anchor_x = rand(Graphics.width - 140) + 70
      @anchor_y = rand(80) + 80
      @theta = rand * Math::PI * 2
      @theta_speed = 0.05 + rand * 0.02
      @pattern_phase = 0
    end

    if @type == 4
      @shield_mode = true
      @swap_timer = Galv_SI::ALIEN4_SWAP_TIME
      refresh_alien4_bitmap
    end
  end

  def refresh_alien4_bitmap
    return unless @type == 4
    cx = self.x
    cy = self.y
    self.bitmap = Cache.space(@shield_mode ? "alien4S" : "alien4")
    self.ox = bitmap.width / 2
    self.oy = bitmap.height / 2
    self.x = cx
    self.y = cy
  end

  def update
    super
    @pattern_timer += 1
    update_alien4_state if @type == 4
    update_move
    update_shot_logic
  end

  def current_speed
    (@base_speed || 1.0) * (@speed_mul || 1.0)
  end

  def update_alien4_state
    @swap_timer -= 1
    if @swap_timer <= 0
      @swap_timer = Galv_SI::ALIEN4_SWAP_TIME
      @shield_mode = !@shield_mode
      refresh_alien4_bitmap
    end
  end

  def update_move
    case @pattern_name
    when :sine
      self.y += current_speed
      self.x = @base_x + Math.sin(@pattern_timer * @freq) * @amp
    when :swoop
      if @pattern_phase == 0
        move_toward(@anchor_x, @anchor_y, 2.8 + current_speed * 0.5)
        if close_to?(@anchor_x, @anchor_y, 6)
          @pattern_phase = 1
          @vx = self.x < Graphics.width / 2 ? 2.5 : -2.5
          @vy = 2.8
        end
      else
        self.x += @vx
        self.y += @vy
      end
    when :diagonal_line
      self.x += @vx * (@speed_mul || 1.0)
      self.y += @vy * (@speed_mul || 1.0)
    when :zigzag
      self.y += current_speed + 0.5
      self.x += (@lane_target_x - self.x) * 0.12
      @zig_timer -= 1
      if @zig_timer <= 0
        @zig_timer = 22 + rand(18)
        @lane_target_x = rand(Graphics.width - 80) + 40
      end
    when :anchor_hover
      if @pattern_phase == 0
        move_toward(@anchor_x, @anchor_y, 2.6 + current_speed * 0.5)
        @pattern_phase = 1 if close_to?(@anchor_x, @anchor_y, 6)
      else
        self.x = @anchor_x + Math.sin(@pattern_timer * 0.04) * 26
        self.y = @anchor_y + Math.cos(@pattern_timer * 0.03) * 10
        @anchor_y += 0.10 * (@speed_mul || 1.0)
      end
    when :orbit_anchor
      if @pattern_phase == 0
        move_toward(@anchor_x, @anchor_y, 2.8 + current_speed * 0.5)
        @pattern_phase = 1 if close_to?(@anchor_x, @anchor_y, 6)
      else
        @theta += @theta_speed * (@speed_mul || 1.0)
        self.x = @anchor_x + Math.cos(@theta) * 42
        self.y = @anchor_y + Math.sin(@theta) * 28
        @anchor_y += 0.08 * (@speed_mul || 1.0)
      end
    when :split_dive
      self.x += @vx
      self.y += @vy
      @vx *= 0.995
    else
      self.y += current_speed
    end
  end

  def update_shot_logic
    @shot_timer -= 1 if @shot_timer > 0
    return if @type == 4

    case @type
    when 0
      if @pattern_name == :sine
        if @shot_timer <= 0 && self.y > 40
          request_shot(:aimed_single)
          @shot_timer = Galv_SI::SHOT_AIMED_COOLDOWN
        end
      elsif @pattern_name == :swoop
        if @pattern_phase == 1 && @shot_timer <= 0
          request_shot(:fast_triple)
          @shot_timer = 54
        end
      end
    when 1
      if @pattern_name == :diagonal_line
        if @shot_timer <= 0 && self.y > 20
          request_shot(:side_fan)
          @shot_timer = Galv_SI::SHOT_LINE_COOLDOWN
        end
      elsif @pattern_name == :zigzag
        if @shot_timer <= 0 && self.y > 40
          request_shot(:aimed_double)
          @shot_timer = 78
        end
      end
    when 2
      if @pattern_name == :anchor_hover && @pattern_phase == 1
        if @shot_timer <= 0
          request_shot(:stream_aimed)
          @shot_timer = Galv_SI::SHOT_STREAM_COOLDOWN
        end
      elsif @pattern_name == :sine
        if @shot_timer <= 0 && self.y > 50
          request_shot(:spread_three)
          @shot_timer = Galv_SI::SHOT_SPREAD_COOLDOWN
        end
      end
    when 3
      if @pattern_name == :orbit_anchor && @pattern_phase == 1 && @shot_timer <= 0
        request_shot(:ring_eight)
        @shot_timer = Galv_SI::SHOT_RING_COOLDOWN
      end
    end
  end

  def move_toward(tx, ty, speed)
    dx = tx - self.x
    dy = ty - self.y
    dist = Math.sqrt(dx * dx + dy * dy)
    return if dist <= 0.001
    self.x += dx / dist * speed
    self.y += dy / dist * speed
  end

  def close_to?(tx, ty, range = 6)
    (self.x - tx).abs <= range && (self.y - ty).abs <= range
  end

  def width
    bitmap.width * self.zoom_x
  end

  def height
    bitmap.height * self.zoom_y
  end
end

#------------------------------------------------------------------------------
#  Scene overhaul
#------------------------------------------------------------------------------
class Scene_Invaders < Scene_Base
  alias merged_invader_start start
  def start
    merged_invader_start
    create_aura_overlay
  end

  alias merged_invader_update update
  def update
    merged_invader_update
    update_bad_pups if @bad_pups
    update_orbit_bullets if @orbit_bullets
    update_aura_overlay if @aura_overlay
  end

  def init_variables
    @nukeall = false
    @sound_timer = Galv_SI::SOUND_TIMER
    @enemy_wave = 1
    @guns = 1
    @gun_type = 0
    @bonus_shields = 0
    @reset_pup = Galv_SI::RESET_PUP * 60
    @player_shields = Galv_SI::PLAYER_SHIELDS
    $game_variables[Galv_SI::SCORE_VAR] = 0
    @plazors = []
    @elazors = []
    @enemies = []
    @explodes = []
    @pups = []
    @bad_pups = []
    @orbit_bullets = []
    @spawn_timer = rand(Galv_SI::START_SPAWN_MAX)
    @ticker = 100
    @game_time = 0
    @alien_count = 0
    @pups_count = 0
    @difficulty = 0.0
    @shoot_difficulty = 0.0
    @dead = false
    $galv_invader_reverse_controls_frames = 0
  end

  def beam_fire_y
    @player.y - (@player.height / 2) + Galv_SI::BEAM_TOP_OFFSET
  end

  def toggle_beam_active?
    @plazors.any? { |l| l && l.beam? }
  end

  def current_toggle_beam
    @plazors.find { |l| l && l.beam? }
  end

  def remove_toggle_beam
    @plazors.each_with_index do |lazor, i|
      next unless lazor && lazor.beam?
      lazor.dispose
      @plazors[i] = nil
    end
    @plazors.compact!
  end

  def update_toggle_beam_position
    beam = current_toggle_beam
    return unless beam
    beam.x = @player.x
    beam.y = beam_fire_y
  end

  def invader_time_seconds
    # Graphics.frame_count belongs to the whole game process and survives a
    # retry. @game_time is reset by init_variables for each minigame run.
    @game_time.to_i / 60
  end

  def active_enemy_count
    @enemies.compact.size
  end

  def current_enemy_cap
    t = invader_time_seconds
    return Galv_SI::START_ENEMY_CAP if t < 25
    return Galv_SI::MID_ENEMY_CAP if t < 60
    return Galv_SI::LATE_ENEMY_CAP if t < 120
    Galv_SI::END_ENEMY_CAP
  end

  def current_spawn_range
    t = invader_time_seconds
    if t < 25
      [Galv_SI::START_SPAWN_MIN, Galv_SI::START_SPAWN_MAX]
    elsif t < 60
      [Galv_SI::MID_SPAWN_MIN, Galv_SI::MID_SPAWN_MAX]
    elsif t < 120
      [Galv_SI::LATE_SPAWN_MIN, Galv_SI::LATE_SPAWN_MAX]
    else
      [Galv_SI::END_SPAWN_MIN, Galv_SI::END_SPAWN_MAX]
    end
  end

  def alien_type
    t = invader_time_seconds
    r = rand(100)
    if t < 20
      return 0 if r < 42
      return 1 if r < 72
      return 2 if r < 87
      return 3 if r < 95
      return 4
    elsif t < 45
      return 0 if r < 34
      return 1 if r < 58
      return 2 if r < 78
      return 3 if r < 90
      return 4
    elsif t < 90
      return 0 if r < 26
      return 1 if r < 46
      return 2 if r < 66
      return 3 if r < 83
      return 4
    else
      return rand(5)
    end
  end

  def update_player_actions
    $galv_invader_reverse_controls_frames -= 1 if $galv_invader_reverse_controls_frames.to_i > 0
    if Input.trigger?(:C) && !@dead
      if @gun_type == 2 && @guns >= 6
        if toggle_beam_active?
          remove_toggle_beam
        else
          player_shoot
        end
      else
        return if Galv_SI::MAX_SHOTS * @guns <= @plazors.count
        player_shoot
      end
    end
    if Input.trigger?(:B)
      SceneManager.goto(Scene_Map)
    end
    if Input.trigger?(:X) && @item && !@dead
      @nukeall = true
      RPG::SE.new(Galv_SI::NSE[0],Galv_SI::NSE[1],Galv_SI::NSE[2]).play
      @difficulty *= 0.75
      @flash.opacity = 225
      @item = nil
      draw_item_held
    end
  end

  def player_shoot
    case @gun_type
    when 0
      RPG::SE.new(Galv_SI::SE[0], Galv_SI::SE[1], Galv_SI::SE[2]).play
      case @guns
      when 1
        @plazors << Sprite_Lazor.new(@viewport1, @player.x, @player.y)
      when 2
        2.times { |i| @plazors << Sprite_Lazor.new(@viewport1, @player.x - 20 + i * 40, @player.y) }
      when 3
        3.times { |i| @plazors << Sprite_Lazor.new(@viewport1, @player.x - 20 + i * 20, @player.y) }
      when 4
        4.times { |i| @plazors << Sprite_Lazor.new(@viewport1, @player.x - 30 + i * 20, @player.y) }
      when 5
        5.times { |i| @plazors << Sprite_Lazor.new(@viewport1, @player.x - 30 + i * 15, @player.y) }
      else
        6.times { |i| @plazors << Sprite_Lazor.new(@viewport1, @player.x - 37 + i * 15, @player.y) }
      end
    when 1
      RPG::SE.new(Galv_SI::SE1[0], Galv_SI::SE1[1], Galv_SI::SE1[2]).play
      case @guns
      when 1
        @plazors << Sprite_Lazor.new(@viewport1, @player.x, @player.y, 1, 0, 1)
      when 2
        2.times { |i| @plazors << Sprite_Lazor.new(@viewport1, @player.x, @player.y, 1, 1 + i, 2) }
      when 3,4,5
        @guns.times { |i| @plazors << Sprite_Lazor.new(@viewport1, @player.x, @player.y, 1, i, @guns) }
      else
        5.times { |i| @plazors << Sprite_Lazor.new(@viewport1, @player.x, @player.y, 1, i, 6) }
      end
    when 2
      RPG::SE.new(Galv_SI::SE2[0], Galv_SI::SE2[1], Galv_SI::SE2[2]).play
      level = @guns >= 6 ? 6 : @guns
      y = @guns >= 6 ? beam_fire_y : @player.y
      @plazors << Sprite_Lazor.new(@viewport1, @player.x, y, 2, 0, level)
    end
  end

  def update_plazors
    update_toggle_beam_position if toggle_beam_active?
    @plazors.each_with_index do |lazor, i|
      next if lazor.nil?
      lazor.update
      if !lazor.beam? && lazor.out_of_bounds?
        lazor.dispose
        @plazors[i] = nil
      end
    end
    @plazors.compact!
  end

  def fire_pattern_bullet(x, y, vx, vy, graphic = "elazor")
    @elazors << Sprite_PatternBullet.new(@viewport1, x, y, vx, vy, graphic)
  end

  def fire_aimed_bullet(enemy, speed = Galv_SI::BULLET_SPEED_MED, spread_x = 0.0)
    dx = (@player.x + spread_x) - enemy.x
    dy = @player.y - enemy.y
    dist = Math.sqrt(dx * dx + dy * dy)
    return if dist <= 0.001
    vx = dx / dist * speed
    vy = dy / dist * speed
    fire_pattern_bullet(enemy.x, enemy.y, vx, vy)
  end

  def enemy_shoot(enemy, shot_type = nil)
    shot_type ||= enemy.consume_shot_request
    return if shot_type.nil?
    if @sound_timer >= Galv_SI::SOUND_TIMER
      RPG::SE.new(Galv_SI::ASE[0],Galv_SI::ASE[1],Galv_SI::ASE[2]).play
      @sound_timer = 0
    end
    case shot_type
    when :aimed_single
      fire_aimed_bullet(enemy, Galv_SI::BULLET_SPEED_MED)
    when :fast_triple
      [-45, 0, 45].each { |off| fire_aimed_bullet(enemy, Galv_SI::BULLET_SPEED_FAST, off) }
    when :side_fan
      [[-1.6, 3.2], [0, 3.8], [1.6, 3.2]].each { |vx, vy| fire_pattern_bullet(enemy.x, enemy.y, vx, vy) }
    when :aimed_double
      fire_aimed_bullet(enemy, Galv_SI::BULLET_SPEED_MED, -28)
      fire_aimed_bullet(enemy, Galv_SI::BULLET_SPEED_MED, 28)
    when :stream_aimed
      fire_aimed_bullet(enemy, Galv_SI::BULLET_SPEED_FAST)
    when :spread_three
      [[-1.4, 3.2], [0, 3.7], [1.4, 3.2]].each { |vx, vy| fire_pattern_bullet(enemy.x, enemy.y, vx, vy) }
    when :ring_eight
      8.times do |i|
        ang = i * Math::PI / 4.0
        fire_pattern_bullet(enemy.x, enemy.y, Math.cos(ang) * Galv_SI::BULLET_SPEED_SLOW, Math.sin(ang) * Galv_SI::BULLET_SPEED_SLOW, "orbit_bullet")
      end
    end
  end

  def update_elazors
    @elazors.compact!
    @elazors.each_with_index do |lazor, i|
      next unless lazor
      lazor.update(@player.x, @player.y)
      if lazor.y > Graphics.height + 40 || lazor.y < -Graphics.height || lazor.x < -80 || lazor.x > Graphics.width + 80
        lazor.dispose
        @elazors[i] = nil
      elsif player_hit?(lazor.x, lazor.y)
        damage_player(Galv_SI::LAZOR_DAMAGE)
        lazor.dispose
        @elazors[i] = nil
      end
    end
  end

  def ensure_orbit_bullets(enemy)
    return unless enemy.type == 3
    current = @orbit_bullets.find_all { |b| b && b.owner == enemy }
    return if current.size >= 3
    (3 - current.size).times do |i|
      angle = i * (Math::PI * 2 / 3.0)
      @orbit_bullets << Sprite_OrbitBullet.new(@viewport1, enemy, angle)
    end
  end

  def update_orbit_bullets
    @orbit_bullets.compact!
    @orbit_bullets.each_with_index do |bullet, i|
      if bullet.owner.nil? || bullet.owner.disposed?
        bullet.dispose
        @orbit_bullets[i] = nil
        next
      end
      bullet.update
      if player_hit?(bullet.x, bullet.y)
        damage_player(Galv_SI::ORBIT_CONTACT_DMG)
        bullet.dispose
        @orbit_bullets[i] = nil
      end
    end
    @orbit_bullets.compact!
  end

  def remove_enemy_orbit_bullets(enemy)
    @orbit_bullets.each_with_index do |b, i|
      next unless b && b.owner == enemy
      b.dispose
      @orbit_bullets[i] = nil
    end
    @orbit_bullets.compact!
  end

  def update_bad_pups
    @bad_pups.compact!
    @bad_pups.each_with_index do |pup, i|
      next unless pup
      pup.update
      if pup.y > Graphics.height + 20
        pup.dispose
        @bad_pups[i] = nil
      elsif enemy_hit?(pup, false) && Galv_SI::DESTROY_PUPS
        pup.dispose
        @bad_pups[i] = nil
      elsif player_hit?(pup.x, pup.y)
        apply_bad_powerup
        pup.dispose
        @bad_pups[i] = nil
      end
    end
  end

  def apply_bad_powerup
    $galv_invader_reverse_controls_frames = Galv_SI::CONFUSE_FRAMES
    @player.flash(Color.new(255, 80, 255), 30)
    Sound.play_buzzer
  end

  def alien2_alive?
    @enemies.any? { |e| e && e.type == 2 }
  end

  def update_spawn
    return if @dead
    if @spawn_timer <= 0
      if active_enemy_count < current_enemy_cap
        @enemies << Sprite_Alien.new(@viewport1, @alien_count, alien_type)
        @alien_count += 1
      end
      min_t, max_t = current_spawn_range
      @spawn_timer = min_t + rand(max_t - min_t + 1)
    end
    @spawn_timer -= 1
  end

  def update_enemies
    @sound_timer += 1
    aura_active = alien2_alive?
    @enemies.each_with_index do |enemy, i|
      next if enemy.nil?
      enemy.speed_mul = 1.0
      enemy.speed_mul *= Galv_SI::ALIEN2_AURA_MULT if aura_active && enemy.type != 2
      enemy.update
      ensure_orbit_bullets(enemy) if enemy.type == 3

      if enemy_hit?(enemy) || @nukeall
        enemy.hp -= @nukeall ? enemy.mhp : 1
        if enemy.hp <= 0
          handle_enemy_death(enemy)
          enemy.dispose
          @enemies[i] = nil
        else
          RPG::SE.new(Galv_SI::PSE[0],Galv_SI::PSE[1],Galv_SI::PSE[2]).play
          enemy.flash(Color.new(255,155,155),20)
        end
      elsif player_hit?(enemy.x, enemy.y)
        handle_enemy_death(enemy)
        enemy.dispose
        @enemies[i] = nil
        damage_player(Galv_SI::COLLIDE_DAMAGE)
      else
        shot_type = enemy.consume_shot_request
        enemy_shoot(enemy, shot_type) if shot_type
      end

      if enemy && !enemy.disposed? && (enemy.y > Graphics.height + 80 || enemy.x < -100 || enemy.x > Graphics.width + 100)
        remove_enemy_orbit_bullets(enemy)
        enemy.dispose
        @enemies[i] = nil
      end
    end
    @enemies.compact!
    @nukeall = false
  end

  def handle_enemy_death(enemy)
    destroy_enemy(Galv_SI::ENEMY_BASE_SCORE)
    @explodes << Sprite_Splosion.new(@viewport1, enemy.x, enemy.y)
    remove_enemy_orbit_bullets(enemy)
    case enemy.type
    when 0
      if !enemy.mini? && invader_time_seconds >= Galv_SI::SPLIT_MIN_TIME && active_enemy_count <= current_enemy_cap - 2
        2.times do |n|
          mini = Sprite_Alien.new(@viewport1, @alien_count, 0)
          @alien_count += 1
          mini.x = enemy.x + (n == 0 ? -12 : 12)
          mini.y = enemy.y
          mini.make_mini(n == 0 ? -1 : 1)
          @enemies << mini
        end
      end
    when 1
      @bad_pups << Sprite_BadPowerup.new(@viewport1, enemy.x, enemy.y)
    end
  end

  def update_pups
    if @reset_pup <= 0
      @pups << Sprite_Powerup.new(@viewport1, @pups_count, 999)
      @reset_pup = (Galv_SI::RESET_PUP + @enemy_wave) * 60
    end
    if rand(1000) > Galv_SI::POWERUP_CHANCE && !@dead
      @pups << Sprite_Powerup.new(@viewport1, @pups_count, rand(5))
      @pups_count += 1
    end
    @pups.each_with_index do |pup, i|
      next if pup.nil?
      pup.update
      if enemy_hit?(pup, false) && Galv_SI::DESTROY_PUPS
        RPG::SE.new(Galv_SI::DSE[0],Galv_SI::DSE[1],Galv_SI::DSE[2]).play
        @explodes << Sprite_Splosion.new(@viewport1, pup.x, pup.y)
        pup.dispose
        @pups[i] = nil
      elsif player_hit?(pup.x, pup.y)
        do_powerup(pup.type)
        pup.dispose
        @pups[i] = nil
      end
    end
  end

  def do_powerup(type)
    @player.flash(Color.new(155,255,155),20)
    case type
    when 0
      RPG::SE.new(Galv_SI::BSE[0],Galv_SI::BSE[1],Galv_SI::BSE[2]).play
      if @player_shields == Galv_SI::PLAYER_SHIELDS
        @bonus_shields += 1 if @bonus_shields < Galv_SI::PLAYER_SHIELDS
      else
        @player_shields = Galv_SI::PLAYER_SHIELDS
      end
      @score_window.refresh(@player_shields.to_f, @bonus_shields)
    when 1
      RPG::SE.new(Galv_SI::PUSE[0],Galv_SI::PUSE[1],Galv_SI::PUSE[2]).play
      if @gun_type != 0
        @gun_type = 0
        @guns = [@guns, 1].max
        remove_toggle_beam
      elsif @guns < Galv_SI::MAX_GUN_LEVEL_EX
        @guns += 1
      end
    when 2
      RPG::SE.new(Galv_SI::PUSE[0],Galv_SI::PUSE[1],Galv_SI::PUSE[2]).play
      if @gun_type != 1
        @gun_type = 1
        @guns = [@guns, 1].max
        remove_toggle_beam
      elsif @guns < Galv_SI::MAX_GUN_LEVEL_EX
        @guns += 1
      end
    when 3
      RPG::SE.new(Galv_SI::PUSE[0],Galv_SI::PUSE[1],Galv_SI::PUSE[2]).play
      @item = "nuke"
      draw_item_held
    when 4
      RPG::SE.new(Galv_SI::PUSE[0],Galv_SI::PUSE[1],Galv_SI::PUSE[2]).play
      if @gun_type != 2
        @gun_type = 2
        @guns = [@guns, 1].max
      elsif @guns < Galv_SI::MAX_GUN_LEVEL_EX
        @guns += 1
      end
    when 999
      RPG::SE.new(Galv_SI::PUSE[0],Galv_SI::PUSE[1],Galv_SI::PUSE[2]).play
      @difficulty *= Galv_SI::RESET_RATIO
      @shoot_difficulty *= Galv_SI::RESET_RATIO
      @spawn_timer = [@spawn_timer, 25 + rand(Galv_SI::SPAWN_SPEED) / 2].max
      @enemy_wave += 1
    end
  end

  def damage_player(amount)
    remove_toggle_beam if toggle_beam_active?
    RPG::SE.new(Galv_SI::PSE[0],Galv_SI::PSE[1],Galv_SI::PSE[2]).play
    @player.flash(Color.new(255,155,155),20)
    if @bonus_shields > 0
      @bonus_shields = [@bonus_shields - amount, 0].max
    else
      @player_shields -= amount
    end
    @score_window.refresh(@player_shields.to_f, @bonus_shields)
    destroy_player if @player_shields <= 0
  end

  def destroy_enemy(score)
    RPG::SE.new(Galv_SI::DSE[0],Galv_SI::DSE[1],Galv_SI::DSE[2]).play
    $game_variables[Galv_SI::SCORE_VAR] += score
    if $game_variables[Galv_SI::SCORE_VAR] > $game_variables[Galv_SI::HIGH_SCORE_VAR]
      $game_variables[Galv_SI::HIGH_SCORE_VAR] = $game_variables[Galv_SI::SCORE_VAR]
    end
    @score_window.refresh(@player_shields.to_f, @bonus_shields)
  end

  def reflect_player_lazor(lazor, enemy)
    @elazors << Sprite_ReflectedLazor2.new(@viewport1, lazor.x, enemy.y, lazor.type)
  end

  def enemy_hit?(enemy, kill = true)
    @plazors.each_with_index do |lazor, i|
      next if lazor.nil?
      hit = if lazor.beam?
        lazor.beam_hit_enemy?(enemy)
      else
        half_lw = lazor.hit_width / 2.0
        half_lh = lazor.hit_height / 2.0
        half_ew = enemy.width / 2.0
        half_eh = enemy.height / 2.0
        (lazor.x - half_lw < enemy.x + half_ew) &&
        (lazor.x + half_lw > enemy.x - half_ew) &&
        (lazor.y - half_lh < enemy.y + half_eh) &&
        (lazor.y + half_lh > enemy.y - half_eh)
      end
      next unless hit

      if enemy.is_a?(Sprite_Alien) && enemy.alien4_shield_mode? && lazor.reflectable_by_alien4?
        reflect_player_lazor(lazor, enemy)
        lazor.dispose
        @plazors[i] = nil
        @plazors.compact!
        return false
      end

      if kill
        remove_lazor = lazor.on_enemy_hit
        if remove_lazor
          lazor.dispose
          @plazors[i] = nil
        end
      end
      @plazors.compact!
      return true
    end
    false
  end

  def create_aura_overlay
    return if @aura_overlay
    @aura_overlay = Sprite.new
    @aura_overlay.bitmap = Bitmap.new(Graphics.width, Graphics.height)
    @aura_overlay.bitmap.fill_rect(0, 0, Graphics.width, Graphics.height, Color.new(255, 0, 0))
    @aura_overlay.opacity = 0
    @aura_overlay.z = 999
  end

  def update_aura_overlay
    return unless @aura_overlay
    target = alien2_alive? ? Galv_SI::AURA_TINT_OPACITY : 0
    if @aura_overlay.opacity < target
      @aura_overlay.opacity = [@aura_overlay.opacity + 4, target].min
    elsif @aura_overlay.opacity > target
      @aura_overlay.opacity = [@aura_overlay.opacity - 4, target].max
    end
  end

  def dispose_graphics
    if @aura_overlay
      @aura_overlay.bitmap.dispose if @aura_overlay.bitmap && !@aura_overlay.bitmap.disposed?
      @aura_overlay.dispose unless @aura_overlay.disposed?
      @aura_overlay = nil
    end
    @item_held.bitmap.dispose if @item_held.bitmap
    @plazors.each { |object| object.dispose if object }
    @elazors.each { |object| object.dispose if object }
    @enemies.each { |object| object.dispose if object }
    @explodes.each { |object| object.dispose if object }
    @pups.each { |object| object.dispose if object }
    @bad_pups.each { |object| object.dispose if object } if @bad_pups
    @orbit_bullets.each { |object| object.dispose if object } if @orbit_bullets
    @backdrop.bitmap.dispose
    @backdrop.dispose
    @player.bitmap.dispose
    @player.dispose
    if @game_over
      @game_over.bitmap.dispose
      @game_over.dispose
    end
    @score_window.dispose
  end
end

#==============================================================================
# ** Invader Fix - Proper reset after death + stop enemy fire on game over
#------------------------------------------------------------------------------
# Put BELOW the merged invader script
#==============================================================================

class Scene_Invaders < Scene_Base

  #--------------------------------------------------------------------------
  # Recreate full scene state properly when restarting after death
  #--------------------------------------------------------------------------
  def restart_invader_game
    dispose_graphics
    initialize_game
    create_aura_overlay
    @aura_overlay.opacity = 0 if @aura_overlay
  end

  #--------------------------------------------------------------------------
  # Game over update
  #--------------------------------------------------------------------------
  def update_game_over
    @game_over.opacity += 3
    if @game_over.opacity >= 255 && Input.trigger?(:C)
      restart_invader_game
    end
  end

  #--------------------------------------------------------------------------
  # Do not let enemies keep acting after player is dead
  #--------------------------------------------------------------------------
  def update_enemies
    if @dead
      @enemies.each_with_index do |enemy, i|
        next if enemy.nil?
        enemy.update
        ensure_orbit_bullets(enemy) if enemy.type == 3

        if enemy && !enemy.disposed? &&
           (enemy.y > Graphics.height + 80 || enemy.x < -100 || enemy.x > Graphics.width + 100)
          remove_enemy_orbit_bullets(enemy)
          enemy.dispose
          @enemies[i] = nil
        end
      end
      @enemies.compact!
      return
    end

    @sound_timer += 1
    aura_active = alien2_alive?

    @enemies.each_with_index do |enemy, i|
      next if enemy.nil?

      enemy.speed_mul = 1.0
      enemy.speed_mul *= Galv_SI::ALIEN2_AURA_MULT if aura_active && enemy.type != 2

      enemy.update
      ensure_orbit_bullets(enemy) if enemy.type == 3

      if enemy_hit?(enemy) || @nukeall
        enemy.hp -= @nukeall ? enemy.mhp : 1
        if enemy.hp <= 0
          handle_enemy_death(enemy)
          enemy.dispose
          @enemies[i] = nil
        else
          RPG::SE.new(Galv_SI::PSE[0],Galv_SI::PSE[1],Galv_SI::PSE[2]).play
          enemy.flash(Color.new(255,155,155),20)
        end

      elsif player_hit?(enemy.x, enemy.y)
        handle_enemy_death(enemy)
        enemy.dispose
        @enemies[i] = nil
        damage_player(Galv_SI::COLLIDE_DAMAGE)

      else
        shot_type = enemy.consume_shot_request
        enemy_shoot(enemy, shot_type) if shot_type
      end

      if enemy && !enemy.disposed? &&
         (enemy.y > Graphics.height + 80 || enemy.x < -100 || enemy.x > Graphics.width + 100)
        remove_enemy_orbit_bullets(enemy)
        enemy.dispose
        @enemies[i] = nil
      end
    end

    @enemies.compact!
    @nukeall = false
  end

  #--------------------------------------------------------------------------
  # Optional safety: do not allow aimed bullets to fire when dead
  #--------------------------------------------------------------------------
  def enemy_shoot(enemy, shot_type = nil)
    return if @dead
    shot_type ||= enemy.consume_shot_request
    return if shot_type.nil?

    if @sound_timer >= Galv_SI::SOUND_TIMER
      RPG::SE.new(Galv_SI::ASE[0],Galv_SI::ASE[1],Galv_SI::ASE[2]).play
      @sound_timer = 0
    end

    case shot_type
    when :aimed_single
      fire_aimed_bullet(enemy, Galv_SI::BULLET_SPEED_MED)

    when :fast_triple
      [-45, 0, 45].each do |off|
        fire_aimed_bullet(enemy, Galv_SI::BULLET_SPEED_FAST, off)
      end

    when :side_fan
      [[-1.6, 3.2], [0, 3.8], [1.6, 3.2]].each do |vx, vy|
        fire_pattern_bullet(enemy.x, enemy.y, vx, vy)
      end

    when :aimed_double
      fire_aimed_bullet(enemy, Galv_SI::BULLET_SPEED_MED, -28)
      fire_aimed_bullet(enemy, Galv_SI::BULLET_SPEED_MED, 28)

    when :stream_aimed
      fire_aimed_bullet(enemy, Galv_SI::BULLET_SPEED_FAST)

    when :spread_three
      [[-1.4, 3.2], [0, 3.7], [1.4, 3.2]].each do |vx, vy|
        fire_pattern_bullet(enemy.x, enemy.y, vx, vy)
      end

    when :ring_eight
      8.times do |i|
        ang = i * Math::PI / 4.0
        vx = Math.cos(ang) * Galv_SI::BULLET_SPEED_SLOW
        vy = Math.sin(ang) * Galv_SI::BULLET_SPEED_SLOW
        fire_pattern_bullet(enemy.x, enemy.y, vx, vy, "orbit_bullet")
      end
    end
  end

end

#==============================================================================
# ** Danmaku Control + Focus Mode + Zzzz Fix
#------------------------------------------------------------------------------
# Put BELOW the merged invader script
#
# Required graphics:
#   Graphics/Invaders/player1.png
#   Graphics/Invaders/player2.png
#==============================================================================

module Galv_SI
  MAX_NUKES           = 5
  FOCUS_SPEED         = 2.2
  FOCUS_HITBOX_RADIUS = 4
end

#------------------------------------------------------------------------------
#  Player focus mode visuals + movement
#------------------------------------------------------------------------------
class Sprite_Player < Sprite
  def initialize(viewport)
    @focus_viewport = viewport
    @focus_dot = nil
    @current_player_bitmap = nil
    super(viewport)
    init_position
    create_focus_dot
    refresh_ship_bitmap(true)
  end

  def dispose
    if @focus_dot
      @focus_dot.dispose unless @focus_dot.disposed?
      @focus_dot = nil
    end
    super
  end

  def update
    super
    refresh_ship_bitmap
    update_src_rect
    update_position
    update_focus_dot
  end

  def focus_mode?
    Input.press?(:A)   # Shift key
  end

  def setup_player_image
    @cell = 1
    self.bitmap = Cache.space("player")
    @current_player_bitmap = "player"
    @cw = bitmap.width / 3
    self.src_rect.set(@cell * @cw, 0, @cw, height)
    self.ox = @cw / 2
    self.oy = height
    self.x = Graphics.width / 2
    self.y = Graphics.height / 2
  end

  def width
    self.bitmap.width / 3
  end

  def height
    self.bitmap.height
  end

  def update_src_rect
    @cell = 1 if @cell.nil?
    @cell = 1 if @cell > 2
    sx = @cell * @cw
    self.src_rect.set(sx, 0, @cw, height)
  end

  def create_focus_dot
    return if @focus_dot
    @focus_dot = Sprite.new(@focus_viewport)
    @focus_dot.bitmap = Cache.space("player1")
    @focus_dot.visible = false
    @focus_dot.z = self.z + 5
  end

  def refresh_ship_bitmap(force = false)
    wanted = focus_mode? ? "player2" : "player"
    return if !force && @current_player_bitmap == wanted

    old_x = self.x
    old_y = self.y
    old_cell = @cell || 1

    self.bitmap = Cache.space(wanted)
    @current_player_bitmap = wanted
    @cw = bitmap.width / 3
    self.ox = @cw / 2
    self.oy = height
    @cell = old_cell
    update_src_rect
    self.x = old_x
    self.y = old_y
  end

  def update_focus_dot
    return unless @focus_dot
    if focus_mode?
      cw = @focus_dot.bitmap.width / 3
      @focus_dot.src_rect.set((@cell || 1) * cw, 0, cw, @focus_dot.bitmap.height)
      @focus_dot.ox = cw / 2
      @focus_dot.oy = @focus_dot.bitmap.height / 2
      @focus_dot.x = hitbox_x
      @focus_dot.y = hitbox_y
      @focus_dot.visible = true
    else
      @focus_dot.visible = false
    end
  end

  def hitbox_x
    self.x
  end

  def hitbox_y
    self.y - self.height / 2
  end

  def update_position
    dx = 0
    dy = 0
    reverse = $galv_invader_reverse_controls_frames.to_i > 0
    speed = focus_mode? ? Galv_SI::FOCUS_SPEED : Galv_SI::SHIP_SPEED

    if Input.press?(:LEFT) && !Input.press?(:RIGHT)
      @cell = reverse ? 2 : 0
      dx += reverse ? speed : -speed
    elsif Input.press?(:RIGHT) && !Input.press?(:LEFT)
      @cell = reverse ? 0 : 2
      dx += reverse ? -speed : speed
    else
      @cell = 1
    end

    if Input.press?(:UP) && !Input.press?(:DOWN)
      dy += reverse ? speed : -speed
    elsif Input.press?(:DOWN) && !Input.press?(:UP)
      dy += reverse ? -speed : speed
    end

    if dx != 0 && dy != 0
      factor = 1.0 / Math.sqrt(2)
      dx *= factor
      dy *= factor
    end

    self.x += dx
    self.y += dy
    self.x = [[self.x, width / 2].max, Graphics.width - width / 2].min
    self.y = [[self.y, height / 2].max, Graphics.height - height / 2].min
  end
end

#------------------------------------------------------------------------------
#  Scene_Invaders updates
#------------------------------------------------------------------------------
class Scene_Invaders < Scene_Base
  #--------------------------------------------------------------------------
  # Init
  #--------------------------------------------------------------------------
  alias danmaku_patch_init_variables init_variables
  def init_variables
    danmaku_patch_init_variables
    @nuke_count = 0
    @item = nil
  end

  #--------------------------------------------------------------------------
  # Correct player size helpers
  #--------------------------------------------------------------------------
  def player_width
    @player ? @player.width : 0
  end

  def player_height
    @player ? @player.height : 0
  end

  #--------------------------------------------------------------------------
  # Focus hitbox
  #--------------------------------------------------------------------------
  def player_hit?(x, y)
    return false unless @player
    if @player.respond_to?(:focus_mode?) && @player.focus_mode?
      hx = @player.hitbox_x
      hy = @player.hitbox_y
      r = Galv_SI::FOCUS_HITBOX_RADIUS
      return x.between?(hx - r, hx + r) && y.between?(hy - r, hy + r)
    else
      return x.between?(@player.x - player_width / 6, @player.x + player_width / 6) &&
             y.between?(@player.y - player_height / 2, @player.y + player_height / 2)
    end
  end

  #--------------------------------------------------------------------------
  # Draw nuke count
  #--------------------------------------------------------------------------
  def draw_item_held
    return unless @item_held

    if @item_held.bitmap && !@item_held.bitmap.disposed?
      @item_held.bitmap.dispose
    end

    if @nuke_count.to_i <= 0
      @item = nil
      @item_held.opacity = 0
      return
    end

    @item = "nuke"
    icon = Cache.space("item_nuke")
    bw = icon.width + 28
    bh = [icon.height, 24].max
    bmp = Bitmap.new(bw, bh)
    bmp.blt(0, 0, icon, icon.rect)
    bmp.font.size = 20
    bmp.draw_text(icon.width - 2, 0, 28, bh, @nuke_count.to_s, 1)
    @item_held.bitmap = bmp
    @item_held.opacity = 255
  end

  #--------------------------------------------------------------------------
  # Clear bullets with nuke
  #--------------------------------------------------------------------------
  def clear_enemy_projectiles
    @elazors.each do |b|
      b.dispose if b && !b.disposed?
    end
    @elazors.clear

    @orbit_bullets.each do |b|
      b.dispose if b && !b.disposed?
    end
    @orbit_bullets.clear
  end

  #--------------------------------------------------------------------------
  # Use one nuke
  #--------------------------------------------------------------------------
  def use_nuke
    return if @dead
    return if @nuke_count.to_i <= 0

    @nukeall = true
    @nuke_count -= 1
    RPG::SE.new(Galv_SI::NSE[0],Galv_SI::NSE[1],Galv_SI::NSE[2]).play
    @difficulty *= 0.75
    @shoot_difficulty *= 0.75 if @shoot_difficulty
    @flash.opacity = 225 if @flash
    clear_enemy_projectiles
    draw_item_held
  end

  #--------------------------------------------------------------------------
  # Controls
  #   Z     = fire   (Input::C)
  #   X     = nuke   (keyboard X = Input::B)
  #   A     = exit   (keyboard A = Input::X)
  #   Shift = focus  (Input::A)
  #--------------------------------------------------------------------------
  def update_player_actions
    $galv_invader_reverse_controls_frames -= 1 if $galv_invader_reverse_controls_frames.to_i > 0

    if Input.trigger?(:C) && !@dead
      if @gun_type == 2 && @guns >= 6
        if toggle_beam_active?
          remove_toggle_beam
        else
          player_shoot
        end
      else
        return if Galv_SI::MAX_SHOTS * @guns <= @plazors.count
        player_shoot
      end
    end

    if Input.trigger?(:B)
      use_nuke
    end

    if Input.trigger?(:X)
      SceneManager.goto(Scene_Map)
    end
  end

  #--------------------------------------------------------------------------
  # Powerups
  #--------------------------------------------------------------------------
  def do_powerup(type)
    @player.flash(Color.new(155,255,155),20)
    case type
    when 0
      RPG::SE.new(Galv_SI::BSE[0],Galv_SI::BSE[1],Galv_SI::BSE[2]).play
      if @player_shields == Galv_SI::PLAYER_SHIELDS
        @bonus_shields += 1 if @bonus_shields < Galv_SI::PLAYER_SHIELDS
      else
        @player_shields = Galv_SI::PLAYER_SHIELDS
      end
      @score_window.refresh(@player_shields.to_f, @bonus_shields)

    when 1
      RPG::SE.new(Galv_SI::PUSE[0],Galv_SI::PUSE[1],Galv_SI::PUSE[2]).play
      if @gun_type != 0
        @gun_type = 0
        @guns = [@guns, 1].max
        remove_toggle_beam
      elsif @guns < Galv_SI::MAX_GUN_LEVEL_EX
        @guns += 1
      end

    when 2
      RPG::SE.new(Galv_SI::PUSE[0],Galv_SI::PUSE[1],Galv_SI::PUSE[2]).play
      if @gun_type != 1
        @gun_type = 1
        @guns = [@guns, 1].max
        remove_toggle_beam
      elsif @guns < Galv_SI::MAX_GUN_LEVEL_EX
        @guns += 1
      end

    when 3
      RPG::SE.new(Galv_SI::PUSE[0],Galv_SI::PUSE[1],Galv_SI::PUSE[2]).play
      @nuke_count = [[@nuke_count.to_i + 1, 0].max, Galv_SI::MAX_NUKES].min
      draw_item_held

    when 4
      RPG::SE.new(Galv_SI::PUSE[0],Galv_SI::PUSE[1],Galv_SI::PUSE[2]).play
      if @gun_type != 2
        @gun_type = 2
        @guns = [@guns, 1].max
      elsif @guns < Galv_SI::MAX_GUN_LEVEL_EX
        @guns += 1
      end

    when 999
      RPG::SE.new(Galv_SI::PUSE[0],Galv_SI::PUSE[1],Galv_SI::PUSE[2]).play
      @difficulty *= Galv_SI::RESET_RATIO
      @shoot_difficulty *= Galv_SI::RESET_RATIO if @shoot_difficulty

      min_t, max_t = current_spawn_range
      slower_spawn = max_t + rand(max_t - min_t + 1)
      @spawn_timer = [@spawn_timer, slower_spawn].max
      @enemy_wave += 1
    end
  end
end

#==============================================================================
# ** Bullet Hell lifecycle safety (keep this patch at the script's EOF)
#==============================================================================
class Scene_Invaders < Scene_Base
  alias wcf_bullethell_destroy_player destroy_player
  def destroy_player
    return if @dead || @death_in_progress
    @death_in_progress = true
    @dead = true
    wcf_bullethell_destroy_player
    clear_hazards_after_player_death
    @death_in_progress = false
  end

  alias wcf_bullethell_damage_player damage_player
  def damage_player(amount)
    return if @dead || @death_in_progress
    wcf_bullethell_damage_player(amount)
  end

  alias wcf_bullethell_player_hit player_hit?
  def player_hit?(x, y)
    return false if @dead || @death_in_progress
    return false unless @player
    return false if @player.disposed? || @player.opacity <= 0
    wcf_bullethell_player_hit(x, y)
  end

  alias wcf_bullethell_update_elazors update_elazors
  def update_elazors
    if @dead
      dispose_sprite_array(@elazors)
      return
    end
    wcf_bullethell_update_elazors
  end

  alias wcf_bullethell_update_orbit_bullets update_orbit_bullets
  def update_orbit_bullets
    if @dead
      dispose_sprite_array(@orbit_bullets)
      return
    end
    wcf_bullethell_update_orbit_bullets
  end

  alias wcf_bullethell_update_pups update_pups
  def update_pups
    return if @dead
    wcf_bullethell_update_pups
  end

  alias wcf_bullethell_update_bad_pups update_bad_pups
  def update_bad_pups
    return if @dead
    wcf_bullethell_update_bad_pups
  end

  alias wcf_bullethell_update_game_over update_game_over
  def update_game_over
    return unless @game_over
    if Input.trigger?(:X)
      SceneManager.goto(Scene_Map)
      return
    end
    wcf_bullethell_update_game_over
  end

  def clear_hazards_after_player_death
    remove_toggle_beam if respond_to?(:remove_toggle_beam)
    # Do not clear @elazors inside its own each-loop. player_hit? is already
    # disabled, and update_elazors clears the array safely on the next frame.
    dispose_sprite_array(@orbit_bullets)
    dispose_sprite_array(@bad_pups)
    dispose_sprite_array(@pups)
    @nukeall = false
  end

  def dispose_sprite_array(array)
    return unless array
    array.each do |sprite|
      next unless sprite
      sprite.dispose unless sprite.disposed?
    end
    array.clear
  end
end
