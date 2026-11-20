# encoding: UTF-8
# Apply card rewards and existing event-list edits without rebuilding maps.
require_relative 'build_transform_animation'
module TransformCardsUpdate
  module_function
  def v(object,key);object.instance_variable_get('@'+key.to_s);end
  def cmd(code,params=[],indent=0)
    result=TransformAnimationBuild.command('')
    result.instance_variable_set(:@code,code);result.instance_variable_set(:@parameters,params);result.instance_variable_set(:@indent,indent);result
  end
  def script(lines,indent=0)
    lines.each_with_index.map{|line,index|cmd(index==0 ? 355 : 655,[line],indent)}
  end
  def choice(rows,indent=0)
    result=[cmd(102,[rows.map(&:first),rows.size],indent)]
    rows.each_with_index do |(name,body),index|
      result << cmd(402,[index,name],indent)
      result.concat(body);result << cmd(0,[],indent+1)
    end
    result << cmd(404,[],indent)
    result
  end
  def wait_ui
    ['while $game_message.busy? || $game_message.visible','  wait(1)','end']
  end
  def hub_list
    individual=choice([
      ['Gamemerr',script(['TransformMagic.unlock(:gamemerr)'],2)],
      ['Sanic',script(['TransformMagic.unlock(:sanic)'],2)],
      ['Diana',script(['TransformMagic.unlock(:diana)'],2)],['Hủy',[]]],1)
    reset=wait_ui+['TransformMagic.revert','[:gamemerr, :sanic, :diana].each do |id|','  TransformMagic.lock(id)','end','TransformMagic.unlock(:riu, false)']
    fast=choice([
      ['Mở cả 4 thẻ',script(['TransformMagic::FORMS.keys.each do |id|','  TransformMagic.unlock(id)','end'],2)],
      ['Chỉ giữ thẻ Riu',script(reset,2)],['Hủy',[]]],1)
    [cmd(101,['',0,0,2]),cmd(401,['Riu có sẵn ngay từ đầu.']),cmd(401,['Chọn thẻ mở trong lượt chơi thử này.']),cmd(401,['Bấm D để dùng phép biến hình.'])]+choice([
      ['Thử biến hình',script(wait_ui+['TransformMagic.unlock(:riu, false)','TransformMagic.request_cast'],1)],
      ['Mở từng thẻ',individual],['Thiết lập nhanh',fast],['Hủy',[]]])+[cmd(0)]
  end
  def apply(root,write)
    data=File.join(root,'Data');outputs={}
    common_path=File.join(data,'CommonEvents.rvdata2');common=Marshal.load(File.binread(common_path))
    ce20=common.fetch(20);list=v(ce20,:list)
    if list.any?{|c|v(c,:code)==117 && v(c,:parameters)==[21]}
      scene=Marshal.load(Marshal.dump(v(common.fetch(21),:list)))
    else
      raise 'CE21 already occupied' if common[21]
      start=list.index{|c|v(c,:code)==111};raise 'RAM condition missing' unless start
      scene=Marshal.load(Marshal.dump(list[start..-1]))
    end
    condition=scene.find{|c|v(c,:code)==111};condition.instance_variable_set(:@parameters,[12,'TransformMagic.diana_ready?'])
    unless scene.any?{|c|v(c,:code)==355 && v(c,:parameters)==['TransformMagic.unlock(:diana)']}
      index=scene.index{|c|v(c,:code)==355 && v(c,:parameters)[0].include?('WCF_RAM_DIANA_CAMERA_RESET')};raise 'Diana scene ending missing' unless index
      scene.insert(index,cmd(355,['TransformMagic.unlock(:diana)'],1))
    end
    ce21=Marshal.load(Marshal.dump(ce20));ce21.instance_variable_set(:@id,21);ce21.instance_variable_set(:@name,'CARD — Diana: encounter after 10 RAM [CE21]');ce21.instance_variable_set(:@list,scene)
    ce20.instance_variable_set(:@name,'ITEM — Receive RAM [CE20]');ce20.instance_variable_set(:@list,list.first(3)+[cmd(117,[21]),cmd(0)])
    common[21]=ce21;outputs[common_path]=Marshal.dump(common)
    map3_path=File.join(data,'Map003.rvdata2');map3=Marshal.load(File.binread(map3_path));geometry=TransformAnimationBuild.geometry(map3)
    page=v(v(map3,:events).fetch(3),:pages).first;intro=v(page,:list)
    unless intro.any?{|c|v(c,:code)==355 && v(c,:parameters)==['# WCF_TRANSFORM_TUTORIAL']}
      index=intro.rindex{|c|v(c,:code)==123};raise 'Intro completion missing' unless index
      intro.insert(index,cmd(355,['# WCF_TRANSFORM_TUTORIAL']),cmd(101,['',0,0,2]),cmd(401,['\\cbm Bấm phím D để dùng phép biến hình.']))
    end
    raise 'Map003 layout changed' unless geometry==TransformAnimationBuild.geometry(map3)
    outputs[map3_path]=Marshal.dump(map3)
    hub_path=File.join(data,'Map069.rvdata2');hub=Marshal.load(File.binread(hub_path));geometry=TransformAnimationBuild.geometry(hub)
    hub_events=v(hub,:events);untouched=hub_events.reject{|id,event|id==43}.to_h{|id,event|[id,Marshal.dump(event)]}
    v(hub_events.fetch(43),:pages).first.instance_variable_set(:@list,hub_list)
    raise 'Hub layout changed' unless geometry==TransformAnimationBuild.geometry(hub)
    untouched.each{|id,bytes|raise 'Existing hub event changed' unless Marshal.dump(hub_events[id])==bytes}
    outputs[hub_path]=Marshal.dump(hub)
    scripts_path=File.join(data,'Scripts.rvdata2');pack=Marshal.load(File.binread(scripts_path));original=Marshal.load(Marshal.dump(pack))
    names=['Custom Menu','Transform Form Selection','Catto Petting Minigame'];slots=[]
    names.each do |name|
      index=pack.each_index.find{|i|pack[i][1]==name};raise name unless index
      pack[index][2]=Zlib::Deflate.deflate(File.binread(File.join(root,'Scripts',name+'.rb')));slots<<index
    end
    raise 'Script identities changed' unless pack.map{|e|e[0,2]}==original.map{|e|e[0,2]}
    pack.each_index{|i|raise "Other script #{i} changed" unless slots.include?(i)||pack[i]==original[i]}
    outputs[scripts_path]=Marshal.dump(pack)
    result={slots:slots,slot_count:pack.size,common_events:[20,21],map_events:{3=>[3],69=>[43]},hub_existing_events_preserved:40,applied:write}
    if write
      backup=File.join(data,'codex_backup_transform_cards_'+Time.now.strftime('%Y%m%d_%H%M%S'));raise 'Backup exists' if File.exist?(backup);FileUtils.mkdir_p(backup)
      outputs.each_key{|path|FileUtils.cp(path,backup)}
      slots.each{|index|File.binwrite(File.join(backup,original[index][1]+'.rb'),Zlib::Inflate.inflate(original[index][2]))}
      FileUtils.cp(File.join(root,'Graphics/Animations/TransformMagic.png'),backup)
      outputs.each{|path,bytes|File.binwrite(path,bytes)};result[:backup]=backup
    end
    puts JSON.pretty_generate(result)
  end
end
TransformCardsUpdate.apply(File.expand_path('..',__dir__),ARGV.include?('--apply')) if $PROGRAM_NAME==__FILE__
