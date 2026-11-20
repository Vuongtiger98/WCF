# encoding: UTF-8
# Targeted two-stage transformation update. No map layout or script-order rebuild.
require 'json'
require 'fileutils'
require 'digest'
require 'zlib'
eval(File.read(File.join(__dir__,'rvdata2_audit.rb'),encoding:'UTF-8').split(/^module RVData2Audit/).first,TOPLEVEL_BINDING)
module TransformAnimationBuild
  module_function
  def iv(object,key); object.instance_variable_get('@'+key.to_s); end
  def smooth(value)
    t=[[value,0.0].max,1.0].min
    t*t*(3-2*t)
  end
  def frame(cells)
    result=RPG::Animation::Frame.new
    result.instance_variable_set(:@cell_max,cells.size)
    raw=[2,cells.size,8,1,cells.size*8].pack('V5')
    raw << 8.times.flat_map{|column|cells.map{|cell|cell[column].round}}.pack('s<*')
    result.instance_variable_set(:@cell_data,Table._load(raw))
    result
  end
  def timing(index,name,volume,pitch)
    result=RPG::Animation::Timing.new
    sound=RPG::SE.new
    {name:name,volume:volume,pitch:pitch}.each{|key,value|sound.instance_variable_set('@'+key.to_s,value)}
    {frame:index,se:sound,flash_scope:0,flash_duration:1,
      flash_color:Color._load([0,0,0,0].pack('E4'))}.each{|key,value|result.instance_variable_set('@'+key.to_s,value)}
    result
  end
  def ring(pattern,y,scale,opacity)
    centres=[[97.5,39.5],[96.5,39.5],[93,44],[96.5,38.5],[96,44.5],
      [100.5,150],[86.5,158],[101.5,154],[86,154],[102.5,150.5]]
    x,cy=centres[pattern]
    [pattern,(96-x)*scale/100.0,y+(96-cy)*scale/100.0,scale,0,0,opacity,0]
  end
  def cells(index,reveal)
    last_cast=47
    step=reveal ? last_cast+index : index
    birth=reveal ? 1.0 : smooth(index/8.0)
    merge=reveal ? 1.0 : smooth((index-33)/14.0)
    exit_progress=reveal ? smooth(index/31.0) : 0.0
    shrink=reveal ? 1-smooth((index-9)/22.0) : 1.0
    opacity=reveal ? 1-smooth((index-16)/15.0) : birth
    head_y=-60+35*merge+35*exit_progress
    foot_y=8-33*merge-38*exit_progress
    head=ring(step/2%5,head_y,(30+56*birth)*shrink,200*opacity)
    foot=ring(5+(4-step/2%5),foot_y,(28+50*birth)*shrink,185*opacity)
    result=[head,foot]
    4.times do |card|
      show=reveal ? 1.0 : smooth((index-7-card*2)/6.0)
      fade=reveal ? 1-smooth((index-4)/27.0) : 1.0
      angle=(card*90+step*8)*Math::PI/180.0
      radius=(78+35*exit_progress)*show
      result << [10+card,Math.cos(angle)*radius,-29+Math.sin(angle)*25-42*exit_progress,
        (33-13*exit_progress)*show,Math.sin(angle)*10,0,235*show*fade,0]
    end
    reveal && index==31 ? [] : result
  end
  def build(id=125)
    reveal=id==127
    raise 'Expected 125 or 127' unless [125,127].include?(id)
    result=RPG::Animation.new
    count=reveal ? 32 : 48
    {id:id,name:(reveal ? 'Transform Magic - Reveal' : 'Transform Magic - Cast')+' <rate: 3><follow><above>',
      animation1_name:'TransformMagic',animation1_hue:0,animation2_name:'',animation2_hue:0,
      position:2,frame_max:count,frames:Array.new(count){|i|frame(cells(i,reveal))},
      timings:[timing(0,reveal ? 'Up2' : 'Magic6',50,reveal ? 110 : 105)]}.each do |key,value|
      result.instance_variable_set('@'+key.to_s,value)
    end
    result
  end
  def blank(id)
    result=RPG::Animation.new
    {id:id,name:'',animation1_name:'',animation1_hue:0,animation2_name:'',animation2_hue:0,
      position:1,frame_max:1,frames:[frame([])],timings:[]}.each{|key,value|result.instance_variable_set('@'+key.to_s,value)}
    result
  end
  def command(text)
    result=RPG::EventCommand.new
    result.instance_variable_set(:@code,355);result.instance_variable_set(:@indent,0)
    result.instance_variable_set(:@parameters,[text]);result
  end
  def patch_map(map,map_id)
    count=0
    iv(map,:events).each_value do |event|
      iv(event,:pages).each do |page|
        list=iv(page,:list)
        condition=iv(page,:condition)
        if map_id==13 && [97,98].include?(iv(event,:id)) && iv(condition,:variable_valid) &&
            iv(condition,:variable_id)==4 && iv(condition,:variable_value)==1 &&
            !list.any?{|c|iv(c,:code)==108 && iv(c,:parameters)==['<transform form: riu>']}
          tag=command('<transform form: riu>');tag.instance_variable_set(:@code,108)
          list=[tag]+list;count+=1
        end
        output=[];i=0
        while i<list.size
          cmd=list[i];code=iv(cmd,:code);pars=iv(cmd,:parameters)
          output << cmd;i+=1
        end
        page.instance_variable_set(:@list,output)
      end
    end
    count
  end
  def geometry(map)
    attrs=map.instance_variables.reject{|key|key==:@events}.to_h{|key|[key,Marshal.dump(map.instance_variable_get(key))]}
    attrs[:events]=iv(map,:events).to_h do |id,event|
      event_attrs=event.instance_variables.reject{|key|key==:@pages}.to_h{|key|[key,Marshal.dump(event.instance_variable_get(key))]}
      event_attrs[:pages]=iv(event,:pages).map{|page|page.instance_variables.reject{|key|key==:@list}.to_h{|key|[key,Marshal.dump(page.instance_variable_get(key))]}}
      [id,event_attrs]
    end
    attrs
  end
  def apply(root,write)
    animation_path=File.join(root,'Data/Animations.rvdata2')
    animations=Marshal.load(File.binread(animation_path));old=animations.map{|object|Marshal.dump(object)}
    animations[123]=blank(123);animations[124]=blank(124)
    animations[125]=build(125);animations[127]=build(127)
    raise 'Other animation changed' unless animations.each_index.all?{|id|[123,124,125,127].include?(id)||Marshal.dump(animations[id])==old[id]}
    script_path=File.join(root,'Data/Scripts.rvdata2');pack=Marshal.load(File.binread(script_path))
    old_pack=Marshal.load(Marshal.dump(pack));slot=pack.each_index.find{|i|pack[i][1]=='Transform Form Selection'}
    raise 'No transformation script' unless slot
    pack[slot][2]=Zlib::Deflate.deflate(File.binread(File.join(root,'Scripts/Transform Form Selection.rb')))
    raise 'Script order or identity changed' unless pack.map{|e|e[0,2]}==old_pack.map{|e|e[0,2]}
    raise 'Other script changed' unless pack.each_index.all?{|i|i==slot||pack[i]==old_pack[i]}
    maps={}
    Dir[File.join(root,'Data/Map[0-9][0-9][0-9].rvdata2')].each do |path|
      map=Marshal.load(File.binread(path));before=geometry(map);count=patch_map(map,File.basename(path)[3,3].to_i)
      next if count==0
      raise 'Map geometry, condition or page setting changed' unless geometry(map)==before
      maps[path]={map:map,changes:count}
    end
    result={animations:[125,127],retired:[123,124],cast_updates:144,reveal_updates:96,
      map_changes:maps.transform_values{|row|row[:changes]},script_slot:slot,slots:pack.size,applied:write}
    if write
      backup=File.join(root,'Data/codex_backup_transform_magical_'+Time.now.strftime('%Y%m%d_%H%M%S'))
      raise 'Backup exists' if File.exist?(backup)
      FileUtils.mkdir_p(backup)
      ([animation_path,script_path]+maps.keys).each{|path|FileUtils.cp(path,backup)}
      File.binwrite(File.join(backup,'Transform Form Selection.rb'),Zlib::Inflate.inflate(old_pack[slot][2]))
      File.binwrite(animation_path,Marshal.dump(animations));File.binwrite(script_path,Marshal.dump(pack))
      maps.each{|path,row|File.binwrite(path,Marshal.dump(row[:map]))}
      result[:backup]=backup
    end
    puts JSON.pretty_generate(result)
  end
end
TransformAnimationBuild.apply(File.expand_path('..',__dir__),ARGV.include?('--apply')) if $PROGRAM_NAME==__FILE__
