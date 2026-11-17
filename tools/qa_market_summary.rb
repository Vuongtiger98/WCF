# Read-only verifier for independent supermarket native runs and source text.
require 'json'
require 'digest'
require 'zlib'
root=File.expand_path('..',__dir__)
base=File.join(root,'Save/MarketQA_20261117')
def visible_text(text)
  text.to_s.unicode_normalize(:nfc).gsub(/\\(?:cbm|bm\[[^\]]*\]|[cC]\[[^\]]*\]|[fF][sS]\[[^\]]*\])/,'').
    gsub(/\\[.!|><^{}]/,'').strip
end
def normalized(text)
  visible_text(text).downcase.gsub(/[[:space:]\u00a0]/,'').gsub('…','...').gsub(/[“”]/,'"').gsub(/[‘’]/,"'")
end
source_path=File.join(base,'source-paragraphs.json')
paragraphs=File.exist?(source_path) ? JSON.parse(File.read(source_path,encoding:'UTF-8')) : []
compact=File.read(File.join(root,'docs/kich ban/GAME_SCRIPT_AI_COMPACT_V2.md'),encoding:'UTF-8')
blocks=compact.lines.filter_map {|line|match=line.match(/^(B\d+): (.*)/);match && {id:match[1],text:match[2]}}
corpus=normalized(blocks.map {|b|b[:text]}.join("\n"))
doc_corpus=paragraphs.group_by {|p|p['source']}.values.map {|rows|normalized(rows.map {|p|p['text']}.join("\n"))}
paths=File.readlines(File.join(base,'cases.txt'),chomp:true).reject(&:empty?).map {|p|File.join(root,p)}
rows=[];overflow={};source_missing={};all_messages=[]
paths.each do |run|
  name=File.basename(run)
  if File.exist?(File.join(run,'failure.marshal'))
    failure=Marshal.load(File.binread(File.join(run,'failure.marshal')))
    rows << {case:name,status:'native-failure',error:failure};next
  end
  result_path=File.join(run,'completion.marshal')
  unless File.exist?(result_path)
    rows << {case:name,status:'not-finished'};next
  end
  data=Marshal.load(File.binread(result_path))
  config=data[:config]
  expected_hint=2+(config[:gift]-1)*4+config[:target]-1
  expected_bg='ED_MKT_'+%w[COFFEE COOKWARE KNITTING LOCK][config[:gift]-1]+'_'+%w[LEO KOHI SHYLVIE HAKASE][config[:target]-1]
  checks={ending:data[:complete] && data[:maps].include?(36),
    gift:data[:gift]==config[:gift],target:data[:target]==config[:target],
    hint:data[:hint]==expected_hint,title_background:data[:title_background]==expected_bg,
    party_done:data[:party_done],ending_unlock:data[:end_unlock],
    coffee:data[:coffee]==(config[:coffee]=='atlantis'),
    no_unexpected_runtime_issues:data[:issues].empty?}
  manifest=JSON.parse(File.read(File.join(run,'production-before.json')))
  checks[:production_unchanged]=manifest.all? {|path,sha|Digest::SHA256.file(File.join(root,path)).hexdigest==sha}
  original=Marshal.load(File.binread(File.join(run,'Data/Scripts.rvdata2'))).reject {|e|e[1]=='LOCAL Supermarket Route QA'}
  checks[:production_script_entries_preserved]=Marshal.dump(original)==File.binread(File.join(root,'Data/Scripts.rvdata2'))
  library_path=File.join(run,'Save/ItemLibrary.rvdata2')
  library=File.exist?(library_path) ? Marshal.load(File.binread(library_path))[:keys] : []
  if config[:gift]==3
    expected_pin={1=>'cg2',2=>'cg5',3=>'cg3',4=>'cg4'}[config[:target]]
    pins=library.grep(/\Apicture:cg[2-5]\z/)
    checks[:recipient_hairclip]=pins==['picture:'+expected_pin]
  end
  messages=Marshal.load(File.binread(File.join(run,'messages.marshal')))
  messages.each do |message|
    next unless [19,37,38,39,40,36].include?(message[:map])
    all_messages << [name,message]
    face=message[:face][0]
    checks[:face_assets_valid]=true unless checks.key?(:face_assets_valid)
    checks[:face_assets_valid]=false unless face.empty? ||
      ((0..7).include?(message[:face][1]) && Dir[File.join(root,'Graphics/Faces',face+'.*')].any?)
    lines=visible_text(message[:text]).split("\n")
    max=face.empty? ? 40 : 33
    lengths=lines.map {|line|line.rstrip.scan(/\P{M}\p{M}*/).size}
    key=[message[:message_map],message[:event],message[:command],message[:text]]
    if lengths.any? {|n|n>max} || lines.size>4
      overflow[key] ||= {map:message[:map],message_map:message[:message_map],event:message[:event],command:message[:command],
        text:message[:text],face:message[:face],lengths:lengths,max:max,runs:[]}
      overflow[key][:runs] << name unless overflow[key][:runs].include?(name)
    end
    text_norm=normalized(message[:text])
    known=text_norm.size<8 || corpus.include?(text_norm) || doc_corpus.any? {|body|body.include?(text_norm)}
    unless known
      # A display window may span consecutive paragraphs with speaker labels.
      known=lines.all? {|line|n=normalized(line);n.size<8 || corpus.include?(n) || doc_corpus.any? {|body|body.include?(n)}}
    end
    unless known
      source_missing[key] ||= {map:message[:map],event:message[:event],command:message[:command],text:message[:text],runs:[]}
      source_missing[key][:runs] << name unless source_missing[key][:runs].include?(name)
    end
  end
  rows << {case:name,status:checks.values.all? ? 'route-checks-pass' : 'needs-review',
    gift:config[:gift],target:config[:target],coffee:config[:coffee],maps:data[:maps],frames:data[:frame],
    pauses:data[:pauses],checks:checks,issues:data[:issues],minigame_result_simulated:data[:coffee_stubbed],
    library_items:library.size,title_background:data[:title_background]}
