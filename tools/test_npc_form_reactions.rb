# encoding: UTF-8
require 'minitest/autorun'
require_relative 'build_transform_animation'
module Input; Z=:Z; end
RPG::EventCommand.class_eval do
  attr_accessor :code,:indent,:parameters
  def initialize(code=0,indent=0,parameters=[]);@code=code;@indent=indent;@parameters=parameters;end
end
{RPG::Event=>[:id,:name,:pages],RPG::Event::Page=>[:list,:condition,:trigger,:graphic],
 RPG::Event::Page::Condition=>[:switch2_valid,:switch2_id],
 RPG::Event::Page::Graphic=>[:character_name]}.each{|klass,fields|klass.class_eval{attr_accessor(*fields)}}
class Game_System
  attr_accessor :menu_disabled
  def initialize;@menu_disabled=false;end
end
class Game_Temp
  attr_accessor :tm_state,:reserved
  def common_event_reserved?;!!reserved;end
end
class Game_Interpreter
  attr_reader :list
  def setup(list,event_id=0);@list=list;@event_id=event_id;end
end
class Game_Player
  attr_accessor :character_name,:character_index,:transparent,:dispatch
  def transfer?;false;end
  def check_action_event;dispatch.call;end
end
class Game_Event
  attr_reader :id,:list,:character_name
  def initialize(data,map_id)
    @event=data;@id=data.id;@map_id=map_id;@erased=false;apply_page(0)
  end
  def apply_page(index)
    @page=@event.pages.fetch(index);@list=@page.list;@trigger=@page.trigger;@character_name=@page.graphic.character_name
  end
  def conditions_met?(page);true;end
  def trigger_in?(triggers);triggers.include?(@trigger);end
  def empty?;!@list || @list.size<=1;end
end
class Scene_Map
  def scene_changing?;false;end
end
module SceneManager
  class << self;attr_accessor :scene;end
  def self.scene_is?(klass);scene.is_a?(klass);end
end
class ReactionMessage
  attr_accessor :busy,:visible
  def busy?;busy;end
end
source=File.read(File.join(__dir__,'../Scripts/Transform Form Selection.rb'),encoding:'UTF-8').gsub("\r\n","\n")
eval(source[/^module TransformMagic\n.*?^end/m],TOPLEVEL_BINDING)
eval(source[source.index("module NPCFormReaction\n")..-1],TOPLEVEL_BINDING)

