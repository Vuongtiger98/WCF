#==============================================================================
#    Animated Parallax [VXA]
#    Version: 1.0
#    Author: modern algebra (rmrk.net)
#    Date: December 20, 2011
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Description:
#
#    This script allows you to set an animated parallax background by having 
#   multiple frames and switching between them at a user-defined speed. By 
#   default, this script only supports .png, .jpg, and .bmp file formats for 
#   the animated parallax panels (as they are the only ones I know RMVX Ace
#   supports).
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Instructions:
#    
#     The script operates by having multiple parallax backgrounds and switching
#    between them at a speed set by you, unique for each map
#
#     Thus, if you want to use an animated parallax, you need to do a few things:
#      (a) Make or find the parallax backgrounds you want to use and import 
#        them into your game. Then, label them all the same with the one
#        distinction that at the end of each should have a _1, _2, etc...
#          Example Naming:
#            BlueSky_1, BlueSky_2, BlueSky_3, etc...
#      (b) Set the parallax background to any given map that you want the 
#        animated parallaxes for. Be sure to set it to the first one you want
#        in succession, so BlueSky_1, not BlueSky_2 or _3. If you do set it to
#        BlueSky_2, then it will only animate between images _2 and _3.
#      (c) Scroll down to the EDITABLE REGION at line 83 and follow the 
#        instructions for setting the animation speed
#``````````````````````````````````````````````````````````````````````````````
#     If you need to change the speed at which parallax panels cycle (for
#    instance, if you have also changed the parallax that is displaying), you  
#    can do so by using the following code in a Script call:
#
#      change_parallax_animation_speed(x)
#        x: the number of frames before cycling to the next panel. There are 60
#          frames in one second.
#
#    Note: there cannot be a space between speed and (.
#      change_parallax_animation_speed(x)     <- Correct
#      change_parallax_animation_speed (x)    <- Incorrect
#
#    You can also change it to an array of times, such that you can make it so
#   some frames remain up for longer than others. To do so, just place all of 
#   the speeds for each panel in order, separated by commas. Ie. 
#
#      change_parallax_animation_speed(x1, x2, ..., xn)
#
#    The same rule as at line 41 applies.
#
#    EXAMPLES: 
#
#      change_parallax_animation_speed(30)
#        Each parallax panel will be up for half a second before switching.
#
#      change_parallax_animation_speed(15, 30, 60, 45)
#        The first parallax panel will be up for one quarter of a second before
#       switching to the second panel; the second panel will be up for half a 
#       second before switching to the third panel; the third panel will be up 
#       for one second before switching to the fourth panel; the fourth panel 
#       will be up for three quarters of a second before switching back to the 
#       first panel. Repeat.
#==============================================================================

$imported = {} unless $imported
$imported[:MA_AnimatedParallax] = true

#==============================================================================
# ** Game Map
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    new constants - MAAP_PARALLAX_ANIMATION_FRAMES; MAAP_PRELOAD_PARALLAXES
#      MAAP_SUPPORTED_EXTENSIONS
#    aliased methods - setup_parallax; change_parallax; update_parallax
#    new methods - setup_parallax_frames; maap_check_extensions
#==============================================================================

