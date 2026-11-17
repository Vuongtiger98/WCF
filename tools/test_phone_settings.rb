# frozen_string_literal: true
# Reuse the RGSS drawing/input stubs and the Save/Load regressions.
require_relative 'test_phone_save_load'

module Input
  def self.press?(key); trigger?(key); end
end
module RPG
  class SettingsTrack
    attr_reader :name,:plays,:pos,:last_play_pos
    def initialize; @name='test-track'; @plays=0; @pos=12345; end
    def play(pos); @plays+=1; @last_play_pos=pos; end
  end
  class BGM
    def self.last; @last ||= SettingsTrack.new; end
  end
  class BGS
    def self.last; @last ||= SettingsTrack.new; end
  end
end

class SettingsSystemFixture
  attr_reader :changes
  def initialize
    @volumes={bgm:100,bgs:100,sfx:100}
    @autodash=true
    @instantmsg=false
    @changes=[]
  end
  def volume(key); @volumes.fetch(key); end
  def volume_change(key,delta)
    @changes << [key,delta]
    @volumes[key]=[[@volumes.fetch(key)+delta,0].max,100].min
  end
  def autodash?; @autodash; end
  def instantmsg?; @instantmsg; end
  def set_autodash(value); @autodash=value; end
  def set_instantmsg(value); @instantmsg=value; end
end
class SettingsSceneFixture < Scene_System
  attr_reader :returned,:title_calls,:shutdown_calls
  def return_scene; @returned=true; end
  def command_to_title; @title_calls=(@title_calls||0)+1; end
  def command_shutdown; @shutdown_calls=(@shutdown_calls||0)+1; end
end

