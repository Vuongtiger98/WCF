# frozen_string_literal: true

require "digest"
require "fileutils"
require "zlib"

# Minimal RGSS3 data classes needed by Ruby Marshal outside RPG Maker.
module RPG
  class Map; end
  class MapInfo; end
  class System; end
  class System::Vehicle; end
  class System::TestBattler; end
  class System::Terms; end
  class EventCommand; end
  class MoveRoute; end
  class MoveCommand; end
  class AudioFile; end
  class BGM; end
  class BGS; end
  class ME; end
  class SE; end
  class Event; end
  class CommonEvent; end
  class Event::Page; end
  class Event::Page::Condition; end
  class Event::Page::Graphic; end
end

class Table
  def self._load(data)
    object = allocate
    object.instance_variable_set(:@marshal_data, data)
    object
  end

  def _dump(_depth = -1)
    @marshal_data
  end
end

class Color
  def self._load(data)
    object = allocate
    object.instance_variable_set(:@marshal_data, data)
    object
  end

  def _dump(_depth = -1)
    @marshal_data
  end
end

class Tone
  def self._load(data)
    object = allocate
    object.instance_variable_set(:@marshal_data, data)
    object
  end

  def _dump(_depth = -1)
    @marshal_data
  end
end

module RVData2Audit
  INVALID_FILENAME_CHARS = {
    "\\" => "&", "/" => "&", ":" => ";", "*" => "°", "?" => "!",
    "<" => "«", ">" => "»", "|" => "¦", '"' => "'"
  }.freeze

  module_function

  def load_data(path)
    Marshal.load(File.binread(path))
  end

  def save_data(path, object)
    File.binwrite(path, Marshal.dump(object))
  end

  def script_filename(name)
    name.each_char.map { |char| INVALID_FILENAME_CHARS.fetch(char, char) }.join + ".rb"
  end

  def compare_scripts
    scripts = load_data("Data/Scripts.rvdata2")
    order = File.readlines("Scripts/!script_order.csv", chomp: true, encoding: "UTF-8")
    missing = []
    mismatches = []
    matches = []

    scripts.drop(1).each_with_index do |entry, offset|
      index = offset + 1
      order_name = order[offset]&.sub(/~blank\z/, "")
      code = Zlib::Inflate.inflate(entry[2])
      next if code.empty?

      filename = script_filename(order_name || entry[1])
      path = File.join("Scripts", filename)
      unless File.file?(path)
        missing << [index, entry[1], filename]
        next
      end

      exported = File.binread(path)
      record = {
        index: index,
        data_name: entry[1],
        order_name: order_name,
        file: filename,
        data_bytes: code.bytesize,
        file_bytes: exported.bytesize,
        data_sha256: Digest::SHA256.hexdigest(code),
        file_sha256: Digest::SHA256.hexdigest(exported)
      }
      if code == exported
        matches << record
      else
        record[:normalized_line_endings_match] =
          code.gsub(/\r\n?/, "\n") == exported.gsub(/\r\n?/, "\n")
        mismatches << record
      end
    end

    puts "Data slots: #{scripts.size}"
    puts "CSV entries: #{order.size}"
    puts "Exact matches: #{matches.size}"
    puts "Missing exports: #{missing.size}"
    puts "Content mismatches: #{mismatches.size}"
    missing.each { |record| puts "MISSING|#{record.join('|')}" }
    mismatches.each do |record|
      puts "MISMATCH|#{record.values.join('|')}"
    end
  end

  def diff_script(index)
    scripts = load_data("Data/Scripts.rvdata2")
    order = File.readlines("Scripts/!script_order.csv", chomp: true, encoding: "UTF-8")
    entry = scripts.fetch(index)
    name = order.fetch(index - 1).sub(/~blank\z/, "")
    path = File.join("Scripts", script_filename(name))
    data_lines = Zlib::Inflate.inflate(entry[2]).lines
    file_lines = File.binread(path).lines
    max = [data_lines.size, file_lines.size].max
    puts "SCRIPT|#{index}|#{entry[1]}|#{path}"
    differences = 0
    max.times do |line_index|
      next if data_lines[line_index] == file_lines[line_index]

      differences += 1
      puts "LINE|#{line_index + 1}|DATA=#{data_lines[line_index].inspect}|FILE=#{file_lines[line_index].inspect}"
      break if differences >= 20
    end
    puts "DIFFERING_LINES_SHOWN|#{differences}"
  end

  def command_code(command)
    command.instance_variable_get(:@code)
  end

  def command_parameters(command)
    command.instance_variable_get(:@parameters) || []
  end

  def dump_map(map_id)
    path = format("Data/Map%03d.rvdata2", map_id)
    map = load_data(path)
    events = map.instance_variable_get(:@events) || {}
    puts "MAP|#{map_id}|#{map.instance_variable_get(:@display_name)}|" \
         "#{map.instance_variable_get(:@width)}x#{map.instance_variable_get(:@height)}|" \
         "events=#{events.size}"

    events.keys.sort.each do |event_id|
      event = events[event_id]
      puts "EVENT|#{event_id}|#{event.instance_variable_get(:@name)}|" \
           "#{event.instance_variable_get(:@x)},#{event.instance_variable_get(:@y)}"
      (event.instance_variable_get(:@pages) || []).each_with_index do |page, page_index|
        condition = page.instance_variable_get(:@condition)
        puts "PAGE|#{page_index + 1}|trigger=#{page.instance_variable_get(:@trigger)}|" \
             "priority=#{page.instance_variable_get(:@priority_type)}|" \
             "condition=#{condition.inspect}"
        (page.instance_variable_get(:@list) || []).each do |command|
          code = command_code(command)
          parameters = command_parameters(command)
          next unless [101, 102, 108, 121, 122, 123, 201, 205, 355, 401, 402, 403, 404, 408, 655].include?(code)

          puts "CMD|#{code}|#{parameters.inspect}"
          if code == 205 && parameters[1]
            route = parameters[1]
            (route.instance_variable_get(:@list) || []).each do |move_command|
              puts "MOVE|#{move_command.instance_variable_get(:@code)}|" \
                   "#{(move_command.instance_variable_get(:@parameters) || []).inspect}"
            end
          end
        end
      end
    end
  end

  def event_command(code, indent, parameters)
    command = RPG::EventCommand.new
    command.instance_variable_set(:@code, code)
    command.instance_variable_set(:@indent, indent)
    command.instance_variable_set(:@parameters, parameters)
    command
  end

  def make_choice_commands
    [
      event_command(101, 0, ["", 0, 0, 2]),
      event_command(401, 0, ["Hello World! Choose a greeting."]),
      event_command(102, 0, [["Hello", "Goodbye"], 0]),
      event_command(402, 0, [0, "Hello"]),
      event_command(101, 1, ["", 0, 0, 2]),
      event_command(401, 1, ["Hello World!"]),
      event_command(402, 0, [1, "Goodbye"]),
      event_command(101, 1, ["", 0, 0, 2]),
      event_command(401, 1, ["Goodbye World!"]),
      event_command(404, 0, []),
      event_command(0, 0, [])
    ]
  end

  def make_plain_commands
    [
      event_command(101, 0, ["", 0, 0, 2]),
      event_command(401, 0, ["Hello from Map021!"]),
      event_command(0, 0, [])
    ]
  end

  def clone_event(template, id, name, x, y, commands)
    event = Marshal.load(Marshal.dump(template))
    event.instance_variable_set(:@id, id)
    event.instance_variable_set(:@name, name)
    event.instance_variable_set(:@x, x)
    event.instance_variable_set(:@y, y)
    pages = event.instance_variable_get(:@pages)
    page = pages.first
    page.instance_variable_set(:@list, commands)
    page.instance_variable_set(:@trigger, 0)
    page.instance_variable_set(:@priority_type, 1)
    condition = page.instance_variable_get(:@condition)
    condition.instance_variables.each do |variable|
      value = condition.instance_variable_get(variable)
      condition.instance_variable_set(variable, false) if value == true || value == false
    end
    event.instance_variable_set(:@pages, [page])
    event
  end

  def create_map_021
    map_path = "Data/Map021.rvdata2"
    infos_path = "Data/MapInfos.rvdata2"
    backup_dir = "Data/codex_backup_map021"
    FileUtils.mkdir_p(backup_dir)

    FileUtils.cp(map_path, File.join(backup_dir, "Map021.rvdata2")) if File.exist?(map_path)
    FileUtils.cp(infos_path, File.join(backup_dir, "MapInfos.rvdata2"), preserve: true)

    base_map = load_data("Data/Map004.rvdata2")
    template_event = (base_map.instance_variable_get(:@events) || {}).values.first
    raise "Map004 has no template event" unless template_event

    base_map.instance_variable_set(:@display_name, "Codex RVData2 Test")
    base_map.instance_variable_set(:@note, "Generated test map: choice and Hello World events")
    base_map.instance_variable_set(:@events, {
      1 => clone_event(template_event, 1, "CODEX_CHOICE_HELLO_WORLD", 8, 6, make_choice_commands),
      2 => clone_event(template_event, 2, "CODEX_PLAIN_HELLO", 10, 6, make_plain_commands)
    })
    save_data(map_path, base_map)

    infos = load_data(infos_path)
    template_info = infos[4] || infos.values.first
    map_info = Marshal.load(Marshal.dump(template_info))
    map_info.instance_variable_set(:@name, "Codex Test - Hello World")
    map_info.instance_variable_set(:@parent_id, 0)
    max_order = infos.values.map { |info| info.instance_variable_get(:@order).to_i }.max
    map_info.instance_variable_set(:@order, max_order + 1)
    map_info.instance_variable_set(:@expanded, true)
    map_info.instance_variable_set(:@scroll_x, 0)
    map_info.instance_variable_set(:@scroll_y, 0)
    infos[21] = map_info
    save_data(infos_path, infos)

    # Round-trip verification.
    verified_map = load_data(map_path)
    verified_infos = load_data(infos_path)
    events = verified_map.instance_variable_get(:@events) || {}
    raise "Map021 verification failed" unless events.size == 2 && verified_infos.key?(21)

    puts "CREATED|#{map_path}|events=#{events.size}|bytes=#{File.size(map_path)}"
    puts "UPDATED|#{infos_path}|map021=#{verified_infos[21].instance_variable_get(:@name)}"
    puts "BACKUP|#{backup_dir}"
  end

  def create_atlantis_gate_map_021
    map_path = "Data/Map021.rvdata2"
    infos_path = "Data/MapInfos.rvdata2"
    base_map = load_data("Data/Map004.rvdata2")
    template_event = (base_map.instance_variable_get(:@events) || {}).values.first
    raise "Map004 has no template event" unless template_event
    base_map.instance_variable_set(:@display_name, "Điểm xuống Atlantis")
    base_map.instance_variable_set(:@note, "Atlantis route gate — Switch 30-33, Variable 30")
    commands = [
      event_command(101, 0, ["", 0, 0, 2]),
      event_command(401, 0, ["Hải Quỳ đứng trước lối xuống Atlantis."]),
      event_command(101, 0, ["", 0, 0, 2]),
      event_command(401, 0, ["Có lẽ mình nên xuống đó để tìm sách phép."]),
      event_command(121, 0, [30, 30, 0]),
      event_command(122, 0, [30, 30, 0, 0, 1]),
      event_command(101, 0, ["", 0, 0, 2]),
      event_command(401, 0, ["Route Atlantis đã được ghi nhận. Khu vực Atlantis sẽ được dựng tiếp."]),
      event_command(123, 0, ["A", 0])
    ]
    base_map.instance_variable_set(:@events, {
      1 => clone_event(template_event, 1, "SCN-ATLANTIS-001 ROUTE GATE [E001]", 4, 4, commands)
    })
    save_data(map_path, base_map)
    infos = load_data(infos_path)
    template_info = infos[4] || infos.values.first
    map_info = Marshal.load(Marshal.dump(template_info))
    map_info.instance_variable_set(:@name, "Điểm xuống Atlantis")
    map_info.instance_variable_set(:@parent_id, 0)
    map_info.instance_variable_set(:@order, infos.values.map { |i| i.instance_variable_get(:@order).to_i }.max + 1)
    map_info.instance_variable_set(:@expanded, true)
    map_info.instance_variable_set(:@scroll_x, 0)
    map_info.instance_variable_set(:@scroll_y, 0)
    infos[21] = map_info
    save_data(infos_path, infos)
    puts "ATLANTIS_GATE|map=21|switch=30|variable=30"
  end

  def add_atlantis_choice_map010
    path = "Data/Map010.rvdata2"
    map = load_data(path)
    event = (map.instance_variable_get(:@events) || {})[2]
    page = (event.instance_variable_get(:@pages) || []).first
    list = page.instance_variable_get(:@list) || []
    choice = list.find { |c| c.instance_variable_get(:@code) == 102 }
    raise "Map010 choice not found" unless choice
    params = choice.instance_variable_get(:@parameters)
    options = params[0]
    unless options.any? { |o| o.to_s == "Xuống Atlantis" }
      options << "Xuống Atlantis"
      choice.instance_variable_set(:@parameters, params)
    end
    unless list.any? { |c| (c.instance_variable_get(:@parameters) || [])[1].to_s == "Xuống Atlantis" }
      end_index = list.index { |c| c.instance_variable_get(:@code) == 404 }
      branch = [
        event_command(402, 0, [2, "Xuống Atlantis"]),
        event_command(101, 0, ["", 0, 0, 2]),
        event_command(401, 0, ["Mình muốn xuống Atlantis tìm sách phép."]),
        event_command(201, 0, [0, 21, 4, 4, 0, 0])
      ]
      list.insert(end_index, *branch)
    end
    page.instance_variable_set(:@list, list)
    save_data(path, map)
    puts "MAP010_ATLANTIS_CHOICE|added=true|destination=Map021(4,4)"
  end

  def name_atlantis_flags
    system = load_data("Data/System.rvdata2")
    switches = system.instance_variable_get(:@switches) || []
    variables = system.instance_variable_get(:@variables) || []
    switches[30] = "ATL Route Chosen"
    switches[31] = "ATL Arrived"
    switches[32] = "ATL Met Owner"
    switches[33] = "ATL Ending Ready"
    variables[30] = "ATL Progress"
    system.instance_variable_set(:@switches, switches)
    system.instance_variable_set(:@variables, variables)
    save_data("Data/System.rvdata2", system)
    puts "ATLANTIS_FLAGS|switches=30..33|variable=30"
  end

  def audit_map_state
    uses = Hash.new { |hash, key| hash[key] = [] }
    Dir.glob("Data/Map[0-9][0-9][0-9].rvdata2").sort.each do |path|
      map_id = File.basename(path)[/\d+/].to_i
      map = load_data(path)
      (map.instance_variable_get(:@events) || {}).each do |event_id, event|
        (event.instance_variable_get(:@pages) || []).each_with_index do |page, page_index|
          condition = page.instance_variable_get(:@condition)
          if condition
            uses[[:switch, condition.instance_variable_get(:@switch1_id)]] << [map_id, event_id, page_index + 1, "page condition"] if condition.instance_variable_get(:@switch1_valid)
            uses[[:switch, condition.instance_variable_get(:@switch2_id)]] << [map_id, event_id, page_index + 1, "page condition"] if condition.instance_variable_get(:@switch2_valid)
            uses[[:variable, condition.instance_variable_get(:@variable_id)]] << [map_id, event_id, page_index + 1, "page condition"] if condition.instance_variable_get(:@variable_valid)
          end
          (page.instance_variable_get(:@list) || []).each do |cmd|
            code = cmd.instance_variable_get(:@code)
            params = cmd.instance_variable_get(:@parameters) || []
            case code
            when 111
              uses[[:switch, params[1]]] << [map_id, event_id, page_index + 1, "conditional branch"] if params[0] == 0
              uses[[:variable, params[1]]] << [map_id, event_id, page_index + 1, "conditional branch"] if params[0] == 1
            when 121
              (params[0]..params[1]).each { |id| uses[[:switch, id]] << [map_id, event_id, page_index + 1, "control switch"] }
            when 122
              (params[0]..params[1]).each { |id| uses[[:variable, id]] << [map_id, event_id, page_index + 1, "control variable"] }
            end
          end
        end
      end
    end
    uses.sort_by { |(kind, id), _| [kind.to_s, id] }.each do |(kind, id), locations|
      detail = locations.map { |loc| "M%03d/E%d/P%d:%s" % loc }.uniq.join(",")
      puts "#{kind.to_s.upcase}|#{id}|#{detail}"
    end
  end

  def replace_runtime_script(name, source_path)
    scripts = load_data("Data/Scripts.rvdata2")
    index = scripts.index { |entry| entry[1].to_s.strip == name.strip }
    raise "Runtime script not found: #{name}" unless index
    source = File.binread(source_path)
    scripts[index][2] = Zlib::Deflate.deflate(source)
    save_data("Data/Scripts.rvdata2", scripts)
    verified = load_data("Data/Scripts.rvdata2")
    actual = Zlib::Inflate.inflate(verified[index][2])
    raise "Runtime script verification failed" unless actual == source
    puts "REPLACED|#{index}|#{scripts[index][1]}|bytes=#{source.bytesize}"
  end

  def dump_common_events
    events = load_data("Data/CommonEvents.rvdata2")
    events.each do |event|
      next unless event
      id = event.instance_variable_get(:@id)
      name = event.instance_variable_get(:@name)
      trigger = event.instance_variable_get(:@trigger)
      switch_id = event.instance_variable_get(:@switch_id)
      list = event.instance_variable_get(:@list) || []
      puts "COMMON|#{id}|#{name}|trigger=#{trigger}|switch=#{switch_id}|commands=#{list.size}"
      list.each do |command|
        code = command.instance_variable_get(:@code)
        params = command.instance_variable_get(:@parameters) || []
        puts "CMD|#{code}|#{params.inspect}" if [355, 655, 102, 111, 121, 122, 123, 201, 205].include?(code)
      end
    end
  end

  def event_command(code, indent, parameters)
    command = RPG::EventCommand.allocate
    command.instance_variable_set(:@code, code)
    command.instance_variable_set(:@indent, indent)
    command.instance_variable_set(:@parameters, parameters)
    command
  end

  def script_commands(lines)
    commands = []
    lines.each_with_index do |line, index|
      commands << event_command(index.zero? ? 355 : 655, 0, [line])
    end
    commands << event_command(0, 0, [])
    commands
  end

  def create_camera_presets
    path = "Data/CommonEvents.rvdata2"
    events = load_data(path)
    presets = {
      1 => ["CAM — Focus Player + Zoom 130 [CE01]", ["ms_pro_cam_center_at_char(-1, 20)", "ms_pro_cam_wait_for_scrolling", "map_effects.refresh_rate = 60", "map_effects.set_zoom(130, 20, false)"]],
      2 => ["CAM — Focus Event Variable 40 [CE02]", ["id = $game_variables[40]", "ms_pro_cam_center_at_char(id, 40)", "ms_pro_cam_wait_for_scrolling", "map_effects.refresh_rate = 60", "map_effects.set_zoom(130, 40, false)"]],
      3 => ["CAM — Reset Camera and Effects [CE03]", ["map_effects.refresh_rate = 60", "map_effects.active = true", "map_effects.set_zoom(100, 20, false)", "map_effects.set_tone(0, 0, 0, 0, 20)", "map_effects.set_color(0, 0, 0, 0, 20)", "map_effects.set_wave(0, 180, 360, 20)", "map_effects.set_pixelize(100, 20)", "map_effects.setup_blur(4, 1, 0, 20)", "map_effects.set_gaussian_blur(0, 20)", "map_effects.set_linear_blur(0, 0, 20)", "map_effects.set_zoom_blur(100, 20)", "map_effects.set_radial_blur(0, 20)", "map_effects.set_motion_blur(0, 20)", "ms_pro_cam_unlock_camera", "ms_pro_cam_ignore_player(false)", "ms_pro_cam_focus_on(-1)", "ms_pro_cam_reset_str", "$game_map.screen.start_tone_change(Tone.new(0, 0, 0, 0), 20)", "$game_map.screen.start_flash(Color.new(0, 0, 0, 0), 1)", "$game_map.screen.start_shake(0, 0, 1)", "$game_map.screen.change_weather(:none, 0, 20)", "map_effects.clear", "map_effects.active = true" ]],
      4 => ["FX — Soft Dialogue Player [CE04]", ["ms_pro_cam_center_at_char(-1, 25)", "ms_pro_cam_wait_for_scrolling", "map_effects.refresh_rate = 60", "map_effects.set_zoom(120, 25, false)", "map_effects.set_tone(-15, -15, -10, 0, 25)"]],
      5 => ["FX — Dramatic Event Variable 40 [CE05]", ["id = $game_variables[40]", "ms_pro_cam_center_at_char(id, 30)", "ms_pro_cam_wait_for_scrolling", "map_effects.refresh_rate = 60", "map_effects.set_zoom(130, 25, false)", "map_effects.set_tone(-35, -35, -20, 0, 25)"]],
      6 => ["FX — Shock [CE06]", ["map_effects.refresh_rate = 60", "map_effects.active = true", "map_effects.set_zoom(115, 8, false)", "map_effects.setup_blur(4, 100, 0, 1)", "map_effects.set_zoom_blur(150, 8)", "map_effects.set_zoom(100, 12, false)", "map_effects.set_zoom_blur(100, 12)"]],
      7 => ["FX — Horror Tension [CE07]", ["map_effects.refresh_rate = 60", "map_effects.active = true", "map_effects.set_zoom(110, 90, false)", "map_effects.set_tone(-80, -80, -80, 40, 90)", "map_effects.set_color(0, 0, 0, 60, 90)", "map_effects.setup_blur(4, 1, 0, 90)", "map_effects.set_gaussian_blur(1, 90)"]],
      8 => ["CAM — Focus Office Coordinate A [CE08]", ["ms_pro_cam_ignore_player(true)", "ms_pro_cam_center_at(7, 21, 20)", "ms_pro_cam_wait_for_scrolling"]],
      9 => ["CAM — Focus Office Coordinate B [CE09]", ["ms_pro_cam_ignore_player(true)", "ms_pro_cam_center_at(13, 3, 20)", "ms_pro_cam_wait_for_scrolling"]],
      10 => ["FX — Clear Screen Effects Only [CE10]", ["map_effects.refresh_rate = 60", "map_effects.set_zoom(100, 20, false)", "map_effects.set_tone(0, 0, 0, 0, 20)", "map_effects.set_color(0, 0, 0, 0, 20)", "map_effects.clear"]]
    }
    presets.each do |id, (name, lines)|
      event = events[id]
      raise "Missing Common Event #{id}" unless event
      event.instance_variable_set(:@name, name)
      event.instance_variable_set(:@trigger, 0)
      event.instance_variable_set(:@switch_id, 1)
      event.instance_variable_set(:@list, script_commands(lines))
    end
    save_data(path, events)
    puts "COMMON_PRESETS|updated=#{presets.size}|file=#{path}"
  end

  def rename_map003_events
    path = "Data/Map003.rvdata2"
    map = load_data(path)
    names = {
      1 => "PHONE CONTACT INIT [E001]", 2 => "MAP LAYER INIT [E002]", 3 => "SCN-SW-001 OFFICE CUTSCENE [E003]",
      4 => "NPC BETA M-34 [E004]", 5 => "NPC ALPHA C-61 [E005]", 6 => "PROP SHARED FRIDGE [E006]",
      7 => "PROP OFFICE NOTICEBOARD [E007]", 8 => "PROP DUTY ROSTER [E008]", 9 => "PROP SIGMA STAR POSTER [E009]",
      10 => "PROP FILE CABINET [E010]", 11 => "PROP ZETA STATISTICS A [E011]", 12 => "PROP ZETA STATISTICS B [E012]",
      13 => "PROP ZETA STATISTICS C [E013]", 14 => "PROP ZETA STATISTICS D [E014]", 15 => "PROP COFFEE CABINET [E015]",
      16 => "PROP BETA RESEARCH BOOKCASE [E016]", 17 => "PROP CARNIVOROUS PLANT [E017]", 18 => "SCN-SW-002 GRASS GAG [E018]",
      19 => "PROP SIGMA DESK [E019]", 20 => "PROP BETA DESK [E020]", 21 => "PROP HQ DESK [E021]",
      22 => "SCN-SW-003 OFFICE BANTER [E022]", 23 => "OFFICE FURNITURE NORTH A [E023]", 24 => "OFFICE FURNITURE NORTH B [E024]",
      25 => "OFFICE SWITCH INTERACTION [E025]", 26 => "OFFICE FURNITURE WEST A [E026]", 27 => "SCN-SW-004 OFFICE DIALOGUE [E027]",
      28 => "OFFICE FURNITURE GRID 01 [E028]", 29 => "OFFICE FURNITURE GRID 02 [E029]", 30 => "OFFICE FURNITURE GRID 03 [E030]",
      31 => "OFFICE FURNITURE GRID 04 [E031]", 32 => "OFFICE FURNITURE GRID 05 [E032]", 33 => "OFFICE FURNITURE GRID 06 [E033]",
      34 => "OFFICE FURNITURE GRID 07 [E034]", 35 => "OFFICE FURNITURE GRID 08 [E035]", 36 => "OFFICE FURNITURE GRID 09 [E036]",
      37 => "OFFICE FURNITURE GRID 10 [E037]", 38 => "OFFICE FURNITURE GRID 11 [E038]", 39 => "OFFICE FURNITURE GRID 12 [E039]",
      40 => "OFFICE FURNITURE GRID 13 [E040]", 41 => "OFFICE FURNITURE GRID 14 [E041]", 42 => "OFFICE FURNITURE GRID 15 [E042]",
      43 => "OFFICE FURNITURE GRID 16 [E043]", 44 => "OFFICE FURNITURE GRID 17 [E044]", 45 => "OFFICE FURNITURE GRID 18 [E045]",
      46 => "OFFICE FURNITURE SOUTH A [E046]", 47 => "OFFICE FURNITURE SOUTH B [E047]", 48 => "OFFICE FURNITURE EAST A [E048]",
      49 => "OFFICE FURNITURE EAST B [E049]", 50 => "OFFICE FURNITURE SOUTH C [E050]", 51 => "OFFICE FURNITURE SOUTH D [E051]",
      52 => "OFFICE FURNITURE SOUTH E [E052]", 53 => "OFFICE FURNITURE SOUTH F [E053]", 54 => "OFFICE FURNITURE SOUTH G [E054]",
      55 => "OFFICE FURNITURE SOUTH H [E055]", 56 => "OFFICE FURNITURE SOUTH I [E056]", 57 => "OFFICE FURNITURE SOUTH J [E057]",
      58 => "OFFICE FURNITURE SOUTH K [E058]", 59 => "OFFICE FURNITURE SOUTH L [E059]", 60 => "OFFICE FURNITURE SOUTH M [E060]",
      61 => "OFFICE FURNITURE SOUTH N [E061]", 62 => "SCN-SW-005 EXIT CHOICE A [E062]", 63 => "SCN-SW-006 EXIT CHOICE B [E063]",
      64 => "SCN-SW-007 BAD ENDING [E064]", 65 => "OFFICE FURNITURE SOUTH O [E065]"
    }
    events = map.instance_variable_get(:@events) || {}
    names.each { |id, name| events[id].instance_variable_set(:@name, name) if events[id] }
    map.instance_variable_set(:@events, events)
    save_data(path, map)
    puts "MAP003_RENAMED|events=#{names.size}|file=#{path}"
  end

  def fix_map017_transfer_wait
    path = "Data/Map017.rvdata2"
    map = load_data(path)
    events = map.instance_variable_get(:@events) || {}
    event = events[2]
    raise "Map017 event 2 not found" unless event
    page = (event.instance_variable_get(:@pages) || []).first
    list = page.instance_variable_get(:@list) || []
    candidates = list.select do |command|
      command.instance_variable_get(:@code) == 205 &&
        (command.instance_variable_get(:@parameters) || [])[0] == -1
    end
    route_command = candidates.last
    raise "Map017 E002 player route not found" unless route_command
    route = (route_command.instance_variable_get(:@parameters) || [])[1]
    previous = route.instance_variable_get(:@wait)
    route.instance_variable_set(:@wait, true)
    save_data(path, map)
    puts "MAP017_WAIT_FIX|event=2|player_routes=#{candidates.size}|previous=#{previous}|wait=true"
  end

  def fix_map017_remove_final_player_route
    path = "Data/Map017.rvdata2"
    map = load_data(path)
    event = (map.instance_variable_get(:@events) || {})[2]
    raise "Map017 event 2 not found" unless event
    page = (event.instance_variable_get(:@pages) || []).first
    list = page.instance_variable_get(:@list) || []
    indexes = list.each_index.select do |index|
      command = list[index]
      command.instance_variable_get(:@code) == 205 &&
        (command.instance_variable_get(:@parameters) || [])[0] == -1
    end
    index = indexes.last
    raise "Final Map017 player route not found" unless index
    list.delete_at(index)
    page.instance_variable_set(:@list, list)
    save_data(path, map)
    puts "MAP017_ROUTE_FIX|removed_final_player_route=true|remaining_player_routes=#{indexes.size - 1}"
  end

  def fix_map017_add_three_step_exit
    path = "Data/Map017.rvdata2"
    map = load_data(path)
    event = (map.instance_variable_get(:@events) || {})[2]
    raise "Map017 event 2 not found" unless event
    page = (event.instance_variable_get(:@pages) || []).first
    list = page.instance_variable_get(:@list) || []
    transfer_index = list.index { |command| command.instance_variable_get(:@code) == 201 }
    raise "Map017 transfer command not found" unless transfer_index
    route = RPG::MoveRoute.allocate
    route.instance_variable_set(:@repeat, false)
    route.instance_variable_set(:@skippable, false)
    route.instance_variable_set(:@wait, true)
    moves = 3.times.map do
      move = RPG::MoveCommand.allocate
      move.instance_variable_set(:@code, 1)
      move.instance_variable_set(:@parameters, [])
      move
    end
    finish = RPG::MoveCommand.allocate
    finish.instance_variable_set(:@code, 0)
    finish.instance_variable_set(:@parameters, [])
    route.instance_variable_set(:@list, moves + [finish])
    command = event_command(205, 0, [-1, route])
    list.insert(transfer_index, command)
    page.instance_variable_set(:@list, list)
    save_data(path, map)
    puts "MAP017_ROUTE_FIX|added_three_step_up=true|wait=true|before_transfer=true"
  end

  def add_map017_camera_reset
    path = "Data/Map017.rvdata2"
    map = load_data(path)
    event = (map.instance_variable_get(:@events) || {})[2]
    page = (event.instance_variable_get(:@pages) || []).first
    list = page.instance_variable_get(:@list) || []
    transfer_index = list.index { |command| command.instance_variable_get(:@code) == 201 }
    raise "Map017 transfer command not found" unless transfer_index
    unless list.any? { |command| command.instance_variable_get(:@code) == 117 && (command.instance_variable_get(:@parameters) || [])[0] == 3 }
      list.insert(transfer_index, event_command(117, 0, [3]))
    end
    page.instance_variable_set(:@list, list)
    save_data(path, map)
    puts "MAP017_CAMERA|reset_common_event=3|before_transfer=true"
  end

  def rename_maps_006_007_017
    mapping = {
      "Data/Map006.rvdata2" => {
        1 => "CITY BUS STOP [E001]", 2 => "CITY ARRIVAL GATE [E002]", 3 => "CITY SOUTH INTERACTION [E003]",
        4 => "SCN-CITY-001 EXIT SILVER WING [E004]", 5 => "CITY PROP SOUTH A [E005]",
        6 => "CITY PROP SOUTH B [E006]", 7 => "CITY EXIT TRANSFER [E007]"
      },
      "Data/Map007.rvdata2" => { 2 => "SCN-CITY-002 BAD ENDING [E002]" },
      "Data/Map017.rvdata2" => { 1 => "NPC IOTA F-40 [E001]", 2 => "SCN-SW-008 IOTA HALLWAY CUTSCENE [E002]" }
    }
    mapping.each do |path, names|
      map = load_data(path)
      events = map.instance_variable_get(:@events) || {}
      names.each { |id, name| events[id].instance_variable_set(:@name, name) if events[id] }
      map.instance_variable_set(:@events, events)
      save_data(path, map)
      puts "MAP_RENAMED|#{path}|events=#{names.size}"
    end
  end

  def rename_map010_events
    path = "Data/Map010.rvdata2"
    map = load_data(path)
    events = map.instance_variable_get(:@events) || {}
    { 1 => "BUS BUMP EFFECT [E001]", 2 => "SCN-BUS-001 CHRISTMAS GIFT PLAN [E002]" }.each do |id, name|
      events[id].instance_variable_set(:@name, name) if events[id]
    end
    map.instance_variable_set(:@events, events)
    save_data(path, map)
    puts "MAP010_RENAMED|events=2|file=#{path}"
  end

  def fix_map006_phone_patch_call
    path = "Data/Map006.rvdata2"
    map = load_data(path)
    events = map.instance_variable_get(:@events) || {}
    changed = 0
    events.each_value do |event|
      next unless event
      (event.instance_variable_get(:@pages) || []).each do |page|
        (page.instance_variable_get(:@list) || []).each do |command|
          next unless command.instance_variable_get(:@code) == 355
          params = command.instance_variable_get(:@parameters) || []
          next unless params[0].to_s.include?("PhoneGroupChatPatch.save_christmas_log") || params[0].to_s.include?("PhoneGroupChatSave.save_current_cutscene(:christmas_group)")
          params[0] = "PhoneGroupChatSave.save_current_cutscene(:wanderer_group)"
          command.instance_variable_set(:@parameters, params)
          changed += 1
        end
      end
    end
    raise "Christmas group save call not found" if changed == 0
    save_data(path, map)
    puts "MAP006_PHONE_CALL|replaced=#{changed}|target=PhoneGroupChatSave.save_current_cutscene"
  end

  def smooth_city_to_bus_transition
    path = "Data/Map006.rvdata2"
    map = load_data(path)
    event = (map.instance_variable_get(:@events) || {})[4]
    page = (event.instance_variable_get(:@pages) || []).first
    list = page.instance_variable_get(:@list) || []
    transfer = list.index { |c| c.instance_variable_get(:@code) == 201 }
    raise "Map006 E004 transfer not found" unless transfer
    easing = [
      event_command(355, 0, ["shake_screen(18, 2)"]),
      event_command(230, 0, [10]),
      event_command(355, 0, ["shake_screen(28, 4)"]),
      event_command(230, 0, [10]),
      event_command(355, 0, ["shake_screen(12, 2)"]),
      event_command(221, 0, []),
      event_command(230, 0, [20])
    ]
    list.insert(transfer, *easing) unless list.any? { |c| (c.instance_variable_get(:@parameters) || [])[0].to_s == "shake_screen(18, 2)" }
    page.instance_variable_set(:@list, list)
    save_data(path, map)

    path = "Data/Map010.rvdata2"
    map = load_data(path)
    event = (map.instance_variable_get(:@events) || {})[2]
    page = (event.instance_variable_get(:@pages) || []).first
    list = page.instance_variable_get(:@list) || []
    list.map! do |c|
      if c.instance_variable_get(:@code) == 355 && (c.instance_variable_get(:@parameters) || [])[0].to_s == "shake_screen(45, 10)"
        event_command(355, 0, ["shake_screen(22, 4)"])
      else
        c
      end
    end
    expanded = []
    list.each_with_index do |c, i|
      expanded << c
      if c.instance_variable_get(:@code) == 355 && (c.instance_variable_get(:@parameters) || [])[0].to_s == "shake_screen(22, 4)"
        nxt = list[i + 1]
        unless nxt && nxt.instance_variable_get(:@code) == 230
          expanded << event_command(230, 0, [8])
        end
      end
    end
    list = expanded
    page.instance_variable_set(:@list, list)
    save_data(path, map)
    puts "BUS_TRANSITION|city_brake=true|bus_acceleration=true|fade=true"
  end

  def remove_city_bus_fadeout
    path = "Data/Map006.rvdata2"
    map = load_data(path)
    event = (map.instance_variable_get(:@events) || {})[4]
    page = (event.instance_variable_get(:@pages) || []).first
    list = page.instance_variable_get(:@list) || []
    before = list.length
    # Transfer uses the normal map fade; an extra Fadeout here leaves the
    # destination scene black because no Fadein command runs on Map010.
    list.reject! { |c| c.instance_variable_get(:@code) == 221 }
    page.instance_variable_set(:@list, list)
    save_data(path, map) if list.length != before
    puts "BUS_FADEOUT|removed=#{before - list.length}"
  end

  def rename_and_camera_map013
    path = "Data/Map013.rvdata2"
    map = load_data(path)
    events = map.instance_variable_get(:@events) || {}
    names = {
      1 => "SCN-WANDERER-001 ARRIVAL INIT [E001]",
      2 => "TRANSFER-WANDERER-TO-KITCHEN-A [E002]",
      3 => "TRANSFER-WANDERER-TO-KITCHEN-B [E003]",
      10 => "TRANSFER-WANDERER-TO-KITCHEN-C [E010]",
      37 => "PROP-WANDERER-SAFE CHOICE [E037]",
      67 => "PUZZLE-LASER-AUTH-A [E067]", 68 => "PUZZLE-LASER-AUTH-B [E068]",
      69 => "PUZZLE-LASER-AUTH-C [E069]", 70 => "PUZZLE-LASER-AUTH-D [E070]",
      71 => "PUZZLE-LASER-AUTH-E [E071]", 80 => "PUZZLE-LASER-AUTH-F [E080]",
      97 => "SCN-WANDERER-002 LEO [E097]",
      98 => "SCN-WANDERER-003 SHYLVIE [E098]",
      100 => "ROUTE-WANDERER-TO-SUPERMARKET [E100]",
      101 => "ITEM-TRANSFORM-RIU [E101]"
    }
    names.each { |id, name| events[id].instance_variable_set(:@name, name) if events[id] }
    # Route all scene camera focus through CE02/CE01, using reserved Variable 40.
    [97, 98].each do |id|
      event = events[id]
      (event.instance_variable_get(:@pages) || []).each do |page|
        list = page.instance_variable_get(:@list) || []
        out = []
        list.each do |command|
          if command.instance_variable_get(:@code) == 355
            script = (command.instance_variable_get(:@parameters) || [])[0].to_s
            if script =~ /ms_pro_cam_focus_on\((\d+)\)/
              out << event_command(122, 0, [40, 40, 0, 0, Regexp.last_match(1).to_i])
              out << event_command(117, 0, [2])
              next
            elsif script == "ms_pro_cam_focus_on(-1)"
              out << event_command(117, 0, [1])
              next
            end
          end
          out << command
        end
        page.instance_variable_set(:@list, out)
      end
    end
    map.instance_variable_set(:@events, events)
    save_data(path, map)
    puts "MAP013_REVIEW|renamed=#{names.size}|camera_common_events=true|variable=40"
  end
