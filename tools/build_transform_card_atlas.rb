# encoding: UTF-8
# Build an isolated RGSS bitmap-packing job. No source art is repainted here.
# The generated back is sampled with nearest neighbours into four equal cells.
require_relative 'build_transform_animation'
root=File.expand_path('..',__dir__)
run=File.expand_path(ARGV.fetch(0),root)
raise 'Runner must stay inside Save' unless run.start_with?(File.join(root,'Save')+'/')
raise 'Runner exists' if File.exist?(run)
FileUtils.mkdir_p(File.join(run,'Data'))
pack=Marshal.load(File.binread(File.join(root,'Data/Scripts.rvdata2')))
main=pack.find{|entry|entry[1]=='Main'}
main[2]=Zlib::Deflate.deflate(<<~RUBY)
  rgss_main do
    begin
      source=Bitmap.new('Graphics/System/TransformCardBack.png')
      raise 'Source dimensions changed; update the crop bounds' unless source.width==1254 && source.height==1254
      card=Bitmap.new(192,192)
      # Alpha >= 128 bounds of the generated card, excluding faint exterior pixels.
      bx=266; by=72; width=722; height=1110
      174.times do |y|
        114.times do |x|
          sx=bx+((x+0.5)*width/114).floor
          sy=by+((y+0.5)*height/174).floor
          card.set_pixel(39+x,9+y,source.get_pixel(sx,sy))
        end
      end
      atlas=Bitmap.new('Graphics/Animations/TransformMagic.png')
      raise 'Unexpected atlas dimensions' unless atlas.width==960 && atlas.height==576
      atlas.clear_rect(0,384,960,192)
      4.times{|index|atlas.blt(index*192,384,card,card.rect)}
      raise 'Cannot save atlas' unless atlas.save('TransformMagic.png')
      raise 'Cannot save card cell' unless card.save('card-cell.png')
      File.open('complete.txt','wb'){|file|file.write('packed 4 identical backs; rings preserved')}
    rescue Exception=>error
      File.open('error.txt','wb'){|file|file.write(error.class.to_s+': '+error.message+"\\n"+error.backtrace.join("\\n"))}
    ensure
      [source,card,atlas].each{|bitmap|bitmap.dispose if bitmap && !bitmap.disposed?}
    end
  end
RUBY
File.binwrite(File.join(run,'Data/Scripts.rvdata2'),Marshal.dump(pack))
['Game.exe','Khas Graphics Library.dll'].each{|name|FileUtils.cp(File.join(root,name),run)}
File.write(File.join(run,'Game.ini'),"[Game]\nRTP=RPGVXAce\nLibrary=System\\RGSS301.dll\nScripts=Data\\Scripts.rvdata2\nTitle=WCF Card Atlas Packing\n")
puts run
