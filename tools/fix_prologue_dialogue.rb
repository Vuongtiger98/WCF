# frozen_string_literal: true
# Mechanical line/page repair only. Preserve words, faces, other commands,
# editor-authored positions, page conditions, graphics and map tile data.
require 'json'
require 'digest'
ROOT_PROLOGUE=File.expand_path('..',__dir__)
eval(File.read(File.join(ROOT_PROLOGUE,'tools/rvdata2_audit.rb')).split('module RVData2Audit',2).first)
module PrologueDialogue
  TAG=/\A\s*(\\(?:bm\[\d+\]|cbm|cbt\[[^\]]*\]))\s*/i
  def self.code(c); c.instance_variable_get(:@code); end
  def self.args(c); c.instance_variable_get(:@parameters); end
  def self.block(list,start)
    finish=start+1
    lines=[]
    while list[finish] && code(list[finish])==401
      lines << args(list[finish])[0]
      finish+=1
    end
    tag=lines.join("\n")[TAG,1].to_s
    text=lines.join("\n").sub(TAG,'').gsub(/\s+/,' ').strip
    {start:start,finish:finish,header:args(list[start]),lines:lines,tag:tag,text:text}
  end
  def self.wrap(text,limit)
    lines=['']
    text.split.each do |word|
      trial=lines[-1].empty? ? word : lines[-1]+' '+word
      if trial.scan(/\X/).size>limit && !lines[-1].empty?
        lines << word
      else
        lines[-1]=trial
      end
    end
    lines
  end
  def self.command(template,code,parameters)
    c=Marshal.load(Marshal.dump(template))
    c.instance_variable_set(:@code,code)
    c.instance_variable_set(:@parameters,parameters)
    c
  end
  def self.repair(list)
    out=[]
    edits=[]
    i=0
    while i<list.size
      if code(list[i])!=101
        out << list[i]; i+=1; next
      end
      group=[block(list,i)]
      cursor=group[-1][:finish]
      while list[cursor] && code(list[cursor])==101
        candidate=block(list,cursor)
        break unless candidate[:header]==group[0][:header] && candidate[:tag].downcase==group[0][:tag].downcase
        group << candidate
        cursor=candidate[:finish]
      end
      limit=group[0][:header][0].to_s.empty? ? 40 : 33
      orphan=group.each_cons(2).any? { |a,b| a[:lines].size>=4 && b[:lines].size==1 && !a[:text].match?(/[.!?…:]\z/) }
      overflow=group.any? { |b| b[:lines].size>4 || b[:lines].each_with_index.any? { |l,j| (j==0 ? l.sub(TAG,'') : l).rstrip.scan(/\X/).size>limit } }
      if orphan || overflow
        text=group.map { |b|b[:text] }.join(' ')
        lines=wrap(text,limit)
        boxes=(lines.size+3)/4
        # Balance pages: avoid another 4+1-line split after the repair.
        base,extra=lines.size.divmod(boxes)
        offset=0
        boxes.times do |n|
          page=lines[offset,base+(n<extra ? 1 : 0)].dup
          offset+=page.size
          page[0]=group[0][:tag]+' '+page[0] unless group[0][:tag].empty?
          out << command(list[i],101,group[0][:header].dup)
          page.each { |line| out << command(list[i+1],401,[line]) }
        end
        edits << {command:i,old_boxes:group.size,new_boxes:boxes,reason:orphan ? 'orphan page' : 'line limit'}
      else
        out.concat(list[i...cursor])
      end
      i=cursor
    end
    before=list.select { |c|code(c)==401 }.map { |c|args(c)[0].sub(TAG,'') }.join(' ').split
    after=out.select { |c|code(c)==401 }.map { |c|args(c)[0].sub(TAG,'') }.join(' ').split
    raise 'Dialogue words changed' unless before==after
    nontext=lambda { |rows| Marshal.dump(rows.reject { |c|[101,401].include?(code(c)) }) }
    raise 'Non-message commands changed' unless nontext.call(list)==nontext.call(out)
    [out,edits]
  end
end
if $PROGRAM_NAME==__FILE__
  apply=ARGV.delete('--apply')
  ids=ARGV.empty? ? [3,4,17,6,10] : ARGV.map(&:to_i)
  result=[]
  ids.each do |id|
    path=File.join(ROOT_PROLOGUE,'Data/Map%03d.rvdata2' % id)
    map=Marshal.load(File.binread(path))
    before_map=Marshal.dump(map)
    events=map.instance_variable_get(:@events)
    geometry=events.transform_values { |e| [e.instance_variable_get(:@x),e.instance_variable_get(:@y),e.instance_variable_get(:@pages).map {|p|[p.instance_variable_get(:@graphic),p.instance_variable_get(:@condition),p.instance_variable_get(:@move_route),p.instance_variable_get(:@walk_anime),p.instance_variable_get(:@step_anime)]}] }
    before_geometry=Marshal.dump(geometry)
    events.each do |eid,event|
      event.instance_variable_get(:@pages).each_with_index do |page,p|
        # E13 is on the impassable wall, unlike a floor interaction. Match its
        # adjacent noticeboards so it can be read from the tile in front.
        if id==3 && eid==13 && page.instance_variable_get(:@priority_type)==0
          page.instance_variable_set(:@priority_type,1)
          result << {map:id,event:eid,page:p+1,priority:'same as player'}
        end
        list=page.instance_variable_get(:@list)
        changed,edits=PrologueDialogue.repair(list)
        if id==3
          changed.each do |c|
            next unless PrologueDialogue.code(c)==401
            text=PrologueDialogue.args(c)[0]
            text=text.gsub('kỳ nghi vui vẻ','kỳ nghỉ vui vẻ').gsub('Beta-M34','Beta M-34')
            c.instance_variable_set(:@parameters,[text])
          end
        end
        page.instance_variable_set(:@list,changed)
        result << {map:id,event:eid,page:p+1,edits:edits} unless edits.empty?
      end
    end
    raise 'Event geometry/graphics/conditions/animation changed' unless before_geometry==Marshal.dump(geometry)
    after_map=Marshal.dump(map)
    File.binwrite(path,after_map) if apply && after_map!=before_map
  end
  puts JSON.pretty_generate({applied:!!apply,changes:result})
end
