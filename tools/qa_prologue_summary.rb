# Read the isolated native runs and verify their evidence against production.
require 'json'
require 'digest'
require 'zlib'
root=File.expand_path('..',__dir__)
base=File.join(root,'Save/PrologueQA_20261116')
names=ARGV.empty? ? ['accepted0','accepted1','accepted2','accepted3'] : ARGV
expected=[19,13,22,20]
rows=[]
names.each_with_index do |name,branch|
  run=File.join(base,name)
  raise "Native failure #{name}" if File.exist?(File.join(run,'failure.marshal'))
  data=Marshal.load(File.binread(File.join(run,'completion.marshal')))
  msgs=Marshal.load(File.binread(File.join(run,'messages.marshal')))
  balloons=Marshal.load(File.binread(File.join(run,'balloons.marshal')))
  manifest=JSON.parse(File.read(File.join(run,'production-before.json')))
  manifest.each {|path,sha|raise "Production changed after build #{path}" unless Digest::SHA256.file(File.join(root,path)).hexdigest==sha}
  pack=Marshal.load(File.binread(File.join(run,'Data/Scripts.rvdata2')))
  pack.reject! {|e|e[1]=='LOCAL Prologue Command QA'}
  raise 'Copy changed production script entries' unless Marshal.dump(pack)==File.binread(File.join(root,'Data/Scripts.rvdata2'))
  raise "Wrong bus destination #{name}" unless data[:complete] && data[:map]==expected[branch]
  raise 'Unreleased bus flags' if data[:transparent] || data[:through] || data[:stop_player] || data[:stop_npc]
  raise 'Black arrival' unless data[:brightness]==255 && data[:kul][:@a]==0
  raise 'Phone transcript missing' unless data[:phone_groups][:wanderer_group]==49
  bus=data[:choices].find {|r|r[:map]==10}
  raise 'Wrong selected bus choice' unless bus && bus[:index]==branch
  msgs.each do |r|
    x,y,w,h=r[:window]
    raise "Message outside screen #{name}/#{r[:id]}" if x<0 || y<0 || x+w>640 || y+h>480
    raise 'Snapshot viewport mismatch' unless r[:source_viewport]==r[:effect_viewport]
    raise 'Wrong pop backdrop lifecycle' unless r[:backdrop]==!!r[:pop]
    raise 'Pop arrow mismatch' if r[:pop] && (r[:bubble_x]-r[:anchor][0]).abs>1
    raise 'Wrong opening player sprite' if r[:message_map]==3 && r[:sprite]!='!$HaiQuy'
  end
  raise 'Balloon clipped' unless balloons.all? {|b|b[:clipped]==0}
  rows << {run:name,branch:branch,map:data[:map],player:data[:player],frames:data[:frame],
    pauses:msgs.size,pop:msgs.count {|m|m[:pop]},balloon_frames:balloons.sum {|b|b[:frames]},
    max_anchor_error:msgs.select {|m|m[:pop]}.map {|m|(m[:bubble_x]-m[:anchor][0]).abs}.max,
    movable:data[:movable],phone_messages:data[:phone_groups][:wanderer_group],
    choices:data[:choices],props:data[:visited]}
end
fax=rows[1]
raise 'Exit cancellation not tested' unless fax[:choices].any? {|r|r[:map]==3 && r[:index]==1}
raise 'Exit confirmation not tested' unless fax[:choices].any? {|r|r[:map]==3 && r[:index]==0}
raise 'Noticeboard interaction not tested' unless rows[0][:props].any? {|r|r[:event]==13 && r[:result]=='completed'}
projection=Marshal.load(File.binread(File.join(base,'projection_fixed/projection.marshal')))
raise 'Native Sprite projection failed' unless projection.all? {|p|p[:error] && p[:error]<=2}
File.write(File.join(base,'verified-summary.json'),JSON.pretty_generate(rows))
puts JSON.pretty_generate({runs:rows.map {|r|r.reject {|k,v|[:choices,:props].include?(k)}},
  total_pauses:rows.sum {|r|r[:pauses]},total_balloon_frames:rows.sum {|r|r[:balloon_frames]},
  native_projection_cases:projection.size,max_projection_raster_error:projection.map {|p|p[:error]}.max,
  production_unchanged_since_build:true,all_checks_passed:true})
