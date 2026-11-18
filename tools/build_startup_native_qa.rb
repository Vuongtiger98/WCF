# Isolated native startup/handoff test; no production Data is written.
require 'fileutils'
require 'zlib'
root=File.expand_path('..',__dir__)
base=File.expand_path(ARGV[0] || 'Save/StartupNativeQA_20261117',root)
raise 'QA must be inside Save' unless base.start_with?(File.join(root,'Save')+'/')
raise 'Use a fresh QA directory' if File.exist?(base)
FileUtils.mkdir_p(base)
main=File.read(File.join(root,'Scripts/Main.rb'),encoding:'UTF-8')
body=main.split(/^rgss_main/).first
original=Marshal.load(File.binread(File.join(root,'Data/Scripts.rvdata2')))
main_index=original.index{|entry|entry[1]=='Main'}
%w[source handoff real-check].each do |name|
  dir=File.join(base,name)
  FileUtils.mkdir_p(dir+'/Data');FileUtils.mkdir_p(dir+'/gameupdate')
  Dir[File.join(root,'Data/*.rvdata2')].each{|p|FileUtils.cp(p,dir+'/Data/'+File.basename(p))}
  %w[Game.exe Game.ini Game.rvproj2 GameUpdate.bat].each{|f|FileUtils.cp(File.join(root,f),dir+'/'+f)}
  FileUtils.cp(File.join(root,'Khas Graphics Library.dll'),dir+'/Khas Graphics Library.dll')
  %w[Update.ps1 WcfUpdater.psm1 config.json].each{|f|FileUtils.cp(File.join(root,'gameupdate',f),dir+'/gameupdate/'+f)}
  pack=Marshal.load(Marshal.dump(original))
  code=body.dup
  if name=='source'
    code+=<<~'RUBY'
      rgss_main do
        skipped=ENV['WCF_SKIP_STARTUP_CHECK']=='1'
        result=WCFStartupUpdate.run
        File.open('native-restarted.marshal','wb'){|f|f.write(Marshal.dump({:skip_received=>skipped,:skip_consumed=>ENV['WCF_SKIP_STARTUP_CHECK'].nil?,:result=>result}))}
      end
    RUBY
  else
    code+=<<~'RUBY'
      module Graphics
        class << self
          alias startup_qa_update update
          def update
            # Native update pauses while a hidden RGSS window lacks focus.
            # Render snapshots and measure wall time without taking user focus.
            @startup_qa_frames=(@startup_qa_frames||0)+1
            if [1,10,20,30,40,180].include?(@startup_qa_frames)
              b=snap_to_bitmap;b.save('startup-'+@startup_qa_frames.to_s+'.png');b.dispose
            end
            sleep(0.005)
          end
        end
      end
    RUBY
    if name=='handoff'
      # Preserve the real wide-character ShellExecute call for Update mode.
      code.sub!("args+=' -StartupMode '","args+=' -PackageDirectory \"#{(base+'/package/release').gsub('/','\\')}\"' if mode=='Update'\n    args+=' -StartupMode '")
      code+=<<~'RUBY'
        module WCFStartupUpdate
          class << self
            alias startup_qa_launch launch
            def launch(mode)
              if mode=='Check'
                File.open(@folder+'/check.txt','wb'){|f|f.write("status=available\nversion=0.1.0-test.5\n")}
                true
              else
                startup_qa_launch(mode)
              end
            end
          end
        end
      RUBY
      helper=File.read(dir+'/gameupdate/Update.ps1',encoding:'bom|UTF-8')
      helper.sub!("$form.StartPosition='CenterScreen'","$form.ShowInTaskbar=$false;$form.StartPosition='Manual';$form.Location=New-Object Drawing.Point(-3000,-3000)")
      helper.sub!('[Diagnostics.ProcessWindowStyle]::Normal','[Diagnostics.ProcessWindowStyle]::Hidden')
      # Capture the actual native WinForms drawing while keeping QA off-screen.
      capture=<<~'PS'
        $shotKey=$heading.Text
        if (!$qaShots.ContainsKey($shotKey)) {
          $qaShots[$shotKey]=$true
          $bmp=New-Object Drawing.Bitmap($form.Width,$form.Height)
          $form.DrawToBitmap($bmp,(New-Object Drawing.Rectangle(0,0,$form.Width,$form.Height)))
          $bmp.Save((Join-Path $GameRoot ('updater-'+$qaShots.Count+'.png')))
          $bmp.Dispose()
        }
      PS
      helper.sub!('$timer.Add_Tick({',"$qaShots=@{}\n    $timer.Add_Tick({")
      helper.sub!("if ($state.process.HasExited) {",capture+"\n            if ($state.process.HasExited) {")
      File.binwrite(dir+'/gameupdate/Update.ps1',"\xEF\xBB\xBF".b+helper.b)
    end
    code+=<<~'RUBY'
      rgss_main do
        started=Time.now
        result=WCFStartupUpdate.run
        rows=Dir['gameupdate/startup-*/check.txt'].map{|p|File.open(p,'rb'){|f|f.read}}
        ready=!Dir['gameupdate/startup-*/ready'].empty?
        File.open('native-result.marshal','wb'){|f|f.write(Marshal.dump({:result=>result,:ready=>ready,:checked=>WCFStartupUpdate.checked,:elapsed=>Time.now-started,:status=>rows}))}
      end
    RUBY
  end
  pack[main_index][2]=Zlib::Deflate.deflate(code)
  File.binwrite(dir+'/Data/Scripts.rvdata2',Marshal.dump(pack))
end
puts base