class PhoneSettingsTest < Minitest::Test
  def setup
    $game_system=SettingsSystemFixture.new
    Input.press
    @scene=SettingsSceneFixture.new
    @scene.wcf_phone_origin=:phone
    @scene.create_background
    @scene.wsp_create_settings
  end
  def teardown
    @scene.dispose_background
    Input.press
  end
  def press(*keys)
    Input.press(*keys)
    @scene.wsp_update_input
  ensure
    Input.press
  end
  def select(key)
    index=Scene_System::WSP_ROWS.index { |row| row[0]==key }
    @scene.wsp_move(index-@scene.instance_variable_get(:@wsp_index))
  end
  def bitmap; @scene.instance_variable_get(:@wsp_panel).bitmap; end
  def text; bitmap.draws.map { |row| row[4] }.join(' '); end

  def test_existing_settings_have_clear_values_and_reachable_exit_actions
    assert_equal [:bgm,:bgs,:sfx,:autodash,:instantmsg,:to_title,:shutdown,:back],Scene_System::WSP_ROWS.map(&:first)
    assert_includes text,'100%'
    assert_includes text,'Bật'
    assert_includes text,'Từng ký tự'
    select(:back)
    assert_equal 3,@scene.instance_variable_get(:@wsp_top)
    assert_includes text,'Quay lại'
    press(:C)
    assert @scene.returned
    assert_nil @scene.title_calls
    assert_nil @scene.shutdown_calls
  end
  def test_volume_changes_use_yanfly_api_shift_and_retain_track_position
    before=RPG::BGM.last.plays
    press(:LEFT)
    assert_equal [:bgm,-1],$game_system.changes.last
    assert_equal 99,$game_system.volume(:bgm)
    assert_equal before+1,RPG::BGM.last.plays
    assert_equal RPG::BGM.last.pos,RPG::BGM.last.last_play_pos
    press(:LEFT,:A)
    assert_equal [:bgm,-10],$game_system.changes.last
    assert_equal 89,$game_system.volume(:bgm)
    select(:bgs)
    before=RPG::BGS.last.plays
    press(:LEFT)
    assert_equal 99,$game_system.volume(:bgs)
    assert_equal before+1,RPG::BGS.last.plays
    assert_equal RPG::BGS.last.pos,RPG::BGS.last.last_play_pos
    select(:sfx)
    press(:LEFT)
    assert_equal 99,$game_system.volume(:sfx)
  end
  def test_volume_boundaries_do_not_replay_or_redraw_when_value_is_unchanged
    count=bitmap.clears
    plays=RPG::BGM.last.plays
    press(:RIGHT)
    assert_equal 100,$game_system.volume(:bgm)
    assert_equal count,bitmap.clears
    assert_equal plays,RPG::BGM.last.plays
    $game_system.volume_change(:bgm,-100)
    @scene.wsp_redraw
    count=bitmap.clears
    press(:LEFT)
    assert_equal 0,$game_system.volume(:bgm)
    assert_equal count,bitmap.clears
  end
  def test_toggles_accept_left_right_and_z_without_touching_other_options
    select(:autodash)
    press(:LEFT)
    refute $game_system.autodash?
    press(:RIGHT)
    assert $game_system.autodash?
    press(:C)
    refute $game_system.autodash?
    select(:instantmsg)
    assert_includes text,'Hiện dần từng ký tự.'
    press(:C)
    assert $game_system.instantmsg?
    assert_includes text,'Hiện cả câu ngay lập tức.'
    refute $game_system.autodash?
    assert_equal 100,$game_system.volume(:bgm)
  end
  def test_exit_confirmation_ignores_arrows_and_prioritizes_x_over_z
    [:to_title,:shutdown].each do |key|
      select(key)
      press(:C)
      assert_equal key,@scene.instance_variable_get(:@wsp_pending)
      assert_nil @scene.title_calls
      assert_nil @scene.shutdown_calls
      assert_includes text,'HƯỚNG DẪN PHÍM'
      assert_includes text,'Nhấn X để hủy'
      refute_match(/[↑↓←→]|\([ZX]\)/,text)
      previous=text
      press(:DOWN)
      assert_equal previous,text
      press(:B,:C)
      assert_nil @scene.instance_variable_get(:@wsp_pending)
      assert_nil @scene.title_calls
      assert_nil @scene.shutdown_calls
      assert_equal key,Scene_System::WSP_ROWS[@scene.instance_variable_get(:@wsp_index)][0]
    end
  end
  def test_fresh_z_confirms_each_exit_through_existing_handlers
    select(:to_title)
    press(:C)
    assert_nil @scene.title_calls
    press(:C)
    assert_equal 1,@scene.title_calls
    @scene.instance_variable_set(:@wsp_pending,nil)
    select(:shutdown)
    press(:C)
    assert_nil @scene.shutdown_calls
    press(:C)
    assert_equal 1,@scene.shutdown_calls
  end
  def test_portrait_layout_stays_in_frame_on_every_row_and_confirmation
    Scene_System::WSP_ROWS.each do |row|
      select(row[0])
      check_bounds
    end
    [:to_title,:shutdown].each do |key|
      select(key)
      press(:C)
      check_bounds
      press(:B)
    end
  end
  def check_bounds
    bitmap.draws.each do |x,y,width,height,value,align,measured|
      assert_operator x,:>=,24
      assert_operator y,:>=,24
      assert_operator x+width,:<=,PhoneMenu::PHONE_WIDTH-16
      assert_operator y+height,:<=,PhoneMenu::PHONE_HEIGHT-16
      assert_operator measured,:<=,width
    end
  end
  def test_idle_does_not_redraw_and_cleanup_keeps_cached_art
    count=bitmap.clears
    600.times { @scene.wsp_update_input }
    assert_equal count,bitmap.clears
    assert_equal 0,@scene.transition_speed
    surfaces=@scene.instance_variable_get(:@wsp_owned).dup
    @scene.dispose_background
    assert surfaces.all? { |sprite| sprite.disposed? && sprite.bitmap.disposed? }
    refute Cache.load_bitmap('Graphics/PhoneMenu/',PhoneMenu::BACKGROUND).disposed?
    refute SceneManager.background_bitmap.disposed?
  end
end
