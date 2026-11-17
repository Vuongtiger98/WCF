# Verify the exact review scope against the pre-fix backup; read-only.
require_relative 'fix_prologue_dialogue'
require 'zlib'
require 'ripper'
root=ROOT_PROLOGUE
backup=File.join(root,'Data/codex_backup_prologue_20261116')
old=Marshal.load(File.binread(File.join(backup,'Scripts.rvdata2')))
now=Marshal.load(File.binread(File.join(root,'Data/Scripts.rvdata2')))
raise 'Script count changed' unless old.size==now.size
changed=[]
old.zip(now).each do |a,b|
  raise 'Script identity/order changed' unless a[0,2]==b[0,2]
  changed << b[1] if a[2]!=b[2]
end
raise "Unexpected script changes #{changed}" unless changed.sort==['Map effects','Pop Message','Sprite_Character'].sort
raise 'Script CSV changed' unless File.binread(File.join(backup,'!script_order.csv'))==File.binread(File.join(root,'Scripts/!script_order.csv'))
def fields(object,except=[])
  object.instance_variables.sort.reject {|k|except.include?(k)}.to_h {|k|[k,object.instance_variable_get(k)]}
end
def text_words(list)
  list.select {|c|PrologueDialogue.code(c)==401}.map {|c|PrologueDialogue.args(c)[0].sub(PrologueDialogue::TAG,'')}.join(' ')
    .gsub('kỳ nghi vui vẻ','kỳ nghỉ vui vẻ').gsub('Beta-M34','Beta M-34').split
end
events_checked=0
[3,4,6,10,17,69].each do |id|
  path='Map%03d.rvdata2' % id
  before=File.binread(File.join(backup,path)); after=File.binread(File.join(root,'Data',path))
  raise "Unexpected changed map #{id}" if ![3,10].include?(id) && before!=after
  a,b=[before,after].map {|bytes|Marshal.load(bytes)}
  raise "Map geometry changed #{id}" unless Marshal.dump(fields(a,[:@events]))==Marshal.dump(fields(b,[:@events]))
  ae,be=[a,b].map {|m|m.instance_variable_get(:@events)}
  raise "Event IDs changed #{id}" unless ae.keys==be.keys
  ae.each do |eid,event|
    other=be.fetch(eid)
    raise "Event position/name changed #{id}/#{eid}" unless Marshal.dump(fields(event,[:@pages]))==Marshal.dump(fields(other,[:@pages]))
    ap,bp=[event,other].map {|e|e.instance_variable_get(:@pages)}
    raise 'Page count changed' unless ap.size==bp.size
    ap.zip(bp).each_with_index do |(p,q),pi|
      skip=[:@list]
      if id==3 && eid==13 && pi==0
        raise 'Wrong E13 priority' unless q.instance_variable_get(:@priority_type)==1
        skip << :@priority_type
      end
      raise "Page settings changed #{id}/#{eid}/#{pi}" unless Marshal.dump(fields(p,skip))==Marshal.dump(fields(q,skip))
      al,bl=[p,q].map {|v|v.instance_variable_get(:@list)}
      raise "Words changed #{id}/#{eid}" unless text_words(al)==text_words(bl)
      nontext=lambda {|l|Marshal.dump(l.reject {|c|[101,401].include?(PrologueDialogue.code(c))})}
      raise "Non-message commands changed #{id}/#{eid}" unless nontext.call(al)==nontext.call(bl)
      headers=lambda {|l|l.select {|c|PrologueDialogue.code(c)==101}.map {|c|PrologueDialogue.args(c)}.chunk {|h|h}.map(&:first)}
      raise "Face/background/position changed #{id}/#{eid}" unless headers.call(al)==headers.call(bl)
      _,edits=PrologueDialogue.repair(bl)
      raise "Unrepaired dialogue #{id}/#{eid}: #{edits}" unless edits.empty?
      bl.each_with_index do |c,index|
        next unless PrologueDialogue.code(c)==355
        lines=[PrologueDialogue.args(c)[0]]
        cursor=index+1
        while bl[cursor] && PrologueDialogue.code(bl[cursor])==655
          lines << PrologueDialogue.args(bl[cursor])[0]; cursor+=1
        end
        raise "Invalid script #{id}/#{eid}/#{index}" unless Ripper.sexp(lines.join("\n"))
      end
    end
    events_checked+=1
  end
end
puts "PROLOGUE_SCOPE|scripts=#{changed.join(',')}|order_preserved=true|events=#{events_checked}|geometry_graphics_conditions_preserved=true|dialogue_words_preserved=true"
