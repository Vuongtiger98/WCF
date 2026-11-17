# Build a disposable native chat runner. No production maps or saves are edited.
require 'fileutils'
require 'digest'
require 'json'
require 'zlib'
root=File.expand_path('..',__dir__)
run=ARGV[0] || 'Save/CutscenePhoneQA_'+Time.now.strftime('%Y%m%d_%H%M%S')
run=File.expand_path(run,root)
raise 'QA run already exists' if File.exist?(run)
raise 'QA must be inside Save' unless run.start_with?(File.join(root,'Save')+File::SEPARATOR)
FileUtils.mkdir_p(File.join(run,'Data'))
FileUtils.mkdir_p(File.join(run,'captures'))
Dir[File.join(root,'Data/*.rvdata2')].each {|p|FileUtils.cp(p,File.join(run,'Data',File.basename(p)))}
['Game.exe','Khas Graphics Library.dll','Graphics Settings.cfg','HaiQuy.txt'].each do |name|
  p=File.join(root,name); FileUtils.cp(p,File.join(run,name)) if File.file?(p)
end
pack=Marshal.load(File.binread(File.join(run,'Data/Scripts.rvdata2')))
harness=ARGV[1] ? File.expand_path(ARGV[1],root) : File.join(__dir__,'qa_cutscene_phone_native.rb')
pack.insert(pack.index {|s|s[1]=='Main'},[999994,'LOCAL Cutscene Phone QA',Zlib::Deflate.deflate(File.binread(harness))])
File.binwrite(File.join(run,'Data/Scripts.rvdata2'),Marshal.dump(pack))
File.write(File.join(run,'Game.ini'),"[Game]\nRTP=RPGVXAce\nLibrary=System\\RGSS301.dll\nScripts=Data\\Scripts.rvdata2\nTitle=WCF Cutscene Phone QA\n")
paths=Dir[File.join(root,'Data/*.rvdata2')]+Dir[File.join(root,'Scripts/*')].select {|p|File.file?(p)}
File.write(File.join(run,'production-before.json'),JSON.pretty_generate(paths.to_h {|p|[p.sub(root+'/',''),Digest::SHA256.file(p).hexdigest]}))
puts run
