#------------------------------------------------------------------------------#
#  Galv's Invader Mini Game
#------------------------------------------------------------------------------#
#  For: RPGMAKER VX ACE
#  Version 2.2
#  Thanks Ocedic for add-on ideas
#------------------------------------------------------------------------------#
#  2025-08-14 - Version 2.2 - adjusted alien3 to spawn and move lower into screen
#                           - updated tracking elazors to move down, form line, pause, then track
#  2025-08-14 - Version 2.1 - fixed tracking elazors to move past target like Hextech Micro-Rockets
#                           - added spread-shot gun (type 2, powerup4) to counter alien3
#  2025-08-14 - Version 2.0 - fixed alien3 not spawning due to spawn logic
#  2025-08-14 - Version 1.9 - added POWERUP_CHANCE for adjustable power-up spawn rate
#                           - added alien3 with 4 tracking elazors that pause and lock on
#  2025-08-14 - Version 1.8 - fixed excessive enemy shooting frequency
#  2025-08-14 - Version 1.7 - fixed enemies stopping shooting due to elazors array mismatch
#  2025-08-14 - Version 1.6 - added cone-pattern shooting for alien1 (2 elazors) and alien2 (3 elazors)
#  2025-08-14 - Version 1.5 - fixed syntax errors in do_powerup, destroy_player, and update_pups
#  2025-08-14 - Version 1.4 - fixed collision detection for power-ups and enemies
#  2025-08-14 - Version 1.3 - added 6-directional movement for player
#  2013-03-20 - Version 1.2 - added options for reset ratio and max gun powerup
#  2013-03-20 - Version 1.1 - added enemy types, new gun type, new powerup
#  2013-03-18 - Version 1.0 - release
#------------------------------------------------------------------------------#
#  A simple shooter mini game that can be played within Ace with a script call.
#
#  The game is designed to be simple. Enemies are random, they shoot random
#  lazors at you. Powerups are random. Slowly during the course of the game
#  the enemies spawn faster and faster until eventually the player will be
#  overrun completely and die. A set time through the game, a reset powerup will
#  spawn. If the player manages to get it, they get another chance at more
#  points as it sets the spawn speed back to the start.
#  Variables are used for current score and high score which you can use in
#  your game to give your player bonuses for doing well or not.
#
#  You'll need the demo for all the graphics (but feel free to create your own)
#
#  NOTE: This is intended to be simple for now. Please don't ask for add-ons
#  or improvements. I might improve it later but for now, it is what it is.
#------------------------------------------------------------------------------#

#------------------------------------------------------------------------------#
#  CONTROLS
#------------------------------------------------------------------------------#
#  Left/Right/Up/Down - moves in 6 directions (left, right, up, down, and diagonals)
#  Space/Z/Enter      - fire your lazor
#  ESC/X              - Leave the mini game
#  A                  - Use held item (currently only nuke)
#------------------------------------------------------------------------------#
#  POWERUPS
#------------------------------------------------------------------------------#
#  Heath  - restores shields completely. If shields full, adds to an bonus bar
#  Zzzz   - resets enemy spawn rate to beginning (spawned only at a set time)
#  Nuke   - Can only hold one nuke at a time. Press A to destroy all enemies.
#
#  Lazors - Get lazors or increases number of lazors fired
#  Lazorball - Get lazorballs or increases number of lazorballs fired
#  Penetrating Lazor - Get penetrating lazor or increases size
#
#  NOTE: Obtaining weapons equips them or improves them if already equipped
#  NOTE2: Yes, I do know it's not spelled "lazor"
#------------------------------------------------------------------------------#

#------------------------------------------------------------------------------#
#  SCRIPT CALL:
#------------------------------------------------------------------------------#
#  SceneManager.call(Scene_Invaders)       # Starts the minigame.
#------------------------------------------------------------------------------#

($imported ||= {})["Galv_Invaders"] = true
module Galv_SI

