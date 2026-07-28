#==============================================================================
# Region Stair Movement - Toggle + Cutscene Compatible
# RPG Maker VX Ace / RGSS3
#------------------------------------------------------------------------------
# Region 63 = stair path.
#
# Script Calls:
#
#   RegionStairs.enable
#   RegionStairs.disable
#   RegionStairs.toggle
#   RegionStairs.enabled?
#
# In Set Move Route > Script, you can also use:
#
#   RegionStairs.enable
#   RegionStairs.disable
#
# Example cutscene:
#
#   Script Call:
#     RegionStairs.enable
#
#   Set Move Route: Player
#     Move Left
#     Move Left
#     Move Left
#
#   Script Call:
#     RegionStairs.disable
#
# Put below Materials and above Main.
# Delete/disable all older stair scripts first.
#==============================================================================

module RegionStairs
  REGION_ID = 63

  # If false, stair movement starts OFF when starting a new game.
  START_ENABLED = false

  # If true, Region 63 tiles can be walked on even if tileset passability is X.
  FORCE_REGION_PASSABLE = true

  # If true, diagonal Region 63 movement is preferred over straight Region 63.
  PREFER_DIAGONAL = true

  # Face left/right when moving diagonally on stairs.
  FACE_HORIZONTAL_ON_DIAGONAL = true

  # Sprite Y offset while standing on Region 63.
  SPRITE_Y_OFFSET = 0

  # Extra walking animation speed while standing on Region 63.
  EXTRA_ANIM_SPEED = 2

  #--------------------------------------------------------------------------
  # Script calls
  #--------------------------------------------------------------------------

  def self.enable
    $game_system.region_stairs_enabled = true if $game_system
  end

  def self.disable
    $game_system.region_stairs_enabled = false if $game_system
  end

  def self.toggle
    return unless $game_system
    $game_system.region_stairs_enabled = !$game_system.region_stairs_enabled
  end

  def self.enabled?
    return false unless $game_system
    $game_system.region_stairs_enabled
  end
end

#==============================================================================
# Game_System
#==============================================================================

class Game_System
  attr_accessor :region_stairs_enabled

  alias region_stairs_initialize initialize

  def initialize
    region_stairs_initialize
    @region_stairs_enabled = RegionStairs::START_ENABLED
  end

  def region_stairs_enabled
    @region_stairs_enabled = RegionStairs::START_ENABLED if @region_stairs_enabled.nil?
    @region_stairs_enabled
  end
end

#==============================================================================
# Game_Map
#==============================================================================

class Game_Map
  def region_stair?(x, y)
    valid?(x, y) && region_id(x, y) == RegionStairs::REGION_ID
  end
end

#==============================================================================
# Game_CharacterBase
#==============================================================================

