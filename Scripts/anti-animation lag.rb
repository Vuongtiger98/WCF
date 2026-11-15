#==============================================================================
# +++ MOG - Anti Animation Lag (v1.0) +++
#==============================================================================
# By Moghunter
# http://www.atelier-rgss.com
#==============================================================================
# This script removes lag related to disposing of an animation.
#==============================================================================

#==============================================================================
# During game execution, RPG Maker VX ACE takes a considerable amount of time
# to read or dispose of a file. (Image, sound, or video)
# This can cause small freezes during gameplay, especially noticeable when
# using relatively heavy files. (Animation files.)
#==============================================================================
# NOTE - This script does not eliminate lag related to the loading time
# of an animation, only the time related to disposing of an animation.
#==============================================================================
  
#===============================================================================
# ■ Game_Temp
#===============================================================================
class Game_Temp
  attr_accessor :animation_garbage
  
  #--------------------------------------------------------------------------
  # ● Initialize
  #--------------------------------------------------------------------------  
  alias mog_anti_lag_animation_initialize initialize
  def initialize
      @animation_garbage = []
      mog_anti_lag_animation_initialize
  end  
  
end

#===============================================================================
# ■ Game System
#===============================================================================
class Game_System
  
  attr_accessor :anti_lag_animation
  
  #--------------------------------------------------------------------------
  # ● Initialize
  #--------------------------------------------------------------------------    
  alias mog_antilag_animation_initialize initialize
  def initialize
      @anti_lag_animation = true
      mog_antilag_animation_initialize
  end  
  
end  

#===============================================================================
# ■ SceneManager
#===============================================================================
class << SceneManager
  
  #--------------------------------------------------------------------------
  # ● Call
  #--------------------------------------------------------------------------  
  alias mog_anti_lag_animation_call call
  def call(scene_class)
      mog_anti_lag_animation_call(scene_class)
      dispose_animation_garbage 
  end  
  
  #--------------------------------------------------------------------------
  # ● Goto
  #--------------------------------------------------------------------------    
  alias mog_anti_lag_animation_goto goto
  def goto(scene_class)
      mog_anti_lag_animation_goto(scene_class)
      dispose_animation_garbage 
  end
  
  #--------------------------------------------------------------------------
  # ● Dispose Animation Garbage
  #--------------------------------------------------------------------------  
  def dispose_animation_garbage
      return unless $game_temp && $game_temp.animation_garbage
      pending = []
      $game_temp.animation_garbage.uniq.each do |animation|
          next unless animation && !animation.disposed?
          # An animation may have reused the cached bitmap since it was queued.
          if Sprite_Base.wcf_animation_bitmap_in_use?(animation)
              pending.push(animation)
          else
              animation.dispose
          end
      end
      $game_temp.animation_garbage = pending.empty? ? nil : pending
  end  

end

#==============================================================================
# ■ Game Map
#==============================================================================
class Game_Map
  
  #--------------------------------------------------------------------------
  # ● Setup
  #--------------------------------------------------------------------------    
  alias mog_anti_lag_animation_setup setup
  def setup(map_id)
      SceneManager.dispose_animation_garbage
      mog_anti_lag_animation_setup(map_id)
  end

end

#==============================================================================
# ■ Scene Base
#==============================================================================
class Scene_Base
  
  #--------------------------------------------------------------------------
  # ● Terminate
  #--------------------------------------------------------------------------      
  alias mog_anti_lag_animation_terminate terminate
  def terminate
      mog_anti_lag_animation_terminate
      SceneManager.dispose_animation_garbage
  end
  
end

#==============================================================================
# ■ Sprite Base 
#==============================================================================
class Sprite_Base < Sprite  

  def self.wcf_animation_bitmap_in_use?(bitmap)
    (@@_reference_count[bitmap] || 0) > 0
  end

  #--------------------------------------------------------------------------
  # ● Dispose Animation
  #--------------------------------------------------------------------------
  alias mog_anti_lag_animation_dispose_animation dispose_animation
  def dispose_animation
      if $game_system.anti_lag_animation  
         execute_animation_garbage  
         return
      end  
      mog_anti_lag_animation_dispose_animation
  end
    
  #--------------------------------------------------------------------------
  # ● Execute Animation Garbage
  #--------------------------------------------------------------------------  
  def execute_animation_garbage  
      $game_temp.animation_garbage = [] if $game_temp.animation_garbage == nil
      if @ani_bitmap1
         @@_reference_count[@ani_bitmap1] -= 1
        if @@_reference_count[@ani_bitmap1] == 0
            $game_temp.animation_garbage.push(@ani_bitmap1)
         end
      end
      if @ani_bitmap2
         @@_reference_count[@ani_bitmap2] -= 1
         if @@_reference_count[@ani_bitmap2] == 0
            $game_temp.animation_garbage.push(@ani_bitmap2)
        end
     end
     if @ani_sprites
        @ani_sprites.each {|sprite| sprite.dispose }
        @ani_sprites = nil
        @animation = nil
     end
     @ani_bitmap1 = nil
     @ani_bitmap2 = nil
  end    
  
end

$rgss3_mog_anti_lag_animation = true
