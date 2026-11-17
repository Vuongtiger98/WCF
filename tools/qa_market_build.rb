# Isolated supermarket route QA. No production map or script entry is rewritten.
require 'fileutils'
require 'digest'
require 'json'
require 'zlib'
root=File.expand_path('..',__dir__)
run=File.expand_path(ARGV.fetch(0),root)
raise 'Run already exists' if File.exist?(run)
raise 'Run must be inside Save' unless run.start_with?(File.join(root,'Save')+File::SEPARATOR)
gift,target=ARGV.fetch(1).to_i,ARGV.fetch(2).to_i
raise 'Invalid gift/target' unless (1..4).include?(gift) && (1..4).include?(target)
config={:gift=>gift,:target=>target,:coffee=>(ARGV[3] || 'normal'),
  :survey=>(['survey','survey-safe'].include?(ARGV[4])),:skip_crafting=>(ARGV[4]=='survey-safe'),
  :start=>(ARGV[5] || 'bus'),:instant=>true}
FileUtils.mkdir_p(File.join(run,'Data'))
FileUtils.mkdir_p(File.join(run,'captures'))
Dir[File.join(root,'Data/*.rvdata2')].each {|p|FileUtils.cp(p,File.join(run,'Data',File.basename(p)))}
['Game.exe','Khas Graphics Library.dll','Graphics Settings.cfg','HaiQuy.txt'].each do |name|
  p=File.join(root,name);FileUtils.cp(p,File.join(run,name)) if File.file?(p)
end
pack=Marshal.load(File.binread(File.join(run,'Data/Scripts.rvdata2')))
original=Marshal.dump(pack)
harness=%w[qa_prologue_native.rb qa_market_native.rb].map {|name|File.binread(File.join(__dir__,name))}.join("\n")
pack.insert(pack.index {|e|e[1]=='Main'},[999990,'LOCAL Supermarket Route QA',Zlib::Deflate.deflate(harness)])
File.binwrite(File.join(run,'Data/Scripts.rvdata2'),Marshal.dump(pack))
raise 'Original slots changed' unless Marshal.dump(pack.reject {|e|e[1]=='LOCAL Supermarket Route QA'})==original
File.write(File.join(run,'Game.ini'),"[Game]\nRTP=RPGVXAce\nLibrary=System\\RGSS301.dll\nScripts=Data\\Scripts.rvdata2\nTitle=WCF Supermarket Route QA\n")
File.binwrite(File.join(run,'market-case.marshal'),Marshal.dump(config))
File.write(File.join(run,'case.txt'),'0')
paths=Dir[File.join(root,'Data/*.rvdata2')]+Dir[File.join(root,'Scripts/*')].select {|p|File.file?(p)}
File.write(File.join(run,'production-before.json'),JSON.pretty_generate(paths.to_h {|p|[p.sub(root+'/',''),Digest::SHA256.file(p).hexdigest]}))
puts run