class Game_Map
  MAAP_PARALLAX_ANIMATION_FRAMES = { # <- Don't touch
  #\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
  #    EDITABLE REGION
  #|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  #  MAAP_PARALLAX_ANIMATION_FRAMES - this constant allows you to set the
  # speed at which the parallax switches to the next graphic in the animation
  # series by individual maps. So if you want it to be every 20 frames in one
  # map but every 35 in another map, this is where you do it. All you need to 
  # do is type in the following code:
  #
  #      map_id => frames,
  #
  # where map_id is the ID of the Map you want to set it for and frames is
  # either (a) an integer for how many frames you want to show each panel 
  # before switching to the next; or (b) an array of integers where each entry
  # of the array is the number of frames to keep the corresponding frame up 
  # before switching to the next. This allows you to vary the time each of the
  # frames is left on before switching. There are 60 frames in a second.
  #
  #    EXAMPLES:
  #      1 => 35,    Map 1 will cycle through parallax panels every 35 frames
  #      2 => 40,    Map 2 will cycle through parallax panels every 40 frames
  #      8 => [20, 5, 15],    Map 8 will keep the first panel of the animated
  #                  parallax on for 20 frames before switching to the second
  #                  panel which will be on for 5 frames before switching to 
  #                  the third panel which is on 15 frames before switching 
  #                  back to the first panel. Repeat.
  #
  #  Note that the comma is necessary! For any maps where you use animated 
  # parallaxes but do not include the map ID in this hash, then it will default
  # to the value set below at: MAAP_PARALLAX_ANIMATION_FRAMES.default.
    1 => 20,
    16 => [60,5,5,5,5,5],
  } # <- Don't touch
  #  Changing the below value allows you to change the default speed of frame 
  # animation. Ie. the speed of frame animation in a map in which you have not
  # directly set the speed via the above hash configuration. 
  MAAP_PARALLAX_ANIMATION_FRAMES.default = 30
  #  Depending on the size of the parallaxes and how many panels you use in a
  # map, there can be some lag when you load new panels. The following option 
  # allows you to decide whether all the parallax frames are loaded at once 
  # when the map is first entered or individually the first time each panel 
  # shows up. Generally, if your panels are very large (1MB+) then you should
  # set it to true; if smaller files, then you should set it to false.
  MAAP_PRELOAD_PARALLAXES = true
  #|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  #    END EDITABLE REGION
  #///////////////////////////////////////////////////////////////////////////
  MAAP_SUPPORTED_EXTENSIONS = ["png", "jpg", "bmp"]
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Setup Parallax
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias ma_anmp_setuplax_6id3 setup_parallax
  def setup_parallax(*args, &block)
    ma_anmp_setuplax_6id3(*args, &block) # Run Original Method
    setup_parallax_frames
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Change Parallax
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias moda_ap_chngprlx_8uz2 change_parallax
  def change_parallax(*args, &block)
    moda_ap_chngprlx_8uz2(*args, &block) # Run Original Method
    setup_parallax_frames
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Update Parallax
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias maba_ap_updprx_9hv3 update_parallax
  def update_parallax(*args, &block)
    maba_ap_updprx_9hv3(*args, &block) # Run Original Method
    # Use the timer if the parallax has more than one frame
    if @maap_parallax_frames && @maap_parallax_frames.size > 1
      @maap_parallax_frame_timer += 1
      # Check if timer exceeded
      if @maap_parallax_frame_timer >= @maap_frame_speed
        @maap_parallax_frame_timer = 0 # Reset Timer
        # Set parallax to next frame
        @maap_parallax_index = (@maap_parallax_index + 1) % @maap_parallax_frames.size
        @parallax_name = @maap_parallax_frames[@maap_parallax_index]
        set_parallax_frame_speed(@maap_parallax_speed, @maap_parallax_index)
      end
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Set Parallax Animation Speed
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def set_parallax_frame_speed(parallax_speed = MAAP_PARALLAX_ANIMATION_FRAMES[@map_id], frame = 0)
    @maap_parallax_speed = parallax_speed
    if @maap_parallax_speed.is_a?(Array)
      @maap_frame_speed = [@maap_parallax_speed[frame], @maap_parallax_speed.compact[0]].compact[0]
    else
      @maap_frame_speed = @maap_parallax_speed
    end
    # Get the default setting, in case the time limit is incorrectly set
    unless @maap_frame_speed.is_a?(Integer)
      p "Error: Animated Parallax 1.0\nFrame Speed incorrectly set for #{@map_id}, frame #{frame + 1} - #{@parallax_name}"
      @maap_frame_speed = MAAP_PARALLAX_ANIMATION_FRAMES.default
      @maap_frame_speed = default.compact[0] if @maap_frame_speed.is_a?(Array)
      @maap_frame_speed = 30 if !@maap_frame_speed
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Setup Parallax Frames
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def setup_parallax_frames
    # Retain the names of old map's parallax, for disposal
    last_map_bmps = @maap_parallax_frames.nil? ? [] : @maap_parallax_frames
    # Initialize Data
    @maap_parallax_index = 0
    @maap_parallax_frames = [@parallax_name]
    @maap_parallax_frame_timer = 0
    set_parallax_frame_speed
    # Collect all frames of the parallax animation
    if @parallax_name[/_(\d+)$/] != nil
      frame_id = $1.to_i + 1
      base_name = @parallax_name.sub(/_\d+$/, "")
      while maap_check_extensions("Graphics/Parallaxes/#{base_name}_#{frame_id}")
        @maap_parallax_frames.push("#{base_name}_#{frame_id}")
        frame_id += 1
      end
    end
    # Dispose the cached bitmaps from the previous map
    (last_map_bmps - @maap_parallax_frames).each { |bmp| (Cache.parallax(bmp)).dispose }
    # Preload all the parallax bitmaps so no lag is experienced on first load
    if MAAP_PRELOAD_PARALLAXES
      (@maap_parallax_frames - last_map_bmps).each { |bmp| Cache.parallax(bmp) }
    end
    Graphics.frame_reset
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Check Extensions
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def maap_check_extensions (filepath)
    MAAP_SUPPORTED_EXTENSIONS.any? { |ext| FileTest.exist?("#{filepath}.#{ext}") }
  end
end

#==============================================================================
# ** Game_Interpreter
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    new method - change_parallax_animation_speed
#==============================================================================

class Game_Interpreter
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Change Parallax Animation Speed
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def change_parallax_animation_speed(*args)
    if args.size <= 1
      $game_map.set_parallax_frame_speed(*args)
    else
      $game_map.set_parallax_frame_speed(args)
    end
  end
end

#==============================================================================
# ** Spriteset Map
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased method - update_parallax
#==============================================================================

class Spriteset_Map
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Update Parallax
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias ma_animpara_updlax_7ig8 update_parallax
  def update_parallax(*args, &block)
    # Don't ever dispose the cached parallax pictures.
    @parallax.bitmap = nil if @parallax_name != $game_map.parallax_name  
    ma_animpara_updlax_7ig8(*args, &block) # Run Original Method
  end
end