end

command = ARGV.shift
case command
when "compare-scripts"
  RVData2Audit.compare_scripts
when "dump-map"
  RVData2Audit.dump_map(Integer(ARGV.fetch(0)))
when "diff-script"
  RVData2Audit.diff_script(Integer(ARGV.fetch(0)))
when "create-map-021"
  RVData2Audit.create_atlantis_gate_map_021
when "add-atlantis-choice-map010"
  RVData2Audit.add_atlantis_choice_map010
when "name-atlantis-flags"
  RVData2Audit.name_atlantis_flags
when "audit-map-state"
  RVData2Audit.audit_map_state
when "replace-script"
  RVData2Audit.replace_runtime_script(ARGV.fetch(0), ARGV.fetch(1))
when "dump-common-events"
  RVData2Audit.dump_common_events
when "create-camera-presets"
  RVData2Audit.create_camera_presets
when "rename-map003-events"
  RVData2Audit.rename_map003_events
when "fix-map017-transfer-wait"
  RVData2Audit.fix_map017_transfer_wait
when "fix-map017-remove-final-player-route"
  RVData2Audit.fix_map017_remove_final_player_route
when "fix-map017-add-three-step-exit"
  RVData2Audit.fix_map017_add_three_step_exit
when "add-map017-camera-reset"
  RVData2Audit.add_map017_camera_reset
when "rename-maps-006-007-017"
  RVData2Audit.rename_maps_006_007_017
when "rename-map010-events"
  RVData2Audit.rename_map010_events
when "fix-map006-phone-patch-call"
  RVData2Audit.fix_map006_phone_patch_call
when "smooth-city-to-bus-transition"
  RVData2Audit.smooth_city_to_bus_transition
when "remove-city-bus-fadeout"
  RVData2Audit.remove_city_bus_fadeout
when "rename-camera-map013"
  RVData2Audit.rename_and_camera_map013
else
  warn "Usage: ruby tools/rvdata2_audit.rb compare-scripts|diff-script INDEX|dump-map MAP_ID|create-map-021|audit-map-state|replace-script NAME FILE|dump-common-events|create-camera-presets|rename-map003-events|fix-map017-transfer-wait|fix-map017-remove-final-player-route|fix-map017-add-three-step-exit|add-map017-camera-reset|rename-maps-006-007-017|rename-map010-events"
  exit 1
end
