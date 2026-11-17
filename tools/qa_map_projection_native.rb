# Native Sprite projection probe, loaded only into an isolated QA copy.
module Graphics
  def self.update; self.frame_count+=1; end
  def self.transition(*); self.brightness=255; end
  def self.freeze; end
  def self.wait(frames); frames.times {update}; end
end
module Input
  def self.update; end
  def self.trigger?(*); false; end
  def self.press?(*); false; end
  def self.repeat?(*); false; end
  def self.dir4; 0; end
  def self.dir8; 0; end
end
class << SceneManager
  def first_scene_class
    DataManager.setup_new_game
    $game_map.setup(3); $game_player.moveto(4,4)
    Scene_Map
  end
end
class Scene_Map
  alias projection_probe_start start
  def start
    projection_probe_start
    black=Sprite.new; black.z=10000; black.bitmap=Bitmap.new(640,480)
    black.bitmap.fill_rect(black.bitmap.rect,Color.new(0,0,0))
    vp=Viewport.new(48,32,544,416); vp.z=11000
    marker=Sprite.new(vp); marker.bitmap=Bitmap.new(640,480)
    marker.bitmap.fill_rect(396,236,8,8,Color.new(255,7,11))
    d=$game_map.effects
    d.x=d.ox=320; d.y=d.oy=240; d.zoom_x=d.zoom_y=1.3
    renderer=@spriteset.instance_variable_get(:@map_effects)
    original=renderer.instance_variable_get(:@viewport)
    renderer.instance_variable_set(:@viewport,vp)
    results=[]
    [[90,false],[31,false],[31,true],[0,true]].each do |angle,mirror|
      d.angle=angle; d.mirror=mirror
      marker.x=d.x; marker.y=d.y; marker.ox=d.ox; marker.oy=d.oy
      marker.zoom_x=d.zoom_x; marker.zoom_y=d.zoom_y
      marker.angle=angle; marker.mirror=mirror
      bmp=Graphics.snap_to_bitmap
      actual=[]
      (0...480).each do |y|
        (0...640).each do |x|
          c=bmp.get_pixel(x,y)
          actual << [x,y] if c.red>240 && c.green<20 && c.blue<20
        end
      end
      p=renderer.wcf_screen_point(400,240)
      center=actual.empty? ? nil : [actual.inject(0.0) {|s,a|s+a[0]}/actual.size,actual.inject(0.0) {|s,a|s+a[1]}/actual.size]
      error=center && Math.sqrt((p[0]-center[0])**2+(p[1]-center[1])**2)
      results << {:angle=>angle,:mirror=>mirror,:predicted=>p,:actual=>center,:error=>error}
      bmp.save('captures/projection_'+angle.to_s+'_'+mirror.to_s+'.png'); bmp.dispose
    end
    File.open('projection.marshal','wb') {|f|f.write(Marshal.dump(results))}
    raise 'Native projection differs by more than two raster pixels' unless results.all? {|r|r[:error] && r[:error]<=2}
    renderer.instance_variable_set(:@viewport,original)
    marker.bitmap.dispose; marker.dispose; vp.dispose; black.bitmap.dispose; black.dispose
    SceneManager.exit
  rescue Exception => e
    File.open('projection-error.txt','wb') {|f|f.write(e.message+"\r\n"+e.backtrace.join("\r\n"))}
    exit
  end
end
