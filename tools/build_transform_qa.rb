# encoding: UTF-8
# Minimal disposable runner: one script pack, exe/config, and shared asset links.
# All database reads are redirected to the project, all QA writes stay in run.
require_relative 'build_transform_animation'
root = File.expand_path('..', __dir__)
run = File.expand_path(ARGV.fetch(0), root)
raise 'Runner must be inside Save' unless run.start_with?(File.join(root, 'Save') + '/')
raise 'Runner exists' if File.exist?(run)
FileUtils.mkdir_p(File.join(run, 'Data'))
FileUtils.mkdir_p(File.join(run, 'captures'))
pack = Marshal.load(File.binread(File.join(root, 'Data/Scripts.rvdata2')))
pack.find { |entry| entry[1] == 'Transform Form Selection' }[2] = Zlib::Deflate.deflate(File.binread(File.join(root, 'Scripts/Transform Form Selection.rb')))
main = pack.find { |entry| entry[1] == 'Main' }
harness = File.binread(File.join(__dir__, 'qa_transform_native.rb'))
pack.insert(pack.index(main), [999993, 'LOCAL Transform QA', Zlib::Deflate.deflate(harness)])
main[2] = Zlib::Deflate.deflate(<<~RUBY)
  TRANSFORM_QA_PROJECT_ROOT = #{root.dump}
  module Kernel
    alias transform_qa_load_data load_data
    def load_data(path)
      path = TRANSFORM_QA_PROJECT_ROOT + '/' + path if path.start_with?('Data/')
      transform_qa_load_data(path)
    end
  end
  rgss_main { TransformQA.run }
RUBY
File.binwrite(File.join(run, 'Data/Scripts.rvdata2'), Marshal.dump(pack))
File.binwrite(File.join(run, 'animation125.rvdata2'), Marshal.dump(TransformAnimationBuild.build))
File.binwrite(File.join(run, 'animation127.rvdata2'), Marshal.dump(TransformAnimationBuild.build(127)))
['Game.exe', 'Khas Graphics Library.dll', 'Graphics Settings.cfg', 'HaiQuy.txt'].each do |name|
  source = File.join(root, name)
  FileUtils.cp(source, File.join(run, name)) if File.file?(source)
end
File.write(File.join(run, 'Game.ini'), "[Game]\nRTP=RPGVXAce\nLibrary=System\\RGSS301.dll\nScripts=Data\\Scripts.rvdata2\nTitle=WCF Transform Animation QA\n")
puts run