class NPCFormReactionsTest < Minitest::Test
  def setup
    $game_temp=Game_Temp.new;$game_system=Game_System.new;$game_player=Game_Player.new
    $game_message=ReactionMessage.new;$game_message.busy=false;$game_message.visible=false
    $game_variables=Array.new(100,0);$game_switches=Array.new(100,false)
    SceneManager.scene=Scene_Map.new
    map(13);form(:riu)
  end
  def map(id)
    data=Marshal.load(File.binread(File.join(__dir__,'../Data/Map%03d.rvdata2'%id)))
    events=data.instance_variable_get(:@events).transform_values{|event|Game_Event.new(event,id)}
    $game_map=Struct.new(:map_id,:events,:interpreter).new(id,events,Game_Interpreter.new)
  end
  def form(id)
    data=TransformMagic.form(id)
    $game_variables[4]=data ? data.value : 0
    $game_player.character_name=data ? data.char_name : '!$HaiQuy'
    $game_player.character_index=0
  end
  def interact(id,commit=true)
    original=$game_map.events.fetch(id).list
    $game_player.dispatch=lambda{$game_map.interpreter.setup(original,id)}
    $game_player.check_action_event
    list=$game_map.interpreter.list
    eval(list[0].parameters[0]) if commit && list[0].code==355 && list[0].parameters[0].start_with?('NPCFormReaction.commit(')
    list
  end
  def words(list);list.select{|c|c.code==401}.map{|c|c.parameters[0].sub(/\\bm\[\d+\]\s*/, '')}.join(' ');end
  def test_four_exact_forms_and_normal_or_stale_sprite_does_not_react
    TransformMagic::FORMS.keys.each{|id|form(id);assert_equal id,NPCFormReaction.current_form.id}
    form(nil);assert_nil NPCFormReaction.current_form
    form(:riu);$game_player.character_name='!$HaiQuy';assert_nil NPCFormReaction.current_form
    assert_same $game_map.events[97].list,interact(97)
  end
  def test_first_special_then_continuous_short_reactions_until_reverted
    original=$game_map.events[97].list;bytes=Marshal.dump(original)
    first=interact(97)
    assert_includes words(first),NPCFormReaction::SPECIAL[:leo][:riu]
    assert_includes words(first),'Ọc ọc ọc!'
    assert_equal NPCFormReaction::SHORT[:leo][:riu],words(interact(97))
    assert_equal NPCFormReaction::SPECIAL[:leo][:riu],words(interact(97))
    form(nil);assert_same original,interact(97)
    assert_equal bytes,Marshal.dump(original)
    assert first.none?{|c|[121,122,123,201].include?(c.code)}
    assert_equal 0,$game_temp.nfr_action_depth
  end
  def test_all_wanderer_approved_lines_are_selected_for_exact_form
    map(38);$game_switches[48]=true
    {3=>:shylvie,4=>:kohi,5=>:leo,6=>:hakase}.each do |id,role|
      $game_map.events[id].apply_page(1)
      TransformMagic::FORMS.keys.each do |key|
        form(key);assert_includes words(interact(id)),NPCFormReaction::SPECIAL[role][key]
      end
    end
  end
  def test_shylvie_exchange_and_bubble_target
    form(:gamemerr);list=interact(98)
    assert_includes words(list),'Bà đang nghi ngờ trình độ của tôi à?'
    assert_includes words(list),'Tôi đang nhớ lại kết quả lần trước.'
    tags=list.select{|c|c.code==401}.map{|c|c.parameters[0][/\\bm\[(\d+)\]/,1]}.compact
    assert_equal ['98','0','98'],tags
  end
  def test_silverwing_anchors_and_approved_special_lines
    map(3);form(:gamemerr)
    assert_includes words(interact(27)),NPCFormReaction::SPECIAL[:alpha][:gamemerr]
    assert_equal 5,$game_map.interpreter.list.find{|c|c.code==213}.parameters[0]
    form(:sanic);assert_includes words(interact(22)),NPCFormReaction::SPECIAL[:beta][:sanic]
    assert_equal 4,$game_map.interpreter.list.find{|c|c.code==213}.parameters[0]
  end
  def test_random_pool_shuffles_without_immediate_local_or_nearby_repeat
    map(19)
    [:riu,:gamemerr,:sanic,:diana].each do |key|
      form(key);last=nil;local={}
      40.times do |i|
        id=i.even? ? 18 : 19;data=NPCFormReaction.profile($game_map.events[id])
        text=NPCFormReaction.pick_common(data,key)
        assert_includes NPCFormReaction::COMMON[key],text
        refute_equal last,text if last
        refute_equal local[id],text if local[id]
        last=text;local[id]=text
      end
    end
  end
  def test_shop_pool_contains_exact_approved_shop_line
    map(19)
    TransformMagic::FORMS.keys.each do |key|
      data=NPCFormReaction.profile($game_map.events[8])
      picks=5.times.map{NPCFormReaction.pick_common(data,key)}
      assert_equal 5,picks.uniq.size
      assert_includes picks,NPCFormReaction::SHOP[key]
    end
  end
  def test_cafe_aliases_share_state_and_never_increment_conversation
    map(58);form(:sanic)
    first=interact(21)
    assert first.any?{|c|c.code==401 && c.parameters[0].include?('\\bm[20]')}
    assert NPCFormReaction.state[:seen][[[58,20],:sanic]]
    refute_same $game_map.events[20].list,interact(20)
    assert_equal 0,$game_variables[84]
    $game_map.events[25].apply_page(1)
    pair=interact(26)
    assert pair.any?{|c|c.code==401 && c.parameters[0].include?('\\bm[26]')}
    refute_same $game_map.events[22].list,interact(22)
    form(nil);assert_same $game_map.events[22].list,interact(22)
  end
  def test_properties_and_quest_transfer_are_never_replaced
    map(19);assert_same $game_map.events[34].list,interact(34)
    map(58);assert_same $game_map.events[2].list,interact(2)
    map(13);$game_map.events[97].apply_page(2);assert_same $game_map.events[97].list,interact(97)
    assert_empty NPCFormReaction.state[:seen]
  end
  def test_no_interception_for_scripts_autorun_child_or_menu_disabled
    original=$game_map.events[97].list
    $game_map.interpreter.setup(original,97);assert_same original,$game_map.interpreter.list
    $game_system.menu_disabled=true;assert_same original,interact(97)
    $game_system.menu_disabled=false;$game_temp.reserved=21;assert_same original,interact(97)
    $game_temp.reserved=nil;$game_message.visible=true;assert_same original,interact(97)
    $game_message.visible=false;$game_temp.nfr_action_depth=1
    child=Game_Interpreter.new;child.setup(original,97);assert_same original,child.list
  end
  def test_diana_empty_event_only_becomes_interactive_after_encounter_in_free_roam
    map(38);form(:diana);event=$game_map.events[18];event.apply_page(1)
    $game_temp.nfr_action_depth=1
    assert event.empty?
    $game_switches[48]=true;$game_switches[82]=true
    refute event.empty?
    assert_includes words(interact(18)),NPCFormReaction::SPECIAL[:diana][:diana]
    form(nil);assert event.empty?
  end
  def test_legacy_riu_page_is_bypassed_and_toilet_anchor_only_is_corrected
    event=$game_map.events[98];page=event.instance_variable_get(:@event).pages[3]
    refute event.conditions_met?(page)
    assert event.conditions_met?(event.instance_variable_get(:@event).pages[1])
    event.apply_page(4);form(nil);before=Marshal.dump(event.list)
    fixed=interact(98)
    assert fixed.any?{|c|c.code==401 && c.parameters[0].include?('\\bm[98]')}
    refute fixed.any?{|c|c.code==401 && c.parameters[0].include?('\\bm[97]')}
    assert_equal before,Marshal.dump(event.list)
    event.apply_page(1);assert_same event.list,interact(98)
  end
  def test_save_roundtrip_and_new_game_state_are_separate
    interact(97);saved=Marshal.load(Marshal.dump($game_system))
    assert saved.npc_form_reactions[:seen][[:leo,:riu]]
    refute saved.npc_form_reactions.key?(:base_next)
    assert_empty Game_System.new.npc_form_reactions[:seen]
  end
  def test_only_manual_map_interpreter_can_react
    original=$game_map.events[97].list
    $game_map.interpreter.setup(original,97)
    assert_same original,$game_map.interpreter.list
    $game_temp.nfr_action_depth=1
    child=Game_Interpreter.new;child.setup(original,97);assert_same original,child.list
    $game_system.menu_disabled=true;assert_same original,interact(97)
    $game_system.menu_disabled=false;$game_temp.reserved=21;assert_same original,interact(97)
    $game_temp.reserved=nil;form(nil);assert_same original,interact(97)
    form(:gamemerr);$game_player.character_name='!$HaiQuy'
    assert_same original,interact(97)
  end
  def test_quest_pages_and_props_are_never_substituted
    $game_map.events[97].apply_page(2)
    assert_same $game_map.events[97].list,interact(97)
    map(19)
    [3,33,34,35,36,44].each{|id|assert_same $game_map.events[id].list,interact(id)}
    map(58);assert_same $game_map.events[2].list,interact(2)
  end
  def test_every_cafe_hitbox_uses_controller_state_and_actual_speaker
    map(58)
    {19=>[18,18],21=>[20,20],22=>[25,25],23=>[25,25],24=>[6,6],26=>[25,25],10=>[8,8],29=>[11,11]}.each do |id,(controller,anchor)|
      data=NPCFormReaction.profile($game_map.events[id])
      assert_equal [58,controller],data[:identity]
      assert_equal anchor,data[:anchor]
    end
    interact(21)
    refute_same $game_map.events[20].list,interact(20)
    $game_map.events[25].apply_page(1)
    assert_equal 26,NPCFormReaction.profile($game_map.events[22])[:anchor]
  end
  def test_every_generated_page_has_at_most_four_valid_lines
    map(38);$game_switches[48]=true
    [3,4,5,6].each do |id|
      $game_map.events[id].apply_page(1)
      TransformMagic::FORMS.keys.each do |key|
        list=NPCFormReaction.reaction_list(NPCFormReaction.profile($game_map.events[id]),key)
        text=[];width=40
        list.each do |entry|
          if entry.code==101
            assert_operator text.size,:<=,4
            text=[];width=entry.parameters[0].empty? ? 40 : 33
          elsif entry.code==401
            line=entry.parameters[0].sub(/\A\\bm\[\d+\] /,'')
            assert_operator NPCFormReaction.letters(line).size,:<=,width
            text<<line
          end
        end
        assert_operator text.size,:<=,4
      end
    end
  end
  def test_action_flag_is_cleared_after_dispatch_failure
    $game_player.dispatch=lambda{raise 'fixture failure'}
    assert_raises(RuntimeError){$game_player.check_action_event}
    refute NPCFormReaction.action?
  end
  def test_wrapping_counts_decomposed_vietnamese_once_and_preserves_words
    text="Mo\u0301n qua\u0300 na\u0300y da\u0300nh cho Ha\u0309i Quy\u0300."
    assert_equal text.unicode_normalize(:nfc).length,NPCFormReaction.letters(text).size
    lines=NPCFormReaction.wrap(text,12)
    assert_equal text,lines.join(' ')
    assert lines.all?{|l|NPCFormReaction.letters(l).size<=12}
    NPCFormReaction::SPECIAL.each_value{|forms|forms.each_value{|t|[33,40].each{|n|ls=NPCFormReaction.wrap(t,n);assert ls.all?{|l|NPCFormReaction.letters(l).size<=n};assert_equal t,ls.join(' ')}}}
  end
  def test_every_form_continues_random_reactions_and_normal_returns_only_after_revert
    map(19);original=$game_map.events[18].list;before=Marshal.dump(original)
    TransformMagic::FORMS.keys.each do |id|
      form(id);last=nil
      10.times do
        list=interact(18)
        refute_same original,list
        text=words(list)
        assert_includes NPCFormReaction::COMMON[id],text
        refute_equal last,text if last
        assert_equal TransformMagic.form(id).value,$game_variables[4]
        last=text
      end
      form(nil);assert_same original,interact(18)
    end
    assert_equal before,Marshal.dump(original)
  end
  def test_old_saved_alternation_flag_is_discarded_without_losing_history
    interact(97)
    legacy=Marshal.load(Marshal.dump($game_system))
    legacy.instance_variable_get(:@npc_form_reactions)[:base_next]={[:leo,:riu]=>true}
    $game_system=legacy
    assert_equal NPCFormReaction::SHORT[:leo][:riu],words(interact(97))
    assert $game_system.npc_form_reactions[:seen][[:leo,:riu]]
    refute $game_system.npc_form_reactions.key?(:base_next)
    map(58);form(:sanic)
    first=words(interact(21));second=words(interact(20))
    refute_equal first,second
    assert_equal 0,$game_variables[82]
    form(nil);assert_same $game_map.events[21].list,interact(21)
  end
end
