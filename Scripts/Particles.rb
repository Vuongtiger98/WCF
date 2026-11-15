if true # << Make true to use this script, false to disable.
#===============================================================================
#
# ☆ $D13x - Particles
# -- Author   : Dekita
# -- Version  : 1.0
# -- Level    : Easy / Normal
# -- Requires : $D13x Core Script v2.5+
# -- Engine   : RPG Maker VX Ace.
#
#===============================================================================
# ☆ Import
#-------------------------------------------------------------------------------
$D13x={}if$D13x==nil
$D13x[:Particles]=true
#===============================================================================
# ☆ Updates
#-------------------------------------------------------------------------------
# D /M /Y
# 15/o4/2o14 - Finished,
# ??/o3/2o14 - Started
# 
#===============================================================================
# ☆ Introduction
#-------------------------------------------------------------------------------
# This script creates 'particles' that are shown in any scene you want.
# A particle is basically an image that is shown. The image will have a certain
# movement and can be used for a number of visual effects.
# This script is required by any other particle type script of mine.
# 
#===============================================================================
# ★☆★☆★☆★☆★☆★☆★☆★ TERMS AND CONDITIONS: ☆★☆★☆★☆★☆★☆★☆★☆★☆
#===============================================================================
# 1. You MUST give credit to "Dekita" !!
# 2. You are NOT allowed to repost this script.(or modified versions)
# 3. You are NOT allowed to convert this script.
# 4. You are NOT allowed to use this script for Commercial games.
# 5. ENJOY!
#
# "FINE PRINT" 
# By using this script you hereby agree to the above terms and conditions, 
#  if any violation of the above terms occurs "legal action" may be taken.
# Not understanding the above terms and conditions does NOT mean that 
#  they do not apply to you.
# If you wish to discuss the terms and conditions in further detail you can 
# contact me at http://dekitarpg.wordpress.com/
#
#===============================================================================
# ☆ Instructions
#-------------------------------------------------------------------------------
# Place Below " ▼ Materials " and Above " ▼ Main " in your script editor.
# 
#===============================================================================
# ☆ Script Calls
#-------------------------------------------------------------------------------
# N/A
# 
#===============================================================================
# ☆ Notetags ( default )
#-------------------------------------------------------------------------------
# N/A
# 
#===============================================================================
# ☆ HELP
#-------------------------------------------------------------------------------
# N/A
# 
#===============================================================================
module DekitaParticles
#===============================================================================
  #-----------------------------------------------------------------------------
  # Graphics Folder
  #-----------------------------------------------------------------------------
  Folder           = "Graphics/$D13x/Particles/"
  #-----------------------------------------------------------------------------
  # Additional space to give images outwith the screen size... (size in pixels)
  #-----------------------------------------------------------------------------
  Screen_Buffer    = 60
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  Transition_Speed = 10
  #-----------------------------------------------------------------------------
  # Particle Type Settings
  #-----------------------------------------------------------------------------
  Type = {
    #---------------------------------------------------------------------------
    #:name      => {
    #     'imag'=> [ 'Image_Name' , hue],
    #     'spwn'=> { x: [min, max] , y: [min, max] },
    #     'move'=> { x: [min, max] , y: [min, max] },
    #     'zoom'=> { x: [min, max] , y: [min, max] },
    #     'angl'=> [ base, rand, add_base, add_rand],
    #     'opac'=> [ base, add, [fade?, -add]],
    #     'wave'=> [ amp, length, speed, phase],
    #     'bush'=> [ depth, opac ]
    #     'dlay'=> [ use delay?, min, max]
    #     'inst'=> instantly visible?,
    #     'grow'=> zoom each frame,
    #     'amnt'=> amount shown on screen,
    #     'blnd'=> blend type,
    #     'zval'=> z value (importance),
    #     'scrl'=> scroll with map? (only works with my weather script),
    #     },
    #---------------------------------------------------------------------------
    # :Meteor - Used in Title by default
    #---------------------------------------------------------------------------
    :Meteor     => {
          'imag'=> ["Fire/MeteorMedium", 0 , 0],
          'spwn'=> { x: [0, 640] , y: [0, 416] },
          'move'=> { x: [-3,  0] , y: [4, 3] },
          'zoom'=> { x: [0.4, 1.0] , y: [0.4, 1.0] },
          'angl'=> [326, 0, 0, 0],
          'opac'=> [0, 2, [false,0]],
          'wave'=> [0,10,180,360],
          'bush'=> [0,255],
          'dlay'=> [true,180,360],
          'inst'=> false,
          'grow'=> 0.01,
          'amnt'=> 1,
          'zval'=> 1,
          'blnd'=> 0,
          'zpop'=> [false, 0.0, 2.0, 50], # [on?, min, max, opac fade],
          'apop'=> [false, 45, 50],   # [on?, angle, opac fade],
          },
    #---------------------------------------------------------------------------
    # :Spark - Used in Title by default && by $D13x Particle Weather 
    #---------------------------------------------------------------------------
    :Spark      => {
          'imag'=> ["Red_Sparkle", 0 , 361],
          'spwn'=> { x: [-20, 660] , y: [-20, 436] },
          'move'=> { x: [-1,  -2] , y: [1, 5] },
          'zoom'=> { x: [1.0, 1.0] , y: [1.0, 1.0] },
          'angl'=> [0,360, -2, 5],
          'opac'=> [0,10, [false,0]],
          'wave'=> [0,10,180,360],
          'bush'=> [0,255],
          'dlay'=> [false,0,0],
          'inst'=> false,
          'grow'=> -0.01,
          'amnt'=> 10,
          'zval'=> 2,
          'blnd'=> 1,
          'zpop'=> [true, 0.0, 2.0, 50],
          'apop'=> [false, 45, 50],
          },
    #---------------------------------------------------------------------------
    # :FireBall - Used in menus by default
    #---------------------------------------------------------------------------
    :FireBall   => {
          'imag'=> ["Fire/Medium",0, 361],
          'spwn'=> { x: [0, 640] , y: [0, 416] },
          'move'=> { x: [-1,  3] , y: [-1, 3] },
          'zoom'=> { x: [0.4, 1.0] , y: [0.4, 1.0] },
          'angl'=> [0, 30, 15, 45],
          'opac'=> [0, 1, [true,-1]],
          'wave'=> [0,10,120,360],
          'bush'=> [0,255],
          'dlay'=> [false, 0, 0],
          'inst'=> false,
          'grow'=> 0.01,
          'amnt'=> 4,
          'zval'=> 1,
          'blnd'=> 0,
          'zpop'=> [true, 0.0, 1.6, 10], # [on?, min, max, opac fade],
          'apop'=> [false, 45, 50],   # [on?, angle, opac fade],
          },
    #---------------------------------------------------------------------------
    # :Rain - Used as weather by 'Particle Weather' add-on
    #---------------------------------------------------------------------------
    :Rain       => {
          'imag'=> ["Water/DropExtraSmall", 0 , 0],
          'spwn'=> { x: [-40, 680] , y: [-40, 416] },
          'move'=> { x: [0,  0] , y: [10, 10] },
          'zoom'=> { x: [1.0, 0.25] , y: [1.0, 0.25] },
          'angl'=> [0,0,0,0],
          'opac'=> [100,5,[false,0]],
          'wave'=> [0,10,180,360],
          'bush'=> [0,255],
          'dlay'=> [false,0,0],
          'inst'=> false,
          'grow'=> 0,#.01,
          'amnt'=> 20,
          'zval'=> 2,
          'blnd'=> 0,
          'zpop'=> [false, 0.0, 2.0, 50],
          'apop'=> [false, 45, 50],
          },
    #---------------------------------------------------------------------------
    # :FireRain - Used as weather by 'Particle Weather' add-on
    #---------------------------------------------------------------------------
    :FireRain   => {
          'imag'=> ["Fire/BrimstoneExtraSmall", 0 , 0],
          'spwn'=> { x: [-40, 680] , y: [-40, 416] },
          'move'=> { x: [0,  0] , y: [10, 10] },
          'zoom'=> { x: [1.0, 0.25] , y: [1.0, 0.5] },
          'angl'=> [0,0,0,0],
          'opac'=> [80,20,[true,40]],
          'wave'=> [0,10,180,360],
          'bush'=> [0,255],
          'dlay'=> [false,0,0],
          'inst'=> false,
          'grow'=> -0.01,
          'amnt'=> 10,
          'zval'=> 2,
          'blnd'=> 0,
          'zpop'=> [false, 0.0, 2.0, 50],
          'apop'=> [false, 45, 50],
          },
    #---------------------------------------------------------------------------
    # :Glow - Used as weather by 'Particle Weather' add-on
    #---------------------------------------------------------------------------
    :Glow       => {
          'imag'=> ["Red_Sparkle", 0 , 0],
          'spwn'=> { x: [-40, 680] , y: [-40, 456] },
          'move'=> { x: [-1,  3] , y: [-1, 3] },
          'zoom'=> { x: [1.0, 0.25] , y: [1.0, 0.25] },
          'angl'=> [0,360, -4, 8],
          'opac'=> [0,10, [false,10]],
          'wave'=> [0,10,180,360],
          'bush'=> [0,255],
          'dlay'=> [false,0,0],
          'inst'=> false,
          'grow'=> -0.01,
          'amnt'=> 10,
          'zval'=> 2,
          'blnd'=> 1,
          'zpop'=> [true, 0.0, 2.0, 50],
          'apop'=> [false, 45, 50],
          },
    #---------------------------------------------------------------------------
    # :Meteor - Used as weather by 'Particle Weather' add-on
    #---------------------------------------------------------------------------
    :MeteorRain => {
          'imag'=> ["Fire/MeteorSmall", 0 , 0],
          'spwn'=> { x: [-40, 680] , y: [-40, 416] },
          'move'=> { x: [-3,  0] , y: [6, 5] },
          'zoom'=> { x: [1.0, 0.25] , y: [1.0, 0.5] },
          'angl'=> [340,0,0,0],
          'opac'=> [80,10,[false,0]],
          'wave'=> [0,10,180,360],
          'bush'=> [0,255],
          'dlay'=> [false,0,0],
          'inst'=> false,
          'grow'=> -0.01,
          'amnt'=> 10,
          'zval'=> 2,
          'blnd'=> 0,
          'zpop'=> [false, 0.0, 2.0, 50],
          'apop'=> [false, 45, 50],
          },
  }#<<Type
  
  #-----------------------------------------------------------------------------
  # Scene's Particles Settings
  #-----------------------------------------------------------------------------
  def self.particles(scene_class_name,scene_particles=nil)
    case scene_class_name.to_s
    when "Scene_Title"     then scene_particles = [:Spark] 
    #when "Scene_Menu"      then scene_particles = [:FireBall, :Spark]
    #when "Scene_Item"      then scene_particles = [:FireBall, :Spark]
    #when "Scene_Skill"     then scene_particles = [:FireBall, :Spark]
    #when "Scene_Equip"     then scene_particles = [:FireBall, :Spark]
    #when "Scene_Status"    then scene_particles = [:FireBall, :Spark]
    #when "Scene_Save"      then scene_particles = [:FireBall, :Spark]
    #when "Scene_Load"      then scene_particles = [:FireBall, :Spark]
    #when "Scene_End"       then scene_particles = [:FireBall, :Spark]
    #when "Scene_Shop"      then scene_particles = [:FireBall, :Spark]
    #when "Scene_Name"      then scene_particles = [:FireBall, :Spark]
    when "Scene_Gameover"  then scene_particles = [:Spark]
      # //
    #when "Scene_SPDS"      then scene_particles = [:FireBall, :Spark]
    #when "SUG_Scene"       then scene_particles = [:FireBall, :Spark]
    #when "Scene_Teleport"  then scene_particles = [:FireBall, :Spark]
    #when "Scene_BANK"      then scene_particles = [:FireBall, :Spark]
    end
    return scene_particles  #####################
  end                       # CUSTOMISATION END #
