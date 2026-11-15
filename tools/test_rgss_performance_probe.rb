# frozen_string_literal: true

# Test the opt-in recorder without loading maps, saves, or the native engine.
require 'minitest/autorun'
require 'tmpdir'
require 'fileutils'

module Graphics
  def self.frame_rate; 60; end
  def self.update(*args)
    yield if block_given?
    [:presented, args]
  end
end
class Game_Map
  attr_accessor :map_id
  def initialize; @map_id=25; end
  def update_events(value=:events)
    yield if block_given?
    value
  end
end
class Scene_Menu
  def update; :menu; end
  private
  def draw_main_panel(value); value; end
end

require_relative 'rgss_performance_probe'
NO_HOOKS_ON_LOAD = !Graphics.respond_to?(:wcf_perf_original_graphics_update) &&
  !Game_Map.method_defined?(:wcf_perf_original_update_events)

class RGSSPerformanceProbeTest < Minitest::Test
  def setup
    @directory=Dir.mktmpdir('wcf-probe-test-')
    @previous_directory=Dir.pwd
    Dir.chdir(@directory)
    $game_map=Game_Map.new
  end

  def teardown
    WCFPerformanceProbe.stop if WCFPerformanceProbe.running?
    Dir.chdir(@previous_directory)
    # Verify the absolute target before recursive cleanup on Windows.
    resolved=File.realpath(@directory)
    unless File.dirname(resolved) == File.realpath(Dir.tmpdir) &&
        File.basename(resolved).start_with?('wcf-probe-test-') &&
        resolved == File.expand_path(@directory)
      raise "Unexpected test cleanup target: #{resolved}"
    end
    FileUtils.remove_entry(resolved)
  end

  def test_loading_has_no_hooks_or_output_until_explicit_start
    assert NO_HOOKS_ON_LOAD
    assert_empty Dir.children('.')
  end

  def test_capture_auto_stops_and_attributes_calls_to_current_map
    assert WCFPerformanceProbe.start(4)
    4.times do |n|
      $game_map.map_id=38 if n >= 2
      assert_equal :events,$game_map.update_events
      assert_equal [:presented,[]],Graphics.update
    end
    refute WCFPerformanceProbe.running?
    path=WCFPerformanceProbe.last_report_path
    assert File.file?(path)
    report=File.read(path)
    assert_match(/frames=4 /,report)
    assert_match(/target_fps=60 /,report)
    assert_match(/^25,events,2,/,report)
    assert_match(/^38,events,2,/,report)
    assert_equal ['Save'],Dir.children('.')
    assert_equal 1,Dir.children('Save').length
  end

  def test_wrappers_preserve_results_blocks_privacy_and_restart_safely
    WCFPerformanceProbe.start(10)
    yielded=0
    assert_equal 123,$game_map.update_events(123) { yielded+=1 }
    assert_equal [:presented,[:argument]],Graphics.update(:argument) { yielded+=1 }
    assert_equal 2,yielded
    assert Scene_Menu.private_method_defined?(:draw_main_panel)
    assert_equal :drawn,Scene_Menu.new.send(:draw_main_panel,:drawn)
    first=WCFPerformanceProbe.stop
    assert File.file?(first)
    WCFPerformanceProbe.start(1)
    $game_map.update_events
    Graphics.update
    second=WCFPerformanceProbe.last_report_path
    refute_equal first,second
    assert_match(/^25,events,1,/,File.read(second))
    before=Dir.children('Save').sort
    assert_equal :unmeasured,$game_map.update_events(:unmeasured)
    Graphics.update
    assert_equal before,Dir.children('Save').sort
  end
end
