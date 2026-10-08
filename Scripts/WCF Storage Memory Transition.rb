#==============================================================================
# ** WCF Storage Memory Transition
#------------------------------------------------------------------------------
# Moves the storage-room parallax and overlay upward together during the floor
# collapse. Characters remain in map space, creating the impression that Hải
# Quỳ drops through the floor while the room rises out of frame.
#==============================================================================

class Game_Temp
  attr_accessor :wcf_storage_fall_offset
  attr_accessor :wcf_falling_player_offset
end

class Spriteset_Map
  alias wcf_storage_memory_dispose dispose
  def dispose
    wcf_storage_end_collapse
    wcf_storage_memory_dispose
  end

  def wcf_storage_begin_collapse
    return if @wcf_storage_fall_tiles
    @wcf_storage_hidden_planes = [@parallax] + (@layer_images || []).compact
    @wcf_storage_fall_tiles = []
    @wcf_storage_hidden_planes.each do |plane|
      bitmap = plane.bitmap
      next unless bitmap && bitmap.width > 0 && bitmap.height > 0
      start_x = -(plane.ox.to_i % bitmap.width)
      start_y = -(plane.oy.to_i % bitmap.height)
      # Storage_Base and Storage_Top are authored as one 544x416 screen. A
      # Plane repeats them automatically, but that repetition must not follow
      # the room upward: otherwise a second copy enters from the bottom.
      sprite = Sprite.new(@viewport1)
      sprite.bitmap = bitmap
      sprite.x = start_x
      sprite.y = start_y
      sprite.z = plane.z
      sprite.opacity = plane.opacity
      sprite.blend_type = plane.blend_type
      @wcf_storage_fall_tiles << [sprite, start_y]
      plane.visible = false
    end
  end

  def wcf_storage_update_collapse(offset)
    return unless @wcf_storage_fall_tiles
    @wcf_storage_fall_tiles.each do |sprite, start_y|
      sprite.y = start_y - offset
    end
  end

  # Remove the moving room tiles while leaving the real parallax/layers hidden.
  # The originals are restored only by wcf_storage_end_collapse, under a fade.
  def wcf_storage_hide_room
    (@wcf_storage_fall_tiles || []).each {|sprite, _| sprite.dispose unless sprite.disposed? }
    @wcf_storage_fall_tiles = nil
  end

  def wcf_storage_end_collapse
    wcf_storage_hide_room
    (@wcf_storage_hidden_planes || []).each do |plane|
      plane.visible = true unless plane.disposed?
    end
    @wcf_storage_hidden_planes = nil
  end
end

class Sprite_Character
  alias wcf_falling_memory_update_position update_position
  def update_position
    wcf_falling_memory_update_position
    if @character == $game_player && $game_temp
      self.y += ($game_temp.wcf_falling_player_offset || 0).to_i
    end
  end
end

class Game_Interpreter
  def wcf_storage_floor_collapse(duration = 90, distance = 520)
    duration = [duration.to_i, 1].max
    distance = distance.to_f
    $game_temp.wcf_storage_fall_offset = 0.0
    spriteset = SceneManager.scene.spriteset
    spriteset.wcf_storage_begin_collapse
    duration.times do |frame|
      rate = (frame + 1).to_f / duration
      # Ease in: the room starts shifting slowly, then rapidly leaves frame.
      $game_temp.wcf_storage_fall_offset = distance * rate * rate
      spriteset.wcf_storage_update_collapse($game_temp.wcf_storage_fall_offset)
      Fiber.yield
    end
    $game_temp.wcf_storage_fall_offset = distance
  end

  def wcf_storage_hide_room
    scene = SceneManager.scene
    scene.spriteset.wcf_storage_hide_room if scene && scene.respond_to?(:spriteset)
  end

  def wcf_storage_floor_collapse_reset
    $game_temp.wcf_storage_fall_offset = 0.0
    scene = SceneManager.scene
    scene.spriteset.wcf_storage_end_collapse if scene && scene.respond_to?(:spriteset)
  end

  def wcf_falling_player_leave_screen(duration = 60, distance = 360)
    duration = [duration.to_i, 1].max
    distance = distance.to_f
    start = ($game_temp.wcf_falling_player_offset || 0).to_f
    duration.times do |frame|
      rate = (frame + 1).to_f / duration
      # Smooth acceleration/deceleration keeps the exit readable while making
      # the final position deterministic and fully outside the viewport.
      eased = rate * rate * (3.0 - 2.0 * rate)
      $game_temp.wcf_falling_player_offset = start - distance * eased
      Fiber.yield
    end
    $game_temp.wcf_falling_player_offset = start - distance
  end

  def wcf_falling_player_offset_reset
    $game_temp.wcf_falling_player_offset = 0.0
  end
end
