# encoding: UTF-8
# Isolated native runner; no real user save is read or written.
require_relative 'build_transform_animation'
root=File.expand_path('..',__dir__)
run=File.expand_path(ARGV.fetch(0),root)
raise 'Runner must be inside Save' unless run.start_with?(File.join(root,'Save')+'/')
raise 'Runner already exists' if File.exist?(run)
FileUtils.mkdir_p(File.join(run,'Data'));FileUtils.mkdir_p(File.join(run,'captures'))
pack=Marshal.load(File.binread(File.join(root,'Data/Scripts.rvdata2')))
entry=pack.find{|e|e[1]=='Transform Form Selection'}
entry[2]=Zlib::Deflate.deflate(File.binread(File.join(root,'Scripts/Transform Form Selection.rb')))
main=pack.find{|e|e[1]=='Main'}
pack.insert(pack.index(main),[999992,'LOCAL NPC Reaction QA',Zlib::Deflate.deflate(File.binread(File.join(__dir__,'qa_npc_reaction_native.rb')))])
main[2]=Zlib::Deflate.deflate(<<~RUBY)
  NFR_QA_ROOT=#{root.dump}
  module Kernel
    alias nfr_qa_load_data load_data
    def load_data(path)
      nfr_qa_load_data(path.start_with?('Data/') ? NFR_QA_ROOT+'/'+path : path)
    end
  end
  rgss_main { NPCReactionQA.run }
RUBY
File.binwrite(File.join(run,'Data/Scripts.rvdata2'),Marshal.dump(pack))
['Game.exe','Khas Graphics Library.dll','Graphics Settings.cfg','HaiQuy.txt'].each do |name|
  FileUtils.cp(File.join(root,name),File.join(run,name)) if File.file?(File.join(root,name))
end
File.write(File.join(run,'Game.ini'),"[Game]\nRTP=RPGVXAce\nLibrary=System\\RGSS301.dll\nScripts=Data\\Scripts.rvdata2\nTitle=WCF NPC Reaction QA\n")
puts run