end
report={cases:rows,recorded:rows.count {|r|r[:checks]},total:paths.size,
  completed_routes:rows.count {|r|r.dig(:checks,:ending)},route_checks_pass:rows.count {|r|r[:status]=='route-checks-pass'},
  display_overflows:overflow.values,unmatched_source_fragments:source_missing.values,
  observed_message_pauses:all_messages.size,source_docx_paragraphs:paragraphs.size,
  note:'Text matching finds source fragments; it does not independently prove branch semantics or face emotion.'}
File.write(File.join(base,'summary.json'),JSON.pretty_generate(report))
File.write(File.join(base,'observed-messages.json'),JSON.pretty_generate(all_messages.map {|name,message|message.merge(run:name)}))
supplementary={}
%w[survey_safe2_g3_t3 visual_g3_t3 hub_prep_g3_t3 hub_prep_g3_t4].each do |name|
  run=File.join(base,name)
  next unless File.exist?(File.join(run,'completion.marshal'))
  data=Marshal.load(File.binread(File.join(run,'completion.marshal')))
  row=data.slice(:config,:complete,:reason,:maps,:issues,:pauses,:ram,:gift,:target,:hint)
  row[:jobs]=data[:jobs].map {|job|job.slice(:map,:event,:kind,:result)}
  if name.start_with?('hub_prep')
    natural=Marshal.load(File.binread(File.join(base,"flow_g3_t#{data[:target]}",'completion.marshal')))
    clean=lambda {|groups|groups.transform_values {|messages|messages.map {|message|message.reject {|key,_|key==:_phone_id}}}}
    row[:recipient_chat_matches_bus_route]=clean.call(data[:phone])==clean.call(natural[:phone])
  end
  supplementary[name]=row
end
%w[boundary_room63_v2 boundary_cashier_v2].each do |name|
  path=File.join(base,name,'boundary-probe.marshal')
  supplementary[name]=Marshal.load(File.binread(path)) if File.exist?(path)
end
visual_path=File.join(base,'visual_g3_t3','phases.marshal')
if File.exist?(visual_path)
  phases=Marshal.load(File.binread(visual_path))
  supplementary[:layer_sequences]=phases.select {|phase|phase[:map]==38 && phase[:layers].any? {|layer|layer[0]==2}}.
    map {|phase|phase.slice(:frame,:camera,:layers,:characters)}
end
File.write(File.join(base,'supplementary-summary.json'),JSON.pretty_generate(supplementary))
puts JSON.pretty_generate({recorded:report[:recorded],total:report[:total],completed_routes:report[:completed_routes],
  route_checks_pass:report[:route_checks_pass],overflows:overflow.size,unmatched_source_fragments:source_missing.size,
  observed_message_pauses:report[:observed_message_pauses],cases:rows.map {|r|r.slice(:case,:status,:gift,:target,:coffee)}})
