# frozen_string_literal: true
require 'minitest/autorun'
require 'tmpdir'
require 'fileutils'

module Graphics
  class << self; attr_accessor :frames; end
  self.frames=0
  def self.width;640;end
  def self.height;480;end
  def self.update;self.frames+=1;end
  def self.transition(*);end
end
module Input; def self.update;end;end
Color=Struct.new(:red,:green,:blue,:alpha)
class Bitmap
  attr_accessor :font
  def initialize(*);@font=Struct.new(:name,:size,:bold,:color).new;end
  def clear;end
  def rect;nil;end
  def fill_rect(*);end
  def draw_text(*);end
  def dispose;@disposed=true;end
  def disposed?;!!@disposed;end
end
class Sprite
  attr_accessor :z,:bitmap
  def dispose;@disposed=true;end
  def disposed?;!!@disposed;end
end
class Win32API
  class << self;attr_accessor :arguments,:result;end
  self.result=42
  def initialize(_,name,*);@name=name;end
  def call(*args)
    return 12345 if @name=='GetCurrentProcessId'
    Win32API.arguments=args
    Win32API.result
  end
end
source=File.read(File.join(__dir__,'../Scripts/Main.rb'),encoding:'UTF-8')
eval(source.split(/^rgss_main/).first,TOPLEVEL_BINDING,'Main startup')

class StartupUpdateTest < Minitest::Test
  def setup
    @old_dir=Dir.pwd;@dir=Dir.mktmpdir('wcf-startup-');Dir.chdir(@dir)
    FileUtils.mkdir_p('gameupdate');File.write('gameupdate/Update.ps1','helper');File.write('gameupdate/config.json','{}')
    WCFStartupUpdate.instance_variables.each{|v|WCFStartupUpdate.remove_instance_variable(v)}
    Graphics.frames=0;Win32API.result=42;Win32API.arguments=nil;$BTEST=false
    @env=ENV.delete('WCF_SKIP_STARTUP_CHECK')
    @calls=[]
  end
  def teardown
    ENV.delete('WCF_SKIP_STARTUP_CHECK');ENV['WCF_SKIP_STARTUP_CHECK']=@env if @env
    Dir.chdir(@old_dir);FileUtils.remove_entry(@dir)
  end
  def run_case(status,update: :ready)
    clock=lambda{Time.at(Graphics.frames/60.0)}
    launcher=lambda do |mode|
      @calls << mode
      folder=WCFStartupUpdate.instance_variable_get(:@folder)
      if mode=='Check'
        File.write(folder+'/check.txt',"status=#{status}\nversion=0.2.0-test.1\n") if status
        true
      elsif update==:fail
        false
      else
        File.write(folder+'/ready','1') if update==:ready
        true
      end
    end
    Time.stub(:now,clock){WCFStartupUpdate.stub(:launch,launcher){WCFStartupUpdate.run}}
  end
  def test_up_to_date_and_offline_continue_without_updater
    assert run_case('up-to-date')
    assert_equal ['Check'],@calls
    assert_operator Graphics.frames,:<,10
    WCFStartupUpdate.checked=false;@calls=[]
    assert run_case('offline')
    assert_equal ['Check'],@calls
  end
  def test_available_waits_for_notice_and_ready_then_hands_off_once
    refute run_case('available')
    assert_equal ['Check','Update'],@calls
    assert_operator Graphics.frames,:>=,60
    refute File.exist?(WCFStartupUpdate.instance_variable_get(:@folder)+'/cancel')
  end
  def test_recovery_also_hands_off
    refute run_case('recovery')
    assert_equal ['Check','Update'],@calls
  end
  def test_failed_launch_keeps_game_open
    assert run_case('available',update: :fail)
    assert_equal ['Check','Update'],@calls
  end
  def test_started_process_without_ready_does_not_close_game
    assert run_case('available',update: :no_ready)
    assert_equal ['Check','Update'],@calls
    assert_operator Graphics.frames,:<=,430
    assert File.exist?(WCFStartupUpdate.instance_variable_get(:@folder)+'/cancel')
  end
  def test_no_worker_reply_has_a_bounded_timeout
    assert run_case(nil)
    assert_operator Graphics.frames,:<=,361
    assert_equal ['Check'],@calls
  end
  def test_restart_skip_is_consumed_only_once
    ENV['WCF_SKIP_STARTUP_CHECK']='1'
    assert WCFStartupUpdate.run
    assert_nil ENV['WCF_SKIP_STARTUP_CHECK']
    assert_nil Win32API.arguments
  end
  def test_battle_test_and_missing_updater_do_not_check
    $BTEST=true
    assert WCFStartupUpdate.run
    assert_nil Win32API.arguments
    $BTEST=false;WCFStartupUpdate.checked=false;File.delete('gameupdate/Update.ps1')
    assert WCFStartupUpdate.run
    assert_nil Win32API.arguments
  end
  def test_a_second_call_in_same_process_does_not_recheck
    assert run_case('up-to-date')
    assert WCFStartupUpdate.run
    assert_equal ['Check'],@calls
  end
  def test_shell_execute_uses_hidden_unicode_command_with_fixed_arguments
    WCFStartupUpdate.instance_variable_set(:@session,'12345-123-4')
    WCFStartupUpdate.instance_variable_set(:@pid,12345)
    assert WCFStartupUpdate.launch('Check')
    args=Win32API.arguments
    assert_equal 0,args[-1]
    assert_includes args[3].encode('UTF-8'),'-StartupMode Check -Session 12345-123-4 -ParentId 12345'
    Win32API.result=31
    refute WCFStartupUpdate.launch('Check')
  end
end