class Game_CharacterBase

  alias region_stairs_char_initialize initialize

  def initialize(*args)
    region_stairs_char_initialize(*args)
    @region_stairs_last_dx = 0
    @region_stairs_last_dy = 0
  end

  #--------------------------------------------------------------------------
  # Region check
  #--------------------------------------------------------------------------

  def region_stairs_on_stair?
    $game_map.region_stair?(@x, @y)
  end

  def region_stairs_region_at_delta?(dx, dy)
    x2 = $game_map.round_x(@x + dx)
    y2 = $game_map.round_y(@y + dy)
    $game_map.region_stair?(x2, y2)
  end

  #--------------------------------------------------------------------------
  # Direction helpers
  #--------------------------------------------------------------------------

  def region_stairs_dir_delta(d)
    case d
    when 2 then [0, 1]
    when 4 then [-1, 0]
    when 6 then [1, 0]
    when 8 then [0, -1]
    else [0, 0]
    end
  end

  def region_stairs_delta_dir(dx, dy)
    return 4 if dx < 0
    return 6 if dx > 0
    return 8 if dy < 0
    return 2 if dy > 0
    return @direction
  end

  def region_stairs_horz_dir(dx)
    dx < 0 ? 4 : 6
  end

  def region_stairs_vert_dir(dy)
    dy < 0 ? 8 : 2
  end

  #--------------------------------------------------------------------------
  # Candidate tiles based on pressed direction
  #--------------------------------------------------------------------------

  def region_stairs_candidates_for_direction(d)
    case d
    when 2
      [
        [0, 1],
        [-1, 1],
        [1, 1]
      ]
    when 4
      [
        [-1, 0],
        [-1, -1],
        [-1, 1]
      ]
    when 6
      [
        [1, 0],
        [1, -1],
        [1, 1]
      ]
    when 8
      [
        [0, -1],
        [-1, -1],
        [1, -1]
      ]
    else
      []
    end
  end

  #--------------------------------------------------------------------------
  # Choose stair tile
  #--------------------------------------------------------------------------

  def region_stairs_choose_delta(d)
    return nil unless RegionStairs.enabled?

    candidates = region_stairs_candidates_for_direction(d)
    candidates = candidates.select do |dx, dy|
      region_stairs_region_at_delta?(dx, dy)
    end

    return nil if candidates.empty?

    candidates.sort_by! do |dx, dy|
      diagonal = dx != 0 && dy != 0
      same_as_last = dx == @region_stairs_last_dx &&
                     dy == @region_stairs_last_dy

      score = 0
      score -= 100 if same_as_last
      score -= 50 if RegionStairs::PREFER_DIAGONAL && diagonal
      score
    end

    candidates[0]
  end

  #--------------------------------------------------------------------------
  # Passability
  #--------------------------------------------------------------------------

  def region_stairs_can_move?(dx, dy)
    x2 = $game_map.round_x(@x + dx)
    y2 = $game_map.round_y(@y + dy)

    return false unless $game_map.valid?(x2, y2)
    return true if @through || debug_through?
    return false if collide_with_characters?(x2, y2)

    if RegionStairs::FORCE_REGION_PASSABLE
      return true if $game_map.region_stair?(x2, y2)
    end

    if dx != 0 && dy != 0
      horz = region_stairs_horz_dir(dx)
      vert = region_stairs_vert_dir(dy)
      return diagonal_passable?(@x, @y, horz, vert)
    else
      d = region_stairs_delta_dir(dx, dy)
      return map_passable?(@x, @y, d)
    end
  end

  #--------------------------------------------------------------------------
  # Move on stair
  #--------------------------------------------------------------------------

  def region_stairs_move(dx, dy, turn_ok = true)
    @move_succeed = region_stairs_can_move?(dx, dy)

    if dx != 0 && dy != 0
      if RegionStairs::FACE_HORIZONTAL_ON_DIAGONAL
        set_direction(region_stairs_horz_dir(dx)) if turn_ok
      else
        set_direction(region_stairs_delta_dir(dx, dy)) if turn_ok
      end
    else
      set_direction(region_stairs_delta_dir(dx, dy)) if turn_ok
    end

    if @move_succeed
      old_x = @x
      old_y = @y

      @x = $game_map.round_x(@x + dx)
      @y = $game_map.round_y(@y + dy)

      @real_x = old_x
      @real_y = old_y

      @region_stairs_last_dx = dx
      @region_stairs_last_dy = dy

      increase_steps
    end
  end

  #--------------------------------------------------------------------------
  # Override move_straight
  # This affects player, followers, and events.
  # It also works with Set Move Route.
  #--------------------------------------------------------------------------

  alias region_stairs_original_move_straight move_straight

  def move_straight(d, turn_ok = true)
    result = region_stairs_choose_delta(d)

    if result
      dx, dy = result
      region_stairs_move(dx, dy, turn_ok)
      return
    end

    @region_stairs_last_dx = 0
    @region_stairs_last_dy = 0

    region_stairs_original_move_straight(d, turn_ok)
  end

  #--------------------------------------------------------------------------
  # Override move_diagonal
  # This affects player, followers, and events.
  # It also works with Set Move Route.
  #--------------------------------------------------------------------------

  alias region_stairs_original_move_diagonal move_diagonal

  def move_diagonal(horz, vert)
    dx = horz == 4 ? -1 : 1
    dy = vert == 8 ? -1 : 1

    if RegionStairs.enabled? && region_stairs_region_at_delta?(dx, dy)
      region_stairs_move(dx, dy, true)
      return
    end

    @region_stairs_last_dx = 0
    @region_stairs_last_dy = 0

    region_stairs_original_move_diagonal(horz, vert)
  end

  #--------------------------------------------------------------------------
  # Sprite Y shift
  #--------------------------------------------------------------------------

  alias region_stairs_original_shift_y shift_y

  def shift_y(*args, &block)
    region_stairs_original_shift_y(*args, &block) +
    (region_stairs_on_stair? ? RegionStairs::SPRITE_Y_OFFSET : 0)
  end

  #--------------------------------------------------------------------------
  # Animation speed
  #--------------------------------------------------------------------------

  alias region_stairs_original_update_anime_count update_anime_count

  def update_anime_count(*args, &block)
    region_stairs_original_update_anime_count(*args, &block)
    @anime_count += RegionStairs::EXTRA_ANIM_SPEED if region_stairs_on_stair?
  end
end

#==============================================================================
# Game_Player
#==============================================================================

class Game_Player < Game_Character

  alias region_stairs_player_move_straight move_straight

  def move_straight(d, turn_ok = true)
    result = region_stairs_choose_delta(d)

    if result
      dx, dy = result
      @followers.move if region_stairs_can_move?(dx, dy)
      region_stairs_move(dx, dy, turn_ok)
      return
    end

    region_stairs_player_move_straight(d, turn_ok)
  end

  alias region_stairs_player_move_diagonal move_diagonal

  def move_diagonal(horz, vert)
    dx = horz == 4 ? -1 : 1
    dy = vert == 8 ? -1 : 1

    if RegionStairs.enabled? && region_stairs_region_at_delta?(dx, dy)
      @followers.move if region_stairs_can_move?(dx, dy)
      region_stairs_move(dx, dy, true)
      return
    end

    region_stairs_player_move_diagonal(horz, vert)
  end
end

#==============================================================================
# End of Script
#==============================================================================