end                         #####################
#☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★#
#                                                                               #
#                       http://dekitarpg.wordpress.com/                         #
#                                                                               #
#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆#
#===============================================================================#
# ARE YOU MODIFYING BEYOND THIS POINT? \.\.                                     #
# YES?\.\.                                                                      #
# OMG, REALLY? \|                                                               #
# WELL SLAP MY FACE AND CALL ME A DRAGONITE.\..\..                              #
# I REALLY DIDN'T THINK YOU HAD IT IN YOU.\..\..                                #
#===============================================================================#
module Cache
#===============================================================================
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def self.particle(filename = "", hue = 0)
    load_bitmap(Particle_Core::Folder, filename, hue)
  end
end
#===============================================================================
class Particle_Core < Sprite
#===============================================================================
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  include DekitaParticles
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  attr_accessor :particle_type
  attr_accessor :spwn
  attr_accessor :move
  attr_accessor :zval
  attr_accessor :imag
  attr_accessor :amnt
  attr_accessor :blnd
  attr_accessor :angl
  attr_accessor :zoom
  attr_accessor :grow
  attr_accessor :opac
  attr_accessor :inst
  attr_accessor :wave
  attr_accessor :bush
  attr_accessor :dlay
  attr_accessor :zpop
  attr_accessor :apop
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def initialize(data,viewport=nil,type=nil)
    @particle_type = type
    @view = viewport
    @data = data
    super(@view)
    init_variabz
    init_bitmap
    init_particle
    self.opacity = 255 if @inst #|| outwith_screen?
  end
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def init_variabz
    @spwn = @data['spwn']
    @move = @data['move']
    @zval = @data['zval']
    @imag = @data['imag']
    @amnt = @data['amnt']
    @blnd = @data['blnd']
    @angl = @data['angl']
    @zoom = @data['zoom']
    @grow = @data['grow']
    @opac = @data['opac']
    @inst = @data['inst']
    @wave = @data['wave']
    @bush = @data['bush']
    @dlay = @data['dlay']
    @zpop = @data['zpop']
    @apop = @data['apop']
  end
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def init_bitmap
    i = @data['imag'][0]
    h = @data['imag'][1]+rand(@data['imag'][2])
    self.bitmap = Cache.particle(i,h)
  end
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def init_particle
    @mx = Graphics.width
    @my = Graphics.height
    @iw = self.bitmap.width
    @ih = self.bitmap.height
    init_posi
    init_opac
    init_wave
    init_blnd
    init_angl
    init_bush
    init_zoom
    init_zval
    init_move
    init_dlay
    @fading = false
  end
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def init_posi
    x_pos = @spwn[:x][0] + rand(@spwn[:x][1]-@spwn[:x][0])
    y_pos = @spwn[:y][0] + rand(@spwn[:y][1]-@spwn[:y][0])
    self.x = x_pos
    self.y = rand(y_pos)
    @imagwi = self.bitmap.width
    @imaghe = self.bitmap.height
    self.ox = (@imagwi/2)
    self.oy = (@imaghe/2)
  end
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def init_opac
    self.opacity = @opac[0]
    self.opacity = 255 if self.y < 0 || self.y > Graphics.height #||
