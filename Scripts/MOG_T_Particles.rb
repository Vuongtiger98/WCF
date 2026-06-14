if true
#==============================================================================
# +++ MOG - Title Particles - [Stand Alone Series] (V1.1) +++
#==============================================================================
# By Moghunter 
# https://atelierrgss.wordpress.com/
#==============================================================================
# Adds multiple animated particles to the title screen.
#==============================================================================
module MOG_TITLE_PARTICLES
  PARTICLES = []
  #--------------------------------------------------------------------------
  # PARTICLES[ A ] = [ B , C , D ,E , F , G, I, J , L] 
  #
  # A - ID
  # B - NUMBER OF PARTICLES
  # C - BLEND TYPE
  # E - SCROLLING SPEED X
  # F - SCROLLING SPEED Y
  # G - ROLLING SPEED
  # H - RANDOM COLOR
  # I - CENTER OXY
  # J - Z-axis
  # L - FILE NAME
  #
  # EX
  #
  # PARTICLES[0] = [5,1,10,10,3,true,false,50,"Particle_0"]
  # PARTICLES[1] = [20,0,-3,-3,5,true,true,50,"Particle_1"]
  # PARTICLES[2] = [10,1,6,5,3,true,false,50,"Particle_2"]
  # PARTICLES[3] = [8,0,8,0,0,true,true,50,"Particle_3"]
  # ... PARTICLES[99] = [7,1,3,3,3,true,false,50,"Particle_99"]
  #  
  #--------------------------------------------------------------------------
  
  PARTICLES[0] = [40,0,0,-1,2,false,false,30,"Particle_2"]
  #PARTICLES[1] = [40,0,5,-3,5,true,true,50,"Particle_1"]
  
end

$imported = {} if $imported.nil?
$imported[:mog_title_screen_particles] = true

#==============================================================================
# ■ Scene Tittle
#==============================================================================
class Scene_Title < Scene_Base  

 #--------------------------------------------------------------------------
 # ● Start
 #--------------------------------------------------------------------------             
  alias mog_ts_particles_start start
  def start
      mog_ts_particles_start
      create_ts_particles
  end
    
 #--------------------------------------------------------------------------
 # ● Terminate
 #--------------------------------------------------------------------------             
  alias mog_ts_particles_terminate terminate
  def terminate
      mog_ts_particles_terminate
      dispose_ts_particles
  end
  
 #--------------------------------------------------------------------------
 # ● Update
 #--------------------------------------------------------------------------             
  alias mog_ts_particles_update update
  def update
      mog_ts_particles_update
      update_ts_particles
  end
  
 #--------------------------------------------------------------------------
 # ● Create TS Particles
 #--------------------------------------------------------------------------             
  def create_ts_particles
      @ts_particles = []
      for i in 0...100
          next if MOG_TITLE_PARTICLES::PARTICLES[i] == nil
          @ts_particles[i] = [MOG_TITLE_PARTICLES::PARTICLES[i],[]]
          @ts_particles[i][0][0].times do 
          @ts_particles[i][1].push(Particles_Title.new(nil,@ts_particles[i][0],i)) end
      end
  end
    
 #--------------------------------------------------------------------------
 # ● Dispose TS Particles
 #--------------------------------------------------------------------------             
  def dispose_ts_particles
      @ts_particles.each {|sprite| next if sprite == nil 
      sprite[1].each {|particle| particle.dispose}}  
  end
  
 #--------------------------------------------------------------------------
 # ● Update TS Particles
 #--------------------------------------------------------------------------             
  def update_ts_particles
      @ts_particles.each {|sprite| next if sprite == nil 
      sprite[1].each {|particle| particle.update}}   
  end
    
end

#==============================================================================
# ■ Particles Title
#==============================================================================
class Particles_Title < Sprite
  
  include MOG_TITLE_PARTICLES
  
 #--------------------------------------------------------------------------
 # ● Initialize
 #--------------------------------------------------------------------------             
  def initialize(viewport = nil,data,index)
      super(viewport)
      @data = data
      self.bitmap = Cache.title1(@data[8].to_s)
      self.ox = self.bitmap.width / 2 if @data[6]
      self.oy = self.bitmap.height / 2 if @data[6]
      self.tone.set(rand(255),rand(255), rand(255), 255) if @data[5]
      self.blend_type = @data[1] ; self.z = @data[7]
      @sc_x = [self.bitmap.width / 2, self.bitmap.width, Graphics.width ]
      @sc_y = [self.bitmap.height / 2, self.bitmap.height, Graphics.height ] 
      @cw0 = self.bitmap.width / 2 ; @ch0 = self.bitmap.height / 2
      @cw = self.bitmap.width + @cw0 ; @cw2 = Graphics.width
      @ch = self.bitmap.height + @ch0 ; @ch2 = Graphics.height
      @nx = @data[2] ; @ny = @data[3]
      reset_setting(true)
  end  
  
 #--------------------------------------------------------------------------
 # ● Reset Setting
 #--------------------------------------------------------------------------               
  def reset_setting(initial = false)
      zoom = (50 + rand(100)) / 100.1
      self.zoom_x = zoom ; self.zoom_y = zoom
      self.x = (rand(@cw2 + 32) -32) 
      if initial ; self.y = rand((@ch2 + 32) + @ch)
      else ; self.y = @data[3] > 0 ? @ch2 : -@ch ; end   
      self.opacity = 0 ; self.angle = rand(360)
      nx2 = rand(@nx).abs ; nx2 = 1 if (@nx != 0 and nx2 < 1)      
      @speed_x = @nx > 0 ? nx2 : @nx < 0 ? -nx2 : 0        
      ny2 = rand(@ny).abs ; ny2 = 1 if (@ny != 0 and ny2 < 1)      
      @speed_y = @ny > 0 ? ny2 : @ny < 0 ? -ny2 : 0   
      @speed_a = [[rand(@data[4]), @data[4]].min, 0].max 
  end
  
 #--------------------------------------------------------------------------
 # ● Dispose
 #--------------------------------------------------------------------------               
  def dispose
      super
      self.bitmap.dispose
  end  
  
 #--------------------------------------------------------------------------
 # ● Update
 #--------------------------------------------------------------------------               
  def update
      super
      self.x += @speed_x ; self.y -= @speed_y ; self.angle += @speed_a      
      self.opacity += 5 ; reset_setting if can_reset_setting?
  end  
  
 #--------------------------------------------------------------------------
 # ● Can Reset Setting
 #--------------------------------------------------------------------------                 
  def can_reset_setting?
      return true if !self.x.between?(-(@cw * 2),(@cw2 + (@cw * 2)))
      return true if !self.y.between?(-(@ch * 2),(@ch2 + (@ch * 2)))
      return false
  end 
    
end

end