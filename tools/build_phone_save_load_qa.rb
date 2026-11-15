# frozen_string_literal: true
# Creates a disposable native runner. Production packs and saves are never run.
require 'fileutils'
require 'zlib'
root=File.expand_path('..',__dir__)
destination=File.join(root,'Save/PhoneSaveLoadQA_'+Time.now.strftime('%Y%m%d_%H%M%S'))
raise 'QA directory already exists; retain its results instead of overwriting' if File.exist?(destination)
FileUtils.mkdir_p(File.join(destination,'Data'))
Dir[File.join(root,'Data/*.rvdata2')].each { |path| FileUtils.cp(path,File.join(destination,'Data',File.basename(path))) }
['Game.exe','Khas Graphics Library.dll','Graphics Settings.cfg'].each do |name|
  FileUtils.cp(File.join(root,name),File.join(destination,name)) if File.file?(File.join(root,name))
end
scripts=Marshal.load(File.binread(File.join(destination,'Data/Scripts.rvdata2')))
slot=scripts.find { |entry| entry[1]=='Custom Menu' }
slot[2]=Zlib::Deflate.deflate(File.binread(File.join(root,'Scripts/Custom Menu.rb')))
harness=File.binread(File.join(__dir__,'qa_phone_save_load_native.rb'))
scripts.insert(scripts.index { |entry| entry[1]=='Main' },[999998,'LOCAL Save Load QA',Zlib::Deflate.deflate(harness)])
File.binwrite(File.join(destination,'Data/Scripts.rvdata2'),Marshal.dump(scripts))
File.write(File.join(destination,'Game.ini'),"[Game]\nRTP=RPGVXAce\nLibrary=System\\RGSS301.dll\nScripts=Data\\Scripts.rvdata2\nTitle=WCF Automated Save Load QA\n")
puts destination