#                          self.y < 0 || self.y > Graphics.height
  end
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def init_wave
    self.wave_amp    = @wave[0]
    self.wave_length = @wave[1]
    self.wave_speed  = @wave[2]
    self.wave_phase  = @wave[3]
  end
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def init_blnd
    self.blend_type = @blnd
  end
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def init_angl
    @base_angl = @angl[0]+rand(@angl[1]).to_i
    @angl_addd = @angl[2]+rand(@angl[3]).to_i
    self.angle = @base_angl
    @anglepopping = false
  end
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def init_bush
    self.bush_depth   = @bush[0]
    self.bush_opacity = @bush[1]
  end
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def init_zoom
    @x_zoom = @zoom[:x][0] + (rand(@zoom[:x][1]*100)/100)
    @y_zoom = @zoom[:y][0] + (rand(@zoom[:y][1]*100)/100)
    self.zoom_x = @x_zoom
    self.zoom_y = @y_zoom
    @zoompopping = false
  end
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def init_zval
    self.z = @zval
  end
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def init_move
    xmoveee = @move[:x][0] + rand(@move[:x][1])
    ymoveee = @move[:y][0] + rand(@move[:y][1])
    @x_move = xmoveee == 0 ? @move[:x][0] : xmoveee
    @y_move = ymoveee == 0 ? @move[:y][0] : ymoveee
  end
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def init_dlay
    delay_time   = @dlay[1]+rand(@dlay[2]-@dlay[1])
    @spawn_delay = @dlay[0] ? delay_time : 0
  end
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def dispose
    return if disposed?
    # Cache.particle shares bitmaps across particles and weather sprites.
    self.bitmap = nil
    super
  end  
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def update
    super
    update_spawn
    updt_particle
    init_particle if respawn_time?
  end
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def respawn_time?
    return true if @spawn_delay < 0 && outwith_screen?
    return false
  end
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def update_spawn
    @spawn_delay -= 1
  end
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def updt_particle
    update_move
    update_opac
    update_fadd
    update_angl
    update_zoom
  end
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def update_move
    self.x += @x_move
    self.y += @y_move
  end
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def update_opac
    return update_fade if @fading && @opac[2][0]
    self.opacity += @opac[1]
  end
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def update_fade
    self.opacity += @opac[2][1]
  end
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def update_fadd
    @fading = true if self.opacity >= 255 && @opac[2][0]
  end
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def update_angl
    self.angle += @angl_addd
    update_apop
  end
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def update_zoom
    @x_zoom    += @grow
    @y_zoom    += @grow
    self.zoom_x = @x_zoom
    self.zoom_y = @y_zoom
    update_zpop
  end
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def update_apop
    if @anglepopping 
      self.opacity -= @apop[1]
    end
    return unless @apop[0]
    @anglepopping = true if self.angle <= -@apop[0]
    @anglepopping = true if self.angle >=  @apop[0]
  end
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def update_zpop
    if @zoompopping 
      self.opacity -= @zpop[3]
    end
    return unless @zpop[0]
    @zoompopping = true if self.zoom_x <= @zpop[1]
    @zoompopping = true if self.zoom_x >= @zpop[2]
    @zoompopping = true if self.zoom_y <= @zpop[1]
    @zoompopping = true if self.zoom_y >= @zpop[2]
  end
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def outwith_screen?
    buff = DekitaParticles::Screen_Buffer
    return true if ( (self.x) < -buff || (self.x) > (@mx+buff) )    
    return true if ( (self.y) < -buff || (self.y) > (@my+buff) )
    return false
  end
