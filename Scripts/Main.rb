#==============================================================================
# ** Main
#------------------------------------------------------------------------------
#  This processing is executed after module and class definition is finished.
#==============================================================================

# Keep the same script slot/order. The network runs in a detached PowerShell
# helper; RGSS only renders a small wait screen and polls a local status file.
module WCFStartupUpdate
  VERSION = "0.1.0-test.5"
  CHECK_TIMEOUT = 6.0
  MIN_DISPLAY_TIME = 5.0
  UPDATE_NOTICE = 1.0
  ALIEN_COLORS = [[255,183,118],[239,174,216],[242,126,153],[190,143,250],[117,219,244]]
  class << self
    attr_accessor :checked
  end

  def self.wide(value)
    (value + "\0").encode("UTF-16LE")
  end

  def self.launch(mode)
    args='-NoLogo -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File ".\\gameupdate\\Update.ps1"'
    args+=' -StartupMode '+mode+' -Session '+@session+' -ParentId '+@pid.to_s+' -CurrentVersion '+VERSION
    api=Win32API.new('shell32','ShellExecuteW',['L','P','P','P','L','L'],'L')
    api.call(0,wide('open'),wide('powershell.exe'),wide(args),0,0)>32
  rescue StandardError
    false
  end

  def self.read_status
    path=@folder+'/check.txt'
    return {} unless File.file?(path)
    return {} if File.size(path)>4096
    result={}
    File.open(path,'rb') { |file| file.read }.split(/\r?\n/).each do |line|
      key,value=line.split('=',2)
      result[key]=value if ['status','version'].include?(key)
    end
    result
  rescue StandardError
    {}
  end

  def self.round_rect(bmp,x,y,width,height,radius,color)
    height.times do |row|
      dy=row<radius ? radius-row-0.5 : row>=height-radius ? row-(height-radius)+0.5 : 0
      inset=dy>0 ? (radius-Math.sqrt([radius*radius-dy*dy,0].max)).ceil : 0
      bmp.fill_rect(x+inset,y+row,width-inset*2,1,color)
    end
  end

  def self.prepare_visuals
    @card_key=nil
    @aliens=[]
    (0..4).each do |i|
      actor=nil
      next unless File.file?("Graphics/Invaders/alien#{i}.png")
      begin
        image=Cache.load_bitmap('Graphics/Invaders/',"alien#{i}")
        actor=Sprite.new
        actor.bitmap=image;actor.ox=image.width/2;actor.oy=image.height;actor.z=10002
        @aliens << [i,actor]
      rescue StandardError
        actor.dispose if actor && !actor.disposed?
      end
    end
    @loading=Sprite.new
    @loading.x=88;@loading.y=(Graphics.height-328)/2+214;@loading.z=10001
    @loading.bitmap=Bitmap.new(Graphics.width-176,38)
  end

  def self.animate(frame)
    base=(Graphics.height-328)/2+190
    (@aliens || []).each do |i,actor|
      beat=(frame+i*6)*Math::PI*2/40.0
      bounce=(Math.sin(beat)+1)/2.0
      actor.x=Graphics.width/2-156+i*78
      actor.y=base-(bounce*bounce*12).round
      actor.zoom_x=1.0-(bounce-0.5)*0.10
      actor.zoom_y=1.0+(bounce-0.5)*0.16
      actor.angle=Math.sin(beat)*5
    end
    return unless @loading && frame%3==0
    bmp=@loading.bitmap;bmp.clear;width=bmp.width
    round_rect(bmp,0,8,width,18,9,Color.new(80,83,119))
    round_rect(bmp,2,10,width-4,14,7,Color.new(12,20,37))
    lead=((Math.sin(frame/36.0)+1)*0.5*(width-110)).round
    5.times do |i|
      color=Color.new(*ALIEN_COLORS[i])
      round_rect(bmp,lead+5+i*20,12,20,10,5,color)
      bmp.fill_rect(lead+10+i*20,13,10,2,Color.new(255,255,255,135))
    end
  end

  def self.dispose_visuals
    (@aliens || []).each { |_,actor| actor.dispose unless actor.disposed? }
    @aliens=nil
    if @loading
      @loading.bitmap.dispose if @loading.bitmap && !@loading.bitmap.disposed?
      @loading.dispose unless @loading.disposed?
      @loading=nil
    end
  end

  def self.draw(sprite,title,note,frame)
    return if @card_key==[title,note]
    @card_key=[title,note]
    bmp=sprite.bitmap
    bmp.clear
    bmp.fill_rect(bmp.rect,Color.new(10,17,31))
    x,y,w=48,(Graphics.height-328)/2,Graphics.width-96
    20.times do |i|
      sx=(i*113+19)%Graphics.width;sy=(i*97+11)%Graphics.height
      next if sx>x-8 && sx<x+w+8 && sy>y-8 && sy<y+336
      bmp.fill_rect(sx,sy,3,3,Color.new(126,149,196,140))
    end
    round_rect(bmp,x-2,y-2,w+4,332,21,Color.new(86,88,128))
    round_rect(bmp,x,y,w,328,20,Color.new(24,36,58))
    bmp.font.name=defined?(PhoneMenu::UI_FONT) ? PhoneMenu::UI_FONT : ['Segoe UI','Arial']
    bmp.font.size=25;bmp.font.bold=true;bmp.font.color=Color.new(246,240,255)
    bmp.draw_text(x+20,y+18,w-40,38,'Wonder Christmas Fiesta',1)
    bmp.font.size=20;bmp.font.bold=false;bmp.font.color=Color.new(211,201,244)
    bmp.draw_text(x+16,y+66,w-32,32,title+'…',1)
    5.times do |i|
      cx=Graphics.width/2-156+i*78
      round_rect(bmp,cx-17,y+192,34,7,3,Color.new(10,18,33))
    end
    bmp.font.size=16;bmp.font.color=Color.new(187,202,229)
    bmp.draw_text(x+24,y+262,w-48,36,note,1)
  end

  def self.run
    return true if checked
    self.checked=true
    if ENV.delete('WCF_SKIP_STARTUP_CHECK')=='1'
      return true
    end
    return true if $BTEST || !File.file?('gameupdate/Update.ps1') || !File.file?('gameupdate/config.json')
    @pid=Win32API.new('kernel32','GetCurrentProcessId',[],'L').call
    @session=@pid.to_s+'-'+Time.now.to_i.to_s+'-'+rand(1000000).to_s
    @folder='gameupdate/startup-'+@session
    Dir.mkdir(@folder)
    sprite=Sprite.new
    sprite.z=10000;sprite.bitmap=Bitmap.new(Graphics.width,Graphics.height)
    prepare_visuals
    draw(sprite,'Đang kiểm tra phiên bản','Bạn có thể tiếp tục chơi khi không có kết nối mạng.',0)
    animate(0)
    Graphics.transition(0)
    started=Time.now;launched=launch('Check');frame=0;notice=nil
    state=launched ? {} : {'status'=>'offline'}
    loop do
      Graphics.update;Input.update;frame+=1
      animate(frame)
      state=read_status if launched && frame%3==0
      elapsed=Time.now-started
      if ['available','recovery'].include?(state['status'])
        version=state['version'].to_s
        unless version =~ /\A[0-9A-Za-z.+-]{1,80}\z/
          return true if elapsed>=MIN_DISPLAY_TIME
          next
        end
        notice ||= Time.now
        title=state['status']=='recovery' ? 'Đang phục hồi cập nhật' : 'Có bản cập nhật mới'
        draw(sprite,title,"Phiên bản #{version} — vui lòng chờ cập nhật.",frame) if frame%8==0
        if elapsed>=MIN_DISPLAY_TIME && Time.now-notice>=UPDATE_NOTICE
          if @update_started
            if File.file?(@folder+'/ready')
              @handed_off=true
              return false
            end
            return true if Time.now-@update_started>=CHECK_TIMEOUT
          elsif launch('Update')
            @update_started=Time.now
          else
            return true
          end
        end
      elsif !state['status'].to_s.empty? || elapsed>=CHECK_TIMEOUT
        return true if elapsed>=MIN_DISPLAY_TIME
        if frame%8==0
          title=state['status']=='up-to-date' ? 'Game đã ở phiên bản mới nhất' : 'Chưa kiểm tra được phiên bản'
          draw(sprite,title,'Chuẩn bị vào game — cùng nhún nhảy một chút nhé!',frame)
        end
      elsif frame%8==0
        draw(sprite,'Đang kiểm tra phiên bản','Đang kết nối tới máy chủ cập nhật',frame)
      end
    end
  rescue StandardError
    true
  ensure
    dispose_visuals
    if @folder && !@handed_off
      begin
        File.open(@folder+'/cancel','wb') { |file| file.write('1') }
      rescue StandardError
      end
    end
    if sprite
      sprite.bitmap.dispose if sprite.bitmap && !sprite.bitmap.disposed?
      sprite.dispose unless sprite.disposed?
    end
  end
end

rgss_main { SceneManager.run if WCFStartupUpdate.run }
