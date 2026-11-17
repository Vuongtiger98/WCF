#==============================================================================
# ** Main
#------------------------------------------------------------------------------
#  This processing is executed after module and class definition is finished.
#==============================================================================

# Keep the same script slot/order. The network runs in a detached PowerShell
# helper; RGSS only renders a small wait screen and polls a local status file.
module WCFStartupUpdate
  VERSION = "0.1.0-test.3"
  CHECK_TIMEOUT = 6.0
  UPDATE_NOTICE = 1.0
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

  def self.draw(sprite,title,note,frame)
    bmp=sprite.bitmap
    bmp.clear
    bmp.fill_rect(bmp.rect,Color.new(9,14,25))
    x,y,w=48,(Graphics.height-200)/2,Graphics.width-96
    bmp.fill_rect(x,y,w,200,Color.new(23,34,55))
    bmp.font.name=defined?(PhoneMenu::UI_FONT) ? PhoneMenu::UI_FONT : ['Segoe UI','Arial']
    bmp.font.size=27;bmp.font.bold=true;bmp.font.color=Color.new(241,245,255)
    bmp.draw_text(x+20,y+18,w-40,38,'Wonder Christmas Fiesta',1)
    bmp.font.size=21;bmp.font.bold=false
    bmp.draw_text(x+16,y+72,w-32,32,title+('.'*(frame/20%4)),1)
    bmp.font.size=16;bmp.font.color=Color.new(187,202,229)
    bmp.draw_text(x+16,y+116,w-32,28,note,1)
    bmp.fill_rect(x+28,y+165,w-56,3,Color.new(58,72,103))
    bmp.fill_rect(x+28+(frame*4)%(w-120),y+165,64,3,Color.new(153,180,249))
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
    draw(sprite,'Đang kiểm tra phiên bản','Bạn có thể tiếp tục chơi khi không có kết nối mạng.',0)
    Graphics.transition(0)
    return true unless launch('Check')
    started=Time.now;frame=0;notice=nil;state={}
    loop do
      Graphics.update;Input.update;frame+=1
      state=read_status if frame%3==0
      if ['available','recovery'].include?(state['status'])
        version=state['version'].to_s
        return true unless version =~ /\A[0-9A-Za-z.+-]{1,80}\z/
        notice ||= Time.now
        title=state['status']=='recovery' ? 'Đang phục hồi cập nhật' : 'Có bản cập nhật mới'
        draw(sprite,title,"Phiên bản #{version} — vui lòng chờ cập nhật.",frame) if frame%8==0
        if Time.now-notice>=UPDATE_NOTICE
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
      elsif !state['status'].to_s.empty? || Time.now-started>=CHECK_TIMEOUT
        return true
      elsif frame%8==0
        draw(sprite,'Đang kiểm tra phiên bản','Đang kết nối tới máy chủ cập nhật',frame)
      end
    end
  rescue StandardError
    true
  ensure
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