#------------------------------------------------------------------------------#
#  SCRIPT SETTINGS
#------------------------------------------------------------------------------#

  #----------------#
  # PLAYER OPTIONS #
  #----------------#

  PLAYER_SHIELDS = 10  # Hits player can take before game over

  MAX_SHOTS = 10    # Maximum number of shots player can have on screen at a time
  Max_Gun_Level = 5 # Max gun powerup level (5 is the highest)

  SE = ["Attack2",80,150]   # "SE_Name",volume,pitch - SE for player laser
  SE1 = ["Heal5",80,160]    # "SE_Name",volume,pitch - SE for player lazorball
  SE2 = ["Attack3",80,140]  # "SE_Name",volume,pitch - SE for player penetrating lazor
  NSE = ["Explosion3",120,100]  # "SE_Name",volume,pitch - SE for nuke

  PSE = ["Damage5",90,150]  # "SE_Name",volume,pitch - SE when player damaged
  KSE = ["Explosion7",100,100]  # "SE_Name",volume,pitch - SE when destroyed

  BSE = ["Down4",120,150]  # "SE_Name",volume,pitch - SE when bonus shield gain
  PUSE = ["Item1",80,150]  # "SE_Name",volume,pitch - SE when get powerup

  SHIP_SPEED = 5        # Speed at which player can move ship in any direction
  LAZOR_SPEED = 5       # Speed the lazor fires
  PENETRATE_SPEED = 4   # Slower speed for penetrating lazor

  #---------------#
  # ENEMY OPTIONS #
  #---------------#

  SPAWN_SPEED = 100    # Lower means faster spawn. Higher is slower spawn.

  LEVEL2 = 30          # Seconds until level 2 ships can start spawning
  LEVEL3 = 100         # Seconds until level 3 ships can start spawning
  LEVEL4 = 130         # Seconds until level 4 ships (alien3) can start spawning

  LEVEL1_HP = 1        # Level 1 enemies have this much hp
  LEVEL2_HP = 2        # Level 2 enemies have this much hp
  LEVEL3_HP = 3       # Level 3 enemies have this much hp
  LEVEL4_HP = 4       # Level 4 enemies (alien3) have this much hp

  LEVEL1_DOWN_SPEED = 1.0  # Downward speed for level 1 enemies (customizable)
  LEVEL2_DOWN_SPEED = 1.5  # Downward speed for level 2 enemies (customizable)
  LEVEL3_DOWN_SPEED = 1.0  # Downward speed for level 3 enemies (customizable)
  LEVEL4_DOWN_SPEED = 1.0  # Downward speed for level 4 enemies (customizable)

  ELAZOR_SPEED = 5     # Enemy lazor speed (normal); tracking elazors use 3x

  ASE = ["Attack2",80,110]  # "SE_Name",volume,pitch - SE for enemy shooting
  DSE = ["Fire3",90,150]  # "SE_Name",volume,pitch - SE for enemy dying

  SHOOT_CHANCE = 995   # Base shooting probability (lower = more frequent)

  #---------------#
  # OTHER OPTIONS #
  #---------------#

  SCORE_VAR = 19         # Variable id to keep track of score
  HIGH_SCORE_VAR = 20    # Variable id to keep track of highest score

  RESET_PUP = 80       # Seconds between reset powerup spawns
  RESET_AMOUNT = 1.5    # Ratio of difficulty when reset powerup is obtained

  POWERUP_CHANCE = 994  # Power-up spawn probability (lower = more frequent)

  SOUND_TIMER = 5       # Prevent enemy lazor sound spam by increasing this

  DESTROY_PUPS = false  # Can destroy powerups true or false

  LAZOR_DAMAGE = 1      # Damage done when lazors hit
  COLLIDE_DAMAGE = 1    # Damage done when collide with enemy

  BGM_LIST = [ # don't touch
  # List of BGM's to random.  ["BGM_Name",volume,pitch]

        ["Battle6",100,110],
        ["Battle5",100,110],

        # ["Battle5",100,110],   # Add more as required
        # ["Battle5",100,110],   # Add more as required
        # ["Battle5",100,110],   # Add more as required

  ] # don't touch

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
      self.zoom_x = 1 + 0.2 * (@level - 1)  # Increase width with level
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