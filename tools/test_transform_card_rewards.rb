# encoding: UTF-8
require 'minitest/autorun'
require_relative 'build_transform_animation'
class Game_System
  attr_accessor :menu_disabled
  def initialize;@menu_disabled=false;end
end
module DataManager
  def self.setup_new_game;$game_system=Game_System.new;:setup_done;end
end
module WCFItemLibrary
  class << self;attr_accessor :pictures;end
  self.pictures=[]
  def self.encounter_picture(name);pictures << name unless pictures.include?(name);end
end
module WCFEventNotice
  class << self;attr_accessor :messages;end
  self.messages=[]
  def self.notify(text);messages << text;end
end
module RPG
  class SE
    def initialize(*args);end
    def play;end
  end
end
module Galv_SI
  SCORE_VAR=19;HIGH_SCORE_VAR=20;DSE=['dummy',80,100]
end
class Scene_Invaders;end
module Input;Z=:Z;end
source=File.read(File.join(__dir__,'../Scripts/Transform Form Selection.rb'),encoding:'UTF-8').gsub("\r\n","\n")
eval(source[/^module TransformMagic\n.*?^end/m],TOPLEVEL_BINDING)
eval(source[/^class Game_System\n.*?^end/m],TOPLEVEL_BINDING)
eval(source[/^class << DataManager\n.*?^end/m],TOPLEVEL_BINDING)
bullet=File.read(File.join(__dir__,'../Scripts/BulletHell.rb'),encoding:'UTF-8').gsub("\r\n","\n")
Scene_Invaders.class_eval(bullet.scan(/^  def destroy_enemy\(score\)\n.*?^  end/m).last)
eval(source[/^class Scene_Invaders\n.*?^end/m],TOPLEVEL_BINDING)
module CattoPetting;SCORE_PER_MOVE=1;end
class CattoRewardProbe
  include CattoPetting
  def refresh_score;end
end
catto=File.read(File.join(__dir__,'../Scripts/Catto Petting Minigame.rb'),encoding:'UTF-8').gsub("\r\n","\n")
CattoRewardProbe.class_eval(catto[/^  def update_score_gain\(moved, on_body\)\n.*?^  end/m])
class Scene_Map
  def scene_changing?;false;end
end
module SceneManager
  def self.scene;@scene ||= Scene_Map.new;end
  def self.scene_is?(klass);scene.is_a?(klass);end
end
module Input
  def self.trigger?(key);false;end
end
class RewardPlayer
  attr_accessor :animation_id
  def transfer?;false;end
  def transparent;false;end
  def movable?;true;end
end
class RewardMessage
  def busy?;false;end
  def visible;false;end
end
class RewardTemp
  attr_accessor :tm_state,:reserved,:tm_snapshot,:tm_requested_map
  def common_event_reserved?;!!reserved;end
  def reserve_common_event(id);self.reserved=id;end
end
class RewardParty
  attr_accessor :ram
  def initialize;@ram=0;end
  def item_number(item);ram;end
