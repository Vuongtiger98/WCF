# Targeted event-list patch, not a map generator. Keep all editor placement.
require 'json'
require 'zlib'
eval(File.read(File.join(__dir__,'rvdata2_audit.rb'),encoding:'UTF-8').split(/^module RVData2Audit/).first,TOPLEVEL_BINDING)

module EndingHintPresentation
  module_function
  def command(code,parameters=[])
    result=RPG::EventCommand.new
    result.instance_variable_set(:@code,code)
    result.instance_variable_set(:@indent,0)
    result.instance_variable_set(:@parameters,parameters)
    result
  end
  def code(cmd);cmd.instance_variable_get(:@code);end
  def params(cmd);cmd.instance_variable_get(:@parameters);end
  def ivars_without(object,excluded)
    object.instance_variables.reject{|key|excluded.include?(key)}.to_h{|key|[key,object.instance_variable_get(key)]}
  end
  def spoken_text(list)
    list.select{|cmd|code(cmd)==401}.map{|cmd|params(cmd)[0]}.join.gsub(/\\(?:bm\[\d+\]|cbm)\s?/i,'').gsub(/[[:space:]]/,'')
  end
  def apply(path='Data/Map036.rvdata2')
    map=Marshal.load(File.binread(path))
    original=Marshal.load(Marshal.dump(map))
    router=map.instance_variable_get(:@events).fetch(1)
    pages=router.instance_variable_get(:@pages)
    ids=pages.map{|page|page.instance_variable_get(:@condition).instance_variable_get(:@variable_value)}
    raise 'Unexpected hint routes' unless ids==(1..28).to_a
    count=0
    pages.each_with_index do |page,page_index|
      list=page.instance_variable_get(:@list)
      body=[];title=[];index=0;face=nil;first_line=false
      while index<list.size
        cmd=list[index];kind=code(cmd)
        case kind
        when 355
          block=[cmd];index+=1
          while index<list.size && code(list[index])==655
            block<<list[index];index+=1
          end
          script=block.map{|row|params(row)[0]}.join("\n")
          if script.start_with?('HAIQUY_TITLE.')
            title.concat(block)
          elsif !script.match?(/\A(?:\$game_player\.transparent|\$game_switches\[17\]|\$game_map\.(?:shadows|events\[2\])|char_effect\(2|wcf_ending_hint_)/)
            raise "Unrecognized presentation script on hint #{page_index+1}: #{script}"
          end
          next
        when 117
          raise 'Unexpected common event' unless [3,5].include?(params(cmd)[0])
        when 221,222,230,354,0
          # Replaced by one common fade sequence and the existing Title action.
        when 101
          face=params(cmd)[0]
          raise "Unexpected speaker face #{face}" unless face.empty? || face=='BullyQuy_Thuongphuc_Emote'
          first_line=true;body<<cmd;count+=1
        when 401
          text=params(cmd)[0].gsub(/\\(?:bm\[\d+\]|cbm)\s?/i,'')
          text="\\bm[#{face.empty? ? 0 : 2}] "+text if first_line
          params(cmd)[0]=text
          first_line=false;body<<cmd
        else
          body<<cmd
        end
        index+=1
      end
      prefix=[command(355,['wcf_ending_hint_start']),command(230,[1]),
        command(355,['wcf_ending_hint_reveal']),command(230,[1])]
      suffix=[command(230,[12]),command(355,['wcf_ending_hint_fade_out']),
        command(230,[1]),command(355,['wcf_ending_hint_finish'])]+title+[command(354),command(0)]
      page.instance_variable_set(:@list,prefix+body+suffix)
      previous=original.instance_variable_get(:@events)[1].instance_variable_get(:@pages)[page_index]
      raise 'Authored words changed' unless spoken_text(list)==spoken_text(previous.instance_variable_get(:@list))
      raise 'Faces changed' unless body.select{|cmd|code(cmd)==101}.map{|cmd|params(cmd)}==previous.instance_variable_get(:@list).select{|cmd|code(cmd)==101}.map{|cmd|params(cmd)}
      raise 'Page/editor properties changed' unless Marshal.dump(ivars_without(page,[:@list]))==Marshal.dump(ivars_without(previous,[:@list]))
    end
    note=map.instance_variable_get(:@note).lines.reject{|line|line.match?(/^\[(?:lighting|opacity|color) /)}.join.rstrip
    map.instance_variable_set(:@note,note+"\n[lighting on]\n[opacity 255]\n[color 000000000]\n")
    old_events=original.instance_variable_get(:@events)
    map.instance_variable_get(:@events).each do |id,event|
      if id==1
        raise 'Router placement changed' unless Marshal.dump(ivars_without(event,[:@pages]))==Marshal.dump(ivars_without(old_events[id],[:@pages]))
      else
        raise "Unrelated event changed #{id}" unless Marshal.dump(event)==Marshal.dump(old_events[id])
      end
    end
    raise 'Map layout changed' unless Marshal.dump(ivars_without(map,[:@events,:@note]))==Marshal.dump(ivars_without(original,[:@events,:@note]))
    File.binwrite(path,Marshal.dump(map))
    puts JSON.pretty_generate({hint_pages:pages.size,pop_messages:count,positions_and_pages_preserved:true,authored_words_and_faces_preserved:true})
  end
end
EndingHintPresentation.apply if $PROGRAM_NAME==__FILE__