end
#===============================================================================
class Particle_Spriteset
#===============================================================================
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  attr_accessor :particle_vp
  attr_accessor :particles
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def initialize
    init_module
    init_partvp
    init_particles
  end
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def dispose 
    disp_particles
  end
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def update
    updt_particles
  end
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def init_module
    @module = DekitaParticles
  end
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def init_partvp
    @particlevp = nil
  end
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def init_particles
    disp_particles
    paarticles = scene_particles
    return unless paarticles 
    @particles = []
    paarticles.each do |particle|
      make_particle(particle)
    end
    updt_particles
  end
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def scene_particles
    @module.particles(SceneManager.scene.class.name) || []
  end
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def particle_count(particle)
    @module::Type[particle]['amnt']
  end
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def make_particle(particle)
    return unless particle
    particle_count(particle).to_i.times do 
      add_particle_to_arr(particle)
    end
  end
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def add_particle_to_arr(particle)
    return unless @particles
    @particles << Particle_Core.new(@module::Type[particle],@particlevp,particle)
  end
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def disp_particles
    return unless @particles
    @particles.each do |particle|
      particle.dispose
    end
    @particles = []
  end
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def updt_particles
    return unless @particles
    @particles.each do |particle|
      particle.update
    end
  end
end
#===============================================================================
class Game_Map
#===============================================================================
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  alias :setup_particle_fog :setup
  alias :sdp_for_fog        :set_display_pos
  alias :s_d_for_fog        :scroll_down
  alias :s_l_for_fog        :scroll_left
  alias :s_r_for_fog        :scroll_right
  alias :s_u_for_fog        :scroll_up
  alias :update_for_fog     :update_parallax
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  attr_reader :particle_x
  attr_reader :particle_y
  attr_reader :particle_sx
  attr_reader :particle_sy
  attr_reader :particle_loopx
  attr_reader :particle_loopy
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def setup(map_id)
    setup_particle_fog(map_id)
    setup_particle
  end
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def setup_particle
    @particle_x  = 0
    @particle_y  = 0
    @particle_sx = 0
    @particle_sy = 0
    @particle_loopx = @particle_sx != 0 ? @particle_sx : 0
    @particle_loopy = @particle_sy != 0 ? @particle_sy : 0
  end
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def set_display_pos(x, y)
    sdp_for_fog(x, y)
    @particle_x = x
    @particle_y = y
  end
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def scroll_up(distance)
    last_y = @display_y
    s_u_for_fog(distance)
    fog_scroll_up(distance, last_y)
  end 
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def scroll_down(distance)
    last_y = @display_y
    s_d_for_fog(distance)
    fog_scroll_down(distance, last_y)
  end
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def scroll_left(distance)
    last_x = @display_x
    s_l_for_fog(distance)
    fog_scroll_left(distance, last_x)
  end
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def scroll_right(distance)
    last_x = @display_x
    s_r_for_fog(distance)
    fog_scroll_right(distance, last_x)
  end
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def fog_scroll_up(distance, last_y)
    value = loop_vertical? ? -distance : @display_y - last_y
    @particle_y += value 
  end
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def fog_scroll_down(distance, last_y)
    value = loop_vertical? ? distance : @display_y - last_y
    @particle_y += value 
  end
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def fog_scroll_left(distance, last_x)
    value = loop_horizontal? ? -distance : @display_x - last_x
    @particle_x += value 
  end
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def fog_scroll_right(distance, last_x)
    value = loop_horizontal? ? distance : @display_x - last_x
    @particle_x += value 
  end
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def update_parallax
    update_for_fog
    update_fog
  end
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def update_fog
    @particle_x += @particle_sx / 128.0 if @particle_loopx
    @particle_y += @particle_sy / 128.0 if @particle_loopy
  end
end
#===============================================================================
class Scene_Base
#===============================================================================
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  attr_accessor :particle_spriteset 
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  alias :sd13x_particle_start  :start
  alias :dispo_particle_sd13x  :terminate
  alias :updat_particle_sd13x  :update
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def start
    sd13x_particle_start
    create_scene_particles
  end
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def terminate
    dispo_particle_sd13x
    dispose_scene_particles
  end
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def update
    updat_particle_sd13x
    update_scene_particles
  end
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def create_scene_particles
    dispose_scene_particles
    @particle_spriteset = Particle_Spriteset.new
  end
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def dispose_scene_particles
    return unless @particle_spriteset
    @particle_spriteset.dispose
    @particle_spriteset = nil
  end
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def update_scene_particles
    return unless @particle_spriteset
    @particle_spriteset.update
  end
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def transition_speed
    return DekitaParticles::Transition_Speed
  end
end
#===============================================================================#
#                      http://dekitarpg.wordpress.com/                          #
#===============================================================================#
end  # if true # << Make true to use this script, false to disable.