end
class TransformCardRewardTest < Minitest::Test
  def setup
    $game_system=Game_System.new;$game_switches=Array.new(100,false);$game_variables=Array.new(100,0)
    interpreter=Object.new;def interpreter.running?;false;end
    $game_map=Struct.new(:map_id,:interpreter).new(19,interpreter)
    $game_temp=RewardTemp.new;$game_player=RewardPlayer.new;$game_message=RewardMessage.new
    $game_party=RewardParty.new;$data_items=Array.new(19);$data_items[18]=Object.new
    $data_animations=[]
    WCFItemLibrary.pictures=[];WCFEventNotice.messages=[]
  end
  def test_new_game_unlocks_riu_and_discovers_its_card
    assert_equal :setup_done,DataManager.setup_new_game
    assert_equal [:riu],TransformMagic.unlocked_forms.map(&:id)
    assert_equal ['TFCard1'],WCFItemLibrary.pictures
    assert_empty WCFEventNotice.messages
  end
  def test_event_cast_waits_until_the_interpreter_finishes
    interpreter=$game_map.interpreter
    def interpreter.running?;@busy;end
    interpreter.instance_variable_set(:@busy,true)
    assert TransformMagic.request_cast
    TransformMagic.update_map
    assert_nil TransformMagic.state
    interpreter.instance_variable_set(:@busy,false)
    TransformMagic.update_map
    assert_equal :cast,TransformMagic.phase
    assert_nil $game_temp.tm_requested_map
  end
  def test_invaders_score_threshold_and_original_score_refresh
    scene=Scene_Invaders.new
    score_window=Object.new;def score_window.refresh(*args);:refreshed;end
    scene.instance_variable_set(:@score_window,score_window);scene.instance_variable_set(:@player_shields,10);scene.instance_variable_set(:@bonus_shields,0)
    $game_variables[19]=998
    scene.destroy_enemy(1);refute TransformMagic.unlocked?(:gamemerr)
    assert_equal :refreshed,scene.destroy_enemy(1)
    assert_equal 1000,$game_variables[19]
    assert_equal 1000,$game_variables[20]
    assert TransformMagic.unlocked?(:gamemerr)
    assert_includes WCFItemLibrary.pictures,'TFCard2'
    scene.destroy_enemy(1);assert_equal 1,WCFEventNotice.messages.size
  end
  def test_score_from_another_map_does_not_award_gamemerr
    $game_map.map_id=1
    refute TransformMagic.reward_score(:gamemerr,1000,19)
    refute TransformMagic.unlocked?(:gamemerr)
  end
  def test_catto_awards_at_1000_only_for_real_petting_in_kohi_room
    $game_map.map_id=46
    scene=CattoRewardProbe.new;scene.instance_variable_set(:@score,999)
    refute scene.update_score_gain(false,true)
    refute scene.update_score_gain(true,false)
    refute TransformMagic.unlocked?(:sanic)
    assert scene.update_score_gain(true,true)
    assert TransformMagic.unlocked?(:sanic)
    assert_includes WCFItemLibrary.pictures,'TFCard3'
    scene.update_score_gain(true,true);assert_equal 1,WCFEventNotice.messages.size
  end
  def test_catto_at_the_old_demo_map_does_not_award_sanic
    $game_map.map_id=1
    scene=CattoRewardProbe.new;scene.instance_variable_set(:@score,999)
    scene.update_score_gain(true,true)
    refute TransformMagic.unlocked?(:sanic)
  end
  def test_diana_requires_ten_ram_in_christmas_office_and_only_once
    $game_party.ram=10;refute TransformMagic.diana_ready?
    $game_map.map_id=38;$game_party.ram=9;refute TransformMagic.diana_ready?
    $game_party.ram=10;assert TransformMagic.diana_ready?
    TransformMagic.update_map;assert_equal 21,$game_temp.reserved
    $game_switches[82]=true;refute TransformMagic.diana_ready?
  end
  def test_diana_poll_does_not_replace_another_common_event
    $game_map.map_id=38;$game_party.ram=10;$game_temp.reserved=12
    TransformMagic.update_map
    assert_equal 12,$game_temp.reserved
  end
  def test_collection_remains_known_when_debug_locks_or_new_game_reset_forms
    TransformMagic.unlock(:diana);TransformMagic.lock(:diana)
    refute TransformMagic.unlocked?(:diana)
    assert_includes WCFItemLibrary.pictures,'TFCard4'
    DataManager.setup_new_game
    assert_equal [:riu],TransformMagic.unlocked_forms.map(&:id)
    assert_includes WCFItemLibrary.pictures,'TFCard4'
  end
  def test_ram_encounter_does_not_grant_an_extra_item_and_unlocks_after_dialogue
    events=Marshal.load(File.binread(File.join(__dir__,'../Data/CommonEvents.rvdata2')))
    gain=events[20].instance_variable_get(:@list);scene=events[21].instance_variable_get(:@list)
    code=lambda{|c|c.instance_variable_get(:@code)};params=lambda{|c|c.instance_variable_get(:@parameters)}
    assert_equal 1,gain.count{|c|code.call(c)==126}
    assert gain.any?{|c|code.call(c)==117 && params.call(c)==[21]}
    refute scene.any?{|c|code.call(c)==126}
    unlock=scene.index{|c|code.call(c)==355 && params.call(c)==['TransformMagic.unlock(:diana)']}
    assert unlock
    assert_operator unlock,:>,scene.rindex{|c|code.call(c)==401}
    assert_equal [12,'TransformMagic.diana_ready?'],params.call(scene.find{|c|code.call(c)==111})
  end
end
