# Build an isolated native RGSS command-test copy. Never rebuild production maps.
require 'fileutils'
require 'digest'
require 'json'
require 'zlib'
root=File.expand_path('..',__dir__)
run=File.expand_path(ARGV.fetch(0),root)
raise 'Run already exists' if File.exist?(run)
raise 'Run must be inside Save' unless run.start_with?(File.join(root,'Save')+File::SEPARATOR)
FileUtils.mkdir_p(File.join(run,'Data'))
FileUtils.mkdir_p(File.join(run,'captures'))
Dir[File.join(root,'Data/*.rvdata2')].each { |p| FileUtils.cp(p,File.join(run,'Data',File.basename(p))) }
['Game.exe','Khas Graphics Library.dll','Graphics Settings.cfg','HaiQuy.txt'].each do |name|
  p=File.join(root,name); FileUtils.cp(p,File.join(run,name)) if File.file?(p)
end
pack=Marshal.load(File.binread(File.join(run,'Data/Scripts.rvdata2')))
original=Marshal.dump(pack)
pack.insert(pack.index { |e|e[1]=='Main' },[999995,'LOCAL Prologue Command QA',Zlib::Deflate.deflate(File.binread(File.join(__dir__,'qa_prologue_native.rb')))])
File.binwrite(File.join(run,'Data/Scripts.rvdata2'),Marshal.dump(pack))
File.write(File.join(run,'Game.ini'),"[Game]\nRTP=RPGVXAce\nLibrary=System\\RGSS301.dll\nScripts=Data\\Scripts.rvdata2\nTitle=WCF Prologue Command QA\n")
File.write(File.join(run,'case.txt'),ARGV[1] || '0')
paths=Dir[File.join(root,'Data/*.rvdata2')]+Dir[File.join(root,'Scripts/*')].select { |p|File.file?(p) }
File.write(File.join(run,'production-before.json'),JSON.pretty_generate(paths.to_h { |p|[p.sub(root+'/',''),Digest::SHA256.file(p).hexdigest] }))
raise 'Original script entries changed' unless Marshal.dump(pack.reject {|e|e[1]=='LOCAL Prologue Command QA'})==original
puts run
