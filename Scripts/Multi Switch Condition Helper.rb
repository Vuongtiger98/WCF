#==============================================================================
# ■ Multi Switch Helper
#------------------------------------------------------------------------------
# For RPG Maker VX Ace / RGSS3
# Place this script under Materials, above Main.
#
# Use in Conditional Branch > Script:
#
#   all_switches_on?(1, 2, 3)
#   any_switch_on?(1, 2, 3)
#   no_switches_on?(1, 2, 3)
#   all_switches_off?(1, 2, 3)
#
# Use in Event Command > Script:
#
#   turn_switches_on(1, 2, 3)
#   turn_switches_off(1, 2, 3)
#   set_switches(true, 1, 2, 3)
#   set_switches(false, 1, 2, 3)
#   toggle_switches(1, 2, 3)
#
# You can also use arrays:
#
#   turn_switches_on([1, 2, 3])
#
#==============================================================================

module MultiSwitchHelper
  #--------------------------------------------------------------------------
  # ● Convert arguments into clean switch ID array
  #--------------------------------------------------------------------------
  def self.clean_ids(args)
    args.flatten.compact.map { |id| id.to_i }.select { |id| id > 0 }
  end

  #--------------------------------------------------------------------------
  # ● True if ALL listed switches are ON
  #--------------------------------------------------------------------------
  def self.all_on?(*switch_ids)
    ids = clean_ids(switch_ids)
    return false if ids.empty?
    ids.all? { |id| $game_switches[id] == true }
  end

  #--------------------------------------------------------------------------
  # ● True if ANY listed switch is ON
  #--------------------------------------------------------------------------
  def self.any_on?(*switch_ids)
    ids = clean_ids(switch_ids)
    return false if ids.empty?
    ids.any? { |id| $game_switches[id] == true }
  end

  #--------------------------------------------------------------------------
  # ● True if NONE of the listed switches are ON
  #--------------------------------------------------------------------------
  def self.none_on?(*switch_ids)
    ids = clean_ids(switch_ids)
    return false if ids.empty?
    ids.none? { |id| $game_switches[id] == true }
  end

  #--------------------------------------------------------------------------
  # ● True if ALL listed switches are OFF
  #--------------------------------------------------------------------------
  def self.all_off?(*switch_ids)
    ids = clean_ids(switch_ids)
    return false if ids.empty?
    ids.all? { |id| $game_switches[id] == false }
  end

  #--------------------------------------------------------------------------
  # ● Set multiple switches to true/false
  #--------------------------------------------------------------------------
  def self.set(value, *switch_ids)
    ids = clean_ids(switch_ids)
    ids.each do |id|
      $game_switches[id] = value ? true : false
    end
    $game_map.need_refresh = true if $game_map
  end

  #--------------------------------------------------------------------------
  # ● Turn multiple switches ON
  #--------------------------------------------------------------------------
  def self.turn_on(*switch_ids)
    set(true, *switch_ids)
  end

  #--------------------------------------------------------------------------
  # ● Turn multiple switches OFF
  #--------------------------------------------------------------------------
  def self.turn_off(*switch_ids)
    set(false, *switch_ids)
  end

  #--------------------------------------------------------------------------
  # ● Toggle multiple switches
  #--------------------------------------------------------------------------
  def self.toggle(*switch_ids)
    ids = clean_ids(switch_ids)
    ids.each do |id|
      $game_switches[id] = !$game_switches[id]
    end
    $game_map.need_refresh = true if $game_map
  end
end

#==============================================================================
# ■ Game_Interpreter
#------------------------------------------------------------------------------
# Allows easy use inside event Script Calls and Conditional Branch > Script.
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # ● Check if all switches are ON
  #--------------------------------------------------------------------------
  def all_switches_on?(*switch_ids)
    MultiSwitchHelper.all_on?(*switch_ids)
  end

  #--------------------------------------------------------------------------
  # ● Check if any switch is ON
  #--------------------------------------------------------------------------
  def any_switch_on?(*switch_ids)
    MultiSwitchHelper.any_on?(*switch_ids)
  end

  #--------------------------------------------------------------------------
  # ● Check if none of the switches are ON
  #--------------------------------------------------------------------------
  def no_switches_on?(*switch_ids)
    MultiSwitchHelper.none_on?(*switch_ids)
  end

  #--------------------------------------------------------------------------
  # ● Check if all switches are OFF
  #--------------------------------------------------------------------------
  def all_switches_off?(*switch_ids)
    MultiSwitchHelper.all_off?(*switch_ids)
  end

  #--------------------------------------------------------------------------
  # ● Turn multiple switches ON
  #--------------------------------------------------------------------------
  def turn_switches_on(*switch_ids)
    MultiSwitchHelper.turn_on(*switch_ids)
  end

  #--------------------------------------------------------------------------
  # ● Turn multiple switches OFF
  #--------------------------------------------------------------------------
  def turn_switches_off(*switch_ids)
    MultiSwitchHelper.turn_off(*switch_ids)
  end

  #--------------------------------------------------------------------------
  # ● Set multiple switches to true/false
  #--------------------------------------------------------------------------
  def set_switches(value, *switch_ids)
    MultiSwitchHelper.set(value, *switch_ids)
  end

  #--------------------------------------------------------------------------
  # ● Toggle multiple switches
  #--------------------------------------------------------------------------
  def toggle_switches(*switch_ids)
    MultiSwitchHelper.toggle(*switch_ids)
  end
end