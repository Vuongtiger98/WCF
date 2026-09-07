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
  class Actor; end
  class Tileset; end
  class CommonEvent; end
  class Animation; end
  class Animation::Frame; end
  class Animation::Timing; end
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

  # Report contiguous runs of Control Switches / Control Variables that assign
  # the exact same state more than once. Repeated state commands in separate
  # branches may be intentional, so the audit deliberately resets at every
  # non-state command to keep false positives low.
  def audit_repeated_route_state_commands
    suspects = []
    Dir.glob("Data/Map[0-9][0-9][0-9].rvdata2").sort.each do |path|
      map_id = File.basename(path)[/\d+/].to_i
      map = load_data(path)
      (map.instance_variable_get(:@events) || {}).each do |event_id, event|
        next unless event
        (event.instance_variable_get(:@pages) || []).each_with_index do |page, page_index|
          run = []
          flush = lambda do
            counts = Hash.new(0)
            run.each { |command| counts[[command_code(command), command_parameters(command)]] += 1 }
            repeated = counts.select { |_signature, count| count > 1 }
            unless repeated.empty?
              suspects << [map_id, event_id, page_index + 1,
                           event.instance_variable_get(:@name), run.length, repeated]
            end
            run.clear
          end
          (page.instance_variable_get(:@list) || []).each do |command|
            if [121, 122].include?(command_code(command))
              run << command
            else
              flush.call
            end
          end
          flush.call
        end
      end
    end
    suspects.each do |map_id, event_id, page_id, name, run_size, repeated|
      puts "REPEATED_ROUTE_STATE|Map%03d|E%03d|P%d|%s|run=%d" %
        [map_id, event_id, page_id, name, run_size]
      repeated.each do |(code, parameters), count|
        puts "  x#{count}|code=#{code}|#{parameters.inspect}"
      end
    end
    puts "REPEATED_ROUTE_STATE_SUMMARY|suspects=#{suspects.length}"
  end

  def dump_map(map_id)
    path = format("Data/Map%03d.rvdata2", map_id)
    map = load_data(path)
    events = map.instance_variable_get(:@events) || {}
    table = map.instance_variable_get(:@data)
    table_header = table && table.instance_variable_get(:@marshal_data)&.unpack("l<5")
    puts "MAP|#{map_id}|#{map.instance_variable_get(:@display_name)}|" \
         "#{map.instance_variable_get(:@width)}x#{map.instance_variable_get(:@height)}|" \
         "events=#{events.size}|tileset=#{map.instance_variable_get(:@tileset_id)}|" \
         "table=#{table_header ? table_header[1, 3].join('x') : 'unknown'}|" \
         "parallax=#{map.instance_variable_get(:@parallax_name)}|" \
         "loop=#{map.instance_variable_get(:@parallax_loop_x)},#{map.instance_variable_get(:@parallax_loop_y)}|" \
         "show=#{map.instance_variable_get(:@parallax_show)}|note=#{map.instance_variable_get(:@note).inspect}"

    events.keys.sort.each do |event_id|
      event = events[event_id]
      puts "EVENT|#{event_id}|#{event.instance_variable_get(:@name)}|" \
           "#{event.instance_variable_get(:@x)},#{event.instance_variable_get(:@y)}"
      (event.instance_variable_get(:@pages) || []).each_with_index do |page, page_index|
        condition = page.instance_variable_get(:@condition)
        puts "PAGE|#{page_index + 1}|trigger=#{page.instance_variable_get(:@trigger)}|" \
             "priority=#{page.instance_variable_get(:@priority_type)}|" \
             "condition=#{condition.inspect}"
        graphic = page.instance_variable_get(:@graphic)
        if graphic
          puts "GRAPHIC|#{graphic.instance_variable_get(:@character_name)}|" \
               "index=#{graphic.instance_variable_get(:@character_index)}|" \
               "direction=#{graphic.instance_variable_get(:@direction)}"
        end
        (page.instance_variable_get(:@list) || []).each do |command|
          code = command_code(command)
          parameters = command_parameters(command)
          next unless [101, 102, 103, 108, 111, 117, 118, 119, 121, 122, 123, 201, 205, 212, 213, 214, 221, 222, 223, 225, 230, 231, 235, 284, 353, 354, 355, 401, 402, 403, 404, 408, 411, 412, 655].include?(code)

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

  def wrapped_message_commands(paragraphs, tag: nil, width: 30, indent: 0)
    result = []
    Array(paragraphs).each do |paragraph|
      words = paragraph.to_s.split(/\s+/)
      lines = []
      current = ""
      words.each do |word|
        if current.empty?
          current = word
        elsif current.length + 1 + word.length <= width
          current += " " + word
        else
          lines << current
          current = word
        end
      end
      lines << current unless current.empty?
      lines.each_slice(3) do |chunk|
        result << event_command(101, indent, ["", 0, 0, 2])
        chunk.each_with_index do |line, index|
          result << event_command(401, indent, [index.zero? && tag ? "#{tag}#{line}" : line])
        end
      end
    end
    result
  end

  def reset_page_condition(condition)
    condition.instance_variables.each do |variable|
      value = condition.instance_variable_get(variable)
      condition.instance_variable_set(variable, false) if value == true || value == false
    end
    condition
  end

  def page_from_template(template, commands, trigger: 0, priority: 1,
                         self_switch: nil, switch_id: nil,
                         variable_id: nil, variable_value: 0)
    page = Marshal.load(Marshal.dump(template.instance_variable_get(:@pages).first))
    condition = reset_page_condition(page.instance_variable_get(:@condition))
    if self_switch
      condition.instance_variable_set(:@self_switch_valid, true)
      condition.instance_variable_set(:@self_switch_ch, self_switch)
    end
    if switch_id
      condition.instance_variable_set(:@switch1_valid, true)
      condition.instance_variable_set(:@switch1_id, switch_id)
    end
    if variable_id
      condition.instance_variable_set(:@variable_valid, true)
      condition.instance_variable_set(:@variable_id, variable_id)
      condition.instance_variable_set(:@variable_value, variable_value)
    end
    page.instance_variable_set(:@trigger, trigger)
    page.instance_variable_set(:@priority_type, priority)
    page.instance_variable_set(:@list, commands + [event_command(0, 0, [])])
    page
  end

  def event_from_pages(template, id, name, x, y, pages)
    event = Marshal.load(Marshal.dump(template))
    event.instance_variable_set(:@id, id)
    event.instance_variable_set(:@name, "#{name} [E%03d]" % id)
    event.instance_variable_set(:@x, x)
    event.instance_variable_set(:@y, y)
    event.instance_variable_set(:@pages, pages)
    event
  end

  def blank_table(width, height, depth = 4)
    size = width * height * depth
    table = Table.allocate
    table.instance_variable_set(:@marshal_data,
      [3, width, height, depth, size].pack("l<5") + Array.new(size, 0).pack("s<*"))
    table
  end

  def table_set(table, x, y, z, value)
    raw = table.instance_variable_get(:@marshal_data)
    _dim, width, height, _depth, size = raw.unpack("l<5")
    values = raw.byteslice(20, size * 2).unpack("s<*")
    values[z * width * height + y * width + x] = value
    table.instance_variable_set(:@marshal_data,
      raw.byteslice(0, 20) + values.pack("s<*"))
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

  def configure_map021_house_parallax
    path = "Data/Map021.rvdata2"
    map = load_data(path)
    map.instance_variable_set(:@width, 22)
    map.instance_variable_set(:@height, 43)
    map.instance_variable_set(:@parallax_name, "HQ_House_Base")
    map.instance_variable_set(:@parallax_loop_x, false)
    map.instance_variable_set(:@parallax_loop_y, false)
    map.instance_variable_set(:@parallax_sx, 0)
    map.instance_variable_set(:@parallax_sy, 0)
    event = (map.instance_variable_get(:@events) || {})[1]
    page = (event.instance_variable_get(:@pages) || []).first
    list = page.instance_variable_get(:@list) || []
    unless list.any? { |c| (c.instance_variable_get(:@parameters) || [])[0].to_s.include?("HQ_House_Top") }
      list.unshift(event_command(355, 0, ["layer(21,0,[\"HQ_House_Top\",0,0,255,200,0,0,0])"]))
      list.insert(1, event_command(655, 0, ["refresh_layers"]))
    end
    page.instance_variable_set(:@list, list)
    save_data(path, map)
    verified = load_data(path)
    puts "MAP021_PARALLAX|size=#{verified.instance_variable_get(:@width)}x#{verified.instance_variable_get(:@height)}|base=#{verified.instance_variable_get(:@parallax_name)}|top=HQ_House_Top"
  end

  def create_map022_house_parallax
    map_path = "Data/Map022.rvdata2"
    infos_path = "Data/MapInfos.rvdata2"
    template = load_data("Data/Map004.rvdata2")
    template.instance_variable_set(:@display_name, "Nhà Hải Quỳ — bản thử")
    template.instance_variable_set(:@width, 22)
    template.instance_variable_set(:@height, 43)
    template.instance_variable_set(:@parallax_name, "HQ_House_Base")
    template.instance_variable_set(:@parallax_loop_x, false)
    template.instance_variable_set(:@parallax_loop_y, false)
    template.instance_variable_set(:@parallax_sx, 0)
    template.instance_variable_set(:@parallax_sy, 0)
    template.instance_variable_set(:@note, "House parallax test: HQ_House_Base + HQ_House_Top")
    event_template = (template.instance_variable_get(:@events) || {}).values.first
    raise "Map004 has no template event" unless event_template
    commands = [
      event_command(355, 0, ["layer(22,0,[\"HQ_House_Top\",0,0,255,200,0,0,0])"]),
      event_command(655, 0, ["refresh_layers"]),
      event_command(123, 0, ["A", 0])
    ]
    template.instance_variable_set(:@events, {
      1 => clone_event(event_template, 1, "SCN-ATL-002 HOUSE PARALLAX TEST [E001]", 4, 4, commands)
    })
    save_data(map_path, template)
    infos = load_data(infos_path)
    info_template = infos[4] || infos.values.first
    info = Marshal.load(Marshal.dump(info_template))
    info.instance_variable_set(:@name, "Nhà Hải Quỳ — bản thử")
    info.instance_variable_set(:@parent_id, 0)
    info.instance_variable_set(:@order, infos.values.map { |i| i.instance_variable_get(:@order).to_i }.max + 1)
    info.instance_variable_set(:@expanded, true)
    info.instance_variable_set(:@scroll_x, 0)
    info.instance_variable_set(:@scroll_y, 0)
    infos[22] = info
    save_data(infos_path, infos)
    puts "MAP022_HOUSE|size=22x43|base=HQ_House_Base|top=HQ_House_Top"
  end

  def add_map022_house_events
    path = "Data/Map022.rvdata2"
    map = load_data(path)
    events = map.instance_variable_get(:@events) || {}
    template = events[1]
    raise "Map022 base event missing" unless template
    thought = lambda do |lines|
      list = [event_command(101, 0, ["", 0, 0, 2])]
      lines.each { |line| list << event_command(401, 0, [line]) }
      list << event_command(0, 0, [])
      list
    end
    main = [event_command(117, 0, [1])] + thought.call([
      "Cuối cùng cũng về tới nhà rồi.",
      "Mình nghỉ một lát, sửa Brilliant Anchor rồi sẽ xuống Atlantis mua sách phép.",
      "Không biết căn nhà này còn giữ lại bao nhiêu thứ mà mình đã quên."
    ]) + [event_command(121, 0, [34, 34, 0]), event_command(122, 0, [30, 30, 0, 0, 1]), event_command(123, 0, ["A", 0])]
    template.instance_variable_set(:@name, "SCN-ATL-002 ARRIVE HOME [E001]")
    template.instance_variable_get(:@pages).first.instance_variable_set(:@list, main)
    events[2] = clone_event(template, 2, "LORE-HOME-FAMILY PHOTO [E002]", 5, 5, thought.call([
      "Ảnh gia đình của mình.",
      "OniOnii từng kể rằng hồi bé mình trông giống chị tư đến mức mọi người tưởng là sinh đôi.",
      "Kỳ lạ thật. Mình không nhớ hình dạng này, nhưng cảm giác biến hình lại rất quen thuộc."
    ]))
    events[3] = clone_event(template, 3, "LORE-HOME-ATLANTIS PHOTO [E003]", 6, 5, thought.call([
      "Ảnh chụp hoàng hôn thành phố Atlantis.",
      "Mình từng đến đó khi còn bé, cùng OniOnii tới tiệm sách phép."
    ]))
    events[4] = clone_event(template, 4, "LORE-STORAGE-DIARY [E004]", 7, 5, thought.call([
      "Một cuốn nhật ký cũ.",
      "Tên Dahria và Aira xuất hiện nhiều lần trong những trang này.",
      "Mình chưa hiểu hết chúng có ý nghĩa gì, nhưng không muốn bỏ qua."
    ]))
    events[5] = clone_event(template, 5, "PROP-HOME-ANCHOR REPAIR [E005]", 8, 5, thought.call([
      "Brilliant Anchor cần được sửa trước khi đi Atlantis.",
      "Không thể để nó quá tải giữa một chiều không gian khác."
    ]))
    events[6] = clone_event(template, 6, "PROP-STORAGE-CASSETTE [E006]", 9, 5, thought.call([
      "Một chiếc TV cũ và vài cuộn băng cassette.",
      "Có lẽ mình sẽ xem chúng sau. Bây giờ phải chuẩn bị xuống Atlantis đã."
    ]))
    map.instance_variable_set(:@events, events)
    save_data(path, map)
    puts "MAP022_EVENTS|main=E001|lore=E002-E006|pop_message_character_ids=deferred"
  end

  def fix_map022_main_trigger
    path = "Data/Map022.rvdata2"
    map = load_data(path)
    event = (map.instance_variable_get(:@events) || {})[1]
    page = (event.instance_variable_get(:@pages) || []).first
    page.instance_variable_set(:@trigger, 3)
    page.instance_variable_set(:@priority_type, 0)
    save_data(path, map)
    puts "MAP022_MAIN|trigger=autorun|priority=below_player"
  end

  def add_map022_pop_dialogue_camera
    path = "Data/Map022.rvdata2"
    map = load_data(path)
    events = map.instance_variable_get(:@events) || {}
    main = events[1]
    page = main.instance_variable_get(:@pages).first
    list = page.instance_variable_get(:@list) || []
    unless list.any? { |c| (c.instance_variable_get(:@parameters) || [])[0].to_s.include?("ATLANCE_DIALOGUE") }
      insert_at = list.index { |c| c.instance_variable_get(:@code) == 101 }
      camera = [
        event_command(355, 0, ["# ATLANCE_DIALOGUE: camera preset sequence"]),
        event_command(117, 0, [1]),
        event_command(122, 0, [40, 40, 0, 0, 7]),
        event_command(117, 0, [2]),
        event_command(101, 0, ["", 0, 0, 2]),
        event_command(401, 0, ["\\bm[7] Đã lâu rồi mới thấy em về nhà đấy."]),
        event_command(101, 0, ["", 0, 0, 2]),
        event_command(401, 0, ["\\bm[0] Em chỉ nghỉ một lát rồi xuống Atlantis mua sách phép thôi."]),
        event_command(117, 0, [1])
      ]
      list.insert(insert_at || 0, *camera)
      page.instance_variable_set(:@list, list)
    end
    template = events[1]
    unless events[7]
      npc = clone_event(template, 7, "NPC-PAULIE HOME DIALOGUE [E007]", 10, 8, [
        event_command(101, 0, ["", 0, 0, 2]),
        event_command(401, 0, ["\\bm[7] Em định xuống Atlantis mua sách phép à? Cẩn thận trên đường nhé."]),
        event_command(101, 0, ["", 0, 0, 2]),
        event_command(401, 0, ["\\bm[0] Vâng, em biết rồi. Em sẽ sửa Brilliant Anchor trước đã."]),
        event_command(117, 0, [1]),
        event_command(0, 0, [])
      ])
      npc_page = npc.instance_variable_get(:@pages).first
      npc_page.instance_variable_set(:@trigger, 0)
      npc_page.instance_variable_set(:@priority_type, 1)
      events[7] = npc
    end
    map.instance_variable_set(:@events, events)
    save_data(path, map)
    puts "MAP022_POP_CAMERA|npc_event=7|player_tag=0|camera_ce1_ce2=true"
  end

  def create_atlantis_route_maps
    infos_path = "Data/MapInfos.rvdata2"
    infos = load_data(infos_path)
    template_info = infos[4] || infos.values.first
    make_info = lambda do |id, name|
      info = Marshal.load(Marshal.dump(template_info))
      info.instance_variable_set(:@name, name)
      info.instance_variable_set(:@parent_id, 0)
      info.instance_variable_set(:@order, infos.values.map { |i| i.instance_variable_get(:@order).to_i }.max + id)
      info.instance_variable_set(:@expanded, true)
      info.instance_variable_set(:@scroll_x, 0)
      info.instance_variable_set(:@scroll_y, 0)
      infos[id] = info
    end
    base = load_data("Data/Map004.rvdata2")
    template_event = (base.instance_variable_get(:@events) || {}).values.first
    raise "Map004 has no template event" unless template_event
    make_map = lambda do |id, name, width, height, events|
      map = Marshal.load(Marshal.dump(base))
      map.instance_variable_set(:@display_name, name)
      map.instance_variable_set(:@width, width)
      map.instance_variable_set(:@height, height)
      map.instance_variable_set(:@parallax_name, "")
      map.instance_variable_set(:@parallax_loop_x, false)
      map.instance_variable_set(:@parallax_loop_y, false)
      map.instance_variable_set(:@parallax_sx, 0)
      map.instance_variable_set(:@parallax_sy, 0)
      map.instance_variable_set(:@note, "Atlantis route prototype")
      map.instance_variable_set(:@events, events)
      save_data("Data/Map%03d.rvdata2" % id, map)
      make_info.call(id, name)
    end
    text = lambda do |tag, lines|
      list = [event_command(355, 0, ["# #{tag}"]), event_command(101, 0, ["", 0, 0, 2])]
      lines.each { |line| list << event_command(401, 0, [line]) }
      list
    end
    # Map023: bookshop and book choice.
    shop = text.call("ATL_BOOKSHOP_SCENE", ["Tiệm sách phép Atlantis vẫn còn ở đây.", "Mình từng ngồi đọc sách ở đây cùng OniOnii-chan."])
    shop += [event_command(121, 0, [31, 31, 0]), event_command(102, 0, [["Mua Ma Vương Cổ Đại", "Mua Phép Dịch Chuyển"], 2]),
      event_command(402, 0, [0, "Mua Ma Vương Cổ Đại"]), event_command(122, 0, [31, 31, 0, 0, 1]), event_command(121, 0, [32, 32, 0]), event_command(122, 0, [31, 31, 0, 0, 1]), event_command(402, 0, [1, "Mua Phép Dịch Chuyển"]), event_command(122, 0, [31, 31, 0, 0, 2]), event_command(121, 0, [32, 32, 0]), event_command(404, 0, []), event_command(355, 0, ["# BOOK_SELECTED"]), event_command(122, 0, [30, 30, 0, 0, 3]), event_command(201, 0, [0, 24, 4, 4, 0, 0]), event_command(0, 0, [])]
    make_map.call(23, "Tiệm sách phép Atlantis", 22, 25, {1 => clone_event(template_event, 1, "SCN-ATL-003 BOOKSHOP [E001]", 4, 4, shop)})
    # Map024: chase start/exit prototype.
    chase = text.call("ATL_CHASE_SCENE", ["Một bóng đen khổng lồ xuất hiện sau lưng mình.", "Không ổn rồi. Nó đã nhận ra mình!", "Chạy thôi!"])
    chase += [event_command(121, 0, [35, 35, 0]), event_command(201, 0, [0, 25, 4, 4, 0, 0]), event_command(123, 0, ["A", 0]), event_command(0, 0, [])]
    exit_event = [event_command(101, 0, ["", 0, 0, 2]), event_command(401, 0, ["Lối thoát ở phía trước!"]), event_command(121, 0, [36, 36, 0]), event_command(201, 0, [0, 25, 4, 4, 0, 0]), event_command(0, 0, [])]
    make_map.call(24, "Atlantis — Chase", 30, 20, {1 => clone_event(template_event, 1, "SCN-ATL-004 CHASE START [E001]", 4, 4, chase), 2 => clone_event(template_event, 2, "SCN-ATL-004 CHASE EXIT [E002]", 28, 18, exit_event)})
    # Map025: reveal endpoint before party convergence.
    reveal = text.call("ATL_REVEAL_PRE_CONVERGENCE", ["Ta là…Dahria…", "Dahria… có thể không phải tên của ta.", "Cái tên Aira vẫn còn vang lên trong đầu mình."])
    reveal += [event_command(121, 0, [33, 33, 0]), event_command(122, 0, [30, 30, 0, 0, 4]), event_command(123, 0, ["A", 0]), event_command(0, 0, [])]
    make_map.call(25, "Atlantis — Reveal", 22, 20, {1 => clone_event(template_event, 1, "SCN-ATL-005 REVEAL BEFORE PARTY [E001]", 4, 4, reveal)})
    save_data(infos_path, infos)
    puts "ATLANTIS_ROUTE_MAPS|created=023,024,025|book_choice=true|chase=true|reveal=true"
  end

  def connect_map022_to_atlantis_shop
    path = "Data/Map022.rvdata2"
    map = load_data(path)
    event = (map.instance_variable_get(:@events) || {})[1]
    page = event.instance_variable_get(:@pages).first
    list = page.instance_variable_get(:@list) || []
    unless list.any? { |c| c.instance_variable_get(:@code) == 201 && (c.instance_variable_get(:@parameters) || [])[1] == 23 }
      idx = list.index { |c| c.instance_variable_get(:@code) == 123 } || list.length
      list.insert(idx, event_command(201, 0, [0, 23, 4, 4, 0, 0]))
    end
    page.instance_variable_set(:@list, list)
    save_data(path, map)
    puts "MAP022_TRANSFER|destination=Map023(4,4)"
  end

  def fix_atlantis_switch_values
    [21, 22, 23, 24, 25].each do |id|
      path = "Data/Map%03d.rvdata2" % id
      next unless File.exist?(path)
      map = load_data(path)
      (map.instance_variable_get(:@events) || {}).each_value do |event|
        next unless event
        (event.instance_variable_get(:@pages) || []).each do |page|
          (page.instance_variable_get(:@list) || []).each do |command|
            next unless command.instance_variable_get(:@code) == 121
            params = command.instance_variable_get(:@parameters) || []
            start_id, end_id = params[0].to_i, params[1].to_i
            if start_id >= 30 && end_id <= 36
              params[2] = 1
              command.instance_variable_set(:@parameters, params)
            end
          end
        end
      end
      save_data(path, map)
    end
    puts "ATLANTIS_SWITCHES|30-36=ON_VALUE_1"
  end

  def fix_atlantis_scene_triggers_camera
    {23 => [1], 24 => [1], 25 => [1]}.each do |id, autoruns|
      path = "Data/Map%03d.rvdata2" % id
      map = load_data(path)
      events = map.instance_variable_get(:@events) || {}
      autoruns.each do |eid|
        event = events[eid]
        next unless event
        page = event.instance_variable_get(:@pages).first
        page.instance_variable_set(:@trigger, 3)
        page.instance_variable_set(:@priority_type, 0)
        list = page.instance_variable_get(:@list) || []
        list.unshift(event_command(117, 0, [1])) unless list.any? { |c| c.instance_variable_get(:@code) == 117 && (c.instance_variable_get(:@parameters) || [])[0] == 1 }
        page.instance_variable_set(:@list, list)
      end
      save_data(path, map)
    end
    puts "ATLANTIS_SCENES|autorun=023,024,025|camera_ce1=true"
  end

  def make_map022_exploration_gate
    path = "Data/Map022.rvdata2"
    map = load_data(path)
    events = map.instance_variable_get(:@events) || {}
    main = events[1]
    page = main.instance_variable_get(:@pages).first
    list = page.instance_variable_get(:@list) || []
    list.reject! { |c| c.instance_variable_get(:@code) == 201 && (c.instance_variable_get(:@parameters) || [])[1] == 23 }
    list.reject! { |c| c.instance_variable_get(:@code) == 121 && (c.instance_variable_get(:@parameters) || [])[0] == 34 }
    page.instance_variable_set(:@list, list)
    template = events[2] || main
    letter = [event_command(101, 0, ["", 0, 0, 2]), event_command(401, 0, ["Một lá thư đặt cạnh Brilliant Anchor."]), event_command(101, 0, ["", 0, 0, 2]), event_command(401, 0, ["Mình sẽ đọc xong rồi xuống Atlantis mua sách phép."]), event_command(121, 0, [34, 34, 1]), event_command(122, 0, [30, 30, 0, 0, 2]), event_command(201, 0, [0, 23, 4, 4, 0, 0]), event_command(0, 0, [])]
    events[8] = clone_event(template, 8, "SCN-ATL-002 READ LETTER [E008]", 10, 5, letter)
    page8 = events[8].instance_variable_get(:@pages).first
    page8.instance_variable_set(:@trigger, 0)
    page8.instance_variable_set(:@priority_type, 1)
    map.instance_variable_set(:@events, events)
    save_data(path, map)
    puts "MAP022_GATE|free_exploration=true|letter_event=8|transfer_after_read=true"
  end

  def rebuild_map022_interactions_from_docx
    path = "Data/Map022.rvdata2"
    map = load_data(path)
    events = map.instance_variable_get(:@events) || {}
    template = events[2] || events[1]
    entries = [
      [10, 15, 10, "PROP-HOME-SINK [E010]", "Bồn rửa tay."],
      [11, 16, 10, "TRANSFER-HOME-POPO WORKSHOP [E011]", "Lối vào phòng sửa chữa của Popo."],
      [12, 14, 11, "PROP-HOME-WASHING MACHINE [E012]", "Máy giặt cửa trên. Hồi bé mình hay chui vào đây ngủ."],
      [13, 10, 10, "PROP-HOME-SIMULATED WINDOW [E013]", "Cửa sổ mô phỏng này vẫn còn hoạt động tốt. Ánh nắng chiếu vào dễ chịu quá."],
      [14, 8, 11, "PROP-HOME-BATH [E014]", "Hồi bé mình hay ngâm mình trong bồn tắm này lắm."],
      [15, 7, 33, "LORE-HOME-FAMILY ALBUM [E015]", "Ảnh chân dung và album ảnh của anh ba và chị tư. Mình nghe nói hồi bé mình từng bị nhầm là chị em sinh đôi với chị tư."],
      [16, 6, 33, "PROP-HOME-LAMP [E016]", "Cây đèn này được Popo sửa liên tục."],
      [17, 5, 33, "PROP-HOME-FIRST AID [E017]", "Tủ đựng thuốc sơ cứu của Momo."],
      [18, 4, 33, "PROP-HOME-POPO TEA CABINET [E018]", "Tủ đựng ly tách và ấm trà của Popo."],
      [19, 6, 29, "LORE-HOME-ATLANTIS SUNSET [E019]", "Ảnh chụp hoàng hôn thành phố Atlantis."],
      [20, 5, 29, "LORE-HOME-MAGNOLIA [E020]", "Ảnh chụp một chậu hoa mẫu lan."],
      [21, 4, 29, "LORE-HOME-FAMILY AWARD [E021]", "Bằng khen của anh ba. Popo luôn tự hào về anh ấy."],
      [22, 13, 26, "LORE-HOME-CHILD PHOTO [E022]", "Ảnh chụp hồi bé của mình. Nhìn quen nhưng mình không nhớ được hình dạng này."],
      [23, 12, 26, "LORE-HOME-FAMILY PICNIC [E023]", "Ảnh chụp cả gia đình đi dã ngoại."],
      [24, 5, 17, "PROP-HOME-FOOD FRIDGE [E024]", "Tủ lạnh luôn đầy ắp thức ăn."],
      [25, 4, 17, "PROP-HOME-MICROWAVE [E025]", "Nhìn tới lò vi sóng là lại nhớ tới bánh mì bơ tỏi."],
      [26, 6, 16, "PROP-HOME-INSTANT NOODLES [E026]", "Tủ mì ăn liền của OniOnii. Mình hay ăn ké mì của ổng."],
      [27, 8, 16, "PROP-HOME-KITCHEN OVEN [E027]", "Bếp và lò nướng."],
      [28, 8, 7, "LORE-STORAGE-RED DRESS [E028]", "Chiếc đầm đỏ của trẻ em. Nó không dính chút bụi nào."],
      [29, 11, 7, "LORE-STORAGE-CASSETTES [E029]", "Trong thùng có rất nhiều băng cassette. Mình sẽ xem chúng sau."],
      [30, 7, 7, "PROP-STORAGE-OLD TV [E030]", "Một chiếc TV cũ cùng đầu băng cassette vẫn còn dùng được."],
      [31, 10, 7, "LORE-STORAGE-ENCODED DIARY [E031]", "Một cuốn nhật ký bị mã hóa bằng phép thuật. Có nên mở ra xem không?"],
      [32, 9, 7, "LORE-STORAGE-ALBUM [E032]", "Một cuốn album tranh vẽ phủ đầy bụi và mạng nhện."],
      [33, 6, 6, "PROP-STORAGE-OLD BOOKS [E033]", "Nhiều sách báo cũ về camera và cách quay phim."],
      [34, 5, 8, "PROP-STORAGE-DIARY LIGHT [E034]", "Bật đèn?"],
      [35, 11, 8, "PROP-STORAGE-LIGHT SWITCH [E035]", "Bật đèn?"],
      [36, 4, 6, "PROP-STORAGE-FAIRYTALE BOOKS [E036]", "Một tủ sách truyện cổ tích bị vẽ bút màu tèm lem lên."],
      [37, 4, 26, "PROP-HOME-KEY SEARCH [E037]", "Có lẽ chìa khóa phòng dưới cầu thang được giấu ở đâu đó quanh đây."],
      [38, 5, 26, "PROP-HOME-SNACK CABINET [E038]", "Hồi bé mình từng lén giấu đồ ăn vặt vào đây."],
      [39, 4, 11, "PROP-HOME-TRANSFORM DEVICES [E039]", "Tủ lưu trữ các thiết bị biến hình của mình."],
      [40, 9, 11, "PROP-HOME-POSEIDON TROPHIES [E040]", "Tủ lưu trữ chiến tích mà mình chưa kịp gửi cho Poseidon."]
    ]
    entries.each do |id, x, y, name, line|
      e = clone_event(template, id, name, x, y, [event_command(101, 0, ["", 0, 0, 2]), event_command(401, 0, [line]), event_command(0, 0, [])])
      page = e.instance_variable_get(:@pages).first
      page.instance_variable_set(:@trigger, 0)
      page.instance_variable_set(:@priority_type, 1)
      events[id] = e
    end
    [2, 3, 4, 5, 6].each { |id| events.delete(id) }
    map.instance_variable_set(:@events, events)
    save_data(path, map)
    puts "MAP022_INTERACTIONS|rebuilt=#{entries.size}|coordinates=docx|placeholder_events_removed=5"
  end

  def correct_map022_source_scope
    path = "Data/Map022.rvdata2"
    map = load_data(path)
    events = map.instance_variable_get(:@events) || {}
    # E028-E036 were incorrectly imported from Tương tác phòng kho.docx.
    # Map022 is reserved for Tương tác nhà Hải Quỳ.docx only.
    (28..36).each { |id| events.delete(id) }
    # Preserve the multi-line interaction as one event, not three events.
    # The wine shelf is (009,026); all three lines belong to this event.
    template = events[19] || events[1]
    if template
      events[41] = clone_event(template, 41, "LORE-HOME-WINE SHELF [E041]", 9, 26, [
        event_command(101, 0, ["", 0, 0, 2]),
        event_command(401, 0, ["Kệ trưng bày rượu."]),
        event_command(401, 0, ["Mình hay trộm rượu của Popo để uống cho tới ngày mình bị dị ứng đồ cồn."]),
        event_command(401, 0, ["Rượu táo nho uống ngon lắm luôn!"]),
        event_command(0, 0, [])
      ])
    end
    map.instance_variable_set(:@events, events)
    save_data(path, map)
    puts "MAP022_SCOPE|source=Tuong_tac_nha_Hai_Quy|storage_events_removed=9|grouped_dialogue=true"
  end

  def reflow_map022_messages
    path = "Data/Map022.rvdata2"
    map = load_data(path)
    max_normal = 42
    max_pop = 34
    events = map.instance_variable_get(:@events) || {}
    events.each_value do |event|
      next unless event
      (event.instance_variable_get(:@pages) || []).each do |page|
        list = page.instance_variable_get(:@list) || []
        out = []
        list.each do |command|
          if command.instance_variable_get(:@code) == 401
            text = (command.instance_variable_get(:@parameters) || [""])[0].to_s
            tag = ""
            if text =~ /^(\\bm\[\d+\]\s*)/
              tag = Regexp.last_match(1)
              text = text.sub(/^#{Regexp.escape(tag)}/, "")
            end
            limit = tag.empty? ? max_normal : max_pop
            words = text.split(/\s+/)
            lines = []
            current = ""
            words.each do |word|
              if current.empty?
                current = word
              elsif (current.length + 1 + word.length) <= limit
                current += " " + word
              else
                lines << current
                current = word
              end
            end
            lines << current unless current.empty?
            lines = [""] if lines.empty?
            lines.each_with_index do |line, index|
              params = [index == 0 ? tag + line : line]
              out << event_command(401, command.instance_variable_get(:@indent), params)
            end
          else
            out << command
          end
        end
        page.instance_variable_set(:@list, out)
      end
    end
    save_data(path, map)
    puts "MAP022_TEXT|reflowed=true|normal_width=#{max_normal}|pop_width=#{max_pop}"
  end

  def rebuild_map022_from_provided_house_text
    path = "Data/Map022.rvdata2"
    map = load_data(path)
    old = map.instance_variable_get(:@events) || {}
    template = old[10] || old[1]
    raise "Map022 template missing" unless template
    events = {}
    events[1] = old[1] if old[1] # keep route arrival scene
    events[8] = old[8] if old[8] # keep route letter gate
    next_id = 10
    one = lambda do |x, y, name, lines|
      list = [event_command(101, 0, ["", 0, 0, 2])]
      lines.each { |line| list << event_command(401, 0, [line]) }
      list << event_command(0, 0, [])
      e = clone_event(template, next_id, name, x, y - 1, list)
      page = e.instance_variable_get(:@pages).first
      page.instance_variable_set(:@trigger, 0); page.instance_variable_set(:@priority_type, 1)
      events[next_id] = e; next_id += 1
    end
    multi = lambda do |x, y, name, page_lines|
      pages = []
      page_lines.each_with_index do |lines, index|
        list = [event_command(101, 0, ["", 0, 0, 2])]
        lines.each { |line| list << event_command(401, 0, [line]) }
        list << event_command(123, 0, [("A".ord + index).chr, 0]) if index < page_lines.length - 1
        list << event_command(0, 0, [])
        page = clone_event(template, next_id, name, x, y - 1, list).instance_variable_get(:@pages).first
        page.instance_variable_set(:@trigger, 0); page.instance_variable_set(:@priority_type, 1)
        condition = page.instance_variable_get(:@condition)
        if index > 0
          condition.instance_variable_set(:@self_switch_valid, true)
          condition.instance_variable_set(:@self_switch_ch, ("A".ord + index - 1).chr)
        end
        pages << page
      end
      e = clone_event(template, next_id, name, x, y - 1, [])
      e.instance_variable_set(:@pages, pages)
      events[next_id] = e; next_id += 1
    end
    # Exact coordinates from Tương tác nhà Hải Quỳ.docx; Y is shifted by -1.
    one.call(15, 10, "PROP-HOME-SINK", ["Bồn rửa tay."])
    one.call(16, 10, "TRANSFER-HOME-POPO-WORKSHOP", ["Lối vào phòng sửa chữa của Popo."])
    one.call(17, 10, "TRANSFER-HOME-POPO-WORKSHOP", ["Lối vào phòng sửa chữa của Popo."])
    one.call(14, 11, "PROP-HOME-WASHING-MACHINE", ["Máy giặt cửa trên. Hồi bé mình hay chui vào đây ngủ."])
    one.call(10, 10, "PROP-HOME-SIMULATED-WINDOW", ["Cửa sổ mô phỏng này vẫn còn hoạt động tốt. Ánh nắng chiếu vào dễ chịu quá."])
    one.call(8, 11, "PROP-HOME-BATH", ["Hồi bé mình hay ngâm mình trong bồn tắm này lắm.", "Có lần mình ngâm tới năm tiếng, da tong teo hết cả."])
    multi.call(7, 33, "LORE-HOME-FAMILY-ALBUM", [["Ảnh chân dung và album ảnh của anh ba và chị tư được trưng lên đây.", "Kế bên là một bình hoa cúc trắng."], ["OniOnii kể lại, hồi ấy ai cũng bảo mình trông giống chị em sinh đôi với chị tư."], ["OniOnii mới quyết định cắt tóc cho mình. Dè đâu trong lúc cắt tóc, cây kéo sượt qua tai mình, làm mình khóc ré lên, tóc từ màu xanh nhạt chuyển thành xanh đậm."], ["Thật kỳ lạ, dù trong đầu mình chẳng có chút ký ức gì về hình dạng này.", "Nhưng mình vẫn biến hình được, lại còn có cảm giác quen thuộc khó tả."]])
    one.call(6, 33, "PROP-HOME-LAMP", ["Cây đèn này được Popo sửa liên tục."])
    one.call(5, 33, "PROP-HOME-FIRST-AID", ["Tủ đựng thuốc sơ cứu của Momo."])
    one.call(4, 33, "PROP-HOME-POPO-TEA", ["Tủ đựng đủ kiểu ly tách, ấm trà của Popo. Trong đó có một ngăn toàn trà được xếp gọn."])
    one.call(3, 33, "PROP-HOME-MOMO-BAGS", ["Tủ đựng nhiều loại túi được Momo xếp gọn gàng. Tầng trên là túi vải, tầng dưới là túi sợi tổng hợp."])
    one.call(8, 33, "PROP-HOME-INCENSE", ["Tủ đựng nhang, đèn cầy, trầm hương."])
    one.call(4, 37, "PROP-HOME-COAT-CABINET", ["Tủ treo nón áo, giày dép có chức năng tự động sấy khô."])
    one.call(4, 38, "PROP-HOME-COAT-CABINET", ["Tủ treo nón áo, giày dép có chức năng tự động sấy khô."])
    one.call(12, 38, "PROP-HOME-ONI-BOOTS", ["Ủng của Oni Onii."])
    one.call(17, 37, "PROP-HOME-GARDEN-CABINET", ["Tủ đựng các dụng cụ trồng cây và các loại phân bón của Popo."])
    one.call(17, 38, "PROP-HOME-GARDEN-CABINET", ["Tủ đựng các dụng cụ trồng cây và các loại phân bón của Popo."])
    one.call(16, 32, "PROP-HOME-MOVIES", ["Mình và OniOnii hay mua đĩa phim về xem. Để xem OniOnii đang xem gì nào?", "Ồ, dạo này ổng đang xem lại Garfield à?"])
    one.call(6, 29, "LORE-HOME-ATLANTIS-SUNSET", ["Ảnh chụp hoàng hôn thành phố Atlantis."])
    one.call(5, 29, "LORE-HOME-MAGNOLIA", ["Ảnh chụp chậu hoa mẫu lan."])
    one.call(4, 29, "LORE-HOME-FAMILY-AWARD", ["Bằng khen của anh ba. Popo kể rằng anh ba là người duy nhất thừa hưởng khả năng bắn súng của Popo."])
    multi.call(3, 29, "LORE-HOME-GLITCH-PHOTO", [["Ảnh chụp về…arg…", "Mình…không biết.", "Nhìn quen lắm nhưng không nhớ nổi tên."], ["Khu vực này…Là…", "Mình không thể nhớ được.", "Cảm giác có cây đinh trong đầu mình vậy."], ["Đã bảo không muốn nhớ rồi mà sao cứ ép người ta nhớ thế hả?", "Đôi mắt này nhiều chuyện quá rồi đó."], ["Không nhớ."]])
    one.call(13, 26, "LORE-HOME-CHILD-PHOTO", ["Ảnh chụp hồi bé của mình."])
    one.call(12, 26, "LORE-HOME-FAMILY-PICNIC", ["Ảnh chụp cả gia đình đi dã ngoại."])
    one.call(11, 26, "LORE-HOME-FAMILY-PICNIC", ["Ảnh chụp cả gia đình đi dã ngoại."])
    one.call(10, 26, "LORE-HOME-WATER-LILY", ["Ảnh chụp hoa súng trắng."])
    one.call(9, 26, "LORE-HOME-WINE-SHELF", ["Kệ trưng bày rượu.", "Mình hay trộm rượu của Popo để uống cho tới ngày mình bị dị ứng đồ cồn.", "Rượu táo nho uống ngon lắm luôn!"])
    one.call(8, 26, "LORE-HOME-SNACK-CABINET", ["Hồi bé mình lén Momo nhét đồ ăn vặt mua ở ngoài cổng trường vào đây.", "Mình chưa kịp xơi thì đã bị tụi Tí Si ăn hết rồi!", "Cũng nhờ thế mà Popo mới biết nhà có Tí rồi tiến hành kế hoạch đuổi chúng nó ra ngoài."])
    (5..7).each { |x| one.call(x, 26, "PROP-HOME-POPO-BOOKS", ["Tủ sách dạy lái xe tăng và các loại tàu chiến của Popo."]) }
    multi.call(4, 26, "TRANSFER-HOME-STORAGE-LOCKED", [["Cửa này luôn bị khóa.", "Chắc là kho chứa đồ hay gì đấy."], ["Mình từng tò mò trong này có gì.", "Nhưng khi thấy Popo lấy đồ từ trong đây đem đi bán đồng nát thì mình mặc định rằng phòng này là phòng kho."], ["Mình nhớ là Momo từng cất chìa khóa phòng này ở cái tủ nào đó dưới đây."]])
    one.call(5, 17, "PROP-HOME-FOOD-FRIDGE", ["Tủ lạnh luôn đầy ắp thức ăn.", "Có một lần mình uống nhiều nước cam mà bị bệnh nên Momo không cho mình trữ nước cam đóng hộp nữa."])
    one.call(4, 17, "PROP-HOME-MICROWAVE", ["Nhìn tới lò vi sóng là lại nhớ tới bánh mì bơ tỏi.", "Mà nhớ tới bánh mì bơ tỏi thì cái bản mặt khó ưa của OniOnii xuất hiện trong đầu mình."])
    one.call(3, 17, "PROP-HOME-UTENSILS", ["Tủ dựng nhiều muỗng, đũa, nĩa, đĩa dùng một lần.", "Chúng được làm từ nguyên vật liệu ăn được.", "Đôi lúc đói, mình hay xuống đây lấy thật nhiều đĩa lên ăn. Giòn giòn như bánh tráng vậy."])
    (19..21).each { |y| one.call(4, y, "PROP-HOME-SPICES", ["Tủ gia vị."]) }
    one.call(6, 16, "PROP-HOME-NOODLES", ["Tủ mì ăn liền của OniOnii. Mình hay ăn ké mì của ổng.", "Mì trứng thịt kho chiên xù rất ngon.", "Pha mì nhé?"])
    one.call(7, 16, "PROP-HOME-SINK-KITCHEN", ["Bồn rửa."])
    one.call(8, 16, "PROP-HOME-KITCHEN-OVEN", ["Bếp và lò nướng."])
    one.call(9, 16, "PROP-HOME-NUT-MILK", ["Máy làm sữa hạt và lò nướng bánh."])
    one.call(10, 16, "PROP-HOME-CLEANING", ["Tủ đựng các loại nước rửa chén, lau sàn và bịch rác."])
    one.call(11, 16, "PROP-HOME-TRASH", ["Thùng rác."])
    one.call(12, 16, "SCN-HOME-NOODLE-MEAL", ["Bình thường giờ này là giờ ăn của gia đình mình.", "Mà Popo với Momo đi du lịch rồi! Mau mau úp mì cho Oni Onii và mình ăn mới được!"])
    map.instance_variable_set(:@events, events)
    save_data(path, map)
    puts "MAP022_PROVIDED_TEXT|events=#{events.size}|source=house_only|y_offset=-1|multi_pages=3,4"
  end

  def split_map022_message_boxes
    path = "Data/Map022.rvdata2"
    map = load_data(path)
    events = map.instance_variable_get(:@events) || {}
    max_chars = 30
    max_lines = 3
    events.each_value do |event|
      next unless event
      (event.instance_variable_get(:@pages) || []).each do |page|
        src = page.instance_variable_get(:@list) || []
        out = []
        i = 0
        while i < src.length
          command = src[i]
          if command.instance_variable_get(:@code) == 101
            face = command.instance_variable_get(:@parameters) || ["", 0, 0, 2]
            texts = []
            j = i + 1
            while j < src.length && src[j].instance_variable_get(:@code) == 401
              texts << (src[j].instance_variable_get(:@parameters) || [""])[0].to_s
              j += 1
            end
            # Wrap every source line, preserving Pop Message tag on first line.
            wrapped = []
            texts.each do |text|
              tag = ""
              if text =~ /^(\\bm\[\d+\]\s*)/
                tag = Regexp.last_match(1)
                text = text.sub(/^#{Regexp.escape(tag)}/, "")
              end
              words = text.split(/\s+/)
              line = ""
              words.each do |word|
                if line.empty?
                  line = word
                elsif line.length + word.length + 1 <= max_chars
                  line += " " + word
                else
                  wrapped << line
                  line = word
                end
              end
              wrapped << line unless line.empty?
              wrapped[0] = tag + wrapped[0] if !tag.empty? && wrapped[0]
            end
            wrapped = [""] if wrapped.empty?
            wrapped.each_slice(max_lines) do |chunk|
              out << event_command(101, command.instance_variable_get(:@indent), face)
              chunk.each { |line| out << event_command(401, command.instance_variable_get(:@indent), [line]) }
            end
            i = j
          else
            out << command
            i += 1
          end
        end
        page.instance_variable_set(:@list, out)
      end
    end
    save_data(path, map)
    puts "MAP022_BOXES|split=true|chars=#{max_chars}|lines_per_box=#{max_lines}"
  end

  def fix_map022_scene_and_layer
    path = "Data/Map022.rvdata2"
    map = load_data(path)
    events = map.instance_variable_get(:@events) || {}
    events.delete(8) # letter belongs to the separate warehouse map
    if events[1]
      event = events[1]
      event.instance_variable_set(:@x, 4)
      event.instance_variable_set(:@y, 4)
      page = event.instance_variable_get(:@pages).first
      list = page.instance_variable_get(:@list) || []
      list.reject! do |c|
        c.instance_variable_get(:@code) == 401 && ((c.instance_variable_get(:@parameters) || [])[0].to_s.include?("\\bm["))
      end
      unless list.any? { |c| (c.instance_variable_get(:@parameters) || [])[0].to_s.include?("HQ_House_Top") }
        list.unshift(event_command(355, 0, ["layer(22,0,[\"HQ_House_Top\",0,0,255,200,0,0,0])"]))
        list.insert(1, event_command(655, 0, ["refresh_layers"]))
      end
      page.instance_variable_set(:@list, list)
    end
    map.instance_variable_set(:@events, events)
    save_data(path, map)
    puts "MAP022_SCENE|main_xy=4,4|top_layer=true|pop_npc_removed=true|letter_removed=true"
  end

  def restore_map022_arrival_dialogue
    path = "Data/Map022.rvdata2"
    map = load_data(path)
    events = map.instance_variable_get(:@events) || {}
    main = events[1]
    template = events[10] || main
    raise "Map022 arrival event missing" unless main
    raise "Map022 event template missing" unless template

    # E007 is the actual speaker/anchor used by both Pop Message (\bm[7])
    # and the camera target stored in Variable 40.  Deleting this event makes
    # both systems dereference a nil map event.
    npc = clone_event(template, 7, "NPC-PAULIE HOME DIALOGUE [E007]", 10, 8, [
      event_command(0, 0, [])
    ])
    npc_page = npc.instance_variable_get(:@pages).first
    npc_page.instance_variable_set(:@trigger, 0)
    npc_page.instance_variable_set(:@priority_type, 1)
    events[7] = npc

    # Rebuild the scene command list from scratch so no orphaned continuation
    # lines from the previous broken edit can survive.
    commands = [
      event_command(355, 0, ["layer(22,0,[\"HQ_House_Top\",0,0,255,200,0,0,0])"]),
      event_command(655, 0, ["refresh_layers"]),
      event_command(355, 0, ["# ATLANTIS_DIALOGUE: CE1 player, CE2 event via V40, CE3 reset"]),
      event_command(117, 0, [1]),
      event_command(122, 0, [40, 40, 0, 0, 7]),
      event_command(117, 0, [2]),
      event_command(101, 0, ["", 0, 0, 2]),
      event_command(401, 0, ["\\bm[7] Đã lâu rồi mới thấy"]),
      event_command(401, 0, ["em về nhà đấy."]),
      event_command(117, 0, [1]),
      event_command(101, 0, ["", 0, 0, 2]),
      event_command(401, 0, ["\\bm[0] Em chỉ nghỉ một lát"]),
      event_command(401, 0, ["rồi xuống Atlantis mua"]),
      event_command(401, 0, ["sách phép thôi."]),
      event_command(101, 0, ["", 0, 0, 2]),
      event_command(401, 0, ["Cuối cùng cũng về tới nhà rồi."]),
      event_command(401, 0, ["Mình nghỉ một lát, sửa"]),
      event_command(401, 0, ["Brilliant Anchor rồi sẽ xuống"]),
      event_command(101, 0, ["", 0, 0, 2]),
      event_command(401, 0, ["Atlantis mua sách phép."]),
      event_command(401, 0, ["Không biết căn nhà này còn"]),
      event_command(401, 0, ["giữ lại bao nhiêu thứ mà"]),
      event_command(101, 0, ["", 0, 0, 2]),
      event_command(401, 0, ["mình đã quên."]),
      event_command(117, 0, [3]),
      event_command(122, 0, [30, 30, 0, 0, 1]),
      event_command(123, 0, ["A", 0]),
      event_command(0, 0, [])
    ]

    first_page = main.instance_variable_get(:@pages).first
    first_page.instance_variable_set(:@list, commands)
    first_page.instance_variable_set(:@trigger, 3)
    first_page.instance_variable_set(:@priority_type, 0)

    # Self-switch A must select a later blank page; otherwise an Autorun page
    # remains active forever even after setting the self-switch.
    done_page = Marshal.load(Marshal.dump(first_page))
    done_condition = done_page.instance_variable_get(:@condition)
    done_condition.instance_variables.each do |variable|
      value = done_condition.instance_variable_get(variable)
      done_condition.instance_variable_set(variable, false) if value == true || value == false
    end
    done_condition.instance_variable_set(:@self_switch_valid, true)
    done_condition.instance_variable_set(:@self_switch_ch, "A")
    done_page.instance_variable_set(:@trigger, 0)
    done_page.instance_variable_set(:@priority_type, 0)
    done_page.instance_variable_set(:@list, [event_command(0, 0, [])])
    main.instance_variable_set(:@pages, [first_page, done_page])

    map.instance_variable_set(:@events, events)
    save_data(path, map)
    puts "MAP022_ARRIVAL_RESTORED|npc=E007|pop=\\bm[7],\\bm[0]|camera=CE1,CE2,CE3|autorun_exit=self_switch_A"
  end

  def dump_actor_graphics
    actors = load_data("Data/Actors.rvdata2")
    actors.each_with_index do |actor, id|
      next unless actor
      puts "ACTOR|#{id}|#{actor.instance_variable_get(:@name)}|character=#{actor.instance_variable_get(:@character_name)}|index=#{actor.instance_variable_get(:@character_index)}|face=#{actor.instance_variable_get(:@face_name)}|face_index=#{actor.instance_variable_get(:@face_index)}"
    end
    Dir.glob("Data/Map[0-9][0-9][0-9].rvdata2").sort.each do |path|
      map = load_data(path)
      (map.instance_variable_get(:@events) || {}).each do |event_id, event|
        (event.instance_variable_get(:@pages) || []).each_with_index do |page, page_index|
          (page.instance_variable_get(:@list) || []).each do |command|
            next unless command.instance_variable_get(:@code) == 322
            puts "CHANGE_ACTOR_GRAPHIC|#{File.basename(path)}|E#{event_id}|P#{page_index + 1}|#{(command.instance_variable_get(:@parameters) || []).inspect}"
          end
        end
      end
    end
  end

  def dump_tilesets
    tilesets = load_data("Data/Tilesets.rvdata2")
    tilesets.each_with_index do |tileset, id|
      next unless tileset
      flags = tileset.instance_variable_get(:@flags)
      flag_values = if flags && flags.instance_variable_get(:@marshal_data)
        raw = flags.instance_variable_get(:@marshal_data)
        header = raw.unpack("l<5")
        raw.byteslice(20, header[4] * 2).unpack("S<*")
      else
        []
      end
      puts "TILESET|#{id}|#{tileset.instance_variable_get(:@name)}|mode=#{tileset.instance_variable_get(:@mode)}|names=#{(tileset.instance_variable_get(:@tileset_names) || []).inspect}|flag250=#{flag_values[250]}|flag251=#{flag_values[251]}"
    end
  end

  def dump_map_tiles(map_id)
    map = load_data("Data/Map%03d.rvdata2" % map_id)
    table = map.instance_variable_get(:@data)
    raw = table.instance_variable_get(:@marshal_data)
    dim, width, height, depth, size = raw.unpack("l<5")
    values = raw.byteslice(20, size * 2).unpack("s<*")
    puts "TABLE|dim=#{dim}|#{width}x#{height}x#{depth}|cells=#{size}"
    depth.times do |z|
      layer = values.slice(z * width * height, width * height)
      puts "LAYER|#{z}|unique=#{layer.tally.sort.to_h.inspect}"
      height.times do |y|
        row = width.times.map { |x| layer[y * width + x] }
        puts "ROW|#{z}|#{y}|#{row.join(',')}"
      end
    end
  end

  def rebuild_map022_exact_script
    path = "Data/Map022.rvdata2"
    map = load_data(path)
    old_events = map.instance_variable_get(:@events) || {}
    main = old_events[1]
    template = old_events[10] || main
    raise "Map022 arrival event missing" unless main
    raise "Map022 event template missing" unless template

    wrap = lambda do |text, width|
      words = text.split(/\s+/)
      lines = []
      current = ""
      words.each do |word|
        if current.empty?
          current = word
        elsif current.length + 1 + word.length <= width
          current += " " + word
        else
          lines << current
          current = word
        end
      end
      lines << current unless current.empty?
      lines
    end

    # Each supplied paragraph stays verbatim. Only whitespace at display line
    # boundaries changes so the text fits VX Ace's message windows.
    message = lambda do |paragraphs, tag = nil, width = 30|
      result = []
      paragraphs.each do |paragraph|
        lines = wrap.call(paragraph, width)
        lines.each_slice(3) do |chunk|
          result << event_command(101, 0, ["", 0, 0, 2])
          chunk.each_with_index do |line, index|
            shown = index.zero? && tag ? "#{tag}#{line}" : line
            result << event_command(401, 0, [shown])
          end
        end
      end
      result
    end

    clean_condition = lambda do |condition|
      condition.instance_variables.each do |variable|
        value = condition.instance_variable_get(variable)
        condition.instance_variable_set(variable, false) if value == true || value == false
      end
    end

    make_page = lambda do |commands, self_switch = nil, switch_id = nil|
      page = Marshal.load(Marshal.dump(template.instance_variable_get(:@pages).first))
      condition = page.instance_variable_get(:@condition)
      clean_condition.call(condition)
      if self_switch
        condition.instance_variable_set(:@self_switch_valid, true)
        condition.instance_variable_set(:@self_switch_ch, self_switch)
      end
      if switch_id
        condition.instance_variable_set(:@switch1_valid, true)
        condition.instance_variable_set(:@switch1_id, switch_id)
      end
      page.instance_variable_set(:@trigger, 0)
      page.instance_variable_set(:@priority_type, 1)
      page.instance_variable_set(:@list, commands + [event_command(0, 0, [])])
      page
    end

    make_event = lambda do |id, name, x, source_y, pages|
      event = Marshal.load(Marshal.dump(template))
      event.instance_variable_set(:@id, id)
      event.instance_variable_set(:@name, "#{name} [E%03d]" % id)
      event.instance_variable_set(:@x, x)
      event.instance_variable_set(:@y, source_y - 1)
      event.instance_variable_set(:@pages, pages)
      event
    end

    self_switch_command = lambda do |letter|
      event_command(123, 0, [letter, 0])
    end

    change_hq_graphic = lambda do |name|
      event_command(322, 0, [3, name, 0, "Face1", 0])
    end

    shake = lambda do
      event_command(225, 0, [4, 6, 20, true])
    end

    turn_player_around = lambda do
      route = RPG::MoveRoute.allocate
      route.instance_variable_set(:@repeat, false)
      route.instance_variable_set(:@skippable, true)
      route.instance_variable_set(:@wait, true)
      turn = RPG::MoveCommand.allocate
      turn.instance_variable_set(:@code, 22)
      turn.instance_variable_set(:@parameters, [])
      finish = RPG::MoveCommand.allocate
      finish.instance_variable_set(:@code, 0)
      finish.instance_variable_set(:@parameters, [])
      route.instance_variable_set(:@list, [turn, finish])
      event_command(205, 0, [-1, route])
    end

    # Entry scene: exact text from Xuống Atlantis Mua Sách Phép.docx.
    scene = [
      event_command(355, 0, ["layer(22,0,[\"HQ_House_Top\",0,0,255,200,0,0,0])"]),
      event_command(655, 0, ["refresh_layers"]),
      change_hq_graphic.call("$HaiQuyGlitch_Base"),
      event_command(117, 0, [1])
    ]
    scene += message.call(["Đúng là không có nơi nào thoải mái bằng nhà!"])
    scene += message.call(["Vừa bước vào nhà, tôi thấy đôi ủng của Oni Onii trên kệ giày. Chứng tỏ ổng đang ở nhà!"])
    scene += message.call(["HAI ƠI, EM VỀ RỒI!!! NHÀ CÓ GÌ ĂN KHÔNG HAI???"], "\\bm[0] ", 24)
    scene += [event_command(122, 0, [40, 40, 0, 0, 7]), event_command(117, 0, [2])]
    scene += message.call(["Pha mì ăn đỡ đi!!"], "\\bm[7] ", 24)
    scene += [event_command(117, 0, [1])]
    scene += message.call(["Popo với Momo đâu haiiii"], "\\bm[0] ", 24)
    scene += [event_command(117, 0, [2])]
    scene += message.call(["Đi du lịch rồi!!"], "\\bm[7] ", 24)
    scene += [event_command(117, 0, [1])]
    scene += message.call(["Ỏ dị hả! Hai ăn hông thì em úp mì luôn?"], "\\bm[0] ", 24)
    scene += [event_command(117, 0, [2])]
    scene += message.call(["Có! Úp mì trứng thịt kho chiên xù. Thêm hai cái trứng chiên nữa."], "\\bm[7] ", 24)
    scene += [event_command(117, 0, [1])]
    scene += message.call(["Chắc chắn ổng đang nằm ì trên giường!!"])
    scene += [
      event_command(117, 0, [3]),
      event_command(122, 0, [30, 30, 0, 0, 1]),
      event_command(123, 0, ["A", 0]),
      event_command(0, 0, [])
    ]
    main_page = main.instance_variable_get(:@pages).first
    clean_condition.call(main_page.instance_variable_get(:@condition))
    main_page.instance_variable_set(:@trigger, 3)
    main_page.instance_variable_set(:@priority_type, 0)
    main_page.instance_variable_set(:@list, scene)
    done_page = Marshal.load(Marshal.dump(main_page))
    done_condition = done_page.instance_variable_get(:@condition)
    clean_condition.call(done_condition)
    done_condition.instance_variable_set(:@self_switch_valid, true)
    done_condition.instance_variable_set(:@self_switch_ch, "A")
    done_page.instance_variable_set(:@trigger, 0)
    done_page.instance_variable_set(:@priority_type, 0)
    done_page.instance_variable_set(:@list, [event_command(0, 0, [])])
    main.instance_variable_set(:@name, "SCN-ATL-002 ARRIVE HOME [E001]")
    main.instance_variable_set(:@x, 4)
    main.instance_variable_set(:@y, 4)
    main.instance_variable_set(:@pages, [main_page, done_page])

    # E007 is Oni Onii/Paulie's Pop Message and camera anchor. Its location is
    # a scene placeholder until the bed coordinate is confirmed in-editor.
    npc = clone_event(template, 7, "NPC-ONIONII SCENE ANCHOR [E007]", 10, 8, [event_command(0, 0, [])])
    npc_page = npc.instance_variable_get(:@pages).first
    npc_page.instance_variable_set(:@trigger, 0)
    npc_page.instance_variable_set(:@priority_type, 1)

    events = {1 => main}
    events[2] = old_events[2] if old_events[2] # RegionStairs map setup, not story content.
    events[7] = npc
    next_id = 10
    add_one = lambda do |x, y, name, paragraphs, extra = []|
      commands = message.call(paragraphs) + extra
      page = make_page.call(commands)
      events[next_id] = make_event.call(next_id, name, x, y, [page])
      next_id += 1
    end
    add_multi = lambda do |x, y, name, command_sets|
      pages = command_sets.each_with_index.map do |commands, index|
        if index < command_sets.length - 1
          commands = commands + [self_switch_command.call(("A".ord + index).chr)]
        end
        make_page.call(commands, index.zero? ? nil : ("A".ord + index - 1).chr)
      end
      events[next_id] = make_event.call(next_id, name, x, y, pages)
      next_id += 1
    end

    add_one.call(15, 10, "PROP-HOME-SINK", ["Bồn rửa tay."])
    add_one.call(16, 10, "TRANSFER-HOME-POPO-WORKSHOP", ["Lối vào phòng sửa chữa của Popo."])
    add_one.call(17, 10, "TRANSFER-HOME-POPO-WORKSHOP", ["Lối vào phòng sửa chữa của Popo."])
    add_one.call(14, 11, "PROP-HOME-WASHING-MACHINE", ["Máy giặt cửa trên. Hồi bé mình hay chui vào đây ngủ."])
    add_one.call(10, 10, "PROP-HOME-SIMULATED-WINDOW", ["Cửa sổ mô phỏng này vẫn còn hoạt động tốt. Ánh nắng chiếu vào dễ chịu quá."])
    add_one.call(8, 11, "PROP-HOME-BATH", ["Hồi bé mình hay ngâm mình trong bồn tắm này lắm.", "Có lần mình ngâm tới năm tiếng, da tong teo hết cả."])

    album = message.call([
      "Ảnh chân dung và album ảnh của anh ba và chị tư được trưng lên đây. Kế bên là một bình hoa cúc trắng.",
      "OniOnii kể lại, hồi ấy ai cũng bảo mình trông giống chị em sinh đôi với chị tư.",
      "OniOnii mới quyết định cắt tóc cho mình. Dè đâu trong lúc cắt tóc, cây kéo sượt qua tai mình, làm mình khóc ré lên, tóc từ màu xanh nhạt chuyển thành xanh đậm."
    ])
    album << change_hq_graphic.call("$HaiQuyAtHome_Base")
    album += message.call([
      "Thật kỳ lạ, dù trong đầu mình chẳng có chút ký ức gì về hình dạng này.",
      "Nhưng mình vẫn biến hình được, lại còn có cảm giác quen thuộc khó tả."
    ])
    album_page = make_page.call(album)
    events[next_id] = make_event.call(next_id, "LORE-HOME-FAMILY-ALBUM", 7, 33, [album_page])
    next_id += 1

    add_one.call(6, 33, "PROP-HOME-LAMP", ["Cây đèn này được Popo sửa liên tục."])
    add_one.call(5, 33, "PROP-HOME-FIRST-AID", ["Tủ đựng thuốc sơ cứu của Momo."])
    add_one.call(4, 33, "PROP-HOME-POPO-TEA", ["Tủ đựng đủ kiểu ly tách, ấm trà của Popo. Trong đó có một ngăn toàn trà được xếp gọn."])
    add_one.call(3, 33, "PROP-HOME-MOMO-BAGS", ["Tủ đựng nhiều loại túi được Momo xếp gọn gàng. Tầng trên là túi vải, tầng dưới là túi được làm từ sợi tổng hợp thân thiện với môi trường."])

    incense_normal = make_page.call(message.call(["Tủ đựng nhang, đèn cầy, trầm hương."]))
    incense_key = make_page.call(message.call(["Ồ, chìa khóa phòng dưới cầu thang đây rồi!"]), nil, 37)
    events[next_id] = make_event.call(next_id, "PROP-HOME-INCENSE-KEY", 8, 33, [incense_normal, incense_key])
    next_id += 1

    add_one.call(4, 37, "PROP-HOME-COAT-CABINET", ["Tủ treo nón áo, giày dép có chức năng tự động sấy khô."])
    add_one.call(4, 38, "PROP-HOME-COAT-CABINET", ["Tủ treo nón áo, giày dép có chức năng tự động sấy khô."])
    add_one.call(12, 38, "PROP-HOME-ONI-BOOTS", ["Ủng của Oni Onii."])
    add_one.call(17, 37, "PROP-HOME-GARDEN-CABINET", ["Tủ đựng các dụng cụ trồng cây và các loại phân bón của Popo."])
    add_one.call(17, 38, "PROP-HOME-GARDEN-CABINET", ["Tủ đựng các dụng cụ trồng cây và các loại phân bón của Popo."])
    add_one.call(16, 32, "PROP-HOME-MOVIES", ["Mình và OniOnii hay mua đĩa phim về xem. Để xem OniOnii có mua thêm đĩa nào mới không?", "Ồ, dạo này ổng đang xem lại Garfield à?"])
    add_one.call(6, 29, "LORE-HOME-ATLANTIS-SUNSET", ["Ảnh chụp hoàng hôn thành phố Atlantis."])
    add_one.call(5, 29, "LORE-HOME-MAGNOLIA", ["Ảnh chụp chậu hoa mẫu lan."])
    add_one.call(4, 29, "LORE-HOME-FAMILY-AWARD", ["Bằng khen của anh ba. Popo kể rằng anh ba là người duy nhất thừa hưởng được khả năng bắn súng của Popo và mãi tự hào về anh ấy."])

    glitch_1 = message.call(["Ảnh chụp về…arg…"]) + [shake.call] + message.call(["Mình…không biết.", "Nhìn quen lắm nhưng không nhớ nổi tên."])
    glitch_2 = message.call(["Khu vực này…Là…"]) + [shake.call] + message.call(["Mình không thể nhớ được."]) + [shake.call] + message.call(["Cảm giác có cây đinh trong đầu mình vậy."])
    glitch_3 = [turn_player_around.call] + message.call(["Đã bảo không muốn nhớ rồi mà sao cứ ép người ta nhớ thế hả?", "Đôi mắt này nhiều chuyện quá rồi đó."])
    glitch_4 = message.call(["Không nhớ."])
    add_multi.call(3, 29, "LORE-HOME-GLITCH-PHOTO", [glitch_1, glitch_2, glitch_3, glitch_4])

    add_one.call(13, 26, "LORE-HOME-CHILD-PHOTO", ["Ảnh chụp hồi bé của mình."])
    add_one.call(12, 26, "LORE-HOME-FAMILY-PICNIC", ["Ảnh chụp cả gia đình đi dã ngoại."])
    add_one.call(11, 26, "LORE-HOME-FAMILY-PICNIC", ["Ảnh chụp cả gia đình đi dã ngoại."])
    add_one.call(10, 26, "LORE-HOME-WATER-LILY", ["Ảnh chụp hoa súng trắng."])
    add_one.call(9, 26, "LORE-HOME-WINE-SHELF", ["Kệ trưng bày rượu.", "Mình hay trộm rượu của Popo để uống cho tới ngày mình bị dị ứng đồ cồn.", "Rượu táo nho uống ngon lắm luôn!"])
    add_one.call(8, 26, "LORE-HOME-SNACK-CABINET", ["Hồi bé mình lén Momo nhét đồ ăn vặt mua ở ngoài cổng trường vào đây.", "Mình chưa kịp xơi thì đã bị tụi Tí Si ăn hết rồi!", "Cũng nhờ thế mà Popo mới biết nhà có Tí rồi tiến hành kế hoạch đuổi chúng nó ra ngoài."])
    (5..7).each { |x| add_one.call(x, 26, "PROP-HOME-POPO-BOOKS", ["Tủ sách dạy lái xe tăng và các loại tàu chiến của Popo."]) }

    door_1 = message.call(["Cửa này luôn bị khóa.", "Chắc là kho chứa đồ hay gì đấy."])
    door_2 = message.call(["Mình từng tò mò trong này có gì.", "Nhưng khi thấy Popo lấy đồ từ trong đây đem đi bán đồng nát thì mình mặc định rằng phòng này là phòng kho."])
    door_3 = message.call(["Mình nhớ là Momo từng cất chìa khóa phòng này ở cái tủ nào đó dưới đây."]) + [event_command(121, 0, [37, 37, 0])]
    add_multi.call(4, 26, "TRANSFER-HOME-STORAGE-LOCKED", [door_1, door_2, door_3])

    add_one.call(5, 17, "PROP-HOME-FOOD-FRIDGE", ["Tủ lạnh luôn đầy ắp thức ăn.", "Có một lần mình uống nhiều nước cam mà bị bệnh nên từ đó tới nay, Momo không cho mình trữ nước cam đóng hộp vô tủ lạnh nữa."])
    add_one.call(4, 17, "PROP-HOME-MICROWAVE", ["Nhìn tới lò vi song là lại nhớ tới bánh mì bơ tỏi.", "Mà nhớ tới bánh mì bơ tỏi thì cái bản mặt khó ưa của OniOnii xuất hiện trong đầu mình."])
    add_one.call(3, 17, "PROP-HOME-UTENSILS", ["Tủ dựng nhiều muỗng, đũa, nĩa, đĩa dùng một lần.", "Chúng được làm từ nguyên vật liệu ăn được.", "Đôi lúc đói, mình hay xuống đây lấy thật nhiều đĩa lên ăn. Giòn giòn như bánh tráng vậy."])
    [21, 20, 19].each { |y| add_one.call(4, y, "PROP-HOME-SPICES", ["Tủ gia vị."]) }
    add_one.call(6, 16, "PROP-HOME-NOODLES", ["Tủ mì ăn liền của OniOnii. Mình hay ăn ké mì của ổng.", "Mì trứng thịt kho chiên xù rất ngon.", "Pha mì nhé?"])
    add_one.call(7, 16, "PROP-HOME-SINK-KITCHEN", ["Bồn rửa."])
    add_one.call(8, 16, "PROP-HOME-KITCHEN-OVEN", ["Bếp và lò nướng."])
    add_one.call(9, 16, "PROP-HOME-NUT-MILK", ["Máy làm sữa hạt và lò nướng bánh."])
    add_one.call(10, 16, "PROP-HOME-CLEANING", ["Tủ đựng các loại nước rửa chén, lau sàn và bịch rác."])
    add_one.call(11, 16, "PROP-HOME-TRASH", ["Thùng rác."])
    add_one.call(12, 16, "SCN-HOME-NOODLE-MEAL", ["Bình thường giờ này là giờ ăn của gia đình mình.", "Mà Popo với Momo đi du lịch rồi! Mau mau úp mì cho Oni Onii và mình ăn mới được!"])

    map.instance_variable_set(:@events, events)
    save_data(path, map)

    system = load_data("Data/System.rvdata2")
    switches = system.instance_variable_get(:@switches) || []
    switches[37] = "HQ_STORAGE_KEY_HINT"
    system.instance_variable_set(:@switches, switches)
    save_data("Data/System.rvdata2", system)
    puts "MAP022_EXACT_SCRIPT|scene=source_exact|interactions=#{next_id - 10}|coordinates=y_minus_1|invented_dialogue=removed|switch37=HQ_STORAGE_KEY_HINT"
  end

  def complete_map022_house_sequence
    path = "Data/Map022.rvdata2"
    map = load_data(path)
    events = map.instance_variable_get(:@events) || {}
    template = events[10] || events[1]
    raise "Map022 exact interaction events missing" unless events[16] && events[21] && events[41] && events[48]

    # The album is the authored condition for changing form and unlocking the
    # basement-key path. This is a direct actor graphic change, not the custom
    # transformation system.
    album_page = events[16].instance_variable_get(:@pages).first
    album_list = album_page.instance_variable_get(:@list) || []
    album_list.insert([album_list.length - 1, 0].max, event_command(121, 0, [40, 40, 0])) unless album_list.any? { |c| c.instance_variable_get(:@code) == 121 && (c.instance_variable_get(:@parameters) || [])[0] == 40 }
    album_page.instance_variable_set(:@list, album_list)

    # E021: the key only exists after the third inspection of the locked door.
    incense_text = wrapped_message_commands(["Tủ đựng nhang, đèn cầy, trầm hương."])
    key_text = wrapped_message_commands(["Ồ, chìa khóa phòng dưới cầu thang đây rồi!"]) + [event_command(121, 0, [38, 38, 0])]
    events[21].instance_variable_set(:@pages, [
      page_from_template(template, incense_text),
      page_from_template(template, key_text, switch_id: 37),
      page_from_template(template, incense_text, switch_id: 38)
    ])

    # E041: page 3 reveals the key location; page 4 opens the separate store room.
    door_pages = events[41].instance_variable_get(:@pages)
    door_pages[2].instance_variable_set(:@list,
      wrapped_message_commands(["Mình nhớ là Momo từng cất chìa khóa phòng này ở cái tủ nào đó dưới đây."]) +
      [event_command(121, 0, [37, 37, 0]), event_command(0, 0, [])])
    door_open = [event_command(201, 0, [0, 26, 6, 4, 2, 0])]
    door_pages.reject! do |page|
      condition = page.instance_variable_get(:@condition)
      condition.instance_variable_get(:@switch1_valid) && condition.instance_variable_get(:@switch1_id) == 38
    end
    door_pages << page_from_template(template, door_open, switch_id: 38)
    events[41].instance_variable_set(:@pages, door_pages)

    focus_hq = lambda do |text|
      [event_command(117, 0, [1])] + wrapped_message_commands([text], tag: "\\bm[0] ", width: 24)
    end
    focus_oni = lambda do |text|
      [event_command(122, 0, [40, 40, 0, 0, 7]), event_command(117, 0, [2])] +
        wrapped_message_commands([text], tag: "\\bm[7] ", width: 24)
    end
    hit = lambda do
      [event_command(225, 0, [3, 7, 12, true])]
    end

    meal = []
    meal += wrapped_message_commands(["Tủ mì ăn liền của OniOnii. Mình hay ăn ké mì của ổng.", "Mì trứng thịt kho chiên xù rất ngon.", "Pha mì nhé?"])
    meal += focus_hq.call("Mì trứng thịt kho chiên xù còn đúng hai gói anh em mình ăn luôn!")
    meal += focus_oni.call("Mốt tao mua thêm vài thùng.")
    meal += focus_hq.call("Cả hạt với cát cho MSG với Black Pepper nữa!")
    meal += focus_oni.call("Cái đó thì mày tự mua đi!!")
    meal += focus_hq.call("Hoy mà haii, mua dùm điiii")
    meal += focus_oni.call("Mày lại đền bù thiệt hại gì gì đó nữa rồi à?")
    meal += focus_hq.call("Đ-Đâu có…")
    meal += focus_oni.call("Không đền bù mà mở mồm ra nhờ tao. Hay quá ha.")
    meal += focus_oni.call("Rồi lần này mày gây họa gì?")
    meal += focus_hq.call("…!!")
    meal += focus_hq.call("Hahaha…Em lỡ…ờm…Bắn nổ nóc tòa nhà hành chính ở khu Icarus…")
    meal += focus_oni.call("Gì?")
    meal += focus_hq.call("Haha…")
    meal += focus_oni.call("Mày…bắn nổ nóc tòa nhà hành chính…chỗ tao làm?")
    meal += focus_hq.call("Dạ…")
    meal += focus_oni.call("Mày báo hại tao phải tăng ca hôm đó!! Con nhóc ăn hại này!!") + hit.call
    meal += focus_hq.call("Ui da!!!")
    meal += focus_oni.call("Đáng lý hôm đó tao được nghỉ!! Nhờ ơn mày mà tao phải lết cái thân già này lên chỗ làm lúc 1h sáng!") + hit.call
    meal += focus_oni.call("Sao không dùng phép trói buộc tao dạy mày hả đầu đất!!")
    meal += focus_hq.call("E-Em không dùng kịp…!!")
    meal += focus_oni.call("Không dùng kịp cái gì mà không dùng kịp!!")
    meal += focus_oni.call("Mày ỷ nại vào trò bắn beam của mày thì có!!") + hit.call
    meal += focus_hq.call("Ui da!!")
    meal += focus_oni.call("Thiệt tình, không hiểu sao mày với chị Tư đều thích cái trò bắn beam vậy…!")
    meal += focus_hq.call("Hả gì! Chị Tư cũng thích bắn beam hả!")
    meal += focus_oni.call("Ừ. Tao nhớ khi ấy chị Tư cố học Aero Blast để làm được trò đó.")
    meal += focus_oni.call("Mỗi lần chị Tư đút cho tao ăn toàn hô “ Aero Twinkle Blast! “ xong đút tọt vào mồm tao.")
    meal += focus_hq.call("Trùng hợp vậy! Tôi cũng tạo ra chiêu thức “ Anemone Diamond Shower “ từ “ Aero Blast “ đó!")
    meal += focus_oni.call("Cho tới khi…")
    meal += focus_oni.call("Thôi.")
    meal += focus_oni.call("Kể nữa chắc không ăn nổi mì mất.")
    meal += [event_command(117, 0, [1])]
    meal += wrapped_message_commands(["Nói xong Oni Onii cắm cúi ăn. Bầu không khí đột ngột yên tĩnh.", "Tôi để ý rằng, mỗi lần Oni Onii, Popo và Momo tôi vô tình nhắc đến chị Tư thì ngay sau đó mọi người sẽ lập tức im bặt không nói thêm lời nào."])

    # Authored branch after the meal: both branches share the first two lines;
    # the transformed form adds OniOnii's extra reaction.
    meal += focus_oni.call("À mà phép biến hình của mày lại lỗi nữa hả? Xíu nữa kiểm tra lại mỏ neo biến hình đi, không là cạn ma lực đấy.")
    meal += focus_hq.call("Dạ, em biết rồi!!")
    # Conditional Branch: Switch 40 (album/form changed) is ON.
    meal << event_command(111, 0, [0, 40, 0])
    meal += focus_oni.call("Chứ nhìn cái dạng hồi còn bé này của mày làm tao ớn quá!").map { |c| c.instance_variable_set(:@indent, 1); c }
    meal += focus_hq.call("Người gì kỳ cục à!!").map { |c| c.instance_variable_set(:@indent, 1); c }
    wrapped_message_commands(["Thôi được rồi! Rửa đống chén này xong phải nghỉ ngơi một chút để còn sửa cái mỏ neo rồi còn đi mua sách nữa!!"], indent: 1).each { |c| meal << c }
    meal << event_command(411, 0, [])
    wrapped_message_commands(["Được rồi! Rửa đống chén này xong phải nghỉ ngơi một chút để còn sửa cái mỏ neo rồi còn đi mua sách nữa!!"], indent: 1).each { |c| meal << c }
    meal << event_command(412, 0, [])
    meal += [
      event_command(117, 0, [3]),
      event_command(121, 0, [41, 41, 0]),
      event_command(201, 0, [0, 23, 15, 37, 8, 0])
    ]
    meal_done = wrapped_message_commands(["Tủ mì ăn liền của OniOnii. Mình hay ăn ké mì của ổng.", "Mì trứng thịt kho chiên xù rất ngon."])
    events[48].instance_variable_set(:@pages, [
      page_from_template(template, meal),
      page_from_template(template, meal_done, switch_id: 41)
    ])

    map.instance_variable_set(:@events, events)
    save_data(path, map)

    system = load_data("Data/System.rvdata2")
    switches = system.instance_variable_get(:@switches) || []
    switches[37] = "HQ_KEY_HINT_READY"
    switches[38] = "HQ_STORAGE_KEY"
    switches[40] = "HQ_HOME_FORM_CHANGED"
    switches[41] = "HQ_MEAL_DONE"
    system.instance_variable_set(:@switches, switches)
    save_data("Data/System.rvdata2", system)
    puts "MAP022_COMPLETED|album=S40|key_hint=S37|key=S38|storage=Map026|meal=S41|next=Map023"
  end

  def create_map026_storage_room
    house = load_data("Data/Map022.rvdata2")
    map = Marshal.load(Marshal.dump(house))
    map.instance_variable_set(:@display_name, "Phòng kho nhà Hải Quỳ")
    map.instance_variable_set(:@width, 17)
    map.instance_variable_set(:@height, 13)
    map.instance_variable_set(:@tileset_id, 7)
    map.instance_variable_set(:@parallax_name, "Storage_Base")
    map.instance_variable_set(:@parallax_loop_x, false)
    map.instance_variable_set(:@parallax_loop_y, false)
    map.instance_variable_set(:@parallax_sx, 0)
    map.instance_variable_set(:@parallax_sy, 0)
    map.instance_variable_set(:@note, "Storage room parallax: Storage_Base + Storage_Top; source: Tương tác phòng kho.docx")

    width = 17
    height = 13
    depth = 4
    size = width * height * depth
    values = Array.new(size, 0)
    layer2 = 2 * width * height
    width.times do |x|
      height.times { |y| values[layer2 + y * width + x] = 251 }
    end
    passable = {}
    (4..11).each { |x| (4..8).each { |y| passable[[x, y]] = true } }
    passable[[6, 3]] = true
    passable.each_key { |x, y| values[layer2 + y * width + x] = 250 }
    table = Table.allocate
    table.instance_variable_set(:@marshal_data,
      [3, width, height, depth, size].pack("l<5") + values.pack("s<*"))
    map.instance_variable_set(:@data, table)

    source_template = (house.instance_variable_get(:@events) || {})[10] || (house.instance_variable_get(:@events) || {})[1]
    events = {}

    setup = [
      event_command(355, 0, ["layer(26,0,[\"Storage_Top\",0,0,255,200,0,0,0])"]),
      event_command(655, 0, ["refresh_layers"]),
      event_command(322, 0, [3, "$HaiQuyAtHome_Base", 0, "Face1", 0]),
      event_command(355, 0, ["map_effects.set_tone(-120,-120,-120,0,20)"]),
      event_command(123, 0, ["A", 0])
    ]
    setup_page = page_from_template(source_template, setup, trigger: 3, priority: 0)
    setup_done = page_from_template(source_template, [], trigger: 0, priority: 0, self_switch: "A")
    events[1] = event_from_pages(source_template, 1, "SYS-STORAGE-SETUP", 6, 4, [setup_page, setup_done])

    route = RPG::MoveRoute.allocate
    route.instance_variable_set(:@repeat, false)
    route.instance_variable_set(:@skippable, true)
    route.instance_variable_set(:@wait, true)
    moves = [35, 1, 1, 36, 0].map do |code|
      move = RPG::MoveCommand.allocate
      move.instance_variable_set(:@code, code)
      move.instance_variable_set(:@parameters, [])
      move
    end
    route.instance_variable_set(:@list, moves)
    rewind = [
      event_command(111, 0, [1, 33, 0, 3, 4]),
      event_command(355, 1, ["map_effects.setup_blur(8,100,-1,12)"]),
      event_command(655, 1, ["map_effects.set_linear_blur(180,24,12)"]),
      event_command(205, 1, [-1, route]),
      event_command(355, 1, ["map_effects.clear"]),
      event_command(411, 0, []),
      event_command(201, 1, [0, 22, 4, 26, 8, 0]),
      event_command(412, 0, [])
    ]
    exit_page = page_from_template(source_template, rewind, trigger: 1, priority: 0)
    events[2] = event_from_pages(source_template, 2, "TRANSFER-STORAGE-RETURN-REWIND", 6, 3, [exit_page])

    next_id = 10
    add_event = lambda do |name, x, y, pages|
      events[next_id] = event_from_pages(source_template, next_id, name, x, y - 1, pages)
      next_id += 1
    end
    simple = lambda do |name, x, y, paragraphs|
      add_event.call(name, x, y, [page_from_template(source_template, wrapped_message_commands(paragraphs))])
    end

    simple.call("PROP-STORAGE-RED-DRESS", 8, 7, ["Tủ quần áo cũ. Bên trong có treo bộ đầm xòe nhiều lớp màu đỏ của trẻ em. Chiếc đầm không bị dính chút bụi nào."])

    tapes = wrapped_message_commands(["Trong thùng này có rất nhiều băng cát-sét. Lấy băng nào?"])
    tape_names = ["Paulie biết đi", "Bánh Mì Bơ Tỏi", "Xích đu", "Cất băng"]
    tapes << event_command(102, 0, [tape_names, 3])
    tape_names.each_with_index do |name, index|
      tapes << event_command(402, 0, [index, name])
      tapes << event_command(122, 1, [32, 32, 0, 0, index == 3 ? 0 : index + 1])
    end
    tapes << event_command(404, 0, [])
    add_event.call("PROP-STORAGE-CASSETTE-BOX", 11, 7, [page_from_template(source_template, tapes)])

    tv_base = wrapped_message_commands(["Một chiếc TV cũ cùng một đầu băng cát-sét vẫn còn dùng được."])
    tape_paulie = tv_base + wrapped_message_commands([
      "“ Anh trai anh trai! Nhìn nè, em trai biết đi rồi! “",
      "“ Em trai giỏi quá! Thật may là anh ghi hình kịp lúc! “",
      "“ Popo! Momo! Paulie biết đi rồi! “",
      "“ Wow! Paulie giỏi quá!!! “"
    ])
    tape_bread = tv_base + wrapped_message_commands([
      "“ Aira! Em đang nấu gì đấy? “",
      "“ Bánh mì bơ tỏi! Em muốn cho Paulie ăn món tủ của anh! “",
      "“ Này, em biết là em bé không ăn được đồ cứng mà, đúng không? “",
      "“ Hơn nữa là bánh khét rồi kìa “",
      "“ ÚI!! “"
    ])
    tape_swing = tv_base + wrapped_message_commands([
      "“ Dahria Dahria!! Xem tớ nè!! “",
      "“ Wow, ngầu quá đi! Cậu đu được một vòng luôn! “",
      "“ Dahria! Aira! Hai đứa dừng lại ngay!! “",
      "“ Awawawa, Popo, cứu con với, con không ngừng đu được!! “"
    ])
    add_event.call("PROP-STORAGE-TV-CASSETTE", 7, 7, [
      page_from_template(source_template, tv_base),
      page_from_template(source_template, tape_paulie, variable_id: 32, variable_value: 1),
      page_from_template(source_template, tape_bread, variable_id: 32, variable_value: 2),
      page_from_template(source_template, tape_swing, variable_id: 32, variable_value: 3)
    ])

    simple.call("PROP-STORAGE-CAMERA-BOOKS", 6, 6, ["Nhiều sách báo cũ được cất ở đây. Đa phần nội dung nói về camera và cách quay phim."])
    light_commands = wrapped_message_commands(["Bật đèn?"]) + [
      event_command(121, 0, [39, 39, 0]),
      event_command(355, 0, ["map_effects.set_tone(0,0,0,0,20)"])
    ]
    add_event.call("PROP-STORAGE-LIGHT-A", 5, 7, [page_from_template(source_template, light_commands)])
    add_event.call("PROP-STORAGE-LIGHT-B", 11, 8, [page_from_template(source_template, light_commands)])

    diary = [
      "Cuốn nhật ký được viết nguệch ngoạc.",
      "“ Ôi nhật ký, đây là lần đầu tiên mình viết nhật ký. Không biết mình nên viết gì ta? Hồi hộp quá! Mình chưa bao giờ viết nhật ký hết! Dahria bảo rằng mình viết cái chi cũng được. Nhật ký, hôm nay Dahria đưa mình cho cậu, à đâu, phải là đưa cậu cho mình! Nhân dịp sinh nhật lần thứ tám! Mình hứa sẽ viết thật nhiều thật nhiều! “",
      "“ Nay mình được anh trai dẫn đi chơi đu quay! Nó hơi chóng mặt nhưng rất vui! Rồi tụi mình còn đi ăn kem, đi bộ trên những bậc thang dài với ánh hoàng hồn trải xuống. Mình sẽ nhớ mãi ngày hôm nay! Vui lắm! “",
      "“ Dahria rất thích làm ma pháp thiếu nữ trừ gian diệt bạo. Hôm nay mình với cô ấy hóa thân thành bộ đôi ma pháp thiếu nữ, đi loanh quanh khắp xóm để giúp đỡ mọi người. “",
      "“ Popo hôm nay không đến đón mình nên anh trai đã đạp xe đến đón mình về. Anh bảo rằng tụi mình sắp có em trai. Nhật ký ơi, mình sắp làm chị rồi! Mình cũng tò mò nên hỏi anh trai rằng Popo và Momo kiếm đâu được em trai vậy, thế là anh trai bật cười. Anh bảo rằng em trai được Poseidon đưa đến. Mình mong được gặp em trai quá. “",
      "“ Hôm nọ khi mình được Momo dắt đi học, có đi ngang qua một cửa tiệm trưng bày bộ váy đỏ nhiều vải gực gỡ, nhìn đẹp lắm. Mình ước gì được mặc nó trong dịp năm mới. “",
      "“ Ôi nhật ký ơi! Momo đã mua bộ váy đỏ đó cho mình! Đẹp quá trời là đẹp! Cả nhà hôm nay đi xem pháo hoa nữa. Nhưng lúc mình đi thì giày bị hỏng nên anh trai đã cõng mình, cũng vì thế mà mình mới nhìn rõ được pháo hoa. Đẹp quá. Mình ước gì năm mới kéo dài mãi, để ngày nào mình cũng được xem pháo hoa, được ăn bánh, cả nhà quay quần bên nhau! “",
      "“ Popo bảo với mình rằng anh trai đã đi đến một nơi xa ơi là xa để làm nhiệm vụ cho Poseidon. Mình không chịu đâu. Anh trai đã hứa sẽ luôn ở bên mình, chăm sóc mình mà…Sao lại bỏ đi? “",
      "“ Nhật ký ơi, hình như mình bị các giáo viên trong trường ghét rồi. Nhưng mình hứa là mình đã không làm gì cả. Hôm nay mình đến trường, các giáo viên nhìn mình với ánh mắt kỳ lạ lắm. “",
      "“ Bạn bè trong lớp mình bảo anh trai mình chết rồi, sẽ không quay về nữa đâu. Chết là gì? Họ chẳng biết gì cả, anh trai mình đang làm việc cho Poseidon mà! “"
    ]
    dark_diary = wrapped_message_commands(["Tối quá, mình chẳng đọc được gì cả"])
    add_event.call("LORE-STORAGE-AIRA-DIARY", 5, 8, [
      page_from_template(source_template, dark_diary),
      page_from_template(source_template, wrapped_message_commands(diary), switch_id: 39)
    ])

    simple.call("PROP-STORAGE-FAIRYTALES", 4, 6, ["Một tủ sách toàn truyện cổ tích bị vẽ bút màu tèm lem lên.", "Tự dưng mình lại nhớ câu chuyện “ kinh dị “ mà hồi bé Momo kể cho mình nghe trước khi mình đi ngủ…"])
    simple.call("LORE-STORAGE-DRAWING-ALBUM", 9, 7, ["Trong tủ sách có một cuốn album tranh vẽ bị phủ đầy bụi và mạng nhện. Mở ra xem?"])

    encrypted = [
      "Có một cuốn nhật ký bị mã hóa bằng phép thuật. Mở ra xem?",
      "“ Nhật ký, xin lỗi vì bỏ bê cậu trong kho một thời gian qua. Mình đã trưởng thành hơn, cuộc sống bộn bề thay đổi chóng mặt, nhất là trong tim mình. Khi xưa, tim mình nặng trĩu mỗi lần bước vào đây. Nhưng bây giờ thì khác, mình cảm thấy tim mình được an ủi, hơi thở của mình nhẹ nhàng hơn khi nhốt mình trong này với cậu. Chà, mình không biết mình đang viết gì nữa, nhưng mỗi khi đặt bút viết gì đấy, đầu óc mình thoải mái hơn. “",
      "“ Mình không phải một đứa vô dụng. Mình không biết giấc mơ của mình là gì. Mình cảm thấy xấu hổ, đau đớn, buồn bã, ăn năn. Mình thực sự cảm thấy lạc lõng… Mình chỉ biết cố gắng để vượt qua. “",
      "Trang nhật ký này có vài vết hoen ố.",
      "“ Mình nhớ anh trai mình. Giá như anh còn ở đây, mình sẽ biết mình phải làm gì. Mình quen với việc dựa dẫm vào anh trai…thật thảm hại. Mình chẳng làm được trò trống gì cả. Trong mắt mọi người, mình chỉ là một đứa vô năng, vô tích sự. Mặc dù Popo, Momo và em trai mình luôn thương yêu mình, mình cảm thấy mình không xứng đáng có được tình yêu thương ấy. Họ luôn bảo rằng mình cứ là chính mình đi, đừng phải e sợ trước ánh nhìn hay lời nói của người khác, nhưng…chính mình là như thế nào? Mình không biết mình là ai…Mình…thực sự cảm thấy khó thở. Nhưng mình không thể để họ lo lắng được. Mình đã thành chị cả rồi mà…Mình phải trưởng thành…”",
      "“ Trưởng thành là khi giấu nỗi đau vào trong tâm thức. Thật cay đắng…Mình chắc chắn là Popo và Momo cũng vậy…Đôi mắt họ trĩu buồn mỗi khi nhìn thấy tấm ảnh của anh trai. Giá như mình tốt đẹp hơn thì hay biết mấy…”",
      "“ Mình không là gì cả. Mình không là gì cả. Mình không là gì cả. Mình không là gì cả. Mình nên biến mất. Mình nên biến mất. Mình nên biến mất. Mình nên biến mất. Mình nên biến mất. “",
      "“ Mình cảm thấy có lỗi. Popo và Momo ắt hẳn phải buồn lắm khi phải nuôi nấng mình. “",
      "“ Mệt mỏi quá. Cảm giác như trong tim có hàng ngàn cây kim đâm xuyên vậy. Mặc cảm, tội lỗi, sầu uất, tất cả những cảm xúc tiêu cực đang chiếm lấy mình. Dahria bảo rằng mình nên vẽ tranh để trút bỏ cảm xúc ấy đi, mình đã vẽ, nhưng chúng vẫn ở đây. “",
      "“ Mình suýt nữa ngả ngửa khi Dahria bảo với mình rằng cô ấy có con. Nhưng hóa ra “ con “ mà cô ấy bảo lại là đứa trẻ mồ côi mà cô ấy chăm sóc. Cô ấy quý con bé lắm. Dù con bé có đầy khiếm khuyết so với bạn bè cùng trang lứa nhưng ít ra con bé là người tốt, Dahria bảo vậy. Mình muốn biết mặt mũi con bé ra sao nhưng Dahria nhất quyết không cho mình xem. “",
      "“ Dahria bảo với mình rằng trước mặt cô ấy thì mình phải buông bỏ, đừng cố gồng nữa. Mình đã khóc rất nhiều, bao nhiêu nỗi đau trong mình cứ thế tuôn trào, không kìm lại được. Dahria là một người bạn tốt hiếm hoi và duy nhất mà mình có. Ánh trăng hôm nay thật đẹp. Cả hai đứa bọn mình dựa lưng vào nhau và giải bày hết tâm sự trong lòng. “",
      "“ Hôm nay Dahria lạ lắm. Cô ấy đột ngột mua nhiều quà cho mình. Mình gặng hỏi lý do nhưng cô ấy chỉ bảo rằng cô ấy thích thế. Đến tối, bọn mình đi chơi đu quay, cùng nhau ăn kem, cùng nhau tản bộ trên những bậc thang dài dằng dặc. Cảm xúc khó tả này là gì…? “",
      "“ Trong lòng mình dâng trào nỗi bất an. Mình cố gọi cho Dahria nhưng cô ấy không bắt máy. Mình chạy đến nhà cô ấy mới biết tin cô ấy đã chuyển nhà ngay trong đêm “",
      "“ Hôm nay mình gọi cho Dahria hàng trăm cuộc. Cô ấy vẫn không bắt máy. Thôi mà, không phải cả Dahria nữa chứ…Làm ơn, Poseidon ơi, đừng…”",
      "“ Đã hơn hai tháng trôi qua. Cuộc sống của mình vẫn cứ tiếp diễn. Nỗi đau đáu và bất an ngày một dâng cao thành núi. Mình vẽ, mình viết, mình hát nhưng chẳng thấy cảm xúc nặng nề này vơi đi tí nào cả. “"
    ]
    simple.call("LORE-STORAGE-ENCRYPTED-DIARY", 10, 7, encrypted)

    letter = [
      "Dưới đáy thùng thứ ba có một lá thư bị vò nhăn nhúm. Chữ viết nhìn có vẻ vội vã. Đọc lá thư?",
      "“ Aira, mình xin lỗi vì đã giấu cậu. Mình xin lỗi vì là người đã bảo cậu buông bỏ tất cả để mở lòng trong khi bản thân mình lại không làm được. Mình xin lỗi vì không nghe điện thoại của cậu. Mình xin lỗi vì đã viết lá thư này cho cậu.",
      "Mình không phải là bảo mẫu chăm trẻ mồ côi. “ Đứa con yêu “ mà mình kể cho cậu nghe, thực chất là bản sao lai tạo giữa gen di truyền của Poseidon và quái vật vực sâu, là bản sao không hoàn hảo trong hàng ngàn bản sao được sinh ra để làm vũ khí chiến tranh. Sự thương yêu mình dành cho nó là giả tạo, mình đã không ngần ngại vứt bỏ nó ra bãi rác, mặc cho nó tự sinh tự diệt.",
      "Aira à, mình thật sự dại dột. Mình ngỡ rằng mình đang cống hiến cho một dự án tốt đẹp, đào tạo ra những siêu chiến binh bảo vệ Atlantis. Nhưng hóa ra, mình đang cống hiến cho một dự án vô nhân đạo, chế tạo ra những cỗ máy giết chóc vô nhân tính.",
      "Vì sự dại dột ấy mà giờ đây mình phải trả giá. “ Kẻ trừng phạt “ sắp tìm được phòng nghiên cứu của dự án rồi. Tất cả những ai liên quan đến dự án đều phải biến mất không dấu vết.",
      "Mình không muốn biến mất hoàn toàn khỏi thế gian này. Mình sợ lắm, Aira. Mình sợ ngày mai không nhìn thấy cậu. Mình sợ cậu sẽ phát điên và tìm kiếm mình, một người bạn không tồn tại. Mình không muốn liên lụy đến cậu, nên sau khi đọc xong lá thư này, kích hoạt vòng tròn phép thuật ở mặt sau để xóa đi toàn bộ ký ức liên quan về mình cũng như lá thư.",
      "Hẹn gặp cậu vào một ngày nắng vàng. Tạm biệt. “"
    ]
    box1 = wrapped_message_commands(["Thùng đầu tiên toàn là bài tập về nhà của OniOnii. Có cả “ phao “ nữa này!!"]) + [event_command(122, 0, [33, 33, 0, 0, 1]), event_command(123, 0, ["A", 0])]
    box2 = wrapped_message_commands(["Thùng thứ hai lại toàn là bài tập điểm kém của mình. Hóa ra OniOnii giấu chúng ở đây!!"]) + [event_command(122, 0, [33, 33, 0, 0, 2]), event_command(123, 0, ["B", 0])]
    box3 = wrapped_message_commands(letter) + [
      event_command(122, 0, [33, 33, 0, 0, 3]),
      event_command(121, 0, [42, 42, 0]),
      event_command(355, 0, ["map_effects.clear"]),
      event_command(201, 0, [0, 24, 10, 10, 2, 0])
    ]
    # Source repeats (11,7) for both cassette selection and the three boxes.
    # Place the story boxes one tile to the right so both authored interactions work.
    add_event.call("SCN-STORAGE-LETTER-BOXES", 12, 7, [
      page_from_template(source_template, box1),
      page_from_template(source_template, box2, self_switch: "A"),
      page_from_template(source_template, box3, self_switch: "B")
    ])

    map.instance_variable_set(:@events, events)
    replace_storage_diary_events!(map)
    gate_map026_interactions_behind_light!(map)
    polish_map026_cassette_player!(map)
    save_data("Data/Map026.rvdata2", map)

    infos = load_data("Data/MapInfos.rvdata2")
    info = Marshal.load(Marshal.dump(infos[22] || infos.values.compact.first))
    info.instance_variable_set(:@name, "Phòng kho nhà Hải Quỳ")
    info.instance_variable_set(:@parent_id, 22)
    info.instance_variable_set(:@order, infos.values.compact.map { |item| item.instance_variable_get(:@order).to_i }.max + 1)
    info.instance_variable_set(:@expanded, true)
    info.instance_variable_set(:@scroll_x, 0)
    info.instance_variable_set(:@scroll_y, 0)
    infos[26] = info
    save_data("Data/MapInfos.rvdata2", infos)

    system = load_data("Data/System.rvdata2")
    switches = system.instance_variable_get(:@switches) || []
    variables = system.instance_variable_get(:@variables) || []
    switches[39] = "HQ_STORAGE_LIGHT"
    switches[42] = "HQ_STORAGE_LETTER_READ"
    variables[32] = "HQ_TAPE_ID"
    variables[33] = "HQ_STORAGE_BOX_STEP"
    system.instance_variable_set(:@switches, switches)
    system.instance_variable_set(:@variables, variables)
    save_data("Data/System.rvdata2", system)
    puts "MAP026_STORAGE|size=17x13|parallax=Storage_Base|top=Storage_Top|events=#{events.size}|collision=250_pass_251_block|source_conflict_boxes=12,6"
  end

  def correct_map023_shop_arrival
    path = "Data/Map023.rvdata2"
    map = load_data(path)
    events = map.instance_variable_get(:@events) || {}
    event = events[1] || events.values.compact.first
    raise "Map023 needs an event template" unless event
    intro = [
      event_command(355, 0, ["layer(23,0,[\"Old_Book_Shop_Top\",0,0,255,200,0,0,0])"]),
      event_command(655, 0, ["refresh_layers"]),
      event_command(117, 0, [1])
    ] + wrapped_message_commands([
      "Uầy, cái mùi sách này…hoài niệm ghê!",
      "Đây chính là tiệm sách phép “ đó “. Một tiệm bán sách phép cũ, huyền thoại đối với tôi. Toàn bộ sách phép ở đây đều không dán niêm phong. Thế nên bạn có thể ngồi ở đây cả ngày đọc sách hoàn toàn miễn phí mà không phải mua chúng. Vì thế hồi tôi còn bé, tôi hay được OniOnii-chan đèo ra đây đọc sách.",
      "Chủ tiệm sách khi ấy là một bà lão dễ tính, vô cùng thương yêu trẻ con, mỗi khi thấy tôi đến đều mang một rổ bánh kẹo và bình trà gạo rang cho tôi vừa nhâm nhi vừa đọc sách. Thế là cứ tuần này sang tháng nọ, tôi mau chóng đọc gần hết sách ở cửa tiệm.",
      "Tôi còn nhớ, trước khi tôi tham gia khóa tập huấn của Poseidon, bà lão từng hứa sẽ tặng cho tôi cuốn sách mà bà ấy thích nhất sau khi tôi trở về. Tiếc rằng lời hứa ấy không thể hoàn thành. Bẵng đi một khoảng thời gian mà tôi không thể xác định, bà lão đã qua đời.",
      "Ngần ấy năm đã trôi qua, cửa tiệm đương nhiên sẽ thay đổi. Nhưng chỗ ngồi năm ấy của tôi và bà lão vẫn nguyên vẹn, chưa bị thời gian chạm vào. Mà thôi, không nhung nhớ quá khứ nữa! Tập trung tìm sách nào!!"
    ]) + [event_command(123, 0, ["A", 0])]
    page1 = page_from_template(event, intro, trigger: 3, priority: 0)
    page2 = page_from_template(event, [], trigger: 0, priority: 0, self_switch: "A")
    event.instance_variable_set(:@name, "SCN-ATL-005 MAGIC SHOP ARRIVAL [E001]")
    event.instance_variable_set(:@x, 15)
    event.instance_variable_set(:@y, 37)
    event.instance_variable_set(:@pages, [page1, page2])
    map.instance_variable_set(:@display_name, "Tiệm sách phép Atlantis")
    map.instance_variable_set(:@width, 30)
    map.instance_variable_set(:@height, 40)
    map.instance_variable_set(:@tileset_id, 7)
    map.instance_variable_set(:@parallax_name, "Old_Book_Shop_Base")
    map.instance_variable_set(:@parallax_loop_x, false)
    map.instance_variable_set(:@parallax_loop_y, false)
    map.instance_variable_set(:@parallax_sx, 0)
    map.instance_variable_set(:@parallax_sy, 0)
    map.instance_variable_set(:@note, "Magic shop parallax: Old_Book_Shop_Base + Old_Book_Shop_Top")
    width = 30
    height = 40
    depth = 4
    size = width * height * depth
    values = Array.new(size, 0)
    offset = 2 * width * height
    (width * height).times { |i| values[offset + i] = 251 }
    passable = {}
    (5..23).each { |x| (3..8).each { |y| passable[[x, y]] = true } }
    (11..18).each { |x| (9..15).each { |y| passable[[x, y]] = true } }
    (5..24).each { |x| (16..23).each { |y| passable[[x, y]] = true } }
    (9..20).each { |x| passable[[x, 24]] = true }
    (5..24).each { |x| (25..36).each { |y| passable[[x, y]] = true } }
    (14..16).each { |x| (37..39).each { |y| passable[[x, y]] = true } }
    passable.each_key { |x, y| values[offset + y * width + x] = 250 }
    table = Table.allocate
    table.instance_variable_set(:@marshal_data,
      [3, width, height, depth, size].pack("l<5") + values.pack("s<*"))
    map.instance_variable_set(:@data, table)
    map.instance_variable_set(:@events, {1 => event})
    save_data(path, map)
    puts "MAP023_SHOP|size=30x40|base=Old_Book_Shop_Base|top=Old_Book_Shop_Top|arrival=15,37|prototype_choice_removed=true"
  end

  def complete_map023_old_book_shop
    path = "Data/Map023.rvdata2"
    map = load_data(path)
    old_events = map.instance_variable_get(:@events) || {}
    intro = old_events[1]
    template = intro || old_events.values.compact.first
    raise "Map023 arrival/template event missing" unless intro && template

    events = {1 => intro}
    next_id = 2
    add_event = lambda do |name, x, source_y, pages|
      id = next_id
      events[id] = event_from_pages(template, id, name, x, source_y - 1, pages)
      next_id += 1
      id
    end
    thought = lambda { |texts| wrapped_message_commands(texts, width: 30) }
    hq = lambda { |text| [event_command(117, 0, [1])] + wrapped_message_commands([text], tag: "\\bm[0] ", width: 24) }
    owner = lambda { |text| [event_command(122, 0, [40, 40, 0, 0, 2]), event_command(117, 0, [2])] + wrapped_message_commands([text], tag: "\\bm[2] ", width: 24) }
    reset_camera = lambda { [event_command(117, 0, [3])] }
    simple = lambda do |name, x, y, texts|
      add_event.call(name, x, y, [page_from_template(template, thought.call(texts))])
    end
    duplicate = lambda do |name, coordinates, texts|
      coordinates.each { |x, y| simple.call(name, x, y, texts) }
    end

    # E002 is the Pop Message/camera anchor for the sleeping shop owner.
    owner_pages = []
    first = hq.call("Chị ơi, cho em hỏi chút!") + owner.call("zz…z…z…zzz") +
      reset_camera.call + thought.call(["Bả ngủ luôn rồi?!"]) +
      [event_command(122, 0, [34, 34, 0, 0, 1])]
    second = hq.call("Chị ơi, dậy chị ơi!!") + owner.call("….") +
      owner.call("Chào mừng….") + owner.call("zz…z…zzzzz") +
      reset_camera.call + thought.call(["Ngủ gì say dữ vậy!!!"]) +
      [event_command(122, 0, [34, 34, 0, 0, 2])]
    third = owner.call("Ồ, xin chào quý khác đến với Tiệm Sách Thời Gian Lay Đọng! Liệu tôi có thể giúp gì- Ô! Là em hả?")
    third += thought.call(["???"])
    third += owner.call("Màu tóc này, tuy hơi nhạt một chút, nhưng màu mắt này không lẫn vào đâu được! Em là cô bé đó hả?")
    third += hq.call("Chị biết em à?")
    third += owner.call("Biết chứ! Bà chị lúc nào cũng kể về em đó!")
    third += hq.call("Vậy ạ?")
    third += owner.call("Ừa! Từ từ! Chị đang nhớ cái gì đó….Hmmm!! À à, đúng rồi đúng rồi! “ NÓ “!")
    third += hq.call("“ Nó “??")
    third += owner.call("Món quà mà bà chị tính tặng cho em mà không kịp!! Đợi chị một xíu!!")
    third += reset_camera.call
    third += thought.call(["Chị chủ tiệm vội chạy vô trong. Đợi khoảng một lúc lâu, chị ấy chạy ra cùng một hộp thiếc dán chi chít giấy niêm phong đã ố vàng, rách bươm đôi chỗ. Chị ấy nhét thẳng chiếc hộp vào tay tôi."])
    third += owner.call("Đây!! Là “ nó “ nè!")
    third += hq.call("Hộp thiếc này…là quà của em hả?")
    third += owner.call("Ừa đúng rồi! Trước khi bà mất đã dặn tụi chị tìm em và trao tận tay hộp thiếc này đó! Cơ mà tụi chị chưa gặp em bao giờ nên không xác định được hình dáng em trông ra sao nên tụi chị cứ chờ hoài chờ mãi thôi! Đúng như bà nói, màu mắt của em đặc biệt thiệt đó! Nhìn phát nhận ra luôn!")
    third += hq.call("Haha…Vậy ạ?")
    third += owner.call("Về món quà này, tụi chị cũng không biết bên trong có gì! Chỉ biết trong hộp thiếc này là món quà mà bà đã chuẩn bị kỹ cho em thôi! Kỹ đến mức dán quá trời quá đất giấy niêm phong, tụi chị có lần tò mò mở thử mà không được!")
    third += reset_camera.call
    third += thought.call(["Chị chủ tiệm vừa nói xong, những tờ giấy niêm phong chiếc hộp lần lượt rơi xuống. Cả tôi và chị chủ tiệm tròn xoe mắt nhìn vào chiếc hộp."])
    third += owner.call("Ủa…giấy niêm phong rơi ra rồi nè…")
    third += thought.call(["Chị chủ tiệm thúc giục tôi."])
    third += owner.call("Mở ra đi em!!")
    third += reset_camera.call
    third += thought.call(["“ Rồi là quà của chị hay là quà của em? “, tôi nói thầm trong lòng. Tôi nậy nắp hộp thiếc ra, bên trong hộp là một quyển sách trông đầy nghi vấn. Bìa cuốn sách được đóng bằng loại da sẫm màu của quái vật vực sâu có dính một vài vệt màu đỏ làm nổi bật phần xù xì của lớp da. Xung quanh cuốn sách tỏa ra một luồng ma năng bất ổn. Tôi hơ nhẹ tay lên để kiểm tra thì cảm nhận được cái nóng thiêu đốt đến rát cả da, luồng điện giật mạnh làm đầu óc choáng váng từ cuốn sách.", "Đây chắc chắn là tạo vật vực sâu, không nhầm lẫn đi đâu được!", "Tiếng chuông cảnh báo sự tấn công của quái vật vực sâu từ điện thoại trong túi tôi và loa công cộng bên ngoài cửa tiệm ngay lập tức vang lên ầm ĩ. Giây sau, cuốn sách trong hộp thiếc nổ tung, thổi bay tiệm sách cũ và khu vực xung quanh tiệm sách. Chỉ trong khoảnh khắc ngắn ngủi, tạo vật vực sâu này đã xóa sạch mọi thứ, cướp đi hàng trăm sinh mạng. Chị chủ tiệm may mắn được tôi tạo khiên chống đỡ nên cơ thể chỉ bị xây xát nhẹ."])
    third += owner.call("E-Em không sao chứ?")
    third += hq.call("Em ổn. Trước khi chiếc khiên chống đỡ mà em tạo hết tác dụng, chị mau tìm hầm trú ẩn. NHANH!")
    third += reset_camera.call
    third += thought.call(["Chị ấy gật đầu, mau chóng chạy đi.", "Cuốn sách bay lên ngang tầm mắt tôi, mở tung và xé toạc từng trang, bao quanh lấy tôi như một cơn lốc xoáy. Tôi chạm nhẹ vào chiếc mỏ neo trong túi, triệu hồi đôi găng tay của tôi để chuẩn bị nghênh chiến với nó."])
    third += hq.call("Nào, tới giờ tính sổ tội lỗi của ngươi rồi!")
    third += [event_command(121, 0, [32, 32, 0]), event_command(122, 0, [34, 34, 0, 0, 3])]
    owner_pages << page_from_template(template, first)
    owner_pages << page_from_template(template, second, variable_id: 34, variable_value: 1)
    owner_pages << page_from_template(template, third, variable_id: 34, variable_value: 2)
    owner_pages << page_from_template(template, [], switch_id: 32)
    add_event.call("NPC-SHOP-OWNER", 11, 29, owner_pages)
    # Second counter tile shares the same authored three-step state and bubbles over E002.
    proxy_pages = owner_pages.map { |page| Marshal.load(Marshal.dump(page)) }
    add_event.call("NPC-SHOP-OWNER-COUNTER", 12, 29, proxy_pages)

    directory_1 = thought.call(["Nhìn bìa cuốn sách này hơi mờ ám một chút nhưng thực chất nó là cuốn sách ma thuật giới thiệu chi tiết danh sách ấn phẩm xuất hiện trong cửa tiệm này.", "Tóm tắt lại…", "Tầng 1 là tầng sách phép thuật và truyện tranh thiếu nhi.", "Tầng 2 là sách lịch sử, văn hóa và tiểu thuyết tuổi vị thành niên.", "Tầng 3 và 4 là khu vực bàn ghế đọc sách."]) + [event_command(123, 0, ["A", 0])]
    directory_2 = thought.call(["Tầng 1 là tầng sách phép thuật và truyện tranh thiếu nhi.", "Tầng 2 là sách lịch sử, văn hóa và tiểu thuyết tuổi vị thành niên.", "Tầng 3 và 4 là khu vực bàn ghế đọc sách."])
    add_event.call("PROP-SHOP-DIRECTORY", 13, 29, [page_from_template(template, directory_1), page_from_template(template, directory_2, self_switch: "A")])

    simple.call("BOOK-EARTH-LAVA-METAL", 18, 29, ["Tuyển tập sách hướng dẫn sử dụng ma thuật đất, dung nham và kim loại.", "Ồ nhớ rồi, hồi bé sau khi đọc xong tuyển tập này, mình đã tạo ra một con búp bê đất khóc ra dung nham!"])
    simple.call("BOOK-CURSED-DOLL", 19, 29, ["Ở trên kệ có cuộn giấy ố vàng bị xé mất niêm phong.", "Tới giờ vẫn không hiểu ai lại để cuộn giấy hướng dẫn sử dụng búp bê nguyền rủa ở đây nữa?"])
    simple.call("BOOK-HEALING", 20, 29, ["Tuyển tập sách hướng dẫn sử dụng phép thuật điều trị.", "Ai mà được Hestia phù hộ mới học được phép thuật điều trị.", "Beta M-34 có diễm phúc đó. Cơ mà bả lại cóc thèm học."])
    simple.call("BOOK-NARDESEN-FAIRYTALES", 21, 29, ["Tuyển tập truyện cổ tích thiếu nhi của Nardesen.", "Nhớ nhất là câu chuyện về nàng Bồ Hóng.", "Mẹ kế và chị kế trong câu chuyện không hề hà khắc.", "Ngược lại còn giúp và bảo vệ Bồ Hóng khỏi Hoàng Tử xấu xa.", "Đoạn kết, Bồ Hóng đập nguyên cái giày pha lê vào đầu Hoàng Tử.", "Oách xà lách."])
    simple.call("NOTE-FLOWEY", 22, 29, ["Có tờ ghi chú được dính lên kệ tủ.", "“ Xin chào, tớ là Flowey. “"])
    simple.call("BOOK-DAHLIA-WITCHIANNA", 22, 30, ["Ô, cuốn “ Dahlia Witchianna, cô phù thủy nhỏ tài năng “ này!", "Hai người dì của Dahlia đẹp điên đảo!", "Còn nội dung thì mình quên béng mất rồi."])
    simple.call("BOOK-DARK-PACT", 22, 31, ["Ê, ai để cuốn “ Bí Mật – Giao ước bóng tối “ ở đây vậy?", "Đáng lẽ nó nên ở tầng trên chứ!"])

    teleport_text = thought.call(["Đây rồi! Cuốn phép thuật dịch chuyển này!", "Nhớ có lần Shylvie từng hỏi tôi rằng phép thuật dịch chuyển ở Atlantis có gì khác với phép thuật dịch chuyển mà bà ấy từng học không.", "Đương nhiên là…Ờm…Tôi không biết?", "Thú thực là tôi không rành về các phép thuật hỗ trợ lắm, nói trắng ra là mù tịt.", "Nên là mua cuốn này cho Shylvie là chuẩn bài rồi!", "Tôi cũng tò mò xem liệu có sự khác biệt giữa các phép thuật dịch chuyển không."])
    teleport_text += [event_command(102, 0, [["Có", "Không"], 0]), event_command(402, 0, [0, "Có"])]
    teleport_text += wrapped_message_commands(["Ok, mua luôn!"], width: 30, indent: 1)
    teleport_text += [event_command(122, 1, [31, 31, 0, 0, 2]), event_command(402, 0, [1, "Không"])]
    teleport_text += wrapped_message_commands(["Từ từ, để xem còn cuốn nào hay không?"], width: 30, indent: 1)
    teleport_text += [event_command(404, 0, [])]
    add_event.call("CHOICE-BOOK-TELEPORT-SHYLVIE", 22, 32, [page_from_template(template, teleport_text)])

    simple.call("PROP-SHOP-CLOCK", 17, 28, ["Nhìn đồng hồ này chả hiểu sao mình lại nhớ đến series Luật Sư Đại Tài."])
    simple.call("BOOK-AERO-BLAST", 8, 29, ["Sách hướng dẫn sử dụng phép thuật Aero Blast đã sờn màu.", "Mình học Aero Blast từ cuốn này.", "Hm? Sao lại có tờ giấy ghi chú ố vàng bị dính chặt vào bìa chính thế này?", "“ Gửi Dahria, tớ đã học được Aero Blast trước cậu rồi nhé, lêu lêu “"])
    simple.call("BOOK-BASIC-MAGIC", 9, 29, ["Tuyển tập sách hướng dẫn sử dụng phép thuật căn bản dành cho nhi đồng.", "Oni Onii từng mượn cuốn này về nhà cho mình đọc để đọc.", "Và…Mình chả học được cái gì cả."])
    simple.call("BOOK-CHILD-ASTROLOGY", 7, 33, ["Tủ đựng các cuốn sách hướng dẫn chiêm tinh dành cho nhi đồng."])
    simple.call("BOOK-CHILD-FRIENDSHIP", 7, 34, ["Tủ đựng các cuốn sách hướng dẫn làm bạn dành cho nhi đồng."])
    simple.call("BOOK-CHILD-MORALS", 7, 35, ["Tủ đựng các cuốn truyện đạo đức dành cho nhi đồng."])

    globe_chain = ["Quả địa cầu này có bảy đại dương.", "Dương dương dương là cái giường để ngủ.", "Ngủ ngủ ngủ là cái tủ đựng tiền.", "Tiền tiền tiền là cô tiên biết múa."]
    [[13,31],[14,31],[13,34],[15,34]].each do |x, y|
      pages = globe_chain.each_with_index.map do |line, index|
        commands = thought.call([line]) + [event_command(122, 0, [35, 35, 0, 0, [index + 1, 3].min])]
        page_from_template(template, commands, variable_id: (index.zero? ? nil : 35), variable_value: index)
      end
      add_event.call("PROP-SHOP-GLOBE-CHAIN", x, y, pages)
    end
    simple.call("PROP-GLOBE-SILVER-WING", 15, 31, ["Chỗ này là vị trí của văn phòng Silverwing nè."])
    simple.call("PROP-GLOBE-ECLIPSE-6", 14, 34, ["Chỗ này là vị trí của Đội phòng chống thảm họa Nguyệt Thực 6 nè."])
    simple.call("PROP-GLOBE-ATLANTIS-STATION", 12, 32, ["À, trạm xe xuống Atlantis đây rồi."])
    simple.call("PROP-GLOBE-WANDERER", 16, 32, ["Chỗ này là vị trí văn phòng Wanderer nè."])

    portrait = ["Chân dung về người phụ nữ quyền quý.", "Bà lão từng bảo mình đây là tranh về cụ cố của bà ấy.", "Cụ cố của bà ấy là một người thích đọc và sưu tầm sách.", "Xưa kia, dòng họ bà lão là một trong những dòng họ quyền quý bậc nhất Atlantis.", "Nhưng vì sa cơ lỡ vận nên bao nhiêu tài sản bay biến hết.", "Poseidon thương tình nên đã giữ lại tòa lâu đài…", "Cùng thư viện phép thuật với biết bao nhiêu cuốn sách cổ của dòng họ bà.", "Cái tên “ Tiệm Sách Thời Gian Lay Đọng “ cũng vì thế mà ra đời."]
    duplicate.call("LORE-SHOP-FOUNDER-PORTRAIT", [[9,21],[10,21]], portrait)

    novels = {
      11 => "“ Gloaming “ Câu chuyện về một chàng trai đã phải lòng với một cương thi, kẻ tỏa ra mùi hương gỗ sồi khi phơi mình dưới ánh mặt trời.",
      12 => "“ Atlantis vòng quanh, lòng ai có cặn “ Câu chuyện về một cô gái trẻ hồn lìa khỏi xác đang tìm cách trở về cuộc sống bình thường cùng Vital – một linh hồn lang thang vui tính luôn giúp đỡ cô.",
      13 => "“ Animorphs “ Câu chuyện về nhóm thiếu niên có khả năng biến hình thành bất kỳ loài động vật nào họ chạm vào và sử dụng khả năng ấy để chống lại cuộc xâm lược của người ngoài hành tinh.",
      14 => "“ Có hai con cá bơi giữa dòng đời “ Câu chuyện xoay quanh hai con cá Thiên Đường và Thanh Ngọc ngồi sau song sắt ngắm nhìn thế giới và chia sẻ những suy nghĩ về cuộc sống.",
      15 => "“ Thời vàng son “ Câu chuyện kể về cá Anh Đào, một cô cá mồ côi, xuất thân nghèo khó liên tiếp gặp vận đỏ nhờ những sự trùng hợp may mắn và khả năng ứng biển.",
      17 => "“ Hoa viên ngôn từ  “ Câu chuyện đẹp về tình bạn giữa chàng trai có năng khiếu đóng giày và một cô gái mắc bệnh trầm cảm đang tìm lại lý do sống của mình tại một hoa viên xinh đẹp.",
      18 => "“ Vivid “ Câu chuyện về một linh hồn vô danh sau khi chết được thiên thần Frapputa thông báo rằng mình đã \"trúng số\" và có cơ hội thứ hai để chuộc lại lỗi lầm trong quá khứ."
    }
    novels.each { |x, text| simple.call("BOOK-SHOP-NOVEL", x, 19, [text]) }

    demon = thought.call(["Mình nhớ cuốn Ma Vương Cổ Đại nằm đâu đó ở kệ này…", "À, đây rồi!!", "Đây là quyển sách cũ rích không rõ nguồn gốc có nói về Ma Vương Atlantis.", "Đến cả tôi lúc đọc cuốn này còn bất ngờ mà!", "Nào giờ ở dưới Atlantis ai cũng tôn thờ thần Poseidon hết, tự dưng tòi đâu ra ông Ma Vương không ai biết mặt biết tên lại chả bất ngờ.", "Ban đầu tôi còn tưởng cuốn này là tiểu thuyết được viết bởi ai đó nhưng khi thử một số phép thuật được viết trong đây…", "Tôi chắc chắc cuốn này là sách siêu cổ đại!", "Đa phần số phép thuật mà tôi dùng hiện giờ đều học từ cuốn này mà ra.", "Mua cuốn này cho Hakase là chuẩn bài rồi đấy!!", "Vì Hakase từng là ma vương mà!", "Trong cuốn này cũng còn nhiều phép thuật tôi chưa sử dụng được, cá chắn Hakase đọc phát thông thạo ngay!", "Mua cuốn này cho Hakase chứ?"])
    demon += [event_command(102, 0, [["Có", "Không"], 0]), event_command(402, 0, [0, "Có"])]
    demon += wrapped_message_commands(["Mua luôn!"], indent: 1)
    demon += [event_command(122, 1, [31, 31, 0, 0, 1]), event_command(402, 0, [1, "Không"])]
    demon += wrapped_message_commands(["Từ từ, để xem còn cuốn nào không."], indent: 1)
    demon += [event_command(404, 0, [])]
    add_event.call("CHOICE-BOOK-ANCIENT-DEMON-HAKASE", 23, 22, [page_from_template(template, demon)])

    simple.call("LORE-ATLANTIS-BLOOD-MOON", 19, 22, ["Tủ này là tủ sách về văn hóa ở Atlantis.", "Ở Atlantis vào ngày 31/10 sẽ là ngày trăng máu.", "Khi ấy, sức mạnh của quái vật vực sâu sẽ tăng lên gấp trăm lần.", "Ngược lại, cư dân Atlantis sẽ bị giảm sức mạnh thậm tệ.", "Có người thì bị hiện tượng “ lại tổ “.", "Có người thì bị mất phép thuật tạm thời hoặc vĩnh viễn.", "Cho nên mỗi khi đến 31/10, mình bắt buộc phải trực xuyên suốt không ngơi nghỉ.", "Vì mình may mắn không bị ảnh hưởng bởi trăng máu.", "Mà còn mạnh khủng khiếp nữa!"])
    simple.call("LORE-ATLANTIS-WAR-HISTORY", 20, 22, ["Ôi cái tủ này có nguyên ổ nhện biển!!", "Tủ này là tủ sách về lịch sử chiến tranh ở Atlantis.", "Loại giấy dùng làm những cuốn sách này lại là món ưa thích của tụi nhện."])
    simple.call("LORE-ATLANTIS-ANCIENT-POETRY", 21, 22, ["Tủ này là tủ sách thi ca thời cổ đại.", "Toàn bộ các bài thơ, bài ca thời đấy…", "Đều là phép thuật phong ấn và khai triển kết giới.", "Mình may mắn học được một vài bài.", "Siêu hữu ích."])
    simple.call("PROP-SHOP-SPIDER-NEST", 22, 22, ["Tầng cuối cùng của kệ này bị nhện biển làm tổ rồi…"])
    simple.call("LORE-ATLANTIS-MAGIC-HISTORY", 24, 22, ["Mình nhớ tủ sách này từng là tủ sách lịch sử phép thuật ở Atlantis.", "Ôi, chưa kịp đọc!! Mấy con nhện biển chết tiệt!!"])
    duplicate.call("PROP-SHOP-OLD-LADY-TABLE", [[20,16],[21,16]], ["Đây là chiếc bàn mà mình với bà lão hay ngồi chung."])
    duplicate.call("TRANSFER-SHOP-OWNER-ROOM", [[20,13],[21,13]], ["Đây là cửa dịch chuyển kết nối với phòng của bà lão."])
    simple.call("LORE-SHOP-GUEST-NOTES", 19, 13, ["Trên tủ này vẫn còn cuốn sách viết tay của bà lão về sở thích của các vị khách.", "“ Buttercup “ hay mượn sách về nghệ thuật hình ảnh. Luôn đi chung với Aira.", "Dahria hay mượn sách cổ tích và truyện tranh về các phù thủy. Hay lén lút mang sách về.", "Aira hay mượn sách về phép thuật. Con bé rất chăm chỉ luyện tập.", "“ Paupipo “ hay mượn sách về văn hóa Atlantis. Thằng bé nghiêm túc hơn anh chị em mình.", "“ Nhện biển xanh “ hay mượn sách phép thuật. Cũng là đứa trẻ hay gặm sách lúc ngủ."])
    duplicate.call("TRANSFER-SHOP-TOILET", [[14,13],[15,13]], ["Đây là cửa dịch chuyển kết nối với phòng vệ sinh."])
    duplicate.call("TRANSFER-SHOP-MODERN-LIBRARY", [[8,13],[9,13]], ["Đây là cửa dịch chuyển kết nối với một thư viện toàn sách thời đại mới."])
    simple.call("PROP-SHOP-MIMIC-PLANT", 10, 13, ["Chậu cây này có thể nhại lại âm thanh."])
    duplicate.call("LORE-SHOP-THREE-OLD-LADIES", [[6,13],[7,13]], ["Chân dung của ba bà lão."])
    simple.call("PROP-SHOP-HQ-ONIONII-TABLE", 9, 6, ["Mình với Oni Onii hay ngồi bàn này."])

    map.instance_variable_set(:@events, events)
    save_data(path, map)

    system = load_data("Data/System.rvdata2")
    switches = system.instance_variable_get(:@switches) || []
    variables = system.instance_variable_get(:@variables) || []
    switches[32] = "ATL_OWNER_MET"
    switches[33] = "ATL_END_READY"
    variables[31] = "ATL_BOOK_ID"
    variables[34] = "ATL_OWNER_STEP"
    variables[35] = "ATL_GLOBE_STEP"
    system.instance_variable_set(:@switches, switches)
    system.instance_variable_set(:@variables, variables)
    save_data("Data/System.rvdata2", system)
    puts "MAP023_OLD_BOOK_SHOP|events=#{events.size}|source_y_offset=-1|owner_anchor=E002|owner_step=V34|globe_step=V35|book=V31"
  end

  def rebuild_map024_memory_intro
    path = "Data/Map024.rvdata2"
    old = load_data(path)
    template = (old.instance_variable_get(:@events) || {}).values.compact.first
    raise "Map024 needs an event template" unless template
    map = Marshal.load(Marshal.dump(old))
    map.instance_variable_set(:@display_name, "Ký ức bãi rác")
    map.instance_variable_set(:@width, 20)
    map.instance_variable_set(:@height, 14)
    map.instance_variable_set(:@parallax_name, "")
    map.instance_variable_set(:@tileset_id, 7)
    table = blank_table(20, 14, 4)
    raw = table.instance_variable_get(:@marshal_data)
    header = raw.unpack("l<5")
    values = raw.byteslice(20, header[4] * 2).unpack("s<*")
    offset = 2 * 20 * 14
    (20 * 14).times { |i| values[offset + i] = 250 }
    table.instance_variable_set(:@marshal_data, raw.byteslice(0, 20) + values.pack("s<*"))
    map.instance_variable_set(:@data, table)

    scroll = lambda do |paragraphs|
      commands = [event_command(105, 0, [2, false])]
      Array(paragraphs).each do |paragraph|
        words = paragraph.split(/\s+/)
        line = ""
        words.each do |word|
          if line.empty? || line.length + 1 + word.length <= 46
            line = line.empty? ? word : "#{line} #{word}"
          else
            commands << event_command(405, 0, [line])
            line = word
          end
        end
        commands << event_command(405, 0, [line]) unless line.empty?
      end
      commands
    end
    step_route = lambda do
      route = RPG::MoveRoute.allocate
      route.instance_variable_set(:@repeat, false)
      route.instance_variable_set(:@skippable, true)
      route.instance_variable_set(:@wait, true)
      move = RPG::MoveCommand.allocate
      move.instance_variable_set(:@code, 1)
      move.instance_variable_set(:@parameters, [])
      finish = RPG::MoveCommand.allocate
      finish.instance_variable_set(:@code, 0)
      finish.instance_variable_set(:@parameters, [])
      route.instance_variable_set(:@list, [move, finish])
      event_command(205, 0, [-1, route])
    end
    scene = [event_command(117, 0, [1])]
    scene += wrapped_message_commands(["Đ-Đây là…!!", "Urg…", "Dahria…"])
    scene += scroll.call(["( ??? ) Ngươi chỉ là đống phế phẩm thất bại thảm hại.", "( ??? ) Ngươi.", "( ??? ) Không xứng đáng ở đây."])
    scene += [event_command(225, 0, [7, 8, 30, true]), event_command(221, 0, []), event_command(355, 0, ["map_effects.clear"]), event_command(222, 0, [])]
    scene += scroll.call(["( ??? ) Một đứa thất bại."])
    scene += wrapped_message_commands(["Không phải…Urg…"])
    memory_lines = [
      "( ??? ) Phế phẩm như mày không nên tồn tại.",
      "( ??? ) Thí nghiệm thất bại. Ghi nhận cảm xúc tồn tại bên trong cá thể.",
      "( ??? ) Em là…",
      "( ??? ) Tại sao…Ngươi phải trống rỗng chứ! Sao lại ngươi lại có xúc cảm?",
      "( ??? ) Mau giết nó đi.",
      "( ??? ) D…a…h…",
      "( ??? ) Ghi nhớ đi.",
      "( ??? ) Tại sao phải quan tâm đến chúng?",
      "( ??? ) Niềm hi vọng…",
      "( ??? ) Sao lại nhìn ta bằng ánh mắt đó?",
      "( ??? ) Chúng là cỗ máy giết chóc."
    ]
    memory_lines.each do |line|
      scene << step_route.call
      scene += scroll.call([line])
    end
    scene += wrapped_message_commands(["Không…phải…cỗ máy…"])
    scene += scroll.call(["( ??? ) Nhiệm vụ…duy nhất…."])
    scene += wrapped_message_commands(["Giết….Không…Urg…"])
    scene += scroll.call(["( ??? ) CÚT ĐI! MAU CÚT KHUẤT MẤT TA!!"])
    scene += [event_command(121, 0, [43, 43, 0]), event_command(123, 0, ["A", 0])]
    page1 = page_from_template(template, scene, trigger: 3, priority: 0)
    page2 = page_from_template(template, [], trigger: 0, priority: 0, self_switch: "A")
    event = event_from_pages(template, 1, "SCN-ATL-MEMORY-CHASE-INTRO", 10, 10, [page1, page2])
    map.instance_variable_set(:@events, {1 => event})
    save_data(path, map)

    infos = load_data("Data/MapInfos.rvdata2")
    if infos[24]
      infos[24].instance_variable_set(:@name, "Ký ức bãi rác")
      infos[24].instance_variable_set(:@parent_id, 26)
      save_data("Data/MapInfos.rvdata2", infos)
    end
    system = load_data("Data/System.rvdata2")
    switches = system.instance_variable_get(:@switches) || []
    switches[43] = "HQ_MEMORY_CHASE_READY"
    system.instance_variable_set(:@switches, switches)
    save_data("Data/System.rvdata2", system)
    puts "MAP024_MEMORY|source=scene4_lines420_451|horizontal=scroll_text|mirror_chase_ready=S43"
  end

  def name_atlantis_flags
    system = load_data("Data/System.rvdata2")
    switches = system.instance_variable_get(:@switches) || []
    variables = system.instance_variable_get(:@variables) || []
    switches[30] = "ATL_CHOSEN"
    switches[31] = "ATL_ARRIVED"
    switches[32] = "ATL_OWNER_MET"
    switches[33] = "ATL_END_READY"
    switches[34] = "ATL_READ_LETTER"
    switches[35] = "ATL_CHASE_STARTED"
    switches[36] = "ATL_CHASE_CLEARED"
    variables[30] = "ATL_STEP"
    variables[31] = "ATL_BOOK_ID"
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

  def insert_runtime_script(name, source_path, before_name = "Main")
    scripts = load_data("Data/Scripts.rvdata2")
    existing = scripts.index { |entry| entry[1].to_s.strip == name.strip }
    source = File.binread(source_path)
    if existing
      scripts[existing][2] = Zlib::Deflate.deflate(source)
      action = "UPDATED"
    else
      index = scripts.index { |entry| entry[1].to_s.strip == before_name.strip }
      raise "Runtime insertion point not found: #{before_name}" unless index
      script_id = scripts.map { |entry| entry[0].to_i }.max.to_i + 1
      scripts.insert(index, [script_id, name, Zlib::Deflate.deflate(source)])
      action = "INSERTED"
    end
    save_data("Data/Scripts.rvdata2", scripts)
    verified = load_data("Data/Scripts.rvdata2")
    actual_index = verified.index { |entry| entry[1].to_s.strip == name.strip }
    actual = Zlib::Inflate.inflate(verified.fetch(actual_index)[2])
    raise "Runtime script verification failed" unless actual == source
    puts "#{action}|#{actual_index}|#{name}|bytes=#{source.bytesize}"
  end

  def prepare_map027_demo_events
    path = "Data/Map027.rvdata2"
    map = load_data(path)
    events = map.instance_variable_get(:@events) || {}
    event = events.fetch(4)
    event.instance_variable_set(:@name, "DEMO-NOM-NOM-EXPLODE [E004]")
    pages = event.instance_variable_get(:@pages)
    first_page = pages.fetch(0)
    first_page.instance_variable_set(:@list, [
      event_command(101, 0, ["", 0, 0, 2]),
      event_command(401, 0, ["Nòm nòm nòm. "]),
      event_command(355, 0, ['char_effect(4, "Giant")']),
      event_command(230, 0, [70]),
      event_command(355, 0, ["shrimp_style_event_explosion(4)"]),
      event_command(230, 0, [65]),
      event_command(123, 0, ["A", 0]),
      event_command(0, 0, [])
    ])

    gone_page = Marshal.load(Marshal.dump(first_page))
    condition = gone_page.instance_variable_get(:@condition)
    condition.instance_variables.each do |variable|
      value = condition.instance_variable_get(variable)
      condition.instance_variable_set(variable, false) if value == true || value == false
    end
    condition.instance_variable_set(:@self_switch_valid, true)
    condition.instance_variable_set(:@self_switch_ch, "A")
    graphic = gone_page.instance_variable_get(:@graphic)
    graphic.instance_variable_set(:@tile_id, 0)
    graphic.instance_variable_set(:@character_name, "")
    graphic.instance_variable_set(:@character_index, 0)
    gone_page.instance_variable_set(:@priority_type, 0)
    gone_page.instance_variable_set(:@trigger, 0)
    gone_page.instance_variable_set(:@list, [event_command(0, 0, [])])
    event.instance_variable_set(:@pages, [first_page, gone_page])

    save_data(path, map)
    verify = load_data(path).instance_variable_get(:@events).fetch(4)
    raise "Map027 demo event verification failed" unless
      verify.instance_variable_get(:@pages).size == 2
    puts "UPDATED|Map027|Event4|nom-nom-expand-explode"
  end

  def create_atlantis_mirror_and_chase_maps
    template_map = load_data("Data/Map005.rvdata2")
    template_event = (load_data("Data/Map024.rvdata2").instance_variable_get(:@events) || {}).values.first
    raise "No event template for Atlantis mirror maps" unless template_event

    set_graphic = lambda do |page, name, index = 0, direction = 2, pattern = 1|
      graphic = page.instance_variable_get(:@graphic)
      graphic.instance_variable_set(:@tile_id, 0)
      graphic.instance_variable_set(:@character_name, name)
      graphic.instance_variable_set(:@character_index, index)
      graphic.instance_variable_set(:@direction, direction)
      graphic.instance_variable_set(:@pattern, pattern)
      page
    end
    blank_page = lambda do |switch = "A"|
      page_from_template(template_event, [], trigger: 0, priority: 0, self_switch: switch)
    end
    make_event = lambda do |id, name, x, y, commands, trigger = 0, priority = 1|
      page = page_from_template(template_event, commands, trigger: trigger, priority: priority)
      event_from_pages(template_event, id, name, x, y, [page])
    end

    # A broad, readable maze: two-tile corridors connected to several chambers.
    # This deliberately avoids the old one-tile DFS "tunnel" appearance.
    logical_width = 25
    logical_height = 19
    logical = Array.new(logical_height) { Array.new(logical_width, 1) }
    rng = Random.new(28029)
    stack = [[1, 1]]
    logical[1][1] = 0
    until stack.empty?
      x, y = stack[-1]
      choices = [[2, 0], [-2, 0], [0, 2], [0, -2]].select do |dx, dy|
        nx = x + dx
        ny = y + dy
        nx > 0 && nx < logical_width - 1 && ny > 0 && ny < logical_height - 1 && logical[ny][nx] == 1
      end
      if choices.empty?
        stack.pop
      else
        dx, dy = choices[rng.rand(choices.size)]
        logical[y + dy / 2][x + dx / 2] = 0
        logical[y + dy][x + dx] = 0
        stack << [x + dx, y + dy]
      end
    end

    # Scale every navigable logical tile to 2x2. Walls stay two tiles thick,
    # making navigation and mirror placement comfortable at 544x416.
    scale = 2
    width = logical_width * scale + 2
    height = logical_height * scale + 2
    maze = Array.new(height) { Array.new(width, 1) }
    logical_height.times do |ly|
      logical_width.times do |lx|
        next unless logical[ly][lx] == 0
        scale.times do |oy|
          scale.times do |ox|
            maze[1 + ly * scale + oy][1 + lx * scale + ox] = 0
          end
        end
      end
    end

    # Carve landmark rooms and a few loops so the route is not just a tunnel.
    rooms = [[2, 2, 9, 7], [21, 3, 9, 8], [39, 4, 9, 7],
             [7, 17, 10, 8], [25, 16, 11, 9], [39, 25, 9, 8],
             [4, 30, 10, 7]]
    rooms.each do |rx, ry, rw, rh|
      (ry...[ry + rh, height - 2].min).each do |y|
        (rx...[rx + rw, width - 2].min).each { |x| maze[y][x] = 0 }
      end
    end
    [[10, 10, 17, 10], [30, 12, 30, 18], [17, 28, 25, 28],
     [35, 31, 42, 31]].each do |x1, y1, x2, y2|
      if y1 == y2
        ([x1, x2].min..[x1, x2].max).each { |x| maze[y1][x] = maze[y1 + 1][x] = 0 }
      else
        ([y1, y2].min..[y1, y2].max).each { |y| maze[y][x1] = maze[y][x1 + 1] = 0 }
      end
    end

    dead_ends = []
    (1...height - 1).each do |y|
      (1...width - 1).each do |x|
        next unless maze[y][x] == 0
        exits = [[1,0],[-1,0],[0,1],[0,-1]].count { |dx,dy| maze[y+dy][x+dx] == 0 }
        dead_ends << [x, y] if exits == 1 && [x, y] != [1, 1]
      end
    end
    exit_cell = (1...height - 1).flat_map do |y|
      (1...width - 1).filter_map { |x| [x, y] if maze[y][x] == 0 }
    end.max_by { |x, y| x + y }
    # Mirrors occupy wall cells directly above accessible floor cells.
    mirror_candidates = []
    (3...height - 2).each do |y|
      (2...width - 2).each do |x|
        next unless maze[y][x] == 1 && maze[y + 1][x] == 0
        next unless maze[y][x - 1] == 1 && maze[y][x + 1] == 1
        mirror_candidates << [[x, y + 1], [x, y]]
      end
    end
    mirror_candidates = mirror_candidates.each_with_index.select { |_v, i| i % 9 == 0 }.map(&:first).first(8)
    mirror_cells = mirror_candidates.map(&:first)
    mirror_wall_cells = mirror_candidates.map(&:last)
    scare_cells = [[13, 9], [29, 11], [43, 13], [11, 25], [31, 27], [43, 34]].select do |x, y|
      maze[y] && maze[y][x] == 0
    end

    mirror_map = Marshal.load(Marshal.dump(template_map))
    mirror_map.instance_variable_set(:@display_name, "Mê cung gương Atlantis")
    mirror_map.instance_variable_set(:@width, width)
    mirror_map.instance_variable_set(:@height, height)
    mirror_map.instance_variable_set(:@tileset_id, 4)
    mirror_map.instance_variable_set(:@scroll_type, 0)
    mirror_map.instance_variable_set(:@parallax_name, "")
    mirror_map.instance_variable_set(:@note, "[lighting on]\n[opacity 245]\n[color 000000000]\nAtlantis mirror maze; KUL height regions")
    table = blank_table(width, height, 4)

    # Learn the exact VX Ace autotile shapes from the generated Dungeon sample
    # (Map032). This gives us the same corners/edges as the editor's Generate
    # Dungeon command without hard-coding a single repeated shape.
    reference = load_data("Data/Map032.rvdata2")
    reference_table = reference.instance_variable_get(:@data)
    reference_raw = reference_table.instance_variable_get(:@marshal_data)
    _rdim, rw, rh, _rdepth, rsize = reference_raw.unpack("l<5")
    reference_values = reference_raw.byteslice(20, rsize * 2).unpack("s<*")
    ref_at = lambda { |x, y| reference_values[y * rw + x] }
    neighbour_mask = lambda do |mask, x, y|
      [[0,-1], [1,0], [0,1], [-1,0], [-1,-1], [1,-1], [1,1], [-1,1]].each_with_index.sum do |(dx, dy), bit|
        nx = x + dx
        ny = y + dy
        nx.between?(0, mask[0].size - 1) && ny.between?(0, mask.size - 1) && mask[ny][nx] ? (1 << bit) : 0
      end
    end
    learn_shapes = lambda do |base|
      same = Array.new(rh) { Array.new(rw, false) }
      rh.times do |y|
        rw.times do |x|
          tile_id = ref_at.call(x, y)
          same[y][x] = tile_id.between?(base, base + 47)
        end
      end
      result = {}
      rh.times do |y|
        rw.times do |x|
          next unless same[y][x]
          result[neighbour_mask.call(same, x, y)] ||= ref_at.call(x, y) - base
        end
      end
      result
    end
    floor_shapes = learn_shapes.call(3200)
    ceiling_shapes = learn_shapes.call(7520)
    face_shapes = learn_shapes.call(7904)
    choose_shape = lambda do |lookup, mask|
      lookup[mask] || lookup.min_by { |known, _shape| (known ^ mask).digits(2).count(1) }[1]
    end

    floor_mask = Array.new(height) { Array.new(width, false) }
    height.times { |y| width.times { |x| floor_mask[y][x] = maze[y][x] == 0 } }
    face_mask = Array.new(height) { Array.new(width, false) }
    floor_mask.each_with_index do |row, y|
      row.each_with_index do |floor, x|
        next unless floor
        [1, 2].each { |distance| face_mask[y - distance][x] = true if y - distance >= 0 && maze[y - distance][x] == 1 }
      end
    end
    ceiling_mask = Array.new(height) { Array.new(width, false) }
    height.times do |y|
      width.times do |x|
        next if floor_mask[y][x] || face_mask[y][x]
        neighbours = [[1,0],[-1,0],[0,1],[0,-1]]
        ceiling_mask[y][x] = neighbours.any? do |dx, dy|
          nx = x + dx
          ny = y + dy
          nx.between?(0, width - 1) && ny.between?(0, height - 1) &&
            (floor_mask[ny][nx] || face_mask[ny][nx])
        end
      end
    end

    height.times do |y|
      width.times do |x|
        if floor_mask[y][x]
          mask = neighbour_mask.call(floor_mask, x, y)
          table_set(table, x, y, 0, 3200 + choose_shape.call(floor_shapes, mask))
        elsif face_mask[y][x]
          mask = neighbour_mask.call(face_mask, x, y)
          table_set(table, x, y, 0, 7904 + choose_shape.call(face_shapes, mask))
        elsif ceiling_mask[y][x]
          mask = neighbour_mask.call(ceiling_mask, x, y)
          table_set(table, x, y, 0, 7520 + choose_shape.call(ceiling_shapes, mask))
          # A ceiling directly above a two-row face is height 2. KUL propagates
          # that height down both face rows. Side/bottom caps are height 1.
          two_row_face = y + 3 < height && face_mask[y + 1][x] &&
            face_mask[y + 2][x] && floor_mask[y + 3][x]
          table_set(table, x, y, 3, (two_row_face ? 2 : 1) << 8)
        end
      end
    end
    mirror_map.instance_variable_set(:@data, table)
    bgm = mirror_map.instance_variable_get(:@bgm)
    bgm.instance_variable_set(:@name, "Dungeon4") if bgm
    mirror_map.instance_variable_set(:@autoplay_bgm, true)

    mirror_events = {}
    setup_commands = [
      event_command(355, 0, ["$game_map.shadows.set_color(0,0,0)"]),
      event_command(355, 0, ["$game_map.shadows.set_opacity(245,30)"]),
      event_command(355, 0, ["$game_player.give_light(\"player_small\")"]),
      event_command(355, 0, ["$game_map.events.each_value {|e| src=e.instance_variable_get(:@event); e.opacity=0 if src && src.name =~ /^SCARE-/ }"]),
      event_command(121, 0, [35, 35, 0]),
      event_command(123, 0, ["A", 0])
    ]
    setup_page = page_from_template(template_event, setup_commands, trigger: 3, priority: 0)
    mirror_events[1] = event_from_pages(template_event, 1, "SYS-ATL-MIRROR-MAZE", 1, 1,
      [setup_page, blank_page.call])

    ex, ey = exit_cell
    exit_commands = [
      event_command(355, 0, ["$game_player.drop_light"]),
      event_command(355, 0, ["$game_map.shadows.set_opacity(0,20)"]),
      event_command(201, 0, [0, 29, 5, 7, 6, 0])
    ]
    exit_event = make_event.call(2, "EXIT-ATL-MIRROR-TO-CHASE", ex, ey, exit_commands, 1, 0)
    exit_event.instance_variable_get(:@pages).first.instance_variable_set(:@through, true)
    mirror_events[2] = exit_event

    # Sparse stationary lights create landmarks without defeating the lantern.
    [[8, 7], [27, 7], [43, 8], [12, 21], [30, 20], [43, 29]].each_with_index do |(x, y), index|
      next unless maze[y][x] == 0
      id = 30 + index
      page = page_from_template(template_event,
        [event_command(108, 0, ["[light broken]"])], trigger: 0, priority: 0)
      page.instance_variable_set(:@through, true)
      mirror_events[id] = event_from_pages(template_event, id, "LIGHT-ATL-FLICKER", x, y, [page])
    end

    mirror_wall_cells.each_with_index do |(x, y), index|
      id = 10 + index
      commands = [event_command(355, 0, ["mirror_maze_randomize(#{id})"])]
      event = make_event.call(id, "MIRROR-ATL-RANDOM", x, y, commands, 0, 1)
      event.instance_variable_get(:@pages).first.instance_variable_set(:@direction_fix, true)
      mirror_events[id] = event
    end

    scare_cells.each_with_index do |(x, y), index|
      id = 20 + index
      commands = [
        event_command(355, 0, ["$game_map.events[#{id}].opacity=255"]),
        event_command(355, 0, ["$game_map.events[#{id}].give_light(\"broken\")"]),
        event_command(355, 0, ["char_effect(#{id}, \"Appear\")"]),
        event_command(355, 0, ["RPG::SE.new(\"Monster2\",75,90).play"]),
        event_command(230, 0, [32]),
        event_command(225, 0, [5, 7, 18, false]),
        event_command(355, 0, ["char_effect(#{id}, \"Crazy\")"]),
        event_command(230, 0, [28]),
        event_command(355, 0, ["$game_map.events[#{id}].drop_light"]),
        event_command(355, 0, ["$game_map.events[#{id}].opacity=0"]),
        event_command(123, 0, ["A", 0])
      ]
      page = page_from_template(template_event, commands, trigger: 1, priority: 0)
      set_graphic.call(page, "Monster1", index % 8, 2, 1)
      page.instance_variable_set(:@through, true)
      mirror_events[id] = event_from_pages(template_event, id, "SCARE-ATL-GHOST", x, y,
        [page, blank_page.call])
    end
    mirror_map.instance_variable_set(:@events, mirror_events)
    save_data("Data/Map028.rvdata2", mirror_map)

    # Horizontal loop chase map.
    chase_width = 40
    chase_height = 15
    chase_map = Marshal.load(Marshal.dump(template_map))
    chase_map.instance_variable_set(:@display_name, "Atlantis — Hành lang truy đuổi")
    chase_map.instance_variable_set(:@width, chase_width)
    chase_map.instance_variable_set(:@height, chase_height)
    chase_map.instance_variable_set(:@tileset_id, 4)
    chase_map.instance_variable_set(:@scroll_type, 2)
    chase_map.instance_variable_set(:@parallax_name, "")
    chase_map.instance_variable_set(:@note, "Atlantis loop chase playtest with QTE")
    chase_table = blank_table(chase_width, chase_height, 4)
    chase_height.times do |y|
      chase_width.times do |x|
        floor = y.between?(6, 8)
        table_set(chase_table, x, y, 0, 2816)
        unless floor
          table_set(chase_table, x, y, 1, 6272)
          table_set(chase_table, x, y, 3, 1 << 8)
        end
      end
    end
    chase_map.instance_variable_set(:@data, chase_table)
    chase_bgm = chase_map.instance_variable_get(:@bgm)
    chase_bgm.instance_variable_set(:@name, "Battle3") if chase_bgm
    chase_map.instance_variable_set(:@autoplay_bgm, true)

    chase_events = {}
    chase_setup = [
      event_command(355, 0, ["$game_map.shadows.set_color(0,0,0)"]),
      event_command(355, 0, ["$game_map.shadows.set_opacity(185,20)"]),
      event_command(355, 0, ["$game_player.give_light(\"player_small\")"]),
      event_command(355, 0, ["char_effect(2, \"Giant\")"]),
      event_command(355, 0, ["$game_map.events[2].give_light(\"broken\")"]),
      event_command(355, 0, ["start_atlantis_chase(2,[3,4,5,6,7])"]),
      event_command(123, 0, ["A", 0])
    ]
    chase_setup_page = page_from_template(template_event, chase_setup, trigger: 3, priority: 0)
    chase_events[1] = event_from_pages(template_event, 1, "SYS-ATL-CHASE", 5, 7,
      [chase_setup_page, blank_page.call])

    monster_page = page_from_template(template_event, [], trigger: 0, priority: 1)
    set_graphic.call(monster_page, "Monster1", 0, 6, 1)
    monster_page.instance_variable_set(:@through, true)
    monster_page.instance_variable_set(:@direction_fix, true)
    chase_events[2] = event_from_pages(template_event, 2, "CHASE-ATL-ABYSS-MONSTER", 1, 7,
      [monster_page])

    (3..7).each do |id|
      obstacle_page = page_from_template(template_event, [], trigger: 0, priority: 0)
      set_graphic.call(obstacle_page, "Monster1", id - 2, 4, 1)
      obstacle_page.instance_variable_set(:@through, true)
      obstacle_page.instance_variable_set(:@direction_fix, true)
      chase_events[id] = event_from_pages(template_event, id, "QTE-ATL-OBSTACLE", 12 + id, 7,
        [obstacle_page])
    end
    chase_map.instance_variable_set(:@events, chase_events)
    save_data("Data/Map029.rvdata2", chase_map)

    # Route Map024 into the mirror maze after the existing memory intro.
    map24 = load_data("Data/Map024.rvdata2")
    intro = map24.instance_variable_get(:@events).fetch(1)
    page = intro.instance_variable_get(:@pages).first
    list = page.instance_variable_get(:@list)
    list.reject! do |command|
      command.instance_variable_get(:@code) == 201 &&
        (command.instance_variable_get(:@parameters) || [])[1] == 28
    end
    insert_at = list.index { |command| command.instance_variable_get(:@code) == 123 } || list.size - 1
    list.insert(insert_at, event_command(201, 0, [0, 28, 3, 3, 2, 0]))
    save_data("Data/Map024.rvdata2", map24)

    infos = load_data("Data/MapInfos.rvdata2")
    template_info = infos[25] || infos.values.compact.first
    max_order = infos.values.compact.map { |info| info.instance_variable_get(:@order).to_i }.max
    [[28, "Mê cung gương Atlantis"], [29, "Atlantis — Hành lang truy đuổi"]].each_with_index do |(id, name), offset|
      info = infos[id] || Marshal.load(Marshal.dump(template_info))
      info.instance_variable_set(:@name, name)
      info.instance_variable_set(:@parent_id, 0)
      info.instance_variable_set(:@order, max_order + offset + 1)
      info.instance_variable_set(:@expanded, true)
      info.instance_variable_set(:@scroll_x, 0)
      info.instance_variable_set(:@scroll_y, 0)
      infos[id] = info
    end
    save_data("Data/MapInfos.rvdata2", infos)

    verify28 = load_data("Data/Map028.rvdata2")
    verify29 = load_data("Data/Map029.rvdata2")
    raise "Map028 verification failed" unless verify28.instance_variable_get(:@events).size >= 7
    raise "Map029 verification failed" unless verify29.instance_variable_get(:@events).size == 7
    puts "CREATED|Map028|#{width}x#{height}|mirrors=#{mirror_cells.size}|scares=#{scare_cells.size}|exit=#{exit_cell.join(',')}"
    puts "CREATED|Map029|#{chase_width}x#{chase_height}|loop_horizontal=true|qte_obstacles=5"
    puts "CONNECTED|Map024->Map028->Map029->Map025"
  end

  def remove_khas_awesome_light_effects
    path = "Data/Scripts.rvdata2"
    scripts = load_data(path)
    matches = scripts.each_index.select do |index|
      scripts[index] && scripts[index][1].to_s == "Khas Awesome Light Effects"
    end
    raise "Expected exactly one Khas Awesome Light Effects slot, found #{matches.size}" unless matches.size == 1
    removed_index = matches.first
    scripts.delete_at(removed_index)
    save_data(path, scripts)
    raise "Khas Awesome Light Effects still present" if
      load_data(path).any? { |entry| entry && entry[1].to_s == "Khas Awesome Light Effects" }
    puts "REMOVED_SCRIPT|Khas Awesome Light Effects|former_slot=#{removed_index}"
  end

  def fix_atlantis_chase_exit_map
    path = "Data/Map025.rvdata2"
    map = load_data(path)
    raw = map.instance_variable_get(:@data).instance_variable_get(:@marshal_data)
    _dim, width, height, _depth, _size = raw.unpack("l<5")
    map.instance_variable_set(:@width, width)
    map.instance_variable_set(:@height, height)
    save_data(path, map)
    puts "FIXED|Map025|dimensions=#{width}x#{height}|matches_table=true"
  end

  def implement_atlantis_post_chase_scene
    map29_path = "Data/Map029.rvdata2"
    map25_path = "Data/Map025.rvdata2"
    map29 = load_data(map29_path)
    map25 = load_data(map25_path)
    map22 = load_data("Data/Map022.rvdata2")
    actors = load_data("Data/Actors.rvdata2")
    events29 = map29.instance_variable_get(:@events) || {}
    template_event = events29.values.first
    raise "Map029 event template missing" unless template_event

    actor = actors[3]
    raise "Hải Quỳ actor 3 missing" unless actor
    actor_name = actor.instance_variable_get(:@character_name).to_s
    actor_index = actor.instance_variable_get(:@character_index).to_i
    set_graphic = lambda do |page, name, index = 0, direction = 2, pattern = 1|
      graphic = page.instance_variable_get(:@graphic)
      graphic.instance_variable_set(:@tile_id, 0)
      graphic.instance_variable_set(:@character_name, name)
      graphic.instance_variable_set(:@character_index, index)
      graphic.instance_variable_set(:@direction, direction)
      graphic.instance_variable_set(:@pattern, pattern)
    end
    pop = lambda do |anchor, text|
      wrapped_message_commands([text], tag: "\\bm[#{anchor}] ", width: 24)
    end

    # Map029: insert the exact pre-chase exchange before the existing setup.
    setup_event = events29.fetch(1)
    setup_page = setup_event.instance_variable_get(:@pages).first
    existing_setup = setup_page.instance_variable_get(:@list) || []
    lighting_index = existing_setup.index do |command|
      command_code(command) == 355 && command_parameters(command)[0].to_s.include?("$game_map.shadows.set_color")
    end
    existing_setup = existing_setup[(lighting_index || 0)..-1].to_a
      .reject { |command| command_code(command) == 0 }
    prelude = [
      event_command(117, 0, [7]),
      event_command(355, 0, ["char_effect(0, \"Breath\")"]),
      event_command(355, 0, ["$game_map.events[2].opacity=0"]),
      event_command(355, 0, ["$game_map.events.values.each {|e| src=e.instance_variable_get(:@event); e.opacity=0 if src && src.name =~ /^FX-ATL-CLONE/ }"]),
      event_command(352, 0, [])
    ]
    [
      "Nghĩa vụ của ngươi…", "Nghĩa vụ của chúng ta…",
      "Tại sao chỉ có ngươi là còn sống?", "Niềm hi vọng…",
      "Còn sống nhưng thất bại…", "Tại sao không chết đi?",
      "Mì…thịt…kho…", "Không thể chết.", "Thà chết còn hơn.",
      "Thất bại.", "Thành công.", "Thảm hại."
    ].each_with_index do |line, index|
      prelude.concat(pop.call(2, line))
      if index == 0
        prelude.concat(pop.call(0, "Im đi! Im đi! Im đi!"))
        prelude << event_command(355, 0, ["$game_map.events.values.each {|e| src=e.instance_variable_get(:@event); e.opacity=255 if src && src.name =~ /^FX-ATL-CLONE/ }"])
        prelude << event_command(355, 0, ["(8..12).each {|id| char_effect(id, \"Appear\") }"])
      end
      if [2, 5, 8].include?(index)
        prelude << event_command(355, 0, ["(8..12).each {|id| e=$game_map.events[id]; e.move_toward_player if e }"])
      end
      prelude << event_command(230, 0, [10])
    end
    prelude.concat([
      event_command(117, 0, [6]),
      event_command(355, 0, ["$game_map.events.values.each {|e| src=e.instance_variable_get(:@event); e.opacity=0 if src && src.name =~ /^FX-ATL-CLONE/ }"]),
      event_command(355, 0, ["char_effect(0, \"Clear\")"]),
      event_command(355, 0, ["$game_map.events[2].opacity=255"]),
      event_command(355, 0, ["char_effect(2, \"Appear\")"]),
      event_command(355, 0, ["RPG::SE.new(\"Monster3\",85,80).play"]),
      event_command(225, 0, [7, 7, 28, false]),
      event_command(230, 0, [30]),
      # CE7 darkens/tints the prelude. Reset Map Effects before the playable
      # chase so only Map029's intended KUL shadow opacity remains.
      event_command(117, 0, [3])
    ])
    setup_page.instance_variable_set(:@list, prelude + existing_setup + [event_command(0, 0, [])])

    clone_positions = [[2, 6], [8, 6], [12, 7], [17, 8], [22, 6]]
    clone_positions.each_with_index do |(x, y), offset|
      id = 8 + offset
      page = page_from_template(template_event, [], trigger: 0, priority: 1)
      set_graphic.call(page, actor_name, actor_index, 2, 1)
      page.instance_variable_set(:@through, true)
      events29[id] = event_from_pages(template_event, id, "FX-ATL-CLONE", x, y, [page])
    end
    map29.instance_variable_set(:@events, events29)
    save_data(map29_path, map29)

    # Map025: replace the fabricated three-line prototype with the exact
    # confrontation from Scene 5.
    old_events25 = map25.instance_variable_get(:@events) || {}
    template25 = old_events25.values.first || template_event
    events25 = {}
    monster_page = page_from_template(template25, [], trigger: 0, priority: 1)
    set_graphic.call(monster_page, "Monster1", 0, 4, 1)
    monster_page.instance_variable_set(:@through, true)
    events25[2] = event_from_pages(template25, 2, "NPC-ATL-ABYSS-MONSTER", 12, 7, [monster_page])

    oni_source = (map22.instance_variable_get(:@events) || {})[7]
    oni_page = if oni_source
      Marshal.load(Marshal.dump(oni_source.instance_variable_get(:@pages).first))
    else
      page_from_template(template25, [], trigger: 0, priority: 1)
    end
    oni_page.instance_variable_set(:@list, [event_command(0, 0, [])])
    oni_page.instance_variable_set(:@through, true)
    events25[3] = event_from_pages(template25, 3, "NPC-ATL-ONI-ONII", 8, 2, [oni_page])

    commands = [
      event_command(355, 0, ["$game_player.moveto(4,7)"]),
      event_command(355, 0, ["$game_player.set_direction(6)"]),
      event_command(355, 0, ["$game_map.events[3].opacity=0"]),
      event_command(355, 0, ["char_effect(2, \"Giant\")"]),
      event_command(122, 0, [40, 40, 0, 0, 2]),
      event_command(117, 0, [5])
    ]
    ["Ngươi…", "Chấp nhận…", "Nghĩa vụ…", "Bản năng…", "Nấu mì…", "Vứt bỏ…"].each { |line| commands.concat(pop.call(2, line)) }
    commands.concat(pop.call(0, "K-Không có nghĩa vụ nào hết! Bản năng gì chứ? Im đi!"))
    ["Đã là phế phẩm…", "Còn dám lên tiếng sao…?", "Được ban ân huệ…", "Lãng phí…"].each { |line| commands.concat(pop.call(2, line)) }
    commands.concat(pop.call(0, "Phế phẩm? Ta…Không phải phế phẩm!"))
    commands.concat(pop.call(0, "Ta là…Dahria…!"))
    ["Không phải tên ngươi…", "Ngươi chẳng là gì…", "Ngươi chẳng có tên…", "Dahria…", "Cũng là phế thải…"].each { |line| commands.concat(pop.call(2, line)) }
    commands.concat(pop.call(0, "…!!"))
    commands.concat([
      event_command(355, 0, ["$game_map.events[2].moveto(10,7)"]),
      event_command(225, 0, [4, 5, 18, false])
    ])
    ["Mau nhớ lại đi…", "Ngươi là…ai…?", "Ai…là ngươi…?"].each { |line| commands.concat(pop.call(2, line)) }
    commands.concat(pop.call(0, "...Ta…Ta là…"))
    commands.concat(pop.call(0, "...."))
    commands << event_command(117, 0, [4])
    [
      "Dahria…có thể không phải tên của ta.",
      "Nên…", "Ta sẽ khẳng định…Dahria…chính là ta!"
    ].each { |line| commands.concat(pop.call(0, line)) }
    commands.concat(pop.call(2, "Ngươi…"))
    [
      "Tính chơi đòn tâm lý với ta à?", "Ngươi cũng to gan đấy…!",
      "Lại còn dám cả gan đột nhập vào nhà ta nữa!"
    ].each { |line| commands.concat(pop.call(0, line)) }
    commands.concat(pop.call(2, "???"))
    [
      "Để ta nói cho thấu nhé!", "TA!",
      "Không phải thí nghiệm, tạo vật hay phế phẩm thất bại mà ngươi nói!",
      "Ta cũng muốn cù nhây với ngươi thêm chút nữa đó.",
      "Cơ mà anh ta không cho phép đâu."
    ].each { |line| commands.concat(pop.call(0, line)) }
    commands.concat(pop.call(2, "DAHRIAAAAAAAAAAAAAAAAAAAAAA"))
    [
      "Đấy, thấy chưa?", "À, để ta nói cho ngươi nghe cái này.",
      "Anh trai ta…cực ghét quái vật vực sâu luôn.", "Nên là…!!!"
    ].each { |line| commands.concat(pop.call(0, line)) }

    commands.concat([
      event_command(355, 0, ["$game_map.events[3].opacity=255"]),
      event_command(355, 0, ["char_effect(3, \"Appear\")"]),
      event_command(122, 0, [40, 40, 0, 0, 3]),
      event_command(117, 0, [2])
    ])
    commands.concat(pop.call(3, "ECLIPSE BLOCKCHAIN!!!"))
    commands.concat([
      event_command(355, 0, ["a=$data_animations.compact.find {|x| x.name =~ /(Bind|Chain|Dark|Thunder)/i}; $game_map.events[2].animation_id=(a ? a.id : 1)"]),
      event_command(225, 0, [6, 7, 24, false]),
      event_command(230, 0, [30])
    ])
    commands.concat(pop.call(3, "Tao đợi mày úp mì chắc tới tết công gô mất!"))
    commands.concat(pop.call(3, "Nhanh giải quyết nó đi!"))
    commands.concat(pop.call(0, "Biết rồi!!!"))
    commands.concat(pop.call(0, "ANEMONE DIAMOND SHOWERRRRRRR"))
    commands.concat([
      event_command(117, 0, [6]),
      event_command(355, 0, ["a=$data_animations.compact.find {|x| x.name =~ /(Light|Laser|Thunder|Holy)/i}; $game_map.events[2].animation_id=(a ? a.id : 1)"]),
      event_command(225, 0, [10, 8, 60, false]),
      event_command(230, 0, [45]),
      event_command(221, 0, []),
      event_command(121, 0, [33, 33, 0]),
      event_command(122, 0, [30, 30, 0, 0, 5]),
      event_command(355, 0, ["$game_player.drop_light"]),
      event_command(355, 0, ["$game_map.events[2].drop_light if $game_map.events[2]"]),
      event_command(117, 0, [3]),
      event_command(123, 0, ["A", 0])
    ])
    main_page = page_from_template(template25, commands, trigger: 3, priority: 0, switch_id: 36)
    blank_page = page_from_template(template25, [], trigger: 0, priority: 0, self_switch: "A")
    events25[1] = event_from_pages(template25, 1, "SCN-ATL-POST-CHASE", 1, 1, [main_page, blank_page])
    map25.instance_variable_set(:@events, events25)
    map25.instance_variable_set(:@display_name, "Atlantis — Đối đầu Vực Sâu")
    save_data(map25_path, map25)

    puts "IMPLEMENTED|Map029|prelude=true|clones=5|exact_source=Scene5"
    puts "IMPLEMENTED|Map025|post_chase=true|events=3|fabricated_Aira_line_removed=true"
  end

  def create_atlantis_clone_encirclement_map
    map28_path = "Data/Map028.rvdata2"
    map29_path = "Data/Map029.rvdata2"
    map34_path = "Data/Map034.rvdata2"
    map28 = load_data(map28_path)
    map29 = load_data(map29_path)
    actors = load_data("Data/Actors.rvdata2")
    events29 = map29.instance_variable_get(:@events) || {}
    template_event = events29.values.first
    raise "Map029 event template missing" unless template_event

    actor = actors[3]
    raise "Hải Quỳ actor 3 missing" unless actor
    actor_name = actor.instance_variable_get(:@character_name).to_s
    actor_index = actor.instance_variable_get(:@character_index).to_i
    set_graphic = lambda do |page, name, index = 0, direction = 2, pattern = 1|
      graphic = page.instance_variable_get(:@graphic)
      graphic.instance_variable_set(:@tile_id, 0)
      graphic.instance_variable_set(:@character_name, name)
      graphic.instance_variable_set(:@character_index, index)
      graphic.instance_variable_set(:@direction, direction)
      graphic.instance_variable_set(:@pattern, pattern)
    end
    pop = lambda do |anchor, text|
      wrapped_message_commands([text], tag: "\\bm[#{anchor}] ", width: 24)
    end

    # Map034 inherits only the proven chase corridor tiles; all event content
    # is rebuilt as a dedicated cutscene.
    map34 = Marshal.load(Marshal.dump(map29))
    map34.instance_variable_set(:@display_name, "Atlantis — Vòng vây bản thể")
    map34.instance_variable_set(:@scroll_type, 0)
    map34.instance_variable_set(:@note,
      "[lighting on]\n[opacity 185]\n[color 000000000]\n" \
      "Atlantis clone encirclement cutscene; leads to Map029")
    events34 = {}

    monster_page = page_from_template(template_event, [], trigger: 0, priority: 1)
    set_graphic.call(monster_page, "Monster1", 0, 6, 1)
    monster_page.instance_variable_set(:@through, true)
    events34[2] = event_from_pages(template_event, 2, "NPC-ATL-ABYSS-SHADOW", 10, 7, [monster_page])

    clone_lines = [
      "Nghĩa vụ của ngươi…", "Nghĩa vụ của chúng ta…",
      "Tại sao chỉ có ngươi là còn sống?", "Còn sống nhưng thất bại…",
      "Tại sao không chết đi?", "Mì…thịt…kho…", "Không thể chết.",
      "Thà chết còn hơn.", "Thất bại.", "Thành công.", "Thảm hại."
    ]
    clone_positions = [[9,6], [10,7], [9,8], [12,6], [12,8], [16,6],
      [16,8], [18,6], [18,8], [20,6], [20,8]]
    clone_lines.each_with_index do |_line, offset|
      id = 3 + offset
      x, y = clone_positions[offset]
      page = page_from_template(template_event, [], trigger: 0, priority: 1)
      set_graphic.call(page, actor_name, actor_index, x < 15 ? 6 : 4, 1)
      page.instance_variable_set(:@through, true)
      events34[id] = event_from_pages(template_event, id, "FX-ATL-CLONE-VOICE", x, y, [page])
    end

    scene = [
      event_command(355, 0, ["$game_player.moveto(15,7)"]),
      event_command(355, 0, ["$game_player.set_direction(2)"]),
      event_command(355, 0, ["$game_map.shadows.set_color(0,0,0)"]),
      event_command(355, 0, ["$game_map.shadows.set_opacity(185,20)"]),
      event_command(355, 0, ["$game_player.give_light(\"player_small\")"]),
      event_command(355, 0, ["$game_map.events[2].opacity=0"]),
      event_command(355, 0, ["char_effect(0, \"Breath\")"]),
      event_command(213, 0, [-1, 6, false]),
      event_command(352, 0, []),
      event_command(117, 0, [7])
    ]
    (3..13).each do |id|
      scene << event_command(355, 0, ["char_effect(#{id}, \"Appear\")"])
      scene << event_command(355, 0, ["$game_map.events[#{id}].give_light(\"atlantis_clone\")"])
    end
    clone_lines.each_with_index do |line, offset|
      id = 3 + offset
      scene.concat(pop.call(id, line))
      scene << event_command(355, 0, ["$game_map.events[#{id}].move_toward_player"])
      scene << event_command(230, 0, [10])
      if offset == 0
        scene << event_command(213, 0, [-1, 5, false])
        scene.concat(pop.call(0, "Im đi! Im đi! Im đi!"))
      end
    end
    scene.concat([
      event_command(355, 0, ["(3..13).each {|id| e=$game_map.events[id]; e.drop_light; e.opacity=0 }"]),
      event_command(355, 0, ["char_effect(0, \"Clear\")"]),
      event_command(213, 0, [-1, 11, false]),
      event_command(355, 0, ["$game_map.events[2].opacity=255"]),
      event_command(355, 0, ["char_effect(2, \"Giant\")"]),
      event_command(355, 0, ["char_effect(2, \"Appear\")"]),
      event_command(355, 0, ["$game_map.events[2].give_light(\"red\")"]),
      event_command(355, 0, ["RPG::SE.new(\"Monster3\",85,80).play"]),
      event_command(117, 0, [6]),
      event_command(225, 0, [7, 7, 28, false]),
      event_command(230, 0, [30]),
      event_command(117, 0, [3]),
      event_command(355, 0, ["$game_player.drop_light"]),
      event_command(355, 0, ["$game_map.events[2].drop_light if $game_map.events[2]"]),
      event_command(355, 0, ["$game_map.shadows.set_opacity(0,10)"]),
      event_command(201, 0, [0, 29, 5, 7, 6, 0]),
      event_command(123, 0, ["A", 0])
    ])
    main_page = page_from_template(template_event, scene, trigger: 3, priority: 0)
    blank_page = page_from_template(template_event, [], trigger: 0, priority: 0, self_switch: "A")
    events34[1] = event_from_pages(template_event, 1, "SCN-ATL-CLONE-ENCIRCLEMENT", 1, 1,
      [main_page, blank_page])
    map34.instance_variable_set(:@events, events34)
    save_data(map34_path, map34)

    # Map029 becomes gameplay-only again.
    setup29 = events29.fetch(1).instance_variable_get(:@pages).first
    list29 = setup29.instance_variable_get(:@list) || []
    lighting_index = list29.index do |command|
      command_code(command) == 355 && command_parameters(command)[0].to_s.include?("$game_map.shadows.set_color")
    end
    raise "Map029 chase setup marker missing" unless lighting_index
    setup29.instance_variable_set(:@list, list29[lighting_index..-1])
    events29.delete_if do |_id, event|
      event.instance_variable_get(:@name).to_s.start_with?("FX-ATL-CLONE")
    end
    map29.instance_variable_set(:@note,
      "[lighting on]\n[opacity 185]\n[color 000000000]\n" \
      "Atlantis clone chase gameplay")
    (3..7).each do |id|
      event = events29[id]
      next unless event
      event.instance_variable_set(:@name, "QTE-ATL-OBSTRUCTING-CLONE [E%03d]" % id)
      page = event.instance_variable_get(:@pages).first
      set_graphic.call(page, actor_name, actor_index, 4, 1)
      page.instance_variable_set(:@priority_type, 1)
      page.instance_variable_set(:@through, true)
    end
    map29.instance_variable_set(:@events, events29)
    save_data(map29_path, map29)

    # Per user instruction, change only Map028's transfer destination.
    changed = 0
    (map28.instance_variable_get(:@events) || {}).each_value do |event|
      (event.instance_variable_get(:@pages) || []).each do |page|
        (page.instance_variable_get(:@list) || []).each do |command|
          next unless command_code(command) == 201
          params = command_parameters(command)
          next unless params[1] == 29
          params[1] = 34
          changed += 1
        end
      end
    end
    existing_to_34 = 0
    (map28.instance_variable_get(:@events) || {}).each_value do |event|
      (event.instance_variable_get(:@pages) || []).each do |page|
        existing_to_34 += (page.instance_variable_get(:@list) || []).count do |command|
          command_code(command) == 201 && command_parameters(command)[1] == 34
        end
      end
    end
    raise "Map028 chase transfer missing or duplicated" unless changed == 1 || (changed == 0 && existing_to_34 == 1)
    save_data(map28_path, map28)

    infos = load_data("Data/MapInfos.rvdata2")
    template_info = infos[29] || infos.values.compact.first
    info = infos[34] || Marshal.load(Marshal.dump(template_info))
    info.instance_variable_set(:@name, "Atlantis — Vòng vây bản thể")
    info.instance_variable_set(:@parent_id, 0)
    info.instance_variable_set(:@order,
      infos.values.compact.map { |entry| entry.instance_variable_get(:@order).to_i }.max + 1)
    info.instance_variable_set(:@expanded, true)
    infos[34] = info
    save_data("Data/MapInfos.rvdata2", infos)

    puts "CREATED|Map034|clone_cutscene=true|clones=11|transfer=Map029"
    puts "UPDATED|Map029|gameplay_only=true|events=#{events29.size}"
    puts "UPDATED|Map028|transfer_only=Map029->Map034|count=#{changed}"
  end

  def rebuild_atlantis_vertical_clone_chase
    set_graphic = lambda do |page, name, index = 0, direction = 2, pattern = 1|
      graphic = page.instance_variable_get(:@graphic)
      graphic.instance_variable_set(:@tile_id, 0)
      graphic.instance_variable_set(:@character_name, name)
      graphic.instance_variable_set(:@character_index, index)
      graphic.instance_variable_set(:@direction, direction)
      graphic.instance_variable_set(:@pattern, pattern)
    end
    make_vertical_table = lambda do |width, height|
      table = blank_table(width, height, 4)
      height.times do |y|
        width.times do |x|
          floor = x.between?(8, 12)
          table_set(table, x, y, 0, 2816)
          unless floor
            table_set(table, x, y, 1, 6272)
            table_set(table, x, y, 3, 1 << 8)
          end
        end
      end
      table
    end

    map34 = load_data("Data/Map034.rvdata2")
    map34.instance_variable_set(:@width, 20)
    map34.instance_variable_set(:@height, 20)
    map34.instance_variable_set(:@scroll_type, 0)
    map34.instance_variable_set(:@data, make_vertical_table.call(20, 20))
    map34.instance_variable_set(:@note,
      "[lighting on]\n[opacity 185]\n[color 000000000]\n" \
      "Vertical Atlantis clone encirclement; custom monster overlay")
    events34 = map34.instance_variable_get(:@events)
    events34[1].instance_variable_set(:@x, 1)
    events34[1].instance_variable_set(:@y, 1)
    events34[2].instance_variable_set(:@x, 10)
    events34[2].instance_variable_set(:@y, 3)
    set_graphic.call(events34[2].instance_variable_get(:@pages).first, "", 0, 8, 1)
    clone_positions = [[9,6],[10,5],[11,6],[8,8],[12,8],[8,10],
      [12,10],[8,12],[12,12],[9,14],[11,14]]
    (3..13).each do |id|
      event = events34[id]
      x,y = clone_positions[id-3]
      event.instance_variable_set(:@x,x)
      event.instance_variable_set(:@y,y)
      page=event.instance_variable_get(:@pages).first
      set_graphic.call(page,"$Clone#{id-2}",0,y<10 ? 2 : 8,1)
    end
    page34=events34[1].instance_variable_get(:@pages).first
    list34=page34.instance_variable_get(:@list)
    list34.reject! do |command|
      command_code(command)==355 &&
        command_parameters(command)[0].to_s.include?('char_effect(2, "Giant")')
    end
    list34.each do |command|
      params=command_parameters(command)
      if command_code(command)==355
        params[0]="$game_player.moveto(10,10)" if params[0]=="$game_player.moveto(15,7)"
        params[0]="$game_player.set_direction(8)" if params[0]=="$game_player.set_direction(2)"
      elsif command_code(command)==201 && params[1]==29
        command.instance_variable_set(:@parameters,[0,29,10,30,2,0])
      end
    end
    save_data("Data/Map034.rvdata2",map34)

    map29=load_data("Data/Map029.rvdata2")
    map29.instance_variable_set(:@width,20)
    map29.instance_variable_set(:@height,40)
    map29.instance_variable_set(:@scroll_type,1)
    map29.instance_variable_set(:@data,make_vertical_table.call(20,40))
    map29.instance_variable_set(:@note,
      "[lighting on]\n[opacity 185]\n[color 000000000]\n" \
      "Vertical Atlantis clone chase; custom Monster1 overlay")
    events29=map29.instance_variable_get(:@events)
    template=events29[3]
    events29[1].instance_variable_set(:@x,1)
    events29[1].instance_variable_set(:@y,1)
    setup=events29[1].instance_variable_get(:@pages).first
    setup_list=setup.instance_variable_get(:@list)
    setup_list.reject! do |command|
      command_code(command)==355 &&
        command_parameters(command)[0].to_s.include?('char_effect(2, "Giant")')
    end
    setup_list.each do |command|
      next unless command_code(command)==355
      text=command_parameters(command)[0].to_s
      if text.include?("start_atlantis_chase")
        command.instance_variable_set(:@parameters,
          ["start_atlantis_chase(2,(3..13).to_a)"])
      end
    end
    events29[2].instance_variable_set(:@x,10)
    events29[2].instance_variable_set(:@y,26)
    set_graphic.call(events29[2].instance_variable_get(:@pages).first,"",0,8,1)
    (3..13).each do |id|
      events29[id]=Marshal.load(Marshal.dump(template)) unless events29[id]
      event=events29[id]
      event.instance_variable_set(:@id,id)
      event.instance_variable_set(:@name,
        "QTE-ATL-OBSTRUCTING-CLONE [E%03d]" % id)
      event.instance_variable_set(:@x,10)
      event.instance_variable_set(:@y,20-id)
      page=event.instance_variable_get(:@pages).first
      set_graphic.call(page,"$Clone#{id-2}",0,2,1)
      page.instance_variable_set(:@priority_type,1)
      page.instance_variable_set(:@through,true)
    end
    map29.instance_variable_set(:@events,events29)
    save_data("Data/Map029.rvdata2",map29)

    map25=load_data("Data/Map025.rvdata2")
    events25=map25.instance_variable_get(:@events)
    events25[2].instance_variable_set(:@x,8)
    events25[2].instance_variable_set(:@y,4)
    set_graphic.call(events25[2].instance_variable_get(:@pages).first,"",0,2,1)
    events25[3].instance_variable_set(:@x,8)
    events25[3].instance_variable_set(:@y,7)
    set_graphic.call(events25[3].instance_variable_get(:@pages).first,
      "",0,2,0)
    main25=events25[1].instance_variable_get(:@pages).first
    list25=main25.instance_variable_get(:@list)
    list25.reject! do |command|
      command_code(command)==355 &&
        command_parameters(command)[0].to_s.include?('char_effect(2, "Giant")')
    end
    list25.each do |command|
      next unless command_code(command)==355
      text=command_parameters(command)[0].to_s
      command.instance_variable_set(:@parameters,["$game_player.moveto(8,10)"]) if text=="$game_player.moveto(4,7)"
      command.instance_variable_set(:@parameters,["$game_player.set_direction(8)"]) if text=="$game_player.set_direction(6)"
      command.instance_variable_set(:@parameters,["$game_map.events[2].moveto(8,4)"]) if text=="$game_map.events[2].moveto(10,7)"
    end
    appear_index=list25.index do |command|
      command_code(command)==355 &&
        command_parameters(command)[0].to_s=='char_effect(3, "Appear")'
    end
    raise "Map025 OniOnii appear marker missing" unless appear_index
    landing=[]
    [[2,0],[2,1],[2,2],[4,0],[4,1],[4,2],[6,0],[6,1]].each do |direction,pattern|
      landing << event_command(355,0,
        ["e=$game_map.events[3]; e.set_direction(#{direction}); e.instance_variable_set(:@pattern,#{pattern})"])
      landing << event_command(230,0,[5])
    end
    list25.insert(appear_index+1,*landing)
    eclipse_index=list25.index do |command|
      command_code(command)==401 && command_parameters(command)[0].to_s.include?("ECLIPSE BLOCKCHAIN")
    end
    raise "Map025 Eclipse line missing" unless eclipse_index
    bind_index=(eclipse_index+1...list25.size).find do |index|
      command_code(list25[index])==355 &&
        command_parameters(list25[index])[0].to_s.include?("animation_id")
    end
    raise "Map025 bind animation marker missing" unless bind_index
    list25.insert(bind_index,event_command(355,0,["atlantis_monster_mode(2,:bound)"]))
    wait_index=(bind_index+1...list25.size).find {|index| command_code(list25[index])==230}
    if wait_index
      list25.insert(wait_index+1,event_command(355,0,
        ["e=$game_map.events[3]; e.set_graphic(\"$OniOnii\",0); e.set_direction(2)"]))
    end
    save_data("Data/Map025.rvdata2",map25)

    puts "REBUILT|Map034|vertical=true|clones=Clone1..Clone11"
    puts "REBUILT|Map029|20x40|loop_vertical=true|clones=Clone1..Clone11"
    puts "UPDATED|Map025|vertical_confrontation=true|OniOnii_landing=true|Monster_bound=true"
  end

  # Corrects the already-built chase without rebuilding its cutscenes.
  # Hải Quỳ runs downward, so the monster anchor must stay above/behind her.
  def fix_atlantis_chase_downward
    map34 = load_data("Data/Map034.rvdata2")
    events34 = map34.instance_variable_get(:@events) || {}
    monster34 = events34[2]
    raise "Map034 monster anchor missing" unless monster34
    monster34.instance_variable_set(:@x, 10)
    monster34.instance_variable_set(:@y, 3)
    transfer_count = 0
    events34.each_value do |event|
      event.instance_variable_get(:@pages).each do |page|
        page.instance_variable_get(:@list).each do |command|
          next unless command_code(command) == 201
          params = command_parameters(command)
          next unless params[1] == 29
          command.instance_variable_set(:@parameters, [0, 29, 10, 30, 2, 0])
          transfer_count += 1
        end
      end
    end
    raise "Map034 -> Map029 transfer missing" if transfer_count == 0
    save_data("Data/Map034.rvdata2", map34)

    map29 = load_data("Data/Map029.rvdata2")
    events29 = map29.instance_variable_get(:@events) || {}
    monster29 = events29[2]
    raise "Map029 monster anchor missing" unless monster29
    monster29.instance_variable_set(:@x, 10)
    monster29.instance_variable_set(:@y, 26)
    save_data("Data/Map029.rvdata2", map29)

    puts "FIXED|Map034->Map029|direction=down|transfer_direction=2"
    puts "FIXED|monster_anchors|Map034=(10,3)|Map029=(10,26)"
  end

  def polish_atlantis_chase_staging
    map35 = load_data("Data/Map035.rvdata2")
    events35 = map35.instance_variable_get(:@events) || {}
    paulie = events35[3]
    raise "Map035 Paulie event E003 missing" unless paulie
    paulie_page = paulie.instance_variable_get(:@pages).first
    paulie_graphic = paulie_page.instance_variable_get(:@graphic)
    paulie_graphic.instance_variable_set(:@character_name, "$OniOnii")
    paulie_graphic.instance_variable_set(:@character_index, 0)
    save_data("Data/Map035.rvdata2", map35)

    map25 = load_data("Data/Map025.rvdata2")
    events25 = map25.instance_variable_get(:@events) || {}
    main = events25[1]
    monster = events25[2]
    raise "Map025 staging events missing" unless main && monster
    monster.instance_variable_set(:@x, 8)
    monster.instance_variable_set(:@y, 6)
    list = main.instance_variable_get(:@pages).first.instance_variable_get(:@list)
    list.each do |command|
      next unless command_code(command) == 355
      text = command_parameters(command)[0].to_s
      if text == "$game_player.moveto(8,10)"
        command.instance_variable_set(:@parameters, ["$game_player.moveto(8,8)"])
      elsif text == "$game_map.events[2].moveto(8,4)"
        command.instance_variable_set(:@parameters,
          ["$game_map.events[2].moveto(8,6)"])
      end
    end
    retreat_marker = "$game_player.jump(0,2) # ATL_PAULIE_RETREAT"
    unless list.any? {|command| command_code(command) == 355 &&
      command_parameters(command)[0].to_s == retreat_marker }
      landing_index = list.index do |command|
        command_code(command) == 355 &&
          command_parameters(command)[0].to_s == "$game_map.events[3].opacity=255"
      end
      raise "Map025 Paulie landing marker missing" unless landing_index
      retreat = [
        event_command(355, 0, ["$game_player.set_direction(8)"]),
        event_command(213, 0, [-1, 1, false]),
        event_command(355, 0, [retreat_marker]),
        event_command(230, 0, [24])
      ]
      list.insert(landing_index, *retreat)
    end
    save_data("Data/Map025.rvdata2", map25)

    puts "UPDATED|Map035|Paulie=$OniOnii"
    puts "UPDATED|Map025|HQ=(8,8)->jump(0,2)|monster=(8,6)"
  end

  def rebuild_atlantis_paulie_drop
    map25 = load_data("Data/Map025.rvdata2")
    events = map25.instance_variable_get(:@events) || {}
    main = events[1]
    raise "Map025 main event E001 missing" unless main
    list = main.instance_variable_get(:@pages).first.instance_variable_get(:@list)

    unless list.any? {|command| command_code(command) == 355 &&
      command_parameters(command)[0].to_s == "atlantis_paulie_high_drop(3)" }
      landing_start = list.index do |command|
        command_code(command) == 355 &&
          command_parameters(command)[0].to_s == "$game_map.events[3].opacity=255"
      end
      landing_end = (landing_start...list.size).find do |index|
        command_code(list[index]) == 122 &&
          command_parameters(list[index])[0] == 40 &&
          command_parameters(list[index])[4] == 3
      end if landing_start
      raise "Map025 old Paulie landing block missing" unless landing_start && landing_end
      list[landing_start...landing_end] = [
        event_command(355, 0, ["atlantis_paulie_high_drop(3)"])
      ]
    end

    eclipse_index = list.index do |command|
      command_code(command) == 401 &&
        command_parameters(command)[0].to_s.include?("ECLIPSE BLOCKCHAIN")
    end
    raise "Map025 Eclipse line missing" unless eclipse_index
    paulie_normal = (eclipse_index+1...list.size).find do |index|
      command_code(list[index]) == 355 &&
        command_parameters(list[index])[0].to_s.include?('set_graphic("$OniOnii"')
    end
    raise "Map025 Paulie normal graphic marker missing" unless paulie_normal
    control_sequence = [
      event_command(355, 0, ["$game_map.events[2].animation_id=139"]),
      event_command(355, 0, ["RPG::SE.new(\"Thunder9\",90,90).play"]),
      event_command(225, 0, [6, 7, 24, false]),
      event_command(230, 0, [45]),
      event_command(355, 0, ["atlantis_monster_mode(2,:bound)"]),
      event_command(230, 0, [60])
    ]
    list[(eclipse_index+1)...paulie_normal] = control_sequence

    attack_index = list.index do |command|
      command_code(command) == 355 &&
        command_parameters(command)[0].to_s.include?("/(Light|Laser|Thunder|Holy)/i")
    end
    raise "Map025 Hải Quỳ attack animation marker missing" unless attack_index
    list[attack_index] = event_command(355, 0,
      ["$game_map.events[2].animation_id=147"])
    save_data("Data/Map025.rvdata2", map25)
    puts "UPDATED|Map025|Paulie_high_drop=true|animations=138,139,147"
  end

  def fix_atlantis_paulie_transition
    map25 = load_data("Data/Map025.rvdata2")
    events = map25.instance_variable_get(:@events) || {}
    main = events[1]
    paulie = events[3]
    raise "Map025 transition events missing" unless main && paulie
    page = paulie.instance_variable_get(:@pages).first
    graphic = page.instance_variable_get(:@graphic)
    graphic.instance_variable_set(:@character_name, "")
    graphic.instance_variable_set(:@character_index, 0)
    list = main.instance_variable_get(:@pages).first.instance_variable_get(:@list)
    list.reject! {|command| command_code(command) == 222 }
    hide_index = list.index do |command|
      command_code(command) == 355 &&
        command_parameters(command)[0].to_s == "$game_map.events[3].opacity=0"
    end
    raise "Map025 Paulie hide marker missing" unless hide_index
    save_data("Data/Map025.rvdata2", map25)
    puts "UPDATED|Map025|Paulie_default_graphic=blank|transfer_fade=standard_black"
  end

  def stage_atlantis_clone_ambush
    map28 = load_data("Data/Map028.rvdata2")
    exit_event = (map28.instance_variable_get(:@events) || {})[2]
    raise "Map028 exit E002 missing" unless exit_event
    exit_list = exit_event.instance_variable_get(:@pages).first.
      instance_variable_get(:@list)
    transfer_index = exit_list.index do |command|
      command_code(command) == 201 && command_parameters(command)[1] == 34
    end
    raise "Map028 -> Map034 transfer missing" unless transfer_index
    unless transfer_index > 0 && command_code(exit_list[transfer_index-1]) == 221
      exit_list.insert(transfer_index, event_command(221, 0, []))
      transfer_index += 1
    end
    transfer = exit_list[transfer_index]
    params = command_parameters(transfer).dup
    params[5] = 2
    transfer.instance_variable_set(:@parameters, params)
    save_data("Data/Map028.rvdata2", map28)

    map34 = load_data("Data/Map034.rvdata2")
    events34 = map34.instance_variable_get(:@events) || {}
    main = events34[1]
    monster = events34[2]
    raise "Map034 main/monster event missing" unless main && monster
    monster.instance_variable_set(:@x, 10)
    monster.instance_variable_set(:@y, 0)
    list = main.instance_variable_get(:@pages).first.instance_variable_get(:@list)
    player_pos = list.index do |command|
      command_code(command) == 355 &&
        command_parameters(command)[0].to_s == "$game_player.moveto(10,10)"
    end
    raise "Map034 player position marker missing" unless player_pos
    list.reject! {|command| command_code(command) == 222 }
    hide_monster_index = list.index do |command|
      command_code(command) == 355 &&
        command_parameters(command)[0].to_s == "$game_map.events[2].opacity=0"
    end
    raise "Map034 monster hide marker missing" unless hide_monster_index
    clone_hide = "(3..13).each {|id| $game_map.events[id].opacity=0 }"
    unless list.any? {|command| command_code(command) == 355 &&
      command_parameters(command)[0].to_s == clone_hide }
      list.insert(hide_monster_index+1, event_command(355, 0, [clone_hide]))
      hide_monster_index += 1
    else
      hide_monster_index = list.index do |command|
        command_code(command) == 355 &&
          command_parameters(command)[0].to_s == clone_hide
      end
    end
    list.insert(hide_monster_index+1, event_command(222, 0, []))

    unless list.any? {|command| command_code(command) == 355 &&
      command_parameters(command)[0].to_s.include?("wait_for_atlantis_clone_grab") }
      slot = 0
      list.each do |command|
        next unless command_code(command) == 355
        text = command_parameters(command)[0].to_s
        match = text.match(/^\$game_map\.events\[(\d+)\]\.move_toward_player$/)
        next unless match
        event_id = match[1].to_i
        command.instance_variable_set(:@parameters,
          ["atlantis_clone_grab(#{event_id},#{slot})"])
        slot += 1
      end
      raise "Map034 expected 11 clone approaches, found #{slot}" unless slot == 11

      cleanup_index = list.index do |command|
        command_code(command) == 355 &&
          command_parameters(command)[0].to_s.start_with?("(3..13).each")
      end
      raise "Map034 clone cleanup marker missing" unless cleanup_index
      breakout = [
        event_command(355, 0, ["wait_for_atlantis_clone_grab(3,13)"]),
        event_command(101, 0, ["", 0, 0, 2]),
        event_command(401, 0, ["\\bm[0] Buông tao ra!"]),
        event_command(355, 0,
          ["a=$data_animations.compact.find {|x| x.name =~ /(Burst|Explosion|Light|Holy|Thunder|Blow)/i}; $game_player.animation_id=(a ? a.id : 1)"]),
        event_command(355, 0, ["atlantis_blast_clones(3,13)"]),
        event_command(213, 0, [-1, 1, false]),
        event_command(355, 0, ["$game_player.set_direction(8)"]),
        event_command(230, 0, [18])
      ]
      list[cleanup_index, 1] = breakout

      opacity_index = list.index do |command|
        command_code(command) == 355 &&
          command_parameters(command)[0].to_s == "$game_map.events[2].opacity=255"
      end
      raise "Map034 monster reveal marker missing" unless opacity_index
      list[opacity_index] = event_command(355, 0, ["atlantis_monster_enter(2)"])
      list.reject! do |command|
        next false unless command_code(command) == 355
        text = command_parameters(command)[0].to_s
        text == 'char_effect(2, "Appear")' ||
          text == '$game_map.events[2].give_light("red")'
      end
    end
    save_data("Data/Map034.rvdata2", map34)

    puts "UPDATED|Map028->Map034|explicit_fadeout=true"
    puts "UPDATED|Map034|clone_grab=11|breakout=true|monster_entry=true"
  end

  def expand_atlantis_chase_clones
    map29 = load_data("Data/Map029.rvdata2")
    events = map29.instance_variable_get(:@events) || {}
    template = events[3]
    raise "Map029 obstacle template E003 missing" unless template
    (3..13).each do |id|
      events[id] = Marshal.load(Marshal.dump(template)) unless events[id]
      event = events[id]
      event.instance_variable_set(:@id, id)
      event.instance_variable_set(:@name,
        "QTE-ATL-OBSTRUCTING-CLONE [E%03d]" % id)
      event.instance_variable_set(:@x, 10)
      event.instance_variable_set(:@y, 20 - (id % 10))
      page = event.instance_variable_get(:@pages).first
      graphic = page.instance_variable_get(:@graphic)
      graphic.instance_variable_set(:@character_name, "$Clone#{id-2}")
      graphic.instance_variable_set(:@character_index, 0)
      graphic.instance_variable_set(:@direction, 8)
      graphic.instance_variable_set(:@pattern, 1)
      page.instance_variable_set(:@priority_type, 1)
      page.instance_variable_set(:@through, true)
    end
    setup = events[1].instance_variable_get(:@pages).first.
      instance_variable_get(:@list)
    changed = 0
    setup.each do |command|
      next unless command_code(command) == 355
      text = command_parameters(command)[0].to_s
      next unless text.include?("start_atlantis_chase")
      command.instance_variable_set(:@parameters,
        ["start_atlantis_chase(2,(3..13).to_a)"])
      changed += 1
    end
    raise "Map029 chase setup call missing" if changed == 0
    map29.instance_variable_set(:@events, events)
    save_data("Data/Map029.rvdata2", map29)
    puts "UPDATED|Map029|obstacle_clones=11|graphics=Clone1..Clone11"
  end

  # Keep KUL darkness continuous across Map034 -> Map029.  A normal transfer
  # fades the new map in before its autorun can establish the destination
  # lights, so use an explicit black screen and a no-fade transfer instead.
  def fix_atlantis_clone_chase_lighting_transition
    map34 = load_data("Data/Map034.rvdata2")
    event34 = (map34.instance_variable_get(:@events) || {})[1]
    raise "Map034 controller E001 missing" unless event34
    list34 = event34.instance_variable_get(:@pages).first.
      instance_variable_get(:@list)
    transfer34 = list34.find do |command|
      command_code(command) == 201 && command_parameters(command)[1] == 29
    end
    raise "Map034 -> Map029 transfer missing" unless transfer34
    transfer_index = list34.index(transfer34)

    # Fade while the source scene is still dark.  All camera/effect cleanup is
    # then hidden behind black rather than producing a one-frame light flash.
    cleanup_index = (0...transfer_index).to_a.reverse.find do |index|
      command = list34[index]
      command_code(command) == 117 && command_parameters(command)[0] == 3
    end
    raise "Map034 camera cleanup CE03 missing" unless cleanup_index
    unless cleanup_index > 0 && command_code(list34[cleanup_index - 1]) == 221
      list34.insert(cleanup_index, event_command(221, 0, []))
      transfer_index += 1
    end

    list34.each do |command|
      next unless command_code(command) == 355
      text = command_parameters(command)[0].to_s
      if text =~ /^\$game_map\.shadows\.set_opacity\(0(?:,\s*10)?\)$/
        command.instance_variable_set(:@parameters,
          ["$game_map.shadows.set_opacity(185)"])
      end
    end
    params34 = command_parameters(transfer34).dup
    params34[5] = 2
    transfer34.instance_variable_set(:@parameters, params34)
    save_data("Data/Map034.rvdata2", map34)

    map29 = load_data("Data/Map029.rvdata2")
    event29 = (map29.instance_variable_get(:@events) || {})[1]
    raise "Map029 controller E001 missing" unless event29
    list29 = event29.instance_variable_get(:@pages).first.
      instance_variable_get(:@list)
    start_index = list29.index do |command|
      command_code(command) == 355 &&
        command_parameters(command)[0].to_s.include?("start_atlantis_chase")
    end
    raise "Map029 chase start missing" unless start_index
    list29.each do |command|
      next unless command_code(command) == 355
      if command_parameters(command)[0].to_s =~
          /^\$game_map\.shadows\.set_opacity\(185(?:,\s*20)?\)$/
        command.instance_variable_set(:@parameters,
          ["$game_map.shadows.set_opacity(185)"])
      end
    end
    unless start_index > 0 && command_code(list29[start_index - 1]) == 222
      list29.insert(start_index, event_command(222, 0, []))
    end
    save_data("Data/Map029.rvdata2", map29)
    puts "UPDATED|Map034->Map029|black_handoff=true|KUL_opacity=185|destination_fadein_after_lighting=true"
  end

  def polish_atlantis_post_chase_confrontation
    map25 = load_data("Data/Map025.rvdata2")
    events25 = map25.instance_variable_get(:@events) || {}
    main25 = events25[1]
    raise "Map025 controller E001 missing" unless main25 && events25[2] && events25[3]

    note25 = map25.instance_variable_get(:@note).to_s
    note25 = note25.lines.reject do |line|
      line =~ /^\[(?:lighting|opacity|color)\b/i
    end.join
    map25.instance_variable_set(:@note,
      "[lighting on]\n[opacity 185]\n[color 000000000]\n#{note25}")

    list25 = main25.instance_variable_get(:@pages).first.
      instance_variable_get(:@list)
    hide_paulie = list25.index do |command|
      command_code(command) == 355 &&
        command_parameters(command)[0].to_s == "$game_map.events[3].opacity=0"
    end
    raise "Map025 Paulie hide marker missing" unless hide_paulie
    lighting = [
      event_command(355, 0, ["map_effects.clear"]),
      event_command(355, 0, ["map_effects.active=false"]),
      event_command(355, 0, ["$game_map.screen.start_tone_change(Tone.new(0,0,0,0),0)"]),
      event_command(355, 0, ["$game_map.screen.start_flash(Color.new(0,0,0,0),1)"]),
      event_command(355, 0, ["$game_map.screen.change_weather(:none,0,0)"]),
      event_command(121, 0, [17, 18, 1]),
      event_command(355, 0, ["$game_map.shadows.set_color(0,0,0)"]),
      event_command(355, 0, ["$game_map.shadows.set_opacity(185)"]),
      event_command(355, 0, ["$game_map.shadows.show"]),
      event_command(355, 0, ["$game_player.give_light(\"cutscene_actor\")"]),
      event_command(355, 0, ["$game_map.events[2].give_light(\"red\")"])
    ]
    list25.reject! do |command|
      command_code(command) == 355 && [
        "$game_map.shadows.set_color(0,0,0)",
        "$game_map.shadows.set_opacity(185)",
        "$game_map.shadows.show",
        "$game_player.give_light(\"player_small\")",
        "$game_player.give_light(\"actor_small\")",
        "$game_player.give_light(\"cutscene_actor\")",
        "$game_map.events[2].give_light(\"red\")"
      ].include?(command_parameters(command)[0].to_s)
    end
    list25.reject! do |command|
      command_code(command) == 355 && [
        "map_effects.clear",
        "map_effects.active=false",
        "$game_map.screen.start_tone_change(Tone.new(0,0,0,0),0)",
        "$game_map.screen.start_flash(Color.new(0,0,0,0),1)",
        "$game_map.screen.change_weather(:none,0,0)"
      ].include?(command_parameters(command)[0].to_s)
    end
    list25.reject! do |command|
      command_code(command) == 121 && command_parameters(command)[0] == 17 &&
        command_parameters(command)[1] == 18
    end
    hide_paulie = list25.index do |command|
      command_code(command) == 355 &&
        command_parameters(command)[0].to_s == "$game_map.events[3].opacity=0"
    end
    list25.insert(hide_paulie + 1, *lighting)

    # Map025 uses Enhanced Camera for framing, but Map Effects must remain
    # disabled so it cannot replace/tint the viewports drawn by KUL.
    camera_only = []
    list25.each do |command|
      unless command_code(command) == 117
        camera_only << command
        next
      end
      common_id = command_parameters(command)[0]
      case common_id
      when 2, 5
        camera_only << event_command(355, 0,
          ["id=$game_variables[40]; ms_pro_cam_center_at_char(id,30)"])
        camera_only << event_command(655, 0,
          ["ms_pro_cam_wait_for_scrolling"])
      when 4
        camera_only << event_command(355, 0,
          ["ms_pro_cam_center_at_char(-1,25)"])
        camera_only << event_command(655, 0,
          ["ms_pro_cam_wait_for_scrolling"])
      when 6
        # CE06 is Map Effects zoom/blur only; screen shake remains in the map.
      when 3
        camera_only << event_command(355, 0,
          ["ms_pro_cam_unlock_camera"])
        camera_only << event_command(655, 0,
          ["ms_pro_cam_ignore_player(false)"])
        camera_only << event_command(655, 0,
          ["ms_pro_cam_focus_on(-1)"])
        camera_only << event_command(655, 0,
          ["ms_pro_cam_reset_str"])
      else
        camera_only << command
      end
    end
    list25 = camera_only
    main25.instance_variable_get(:@pages).first.
      instance_variable_set(:@list, list25)

    paulie_normal = list25.index do |command|
      command_code(command) == 355 &&
        command_parameters(command)[0].to_s.include?('set_graphic("$OniOnii"')
    end
    raise "Map025 Paulie normal graphic marker missing" unless paulie_normal
    rejoin_call = "atlantis_paulie_rejoin_player(3)"
    unless list25.any? {|command| command_code(command) == 355 &&
      command_parameters(command)[0].to_s == rejoin_call }
      list25.insert(paulie_normal + 1, event_command(355, 0, [rejoin_call]))
    end

    finisher = list25.index do |command|
      command_code(command) == 355 &&
        command_parameters(command)[0].to_s == "$game_map.events[2].animation_id=147"
    end
    raise "Map025 finisher animation 147 missing" unless finisher
    fadeout_index = (finisher...list25.size).find do |index|
      command_code(list25[index]) == 221
    end
    raise "Map025 final fadeout missing" unless fadeout_index
    shatter_call = "atlantis_monster_shatter_and_fade(2,90)"
    list25.reject! do |command|
      command_code(command) == 355 &&
        command_parameters(command)[0].to_s.start_with?("atlantis_monster_shatter_and_fade")
    end
    fadeout_index = list25.index {|command| command_code(command) == 221 }
    list25.insert(fadeout_index, event_command(355, 0, [shatter_call]))

    transfer25 = list25.find do |command|
      command_code(command) == 201 && command_parameters(command)[1] == 35
    end
    raise "Map025 -> Map035 transfer missing" unless transfer25
    transfer25_index = list25.index(transfer25)
    paulie_drop_light = "$game_map.events[3].drop_light if $game_map.events[3]"
    unless list25[0...transfer25_index].any? {|command|
      command_code(command) == 355 &&
        command_parameters(command)[0].to_s == paulie_drop_light }
      list25.insert(transfer25_index,
        event_command(355, 0, [paulie_drop_light]))
    end
    params25 = command_parameters(transfer25).dup
    params25[5] = 2
    transfer25.instance_variable_set(:@parameters, params25)
    save_data("Data/Map025.rvdata2", map25)

    map35 = load_data("Data/Map035.rvdata2")
    main35 = (map35.instance_variable_get(:@events) || {})[1]
    raise "Map035 controller E001 missing" unless main35
    list35 = main35.instance_variable_get(:@pages).first.
      instance_variable_get(:@list)
    fadein35 = list35.index {|command| command_code(command) == 222 }
    raise "Map035 Fade In missing" unless fadein35
    black_cleanup = [
      event_command(117, 0, [3]),
      event_command(355, 0, ["$game_player.drop_light"]),
      event_command(355, 0, ["$game_map.shadows.set_opacity(0)"])
    ]
    unless list35[0...fadein35].any? {|command| command_code(command) == 117 &&
      command_parameters(command)[0] == 3 }
      list35.insert(fadein35, *black_cleanup)
    end
    save_data("Data/Map035.rvdata2", map35)

    puts "UPDATED|Map029->Map025|KUL_dark_handoff=true"
    puts "UPDATED|Map025|Paulie_rejoin=true|monster_shatter=true|fatigue_fade=true"
    puts "UPDATED|Map025->Map035|no_fade_transfer=true|bedroom_cleanup_before_fadein=true"
  end

  def use_player_in_atlantis_bedroom_epilogue
    map = load_data("Data/Map035.rvdata2")
    events = map.instance_variable_get(:@events) || {}
    main = events[1]
    paulie = events[3]
    raise "Map035 controller/Paulie missing" unless main && paulie
    page = main.instance_variable_get(:@pages).first
    list = page.instance_variable_get(:@list) || []

    # Replace the old sleeping event with the current Game_Player graphic.
    events.delete(2)
    transparent = list.index do |command|
      command_code(command) == 355 &&
        command_parameters(command)[0].to_s == "$game_player.transparent=true"
    end
    raise "Map035 Player hide marker missing" unless transparent
    list[transparent, 1] = [
      event_command(355, 0, ["$game_player.moveto(7,5)"]),
      event_command(355, 0, ["$game_player.set_direction(2)"]),
      event_command(355, 0, ["$game_player.transparent=false"])
    ]

    list.each do |command|
      if command_code(command) == 401
        text = command_parameters(command)[0].to_s
        command.instance_variable_set(:@parameters,
          [text.sub(/^\\bm\[2\]/, "\\bm[0]")])
      elsif command_code(command) == 213 &&
          command_parameters(command)[0] == 2
        params = command_parameters(command).dup
        params[0] = -1
        command.instance_variable_set(:@parameters, params)
      end
    end

    focus_index = list.index do |command|
      command_code(command) == 117 && command_parameters(command)[0] == 2
    end
    raise "Map035 old E002 camera focus missing" unless focus_index
    list[focus_index, 1] = [
      event_command(355, 0, ["ms_pro_cam_center_at_char(-1,40)"]),
      event_command(655, 0, ["ms_pro_cam_wait_for_scrolling"])
    ]

    disappear_index = list.index do |command|
      command_code(command) == 355 &&
        command_parameters(command)[0].to_s == 'char_effect(3, "Disappear")'
    end
    raise "Map035 Paulie disappear marker missing" unless disappear_index
    remove_count = 1
    if command_code(list[disappear_index + 1]) == 230 &&
        command_parameters(list[disappear_index + 1])[0] == 35
      remove_count += 1
    end
    list[disappear_index, remove_count] = [
      event_command(212, 0, [3, 116, true]),
      event_command(355, 0, ["$game_map.events[3].opacity=0"])
    ]
    # Remove a duplicate opacity command left by the old Disappear sequence.
    first_opacity = list.index do |command|
      command_code(command) == 355 &&
        command_parameters(command)[0].to_s == "$game_map.events[3].opacity=0"
    end
    list.delete_at(first_opacity + 1) if first_opacity &&
      command_code(list[first_opacity + 1]) == 355 &&
      command_parameters(list[first_opacity + 1])[0].to_s ==
        "$game_map.events[3].opacity=0"

    page.instance_variable_set(:@list, list)
    map.instance_variable_set(:@events, events)
    note = map.instance_variable_get(:@note).to_s
    note = note.gsub(/\r?\n?Atlantis chase ending bedroom epilogue/, "")
    map.instance_variable_set(:@note,
      "#{note}\r\nAtlantis bedroom epilogue; Hải Quỳ uses Game_Player")
    save_data("Data/Map035.rvdata2", map)
    puts "UPDATED|Map035|HaiQuy=Game_Player|E002_removed=true|Paulie_teleport_animation=116"
  end

  def fix_map035_chat_handoff_and_teleport
    map = load_data("Data/Map035.rvdata2")
    main = (map.instance_variable_get(:@events) || {})[1]
    raise "Map035 controller missing" unless main
    page = main.instance_variable_get(:@pages).first
    list = page.instance_variable_get(:@list) || []
    animation_index = list.index do |command|
      command_code(command) == 212 && command_parameters(command)[0] == 3 &&
        command_parameters(command)[1] == 116
    end
    unless animation_index
      animation_index = list.index do |command|
        command_code(command) == 355 &&
          command_parameters(command)[0].to_s ==
            "atlantis_event_teleport(3,116)"
      end
    end
    raise "Map035 Paulie teleport marker missing" unless animation_index
    unless command_code(list[animation_index]) == 355
      remove_count = 1
      if command_code(list[animation_index + 1]) == 355 &&
          command_parameters(list[animation_index + 1])[0].to_s ==
            "$game_map.events[3].opacity=0"
        remove_count += 1
      end
      list[animation_index, remove_count] = [
        event_command(355, 0, ["atlantis_event_teleport(3,116)"])
      ]
    end
    page.instance_variable_set(:@list, list)
    save_data("Data/Map035.rvdata2", map)
    puts "UPDATED|Map035|PopMessage_handoff=GroupChat.start|Paulie_teleport=sprite_wait"
  end

  # Adds expressive balloon beats to the implemented Atlantis book route.
  # Balloon targets follow VX Ace's convention: -1 is Player, 0 is the event
  # currently running, and a positive value is that map event ID.
  def apply_atlantis_route_balloons
    specs = {
      22 => [
        [1, "HAI ƠI, EM VỀ RỒI", -1, 1],
        [1, "Ỏ dị hả", -1, 2],
        [1, "Chắc chắn ổng đang nằm", -1, 9],
        [21, "Ồ, chìa khóa", -1, 9],
        [31, "Ảnh chụp về", -1, 11],
        [31, "Đã bảo không muốn nhớ", -1, 5],
        [48, "Đ-Đâu có", -1, 6],
        [48, "\\bm[7] Gì?", 7, 1],
        [48, "\\bm[0] Ui da", -1, 12],
        [48, "Hả gì! Chị Tư", -1, 2],
        [48, "Bầu không khí đột ngột", -1, 8]
      ],
      23 => [
        [2, "Bả ngủ luôn rồi", -1, 2],
        [2, "Ồ, xin chào quý", 2, 10],
        [2, "Ủa…giấy niêm phong", 2, 1],
        [2, "luồng điện giật mạnh", -1, 11],
        [3, "Bả ngủ luôn rồi", -1, 2],
        [3, "Ồ, xin chào quý", 3, 10],
        [3, "Ủa…giấy niêm phong", 3, 1],
        [3, "luồng điện giật mạnh", -1, 11]
      ],
      24 => [
        [1, "Dahria…", -1, 2],
        [1, "Không phải…Urg", -1, 11],
        [1, "Không…phải…cỗ máy", -1, 7]
      ],
      25 => [
        [1, "Phế phẩm?", -1, 5],
        [1, "Ngươi là…ai", 2, 2],
        [1, "ECLIPSE BLOCKCHAIN", 3, 1],
        [1, "ANEMONE DIAMOND", -1, 1]
      ],
      26 => [
        [20, "phao “ nữa này", -1, 1],
        [20, "lá thư bị vò", -1, 9],
        [20, "thực chất là bản sao", -1, 11]
      ],
      28 => [
        [20, "char_effect(20, \"Appear\")", -1, 11],
        [21, "char_effect(21, \"Appear\")", -1, 11],
        [22, "char_effect(22, \"Appear\")", -1, 11]
      ],
      34 => [
        [1, "char_effect(0, \"Breath\")", -1, 6],
        [1, "Im đi! Im đi! Im đi!", -1, 5],
        [1, "$game_map.events[2].opacity=255", -1, 11]
      ]
    }

    inserted = 0
    specs.each do |map_id, entries|
      path = format("Data/Map%03d.rvdata2", map_id)
      map = load_data(path)
      events = map.instance_variable_get(:@events) || {}
      entries.each do |event_id, needle, target, balloon_id|
        event = events[event_id]
        raise "Map#{map_id} event #{event_id} missing" unless event
        matched = false
        (event.instance_variable_get(:@pages) || []).each do |page|
          list = page.instance_variable_get(:@list) || []
          hit = list.index do |command|
            [355, 401].include?(command_code(command)) &&
              command_parameters(command)[0].to_s.include?(needle)
          end
          next unless hit
          matched = true
          # Put dialogue balloons before Show Text so they animate while the
          # matching line is visible. Script-call beats use their exact index.
          insert_at = hit
          if command_code(list[hit]) == 401
            cursor = hit - 1
            cursor -= 1 while cursor >= 0 && command_code(list[cursor]) == 401
            insert_at = cursor if cursor >= 0 && command_code(list[cursor]) == 101
          end
          duplicate = insert_at > 0 && command_code(list[insert_at - 1]) == 213 &&
            command_parameters(list[insert_at - 1])[0, 2] == [target, balloon_id]
          unless duplicate
            indent = list[insert_at].instance_variable_get(:@indent).to_i
            list.insert(insert_at, event_command(213, indent, [target, balloon_id, false]))
            inserted += 1
          end
          break
        end
        raise "Balloon anchor missing Map#{map_id} E#{event_id}: #{needle}" unless matched
      end
      save_data(path, map)
    end
    puts "ATLANTIS_BALLOONS|inserted=#{inserted}|maps=#{specs.keys.join(',')}"
  end

  def create_atlantis_chase_epilogue
    map25_path = "Data/Map025.rvdata2"
    map35_path = "Data/Map035.rvdata2"
    map36_path = "Data/Map036.rvdata2"
    map25 = load_data(map25_path)
    source_events = map25.instance_variable_get(:@events) || {}
    template = source_events[1]
    oni_template = source_events[3]
    raise "Map025 templates missing" unless template && oni_template

    # Paulie/OniOnii uses the project charset $test.png.
    oni_source_page = oni_template.instance_variable_get(:@pages).first
    oni_source_graphic = oni_source_page.instance_variable_get(:@graphic)
    oni_source_graphic.instance_variable_set(:@tile_id, 0)
    oni_source_graphic.instance_variable_set(:@character_name, "$test")
    oni_source_graphic.instance_variable_set(:@character_index, 0)
    oni_source_graphic.instance_variable_set(:@direction, 2)
    oni_source_graphic.instance_variable_set(:@pattern, 1)

    pop = lambda do |anchor, text|
      wrapped_message_commands([text], tag: "\\bm[#{anchor}] ", width: 24)
    end

    # Continue Map025's existing fade-out directly into the route epilogue.
    page25 = template.instance_variable_get(:@pages).first
    list25 = page25.instance_variable_get(:@list) || []
    unless list25.any? { |c| command_code(c) == 201 && command_parameters(c)[1] == 35 }
      at = list25.index { |c| command_code(c) == 123 } || list25.length - 1
      list25.insert(at, event_command(201, 0, [0, 35, 10, 9, 2, 0]))
      page25.instance_variable_set(:@list, list25)
    end
    save_data(map25_path, map25)

    # Map035: fixed 21x17 parallax cutscene. Hải Quỳ is shown with the dedicated
    # sleeping-at-night charset; E002 is also her Pop Message/camera anchor.
    map35 = Marshal.load(Marshal.dump(map25))
    map35.instance_variable_set(:@display_name, "Phòng Hải Quỳ — Đêm muộn")
    map35.instance_variable_set(:@width, 21)
    map35.instance_variable_set(:@height, 17)
    map35.instance_variable_set(:@data, blank_table(21, 17, 4))
    map35.instance_variable_set(:@parallax_name, "HQ_Room_Midnight_Base")
    map35.instance_variable_set(:@parallax_loop_x, false)
    map35.instance_variable_set(:@parallax_loop_y, false)
    map35.instance_variable_set(:@parallax_sx, 0)
    map35.instance_variable_set(:@parallax_sy, 0)
    map35.instance_variable_set(:@scroll_type, 0)
    map35.instance_variable_set(:@note, "Atlantis chase ending bedroom epilogue")

    events35 = {}
    anchor_page = page_from_template(template, [], trigger: 0, priority: 0)
    anchor_graphic = anchor_page.instance_variable_get(:@graphic)
    anchor_graphic.instance_variable_set(:@tile_id, 0)
    anchor_graphic.instance_variable_set(:@character_name, "$HaiQuy_Sleep_Night")
    anchor_graphic.instance_variable_set(:@character_index, 0)
    anchor_graphic.instance_variable_set(:@direction, 2)
    anchor_graphic.instance_variable_set(:@pattern, 1)
    anchor_page.instance_variable_set(:@priority_type, 1)
    events35[2] = event_from_pages(template, 2, "ANCHOR-HQ-BED", 7, 5, [anchor_page])
    oni_page = Marshal.load(Marshal.dump(oni_template.instance_variable_get(:@pages).first))
    oni_page.instance_variable_set(:@list, [event_command(0, 0, [])])
    oni_page.instance_variable_set(:@trigger, 0)
    oni_page.instance_variable_set(:@priority_type, 1)
    events35[3] = event_from_pages(oni_template, 3, "NPC-ONI-ONII-BEDSIDE", 10, 6, [oni_page])

    scene35 = [
      event_command(355, 0, ["$game_player.transparent=true"]),
      event_command(222, 0, []),
      event_command(122, 0, [40, 40, 0, 0, 2]),
      event_command(117, 0, [2]),
      event_command(213, 0, [2, 6, false])
    ]
    scene35.concat(pop.call(3, "Mày thấy sao rồi?"))
    scene35.concat(pop.call(2, "Cũng đỡ đỡ…"))
    [
      "Ai mà ngờ được cái con quái vật vực sâu có khả năng ngụy trang mà mọi người ráo riết truy đuổi",
      "Lại ở nhà mình cơ chứ?"
    ].each { |line| scene35.concat(pop.call(3, line)) }
    scene35 << event_command(213, 0, [2, 2, false])
    scene35.concat(pop.call(2, "Hả…?"))
    [
      "Ban nãy tao nhận được tin báo là có một con quái vật vực sâu lọt vào thành phố.",
      "Cấp trên điều động tao đi tìm nó nên tao tính xuống ăn mì cho lại sức rồi đi.",
      "Dè đâu mì chẳng thấy mà lại thấy nó.", "Thế mà lại hay.",
      "Phen này tao có huân chương là cái chắc."
    ].each { |line| scene35.concat(pop.call(3, line)) }
    scene35.concat(pop.call(2, "Thế hai không tính khao em à?"))
    scene35.concat(pop.call(2, "Tính ra em là đứa giúp hai có huy chương luôn á."))
    [
      "Rồi rồi! Tao sẽ suy nghĩ.",
      "Giờ mày nghỉ ngơi đi, tao đi xuống báo cáo với anh em."
    ].each { |line| scene35.concat(pop.call(3, line)) }
    scene35.concat(pop.call(2, "Dạ…!"))
    scene35.concat([
      event_command(355, 0, ["$game_map.events[3].set_direction(2)"]),
      event_command(230, 0, [20])
    ])
    [
      "Cái chiêu “ Anemone Diamond Shower “ gi gì đó của mày…",
      "Sao nó gần giống “ Aero Blast “ vậy?"
    ].each { |line| scene35.concat(pop.call(3, line)) }
    scene35.concat(pop.call(2, "Thì em nâng cấp từ chiêu đó mà…!"))
    ["Ồ, vậy hả?", "Sao không đặt là “ Aero Twinkle Blast “?", "Tên mày đặt nghe thối tai quá."].each do |line|
      scene35.concat(pop.call(3, line))
    end
    scene35.concat([
      event_command(355, 0, ["char_effect(3, \"Disappear\")"]),
      event_command(230, 0, [35]),
      event_command(355, 0, ["$game_map.events[3].opacity=0"]),
      event_command(213, 0, [2, 5, false])
    ])
    scene35.concat(pop.call(2, "ÔNG ANH HAI ĐÁNG GHÉT!!!!!"))
    scene35 << event_command(213, 0, [2, 6, false])
    scene35.concat(pop.call(2, "Cơ mà…người ngợm thế này chắc không tham gia tiệc giáng sinh được rồi…"))
    scene35.concat(pop.call(2, "Phải nhắn cho mọi người biết…"))
    scene35.concat([
      event_command(355, 0, ["GroupChatPreset.atlantis_chase_ending"]),
      # SceneManager.call only queues the phone scene. This one-frame wait
      # yields the interpreter so the chat opens before unlock/CG commands.
      event_command(230, 0, [1]),
      event_command(355, 0, ["PhoneGroupChatSave.save_current_cutscene(:wanderer_group)"]),
      event_command(355, 0, ["GlobalGallery.unlock(9)"]),
      event_command(355, 0, ["EndingPresentation.show_gallery(\"EDRuotDuoi\",240)"]),
      event_command(122, 0, [41, 41, 0, 0, 1]),
      event_command(201, 0, [0, 36, 8, 6, 2, 2])
    ])
    main35 = page_from_template(template, scene35, trigger: 3, priority: 0)
    events35[1] = event_from_pages(template, 1, "SCN-ATL-CHASE-EPILOGUE", 0, 0, [main35])
    map35.instance_variable_set(:@events, events35)
    save_data(map35_path, map35)

    # Map036: shared after-ending hub. Variable 41 selects the route page;
    # future endings add higher-value pages to this same controller.
    map36 = Marshal.load(Marshal.dump(map25))
    map36.instance_variable_set(:@display_name, "After Ending Hint")
    map36.instance_variable_set(:@width, 17)
    map36.instance_variable_set(:@height, 13)
    map36.instance_variable_set(:@data, blank_table(17, 13, 4))
    map36.instance_variable_set(:@parallax_name, "")
    map36.instance_variable_set(:@scroll_type, 0)
    map36.instance_variable_set(:@note, "Shared after-ending hint hub; Variable 41 = route hint ID")
    events36 = {}
    bully_page = page_from_template(template, [], trigger: 0, priority: 1)
    graphic = bully_page.instance_variable_get(:@graphic)
    graphic.instance_variable_set(:@tile_id, 0)
    graphic.instance_variable_set(:@character_name, "$BullyQuy_Sleep_Night")
    graphic.instance_variable_set(:@character_index, 0)
    graphic.instance_variable_set(:@direction, 2)
    graphic.instance_variable_set(:@pattern, 1)
    events36[2] = event_from_pages(template, 2, "NPC-AFTER-END-BULLY-QUY", 8, 6, [bully_page])
    hint_lines = [
      "Ôi, chán thế?", "Ngươi cũng thấy buồn mà đúng không?", "Không sao!",
      "Ta có thể giúp ngươi đó!", "Với “ Wonder Chrismast Fiesta “ này",
      "Ta sẽ giúp ngươi tận hưởng kỳ nghỉ đáng mơ ước nhất mà ngươi có thể mơ.",
      "Hmmm?", "Chuyện của Hải Quỳ á?", "Ồ, tự thân ngươi hiểu đi chứ.",
      "Ta lười giải thích quá.", "Lỡ bung bét hết rồi.",
      "Giờ ta chỉ muốn tận hưởng giáng sinh thôi.", "Nên là…!",
      "WONDER CHRISMAST FIESTA!!"
    ]
    scene36 = [
      event_command(355, 0, ["$game_player.transparent=true"]),
      event_command(122, 0, [40, 40, 0, 0, 2]),
      event_command(117, 0, [5]),
      event_command(355, 0, ["char_effect(2, \"Breath\")"])
    ]
    hint_lines.each_with_index do |line, index|
      scene36 << event_command(213, 0, [2, 9, false]) if index == 3
      scene36 << event_command(213, 0, [2, 2, false]) if index == 6
      scene36 << event_command(213, 0, [2, 1, false]) if index == hint_lines.length - 1
      scene36.concat(pop.call(2, line))
    end
    scene36.concat([
      event_command(117, 0, [3]),
      # Let the final balloon animation finish before the map spriteset is
      # disposed by Return to Title.
      event_command(230, 0, [60]),
      event_command(355, 0, ["HAIQUY_TITLE.set_ending_background(\"EDRuotDuoi\")"]),
      event_command(354, 0, [])
    ])
    page36 = page_from_template(template, scene36, trigger: 3, priority: 0,
      variable_id: 41, variable_value: 1)
    events36[1] = event_from_pages(template, 1, "SYS-AFTER-ENDING-HINT-ROUTER", 0, 0, [page36])
    map36.instance_variable_set(:@events, events36)
    save_data(map36_path, map36)

    infos = load_data("Data/MapInfos.rvdata2")
    [[35, "Phòng Hải Quỳ — Đêm muộn"], [36, "After Ending Hint"]].each do |id, name|
      info = infos[id] || Marshal.load(Marshal.dump(infos[25]))
      info.instance_variable_set(:@name, name)
      info.instance_variable_set(:@parent_id, 0)
      info.instance_variable_set(:@order,
        infos.values.compact.map { |i| i.instance_variable_get(:@order).to_i }.max + 1)
      info.instance_variable_set(:@expanded, true)
      infos[id] = info
    end
    save_data("Data/MapInfos.rvdata2", infos)

    system = load_data("Data/System.rvdata2")
    variables = system.instance_variable_get(:@variables) || []
    variables[41] = "ENDING_HINT_ID"
    system.instance_variable_set(:@variables, variables)
    save_data("Data/System.rvdata2", system)
    puts "ATLANTIS_EPILOGUE|Map025->Map035->Map036->Title|gallery=9|hint_var=41"
  end

  # Normalize one supermarket item choice page. This is intentionally
  # idempotent: older versions appended variables 42/44 after every run while
  # deleting only switch 44, which produced the repeated commands seen in the
  # RPG Maker event editor.
  def normalize_supermarket_item_route_page(list, gift_id)
    branch_index = list.index do |command|
      command_code(command) == 402 && command_parameters(command)[0].to_i == 0
    end
    return list unless branch_index

    route_state_command = lambda do |command|
      parameters = command_parameters(command)
      (command_code(command) == 121 && parameters[0].to_i == 44 && parameters[1].to_i == 44) ||
        (command_code(command) == 122 && parameters[0].to_i == parameters[1].to_i &&
          [42, 44].include?(parameters[0].to_i))
    end
    first_state_index = list.index { |command| route_state_command.call(command) }
    insert_index = first_state_index ?
      list[0...first_state_index].count { |command| !route_state_command.call(command) } :
      branch_index + 1
    list = list.reject do |command|
      route_state_command.call(command)
    end
    branch = list.find do |command|
      command_code(command) == 402 && command_parameters(command)[0].to_i == 0
    end
    indent = branch.instance_variable_get(:@indent).to_i + 1
    route_state = [
      event_command(122, indent, [42, 42, 0, 0, gift_id]),
      event_command(121, indent, [44, 44, 0]),
      event_command(122, indent, [44, 44, 0, 0, 1])
    ]
    list.insert(insert_index, *route_state)
    list
  end

  def repair_supermarket_item_route_state
    path = "Data/Map019.rvdata2"
    map = load_data(path)
    events = map.instance_variable_get(:@events) || {}
    repaired = []
    {33 => 1, 34 => 2, 35 => 3, 36 => 4}.each do |event_id, gift_id|
      event = events[event_id]
      raise "Map019 E%03d item event missing" % event_id unless event
      (event.instance_variable_get(:@pages) || []).each_with_index do |page, page_index|
        old_list = page.instance_variable_get(:@list) || []
        new_list = normalize_supermarket_item_route_page(old_list, gift_id)
        next if Marshal.dump(old_list) == Marshal.dump(new_list)
        page.instance_variable_set(:@list, new_list)
        repaired << "E%03d/P%d" % [event_id, page_index + 1]
      end
    end
    save_data(path, map)
    puts "SUPERMARKET_ITEM_ROUTE_STATE|normalized=#{repaired.join(',')}"
  end

  # Build the shared supermarket route spine and the first playable vertical
  # slice (coffee machine -> Kohi). Variables: 42 gift, 43 target, 44 stage.
  # Switches: 44 active, 45 party done, 46 ending unlocked.
  def create_supermarket_route_slice
    # This was the prototype builder. Once the complete 4x4 route has been
    # materialized, running it again would replace Maps 037-039 with the older
    # one-recipient prototype. Keep the command useful for repairing Map019,
    # but never let it regress an already completed route.
    complete_markers = {
      37 => "# MKT_ALL_GIFT_PREP",
      38 => "# MKT_ALL_GIFT_SCENE9",
      39 => "# MKT_ALL_GIFT_EPILOGUES"
    }
    complete_route_exists = complete_markers.all? do |map_id, marker|
      path = "Data/Map%03d.rvdata2" % map_id
      next false unless File.exist?(path)
      map = load_data(path)
      (map.instance_variable_get(:@events) || {}).values.compact.any? do |event|
        (event.instance_variable_get(:@pages) || []).any? do |page|
          (page.instance_variable_get(:@list) || []).any? do |command|
            command_code(command) == 355 && command_parameters(command)[0].to_s == marker
          end
        end
      end
    end
    if complete_route_exists
      repair_supermarket_item_route_state
      puts "SUPERMARKET_ROUTE_SLICE|prototype_skipped=complete_route_present"
      return
    end

    map19 = load_data("Data/Map019.rvdata2")
    events = map19.instance_variable_get(:@events) || {}
    raise "Map019 route events missing" unless (5..10).all? { |id| events[id] } &&
      (33..36).all? { |id| events[id] } && events[42]

    names = {
      5 => "NPC-CASHIER-A [E005]", 6 => "PROP-CASHIER-A-COUNTER-L [E006]",
      7 => "PROP-CASHIER-A-COUNTER-R [E007]", 8 => "NPC-CASHIER-B [E008]",
      9 => "PROP-CASHIER-B-COUNTER-L [E009]", 10 => "PROP-CASHIER-B-COUNTER-R [E010]",
      33 => "ITEM-MKT-COFFEE [E033]", 34 => "ITEM-MKT-COOKWARE [E034]",
      35 => "ITEM-MKT-KNITTING [E035]", 36 => "ITEM-MKT-LOCKPICK [E036]",
      42 => "SCN-MKT-CHECKOUT-GATE [E042]", 43 => "SYS-MKT-LEGACY-PLACEHOLDER [E043]"
    }
    names.each { |id, name| events[id].instance_variable_set(:@name, name) }

    # Replace the conflicting legacy switches 4/5/6/7 with one gift variable.
    {33 => 1, 34 => 2, 35 => 3, 36 => 4}.each do |event_id, gift_id|
      pages = events[event_id].instance_variable_get(:@pages) || []
      pages.each do |page|
        list = page.instance_variable_get(:@list) || []
        rewritten = list.reject do |command|
          command_code(command) == 355 &&
            command_parameters(command)[0].to_s.include?("turn_switches_off")
        end
        rewritten = normalize_supermarket_item_route_page(rewritten, gift_id)
        page.instance_variable_set(:@list, rewritten)
      end
    end

    thought = lambda { |text, indent = 0| wrapped_message_commands([text], width: 30, indent: indent) }
    pop = lambda { |anchor, text, indent = 0| wrapped_message_commands([text], tag: "\\bm[#{anchor}] ", width: 24, indent: indent) }
    checkout = [event_command(111, 0, [1, 42, 0, 0, 0])]
    checkout.concat(thought.call("Mình còn chưa chọn quà mà. Phải tìm một món trước đã!", 1))
    checkout << event_command(411, 0, [])
    checkout.concat(thought.call("Chọn quà vậy là xong rồi nhỉ?", 1))
    checkout << event_command(102, 1, [["Xong rồi", "Hay là xem còn món nào khác không"], 1])
    checkout << event_command(402, 1, [0, "Xong rồi"])
    checkout.concat([
      event_command(221, 2, []), event_command(230, 2, [30]),
      event_command(201, 2, [0, 19, 16, 24, 8, 0]), event_command(222, 2, []),
      event_command(122, 2, [40, 40, 0, 0, 8]), event_command(117, 2, [2])
    ])
    checkout.concat(pop.call(8, "Xin chào! Quý khách đã chọn xong quà Giáng sinh rồi chứ?", 2))
    checkout.concat(pop.call(0, "Rồi! Nhờ bạn tính tiền giúp mình nhé!", 2))
    checkout.concat(thought.call("Máy quét kêu “bíp” một tiếng. Món quà được đặt gọn vào một chiếc túi lớn.", 2))
    checkout.concat(pop.call(8, "Thanh toán hoàn tất. Chúc quý khách một mùa Giáng sinh vui vẻ!", 2))
    checkout.concat(pop.call(0, "Cảm ơn! Bạn cũng vậy nhé!", 2))
    checkout.concat([
      event_command(117, 2, [1]),
      event_command(355, 2, ["GroupChatPreset.market_recipient"]),
      event_command(230, 2, [1]),
      event_command(355, 2, ["PhoneGroupChatSave.save_current_cutscene(:wanderer_group)"]),
      event_command(122, 2, [44, 44, 0, 0, 2]),
      event_command(221, 2, []), event_command(230, 2, [30]),
      event_command(201, 2, [0, 37, 10, 9, 2, 0])
    ])
    checkout << event_command(402, 1, [1, "Hay là xem còn món nào khác không"])
    checkout << event_command(404, 1, [])
    checkout << event_command(412, 0, [])
    checkout << event_command(0, 0, [])
    page42 = events[42].instance_variable_get(:@pages).first
    page42.instance_variable_set(:@list, checkout)
    save_data("Data/Map019.rvdata2", map19)

    template_map = load_data("Data/Map035.rvdata2")
    template_event = (template_map.instance_variable_get(:@events) || {})[1]
    map37 = Marshal.load(Marshal.dump(template_map))
    map37.instance_variable_set(:@display_name, "Phòng Hải Quỳ — Chuẩn bị quà")
    map37.instance_variable_set(:@width, 21)
    map37.instance_variable_set(:@height, 17)
    map37.instance_variable_set(:@data, blank_table(21, 17, 4))
    map37.instance_variable_set(:@parallax_name, "HQ_Room_Midnight_Base")
    map37.instance_variable_set(:@note, "<full lock parallax>\r\n<tile lock parallax>\r\nSupermarket route gift preparation; coffee route")
    scene = [
      event_command(355, 0, ["$game_player.transparent=true"]),
      event_command(355, 0, ["layer(37,0,[\"HQ_Room_Midnight_Top\",0,0,255,200,0,0,0])"]),
      event_command(655, 0, ["refresh_layers"]), event_command(117, 0, [3]),
      event_command(222, 0, [])
    ]
    [
      "Hai mắt tôi mở tháo láo.",
      "Bây giờ là gần hai giờ sáng rồi. Tôi không tài nào ngủ được.",
      "Mặc dù còn vài ngày nữa mới tới buổi tiệc giáng sinh nhưng không biết vì sao mà tôi cứ có cảm giác là bữa tiệc sẽ diễn ra vào ngày mai.",
      "Và điều đó khiến tim tôi đập thình thịch, tạo cảm giác lo lắng tột độ.",
      "Tôi không gói máy pha cà phê bằng giấy gói quà mà chỉ buộc vài chiếc nơ đỏ xung quanh thành máy. Không biết như vậy có ổn không ta?",
      "Nửa bên kia của tôi ơi, còn thức không!",
      "Gì vậy trời? Nửa đêm nửa hôm đánh thức người ta dậy làm gì?",
      "Tui cảm thấy hơi bất an một chút…Không biết Kohi có thích món quà này không….",
      "Kiểu gì Kohi chả thích. Giờ thì ngủ dùm cái đi!",
      "Thiệt không?!", "Phiền quá đừng hỏi nữa!", "Aira không thân thiện tí nào hết!",
      "Thân thiện gì với cái đứa nhiều chuyện như ngươi. Ngươi cứ lo lắng dư thừa, Kohi lại chẳng thích máy pha cà phê bỏ xừ ra, mắc gì phải lo?",
      "Nhưng…", "Không nhưng nhị gì hết! Đi ngủ!"
    ].each { |line| scene.concat(thought.call(line)) }
    scene.concat([
      event_command(225, 0, [3, 5, 20, false]),
      *thought.call("Aira lấy xúc tu bịt mắt và miệng của tôi lại, cố ép tôi đi ngủ bằng vũ lực."),
      *thought.call("Nhớ…đánh thức…bọn mình dậy…trước giáng sinh nha…Aira…"),
      event_command(221, 0, []),
      event_command(355, 0, ["$game_map.events[3].set_graphic(\"$HaiQuy_Sleep_Night\",0)"]),
      event_command(230, 0, [60]),
      event_command(117, 0, [18]), event_command(222, 0, [])
    ])
    ["Tôi mở mắt dậy và quay sang nhìn chiếc đồng hồ điện tử treo trên tường.",
     "Ồ, nay là giáng sinh rồi à…", "Tôi đã ngủ một mạch đến ngày giáng sinh….Ngon thật đấy….",
     "Tôi…ngủ một mạch….đến…GIÁNG SINH?!", "Chết rồi!! Vỡ kế hoạch rồi!!",
     "Nửa bên kia của tôi ơi!! Đã dặn là đánh thức trước giáng sinh mà?! Còn vài tiếng nữa là đến tiệc giáng sinh trong văn phòng rồi!!",
     "Giờ này thì làm sao mà kịp bắt xe đến văn phòng được?! Chìa khóa dịch chuyển đâu rồi…!! Nó nằm ở đâu vậy?!",
     "Mình còn chưa chuẩn bị trang phục nữa!! Nên mặc bộ nào đây!!", "Không phải bộ này….",
     "Cũng không phải bộ này nốt!!", "Bộ này ổn này!!"].each { |line| scene.concat(thought.call(line)) }
    scene << event_command(355, 0, ["$game_map.events[3].set_graphic(\"!$HaiQuy_GiangSinh\",0)"])
    scene.concat([event_command(122, 0, [44, 44, 0, 0, 3]), event_command(221, 0, []),
                  event_command(230, 0, [30]), event_command(201, 0, [0, 38, 22, 34, 8, 0])])
    controller = page_from_template(template_event, scene, trigger: 3, priority: 0)
    gift_page = page_from_template(template_event, [], trigger: 0, priority: 1)
    gg = gift_page.instance_variable_get(:@graphic)
    gg.instance_variable_set(:@character_name, "$Gift_Coffee")
    gg.instance_variable_set(:@character_index, 0)
    map37.instance_variable_set(:@events, {
      1 => event_from_pages(template_event, 1, "SCN-MKT-GIFT-PREP", 0, 0, [controller]),
      2 => event_from_pages(template_event, 2, "PROP-GIFT-COFFEE", 11, 8, [gift_page]),
      3 => begin
        hq_page = page_from_template(template_event, [], trigger: 0, priority: 1)
        hq_graphic = hq_page.instance_variable_get(:@graphic)
        hq_graphic.instance_variable_set(:@character_name, "$HaiQuyAtHome_Base")
        hq_graphic.instance_variable_set(:@character_index, 0)
        event_from_pages(template_event, 3, "NPC-HAI-QUY-PREP", 7, 5, [hq_page])
      end
    })
    save_data("Data/Map037.rvdata2", map37)

    # Map038: Christmas party. A separate map avoids altering Map013's hub,
    # laser puzzle, and route interaction state.
    office_template = load_data("Data/Map013.rvdata2")
    map38 = Marshal.load(Marshal.dump(office_template))
    map38.instance_variable_set(:@display_name, "Wanderer Office — Giáng sinh")
    map38.instance_variable_set(:@width, 45)
    map38.instance_variable_set(:@height, 43)
    map38.instance_variable_set(:@parallax_name, "Map_Wanderer_Office_GiangSinh_Base")
    map38.instance_variable_set(:@parallax_show, true)
    map38.instance_variable_set(:@note, "<full lock parallax>\r\n<tile lock parallax>\r\nSupermarket Christmas party; based on Map013 collision and tileset")
    party = [
      event_command(355, 0, ["$game_player.transparent=true"]),
      event_command(355, 0, ["layer(38,0,[\"Map_Wanderer_Office_GiangSinh_Top\",0,0,255,200,0,0,0])"]),
      event_command(655, 0, ["refresh_layers"]), event_command(117, 0, [18]),
      event_command(122, 0, [40, 40, 0, 0, 3]), event_command(117, 0, [2]),
      event_command(222, 0, [])
    ]
    party.concat(pop.call(3, "Quỳ!! Hello!"))
    party.concat(thought.call("Người đầu tiên tôi gặp khi vừa mở cửa là Shylvie. Trên tay Shylvie đang cầm một đĩa hoa quả đầy ú ụ."))
    party.concat(pop.call(2, "A…Shylvie!! Mọi người chuẩn bị đến đâu rồi?"))
    party.concat(pop.call(3, "Đã xong đâu. Leo với Hakase đi mua đồ để trang trí mà giờ chưa thấy về."))
    party.concat(pop.call(2, "Để tui trang trí cho…!"))
    party.concat(thought.call("Tôi lao nhanh vào phòng họp và bấm bảng điều khiển loạn xạ."))
    party.concat(thought.call("Được rồi Siera, làm việc của cô đi nào! Hãy cho mọi người thấy AI của Atlantis xịn đến mức nào!"))
    party.concat([event_command(225, 0, [5, 7, 30, false]), event_command(230, 0, [20])])
    party.concat(pop.call(4, "Ối cái gì thế Shylvie!"))
    party.concat(pop.call(3, "Không phải do tôi!!"))
    party.concat(thought.call("Tôi mở cửa, chưa kịp nói xong câu thì một đống tuyết nặng trịch đổ ầm xuống đầu tôi."))
    party.concat([event_command(213, 0, [2, 11, false]), event_command(225, 0, [3, 4, 16, false]), event_command(230, 0, [20])])
    party.concat(pop.call(4, "AHAHAHAHAHAHAHA!"))
    party.concat(thought.call("Kohi hợp sức cùng Shylvie để kéo tôi ra khỏi đống tuyết."))
    party.concat(pop.call(5, "Vậy “kiệt tác” này là do bà làm à?"))
    party.concat(pop.call(2, "Ừm! Tui nghĩ rằng cho cả Văn Phòng ngập trong tuyết sẽ hay lắm mà dè đâu…"))
    party.concat(pop.call(5, "Haha. Ý tưởng không tồi. Cũng lâu lắm rồi tui chưa thấy tuyết."))
    party.concat(thought.call("Bàn tiệc giáng sinh đã chuẩn bị xong!"))
    party.concat(pop.call(2, "Mời mọi người cùng ăn!"))
    party.concat(thought.call("Bữa ăn diễn ra vui vẻ, mọi người kể cho nhau nghe đủ chuyện từ trên trời xuống đất."))
    party.concat(thought.call("Sau khi ăn uống no say, cả đám bọn tôi quyết định chơi vài ván mèo nổ với vài ván rút tháp."))
    party.concat(pop.call(5, "E hèm! Tui nghĩ đã đến lúc cho sự kiện chính ngày hôm nay rồi, Quỳ nhỉ?"))
    party.concat(thought.call("Tôi tính đứng lên để tặng chiếc máy pha cà phê thì chợt nhận ra tôi để quên nó ở nhà…"))
    party.concat(thought.call("Haizz, đúng là không có tôi thì Dahria là một con mắm hay quên nhỉ."))
    party.concat(thought.call("Tôi cởi mũ len, thò tay vào và cuối cùng cũng lôi được chiếc máy pha cà phê mà con nhỏ Dahria để quên ở nhà."))
    party.concat(pop.call(2, "Giáng sinh vui vẻ nha Kohi!!"))
    party.concat([event_command(213, 0, [4, 9, false])])
    party.concat(pop.call(4, "MỘT CHIẾC MÁY PHA CÀ PHÊ?! UI!! THÍCH THẾ!!"))
    party.concat(pop.call(2, "Hehe!! Bà thích là tui vui rồi!!"))
    party.concat(pop.call(3, "Đấy thấy chưa Kohi, tôi đã nói là bà ấy nhìn thấy trước tương lai rồi mà."))
    party.concat(pop.call(4, "À, tuần trước tui với Shylvie có cược với nhau rằng bà sẽ mua máy pha cà phê tặng tui ấy mà."))
    party.concat(pop.call(2, "À…Thế là mấy người đem tui ra để cá cược với nhau hả??"))
    party.concat(thought.call("Kohi nhào đến ôm tôi. Tôi vòng tay ra sau lưng Kohi, ôm cô ấy thật chặt."))
    party.concat(thought.call("Đột nhiên điện thoại tôi rung lên. Tôi lấy điện thoại ra kiểm tra xem ai vừa gọi tôi. Nó là số của đồng chí Alpha C-61. Tôi chưa kịp gọi lại thì đồng chí ấy đã nhắn tràng giang đại hải cho tôi rồi."))
    ["Omega D-13! Có chuyện lớn!!", "Tui biết là bây giờ đồng chí đang trong đợt nghỉ phép nhưng chuyện này cấp bách lắm rồi!",
     "Beta M-34 đã tìm ra được điểm vô lý trong lúc kiểm tra lại hồ sơ về lỗ hổng vực sâu 61.",
     "Ngoại trừ tôi với Beta M-34 thì những người còn lại được điều xuống khu vực rìa lỗ hổng vực sâu 61 để điều tra dị thường. Đã hơn ba ngày rồi mà không ai gửi báo cáo lại cho chúng tôi cả.",
     "Tôi đã cố liên lạc với họ nhưng không một ai phản hồi hết! Tất cả thiết bị của bọn họ đều bị ngừng hoạt động cùng lúc!",
     "Chúng tôi cho rằng họ đang gặp sự cố.", "Beta M-34 yêu cầu đồng chí phải quay trở về gấp để thực thi nhiệm vụ giải cứu.",
     "Omega D-13: Đã rõ."].each do |line|
      party.concat(thought.call(line))
    end
    party.concat(thought.call("Tôi biết ngay mà. Từ lúc tôi tổng hợp hồ sơ, tôi có xem qua một chút, cũng đã thấy nghi nghi rồi."))
    party.concat(thought.call("Tôi đã hi vọng rằng chuyện phát hiện ra điểm vô lý sẽ xảy ra sau khi kỳ nghỉ phép của tôi kết thúc. Đành vậy, cứu người vẫn quan trọng nhất. Tiếc ghê, vậy là không được ngồi xem phim \" Ở nhà một mình \" cùng mọi người tại Văn phòng Wanderer rồi."))
    party.concat(pop.call(3, "Quỳ! Quỳ!! Bà sao vậy?"))
    party.concat(pop.call(2, "A….Tui đang tò mò là ông sẽ tặng quà gì cho tui đó!"))
    party.concat(pop.call(3, "Trời? Nay biết tò mò luôn? Tui còn tưởng là bà đã đoán ra được rồi cơ."))
    party.concat(pop.call(2, "Ơ? Thế để tui đoán nhé?"))
    party.concat(pop.call(3, "Ừ đoán đi."))
    party.concat(pop.call(2, "Ừm….Là...Gấu bông?"))
    party.concat(pop.call(3, "Bà cố tình đoán sai đúng không? Đoán trật là không tặng đâu!"))
    party.concat(pop.call(2, "Ủa mắc gì!! Thôi được rồi, là máy ép nước cam MK25 thế hệ R34?"))
    party.concat(pop.call(3, "Bingo!"))
    party.concat(thought.call("Shylvie lôi từ chiếc túi không gian của Shylvie một chiếc máy ép cam tân tiến. Tôi chạy qua chạy lại để ngắm nhìn kiểu dáng của chiếc máy, táy máy mở từng bộ phận để kiểm tra kỹ lưỡng."))
    party.concat(pop.call(3, "Ha, Kohi! Bà đưa tiền đây!"))
    party.concat(pop.call(2, "Hả? Hai người cá cược gì đấy?"))
    party.concat(pop.call(4, "Shylvie và tui đã cá với nhau là bà sẽ phản ứng như thế nào khi được tặng cái máy."))
    party.concat(pop.call(2, "Ơ thế Kohi nghĩ tui sẽ phản ứng như thế nào?"))
    party.concat(pop.call(4, "Tui đã nghĩ bà sẽ liếm láp nó cơ…"))
    party.concat(pop.call(2, "Thì tui đang liếm nó mà. Bằng xúc tu của tui."))
    party.concat(pop.call(4, "Ha, Shylvie! Đưa tiền đây!"))
    party.concat(thought.call("Cả nhóm cùng nhau cười rộn rã. Tôi biết Kohi với Shylvie hay cá cược với nhau nhưng không ngờ rằng hai người họ lại dùng tôi để cá cược đấy."))
    party.concat(pop.call(2, "Xin lỗi mọi người—"))
    party.concat(pop.call(5, "Bà cứ đi đi, không sao hết."))
    party.concat(pop.call(3, "Nhớ về sớm đấy nhé!"))
    party.concat(pop.call(6, "Không là mọi người ăn hết kem đó!!"))
    party.concat(pop.call(4, "Đi cẩn thận nhé!!"))
    party.concat(pop.call(2, "Ừa! Tui đi đây!! Nhớ chừa kem cho tui đó!!"))
    party.concat([event_command(121, 0, [45, 45, 0]), event_command(122, 0, [44, 44, 0, 0, 4]),
                  event_command(221, 0, []), event_command(230, 0, [40]), event_command(201, 0, [0, 39, 22, 34, 8, 0])])
    events38 = {1 => event_from_pages(template_event, 1, "SCN-MKT-CHRISTMAS-PARTY", 0, 0,
                                      [page_from_template(template_event, party, trigger: 3, priority: 0)])}
    [[2, "!$HaiQuy_GiangSinh", 22, 31, "NPC-HAI-QUY"],
     [3, "$Shylvie_giangsinh", 20, 31, "NPC-SHYLVIE"],
     [4, "$Kohi_giangsinh", 24, 31, "NPC-KOHI"],
     [5, "$Leo_giangsinh", 21, 29, "NPC-LEO"],
     [6, "$Hakasa_GiangSinh", 23, 29, "NPC-HAKASE"]].each do |id, charset, x, y, name|
      pg = page_from_template(template_event, [], trigger: 0, priority: 1)
      gr = pg.instance_variable_get(:@graphic)
      gr.instance_variable_set(:@character_name, charset)
      gr.instance_variable_set(:@character_index, 0)
      events38[id] = event_from_pages(template_event, id, name, x, y, [pg])
    end
    map38.instance_variable_set(:@events, events38)
    save_data("Data/Map038.rvdata2", map38)

    # Map039: coffee -> Kohi epilogue, default branch because the current phone
    # contact system does not persist whether Momo's message was opened.
    map39 = Marshal.load(Marshal.dump(map38))
    map39.instance_variable_set(:@display_name, "Wanderer Office — Sáng hôm sau")
    map39.instance_variable_set(:@parallax_name, "Map_Wanderer_Office_base")
    map39.instance_variable_set(:@note, "<full lock parallax>\r\n<tile lock parallax>\r\nMKT coffee->Kohi epilogue; default no-Momo-read branch")
    ep = [event_command(355, 0, ["$game_player.transparent=true"]),
          event_command(355, 0, ["layer(39,0,[\"Map_Wanderer_Office_top\",0,0,255,200,0,0,0])"]),
          event_command(655, 0, ["refresh_layers"]), event_command(117, 0, [3]),
          event_command(222, 0, [])]
    ["Tôi thực hiện thành công nhiệm vụ giải cứu phiền phức ngay tối hôm đấy.",
     "Rìa lỗ hổng 61 là khu vực cực kỳ hỗn loạn. Tuy vậy tôi vẫn dễ dàng giải cứu hết các thành viên Silver Wing bị bắt nhốt tại đấy trong tích tắc và không chần chừ tạo một kết giới để phong tỏa toàn bộ quái vật rồi cho nổ tanh bành mọi thứ.",
     "May cho mấy đứa bên Silver Wing vì TÔI là người đã cứu chúng nó, chứ nếu mà để Dahria làm thì có khi giờ này chúng nó đi chầu ông bà rồi.",
     "Sáng hôm sau, tôi dịch chuyển về văn phòng Wanderer để ăn kem.",
     "Vừa bước vào bếp, tôi đã ngửi thấy mùi cà phê nồng nàn. Kohi đang cầm một cốc cà phê nóng hôi hổi, còn bàn bếp thì chất đầy cốc cà phê sử dụng một lần."].each { |line| ep.concat(thought.call(line)) }
    ep.concat(pop.call(4, "Ơ Quỳ, bà về sớm thế! Uống cà phê không?"))
    ep.concat(pop.call(2, "Uống chứ. Bà pha loại nào đó?"))
    ep.concat(pop.call(4, "À, cái loại của Leo ấy. Loại này khá là đặc biệt nha. Của bà đây."))
    ep.concat(thought.call("Tôi nếm thử. Ừa, đúng là ngon thật. Mùi cà phê này thơm quá mà lạ nữa, hình như không phải loại cà phê ở thế giới này. Nó có mùi gì đấy giống giống mùi bạc hà, một chút khét của nhựa đường và vị chát của vôi."))
    ep.concat(pop.call(2, "Ừ, ngon ghê."))
    ep.concat(pop.call(4, "Phải ha!!"))
    ep.concat(pop.call(2, "Bảo sao bà uống tận hơn ba mươi ly."))
    ep.concat(pop.call(4, "Ồ, nó đặc biệt ở chỗ đó đó Quỳ! Một muỗng cà phê Luminous mà pha hơn tận ba chục ly mà vẫn đậm đặc. Thần kỳ thật ha!"))
    ep.concat(pop.call(2, "Ừa, bảo sao đợt lâu rồi Leo mượn phin pha cà phê của tui tận một tháng mà không trả."))
    ep.concat(thought.call("Cứ thế, hai đứa bọn tôi vừa ngồi uống cà phê, vừa trò chuyện, vừa ngắm nhìn bầu trời buổi sáng."))
    ep.concat([event_command(355, 0, ["GlobalGallery.unlock(11)"]),
               event_command(355, 0, ["EndingPresentation.show_gallery(\"ED_MKT_COFFEE_KOHI\",240)"]),
               event_command(121, 0, [46, 46, 0]), event_command(122, 0, [41, 41, 0, 0, 2]),
               event_command(201, 0, [0, 36, 8, 6, 2, 2])])
    events39 = events38.dup
    events39[1] = event_from_pages(template_event, 1, "SCN-MKT-COFFEE-KOHI-EPILOGUE", 0, 0,
                                   [page_from_template(template_event, ep, trigger: 3, priority: 0)])
    map39.instance_variable_set(:@events, events39)
    save_data("Data/Map039.rvdata2", map39)

    # Reusable after-ending hub: later page wins when ENDING_HINT_ID >= 2.
    map36 = load_data("Data/Map036.rvdata2")
    router = (map36.instance_variable_get(:@events) || {})[1]
    bully = (map36.instance_variable_get(:@events) || {})[2]
    hint = [event_command(355, 0, ["$game_player.transparent=true"]),
            event_command(122, 0, [40, 40, 0, 0, 2]), event_command(117, 0, [5])]
    ["Ta thấy hơi chán", "Ngươi tặng cho Kohi món quà tuyệt vời nhất. Best Ending luôn rồi còn gì?",
     "Ngươi chưa từng nghĩ đến việc tặng cho cô ấy một món quà độc lạ hả?",
     "Tặng cái gì khác ngoài cà phê đi!!"].each { |line| hint.concat(pop.call(2, line)) }
    hint.concat([event_command(117, 0, [3]), event_command(230, 0, [60]),
                 event_command(355, 0, ["HAIQUY_TITLE.set_ending_background(\"ED_MKT_COFFEE_KOHI\")"]),
                 event_command(354, 0, [])])
    pages36 = router.instance_variable_get(:@pages) || []
    pages36.reject! do |pg|
      c = pg.instance_variable_get(:@condition)
      c && c.instance_variable_get(:@variable_valid) && c.instance_variable_get(:@variable_value) == 2
    end
    pages36 << page_from_template(router, hint, trigger: 3, priority: 0, variable_id: 41, variable_value: 2)
    router.instance_variable_set(:@pages, pages36)
    save_data("Data/Map036.rvdata2", map36)

    infos = load_data("Data/MapInfos.rvdata2")
    [[37, "Phòng Hải Quỳ — Chuẩn bị quà"], [38, "Wanderer Office — Giáng sinh"],
     [39, "Wanderer Office — Sáng hôm sau"]].each do |id, name|
      info = infos[id] || Marshal.load(Marshal.dump(infos[35]))
      info.instance_variable_set(:@name, name)
      info.instance_variable_set(:@parent_id, 0)
      info.instance_variable_set(:@order, infos.values.compact.map { |i| i.instance_variable_get(:@order).to_i }.max + 1)
      infos[id] = info
    end
    save_data("Data/MapInfos.rvdata2", infos)

    system = load_data("Data/System.rvdata2")
    variables = system.instance_variable_get(:@variables)
    switches = system.instance_variable_get(:@switches)
    variables[42], variables[43], variables[44] = "MKT_GIFT", "MKT_TARGET", "MKT_STAGE"
    switches[44], switches[45], switches[46] = "MKT_ACTIVE", "MKT_PARTY_DONE", "MKT_END_UNLOCK"
    save_data("Data/System.rvdata2", system)
    puts "SUPERMARKET_SLICE|Map019->Map037->Map038|gift_var=42|target_var=43|stage_var=44"
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

  def replace_storage_diary_events!(map)
    events = map.instance_variable_get(:@events) || {}
    by_name = {}
    events.each_value do |event|
      next unless event
      by_name[event.instance_variable_get(:@name)] = event
    end

    child = by_name["LORE-STORAGE-AIRA-DIARY [E016]"] ||
            by_name["LORE-STORAGE-AIRA-DIARY"]
    old = by_name["LORE-STORAGE-ENCRYPTED-DIARY [E019]"] ||
          by_name["LORE-STORAGE-ENCRYPTED-DIARY"]
    letter = by_name["SCN-STORAGE-LETTER-BOXES [E020]"] ||
             by_name["SCN-STORAGE-LETTER-BOXES"]
    album = by_name["LORE-STORAGE-DRAWING-ALBUM [E018]"] ||
            by_name["LORE-STORAGE-DRAWING-ALBUM"]
    missing = []
    missing << "Aira child diary" unless child
    missing << "Aira old diary" unless old
    missing << "Dahria last letter" unless letter
    missing << "storage album" unless album
    raise "Map026 diary events missing: #{missing.join(', ')}" unless missing.empty?

    intro = lambda do |text, face_index = 1|
      commands = wrapped_message_commands([text])
      commands.each do |command|
        next unless command_code(command) == 101
        params = command_parameters(command)
        params[0] = "HaiQuy_Thuongphuc_Emote"
        params[1] = face_index
      end
      commands
    end

    child_pages = child.instance_variable_get(:@pages) || []
    raise "Map026 child diary light page missing" unless child_pages[1]
    child_pages[1].instance_variable_set(:@list,
      intro.call("Cuốn nhật ký được viết nguệch ngoạc.") + [
      event_command(355, 0, ["WCFDiaryReader.read(:aira_child)"]),
      event_command(0, 0, [])
    ])

    old_page = (old.instance_variable_get(:@pages) || [])[0]
    raise "Map026 old diary page missing" unless old_page
    old_page.instance_variable_set(:@list,
      intro.call("Có một cuốn nhật ký bị mã hóa bằng phép thuật. Mở ra xem?") + [
      event_command(355, 0, ["WCFDiaryReader.read(:aira_old)"]),
      event_command(0, 0, [])
    ])

    album_page = (album.instance_variable_get(:@pages) || [])[0]
    raise "Map026 storage album page missing" unless album_page
    album_page.instance_variable_set(:@list,
      intro.call("Trong tủ sách có một cuốn album tranh vẽ bị phủ đầy bụi và mạng nhện. Mở ra xem?") + [
      event_command(355, 0, ["WCFDiaryReader.read(:storage_album)"]),
      event_command(0, 0, [])
    ])

    letter_page = (letter.instance_variable_get(:@pages) || [])[2]
    raise "Map026 letter page missing" unless letter_page
    list = letter_page.instance_variable_get(:@list) || []
    first_state_command = list.index do |command|
      [121, 122, 123, 201].include?(command_code(command))
    end
    tail = first_state_command ? list[first_state_command..-1] : []
    tail = tail.reject { |command| command_code(command) == 0 }
    letter_intro = "Dưới đáy thùng thứ ba có một lá thư bị vò nhăn nhúm. " +
      "Chữ viết nhìn có vẻ vội vã. Đọc lá thư?"
    letter_page.instance_variable_set(:@list, intro.call(letter_intro, 3) + [
      event_command(355, 0, ["WCFDiaryReader.read(:dahria_last)"])
    ] + tail + [event_command(0, 0, [])])
    map
  end

  def replace_storage_diary_text_with_pictures
    path = "Data/Map026.rvdata2"
    map = load_data(path)
    replace_storage_diary_events!(map)
    save_data(path, map)
    puts "MAP026_DIARY_PICTURES|child=9|old=13|album=4|letter=3|events=16,18,19,20"
  end

  def gate_map026_interactions_behind_light!(map)
    events = map.instance_variable_get(:@events) || {}
    light_switch = 39
    dark_text = "Tối quá mình không nhìn thấy gì, cần phải tìm đèn"
    interaction_ids = [10, 11, 12, 13, 16, 17, 18, 19, 20]

    dark_commands = wrapped_message_commands([dark_text])
    dark_commands.each do |command|
      next unless command_code(command) == 101
      params = command_parameters(command)
      params[0] = "HaiQuy_Thuongphuc_Emote"
      params[1] = 3
    end
    dark_commands << event_command(0, 0, [])

    interaction_ids.each do |event_id|
      event = events[event_id]
      raise "Map026 interaction event #{event_id} missing" unless event
      pages = event.instance_variable_get(:@pages) || []
      normal_pages = pages.reject do |page|
        list = page.instance_variable_get(:@list) || []
        text = list.select { |command| command_code(command) == 401 }
                   .map { |command| command_parameters(command)[0].to_s }.join(" ")
        text.include?("Tối quá") &&
          list.none? { |command| ![0, 101, 401].include?(command_code(command)) }
      end
      raise "Map026 interaction event #{event_id} has no normal page" if normal_pages.empty?

      normal_pages.each do |page|
        condition = page.instance_variable_get(:@condition)
        condition.instance_variable_set(:@switch1_valid, true)
        condition.instance_variable_set(:@switch1_id, light_switch)
      end

      dark_page = Marshal.load(Marshal.dump(normal_pages.first))
      reset_page_condition(dark_page.instance_variable_get(:@condition))
      dark_page.instance_variable_set(:@list, Marshal.load(Marshal.dump(dark_commands)))
      event.instance_variable_set(:@pages, [dark_page] + normal_pages)
    end

    light = events[15]
    raise "Map026 remaining light event E015 missing" unless light
    light_pages = light.instance_variable_get(:@pages) || []
    raise "Map026 light event E015 has no page" if light_pages.empty?
    active_page = light_pages.first
    reset_page_condition(active_page.instance_variable_get(:@condition))

    completed_page = if light_pages[1]
      light_pages[1]
    else
      Marshal.load(Marshal.dump(active_page))
    end
    condition = completed_page.instance_variable_get(:@condition)
    reset_page_condition(condition)
    condition.instance_variable_set(:@switch1_valid, true)
    condition.instance_variable_set(:@switch1_id, light_switch)
    completed_page.instance_variable_set(:@list, [event_command(0, 0, [])])
    light.instance_variable_set(:@pages, [active_page, completed_page])

    events.delete(14)
    map
  end

  def gate_map026_interactions_behind_light
    path = "Data/Map026.rvdata2"
    map = load_data(path)
    gate_map026_interactions_behind_light!(map)
    save_data(path, map)
    puts "MAP026_LIGHT_GATE|light=E015|switch=39|guarded=10,11,12,13,16,17,18,19,20|removed=E014"
  end

  def polish_map026_cassette_player!(map)
    events = map.instance_variable_get(:@events) || {}
    event = events[12]
    raise "Map026 cassette player E012 missing" unless event
    pages = event.instance_variable_get(:@pages) || []

    hq_message = lambda do |text, face_index = 1|
      commands = wrapped_message_commands([text])
      commands.each do |command|
        next unless command_code(command) == 101
        params = command_parameters(command)
        params[0] = "HaiQuy_Thuongphuc_Emote"
        params[1] = face_index
      end
      commands
    end
    recording = lambda do |lines|
      # Empty face name is intentional: these voices come from the cassette
      # player and are not Hải Quỳ speaking in the present.
      wrapped_message_commands(lines)
    end

    description = "Một chiếc TV cũ cùng một đầu băng cát-sét vẫn còn dùng được."
    tapes = {
      1 => ["Paulie biết đi", [
        "“ Anh trai anh trai! Nhìn nè, em trai biết đi rồi! “",
        "“ Em trai giỏi quá! Thật may là anh ghi hình kịp lúc! “",
        "“ Popo! Momo! Paulie biết đi rồi! “",
        "“ Wow! Paulie giỏi quá!!! “"
      ]],
      2 => ["Bánh Mì Bơ Tỏi", [
        "“ Aira! Em đang nấu gì đấy? “",
        "“ Bánh mì bơ tỏi! Em muốn cho Paulie ăn món tủ của anh! “",
        "“ Này, em biết là em bé không ăn được đồ cứng mà, đúng không? “",
        "“ Hơn nữa là bánh khét rồi kìa “",
        "“ ÚI!! “"
      ]],
      3 => ["Xích đu", [
        "“ Dahria Dahria!! Xem tớ nè!! “",
        "“ Wow, ngầu quá đi! Cậu đu được một vòng luôn! “",
        "“ Dahria! Aira! Hai đứa dừng lại ngay!! “",
        "“ Awawawa, Popo, cứu con với, con không ngừng đu được!! “"
      ]]
    }

    pages.each do |page|
      condition = page.instance_variable_get(:@condition)
      next unless condition.instance_variable_get(:@switch1_valid) &&
                  condition.instance_variable_get(:@switch1_id) == 39
      if condition.instance_variable_get(:@variable_valid) &&
         condition.instance_variable_get(:@variable_id) == 32
        value = condition.instance_variable_get(:@variable_value)
        tape = tapes[value]
        next unless tape
        name, lines = tape
        list = hq_message.call(description) +
          hq_message.call("Bỏ băng “#{name}” vào đầu đĩa.") +
          recording.call(lines) + [event_command(0, 0, [])]
        page.instance_variable_set(:@list, list)
      else
        page.instance_variable_set(:@list,
          hq_message.call(description) + [event_command(0, 0, [])])
      end
    end
    map
  end

  def polish_map026_cassette_player
    path = "Data/Map026.rvdata2"
    map = load_data(path)
    polish_map026_cassette_player!(map)
    save_data(path, map)
    puts "MAP026_CASSETTE_PLAYER|event=E012|insert_lines=3|recording_faces=none"
  end

  def apply_map026_khas_lighting
    path = "Data/Map026.rvdata2"
    map = load_data(path)
    events = map.instance_variable_get(:@events) || {}
    required = [1, 2, 15, 20]
    missing = required.reject { |id| events[id] }
    raise "Map026 missing events: #{missing.join(', ')}" unless missing.empty?

    note = map.instance_variable_get(:@note).to_s
    note = note.lines.reject { |line| line =~ /^\[(?:lighting|opacity|color)\b/i }.join
    note = "[lighting on]\n[opacity 235]\n[color 000000000]\n#{note}"
    map.instance_variable_set(:@note, note)

    setup_page = events[1].instance_variable_get(:@pages).first
    setup_page.instance_variable_set(:@list, [
      event_command(355, 0, ['layer(26,0,["Storage_Top",0,0,255,200,0,0,0])']),
      event_command(655, 0, ["refresh_layers"]),
      event_command(355, 0, ["if $game_switches[39]"]),
      event_command(655, 0, ["  $game_player.drop_light"]),
      event_command(655, 0, ["  $game_map.shadows.set_opacity(0)"]),
      event_command(655, 0, ["else"]),
      event_command(655, 0, ["  $game_map.shadows.set_color(0, 0, 0)"]),
      event_command(655, 0, ["  $game_map.shadows.set_opacity(235)"]),
      event_command(655, 0, ['  $game_player.give_light("player_small")']),
      event_command(655, 0, ["end"]),
      event_command(355, 0, ["map_effects.set_tone(0,0,0,0,0)"]),
      event_command(123, 0, ["A", 0]),
      event_command(0, 0, [])
    ])

    [15].each do |event_id|
      page = events[event_id].instance_variable_get(:@pages).first
      page.instance_variable_set(:@list, [
        event_command(101, 0, ["", 0, 0, 2]),
        event_command(401, 0, ["Bật đèn?"]),
        event_command(121, 0, [39, 39, 0]),
        event_command(355, 0, ["$game_player.drop_light"]),
        event_command(355, 0, ["$game_map.shadows.set_opacity(0, 30)"]),
        event_command(0, 0, [])
      ])
    end

    cleanup = [
      event_command(355, 0, ["$game_player.drop_light"]),
      event_command(355, 0, ["$game_map.shadows.set_opacity(0)"])
    ]
    exit_page = events[2].instance_variable_get(:@pages).first
    exit_list = exit_page.instance_variable_get(:@list) || []
    exit_list.reject! do |command|
      command_code(command) == 355 && ["$game_player.drop_light", "$game_map.shadows.set_opacity(0)"].include?(command_parameters(command)[0])
    end
    transfer_index = exit_list.index { |command| command_code(command) == 201 } || exit_list.length - 1
    exit_list.insert(transfer_index, *Marshal.load(Marshal.dump(cleanup)))

    letter_page = events[20].instance_variable_get(:@pages)[2]
    letter_list = letter_page.instance_variable_get(:@list) || []
    letter_list.reject! do |command|
      command_code(command) == 355 && ["$game_player.drop_light", "$game_map.shadows.set_opacity(0)"].include?(command_parameters(command)[0])
    end
    transfer_index = letter_list.index { |command| command_code(command) == 201 } || letter_list.length - 1
    letter_list.insert(transfer_index, *Marshal.load(Marshal.dump(cleanup)))

    save_data(path, map)
    puts "MAP026_KHAS_LIGHTING|dark=235|player_light=player_small|switch=39|events=1,2,14,15,20"
  end

  def create_phone_timeline_presets
    common_path = "Data/CommonEvents.rvdata2"
    common_events = load_data(common_path)
    template = common_events.compact.first
    raise "No Common Event template" unless template
    presets = {
      12 => ["PHONE — Prologue 21 Dec 08:45 [CE12]", :prologue],
      13 => ["PHONE — City 21 Dec 17:35 [CE13]", :city],
      14 => ["PHONE — Bus 21 Dec 18:05 [CE14]", :bus],
      15 => ["PHONE — Atlantis Gate 21 Dec 19:00 [CE15]", :atlantis_gate],
      16 => ["PHONE — Home 21 Dec 19:20 [CE16]", :home],
      17 => ["PHONE — Book Shop 21 Dec 20:10 [CE17]", :book_shop],
      18 => ["PHONE — Christmas Gift 25 Dec 19:00 [CE18]", :christmas_gift]
    }
    presets.each do |id, (name, stage)|
      event = common_events[id] || Marshal.load(Marshal.dump(template))
      event.instance_variable_set(:@id, id)
      event.instance_variable_set(:@name, name)
      event.instance_variable_set(:@trigger, 0)
      event.instance_variable_set(:@switch_id, 1)
      event.instance_variable_set(:@list, [
        event_command(355, 0, ["PhoneTimeline.advance(:#{stage})"]),
        event_command(0, 0, [])
      ])
      common_events[id] = event
    end
    save_data(common_path, common_events)

    attachments = {
      3 => [1, 12],
      6 => [2, 13],
      10 => [2, 14],
      21 => [1, 15],
      22 => [1, 16],
      23 => [1, 17]
    }
    attachments.each do |map_id, (event_id, common_id)|
      path = format("Data/Map%03d.rvdata2", map_id)
      map = load_data(path)
      event = (map.instance_variable_get(:@events) || {})[event_id]
      raise "Map#{map_id} missing Event #{event_id}" unless event
      page = (event.instance_variable_get(:@pages) || []).first
      list = page.instance_variable_get(:@list) || []
      list.reject! do |command|
        command_code(command) == 117 && (12..18).include?(command_parameters(command)[0])
      end
      list.unshift(event_command(117, 0, [common_id]))
      page.instance_variable_set(:@list, list)
      save_data(path, map)
    end
    puts "PHONE_TIMELINE|common_events=12..18|maps=3,6,10,21,22,23|gift=25-Dec-19:00"
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

  def remove_bus_route_choice_fadeouts
    path = "Data/Map010.rvdata2"
    map = load_data(path)
    event = (map.instance_variable_get(:@events) || {})[2]
    page = (event.instance_variable_get(:@pages) || []).first
    list = page.instance_variable_get(:@list) || []
    before = list.length
    # Transfer Player with fade type 0 already performs its own black
    # transition. Event command 221 changes Game_Screen#brightness to zero;
    # the transfer transition does not restore that value, so every route
    # choice could arrive on its destination map with a permanently black
    # screen. Let Transfer Player own the complete transition instead.
    list.reject! { |command| command.instance_variable_get(:@code) == 221 }
    page.instance_variable_set(:@list, list)
    save_data(path, map) if list.length != before
    puts "BUS_ROUTE_FADEOUT|removed=#{before - list.length}"
  end

  def animate_supermarket_bus_departure
    arrival_switch_id = 50

    # Mark only the bus -> supermarket transfer. This prevents the bus
    # departure autorun from playing when Map019 is entered by another route.
    bus_path = "Data/Map010.rvdata2"
    bus_map = load_data(bus_path)
    bus_event = (bus_map.instance_variable_get(:@events) || {})[2]
    bus_page = (bus_event.instance_variable_get(:@pages) || []).first
    bus_list = bus_page.instance_variable_get(:@list) || []
    transfer_index = bus_list.index do |command|
      command_code(command) == 201 && command_parameters(command)[1] == 19
    end
    raise "Map010 supermarket transfer not found" unless transfer_index
    previous = bus_list[transfer_index - 1]
    unless previous && command_code(previous) == 121 &&
           command_parameters(previous) == [arrival_switch_id, arrival_switch_id, 0]
      bus_list.insert(transfer_index,
        event_command(121, 1, [arrival_switch_id, arrival_switch_id, 0]))
      bus_page.instance_variable_set(:@list, bus_list)
      save_data(bus_path, bus_map)
    end

    market_path = "Data/Map019.rvdata2"
    market_map = load_data(market_path)
    market_events = market_map.instance_variable_get(:@events) || {}
    bus = market_events[44]
    raise "Map019 E044 bus event not found" unless bus
    bus.instance_variable_set(:@name, "SCN-MKT-BUS-DEPARTURE [E044]")

    page = (bus.instance_variable_get(:@pages) || []).first
    condition = page.instance_variable_get(:@condition)
    condition.instance_variable_set(:@switch1_valid, true)
    condition.instance_variable_set(:@switch1_id, arrival_switch_id)
    condition.instance_variable_set(:@switch2_valid, false)
    condition.instance_variable_set(:@variable_valid, false)
    condition.instance_variable_set(:@self_switch_valid, false)
    page.instance_variable_set(:@trigger, 3)
    page.instance_variable_set(:@priority_type, 1)

    route = RPG::MoveRoute.allocate
    route.instance_variable_set(:@repeat, false)
    route.instance_variable_set(:@skippable, true)
    route.instance_variable_set(:@wait, true)
    move_list = []
    [[37, []], [29, [5]], [30, [5]]].each do |code, parameters|
      move = RPG::MoveCommand.allocate
      move.instance_variable_set(:@code, code)
      move.instance_variable_set(:@parameters, parameters)
      move_list << move
    end
    16.times do
      move = RPG::MoveCommand.allocate
      move.instance_variable_set(:@code, 2) # Move Left
      move.instance_variable_set(:@parameters, [])
      move_list << move
    end
    invisible = RPG::MoveCommand.allocate
    invisible.instance_variable_set(:@code, 42)
    invisible.instance_variable_set(:@parameters, [0])
    move_list << invisible
    route_end = RPG::MoveCommand.allocate
    route_end.instance_variable_set(:@code, 0)
    route_end.instance_variable_set(:@parameters, [])
    move_list << route_end
    route.instance_variable_set(:@list, move_list)

    page.instance_variable_set(:@list, [
      event_command(205, 0, [0, route]),
      event_command(123, 0, ["A", 0]),
      event_command(121, 0, [arrival_switch_id, arrival_switch_id, 1]),
      event_command(0, 0, [])
    ])

    finished_page = Marshal.load(Marshal.dump(page))
    finished_condition = finished_page.instance_variable_get(:@condition)
    finished_condition.instance_variable_set(:@switch1_valid, false)
    finished_condition.instance_variable_set(:@self_switch_valid, true)
    finished_condition.instance_variable_set(:@self_switch_ch, "A")
    finished_graphic = finished_page.instance_variable_get(:@graphic)
    finished_graphic.instance_variable_set(:@character_name, "")
    finished_page.instance_variable_set(:@trigger, 0)
    finished_page.instance_variable_set(:@priority_type, 0)
    finished_page.instance_variable_set(:@list, [event_command(0, 0, [])])
    bus.instance_variable_set(:@pages, [page, finished_page])
    save_data(market_path, market_map)

    system = load_data("Data/System.rvdata2")
    switches = system.instance_variable_get(:@switches) || []
    switches[arrival_switch_id] = "MKT_BUS_ARRIVAL"
    system.instance_variable_set(:@switches, switches)
    save_data("Data/System.rvdata2", system)
    puts "MKT_BUS_DEPARTURE|switch=#{arrival_switch_id}|event=44|left_steps=16"
  end

  def fix_supermarket_coffee_checkout
    path = "Data/Map019.rvdata2"
    map = load_data(path)
    events = map.instance_variable_get(:@events) || {}
    coffee = events[33]
    checkout = events[42]
    raise "Map019 E033 coffee event not found" unless coffee
    raise "Map019 E042 checkout event not found" unless checkout

    page = (coffee.instance_variable_get(:@pages) || []).first
    reaction = [
      "Máy pha cà phê là món quà ổn áp ấy chứ nhỉ? Vì cả văn phòng Wanderer ai cũng thích uống cà phê hết. Thành ra là bây giờ tôi không biết nên tặng cho ai.",
      "Tặng cho Kohi là điều đầu tiên mà tôi nghĩ tới vì Kohi là Quỷ cà phê, không những thế bà ấy thực sự nghiện uống cà phê.",
      "Tiếp đến là Shylvie, Shylvie lắm hôm cũng hay thức khuya nên tần suất uống cà phê cũng nhiều.",
      "Kế đến là Leo và Hakase, tuy hai người này uống cà phê ít hơn hai người kia nhưng mà mỗi lần họ uống thì toàn uống một lít.",
      "Sao càng nói càng thấy văn phòng này đang có vấn đề với cà phê vậy nhỉ?",
      "Đương nhiên là phải loại trừ tôi ra rồi.",
      "Vì tôi uống sữa nhiều hơn cà phê, haha.",
      "Quả đúng là con nít! Tự hào quá đi!",
      "Tôi tí ta tí tởn đi đến khu vực mua máy pha cà phê."
    ].flat_map do |text|
      wrapped_message_commands([text], width: 30, indent: 1).each do |command|
        if command_code(command) == 101
          command.instance_variable_set(:@parameters,
            ["HaiQuy_Thuongphuc_Emote", 1, 0, 2])
        end
      end
    end

    commands = [
      event_command(101, 0, ["HaiQuy_Thuongphuc_Emote", 3, 0, 2]),
      event_command(401, 0, ["\\bm[0]- Ui? Máy pha cà phê đang giảm giá nè!"]),
      event_command(401, 0, ["Chỉ với 599k thôi á?!"]),
      event_command(102, 0, [["MUA LUÔN!", "Thử đi tìm món khác xem"], 2]),
      event_command(402, 0, [0, "MUA LUÔN!"])
    ]
    commands.concat(reaction)
    commands.concat([
      event_command(122, 1, [42, 42, 0, 0, 1]),
      event_command(121, 1, [44, 44, 0]),
      event_command(122, 1, [44, 44, 0, 0, 1]),
      event_command(402, 0, [1, "Thử đi tìm món khác xem"]),
      event_command(404, 0, []),
      event_command(0, 0, [])
    ])
    page.instance_variable_set(:@list, commands)
    # Match E034-E036: selecting an item only records route state and returns
    # control to the player. E042 at the exit remains the sole checkout gate.
    coffee.instance_variable_set(:@pages, [page])
    save_data(path, map)

    verify = load_data(path)
    verify_events = verify.instance_variable_get(:@events) || {}
    errors = []
    (33..36).each do |event_id|
      event = verify_events[event_id]
      list = event && (event.instance_variable_get(:@pages) || []).flat_map do |event_page|
        event_page.instance_variable_get(:@list) || []
      end
      errors << "E%03d missing" % event_id unless list
      next unless list
      errors << "E%03d forces transfer/fade" % event_id if
        list.any? { |command| [201, 221, 222].include?(command_code(command)) }
      errors << "E%03d starts checkout directly" % event_id if list.any? do |command|
        [355, 655].include?(command_code(command)) &&
          command_parameters(command).join(" ").include?("events[42].start")
      end
    end
    checkout_list = (verify_events[42].instance_variable_get(:@pages) || []).flat_map do |event_page|
      event_page.instance_variable_get(:@list) || []
    end
    errors << "E042 no checkout choice" unless checkout_list.any? do |command|
      command_code(command) == 102 && command_parameters(command)[0].include?("Xong rồi")
    end
    raise "Supermarket checkout audit failed: #{errors.join(', ')}" unless errors.empty?
    puts "MKT_COFFEE_CHECKOUT|free_roam=true|checkout_gate=E042|forced_handoff=false"
  end

  def rebuild_christmas_office_black_cutscene
    bully_switch_id = 51
    picture_id = 20

    # The current supermarket preparation scene explicitly hands control to
    # Aira. Keep that state data-driven so future routes can leave the switch
    # OFF and use CG6 for Hải Quỳ instead.
    prep_path = "Data/Map037.rvdata2"
    prep_map = load_data(prep_path)
    prep_event = (prep_map.instance_variable_get(:@events) || {})[1]
    prep_page = (prep_event.instance_variable_get(:@pages) || []).first
    prep_list = prep_page.instance_variable_get(:@list) || []
    unless prep_list.any? do |command|
      command_code(command) == 121 &&
        command_parameters(command)[0, 2] == [bully_switch_id, bully_switch_id]
    end
      insert_at = [prep_list.index { |command| command_code(command) == 101 } || 1, 1].max
      prep_list.insert(insert_at,
        event_command(121, 0, [bully_switch_id, bully_switch_id, 0]))
      prep_page.instance_variable_set(:@list, prep_list)
      save_data(prep_path, prep_map)
    end

    path = "Data/Map038.rvdata2"
    map = load_data(path)
    events = map.instance_variable_get(:@events) || {}

    strip_pop_tags = lambda do |list|
      list.each do |command|
        next unless command_code(command) == 401
        parameters = command_parameters(command)
        parameters[0] = parameters[0].to_s.gsub(/\\bm\[\d+\]\s*/, "")
      end
    end

    intro = events.fetch(1).instance_variable_get(:@pages).first
    intro_list = intro.instance_variable_get(:@list) || []
    strip_pop_tags.call(intro_list)

    # Remove any previous generated CG selector/erase commands and rebuild it.
    cleaned = []
    index = 0
    while index < intro_list.length
      command = intro_list[index]
      if command_code(command) == 111 && command_parameters(command)[0, 3] == [0, bully_switch_id, 0] &&
         intro_list[index + 1] && command_code(intro_list[index + 1]) == 231
        index += 5
        next
      end
      if command_code(command) == 235 && command_parameters(command)[0] == picture_id
        index += 1
        next
      end
      if command_code(command) == 121 &&
         command_parameters(command)[0, 3] == [bully_switch_id, bully_switch_id, 1]
        index += 1
        next
      end
      if command_code(command) == 355 &&
         command_parameters(command)[0].to_s.include?("WCF_CHRISTMAS_REVEAL")
        index += 1
        index += 1 if intro_list[index] && command_code(intro_list[index]) == 230 &&
                      command_parameters(intro_list[index])[0] == 30
        next
      end
      cleaned << command
      index += 1
    end
    intro_list = cleaned

    # Use map tone instead of Fadeout Screen: viewport3 brightness would cover
    # Pictures as well, while a black map tone leaves CG6/CG7 and messages visible.
    intro_list.reject! do |command|
      command_code(command) == 355 &&
        command_parameters(command)[0].to_s.include?("WCF_CHRISTMAS_BLACK")
    end
    intro_list.unshift(event_command(355, 0, [
      "$game_map.screen.start_tone_change(Tone.new(-255,-255,-255,0),0); map_effects.set_tone(-255,-255,-255,0,0) # WCF_CHRISTMAS_BLACK"
    ]))

    buried_text = intro_list.index do |command|
      command_code(command) == 401 &&
        command_parameters(command)[0].to_s.include?("Cả cơ thể của tôi bị chôn vùi")
    end
    raise "Map038 buried-in-snow dialogue marker missing" unless buried_text
    show_at = buried_text
    show_at -= 1 while show_at.positive? && command_code(intro_list[show_at - 1]) == 101
    show_at = buried_text.downto(0).find { |i| command_code(intro_list[i]) == 101 } || buried_text
    selector = [
      event_command(111, 0, [0, bully_switch_id, 0]),
      event_command(231, 1, [picture_id, "CG7", 1, 0, 320, 240, 100, 100, 255, 0]),
      event_command(411, 0, []),
      event_command(231, 1, [picture_id, "CG6", 1, 0, 320, 240, 100, 100, 255, 0]),
      event_command(412, 0, [])
    ]
    intro_list.insert(show_at, *selector)

    pulled_text = intro_list.index do |command|
      command_code(command) == 401 &&
        command_parameters(command)[0].to_s.include?("Cả bọn cùng hợp sức để kéo tôi")
    end
    raise "Map038 pulled-from-snow dialogue marker missing" unless pulled_text
    erase_at = pulled_text + 1
    erase_at += 1 while erase_at < intro_list.length && command_code(intro_list[erase_at]) == 401
    intro_list.insert(erase_at, event_command(235, 0, [picture_id]))

    # Remain black through the whole autorun. Reveal the office only after all
    # scene staging is ready and immediately before free exploration unlocks.
    free_index = intro_list.index do |command|
      command_code(command) == 121 && command_parameters(command)[0, 2] == [48, 48] &&
        command_parameters(command)[2] == 0
    end
    raise "Map038 free-explore switch marker missing" unless free_index
    intro_list.insert(free_index,
      event_command(235, 0, [picture_id]),
      event_command(121, 0, [bully_switch_id, bully_switch_id, 1]),
      event_command(355, 0, ["$game_map.screen.start_tone_change(Tone.new(0,0,0,0),30); map_effects.set_tone(0,0,0,0,30) # WCF_CHRISTMAS_REVEAL"]),
      event_command(230, 0, [30]))
    intro.instance_variable_set(:@list, intro_list)

    continuation = events.fetch(7).instance_variable_get(:@pages).first
    continuation_list = continuation.instance_variable_get(:@list) || []
    strip_pop_tags.call(continuation_list)
    continuation_list.reject! do |command|
      command_code(command) == 221 ||
        (command_code(command) == 355 &&
         command_parameters(command)[0].to_s.include?("WCF_CHRISTMAS_CONTINUE_BLACK"))
    end
    if continuation_list.first && command_code(continuation_list.first) == 230 &&
       command_parameters(continuation_list.first)[0] == 20
      continuation_list.shift
    end
    continuation_list.unshift(
      event_command(355, 0, ["$game_map.screen.start_tone_change(Tone.new(-255,-255,-255,0),20); map_effects.set_tone(-255,-255,-255,0,20) # WCF_CHRISTMAS_CONTINUE_BLACK"]),
      event_command(230, 0, [20]))
    continuation.instance_variable_set(:@list, continuation_list)
    save_data(path, map)

    system = load_data("Data/System.rvdata2")
    switches = system.instance_variable_get(:@switches) || []
    switches[bully_switch_id] = "MKT_BULLY_ACTIVE"
    system.instance_variable_set(:@switches, switches)
    save_data("Data/System.rvdata2", system)
    puts "CHRISTMAS_BLACK_CUTSCENE|normal_messages=true|CG6=HQ|CG7=Bully|free_reveal=true"
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

  def inspect_animation(id)
    animations = load_data("Data/Animations.rvdata2")
    animation = animations[id.to_i]
    raise "Animation #{id} missing" unless animation
    puts "ANIMATION|#{id}|#{animation.instance_variable_get(:@name)}|frames=#{animation.instance_variable_get(:@frame_max)}|position=#{animation.instance_variable_get(:@position)}"
    puts "GRAPHIC1|#{animation.instance_variable_get(:@animation1_name)}|hue=#{animation.instance_variable_get(:@animation1_hue)}"
    puts "GRAPHIC2|#{animation.instance_variable_get(:@animation2_name)}|hue=#{animation.instance_variable_get(:@animation2_hue)}"
    timings = animation.instance_variable_get(:@timings) || []
    puts "TIMINGS|#{timings.size}"
  end

  # Split the Christmas-party controller at the end of preparation, then add
  # a free-exploration phase and optional rhythm snowball invitations. This
  # mutates the current Map038 in place so editor-authored tiles and NPC
  # coordinates remain authoritative.
  def install_christmas_snowball_exploration
    map = load_data("Data/Map038.rvdata2")
    events = map.instance_variable_get(:@events) || {}
    controller = events.fetch(1)
    hq_event = events.fetch(2)
    raise "Map038 Wanderer NPC events missing" unless (3..6).all? { |id| events[id] }

    intro_page = (controller.instance_variable_get(:@pages) || []).first
    original = intro_page.instance_variable_get(:@list) || []

    # If this command has already been split, rebuild from the continuation.
    if events[7]
      continuation_page = (events[7].instance_variable_get(:@pages) || []).first
      continuation = continuation_page.instance_variable_get(:@list) || []
      start_index = continuation.index do |command|
        command_code(command) == 101
      end
      raise "Map038 continuation dialogue missing" unless start_index
      old_marker = original.index do |command|
        command_code(command) == 401 &&
          command_parameters(command)[0].to_s.include?("Bàn tiệc giáng sinh đã chuẩn")
      end
      raise "Map038 existing split marker missing" unless old_marker
      narrative_end = old_marker
      while narrative_end + 1 < original.length &&
            command_code(original[narrative_end + 1]) == 401
        narrative_end += 1
      end
      original = original[0..narrative_end] + continuation[start_index..-1]
    end

    marker = original.index do |command|
      command_code(command) == 401 &&
        command_parameters(command)[0].to_s.include?("Bàn tiệc giáng sinh đã chuẩn")
    end
    raise "Map038 party preparation marker missing" unless marker
    split_at = ((marker + 1)...original.length).find do |index|
      command_code(original[index]) == 101
    end
    raise "Map038 party continuation marker missing" unless split_at

    intro = original[0...split_at]
    intro.pop while intro.any? && command_code(intro[-1]) == 0
    intro.concat([
      event_command(117, 0, [1]),
      event_command(355, 0, ["hq=$game_map.events[2]; $game_player.moveto(hq.x,hq.y)"]),
      event_command(655, 0, ["$game_player.set_graphic(\"!$HaiQuy_GiangSinh\",0)"]),
      event_command(655, 0, ["$game_player.transparent=false; hq.transparent=true"]),
      event_command(655, 0, ["hq.instance_variable_set(:@through,true)"]),
      event_command(121, 0, [48, 48, 0]),
      event_command(122, 0, [44, 44, 0, 0, 4]),
      event_command(123, 0, ["A", 0]),
      event_command(0, 0, [])
    ])
    intro_page.instance_variable_set(:@list, intro)

    done_page = page_from_template(controller, [], trigger: 0, priority: 0,
                                   self_switch: "A")
    controller.instance_variable_set(:@pages, [intro_page, done_page])

    resume = [
      event_command(121, 0, [48, 48, 1]),
      event_command(121, 0, [47, 47, 1]),
      event_command(355, 0, ["hq=$game_map.events[2]; hq.moveto($game_player.x,$game_player.y)"]),
      event_command(655, 0, ["hq.transparent=false; $game_player.transparent=true"]),
      event_command(655, 0, ["hq.instance_variable_set(:@through,false)"]),
      event_command(122, 0, [40, 40, 0, 0, 2]),
      event_command(117, 0, [2])
    ]
    suffix = original[split_at..-1].reject { |command| command_code(command) == 0 }
    resume.concat(suffix)
    resume << event_command(0, 0, [])
    resume_page = page_from_template(controller, resume, trigger: 3, priority: 0,
                                     switch_id: 47)
    events[7] = event_from_pages(controller, 7, "SCN-MKT-PARTY-CONTINUE", 0, 0,
                                 [resume_page])

    (3..6).each do |event_id|
      event = events[event_id]
      pages = event.instance_variable_get(:@pages) || []
      pages.reject! do |page|
        condition = page.instance_variable_get(:@condition)
        condition && condition.instance_variable_get(:@switch1_valid) &&
          condition.instance_variable_get(:@switch1_id) == 48
      end
      choices = event_id == 5 ?
        ["Rủ chơi ném tuyết", "Bắt đầu bữa tiệc", "Thôi"] :
        ["Rủ chơi ném tuyết", "Thôi"]
      commands = [event_command(102, 0, [choices, choices.length - 1])]
      commands << event_command(402, 0, [0, choices[0]])
      commands << event_command(355, 1, ["WCF_SNOWBALL.start(#{event_id})"])
      if event_id == 5
        commands << event_command(402, 0, [1, choices[1]])
        commands << event_command(121, 1, [48, 48, 1])
        commands << event_command(121, 1, [47, 47, 0])
        commands << event_command(402, 0, [2, choices[2]])
      else
        commands << event_command(402, 0, [1, choices[1]])
      end
      commands << event_command(404, 0, [])
      pages << page_from_template(event, commands, trigger: 0, priority: 1,
                                  switch_id: 48)
      event.instance_variable_set(:@pages, pages)
    end

    map.instance_variable_set(:@events, events)
    save_data("Data/Map038.rvdata2", map)

    system = load_data("Data/System.rvdata2")
    switches = system.instance_variable_get(:@switches) || []
    variables = system.instance_variable_get(:@variables) || []
    switches[47] = "MKT_PARTY_CONTINUE"
    switches[48] = "MKT_FREE_EXPLORE"
    variables[45] = "SNOWBALL_RESULT"
    system.instance_variable_set(:@switches, switches)
    system.instance_variable_set(:@variables, variables)
    save_data("Data/System.rvdata2", system)

    puts "CHRISTMAS_SNOWBALL|Map038 split|NPC=3,4,5,6|continue=Leo|switches=47,48|result_var=45"
  end

  def name_snowball_progress
    system = load_data("Data/System.rvdata2")
    switches = system.instance_variable_get(:@switches) || []
    variables = system.instance_variable_get(:@variables) || []
    switches[49] = "SNOWBALL_ALL_CLEAR"
    variables[46] = "SNOWBALL_WINS"
    system.instance_variable_set(:@switches, switches)
    system.instance_variable_set(:@variables, variables)
    save_data("Data/System.rvdata2", system)
    puts "SNOWBALL_PROGRESS|switch=49|variable=46"
  end

  # Reconcile the implemented Atlantis route with GAME_SCRIPT_AI_COMPACT_V2.
  # This deliberately changes dialogue/route wiring only; authored map art and
  # event positions outside the controller events are left untouched.
  def reconcile_atlantis_compact_v2
    map10 = load_data("Data/Map010.rvdata2")
    event10 = (map10.instance_variable_get(:@events) || {}).values.find do |event|
      (event.instance_variable_get(:@pages) || []).any? do |page|
        (page.instance_variable_get(:@list) || []).any? do |command|
          command_code(command) == 402 && command_parameters(command)[1] == "Xuống Atlantis"
        end
      end
    end
    raise "Map010 Atlantis choice missing" unless event10
    page10 = event10.instance_variable_get(:@pages).find do |page|
      (page.instance_variable_get(:@list) || []).any? do |command|
        command_code(command) == 402 && command_parameters(command)[1] == "Xuống Atlantis"
      end
    end
    list10 = page10.instance_variable_get(:@list)
    branch_start = list10.index do |command|
      command_code(command) == 402 && command_parameters(command)[1] == "Xuống Atlantis"
    end
    branch_end = ((branch_start + 1)...list10.length).find do |index|
      [402, 403, 404].include?(command_code(list10[index])) &&
        list10[index].instance_variable_get(:@indent).to_i == 0
    end
    raise "Map010 Atlantis branch end missing" unless branch_end
    exact_branch = [event_command(402, 0, [2, "Xuống Atlantis"])]
    exact_branch.concat(wrapped_message_commands([
      "Mua sách phép làm quà tặng giáng sinh là ý tưởng không tồi!!",
      "Lâu rồi mình cũng chưa ghé tiệm sách phép “ đó “ dưới Atlantis! Chắc là mình sẽ về nhà nghỉ ngơi một xíu rồi đi tiệm sách vậy!"
    ], width: 30, indent: 1))
    exact_branch << event_command(221, 1, [])
    exact_branch << event_command(201, 1, [0, 22, 4, 39, 8, 0])
    list10[branch_start...branch_end] = exact_branch
    page10.instance_variable_set(:@list, list10)
    save_data("Data/Map010.rvdata2", map10)

    # After the meal, travel to the descent station before reaching the shop.
    map22 = load_data("Data/Map022.rvdata2")
    event48 = (map22.instance_variable_get(:@events) || {})[48]
    raise "Map022 noodle event E048 missing" unless event48
    changed22 = 0
    (event48.instance_variable_get(:@pages) || []).each do |page|
      (page.instance_variable_get(:@list) || []).each do |command|
        next unless command_code(command) == 201
        params = command_parameters(command)
        if params[1] == 23
          params[1], params[2], params[3], params[4] = 21, 4, 4, 2
          changed22 += 1
        elsif params[1] == 21
          changed22 += 1
        end
      end
    end
    raise "Map022 meal transfer to Map023 missing" if changed22 == 0
    save_data("Data/Map022.rvdata2", map22)

    map23 = load_data("Data/Map023.rvdata2")
    events23 = map23.instance_variable_get(:@events) || {}
    book_specs = {
      36 => [
        [
          "Mình nhớ cuốn Ma Vương Cổ Đại nằm đâu đó ở kệ này…", "À, đây rồi!!",
          "Đây là quyển sách cũ rích không rõ nguồn gốc có nói về Ma Vương Atlantis.",
          "Đến cả tôi lúc đọc cuốn này còn bất ngờ mà!",
          "Nào giờ ở dưới Atlantis ai cũng tôn thờ thần Poseidon hết, tự dưng tòi đâu ra ông Ma Vương không ai biết mặt biết tên lại chả bất ngờ.",
          "Ban đầu tôi còn tưởng cuốn này là tiểu thuyết được viết bởi ai đó nhưng khi thử một số phép thuật được viết trong đây…",
          "Tôi chắc chắc cuốn này là sách siêu cổ đại!",
          "Đa phần số phép thuật mà tôi dùng hiện giờ đều học từ cuốn này mà ra.",
          "Mua cuốn này cho Hakase là chuẩn bài rồi đấy!!", "Vì Hakase từng là ma vương mà!",
          "Trong cuốn này cũng còn nhiều phép thuật tôi chưa sử dụng được, cá chắn Hakase đọc phát thông thạo ngay!",
          "Mua cuốn này cho Hakase chứ?"
        ], 1
      ],
      12 => [
        [
          "Đây rồi! Cuốn phép thuật dịch chuyển này!",
          "Nhớ có lần Shylvie từng hỏi tôi rằng phép thuật dịch chuyển ở Atlantis có gì khác với phép thuật dịch chuyển mà bà ấy từng học không.",
          "Đương nhiên là…Ờm…Tôi không biết?",
          "Thú thực là tôi không rành về các phép thuật hỗ trợ lắm, nói trắng ra là mù tịt.",
          "Nên là mua cuốn này cho Shylvie là chuẩn bài rồi!",
          "Tôi cũng tò mò xem liệu có sự khác biệt giữa các phép thuật dịch chuyển không."
        ], 2
      ]
    }
    book_specs.each do |event_id, spec|
      event = events23[event_id]
      raise "Map023 book event E#{event_id} missing" unless event
      page = event.instance_variable_get(:@pages).first
      commands = wrapped_message_commands(spec[0], width: 30)
      commands << event_command(102, 0, [["Có", "Không"], 0])
      commands << event_command(402, 0, [0, "Có"])
      commands.concat(wrapped_message_commands([
        event_id == 36 ? "Mua luôn!" : "Ok, mua luôn!"
      ], width: 30, indent: 1))
      commands << event_command(122, 1, [31, 31, 0, 0, spec[1]])
      commands << event_command(402, 0, [1, "Không"])
      commands.concat(wrapped_message_commands([
        event_id == 36 ? "Từ từ, để xem còn cuốn nào không." :
                         "Từ từ, để xem còn cuốn nào hay không?"
      ], width: 30, indent: 1))
      commands << event_command(404, 0, [])
      page.instance_variable_set(:@list, commands)
    end
    map23.instance_variable_set(:@events, events23)
    save_data("Data/Map023.rvdata2", map23)

    # Map021 is a silent transit map. Remove the old placeholder narration and
    # continue to the bookshop without inventing dialogue absent from V2.
    map21 = Marshal.load(Marshal.dump(load_data("Data/Map004.rvdata2")))
    map21.instance_variable_set(:@display_name, "Điểm xuống Atlantis")
    map21.instance_variable_set(:@note,
      "Atlantis descent transit; no dialogue outside GAME_SCRIPT_AI_COMPACT_V2")
    events21 = map21.instance_variable_get(:@events) || {}
    template21 = events21[1] || events21.values.compact.first
    raise "Map021 controller template missing" unless template21
    commands21 = [
      event_command(117, 0, [3]),
      event_command(121, 0, [31, 31, 0]),
      event_command(122, 0, [30, 30, 0, 0, 2]),
      event_command(201, 0, [0, 23, 15, 37, 8, 0]),
      event_command(123, 0, ["A", 0])
    ]
    page21a = page_from_template(template21, commands21, trigger: 3, priority: 0)
    page21b = page_from_template(template21, [], trigger: 0, priority: 0,
                                 self_switch: "A")
    controller21 = event_from_pages(template21, 1,
      "SCN-ATL-DESCENT-TRANSIT", 4, 4, [page21a, page21b])
    map21.instance_variable_set(:@events, {1 => controller21})
    save_data("Data/Map021.rvdata2", map21)

    puts "ATLANTIS_V2|Map010=B2827-B2828->Map022|Map022 meal->Map021|Map021 silent->Map023|Map023 books=B3706-B3715,B3751-B3764"
  end

  def audit_atlantis_v2_dialogue
    map_ids = [10, 21, 22, 23, 24, 25, 26, 28, 29, 34, 35, 36]
    runtime_lines = []
    map_ids.each do |map_id|
      map = load_data(format("Data/Map%03d.rvdata2", map_id))
      (map.instance_variable_get(:@events) || {}).each_value do |event|
        (event.instance_variable_get(:@pages) || []).each do |page|
          (page.instance_variable_get(:@list) || []).each do |command|
            runtime_lines << command_parameters(command)[0].to_s if [401, 405].include?(command_code(command))
          end
        end
      end
    end
    runtime_lines << File.read("Scripts/Cutscene Group Chat.rb", encoding: "UTF-8")
    normalize = lambda do |text|
      text.to_s.gsub(/\\bm\[\d+\]\s*/, " ").downcase
          .gsub(/[^\p{L}\p{N}]+/u, " ").strip
    end
    corpus = normalize.call(runtime_lines.join(" "))
    source = File.readlines("docs/kich ban/GAME_SCRIPT_AI_COMPACT_V2.md", encoding: "UTF-8")
    checked = 0
    missing = []
    source.each do |raw|
      match = raw.match(/^B(\d+):\s*(.+)$/)
      next unless match
      id = match[1].to_i
      next unless (2827..3026).include?(id) || (3187..3234).include?(id) ||
                  (3259..3330).include?(id) || (3402..3494).include?(id) ||
                  (3668..3909).include?(id)
      text = match[2].strip
      next if (text.start_with?("[") && text.end_with?("]")) ||
              (text.start_with?("(") && text.end_with?(")") && text !~ /^\(\s*\?+/)
      text = text.sub(/^\(\s*\?+\s*\)\s*/, "")
      text = text.sub(/^(?:\(\s*\d+\s*,\s*\d+\s*\)\s*(?:[-–,]\s*)?)+/, "")
      text = text.sub(/^\[[^\]]+\]\s*/, "")
      next if text =~ /^(Rượt đuổi|Ma Vương Cổ Đại|Phép thuật dịch chuyển)$/i
      next if text =~ /^(Tương tác|Lần \d+|Source:|Sources:)/i
      text = text.sub(/^(Hải Quỳ|Oni Onii|Leo|Kohi|Hakase|Shylvie):\s*/i, "")
      normalized = normalize.call(text.sub(/\s*\[\s*Q\d+\s*\]\s*$/, ""))
      next if normalized.length < 3
      checked += 1
      missing << [id, text] unless corpus.include?(normalized)
    end
    puts "ATLANTIS_DIALOGUE_AUDIT|checked=#{checked}|missing=#{missing.size}"
    missing.each { |id, text| puts "MISSING_B#{id}|#{text}" }
  end

  # Reconcile the playable coffee-machine -> Kohi slice with the compact V2
  # script, without changing the snowball free-play split or any transfer IDs.
  def reconcile_supermarket_christmas_v2
    thought = lambda { |text, indent = 0| wrapped_message_commands([text], width: 30, indent: indent) }
    pop = lambda { |anchor, text, indent = 0| wrapped_message_commands([text.sub(/^[-–]\s*/, "")], tag: "\\bm[#{anchor}] ", width: 24, indent: indent) }

    map19 = load_data("Data/Map019.rvdata2")
    coffee = map19.instance_variable_get(:@events)[33]
    list = coffee.instance_variable_get(:@pages).first.instance_variable_get(:@list)
    coffee_text = list.select { |c| command_code(c) == 401 }
                      .map { |c| command_parameters(c)[0].to_s }
                      .join(" ").gsub(/\s+/, " ")
    unless coffee_text.include?("Máy pha cà phê là món quà ổn áp")
      at = list.index { |c| command_code(c) == 402 && command_parameters(c)[0] == 0 }
      raise "Map019 coffee choice branch missing" unless at
      exact = [
        "Máy pha cà phê là món quà ổn áp ấy chứ nhỉ? Vì cả văn phòng Wanderer ai cũng thích uống cà phê hết. Thành ra là bây giờ tôi không biết nên tặng cho ai.",
        "Tặng cho Kohi là điều đầu tiên mà tôi nghĩ tới vì Kohi là Quỷ cà phê, không những thế bà ấy thực sự nghiện uống cà phê.",
        "Tiếp đến là Shylvie, Shylvie lắm hôm cũng hay thức khuya nên tần suất uống cà phê cũng nhiều.",
        "Kế đến là Leo và Hakase, tuy hai người này uống cà phê ít hơn hai người kia nhưng mà mỗi lần họ uống thì toàn uống một lít.",
        "Sao càng nói càng thấy văn phòng này đang có vấn đề với cà phê vậy nhỉ?",
        "Đương nhiên là phải loại trừ tôi ra rồi.", "Vì tôi uống sữa nhiều hơn cà phê, haha.",
        "Quả đúng là con nít! Tự hào quá đi!", "Tôi tí ta tí tởn đi đến khu vực mua máy pha cà phê."
      ].flat_map { |s| thought.call(s, 1) }
      list.insert(at + 1, *exact)
    end
    save_data("Data/Map019.rvdata2", map19)

    map37 = load_data("Data/Map037.rvdata2")
    controller = map37.instance_variable_get(:@events)[1]
    old = controller.instance_variable_get(:@pages).first.instance_variable_get(:@list)
    cut = old.index { |c| command_code(c) == 117 && command_parameters(c)[0] == 18 }
    raise "Map037 wake camera marker missing" unless cut
    wake = []
    wake.concat(thought.call("Dậy coi con âm binh!!"))
    [
      "Tôi được gọi là Aira, là nửa còn lại của Dahria. Hiện tại, Dahria đang chìm trong vô thức, hai mắt thì trắng dã còn tôi đang cố đánh thức nó dậy bằng cách quật xúc tu vào mặt nó.",
      "Quật mãi, hai má Dahria đỏ bừng lên mà nó vẫn không tỉnh. Kiểu này dám cá nó lạc sâu tận trong vô thức sau mấy ngày không ngủ vì cứ bận suy nghĩ đau đáu về chuyện nó có phải là kẻ tồi tệ hay không.",
      "Chết thật. Hôm nay là ngày diễn ra bữa tiệc giáng sinh cùng với mấy đứa dở hơi trong cái văn phòng Wanderer gì đó.",
      "Nếu mà nó không tỉnh ngay bây giờ thì kiểu gì cũng sẽ đến trễ và không trang trí văn phòng được mất!",
      "Tôi đành chiếm quyền kiểm soát cơ thể của Dahria, lọ mọ đứng dậy, lảo đảo bước vào nhà vệ sinh.",
      "Dahria, nửa bên kia của tôi, luôn là một đứa lạc quan một cách quá đà kể từ lúc hai đứa tôi chào đời.",
      "Về việc lý do tại sao tôi lại mắc kẹt trong cơ thể này cùng với nó, đó là một câu chuyện siêu dài dòng mà tôi không muốn kể lại.",
      "Nhưng nếu ai đó đòi tóm tắt thì tôi sẽ tóm tắt như thế này.",
      "Tôi và nó tuy hai mà một, tuy một mà hai. Tôi là đóm lửa tàn cuối cùng còn sót lại để giữ sinh mạng cho nó, là sinh mạng vốn dĩ sinh ra để thay thế cho mục đích cao cả. Chỉ có thế thôi.",
      "Nghe lằng nhà lằng nhằng nhỉ? Ừ, đến tôi còn nhức đầu mà.",
      "Tôi có thể chiếm quyền kiểm soát cơ thể của Dahria nhưng đa phần tôi sẽ tự tạo một chiếc miệng đằng sau gáy để nói chuyện và biến tóc thành xúc tu để tương tác cùng lúc với nó.",
      "Tại vì tôi cảm thấy bị phiền phức.",
      "Tôi luôn càu nhàu với Dahria rằng tôi không muốn nó nhờ vả tôi. Nhưng nếu không có tôi thì nó chả làm được cái giống ôn gì hết. Bực hết cả mình.",
      "Như lúc này chả hạn. Mắc cái giống gì tự đánh giá bản thân xong tự chìm trong mặc cảm luôn vậy?",
      "Haha, hài hước các thứ….cái cù lôi! Giờ ai là người phải giải quyết hậu quả dùm đây hả?!"
    ].each { |s| wake.concat(thought.call(s)) }
    wake.concat(thought.call("Bộ quái gì đây?")); wake << event_command(225, 0, [3, 5, 20, false])
    wake.concat(thought.call("Không phải bộ này….")); wake.concat(thought.call("Bộ này xấu ói!"))
    wake.concat(thought.call("Chậc!! Sau vụ này mà không cho ta ăn cacao dầm là ta ném ngươi ra ngoài biển cho chết đuối đấy!"))
    wake.concat([event_command(355, 0, ["$game_map.events[3].set_graphic(\"!$HaiQuy_GiangSinh\",0)"]),
                 event_command(122, 0, [44, 44, 0, 0, 3]), event_command(221, 0, []),
                 event_command(230, 0, [30]), event_command(201, 0, [0, 38, 22, 34, 8, 0]), event_command(0, 0, [])])
    controller.instance_variable_get(:@pages).first.instance_variable_set(:@list,
      old[0..cut] + [event_command(222, 0, [])] + wake)
    save_data("Data/Map037.rvdata2", map37)

    map38 = load_data("Data/Map038.rvdata2")
    events = map38.instance_variable_get(:@events)
    registry = {}
    File.foreach("docs/kich ban/GAME_SCRIPT_AI_COMPACT_V2.md", encoding: "UTF-8") do |line|
      registry[$1.to_i] = $2.strip if line =~ /^B(\d{4}):\s*(.*)$/
    end
    pre_page = events[1].instance_variable_get(:@pages).first
    pre_old = pre_page.instance_variable_get(:@list)
    pre_first = pre_old.index { |c| command_code(c) == 101 }
    pre_tail = pre_old.index { |c| command_code(c) == 117 && command_parameters(c)[0] == 1 }
    raise "Map038 free-play split markers missing" unless pre_first && pre_tail
    speaker = {250 => 3, 252 => 2, 254 => 4, 257 => 4, 259 => 2,
               263 => 2, 264 => 4, 268 => 5, 276 => 5, 278 => 2,
               279 => 5, 280 => 2, 281 => 5, 282 => 2, 283 => 5, 284 => 2}
    prelude = []
    (232..288).each do |id|
      text = registry[id].to_s
      next if text.empty? || text =~ /^(?:CẢNH|Hết cảnh)/i || text.start_with?("[")
      if speaker[id]
        prelude.concat(pop.call(speaker[id], text))
      else
        prelude.concat(thought.call(text))
      end
    end
    # Setup/fade remains editor-authored; all prose between it and the
    # snowball free-play switch now comes verbatim from B0232..B0288.
    pre_page.instance_variable_set(:@list, pre_old[0...pre_first] + prelude + pre_old[pre_tail..-1])

    page = events[7].instance_variable_get(:@pages).first
    cont = page.instance_variable_get(:@list)
    first_text = cont.index { |c| command_code(c) == 101 }
    gift_text = cont.each_index.find { |i| command_code(cont[i]) == 401 && command_parameters(cont[i])[0].to_s.include?("sự kiện chính") }
    gift = gift_text && gift_text.downto(0).find { |i| command_code(cont[i]) == 101 }
    raise "Map038 continuation markers missing" unless first_text && gift
    meal = []
    meal.concat(thought.call("Mùi thơm quá…Tôi muốn ăn sạch cái đĩa bánh socola tan chảy kia!")); meal.concat(pop.call(2, "Mời mọi người cùng ăn!"))
    [
      "Ôi ngon quá trời. Tôi vốn không thích món bò hầm kem nên ăn một bát rồi ngưng, chuyển sang ăn ngấu nghiến gần hết đĩa bánh socola tan chảy trên bàn.",
      "Bữa ăn diễn ra vui vẻ, mọi người kể cho nhau nghe đủ chuyện từ trên trời xuống đất.",
      "Leo chia sẻ cho mọi người công việc của vệ thần không gian, Hakase thì kể về việc ông ấy bắt được Pokemon hiếm.",
      "Kohi càm ràm về một bộ anime tình yêu học đường, Shylvie vẫn chưa tha cho món phá lấu mà Leo đã dẫn Shylvie ăn vào hai năm trước.",
      "Tôi không biết phải kể mọi người nghe chuyện gì. Tôi chả rõ chuyện về mấy đứa ở Văn phòng Silver Wing lẫn Phòng Tác Chiến Nguyệt Thực 6 cho lắm. Kể về nhiệm vụ thì phiền phức quá.",
      "Có lẽ vì trông thấy tôi chưa có chủ đề để kể, Shylvie đã chủ động hỏi tôi về bộ giáp."
    ].each { |s| meal.concat(thought.call(s)) }
    meal.concat(pop.call(3, "Bộ giáp sao rồi?")); meal.concat(pop.call(2, "Nó vẫn đang được sửa chữa và hoàn thiện.")); meal.concat(pop.call(3, "Lâu vậy á?"))
    meal.concat(pop.call(2, "Tuổi đời bộ giáp đó có khi còn hơn tuổi của tui, nên việc sửa chữa nó sẽ lâu lắm.")); meal.concat(pop.call(5, "Khoan, vụ này mới. Sao bà lại sử dụng bộ giáp cổ vậy?"))
    meal.concat(pop.call(2, "Nó là bộ giáp được truyền lại cho người xứng đáng trong dòng họ Anizoa Drosalie Hexacoral. Và tui được nó chọn.")); meal.concat(thought.call("Bốn người họ đồng thanh “ồ” lên một tiếng dài ơi là dài."))
    meal.concat(pop.call(6, "Nhí nhí, tui có câu hỏi.")); meal.concat(pop.call(5, "Hakase à….Đừng…Tui biết ông tính hỏi gì…")); meal.concat(pop.call(6, "Hả…Sao ông biết là tui đang hỏi về tuổi…."))
    meal.concat(thought.call("Hakase chưa kịp nói xong thì đã bị Leo bịt miệng bằng miếng thịt bò nóng hổi.")); meal.concat(pop.call(2, "Gì vậy Hakase. Kỳ quá nha. Tui mười bốn tuổi mà."))
    ["Dahria đâu phải cô bé mười bốn tuổi? Tôi chắc chắn như vậy.", "Tôi không thể xác định được độ tuổi chính xác của nó là bao nhiêu nữa.", "Vì thông tin đó đã bị Dahria xóa khỏi đầu rồi.",
     "Sau khi ăn uống no say, cả đám bọn tôi quyết định chơi vài ván mèo nổ với vài ván rút tháp. Leo với Hakase liên tục bị “kaboom”.",
     "Dù đã chơi board game với Kohi vài lần rồi nhưng lần nào tôi cũng bị sự may mắn của bà ấy làm cho bất ngờ. Nãy giờ chưa thấy bà ấy bị “kaboom” lần nào!",
     "Tuy nhiên đến với trò rút tháp, sự may mắn của Kohi cũng không thể cứu nổi tòa tháp đang sập xuống trước mắt bà ấy.",
     "Để gia tăng sự khó chịu cho trò này, Leo đã chuẩn bị một túi kẹo siêu chua, hễ ai làm tháp bị sập sẽ phải ăn một lúc hai viên kẹo đấy.",
     "Tôi gần như ăn sạch túi kẹo chua mà Leo mua. Nó không chua như tôi tưởng tượng."].each { |s| meal.concat(thought.call(s)) }
    page.instance_variable_set(:@list, cont[0...first_text] + meal + cont[gift..-1])
    cont = page.instance_variable_get(:@list)
    bet_start_text = cont.each_index.find { |i| command_code(cont[i]) == 401 && command_parameters(cont[i])[0].to_s.include?("Đấy thấy chưa Kohi") }
    phone_text = cont.each_index.find { |i| command_code(cont[i]) == 401 && command_parameters(cont[i])[0].to_s.include?("Đột nhiên điện thoại") }
    if bet_start_text && phone_text
      bet_start = bet_start_text.downto(0).find { |i| command_code(cont[i]) == 101 }
      phone_start = phone_text.downto(0).find { |i| command_code(cont[i]) == 101 }
      kohi = []
      [[3, "Đấy thấy chưa Kohi, tôi đã nói là bà ấy nhìn thấy trước tương lai rồi mà."],
       [2, "Hả? Vụ gì đấy?"],
       [4, "À, tuần trước tui với Shylvie có cược với nhau rằng bà sẽ mua máy pha cà phê tặng tui ấy mà."],
       [2, "À…Thế là mấy người đem tui ra để cá cược với nhau hả??"],
       [4, "Không không, không hẳn là thế! Tui muốn kiểm chứng vụ đấy thôi!!"],
       [2, "Vụ…tui nhìn thấy trước tương lai?"],
       [4, "Ừm hứm! Shylvie thậm chí còn bảo rằng bà có thể tác động cả thực tại cơ."],
       [3, "Ừ, chuyện là vậy đó."], [4, "Mà bỏ qua vụ đó đi! Quan trọng là…."],
       [2, "À…Thế thì không một ai thắng cược hết!"], [4, "HẢ? Tại sao?"],
       [2, "Tại vì ngoài máy pha cà phê ra tui còn tặng cả cà phê Atlantis cơ!"],
       [4, "Ồ! Tui có nghe về nó rồi!! Là loại cà phê hiếm có khó tìm, được trồng trên các tảng san hô núi lửa ở rãnh Marianna không?"],
       [2, "Đúng đúng! Nhưng còn điều này bà chưa biết…! Để cho ra được cà phê Atlantis, bắt buộc phải có sự tiêu hóa của tôm tích núi lửa nữa!"],
       [4, "Là sao á?"], [2, "Là tôm tích núi lửa phải ăn! Nó giống cà phê chồn ấy!"], [4, "Ồ!! Ra là vậy!!"]].each { |anchor, text| kohi.concat(pop.call(anchor, text)) }
      ["Nó gần giống cà phê chồn. Ngoại trừ việc một số con tôm sau khi ăn cà phê sẽ bị nổ banh xác.",
       "Vì cà phê Atlantis đa phần là các loại có độc tính mạnh, để xác định được chỗ cà phê nào uống được thì phải quan sát tôm núi lửa.",
       "Chỗ trồng cà phê nào mà có nhiều xác tôm núi lửa banh xác thì chỗ cà phê đó không uống được.",
       "Ngược lại, chỗ nào mà bọn tôm núi lửa ăn xong mà phát ra màu ánh kim, chỗ cà phê đó không những uống được mà còn là loại ngon nhất nữa!",
       "Mặc dù đã tìm cách để nhân giống loại trừ các loại có độc tính mạnh nhưng độc tính của cà phê Atlantis vẫn không giảm."].each { |s| kohi.concat(thought.call(s)) }
      kohi.concat(pop.call(4, "Cảm ơn bà nhiều nhiều lắm Quỳ! Món quà tuyệt vời ông mặt trời!"))
      kohi.concat(thought.call("Kohi cất chiếc máy pha cà phê vào trong bếp. Cô ấy lấy từ trong túi xách của mình một chiếc hộp thiếc bóng loáng có vài đường vân được dát vàng sáng bóng cho bọn tôi chiêm ngưỡng rồi dúi nó vào tay Leo."))
      kohi.concat(thought.call("Kohi nhào đến ôm tôi. Tôi vòng tay ra sau lưng Kohi, ôm cô ấy thật chặt. Mùi của Kohi thơm thật đấy, thơm đến mức đánh bay cả sự lo âu của tôi."))
      page.instance_variable_set(:@list, cont[0...bet_start] + kohi + cont[phone_start..-1])
    end
    save_data("Data/Map038.rvdata2", map38)
    puts "SUPERMARKET_V2|Map019 coffee reaction|Map037 Aira wake|Map038 meal/armor/boardgame restored"
  end

  def organize_route_map_tree
    infos = load_data("Data/MapInfos.rvdata2")
    {37 => 19, 38 => 19, 39 => 19, 22 => 21, 23 => 21, 28 => 21,
     26 => 22, 24 => 26, 34 => 28, 29 => 28, 25 => 28, 35 => 28}.each do |id, parent|
      infos[id].instance_variable_set(:@parent_id, parent) if infos[id]
    end
    [19, 21, 22, 26, 28].each { |id| infos[id].instance_variable_set(:@expanded, true) if infos[id] }
    infos[36].instance_variable_set(:@parent_id, 0) if infos[36]
    save_data("Data/MapInfos.rvdata2", infos)
    puts "MAP_TREE|supermarket=19>[37,38,39]|atlantis=21>[22>26>24,23,28>[34,29,25,35]]|ending=36(root)"
  end

  # Coffee-machine branch: after checkout, Hải Quỳ returns to Atlantis for
  # coffee, then chooses regular coffee or the shrimp-fishing challenge.
  # Map040 is deliberately a black-screen story template so its final art can
  # be supplied later without changing the route/state contract.
  def create_coffee_atlantis_fishing_template
    map_id = 40
    map_path = "Data/Map%03d.rvdata2" % map_id
    map19_path = "Data/Map019.rvdata2"
    infos_path = "Data/MapInfos.rvdata2"

    base_map = Marshal.load(Marshal.dump(load_data("Data/Map007.rvdata2")))
    template_map = load_data(map19_path)
    template_event = (template_map.instance_variable_get(:@events) || {})[42]
    raise "Map019 E042 is missing" unless template_event

    message = lambda do |text, face = nil, face_index = 1, indent = 0|
      commands = wrapped_message_commands([text], width: 30, indent: indent)
      commands.each do |command|
        next unless command_code(command) == 101
        command.instance_variable_set(:@parameters,
          [face || "", face ? face_index : 0, 0, 2])
      end
      commands
    end
    hq = lambda { |text, face_index = 1, indent = 0| message.call(text, "HaiQuy_Thuongphuc_Emote", face_index, indent) }
    npc = lambda { |text, indent = 0| message.call(text, nil, 0, indent) }

    commands = [
      event_command(355, 0, ["$game_player.transparent=true"]),
      # Use RPG Maker's native Fadeout Screen command.  Script-level calls to
      # Game_Interpreter#screen previously became nil in several transferred
      # cutscenes, so route builders must not reintroduce that legacy form.
      event_command(221, 0, []),
      event_command(121, 0, [52, 52, 1]),
      event_command(230, 0, [2])
    ]
    commands.concat(hq.call("Chiếc máy pha cà phê thôi vẫn chưa đủ. Đã tặng thì phải kèm loại cà phê ngon nhất."))
    commands.concat(hq.call("Tôi lại xuống Atlantis để lấy số cà phê Momo gửi ở quán quen."))
    commands.concat(npc.call("THÔNG BÁO KHẨN: Một Quái Vật Vực Sâu xuất hiện gần khu hành chính đã bị khống chế."))
    commands.concat(npc.call("Mái nhà thị chính bị hư hại trong quá trình xử lý. Người dân vui lòng tránh khu vực sửa chữa."))
    commands.concat(hq.call("Quái vật đã bị khống chế mà mái nhà thị chính vẫn hỏng à? Atlantis đúng là yên bình theo cách rất riêng.", 3))
    commands.concat(npc.call("Xin lỗi cô bé, cà phê Atlantis hôm nay hết sạch rồi."))
    commands.concat(hq.call("Hết sạch? Cháu vừa đi một quãng đường dài xuống đây đó!", 3))
    commands.concat(npc.call("Quán vẫn còn cà phê thường. Cháu có thể lấy loại đó, hoặc tự câu tôm để kiếm cà phê Atlantis."))
    commands << event_command(102, 0, [["Dùng cà phê thường", "Đi câu tôm"], 1])
    commands << event_command(402, 0, [0, "Dùng cà phê thường"])
    commands.concat(hq.call("Cà phê thường cũng được. Quan trọng là có cà phê để thử chiếc máy mới.", 1, 1))
    commands.concat([
      event_command(123, 1, ["A", 0]),
      event_command(201, 1, [0, 37, 10, 9, 2, 2]),
      event_command(402, 0, [1, "Đi câu tôm"])
    ])
    commands.concat(npc.call("Trong kho chỉ còn hạt cà phê thô. Muốn dùng được, cháu phải mang chúng ra hồ làm mồi câu.", 1))
    commands.concat(npc.call("Nếu tôm ăn hạt cà phê, chúng sẽ đổi màu. Chỉ kéo lên khi tôm vừa chuyển sang màu vàng.", 1))
    commands.concat(npc.call("Kéo sớm lúc tôm còn đen, nó sẽ vùng xuống hồ. Chậm tới lúc chuyển đỏ thì nó sẽ phát nổ.", 1))
    commands.concat(npc.call("Cá khác ăn hạt cà phê cũng sẽ phát nổ. Cháu cần câu đủ mười con tôm vàng.", 1))
    commands.concat(hq.call("Hiểu rồi. Muốn lấy cà phê thì phải đi câu tôm, còn phải canh cho chúng đừng nổ.", 1, 1))
    commands.concat(hq.call("Atlantis chưa bao giờ bán thứ gì theo cách bình thường hết!", 3, 1))
    commands << event_command(118, 1, ["ATLANTIS_SHRIMP_RETRY"])
    commands << event_command(355, 1, ["atlantis_shrimp_fishing"])
    commands << event_command(111, 1, [12, "atlantis_shrimp_result >= 10"])
    commands.concat(npc.call("Đủ mười phần rồi. Số cà phê này vừa đủ để tặng kèm chiếc máy.", 2))
    commands.concat(hq.call("Tốt! Giờ thì món quà mới hoàn chỉnh.", 2, 2))
    commands.concat([
      event_command(121, 2, [52, 52, 0]),
      event_command(123, 2, ["A", 0]),
      event_command(201, 2, [0, 37, 10, 9, 2, 2]),
      event_command(411, 1, [])
    ])
    commands.concat(hq.call("Chưa đủ mười con tôm vàng. Không thể mang từng này về làm quà được.", 5, 2))
    commands.concat([event_command(119, 2, ["ATLANTIS_SHRIMP_RETRY"]),
                     event_command(412, 1, []), event_command(404, 0, [])])

    main_page = page_from_template(template_event, commands, trigger: 3, priority: 0)
    done_page = page_from_template(template_event, [], trigger: 0, priority: 0, self_switch: "A")
    event = event_from_pages(template_event, 1,
      "SCN-MKT-ATLANTIS-COFFEE-FISHING", 0, 0, [main_page, done_page])
    base_map.instance_variable_set(:@display_name, "Atlantis — Quán cà phê")
    base_map.instance_variable_set(:@note,
      "Coffee-route black-screen template; regular/fishing choice; Switch 52")
    base_map.instance_variable_set(:@autoplay_bgm, false)
    base_map.instance_variable_set(:@autoplay_bgs, false)
    base_map.instance_variable_set(:@encounter_list, [])
    base_map.instance_variable_set(:@events, {1 => event})
    save_data(map_path, base_map)

    # Route only the coffee-machine gift through Map040. Other gifts keep the
    # existing direct handoff to Map037.
    map19 = load_data(map19_path)
    checkout = map19.instance_variable_get(:@events)[42]
    checkout_page = checkout.instance_variable_get(:@pages).first
    checkout_list = checkout_page.instance_variable_get(:@list)
    unless checkout_list.any? { |c| command_code(c) == 201 && command_parameters(c)[1] == map_id }
      transfer_index = checkout_list.rindex do |c|
        command_code(c) == 201 && command_parameters(c)[1] == 37
      end
      raise "Map019 E042 final Map037 transfer missing" unless transfer_index
      indent = checkout_list[transfer_index].instance_variable_get(:@indent)
      replacement = [
        event_command(111, indent, [1, 42, 0, 1, 0]),
        event_command(201, indent + 1, [0, map_id, 8, 6, 2, 2]),
        event_command(411, indent, []),
        event_command(201, indent + 1, [0, 37, 10, 9, 2, 2]),
        event_command(412, indent, [])
      ]
      checkout_list[transfer_index, 1] = replacement
      save_data(map19_path, map19)
    end

    # Gift and epilogue variants are authored in the compact route. They are
    # rebuilt by complete_coffee_route_branches; never invent fallback lines.

    infos = load_data(infos_path)
    info = infos[map_id] || Marshal.load(Marshal.dump(infos[37] || infos.values.compact.first))
    info.instance_variable_set(:@name, "Atlantis — Lấy cà phê")
    info.instance_variable_set(:@parent_id, 19)
    info.instance_variable_set(:@order,
      infos.values.compact.map { |entry| entry.instance_variable_get(:@order).to_i }.max + 1) unless infos[map_id]
    info.instance_variable_set(:@expanded, true)
    infos[map_id] = info
    save_data(infos_path, infos)

    system = load_data("Data/System.rvdata2")
    switches = system.instance_variable_get(:@switches)
    switches[52] = "MKT_COFFEE_READY"
    save_data("Data/System.rvdata2", system)

    apply_authored_coffee_source_variants
    puts "COFFEE_ATLANTIS_TEMPLATE|Map019 E042 -> Map040 -> regular_or_fishing -> Map037|switch=52|target=10"
  end

  # Apply the two authored coffee-source variants from the expanded MAIN
  # sequence of GAME_SCRIPT_AI_COMPACT_V2. Switch 52 temporarily replaces the
  # original "checked Momo's message" condition:
  #   ON  = caught ten golden shrimp / has Atlantis coffee
  #   OFF = chose the route without Atlantis coffee
  def apply_authored_coffee_source_variants
    thought = lambda { |text, indent = 0| wrapped_message_commands([text], width: 30, indent: indent) }
    pop = lambda { |anchor, text, indent = 0| wrapped_message_commands([text.sub(/^[-–]\s*/, "")], tag: "\\bm[#{anchor}] ", width: 24, indent: indent) }
    face_message = lambda do |face, face_index, text, indent = 0|
      result = wrapped_message_commands([text], width: 30, indent: indent)
      result.each do |command|
        next unless command_code(command) == 101
        command.instance_variable_set(:@parameters, [face, face_index, 0, 2])
      end
      result
    end
    nest = lambda do |commands, amount|
      commands.each do |command|
        command.instance_variable_set(:@indent,
          command.instance_variable_get(:@indent).to_i + amount)
      end
      commands
    end
    switch_branch = lambda do |on_commands, off_commands|
      [event_command(111, 0, [0, 52, 0])] + nest.call(on_commands, 1) +
        [event_command(411, 0, [])] + nest.call(off_commands, 1) +
        [event_command(412, 0, [])]
    end
    variable_branch = lambda do |value, commands|
      [event_command(111, 0, [1, 43, 0, value, 0])] + nest.call(commands, 1) +
        [event_command(412, 0, [])]
    end

    # Map040: place the exact Q1/Q2 version after the temporary player choice.
    map40_path = "Data/Map040.rvdata2"
    if File.exist?(map40_path)
      map40 = load_data(map40_path)
      event40 = (map40.instance_variable_get(:@events) || {})[1]
      raise "Map040 coffee event missing" unless event40
      list40 = event40.instance_variable_get(:@pages).first.instance_variable_get(:@list)
      hq = lambda { |text, indent| face_message.call("HaiQuy_Thuongphuc_Emote", 1, text, indent) }
      bully = lambda { |text, indent| face_message.call("BullyQuy_Thuongphuc_Emote", 1, text, indent) }
      scene5 = lambda do |atlantis, indent|
        variants = if atlantis
          {
            1 => [[:b, "Nè con nhãi kia, nay dư giả quá ha, mua hẳn máy pha cà phê làm quà!"], [:h, "Chứ sao nữa! Quỹ đen tích góp bấy lâu nay mà lị!"], [:b, "Vậy thì mua máy nào tốt tốt một chút, loại mà pha được cả cà phê Atlantis ấy."], [:h, "Ừa, tui cũng đang tính tặng kèm cả cà phê Atlantis cho Leo luôn!"], [:b, "Ờm, ta không nghĩ đó là ý hay…"], [:h, "Cà phê Atlantis uống ngon bỏ xừ! Leo chắc chắn sẽ thích nó thôi!"]],
            2 => [[:b, "Nè con nhãi kia, nay dư giả quá ha, mua hẳn máy pha cà phê làm quà!"], [:h, "Chứ sao nữa! Kohi siêu siêu thích cà phê luôn mà! Đây là món quà quá phù hợp luôn!"], [:b, "Vậy thì mua máy nào tốt tốt một chút, loại mà pha được cả cà phê Atlantis ấy."], [:h, "Ồ, sao biết tui đang tính tặng Kohi cà phê Atlantis vậy?"], [:b, "Ờm, ta không nghĩ đó là ý hay…"], [:h, "Cà phê Atlantis uống ngon bỏ xừ! Kohi chắc chắn sẽ thích nó thôi!"]],
            3 => [[:b, "Bực mình vậy mà còn chuẩn bị quà tặng nó à?"], [:h, "Lời đã nói ra sao mà rút được"], [:b, "À, vậy thì nhớ tặng kèm cà phê Atlantis cho nó đi."], [:h, "Nhớ rồi."]],
            4 => [[:b, "Ngươi tính tặng máy pha cà phê cho tên ma vương đáng gờm đó à?"], [:h, "Ừ đúng rồi, sao thế?"], [:b, "Ta không hiểu. Thay vì tặng hắn một quyển sách ma thuật thì ngươi tặng hắn một chiếc máy pha cà phê à? Để làm gì?"], [:h, "Có mấy hôm khuya khoắt vô tình tạt ngang qua nhà ổng thì thấy ổng đang luyện tập bắn tia năng lượng hăng say lắm. Mà trời dạo này trở lạnh, dễ buồn ngủ nữa. Mua cho ổng máy pha cà phê để ổng uống cho đỡ buồn ngủ chứ sao!"], [:b, "Chịu. Không hiểu gì hết. À đúng rồi, nhớ tặng kèm cà phê Atlantis đấy."], [:h, "Ừa, biết rồi mà!"]]
          }
        else
          {
            1 => [[:b, "Nè con nhãi kia, nay dư giả quá ha, mua hẳn máy pha cà phê làm quà!"], [:h, "Chứ sao nữa! Quỹ đen tích góp bấy lâu nay mà lị!"], [:b, "Mà Leo hắn uống cà phê à? Ta tưởng hắn thích uống sting hơn chứ? Có khi ngươi nên mua máy làm kem đá bào cho hắn thì hợp lý hơn."], [:h, "Ai bảo Leo không uống cà phê! Mỗi lần Leo uống là uống cả cái ca một lít đó! Leo còn buồn vì cà phê ở đây không giống vị ở Luminus nên đang tìm máy phù hợp để pha cà phê quê nhà ổng kìa."], [:b, "Ghê vậy sao?"], [:h, "Ghê chứ sao!"]],
            2 => [[:b, "Nè con nhãi kia, nay dư giả quá ha, mua hẳn máy pha cà phê làm quà!"], [:h, "Chứ sao nữa! Kohi siêu siêu thích cà phê luôn mà! Đây là món quà quá phù hợp luôn"], [:b, "À ừ suýt thì quên mất. Phải rồi ha, bả là Quỷ cà phê mà."], [:h, "Tiếc là bọn mình không tặng được cho bà ấy cà phê Atlantis ha! Cà phê Atlantis ngon bỏ xừ luôn!"], [:b, "Tiếc ghê ha!"], [:h, "Tiếc chứ sao!"]],
            3 => [[:b, "Bực mình vậy mà còn chuẩn bị quà tặng nó à?"], [:h, "Lời đã nói ra sao mà rút được"], [:b, "À, hóa ra ngươi là người tốt, phải rồi ha."], [:h, "Ôi thôi đừng chọc, quạo á."]],
            4 => [[:b, "Ngươi tính tặng máy pha cà phê cho tên ma vương đáng gờm đó à?"], [:h, "Ừ đúng rồi, sao thế?"], [:b, "Ta không hiểu. Thay vì tặng hắn một quyển sách ma thuật thì ngươi tặng hắn một chiếc máy pha cà phê à? Để làm gì?"], [:h, "Có mấy hôm khuya khoắt vô tình tạt ngang qua nhà ổng thì thấy ổng đang luyện tập bắn tia năng lượng hăng say lắm. Mà trời dạo này trở lạnh, dễ buồn ngủ nữa. Mua cho ổng máy pha cà phê để ổng uống cho đỡ buồn ngủ chứ sao!"], [:b, "Có chắc là ổng uống cà phê không vậy…"]]
          }
        end
        variants.flat_map do |value, lines|
          body = lines.flat_map { |speaker, text| speaker == :b ? bully.call(text, indent + 1) : hq.call(text, indent + 1) }
          [event_command(111, indent, [1, 43, 0, value, 0])] + body +
            [event_command(412, indent, [])]
        end
      end

      regular = list40.index { |c| command_code(c) == 402 && command_parameters(c)[0] == 0 }
      fishing = list40.index { |c| command_code(c) == 402 && command_parameters(c)[0] == 1 }
      raise "Map040 coffee choices missing" unless regular && fishing
      regular_body = scene5.call(false, 1) + [event_command(123, 1, ["A", 0]), event_command(201, 1, [0, 37, 10, 9, 2, 2])]
      list40[(regular + 1)...fishing] = regular_body

      marker = list40.index { |c| command_code(c) == 355 && command_parameters(c)[0] == "# AUTHORED_COFFEE_SCENE5_ATLANTIS" }
      switch_on = list40.index { |c| command_code(c) == 121 && command_parameters(c) == [52, 52, 0] }
      raise "Map040 Atlantis success switch missing" unless switch_on
      list40[marker...switch_on] = [] if marker
      switch_on = list40.index { |c| command_code(c) == 121 && command_parameters(c) == [52, 52, 0] }
      list40.insert(switch_on, event_command(355, 2, ["# AUTHORED_COFFEE_SCENE5_ATLANTIS"]), *scene5.call(true, 2))
      save_data(map40_path, map40)
    end

    # Map038: rebuild the gift block with exact authored ON/OFF variants.
    map38 = load_data("Data/Map038.rvdata2")
    page38 = map38.instance_variable_get(:@events)[7].instance_variable_get(:@pages).first
    list38 = page38.instance_variable_get(:@list)
    gift_outer = list38.index do |command|
      command_code(command) == 111 &&
        command_parameters(command)[0, 4] == [1, 42, 0, 1]
    end
    raise "Map038 coffee outer branch missing" unless gift_outer
    gift_outer_indent = list38[gift_outer].instance_variable_get(:@indent).to_i
    gift_outer_end = ((gift_outer + 1)...list38.length).find do |index|
      command_code(list38[index]) == 412 &&
        list38[index].instance_variable_get(:@indent).to_i == gift_outer_indent
    end
    raise "Map038 coffee outer branch end missing" unless gift_outer_end

    intro = lambda { |recipient| pop.call(5, "E hèm! Tui nghĩ đã đến lúc cho sự kiện chính ngày hôm nay rồi, Quỳ nhỉ?") + thought.call("Leo đánh mắt sang tôi.") + thought.call("Tôi tính đứng lên để tặng chiếc máy pha cà phê cho #{recipient} thì chợt nhận ra tôi để quên nó ở nhà…") + thought.call("Haizz, đúng là không có tôi thì Dahria là một con mắm hay quên nhỉ.") + thought.call("Tôi cởi mũ len của mình xuống, thò tay vào nó trước bốn cặp mắt ngỡ ngàng. Tôi moi moi một lúc, cuối cùng cũng lôi được chiếc máy pha cà phê mà con nhỏ Dahria để quên ở nhà.") }
    gifts = {}
    gifts[1] = intro.call("Leo")
    [[2,"Giáng sinh an lành Leo! Tui hi vọng ông thích chiếc máy pha cà phê này!"],[5,"Uầy!! Bà dùng được phép dịch chuyển rồi hả?!"],[2,"Ngạc nhiên sai thứ rồi!! Ông phải ngạc nhiên vì chiếc máy pha cà phê này chứ!"],[5,"À ừ thì đương nhiên rồi! Cảm ơn bà nha!!!"]].each { |a,s| gifts[1].concat(pop.call(a,s)) }
    gifts[1].concat(thought.call("Leo nhận chiếc máy pha cà phê từ tay tôi rồi lon ton lon ton cất nó vào trong bếp. Tôi thấy Leo lấy điện thoại ra chụp tự sướng cùng chiếc máy pha cà phê. Tôi cá mười quả cam chút nữa ổng sẽ gửi cho người thương của ông ấy."))
    gifts[1].concat(pop.call(5,"Món quà tuyệt vời lắm Quỳ!!"))
    leo_atlantis=[]; [[2,"Phải như vậy chứ! Tui thậm chí còn tặng cho ông đặc sản quê tui, cà phê Atlantis siêu hảo hạng luôn!!"],[5,"Ồ!! Bà chu đáo quá! Cà phê siêu hảo hạng luôn!! Không biết mùi vị như thế nào nhỉ?!"],[4,"Leo!! Nó ngon lắm đó!! Hôm bữa tui uống ké của Quỳ rồi, ngon xĩu luôn!!"],[5,"Thiệt hả?!"]].each { |a,s| leo_atlantis.concat(pop.call(a,s)) }
    gifts[1].concat(switch_branch.call(leo_atlantis, []))

    # The compact preserves an obvious source copy-paste saying "tặng ... cho
    # Leo" inside KOHI CẢNH 9. Use the recipient named by the route branch.
    gifts[2] = intro.call("Kohi")
    [[2,"Giáng sinh vui vẻ nha Kohi!!"],[4,"MỘT CHIẾC MÁY PHA CÀ PHÊ?! UI!! THÍCH THẾ!!"],[2,"Hehe!! Bà thích là tui vui rồi!!"],[3,"Đấy thấy chưa Kohi, tôi đã nói là bà ấy nhìn thấy trước tương lai rồi mà."],[2,"Hả? Vụ gì đấy?"],[4,"À, tuần trước tui với Shylvie có cược với nhau rằng bà sẽ mua máy pha cà phê tặng tui ấy mà."],[2,"À…Thế là mấy người đem tui ra để cá cược với nhau hả??"],[4,"Không không, không hẳn là thế! Tui muốn kiểm chứng vụ đấy thôi!!"],[2,"Vụ…tui nhìn thấy trước tương lai?"],[4,"Ừm hứm! Shylvie thậm chí còn bảo rằng bà có thể tác động cả thực tại cơ."],[3,"Ừ, chuyện là vậy đó."],[4,"Mà bỏ qua vụ đó đi! Quan trọng là…."]].each { |a,s| gifts[2].concat(pop.call(a,s)) }
    hug = thought.call("Kohi nhào đến ôm tôi. Tôi vòng tay ra sau lưng Kohi, ôm cô ấy thật chặt. Mùi của Kohi thơm thật đấy, thơm đến mức đánh bay cả sự lo âu của tôi.")
    kohi_atlantis=[]; [[2,"À…Thế thì không một ai thắng cược hết!"],[4,"HẢ? Tại sao?"],[2,"Tại vì ngoài máy pha cà phê ra tui còn tặng cả cà phê Atlantis cơ!"],[4,"Ồ! Tui có nghe về nó rồi!! Là loại cà phê hiếm có khó tìm, được trồng trên các tảng san hô núi lửa ở rãnh Marianna không?"],[2,"Đúng đúng! Nhưng còn điều này bà chưa biết…! Để cho ra được cà phê Atlantis, bắt buộc phải có sự tiêu hóa của tôm tích núi lửa nữa!"],[4,"Là sao á?"],[2,"Là tôm tích núi lửa phải ăn! Nó giống cà phê chồn ấy!"],[4,"Ồ!! Ra là vậy!!"]].each { |a,s| kohi_atlantis.concat(pop.call(a,s)) }
    ["Nó gần giống cà phê chồn. Ngoại trừ việc một số con tôm sau khi ăn cà phê sẽ bị nổ banh xác. Vì cà phê Atlantis đa phần là các loại có độc tính mạnh, để xác định được chỗ cà phê nào uống được thì phải quan sát tôm núi lửa.","Chỗ trồng cà phê nào mà có nhiều xác tôm núi lửa banh xác thì chỗ cà phê đó không uống được.","Ngược lại, chỗ nào mà bọn tôm núi lửa ăn xong mà phát ra màu ánh kim, chỗ cà phê đó không những uống được mà còn là loại ngon nhất nữa!","Mặc dù đã tìm cách để nhân giống loại trừ các loại có độc tính mạnh nhưng độc tính của cà phê Atlantis vẫn không giảm."].each { |s| kohi_atlantis.concat(thought.call(s)) }
    kohi_atlantis.concat(hug).concat(pop.call(4,"Cảm ơn bà nhiều nhiều lắm Quỳ! Món quà tuyệt vời ông mặt trời!")).concat(thought.call("Kohi cất chiếc máy pha cà phê vào trong bếp. Cô ấy lấy từ trong túi xách của mình một chiếc hộp thiếc bóng loáng có vài đường vân được dát vàng sáng bóng cho bọn tôi chiêm ngưỡng rồi dúi nó vào tay Leo."))
    gifts[2].concat(switch_branch.call(kohi_atlantis, hug))

    gifts[3] = intro.call("Shylvie")
    [[2,"Giáng sinh an lành Shi-ru-vi! Tui hi vọng ông thích chiếc máy pha cà phê này!"],[3,"WOW! Từ khi nào bà xài được phép dịch chuyển vậy?"],[2,"Từ hôm nay. Thấy sao hả Shylvie? Về cái máy pha cà phê ấy?"],[3,"Ồ, đương nhiên là tui thích nó rồi!"]].each { |a,s| gifts[3].concat(pop.call(a,s)) }
    shylvie_atlantis=[]; [[2,"Phải thích chứ ha! Tui còn tặng kèm cả cà phê Atlantis đắt tiền cho bà đấy!"],[3,"Trời!! Trùng hợp thế!!"],[2,"Hả? Trùng hợp gì?"],[3,"Thì đây…!"]].each { |a,s| shylvie_atlantis.concat(pop.call(a,s)) }
    gifts[3].concat(switch_branch.call(shylvie_atlantis, []))
    gifts[3].concat(thought.call("Shylvie cất chiếc máy pha cà phê mà tôi tặng thật cẩn thận vào túi của mình, đồng thời rút ra một túi một túi cà phê dát vàng thượng hạng ở chiều không gian của mình. Nhận lấy túi cà phê, Kohi cười híp cả mắt."))
    shylvie_tail_on=[]; shylvie_tail_on.concat(pop.call(3,"Tại nay tui cũng tặng cà phê cho Kohi á.")); shylvie_tail_on.concat(pop.call(4,"Cảm ơn bố nhe!! Thấy bao bì bắt mắt thế này, hi vọng nó sẽ ngon!!")); shylvie_tail_on.concat(pop.call(2,"Chắc chắn sẽ ngon rồi!"))
    shylvie_tail_off=[]; shylvie_tail_off.concat(pop.call(4,"Cảm ơn bố nhe!! Thấy bao bì bắt mắt thế này, hi vọng nó sẽ ngon!!")); shylvie_tail_off.concat(pop.call(2,"Chắc chắn sẽ ngon rồi!"))
    gifts[3].concat(switch_branch.call(shylvie_tail_on, shylvie_tail_off))

    gifts[4] = intro.call("Hakase") + thought.call("Nếu là Dahria thì nó sẽ lo lắng đến mức bị loạn ngôn, khiến cho ai nấy đều phải bật cười nhỉ.")
    [[6,"Cảm ơn Hải Quỳ nha!! Nó là gì đó!!"],[2,"Là máy pha cà phê đó!!"],[2,"À, em chỉ nghĩ đơn giản là Hakase sẽ cần máy pha cà phê nên là em mua thôi! Ừm, là vậy đó! Dù sao thì mấy nay Hakase cũng làm việc cật lực mà ha! Kiểu gì cũng dễ bị buồn ngủ nên là mua máy pha cà phê là hợp lý nhỉ!"]].each { |a,s| gifts[4].concat(pop.call(a,s)) }
    gifts[4].concat(thought.call("Nói dứt lời, Hakase vỗ tay làm cho chiếc máy pha cà phê mà tôi đang ôm khư khư trong tay dịch chuyển lên bàn bếp. Rồi Hakase búng tay, một chiếc kệ gỗ bóng loáng bỗng dưng xuất hiện từ không trung. Nhìn vào hình dáng của chiếc kệ, tôi đoán nó là kệ đựng vũ khí."))
    gift_branches = gifts.flat_map { |value, commands| variable_branch.call(value, commands) }
    nest.call(gift_branches, gift_outer_indent + 1)
    list38[(gift_outer + 1)...gift_outer_end] = gift_branches
    save_data("Data/Map038.rvdata2", map38)

    # Map039: replace only Kohi and Shylvie recipient branches; Leo and Hakase
    # do not have separate coffee-source epilogues in the authored route.
    map39 = load_data("Data/Map039.rvdata2")
    page39 = map39.instance_variable_get(:@events)[1].instance_variable_get(:@pages).first
    list39 = page39.instance_variable_get(:@list)
    intro_ep = ["Tôi thực hiện thành công nhiệm vụ giải cứu phiền phức ngay tối hôm đấy.", "Rìa lỗ hổng 61 là khu vực cực kỳ hỗn loạn. Tuy vậy tôi vẫn dễ dàng giải cứu hết các thành viên Silver Wing bị bắt nhốt tại đấy trong tích tắc và không chần chừ tạo một kết giới để phong tỏa toàn bộ quái vật rồi cho nổ tanh bành mọi thứ.", "May cho mấy đứa bên Silver Wing vì TÔI là người đã cứu chúng nó, chứ nếu mà để Dahria làm thì có khi giờ này chúng nó đi chầu ông bà rồi."].flat_map { |s| thought.call(s) }
    kohi_off=[]; kohi_off.concat(thought.call("Sáng hôm sau, tôi dịch chuyển về văn phòng Wanderer để ăn kem. Vừa bước vào bếp, tôi đã ngửi thấy mùi cà phê nồng nàn. Tôi quay qua nhìn khu vực bếp thì thấy Kohi đang nhìn tôi, tay cầm một cốc cà phê nóng hôi hổi, còn bàn bếp thì chất đầy cốc cà phê sử dụng một lần.")); [[4,"Ơ Quỳ, bà về sớm thế! Uống cà phê không?"],[2,"Uống chứ. Bà pha loại nào đó?"],[4,"À, cái loại của Leo ấy. Loại này khá là đặc biệt nha. Của bà đây."]].each { |a,s| kohi_off.concat(pop.call(a,s)) }; kohi_off.concat(thought.call("Tôi nếm thử. Ừa, đúng là ngon thật. Mùi cà phê này thơm quá mà lạ nữa, hình như không phải loại cà phê ở thế giới này. Nó có mùi gì đấy giống giống mùi bạc hà, một chút khét của nhựa đường và vị chát của vôi.")); [[2,"Ừ, ngon ghê."],[4,"Phải ha!!"],[2,"Bảo sao bà uống tận hơn ba mươi ly."],[4,"Ồ, nó đặc biệt ở chỗ đó đó Quỳ! Một muỗng cà phê Luminous mà pha hơn tận ba chục ly mà vẫn đậm đặc. Thần kỳ thật ha!"],[2,"Ừa, bảo sao đợt lâu rồi Leo mượn phin pha cà phê của tui tận một tháng mà không trả."]].each { |a,s| kohi_off.concat(pop.call(a,s)) }; kohi_off.concat(thought.call("Cứ thế, hai đứa bọn tôi vừa ngồi uống cà phê, vừa trò chuyện, vừa ngắm nhìn bầu trời buổi sáng."))
    kohi_on=[]; kohi_on.concat(thought.call("Sáng hôm sau, tôi dịch chuyển về văn phòng Wanderer để ăn kem. Tôi chưa kịp mở tủ thì đã nghe thấy tiếng hét thất thanh của Shylvie từ trong phòng Kohi. Không những tôi mà Hakase và Leo đều tức tốc chạy vào kiểm tra.")); [[5,"Chuyện gì vậy Shylvie?!"],[3,"K-Kohi! Bà ấy không còn thở nữa!!"]].each { |a,s| kohi_on.concat(pop.call(a,s)) }; kohi_on.concat(thought.call("Hakase lập tức triệu hồi một vòng tròn ma pháp loại y tế để kiểm tra cấp tốc cho Kohi.")); [[6,"Bà ấy đang ngủ nhưng hơi thở yếu như người sắp chết ấy…"],[3,"Vậy chúng ta phải làm sao?!"],[6,"Không làm gì cả, cứ để bà ấy ngủ thôi."],[3,"Điên à? Chả phải ông bảo bà ấy sắp chết sao?"],[6,"Không chết được, yên tâm. Kiểu này cỡ 2-3 ngày sau là dậy ấy mà."],[5,"Chết thật! Thôi thì để bà ấy ngủ bù cho tuần vừa rồi làm việc cật lực vậy!"]].each { |a,s| kohi_on.concat(pop.call(a,s)) }; kohi_on.concat(thought.call("Leo kéo cả bọn ra ngoài để Kohi nghỉ ngơi. Hakase kéo tôi riêng ra một góc để hỏi chuyện.")); [[6,"Nè, cà phê Atlantis thực sự khiến người khác mất ngủ vậy hả?"],[2,"Cái này mới gặp lần đầu luôn…Đừng nói là anh uống rồi nha?"],[6,"À thì…sáng nay Kohi có mời một cốc…"],[2,"Chắc là không sao đâu ha…?"]].each { |a,s| kohi_on.concat(pop.call(a,s)) }; kohi_on.concat(thought.call("Ba ngày sau, Kohi lảo đảo bước ra khỏi phòng trước sự ngỡ ngàng đến vỡ òa của mọi người, nhất là Shylvie. Kohi bảo rằng đây là giấc ngủ ngon nhất từ trước đến giờ của bà ấy nên chắc bà ấy sẽ chuyển sang uống cà phê Atlantis một thời gian.")); kohi_on.concat(thought.call("Tôi với Hakase đã ba ngày không ngủ. Đến giờ Hakase vẫn chưa ngủ được."))
    shylvie_off=[]; shylvie_off.concat(thought.call("Từ hôm tôi tặng máy pha cà phê cho Shylvie đã hơn một tuần. Tần suất uống cà phê của Shylvie từ đó tỷ lệ thuận với bọng mắt của Shylvie, chúng bắt đầu tăng lên. Hỏi ra thì mới biết, Kohi vì không muốn Shylvie thức khuya làm việc nên đã nhất quyết không cho Shylvie mượn máy pha cà phê của bà ấy, thế nên việc tôi tặng máy pha cà phê cho Shylvie không khác gì tiếp giáo cho giặc.")); shylvie_off.concat(thought.call("Chà, biết vậy tặng Shylvie cà phê Atlantis cho Shylvie mất ngủ chơi, keke."))
    shylvie_on=[]; shylvie_on.concat(thought.call("Hai tuần sau, tôi cúp việc để đến văn phòng Wanderer ăn tối cùng với mọi người.")); [[3,"Q…Quỳ…Bà đến rồi hả?"],[2,"Shylvie sao vậy?"],[3,"Giọng điệu này…bà…Bà chơi xỏ tôi…"],[2,"Cà phê Atlantis ngon không?"],[3,"Haiz…\"ngon\" quá trời luôn…"],[2,"Ồ, đương nhiên rồi, keke. Hàng xịn mà lị."],[3,"Ừ, xịn đến mức mất ngủ hai tuần luôn. Tui không tài nào ngủ được…"],[2,"Trời trời, khổ thân chưa!!"]].each { |a,s| shylvie_on.concat(pop.call(a,s)) }; shylvie_on.concat(thought.call("Bữa tối diễn ra vui vẻ. Vì để Shylvie hết bị mất ngủ, tôi đã nói với Hakase rằng Shylvie đang bị bệnh nên cần ông ấy nấu cháo. Nhờ có tô cháo đặc biệt của Hakase, Shylvie đã nôn bán sống bán chết và rồi ngủ một mạch tận ba ngày. Do đó, chứng mất ngủ của Shylvie đã được chữa khỏi."))
    replacements = {2 => intro_ep + switch_branch.call(kohi_on, kohi_off), 3 => intro_ep + switch_branch.call(shylvie_on, shylvie_off)}
    replacements.keys.sort.reverse_each do |value|
      start = list39.index { |c| command_code(c) == 111 && command_parameters(c)[0,4] == [1,43,0,value] }
      raise "Map039 recipient branch #{value} missing" unless start
      branch_indent = list39[start].instance_variable_get(:@indent).to_i
      finish = ((start + 1)...list39.length).find { |i| command_code(list39[i]) == 412 && list39[i].instance_variable_get(:@indent).to_i == branch_indent }
      raise "Map039 recipient branch #{value} end missing" unless finish
      rebuilt = variable_branch.call(value, replacements[value])
      nest.call(rebuilt, branch_indent) if branch_indent > 0
      list39[start..finish] = rebuilt
    end
    save_data("Data/Map039.rvdata2", map39)
    puts "COFFEE_SOURCE_AUTHORED|Map040 Q1Q2|Map038 gifts|Map039 Kohi+Shylvie|switch=52"
  end

  # Finish all four recipient branches for the coffee-machine route.
  # Variable 43: 1 Leo, 2 Kohi, 3 Shylvie, 4 Hakase.
  def complete_coffee_route_branches
    thought = lambda { |text, indent = 0| wrapped_message_commands([text], width: 30, indent: indent) }
    pop = lambda { |anchor, text, indent = 0| wrapped_message_commands([text.sub(/^[-–]\s*/, "")], tag: "\\bm[#{anchor}] ", width: 24, indent: indent) }
    branch = lambda do |value, commands|
      [event_command(111, 0, [1, 43, 0, value, 0])] + commands.map { |c| c.instance_variable_set(:@indent, 1); c } + [event_command(412, 0, [])]
    end

    # Map037: recipient-specific anxiety before the common Aira sleep/wake part.
    map37 = load_data("Data/Map037.rvdata2")
    page37 = map37.instance_variable_get(:@events)[1].instance_variable_get(:@pages).first
    list37 = page37.instance_variable_get(:@list)
    start37_text = list37.index { |c| command_code(c) == 401 && command_parameters(c)[0].to_s.include?("Tui cảm thấy hơi bất an") }
    start37 = start37_text && start37_text.downto(0).find { |i| command_code(list37[i]) == 111 && command_parameters(list37[i])[1] == 43 }
    start37 ||= start37_text && start37_text.downto(0).find { |i| command_code(list37[i]) == 101 }
    end37 = list37.index { |c| command_code(c) == 225 }
    raise "Map037 recipient segment missing" unless start37 && end37
    common_reply = ["Thiệt không?!", "Phiền quá đừng hỏi nữa!", "Aira không thân thiện tí nào hết!"]
    prep = {
      1 => ["Tui cảm thấy hơi bất an một chút…Không biết Leo có thích món quà này không….", "Leo sẽ thích thôi, lo lắng chi vậy trời. Giờ thì ngủ dùm cái đi!", *common_reply,
            "Thân thiện gì với cái đứa nhiều chuyện như ngươi. Ngươi cứ lo lắng dư thừa, Leo vốn là một người dễ tính, ngươi tặng món gì mà hắn chả thích, mắc gì phải lo?", "Nhưng…", "Không nhưng nhị gì hết! Đi ngủ!"],
      2 => ["Tui cảm thấy hơi bất an một chút…Không biết Kohi có thích món quà này không….", "Kiểu gì Kohi chả thích. Giờ thì ngủ dùm cái đi!", *common_reply,
            "Thân thiện gì với cái đứa nhiều chuyện như ngươi. Ngươi cứ lo lắng dư thừa, Kohi lại chẳng thích máy pha cà phê bỏ xừ ra, mắc gì phải lo?", "Nhưng…", "Không nhưng nhị gì hết! Đi ngủ!"],
      3 => ["Tui cảm thấy hơi bất an một chút…Không biết Shylvie có thích món quà này không….", "Shylvie sẽ thích thôi, lo lắng chi vậy trời. Giờ thì ngủ dùm cái đi!", *common_reply,
            "Thân thiện gì với cái đứa nhiều chuyện như ngươi. Ngươi cứ lo lắng dư thừa, Shylvie vốn là một đứa thích cà phê mà, nhiễu sự ghê.", "Nhưng…", "Không nhưng nhị gì hết! Đi ngủ!"],
      4 => ["Tui cảm thấy hơi bất an một chút…Không biết Hakase có thích món quà này không….", "Hakase sẽ thích thôi, lo lắng chi vậy trời. Giờ thì ngủ dùm cái đi!", *common_reply,
            "Thân thiện gì với cái đứa nhiều chuyện như ngươi. Ngươi cứ lo lắng dư thừa, Hakase vốn là một kẻ tò mò, ngươi tặng cái quái gì mà hắn chả khoái.", "Nhưng…", "Không nhưng nhị gì hết! Đi ngủ!"]
    }
    prep_cmds = [event_command(355, 0, ["$game_variables[43]=2 unless (1..4).include?($game_variables[43])"])] +
      prep.flat_map { |value, lines| branch.call(value, lines.flat_map { |s| thought.call(s) }) }
    page37.instance_variable_set(:@list, list37[0...start37] + prep_cmds + list37[end37..-1])
    save_data("Data/Map037.rvdata2", map37)

    # Map038: replace the Kohi-only gift block by four exact recipient blocks.
    map38 = load_data("Data/Map038.rvdata2")
    page38 = map38.instance_variable_get(:@events)[7].instance_variable_get(:@pages).first
    list38 = page38.instance_variable_get(:@list)
    gift_text = list38.index { |c| command_code(c) == 401 && command_parameters(c)[0].to_s.include?("sự kiện chính") }
    gift_start = gift_text && gift_text.downto(0).find { |i| command_code(list38[i]) == 111 && command_parameters(list38[i])[1] == 43 }
    gift_start ||= gift_text && gift_text.downto(0).find { |i| command_code(list38[i]) == 101 }
    phone_text = list38.index { |c| command_code(c) == 401 && command_parameters(c)[0].to_s.include?("Đột nhiên điện thoại") }
    phone_start = phone_text && phone_text.downto(0).find { |i| command_code(list38[i]) == 101 }
    raise "Map038 gift/phone segment missing" unless gift_start && phone_start
    gifts = {}
    gifts[1] = []
    gifts[1].concat(pop.call(5, "E hèm! Tui nghĩ đã đến lúc cho sự kiện chính ngày hôm nay rồi, Quỳ nhỉ?"))
    ["Tôi tính đứng lên để tặng chiếc máy pha cà phê cho Leo thì chợt nhận ra tôi để quên nó ở nhà…", "Haizz, đúng là không có tôi thì Dahria là một con mắm hay quên nhỉ.",
     "Tôi cởi mũ len của mình xuống, thò tay vào nó trước bốn cặp mắt ngỡ ngàng. Tôi moi moi một lúc, cuối cùng cũng lôi được chiếc máy pha cà phê mà con nhỏ Dahria để quên ở nhà."].each { |s| gifts[1].concat(thought.call(s)) }
    [[2,"Giáng sinh an lành Leo! Tui hi vọng ông thích chiếc máy pha cà phê này!"],[5,"Uầy!! Bà dùng được phép dịch chuyển rồi hả?!"],[2,"Ngạc nhiên sai thứ rồi!! Ông phải ngạc nhiên vì chiếc máy pha cà phê này chứ!"],[5,"À ừ thì đương nhiên rồi! Cảm ơn bà nha!!!"]].each { |a,s| gifts[1].concat(pop.call(a,s)) }
    gifts[1].concat(thought.call("Leo nhận chiếc máy pha cà phê từ tay tôi rồi lon ton lon ton cất nó vào trong bếp. Tôi thấy Leo lấy điện thoại ra chụp tự sướng cùng chiếc máy pha cà phê. Tôi cá mười quả cam chút nữa ổng sẽ gửi cho người thương của ông ấy."))
    [[5,"Món quà tuyệt vời lắm Quỳ!!"],[2,"Phải như vậy chứ! Tui thậm chí còn tặng cho ông đặc sản quê tui, cà phê Atlantis siêu hảo hạng luôn!!"],[5,"Ồ!! Bà chu đáo quá! Cà phê siêu hảo hạng luôn!! Không biết mùi vị như thế nào nhỉ?!"],[4,"Leo!! Nó ngon lắm đó!! Hôm bữa tui uống ké của Quỳ rồi, ngon xĩu luôn!!"],[5,"Thiệt hả?!"]].each { |a,s| gifts[1].concat(pop.call(a,s)) }

    gifts[2] = []
    gifts[2].concat(pop.call(5, "E hèm! Tui nghĩ đã đến lúc cho sự kiện chính ngày hôm nay rồi, Quỳ nhỉ?"))
    ["Tôi tính đứng lên để tặng chiếc máy pha cà phê thì chợt nhận ra tôi để quên nó ở nhà…", "Haizz, đúng là không có tôi thì Dahria là một con mắm hay quên nhỉ.", "Tôi cởi mũ len, thò tay vào và cuối cùng cũng lôi được chiếc máy pha cà phê mà con nhỏ Dahria để quên ở nhà."].each { |s| gifts[2].concat(thought.call(s)) }
    [[2,"Giáng sinh vui vẻ nha Kohi!!"],[4,"MỘT CHIẾC MÁY PHA CÀ PHÊ?! UI!! THÍCH THẾ!!"],[2,"Hehe!! Bà thích là tui vui rồi!!"],[3,"Đấy thấy chưa Kohi, tôi đã nói là bà ấy nhìn thấy trước tương lai rồi mà."],[2,"Hả? Vụ gì đấy?"],[4,"À, tuần trước tui với Shylvie có cược với nhau rằng bà sẽ mua máy pha cà phê tặng tui ấy mà."],[2,"À…Thế là mấy người đem tui ra để cá cược với nhau hả??"],[4,"Không không, không hẳn là thế! Tui muốn kiểm chứng vụ đấy thôi!!"],[2,"Vụ…tui nhìn thấy trước tương lai?"],[4,"Ừm hứm! Shylvie thậm chí còn bảo rằng bà có thể tác động cả thực tại cơ."],[3,"Ừ, chuyện là vậy đó."],[4,"Mà bỏ qua vụ đó đi! Quan trọng là…."],[2,"À…Thế thì không một ai thắng cược hết!"],[4,"HẢ? Tại sao?"],[2,"Tại vì ngoài máy pha cà phê ra tui còn tặng cả cà phê Atlantis cơ!"],[4,"Ồ! Tui có nghe về nó rồi!! Là loại cà phê hiếm có khó tìm, được trồng trên các tảng san hô núi lửa ở rãnh Marianna không?"],[2,"Đúng đúng! Nhưng còn điều này bà chưa biết…! Để cho ra được cà phê Atlantis, bắt buộc phải có sự tiêu hóa của tôm tích núi lửa nữa!"],[4,"Là sao á?"],[2,"Là tôm tích núi lửa phải ăn! Nó giống cà phê chồn ấy!"],[4,"Ồ!! Ra là vậy!!"]].each { |a,s| gifts[2].concat(pop.call(a,s)) }
    ["Nó gần giống cà phê chồn. Ngoại trừ việc một số con tôm sau khi ăn cà phê sẽ bị nổ banh xác. Vì cà phê Atlantis đa phần là các loại có độc tính mạnh, để xác định được chỗ cà phê nào uống được thì phải quan sát tôm núi lửa.", "Chỗ trồng cà phê nào mà có nhiều xác tôm núi lửa banh xác thì chỗ cà phê đó không uống được.", "Ngược lại, chỗ nào mà bọn tôm núi lửa ăn xong mà phát ra màu ánh kim, chỗ cà phê đó không những uống được mà còn là loại ngon nhất nữa!", "Mặc dù đã tìm cách để nhân giống loại trừ các loại có độc tính mạnh nhưng độc tính của cà phê Atlantis vẫn không giảm."].each { |s| gifts[2].concat(thought.call(s)) }
    gifts[2].concat(pop.call(4,"Cảm ơn bà nhiều nhiều lắm Quỳ! Món quà tuyệt vời ông mặt trời!")); gifts[2].concat(thought.call("Kohi cất chiếc máy pha cà phê vào trong bếp. Cô ấy lấy từ trong túi xách của mình một chiếc hộp thiếc bóng loáng có vài đường vân được dát vàng sáng bóng cho bọn tôi chiêm ngưỡng rồi dúi nó vào tay Leo.")); gifts[2].concat(thought.call("Kohi nhào đến ôm tôi. Tôi vòng tay ra sau lưng Kohi, ôm cô ấy thật chặt. Mùi của Kohi thơm thật đấy, thơm đến mức đánh bay cả sự lo âu của tôi."))

    gifts[3] = []
    gifts[3].concat(pop.call(5,"E hèm! Tui nghĩ đã đến lúc cho sự kiện chính ngày hôm nay rồi, Quỳ nhỉ?"))
    ["Tôi tính đứng lên để tặng chiếc máy pha cà phê cho Shylvie thì chợt nhận ra tôi để quên nó ở nhà…", "Haizz, đúng là không có tôi thì Dahria là một con mắm hay quên nhỉ.", "Tôi cởi mũ len của mình xuống, thò tay vào nó trước bốn cặp mắt ngỡ ngàng. Tôi moi moi một lúc, cuối cùng cũng lôi được chiếc máy pha cà phê mà con nhỏ Dahria để quên ở nhà."].each { |s| gifts[3].concat(thought.call(s)) }
    [[2,"Giáng sinh an lành Shi-ru-vi! Tui hi vọng ông thích chiếc máy pha cà phê này!"],[3,"WOW! Từ khi nào bà xài được phép dịch chuyển vậy?"],[2,"Từ hôm nay. Thấy sao hả Shylvie? Về cái máy pha cà phê ấy?"],[3,"Ồ, đương nhiên là tui thích nó rồi!"],[2,"Phải thích chứ ha! Tui còn tặng kèm cả cà phê Atlantis đắt tiền cho ông đấy!"],[3,"Trời!! Trùng hợp thế!!"],[2,"Hả? Trùng hợp gì?"],[3,"Thì đây…!"]].each { |a,s| gifts[3].concat(pop.call(a,s)) }
    gifts[3].concat(thought.call("Shylvie cất chiếc máy pha cà phê mà tôi tặng thật cẩn thận vào túi của mình, đồng thời rút ra một túi một túi cà phê dát vàng thượng hạng ở chiều không gian của mình. Nhận lấy túi cà phê, Kohi cười híp cả mắt.")); gifts[3].concat(pop.call(3,"Tại nay tui cũng tặng cà phê cho Kohi á.")); gifts[3].concat(pop.call(2,"Chắc chắn sẽ ngon rồi!"))

    gifts[4] = []
    gifts[4].concat(pop.call(5,"E hèm! Tui nghĩ đã đến lúc cho sự kiện chính ngày hôm nay rồi, Quỳ nhỉ?"))
    ["Tôi tính đứng lên để tặng chiếc máy pha cà phê cho Hakase thì chợt nhận ra tôi để quên nó ở nhà…", "Haizz, đúng là không có tôi thì Dahria là một con mắm hay quên nhỉ.", "Tôi cởi mũ len của mình xuống, thò tay vào nó trước bốn cặp mắt ngỡ ngàng. Tôi moi moi một lúc, cuối cùng cũng lôi được chiếc máy pha cà phê mà con nhỏ Dahria để quên ở nhà.", "Nếu là Dahria thì nó sẽ lo lắng đến mức bị loạn ngôn, khiến cho ai nấy đều phải bật cười nhỉ."].each { |s| gifts[4].concat(thought.call(s)) }
    [[6,"Cảm ơn Hải Quỳ nha!! Nó là gì đó!!"],[2,"Là máy pha cà phê đó!!"],[2,"À, em chỉ nghĩ đơn giản là Hakase sẽ cần máy pha cà phê nên là em mua thôi! Ừm, là vậy đó! Dù sao thì mấy nay Hakase cũng làm việc cật lực mà ha! Kiểu gì cũng dễ bị buồn ngủ nên là mua máy pha cà phê là hợp lý nhỉ!"]].each { |a,s| gifts[4].concat(pop.call(a,s)) }
    gifts[4].concat(thought.call("Nói dứt lời, Hakase vỗ tay làm cho chiếc máy pha cà phê mà tôi đang ôm khư khư trong tay dịch chuyển lên bàn bếp. Rồi Hakase búng tay, một chiếc kệ gỗ bóng loáng bỗng dưng xuất hiện từ không trung. Nhìn vào hình dáng của chiếc kệ, tôi đoán nó là kệ đựng vũ khí."))
    gift_branches = gifts.flat_map { |value, cmds| branch.call(value, cmds) }
    page38.instance_variable_set(:@list, list38[0...gift_start] + gift_branches + list38[phone_start..-1])
    save_data("Data/Map038.rvdata2", map38)

    # Map039: four complete V2 epilogues, galleries and hint IDs.
    map39 = load_data("Data/Map039.rvdata2")
    event39 = map39.instance_variable_get(:@events)[1]
    setup = [event_command(355,0,["$game_player.transparent=true"]), event_command(355,0,["layer(39,0,[\"Map_Wanderer_Office_top\",0,0,255,200,0,0,0])"]), event_command(655,0,["refresh_layers"]), event_command(117,0,[3]), event_command(222,0,[])]
    eps = {}
    eps[1] = []
    ["Tôi thực hiện thành công nhiệm vụ giải cứu phiền phức ngay tối hôm đấy.", "Rìa lỗ hổng 61 là khu vực cực kỳ hỗn loạn. Tuy vậy tôi vẫn dễ dàng giải cứu hết các thành viên Silver Wing bị bắt nhốt tại đấy trong tích tắc và không chần chừ tạo một kết giới để phong tỏa toàn bộ quái vật rồi cho nổ tanh bành mọi thứ.", "May cho mấy đứa bên Silver Wing vì TÔI là người đã cứu chúng nó, chứ nếu mà để Dahria làm thì có khi giờ này chúng nó đi chầu ông bà rồi.", "Sáng hôm sau, tôi dịch chuyển về văn phòng Wanderer để ăn kem. Mở tủ lạnh ra, cả một núi kem Socola đè vào người tôi."].each { |s| eps[1].concat(thought.call(s)) }
    [[5,"Ơ? Quỳ đấy à?! Bà về hồi nào đấy…"],[2,"Mới…Mới về….Nay Leo dậy sớm thế…."],[5,"À, tui đang pha cà phê ấy mà!"]].each { |a,s| eps[1].concat(pop.call(a,s)) }
    ["Leo đỡ tôi ngồi lên ghế. Cầm hộp kem Socola chà bá trong tay, tôi vừa ăn vừa nhìn Leo pha cà phê bằng chiếc máy mà tôi tặng ông ấy ngày hôm qua. Mùi cà phê này thơm quá mà lạ nữa, hình như không phải loại cà phê ở thế giới này. Nó có mùi gì đấy giống giống mùi bạc hà, một chút khét của nhựa đường và vị chát của vôi.", "Leo pha một cốc đầy và san ra làm hai cốc nhỏ, một cốc cho tôi và một cốc cho ông ấy."].each { |s| eps[1].concat(thought.call(s)) }
    [[2,"Ừm, ngon phết."],[5,"À, bà có thể đổ thêm Sting vào để gia tăng vị ngọt đó."],[2,"Hả…Ai lại cho Sting vào cà phê cơ…"],[4,"A!! Leo pha lén cà phê mà không rủ tớ!!"]].each { |a,s| eps[1].concat(pop.call(a,s)) }
    eps[1].concat(thought.call("Tiếng Kohi vọng ra từ trong phòng họp. Tức tốc, Kohi phi ra bếp với vận tốc âm thanh với vẻ mặt háo hức.")); eps[1].concat(pop.call(4,"Ừm hưm! Là cà phê Luminous trứ danh đó sao!! Cho tui một ly, cho tui một ly!!")); eps[1].concat(pop.call(5,"Ok! Chờ xíu!!")); ["Leo múc một muỗng bột cà phê từ trong hũ cho vào máy pha cà phê. Nhưng không biết vì lý do nào đó mà đã hơn 10 phút rồi mà chưa thấy giọt cà phê nào nhỏ xuống cốc. Không những thế lại còn có mùi khét bốc ra từ trong máy.", "Và rồi cái máy pha cà phê bốc cháy. Leo hoảng hốt chạy đi lấy bình cứu hỏa để ở góc bếp ra xịt tùm lum.", "Ừm, cà phê đổ thêm Sting uống cũng ngon phết."].each { |s| eps[1].concat(thought.call(s)) }
    eps[2] = []
    ["Tôi thực hiện thành công nhiệm vụ giải cứu phiền phức ngay tối hôm đấy.", "Rìa lỗ hổng 61 là khu vực cực kỳ hỗn loạn. Tuy vậy tôi vẫn dễ dàng giải cứu hết các thành viên Silver Wing bị bắt nhốt tại đấy trong tích tắc và không chần chừ tạo một kết giới để phong tỏa toàn bộ quái vật rồi cho nổ tanh bành mọi thứ.", "May cho mấy đứa bên Silver Wing vì TÔI là người đã cứu chúng nó, chứ nếu mà để Dahria làm thì có khi giờ này chúng nó đi chầu ông bà rồi.", "Sáng hôm sau, tôi dịch chuyển về văn phòng Wanderer để ăn kem. Vừa bước vào bếp, tôi đã ngửi thấy mùi cà phê nồng nàn. Tôi quay qua nhìn khu vực bếp thì thấy Kohi đang nhìn tôi, tay cầm một cốc cà phê nóng hôi hổi, còn bàn bếp thì chất đầy cốc cà phê sử dụng một lần."].each { |s| eps[2].concat(thought.call(s)) }
    [[4,"Ơ Quỳ, bà về sớm thế! Uống cà phê không?"],[2,"Uống chứ. Bà pha loại nào đó?"],[4,"À, cái loại của Leo ấy. Loại này khá là đặc biệt nha. Của bà đây."]].each { |a,s| eps[2].concat(pop.call(a,s)) }
    eps[2].concat(thought.call("Tôi nếm thử. Ừa, đúng là ngon thật. Mùi cà phê này thơm quá mà lạ nữa, hình như không phải loại cà phê ở thế giới này. Nó có mùi gì đấy giống giống mùi bạc hà, một chút khét của nhựa đường và vị chát của vôi.")); [[2,"Ừ, ngon ghê."],[4,"Phải ha!!"],[2,"Bảo sao bà uống tận hơn ba mươi ly."],[4,"Ồ, nó đặc biệt ở chỗ đó đó Quỳ! Một muỗng cà phê Luminous mà pha hơn tận ba chục ly mà vẫn đậm đặc. Thần kỳ thật ha!"],[2,"Ừa, bảo sao đợt lâu rồi Leo mượn phin pha cà phê của tui tận một tháng mà không trả."]].each { |a,s| eps[2].concat(pop.call(a,s)) }; eps[2].concat(thought.call("Cứ thế, hai đứa bọn tôi vừa ngồi uống cà phê, vừa trò chuyện, vừa ngắm nhìn bầu trời buổi sáng."))
    eps[3] = []
    ["Tôi thực hiện thành công nhiệm vụ giải cứu phiền phức ngay tối hôm đấy.", "Rìa lỗ hổng 61 là khu vực cực kỳ hỗn loạn. Tuy vậy tôi vẫn dễ dàng giải cứu hết các thành viên Silver Wing bị bắt nhốt tại đấy trong tích tắc và không chần chừ tạo một kết giới để phong tỏa toàn bộ quái vật rồi cho nổ tanh bành mọi thứ.", "May cho mấy đứa bên Silver Wing vì TÔI là người đã cứu chúng nó, chứ nếu mà để Dahria làm thì có khi giờ này chúng nó đi chầu ông bà rồi.", "Hai tuần sau, tôi cúp việc để đến văn phòng Wanderer ăn tối cùng với mọi người."].each { |s| eps[3].concat(thought.call(s)) }
    [[3,"Q…Quỳ…Bà đến rồi hả?"],[2,"Shylvie sao vậy?"],[3,"Giọng điệu này…bà…Bà chơi xỏ tôi…"],[2,"Cà phê Atlantis ngon không?"],[3,"Haiz…“ngon” quá trời luôn…"],[2,"Ồ, đương nhiên rồi, keke. Hàng xịn mà lị."],[3,"Ừ, xịn đến mức mất ngủ hai tuần luôn. Tui không tài nào ngủ được…"],[2,"Trời trời, khổ thân chưa!!"]].each { |a,s| eps[3].concat(pop.call(a,s)) }
    eps[3].concat(thought.call("Bữa tối diễn ra vui vẻ. Vì để Shylvie hết bị mất ngủ, tôi đã nói với Hakase rằng Shylvie đang bị bệnh nên cần ông ấy nấu cháo. Nhờ có tô cháo đặc biệt của Hakase, Shylvie đã nôn bán sống bán chết và rồi ngủ một mạch tận ba ngày. Do đó, chứng mất ngủ của Shylvie đã được chữa khỏi."))
    eps[4] = []
    ["Tôi thực hiện thành công nhiệm vụ giải cứu phiền phức ngay tối hôm đấy.", "Rìa lỗ hổng 61 là khu vực cực kỳ hỗn loạn. Tuy vậy tôi vẫn dễ dàng giải cứu hết các thành viên Silver Wing bị bắt nhốt tại đấy trong tích tắc và không chần chừ tạo một kết giới để phong tỏa toàn bộ quái vật rồi cho nổ tanh bành mọi thứ.", "May cho mấy đứa bên Silver Wing vì TÔI là người đã cứu chúng nó, chứ nếu mà để Dahria làm thì có khi giờ này chúng nó đi chầu ông bà rồi.", "Sáng hôm sau, tôi dịch chuyển về văn phòng Wanderer để ăn kem. Mở tủ lạnh ra, cả một núi kem Socola đè vào người tôi."].each { |s| eps[4].concat(thought.call(s)) }
    [[5,"Ơ? Quỳ đấy à?! Bà về hồi nào đấy…"],[2,"Mới…Mới về….Ơ, nay mọi người dậy sớm thế…."],[5,"À, Hakase bảo là sẽ pha cà phê cho mọi người uống sáng nay nên là mọi người thấy tò mò thôi….Nhỉ…"],[2,"Vậy là mọi người uống rồi à? Cà phê ngon không?"]].each { |a,s| eps[4].concat(pop.call(a,s)) }
    eps[4].concat(thought.call("Không một ai đáp lại lời của tôi, tất cả đều đá mắt sang Hakase, người đang loay hoay trong bếp.")); [[6,"Ơ! Quỳ!! Cậu về đúng lúc đấy!! Tớ có làm cà phê cho cậu này!!"],[2,"Hả…Ừ, cảm ơn Hakase nha…"]].each { |a,s| eps[4].concat(pop.call(a,s)) }
    ["Ah, chết tiệt. Biết vậy về trễ cho rồi.", "Đón lấy ly cà phê vào lòng bàn tay, chân mày tôi khẽ chau lại đôi chút. Tại sao trong ly cà phê này lại có cỏ vậy…? Lại còn có cả hạt của loại trái cây nào đó? Chất cà phê thì bùn lầy, sánh đặc. Hương thơm thì có chút mùi cháy của giấy báo, than chì.", "Thôi xong, không ổn rồi.", "Tôi quay qua nhìn ba người kia, họ đã bất tỉnh nhân sự. Thôi thì….ỰC ỰC ỰC.", "Hừm, cà phê không tệ như tôi nghĩ? Nó khá là….HỰ…..Huệ…."].each { |s| eps[4].concat(thought.call(s)) }
    [[6,"Ơ?! Quỳ sao vậy?!"],[2,"Không…Không có gì…"],[6,"Thiệt không? Thế sao da của cậu chuyển sang màu nâu vậy?"],[2,"À…Hue…Ừm, mỗi lần em uống nước gì đó mà đậm đặc thì…hue….ực, da sẽ chuyển m…màu…"],[6,"À!! Ra là thế!! Hiệu ứng hay thế!"]].each { |a,s| eps[4].concat(pop.call(a,s)) }
    eps[4].concat(thought.call("Vài tiếng sau, Leo, Kohi và Shylvie đều nằm liệt giường. Tôi phải lấp liếm với Hakase rằng có lẽ tối qua mọi người ăn quá nhiều kem nên bị đau bụng.")); eps[4].concat(pop.call(6,"Trời ơi, vậy trưa nay tớ sẽ đứng bếp nấu cháo cho mọi người ăn ha!")); eps[4].concat(pop.call(2,"HAKASE ĐỪNG! E hèm, ý tớ là, để tớ nấu cháo cho..!"))
    ep_branches = eps.flat_map { |value, cmds| branch.call(value, cmds) }
    finish = [event_command(355,0,["id={1=>10,2=>11,3=>12,4=>13}[$game_variables[43]] || 11; GlobalGallery.unlock(id)"]), event_command(355,0,["name={1=>\"ED_MKT_COFFEE_LEO\",2=>\"ED_MKT_COFFEE_KOHI\",3=>\"ED_MKT_COFFEE_SHYLVIE\",4=>\"ED_MKT_COFFEE_HAKASE\"}[$game_variables[43]] || \"ED_MKT_COFFEE_KOHI\"; EndingPresentation.show_gallery(name,240)"]), event_command(121,0,[46,46,0]), event_command(355,0,["$game_variables[41]=$game_variables[43]+1"]), event_command(201,0,[0,36,8,6,2,2]), event_command(0,0,[])]
    event39.instance_variable_get(:@pages).first.instance_variable_set(:@list, setup + ep_branches + finish)
    save_data("Data/Map039.rvdata2", map39)

    # Shared hint hub pages 2..5 correspond to Leo/Kohi/Shylvie/Hakase.
    map36 = load_data("Data/Map036.rvdata2"); router = map36.instance_variable_get(:@events)[1]; pages = router.instance_variable_get(:@pages)
    pages.reject! { |pg| (c=pg.instance_variable_get(:@condition)) && c.instance_variable_get(:@variable_valid) && c.instance_variable_get(:@variable_value).to_i.between?(2,5) }
    hints = {2=>["Ê.","Cà phê Atlantis cũng ngon đấy, nhưng ta vẫn thích cà phê Luminous ở quê nhà Leo hơn.","Chỉ cần đổ vào một chút nước nóng, khuấy đều lên.","Cà phê Luminous đậm đà, sánh kẹo, thơm lừng.","Hậu vị không có bị chua.","Ngươi mau đi nói chuyện với Leo để hỏi chỗ mua cà phê Luminous đi!"], 3=>["Ta thấy hơi chán","Ngươi tặng cho Kohi món quà tuyệt vời nhất. Best Ending luôn rồi còn gì?","Ngươi chưa từng nghĩ đến việc tặng cho cô ấy một món quà độc lạ hả?","Tặng cái gì khác ngoài cà phê đi!!"], 4=>["Nghe ta nói này.","Tuyệt đối.","Đừng tặng món này.","Cho Hakase.","Ngươi mà tặng hắn món này.","“Ngu tuyệt đối”","Sẽ là tên cún cơm mà ta sẽ gọi ngươi đấy."], 5=>["Ê!","NGƯƠI NGHĨ GÌ MÀ TẶNG HAKASE MÓN NÀY VẬY HẢ?","NGU TUYỆT ĐỐI!!","DA CHÚNG TA RÁM LẠI RỒI ĐÂY NÀY!!","RÁM HƠN MÀU BÁNH CAM NỮA!!!","NGU, NGƯỜI GÌ ĐÂU MÀ NGU THẾ KHÔNG BIẾT!!","Mau quay lại mà tặng hắn món khác đi!!","TẶNG MÓN GÌ CŨNG ĐƯỢC!!"]}
    names = {2=>"ED_MKT_COFFEE_LEO",3=>"ED_MKT_COFFEE_KOHI",4=>"ED_MKT_COFFEE_SHYLVIE",5=>"ED_MKT_COFFEE_HAKASE"}
    hints.each do |value, lines|
      cmds=[event_command(355,0,["$game_player.transparent=true"]),event_command(122,0,[40,40,0,0,2]),event_command(117,0,[5])]
      lines.each { |s| cmds.concat(pop.call(2,s)) }; cmds.concat([event_command(117,0,[3]),event_command(230,0,[60]),event_command(355,0,["HAIQUY_TITLE.set_ending_background(\"#{names[value]}\")"]),event_command(354,0,[])])
      pages << page_from_template(router,cmds,trigger:3,priority:0,variable_id:41,variable_value:value)
    end
    router.instance_variable_set(:@pages,pages); save_data("Data/Map036.rvdata2",map36)
    apply_authored_coffee_source_variants
    puts "COFFEE_ROUTE_COMPLETE|targets=Leo,Kohi,Shylvie,Hakase|gallery=10..13|hint=2..5"
  end

  # Complete all supermarket gift/recipient combinations from the compact
  # script. This deliberately materializes DOCUMENT SEQUENCES/MAIN first; the
  # deduplicated BLOCK REGISTRY is never read as linear story text.
  def complete_remaining_supermarket_routes
    compact_path = "docs/kich ban/GAME_SCRIPT_AI_COMPACT_V2.md"
    compact_lines = File.readlines(compact_path, encoding: "UTF-8", chomp: true)
    registry = {}
    compact_lines.each do |line|
      match = /\A(B\d{4}):\s?(.*)\z/.match(line)
      registry[match[1]] = match[2] if match
    end
    expand = lambda do |title|
      heading = compact_lines.index("### #{title}")
      raise "Compact document missing: #{title}" unless heading
      main = compact_lines[(heading + 1)..-1].find { |line| line.start_with?("MAIN: ") }
      raise "Compact MAIN missing: #{title}" unless main
      ids = main.sub(/\AMAIN:\s*/, "").split.flat_map do |token|
        if (range = /\AB(\d{4})\.\.B(\d{4})\z/.match(token))
          (range[1].to_i..range[2].to_i).map { |id| "B%04d" % id }
        else
          [token]
        end
      end
      missing = ids.reject { |id| registry.key?(id) }
      raise "Compact registry missing #{missing.uniq.join(', ')}" unless missing.empty?
      ids.map { |id| registry[id] }
    end

    routes = {
      1 => expand.call("Route Máy Pha Cà Phê"),
      2 => expand.call("Route Dao & Chao"),
      3 => expand.call("Route Khăn Len"),
      4 => expand.call("Route Bophakhoa")
    }
    target_names = {1 => "Leo", 2 => "Kohi", 3 => "Shylvie", 4 => "Hakase"}
    heading_name = lambda { |name| name == "Shylvie" ? "SHYL(?:VIE|IVE)" : Regexp.escape(name) }
    section = lambda do |lines, start_pattern, end_pattern|
      start = lines.index { |line| line.match?(start_pattern) }
      raise "Compact section missing: #{start_pattern.inspect}" unless start
      finish = ((start + 1)...lines.length).find { |i| lines[i].match?(end_pattern) } || lines.length
      lines[(start + 1)...finish]
    end

    thought = lambda { |text, indent = 0| wrapped_message_commands([text], width: 30, indent: indent) }
    pop = lambda { |anchor, text, indent = 0| wrapped_message_commands([text.sub(/^[-–]\s*/, "")], tag: "\\bm[#{anchor}] ", width: 24, indent: indent) }
    face_message = lambda do |face, face_index, text, indent = 0|
      result = wrapped_message_commands([text], width: 30, indent: indent)
      result.each do |command|
        next unless command_code(command) == 101
        command.instance_variable_set(:@parameters, [face, face_index, 0, 2])
      end
      result
    end
    actors = {
      "Hải Quỳ" => [2, "HaiQuy_Giangsinh_Emote", 1],
      "Bully Quỳ" => [2, "BullyQuy_Thuongphuc_Emote", 1],
      "Shylvie" => [3, "CV_Giangsinh_Emote1", 1],
      "Kohi" => [4, "Kohi_Giangsinh_Emote1", 1],
      "Leo" => [5, "Leo_Giangsinh_Emote", 1],
      "Hakase" => [6, "Hakase_Giangsinh_Emote", 1]
    }
    compile = lambda do |source_lines, mode = :party|
      commands = []
      speaker = actors["Hải Quỳ"]
      force_next_pop = false
      source_lines.each do |raw|
        text = raw.to_s.strip
        next if text.empty?
        if text.start_with?("[") && text.end_with?("]")
          if text.match?(/Sprite|Hải Quỳ|Bully Quỳ|Kohi|Leo|Shylvie|Hakase/i)
            # Some directions name two actors.  Preserve their written order;
            # Hash order used to pick Shylvie before an earlier Hakase/Leo and
            # consequently attached the following dialogue to the wrong event.
            lowered = text.downcase
            found = actors.keys.select { |name| lowered.include?(name.downcase) }
                          .min_by { |name| lowered.index(name.downcase) }
            speaker = actors[found] if found
            force_next_pop = true if found
          end
          next
        end
        next if text.match?(/\A(?:Cảnh|CẢNH|Hết cảnh|HẾT CẢNH|LEO CẢNH|KOHI CẢNH|SHYL)/i)
        if text =~ /\[\s*Q([12])\s*\]\s*\z/i
          q = Regexp.last_match(1).to_i
          clean = text.sub(/\s*\[\s*Q[12]\s*\]\s*\z/i, "")
          face = q == 2 ? ["BullyQuy_Thuongphuc_Emote", 1] : ["HaiQuy_Thuongphuc_Emote", 1]
          commands.concat(face_message.call(face[0], face[1], clean))
          force_next_pop = false
          next
        end
        if (named = /\A(Hải Quỳ|Bully Quỳ|Shylvie|Kohi|Leo|Hakase):\s*(.+)\z/i.match(text))
          key = actors.keys.find { |name| name.downcase == named[1].downcase }
          actor = actors[key]
          if mode == :party
            commands.concat(face_message.call(actor[1], actor[2], named[2]))
          else
            commands.concat(pop.call(actor[0], named[2]))
          end
          speaker = actor
          force_next_pop = false
        elsif mode == :party && (text.start_with?("-", "–") || force_next_pop)
          # The Christmas-office scene is deliberately presented over a black
          # screen.  It must use regular messages with faces, never event
          # bubbles (there is no visible event to anchor a bubble to).
          clean = text.sub(/^[-–]\s*/, "")
          commands.concat(face_message.call(speaker[1], speaker[2], clean))
          force_next_pop = false
        else
          face = mode == :bedroom ? "HaiQuy_Thuongphuc_Emote" : "HaiQuy_Giangsinh_Emote"
          commands.concat(face_message.call(face, 1, text))
          force_next_pop = false
        end
      end
      commands
    end
    apply_face_overrides = lambda do |commands, overrides|
      index = 0
      while index < commands.length
        unless command_code(commands[index]) == 101
          index += 1
          next
        end
        last = index
        lines = []
        while last + 1 < commands.length && command_code(commands[last + 1]) == 401
          last += 1
          lines << command_parameters(commands[last])[0].to_s
        end
        logical_text = lines.join(" ").gsub(/\s+/, " ")
        match = overrides.find { |needle, _actor_name| logical_text.include?(needle) }
        if match
          actor = actors.fetch(match[1])
          commands[index].instance_variable_set(:@parameters, [actor[1], actor[2], 0, 2])
        end
        index = last + 1
      end
      commands
    end
    lock_scene9_faces = {
      1 => {
        "Mở ra xem là biết liền" => "Leo",
        "Haha. Tôi biết ngay" => "Leo",
        "Thích á? Không, tôi yêu" => "Hakase",
        "Ê ê, no homo" => "Leo",
        "Yeah, no homo" => "Hakase",
        "Đeo vào luôn đi" => "Hakase"
      },
      2 => {},
      3 => {
        "Hả gì? Nhìn trước gì cơ" => "Hải Quỳ",
        "Cái bộ dụng cụ này là bộ tui" => "Shylvie",
        "Tuyệt vời! Cảm ơn bà nha" => "Shylvie",
        "Mở ra xem là biết liền" => "Shylvie",
        "Sao lại “ được thế “" => "Shylvie",
        "UẦY!! XỊN!!" => "Leo",
        "Đấy, phải là xịn chứ" => "Shylvie",
        "Tui còn biết nói gì ngoài xịn" => "Leo",
        "Ừ, phải như thế chứ" => "Shylvie",
        "Nhìn ngầu thật sự! Shylvie tài" => "Hakase",
        "Ôi cảm ơn Hakase" => "Shylvie",
        "Cậu làm cho tớ một cái" => "Hakase",
        "Được chứ! Cậu gửi cho tớ" => "Shylvie"
      },
      4 => {
        "Happy Merry Chích Mớt" => "Hải Quỳ",
        "Siêu thích là đằng khác" => "Hakase",
        "À...Vậy hả?" => "Hải Quỳ",
        "Yep, đúng rồi đấy" => "Leo",
        "Tui vẫn không biết là bà tác động" => "Shylvie",
        "Hổng nhớ, kể nghe với" => "Kohi",
        "Con mới vào sao mà nhớ được" => "Shylvie",
        "Tên Văn phòng này được đặt theo kiểu" => "Kohi",
        "Do có nhiều tên quá" => "Leo",
        "Tôi thề luôn, lần quay đó" => "Shylvie",
        "Hoặc là bả tác động vô cái vòng quay" => "Hakase",
        "Hông! Hông muốn" => "Hải Quỳ",
        "Haha, phải rồi ha" => "Hakase"
      }
    }
    lock_scene13_faces = {
      1 => {
        "Ai đấy!!" => "Leo",
        "Leo! Cửa bị kẹt" => "Hải Quỳ",
        "Ơ Quỳ hả?" => "Leo",
        "Đại khái vậy! Ông mở" => "Hải Quỳ",
        "Đợi tí!!" => "Leo"
      },
      2 => {
        "K…Kohi…!!" => "Bully Quỳ",
        "Ớ? Quỳ! Cuối cùng" => "Kohi",
        "Quà….Quà giáng sinh muộn" => "Bully Quỳ",
        "Tối hôm qua….Tui" => "Bully Quỳ",
        "Bà mang nhầm quà chứ gì" => "Kohi",
        "Ừm…Đại khái là vậy" => "Bully Quỳ",
        "Thấy chưa Shylvie" => "Kohi",
        "Máy pha cà phê!! Lại còn" => "Kohi",
        "Hôm qua tính chơi khăm" => "Shylvie",
        "Mắc gì? Nhầm quà" => "Bully Quỳ",
        "Ừ, nhầm quà. Chắc là vậy rồi" => "Shylvie",
        "Những người còn lại thì sao" => "Bully Quỳ",
        "Ờm để nhớ xem" => "Shylvie",
        "Hửm? Ấp úng thế" => "Bully Quỳ",
        "Ừ đoán đi" => "Shylvie",
        "Ừm….Là...Gấu bông" => "Bully Quỳ",
        "Đúng là không thể giấu" => "Shylvie",
        "LÀ TAILS?!" => "Bully Quỳ",
        "Tui biết thừa là bà thích" => "Shylvie",
        "Không thừa nhận!" => "Bully Quỳ",
        "Không thừa nhận thì tui sẽ" => "Shylvie",
        "TUI THÍCH SỰ DỄ THƯƠNG" => "Bully Quỳ",
        "Aaaa, cảm giác này" => "Bully Quỳ"
      },
      3 => {},
      4 => {}
    }
    knitting_scene9_faces = {
      1 => {
        "Ông thấy sao?" => "Hải Quỳ",
        "GÌ CƠ?? CHIẾC KHIÊN HUYỀN THOẠI" => "Leo"
      },
      2 => {
        "Ừm! Chỉ là, tui hơi lo lắng" => "Hải Quỳ",
        "Mở ra xem đi Leo" => "Kohi",
        "Tui thấy ông dính với hình tượng" => "Kohi"
      },
      3 => {
        "X…Xin lỗi…ặc…Thật sự xin lỗi" => "Shylvie",
        "Phú bà đâu" => "Kohi"
      },
      4 => {
        "Happy Merry Chích Mớt" => "Hải Quỳ",
        "Nhí nhí, cho tớ hỏi" => "Hakase",
        "Ơ, tớ tưởng khăn choàng" => "Hakase",
        "À, xem nè!!" => "Hakase",
        "Ghê chứ sao không" => "Shylvie"
      }
    }
    knitting_scene12_faces = {
      "Ừa! Tui đi đây!! Nhớ chừa kem" => "Hải Quỳ"
    }
    nest = lambda do |commands, amount|
      commands.each { |command| command.instance_variable_set(:@indent, command.instance_variable_get(:@indent).to_i + amount) }
      commands
    end
    variable_branch = lambda do |variable_id, value, commands|
      [event_command(111, 0, [1, variable_id, 0, value, 0])] + nest.call(commands, 1) + [event_command(412, 0, [])]
    end
    switch_branch = lambda do |on_commands, off_commands|
      [event_command(111, 0, [0,52,0])] + nest.call(on_commands, 1) +
        [event_command(411, 0, [])] + nest.call(off_commands, 1) + [event_command(412, 0, [])]
    end
    compile_conditionals = lambda do |body, mode|
      markers = []
      body.each_with_index do |line, index|
        markers << [index, line] if line.match?(/\A\[\s*Nếu (?:không )?check tin nhắn của Momo/i)
      end
      if markers.length < 2
        compile.call(body, mode)
      else
        variants = {}
        markers.each_with_index do |(index, label), marker_index|
          finish = marker_index + 1 < markers.length ? markers[marker_index + 1][0] : body.length
          variants[label.match?(/Nếu không/i) ? :off : :on] = compile.call(body[(index + 1)...finish], mode)
        end
        switch_branch.call(variants[:on] || [], variants[:off] || [])
      end
    end
    target_sections = lambda do |lines, scene_number, mode|
      target_names.flat_map do |value, name|
        start_pattern = /\A#{heading_name.call(name)}\s+Cảnh #{scene_number}\z/i
        end_pattern = /\A(?:LEO|KOHI|SHYL(?:VIE|IVE)|HAKASE)\s+Cảnh #{scene_number}\z|\AHẾT CẢNH #{scene_number}/i
        body = section.call(lines, start_pattern, end_pattern)
        variable_branch.call(43, value, compile.call(body, mode))
      end
    end

    # Map037 — exact recipient-specific preparation scene for every gift.
    map37 = load_data("Data/Map037.rvdata2")
    page37 = map37.instance_variable_get(:@events)[1].instance_variable_get(:@pages).first
    list37 = page37.instance_variable_get(:@list)
    light_reset37 = "# WCF_MKT_PREP_LIGHT_RESET"
    list37.reject! do |command|
      command_code(command) == 355 && command_parameters(command)[0].to_s.include?(light_reset37)
    end
    fadein37 = list37.index { |command| command_code(command) == 222 }
    raise "Map037 fade-in marker missing" unless fadein37
    list37.insert(fadein37, event_command(355, 0, [
      "$game_map.screen.start_tone_change(Tone.new(0,0,0,0),0); map_effects.set_tone(0,0,0,0,0) #{light_reset37}"
    ]))
    end37 = list37.index { |command| command_code(command) == 225 }
    raise "Map037 preparation boundary missing" unless end37
    setup_end37 = (0...end37).find do |i|
      command_code(list37[i]) == 121 && command_parameters(list37[i])[0, 3] == [51, 51, 0]
    end
    raise "Map037 setup boundary missing" unless setup_end37
    start37 = setup_end37 + 1
    prep_by_gift = {}
    routes.each do |gift, lines|
      prep_by_gift[gift] = target_sections.call(lines, 6, :bedroom)
    end
    prep = [
      event_command(355, 0, ["$game_variables[43]=2 unless (1..4).include?($game_variables[43])"]),
      event_command(355, 0, ["# MKT_ALL_GIFT_PREP"])
    ] + prep_by_gift.flat_map { |gift, commands| variable_branch.call(42, gift, commands) }
    page37.instance_variable_set(:@list, list37[0...start37] + prep + list37[end37..-1])
    map37.instance_variable_set(:@note, "[lighting off]\r\n<full lock parallax>\r\n<tile lock parallax>\r\nSupermarket route preparation; 4 gifts x 4 recipients")
    save_data("Data/Map037.rvdata2", map37)

    # Map038 — full authored Scene 9 for all twelve remaining combinations.
    map38 = load_data("Data/Map038.rvdata2")
    page38 = map38.instance_variable_get(:@events)[7].instance_variable_get(:@pages).first
    list38 = page38.instance_variable_get(:@list)
    phone_text = list38.index { |command| command_code(command) == 401 && command_parameters(command)[0].to_s.include?("Đột nhiên điện thoại") }
    phone_start = phone_text && phone_text.downto(0).find { |i| command_code(list38[i]) == 101 }
    gift_start = list38.index { |command| command_code(command) == 355 && command_parameters(command)[0] == "# MKT_ALL_GIFT_SCENE9" }
    unless gift_start
      gift_text = list38.index { |command| command_code(command) == 401 && command_parameters(command)[0].to_s.include?("sự kiện chính") }
      gift_start = gift_text && gift_text.downto(0).find { |i| command_code(list38[i]) == 111 && command_parameters(list38[i])[0,2] == [1,43] }
    end
    raise "Map038 gift boundaries missing" unless gift_start && phone_start
    scene9_by_gift = {}
    routes.each do |gift, lines|
      if gift == 1
        scene9_by_gift[gift] = target_names.flat_map do |value, name|
          body = section.call(lines,
            /\A#{heading_name.call(name)}\s+Cảnh 9\z/i,
            /\A(?:LEO|KOHI|SHYL(?:VIE|IVE)|HAKASE)\s+Cảnh 9\z|\AHẾT CẢNH 9/i)
          body = body.map { |line| value == 3 ? line.sub("cho ông đấy", "cho bà đấy") : line }
          variable_branch.call(43, value, compile_conditionals.call(body, :party))
        end
      elsif gift == 3
        scene9_by_gift[gift] = target_names.flat_map do |value, name|
          body = section.call(lines,
            /\A#{heading_name.call(name)}\s+Cảnh 9\z/i,
            /\A(?:LEO|KOHI|SHYL(?:VIE|IVE)|HAKASE)\s+Cảnh 9\z|\AHẾT CẢNH 9/i)
          compiled = compile.call(body, :party)
          apply_face_overrides.call(compiled, knitting_scene9_faces.fetch(value))
          variable_branch.call(43, value, compiled)
        end
      elsif gift == 4
        scene9_by_gift[gift] = target_names.flat_map do |value, name|
          body = section.call(lines,
            /\A#{heading_name.call(name)}\s+Cảnh 9\z/i,
            /\A(?:LEO|KOHI|SHYL(?:VIE|IVE)|HAKASE)\s+Cảnh 9\z|\AHẾT CẢNH 9/i)
          compiled = compile.call(body, :party)
          apply_face_overrides.call(compiled, lock_scene9_faces.fetch(value))
          variable_branch.call(43, value, compiled)
        end
      else
        scene9_by_gift[gift] = target_sections.call(lines, 9, :party)
      end
    end
    all_gifts = [event_command(355, 0, ["# MKT_ALL_GIFT_SCENE9"])] + scene9_by_gift.flat_map { |gift, commands| variable_branch.call(42, gift, commands) }
    page38.instance_variable_set(:@list, list38[0...gift_start] + all_gifts + list38[phone_start..-1])
    map38.instance_variable_set(:@note, "<full lock parallax>\r\n<tile lock parallax>\r\nSupermarket Christmas party; 16 authored gift/recipient branches")
    save_data("Data/Map038.rvdata2", map38)

    # Map039 — preserve the completed coffee epilogues, add authored Scene 13
    # for cookware/lockpick, and the common ending scene for knitting.
    map39 = load_data("Data/Map039.rvdata2")
    page39 = map39.instance_variable_get(:@events)[1].instance_variable_get(:@pages).first
    list39 = page39.instance_variable_get(:@list)
    light_reset39 = "# WCF_MKT_EPILOGUE_LIGHT_RESET"
    list39.reject! do |command|
      command_code(command) == 355 && command_parameters(command)[0].to_s.include?(light_reset39)
    end
    fadein39 = list39.index { |command| command_code(command) == 222 }
    raise "Map039 fade-in marker missing" unless fadein39
    list39.insert(fadein39, event_command(355, 0, [
      "$game_map.screen.start_tone_change(Tone.new(0,0,0,0),0); map_effects.set_tone(0,0,0,0,0) #{light_reset39}"
    ]))
    finish39 = list39.index { |command| command_code(command) == 355 && command_parameters(command)[0].to_s.include?("GlobalGallery.unlock") }
    start39 = list39.index { |command| command_code(command) == 355 && command_parameters(command)[0] == "# MKT_ALL_GIFT_EPILOGUES" }
    start39 ||= list39.index { |command| command_code(command) == 111 && command_parameters(command)[0,2] == [1,43] }
    raise "Map039 epilogue boundaries missing" unless start39 && finish39
    epilogues = {}
    coffee_scene12 = section.call(routes[1], /\ACẢNH 12\z/i, /\AHẾT CẢNH 12/i)
    epilogues[1] = target_names.flat_map do |value, name|
      body = section.call(coffee_scene12,
        /\A#{heading_name.call(name)}\z/i,
        /\A(?:LEO|KOHI|SHYL(?:VIE|IVE)|HAKASE)\z|\AHẾT CẢNH 12/i)
      variable_branch.call(43, value, compile_conditionals.call(body, :party))
    end
    epilogues[2] = target_sections.call(routes[2], 13, :party)
    scarf_body = section.call(routes[3], /\ACẢNH 12\z/i, /\AHẾT CẢNH 12/i)
    scarf_commands = compile.call(scarf_body, :party)
    apply_face_overrides.call(scarf_commands, knitting_scene12_faces)
    epilogues[3] = target_names.keys.flat_map { |target| variable_branch.call(43, target, Marshal.load(Marshal.dump(scarf_commands))) }
    epilogues[4] = target_names.flat_map do |value, name|
      body = section.call(routes[4],
        /\A#{heading_name.call(name)}\s+Cảnh 13\z/i,
        /\A(?:LEO|KOHI|SHYL(?:VIE|IVE)|HAKASE)\s+Cảnh 13\z|\AHẾT CẢNH 13/i)
      compiled = compile.call(body, :party)
      if value == 2
        # This ending is narrated while Bully Quỳ is in control (the text
        # refers to Dahria in third person and Shylvie addresses Bully Quỳ).
        compiled.each do |command|
          next unless command_code(command) == 101
          params = command_parameters(command)
          if params[0] == actors["Hải Quỳ"][1]
            command.instance_variable_set(:@parameters,
              [actors["Bully Quỳ"][1], actors["Bully Quỳ"][2], 0, 2])
          end
        end
      end
      apply_face_overrides.call(compiled, lock_scene13_faces.fetch(value))
      variable_branch.call(43, value, compiled)
    end
    epilogue_commands = [event_command(355, 0, ["# MKT_ALL_GIFT_EPILOGUES"])] + epilogues.flat_map { |gift, commands| variable_branch.call(42, gift, commands) }
    gallery_names = %w[COFFEE COOKWARE KNITTING LOCK]
    finish = [
      event_command(355, 0, ["id=10+($game_variables[42]-1)*4+($game_variables[43]-1); GlobalGallery.unlock(id)"]),
      event_command(355, 0, ["g=%w[COFFEE COOKWARE KNITTING LOCK][$game_variables[42]-1]||\"COFFEE\"; t=%w[LEO KOHI SHYLVIE HAKASE][$game_variables[43]-1]||\"KOHI\"; EndingPresentation.show_gallery(\"ED_MKT_#{'#{'}g}_#{'#{'}t}\",240)"]),
      event_command(121, 0, [46,46,0]),
      event_command(355, 0, ["$game_variables[41]=2+($game_variables[42]-1)*4+($game_variables[43]-1)"]),
      event_command(201, 0, [0,36,8,6,2,2]), event_command(0,0,[])
    ]
    page39.instance_variable_set(:@list, list39[0...start39] + epilogue_commands + finish)
    map39.instance_variable_set(:@note, "<full lock parallax>\r\n<tile lock parallax>\r\nSupermarket route epilogues; Gallery 10..25; Hint 2..17")
    save_data("Data/Map039.rvdata2", map39)

    # Map036 — all 16 authored Bully Quỳ ending hints.
    hint_lines = expand.call("After Ending Hint")
    hint_route_names = {1 => "ROUTE MÁY CÀ PHÊ", 2 => "ROUTE DAO VÀ CHẢO", 3 => "ROUTE KHĂN LEN", 4 => "ROUTE BỘ PHÁ KHÓA"}
    map36 = load_data("Data/Map036.rvdata2")
    router = map36.instance_variable_get(:@events)[1]
    pages = router.instance_variable_get(:@pages)
    pages.reject! do |page|
      condition = page.instance_variable_get(:@condition)
      condition && condition.instance_variable_get(:@variable_valid) &&
        condition.instance_variable_get(:@variable_id).to_i == 41 &&
        condition.instance_variable_get(:@variable_value).to_i >= 2
    end
    hint_route_names.each do |gift, route_heading|
      route_start = hint_lines.index(route_heading)
      raise "Ending hint route missing: #{route_heading}" unless route_start
      route_end = ((route_start + 1)...hint_lines.length).find { |i| hint_lines[i].start_with?("ROUTE ") } || hint_lines.length
      target_names.each do |target, name|
        target_start = ((route_start + 1)...route_end).find { |i| hint_lines[i] == name.upcase }
        raise "Ending hint missing: #{route_heading}/#{name}" unless target_start
        target_end = ((target_start + 1)...route_end).find { |i| target_names.values.map(&:upcase).include?(hint_lines[i]) } || route_end
        texts = hint_lines[(target_start + 1)...target_end].reject { |line| line.start_with?("[") || line.strip.empty? }
        commands = [event_command(355,0,["$game_player.transparent=true"]), event_command(122,0,[40,40,0,0,2]), event_command(117,0,[5])]
        texts.each { |text| commands.concat(face_message.call("BullyQuy_Thuongphuc_Emote", 1, text)) }
        gallery = "ED_MKT_#{gallery_names[gift-1]}_#{target_names[target].upcase}"
        commands.concat([event_command(117,0,[3]), event_command(230,0,[60]), event_command(355,0,["HAIQUY_TITLE.set_ending_background(\"#{gallery}\")"]), event_command(354,0,[])])
        hint_id = 2 + (gift - 1) * 4 + (target - 1)
        pages << page_from_template(router, commands, trigger: 3, priority: 0, variable_id: 41, variable_value: hint_id)
      end
    end
    router.instance_variable_set(:@pages, pages)
    save_data("Data/Map036.rvdata2", map36)
    integrate_picture_gallery_assets
    puts "SUPERMARKET_ROUTES_COMPLETE|gifts=4|targets=4|combinations=16|hints=2..17|gallery=10..25"
  end

  # Remove the pre-compact coffee preparation block which was accidentally
  # retained before the generated 4x4 route matrix. Also make Map037 own its
  # visual handoff: Map040 blacks out Game_Screen, while an enabled KUL shadow
  # is a separate overlay and otherwise survives the no-fade transfer.
  def repair_map037_prep_and_fade
    path = "Data/Map037.rvdata2"
    map = load_data(path)
    event = (map.instance_variable_get(:@events) || {})[1]
    page = event && (event.instance_variable_get(:@pages) || []).first
    raise "Map037 E001 page 1 missing" unless page
    list = page.instance_variable_get(:@list) || []

    marker = list.index do |command|
      command_code(command) == 355 && command_parameters(command)[0] == "# MKT_ALL_GIFT_PREP"
    end
    finish = list.index { |command| command_code(command) == 225 }
    setup_end = list.index do |command|
      command_code(command) == 121 && command_parameters(command)[0, 3] == [51, 51, 0]
    end
    raise "Map037 generated preparation marker missing" unless marker
    raise "Map037 preparation finish missing" unless finish && finish > marker
    raise "Map037 setup boundary missing" unless setup_end && setup_end < marker

    clamp = event_command(355, 0, ["$game_variables[43]=2 unless (1..4).include?($game_variables[43])"])
    generated = list[marker...finish]
    page.instance_variable_set(:@list,
      list[0..setup_end] + [clamp] + generated + list[finish..-1])

    note_lines = map.instance_variable_get(:@note).to_s.split(/\r?\n/)
    note_lines.reject! { |line| line.match?(/\A\[lighting\s+/i) }
    note_lines.unshift("[lighting off]")
    map.instance_variable_set(:@note, note_lines.join("\r\n"))
    save_data(path, map)
    puts "MAP037_PREP_REPAIRED|legacy_removed=true|target_clamp=1|kul=off|fadein=event222"
  end

  # Fade the room completely before swapping E003 to the sleeping charset,
  # then restore Game_Screen brightness after the phone timeline advances and
  # before the wake-up CG/dialogue begins. This avoids both the one-frame pose
  # flash and the permanently black wake-up sequence.
  def repair_map037_sleep_transition
    path = "Data/Map037.rvdata2"
    map = load_data(path)
    event = (map.instance_variable_get(:@events) || {})[1]
    page = event && (event.instance_variable_get(:@pages) || []).first
    raise "Map037 E001 page 1 missing" unless page
    list = page.instance_variable_get(:@list) || []

    sleep_script = '$game_map.events[3].set_graphic("$HaiQuy_Sleep_Night",0)'
    sleep_index = list.index do |command|
      command_code(command) == 355 && command_parameters(command)[0] == sleep_script
    end
    raise "Map037 sleeping graphic command missing" unless sleep_index

    fadeout_index = list.index { |command| command_code(command) == 221 && list.index(command) >= sleep_index - 1 }
    unless fadeout_index && (fadeout_index - sleep_index).abs == 1
      raise "Map037 sleep Fade Out is not adjacent to the graphic swap"
    end
    if sleep_index < fadeout_index
      list[sleep_index], list[fadeout_index] = list[fadeout_index], list[sleep_index]
      sleep_index, fadeout_index = fadeout_index, sleep_index
    end

    phone_index = list.index do |command|
      command_code(command) == 117 && command_parameters(command)[0] == 18
    end
    raise "Map037 Christmas phone timeline call missing" unless phone_index
    while list[phone_index + 1] && command_code(list[phone_index + 1]) == 222
      list.delete_at(phone_index + 1)
    end
    list.insert(phone_index + 1, event_command(222, 0, []))

    page.instance_variable_set(:@list, list)
    save_data(path, map)
    puts "MAP037_SLEEP_TRANSITION|fade_before_graphic=true|wake_fadein=1"
  end

  # Build Hải Quỳ's explorable bedroom from compact B3331-B3376 and connect
  # it to Map022's existing RegionStairs route.
  def create_haiquy_home_bedroom
    map_id = 41
    map22 = load_data("Data/Map022.rvdata2")
    events22 = map22.instance_variable_get(:@events) || {}
    stair = events22[2]
    template = events22[10] || events22.values.compact.first
    raise "Map022 E002 stair event missing" unless stair
    raise "Map022 has no interaction event template" unless template

    stair_page = (stair.instance_variable_get(:@pages) || []).first
    stair_list = stair_page && (stair_page.instance_variable_get(:@list) || [])
    route = stair_list.find { |command| command_code(command) == 205 }
    raise "Map022 E002 stair movement route missing" unless route
    cleanup = "RegionStairs.disable; " \
      "$game_player.instance_variable_set(:@through,false); " \
      "$game_player.instance_variable_set(:@move_speed,4)"
    stair_page.instance_variable_set(:@list, [
      event_command(111, 0, [6, -1, 4]),
      event_command(355, 1, ["RegionStairs.enable"]),
      route,
      event_command(355, 1, [cleanup]),
      event_command(201, 1, [0, map_id, 13, 13, 8, 0]),
      event_command(411, 0, []),
      event_command(355, 1, [cleanup]),
      event_command(412, 0, []),
      event_command(0, 0, [])
    ])
    stair.instance_variable_set(:@name, "TRANSFER-HOME-UPSTAIRS-BEDROOM [E002]")
    save_data("Data/Map022.rvdata2", map22)

    base = Marshal.load(Marshal.dump(load_data("Data/Map037.rvdata2")))
    base.instance_variable_set(:@display_name, "Phòng Hải Quỳ ở nhà")
    base.instance_variable_set(:@width, 21)
    base.instance_variable_set(:@height, 17)
    base.instance_variable_set(:@tileset_id, 7)
    base.instance_variable_set(:@parallax_name, "HQ_Room_Morning_Base")
    base.instance_variable_set(:@parallax_loop_x, false)
    base.instance_variable_set(:@parallax_loop_y, false)
    base.instance_variable_set(:@parallax_sx, 0)
    base.instance_variable_set(:@parallax_sy, 0)
    base.instance_variable_set(:@parallax_show, false)
    base.instance_variable_set(:@note,
      "[lighting off]\r\n<full lock parallax>\r\n<tile lock parallax>\r\n" \
      "Hải Quỳ home bedroom exploration; compact B3331-B3376")
    base.instance_variable_set(:@autoplay_bgm, false)
    base.instance_variable_set(:@autoplay_bgs, false)
    base.instance_variable_set(:@encounter_list, [])

    # Tiles 250/251 in Tileset 7 are the invisible passable/blocking pair used
    # by the other parallax exploration maps in this project.
    table = blank_table(21, 17, 4)
    17.times { |y| 21.times { |x| table_set(table, x, y, 2, 251) } }
    walkable = []
    (4..12).each { |y| (4..14).each { |x| walkable << [x, y] } }
    (13..14).each { |y| (12..13).each { |x| walkable << [x, y] } }
    walkable.uniq.each { |x, y| table_set(table, x, y, 2, 250) }
    # The game-station interaction has three authored responses for approach
    # from below/left/right. Block its upper approach so the fallback cannot
    # silently treat a downward-facing player as the left-side response.
    table_set(table, 13, 8, 2, 251)
    base.instance_variable_set(:@data, table)

    hq = lambda do |paragraphs, indent = 0, face_index = 1|
      commands = wrapped_message_commands(Array(paragraphs), width: 30, indent: indent)
      commands.each do |command|
        next unless command_code(command) == 101
        command.instance_variable_set(:@parameters,
          ["HaiQuy_Thuongphuc_Emote", face_index, 0, 2])
      end
      commands
    end
    make_page = lambda do |commands, self_switch_name = nil, trigger = 0, priority = 1|
      page_from_template(template, commands, trigger: trigger, priority: priority,
        self_switch: self_switch_name)
    end
    events = {}
    next_id = 1
    add_event = lambda do |name, x, y, pages|
      events[next_id] = event_from_pages(template, next_id, name, x, y, pages)
      next_id += 1
    end
    add_one = lambda do |name, x, y, paragraphs, face_index = 1|
      add_event.call(name, x, y, [make_page.call(hq.call(paragraphs, 0, face_index))])
    end
    add_twice = lambda do |name, x, y, first, second|
      first_commands = hq.call(first) + [event_command(123, 0, ["A", 0])]
      add_event.call(name, x, y, [
        make_page.call(first_commands),
        make_page.call(hq.call(second), "A")
      ])
    end

    arrival = [
      event_command(355, 0, [cleanup]),
      event_command(355, 0, ["$game_player.transparent=false"]),
      event_command(355, 0, ["layer(41,0,[\"HQ_Room_Morning_Top\",0,0,255,200,0,0,0])"]),
      event_command(655, 0, ["refresh_layers"]),
      event_command(117, 0, [3]),
      event_command(123, 0, ["A", 0])
    ]
    add_event.call("SCN-HQ-BEDROOM-ARRIVAL-CLEANUP", 0, 0, [
      make_page.call(arrival, nil, 3, 0),
      make_page.call([], "A", 0, 0)
    ])

    add_twice.call("LORE-HQ-POETRY-GIRL-FILE", 11, 4,
      ["“Cô Gái Thi Ca” – Câu chuyện kể về một nam sinh trung học từng là thần đồng sáng tác nhạc nhưng từ bỏ năng khiếu sau một biến cố. Cậu tham gia câu lạc bộ âm nhạc và gặp được một cô gái kỳ lạ có sở thích ăn các bảng nhạc. Cô nói rằng mỗi bản nhạc đều có hương vị riêng và yêu cầu nam sinh trung học phải viết những “món ăn mới” cho mình."],
      ["Có một tấm ảnh rơi ra từ tệp hồ sơ.",
       "Ảnh chụp chung của Hoàng Hà, Ánh Lam và Omega D-13."])
    add_twice.call("LORE-HQ-BERRY-POHTA-BOOK", 12, 4,
      ["“Berry Pohta” – Câu chuyện kể về một cô bé mồ côi sống cùng gia đình dì dượng. Vào sinh nhật lần thứ 11, cô bé phát hiện mình là một Rap Sư và được mời theo học tại hệ thống trường riêng biệt dành cho các Rap Sư tài năng."],
      ["Một tờ ghi chú rơi ra từ một cuốn sách.",
       "Cách để hoán đổi thân phận:",
       "Cách một: Dùng Brilliant Anchor để sao chép dữ liệu ADN.",
       "Ưu điểm: Tái tạo ngoại hình nhanh.",
       "Nhược điểm: Không có ký ức của chủ thể. Chỉ sử dụng ADN được sao chép tối đa ba lần.",
       "Cách hai: Trực tiếp nhai xương. Nên dùng cách này đối với “kẻ phản bội”.",
       "Ưu điểm: Lưu giữ được ký ức của chủ thể. ADN tồn tại vĩnh viễn, có thể dùng bất kỳ lúc nào.",
       "Nhược điểm: Mất một thời gian để hấp thụ. Phải uống thuốc ức chế để không bị chồng chéo ký ức."])
    add_one.call("PROP-HQ-DESKTOP", 13, 5,
      ["Máy tính bàn của mình. Nhắc mới nhớ, mình chưa chơi xong Dave The Diver thì phải?"])
    add_twice.call("PROP-HQ-RECORD-PLAYER-SWORDS", 14, 5,
      ["Đầu đĩa than được tặng bởi OniOnii."],
      ["Hai thanh kiếm được viết bùa chú diệt quái vật vực sâu được làm bởi Popo. Một quẹt là phát nổ."])
    add_one.call("LORE-HQ-FAMILY-PHOTO", 10, 4, ["Ảnh chụp gia đình mình."])
    add_twice.call("PROP-HQ-BEDSIDE-CABINET", 8, 4,
      ["Tủ kê đầu giường. Trong hộc tủ nhét đầy đồ ăn vặt."],
      ["Ảnh chân dung của mình hồi còn bé.",
       "OniOnii bảo màu tóc khi ấy của mình nhìn y đúc chị cả."])
    add_one.call("PROP-HQ-SHELL-BED", 8, 5, ["Giường ngủ vỏ sò."])
    add_one.call("PROP-HQ-GAME-TAPE-BOX", 4, 5,
      ["Thùng đựng băng game mà mình đã chơi."])

    directional = [
      event_command(111, 0, [6, -1, 8]),
      *hq.call(["Máy chơi game đầu tiên của mình được tặng bởi Popo."], 1),
      event_command(411, 0, []),
      event_command(111, 1, [6, -1, 6]),
      *hq.call(["Máy chơi game Polystation này mình mượn từ OniOnii."], 2),
      event_command(411, 1, []),
      *hq.call(["Laptop để mình ngồi viết tiểu thuyết."], 2),
      event_command(412, 1, []),
      event_command(412, 0, [])
    ]
    add_event.call("PROP-HQ-GAME-STATION-DIRECTIONAL", 13, 9,
      [make_page.call(directional)])
    add_one.call("PROP-HQ-WARDROBE", 7, 11, ["Tủ quần áo."])
    add_one.call("LORE-HQ-TRANSFORMATION-DEVICES", 4, 11, [
      "Tủ lưu trữ các thiết bị “biến hình” của mình.",
      "Trước khi có mỏ neo Brilliant Anchor mình toàn dùng mấy món này để hoán đổi thân phận.",
      "Xem nào, có bút bi biến hình, hộp phấn biến hình, nước hoa biến hình, son môi biến hình.",
      "Nước hoa biến hình là món xài vui nhất! Xịt xịt khắp người, múa may quay cuồng một xíu là hoán đổi cả cơ thể lẫn trang phục! Giống như ma pháp thiếu nữ biến hình vậy!",
      "Ngầu đét!"
    ])
    add_one.call("PROP-HQ-MAGICAL-GIRL-MODELS", 5, 11, [
      "Tủ lưu trữ mô hình gậy phép thuật của các series ma pháp thiếu nữ mà mình coi.",
      "Bao nhiêu tiền lương đổ hết vào đây…Nó đáng! Nó đáng!!"
    ])
    add_one.call("PROP-HQ-ROBOT-MODELS", 6, 11, [
      "Tủ trưng bày các mô hình người máy, robot.",
      "Ôi, mình là khách hàng thân thiết của cửa hàng bán mô hình gần Wanderer Office!",
      "Lần nào có sản phẩm mới họ cũng chào mời mình.",
      "Leo cảnh cáo mình bao lần rồi nhưng mình vẫn lén lút mua, hehe."
    ])
    add_one.call("PROP-HQ-WINTER-WARDROBE", 8, 11,
      ["Tủ quần áo mùa đông của mình."])
    add_one.call("LORE-HQ-TROPHIES", 9, 11, [
      "Tủ lưu trữ “chiến tích” mà mình chưa kịp gửi cho Poseidon.",
      "Bao gồm mắt, lưỡi, ngón tay, nội tạng của những “kẻ phản bội” mà mình đã thanh trừng đợt rồi.",
      "Để sau kỳ nghỉ làm báo cáo đầy đủ chi tiết vậy.",
      "Thanh trừng bọn này mệt khiếp."
    ], 5)

    exit_commands = [
      event_command(355, 0, [cleanup]),
      event_command(117, 0, [3]),
      # Return beside the foot of the stairs, not onto Region 63: stair mode is
      # deliberately OFF after leaving the bedroom.
      event_command(201, 0, [0, 22, 11, 28, 6, 0])
    ]
    add_event.call("TRANSFER-HQ-BEDROOM-DOWNSTAIRS", 13, 14,
      [make_page.call(exit_commands, nil, 1, 0)])
    base.instance_variable_set(:@events, events)
    save_data("Data/Map041.rvdata2", base)

    infos = load_data("Data/MapInfos.rvdata2")
    info = infos[map_id] || Marshal.load(Marshal.dump(infos[22] || infos.values.compact.first))
    info.instance_variable_set(:@name, "Phòng Hải Quỳ ở nhà")
    info.instance_variable_set(:@parent_id, 22)
    info.instance_variable_set(:@order,
      infos.values.compact.map { |entry| entry.instance_variable_get(:@order).to_i }.max + 1) unless infos[map_id]
    info.instance_variable_set(:@expanded, true)
    info.instance_variable_set(:@scroll_x, 0)
    info.instance_variable_set(:@scroll_y, 0)
    infos[map_id] = info
    save_data("Data/MapInfos.rvdata2", infos)
    puts "HQ_HOME_BEDROOM|Map022 E002 -> Map041|interactions=15|two_stage=4|stairs_cleanup=true"
  end

  # Build a conditional return list for maps shared by every Wanderer Office
  # variant. Variable 49 remembers which office map opened the room/kitchen.
  def wanderer_office_return_commands(x, y, indent = 0)
    [
      event_command(111, indent, [1, 49, 0, 38, 0]),
      event_command(201, indent + 1, [0, 38, x, y, 2, 0]),
      event_command(411, indent, []),
      event_command(111, indent + 1, [1, 49, 0, 39, 0]),
      event_command(201, indent + 2, [0, 39, x, y, 2, 0]),
      event_command(411, indent + 1, []),
      event_command(201, indent + 2, [0, 13, x, y, 2, 0]),
      event_command(412, indent + 1, []),
      event_command(412, indent, [])
    ]
  end

  # Install the private-room and kitchen entrances on every authored Wanderer
  # Office variant, and make all shared destinations return to that variant.
  def connect_wanderer_office_variants
    office_ids = [13, 38, 39]
    hub = load_data("Data/Map013.rvdata2")
    hub_events = hub.instance_variable_get(:@events) || {}

    # Every entrance records its source office immediately before transferring.
    [2, 3, 5, 6, 7, 8, 9, 10].each do |event_id|
      event = hub_events[event_id]
      raise "Map013 Wanderer entrance E#{event_id} missing" unless event
      (event.instance_variable_get(:@pages) || []).each do |page|
        list = page.instance_variable_get(:@list) || []
        list.reject! do |command|
          command_code(command) == 122 && command_parameters(command)[0, 2] == [49, 49]
        end
        rebuilt = []
        list.each do |command|
          rebuilt << event_command(122, command.instance_variable_get(:@indent),
            [49, 49, 0, 0, 13]) if command_code(command) == 201
          rebuilt << command
        end
        page.instance_variable_set(:@list, rebuilt)
      end
    end
    hub.instance_variable_set(:@events, hub_events)
    save_data("Data/Map013.rvdata2", hub)

    # The kitchen is shared, so both floor exits dynamically return to the map
    # that the player actually came from. Rebuilding these tiny pages also
    # makes this operation idempotent after repeated generator runs.
    kitchen = load_data("Data/Map014.rvdata2")
    kitchen_events = kitchen.instance_variable_get(:@events) || {}
    {2 => [24, 11], 3 => [23, 11]}.each do |event_id, (x, y)|
      event = kitchen_events[event_id]
      raise "Map014 kitchen exit E#{event_id} missing" unless event
      page = (event.instance_variable_get(:@pages) || []).first
      page.instance_variable_set(:@list, [
        event_command(111, 0, [6, -1, 2]),
        *wanderer_office_return_commands(x, y, 1),
        event_command(411, 0, []),
        event_command(412, 0, []),
        event_command(0, 0, [])
      ])
      event.instance_variable_set(:@name,
        "TRANSFER-KITCHEN-TO-WANDERER-%s [E%03d]" % [event_id == 2 ? "A" : "B", event_id])
    end
    kitchen.instance_variable_set(:@events, kitchen_events)
    save_data("Data/Map014.rvdata2", kitchen)

    # Clone the authored normal-office doors, including their graphics and door
    # animations. High stable IDs avoid colliding with the cutscene events.
    source_to_variant_id = {
      2 => 115, 3 => 116, 5 => 110, 6 => 111,
      7 => 112, 8 => 113, 9 => 114, 10 => 117
    }
    [38, 39].each do |map_id|
      map = load_data(format("Data/Map%03d.rvdata2", map_id))
      events = map.instance_variable_get(:@events) || {}
      source_to_variant_id.each do |source_id, event_id|
        occupied = events[event_id]
        if occupied && !occupied.instance_variable_get(:@name).to_s.include?("WCF-OFFICE-VARIANT")
          raise "Map%03d E%03d is occupied by authored content" % [map_id, event_id]
        end
        event = Marshal.load(Marshal.dump(hub_events.fetch(source_id)))
        event.instance_variable_set(:@id, event_id)
        event.instance_variable_set(:@name,
          "WCF-OFFICE-VARIANT-%03d-%s [E%03d]" %
            [map_id, event.instance_variable_get(:@name).to_s.sub(/ \[E\d+\]\z/, ""), event_id])
        (event.instance_variable_get(:@pages) || []).each do |page|
          (page.instance_variable_get(:@list) || []).each do |command|
            next unless command_code(command) == 122 && command_parameters(command)[0, 2] == [49, 49]
            command.instance_variable_set(:@parameters, [49, 49, 0, 0, map_id])
          end
        end
        events[event_id] = event
      end
      map.instance_variable_set(:@events, events)
      save_data(format("Data/Map%03d.rvdata2", map_id), map)
    end

    # Private rooms are shared by all variants as well.
    {42 => 16, 43 => 20, 44 => 24, 45 => 28, 46 => 32}.each do |map_id, return_x|
      map = load_data(format("Data/Map%03d.rvdata2", map_id))
      exit_event = (map.instance_variable_get(:@events) || {}).values.compact.find do |event|
        event.instance_variable_get(:@name).to_s.include?("TRANSFER-ROOM-TO-WANDERER")
      end
      raise "Map%03d private-room exit missing" % map_id unless exit_event
      page = (exit_event.instance_variable_get(:@pages) || []).first
      list = page.instance_variable_get(:@list) || []
      prefix = list.take_while { |command| command_code(command) != 111 && command_code(command) != 201 }
      page.instance_variable_set(:@list,
        prefix + wanderer_office_return_commands(return_x, 6) + [event_command(0, 0, [])])
      save_data(format("Data/Map%03d.rvdata2", map_id), map)
    end

    system = load_data("Data/System.rvdata2")
    variables = system.instance_variable_get(:@variables)
    variables[49] = "WANDERER_OFFICE_RETURN_MAP"
    system.instance_variable_set(:@variables, variables)
    save_data("Data/System.rvdata2", system)
    puts "WANDERER_OFFICE_VARIANTS|offices=#{office_ids.join(',')}|rooms=42..46|kitchen=14|return_var=49"
  end

  # Add the shared meeting/crafting rooms to every current Wanderer Office
  # variant without rebuilding any office map. Map061 is the normal meeting
  # room, Map062 its Movie Night state, and Map063 the authored crafting room.
  def create_wanderer_meeting_and_crafting_rooms
    office_ids = [13, 38, 39, 48, 50, 52, 54]
    movie_offices = [38, 48, 54]
    meeting_normal_id, meeting_movie_id, crafting_id = 61, 62, 63
    return_var = 49
    meeting_entrance = [13, 39]
    crafting_entrance = [37, 37]

    hub = load_data("Data/Map013.rvdata2")
    template = hub.instance_variable_get(:@events).values.compact.first
    room_source = load_data("Data/Map042.rvdata2")
    cleanup = "RegionStairs.disable; " \
      "$game_player.instance_variable_set(:@through,false); " \
      "$game_player.instance_variable_set(:@move_speed,4); " \
      "$game_player.transparent=false; ms_pro_cam_focus_on(-1); " \
      "ms_pro_cam_unlock_camera"

    make_page = lambda do |commands, trigger = 0, priority = 1|
      page = page_from_template(template, commands, trigger: trigger, priority: priority)
      graphic = page.instance_variable_get(:@graphic)
      if graphic
        graphic.instance_variable_set(:@tile_id, 0)
        graphic.instance_variable_set(:@character_name, "")
        graphic.instance_variable_set(:@character_index, 0)
      end
      page
    end
    make_event = lambda do |id, name, x, y, commands, trigger = 0, priority = 1|
      event_from_pages(template, id, name, x, y,
        [make_page.call(commands, trigger, priority)])
    end
    face_text = lambda do |text, indent = 0, face_index = 1|
      commands = wrapped_message_commands([text], width: 30, indent: indent)
      commands.each do |command|
        next unless command_code(command) == 101
        command.instance_variable_set(:@parameters,
          ["HaiQuy_Thuongphuc_Emote", face_index, 0, 2])
      end
      commands
    end
    table_for = lambda do |width, height, rectangles|
      table = blank_table(width, height, 4)
      height.times { |y| width.times { |x| table_set(table, x, y, 2, 251) } }
      rectangles.each do |x1, x2, y1, y2|
        (y1..y2).each do |y|
          (x1..x2).each { |x| table_set(table, x, y, 2, 250) }
        end
      end
      table
    end
    return_commands = lambda do |x, y|
      build = nil
      build = lambda do |remaining, indent|
        map_id = remaining.first
        commands = [event_command(111, indent, [1, return_var, 0, map_id, 0]),
          event_command(201, indent + 1, [0, map_id, x, y, 2, 0]),
          event_command(411, indent, [])]
        if remaining.length > 1
          commands.concat(build.call(remaining.drop(1), indent + 1))
        else
          commands << event_command(201, indent + 1, [0, 13, x, y, 2, 0])
        end
        commands << event_command(412, indent, [])
        commands
      end
      build.call(office_ids, 0)
    end
    room_shell = lambda do |map_id, title, parallax, width, height, walkable|
      map = Marshal.load(Marshal.dump(room_source))
      map.instance_variable_set(:@display_name, title)
      map.instance_variable_set(:@width, width)
      map.instance_variable_set(:@height, height)
      map.instance_variable_set(:@tileset_id, 7)
      map.instance_variable_set(:@data, table_for.call(width, height, walkable))
      map.instance_variable_set(:@parallax_name, parallax)
      map.instance_variable_set(:@parallax_loop_x, false)
      map.instance_variable_set(:@parallax_loop_y, false)
      map.instance_variable_set(:@parallax_sx, 0)
      map.instance_variable_set(:@parallax_sy, 0)
      map.instance_variable_set(:@parallax_show, true)
      map.instance_variable_set(:@note,
        "[lighting off]\r\n<full lock parallax>\r\n<tile lock parallax>\r\n" \
        "Shared Wanderer room; source office in Variable 49")
      map.instance_variable_set(:@autoplay_bgm, false)
      map.instance_variable_set(:@autoplay_bgs, false)
      map.instance_variable_set(:@encounter_list, [])
      map.instance_variable_set(:@events, {})
      map
    end

    # Meeting rooms share geometry but retain their two authored visuals.
    [[meeting_normal_id, "Phòng họp", "Meeting_Room_Base"],
     [meeting_movie_id, "Phòng họp — Movie Night", "Meeting Room_MovieNight_base"]].each do |map_id, title, parallax|
      map = room_shell.call(map_id, title, parallax, 36, 25, [[11, 23, 5, 17]])
      events = {}
      events[1] = make_event.call(1, "SCN-MEETING-ROOM-INIT", 0, 0,
        [event_command(355, 0, [cleanup]), event_command(214, 0, [])], 3, 0)
      events[2] = make_event.call(2, "TRANSFER-MEETING-TO-WANDERER", 17, 17,
        [event_command(355, 0, [cleanup]), *return_commands.call(13, 38)], 1, 0)
      map.instance_variable_set(:@events, events)
      save_data("Data/Map%03d.rvdata2" % map_id, map)
    end

    crafting = room_shell.call(crafting_id, "Phòng chế tạo", "Crafting_Room_Base",
      34, 24, [[4, 27, 3, 19]])
    crafting_events = {}
    crafting_events[1] = make_event.call(1, "SCN-CRAFTING-ROOM-INIT", 0, 0,
      [event_command(355, 0, [cleanup]), event_command(214, 0, [])], 3, 0)
    crafting_events[2] = make_event.call(2, "TRANSFER-CRAFTING-TO-WANDERER", 4, 10,
      [event_command(355, 0, [cleanup]), *return_commands.call(37, 36)], 1, 0)
    next_event_id = 3
    add_interaction = lambda do |name, coordinates, text|
      coordinates = [coordinates] unless coordinates.first.is_a?(Array)
      x, y = coordinates.first
      source_id = next_event_id
      crafting_events[source_id] = make_event.call(source_id, name, x, y,
        face_text.call(text))
      next_event_id += 1
      coordinates.drop(1).each do |alias_x, alias_y|
        alias_id = next_event_id
        crafting_events[alias_id] = make_event.call(alias_id, "#{name}-ALIAS",
          alias_x, alias_y,
          [event_command(355, 0, ["$game_map.events[#{source_id}].start"])] )
        next_event_id += 1
      end
    end
    range_coords = lambda do |x1, x2, y|
      (x1..x2).map { |x| [x, y] }
    end
    crafting_specs = [
      ["PROP-CRAFT-SPARE-PARTS", [5,9], "Kệ phụ tùng thay thế. Hộp đựng nhãn cầu nhân tạo của mình được để ở đây."],
      ["PROP-CRAFT-BIO-SAMPLES", [6,9], "Kệ bảo quản mẫu sinh học. Ồ, cánh tay phải của mình được bảo quản tốt thế!"],
      ["PROP-CRAFT-DRAGON-MATERIAL", [7,9], "Kệ bảo quản vảy và sừng rồng để chế tạo thuốc tăng tốc."],
      ["PROP-CRAFT-FROZEN-ORANGE", [8,9], "Kệ nước cam đông lạnh."],
      ["PROP-CRAFT-NETHERVOID-PIPE", range_coords.call(5,6,4), "Ống dẫn năng lượng Nethervoid."],
      ["PROP-CRAFT-WEAPON-BENCH", range_coords.call(7,9,5), "Bàn chế tạo vũ khí. Mình hay nằm ngủ ở đây vì bàn này mát lắm luôn."],
      ["PROP-CRAFT-NETHERVOID-PELLETS", [10,4], "Tủ dự trữ năng lượng Nethervoid dạng viên nén. Mình hay lấy vài viên để nạp vô găng tay Ruby Moon."],
      ["PROP-CRAFT-NETHERVOID-WEAPONS", [11,4], "Vũ khí hỗ trợ ở văn phòng đa phần đều sử dụng viên nén năng lượng Nethervoid. Không những tiết kiệm tối đa ma lực mà còn hỗ trợ người sử dụng gây ra sát thương khủng khiếp."],
      ["PROP-CRAFT-NETHERVOID-VIBRANIUM", [12,4], "Tủ dự trữ hợp chất năng lượng Nethervoid-Vibranium dạng lỏng đựng trong các lọ nhỏ. Chúng thường được sử dụng để gia tăng độ bền và độ cứng cho vũ khí. Có thể dùng để ném trực tiếp như bom sinh học, khiến cho sinh vật hữu cơ bị ném trúng tan chảy thành đống bầy nhầy."],
      ["PROP-CRAFT-UNIT4-CHARGER", [13,4], "Buồng sạc điện của UNIT 4 SRA-FL-04, loại mech hỗ trợ dạng drone không người lái."],
      ["PROP-CRAFT-UNIT9-RX36", [14,4], "Buồng sạc điện của UNIT 9 SRA-RX-36, loại mech tác chiến được trang bị hai khẩu pháo nòng dài trên lưng cùng các ụ súng liên thanh ở hai cánh tay."],
      ["PROP-CRAFT-MECH-ACTIVATE", [15,4], "Nút kích hoạt UNIT 9 SRA-RX-36 và UNIT 9 SRA-FX-67."],
      ["PROP-CRAFT-UNIT9-FX67", [16,4], "Buồng sạc điện của UNIT 9 SRA-FX-67, loại mech tác chiến được trang bị kiếm và khiên được tráng một lớp Nethervoid có khả năng chống ăn mòn dị thường, hấp thụ và phản lại mọi đòn tấn công kể cả phép thuật."],
      ["PROP-CRAFT-THEOSPHOROS", [17,5], "Bình năng lượng Theosphoros đã tinh chế được nối vào buồng hồi phục của Kohi."],
      ["PROP-CRAFT-KOHI-POD", [18,6], "Buồng hồi phục của Kohi. Thơm mùi cà phê."],
      ["PROP-CRAFT-SHYLVIE-POD", [19,6], "Buồng hồi phục của Shylvie. Cũng dùng năng lượng Theosphoros để hồi phục."],
      ["PROP-CRAFT-ABYSSALNITE", [20,6], "Trong kia là bình năng lượng Abyssalnite đã tinh chế được nối vào buồng hồi phục của mình."],
      ["PROP-CRAFT-HAIQUY-POD", [21,6], "Buồng hồi phục của mình. Abyssalnite là chất kịch độc đối với các thành viên còn lại."],
      ["PROP-CRAFT-LUMINIDITE", [22,6], "Trong kia là bình năng lượng Luminidite nguyên chất được nối vào buồng hồi phục của Leo."],
      ["PROP-CRAFT-LEO-POD", [23,6], "Buồng hồi phục của Leo. Còn kia là bình năng lượng Rubinite đặc chế riêng của Hakase."],
      ["PROP-CRAFT-HAKASE-POD", [24,6], "Buồng hồi phục của Hakase. Thơm hương hạt dẻ nướng."],
      ["PROP-CRAFT-EMPTY-ENERGY", [25,6], "Bình năng lượng trống không được nối vào buồng hồi phục dự phòng."],
      ["PROP-CRAFT-SPARE-POD", [26,6], "Buồng hồi phục dự phòng."],
      ["PROP-CRAFT-PORTAL-CONSOLE", [23,10], "Máy thiết lập cổng dịch chuyển. Hửm? Có tờ giấy ghi chú nè. Ủa, đây không phải là tọa độ của thế giới đang có trận chiến giữa con người và loài rồng à?"],
      ["PROP-CRAFT-SPACETIME-COMPUTER", [22,11], "Siêu máy tính phát hiện sai lệch không-thời gian. Shylvie là người điều hành máy này."],
      ["PROP-CRAFT-SRA-CONTROL", [23,12], "Máy điều khiển SRA-UNIT. Mình hay ngồi ở đây để điều khiển các robot hỗ trợ các thành viên khi chưa được điều động. Nếu bị điều động thì SIERRA sẽ là người điều khiển chúng."],
      ["PROP-CRAFT-BROKEN-WEAPONS", range_coords.call(10,13,13), "Thùng sắt đựng vũ khí đã hỏng. Bán cho chị đồng nát là kiếm được khối tiền mua sting cho Leo luôn!"],
      ["PROP-CRAFT-SHIELD-BOX", [5,11], "Thùng đựng khiên. Đa số đều là hàng “phế phẩm” mà Shylvie lụm về từ các chuyến thăm dò. Mọi người có thể lấy khiên ở đây để tùy ý sử dụng."],
      ["PROP-CRAFT-SUPPORT-WEAPONS", [6,11], "Thùng đựng vũ khí hỗ trợ chiến đấu như kiếm, khiên có cưa, rìu, chùy…v..v"],
      ["PROP-CRAFT-SHYLVIE-SHIELDS", [7,11], "Thùng đựng khiên xịn của Shylvie. Không một ai được động vô."],
      ["PROP-CRAFT-HAKASE-ARMOR", [8,11], "Thùng đựng giáp hỗ trợ do Hakase chế tạo."],
      ["PROP-CRAFT-SUPPORT-TOOLS", [9,11], "Thùng đựng thiết bị hỗ trợ như chiếc vòng tay có gắn la bàn, bút dò đường, mặt nạ chống ăn mòn..v…v. Khi trước từng có người dành hàng giờ để sửa chữa chúng sau mỗi chuyến thăm dò."],
      ["PROP-CRAFT-COFFINS", range_coords.call(17,19,15), "Hakase đã trưng dụng mấy chiếc quan tài cũ của Leo làm hòm đựng xác các sinh vật dị biến. Chả hiểu sao mỗi lần mình nhìn vào đây thì trong đầu sẽ vang vảng câu: “Bật nắp quan tài, nhận ngay tài lộc”."],
      ["PROP-CRAFT-AUTOPSY-TABLE", range_coords.call(20,22,15), "Bàn mổ xác chết. Tận dụng xác chết của các sinh vật dị biến là món nghề của Hakase. Lâu lâu mình lôi về mấy con quái vật biển sâu để anh ấy mổ lấy thịt và lấy các cơ quan có thể dùng để chế tạo vật phẩm khác."],
      ["PROP-CRAFT-SURGERY-TOOLS", [24,16], "Dụng cụ phẫu thuật được rửa sạch sẽ. Mình nhớ có hôm Leo bị dính con ký sinh trùng bắt buộc phải mổ sống. Thế là Shylvie phải dùng phép thuật để khóa chân tay Leo lại và để Hakase xử lý con ký sinh đó. Nhớ lại vẫn hãi, máu me tùm lum, Leo la hét thảm thương luôn."],
      ["PROP-CRAFT-LAB-MACHINES", range_coords.call(5,8,14), "Các loại máy móc gì đó mà mình không biết sử dụng. Nhớ mang máng là máy phân tích thành phần, máy trộn chất hóa học, máy sàng lọc thì phải."],
      ["PROP-CRAFT-NETHERVOID-FILTER", [8,18], "Máy lọc tạp chất Nethervoid. Vị của Nethervoid chưa lọc na ná xá xị trộn trà ô long."],
      ["PROP-CRAFT-FILTERED-NETHERVOID", range_coords.call(5,7,18), "Bình chứa chất Nethervoid đã lọc. Uống ngon như nước có ga vị sấu muối."],
      ["PROP-CRAFT-HAIQUY-SIGNAL", [13,17], "Tháp dò tín hiệu của mình. Nhìn vào đây sẽ biết được vị trí hiện tại của mình đang ở đâu. Ngay khi mất tín hiệu thì SIERRA sẽ ngay lập tức ghi nhận."],
      ["PROP-CRAFT-SHYLVIE-LEO-SIGNAL", [14,17], "Tháp dò tín hiệu của Shylvie và Leo."],
      ["PROP-CRAFT-KOHI-HAKASE-SIGNAL", [15,17], "Tháp dò tín hiệu của Kohi và Hakase."],
      ["PROP-CRAFT-OFFLINE-SIGNAL", [16,17], "Tháp dò tín hiệu đã tắt nguồn."],
      ["PROP-CRAFT-MATTER-SCANNER", [14,14], "Máy thăm dò đánh giá vật chất dị giới."],
      ["PROP-CRAFT-DISTORTION-METER", [15,14], "Máy đo đạc biên độ biến dạng dị giới. Hình như đang đặt ở tọa độ chiều không gian Epsilon 017, hành tinh Bellamont?"]
    ]
    crafting_specs.each { |name, coords, text| add_interaction.call(name, coords, text) }
    crafting.instance_variable_set(:@events, crafting_events)
    save_data("Data/Map063.rvdata2", crafting)

    # Add only the two requested floor-transfer events; every other authored
    # event and manual map edit remains untouched.
    office_ids.each do |office_id|
      path = "Data/Map%03d.rvdata2" % office_id
      map = load_data(path)
      events = map.instance_variable_get(:@events) || {}
      meeting_id = movie_offices.include?(office_id) ? meeting_movie_id : meeting_normal_id
      [[130, "TRANSFER-WANDERER-TO-MEETING", meeting_entrance, meeting_id, [17,16]],
       [131, "TRANSFER-WANDERER-TO-CRAFTING", crafting_entrance, crafting_id, [5,10]]].each do |event_id, name, xy, target_map, target_xy|
        occupied = events[event_id]
        if occupied && !occupied.instance_variable_get(:@name).to_s.include?(name)
          raise "Map%03d E%03d occupied by %s" % [office_id, event_id, occupied.instance_variable_get(:@name)]
        end
        commands = [event_command(355, 0, [cleanup]),
          event_command(122, 0, [return_var, return_var, 0, 0, office_id]),
          event_command(201, 0, [0, target_map, target_xy[0], target_xy[1], 8, 0])]
        events[event_id] = make_event.call(event_id,
          "WCF-OFFICE-#{name}", xy[0], xy[1], commands, 1, 0)
      end
      map.instance_variable_set(:@events, events)
      save_data(path, map)
    end

    infos = load_data("Data/MapInfos.rvdata2")
    max_order = infos.values.compact.map { |info| info.instance_variable_get(:@order).to_i }.max
    [[61, "Phòng họp"], [62, "Phòng họp — Movie Night"], [63, "Phòng chế tạo"]].each_with_index do |(map_id, name), index|
      info = infos[map_id] || Marshal.load(Marshal.dump(infos[42] || infos.values.compact.first))
      info.instance_variable_set(:@name, name)
      info.instance_variable_set(:@parent_id, 13)
      info.instance_variable_set(:@order, max_order + index + 1) unless infos[map_id]
      info.instance_variable_set(:@expanded, false)
      info.instance_variable_set(:@scroll_x, 0)
      info.instance_variable_set(:@scroll_y, 0)
      infos[map_id] = info
    end
    save_data("Data/MapInfos.rvdata2", infos)

    errors = []
    office_ids.each do |office_id|
      events = load_data("Data/Map%03d.rvdata2" % office_id).instance_variable_get(:@events)
      errors << "Map#{office_id} meeting entrance" unless events[130] && [events[130].instance_variable_get(:@x), events[130].instance_variable_get(:@y)] == meeting_entrance
      errors << "Map#{office_id} crafting entrance" unless events[131] && [events[131].instance_variable_get(:@x), events[131].instance_variable_get(:@y)] == crafting_entrance
      expected_meeting = movie_offices.include?(office_id) ? meeting_movie_id : meeting_normal_id
      meeting_list = events[130].instance_variable_get(:@pages).first.instance_variable_get(:@list)
      crafting_list = events[131].instance_variable_get(:@pages).first.instance_variable_get(:@list)
      meeting_targets = meeting_list.select { |command| command_code(command) == 201 }.map { |command| command_parameters(command)[1] }
      crafting_targets = crafting_list.select { |command| command_code(command) == 201 }.map { |command| command_parameters(command)[1] }
      errors << "Map#{office_id} meeting target" unless meeting_targets == [expected_meeting]
      errors << "Map#{office_id} crafting target" unless crafting_targets == [crafting_id]
      errors << "Map#{office_id} return source" unless [meeting_list, crafting_list].all? { |list| list.any? { |command| command_code(command) == 122 && command_parameters(command) == [return_var, return_var, 0, 0, office_id] } }
    end
    [meeting_normal_id, meeting_movie_id, crafting_id].each do |room_id|
      events = load_data("Data/Map%03d.rvdata2" % room_id).instance_variable_get(:@events)
      exit_list = events.fetch(2).instance_variable_get(:@pages).first.instance_variable_get(:@list)
      targets = exit_list.select { |command| command_code(command) == 201 }.map { |command| command_parameters(command)[1] }
      errors << "Map#{room_id} return targets" unless (office_ids - targets).empty?
    end
    verify63 = load_data("Data/Map063.rvdata2")
    interaction_roots = verify63.instance_variable_get(:@events).values.count { |event| event.instance_variable_get(:@name).to_s.start_with?("PROP-CRAFT-") && !event.instance_variable_get(:@name).to_s.include?("-ALIAS") }
    errors << "Map063 interaction roots #{interaction_roots}/44" unless interaction_roots == 44
    raise errors.join("; ") unless errors.empty?
    puts "WANDERER_SHARED_ROOMS|offices=#{office_ids.join(',')}|meeting=61/62@13,39|crafting=63@37,37|craft_interactions=44|return_var=49|errors=0"
  end

  # Build the five explorable bedrooms attached to the Wanderer Office.
  # The interaction coordinates and wording come from compact B3236-B3557.
  # Map013 E005 is the only unassigned member-room door in the authored row:
  # E004 remains the guest room, E005 becomes Hai Quy's room, and E006-E009
  # retain the authored Shylvie/Leo/Hakase/Kohi order.
  def create_wanderer_private_rooms
    room_specs = {
      42 => ["Phòng Hải Quỳ — Wanderer", "HQ_Room_Normal", 20, 14,
             [[4, 17, 4, 11], [12, 13, 12, 13]], [13, 12, 8], [13, 13], 16],
      43 => ["Phòng Shylvie", "CV_Room_Lightoff_Base", 20, 18,
             [[2, 15, 2, 15], [0, 2, 5, 7]], [2, 6, 6], [1, 6], 20],
      44 => ["Phòng Leo", "Leo_Room_Base", 17, 17,
             [[2, 15, 3, 11], [1, 3, 6, 8]], [2, 7, 6], [1, 7], 24],
      45 => ["Phòng Hakase", "MystRoom_Base", 17, 17,
             [[2, 14, 4, 12], [9, 11, 12, 16]], [10, 15, 8], [10, 16], 28],
      46 => ["Phòng Kohi", "Kohi_Room_Base", 17, 18,
             [[2, 14, 4, 14], [3, 5, 14, 17]], [4, 16, 8], [4, 17], 32]
    }

    hub = load_data("Data/Map013.rvdata2")
    hub_events = hub.instance_variable_get(:@events) || {}
    template = hub_events[4] || hub_events.values.compact.first
    base_source = load_data("Data/Map041.rvdata2")
    raise "Map013 has no room-door template" unless template

    cleanup = "RegionStairs.disable; " \
      "$game_player.instance_variable_set(:@through,false); " \
      "$game_player.instance_variable_set(:@move_speed,4); " \
      "$game_player.transparent=false; " \
      "ms_pro_cam_focus_on(-1); ms_pro_cam_unlock_camera"

    text = lambda do |paragraphs, indent = 0, face_index = 1|
      commands = wrapped_message_commands(Array(paragraphs), width: 30, indent: indent)
      commands.each do |command|
        next unless command_code(command) == 101
        command.instance_variable_set(:@parameters,
          ["HaiQuy_Thuongphuc_Emote", face_index, 0, 2])
      end
      commands
    end

    # Create the common map shell and return small event-building helpers.
    begin_room = lambda do |map_id|
      display_name, parallax, width, height, rectangles, arrival, exit_xy, return_x = room_specs.fetch(map_id)
      map = Marshal.load(Marshal.dump(base_source))
      map.instance_variable_set(:@display_name, display_name)
      map.instance_variable_set(:@width, width)
      map.instance_variable_set(:@height, height)
      map.instance_variable_set(:@tileset_id, 7)
      map.instance_variable_set(:@parallax_name, parallax)
      map.instance_variable_set(:@parallax_loop_x, false)
      map.instance_variable_set(:@parallax_loop_y, false)
      map.instance_variable_set(:@parallax_sx, 0)
      map.instance_variable_set(:@parallax_sy, 0)
      map.instance_variable_set(:@parallax_show, false)
      map.instance_variable_set(:@note,
        "[lighting off]\r\n<full lock parallax>\r\n<tile lock parallax>\r\n" \
        "Wanderer private room; compact B3236-B3557")
      map.instance_variable_set(:@autoplay_bgm, false)
      map.instance_variable_set(:@autoplay_bgs, false)
      map.instance_variable_set(:@encounter_list, [])

      table = blank_table(width, height, 4)
      height.times { |y| width.times { |x| table_set(table, x, y, 2, 251) } }
      rectangles.each do |x1, x2, y1, y2|
        (y1..y2).each do |y|
          (x1..x2).each { |x| table_set(table, x, y, 2, 250) }
        end
      end
      map.instance_variable_set(:@data, table)

      events = {}
      next_id = 1
      make_page = lambda do |commands, self_switch = nil, trigger = 0, priority = 1,
                             switch_id = nil|
        built = page_from_template(template, commands, trigger: trigger, priority: priority,
          self_switch: self_switch, switch_id: switch_id)
        graphic = built.instance_variable_get(:@graphic)
        if graphic
          graphic.instance_variable_set(:@tile_id, 0)
          graphic.instance_variable_set(:@character_name, "")
          graphic.instance_variable_set(:@character_index, 0)
        end
        built
      end
      add_event = lambda do |name, x, y, pages|
        id = next_id
        events[id] = event_from_pages(template, id, name, x, y, pages)
        next_id += 1
        id
      end
      add_alias = lambda do |target_id, x, y, name = "INTERACTION-ALIAS"|
        add_event.call(name, x, y, [make_page.call([
          event_command(355, 0, ["$game_map.events[#{target_id}].start"])
        ])])
      end
      add_one = lambda do |name, coordinates, paragraphs, face_index = 1|
        coords = coordinates.first.is_a?(Array) ? coordinates : [coordinates]
        first = coords.first
        id = add_event.call(name, first[0], first[1],
          [make_page.call(text.call(paragraphs, 0, face_index))])
        coords.drop(1).each { |x, y| add_alias.call(id, x, y, "#{name}-ALIAS") }
        id
      end
      add_multi = lambda do |name, coordinates, stages|
        coords = coordinates.first.is_a?(Array) ? coordinates : [coordinates]
        letters = [nil, "A", "B", "C"]
        pages = stages.each_with_index.map do |stage, index|
          paragraphs, face_index = stage
          commands = text.call(paragraphs, 0, face_index || 1)
          commands << event_command(123, 0, [letters[index + 1], 0]) if index < stages.length - 1
          make_page.call(commands, letters[index])
        end
        id = add_event.call(name, coords.first[0], coords.first[1], pages)
        coords.drop(1).each { |x, y| add_alias.call(id, x, y, "#{name}-ALIAS") }
        id
      end

      init_extra = if map_id == 43
        "if $game_self_switches[[43,3,'A']]; " \
          "$game_map.change_parallax('CV_Room_Lighton_Base',false,false,0,0); end"
      end
      init = [event_command(355, 0, [cleanup])]
      init << event_command(355, 0, [init_extra]) if init_extra
      init << event_command(214, 0, [])
      add_event.call("SCN-WANDERER-ROOM-INIT", 0, 0,
        [make_page.call(init, nil, 3, 0)])

      exit_commands = [event_command(355, 0, [cleanup])]
      if map_id == 43
        exit_commands << event_command(355, 0,
          ["$game_self_switches[[43,3,'A']]=false"])
      end
      exit_commands.concat(wanderer_office_return_commands(return_x, 6))
      add_event.call("TRANSFER-ROOM-TO-WANDERER", exit_xy[0], exit_xy[1],
        [make_page.call(exit_commands, nil, 1, 0)])

      {
        map: map, events: events, make_page: make_page, add_event: add_event,
        add_alias: add_alias, one: add_one, multi: add_multi,
        arrival: arrival, display_name: display_name
      }
    end

    # Map042 — Hải Quỳ's bedroom in Wanderer Office.
    room = begin_room.call(42)
    page = room[:make_page]
    add = room[:add_event]
    one = room[:one]
    aliaz = room[:add_alias]

    cabinet_first = text.call([
      "Tủ bị khóa bằng mã điện tử. Nhập mã chứ?",
      "Nhập tám số đầu, rồi nhập tám số cuối."
    ], 0, 3) + [
      event_command(122, 0, [47, 48, 0, 0, 0]),
      event_command(103, 0, [47, 8]),
      event_command(103, 0, [48, 8]),
      event_command(111, 0, [1, 47, 0, 2_901_202, 0]),
      event_command(111, 1, [1, 48, 0, 40_012_202, 0]),
      *text.call(["Ồ, cái hộp blu-ray Sousou no Frieren của Shylvie nè? Để năm sau trả vậy."], 2, 3),
      event_command(123, 2, ["A", 0]),
      event_command(411, 1, []),
      *text.call(["Mã không đúng."], 2, 5),
      event_command(412, 1, []),
      event_command(411, 0, []),
      *text.call(["Mã không đúng."], 1, 5),
      event_command(412, 0, [])
    ]
    album = text.call(["Uầy, cuốn album ảnh thẻ của những thân phận mình cải trang nè. Ngồi xem chứ?"], 0, 0) + [
      event_command(102, 0, [["Ngồi xem", "Để sau"], 1]),
      event_command(402, 0, [0, "Ngồi xem"]),
      *text.call(["Mình mở cuốn album ảnh thẻ ra xem."], 1, 1),
      event_command(123, 1, ["B", 0]),
      event_command(402, 0, [1, "Để sau"]),
      event_command(404, 0, [])
    ]
    designs = text.call(["Một xấp bản thiết kế trang phục cũ của mình. Ngồi xem chứ?"], 0, 3) + [
      event_command(102, 0, [["Ngồi xem", "Để sau"], 1]),
      event_command(402, 0, [0, "Ngồi xem"]),
      *text.call(["Mình ngồi xuống xem lại xấp bản thiết kế cũ."], 1, 1),
      event_command(402, 0, [1, "Để sau"]),
      event_command(404, 0, [])
    ]
    add.call("PROP-HQ-OFFICE-ELECTRONIC-CABINET", 16, 8, [
      page.call(cabinet_first), page.call(album, "A"), page.call(designs, "B")
    ])
    one.call("PROP-HQ-OFFICE-CALENDAR", [15, 8],
      ["Trang lịch tháng 10 của năm 2022. Ngày 04 tháng 10 được khoanh tròn bằng bút dạ màu đỏ."])
    one.call("PROP-HQ-OFFICE-ABYSS-FLOWER-PHOTO", [14, 8],
      ["Khung ảnh chụp bông hoa dưới vực sâu. Mình nhớ sau khi mình chụp tấm ảnh này, bông hoa đã phát nổ."], 3)
    one.call("PROP-HQ-OFFICE-BATTLE-AXE", [13, 8],
      ["Rìu chiến phòng bị. Lâu lâu đang ngủ mà bị Leo gọi giật dậy tham chiến thì mình luôn vác con hàng này đi thay vì găng tay Ruby Moon."])
    one.call("PROP-HQ-OFFICE-PAJAMAS", [12, 8],
      ["Tủ pajama của mình. Đa phần là pajama màu cam hoặc có hoa văn trái cam."])
    one.call("PROP-HQ-OFFICE-DOUJINSHI", [11, 8],
      ["Ủa, trong khe hẹp này có quyển doujinshi Touhou hồi bữa mình lỡ tay dịch chuyển nè? Để lấy sau vậy."], 3)
    one.call("PROP-HQ-OFFICE-MISSION-GEAR", [10, 8], [
      "Tủ đựng vũ khí quân dụng và thiết bị hỗ trợ nhiệm vụ nằm vùng.",
      "Ôi vẫn tiếc đứt ruột “Bát Họ”…! Cái bát biến ra mọi món ăn mà mình nghĩ trong đầu…!!"
    ], 4)
    # $HaiQuy_Bath is an 11-frame, single-character sheet (3 columns x 4
    # rows; the final cell is intentionally unused). VX Ace normally treats
    # the rows as directions, so drive both @direction and @pattern manually
    # to play the authored sequence instead of leaving the player on a single
    # walking row.
    bath_frames = [[2, 0], [2, 1], [2, 2]] * 3 +
      [[4, 0], [4, 1], [4, 2], [6, 0], [6, 1], [6, 2], [8, 0], [8, 1]]
    bath_animation = []
    bath_frames.each_with_index do |(direction, pattern), index|
      bath_animation << event_command(355, 1, [
        "$game_player.instance_variable_set(:@direction,#{direction}); " \
        "$game_player.instance_variable_set(:@pattern,#{pattern}); " \
        "$game_player.instance_variable_set(:@original_pattern,#{pattern}); " \
        "$game_player.instance_variable_set(:@anime_count,0)"
      ])
      # About five frames per second during playback; pause noticeably on the
      # completed bath pose before fading back to the room.
      bath_animation << event_command(230, 1, [index == bath_frames.length - 1 ? 90 : 12])
    end

    bath = text.call(["Bồn tắm. Tắm ngay bây giờ chứ?"], 0, 3) + [
      event_command(102, 0, [["Tắm thôi!", "Để sau!"], 1]),
      event_command(402, 0, [0, "Tắm thôi!"]),
      event_command(221, 1, []),
      event_command(355, 1, [
        "$game_player.instance_variable_set(:@wcf_room_return,[$game_player.x,$game_player.y,$game_player.character_name,$game_player.character_index,$game_player.direction,$game_player.pattern,$game_player.direction_fix,$game_player.walk_anime,$game_player.step_anime,$game_player.instance_variable_get(:@original_pattern)]); " \
        "$game_player.moveto(5,10); $game_player.set_graphic('$HaiQuy_Bath',0); " \
        "$game_player.instance_variable_set(:@walk_anime,false); $game_player.instance_variable_set(:@step_anime,false); " \
        "$game_player.instance_variable_set(:@direction_fix,true); $game_player.instance_variable_set(:@direction,2); " \
        "$game_player.instance_variable_set(:@pattern,0); $game_player.instance_variable_set(:@original_pattern,0); " \
        "$game_player.instance_variable_set(:@anime_count,0)"
      ]),
      event_command(222, 1, []),
      *bath_animation,
      event_command(221, 1, []),
      event_command(355, 1, [
        "r=$game_player.instance_variable_get(:@wcf_room_return); " \
        "$game_player.moveto(r[0],r[1]); $game_player.set_graphic(r[2],r[3]); " \
        "$game_player.instance_variable_set(:@direction,r[4]); $game_player.instance_variable_set(:@pattern,r[5]); " \
        "$game_player.instance_variable_set(:@direction_fix,r[6]); $game_player.instance_variable_set(:@walk_anime,r[7]); " \
        "$game_player.instance_variable_set(:@step_anime,r[8]); $game_player.instance_variable_set(:@original_pattern,r[9]); " \
        "$game_player.instance_variable_set(:@anime_count,0); " \
        "$game_player.instance_variable_set(:@wcf_room_return,nil)"
      ]),
      event_command(222, 1, []),
      event_command(402, 0, [1, "Để sau!"]),
      event_command(404, 0, [])
    ]
    bath_id = add.call("SCN-HQ-OFFICE-BATH", 5, 9, [page.call(bath)])
    aliaz.call(bath_id, 5, 10, "SCN-HQ-OFFICE-BATH-ALIAS")
    # !$TV_Sprite contains nine authored screens in the first three rows of
    # its 3x4 single-character sheet. Show each screen for two seconds and
    # hide every frame swap behind a normal screen fade.
    tv_frames = [2, 4, 6].flat_map { |direction| [[direction, 0], [direction, 1], [direction, 2]] }
    tv_animation = [
      event_command(221, 1, []),
      event_command(355, 1, [
        "$game_player.moveto(5,5); $game_player.instance_variable_set(:@direction,8); " \
        "$game_player.instance_variable_set(:@pattern,1); $game_player.instance_variable_set(:@original_pattern,1); " \
        "$game_player.instance_variable_set(:@anime_count,0)"
      ])
    ]
    tv_frames.each_with_index do |(direction, pattern), index|
      tv_animation << event_command(221, 1, []) if index > 0
      tv_animation << event_command(355, 1, [
        "tv=$game_map.events[@event_id]; tv.set_graphic('!$TV_Sprite',0); " \
        "tv.instance_variable_set(:@walk_anime,false); tv.instance_variable_set(:@step_anime,false); " \
        "tv.instance_variable_set(:@direction_fix,true); tv.instance_variable_set(:@priority_type,0); " \
        "tv.instance_variable_set(:@direction,#{direction}); tv.instance_variable_set(:@pattern,#{pattern}); " \
        "tv.instance_variable_set(:@original_pattern,#{pattern}); tv.instance_variable_set(:@anime_count,0)"
      ])
      tv_animation << event_command(222, 1, [])
      tv_animation << event_command(230, 1, [120])
    end

    television = text.call(["Ngồi xem TV một chút chứ?"], 0, 3) + [
      event_command(102, 0, [["Xem xíu đi!", "Không xem"], 1]),
      event_command(402, 0, [0, "Xem xíu đi!"]),
      *tv_animation,
      *text.call(["Xem hết phim này đến phim khác…", "BAD ENDING: “Thêm tập nữa thôi!”"], 1, 5),
      event_command(221, 1, []),
      event_command(354, 1, []),
      event_command(402, 0, [1, "Không xem"]),
      event_command(404, 0, [])
    ]
    tv_id = add.call("BAD-END-HQ-OFFICE-TELEVISION", 5, 4, [page.call(television)])
    one.call("PROP-HQ-OFFICE-BED", [6, 5],
      ["Muốn leo lên giường nằm ngủ ghê! Nhưng mà mình ngủ sâu với lâu lắm! Thôi, để tối ngủ!!"], 5)
    room[:map].instance_variable_set(:@events, room[:events])
    save_data("Data/Map042.rvdata2", room[:map])

    # Map043 — Shylvie. E003 is deliberately the light switch because the
    # arrival synchronizer above references that stable event ID.
    room = begin_room.call(43)
    page = room[:make_page]
    add = room[:add_event]
    one = room[:one]
    aliaz = room[:add_alias]
    light_on = text.call(["Công tắc đèn. Bật đèn chứ?"], 0, 3) + [
      event_command(102, 0, [["Bật đèn", "Để sau"], 1]),
      event_command(402, 0, [0, "Bật đèn"]),
      event_command(284, 1, ["CV_Room_Lighton_Base", false, false, 0, 0]),
      event_command(123, 1, ["A", 0]),
      event_command(402, 0, [1, "Để sau"]),
      event_command(404, 0, [])
    ]
    light_off = text.call(["Tắt đèn chứ?"], 0, 3) + [
      event_command(102, 0, [["Tắt đèn", "Để nguyên"], 1]),
      event_command(402, 0, [0, "Tắt đèn"]),
      event_command(284, 1, ["CV_Room_Lightoff_Base", false, false, 0, 0]),
      event_command(123, 1, ["A", 1]),
      event_command(402, 0, [1, "Để nguyên"]),
      event_command(404, 0, [])
    ]
    add.call("PROP-SHYLVIE-LIGHT-SWITCH", 2, 8,
      [page.call(light_on), page.call(light_off, "A")])
    one.call("PROP-SHYLVIE-SWUTCH3", [11, 7], ["Máy Swutch 3 mà Shylvie tậu được ở chiều không gian khác."])
    one.call("PROP-SHYLVIE-PORTRAIT", [12, 7], ["Tranh chân dung Shylvie được vẽ bởi Kohi."])
    one.call("PROP-SHYLVIE-WARDROBE", [8, 7], ["Tủ quần áo của Shylvie."])
    one.call("PROP-SHYLVIE-STEAMPUNK-SHIELD", [8, 8], ["Tủ trưng bày khiên steampunk."])
    one.call("PROP-SHYLVIE-ANCIENT-SHIELD", [8, 9],
      ["Tủ trưng bày khiên cổ xưa. Chiếc khiên này được đính rất nhiều ngọc ma thuật."])
    one.call("PROP-SHYLVIE-REVERSE-BUNNY", [8, 10],
      ["Tủ trưng bày Reverse Bunny mà mình tặng Shylvie này! WOW!"], 0)
    one.call("PROP-SHYLVIE-GAME-DISCS", [8, 11],
      ["Tủ đựng đĩa chơi game Swutch 3 và các loại tay cầm chơi game khác."])
    one.call("PROP-SHYLVIE-PERSONAL", [2, 7], ["Tủ đựng đồ dùng cá nhân của Shylvie."])
    one.call("PROP-SHYLVIE-PET-CARE", [3, 7], ["Tủ đựng đồ chăm sóc thú cưng."])
    one.call("PROP-SHYLVIE-CLOCK-BOMB", [4, 7],
      ["Đồng hồ kiêm quả bom mà mình tặng cho Shylvie. Hình như Shylvie tháo mất bộ phận gây nổ của nó rồi."], 3)
    one.call("PROP-SHYLVIE-COMPUTER", [6, 8],
      ["Hình như Shylvie đang tải game gì đó. Rhythm Hellaly Megamix Groove à?"], 3)
    one.call("PROP-SHYLVIE-WANDERSISTER-SEAT", [13, 15],
      ["WanderSister hay ngồi đây mỗi lần chơi Katrio Slicing."])
    one.call("PROP-SHYLVIE-HQ-SEAT", [14, 15],
      ["Mình sẽ nằm dài ở đây khi chơi Katrio Slicing cùng WanderSister. Cái ghế này siêu êm."])
    one.call("PROP-SHYLVIE-SUMMONING-GONG", [15, 8],
      ["Một cái chiêng thần thoại có khả năng dịch chuyển người được đọc tên. Eden thường xuyên bị Shylvie “triệu hồi” bằng chiếc chiêng này."])
    one.call("PROP-SHYLVIE-SYMBOL-SHIELD", [14, 7], ["Bản sao của chiếc khiên biểu tượng cho Shylvie."])
    one.call("LORE-SHYLVIE-BROKEN-MIRROR", [11, 3], [
      "Chiếc gương này từng là gương dịch chuyển nhưng đã bị vỡ sau một trận chiến.",
      "Leo đã phải phong ấn chiếc gương này lại, phòng cho kẻ địch lợi dụng nó để úp sọt Shylvie."
    ])
    one.call("PROP-SHYLVIE-MAGIC-WINDOW", [13, 2],
      ["Tấm tranh ma thuật vẽ hình cửa sổ. Chức năng y chang cửa sổ mô phỏng ở phòng của Kohi và Leo."])
    one.call("PROP-SHYLVIE-INFINITE-STORAGE", [15, 2],
      ["Tủ chứa đồ vô hạn. Shylvie lúc nào cũng bảo: “Sẽ sửa sau” xong rồi vứt mấy đồ hỏng hóc vào đây, chả bao giờ sửa."])
    steve = one.call("PROP-SHYLVIE-STEVE", [2, 14], ["S T E V E."], 3)
    aliaz.call(steve, 3, 15, "PROP-SHYLVIE-STEVE-ALIAS")
    room[:map].instance_variable_set(:@events, room[:events])
    save_data("Data/Map043.rvdata2", room[:map])

    # Map044 — Leo.
    room = begin_room.call(44)
    one = room[:one]
    multi = room[:multi]
    aliaz = room[:add_alias]
    one.call("PROP-LEO-MURAMASA-PHOTO", [6, 4],
      ["Giá đỡ thanh Muramasa của Leo.", "Trên kệ là ảnh chụp của Leo và Sakura Usagi."])
    books = multi.call("LORE-LEO-OMEN-BOOKS", [2, 4], [
      [["Sách điềm báo. Cuốn sách này giúp Leo biết trước các thảm họa tồi tệ ở đa chiều không gian để kịp thời xử lý."], 1],
      [["EPSILON-017 – HÀNH TINH BELLAMONT. NGỦ YÊN. NGÀN THU. KHÔNG LỐI THOÁT."], 5]
    ])
    aliaz.call(books, 3, 4, "LORE-LEO-OMEN-BOOKS-ALIAS")
    one.call("PROP-LEO-FIREPLACE", [4, 4], ["Lò sưởi."])
    lamps = one.call("PROP-LEO-SHYLVIE-LAMPS", [2, 8],
      ["Đây là hai cái đèn ngủ mà Shylvie tặng Leo mà nhỉ."], 3)
    aliaz.call(lamps, 3, 8, "PROP-LEO-SHYLVIE-LAMPS-ALIAS")
    coffin = one.call("PROP-LEO-UPRIGHT-BED", [8, 5],
      ["Quan tài, à nhầm, giường ngủ đứng của Leo. Vì Leo đang ở ngoài nên viên ngọc trên quan tài mới sáng đèn."], 3)
    aliaz.call(coffin, 9, 5, "PROP-LEO-UPRIGHT-BED-ALIAS")
    one.call("PROP-LEO-MAGIC-WINDOW", [13, 4],
      ["Chà, trăng hôm nay sáng ghê! Cửa sổ mô phỏng môi trường này hay thật đó."], 0)
    desk = one.call("PROP-LEO-WORK-DESK", [11, 5], [
      "Bàn làm việc của Leo. Ổng đang nghiên cứu gì vậy nè?",
      "Hừm…Ku-ro-ya-mi? Sừng rồng có thể chế biến thành thuốc súng siêu cấp?"
    ], 3)
    aliaz.call(desk, 12, 5, "PROP-LEO-WORK-DESK-ALIAS")
    one.call("PROP-LEO-SLEEP-PLANT", [13, 6],
      ["Mình không biết tên của cây này là gì. Chỉ biết mỗi lần Leo bị thương nặng đều sẽ cắn rất nhiều lá từ cây này để ngủ. Mình cắn không xi nhê gì."])
    one.call("PROP-LEO-GOD-OF-WAR", [10, 10],
      ["Trời đất ơi, ổng đang chơi dở God of War Fimbulwinter nè!"], 4)
    multi.call("PROP-LEO-MULTIVERSE-GAMES", [9, 10], [
      [["Rất nhiều đĩa game đến từ dòng thời gian khác. Pragmator 2? Pragmator 1 đâu?!"], 3],
      [["Bún Bò Phố Cổ? Phần tiếp theo của Phở Anh Ba à?"], 3],
      [["Falling Out Lastest Last Vegan? Huh?"], 3]
    ])
    one.call("PROP-LEO-YCARTON-CONTROLLERS", [11, 10], ["Quá trời tay cầm YCARTON luôn."], 0)
    one.call("PROP-LEO-READING-GLASSES", [7, 11],
      ["Ồ, kính lão này! Hình như Leo đang đọc Độc Đắc Cõi Ma Cà Rồng hả?"], 3)
    one.call("PROP-LEO-WARDROBE", [13, 11],
      ["Tủ quần áo của Leo. Có một hộc toàn là quần xì ma thuật màu hồng chấm bi."], 6)
    one.call("PROP-LEO-STING-COLLECTION", [15, 11],
      ["Tủ trưng bày các loại Sting. Sting vàng, Sting xanh, Sting Wasabi, Sting Tỏi…v.v."])
    room[:map].instance_variable_set(:@events, room[:events])
    save_data("Data/Map044.rvdata2", room[:map])

    # Map045 — Hakase.
    room = begin_room.call(45)
    page = room[:make_page]
    add = room[:add_event]
    one = room[:one]
    directional = [
      event_command(111, 0, [6, -1, 4]),
      *text.call(["Tablet và Swutch OLED nằm tứ tung trên giường."], 1, 1),
      event_command(411, 0, []),
      *text.call(["Mấy cái hộc tủ khóa rồi. Mình nhớ Hakase hay nhét đĩa game Swutch vào mấy cái hộc này."], 1, 1),
      event_command(412, 0, [])
    ]
    one.call("PROP-HAKASE-TOILET-PAPER", [9, 5],
      ["Tại sao trên kệ này lại để hai cuộn giấy vệ sinh vậy?"], 3)
    add.call("PROP-HAKASE-BED-DIRECTIONAL", 8, 5, [page.call(directional)])
    one.call("PROP-HAKASE-LUCARIO", [4, 7], ["Trời má, tượng Lucario 1:1 luôn! Oách thế!!!"], 0)
    one.call("PROP-HAKASE-HOGWARTS", [3, 7], ["Hửm? Hakase đang tải Hogwarts Legacy về chơi à?"], 3)
    one.call("PROP-HAKASE-MINI-FRIDGE", [2, 7], ["Tủ lạnh mini nhét đầy thức uống có cồn."])
    one.call("PROP-HAKASE-CARDBOARD-CLEANUP", [2, 11], [
      "So với mấy hôm trước thì Hakase đã dọn dẹp gọn gàng phòng ngủ của mình…",
      "Bằng cách nhét không biết bao nhiêu thứ vào mấy thùng cạc tông này.",
      "Chà, muốn đem đống này bán đồng nát ghê."
    ], 5)
    one.call("PROP-HAKASE-RABBIT", [3, 10],
      ["Thỏ Bông. Hakase hay điều khiển con này đi xuống bếp lấy đồ ăn."])
    thorn = text.call(["Có một chậu hoa hồng gai trên bàn. Chạm nó chứ?"], 0, 3) + [
      event_command(102, 0, [["Chạm", "Không chạm"], 1]),
      event_command(402, 0, [0, "Chạm"]),
      *text.call(["Hải Quỳ lăn ra chết."], 1, 4),
      event_command(353, 1, []),
      event_command(402, 0, [1, "Không chạm"]),
      *text.call(["Urg, khùng hông mà chạm vô cái chậu đầy gai vậy."], 1, 5),
      event_command(404, 0, [])
    ]
    add.call("BAD-END-HAKASE-THORN-ROSE", 4, 10, [page.call(thorn)])
    one.call("PROP-HAKASE-FIGURES-SELFIE", [10, 7],
      ["Trên kệ trưng figure anime. Ngoài ra còn một tấm ảnh selfie của Hakase được đóng khung và gắn tùm lum charm nhỏ xinh."])
    record = text.call(["Đầu đĩa than. Chà, nhạc có bản quyền. Bật không?"], 0, 3) + [
      event_command(108, 0, ["Track metadata: https://www.youtube.com/watch?v=TLXdmt_k0ig"]),
      event_command(408, 0, ["Track metadata: https://www.youtube.com/watch?v=kiQxfZg7Z68"]),
      event_command(408, 0, ["Track metadata: https://www.youtube.com/watch?v=tJH-7u4kAyw"]),
      event_command(102, 0, [["Bật", "Đổi nhạc", "Đổi nhạc lần nữa", "Không bật"], 3]),
      event_command(402, 0, [0, "Bật"]),
      event_command(402, 0, [1, "Đổi nhạc"]),
      event_command(402, 0, [2, "Đổi nhạc lần nữa"]),
      event_command(402, 0, [3, "Không bật"]),
      event_command(404, 0, [])
    ]
    add.call("PROP-HAKASE-RECORD-PLAYER", 11, 7, [page.call(record)])
    ram_empty = text.call(["Ở đây có một khe trống vừa khít một thanh RAM."], 0, 3)
    ram_found = text.call(["Nhét thanh RAM tìm thấy trong phòng Kohi vào đây chứ?"], 0, 3) + [
      event_command(102, 0, [["Nhét vào", "Để sau"], 1]),
      event_command(402, 0, [0, "Nhét vào"]),
      *text.call(["Vừa khít."], 1, 0),
      event_command(121, 1, [54, 54, 0]),
      event_command(121, 1, [53, 53, 1]),
      event_command(402, 0, [1, "Để sau"]),
      event_command(404, 0, [])
    ]
    ram_done = text.call(["Thanh RAM đã được nhét vào đúng vị trí."], 0, 1)
    add.call("PROP-HAKASE-DIANA-RAM-SLOT", 12, 7, [
      page.call(ram_empty), page.call(ram_found, nil, 0, 1, 53),
      page.call(ram_done, nil, 0, 1, 54)
    ])
    one.call("PROP-HAKASE-LUCKY-CAT", [13, 7],
      ["Mèo chiêu tài. Hakase từng bảo mắt con mèo này có thể bắn laze vừa đủ để nướng kẹo dẻo."])
    one.call("PROP-HAKASE-BONSAI", [14, 7],
      ["Chậu Bonsai này cao hơn mình. Hakase nhìn vậy chứ chăm cây tốt phết."])
    one.call("PROP-HAKASE-GUNDAM-BOXES", [14, 11], ["Thùng đựng các hộp Gundam chưa lắp."])
    one.call("PROP-HAKASE-MODEL-BOXES", [9, 8], ["Thùng đựng các hộp mô hình chưa lắp."])
    room[:map].instance_variable_set(:@events, room[:events])
    save_data("Data/Map045.rvdata2", room[:map])

    # Map046 — Kohi.
    room = begin_room.call(46)
    page = room[:make_page]
    add = room[:add_event]
    one = room[:one]
    multi = room[:multi]
    multi.call("PROP-KOHI-MEME-PAINTING", [14, 11], [
      [["Đây đúng là một tuyệt tác nghệ thuật. Một bức tranh về nụ cười khả ố của Kohi."], 6],
      [["Hình như đây là cái meme mà bả dùng trong server Discord của mình mà đúng không?"], 3],
      [["Mình có thể nghe thấy tiếng cười của bả ở trong đầu."], 5]
    ])
    one.call("PROP-KOHI-WARDROBE", [6, 7], ["Tủ quần áo của Kohi."])
    one.call("PROP-KOHI-PORTRAIT", [8, 7], ["Tranh chân dung của Kohi."])
    ram_take = text.call(["Hửm? Có gì dưới gầm giường vậy? Ồ, là một thanh RAM!"], 0, 3) + [
      event_command(102, 0, [["Lấy thanh RAM", "Để nguyên"], 1]),
      event_command(402, 0, [0, "Lấy thanh RAM"]),
      event_command(121, 1, [53, 53, 0]),
      *text.call(["Mình cất thanh RAM đi."], 1, 1),
      event_command(402, 0, [1, "Để nguyên"]),
      event_command(404, 0, [])
    ]
    ram_taken = text.call(["Mình đã lấy thanh RAM ở dưới gầm giường."], 0, 1)
    add.call("PROP-KOHI-DIANA-RAM", 13, 7, [
      page.call(ram_take), page.call(ram_taken, nil, 0, 1, 53),
      page.call(ram_taken, nil, 0, 1, 54)
    ])
    one.call("PROP-KOHI-WINDOW", [10, 5], [
      "Chà, ngoài trời ánh nắng dịu dàng ghê.",
      "Làm mình nhớ tới hồi còn bé mình nhìn thẳng vào mặt trời. Nhớ lại mà mắt trái giật giật rồi đó."
    ], 5)
    one.call("PROP-KOHI-FLOWER", [14, 12], ["Ồ, bông này là bông gì nhỉ? Nhìn tươi tốt phết."], 3)
    multi.call("PROP-KOHI-TEA-CAMERA-BOOKS", [3, 8], [
      [["Bộ ấm chén đặc biệt mà Kohi đã mua ở hành tinh Luminous. Chất lượng tốt khỏi phải bàn. Đặc biệt là chiếc ấm có thể dùng để nấu mì ăn liền."], 1],
      [["Sao mắt con mèo chiêu tài này nhìn lạ thế? Ồ, là camera ẩn! Hello Kohi!"], 4],
      [["Kohi cũng thích đọc sách. Trên kệ này có vài cuốn nhìn hay ho quá chừng."], 1]
    ])
    one.call("PROP-KOHI-PERSONAL-CABINET", [9, 5], ["Tủ đồ cá nhân của Kohi."])
    one.call("PROP-KOHI-COFFEE-CABINET", [11, 5], ["Sao cái tủ này có mùi cà phê nhỉ?"], 3)
    one.call("PROP-KOHI-HOBBY", [7, 11], ["Kohi có sở thích mới sao? Vậy là gần đủ cầm kỳ thi họa rồi."], 3)
    one.call("PROP-KOHI-BOCCHI", [8, 11], ["Rất là Bocchi The Đá."], 6)
    room[:map].instance_variable_set(:@events, room[:events])
    save_data("Data/Map046.rvdata2", room[:map])

    # Replace only the five authored room doors. Their graphics and placement
    # remain untouched; all other hub content, route pages, and the guest room
    # remain byte-for-byte equivalent within the Map013 object.
    door_map = {5 => 42, 6 => 43, 7 => 44, 8 => 45, 9 => 46}
    door_names = {5 => "HQ", 6 => "SHYLVIE", 7 => "LEO", 8 => "HAKASE", 9 => "KOHI"}
    door_map.each do |event_id, destination|
      event = hub_events[event_id]
      raise "Map013 room door E#{event_id} missing" unless event
      spec = room_specs.fetch(destination)
      arrival = spec[5]
      event.instance_variable_set(:@name,
        "TRANSFER-WANDERER-TO-#{door_names[event_id]}-ROOM [E%03d]" % event_id)
      room_page = (event.instance_variable_get(:@pages) || []).first
      room_page.instance_variable_set(:@trigger, 0)
      room_page.instance_variable_set(:@priority_type, 1)
      room_page.instance_variable_set(:@list, [
        event_command(355, 0, [cleanup]),
        event_command(201, 0, [0, destination, arrival[0], arrival[1], arrival[2], 0]),
        event_command(0, 0, [])
      ])
      event.instance_variable_set(:@pages, [room_page])
    end
    hub.instance_variable_set(:@events, hub_events)
    save_data("Data/Map013.rvdata2", hub)

    infos = load_data("Data/MapInfos.rvdata2")
    max_order = infos.values.compact.map { |entry| entry.instance_variable_get(:@order).to_i }.max
    room_specs.each do |map_id, spec|
      info = infos[map_id] || Marshal.load(Marshal.dump(infos[13] || infos.values.compact.first))
      info.instance_variable_set(:@name, spec[0])
      info.instance_variable_set(:@parent_id, 13)
      unless infos[map_id]
        max_order += 1
        info.instance_variable_set(:@order, max_order)
      end
      info.instance_variable_set(:@expanded, true)
      info.instance_variable_set(:@scroll_x, 0)
      info.instance_variable_set(:@scroll_y, 0)
      infos[map_id] = info
    end
    save_data("Data/MapInfos.rvdata2", infos)

    system = load_data("Data/System.rvdata2")
    switches = system.instance_variable_get(:@switches)
    switches[53] = "WANDERER_RAM_FOUND"
    switches[54] = "WANDERER_RAM_INSTALLED"
    system.instance_variable_set(:@switches, switches)
    variables = system.instance_variable_get(:@variables)
    variables[47] = "WANDERER_ROOM_CODE_A"
    variables[48] = "WANDERER_ROOM_CODE_B"
    variables[49] = "WANDERER_OFFICE_RETURN_MAP"
    system.instance_variable_set(:@variables, variables)
    save_data("Data/System.rvdata2", system)

    connect_wanderer_office_variants
    puts "WANDERER_PRIVATE_ROOMS|maps=42..46|HQ,Shylvie,Leo,Hakase,Kohi|hub_doors=5..9|RAM=53,54"
  end

  def audit_wanderer_private_rooms
    expected = {
      42 => ["HQ_Room_Normal", 20, 14, [13, 12], [13, 13], 16],
      43 => ["CV_Room_Lightoff_Base", 20, 18, [2, 6], [1, 6], 20],
      44 => ["Leo_Room_Base", 17, 17, [2, 7], [1, 7], 24],
      45 => ["MystRoom_Base", 17, 17, [10, 15], [10, 16], 28],
      46 => ["Kohi_Room_Base", 17, 18, [4, 16], [4, 17], 32]
    }
    infos = load_data("Data/MapInfos.rvdata2")
    errors = []
    summaries = []

    expected.each do |map_id, (parallax, width, height, arrival, exit_xy, return_x)|
      path = format("Data/Map%03d.rvdata2", map_id)
      unless File.file?(path)
        errors << "Map%03d missing" % map_id
        next
      end
      map = load_data(path)
      events = map.instance_variable_get(:@events) || {}
      errors << "Map%03d dimensions" % map_id unless
        [map.instance_variable_get(:@width), map.instance_variable_get(:@height)] == [width, height]
      errors << "Map%03d parallax" % map_id unless map.instance_variable_get(:@parallax_name) == parallax
      errors << "Map%03d parent" % map_id unless
        infos[map_id] && infos[map_id].instance_variable_get(:@parent_id) == 13

      raw = map.instance_variable_get(:@data).instance_variable_get(:@marshal_data)
      _dim, table_width, table_height, depth, size = raw.unpack("l<5")
      errors << "Map%03d table header" % map_id unless
        [table_width, table_height, depth] == [width, height, 4]
      values = raw.byteslice(20, size * 2).unpack("s<*")
      tile = lambda { |x, y| values[2 * width * height + y * width + x] }
      errors << "Map%03d arrival blocked" % map_id unless tile.call(*arrival) == 250
      errors << "Map%03d exit blocked" % map_id unless tile.call(*exit_xy) == 250

      occupied = events.values.compact.select do |event|
        page = (event.instance_variable_get(:@pages) || []).first
        page && page.instance_variable_get(:@priority_type) == 1
      end.map { |event| [event.instance_variable_get(:@x), event.instance_variable_get(:@y)] }
      queue = [arrival]
      reached = {arrival => true}
      until queue.empty?
        x, y = queue.shift
        [[x + 1, y], [x - 1, y], [x, y + 1], [x, y - 1]].each do |nx, ny|
          next if nx < 0 || ny < 0 || nx >= width || ny >= height
          point = [nx, ny]
          next if reached[point] || occupied.include?(point) || tile.call(nx, ny) != 250
          reached[point] = true
          queue << point
        end
      end
      errors << "Map%03d exit unreachable" % map_id unless reached[exit_xy]

      events.each do |event_id, event|
        next unless event
        x = event.instance_variable_get(:@x)
        y = event.instance_variable_get(:@y)
        errors << "Map%03d E%03d out of bounds" % [map_id, event_id] unless
          x.between?(0, width - 1) && y.between?(0, height - 1)
        (event.instance_variable_get(:@pages) || []).each_with_index do |page, page_index|
          list = page.instance_variable_get(:@list) || []
          errors << "Map%03d E%03d P%d missing terminator" % [map_id, event_id, page_index + 1] unless
            list.last && command_code(list.last) == 0
          list.each do |command|
            next unless command_code(command) == 101
            params = command_parameters(command)
            errors << "Map%03d E%03d faceless interaction" % [map_id, event_id] if params[0].to_s.empty?
          end
        end
      end

      exit_event = events.values.compact.find do |event|
        event.instance_variable_get(:@name).to_s.include?("TRANSFER-ROOM-TO-WANDERER")
      end
      transfers = exit_event && (exit_event.instance_variable_get(:@pages) || []).flat_map do |page|
        page.instance_variable_get(:@list) || []
      end.select { |command| command_code(command) == 201 }
      errors << "Map%03d exit transfer" % map_id unless
        transfers && transfers.map { |command| command_parameters(command)[1] }.sort == [13, 38, 39] &&
          transfers.all? { |command| command_parameters(command)[2, 2] == [return_x, 6] }
      summaries << "Map%03d events=%d reached=%d" % [map_id, events.length, reached.length]
    end

    hub = load_data("Data/Map013.rvdata2")
    hub_events = hub.instance_variable_get(:@events) || {}
    {5 => 42, 6 => 43, 7 => 44, 8 => 45, 9 => 46}.each do |event_id, map_id|
      event = hub_events[event_id]
      transfer = event && (event.instance_variable_get(:@pages) || []).flat_map do |page|
        page.instance_variable_get(:@list) || []
      end.find { |command| command_code(command) == 201 }
      errors << "Map013 E%03d door transfer" % event_id unless
        transfer && command_parameters(transfer)[1] == map_id
    end

    # Normal, Christmas, and morning-after office maps must expose the same
    # five private rooms and all three paths into the shared kitchen.
    expected_entries = {
      110 => 42, 111 => 43, 112 => 44, 113 => 45, 114 => 46,
      115 => 14, 116 => 14, 117 => 14
    }
    {13 => {5 => 42, 6 => 43, 7 => 44, 8 => 45, 9 => 46,
            2 => 14, 3 => 14, 10 => 14},
     38 => expected_entries, 39 => expected_entries}.each do |office_id, entries|
      map = load_data(format("Data/Map%03d.rvdata2", office_id))
      events = map.instance_variable_get(:@events) || {}
      entries.each do |event_id, destination|
        event = events[event_id]
        commands = event && (event.instance_variable_get(:@pages) || []).flat_map do |page|
          page.instance_variable_get(:@list) || []
        end
        transfer = commands && commands.find do |command|
          command_code(command) == 201 && command_parameters(command)[1] == destination
        end
        source_stamp = commands && commands.find do |command|
          command_code(command) == 122 && command_parameters(command) ==
            [49, 49, 0, 0, office_id]
        end
        errors << "Map%03d E%03d destination" % [office_id, event_id] unless transfer
        errors << "Map%03d E%03d return source" % [office_id, event_id] unless source_stamp
      end
    end

    kitchen = load_data("Data/Map014.rvdata2")
    kitchen_events = kitchen.instance_variable_get(:@events) || {}
    {2 => [24, 11], 3 => [23, 11]}.each do |event_id, coordinate|
      event = kitchen_events[event_id]
      transfers = event && (event.instance_variable_get(:@pages) || []).flat_map do |page|
        page.instance_variable_get(:@list) || []
      end.select { |command| command_code(command) == 201 }
      errors << "Map014 E%03d variant returns" % event_id unless
        transfers && transfers.map { |command| command_parameters(command)[1] }.sort == [13, 38, 39] &&
          transfers.all? { |command| command_parameters(command)[2, 2] == coordinate }
    end

    # Guard the custom 11-frame bath sheet against being reduced to VX Ace's
    # normal three-frame walking animation when these maps are regenerated.
    hq_room = load_data("Data/Map042.rvdata2")
    bath_event = (hq_room.instance_variable_get(:@events) || {}).values.compact.find do |event|
      event.instance_variable_get(:@name).to_s.start_with?("SCN-HQ-OFFICE-BATH [")
    end
    bath_commands = bath_event && (bath_event.instance_variable_get(:@pages) || []).flat_map do |page|
      page.instance_variable_get(:@list) || []
    end
    expected_bath_frames = [[2, 0], [2, 1], [2, 2]] * 3 +
      [[4, 0], [4, 1], [4, 2], [6, 0], [6, 1], [6, 2], [8, 0], [8, 1]]
    actual_bath_frames = Array(bath_commands).filter_map do |command|
      next unless command_code(command) == 355
      script = command_parameters(command)[0].to_s
      next if script.include?("wcf_room_return")
      match = script.match(/@direction,(\d+)\).*@pattern,(\d+)/)
      match && [match[1].to_i, match[2].to_i]
    end
    bath_waits = Array(bath_commands).select { |command| command_code(command) == 230 }
      .map { |command| command_parameters(command)[0] }
    errors << "Map042 bath frame order" unless actual_bath_frames == expected_bath_frames
    errors << "Map042 bath timing" unless bath_waits == [12] * 16 + [90]

    hq_events = (hq_room.instance_variable_get(:@events) || {}).values.compact
    tv_event = hq_events.find do |event|
      event.instance_variable_get(:@name).to_s.start_with?("BAD-END-HQ-OFFICE-TELEVISION [")
    end
    tv_commands = tv_event && (tv_event.instance_variable_get(:@pages) || []).flat_map do |page|
      page.instance_variable_get(:@list) || []
    end
    expected_tv_frames = [2, 4, 6].flat_map do |direction|
      [[direction, 0], [direction, 1], [direction, 2]]
    end
    actual_tv_frames = Array(tv_commands).filter_map do |command|
      next unless command_code(command) == 355
      script = command_parameters(command)[0].to_s
      next unless script.include?("!$TV_Sprite")
      match = script.match(/@direction,(\d+)\).*@pattern,(\d+)/)
      match && [match[1].to_i, match[2].to_i]
    end
    tv_waits = Array(tv_commands).select { |command| command_code(command) == 230 }
      .map { |command| command_parameters(command)[0] }
    tv_scripts = Array(tv_commands).select { |command| command_code(command) == 355 }
      .map { |command| command_parameters(command)[0].to_s }
    tv_fadeouts = Array(tv_commands).count { |command| command_code(command) == 221 }
    tv_fadeins = Array(tv_commands).count { |command| command_code(command) == 222 }
    tv_coordinates = hq_events.select do |event|
      event.instance_variable_get(:@name).to_s.start_with?("BAD-END-HQ-OFFICE-TELEVISION")
    end.map do |event|
      [event.instance_variable_get(:@x), event.instance_variable_get(:@y)]
    end.sort
    errors << "Map042 TV frame order" unless actual_tv_frames == expected_tv_frames
    errors << "Map042 TV timing" unless tv_waits == [120] * 9
    errors << "Map042 TV control event" unless tv_coordinates == [[5, 4]]
    errors << "Map042 TV fade sequence" unless tv_fadeouts == 10 && tv_fadeins == 9
    errors << "Map042 TV player seat" unless tv_scripts.any? { |script| script.include?("moveto(5,5)") }
    errors << "Map042 TV layer" unless tv_scripts.count { |script| script.include?("@priority_type,0") } == 9

    system = load_data("Data/System.rvdata2")
    variables = system.instance_variable_get(:@variables) || []
    errors << "Variable 49 return-map name" unless variables[49] == "WANDERER_OFFICE_RETURN_MAP"

    summaries.each { |line| puts "WANDERER_ROOM_AUDIT|#{line}" }
    errors.each { |line| puts "WANDERER_ROOM_ERROR|#{line}" }
    puts "WANDERER_ROOM_AUDIT_SUMMARY|errors=#{errors.length}|rooms=#{expected.length}|office_variants=3|kitchen=14"
    raise "Wanderer private room audit failed" unless errors.empty?
  end

  def fix_playable_parallax_notetags
    fixed = []
    [35, 37].each do |id|
      path = format("Data/Map%03d.rvdata2", id)
      next unless File.exist?(path)
      map = load_data(path)
      next if map.instance_variable_get(:@parallax_name).to_s.empty?
      note = map.instance_variable_get(:@note).to_s
      lines = note.split(/\r?\n/)
      lines.unshift("<tile lock parallax>") unless lines.include?("<tile lock parallax>")
      lines.unshift("<full lock parallax>") unless lines.include?("<full lock parallax>")
      map.instance_variable_set(:@note, lines.join("\r\n"))
      save_data(path, map)
      fixed << id
    end
    puts "PARALLAX_NOTETAGS|fixed=#{fixed.join(',')}"
  end

  # Stage the Map022 noodle meal on the two authored full-map parallaxes.
  # Switch 40 is set by E016 after Hải Quỳ examines the family album and
  # changes form. The baked character art is used for the meal, while the
  # invisible runtime characters remain at the same tiles as Pop Message
  # anchors (player=0, Paulie=E007).
  def apply_map022_ramen_parallax
    path = "Data/Map022.rvdata2"
    map = load_data(path)
    events = map.instance_variable_get(:@events) || {}
    meal = events[48]
    paulie = events[7]
    album = events[16]
    raise "Map022 noodle event E048 missing" unless meal
    raise "Map022 Paulie anchor E007 missing" unless paulie
    raise "Map022 album event E016 missing" unless album

    album_sets_form = (album.instance_variable_get(:@pages) || []).any? do |page|
      (page.instance_variable_get(:@list) || []).any? do |command|
        command_code(command) == 121 && command_parameters(command)[0, 3] == [40, 40, 0]
      end
    end
    raise "Map022 E016 no longer sets Switch 40" unless album_sets_form

    page = (meal.instance_variable_get(:@pages) || []).first
    raise "Map022 E048 page 1 missing" unless page
    list = page.instance_variable_get(:@list) || []

    # Idempotent: remove the complete generated setup/cleanup ranges, including
    # their fades, instead of leaving old commands behind on repeated runs.
    ["RAMEN_PARALLAX_BEGIN", "RAMEN_PARALLAX_CLEANUP_BEGIN"].each do |marker|
      loop do
        marker_index = list.index do |command|
          [355, 655].include?(command_code(command)) &&
            command_parameters(command)[0].to_s.include?(marker)
        end
        break unless marker_index
        finish_marker = marker.sub("BEGIN", "END")
        finish_index = (marker_index...list.length).find do |index|
          [355, 655].include?(command_code(list[index])) &&
            command_parameters(list[index])[0].to_s.include?(finish_marker)
        end
        raise "Map022 E048 #{finish_marker} missing" unless finish_index
        range_start = marker_index > 0 && command_code(list[marker_index - 1]) == 221 ? marker_index - 1 : marker_index
        range_end = finish_index
        range_end += 1 if marker == "RAMEN_PARALLAX_BEGIN" &&
          range_end + 1 < list.length && command_code(list[range_end + 1]) == 222
        list.slice!(range_start..range_end)
      end
    end

    prompt_index = list.index do |command|
      command_code(command) == 401 &&
        command_parameters(command)[0].to_s.include?("Pha mì nhé?")
    end
    raise "Map022 E048 noodle prompt missing" unless prompt_index

    transfer_index = list.index { |command| command_code(command) == 201 }
    raise "Map022 E048 transfer missing" unless transfer_index

    # CE01/CE02 focus the current speaker. On a 22-tile-wide map this keeps
    # clamping the camera at the right edge, while Map Effects transforms the
    # baked parallax after Pop Message has calculated its anchor. Keep one
    # fixed two-shot instead and supply screen-space anchors for this scene.
    (prompt_index + 1...transfer_index).to_a.reverse_each do |index|
      command = list[index]
      list.delete_at(index) if command_code(command) == 117 &&
        [1, 2].include?(command_parameters(command)[0])
    end

    # The source marks these as silent reaction/self-talk rather than dialogue
    # addressed to Paulie. Keep the wording exact and only change presentation.
    thought_lines = ["…!!", "Người gì kỳ cục à!!"]
    list.each do |command|
      next unless command_code(command) == 401
      params = command_parameters(command)
      text = params[0].to_s
      prefix = "\\bm[0] "
      next unless text.start_with?(prefix) && thought_lines.include?(text[prefix.length..-1])
      params[0] = text[prefix.length..-1]
    end

    # Explicitly cancel Pop Message at the beginning of every ordinary Show
    # Text block in the meal. This protects narration/thoughts even if another
    # message system keeps the previous bubble state for an extra frame.
    in_meal = false
    expect_first_line = false
    list.each do |command|
      in_meal = true if command.equal?(list[prompt_index + 1])
      break if in_meal && command_code(command) == 201
      next unless in_meal
      if command_code(command) == 101
        expect_first_line = true
      elsif command_code(command) == 401 && expect_first_line
        params = command_parameters(command)
        text = params[0].to_s
        params[0] = "\\cbm #{text}" unless text.start_with?("\\bm[") || text.start_with?("\\cbm")
        expect_first_line = false
      elsif command_code(command) != 401
        expect_first_line = false if command_code(command) != 101
      end
    end
    scene_start = prompt_index + 1

    setup = [
      event_command(221, 0, []),
      event_command(355, 0, ["# RAMEN_PARALLAX_BEGIN"]),
      event_command(355, 0, ["$game_map.change_parallax($game_switches[40] ? \"HaiQuy_Parent_House_Ramen_NoGlitch\" : \"HaiQuy_Parent_House_Ramen_Glitch\",false,false,0,0)"]),
      event_command(355, 0, ["del_layer(22,0); refresh_layers"]),
      event_command(355, 0, ["$game_player.moveto(15,19); $game_player.opacity=0"]),
      event_command(355, 0, ["$game_map.events[7].moveto(18,19)"]),
      event_command(355, 0, ["map_effects.refresh_rate=60; map_effects.active=true"]),
      event_command(355, 0, ["map_effects.set_origin(100,50); map_effects.set_zoom(130,0,false)"]),
      event_command(355, 0, ["$game_map.set_display_pos(16.5-$game_map.screen_tile_x/2,19-$game_map.screen_tile_y/2)"]),
      event_command(355, 0, ["ms_pro_cam_ignore_player(true); ms_pro_cam_lock_camera"]),
      event_command(355, 0, ["$game_player.instance_variable_set(:@pop_message_screen_x,274); $game_player.instance_variable_set(:@pop_message_top_y,210); $game_player.instance_variable_set(:@pop_message_baseline_y,282)"]),
      event_command(355, 0, ["p=$game_map.events[7]; p.instance_variable_set(:@pop_message_screen_x,399); p.instance_variable_set(:@pop_message_top_y,210); p.instance_variable_set(:@pop_message_baseline_y,282)"]),
      event_command(355, 0, ["# RAMEN_PARALLAX_END"]),
      event_command(222, 0, [])
    ]
    list.insert(scene_start, *setup)

    transfer_index = list.index { |command| command_code(command) == 201 }
    cleanup = [
      event_command(221, 0, []),
      event_command(355, 0, ["# RAMEN_PARALLAX_CLEANUP_BEGIN"]),
      event_command(355, 0, ["ms_pro_cam_unlock_camera; ms_pro_cam_ignore_player(false)"]),
      event_command(355, 0, ["map_effects.set_origin(50,50)"]),
      event_command(355, 0, ["[$game_player,$game_map.events[7]].each{|c| c.instance_variable_set(:@pop_message_screen_x,nil); c.instance_variable_set(:@pop_message_top_y,nil); c.instance_variable_set(:@pop_message_baseline_y,nil)}"]),
      event_command(355, 0, ["$game_player.opacity=255"]),
      event_command(355, 0, ["$game_map.change_parallax(\"HQ_House_Base\",false,false,0,0)"]),
      event_command(355, 0, ["layer(22,0,[\"HQ_House_Top\",0,0,255,200,0,0,0]); refresh_layers"]),
      event_command(355, 0, ["# RAMEN_PARALLAX_CLEANUP_END"])
    ]
    list.insert(transfer_index, *cleanup)
    transfer = list.find { |command| command_code(command) == 201 }
    command_parameters(transfer)[5] = 2 # Keep the explicit black screen.
    page.instance_variable_set(:@list, list)
    save_data(path, map)

    # Map021 is a non-playable transit map. Do not fade it in only to fade it
    # out again; carry the black handoff through to the prepared shop map.
    transit_path = "Data/Map021.rvdata2"
    transit = load_data(transit_path)
    transit_event = (transit.instance_variable_get(:@events) || {})[1]
    raise "Map021 transit E001 missing" unless transit_event
    transit_page = (transit_event.instance_variable_get(:@pages) || []).first
    transit_transfer = (transit_page.instance_variable_get(:@list) || []).find do |command|
      command_code(command) == 201 && command_parameters(command)[1] == 23
    end
    raise "Map021 -> Map023 transfer missing" unless transit_transfer
    command_parameters(transit_transfer)[5] = 2
    save_data(transit_path, transit)

    # Fade in only after Old_Book_Shop_Base and Old_Book_Shop_Top are ready.
    shop_path = "Data/Map023.rvdata2"
    shop = load_data(shop_path)
    shop_event = (shop.instance_variable_get(:@events) || {})[1]
    raise "Map023 arrival E001 missing" unless shop_event
    shop_page = (shop_event.instance_variable_get(:@pages) || []).first
    shop_list = shop_page.instance_variable_get(:@list) || []
    shop_list.reject! do |command|
      command_code(command) == 355 &&
        command_parameters(command)[0].to_s == "# RAMEN_TO_SHOP_FADEIN"
    end
    # Remove only a Fade In generated immediately after our old marker run.
    shop_list.each_index.to_a.reverse_each do |index|
      next unless command_code(shop_list[index]) == 222
      previous = index > 0 ? shop_list[index - 1] : nil
      shop_list.delete_at(index) if previous && command_code(previous) == 655 &&
        command_parameters(previous)[0].to_s == "refresh_layers"
    end
    refresh_index = shop_list.index do |command|
      command_code(command) == 655 && command_parameters(command)[0].to_s == "refresh_layers"
    end
    raise "Map023 layer refresh missing" unless refresh_index
    shop_list.insert(refresh_index + 1,
      event_command(355, 0, ["# RAMEN_TO_SHOP_FADEIN"]),
      event_command(222, 0, []))
    shop_page.instance_variable_set(:@list, shop_list)

    # Existing playtest saves may already have E001 Self Switch A enabled and
    # therefore skip page 1. Page 2 restores brightness only when necessary,
    # then erases itself for the current visit so the autorun cannot loop.
    shop_pages = shop_event.instance_variable_get(:@pages) || []
    shop_page2 = shop_pages[1]
    raise "Map023 arrival E001 page 2 missing" unless shop_page2
    shop_page2.instance_variable_set(:@trigger, 3)
    shop_page2.instance_variable_set(:@priority_type, 0)
    shop_page2.instance_variable_set(:@list, [
      event_command(111, 0, [12, "$game_map.screen.brightness < 255"]),
      event_command(222, 1, []),
      event_command(412, 0, []),
      event_command(214, 0, []),
      event_command(0, 0, [])
    ])
    save_data(shop_path, shop)

    puts "MAP022_RAMEN|switch=40|off=Glitch|on=NoGlitch|anchors=player:15,19;E007:18,19|camera=fixed-two-shot|handoff=black-until-Map023"
  end

  # E002 is the invisible screen/camera anchor for the shop owner baked into
  # Old_Book_Shop_Base. E003 remains the counter interaction tile; both copies
  # of the conversation deliberately use \bm[2].
  def fix_map023_shop_owner_anchor
    path = "Data/Map023.rvdata2"
    map = load_data(path)
    events = map.instance_variable_get(:@events) || {}
    owner = events[2]
    counter = events[3]
    raise "Map023 shop owner E002 missing" unless owner
    raise "Map023 owner counter E003 missing" unless counter

    owner.instance_variable_set(:@x, 12)
    owner.instance_variable_set(:@y, 27)
    owner.instance_variable_set(:@name, "NPC-SHOP-OWNER ANCHOR [E002]")
    counter.instance_variable_set(:@name, "NPC-SHOP-OWNER COUNTER [E003]")

    owner_bubbles = 0
    [owner, counter].each do |event|
      (event.instance_variable_get(:@pages) || []).each do |page|
        (page.instance_variable_get(:@list) || []).each do |command|
          next unless command_code(command) == 401
          owner_bubbles += 1 if command_parameters(command)[0].to_s.start_with?("\\bm[2]")
        end
      end
    end
    raise "Map023 owner dialogue has no \\bm[2]" if owner_bubbles == 0

    save_data(path, map)
    puts "MAP023_OWNER_ANCHOR|E002=12,27|counter=E003@12,28|bubble=2|groups=#{owner_bubbles}"
  end

  # Add face portraits to the two implemented route families without inventing
  # portraits for characters that have no matching asset. Existing authored
  # face choices are preserved. Pop Message draws these through its separate
  # Window_MessageFace because default_face is disabled.
  def apply_atlantis_and_coffee_route_faces
    casual_hq = ["HaiQuy_Thuongphuc_Emote", 1]
    paulie = ["Paulie", 1]
    bully = ["BullyQuy_Thuongphuc_Emote", 1]
    christmas = {
      hq:       ["HaiQuy_Giangsinh_Emote", 1],
      shylvie:  ["CV_Giangsinh_Emote1", 1],
      kohi:     ["Kohi_Giangsinh_Emote1", 1],
      leo:      ["Leo_Giangsinh_Emote", 1],
      hakase:   ["Hakase_Giangsinh_Emote", 1]
    }
    generated_face_names = [casual_hq, paulie, bully, *christmas.values].map(&:first).uniq

    route_maps = [10, 19, 22, 23, 24, 25, 26, 34, 35, 36, 37, 38, 39]
    totals = {}

    emotion_index = lambda do |role, text, base|
      loud = text =~ /[A-ZÀ-ỸĐ]{4,}|!{2,}/
      question = text.include?("?") || text.include?("???")
      strained = text.include?("…") || text.include?("...") ||
        text =~ /Urg|không sao|mệt|buồn|lo lắng|bất an/i
      table = {
        hq:        { loud: 0, question: 3, strained: 5 },
        paulie:    { loud: 3, question: 2, strained: 4 },
        bully:     { loud: 2, question: 3, strained: 5 },
        clone:     { loud: 2, question: 3, strained: 3 },
        xmas_hq:   { loud: 0, question: 3, strained: 5 },
        shylvie:   { loud: 3, question: 5, strained: 1 },
        kohi:      { loud: 2, question: 4, strained: 0 },
        leo:       { loud: 3, question: 3, strained: 7 },
        hakase:    { loud: 2, question: 3, strained: 0 }
      }
      # A stammer/ellipsis remains strained even if it ends in "!!"; treating
      # it as a triumphant shout gives reactions such as "…!!" the wrong face.
      mood = question ? :question : strained ? :strained : loud ? :loud : nil
      mood ? table.fetch(role, {}).fetch(mood, base) : base
    end

    first_text_after = lambda do |list, index|
      cursor = index + 1
      while cursor < list.length && command_code(list[cursor]) == 401
        text = command_parameters(list[cursor])[0].to_s
        return text unless text.empty?
        cursor += 1
      end
      ""
    end

    route_maps.each do |map_id|
      path = format("Data/Map%03d.rvdata2", map_id)
      next unless File.exist?(path)
      map = load_data(path)
      changed = 0
      unresolved = 0

      (map.instance_variable_get(:@events) || {}).each_value do |event|
        (event.instance_variable_get(:@pages) || []).each do |page|
          list = page.instance_variable_get(:@list) || []
          aira_narrator = false
          list.each_with_index do |command, index|
            next unless command_code(command) == 101
            params = command_parameters(command)
            text = first_text_after.call(list, index)
            plain = text.sub(/\A\\(?:bm\[\d+\]|cbm)\s*/i, "")
            if map_id == 26 &&
               event.instance_variable_get(:@name).to_s.include?("TV-CASSETTE") &&
               plain.start_with?("“")
              if !params[0].to_s.empty? || params[1].to_i != 0
                params[0], params[1] = "", 0
                changed += 1
              end
              next
            end
            # Map010 already used a deliberate character-card portrait when
            # introducing Hakase. Restore/preserve it rather than treating the
            # shared Christmas sheet name as one generated by this pass.
            if map_id == 10 && plain.start_with?("Cuối cùng là Hakase")
              if params[0] != "Hakase_Giangsinh_Emote" || params[1] != 0
                params[0], params[1] = "Hakase_Giangsinh_Emote", 0
                changed += 1
              end
              next
            end
            # Preserve authored faces while allowing generated faces outside
            # Map010 to be recomputed after emotion heuristics are refined.
            next unless params[0].to_s.empty? ||
              (map_id != 10 && generated_face_names.include?(params[0].to_s))
            aira_narrator = true if map_id == 37 && plain.start_with?("Dậy coi con âm binh")
            bubble_id = text[/\A\\bm\[(\d+)\]/i, 1]
            bubble_id = bubble_id.to_i if bubble_id

            role = nil
            face = nil
            case map_id
            when 10, 19, 24, 26
              role, face = :hq, casual_hq if bubble_id.nil? || bubble_id == 0
            when 22
              if bubble_id == 7
                role, face = :paulie, paulie
              elsif bubble_id.nil? || bubble_id == 0
                role, face = :hq, casual_hq
              end
            when 23
              # E002 is the shop owner, for whom no matching face asset exists.
              if bubble_id.nil? || bubble_id == 0
                role, face = :hq, casual_hq
              end
            when 25
              if bubble_id == 3
                role, face = :paulie, paulie
              elsif bubble_id == 0
                role, face = :hq, casual_hq
              end
            when 34
              if bubble_id == 0
                role, face = :hq, casual_hq
              elsif bubble_id && bubble_id.between?(3, 13)
                role, face = :clone, bully
              end
            when 35
              if bubble_id == 3
                role, face = :paulie, paulie
              elsif bubble_id == 0
                role, face = :hq, casual_hq
              end
            when 36
              role, face = :bully, bully if bubble_id == 2
            when 37
              aira_line = aira_narrator ||
                plain =~ /\A(?:Gì vậy trời|Leo sẽ thích|Kiểu gì Kohi|Shylvie sẽ thích|Hakase sẽ thích|Phiền quá|Thân thiện gì|Không nhưng)/
              role, face = aira_line ? [:bully, bully] : [:hq, casual_hq]
            when 38, 39
              mapping = {
                2 => [:xmas_hq, christmas[:hq]],
                3 => [:shylvie, christmas[:shylvie]],
                4 => [:kohi, christmas[:kohi]],
                5 => [:leo, christmas[:leo]],
                6 => [:hakase, christmas[:hakase]]
              }
              if bubble_id && mapping[bubble_id]
                role, face = mapping[bubble_id]
              elsif bubble_id.nil?
                role, face = :xmas_hq, christmas[:hq]
              end
            end

            unless face
              unresolved += 1
              next
            end
            new_index = emotion_index.call(role, plain, face[1])
            if params[0] != face[0] || params[1] != new_index
              params[0] = face[0]
              params[1] = new_index
              changed += 1
            end
          end
        end
      end
      save_data(path, map) if changed > 0
      totals[map_id] = [changed, unresolved]
    end

    summary = totals.map { |id, counts| "#{id}:#{counts[0]}/#{counts[1]}" }.join(",")
    puts "ROUTE_FACES|map=added/unresolved|#{summary}"
  end

  # Register CG/item illustrations at authored moments where their subject is
  # explicitly present. Generated calls carry a marker and are rebuilt on each
  # run, so route regeneration cannot duplicate them.
  def integrate_picture_gallery_assets
    map_ids = [6, 19, 22, 37, 38, 39, 40]
    maps = {}
    map_ids.each do |map_id|
      path = "Data/Map%03d.rvdata2" % map_id
      maps[map_id] = load_data(path) if File.exist?(path)
    end

    marker = "# WCF_GALLERY_SCENE"
    maps.each_value do |map|
      (map.instance_variable_get(:@events) || {}).each_value do |event|
        next unless event
        (event.instance_variable_get(:@pages) || []).each do |page|
          list = page.instance_variable_get(:@list) || []
          list.reject! do |command|
            [355, 655].include?(command_code(command)) &&
              command_parameters(command)[0].to_s.include?(marker)
          end
        end
      end
    end

    show_call = lambda do |expression, indent|
      event_command(355, indent,
        ["WCFGalleryScene.show(#{expression}) #{marker}"])
    end
    hide_call = lambda do |indent|
      event_command(355, indent, ["WCFGalleryScene.hide #{marker}"])
    end

    decorate = lambda do |map_id, event_id, needle, expression, all_matches = true|
      map = maps.fetch(map_id)
      events = map.instance_variable_get(:@events) || {}
      candidates = event_id ? [events[event_id]].compact : events.values.compact
      hits = 0
      candidates.each do |event|
        (event.instance_variable_get(:@pages) || []).each do |page|
          list = page.instance_variable_get(:@list) || []
          blocks = []
          index = 0
          while index < list.length
            unless command_code(list[index]) == 101
              index += 1
              next
            end
            first = index
            last = index
            message_lines = []
            while last + 1 < list.length && command_code(list[last + 1]) == 401
              last += 1
              message_lines << command_parameters(list[last])[0].to_s
            end
            # Match the logical message instead of a single wrapped line.
            # Adding faces changes the available text width, so authored
            # phrases may move across two Event Command 401 entries.
            logical_text = message_lines.join(" ").gsub(/\s+/, " ")
            blocks << [first, last] if logical_text.include?(needle)
            index = last + 1
          end
          blocks = blocks.first(1) unless all_matches
          blocks.reverse_each do |first, last|
            indent = list[first].instance_variable_get(:@indent).to_i
            block = list[first..last]
            list[first..last] = [show_call.call(expression, indent)] + block +
              [hide_call.call(indent)]
            hits += 1
          end
        end
      end
      puts "GALLERY_SCENE_MISSING|Map%03d|E%s|%s" %
        [map_id, event_id || "*", needle] if hits == 0
      hits
    end

    # Existing full-screen CG commands retain their authored lifetime.
    {6 => {"CG1" => 1}, 38 => {"CG6" => 6, "CG7" => 7}}.each do |map_id, files|
      (maps.fetch(map_id).instance_variable_get(:@events) || {}).each_value do |event|
        next unless event
        (event.instance_variable_get(:@pages) || []).each do |page|
          list = page.instance_variable_get(:@list) || []
          indexes = list.each_index.select do |index|
            command_code(list[index]) == 231 &&
              files.key?(command_parameters(list[index])[1].to_s)
          end
          indexes.reverse_each do |index|
            id = files[command_parameters(list[index])[1].to_s]
            indent = list[index].instance_variable_get(:@indent).to_i
            list.insert(index, event_command(355, indent,
              ["GlobalGallery.unlock(#{id}) #{marker}"]))
          end
        end
      end
    end

    # Preparation CGs and Christmas outfit sequence.
    decorate.call(37, 1, "kẹp sắt hình con dơi được", "2")
    decorate.call(37, 1, "kẹp sắt hình chiếc khiên được", "3")
    decorate.call(37, 1, "kẹp sắt hình chìa khóa được", "4")
    decorate.call(37, 1, "hạt cà phê lên chiếc khăn", "5")
    decorate.call(37, 1, "Dậy coi con âm binh", "28")
    decorate.call(37, 1, "Bộ quái gì đây?", "29")
    decorate.call(37, 1, "Không phải bộ này", "30")
    decorate.call(37, 1, "Chậc!! Sau vụ này", "31")

    # Christmas party CGs with unambiguous source-text anchors.
    decorate.call(38, 7, "Nói dứt lời, Hakase quấn chiếc", "8")
    decorate.call(38, 7, "len mà tôi đan bị hóa", "26")
    decorate.call(38, 7, "Chiếc khiên này có vẻ", "32")
    decorate.call(38, 7, "chiếc khăn quấn mạnh vào cổ", "33")
    decorate.call(38, 7, "thanh gươm xuất hiện một vòng", "34")
    decorate.call(38, 7, "hiểu lắm! Mấy thanh gỗ", "35")
    decorate.call(38, 7, "phóc lên ôm Leo thật", "39")
    decorate.call(38, 7, "sang ăn ngấu nghiến gần hết",
      "$game_switches[51] ? 41 : 40", false)
    decorate.call(39, 1, "tay cầm một cốc cà phê nóng", "37")
    decorate.call(39, 1, "Bảo sao bà uống tận hơn", "38")

    # Items inspected in the supermarket.
    decorate.call(19, 34, "Combo Dao làm bếp", "52", false)
    decorate.call(19, 35, "bộ dụng cụ đan len", "47", false)
    decorate.call(19, 36, "Bộ dụng cụ phá khóa", "57", false)

    # Items visibly exchanged during implemented Christmas branches.
    item_specs = [
      [42, "chiếc áo choàng mới toanh"],
      [45, "một đôi bao tay mới màu hồng"],
      [48, "một cây bút bằng vàng"],
      [56, "túi cà phê dát vàng thượng hạng"],
      [55, "Đèn ngủ ánh sao ma thuật để"],
      [60, "rất nhiều thanh gỗ có hình"],
      [65, "chiếc khiên cổ bị rỉ"],
      [66, "chiếc kiếm cách có kiểu cách"],
      [67, "một con gấu bông Kirby"],
      [70, "là máy ép nước cam"],
      [73, "một hộp mô hình Gundam"],
      [74, "một chiếc ốp lưng điện thoại"],
      [79, "ra ngoài với một chiếc túi đeo"]
    ]
    item_specs.each { |id, needle| decorate.call(38, 7, needle, id.to_s) }
    decorate.call(39, 1, "Hakase chiếc bao tay len", "46")
    decorate.call(39, 1, "Luminous trứ danh đó", "51")
    decorate.call(39, 1, "LÀ TAILS", "78")
    decorate.call(40, 1, "Đủ mười phần rồi. Số cà phê", "50", false)

    # Recipient-specific scarves share one generated MKT_GIFT=3 branch.
    map38 = maps.fetch(38)
    page38 = map38.instance_variable_get(:@events)[7].instance_variable_get(:@pages).first
    list38 = page38.instance_variable_get(:@list) || []
    scarf_branch = list38.index do |command|
      command_code(command) == 111 &&
        command_parameters(command)[0, 4] == [1, 42, 0, 3]
    end
    if scarf_branch
      indent = list38[scarf_branch].instance_variable_get(:@indent).to_i + 1
      expression = "({1=>64,2=>63,3=>61,4=>62}[$game_variables[43]] || 61)"
      while list38[scarf_branch + 1] &&
          command_code(list38[scarf_branch + 1]) == 230 &&
          command_parameters(list38[scarf_branch + 1]) == [75]
        list38.delete_at(scarf_branch + 1)
      end
      list38.insert(scarf_branch + 1, show_call.call(expression, indent),
        event_command(355, indent, ["WCFGalleryScene.hold(75) #{marker}"]),
        hide_call.call(indent))
    else
      puts "GALLERY_SCENE_MISSING|Map038|E7|MKT_GIFT=3"
    end

    # Regular coffee is an explicit choice with no acquisition message.
    map40 = maps.fetch(40)
    page40 = map40.instance_variable_get(:@events)[1].instance_variable_get(:@pages).first
    list40 = page40.instance_variable_get(:@list) || []
    regular = list40.index do |command|
      command_code(command) == 402 && command_parameters(command)[0].to_i == 0
    end
    if regular
      indent = list40[regular].instance_variable_get(:@indent).to_i + 1
      while list40[regular + 1] && command_code(list40[regular + 1]) == 230 &&
          command_parameters(list40[regular + 1]) == [75]
        list40.delete_at(regular + 1)
      end
      list40.insert(regular + 1, show_call.call("49", indent),
        event_command(355, indent, ["WCFGalleryScene.hold(75) #{marker}"]),
        hide_call.call(indent))
    end

    normalize_picture_and_black_scene_messages!(maps)
    maps.each do |map_id, map|
      save_data("Data/Map%03d.rvdata2" % map_id, map)
    end
    puts "PICTURE_GALLERY_ASSETS|maps=#{maps.keys.sort.join(',')}|CG10=deferred|CG19=Map038-E118"
  end

  def normalize_picture_and_black_scene_messages!(maps)
    totals = {}
    maps.each do |map_id, map|
      changed = 0
      # These two authored scenes deliberately hide the map/events behind a
      # black presentation for their dialogue sequence.
      always_normal = [38, 40].include?(map_id)
      (map.instance_variable_get(:@events) || {}).each_value do |event|
        next unless event
        (event.instance_variable_get(:@pages) || []).each do |page|
          list = page.instance_variable_get(:@list) || []
          gallery_visible = false
          black_screen = false
          visible_pictures = {}
          list.each_with_index do |command, index|
            code = command_code(command)
            params = command_parameters(command)
            if [355, 655].include?(code)
              script = params[0].to_s
              gallery_visible = true if script.include?("WCFGalleryScene.show(")
              gallery_visible = false if script.include?("WCFGalleryScene.hide")
            elsif code == 231
              visible_pictures[params[0].to_i] = true
            elsif code == 235
              visible_pictures.delete(params[0].to_i)
            elsif code == 221
              black_screen = true
            elsif code == 222
              black_screen = false
            elsif code == 101 &&
                (always_normal || gallery_visible || black_screen || !visible_pictures.empty?)
              cursor = index + 1
              first = true
              while cursor < list.length && command_code(list[cursor]) == 401
                text = command_parameters(list[cursor])[0].to_s
                cleaned = text.gsub(/\A\s*\\(?:bm\[\d+\]|cbm|cbt\[[^\]]*\])\s*/i, "")
                cleaned = "\\cbm #{cleaned}" if first
                if cleaned != text
                  command_parameters(list[cursor])[0] = cleaned
                  changed += 1
                end
                first = false
                cursor += 1
              end
            end
          end
        end
      end
      totals[map_id] = changed
    end
    totals
  end

  def normalize_picture_and_black_scene_messages
    map_ids = [6, 19, 22, 37, 38, 39, 40, 48]
    maps = {}
    map_ids.each do |map_id|
      path = "Data/Map%03d.rvdata2" % map_id
      maps[map_id] = load_data(path) if File.exist?(path)
    end
    totals = normalize_picture_and_black_scene_messages!(maps)
    maps.each do |map_id, map|
      save_data("Data/Map%03d.rvdata2" % map_id, map)
    end
    summary = totals.keys.sort.map { |id| "#{id}:#{totals[id]}" }.join(",")
    puts "NORMAL_PICTURE_MESSAGES|map=changed_lines|#{summary}"
  end

  # Final coffee-route reconciliation after the authored source variants have
  # been materialized.  The compact document retains dialogue text but drops
  # too many speaker/emotion directions to be a safe portrait source, so this
  # pass uses the Q1/Q2 markers and the actor anchors reconstructed from the
  # original route document.  It also removes the last script-level fade and
  # restores the omitted Shylvie reassurance in the bedroom scene.
  def repair_coffee_route_faces_fade_and_pictures
    faces = {
      hq:      ["HaiQuy_Giangsinh_Emote", 1],
      shylvie: ["CV_Giangsinh_Emote1", 1],
      kohi:    ["Kohi_Giangsinh_Emote1", 1],
      leo:     ["Leo_Giangsinh_Emote", 1],
      hakase:  ["Hakase_Giangsinh_Emote", 1],
      casual_hq: ["HaiQuy_Thuongphuc_Emote", 1],
      bully:   ["BullyQuy_Thuongphuc_Emote", 1]
    }
    emotion = lambda do |role, text|
      loud = text =~ /[A-ZÀ-ỸĐ]{4,}|!{2,}/
      question = text.include?("?")
      strained = text.include?("…") || text.include?("...") ||
        text =~ /mệt|buồn|lo lắng|bất an|không sao|chết|hết thở/i
      table = {
        hq:        {loud: 0, question: 3, strained: 5},
        casual_hq: {loud: 0, question: 3, strained: 5},
        bully:     {loud: 2, question: 3, strained: 5},
        shylvie:   {loud: 3, question: 5, strained: 1},
        kohi:      {loud: 2, question: 4, strained: 0},
        leo:       {loud: 3, question: 3, strained: 7},
        hakase:    {loud: 2, question: 3, strained: 0}
      }
      mood = question ? :question : strained ? :strained : loud ? :loud : nil
      mood ? table.fetch(role).fetch(mood) : faces.fetch(role)[1]
    end
    logical_text = lambda do |list, index|
      cursor = index + 1
      lines = []
      while cursor < list.length && command_code(list[cursor]) == 401
        lines << command_parameters(list[cursor])[0].to_s
        cursor += 1
      end
      lines.join(" ").gsub(/\s+/, " ")
    end
    set_face = lambda do |command, role, text|
      face = faces.fetch(role)
      params = command_parameters(command)
      params[0] = face[0]
      params[1] = emotion.call(role, text)
      params[2] = 0
      params[3] = 2
    end

    # Map037: restore the source line omitted by the compact expansion.
    map37 = load_data("Data/Map037.rvdata2")
    list37 = map37.instance_variable_get(:@events)[1]
      .instance_variable_get(:@pages).first.instance_variable_get(:@list)
    branch3 = list37.index do |command|
      command_code(command) == 111 &&
        command_parameters(command)[0, 4] == [1, 43, 0, 3]
    end
    branch4 = list37.index do |command|
      command_code(command) == 111 &&
        command_parameters(command)[0, 4] == [1, 43, 0, 4]
    end
    raise "Map037 coffee Shylvie branch missing" unless branch3 && branch4
    has_reassurance = list37[branch3...branch4].any? do |command|
      command_code(command) == 401 &&
        command_parameters(command)[0].to_s.include?("Shylvie sẽ thích")
    end
    unless has_reassurance
      answer = (branch3...branch4).find do |index|
        command_code(list37[index]) == 401 &&
          command_parameters(list37[index])[0].to_s.include?("Thiệt không?!")
      end
      raise "Map037 Shylvie reply insertion point missing" unless answer
      insertion = answer.downto(branch3).find { |i| command_code(list37[i]) == 101 }
      indent = list37[insertion].instance_variable_get(:@indent).to_i
      restored = wrapped_message_commands(
        ["Shylvie sẽ thích thôi, lo lắng chi vậy trời. Giờ thì ngủ dùm cái đi!"],
        width: 30, indent: indent)
      restored.each do |command|
        set_face.call(command, :bully,
          "Shylvie sẽ thích thôi, lo lắng chi vậy trời. Giờ thì ngủ dùm cái đi!") if command_code(command) == 101
      end
      list37.insert(insertion, *restored)
    end
    gift37 = list37.index do |command|
      command_code(command) == 111 &&
        command_parameters(command)[0, 4] == [1, 42, 0, 1]
    end
    gift37_end = list37.index do |command|
      command_code(command) == 111 &&
        command_parameters(command)[0, 4] == [1, 42, 0, 2]
    end
    list37.each_with_index do |command, index|
      next unless gift37 && gift37_end && index.between?(gift37, gift37_end - 1)
      if command_code(command) == 401
        params = command_parameters(command)
        params[0] = params[0].to_s.gsub("xunh quanh", "xung quanh")
      end
      next unless command_code(command) == 101
      text = logical_text.call(list37, index)
      plain = text.sub(/\A\\(?:bm\[\d+\]|cbm)\s*/i, "")
      bully_line = plain =~ /\A(?:Gì vậy trời|Leo sẽ thích|Kiểu gì Kohi|Shylvie sẽ thích|Hakase sẽ thích|Phiền quá|Thân thiện gì|Không nhưng|một người dễ tính|chẳng thích máy pha|vốn là một đứa thích cà phê|là một kẻ tò mò)/
      set_face.call(command, bully_line ? :bully : :casual_hq, plain)
    end
    save_data("Data/Map037.rvdata2", map37)

    # Map038 and Map039: actor anchors 2..6 were reconstructed from the DOCX.
    anchor_roles = {2 => :hq, 3 => :shylvie, 4 => :kohi, 5 => :leo, 6 => :hakase}
    map38_overrides = {
      "Ngạc nhiên sai thứ rồi" => :hq,
      "Món quà tuyệt vời lắm Quỳ" => :leo,
      "Phải như vậy chứ" => :hq,
      "Thiệt hả?!" => :leo,
      "Hehe!! Bà thích là tui vui" => :hq,
      "Hả? Vụ gì đấy" => :hq,
      "À, tuần trước tui với Shylvie" => :kohi,
      "À…Thế là mấy người đem tui" => :hq,
      "Không không, không hẳn là thế" => :kohi,
      "Vụ…tui nhìn thấy trước tương lai" => :hq,
      "Ừm hứm! Shylvie thậm chí" => :kohi,
      "Ừ, chuyện là vậy đó" => :shylvie,
      "Mà bỏ qua vụ đó đi" => :kohi,
      "À…Thế thì không một ai thắng" => :hq,
      "Tại vì ngoài máy pha cà phê" => :hq,
      "Ồ! Tui có nghe về nó rồi" => :kohi,
      "Đúng đúng! Nhưng còn điều này" => :hq,
      "Là sao á" => :kohi,
      "Là tôm tích núi lửa phải ăn" => :hq,
      "Ồ!! Ra là vậy" => :kohi,
      "Từ hôm nay. Thấy sao hả Shylvie" => :hq,
      "Phải thích chứ ha" => :hq,
      "Hả? Trùng hợp gì" => :hq,
      "Là máy pha cà phê đó" => :hq,
      "À, em chỉ nghĩ đơn giản là Hakase" => :hq
    }
    map39_overrides = {
      1 => {
        "Ơ? Quỳ đấy à" => :leo,
        "À, tui đang pha cà phê" => :leo,
        "À, bà có thể đổ thêm Sting" => :leo,
        "A!! Leo pha lén cà phê" => :kohi,
        "Ừm hưm! Là cà phê Luminous" => :kohi,
        "Ok! Chờ xíu" => :leo
      },
      2 => {
        "Ơ Quỳ, bà về sớm thế" => :kohi,
        "Uống chứ. Bà pha loại" => :hq,
        "À, cái loại của Leo ấy" => :kohi,
        "Ừ, ngon ghê" => :hq,
        "Phải ha!!" => :kohi,
        "Bảo sao bà uống tận" => :hq,
        "Ồ, nó đặc biệt ở chỗ đó" => :kohi,
        "Ừa, bảo sao đợt lâu rồi" => :hq,
        "Chuyện gì vậy Shylvie" => :leo,
        "K-Kohi! Bà ấy không còn thở" => :shylvie,
        "Bà ấy đang ngủ nhưng hơi thở" => :hakase,
        "Vậy chúng ta phải làm sao" => :shylvie,
        "Không làm gì cả" => :hakase,
        "Điên à? Chả phải ông bảo" => :shylvie,
        "Không chết được, yên tâm" => :hakase,
        "Chết thật! Thôi thì để bà ấy" => :leo,
        "Nè, cà phê Atlantis thực sự" => :hakase,
        "Cái này mới gặp lần đầu" => :hq,
        "À thì…sáng nay Kohi" => :hakase,
        "Chắc là không sao đâu ha" => :hq
      },
      3 => {
        "Q…Quỳ…Bà đến rồi hả" => :shylvie,
        "Shylvie sao vậy" => :hq,
        "Giọng điệu này…bà" => :shylvie,
        "Cà phê Atlantis ngon không" => :hq,
        "Haiz…\" ngon \" quá trời" => :shylvie,
        "Haiz…\"ngon\" quá trời" => :shylvie,
        "Ồ, đương nhiên rồi, keke" => :hq,
        "Ừ, xịn đến mức mất ngủ" => :shylvie,
        "Trời trời, khổ thân chưa" => :hq
      },
      4 => {
        "Ơ? Quỳ đấy à" => :leo,
        "À, Hakase bảo là sẽ pha cà phê" => :leo,
        "Ơ! Quỳ!! Cậu về đúng lúc" => :hakase,
        "Thiệt không? Thế sao da" => :hakase,
        "À!! Ra là thế!!" => :hakase,
        "Trời ơi, vậy trưa nay" => :hakase
      }
    }
    [38, 39].each do |map_id|
      map = load_data("Data/Map%03d.rvdata2" % map_id)
      event_id = map_id == 38 ? 7 : 1
      list = map.instance_variable_get(:@events)[event_id]
        .instance_variable_get(:@pages).first.instance_variable_get(:@list)
      start = list.index do |command|
        command_code(command) == 111 &&
          command_parameters(command)[0, 4] == [1, 42, 0, 1]
      end
      finish = list.index do |command|
        command_code(command) == 111 &&
          command_parameters(command)[0, 4] == [1, 42, 0, 2]
      end
      raise "Map%03d coffee branch missing" % map_id unless start && finish
      recipient = nil
      list.each_with_index do |command, index|
        next if index < start || index >= finish
        if command_code(command) == 111 && command_parameters(command)[0, 3] == [1, 43, 0]
          recipient = command_parameters(command)[3].to_i
          next
        end
        next unless command_code(command) == 101
        text = logical_text.call(list, index)
        anchor = text[/\A\\bm\[(\d+)\]/i, 1]
        role = anchor && anchor_roles[anchor.to_i]
        if !role && map_id == 38
          match = map38_overrides.find { |needle, _value| text.include?(needle) }
          role = match[1] if match
        elsif !role && map_id == 39 && map39_overrides[recipient]
          match = map39_overrides[recipient].find { |needle, _value| text.include?(needle) }
          role = match[1] if match
        end
        next unless role
        plain = text.sub(/\A\\(?:bm\[\d+\]|cbm)\s*/i, "")
        set_face.call(command, role, plain)
      end
      save_data("Data/Map%03d.rvdata2" % map_id, map)
    end

    # Map040 keeps both player choices, but uses the native fade command and
    # recomputes Q1/Q2 expressions from their authored faces.
    map40 = load_data("Data/Map040.rvdata2")
    list40 = map40.instance_variable_get(:@events)[1]
      .instance_variable_get(:@pages).first.instance_variable_get(:@list)
    list40.each_with_index do |command, index|
      if [355, 655].include?(command_code(command)) &&
          command_parameters(command)[0].to_s.match?(/\Ascreen\.start_fadeout\(/)
        command.instance_variable_set(:@code, 221)
        command.instance_variable_set(:@parameters, [])
        next
      end
      next unless command_code(command) == 101
      params = command_parameters(command)
      role = case params[0].to_s
             when "HaiQuy_Thuongphuc_Emote" then :casual_hq
             when "BullyQuy_Thuongphuc_Emote" then :bully
             end
      next unless role
      text = logical_text.call(list40, index).sub(/\A\\cbm\s*/i, "")
      set_face.call(command, role, text)
    end
    save_data("Data/Map040.rvdata2", map40)

    integrate_picture_gallery_assets
    puts "COFFEE_ROUTE_REPAIRED|choices=regular+fishing|fade=native|faces=DOCX_anchors+emotion|DiamondCoffee=56"
  end

  # Build the two authored "Mua mì cay cho Leo" branches. The route owns its
  # state and preparation map, borrows Map019/014, then surgically merges the
  # party pages into the shared editor-authored Map038 without entering the
  # supermarket gift matrix.
  def implement_spicy_noodle_leo_route
    active_switch = 55
    aira_switch = 56
    done_switch = 57
    branch_variable = 50 # 1=Aira, 2=Hải Quỳ
    stage_variable = 51
    hint_id = 18

    nest = lambda do |commands, amount|
      commands.each do |command|
        command.instance_variable_set(:@indent,
          command.instance_variable_get(:@indent).to_i + amount)
      end
      commands
    end
    say = lambda do |face, face_index, text, indent = 0|
      commands = wrapped_message_commands([text], tag: "\\cbm ", width: 30, indent: indent)
      commands.each do |command|
        next unless command_code(command) == 101
        command.instance_variable_set(:@parameters,
          [face.to_s, face.to_s.empty? ? 0 : face_index, 0, 2])
      end
      commands
    end
    narration = lambda { |text, indent = 0| say.call("", 0, text, indent) }
    hq = lambda { |text, index = 1, indent = 0| say.call("HaiQuy_Thuongphuc_Emote", index, text, indent) }
    aira = lambda { |text, index = 1, indent = 0| say.call("BullyQuy_Thuongphuc_Emote", index, text, indent) }
    hq_xmas = lambda { |text, index = 1, indent = 0| say.call("HaiQuy_Giangsinh_Emote", index, text, indent) }
    aira_xmas = lambda { |text, index = 2, indent = 0| say.call("HaiQuy_Giangsinh_Emote1", index, text, indent) }
    leo = lambda { |text, index = 1, indent = 0| say.call("Leo_Giangsinh_Emote", index, text, indent) }
    shy = lambda { |text, index = 1, indent = 0| say.call("CV_Giangsinh_Emote1", index, text, indent) }
    kohi = lambda { |text, index = 1, indent = 0| say.call("Kohi_Giangsinh_Emote1", index, text, indent) }
    hakase = lambda { |text, index = 1, indent = 0| say.call("Hakase_Giangsinh_Emote", index, text, indent) }
    picture = lambda do |id, commands, indent = 0|
      [event_command(355, indent, ["WCFGalleryScene.show(#{id}) # WCF_GALLERY_SCENE"])] +
        commands +
        [event_command(355, indent, ["WCFGalleryScene.hide # WCF_GALLERY_SCENE"])]
    end

    # Map010: add the fourth route choice exactly once.
    map10_path = "Data/Map010.rvdata2"
    map10 = load_data(map10_path)
    bus_event = map10.instance_variable_get(:@events).fetch(2)
    bus_list = bus_event.instance_variable_get(:@pages).first.instance_variable_get(:@list)
    choice = bus_list.find { |command| command_code(command) == 102 && command_parameters(command)[0].include?("Tới siêu thị") }
    raise "Map010 route choice missing" unless choice
    choices = command_parameters(choice)[0]
    unless choices.include?("Mua mì cay")
      choices << "Mua mì cay"
      branch_end = bus_list.index { |command| command_code(command) == 404 }
      raise "Map010 branch end missing" unless branch_end
      noodle_branch = [event_command(402, 0, [3, "Mua mì cay"])]
      noodle_branch.concat(hq.call("Tự dưng trong đầu mình nghĩ đến mì cay. Mà nghĩ đến mì cay thì lại nhớ tới Leo! Đây là tín hiệu sao?", 0, 1))
      noodle_branch.concat(hq.call("Giáng sinh năm nay đãi ổng một bữa mì cay thập cẩm siêu to khổng lồ mới được!", 1, 1))
      noodle_branch.concat(hq.call("Cái phép thuật phân tích công thức món ăn Hakase chỉ sẽ hữu dụng đây. Đến quán mì cay mà Leo yêu thích thôi!", 0, 1))
      noodle_branch.concat([
        event_command(121, 1, [active_switch, active_switch, 0]),
        event_command(121, 1, [aira_switch, done_switch, 1]),
        event_command(122, 1, [branch_variable, stage_variable, 0, 0, 0]),
        event_command(221, 1, []),
        event_command(201, 1, [0, 20, 16, 17, 8, 2])
      ])
      bus_list.insert(branch_end, *noodle_branch)
      save_data(map10_path, map10)
    end

    # Map020: authored noodle-shop choice.  Keep its native three-layer tile
    # map; MyCay.png is a mapshot, not a replacement parallax/top layer.
    map20_path = "Data/Map020.rvdata2"
    map20 = load_data(map20_path)
    template = load_data("Data/Map037.rvdata2").instance_variable_get(:@events).fetch(1)
    shop = [
      event_command(355, 0, ["$game_player.transparent=false"]),
      event_command(117, 0, [3]),
      event_command(222, 0, [])
    ]
    shop.concat(narration.call("Quán mì cay mà Leo yêu thích đây rồi. Lúc ý tưởng lóe lên thì tôi hùng hổ lắm, xong lúc đến nơi mới nhớ ra rằng tôi không ăn được cay."))
    shop.concat(hq.call("Đừng chùn chân nữa, Dahlia! Mày ăn được cay! Chỉ là ớt thôi mà… chắc là không cay đâu!", 5))
    shop.concat(aira.call("Trời ơi, nay chưa đủ nóng hay sao mà đi ăn đồ cay vậy gái?", 3))
    shop.concat(hq.call("Biết là vậy rồi… Nhưng mà không ăn thì không nấu được đâu!!", 3))
    shop.concat(aira.call("Nấu mì cay dễ mà! Ngươi cứ để ta nấu là được!", 1))
    shop.concat(hq.call("Aira biết nấu mì cay á? Tin tưởng được không đấy?", 3))
    shop.concat(aira.call("Phải thử mới biết được chứ.", 1))
    shop << event_command(102, 0, [["Tin tưởng", "Có cái nịt"], 1])
    shop << event_command(402, 0, [0, "Tin tưởng"])
    shop.concat(hq.call("Tin tưởng Aira lần này đấy!", 1, 1))
    shop.concat(aira.call("Vậy đi siêu thị mua nguyên vật liệu thôi.", 1, 1))
    shop.concat([
      event_command(122, 1, [branch_variable, branch_variable, 0, 0, 1]),
      event_command(122, 1, [stage_variable, stage_variable, 0, 0, 1]),
      event_command(121, 1, [aira_switch, aira_switch, 0]),
      event_command(221, 1, []),
      event_command(201, 1, [0, 19, 26, 35, 2, 2]),
      event_command(402, 0, [1, "Có cái nịt"])
    ])
    shop.concat(hq.call("Có cái nịt! Lần nào để Aira làm hộ đều xôi hỏng bỏng không hết!", 3, 1))
    shop.concat(aira.call("Hứ, vậy thôi!!", 5, 1))
    shop.concat(narration.call("Tôi dồn hết dũng khí bước đến quầy, gọi mang về tất cả mọi loại mì cay của quán trước bao ánh nhìn ngỡ ngàng.", 1))
    shop.concat(narration.call("Tốt nhất nên về nhà dùng ma thuật phân tích công thức. Nhân loại không nên biết quá nhiều về ma pháp. Hoặc tôi bị lười. Lý do nào cũng hợp lý hết.", 1))
    shop.concat([
      event_command(122, 1, [branch_variable, branch_variable, 0, 0, 2]),
      event_command(122, 1, [stage_variable, stage_variable, 0, 0, 2]),
      event_command(121, 1, [aira_switch, aira_switch, 1]),
      event_command(221, 1, []),
      event_command(201, 1, [0, 47, 10, 9, 2, 2]),
      event_command(404, 0, [])
    ])
    shop_page = page_from_template(template, shop, trigger: 3, priority: 0, switch_id: active_switch)
    map20.instance_variable_set(:@display_name, "Quán mì cay")
    map20.instance_variable_set(:@note, "NOODLE route shop; native tile map; Switch 55, Variable 50")
    map20.instance_variable_set(:@events, {1 => event_from_pages(template, 1, "SCN-NOODLE-SHOP", 0, 0, [shop_page])})
    save_data(map20_path, map20)

    # Map019: Aira branch is a non-interactive ingredient montage.
    map19_path = "Data/Map019.rvdata2"
    map19 = load_data(map19_path)
    market_events = map19.instance_variable_get(:@events)
    market_template = market_events.fetch(42)
    market = [event_command(117, 0, [3]), event_command(222, 0, [])]
    market.concat(narration.call("Cùng với Aira, tôi mau chóng mua nguyên vật liệu cho nồi mì cay được bà ấy đặt tên là “dữ tợn”."))
    market.concat(narration.call("Hành baro, bắp cải, thịt gà, thịt bò, hải sản, bột mì… rồi cả vi cá mập, đầu heo, mía và nhộng tằm. Công thức này thực sự ổn chứ?"))
    market.concat([
      event_command(122, 0, [stage_variable, stage_variable, 0, 0, 2]),
      event_command(221, 0, []),
      event_command(201, 0, [0, 47, 10, 9, 2, 2])
    ])
    market_page = page_from_template(market_template, market, trigger: 3, priority: 0,
      switch_id: active_switch, variable_id: stage_variable, variable_value: 1)
    market_events[45] = event_from_pages(market_template, 45,
      "SCN-NOODLE-AIRA-INGREDIENTS", 0, 0, [market_page])
    save_data(map19_path, map19)

    # Map047: bedroom preparation, sleep and Christmas morning.
    map47 = Marshal.load(Marshal.dump(load_data("Data/Map037.rvdata2")))
    prep_template = map47.instance_variable_get(:@events).fetch(1)
    prep = [
      event_command(355, 0, ["$game_player.transparent=true"]),
      event_command(355, 0, ["layer(47,0,[\"HQ_Room_Midnight_Top\",0,0,255,200,0,0,0])"]),
      event_command(655, 0, ["refresh_layers"]),
      event_command(117, 0, [3]),
      event_command(222, 0, []),
      event_command(355, 0, ["GroupChatPreset.noodle_recipient"]),
      event_command(230, 0, [1]),
      event_command(355, 0, ["PhoneGroupChatSave.save_current_cutscene(:wanderer_group)"])
    ]
    prep.concat(hq.call("Thế là xong!!"))
    prep.concat(aira.call("Nè con nhãi kia, hình như chưa mua Sting.", 3))
    prep.concat(hq.call("Hả gì? Từ khi nào muốn uống Sting vậy?", 3))
    prep.concat(aira.call("Mua cho Leo mà!! Cái bình Sting 20 lít, nhớ không?", 1))
    prep.concat(hq.call("À!! Để tui gọi họ gửi năm thùng qua nhà mình cho tiện!", 0))
    prep.concat(aira.call("LƯỜI THÌ CÓ!!!", 3))
    prep << event_command(111, 0, [1, branch_variable, 0, 1, 0])
    prep.concat(hq.call("Lưng tôi dán chặt lên giường, không nhúc nhích nổi. Aira có chắc là mình nấu được không đấy?", 3, 1))
    prep.concat(aira.call("Chả phải ngươi được ăn đồ ta nấu mấy lần rồi sao? Cứ đợi đến Giáng sinh đi, ta trổ tài cho xem.", 1, 1))
    prep.concat(hq.call("Nhưng đâu phải mì cay đâu!!", 3, 1))
    prep.concat(aira.call("Giờ thì ngủ dùm cái!", 3, 1))
    prep.concat(hq.call("Có chắc là Aira không trêu Leo không đấy?", 5, 1))
    prep.concat(aira.call("Ngươi còn hỏi nữa là ta trêu hắn thật đấy.", 5, 1))
    prep.concat(narration.call("Dưới sự thúc giục của Aira, tôi mau chóng chìm vào giấc ngủ.", 1))
    prep << event_command(411, 0, [])
    prep.concat(narration.call("Bên cạnh tôi là ba chiếc mâm xếp chồng, mỗi mâm năm tô mì cay. Tôi vừa xem anime vừa ăn và dùng ma thuật phân tích từng công thức.", 1))
    prep.concat(narration.call("Tô thứ chín… rồi tô thứ mười. Mắt tôi díp lại. Aira ơi, có gì gọi tớ dậy nhé… tớ chợp mắt một lát.", 1))
    prep << event_command(412, 0, [])
    prep.concat([event_command(221, 0, []), event_command(230, 0, [30]), event_command(222, 0, [])])
    prep << event_command(111, 0, [1, branch_variable, 0, 1, 0])
    prep.concat(aira.call("Dậy coi con âm binh!!", 3, 1))
    prep.concat(hq.call("Ưm… cho nướng thêm năm phút nữa…", 5, 1))
    prep.concat(aira.call("Không có năm phút gì hết! Dậy coi!!", 3, 1))
    prep.concat(narration.call("Chiếc miệng sau đầu dùng hết lực hất tung tôi khỏi giường. Tôi lảo đảo bước vào nhà vệ sinh.", 1))
    prep << event_command(411, 0, [])
    prep.concat(hq.call("Ồ, nay là Giáng sinh rồi à… Tôi đã ngủ một mạch đến… GIÁNG SINH?!", 3, 1))
    prep.concat(hq.call("Chết rồi!! Còn vài tiếng nữa là đến tiệc! Chìa khóa dịch chuyển đâu rồi?!", 3, 1))
    prep.concat(narration.call("Bên giường là chai Sting 20 lít, túi đi chợ, trang phục, chìa khóa dịch chuyển và tờ công thức. Tôi túm lấy mọi thứ.", 1))
    prep << event_command(412, 0, [])
    prep.concat(picture.call(28, hq.call("Không phải bộ này…", 5)))
    prep.concat(picture.call(29, aira.call("Bộ này xấu quá.", 5)))
    prep.concat(picture.call(30, hq.call("Đồng ý.", 1)))
    prep.concat(picture.call(31, hq.call("Bộ này ổn này!!", 0)))
    prep.concat(hq.call("Ủa mà nguyên liệu đâu?", 3))
    prep.concat(aira.call("Ta đã chuẩn bị hết rồi. Cả chai Sting 20 lít nữa.", 1))
    prep.concat([
      event_command(122, 0, [stage_variable, stage_variable, 0, 0, 3]),
      event_command(221, 0, []),
      event_command(201, 0, [0, 14, 14, 6, 8, 2])
    ])
    prep_page = page_from_template(prep_template, prep, trigger: 3, priority: 0, switch_id: active_switch)
    prep_event = event_from_pages(prep_template, 1, "SCN-NOODLE-PREP-SLEEP", 0, 0, [prep_page])
    prep_sprite = map47.instance_variable_get(:@events)[3]
    map47.instance_variable_set(:@display_name, "Phòng Hải Quỳ — Chuẩn bị mì cay")
    map47.instance_variable_set(:@note, "[lighting off]\r\n<full lock parallax>\r\n<tile lock parallax>\r\nNOODLE route prep")
    map47.instance_variable_set(:@events, {1 => prep_event, 3 => prep_sprite})
    save_data("Data/Map047.rvdata2", map47)

    # Map014: route-only cooking autorun, using existing sprites and magic/fire
    # animations as the approved demo substitute for bespoke cooking art.
    map14_path = "Data/Map014.rvdata2"
    map14 = load_data(map14_path)
    kitchen_events = map14.instance_variable_get(:@events)
    kitchen_template = kitchen_events.fetch(1)
    cooking = [
      event_command(355, 0, ["$game_player.transparent=true"]),
      event_command(355, 0, ["layer(14,0,[\"Map_Wanderer_Office_Kitchen_Top\",0,0,255,200,0,0,0])"]),
      event_command(655, 0, ["refresh_layers"]),
      event_command(117, 0, [3]), event_command(222, 0, [])
    ]
    cooking.concat(shy.call("Quỳ!! Hello! Mọi người vẫn đang chuẩn bị. Bà cứ thoải mái dùng bếp đi!", 1))
    cooking << event_command(111, 0, [1, branch_variable, 0, 1, 0])
    cooking.concat(aira_xmas.call("TỚI GIỜ BỔN CÔ NƯƠNG TA ĐÂY TRỔ TÀI RỒI!", 2, 1))
    cooking.concat([event_command(212, 1, [25, 151, false]), event_command(230, 1, [30]), event_command(212, 1, [25, 59, false]), event_command(225, 1, [5, 5, 20])])
    cooking.concat(picture.call(71, aira_xmas.call("Hoàn thành rồi! Đây sẽ là món mì cay duy nhất mà Leo nhung nhớ mãi!", 2, 1), 1))
    cooking << event_command(411, 0, [])
    cooking.concat(hq_xmas.call("Chà không sao đâu, Sierra tự dọn được mà! TỚI GIỜ TRỔ TÀI RỒI!", 0, 1))
    cooking.concat([event_command(212, 1, [25, 151, false]), event_command(230, 1, [30]), event_command(212, 1, [25, 59, false]), event_command(225, 1, [5, 5, 20])])
    cooking.concat(picture.call(72, hq_xmas.call("Hoàn thành rồi! Đây sẽ là món mì cay tuyệt vời nhất mà Leo từng được ăn!!", 0, 1), 1))
    cooking << event_command(412, 0, [])
    cooking.concat([event_command(221, 0, []), event_command(201, 0, [0, 38, 14, 21, 2, 2])])
    cooking_page = page_from_template(kitchen_template, cooking, trigger: 3, priority: 1,
      switch_id: active_switch, variable_id: stage_variable, variable_value: 3)
    cook_event = event_from_pages(kitchen_template, 25, "SCN-NOODLE-COOKING", 14, 5, [cooking_page])
    source_graphic = load_data("Data/Map038.rvdata2").instance_variable_get(:@events).fetch(2)
      .instance_variable_get(:@pages).first.instance_variable_get(:@graphic)
    cooking_page.instance_variable_set(:@graphic, Marshal.load(Marshal.dump(source_graphic)))
    kitchen_events[25] = cook_event
    save_data(map14_path, map14)

    # Map048: inert donor/rollback copy for the noodle party commands. Runtime
    # pages are merged into the current Map038 at the end of this method.
    map48 = Marshal.load(Marshal.dump(load_data("Data/Map038.rvdata2")))
    source_events = map48.instance_variable_get(:@events)
    party_template = source_events.fetch(1)
    party = [
      event_command(355, 0, ["$game_player.transparent=true"]),
      event_command(355, 0, ["layer(48,0,[\"Map_Wanderer_Office_GiangSinh_Top\",0,0,255,200,0,0,0])"]),
      event_command(655, 0, ["refresh_layers"]),
      event_command(117, 0, [18]), event_command(117, 0, [3]), event_command(222, 0, [])
    ]
    party.concat(narration.call("Sierra phủ tuyết lên cả văn phòng. Tiếng Kohi và Shylvie la toáng nối tiếp tiếng chén dĩa vỡ tanh bành."))
    party.concat(narration.call("Tôi vừa bước khỏi bếp thì một đống tuyết đổ ầm xuống, chôn vùi cả người."))
    party << event_command(111, 0, [1, branch_variable, 0, 1, 0])
    party.concat(picture.call(7, narration.call("Kohi và Shylvie nhìn Bully Quỳ đang mắc kẹt trong tuyết rồi phá lên cười."), 1))
    party << event_command(411, 0, [])
    party.concat(picture.call(6, narration.call("Kohi và Shylvie nhìn Hải Quỳ đang mắc kẹt trong tuyết rồi phá lên cười."), 1))
    party << event_command(412, 0, [])
    party.concat(narration.call("Kohi và Shylvie kéo tôi ra. Leo và Hakase vừa về tới nơi cũng không nhịn được cười."))
    party.concat(leo.call("Vậy “kiệt tác” này là do bà làm à?", 1))
    party.concat(hq_xmas.call("Ừm! Tui nghĩ cho cả văn phòng ngập trong tuyết sẽ hay lắm mà dè đâu…", 1))
    party.concat(leo.call("Haha. Ý tưởng không tồi. Cũng lâu lắm rồi tui chưa thấy tuyết.", 1))
    party.concat(narration.call("Mọi người dọn dẹp, bày thức ăn rồi cùng ăn uống, kể chuyện và chơi board game. Leo với Hakase liên tục bị “kaboom”."))
    party.concat(leo.call("E hèm! Tui nghĩ đã đến lúc cho sự kiện chính ngày hôm nay rồi, Quỳ nhỉ?", 1))
    party << event_command(111, 0, [1, branch_variable, 0, 1, 0])
    party.concat(picture.call(71, aira_xmas.call("Xin giới thiệu, đây là mì cay “dữ tợn”! Mì mực, thịt chiên, hải sản nướng mía, chả đầu heo và nhộng tằm!", 2, 1), 1))
    party.concat(shy.call("Thôi rồi… Bả lại sáng tạo ra món dị hợm rồi…!", 5, 1))
    party << event_command(411, 0, [])
    party.concat(picture.call(72, hq_xmas.call("Đây là nồi mì cay Chìm và Nổi Atlantis, hội tụ đủ loại thịt và hải sản độc lạ!", 0, 1), 1))
    party.concat(leo.call("Thịt gì với thịt gì đó bà!!", 7, 1))
    party << event_command(412, 0, [])
    party.concat(narration.call("Mọi người nếm thử rồi đồng loạt thừa nhận nồi mì trông lạ nhưng thực sự ngon."))
    party.concat(hakase.call("Quỳ, tuyết này ăn được không?", 1))
    party.concat(hq_xmas.call("Chắc được á anh.", 3))
    party.concat(narration.call("Hakase xới tuyết cho thẳng vào tô mì cay."))
    party.concat(shy.call("KHÔNG AI LẠI ĂN ĐÁ BÀO MÌ CAY CẢ!! NÓ KHÔNG NÊN TỒN TẠI!!", 5))
    party.concat(hakase.call("Ngon mà!!", 0))
    party.concat(hq_xmas.call("Ngoài ra, tui còn chuẩn bị cho Leo…", 0))
    party.concat([
      event_command(101, 0, ["", 0, 0, 2]),
      event_command(401, 0, ["\\cbm \\c[6][ẢNH BÌNH STING 20 LÍT]"])
    ])
    party.concat(leo.call("BÌNH STING 20 LÍT!? BÀ ĐIÊN RỒI HẢ QUỲ?!", 7))
    party.concat(hq_xmas.call("ĐIÊN CHỨ!! 20 LÍT UỐNG MỚI ĐÃ!!", 0))
    party.concat(leo.call("AAAAAAAAAAAAAAAAA!! TUYỆT VỜI QUÁ QUỲ!!", 7))
    party.concat(narration.call("Ăn xong, mọi người dọn dẹp và tiếp tục vòng tặng quà."))
    party.concat(picture.call(73, narration.call("Leo trao cho Hakase một hộp mô hình Armored Core chính hãng.")))
    party.concat(hakase.call("Là nó!! Ôi vãi cả lồng đèn Leo ơi!! Tôi yêu nó vãi cả nồi! Cả ông nữa!", 0))
    party.concat(leo.call("Ê ê, no homo bro.", 1))
    party.concat(picture.call(39, narration.call("Hakase đặt hộp xuống rồi nhảy phóc lên ôm Leo thật chặt.")))
    party.concat(shy.call("Wow, that's gay.", 3))
    party.concat(picture.call(69, narration.call("Hakase tặng Shylvie một chiếc Mặt Nạ Đá đã tinh chỉnh.")))
    party.concat(picture.call(36, narration.call("Hải Quỳ và Shylvie cùng hốt hoảng khi nhận ra đây là chiếc mặt nạ nguyền rủa từng bị phong ấn.")))
    party.concat(shy.call("Anh thực sự tinh chỉnh lại cái mặt nạ đá nguyền rủa mà bọn em phong ấn sao?!", 3))
    party.concat(hakase.call("Ủa, có phong ấn hả?", 3))
    party.concat(picture.call(47, kohi.call("LÀ BỘ MÓC LEN MỚI!!", 0)))
    party.concat(narration.call("Đột nhiên điện thoại tôi rung lên. Silver Wing báo khu vực rìa lỗ hổng vực sâu 61 đã mất liên lạc và yêu cầu tôi quay về làm nhiệm vụ giải cứu."))
    party.concat(hq_xmas.call("Tôi biết ngay mà. Cứu người vẫn quan trọng nhất. Tiếc ghê, vậy là không được xem phim cùng mọi người rồi.", 5))
    party.concat(kohi.call("Quỳ! Bà sao vậy?", 5))
    party.concat(hq_xmas.call("A… hông có gì!! Tui đang nghĩ về đá bào…", 1))
    party.concat(picture.call(44, kohi.call("Bữa bà nói chưa ăn bánh phô mai cam đúng không! Tui làm nó cho bà đó!", 0)))
    party.concat(picture.call(40, narration.call("Tôi mở miệng cạp mất một nửa chiếc bánh phô mai cam.")))
    party.concat(picture.call(41, narration.call("Rồi tôi đưa nửa còn lại ra sau cho chiếc miệng của Bully Quỳ ăn hết.")))
    party.concat(leo.call("Ờm Quỳ à… bà ăn cả đĩa à…?", 3))
    party.concat(hq_xmas.call("Đâu có!", 1))
    party.concat(narration.call("Trong lúc mọi người dọn bàn tiệc, tôi chuẩn bị bắp rang, nước ngọt và kem. Điện thoại vẫn rung không ngừng."))
    party.concat(hq_xmas.call("Xin lỗi mọi người—", 5))
    party.concat(leo.call("Bà cứ đi đi, không sao hết.", 1))
    party.concat(shy.call("Nhớ về sớm đấy nhé!", 1))
    party.concat(hakase.call("Không là mọi người ăn hết kem đó!!", 0))
    party.concat(kohi.call("Đi cẩn thận nhé!!", 0))
    party.concat(hq_xmas.call("Ừa! Tui đi đây!! Nhớ chừa kem cho tui đó!!", 0))
    party.concat([
      event_command(121, 0, [done_switch, done_switch, 0]),
      event_command(122, 0, [41, 41, 0, 0, hint_id]),
      event_command(121, 0, [active_switch, active_switch, 1]),
      event_command(221, 0, []),
      event_command(201, 0, [0, 36, 8, 6, 2, 2])
    ])
    party_page = page_from_template(party_template, party, trigger: 3, priority: 0, switch_id: active_switch)
    party_event = event_from_pages(party_template, 1, "SCN-NOODLE-CHRISTMAS-PARTY", 0, 0, [party_page])
    party_events = {1 => party_event}
    (2..6).each do |id|
      source = source_events.fetch(id)
      page = page_from_template(source, [], trigger: 0, priority: 1)
      party_events[id] = event_from_pages(source, id, source.instance_variable_get(:@name).sub(/ \[E\d+\]\z/, ""),
        source.instance_variable_get(:@x), source.instance_variable_get(:@y), [page])
    end
    map48.instance_variable_set(:@display_name, "Wanderer Office — Tiệc mì cay")
    map48.instance_variable_set(:@note, "<full lock parallax>\r\n<tile lock parallax>\r\nNOODLE route party; no free exploration")
    map48.instance_variable_set(:@events, party_events)
    save_data("Data/Map048.rvdata2", map48)

    # Shared hint router: exact authored best-ending message, no invented art.
    map36_path = "Data/Map036.rvdata2"
    map36 = load_data(map36_path)
    hint_event = map36.instance_variable_get(:@events).fetch(1)
    hint = [event_command(355, 0, ["$game_player.transparent=true"]), event_command(117, 0, [3]), event_command(222, 0, [])]
    hint.concat(aira.call("ROUTE MUA MÌ CAY CHO LEO — BEST ENDING CỦA LEO!!", 0))
    hint.concat(aira.call("Xin chúc mừng!! Trong các kết quả mà ta nhìn thấy, chỉ có cái này mới là Best Ending cho Leo thôi!", 1))
    hint.concat(aira.call("Gì? Ngươi muốn biết các Best Ending còn lại á? Còn lâu!", 3))
    hint.concat([event_command(117, 0, [3]), event_command(230, 0, [60]), event_command(354, 0, [])])
    hint_page = page_from_template(hint_event, hint, trigger: 3, priority: 0,
      variable_id: 41, variable_value: hint_id)
    pages = hint_event.instance_variable_get(:@pages)
    pages.reject! do |page|
      condition = page.instance_variable_get(:@condition)
      condition.instance_variable_get(:@variable_valid) &&
        condition.instance_variable_get(:@variable_id) == 41 &&
        condition.instance_variable_get(:@variable_value) == hint_id
    end
    pages << hint_page
    save_data(map36_path, map36)

    # Map tree and runtime registry.
    infos_path = "Data/MapInfos.rvdata2"
    infos = load_data(infos_path)
    infos.fetch(20).instance_variable_set(:@name, "Quán mì cay")
    infos.fetch(20).instance_variable_set(:@parent_id, 10)
    infos.fetch(20).instance_variable_set(:@expanded, true)
    [[47, 37, "Phòng Hải Quỳ — Chuẩn bị mì cay", 20],
     [48, 38, "Wanderer Office — Tiệc mì cay", 20]].each do |id, source_id, name, parent|
      info = infos[id] || Marshal.load(Marshal.dump(infos.fetch(source_id)))
      info.instance_variable_set(:@name, name)
      info.instance_variable_set(:@parent_id, parent)
      info.instance_variable_set(:@order,
        infos.values.compact.map { |entry| entry.instance_variable_get(:@order).to_i }.max + 1) unless infos[id]
      info.instance_variable_set(:@expanded, true)
      infos[id] = info
    end
    save_data(infos_path, infos)

    system_path = "Data/System.rvdata2"
    system = load_data(system_path)
    switches = system.instance_variable_get(:@switches)
    variables = system.instance_variable_get(:@variables)
    switches[active_switch] = "NOODLE_ACTIVE"
    switches[aira_switch] = "NOODLE_AIRA_CONTROL"
    switches[done_switch] = "NOODLE_DONE"
    variables[branch_variable] = "NOODLE_BRANCH"
    variables[stage_variable] = "NOODLE_STAGE"
    save_data(system_path, system)

    # Round-trip verification of route, pictures and placeholder contract.
    errors = []
    verify10 = load_data(map10_path)
    list10 = verify10.instance_variable_get(:@events)[2].instance_variable_get(:@pages).first.instance_variable_get(:@list)
    errors << "Map010 choice" unless list10.any? { |c| command_code(c) == 102 && command_parameters(c)[0].include?("Mua mì cay") }
    [20, 47, 48].each { |id| errors << "Map%03d missing" % id unless File.exist?("Data/Map%03d.rvdata2" % id) }
    verify48 = load_data("Data/Map048.rvdata2")
    list48 = verify48.instance_variable_get(:@events)[1].instance_variable_get(:@pages).first.instance_variable_get(:@list)
    scripts48 = list48.select { |c| [355, 655].include?(command_code(c)) }.map { |c| command_parameters(c)[0].to_s }.join("\n")
    [6, 7, 36, 39, 40, 41, 44, 47, 69, 71, 72, 73].each do |id|
      errors << "Gallery #{id}" unless scripts48.include?("show(#{id})")
    end
    text48 = list48.select { |c| command_code(c) == 401 }.map { |c| command_parameters(c)[0].to_s }.join(" ")
    errors << "Sting placeholder" unless text48.include?("ẢNH BÌNH STING 20 LÍT")
    errors << "Map048 exit" unless list48.any? { |c| command_code(c) == 201 && command_parameters(c)[1] == 36 }
    raise "NOODLE route audit failed: #{errors.join(', ')}" unless errors.empty?
    merge_noodle_party_into_shared_christmas_office
    puts "NOODLE_ROUTE|Map010>020>019?/047>014>038>036|branches=Aira+HQ|free_roam=snowball|CG19=true|Sting=placeholder|errors=0"
  end

  # Merge only the noodle-party event logic into the current editor-authored
  # Map038.  Map048 remains an inert donor/rollback copy; the shared map's
  # tiles, parallax, NPC coordinates, room doors, kitchen doors and unrelated
  # events must survive byte-for-byte.
  def merge_noodle_party_into_shared_christmas_office
    active_switch = 55
    done_switch = 57
    free_switch = 58
    continue_switch = 59
    stage_variable = 51

    map38_path = "Data/Map038.rvdata2"
    map48_path = "Data/Map048.rvdata2"
    map14_path = "Data/Map014.rvdata2"
    map10_path = "Data/Map010.rvdata2"
    system_path = "Data/System.rvdata2"
    map38 = load_data(map38_path)
    donor = load_data(map48_path)
    events = map38.instance_variable_get(:@events) || {}
    donor_events = donor.instance_variable_get(:@events) || {}
    intro_event = events[1]
    leo_event = events[5]
    donor_event = donor_events[1]
    raise "Map038 shared party anchors missing" unless intro_event && leo_event && events[7]
    raise "Map048 noodle donor missing" unless donor_event
    if events[118] && !events[118].instance_variable_get(:@name).to_s.start_with?("SCN-NOODLE-PARTY-CONTINUE")
      raise "Map038 E118 is occupied by an editor-authored event"
    end

    tile_data_before = map38.instance_variable_get(:@data).instance_variable_get(:@marshal_data).dup
    preserved_events = events.each_with_object({}) do |(id, event), result|
      next if [1, 5, 118].include?(id)
      result[id] = Marshal.dump(event)
    end

    donor_list = donor_event.instance_variable_get(:@pages).first.instance_variable_get(:@list)
    split_text = donor_list.index do |command|
      command_code(command) == 401 &&
        command_parameters(command)[0].to_s.include?("Mọi người dọn dẹp, bày thức ăn")
    end
    raise "Map048 noodle free-roam split marker missing" unless split_text
    split_at = split_text.downto(0).find { |index| command_code(donor_list[index]) == 101 }
    raise "Map048 noodle message header missing" unless split_at

    clone_commands = lambda do |commands|
      Marshal.load(Marshal.dump(commands.reject { |command| command_code(command) == 0 }))
    end
    retarget_layer = lambda do |commands|
      commands.each do |command|
        next unless [355, 655].include?(command_code(command))
        params = command_parameters(command)
        params[0] = params[0].to_s.gsub("layer(48,", "layer(38,")
      end
      commands
    end

    intro = retarget_layer.call(clone_commands.call(donor_list[0...split_at]))
    # Clear stale supermarket/noodle exploration state on entry, then hand
    # control from the cutscene actor event to the real player.
    intro.insert(0,
      event_command(121, 0, [47, 48, 1]),
      event_command(121, 0, [free_switch, continue_switch, 1]))
    intro.concat([
      event_command(355, 0, ["hq=$game_map.events[2]; $game_player.moveto(hq.x,hq.y); $game_player.set_graphic('!$HaiQuy_GiangSinh',0)"]),
      event_command(655, 0, ["$game_player.transparent=false; hq.transparent=true; hq.instance_variable_set(:@through,true)"]),
      event_command(122, 0, [stage_variable, stage_variable, 0, 0, 4]),
      event_command(121, 0, [48, 48, 0]),
      event_command(121, 0, [free_switch, free_switch, 0]),
      event_command(123, 0, ["A", 0])
    ])

    intro_pages = intro_event.instance_variable_get(:@pages)
    intro_pages.reject! do |page|
      condition = page.instance_variable_get(:@condition)
      condition.instance_variable_get(:@switch1_valid) &&
        [active_switch, free_switch, continue_switch].include?(condition.instance_variable_get(:@switch1_id))
    end
    intro_pages << page_from_template(intro_event, intro, trigger: 3, priority: 0,
      switch_id: active_switch)
    intro_pages << page_from_template(intro_event, [], trigger: 0, priority: 0,
      switch_id: free_switch)
    intro_pages << page_from_template(intro_event, [], trigger: 0, priority: 0,
      switch_id: continue_switch)

    # Existing Shylvie/Kohi/Hakase free-roam pages already key from Switch 48.
    # Leo needs a higher-priority noodle page so his Continue choice cannot set
    # the supermarket continuation switch (47).
    leo_pages = leo_event.instance_variable_get(:@pages)
    leo_pages.reject! do |page|
      condition = page.instance_variable_get(:@condition)
      condition.instance_variable_get(:@switch1_valid) &&
        condition.instance_variable_get(:@switch1_id) == free_switch
    end
    leo_free = [
      event_command(102, 0, [["Rủ chơi ném tuyết", "Bắt đầu bữa tiệc", "Thôi"], 2]),
      event_command(402, 0, [0, "Rủ chơi ném tuyết"]),
      event_command(355, 1, ["WCF_SNOWBALL.start(5)"]),
      event_command(402, 0, [1, "Bắt đầu bữa tiệc"]),
      event_command(122, 1, [stage_variable, stage_variable, 0, 0, 5]),
      event_command(121, 1, [48, 48, 1]),
      event_command(121, 1, [free_switch, free_switch, 1]),
      event_command(121, 1, [continue_switch, continue_switch, 0]),
      event_command(402, 0, [2, "Thôi"]),
      event_command(404, 0, [])
    ]
    leo_pages << page_from_template(leo_event, leo_free, trigger: 0, priority: 1,
      switch_id: free_switch)

    continuation = retarget_layer.call(clone_commands.call(donor_list[split_at..-1]))
    continuation.unshift(
      event_command(355, 0, ["$game_map.screen.start_tone_change(Tone.new(-255,-255,-255,0),20); map_effects.set_tone(-255,-255,-255,0,20) # WCF_NOODLE_CONTINUE_BLACK"]),
      event_command(230, 0, [20]),
      event_command(355, 0, ["hq=$game_map.events[2]; hq.moveto($game_player.x,$game_player.y); hq.transparent=false; $game_player.transparent=true"]),
      event_command(655, 0, ["hq.instance_variable_set(:@through,false)"])
    )
    cleanup_at = continuation.index do |command|
      command_code(command) == 121 && command_parameters(command)[0, 2] == [done_switch, done_switch]
    end
    raise "Map048 noodle completion marker missing" unless cleanup_at
    continuation.insert(cleanup_at,
      event_command(122, 0, [stage_variable, stage_variable, 0, 0, 6]),
      event_command(121, 0, [48, 48, 1]),
      event_command(121, 0, [free_switch, continue_switch, 1]))
    continuation_page = page_from_template(events[7], continuation, trigger: 3,
      priority: 0, switch_id: continue_switch)
    events[118] = event_from_pages(events[7], 118, "SCN-NOODLE-PARTY-CONTINUE",
      0, 0, [continuation_page])

    # Change only the noodle cooking event's final destination.  Every other
    # event on the shared kitchen map is left untouched.
    map14 = load_data(map14_path)
    cook_event = (map14.instance_variable_get(:@events) || {})[25]
    raise "Map014 noodle cooking event missing" unless cook_event
    cook_transfers = cook_event.instance_variable_get(:@pages).flat_map do |page|
      page.instance_variable_get(:@list) || []
    end.select { |command| command_code(command) == 201 && [38, 48].include?(command_parameters(command)[1]) }
    raise "Map014 noodle party transfer missing" unless cook_transfers.length == 1
    cook_transfer = cook_transfers.first
    command_parameters(cook_transfer)[1] = 38
    cook_pages = cook_event.instance_variable_get(:@pages)
    cook_pages.each do |page|
      condition = page.instance_variable_get(:@condition)
      next unless condition.instance_variable_get(:@switch1_valid) &&
        condition.instance_variable_get(:@switch1_id) == active_switch
      list = page.instance_variable_get(:@list) || []
      transfer_index = list.index { |command| command.equal?(cook_transfer) }
      next unless transfer_index
      unless list[0...transfer_index].any? do |command|
          command_code(command) == 123 && command_parameters(command) == ["A", 0]
        end
        list.insert(transfer_index, event_command(123, 0, ["A", 0]))
      end
    end
    cook_pages.reject! do |page|
      condition = page.instance_variable_get(:@condition)
      condition.instance_variable_get(:@self_switch_valid) &&
        condition.instance_variable_get(:@self_switch_ch) == "A"
    end
    cooked_page = page_from_template(cook_event, [], trigger: 0, priority: 0,
      self_switch: "A")
    cooked_graphic = cooked_page.instance_variable_get(:@graphic)
    cooked_graphic.instance_variable_set(:@tile_id, 0)
    cooked_graphic.instance_variable_set(:@character_name, "")
    cooked_graphic.instance_variable_set(:@character_index, 0)
    cook_pages << cooked_page

    # Clear the two new phase switches whenever the player chooses this route,
    # so an older save cannot enter a blank/free-roam page before the intro.
    map10 = load_data(map10_path)
    bus_event = (map10.instance_variable_get(:@events) || {})[2]
    bus_list = bus_event && bus_event.instance_variable_get(:@pages).first.instance_variable_get(:@list)
    noodle_choice = bus_list && bus_list.index do |command|
      command_code(command) == 402 && command_parameters(command)[1] == "Mua mì cay"
    end
    raise "Map010 noodle branch missing" unless noodle_choice
    branch_end = ((noodle_choice + 1)...bus_list.length).find do |index|
      [402, 404].include?(command_code(bus_list[index])) &&
        bus_list[index].instance_variable_get(:@indent).to_i == 0
    end
    raise "Map010 noodle branch boundary missing" unless branch_end
    branch_commands = bus_list[noodle_choice...branch_end]
    has_phase_reset = branch_commands.any? do |command|
      command_code(command) == 121 && command_parameters(command)[0, 2] == [free_switch, continue_switch]
    end
    has_cooking_reset = branch_commands.any? do |command|
      command_code(command) == 355 &&
        command_parameters(command)[0].to_s.include?("$game_self_switches[[14,25,'A']]=false")
    end
    if !has_phase_reset
      bus_list.insert(noodle_choice + 1,
        event_command(121, 1, [47, 48, 1]),
        event_command(121, 1, [free_switch, continue_switch, 1]),
        event_command(355, 1, ["$game_self_switches[[14,25,'A']]=false"]))
    elsif !has_cooking_reset
      reset_index = bus_list.index do |command|
        command_code(command) == 121 && command_parameters(command)[0, 2] == [free_switch, continue_switch]
      end
      bus_list.insert(reset_index + 1,
        event_command(355, 1, ["$game_self_switches[[14,25,'A']]=false"]))
    end

    system = load_data(system_path)
    switches = system.instance_variable_get(:@switches)
    {free_switch => "NOODLE_FREE_EXPLORE", continue_switch => "NOODLE_PARTY_CONTINUE"}.each do |id, name|
      raise "Switch #{id} already belongs to #{switches[id]}" unless switches[id].to_s.empty? || switches[id] == name
      switches[id] = name
    end

    map38.instance_variable_set(:@events, events)
    save_data(map38_path, map38)
    save_data(map14_path, map14)
    save_data(map10_path, map10)
    save_data(system_path, system)

    verify38 = load_data(map38_path)
    verify_events = verify38.instance_variable_get(:@events) || {}
    verify_tiles = verify38.instance_variable_get(:@data).instance_variable_get(:@marshal_data)
    errors = []
    errors << "Map038 tile data changed" unless verify_tiles == tile_data_before
    preserved_events.each do |id, dump|
      errors << "Map038 E%03d changed" % id unless verify_events[id] && Marshal.dump(verify_events[id]) == dump
    end
    errors << "Map038 noodle continuation missing" unless verify_events[118]
    errors << "Map038 snowball NPCs missing" unless (3..6).all? { |id| verify_events[id] }
    verify_continue = verify_events[118].instance_variable_get(:@pages).first.instance_variable_get(:@list)
    errors << "Map038 noodle exit" unless verify_continue.any? do |command|
      command_code(command) == 201 && command_parameters(command)[1] == 36
    end
    errors << "Map038 CG19" unless verify_continue.any? do |command|
      [355, 655].include?(command_code(command)) && command_parameters(command)[0].to_s.include?("show(36)")
    end
    verify_cook = load_data(map14_path).instance_variable_get(:@events)[25]
      .instance_variable_get(:@pages).flat_map { |page| page.instance_variable_get(:@list) || [] }
    errors << "Map014 shared-party transfer" unless verify_cook.any? do |command|
      command_code(command) == 201 && command_parameters(command)[1] == 38
    end
    errors << "Map014 cooking replay guard" unless verify_cook.any? do |command|
      command_code(command) == 123 && command_parameters(command) == ["A", 0]
    end
    raise "Shared noodle party merge failed: #{errors.join(', ')}" unless errors.empty?
    puts "NOODLE_SHARED_OFFICE|Map014>038>036|free=58|continue=59|snowball=3,4,5,6|preserved=#{preserved_events.length}|errors=0"
  end

  # Complete the normal Atlantis teleport-book route for Shylvie. Existing
  # Map023/Map038 data is changed only at explicit route anchor events.
  def implement_atlantis_teleport_book_shylvie_route
    active_sw, free_sw, continue_sw, done_sw = 61, 62, 64, 65
    stage_var = 52
    hint_id = 19
    say = lambda do |face, index, text, indent = 0|
      result = wrapped_message_commands([text], tag: "\\cbm ", width: 30, indent: indent)
      result.each do |command|
        next unless command_code(command) == 101
        command.instance_variable_set(:@parameters, [face, face.empty? ? 0 : index, 0, 2])
      end
      result
    end
    narr = lambda { |text, indent = 0| say.call("", 0, text, indent) }
    hq = lambda { |text, index = 1, indent = 0| say.call("HaiQuy_Thuongphuc_Emote", index, text, indent) }
    aira = lambda { |text, index = 1, indent = 0| say.call("BullyQuy_Thuongphuc_Emote", index, text, indent) }
    hqx = lambda { |text, index = 1, indent = 0| say.call("HaiQuy_Giangsinh_Emote", index, text, indent) }
    shy = lambda { |text, index = 1, indent = 0| say.call("CV_Giangsinh_Emote1", index, text, indent) }
    leo = lambda { |text, index = 1, indent = 0| say.call("Leo_Giangsinh_Emote", index, text, indent) }
    kohi = lambda { |text, index = 1, indent = 0| say.call("Kohi_Giangsinh_Emote1", index, text, indent) }
    hakase = lambda { |text, index = 1, indent = 0| say.call("Hakase_Giangsinh_Emote", index, text, indent) }
    bully_hint = lambda do |text, index = 1, indent = 0|
      result = wrapped_message_commands([text], tag: "\\bm[2] ", width: 30, indent: indent)
      result.each do |command|
        next unless command_code(command) == 101
        command.instance_variable_set(:@parameters, ["BullyQuy_Thuongphuc_Emote", index, 0, 2])
      end
      result
    end
    picture = lambda do |id, commands|
      [event_command(355, 0, ["WCFGalleryScene.show(#{id}) # WCF_GALLERY_SCENE"])] + commands +
        [event_command(355, 0, ["WCFGalleryScene.hide # WCF_GALLERY_SCENE"])]
    end
    clone_commands = lambda do |commands|
      Marshal.load(Marshal.dump(commands.reject { |command| command_code(command) == 0 }))
    end

    system_path = "Data/System.rvdata2"
    system = load_data(system_path)
    switches = system.instance_variable_get(:@switches)
    variables = system.instance_variable_get(:@variables)
    {61 => "ATL_BOOK_SHY_ACTIVE", 62 => "ATL_BOOK_SHY_FREE_EXPLORE",
     64 => "ATL_BOOK_SHY_PARTY_CONTINUE", 65 => "ATL_BOOK_SHY_DONE"}.each do |id, name|
      raise "Switch #{id} already belongs to #{switches[id]}" unless switches[id].to_s.empty? || switches[id] == name
      switches[id] = name
    end
    raise "Variable 52 already belongs to #{variables[stage_var]}" unless variables[stage_var].to_s.empty? || variables[stage_var] == "ATL_BOOK_SHY_STAGE"
    variables[stage_var] = "ATL_BOOK_SHY_STAGE"

    # Reset route-owned and shared party phase state only inside the Atlantis
    # bus branch, so old saves cannot open a later page on a new run.
    map10_path = "Data/Map010.rvdata2"
    map10 = load_data(map10_path)
    bus_event = (map10.instance_variable_get(:@events) || {}).values.find do |event|
      (event.instance_variable_get(:@pages) || []).any? do |page|
        (page.instance_variable_get(:@list) || []).any? do |command|
          command_code(command) == 402 && command_parameters(command)[1].to_s.start_with?("Xuống Atlantis")
        end
      end
    end
    raise "Map010 Atlantis branch missing" unless bus_event
    bus_page = bus_event.instance_variable_get(:@pages).find do |page|
      (page.instance_variable_get(:@list) || []).any? do |command|
        command_code(command) == 402 && command_parameters(command)[1].to_s.start_with?("Xuống Atlantis")
      end
    end
    bus_list = bus_page.instance_variable_get(:@list)
    branch_at = bus_list.index { |command| command_code(command) == 402 && command_parameters(command)[1].to_s.start_with?("Xuống Atlantis") }
    unless bus_list.any? { |command| [355, 655].include?(command_code(command)) && command_parameters(command)[0].to_s.include?("WCF_ATL_BOOK_SHY_RESET") }
      bus_list.insert(branch_at + 1,
        event_command(121, 1, [active_sw, active_sw, 1]),
        event_command(121, 1, [free_sw, free_sw, 1]),
        event_command(121, 1, [continue_sw, continue_sw, 1]),
        event_command(121, 1, [done_sw, done_sw, 1]),
        event_command(121, 1, [51, 51, 1]),
        event_command(121, 1, [47, 48, 1]),
        event_command(121, 1, [58, 59, 1]),
        event_command(355, 1, ["$game_variables[31]=0; $game_variables[52]=0 # WCF_ATL_BOOK_SHY_RESET"]))
    end

    # Map023 book selection and checkout.
    map23_path = "Data/Map023.rvdata2"
    map23 = load_data(map23_path)
    events23 = map23.instance_variable_get(:@events) || {}
    [2, 3, 12, 36].each { |id| raise "Map023 E#{id} missing" unless events23[id] }
    tiles23 = map23.instance_variable_get(:@data).instance_variable_get(:@marshal_data).dup
    keep23 = events23.each_with_object({}) { |(id, event), memo| memo[id] = Marshal.dump(event) unless [2, 3, 12, 36].include?(id) }
    [
      [events23[12], hq.call("Mình đã chọn cuốn phép thuật dịch chuyển rồi. Mang ra quầy thôi.")],
      [events23[36], hq.call("Mình đã chọn sách cho Shylvie rồi. Không nên đổi sang cuốn khác nữa.")]
    ].each do |event, commands|
      pages = event.instance_variable_get(:@pages)
      pages.reject! do |page|
        condition = page.instance_variable_get(:@condition)
        condition.instance_variable_get(:@variable_valid) && condition.instance_variable_get(:@variable_id) == 31 && condition.instance_variable_get(:@variable_value) == 2
      end
      pages << page_from_template(event, commands, trigger: 0, priority: 1, variable_id: 31, variable_value: 2)
    end
    checkout = []
    checkout.concat(hq.call("Đọc tin nhắn xong mắt tôi nổ đom đóm. Cái nhỏ Shylvie chết tiệt khó ưa này!", 3))
    checkout.concat(aira.call("Tặng cho nhỏ đó cuốn phép thuật dịch chuyển này không phải ý tồi đâu."))
    checkout.concat(narr.call("Tôi mang cuốn sách ra quầy cho chủ tiệm gói lại cẩn thận. Chị ấy còn tặng kèm một thẻ đánh dấu trang giấy có in hình hoa cẩm chướng màu hồng."))
    checkout.concat([event_command(121, 0, [active_sw, active_sw, 0]),
      event_command(121, 0, [free_sw, free_sw, 1]),
      event_command(121, 0, [continue_sw, continue_sw, 1]),
      event_command(121, 0, [done_sw, done_sw, 1]),
      event_command(122, 0, [stage_var, stage_var, 0, 0, 1]),
      event_command(355, 0, ["$game_switches[17]=false; $game_switches[18]=false; map_effects.clear; map_effects.active=false"]),
      event_command(355, 0, ["$game_map.shadows.set_color(0,0,0); $game_map.shadows.show; $game_map.shadows.set_opacity(255,20) # WCF_ATL_BOOK_KUL_CHECKOUT"]),
      event_command(230, 0, [20]), event_command(201, 0, [0, 49, 7, 5, 2, 2])])
    [events23[2], events23[3]].each do |event|
      pages = event.instance_variable_get(:@pages)
      pages.reject! do |page|
        condition = page.instance_variable_get(:@condition)
        condition.instance_variable_get(:@variable_valid) && condition.instance_variable_get(:@variable_id) == 31 && condition.instance_variable_get(:@variable_value) == 2
      end
      pages << page_from_template(event, clone_commands.call(checkout), trigger: 0, priority: 1, variable_id: 31, variable_value: 2)
    end

    # Map049: dedicated preparation map. All sprite changes occur while KUL's
    # shadow overlay is fully opaque; native Fade/Tint commands are forbidden.
    map49 = Marshal.load(Marshal.dump(load_data("Data/Map037.rvdata2")))
    source49 = map49.instance_variable_get(:@events)
    prep_template = source49.fetch(1)
    prep = [event_command(355, 0, ["$game_player.transparent=true"]),
      event_command(355, 0, ["layer(49,0,[\"HQ_Room_Midnight_Top\",0,0,255,200,0,0,0])"]),
      event_command(655, 0, ["refresh_layers"]),
      event_command(355, 0, ["$game_switches[17]=false; $game_switches[18]=false; map_effects.clear; map_effects.active=false"]),
      event_command(355, 0, ["$game_map.shadows.set_color(0,0,0); $game_map.shadows.show; $game_map.shadows.set_opacity(255) # WCF_ATL_BOOK_KUL_PREP"]),
      event_command(355, 0, ["$game_map.events[3].give_light(\"cutscene_actor\")"]),
      event_command(355, 0, ["$game_map.events[3].set_graphic(\"$HaiQuy_Sleep_Night\",0)"]),
      event_command(355, 0, ["$game_map.shadows.set_opacity(185,30)"]), event_command(230, 0, [30]),
      event_command(230, 0, [60]), event_command(355, 0, ["$game_map.shadows.set_opacity(255,30)"]),
      event_command(230, 0, [30]), event_command(355, 0, ["$game_map.shadows.set_opacity(185,30)"]),
      event_command(230, 0, [30])]
    prep.concat(picture.call(28, hq.call("Tôi…ngủ một mạch….đến…GIÁNG SINH?!", 3)))
    prep.concat(hq.call("Chết rồi!! Vỡ kế hoạch rồi!! Nửa bên kia của tôi ơi!! SAO KHÔNG GỌI TÔI DẬY?! Còn vài tiếng nữa là đến tiệc Giáng sinh trong văn phòng rồi!!", 3))
    prep.concat(hq.call("Giờ này thì làm sao mà kịp bắt xe đến văn phòng được?! Chìa khóa dịch chuyển đâu rồi…!! Nó nằm ở đâu vậy?!", 3))
    prep.concat(picture.call(29, hq.call("Mình còn chưa chuẩn bị trang phục nữa!! Nên mặc bộ nào đây!!", 3)))
    prep.concat(picture.call(30, hq.call("Cũng không phải bộ này nốt!!", 5)))
    prep.concat(picture.call(31, hq.call("Bộ này ổn này!!", 0)))
    prep.concat([event_command(355, 0, ["$game_map.shadows.set_opacity(255,20) # WCF_ATL_BOOK_KUL_OUTFIT_BLACK"]),
      event_command(230, 0, [20]),
      event_command(355, 0, ["$game_map.events[3].set_graphic(\"!$HaiQuy_GiangSinh\",0) # WCF_ATL_BOOK_OUTFIT_SWAP_AFTER_CG14"]),
      event_command(355, 0, ["$game_map.shadows.set_opacity(185,20)"]), event_command(230, 0, [20])])
    prep.concat(hq.call("Ý chết! Suýt nữa là quên hộp quà!", 3))
    prep.concat([event_command(122, 0, [stage_var, stage_var, 0, 0, 2]),
      event_command(355, 0, ["$game_map.shadows.set_opacity(255,30) # WCF_ATL_BOOK_KUL_TO_PARTY"]),
      event_command(230, 0, [30]), event_command(201, 0, [0, 38, 22, 34, 8, 2])])
    prep_page = page_from_template(prep_template, prep, trigger: 3, priority: 0, switch_id: active_sw)
    map49.instance_variable_set(:@display_name, "Phòng Hải Quỳ — Sách tặng Shylvie")
    map49.instance_variable_set(:@note, "[lighting on]\r\n[opacity 255]\r\n[color 000000000]\r\n<full lock parallax>\r\n<tile lock parallax>\r\nATL teleport-book preparation; KUL only")
    map49.instance_variable_set(:@events, {1 => event_from_pages(prep_template, 1, "SCN-ATL-BOOK-SHY-PREP", 0, 0, [prep_page]), 3 => source49.fetch(3)})

    # Map038: this route reaches the office late. The compact script has only
    # Shylvie's "Quỳ!! Hello!" before the gift sequence; the early-arrival
    # Sierra/decorating scene belongs to other routes and must not be reused.
    # Free roam remains inserted between that greeting and the gift exchange.
    map38_path = "Data/Map038.rvdata2"
    map38 = load_data(map38_path)
    events38 = map38.instance_variable_get(:@events) || {}
    intro_event, leo_event = events38.fetch(1), events38.fetch(5)
    raise "Map038 E119 is occupied" if events38[119] && !events38[119].instance_variable_get(:@name).to_s.start_with?("SCN-ATL-BOOK-SHY")
    tiles38 = map38.instance_variable_get(:@data).instance_variable_get(:@marshal_data).dup
    keep38 = events38.each_with_object({}) { |(id, event), memo| memo[id] = Marshal.dump(event) unless [1, 5, 119].include?(id) }
    route_intro = [event_command(121, 0, [47, 48, 1]), event_command(121, 0, [58, 59, 1]),
      event_command(121, 0, [free_sw, free_sw, 1]), event_command(121, 0, [continue_sw, continue_sw, 1]),
      event_command(355, 0, ["$game_switches[17]=false; $game_switches[18]=false; map_effects.clear; map_effects.active=false"]),
      event_command(355, 0, ["$game_map.shadows.set_color(0,0,0); $game_map.shadows.show; $game_map.shadows.set_opacity(255) # WCF_ATL_BOOK_KUL_ARRIVAL"]),
      event_command(355, 0, ["$game_player.transparent=true"]),
      event_command(355, 0, ["layer(38,0,[\"Map_Wanderer_Office_GiangSinh_Top\",0,0,255,200,0,0,0])"]),
      event_command(655, 0, ["refresh_layers"])]
    route_intro.concat(shy.call("Quỳ!! Hello!", 1))
    route_intro.concat([event_command(355, 0, ["hq=$game_map.events[2]; $game_player.moveto(hq.x,hq.y); $game_player.set_graphic('!$HaiQuy_GiangSinh',0)"]),
      event_command(655, 0, ["$game_player.transparent=false; hq.transparent=true; hq.instance_variable_set(:@through,true)"]),
      event_command(122, 0, [stage_var, stage_var, 0, 0, 3]),
      event_command(355, 0, ["$game_map.shadows.set_opacity(0,30) # WCF_ATL_BOOK_KUL_FREE_REVEAL"]),
      event_command(230, 0, [30]), event_command(121, 0, [free_sw, free_sw, 0]), event_command(121, 0, [48, 48, 0])])
    intro_pages = intro_event.instance_variable_get(:@pages)
    intro_pages.reject! do |page|
      condition = page.instance_variable_get(:@condition)
      condition.instance_variable_get(:@switch1_valid) && [active_sw, free_sw, continue_sw].include?(condition.instance_variable_get(:@switch1_id))
    end
    intro_pages << page_from_template(intro_event, route_intro, trigger: 3, priority: 0, switch_id: active_sw)
    intro_pages << page_from_template(intro_event, [], trigger: 0, priority: 0, switch_id: free_sw)
    intro_pages << page_from_template(intro_event, [], trigger: 0, priority: 0, switch_id: continue_sw)
    leo_pages = leo_event.instance_variable_get(:@pages)
    leo_pages.reject! do |page|
      condition = page.instance_variable_get(:@condition)
      condition.instance_variable_get(:@switch1_valid) && condition.instance_variable_get(:@switch1_id) == free_sw
    end
    leo_free = [event_command(102, 0, [["Rủ chơi ném tuyết", "Bắt đầu bữa tiệc", "Thôi"], 2]),
      event_command(402, 0, [0, "Rủ chơi ném tuyết"]), event_command(355, 1, ["WCF_SNOWBALL.start(5)"]),
      event_command(402, 0, [1, "Bắt đầu bữa tiệc"]), event_command(122, 1, [stage_var, stage_var, 0, 0, 4]),
      event_command(121, 1, [48, 48, 1]), event_command(121, 1, [free_sw, free_sw, 1]),
      event_command(121, 1, [continue_sw, continue_sw, 0]), event_command(402, 0, [2, "Thôi"]), event_command(404, 0, [])]
    leo_pages << page_from_template(leo_event, leo_free, trigger: 0, priority: 1, switch_id: free_sw)

    party = [event_command(355, 0, ["$game_map.shadows.set_color(0,0,0); $game_map.shadows.show; $game_map.shadows.set_opacity(255,20) # WCF_ATL_BOOK_KUL_PARTY_BLACK"]),
      event_command(230, 0, [20]),
      event_command(355, 0, ["hq=$game_map.events[2]; hq.moveto($game_player.x,$game_player.y); hq.transparent=false; $game_player.transparent=true"]),
      event_command(655, 0, ["hq.instance_variable_set(:@through,false)"])]
    party.concat(narr.call("Tôi đưa túi quà cho Shylvie. Ngay khi cầm, Shylvie vô cùng tò mò, đôi tay liên tục sờ soạng túi quà."))
    party.concat(hqx.call("Giáng sinh an lành Shi-ru-vi! Tui hi vọng bà thích cuốn sách này!", 0))
    party.concat(shy.call("UẦY! BIẾT NGAY LÀ SÁCH MÀ!!", 2))
    party.concat(narr.call("Shylvie vui vẻ xé túi giấy, lập tức mở cuốn sách ra đọc làu làu."))
    party.concat(hqx.call("Hồi lâu bà có nói là bà tò mò tui học phép thuật dịch chuyển như thế nào và muốn so sánh với phép thuật của bà nên là tada!", 0))
    party.concat(shy.call("Chuẩn rồi, nhớ dai dữ! Phép thuật dịch chuyển này….là phép thuật nâng cao…ủa, nâng cao??", 3))
    party.concat(hqx.call("Hử? Nâng cao thì sao?", 3)); party.concat(shy.call("Nghĩa là bà không học căn bản, học luôn nâng cao hả?", 3))
    party.concat(hqx.call("Có căn bản hả??", 3)); party.concat(leo.call("Trời… Giờ thì tui có thể hiểu được lý do vì sao bả dùng phép thuật dịch chuyển tệ rồi đấy…", 3))
    party.concat(hakase.call("WOW! Em giống anh ghê!", 2)); party.concat(kohi.call("Bả còn không biết là có phép căn bản luôn chứ... Vậy ở Atlantis ai cũng học nâng cao ngay từ đầu…hay chỉ mỗi bà thôi?", 3))
    party.concat(hqx.call("Không, họ học từ cơ bản ấy chứ…Xong mới từ từ nâng cao.", 5)); party.concat(shy.call("Rồi sao bà học cuốn này ngay từ đầu vậy?", 3))
    party.concat(hqx.call("Thì tại nó không có tập cơ bản….", 5)); party.concat(shy.call("THÌ BÀ PHẢI TÌM ĐI CHỨ!!", 2))
    party.concat(narr.call("Shylvie gõ vào đầu tôi một cái."))
    party.concat(narr.call("Rồi Shylvie cất cuốn sách của tôi vào túi không gian, đồng thời lôi ra một túi cà phê dát vàng thượng hạng ở chiều không gian của mình. Nhận lấy túi cà phê, Kohi cười híp cả mắt."))
    party.concat([event_command(122, 0, [stage_var, stage_var, 0, 0, 5]), event_command(121, 0, [48, 48, 1]),
      event_command(121, 0, [free_sw, free_sw, 1]), event_command(121, 0, [continue_sw, continue_sw, 1]),
      event_command(355, 0, ["$game_map.shadows.set_opacity(255,30) # WCF_ATL_BOOK_KUL_TO_EPILOGUE"]),
      event_command(230, 0, [30]), event_command(201, 0, [0, 50, 21, 31, 8, 2])])
    events38[119] = event_from_pages(events38.fetch(7), 119, "SCN-ATL-BOOK-SHY-PARTY-CONTINUE", 0, 0,
      [page_from_template(events38.fetch(7), party, trigger: 3, priority: 0, switch_id: continue_sw)])

    # Map050: exact compact epilogue, followed by the authored Atlantis book
    # ending hint B2740..B2745 on the shared Map036 router.
    map50 = Marshal.load(Marshal.dump(load_data("Data/Map039.rvdata2")))
    events50 = map50.instance_variable_get(:@events)
    epi_template = events50.fetch(1)
    epi = [event_command(355, 0, ["$game_player.transparent=true"]),
      event_command(355, 0, ["layer(50,0,[\"Map_Wanderer_Office_top\",0,0,255,200,0,0,0])"]), event_command(655, 0, ["refresh_layers"]),
      event_command(355, 0, ["$game_switches[17]=false; $game_switches[18]=false; map_effects.clear; map_effects.active=false"]),
      event_command(355, 0, ["$game_map.shadows.set_color(0,0,0); $game_map.shadows.show; $game_map.shadows.set_opacity(255) # WCF_ATL_BOOK_KUL_EPILOGUE"]),
      event_command(355, 0, ["$game_map.shadows.set_opacity(0,30)"]), event_command(230, 0, [30])]
    epi.concat(narr.call("Sáng hôm sau, tôi mệt mỏi dịch chuyển về văn phòng để ăn kem như lời đã hẹn."))
    epi.concat(narr.call("Tôi buồn chán chuẩn bị rời đi thì bị dịch chuyển lên bầu trời cao vút."))
    epi.concat(shy.call("DÙNG MOONLIGHT DELUSION BREAKER!! MAU MAU!! BẮN XUỐNG DƯỚI!", 2))
    epi.concat(hqx.call("Nó là Moonlight Illusion Breaker má ơi….MOONLIGHT ILLUSION BREAKER!", 3))
    epi.concat(leo.call("Ê!! NHƯ VẬY LÀ ĂN GIAN—", 3))
    epi.concat(narr.call("Hóa ra Shylvie và Leo đang tranh nhau hộp kem cuối cùng. Leo thì muốn để dành cho tôi, trong khi Shylvie lại muốn dùng nó để dụ con rồng nào đấy."))
    epi.concat(narr.call("Sau khi dụ con rồng bất thành thì Shylvie quyết định kéo cả ba đứa đi ăn mì cay để đền bù cho Leo."))
    epi.concat(shy.call("Để mà so sánh thì…phép thuật dịch chuyển này còn kém xa phép thuật dịch chuyển của tui. Giờ tui hiểu sao bà không dùng được phép dịch chuyển rồi đấy."))
    epi.concat(hqx.call("Vì sao thế?", 3))
    epi.concat(shy.call("Vì cái phép bà học thực chất là phép hoán đổi. Bà muốn hoán đổi vật A với vật B thì bà phải cầm vật A hoặc vật B có cùng ma lực… Nói ngắn gọn, ban nãy tui hoán đổi bà với băng đạn ma thuật của bà, thứ sở hữu ma lực của bà đó."))
    epi.concat(leo.call("À…hóa ra là vậy… Bảo sao có lúc bả dùng được, có lúc không.", 3))
    epi.concat(shy.call("Không, Leo. Bả còn không dùng được cái phép này. Bằng cách nào đấy, bả học phép này lại dùng được mấy phép dịch chuyển khác…", 3))
    epi.concat(hqx.call("Đàm….", 5)); epi.concat(hqx.call("Rồi tôi được ăn kem chưa?")); epi.concat(shy.call("Đây đây, kem của bà đây."))
    epi.concat(narr.call("Shylvie làm đông hũ kem rồi đưa cho tôi.")); epi.concat(hqx.call("Ngon!", 0))
    epi.concat(narr.call("Tôi múc từng muỗng ăn ngấu nghiến. Và rồi tôi múc từng muỗng cho vô tô mì cay trước sự chứng kiến của Leo và Shylvie."))
    epi.concat(shy.call("Bà…AI LẠI CHO KEM SOCOLA VÀO MÌ CAY HẢ?!?!?!", 2))
    epi.concat([event_command(121, 0, [active_sw, active_sw, 1]), event_command(121, 0, [free_sw, free_sw, 1]),
      event_command(121, 0, [continue_sw, continue_sw, 1]), event_command(121, 0, [done_sw, done_sw, 0]),
      event_command(122, 0, [stage_var, stage_var, 0, 0, 6]),
      event_command(122, 0, [41, 41, 0, 0, hint_id]),
      event_command(355, 0, ["$game_map.shadows.set_opacity(255,30) # WCF_ATL_BOOK_KUL_END"]), event_command(230, 0, [30]),
      event_command(201, 0, [0, 36, 8, 7, 8, 2])])
    events50[1] = event_from_pages(epi_template, 1, "SCN-ATL-BOOK-SHY-EPILOGUE", 0, 0,
      [page_from_template(epi_template, epi, trigger: 3, priority: 0, switch_id: active_sw)])
    map50.instance_variable_set(:@display_name, "Wanderer Office — Hậu truyện sách Shylvie")
    map50.instance_variable_set(:@note, "[lighting on]\r\n[opacity 255]\r\n[color 000000000]\r\n<full lock parallax>\r\n<tile lock parallax>\r\nATL teleport-book Shylvie epilogue; KUL only; hint=19; no unassigned ending CG")
    map50.instance_variable_set(:@events, events50)

    # Map036 hint ID 19. This page deliberately does not reuse CE03/CE05 or
    # native Fade/Tint because this route's complete visual handoff is KUL-only.
    map36_path = "Data/Map036.rvdata2"
    map36 = load_data(map36_path)
    events36 = map36.instance_variable_get(:@events) || {}
    hint_router = events36.fetch(1)
    hint_pages = hint_router.instance_variable_get(:@pages)
    hint_pages.reject! do |page|
      condition = page.instance_variable_get(:@condition)
      condition.instance_variable_get(:@variable_valid) &&
        condition.instance_variable_get(:@variable_id) == 41 &&
        condition.instance_variable_get(:@variable_value) == hint_id
    end
    hint = [event_command(355, 0, ["$game_player.transparent=true; $game_player.moveto(8,7)"]),
      event_command(355, 0, ["$game_switches[17]=false; $game_switches[18]=false; map_effects.clear; map_effects.active=false"]),
      event_command(355, 0, ["$game_map.shadows.set_color(0,0,0); $game_map.shadows.show; $game_map.shadows.set_opacity(255) # WCF_ATL_BOOK_KUL_HINT"]),
      event_command(355, 0, ["$game_map.events[2].give_light(\"cutscene_actor\")"]),
      event_command(355, 0, ["$game_map.shadows.set_opacity(185,30)"]), event_command(230, 0, [30])]
    hint.concat(bully_hint.call("ROUTE XUỐNG ATLANTIS MUA SÁCH", 0))
    hint.concat(bully_hint.call("Ending này cũng đẹp đấy."))
    hint.concat(bully_hint.call("Thật yên bình và hoài niệm làm sao."))
    hint.concat(bully_hint.call("Làm ta nhớ về thời kỳ văn phòng Wanderer chỉ có ba mống."))
    hint.concat(bully_hint.call("Cả đám cũng rủ nhau đi ăn với đi phá phách như thế này."))
    hint.concat(bully_hint.call("Cơ mà yên bình như này chán lắm, kiếm ending khác đi!", 3))
    hint.concat([event_command(355, 0, ["$game_map.shadows.set_opacity(255,30) # WCF_ATL_BOOK_KUL_HINT_END"]),
      event_command(230, 0, [30]), event_command(355, 0, ["$game_map.events[2].drop_light"]),
      event_command(355, 0, ["HAIQUY_TITLE.clear_ending_background"]), event_command(354, 0, [])])
    hint_pages << page_from_template(hint_router, hint, trigger: 3, priority: 0,
      variable_id: 41, variable_value: hint_id)

    infos_path = "Data/MapInfos.rvdata2"
    infos = load_data(infos_path)
    [[49, 37, "Phòng Hải Quỳ — Sách tặng Shylvie"], [50, 39, "Hậu truyện — Sách dịch chuyển Shylvie"]].each do |id, source_id, name|
      raise "MapInfo #{id} already belongs to #{infos[id].instance_variable_get(:@name)}" if infos[id] && infos[id].instance_variable_get(:@name) != name
      info = infos[id] || Marshal.load(Marshal.dump(infos.fetch(source_id)))
      info.instance_variable_set(:@name, name); info.instance_variable_set(:@parent_id, 23); info.instance_variable_set(:@expanded, true)
      info.instance_variable_set(:@order, infos.values.compact.map { |entry| entry.instance_variable_get(:@order).to_i }.max + 1) unless infos[id]
      infos[id] = info
    end

    map23.instance_variable_set(:@events, events23); map38.instance_variable_set(:@events, events38)
    save_data(map10_path, map10); save_data(map23_path, map23); save_data("Data/Map049.rvdata2", map49)
    save_data(map38_path, map38); save_data("Data/Map050.rvdata2", map50); save_data(map36_path, map36)
    save_data(infos_path, infos); save_data(system_path, system)

    errors = []
    verify23 = load_data(map23_path); verify23_events = verify23.instance_variable_get(:@events)
    errors << "Map023 tile data changed" unless verify23.instance_variable_get(:@data).instance_variable_get(:@marshal_data) == tiles23
    keep23.each { |id, dump| errors << "Map023 E%03d changed" % id unless verify23_events[id] && Marshal.dump(verify23_events[id]) == dump }
    verify38 = load_data(map38_path); verify38_events = verify38.instance_variable_get(:@events)
    errors << "Map038 tile data changed" unless verify38.instance_variable_get(:@data).instance_variable_get(:@marshal_data) == tiles38
    keep38.each { |id, dump| errors << "Map038 E%03d changed" % id unless verify38_events[id] && Marshal.dump(verify38_events[id]) == dump }
    verify_intro_page = verify38_events[1].instance_variable_get(:@pages).find do |page|
      condition = page.instance_variable_get(:@condition)
      condition.instance_variable_get(:@switch1_valid) && condition.instance_variable_get(:@switch1_id) == active_sw
    end
    verify_intro_text = (verify_intro_page && verify_intro_page.instance_variable_get(:@list) || []).select do |command|
      command_code(command) == 401
    end.map { |command| command_parameters(command)[0].to_s }.join(" ")
    errors << "Map038 late-arrival greeting missing" unless verify_intro_text.include?("Quỳ!! Hello!")
    errors << "Map038 inherited early-arrival dialogue" if verify_intro_text.include?("Văn phòng hoàn toàn im ắng") || verify_intro_text.include?("Sierra")
    errors << "Map038 continuation missing" unless verify38_events[119]
    errors << "Map038 snowball NPCs missing" unless (3..6).all? { |id| verify38_events[id] }
    verify49 = load_data("Data/Map049.rvdata2")
    verify49_list = verify49.instance_variable_get(:@events)[1].instance_variable_get(:@pages).first.instance_variable_get(:@list)
    verify50 = load_data("Data/Map050.rvdata2")
    verify50_list = verify50.instance_variable_get(:@events)[1].instance_variable_get(:@pages).first.instance_variable_get(:@list)
    verify36 = load_data(map36_path)
    verify_hint_page = verify36.instance_variable_get(:@events)[1].instance_variable_get(:@pages).find do |page|
      condition = page.instance_variable_get(:@condition)
      condition.instance_variable_get(:@variable_valid) && condition.instance_variable_get(:@variable_id) == 41 && condition.instance_variable_get(:@variable_value) == hint_id
    end
    verify_hint_list = verify_hint_page && verify_hint_page.instance_variable_get(:@list) || []
    verify_party_list = verify38_events[119].instance_variable_get(:@pages).first.instance_variable_get(:@list)
    verify_checkout_pages = [2, 3].map do |id|
      verify23_events[id].instance_variable_get(:@pages).find do |page|
        condition = page.instance_variable_get(:@condition)
        condition.instance_variable_get(:@variable_valid) && condition.instance_variable_get(:@variable_id) == 31 && condition.instance_variable_get(:@variable_value) == 2
      end
    end
    kul_only_lists = {
      "Map023 checkout E002" => verify_checkout_pages[0].instance_variable_get(:@list),
      "Map023 checkout E003" => verify_checkout_pages[1].instance_variable_get(:@list),
      "Map049 preparation" => verify49_list,
      "Map038 arrival" => verify_intro_page.instance_variable_get(:@list),
      "Map038 party continuation" => verify_party_list,
      "Map050 epilogue" => verify50_list,
      "Map036 Atlantis book hint" => verify_hint_list
    }
    kul_only_lists.each do |label, list|
      errors << "#{label} contains native Fade/Tint" if list.any? { |command| [221, 222, 223].include?(command_code(command)) }
      errors << "#{label} calls legacy lighting common event" if list.any? { |command| command_code(command) == 117 && command_parameters(command)[0] == 3 }
      legacy_visual = list.any? do |command|
        [355, 655].include?(command_code(command)) && command_parameters(command)[0].to_s.match?(/start_tone_change|map_effects\.(?:set_tone|set_color|set_zoom)/)
      end
      errors << "#{label} contains legacy visual lighting" if legacy_visual
      errors << "#{label} missing KUL opacity control" unless list.any? do |command|
        [355, 655].include?(command_code(command)) && command_parameters(command)[0].to_s.include?("$game_map.shadows.set_opacity")
      end
    end
    errors << "Map049 exit missing" unless verify49_list.any? { |command| command_code(command) == 201 && command_parameters(command)[1] == 38 }
    cg14_index = verify49_list.index { |command| [355, 655].include?(command_code(command)) && command_parameters(command)[0].to_s.include?("WCFGalleryScene.show(31)") }
    outfit_swap_index = verify49_list.index { |command| [355, 655].include?(command_code(command)) && command_parameters(command)[0].to_s.include?("WCF_ATL_BOOK_OUTFIT_SWAP_AFTER_CG14") }
    errors << "Map049 outfit swap occurs before CG14" unless cg14_index && outfit_swap_index && outfit_swap_index > cg14_index
    errors << "Map049 outfit swap is not hidden by KUL" unless cg14_index && outfit_swap_index && verify49_list[cg14_index...outfit_swap_index].any? do |command|
      [355, 655].include?(command_code(command)) && command_parameters(command)[0].to_s.include?("set_opacity(255")
    end
    errors << "Map050 hint ID missing" unless verify50_list.any? { |command| command_code(command) == 122 && command_parameters(command) == [41, 41, 0, 0, hint_id] }
    errors << "Map050 hint transfer missing" unless verify50_list.any? { |command| command_code(command) == 201 && command_parameters(command)[1] == 36 }
    verify_hint_text = verify_hint_list.select { |command| command_code(command) == 401 }.map { |command| command_parameters(command)[0].to_s }.join(" ")
    errors << "Map036 Atlantis book hint missing" unless verify_hint_text.include?("ROUTE XUỐNG ATLANTIS MUA SÁCH") && verify_hint_text.include?("kiếm ending khác đi!")
    errors << "Map036 hint title exit missing" unless verify_hint_list.any? { |command| command_code(command) == 354 }
    raise "Atlantis Shylvie book route audit failed: #{errors.join(', ')}" unless errors.empty?
    puts "ATL_BOOK_SHY_ROUTE|Map023>049>038>050>036>Title|free=62|continue=64|hint=19|snowball=3,4,5,6|CG=none_assigned|errors=0"
  end

  # Complete the owner-first Atlantis branch: the sealed Abyss book destroys
  # the shop, Hai Quy disappears, Wanderer traces her, and the group breaks
  # the self-imposed cage.  This route deliberately owns Maps 053..055 and
  # does not reuse the Paulie chase timeline.
  def implement_atlantis_owner_abyss_route
    active_sw, done_sw, stage_var, hint_id = 70, 71, 54, 21
    say = lambda do |face, index, text, indent = 0|
      result = wrapped_message_commands([text], tag: "\\cbm ", width: 30, indent: indent)
      result.each do |command|
        next unless command_code(command) == 101
        command.instance_variable_set(:@parameters, [face, face.empty? ? 0 : index, 0, 2])
      end
      result
    end
    narr = lambda { |text, indent = 0| say.call("", 0, text, indent) }
    hq = lambda { |text, index = 1, indent = 0| say.call("HaiQuy_Thuongphuc_Emote", index, text, indent) }
    bully = lambda { |text, index = 1, indent = 0| say.call("BullyQuy_Thuongphuc_Emote", index, text, indent) }
    shy = lambda { |text, index = 1, indent = 0| say.call("CV_Giangsinh_Emote1", index, text, indent) }
    leo = lambda { |text, index = 1, indent = 0| say.call("Leo_Giangsinh_Emote", index, text, indent) }
    kohi = lambda { |text, index = 1, indent = 0| say.call("Kohi_Giangsinh_Emote1", index, text, indent) }
    hakase = lambda { |text, index = 1, indent = 0| say.call("Hakase_Giangsinh_Emote", index, text, indent) }
    set_graphic = lambda do |page, name, direction = 2, pattern = 1|
      graphic = page.instance_variable_get(:@graphic)
      graphic.instance_variable_set(:@character_name, name)
      graphic.instance_variable_set(:@character_index, 0)
      graphic.instance_variable_set(:@direction, direction)
      graphic.instance_variable_set(:@pattern, pattern)
      page
    end

    system_path = "Data/System.rvdata2"
    system = load_data(system_path)
    switches = system.instance_variable_get(:@switches)
    variables = system.instance_variable_get(:@variables)
    {active_sw => "ATL_OWNER_ABYSS_ACTIVE", done_sw => "ATL_OWNER_ABYSS_DONE"}.each do |id, name|
      raise "Switch #{id} already belongs to #{switches[id]}" unless switches[id].to_s.empty? || switches[id] == name
      switches[id] = name
    end
    raise "Variable #{stage_var} already belongs to #{variables[stage_var]}" unless variables[stage_var].to_s.empty? || variables[stage_var] == "ATL_OWNER_ABYSS_STAGE"
    variables[stage_var] = "ATL_OWNER_ABYSS_STAGE"

    # Connect only the two counter anchors that already contain B2925..B2951.
    map23_path = "Data/Map023.rvdata2"
    map23 = load_data(map23_path)
    events23 = map23.instance_variable_get(:@events) || {}
    tiles23 = map23.instance_variable_get(:@data).instance_variable_get(:@marshal_data).dup
    keep23 = events23.each_with_object({}) { |(id, event), memo| memo[id] = Marshal.dump(event) unless [2, 3].include?(id) }
    [2, 3].each do |event_id|
      event = events23.fetch(event_id)
      page = event.instance_variable_get(:@pages).find do |candidate|
        (candidate.instance_variable_get(:@list) || []).any? do |command|
          command_code(command) == 401 && command_parameters(command)[0].to_s.include?("Nào, tới giờ tính sổ")
        end
      end
      raise "Map023 E#{event_id} owner-first page missing" unless page
      list = page.instance_variable_get(:@list)
      final_text = list.rindex { |command| command_code(command) == 401 }
      raise "Map023 E#{event_id} final owner text missing" unless final_text
      core = list[0..final_text].reject do |command|
        command_code(command) == 117 && (1..10).include?(command_parameters(command)[0].to_i)
      end
      # Restore the authored glove-summon beat without invoking legacy camera
      # common events.  The transfer is made only after KUL is fully black.
      final_header = core.rindex { |command| command_code(command) == 101 }
      core.insert(final_header,
        event_command(212, 0, [-1, 151, true]),
        event_command(230, 0, [12]))
      core.concat([
        event_command(121, 0, [32, 32, 0]),
        event_command(122, 0, [34, 34, 0, 0, 3]),
        event_command(121, 0, [active_sw, active_sw, 0]),
        event_command(121, 0, [done_sw, done_sw, 1]),
        event_command(122, 0, [stage_var, stage_var, 0, 0, 1]),
        event_command(355, 0, ["$game_switches[17]=false; $game_switches[18]=false; map_effects.clear; map_effects.active=false"]),
        event_command(355, 0, ["$game_map.shadows.set_color(0,0,0); $game_map.shadows.show; $game_map.shadows.set_opacity(255,30) # WCF_OWNER_ABYSS_KUL_SHOP_EXIT"]),
        event_command(225, 0, [8, 8, 45, false]),
        event_command(355, 0, ["RPG::SE.new('sfx_smash',90,90).play"]),
        event_command(230, 0, [30]),
        event_command(201, 0, [0, 53, 8, 8, 8, 2]),
        event_command(0, 0, [])
      ])
      page.instance_variable_set(:@list, core)
    end

    dark_source = load_data("Data/Map025.rvdata2")
    dark_template = dark_source.instance_variable_get(:@events).fetch(1)

    # Map053: a wordless visual bridge from the authored challenge to the
    # later fact that Bully Quy sealed herself and the possessed body away.
    map53 = Marshal.load(Marshal.dump(dark_source))
    bridge = [
      event_command(355, 0, ["$game_player.transparent=true; $game_player.moveto(8,9)"]),
      event_command(355, 0, ["$game_switches[17]=false; $game_switches[18]=false; map_effects.clear; map_effects.active=false"]),
      event_command(355, 0, ["$game_map.shadows.set_color(0,0,0); $game_map.shadows.show; $game_map.shadows.set_opacity(255) # WCF_OWNER_ABYSS_KUL_BRIDGE"]),
      event_command(355, 0, ["$game_map.events[2].opacity=0; $game_map.events[3].opacity=255; $game_map.events[4].opacity=0"]),
      event_command(355, 0, ["$game_map.events[3].give_light('cutscene_actor')"]),
      event_command(355, 0, ["$game_map.shadows.set_opacity(185,35)"]),
      event_command(230, 0, [45]),
      event_command(212, 0, [3, 150, true]),
      event_command(225, 0, [7, 8, 36, false]),
      event_command(355, 0, ["$game_map.events[2].opacity=220; atlantis_monster_mode(2,:bound)"]),
      event_command(230, 0, [80]),
      event_command(355, 0, ["c=$game_map.events[4]; c.set_graphic('$Cage_1',0); c.set_direction(2); c.instance_variable_set(:@pattern,0); c.opacity=255"]),
      event_command(212, 0, [4, 150, true]),
      event_command(355, 0, ["$game_map.events[3].opacity=0"]),
      event_command(225, 0, [5, 6, 30, false]),
      event_command(230, 0, [90]),
      event_command(355, 0, ["$game_map.shadows.set_opacity(255,45) # WCF_OWNER_ABYSS_KUL_TIME_SKIP"]),
      event_command(230, 0, [45]),
      event_command(122, 0, [stage_var, stage_var, 0, 0, 2]),
      event_command(201, 0, [0, 54, 13, 21, 8, 2])
    ]
    e53_1 = event_from_pages(dark_template, 1, "SCN-ATL-OWNER-ABYSS-SEAL", 0, 0,
      [page_from_template(dark_template, bridge, trigger: 3, priority: 0, switch_id: active_sw)])
    blank53 = page_from_template(dark_template, [], trigger: 0, priority: 1)
    e53_2 = event_from_pages(dark_template, 2, "NPC-ABYSS-MONSTER", 8, 5, [blank53])
    hq53_page = page_from_template(dark_template, [], trigger: 0, priority: 1)
    set_graphic.call(hq53_page, "!$HaiQuy", 8)
    e53_3 = event_from_pages(dark_template, 3, "NPC-HAI-QUY-POSSESSED", 8, 7, [hq53_page])
    cage53_page = page_from_template(dark_template, [], trigger: 0, priority: 1)
    # The cage frame embeds Hai Quy about 1.6 tiles above its event anchor;
    # y=9 keeps the embedded feet aligned with the visible Hai Quy at y=7.
    e53_4 = event_from_pages(dark_template, 4, "FX-ABYSS-CAGE", 8, 9, [cage53_page])
    map53.instance_variable_set(:@display_name, "Atlantis — Phong ấn Vực Sâu")
    map53.instance_variable_set(:@note, "[lighting on]\r\n[opacity 255]\r\n[color 000000000]\r\nOwner-first Abyss visual bridge; KUL only")
    map53.instance_variable_set(:@events, {1 => e53_1, 2 => e53_2, 3 => e53_3, 4 => e53_4})

    # Map054: exact compact B3093..B3108 on the Christmas office parallax.
    office_source = load_data("Data/Map038.rvdata2")
    office_template = office_source.instance_variable_get(:@events).fetch(1)
    office = [
      event_command(355, 0, ["$game_player.transparent=true; $game_player.moveto(13,21)"]),
      event_command(355, 0, ["$game_switches[17]=false; $game_switches[18]=false; map_effects.clear; map_effects.active=false"]),
      event_command(355, 0, ["layer(54,0,['Map_Wanderer_Office_GiangSinh_Top',0,0,255,200,0,0,0])"]),
      event_command(655, 0, ["refresh_layers"]),
      event_command(355, 0, ["$game_map.shadows.set_color(0,0,0); $game_map.shadows.show; $game_map.shadows.set_opacity(255) # WCF_OWNER_ABYSS_KUL_OFFICE"]),
      event_command(355, 0, ["$game_map.shadows.set_opacity(95,35)"]),
      event_command(230, 0, [35])
    ]
    office.concat(narr.call("Đã hơn ba ngày kể từ khi Hải Quỳ mất liên lạc. Mọi người ngồi giữa văn phòng phủ đầy tuyết, chờ đợi trong lo lắng."))
    office.concat(leo.call("Đã quá giờ luôn rồi mà vẫn không thấy Quỳ đâu.", 5))
    office.concat(kohi.call("Chắc không có chuyện gì đâu, đúng không? Có lẽ bà ấy ngủ quên chăng?", 5))
    office.concat(shy.call("Không có chuyện ngủ quên mà không báo chúng ta đâu. Không phải bà ấy gặp chuyện gì đấy chứ?", 5))
    office.concat(hakase.call("Khả năng cao là vậy. Nãy giờ anh không liên lạc được với Quỳ. Tin nhắn cũng không gửi được.", 5))
    office.concat(leo.call("Sierra, mau chóng xác định vị trí hiện tại của Hải Quỳ đi!", 3))
    office.concat(narr.call("Sierra: Nhận lệnh. Kích hoạt hệ thống định vị. Đang phân tích. Không thể xác định. Vị trí cuối cùng: 25°B 71°T. Thời gian: 3 ngày 13 tiếng trước."))
    office.concat(leo.call("Vậy là ngay sau khi xuống Atlantis thì mất liên lạc sao?", 5))
    office.concat(kohi.call("Sao Leo biết Quỳ xuống Atlantis?", 3))
    office.concat(leo.call("Tọa độ đó là tọa độ “nhà ga” xuống Atlantis đó."))
    office.concat(shy.call("Chắc chắn có chuyện rồi. Thiết bị liên lạc của chúng ta phủ sóng đa chiều không gian, kể cả Atlantis mà.", 5))
    office.concat(kohi.call("Giờ làm sao tìm được bà ấy đây?", 5))
    office.concat(hakase.call("Anh có phép thuật dò tìm. Nhưng phải dùng tới món đồ đã lưu trữ ma pháp của Hải Quỳ."))
    office.concat(leo.call("Có! Băng đạn của Quỳ! Để tui đi lấy!", 3))
    office.concat(narr.call("Leo chạy đi lấy băng đạn rồi đưa cho Hakase. Hakase thiết lập vòng tròn ma pháp và đặt băng đạn xuống."))
    office << event_command(212, 0, [5, 109, true])
    office.concat(narr.call("Chỉ trong thoáng chốc, ma lực còn sót lại trong băng đạn của Hải Quỳ văng ra ngoài, tạo thành một khối cầu ma lực bay lơ lửng ngang tầm mắt tất cả mọi người."))
    office.concat(hakase.call("Mọi người, chuẩn bị đi. Chúng ta đi tìm Hải Quỳ.", 3))
    office.concat([
      event_command(355, 0, ["$game_map.shadows.set_opacity(255,35) # WCF_OWNER_ABYSS_KUL_TO_RESCUE"]),
      event_command(230, 0, [35]),
      event_command(122, 0, [stage_var, stage_var, 0, 0, 3]),
      event_command(201, 0, [0, 55, 8, 10, 8, 2])
    ])
    e54_1 = event_from_pages(office_template, 1, "SCN-ATL-OWNER-WANDERER-SEARCH", 0, 0,
      [page_from_template(office_template, office, trigger: 3, priority: 0, switch_id: active_sw)])
    office_events = {1 => e54_1}
    [[2, 3, "NPC-SHYLVIE", 11, 20], [3, 4, "NPC-KOHI", 12, 22],
     [4, 5, "NPC-LEO", 14, 20], [5, 6, "NPC-HAKASE", 15, 22]].each do |new_id, source_id, name, x, y|
      source_event = office_source.instance_variable_get(:@events).fetch(source_id)
      page = page_from_template(source_event, [], trigger: 0, priority: 1)
      source_graphic = source_event.instance_variable_get(:@pages).first.instance_variable_get(:@graphic)
      page.instance_variable_set(:@graphic, Marshal.load(Marshal.dump(source_graphic)))
      office_events[new_id] = event_from_pages(source_event, new_id, name, x, y, [page])
    end
    map54 = Marshal.load(Marshal.dump(office_source))
    map54.instance_variable_set(:@display_name, "Wanderer Office — Tìm Hải Quỳ")
    map54.instance_variable_set(:@note, "[lighting on]\r\n[opacity 255]\r\n[color 000000000]\r\n<full lock parallax>\r\n<tile lock parallax>\r\nOwner-first search scene; KUL only")
    map54.instance_variable_set(:@events, office_events)

    # Map055: exact compact B3152..B3186.  The cage helper intentionally
    # starts slowly and accelerates through the later fracture sheets.
    map55 = Marshal.load(Marshal.dump(dark_source))
    rescue_scene = [
      event_command(355, 0, ["$game_player.transparent=true; $game_player.moveto(8,10)"]),
      event_command(355, 0, ["$game_switches[17]=false; $game_switches[18]=false; map_effects.clear; map_effects.active=false"]),
      event_command(355, 0, ["$game_map.shadows.set_color(0,0,0); $game_map.shadows.show; $game_map.shadows.set_opacity(255) # WCF_OWNER_ABYSS_KUL_RESCUE"]),
      event_command(355, 0, ["$game_map.events[3].opacity=155; atlantis_monster_mode(3,:bound); $game_map.events[8].opacity=0"]),
      event_command(355, 0, ["[4,5,6,7].each{|id| $game_map.events[id].give_light('cutscene_actor') }"]),
      event_command(355, 0, ["$game_map.shadows.set_opacity(185,40)"]),
      event_command(230, 0, [50])
    ]
    rescue_scene.concat(narr.call("Theo chỉ dẫn của cầu ma lực, mọi người đã tìm đến chỗ của Hải Quỳ. Tại đây, họ thấy Hải Quỳ đang ngồi trong lồng phép thuật."))
    rescue_scene.concat(bully.call("Ô kìa? Mấy người mò được đến đây luôn à? Đỉnh thế?", 1))
    rescue_scene.concat(shy.call("Cái giọng này… Bully Quỳ? Chuyện gì đã xảy ra vậy?", 3))
    rescue_scene.concat(bully.call("Ờ thì bọn ta chạm trán quái vật vực sâu. Và ngươi thấy rồi đó."))
    rescue_scene.concat(leo.call("Thấy gì? Ngươi tự nhốt bản thân?", 3))
    rescue_scene.concat(bully.call("Ừ. Con này khó nhai quá, nó nhập hồn vô xác bọn ta rồi. Thế nên đành phải tự nhốt bản thân thôi."))
    rescue_scene.concat(kohi.call("Hai người không còn cách nào hạ nó sao?", 5))
    rescue_scene.concat(bully.call("Đang làm đây thôi. Ngồi đây chờ chết. Khi nào bọn ta chết, nó cũng sẽ chết."))
    rescue_scene.concat(shy.call("NGƯƠI BỊ ĐIÊN À?! Tụi tui sẽ có cách giải quyết, đừng tự ý quyết định ngu xuẩn thế!", 3))
    rescue_scene.concat(bully.call("Khỏi, cảm ơn. Ê tên đầu tảo màu tím khoai lang kia, lại đây nói cái."))
    rescue_scene << event_command(355, 0, ["$game_map.events[4].moveto(8,7)"])
    rescue_scene.concat(narr.call("Hakase bước lại gần chiếc lồng."))
    rescue_scene.concat(bully.call("Ngươi là cựu ma vương đúng không?"))
    rescue_scene.concat(hakase.call("Cũng có thể nói vậy."))
    rescue_scene.concat(bully.call("Thấy cuốn sách đằng kia không? Lụm lại đây đi."))
    rescue_scene.concat(narr.call("Hakase làm theo lời của Bully Quỳ, ra chỗ cô ta chỉ tay để lấy cuốn sách rồi quay lại."))
    rescue_scene.concat(bully.call("Trong đây có phép thuật trục xuất của Ma Vương đấy. Lật trang 512 đi."))
    rescue_scene.concat(hakase.call("Ồ, đúng thật. Oblivion Blast. “Blast” một phát thì “đăng xuất” chứ trục xuất gì…?", 3))
    rescue_scene.concat(bully.call("Thì cho đăng xuất con quái vật chứ sao ba nội? Mấy cái phép này không đủ làm bọn ta bay màu đâu, yên tâm dùng nhé."))
    rescue_scene.concat(hakase.call("Nói nghe an tâm dữ ha. Cô chưa tính đến vụ phải học phép thuật này trong bao lâu à?", 3))
    rescue_scene.concat(bully.call("Ngươi là ma vương mà, học hành là bỡn. Có khi đọc xong là ngươi đã dùng được rồi."))
    rescue_scene.concat(kohi.call("Hai người thì thầm gì đó?", 3))
    rescue_scene.concat(hakase.call("Cách để trục xuất quái vật! Mọi người đợi chút."))
    rescue_scene.concat(bully.call("Sao? Nhắm dùng được không?"))
    rescue_scene.concat(hakase.call("Dùng được! Có kế hoạch gì không?", 0))
    rescue_scene.concat(bully.call("Ta sẽ gỡ phong ấn chiếc lồng lẫn phong ấn con quái vật. Ngay khoảnh khắc chiếc lồng vừa bị phá, ngươi phải dùng phép thuật này ngay lập tức."))
    rescue_scene.concat(bully.call("Chỉ cần chậm một khắc thôi, tất cả các ngươi đều bán muối đấy."))
    rescue_scene.concat(hakase.call("Haha. Tôi lại không nghĩ mọi người yếu đến mức đấy đâu."))
    rescue_scene.concat(narr.call("Hakase hét lớn."))
    rescue_scene.concat(hakase.call("MỌI NGƯỜI! SẴN SÀNG CHIẾN ĐẤU!", 3))
    rescue_scene.concat(narr.call("Shylvie ngay lập tức triệu hồi khiên chắn cho Kohi, Leo thì xông lên trước với thanh kiếm trong tay."))
    rescue_scene << event_command(212, 0, [5, 150, true])
    rescue_scene.concat(hakase.call("Được rồi Bully Quỳ, làm đi!", 3))
    rescue_scene << event_command(225, 0, [8, 9, 180, false])
    rescue_scene << event_command(355, 0, ["atlantis_play_cage_break(2)"])
    rescue_scene << event_command(355, 0, ["$game_map.events[3].opacity=255"])
    rescue_scene.concat(narr.call("Cơn rung chấn bất ngờ diễn ra. Chiếc lồng vỡ tung. Con quái vật trỗi dậy, nuốt chửng thân xác của Hải Quỳ."))
    rescue_scene.concat(hakase.call("OBLIVION BLAST!!", 3))
    rescue_scene << event_command(212, 0, [3, 108, true])
    rescue_scene << event_command(225, 0, [10, 10, 60, false])
    rescue_scene << event_command(355, 0, ["atlantis_monster_shatter_and_fade(3,90)"])
    rescue_scene << event_command(355, 0, ["$game_map.events[8].opacity=255; $game_map.events[8].give_light('cutscene_actor')"])
    rescue_scene.concat(narr.call("Từ trên giáng xuống một cột sáng khiến con quái vật tan thành khói bụi. Khói bụi tan đi, Hải Quỳ đang đứng sừng sững hiện ra, từ từ quay lại nhìn mọi người."))
    rescue_scene.concat(narr.call("【CG HẢI QUỲ MỈM CƯỜI — CHƯA CÓ ẢNH】"))
    rescue_scene.concat(hq.call("Tui đói quá à... Tụi mình đi ăn ha, tui mời!", 0))
    rescue_scene.concat([
      event_command(121, 0, [done_sw, done_sw, 0]),
      event_command(121, 0, [active_sw, active_sw, 1]),
      event_command(122, 0, [stage_var, stage_var, 0, 0, 4]),
      event_command(122, 0, [41, 41, 0, 0, hint_id]),
      event_command(355, 0, ["$game_map.shadows.set_opacity(255,45) # WCF_OWNER_ABYSS_KUL_END"]),
      event_command(230, 0, [45]),
      event_command(201, 0, [0, 36, 8, 7, 8, 2])
    ])
    rescue_events = {}
    rescue_events[1] = event_from_pages(dark_template, 1, "SCN-ATL-OWNER-ABYSS-RESCUE", 0, 0,
      [page_from_template(dark_template, rescue_scene, trigger: 3, priority: 0, switch_id: active_sw)])
    cage_page = page_from_template(dark_template, [], trigger: 0, priority: 1)
    set_graphic.call(cage_page, "$Cage_1", 2, 0)
    rescue_events[2] = event_from_pages(dark_template, 2, "FX-ABYSS-CAGE-BREAK", 8, 5, [cage_page])
    rescue_events[3] = event_from_pages(dark_template, 3, "NPC-ABYSS-MONSTER", 8, 5,
      [page_from_template(dark_template, [], trigger: 0, priority: 1)])
    [[4, "$Hakasa_GiangSinh", "NPC-HAKASE", 6, 9],
     [5, "$Shylvie_giangsinh", "NPC-SHYLVIE", 5, 9],
     [6, "$Leo_giangsinh", "NPC-LEO", 10, 8],
     [7, "$Kohi_giangsinh", "NPC-KOHI", 11, 9],
     [8, "!$HaiQuy", "NPC-HAI-QUY-RESCUED", 8, 3]].each do |id, graphic_name, name, x, y|
      page = page_from_template(dark_template, [], trigger: 0, priority: 1)
      set_graphic.call(page, graphic_name, id == 8 ? 2 : 8)
      rescue_events[id] = event_from_pages(dark_template, id, name, x, y, [page])
    end
    map55.instance_variable_set(:@display_name, "Atlantis — Giải cứu Hải Quỳ")
    map55.instance_variable_set(:@note, "[lighting on]\r\n[opacity 255]\r\n[color 000000000]\r\nOwner-first Abyss rescue; KUL only; missing smiling CG placeholder")
    map55.instance_variable_set(:@events, rescue_events)

    # Hint 21 is the remaining B2761..B2809 Atlantis-book exchange.  Drosalya
    # has no visual asset, so her authored name is shown in ordinary messages.
    map36_path = "Data/Map036.rvdata2"
    map36 = load_data(map36_path)
    router = map36.instance_variable_get(:@events).fetch(1)
    pages36 = router.instance_variable_get(:@pages)
    pages36.reject! do |page|
      c = page.instance_variable_get(:@condition)
      c.instance_variable_get(:@variable_valid) && c.instance_variable_get(:@variable_id) == 41 && c.instance_variable_get(:@variable_value) == hint_id
    end
    dros = lambda { |text| narr.call("Drosalya: #{text}") }
    hint = [
      event_command(355, 0, ["$game_player.transparent=true; $game_player.moveto(8,7)"]),
      event_command(355, 0, ["$game_switches[17]=false; $game_switches[18]=false; map_effects.clear; map_effects.active=false"]),
      event_command(355, 0, ["$game_map.shadows.set_color(0,0,0); $game_map.shadows.show; $game_map.shadows.set_opacity(255) # WCF_OWNER_ABYSS_KUL_HINT"]),
      event_command(355, 0, ["$game_map.events[2].give_light('cutscene_actor')"]),
      event_command(355, 0, ["$game_map.shadows.set_opacity(185,30)"]),
      event_command(230, 0, [30])
    ]
    hint.concat(dros.call("Ôi cháu gái yêu đã nhận được món quà của ta chưa?"))
    hint.concat(bully.call("Món quà tuyệt vời quá ha, “mụ già”.", 3))
    hint.concat(dros.call("Kìa, lâu rồi mới gặp mà cháu nỡ nào gọi ta là “mụ già”? Ôi, đau lòng quá đi…!"))
    hint.concat(bully.call("Hừ. Quà chẳng tuyệt vời tí nào cả."))
    hint.concat(dros.call("Ôi, biết bao nhiêu kẻ thèm khát mà chẳng có được. Cháu thì được trao tận một nửa sức mạnh mà còn chê ỏng chê eo."))
    hint.concat(bully.call("Ta không cần thứ sức mạnh này."))
    hint.concat(dros.call("Cháu nỡ nào hắt hủi ta vậy?"))
    hint.concat(bully.call("Ta không có hắt hủi bà. Món quà của bà tuyệt vời thật đấy. Nhưng nó sẽ khiến cho việc tận hưởng niềm vui giết chóc của ta trở nên nhàm chán."))
    hint.concat(dros.call("Ôi cháu yêu ngốc này. Cháu chẳng hiểu gì cả. Đứng từ trên nhìn xuống dưới những kẻ đang cố leo lên bằng vị trí của cháu… Mới thú vị chứ?"))
    hint.concat(bully.call("Ta có tự cao nhưng không tự cao đến vậy. Chẳng vui gì cả."))
    hint.concat(dros.call("Vậy thì ta lấy lại nhé?"))
    hint.concat(bully.call("Quà đã tặng rồi mà còn đòi lại là sao? “Mụ già” tồi quá vậy?", 3))
    hint.concat(dros.call("Ồ, vậy là cháu chấp nhận sức mạnh này sao! Vui quá!"))
    hint.concat(bully.call("Quà được nhét tận tay chả lẽ không nhận?"))
    hint.concat(dros.call("Phải ép buộc thì cháu mới nhận. Ta rõ cháu ta quá mà."))
    hint.concat(bully.call("Hừ…"))
    hint.concat(dros.call("Dahria hay là Aira, đều là cháu ta hết. Đều là “tạo vật đáng yêu” của ta."))
    hint.concat(bully.call("………..", 5))
    hint.concat(dros.call("Thứ thuốc mà Dahria hay sử dụng… Không chỉ ức chế ký ức của kẻ bị tước đoạt danh phận… Mà còn ức chế cả “bản ngã” của cháu."))
    hint.concat(dros.call("Ôi, nhìn thứ sức mạnh quý báu của ta bị mai một dần làm ta buồn lắm. Nên đành phải dùng cách này thôi."))
    hint.concat(bully.call("Bà đã… can thiệp vào ký ức bọn ta?", 3))
    hint.concat(dros.call("Chính xác. Mà thôi, ta chỉ nói tới đây thôi. Sử dụng sức mạnh như thế nào, là tùy cháu."))
    hint.concat(dros.call("Trở thành kẻ hủy diệt. Hoặc đấng cứu thế. Là ở cháu thôi, Aira."))
    hint.concat(dros.call("À, suýt nữa quên mất kẻ đang ngồi xem bà cháu mình trò chuyện. Hãy thương yêu Dahria với Aira nhiều hơn nhé."))
    hint.concat(bully.call("Ê-", 3))
    hint.concat([
      event_command(355, 0, ["$game_map.shadows.set_opacity(255,30) # WCF_OWNER_ABYSS_KUL_HINT_END"]),
      event_command(230, 0, [30]),
      event_command(355, 0, ["$game_map.events[2].drop_light"]),
      event_command(355, 0, ["HAIQUY_TITLE.clear_ending_background"]),
      event_command(354, 0, [])
    ])
    pages36 << page_from_template(router, hint, trigger: 3, priority: 0, variable_id: 41, variable_value: hint_id)

    infos_path = "Data/MapInfos.rvdata2"
    infos = load_data(infos_path)
    [[53, 25, "Atlantis — Phong ấn Vực Sâu"], [54, 38, "Wanderer — Tìm Hải Quỳ"],
     [55, 25, "Atlantis — Giải cứu Hải Quỳ"]].each do |id, source_id, name|
      raise "MapInfo #{id} already belongs to #{infos[id].instance_variable_get(:@name)}" if infos[id] && infos[id].instance_variable_get(:@name) != name
      info = infos[id] || Marshal.load(Marshal.dump(infos.fetch(source_id)))
      info.instance_variable_set(:@name, name)
      info.instance_variable_set(:@parent_id, 23)
      info.instance_variable_set(:@expanded, true)
      info.instance_variable_set(:@order, infos.values.compact.map { |entry| entry.instance_variable_get(:@order).to_i }.max + 1) unless infos[id]
      infos[id] = info
    end

    save_data(map23_path, map23)
    save_data("Data/Map053.rvdata2", map53)
    save_data("Data/Map054.rvdata2", map54)
    save_data("Data/Map055.rvdata2", map55)
    save_data(map36_path, map36)
    save_data(infos_path, infos)
    save_data(system_path, system)

    errors = []
    verify23 = load_data(map23_path)
    verify23_events = verify23.instance_variable_get(:@events)
    errors << "Map023 tile data changed" unless verify23.instance_variable_get(:@data).instance_variable_get(:@marshal_data) == tiles23
    keep23.each { |id, dump| errors << "Map023 E%03d changed" % id unless verify23_events[id] && Marshal.dump(verify23_events[id]) == dump }
    [2, 3].each do |event_id|
      page = verify23_events[event_id].instance_variable_get(:@pages).find { |p| (p.instance_variable_get(:@list) || []).any? { |c| command_code(c) == 201 && command_parameters(c)[1] == 53 } }
      errors << "Map023 E#{event_id} owner transfer missing" unless page
      next unless page
      list = page.instance_variable_get(:@list)
      errors << "Map023 E#{event_id} retained legacy CE" if list.any? { |c| command_code(c) == 117 && (1..10).include?(command_parameters(c)[0].to_i) }
    end
    {53 => [54, "ATL-OWNER-ABYSS-SEAL"], 54 => [55, "WANDERER-SEARCH"], 55 => [36, "ABYSS-RESCUE"]}.each do |map_id, (target, marker)|
      map = load_data(format("Data/Map%03d.rvdata2", map_id))
      all = (map.instance_variable_get(:@events) || {}).values.flat_map { |e| e.instance_variable_get(:@pages) || [] }.flat_map { |p| p.instance_variable_get(:@list) || [] }
      errors << "Map#{map_id} transfer to #{target} missing" unless all.any? { |c| command_code(c) == 201 && command_parameters(c)[1] == target }
      errors << "Map#{map_id} contains native Fade/Tint" if all.any? { |c| [221, 222, 223].include?(command_code(c)) }
      errors << "Map#{map_id} missing KUL" unless all.any? { |c| [355, 655].include?(command_code(c)) && command_parameters(c)[0].to_s.include?("set_opacity") }
    end
    verify55 = load_data("Data/Map055.rvdata2")
    list55 = verify55.instance_variable_get(:@events).fetch(1).instance_variable_get(:@pages).first.instance_variable_get(:@list)
    errors << "Map055 cage timing helper missing" unless list55.any? { |c| [355, 655].include?(command_code(c)) && command_parameters(c)[0].to_s.include?("atlantis_play_cage_break(2)") }
    placeholder_text = list55.select { |c| command_code(c) == 401 }.map { |c| command_parameters(c)[0].to_s }.join(" ")
    errors << "Map055 smiling-CG placeholder missing" unless placeholder_text.include?("CHƯA CÓ ẢNH")
    verify36 = load_data(map36_path)
    hint_page = verify36.instance_variable_get(:@events).fetch(1).instance_variable_get(:@pages).find do |page|
      c = page.instance_variable_get(:@condition)
      c.instance_variable_get(:@variable_valid) && c.instance_variable_get(:@variable_id) == 41 && c.instance_variable_get(:@variable_value) == hint_id
    end
    errors << "Map036 hint 21 missing" unless hint_page
    errors << "Map036 hint 21 lacks title exit" unless hint_page && hint_page.instance_variable_get(:@list).any? { |c| command_code(c) == 354 }
    raise "Atlantis owner-first route audit failed: #{errors.join(', ')}" unless errors.empty?
    puts "ATL_OWNER_ABYSS_ROUTE|Map023>053>054>055>036>Title|switches=70,71|stage=54|hint=21|cage=slow_to_fast|placeholders=smiling_CG,Drosalya|errors=0"
  end

  # Complete the normal Ancient Demon King book route for Hakase. The special
  # owner-first/Abyss route remains separate and is not touched here.
  def implement_atlantis_ancient_book_hakase_route
    active_sw, free_sw, continue_sw, done_sw = 66, 67, 68, 69
    stage_var, hint_id = 53, 20
    say = lambda do |face, index, text, indent = 0, tag = "\\cbm "|
      result = wrapped_message_commands([text], tag: tag, width: 30, indent: indent)
      result.each do |command|
        next unless command_code(command) == 101
        command.instance_variable_set(:@parameters, [face, face.empty? ? 0 : index, 0, 2])
      end
      result
    end
    narr = lambda { |text, indent = 0| say.call("", 0, text, indent) }
    hq = lambda { |text, index = 1, indent = 0| say.call("HaiQuy_Thuongphuc_Emote", index, text, indent) }
    aira = lambda { |text, index = 1, indent = 0| say.call("BullyQuy_Thuongphuc_Emote", index, text, indent) }
    hqx = lambda { |text, index = 1, indent = 0| say.call("HaiQuy_Giangsinh_Emote", index, text, indent) }
    shy = lambda { |text, index = 1, indent = 0| say.call("CV_Giangsinh_Emote1", index, text, indent) }
    leo = lambda { |text, index = 1, indent = 0| say.call("Leo_Giangsinh_Emote", index, text, indent) }
    kohi = lambda { |text, index = 1, indent = 0| say.call("Kohi_Giangsinh_Emote1", index, text, indent) }
    hakase = lambda { |text, index = 1, indent = 0| say.call("Hakase_Giangsinh_Emote", index, text, indent) }
    bully = lambda { |text, index = 1, indent = 0| say.call("BullyQuy_Thuongphuc_Emote", index, text, indent, "\\bm[2] ") }
    picture = lambda do |id, commands|
      [event_command(355, 0, ["WCFGalleryScene.show(#{id}) # WCF_GALLERY_SCENE"])] + commands +
        [event_command(355, 0, ["WCFGalleryScene.hide # WCF_GALLERY_SCENE"])]
    end
    clone_commands = lambda { |commands| Marshal.load(Marshal.dump(commands.reject { |command| command_code(command) == 0 })) }
    remap_shared = lambda do |commands|
      result = clone_commands.call(commands)
      switch_map = {61 => active_sw, 62 => free_sw, 64 => continue_sw, 65 => done_sw}
      result.each do |command|
        params = command_parameters(command)
        if command_code(command) == 121 && switch_map[params[0]]
          params[0] = params[1] = switch_map[params[0]]
        elsif command_code(command) == 122 && params[0] == 52
          params[0] = params[1] = stage_var
        elsif [355, 655].include?(command_code(command))
          params[0] = params[0].to_s.gsub("WCF_ATL_BOOK_KUL", "WCF_ATL_HAK_KUL").gsub("layer(49,", "layer(51,")
        end
      end
      result
    end

    system_path = "Data/System.rvdata2"
    system = load_data(system_path)
    switches = system.instance_variable_get(:@switches)
    variables = system.instance_variable_get(:@variables)
    {66 => "ATL_BOOK_HAK_ACTIVE", 67 => "ATL_BOOK_HAK_FREE_EXPLORE",
     68 => "ATL_BOOK_HAK_PARTY_CONTINUE", 69 => "ATL_BOOK_HAK_DONE"}.each do |id, name|
      raise "Switch #{id} already belongs to #{switches[id]}" unless switches[id].to_s.empty? || switches[id] == name
      switches[id] = name
    end
    raise "Variable 53 already belongs to #{variables[stage_var]}" unless variables[stage_var].to_s.empty? || variables[stage_var] == "ATL_BOOK_HAK_STAGE"
    variables[stage_var] = "ATL_BOOK_HAK_STAGE"

    # Reset only this route's private state in the existing Atlantis bus branch.
    map10_path = "Data/Map010.rvdata2"
    map10 = load_data(map10_path)
    bus_page = (map10.instance_variable_get(:@events) || {}).values.flat_map { |event| event.instance_variable_get(:@pages) || [] }.find do |page|
      (page.instance_variable_get(:@list) || []).any? { |command| command_code(command) == 402 && command_parameters(command)[1].to_s.start_with?("Xuống Atlantis") }
    end
    raise "Map010 Atlantis branch missing" unless bus_page
    bus_list = bus_page.instance_variable_get(:@list)
    branch_at = bus_list.index { |command| command_code(command) == 402 && command_parameters(command)[1].to_s.start_with?("Xuống Atlantis") }
    unless bus_list.any? { |command| [355, 655].include?(command_code(command)) && command_parameters(command)[0].to_s.include?("WCF_ATL_BOOK_HAK_RESET") }
      bus_list.insert(branch_at + 1,
        event_command(121, 1, [active_sw, active_sw, 1]), event_command(121, 1, [free_sw, free_sw, 1]),
        event_command(121, 1, [continue_sw, continue_sw, 1]), event_command(121, 1, [done_sw, done_sw, 1]),
        event_command(355, 1, ["$game_variables[53]=0 # WCF_ATL_BOOK_HAK_RESET"]))
    end

    # Map023: Variable 31 uses >= page conditions, therefore value-1 pages
    # must be inserted before the existing value-2 Shylvie pages.
    map23_path = "Data/Map023.rvdata2"
    map23 = load_data(map23_path)
    events23 = map23.instance_variable_get(:@events) || {}
    [2, 3, 12, 36].each { |id| raise "Map023 E#{id} missing" unless events23[id] }
    tiles23 = map23.instance_variable_get(:@data).instance_variable_get(:@marshal_data).dup
    keep23 = events23.each_with_object({}) { |(id, event), memo| memo[id] = Marshal.dump(event) unless [2, 3, 12, 36].include?(id) }
    insert_var1 = lambda do |event, commands|
      pages = event.instance_variable_get(:@pages)
      pages.reject! do |page|
        condition = page.instance_variable_get(:@condition)
        condition.instance_variable_get(:@variable_valid) && condition.instance_variable_get(:@variable_id) == 31 && condition.instance_variable_get(:@variable_value) == 1
      end
      page = page_from_template(event, commands, trigger: 0, priority: 1, variable_id: 31, variable_value: 1)
      index2 = pages.index do |candidate|
        condition = candidate.instance_variable_get(:@condition)
        condition.instance_variable_get(:@variable_valid) && condition.instance_variable_get(:@variable_id) == 31 && condition.instance_variable_get(:@variable_value) == 2
      end
      pages.insert(index2 || pages.length, page)
    end
    insert_var1.call(events23[12], hq.call("Mình đã chọn cuốn Ma Vương Cổ Đại cho Hakase rồi. Không nên đổi sang cuốn khác nữa."))
    insert_var1.call(events23[36], hq.call("Mình đã chọn cuốn Ma Vương Cổ Đại rồi. Mang ra quầy thôi."))
    checkout = []
    checkout.concat(narr.call("Tôi mang cuốn sách ra quầy cho chủ tiệm gói lại cẩn thận. Chị ấy còn tặng kèm một thẻ đánh dấu trang giấy có in hình hoa oải hương trên đấy."))
    checkout.concat(aira.call("Ngươi tính tặng cho tên ma vương đáng gờm đó à?", 3))
    checkout.concat(hq.call("Ừ đúng rồi, sao thế?", 3))
    checkout.concat(aira.call("Chưa bao giờ ta thấy ngươi đưa ra lựa chọn đúng đắn như thế này. Ngoan quá!", 0))
    checkout.concat(hq.call("Ê nha, có ẩn ý gì đấy?", 3)); checkout.concat(aira.call("Ẩn ý gì đâu, ngươi nghĩ nhiều quá rồi đó!"))
    checkout.concat([event_command(121, 0, [active_sw, active_sw, 0]),
      event_command(121, 0, [free_sw, free_sw, 1]), event_command(121, 0, [continue_sw, continue_sw, 1]),
      event_command(121, 0, [done_sw, done_sw, 1]), event_command(122, 0, [stage_var, stage_var, 0, 0, 1]),
      event_command(355, 0, ["$game_switches[17]=false; $game_switches[18]=false; map_effects.clear; map_effects.active=false"]),
      event_command(355, 0, ["$game_map.shadows.set_color(0,0,0); $game_map.shadows.show; $game_map.shadows.set_opacity(255,20) # WCF_ATL_HAK_KUL_CHECKOUT"]),
      event_command(230, 0, [20]), event_command(201, 0, [0, 51, 7, 5, 2, 2])])
    insert_var1.call(events23[2], clone_commands.call(checkout)); insert_var1.call(events23[3], clone_commands.call(checkout))

    # Map051 reuses the already-tested preparation staging from Map049.
    map51 = Marshal.load(Marshal.dump(load_data("Data/Map049.rvdata2")))
    events51 = map51.instance_variable_get(:@events)
    template51 = events51.fetch(1)
    source_page51 = template51.instance_variable_get(:@pages).first
    prep51 = remap_shared.call(source_page51.instance_variable_get(:@list))
    page51 = page_from_template(template51, prep51, trigger: 3, priority: 0, switch_id: active_sw)
    map51.instance_variable_set(:@display_name, "Phòng Hải Quỳ — Sách tặng Hakase")
    map51.instance_variable_set(:@note, "[lighting on]\r\n[opacity 255]\r\n[color 000000000]\r\n<full lock parallax>\r\n<tile lock parallax>\r\nATL ancient-book Hakase preparation; KUL only")
    map51.instance_variable_set(:@events, {1 => event_from_pages(template51, 1, "SCN-ATL-BOOK-HAK-PREP", 0, 0, [page51]), 3 => events51.fetch(3)})

    # Map038: clone only the stable greeting/free-roam shell; all Hakase gift
    # dialogue lives in a new continuation event E120.
    map38_path = "Data/Map038.rvdata2"
    map38 = load_data(map38_path)
    events38 = map38.instance_variable_get(:@events) || {}
    intro_event, leo_event = events38.fetch(1), events38.fetch(5)
    raise "Map038 E120 is occupied" if events38[120] && !events38[120].instance_variable_get(:@name).to_s.start_with?("SCN-ATL-BOOK-HAK")
    tiles38 = map38.instance_variable_get(:@data).instance_variable_get(:@marshal_data).dup
    keep38 = events38.each_with_object({}) { |(id, event), memo| memo[id] = Marshal.dump(event) unless [1, 5, 120].include?(id) }
    source_intro = intro_event.instance_variable_get(:@pages).find { |page| c=page.instance_variable_get(:@condition); c.instance_variable_get(:@switch1_valid) && c.instance_variable_get(:@switch1_id) == 61 }
    source_leo = leo_event.instance_variable_get(:@pages).find { |page| c=page.instance_variable_get(:@condition); c.instance_variable_get(:@switch1_valid) && c.instance_variable_get(:@switch1_id) == 62 }
    raise "Map038 Shylvie route shell missing" unless source_intro && source_leo
    intro_pages = intro_event.instance_variable_get(:@pages)
    intro_pages.reject! { |page| c=page.instance_variable_get(:@condition); c.instance_variable_get(:@switch1_valid) && [active_sw,free_sw,continue_sw].include?(c.instance_variable_get(:@switch1_id)) }
    intro_pages << page_from_template(intro_event, remap_shared.call(source_intro.instance_variable_get(:@list)), trigger: 3, priority: 0, switch_id: active_sw)
    intro_pages << page_from_template(intro_event, [], trigger: 0, priority: 0, switch_id: free_sw)
    intro_pages << page_from_template(intro_event, [], trigger: 0, priority: 0, switch_id: continue_sw)
    leo_pages = leo_event.instance_variable_get(:@pages)
    leo_pages.reject! { |page| c=page.instance_variable_get(:@condition); c.instance_variable_get(:@switch1_valid) && c.instance_variable_get(:@switch1_id) == free_sw }
    leo_pages << page_from_template(leo_event, remap_shared.call(source_leo.instance_variable_get(:@list)), trigger: 0, priority: 1, switch_id: free_sw)

    party = [event_command(355, 0, ["$game_map.shadows.set_color(0,0,0); $game_map.shadows.show; $game_map.shadows.set_opacity(255,20) # WCF_ATL_HAK_KUL_PARTY_BLACK"]),
      event_command(230, 0, [20]), event_command(355, 0, ["hq=$game_map.events[2]; hq.moveto($game_player.x,$game_player.y); hq.transparent=false; $game_player.transparent=true"])]
    party.concat(narr.call("Tôi lập tức đứng dậy, cầm theo túi quà được gói kỹ càng tiến đến chỗ của Hakase."))
    party.concat(narr.call("Hakase xé giấy gói quà của tôi rách thành trăm mảnh bay xuống nền nhà như pháo giấy. Hakase cầm cuốn sách lên, mắt chữ A và miệng chữ O nhìn tôi, kinh ngạc hết cỡ."))
    party.concat(hqx.call("Đây là…sách “Ma Vương Cổ Đại” á anh! Cuốn này kể về Ma Vương Cổ Đại từng trị vì Atlantis."))
    party.concat(hakase.call("Nghe nó cứ sai sai làm sao ấy Hải Quỳ! Anh tưởng Atlantis nào giờ được trị vì bởi Poseidon?", 3))
    party.concat(hqx.call("Thú thực là em cũng không rõ lắm. Chỉ biết là cuốn này được viết bằng ngôn ngữ cổ, phép thuật được viết trong này toàn bộ là phép thuật không ai dùng ở Atlantis thời đại bây giờ nữa."))
    party.concat(hakase.call("Trời! Em đọc được ngôn ngữ cổ hả?", 3)); party.concat(hqx.call("Em đọc bặp bẹ được vài từ thôi!"))
    party.concat(shy.call("Ê ê Quỳ, tôi có câu hỏi. Rồi sao bà biết phép thuật ở trong cuốn này không còn ai dùng nữa? Bà thử rồi phải không??", 3))
    party.concat(hqx.call("T-Thì đọc chứ sao má!! Ngộ ghê!", 3)); party.concat(hqx.call("Oblivion Blast.", 0))
    party << event_command(225, 0, [8, 8, 30, false]); party.concat(narr.call("“ĐÙNG”"))
    party.concat(narr.call("Cả văn phòng Wanderer rung chuyển dữ dội làm mọi người hoảng hốt. Sierra phát báo động đỏ."))
    party.concat(narr.call("Cảnh báo. Cảnh báo. Ghi nhận sự nhiễu động mạnh từ luồng ma lực bất thường trong văn phòng."))
    party.concat(kohi.call("Cái gì vừa xảy ra vậy? Thiên thạch đâm trúng văn phòng hả? Ủa đâu…", 3))
    party.concat(shy.call("Leo…sao người ông cháy đen thui vậy?!?! TỪ TỪ, ĐỂ TUI HỒI PHỤC CHO!!", 3))
    party.concat(hakase.call("Uầy Quỳ, phép thuật này ở Atlantis có ai dùng chưa?", 3)); party.concat(hqx.call("Chưa…! Anh chỉ em với! Em cũng muốn học!"))
    party.concat(hakase.call("Đưa tay em đây.")); party.concat(narr.call("Tôi chìa tay, Hakase lập tức chộp lấy, truyền dạy cho tôi “Oblivion Blast”. Một luồng điện xẹt qua đầu, trong đầu tôi bỗng dưng hiện lên hàng chục dòng ngôn ngữ cổ được dịch sang ngôn ngữ Atlantis hiện đại."))
    party.concat(hqx.call("OBLIVION BLAST!!!", 3)); party << event_command(225, 0, [6, 7, 24, false])
    party.concat(shy.call("TRỜI ƠI QUỲ ƠI!! BÀ LÀM CÁI GÌ VẬY?! SUÝT NỮA TRÚNG TÔI RỒI!!", 3))
    party.concat(hqx.call("Úi da, xin lỗi nha! Ehe", 5)); party.concat(shy.call("EHE CÁI QUẦN!!!", 3))
    party.concat(narr.call("Hakase lướt nhanh qua cuốn sách, vừa đọc vừa gật gù.")); party.concat(hakase.call("Cảm ơn em nha!! Món quà này tuyệt vời lắm!", 0))
    party.concat(narr.call("Nói rồi Hakase cất cuốn sách vào túi không gian của anh ấy, đồng thời lôi ra một hộp giấy đính nhiều ruy băng."))
    party.concat(picture.call(80, narr.call("Kohi gọi với Sierra một tiếng, toàn bộ đèn trong văn phòng được bật sáng trở lại. Kohi đứng dậy đi vào phòng để cất chiếc đèn ngủ ma thuật rồi đi ra ngoài với một chiếc váy dạ hội màu xanh lơ lấp lánh kim tuyến. Chỉ cần nhìn vào chúng thôi, tôi có thể xác định được món quà này sẽ dành tặng cho ai.")))
    party.concat(shy.call("Ôi, cảm ơn con gái yêu của bố! Váy đẹp quá!!", 0))
    party.concat(picture.call(74, narr.call("Sau khi nhận được chiếc váy dạ hội mà Kohi tặng, Shylvie cẩn thận cất nó vào trong chiếc túi không gian ma thuật của mình. Xong, Shylvie rút ra một chiếc ốp lưng điện thoại màu đen từ trong chiếc túi và đưa nó cho Leo.")))
    party.concat([event_command(122, 0, [stage_var, stage_var, 0, 0, 5]),
      event_command(121, 0, [free_sw, free_sw, 1]), event_command(121, 0, [continue_sw, continue_sw, 1]),
      event_command(355, 0, ["$game_map.shadows.set_opacity(255,30) # WCF_ATL_HAK_KUL_TO_EPILOGUE"]),
      event_command(230, 0, [30]), event_command(201, 0, [0, 52, 21, 31, 8, 2])])
    events38[120] = event_from_pages(events38.fetch(7), 120, "SCN-ATL-BOOK-HAK-PARTY-CONTINUE", 0, 0,
      [page_from_template(events38.fetch(7), party, trigger: 3, priority: 0, switch_id: continue_sw)])

    # Map052: exact compact B3110..B3130. No transformed-Hakase sprite exists,
    # so retain his current event graphic instead of substituting a wrong asset.
    map52 = Marshal.load(Marshal.dump(load_data("Data/Map039.rvdata2")))
    events52 = map52.instance_variable_get(:@events); template52 = events52.fetch(1)
    epi = [event_command(355, 0, ["$game_player.transparent=true"]),
      event_command(355, 0, ["layer(52,0,[\"Map_Wanderer_Office_top\",0,0,255,200,0,0,0])"]), event_command(655, 0, ["refresh_layers"]),
      event_command(355, 0, ["$game_switches[17]=false; $game_switches[18]=false; map_effects.clear; map_effects.active=false"]),
      event_command(355, 0, ["$game_map.shadows.set_color(0,0,0); $game_map.shadows.show; $game_map.shadows.set_opacity(255) # WCF_ATL_HAK_KUL_EPILOGUE"]),
      event_command(355, 0, ["$game_map.shadows.set_opacity(0,30)"]), event_command(230, 0, [30])]
    epi.concat(narr.call("Sáng hôm sau, tôi mệt mỏi dịch chuyển về văn phòng để ăn kem như lời đã hẹn. Nhưng Shylvie đã dùng hết số kem socola tối qua để làm một món tráng miệng mới theo kiểu Tây Âu cho cả văn phòng, đến chiều mới được ăn."))
    epi.concat(narr.call("Bù lại, sáng nay Shylvie nấu bữa sáng theo kiểu Đức, ăn ngon lắm.")); epi.concat(hqx.call("Thế Hakase đâu rồi?", 3))
    epi.concat(shy.call("Đang thử phép thuật trong phòng nghiên cứu á. Vậy có gì ăn xong bà mang bữa sáng qua cho ổng nhé?")); epi.concat(hqx.call("Ọ, biết ùi."))
    epi.concat(narr.call("Tui liếm sạch đĩa, chùi miệng rồi lon ton mang khay bữa sáng vô phòng nghiên cứu. Tại đây, tôi nghe thấy giọng Hakase vọng ra từ một luồng sáng gì đó cháy rực làm đôi mắt mỏi mệt của tôi muốn mù."))
    epi.concat(hakase.call("Quỳ! Em đến đúng lúc lắm! Nhìn nè!", 0)); epi.concat(narr.call("Hakase bước ra từ luồng sáng ấy. Mặt Hakase điển trai hơn, có sức hút kỳ lạ hơn."))
    epi.concat(hakase.call("Tada! Tối hôm qua anh nghiên cứu cuốn sách này và phát hiện ra ma lực còn sót lại của Ma Vương! Rồi anh hấp thụ nó và thế là…!!", 0))
    epi.concat(hqx.call("Nhìn ngầu thiệt đó!!", 0)); epi.concat(narr.call("Nhưng chả hiểu vì sao cơ thể tôi cảm thấy khó chịu khôn lường. Một cảm giác quen thuộc? Tức giận? Không đời nào tôi lại ghen tỵ với Hakase vì ông ấy mở khóa được hình dạng mới. Hakase xứng đáng mà."))
    epi.concat(hakase.call("Hải Quỳ, mang bữa sáng qua bàn mổ đi!")); epi.concat(hqx.call("Hả? Okay, bữa sáng đây.", 3)); epi.concat(narr.call("Tôi đặt bữa sáng lên bàn mổ của Hakase."))
    epi.concat(hakase.call("Hải Quỳ! Mau chồng cây chuối đi!", 3)); epi.concat(hqx.call("Hả…Em đâu biết chồng cây chuối đâu…", 3))
    epi.concat(hakase.call("…??? Hmm, Hải Quỳ, sử dụng Moonlight Delulu Breaker đi!!", 3)); epi.concat(hqx.call("Nó là Moonlight Divine Breaker!! Cơ mà sao em phải dùng vậy??", 3))
    epi.concat(hakase.call("Quái lạ…! Trong sách bảo là với hình dạng này, anh có thể sai khiến cư dân Atlantis làm theo điều anh muốn, kể cả Poseidon mà…! Chả lẽ…", 3))
    epi.concat(hqx.call("Hả….???", 3)); epi.concat(hakase.call("Em…không phải là người Atlantis à…?", 3))
    epi.concat([event_command(121, 0, [active_sw, active_sw, 1]), event_command(121, 0, [done_sw, done_sw, 0]),
      event_command(122, 0, [stage_var, stage_var, 0, 0, 6]), event_command(122, 0, [41, 41, 0, 0, hint_id]),
      event_command(355, 0, ["$game_map.shadows.set_opacity(255,30) # WCF_ATL_HAK_KUL_END"]), event_command(230, 0, [30]),
      event_command(201, 0, [0, 36, 8, 7, 8, 2])])
    events52[1] = event_from_pages(template52, 1, "SCN-ATL-BOOK-HAK-EPILOGUE", 0, 0,
      [page_from_template(template52, epi, trigger: 3, priority: 0, switch_id: active_sw)])
    map52.instance_variable_set(:@display_name, "Wanderer Office — Hậu truyện sách Hakase")
    map52.instance_variable_set(:@note, "[lighting on]\r\n[opacity 255]\r\n[color 000000000]\r\n<full lock parallax>\r\n<tile lock parallax>\r\nATL ancient-book Hakase epilogue; KUL only; hint=20; missing transformed Hakase asset")
    map52.instance_variable_set(:@events, events52)

    # Map036 hint 20: exact compact B2746..B2760, KUL-only.
    map36_path = "Data/Map036.rvdata2"; map36 = load_data(map36_path)
    router = map36.instance_variable_get(:@events).fetch(1); pages36 = router.instance_variable_get(:@pages)
    pages36.reject! { |page| c=page.instance_variable_get(:@condition); c.instance_variable_get(:@variable_valid) && c.instance_variable_get(:@variable_id) == 41 && c.instance_variable_get(:@variable_value) == hint_id }
    hint = [event_command(355, 0, ["$game_player.transparent=true; $game_player.moveto(8,7)"]),
      event_command(355, 0, ["$game_switches[17]=false; $game_switches[18]=false; map_effects.clear; map_effects.active=false"]),
      event_command(355, 0, ["$game_map.shadows.set_color(0,0,0); $game_map.shadows.show; $game_map.shadows.set_opacity(255) # WCF_ATL_HAK_KUL_HINT"]),
      event_command(355, 0, ["$game_map.events[2].give_light(\"cutscene_actor\")"]),
      event_command(355, 0, ["$game_map.shadows.set_opacity(185,30)"]), event_command(230, 0, [30])]
    ["…..", "Sao, ngươi không hiểu chuyện gì vừa xảy ra à?", "Ngươi, à không.", "Hải Quỳ, không phải là người Atlantis.",
     "Chính xác hơn, Hải Quỳ không phải người Atlantis thuần chủng.", "Nên là nhỏ mới không bị ràng buộc bởi lời sai khiến từ ma vương.",
     "Và hoàn toàn miễn nhiễm với sức mạnh thao túng từ các quái vật vực sâu cấp cao.", "Vì thế Poseidon mới trọng dụng con nhỏ ăn hại này đó.",
     "Ồ, ngươi bắt đầu ngờ ngợ ra rồi phải không?", "Nhỏ này chưa bao giờ đề cập đến vụ này hả?",
     "Ừ, nhỏ này có nhớ gì đâu mà đề cập. Giờ ngươi có hỏi nó nó cũng đơ mặt nó ra.", "Đúng rồi, người duy nhất biết rõ chân tướng của Hải Quỳ.",
     "Chỉ có ta mà thôi.", "Nhưng ta sẽ không “sì poi” đâu.", "Paii paii~"].each_with_index { |text, index| hint.concat(bully.call(text, index == 0 ? 5 : 1)) }
    hint.concat([event_command(355, 0, ["$game_map.shadows.set_opacity(255,30) # WCF_ATL_HAK_KUL_HINT_END"]), event_command(230, 0, [30]),
      event_command(355, 0, ["$game_map.events[2].drop_light"]), event_command(355, 0, ["HAIQUY_TITLE.clear_ending_background"]), event_command(354, 0, [])])
    pages36 << page_from_template(router, hint, trigger: 3, priority: 0, variable_id: 41, variable_value: hint_id)

    infos_path = "Data/MapInfos.rvdata2"; infos = load_data(infos_path)
    [[51, 49, "Phòng Hải Quỳ — Sách tặng Hakase"], [52, 39, "Hậu truyện — Ma Vương Cổ Đại Hakase"]].each do |id, source_id, name|
      raise "MapInfo #{id} already belongs to #{infos[id].instance_variable_get(:@name)}" if infos[id] && infos[id].instance_variable_get(:@name) != name
      info = infos[id] || Marshal.load(Marshal.dump(infos.fetch(source_id)))
      info.instance_variable_set(:@name, name); info.instance_variable_set(:@parent_id, 23); info.instance_variable_set(:@expanded, true)
      info.instance_variable_set(:@order, infos.values.compact.map { |entry| entry.instance_variable_get(:@order).to_i }.max + 1) unless infos[id]
      infos[id] = info
    end
    map23.instance_variable_set(:@events, events23); map38.instance_variable_set(:@events, events38)
    save_data(map10_path, map10); save_data(map23_path, map23); save_data("Data/Map051.rvdata2", map51)
    save_data(map38_path, map38); save_data("Data/Map052.rvdata2", map52); save_data(map36_path, map36)
    save_data(infos_path, infos); save_data(system_path, system)

    errors = []
    verify23 = load_data(map23_path); verify23_events = verify23.instance_variable_get(:@events)
    errors << "Map023 tile data changed" unless verify23.instance_variable_get(:@data).instance_variable_get(:@marshal_data) == tiles23
    keep23.each { |id, dump| errors << "Map023 E%03d changed" % id unless verify23_events[id] && Marshal.dump(verify23_events[id]) == dump }
    verify38 = load_data(map38_path); verify38_events = verify38.instance_variable_get(:@events)
    errors << "Map038 tile data changed" unless verify38.instance_variable_get(:@data).instance_variable_get(:@marshal_data) == tiles38
    keep38.each { |id, dump| errors << "Map038 E%03d changed" % id unless verify38_events[id] && Marshal.dump(verify38_events[id]) == dump }
    verify51_list = load_data("Data/Map051.rvdata2").instance_variable_get(:@events)[1].instance_variable_get(:@pages).first.instance_variable_get(:@list)
    verify52_list = load_data("Data/Map052.rvdata2").instance_variable_get(:@events)[1].instance_variable_get(:@pages).first.instance_variable_get(:@list)
    verify120_list = verify38_events[120].instance_variable_get(:@pages).first.instance_variable_get(:@list)
    verify_intro = verify38_events[1].instance_variable_get(:@pages).find { |page| c=page.instance_variable_get(:@condition); c.instance_variable_get(:@switch1_valid) && c.instance_variable_get(:@switch1_id) == active_sw }
    verify_intro_list = verify_intro && verify_intro.instance_variable_get(:@list) || []
    verify_checkout = verify23_events[2].instance_variable_get(:@pages).find { |page| c=page.instance_variable_get(:@condition); c.instance_variable_get(:@variable_valid) && c.instance_variable_get(:@variable_id) == 31 && c.instance_variable_get(:@variable_value) == 1 }
    verify_checkout_list = verify_checkout && verify_checkout.instance_variable_get(:@list) || []
    verify_hint = load_data(map36_path).instance_variable_get(:@events)[1].instance_variable_get(:@pages).find { |page| c=page.instance_variable_get(:@condition); c.instance_variable_get(:@variable_valid) && c.instance_variable_get(:@variable_id) == 41 && c.instance_variable_get(:@variable_value) == hint_id }
    verify_hint_list = verify_hint && verify_hint.instance_variable_get(:@list) || []
    {"Map023 Hakase checkout" => verify_checkout_list, "Map051 preparation" => verify51_list,
     "Map038 Hakase arrival" => verify_intro_list, "Map038 Hakase party" => verify120_list,
     "Map052 epilogue" => verify52_list, "Map036 Hakase hint" => verify_hint_list}.each do |label, list|
      errors << "#{label} contains native Fade/Tint" if list.any? { |command| [221, 222, 223].include?(command_code(command)) }
      errors << "#{label} calls legacy lighting common event" if list.any? { |command| command_code(command) == 117 && [3, 5].include?(command_parameters(command)[0]) }
      errors << "#{label} contains legacy visual lighting" if list.any? { |command| [355, 655].include?(command_code(command)) && command_parameters(command)[0].to_s.match?(/start_tone_change|map_effects\.(?:set_tone|set_color|set_zoom)/) }
      errors << "#{label} missing KUL opacity" unless list.any? { |command| [355, 655].include?(command_code(command)) && command_parameters(command)[0].to_s.include?("$game_map.shadows.set_opacity") }
    end
    errors << "Map038 E120 missing" unless verify38_events[120]
    cg14_index = verify51_list.index { |command| [355, 655].include?(command_code(command)) && command_parameters(command)[0].to_s.include?("WCFGalleryScene.show(31)") }
    outfit_swap_index = verify51_list.index { |command| [355, 655].include?(command_code(command)) && command_parameters(command)[0].to_s.include?("WCF_ATL_BOOK_OUTFIT_SWAP_AFTER_CG14") }
    errors << "Map051 outfit swap occurs before CG14" unless cg14_index && outfit_swap_index && outfit_swap_index > cg14_index
    errors << "Map051 outfit swap is not hidden by KUL" unless cg14_index && outfit_swap_index && verify51_list[cg14_index...outfit_swap_index].any? do |command|
      [355, 655].include?(command_code(command)) && command_parameters(command)[0].to_s.include?("set_opacity(255")
    end
    [2, 3, 12, 36].each do |id|
      values = verify23_events[id].instance_variable_get(:@pages).map do |page|
        c = page.instance_variable_get(:@condition)
        c.instance_variable_get(:@variable_valid) && c.instance_variable_get(:@variable_id) == 31 ? c.instance_variable_get(:@variable_value) : nil
      end
      errors << "Map023 E#{id} book page priority invalid" unless values.index(1) && values.index(2) && values.index(1) < values.index(2)
    end
    errors << "Map052 hint transfer missing" unless verify52_list.any? { |command| command_code(command) == 201 && command_parameters(command)[1] == 36 }
    hint_text = verify_hint_list.select { |command| command_code(command) == 401 }.map { |command| command_parameters(command)[0].to_s }.join(" ")
    errors << "Hakase ending hint text missing" unless hint_text.include?("không phải là người Atlantis") && hint_text.include?("Paii paii~")
    errors << "VayCV picture missing" unless verify120_list.any? { |command| [355, 655].include?(command_code(command)) && command_parameters(command)[0].to_s.include?("WCFGalleryScene.show(80)") }
    errors << "Oplung picture missing" unless verify120_list.any? { |command| [355, 655].include?(command_code(command)) && command_parameters(command)[0].to_s.include?("WCFGalleryScene.show(74)") }
    raise "Atlantis Hakase ancient-book route audit failed: #{errors.join(', ')}" unless errors.empty?
    puts "ATL_BOOK_HAK_ROUTE|Map023>051>038>052>036>Title|free=67|continue=68|hint=20|pictures=80,74|CG=none_assigned|errors=0"
  end

  def fix_invalid_game_screen_calls
    changed = []
    Dir.glob("Data/Map[0-9][0-9][0-9].rvdata2").sort.each do |path|
      map = load_data(path)
      hits = 0
      (map.instance_variable_get(:@events) || {}).each_value do |event|
        next unless event
        (event.instance_variable_get(:@pages) || []).each do |page|
          (page.instance_variable_get(:@list) || []).each do |command|
            next unless [355, 655].include?(command_code(command))
            params = command_parameters(command)
            script = params[0].to_s
            next unless script.include?("$game_screen.")
            # Explicitly address the map screen in script commands.  The
            # interpreter helper `screen` is context-sensitive and can resolve
            # to nil during map-transfer cutscenes.
            params[0] = script.gsub("$game_screen.", "$game_map.screen.")
            hits += 1
          end
        end
      end
      next if hits == 0
      save_data(path, map)
      changed << "#{File.basename(path, '.rvdata2')}:#{hits}"
    end
    puts "FIX_GAME_SCREEN_CALLS|#{changed.empty? ? 'none' : changed.join(',')}"
  end

  # Three authored branches entered after the third Leo interaction on
  # Map013.  New maps own all route-specific staging; shared maps only gain
  # pages/events identified by the LEO_SHOP names below.
  def implement_leo_shop_routes
    active_sw, free_sw, continue_sw, done_sw = 72, 73, 74, 75
    branch_var, stage_var = 55, 56
    say = lambda do |face, index, text, indent = 0, tag = "\\cbm "|
      result = wrapped_message_commands([text], tag: tag, width: 30, indent: indent)
      result.each do |command|
        next unless command_code(command) == 101
        command.instance_variable_set(:@parameters, [face, face.empty? ? 0 : index, 0, 2])
      end
      result
    end
    narr = lambda { |text, indent = 0| say.call("", 0, text, indent) }
    hq = lambda { |text, index = 1, indent = 0| say.call("HaiQuy_Thuongphuc_Emote", index, text, indent) }
    hqx = lambda { |text, index = 1, indent = 0| say.call("HaiQuy_Giangsinh_Emote", index, text, indent) }
    aira = lambda { |text, index = 1, indent = 0| say.call("BullyQuy_Thuongphuc_Emote", index, text, indent) }
    leo = lambda { |text, index = 1, indent = 0| say.call("Leo_Giangsinh_Emote", index, text, indent) }
    shy = lambda { |text, index = 1, indent = 0| say.call("CV_Giangsinh_Emote1", index, text, indent) }
    kohi = lambda { |text, index = 1, indent = 0| say.call("Kohi_Giangsinh_Emote1", index, text, indent) }
    hakase = lambda { |text, index = 1, indent = 0| say.call("Hakase_Giangsinh_Emote", index, text, indent) }
    erufu = lambda { |text, index = 1, indent = 0| say.call("Erufu_Emote", index, text, indent) }
    traveller = lambda { |text, index = 1, indent = 0| say.call("Traveller_Emote", index, text, indent) }
    picture = lambda do |id, commands|
      [event_command(355, 0, ["WCFGalleryScene.show(#{id}) # WCF_GALLERY_SCENE"])] + commands +
        [event_command(355, 0, ["WCFGalleryScene.hide # WCF_GALLERY_SCENE"])]
    end
    clone_commands = lambda do |commands|
      Marshal.load(Marshal.dump(commands.reject { |command| command_code(command) == 0 }))
    end
    set_graphic = lambda do |page, name, direction = 2, pattern = 1|
      graphic = page.instance_variable_get(:@graphic)
      graphic.instance_variable_set(:@character_name, name)
      graphic.instance_variable_set(:@character_index, 0)
      graphic.instance_variable_set(:@direction, direction)
      graphic.instance_variable_set(:@pattern, pattern)
      page
    end
    compact_path = "docs/kich ban/GAME_SCRIPT_AI_COMPACT_V2.md"
    registry = {}
    File.readlines(compact_path, encoding: "UTF-8", chomp: true).each do |line|
      match = /\A(B\d{4}):\s?(.*)\z/.match(line)
      registry[match[1]] = match[2] if match
    end
    blocks = lambda do |first, last|
      (first..last).map { |id| registry.fetch(format("B%04d", id)) }
    end
    source_messages = lambda do |first, last|
      commands = []
      blocks.call(first, last).each_with_index do |text, offset|
        block_id = first + offset
        next if text.empty? || text.match?(/\A(?:\[|Cảnh số|Hết cảnh|Hakase\z|Kohi\z|Shylvie\z)/i)
        case text
        when /\A(?:Cô Elf tóc tím|Erufu)[\s\u00A0]*:[\s\u00A0]*(.*)/i
          commands.concat(erufu.call(Regexp.last_match(1), 1))
        when /\A(?:Cô gái tóc nâu|Traveller)[\s\u00A0]*:[\s\u00A0]*(.*)/i
          commands.concat(traveller.call(Regexp.last_match(1), 1))
        when /\AHải Quỳ[\s\u00A0]*:[\s\u00A0]*(.*)/i
          commands.concat(hq.call(Regexp.last_match(1), 1))
        when /\A(?:Bà chủ|Chủ tiệm)[\s\u00A0]*:[\s\u00A0]*(.*)/i
          commands.concat(narr.call("[PLACEHOLDER FACE: CHỦ CỬA HÀNG] #{Regexp.last_match(1)}"))
        when /\A-\s*(.*)/
          if [1675, 1677, 1679, 1681].include?(block_id)
            commands.concat(narr.call("[PLACEHOLDER FACE: EDEN] #{Regexp.last_match(1)}"))
          else
            commands.concat(hq.call(Regexp.last_match(1), 1))
          end
        else
          commands.concat(hq.call(text, text.include?("!") ? 3 : 1))
        end
      end
      commands
    end

    system_path = "Data/System.rvdata2"
    system = load_data(system_path)
    switches = system.instance_variable_get(:@switches)
    variables = system.instance_variable_get(:@variables)
    {active_sw => "LEO_SHOP_ACTIVE", free_sw => "LEO_SHOP_FREE_EXPLORE",
     continue_sw => "LEO_SHOP_PARTY_CONTINUE", done_sw => "LEO_SHOP_DONE"}.each do |id, name|
      raise "Switch #{id} already belongs to #{switches[id]}" unless switches[id].to_s.empty? || switches[id] == name
      switches[id] = name
    end
    {branch_var => "LEO_SHOP_BRANCH", stage_var => "LEO_SHOP_STAGE"}.each do |id, name|
      raise "Variable #{id} already belongs to #{variables[id]}" unless variables[id].to_s.empty? || variables[id] == name
      variables[id] = name
    end

    # Map013: replace only the authored third Leo interaction page.  The
    # transfer is forced after B1614, fully hidden by KUL.
    map13_path = "Data/Map013.rvdata2"
    map13 = load_data(map13_path)
    events13 = map13.instance_variable_get(:@events) || {}
    leo_event13 = events13.fetch(97)
    page3 = leo_event13.instance_variable_get(:@pages).find do |page|
      c = page.instance_variable_get(:@condition)
      c.instance_variable_get(:@variable_valid) && c.instance_variable_get(:@variable_id) == 2 && c.instance_variable_get(:@variable_value) == 2
    end
    raise "Map013 Leo third interaction missing" unless page3
    list3 = page3.instance_variable_get(:@list)
    if list3.any? { |command| command_code(command) == 201 && command_parameters(command)[1] == 56 }
      entry = list3
    else
      final_line = list3.index { |command| command_code(command) == 401 && command_parameters(command)[0].to_s.include?("Thôi chào ông") }
      raise "Map013 Leo final line missing" unless final_line
      header = (0..final_line).to_a.reverse.find { |index| command_code(list3[index]) == 101 }
      entry = list3[0...header].reject do |command|
        [355, 655].include?(command_code(command)) && command_parameters(command)[0].to_s.include?("map_effects")
      end
      entry.concat(hq.call("Ấy chết! Phải đi mua đồ thôi, kẻo trễ mất!!", 3))
      entry.concat(narr.call("Sau khi chào tạm biệt Leo, tôi cắm đầu chạy thẳng ra khỏi văn phòng."))
      entry.concat([
      event_command(121, 0, [active_sw, active_sw, 0]), event_command(121, 0, [free_sw, free_sw, 1]),
      event_command(121, 0, [continue_sw, continue_sw, 1]), event_command(121, 0, [done_sw, done_sw, 1]),
      event_command(122, 0, [branch_var, branch_var, 0, 0, 0]), event_command(122, 0, [stage_var, stage_var, 0, 0, 1]),
      event_command(355, 0, ["$game_switches[17]=false; $game_switches[18]=false; map_effects.clear; map_effects.active=false"]),
      event_command(355, 0, ["$game_map.shadows.set_color(0,0,0); $game_map.shadows.show; $game_map.shadows.set_opacity(255,30) # WCF_LEO_SHOP_KUL_ENTRY"]),
        event_command(230, 0, [30]), event_command(201, 0, [0, 56, 89, 23, 8, 2]), event_command(0, 0, [])
      ])
    end
    page3.instance_variable_set(:@list, entry)

    # Map056: isolated copy of the city so the route cannot disturb Map006.
    city = load_data("Data/Map006.rvdata2")
    map56 = Marshal.load(Marshal.dump(city))
    template56 = city.instance_variable_get(:@events).values.compact.first
    bus_scene = [
      event_command(355, 0, ["$game_player.transparent=false; $game_player.instance_variable_set(:@through,false); $game_player.instance_variable_set(:@move_speed,4); $game_player.moveto(89,23)"]),
      event_command(355, 0, ["$game_switches[17]=false; $game_switches[18]=false; map_effects.clear; map_effects.active=false"]),
      event_command(355, 0, ["$game_map.shadows.set_color(0,0,0); $game_map.shadows.show; $game_map.shadows.set_opacity(255) # WCF_LEO_SHOP_KUL_BUS"]),
      event_command(355, 0, ["$game_map.shadows.set_opacity(0,24)"]), event_command(230, 0, [24])
    ]
    bus_scene.concat(narr.call("Tôi vừa ngồi xuống trạm xe buýt thì tiếng chuông báo tin nhắn vang lên."))
    bus_scene.concat([event_command(118, 0, ["LEO_SHOP_CHOICE"]),
      event_command(355, 0, ["GroupChatPreset.leo_shop_choice"]), event_command(230, 0, [1]),
      event_command(355, 0, ["chat=$game_temp.group_chat_data; v=$game_temp.group_chat_result; v=chat.selected_choice_value if ![1,2,3].include?(v) && chat && chat.respond_to?(:selected_choice_value); $game_variables[55]=v if [1,2,3].include?(v) # WCF_LEO_SHOP_SYNC_CHOICE"]),
      event_command(355, 0, ["$game_map.shadows.set_opacity(255,24) # WCF_LEO_SHOP_KUL_BUS_EXIT"]), event_command(230, 0, [24]),
      event_command(111, 0, [1, branch_var, 0, 1, 0]), event_command(201, 1, [0, 58, 14, 16, 8, 2]),
      event_command(411, 0, []), event_command(111, 1, [1, branch_var, 0, 2, 0]), event_command(201, 2, [0, 59, 15, 22, 8, 2]),
      event_command(411, 1, []), event_command(111, 2, [1, branch_var, 0, 3, 0]), event_command(201, 3, [0, 57, 10, 15, 8, 2]),
      event_command(411, 2, []), event_command(119, 3, ["LEO_SHOP_CHOICE"]),
      event_command(412, 2, []), event_command(412, 1, []), event_command(412, 0, [])])
    map56.instance_variable_set(:@display_name, "Trạm xe buýt — Tin nhắn Leo")
    map56.instance_variable_set(:@note, "[lighting on]\r\n[opacity 255]\r\n[color 000000000]\r\nLeo shop route staging; KUL only")
    map56.instance_variable_set(:@events, {1 => event_from_pages(template56, 1, "SCN-LEO-SHOP-BUS-CHOICE", 0, 0,
      [page_from_template(template56, bus_scene, trigger: 3, priority: 0, switch_id: active_sw)])})

    room_source = load_data("Data/Map049.rvdata2")
    room_template = room_source.instance_variable_get(:@events).fetch(1)
    make_shop = lambda do |id, width, height, parallax, top_name, title, branch|
      map = Marshal.load(Marshal.dump(room_source))
      map.instance_variable_set(:@width, width); map.instance_variable_set(:@height, height)
      map.instance_variable_set(:@data, blank_table(width, height, 4))
      map.instance_variable_set(:@parallax_name, parallax); map.instance_variable_set(:@parallax_show, true)
      map.instance_variable_set(:@display_name, title)
      map.instance_variable_set(:@note, "[lighting on]\r\n[opacity 255]\r\n[color 000000000]\r\n<full lock parallax>\r\n<tile lock parallax>\r\nLeo shop branch #{branch}; KUL only")
      [map, [event_command(355, 0, ["$game_player.transparent=false; $game_player.instance_variable_set(:@through,false); $game_player.instance_variable_set(:@move_speed,4)"]),
        event_command(355, 0, ["layer(#{id},0,[\"#{top_name}\",0,0,255,200,0,0,0])"]), event_command(655, 0, ["refresh_layers"]),
        event_command(355, 0, ["$game_switches[17]=false; $game_switches[18]=false; map_effects.clear; map_effects.active=false"]),
        event_command(355, 0, ["$game_map.shadows.set_color(0,0,0); $game_map.shadows.show; $game_map.shadows.set_opacity(255) # WCF_LEO_SHOP_KUL_SHOP"]),
        event_command(355, 0, ["$game_map.shadows.set_opacity(#{branch == 3 ? 70 : 0},28)"]), event_command(230, 0, [28])]]
    end

    map57, magic = make_shop.call(57, 21, 20, "Magic_Store_Base", "Magic_Store_Top", "Cửa tiệm dụng cụ ma pháp", 3)
    magic.unshift(event_command(355, 0, ["$game_variables[55]=3 # WCF_LEO_SHOP_CANONICAL_BRANCH"]))
    magic.concat(source_messages.call(1667, 1685))
    magic.concat(narr.call("[PLACEHOLDER FACE: EDEN — CHỦ TIỆM MA PHÁP]"))
    magic.concat(picture.call(43, narr.call("Chủ tiệm gói chiếc áo choàng cẩn thận rồi đưa nó cho tôi.")))
    magic.concat([event_command(122, 0, [stage_var, stage_var, 0, 0, 2]),
      event_command(355, 0, ["$game_map.shadows.set_opacity(255,28) # WCF_LEO_SHOP_KUL_MAGIC_EXIT"]), event_command(230, 0, [28]),
      event_command(201, 0, [0, 60, 7, 5, 2, 2])])
    magic_page = page_from_template(room_template, magic, trigger: 3, priority: 0, switch_id: active_sw)
    owner_page = page_from_template(room_template, [], trigger: 0, priority: 1)
    set_graphic.call(owner_page, "$VapeEden", 2, 0)
    owner_page.instance_variable_set(:@direction_fix, true)
    route = RPG::MoveRoute.allocate; route.instance_variable_set(:@repeat, true); route.instance_variable_set(:@skippable, true); route.instance_variable_set(:@wait, false)
    moves = [[45,["@pattern=0"]],[15,[60]],[45,["@pattern=1"]],[15,[60]],[45,["@pattern=2"]],[15,[60]],[0,[]]].map do |code, params|
      move = RPG::MoveCommand.allocate; move.instance_variable_set(:@code, code); move.instance_variable_set(:@parameters, params); move
    end
    route.instance_variable_set(:@list, moves); owner_page.instance_variable_set(:@move_type, 3); owner_page.instance_variable_set(:@move_route, route)
    map57.instance_variable_set(:@events, {
      1 => event_from_pages(room_template, 1, "SCN-LEO-SHOP-MAGIC", 0, 0, [magic_page]),
      2 => event_from_pages(room_template, 2, "NPC-EDEN-MAGIC-SHOP", 14, 11, [owner_page])
    })

    map58, cafe = make_shop.call(58, 23, 19, "Isekai_Caffe_Base", "Isekai_Caffe_Top", "Cửa hàng cà phê Luminous", 1)
    cafe.unshift(event_command(355, 0, ["$game_variables[55]=1 # WCF_LEO_SHOP_CANONICAL_BRANCH"]))
    cafe.concat(source_messages.call(1687, 1692))
    cafe.concat(narr.call("[PLACEHOLDER FACE: CHỦ TIỆM CÀ PHÊ]"))
    cafe.concat(aira.call("Nè con nhãi kia, ta cũng muốn uống!", 3)); cafe.concat(hq.call("Rồi rồi! Tui sẽ mua thêm vài gói! Mua tặng cả nhà luôn!", 3))
    cafe.concat(aira.call("Phải thế chứ!", 0)); cafe.concat(aira.call("Thôi, dù rằng bà ấy là Quỷ cà phê nhưng Cà phê Atlantis nặng đô lắm. Cho bà ấy uống lỡ gặp chuyện gì thì sao?"))
    cafe.concat(hq.call("Ừ ha.")); cafe.concat(picture.call(51, narr.call("Tôi dòm lên kệ trước mặt, với tay lấy thêm vài túi cà phê thượng hạng mạ vàng.")))
    cafe.concat([event_command(122, 0, [stage_var, stage_var, 0, 0, 2]), event_command(355, 0, ["$game_map.shadows.set_opacity(255,28) # WCF_LEO_SHOP_KUL_CAFE_EXIT"]),
      event_command(230, 0, [28]), event_command(201, 0, [0, 60, 7, 5, 2, 2])])
    cafe_owner = page_from_template(room_template, [], trigger: 0, priority: 1)
    map58.instance_variable_set(:@events, {1 => event_from_pages(room_template, 1, "SCN-LEO-SHOP-CAFE", 0, 0,
      [page_from_template(room_template, cafe, trigger: 3, priority: 0, switch_id: active_sw)]),
      2 => event_from_pages(room_template, 2, "ANCHOR-CAFE-OWNER-PLACEHOLDER", 17, 9, [cafe_owner])})

    map59, weapon = make_shop.call(59, 21, 28, "Cuahangvukhi_bas3", "Cuahangvukhi_top", "Cửa hàng vũ khí", 2)
    weapon.unshift(event_command(355, 0, ["$game_variables[55]=2 # WCF_LEO_SHOP_CANONICAL_BRANCH"]))
    weapon.concat(hq.call(registry.fetch("B1687"), 1))
    weapon.concat(source_messages.call(1695, 1744))
    weapon.concat(picture.call(54, narr.call("Tôi mua được viên đá đen to đùng để làm quà cho Shylvie. Một vết nứt bắt đầu lan trên bề mặt đá.")))
    weapon.concat([event_command(122, 0, [stage_var, stage_var, 0, 0, 2]), event_command(355, 0, ["$game_map.shadows.set_opacity(255,28) # WCF_LEO_SHOP_KUL_WEAPON_EXIT"]),
      event_command(230, 0, [28]), event_command(201, 0, [0, 60, 7, 5, 2, 2])])
    erufu_page = page_from_template(room_template, [], trigger: 0, priority: 1); set_graphic.call(erufu_page, "$Erufu_withbag", 2)
    traveller_page = page_from_template(room_template, [], trigger: 0, priority: 1); set_graphic.call(traveller_page, "$traveller_sprite", 2)
    map59.instance_variable_set(:@events, {
      1 => event_from_pages(room_template, 1, "SCN-LEO-SHOP-WEAPON", 0, 0,
        [page_from_template(room_template, weapon, trigger: 3, priority: 0, switch_id: active_sw)]),
      2 => event_from_pages(room_template, 2, "ANCHOR-WEAPON-OWNER-PLACEHOLDER", 10, 8, [page_from_template(room_template, [], trigger: 0, priority: 1)]),
      3 => event_from_pages(room_template, 3, "NPC-ERUFU", 10, 16, [erufu_page]),
      4 => event_from_pages(room_template, 4, "NPC-TRAVELLER", 11, 16, [traveller_page])
    })

    # Map060: branch-specific anxiety, then the established KUL-only wake and
    # outfit sequence.  The sprite is changed only after CG14.
    map60 = Marshal.load(Marshal.dump(room_source))
    map60.instance_variable_set(:@display_name, "Phòng Hải Quỳ — Quà theo gợi ý Leo")
    map60.instance_variable_set(:@note, "[lighting on]\r\n[opacity 255]\r\n[color 000000000]\r\n<full lock parallax>\r\n<tile lock parallax>\r\nLeo shop preparation; KUL only")
    prep = [event_command(355, 0, ["$game_player.transparent=true"]),
      event_command(355, 0, ["layer(60,0,[\"HQ_Room_Midnight_Top\",0,0,255,200,0,0,0])"]), event_command(655, 0, ["refresh_layers"]),
      event_command(355, 0, ["$game_switches[17]=false; $game_switches[18]=false; map_effects.clear; map_effects.active=false"]),
      event_command(355, 0, ["$game_map.shadows.set_color(0,0,0); $game_map.shadows.show; $game_map.shadows.set_opacity(255) # WCF_LEO_SHOP_KUL_PREP"]),
      event_command(355, 0, ["$game_map.events[3].give_light('cutscene_actor'); $game_map.events[3].set_graphic('$HaiQuyAtHome_Base',0)"]),
      event_command(355, 0, ["$game_map.shadows.set_opacity(185,24)"]), event_command(230, 0, [24]),
      event_command(111, 0, [1, branch_var, 0, 3, 0])]
    prep.concat(hq.call("Tôi đặt gói quà của Hakase lên bàn, lấy đồng hồ báo thức đè lên nó. Mặc dù còn vài ngày nữa mới tới buổi tiệc giáng sinh nhưng không biết vì sao tôi cứ có cảm giác bữa tiệc sẽ diễn ra vào ngày mai.", 1, 1))
    prep.concat(hq.call("Tôi tò mò, tự tưởng tượng ra hàng tá trò vặt vãnh mà Hakase có thể làm với áo choàng tàng hình. Càng tưởng tượng, tâm trí tôi càng được xoa dịu.", 0, 1))
    prep << event_command(411, 0, []); prep << event_command(111, 1, [1, branch_var, 0, 1, 0])
    prep.concat(hq.call("Tôi chỉnh lại nơ trên chiếc túi giấy đựng cà phê. Khi nghĩ đến việc Kohi sẽ thích thú với túi cà phê, cảm giác lo lắng trong tôi tan biến đi một chút.", 0, 2))
    prep << event_command(411, 1, [])
    prep.concat(hq.call("Vài ngày nữa là tới buổi tiệc mà tôi vẫn chưa đẽo được cục đá này. Đá gì đâu mà cứng chết đi được!", 3, 2))
    prep.concat(hq.call("Chả lẽ tặng nguyên cục đá này cho Shylvie hả ta?", 3, 2)); prep.concat(hq.call("Tui cảm thấy hơi bất an một chút…", 3, 2))
    prep.concat(aira.call("Ngươi cứ lo lắng dư thừa. Shylvie vốn là một đứa thích đá mà, nhiễu sự ghê.", 1, 2))
    prep.concat(hq.call("Nhớ…buộc nơ…vô cục đá nha…Aira…", 5, 2)); prep << event_command(412, 1, []); prep << event_command(412, 0, [])
    prep.concat([event_command(355, 0, ["$game_map.shadows.set_opacity(255,24)"]), event_command(230, 0, [24]),
      event_command(355, 0, ["$game_map.events[3].set_graphic('$HaiQuy_Sleep_Night',0)"]), event_command(230, 0, [60]),
      event_command(355, 0, ["$game_map.shadows.set_opacity(185,24)"]), event_command(230, 0, [24])])
    source_prep = room_source.instance_variable_get(:@events).fetch(1).instance_variable_get(:@pages).first.instance_variable_get(:@list)
    wake_at = source_prep.index { |command| [355, 655].include?(command_code(command)) && command_parameters(command)[0].to_s.include?("WCFGalleryScene.show(28)") }
    wake = clone_commands.call(source_prep[wake_at..-1])
    wake.each do |command|
      params = command_parameters(command)
      if command_code(command) == 122 && params[0] == 52 then params[0] = params[1] = stage_var end
      if [355, 655].include?(command_code(command))
        params[0] = params[0].to_s.gsub("layer(49,", "layer(60,").gsub("WCF_ATL_BOOK", "WCF_LEO_SHOP")
      end
    end
    prep.concat(wake)
    template60 = room_source.instance_variable_get(:@events).fetch(1)
    map60.instance_variable_set(:@events, {1 => event_from_pages(template60, 1, "SCN-LEO-SHOP-PREP", 0, 0,
      [page_from_template(template60, prep, trigger: 3, priority: 0, switch_id: active_sw)]), 3 => room_source.instance_variable_get(:@events).fetch(3)})

    # Shared Christmas office: clone the stable early-arrival/free-roam shell,
    # remapping only route state. Existing pages and manual map edits remain.
    map38_path = "Data/Map038.rvdata2"
    map38 = load_data(map38_path); events38 = map38.instance_variable_get(:@events) || {}
    intro_event = events38.fetch(1); leo_event = events38.fetch(5)
    raise "Map038 E121 occupied" if events38[121] && !events38[121].instance_variable_get(:@name).to_s.start_with?("SCN-LEO-SHOP")
    remap = lambda do |commands|
      result = clone_commands.call(commands)
      result.each do |command|
        params = command_parameters(command)
        if command_code(command) == 121
          mapping = {47 => continue_sw, 48 => free_sw}
          params[0] = params[1] = mapping[params[0]] if mapping[params[0]]
        elsif command_code(command) == 122 && params[0] == 44
          params[0] = params[1] = stage_var
        end
      end
      result.reject { |command| [221,222,223].include?(command_code(command)) || ([355,655].include?(command_code(command)) && command_parameters(command)[0].to_s.match?(/start_tone_change|map_effects\.(?:set_tone|set_color)/)) }
    end
    source_intro = intro_event.instance_variable_get(:@pages).first
    source_free = leo_event.instance_variable_get(:@pages).find { |page| c=page.instance_variable_get(:@condition); c.instance_variable_get(:@switch1_valid) && c.instance_variable_get(:@switch1_id) == 48 }
    raise "Map038 shared free-roam shell missing" unless source_free
    leo_intro = remap.call(source_intro.instance_variable_get(:@list))
    layer_refresh = leo_intro.index { |command| [355,655].include?(command_code(command)) && command_parameters(command)[0].to_s.include?("refresh_layers") }
    raise "Map038 Leo top-layer refresh missing" unless layer_refresh
    leo_intro.insert(layer_refresh + 1,
      event_command(355, 0, ["$game_switches[17]=false; $game_switches[18]=false; map_effects.clear; map_effects.active=false"]),
      event_command(355, 0, ["$game_map.shadows.set_color(0,0,0); $game_map.shadows.show; $game_map.shadows.set_opacity(255) # WCF_LEO_SHOP_KUL_OFFICE_BLACK"]),
      event_command(355, 0, ["$game_map.shadows.set_opacity(0,30) # WCF_LEO_SHOP_KUL_OFFICE_REVEAL"]),
      event_command(230, 0, [30]))
    free_switch = leo_intro.index { |command| command_code(command) == 121 && command_parameters(command)[0] == free_sw && command_parameters(command)[2] == 0 }
    raise "Map038 Leo free-roam switch missing" unless free_switch
    leo_intro.insert(free_switch,
      event_command(355, 0, ["$game_map.shadows.set_opacity(0,30) # WCF_LEO_SHOP_KUL_FREE_REVEAL"]),
      event_command(230, 0, [30]))
    intro_pages = intro_event.instance_variable_get(:@pages)
    intro_pages.reject! { |page| c=page.instance_variable_get(:@condition); c.instance_variable_get(:@switch1_valid) && [active_sw,free_sw,continue_sw].include?(c.instance_variable_get(:@switch1_id)) }
    intro_pages << page_from_template(intro_event, leo_intro, trigger: 3, priority: 0, switch_id: active_sw)
    intro_pages << page_from_template(intro_event, [], trigger: 0, priority: 0, switch_id: free_sw)
    intro_pages << page_from_template(intro_event, [], trigger: 0, priority: 0, switch_id: continue_sw)
    leo_pages = leo_event.instance_variable_get(:@pages)
    leo_pages.reject! { |page| c=page.instance_variable_get(:@condition); c.instance_variable_get(:@switch1_valid) && c.instance_variable_get(:@switch1_id) == free_sw }
    leo_pages << page_from_template(leo_event, remap.call(source_free.instance_variable_get(:@list)), trigger: 0, priority: 1, switch_id: free_sw)

    party = [event_command(355, 0, ["$game_map.shadows.set_color(0,0,0); $game_map.shadows.show; $game_map.shadows.set_opacity(255,20) # WCF_LEO_SHOP_KUL_PARTY"]),
      event_command(230, 0, [20]), event_command(355, 0, ["hq=$game_map.events[2]; hq.moveto($game_player.x,$game_player.y); hq.transparent=false; $game_player.transparent=true"])]
    party.concat(narr.call(registry.fetch("B0317")))
    party.concat(narr.call(registry.fetch("B0318")))
    party.concat(narr.call(registry.fetch("B0319")))
    party.concat(leo.call("E hèm! Tui nghĩ đã đến lúc cho sự kiện chính ngày hôm nay rồi, Quỳ nhỉ?", 0))
    party.concat(narr.call("Leo đá mắt sang tôi."))
    party.concat([event_command(111, 0, [1, branch_var, 0, 3, 0])])
    party.concat(hqx.call("Giáng sinh vui vẻ Hakase! Anh thử choàng nó lên người đi!", 0, 1))
    party.concat(picture.call(43, narr.call("Hakase khoác áo rồi từ từ truyền ma lực. Cơ thể của anh ấy bắt đầu biến mất.")))
    party.concat(hakase.call("Ui, Leo ơi, Hải Quỳ ơi, tớ dùng được phép thuật tàng hình rồi nè!! Đỉnh thiệt chứ!!", 0, 1))
    party.concat(leo.call("Ừ, áo choàng tàng hình mà lại! Mà bà tài thật đó Quỳ, kiếm được đồ cổ luôn.", 0, 1))
    party.concat(hakase.call("Cảm ơn Hải Quỳ nha! Tớ thích món này lắm!!", 0, 1))
    party << event_command(411, 0, []); party << event_command(111, 1, [1, branch_var, 0, 1, 0])
    party.concat(hqx.call("Giáng sinh vui vẻ Kohi!", 0, 2)); party.concat(picture.call(51, kohi.call("BỘT CÀ PHÊ NGON NHẤT LUMINOUS SAO!? UI!! THÍCH THẾ!!", 0, 2)))
    party.concat(kohi.call("Cảm ơn bà nha Quỳ!", 0, 2)); party.concat(shy.call("K-Không thể nào!", 3, 2))
    party.concat(hqx.call("À…Thế thì Shylvie thua cược rồi.", 0, 2)); party << event_command(411, 1, [])
    party.concat(hqx.call("Giáng sinh an lành Shi-ru-vi! Tui hi vọng ông thích cục đá…phong thủy này!", 0, 2))
    party.concat(shy.call("WOW! Đá phong thủy gì mà to vậy!", 3, 2)); party.concat(narr.call("Shylvie vừa nói dứt lời, cục đá nứt toác rồi nổ tung. Một chiếc khiên hiện ra, lớp vỏ rỉ sét tróc thành từng mảng rơi xuống sàn.", 2))
    party.concat(picture.call(65, narr.call("Chiếc khiên tỏa ra ánh sáng rực rỡ, hớp hồn tất cả mọi người trong văn phòng.", 2)))
    party.concat(picture.call(32, leo.call("Ôi vãi…?! Nó là chiếc khiên huyền thoại ở chiều không gian của tôi mà!?", 3, 2)))
    party.concat(shy.call("GÌ CƠ?? CHIẾC KHIÊN HUYỀN THOẠI Ở CHIỀU KHÔNG GIAN CỦA LEO Á??", 3, 2)); party << event_command(412, 1, []); party << event_command(412, 0, [])
    party.concat(narr.call(registry.fetch("B0505")))
    party.concat(narr.call("[PLACEHOLDER CG: ĐIỆN THOẠI HẢI QUỲ — ALPHA C-61]"))
    blocks.call(507, 514).each { |text| party.concat(narr.call(text)) }
    party.concat(narr.call(registry.fetch("B0515"))); party.concat(narr.call(registry.fetch("B0516")))
    party << event_command(111, 0, [1, branch_var, 0, 3, 0])
    party.concat(leo.call("Quỳ! Quỳ!! Bà sao vậy?", 3, 1)); party.concat(hqx.call("A….Tui đang tò mò là ông sẽ tặng quà gì cho tui đó!", 0, 1))
    party.concat(leo.call("Trời! Khỏi phải đoán! Quà đây!!", 0, 1))
    party.concat(picture.call(68, narr.call("Leo đặt trước mặt tôi một túi quà khổng lồ. Bên trong là một chiếc thú bông Knuckles tỷ lệ 1:1.", 1)))
    party.concat(hqx.call("Tui luôn muốn có một con!! Cảm ơn ông nha Leo!! Thích quá xá!!", 0, 1))
    party << event_command(411, 0, []); party << event_command(111, 1, [1, branch_var, 0, 1, 0])
    party.concat(shy.call("Quỳ! Quỳ!! Bà sao vậy?", 3, 2)); party.concat(hqx.call("A….Tui đang tò mò là bà sẽ tặng quà gì cho tui đó!", 0, 2))
    party.concat(shy.call("Trời? Nay biết tò mò luôn? Tui còn tưởng là bà đã đoán ra được rồi cơ.", 1, 2))
    party.concat(picture.call(78, narr.call("Shylvie lôi từ túi không gian một chiếc gấu bông Tails màu vàng hai đuôi.", 2)))
    party.concat(hqx.call("LÀ TAILS?! UI!! DỄ THƯƠNG QUÁ XÁ!!", 0, 2)); party.concat(shy.call("Tui biết thừa là bà thích mấy nhân vật bé trai mà, thừa nhận đi.", 0, 2))
    party << event_command(411, 1, [])
    party.concat(hakase.call("Quỳ! Quỳ!! Cậu sao vậy?", 3, 2)); party.concat(hqx.call("A….Tớ đang tò mò là cậu sẽ tặng quà gì cho tớ đó!", 0, 2))
    party.concat(hakase.call("Vậy hả! Vậy cậu đoán xem!!", 0, 2)); party.concat(hqx.call("Để tớ đoán nhé…Là gấu bông Sonic hả?", 0, 2))
    party.concat(hakase.call("Sai rồi! Là một chiếc gậy phép thuật!!", 0, 2))
    party.concat(picture.call(58, narr.call("Hakase đập tay một cái, một chiếc gậy phép có cánh chuồn chuồn đính ngọc đỏ rơi xuống tay tôi.", 2)))
    party.concat(hqx.call("Gậy phép thuật!! Nhìn quen lắm! Phải chăng Hakase làm cây gậy này dựa trên tiểu thuyết tớ viết?", 0, 2))
    party.concat(hakase.call("Đúng vậy!! Mà nó không phải là đồ chơi đâu, nó là gậy phép thật đấy!", 0, 2))
    party.concat(narr.call("Tôi quơ nhẹ một cái. Một vụ nổ xảy ra, đủ mạnh thổi bay tôi đập vào cửa chính. May mà Aira dùng xúc tu đỡ hộ.", 2))
    party.concat(hqx.call("Ui da….Là hàng thật này!", 0, 2)); party.concat(hakase.call("Thấy chưa! Tớ nói rồi mà cậu không tin!!", 0, 2))
    party << event_command(412, 1, []); party << event_command(412, 0, [])
    party.concat(narr.call("Trong lúc mọi người đang dọn dẹp bàn tiệc, tôi phụ trách chuẩn bị bắp rang ngũ vị, một thùng đá lạnh để ướp các loại nước ngọt và kem. Điện thoại của tôi rung không ngưng nghỉ trên bàn bếp."))
    party.concat(hqx.call("Xin lỗi mọi người—", 3)); party.concat(leo.call("Bà cứ đi đi, không sao hết.", 0)); party.concat(shy.call("Nhớ về sớm đấy nhé!", 0))
    party.concat(hakase.call("Không là mọi người ăn hết kem đó!!", 0)); party.concat(kohi.call("Đi cẩn thận nhé!!", 0)); party.concat(hqx.call("Ừa! Tui đi đây!! Nhớ chừa kem cho tui đó!!", 0))
    party.concat([event_command(121, 0, [active_sw, active_sw, 1]), event_command(121, 0, [free_sw, free_sw, 1]),
      event_command(121, 0, [continue_sw, continue_sw, 1]), event_command(121, 0, [done_sw, done_sw, 0]),
      event_command(122, 0, [stage_var, stage_var, 0, 0, 6]),
      event_command(111, 0, [1, branch_var, 0, 1, 0]), event_command(122, 1, [41,41,0,0,22]), event_command(411,0,[]),
      event_command(111,1,[1,branch_var,0,2,0]), event_command(122,2,[41,41,0,0,23]), event_command(411,1,[]), event_command(122,2,[41,41,0,0,24]), event_command(412,1,[]), event_command(412,0,[]),
      event_command(355, 0, ["$game_map.shadows.set_opacity(255,30) # WCF_LEO_SHOP_KUL_END"]), event_command(230,0,[30]), event_command(201,0,[0,36,8,7,8,2])])
    events38[121] = event_from_pages(events38.fetch(7), 121, "SCN-LEO-SHOP-PARTY-CONTINUE", 0, 0,
      [page_from_template(events38.fetch(7), party, trigger: 3, priority: 0, switch_id: continue_sw)])

    # Ending hints 22..24. Drosalya remains an explicit production placeholder.
    map36_path = "Data/Map036.rvdata2"; map36 = load_data(map36_path); router = map36.instance_variable_get(:@events).fetch(1)
    pages36 = router.instance_variable_get(:@pages)
    [22,23,24].each do |hint_id|
      pages36.reject! { |page| c=page.instance_variable_get(:@condition); c.instance_variable_get(:@variable_valid) && c.instance_variable_get(:@variable_id) == 41 && c.instance_variable_get(:@variable_value) == hint_id }
      hint = [event_command(355,0,["$game_player.transparent=true; $game_player.moveto(8,7)"]), event_command(355,0,["$game_switches[17]=false; $game_switches[18]=false; map_effects.clear; map_effects.active=false"]),
        event_command(355,0,["$game_map.shadows.set_color(0,0,0); $game_map.shadows.show; $game_map.shadows.set_opacity(255) # WCF_LEO_SHOP_KUL_HINT"]), event_command(355,0,["$game_map.events[2].give_light('cutscene_actor')"]),
        event_command(355,0,["$game_map.shadows.set_opacity(185,24)"]), event_command(230,0,[24])]
      if hint_id == 22
        ["Ái chà chà, cà phê Luminous sao!!", "Cà phê Luminous thì ngon không bàn cãi!", "Cũng coi như là Best Ending rồi ha!"].each { |text| hint.concat(aira.call(text)) }
      elsif hint_id == 23
        ["Một cục đá chùi đít ngẫu nhiên nào đó cũng có thể biến thành khiên…", "GÌ KỲ VẬY TRỜI?", "Ta không chấp nhận đây là Best Ending!!", "Đi tìm Ending khác mau!!"].each { |text| hint.concat(aira.call(text, text.include?("!") ? 3 : 1)) }
      else
        hint.concat(narr.call("[PLACEHOLDER SPRITE/FACE: DROSALYA]"))
        ["Ôi, cháu gái yêu quý của ta!", "…", "Gương mặt đó là sao thế?", "Cháu quên ta rồi sao?", "Là bà ngoại yêu dấu, Drosalya của cháu đây!", "Cháu quên cũng phải thôi", "Ta đã lặn mất tăm mà không nói lời nào mà.", "Chưa kể là cháu vẫn đang sử dụng thứ “thuốc” ấy.", "Ta ghét thứ “thuốc” đó thế không biết!", "Làm cháu quên cả gốc gác của mình!", "Nên là để ta “hint” nhẹ cho cháu gái yêu quý nè!", "Ta có để lại một món quà cho cháu ở tiệm sách cũ đó!", "Đến đó mà nhận lấy món quà đặc biệt của ta đi!!"].each { |text| hint.concat(narr.call(text)) }
      end
      hint.concat([event_command(355,0,["$game_map.shadows.set_opacity(255,24) # WCF_LEO_SHOP_KUL_HINT_END"]), event_command(230,0,[24]),
        event_command(355,0,["$game_map.events[2].drop_light"]), event_command(355,0,["HAIQUY_TITLE.clear_ending_background"]), event_command(354,0,[])])
      pages36 << page_from_template(router, hint, trigger: 3, priority: 0, variable_id: 41, variable_value: hint_id)
    end

    infos_path = "Data/MapInfos.rvdata2"; infos = load_data(infos_path)
    [[56,6,"Trạm xe buýt — Tin nhắn Leo"],[57,49,"Tiệm ma pháp — Gợi ý Leo"],[58,49,"Cà phê Luminous — Gợi ý Leo"],
     [59,49,"Cửa hàng vũ khí — Gợi ý Leo"],[60,49,"Chuẩn bị quà — Gợi ý Leo"]].each do |id, source_id, name|
      raise "MapInfo #{id} belongs to #{infos[id].instance_variable_get(:@name)}" if infos[id] && infos[id].instance_variable_get(:@name) != name
      info = infos[id] || Marshal.load(Marshal.dump(infos.fetch(source_id)))
      info.instance_variable_set(:@name,name); info.instance_variable_set(:@parent_id,13); info.instance_variable_set(:@expanded,true)
      info.instance_variable_set(:@order, infos.values.compact.map { |entry| entry.instance_variable_get(:@order).to_i }.max + 1) unless infos[id]
      infos[id] = info
    end

    map13.instance_variable_set(:@events, events13); map38.instance_variable_set(:@events, events38)
    save_data(map13_path,map13); save_data("Data/Map056.rvdata2",map56); save_data("Data/Map057.rvdata2",map57)
    save_data("Data/Map058.rvdata2",map58); save_data("Data/Map059.rvdata2",map59); save_data("Data/Map060.rvdata2",map60)
    save_data(map38_path,map38); save_data(map36_path,map36); save_data(infos_path,infos); save_data(system_path,system)

    errors = []
    (56..60).each { |id| errors << "Map#{id} missing" unless File.file?(format("Data/Map%03d.rvdata2",id)) }
    errors << "Map013 forced transfer missing" unless page3.instance_variable_get(:@list).any? { |command| command_code(command)==201 && command_parameters(command)[1]==56 }
    errors << "VapeEden missing" unless map57.instance_variable_get(:@events)[2].instance_variable_get(:@pages).first.instance_variable_get(:@graphic).instance_variable_get(:@character_name)=="$VapeEden"
    eden_route = map57.instance_variable_get(:@events)[2].instance_variable_get(:@pages).first.instance_variable_get(:@move_route)
    eden_codes = (eden_route.instance_variable_get(:@list) || []).map { |move| move.instance_variable_get(:@code) }
    errors << "VapeEden timing route invalid" unless eden_route.instance_variable_get(:@repeat) && eden_codes == [45,15,45,15,45,15,0]
    errors << "Map038 E121 missing" unless events38[121]
    errors << "Leo choice preset call missing" unless bus_scene.any? { |command| [355,655].include?(command_code(command)) && command_parameters(command)[0].to_s.include?("leo_shop_choice") }
    [57,58,59,60].each do |id|
      lists = load_data(format("Data/Map%03d.rvdata2",id)).instance_variable_get(:@events).values.compact.flat_map { |event| event.instance_variable_get(:@pages).flat_map { |page| page.instance_variable_get(:@list) } }
      errors << "Map#{id} contains native Fade/Tint" if lists.any? { |command| [221,222,223].include?(command_code(command)) }
      errors << "Map#{id} lacks KUL" unless lists.any? { |command| [355,655].include?(command_code(command)) && command_parameters(command)[0].to_s.include?("$game_map.shadows.set_opacity") }
    end
    raise "Leo shop route audit failed: #{errors.join(', ')}" unless errors.empty?
    puts "LEO_SHOP_ROUTES|Map013>056>{57,58,59}>060>038>036>Title|branch=55|switches=72..75|hints=22..24|VapeEden=60f|errors=0"
  end

  # Four authored jewel-shop branches entered after the third Shylvie
  # interaction on Map013. Dedicated party/epilogue maps keep shared route
  # maps untouched and make this builder safe to rerun.
  def implement_shylvie_jewel_routes
    active_sw, free_sw, continue_sw, done_sw = 76, 77, 78, 79
    branch_var, stage_var = 57, 58
    say = lambda do |face, index, text, indent = 0|
      result = wrapped_message_commands([text], tag: "\\cbm ", width: 30, indent: indent)
      result.each do |command|
        next unless command_code(command) == 101
        command.instance_variable_set(:@parameters, [face, face.empty? ? 0 : index, 0, 2])
      end
      result
    end
    narr = lambda { |text, indent = 0| say.call("", 0, text, indent) }
    hq = lambda { |text, index = 1, indent = 0| say.call("HaiQuy_Thuongphuc_Emote", index, text, indent) }
    hqx = lambda { |text, index = 1, indent = 0| say.call("HaiQuy_Giangsinh_Emote", index, text, indent) }
    aira = lambda { |text, index = 1, indent = 0| say.call("BullyQuy_Thuongphuc_Emote", index, text, indent) }
    shy = lambda { |text, index = 1, indent = 0| say.call("CV_Giangsinh_Emote1", index, text, indent) }
    leo = lambda { |text, index = 1, indent = 0| say.call("Leo_Giangsinh_Emote", index, text, indent) }
    kohi = lambda { |text, index = 1, indent = 0| say.call("Kohi_Giangsinh_Emote1", index, text, indent) }
    hakase = lambda { |text, index = 1, indent = 0| say.call("Hakase_Giangsinh_Emote", index, text, indent) }
    show_picture = lambda do |name, commands, indent = 0|
      [event_command(231, indent, [20, name, 1, 0, 320, 240, 100, 100, 255, 0])] + commands +
        [event_command(235, indent, [20])]
    end
    setup = lambda do |map_id, top_name, marker|
      [event_command(355, 0, ["$game_player.transparent=true"]),
       event_command(355, 0, ["layer(#{map_id},0,[\"#{top_name}\",0,0,255,200,0,0,0])"]),
       event_command(655, 0, ["refresh_layers"]),
       event_command(355, 0, ["$game_switches[17]=false; $game_switches[18]=false; map_effects.clear; map_effects.active=false"]),
       event_command(355, 0, ["$game_map.shadows.set_color(0,0,0); $game_map.shadows.show; $game_map.shadows.set_opacity(255) # #{marker}"]),
       event_command(355, 0, ["$game_map.shadows.set_opacity(0,24)"]), event_command(230, 0, [24])]
    end
    finish_transfer = lambda do |map_id, x, y, marker|
      [event_command(355, 0, ["$game_map.shadows.set_opacity(255,24) # #{marker}"]),
       event_command(230, 0, [24]), event_command(201, 0, [0, map_id, x, y, 2, 2])]
    end

    system_path = "Data/System.rvdata2"
    system = load_data(system_path)
    switches = system.instance_variable_get(:@switches)
    variables = system.instance_variable_get(:@variables)
    {active_sw => "SHY_JEWEL_ACTIVE", free_sw => "SHY_JEWEL_FREE_EXPLORE",
     continue_sw => "SHY_JEWEL_PARTY_CONTINUE", done_sw => "SHY_JEWEL_DONE"}.each do |id, name|
      raise "Switch #{id} already belongs to #{switches[id]}" unless switches[id].to_s.empty? || switches[id] == name
      switches[id] = name
    end
    {branch_var => "SHY_JEWEL_BRANCH", stage_var => "SHY_JEWEL_STAGE"}.each do |id, name|
      raise "Variable #{id} already belongs to #{variables[id]}" unless variables[id].to_s.empty? || variables[id] == name
      variables[id] = name
    end

    # Replace only the closing beat of Shylvie's third interaction.
    map13_path = "Data/Map013.rvdata2"
    map13 = load_data(map13_path)
    event98 = map13.instance_variable_get(:@events).fetch(98)
    page3 = event98.instance_variable_get(:@pages).find do |page|
      c = page.instance_variable_get(:@condition)
      c.instance_variable_get(:@variable_valid) && c.instance_variable_get(:@variable_id) == 3 && c.instance_variable_get(:@variable_value) == 2
    end
    raise "Map013 Shylvie third interaction missing" unless page3
    entry = page3.instance_variable_get(:@list)
    unless entry.any? { |command| [355,655].include?(command_code(command)) && command_parameters(command)[0].to_s.include?("WCF_SHY_JEWEL_ENTRY") }
      final_line = entry.index { |command| command_code(command) == 401 && command_parameters(command)[0].to_s.include?("Thôi chào") }
      raise "Map013 Shylvie closing line missing" unless final_line
      header = (0..final_line).to_a.reverse.find { |index| command_code(entry[index]) == 101 }
      entry = entry[0...header]
      entry.concat(narr.call("Sau khi chào tạm biệt Shylvie, tôi cắm đầu chạy thẳng ra khỏi văn phòng."))
      entry.concat([event_command(121,0,[active_sw,active_sw,0]), event_command(121,0,[free_sw,free_sw,1]),
        event_command(121,0,[continue_sw,continue_sw,1]), event_command(121,0,[done_sw,done_sw,1]),
        event_command(122,0,[branch_var,branch_var,0,0,0]), event_command(122,0,[stage_var,stage_var,0,0,1]),
        event_command(355,0,["$game_switches[17]=false; $game_switches[18]=false; map_effects.clear; map_effects.active=false"]),
        event_command(355,0,["$game_map.shadows.set_color(0,0,0); $game_map.shadows.show; $game_map.shadows.set_opacity(255,24) # WCF_SHY_JEWEL_ENTRY"]),
        event_command(230,0,[24]), event_command(201,0,[0,64,9,23,2,2]), event_command(0,0,[])])
      page3.instance_variable_set(:@list, entry)
    end

    room = load_data("Data/Map049.rvdata2")
    template = room.instance_variable_get(:@events).fetch(1)

    # Map064: one jewel shop, four explicit recipient choices.
    map64 = Marshal.load(Marshal.dump(room))
    map64.instance_variable_set(:@width,18); map64.instance_variable_set(:@height,28)
    map64.instance_variable_set(:@data,blank_table(18,28,4))
    map64.instance_variable_set(:@parallax_name,"Jewel_Shop_Base"); map64.instance_variable_set(:@parallax_show,true)
    map64.instance_variable_set(:@display_name,"Cửa tiệm đá phong thủy")
    map64.instance_variable_set(:@note,"[lighting on]\r\n[opacity 255]\r\n[color 000000000]\r\n<full lock parallax>\r\n<tile lock parallax>\r\nShylvie jewel route; KUL only")
    shop = setup.call(64,"Jewel_Shop_Top","WCF_SHY_JEWEL_SHOP")
    shop.concat(shy.call("Hải Quỳ, bà có muốn tạt ngang qua cửa tiệm bán đá phong thủy không?", 1))
    shop.concat(hq.call("Shylvie nhiệt tình giới thiệu quá nên chắc là có."))
    shop.concat(shy.call("Để tui gửi tọa độ cho.")); shop.concat(hq.call("Ừ, gửi tọa độ lẹ lên!"))
    shop.concat(narr.call("Shylvie ngay lập tức gửi tôi tọa độ chính xác của cửa tiệm, cùng một chiếc vòng tay có gắn la bàn và một túi châu báu to đùng."))
    shop.concat(hq.call("Trời đất thánh thần Poseidon ơi…Chói quá…!!! Lại còn tràn đầy ma lực nữa chứ!!",3))
    shop.concat(narr.call("Tôi dạo một vòng quanh tiệm, ngắm hết kệ Ruby, Sapphire, Emerald cho tới Topaz, Tourmaline và Amber."))
    shop << event_command(102,0,[["Shylvie","Kohi","Leo","Hakase"],0])
    choices = [
      [0,"Shylvie",3,"CongoTourmaline", "Tôi nhìn qua kệ Tourmaline và chọn Congo Tourmaline. Viên đá có khả năng triệu hồi một chiếc khiên phép thuật mạnh mẽ."],
      [1,"Kohi",2,"DiamondCoffee", "Tôi nhìn qua kệ Kim Cương và chọn viên kim cương hình hạt cà phê cho Kohi."],
      [2,"Leo",1,"PurpleGarnet", "Tôi nhìn qua kệ Garnet và chọn Purple Garnet. Nó có khả năng giải trừ trạng thái bất lợi, độc tố và giúp tinh thần vui vẻ hơn."],
      [3,"Hakase",4,"RainbowFluorite", "Tôi nhìn qua kệ Fluorite và chọn Rainbow Fluorite, viên đá trí tuệ có thể truyền đạt phép thuật cho người sử dụng."]
    ]
    choices.each do |choice_index, label, branch, image_name, description|
      shop << event_command(402,0,[choice_index,label])
      shop << event_command(122,1,[branch_var,branch_var,0,0,branch])
      shop.concat(show_picture.call(image_name,narr.call(description,1),1))
      case branch
      when 1
        shop.concat(aira.call("Ồ, là Purple Garnet này.",1,1)); shop.concat(hq.call("Cũng rành về đá quý dữ ha?",1,1))
      when 2
        shop.concat(aira.call("NÈ CON NHÃI KIA, GIÀU DỮ HA, MUA HẲN KIM CƯƠNG LUÔN MÀ!",3,1)); shop.concat(hq.call("Nhưng nó có hình hạt cà phê.",1,1))
      when 3
        shop.concat(aira.call("Congo Tourmaline cơ à? Ta tưởng ngươi sẽ mua viên đá màu xanh dương chứ?",1,1)); shop.concat(hq.call("Giờ xu hướng phải tặng màu xa lánh!",1,1))
      when 4
        shop.concat(aira.call("Ngươi tính tặng Rainbow Fluorite cho tên ma vương đáng gờm đó à?",1,1)); shop.concat(hq.call("Chà, đáng để Hakase thử nhỉ?",1,1))
      end
      shop << event_command(122,1,[stage_var,stage_var,0,0,2])
      shop.concat(finish_transfer.call(65,7,5,"WCF_SHY_JEWEL_SHOP_EXIT").each { |command| command.instance_variable_set(:@indent,1) })
    end
    shop << event_command(404,0,[])
    map64.instance_variable_set(:@events,{1=>event_from_pages(template,1,"SCN-SHY-JEWEL-SHOP",0,0,[page_from_template(template,shop,trigger:3,priority:0,switch_id:active_sw)])})

    # Map065: branch-specific wrapping beat.
    map65 = Marshal.load(Marshal.dump(room)); map65.instance_variable_set(:@display_name,"Phòng Hải Quỳ — Chuẩn bị đá phong thủy")
    map65.instance_variable_set(:@note,"[lighting on]\r\n[opacity 255]\r\n[color 000000000]\r\n<full lock parallax>\r\n<tile lock parallax>\r\nShylvie jewel preparation; KUL only")
    prep = setup.call(65,"HQ_Room_Midnight_Top","WCF_SHY_JEWEL_PREP")
    [[1,"PurpleGarnet","Tôi đặt gói quà của Leo lên bàn, lấy đồng hồ báo thức đè lên nó."],
     [2,"DiamondCoffee","Tôi đặt gói quà của Kohi lên bàn, lấy đồng hồ báo thức đè lên nó."],
     [3,"CongoTourmaline","Tôi đặt gói quà của Shylvie lên bàn, lấy đồng hồ báo thức đè lên nó."],
     [4,"RainbowFluorite","Tôi đặt gói quà của Hakase lên bàn, lấy đồng hồ báo thức đè lên nó."]].each do |branch,image_name,text|
      prep << event_command(111,0,[1,branch_var,0,branch,0]); prep.concat(show_picture.call(image_name,narr.call(text,1),1)); prep << event_command(412,0,[])
    end
    prep.concat(narr.call("Mặc dù còn vài ngày nữa mới tới buổi tiệc giáng sinh, tôi cứ có cảm giác bữa tiệc sẽ diễn ra vào ngày mai."))
    prep << event_command(122,0,[stage_var,stage_var,0,0,3]); prep.concat(finish_transfer.call(66,8,7,"WCF_SHY_JEWEL_PREP_EXIT"))
    map65.instance_variable_set(:@events,{1=>event_from_pages(template,1,"SCN-SHY-JEWEL-PREP",0,0,[page_from_template(template,prep,trigger:3,priority:0,switch_id:active_sw)])})

    # Map066: dedicated Christmas-office copy; only route narration runs.
    map66 = Marshal.load(Marshal.dump(load_data("Data/Map038.rvdata2")))
    map66.instance_variable_set(:@display_name,"Wanderer Office — Tiệc đá phong thủy")
    map66.instance_variable_set(:@note,"[lighting on]\r\n[opacity 255]\r\n[color 000000000]\r\n<full lock parallax>\r\n<tile lock parallax>\r\nShylvie jewel party; KUL only")
    party_template = map66.instance_variable_get(:@events).fetch(1)
    party = setup.call(66,"Map_Wanderer_Office_GiangSinh_Top","WCF_SHY_JEWEL_PARTY")
    party.concat(narr.call("E hèm! Đã đến lúc cho sự kiện chính ngày hôm nay rồi."))
    {1=>"JEWEL_PARTY_LEO",2=>"JEWEL_PARTY_KOHI",3=>"JEWEL_PARTY_SHY",4=>"JEWEL_PARTY_HAK"}.each do |branch,label|
      party << event_command(111,0,[1,branch_var,0,branch,0]); party << event_command(119,1,[label]); party << event_command(412,0,[])
    end
    party << event_command(118,0,["JEWEL_PARTY_LEO"])
    party.concat(hqx.call("Giáng sinh an lành Leo! Tui hi vọng ông thích viên đá này!")); party.concat(show_picture.call("PurpleGarnet",leo.call("Uầy!! Purple Garnet à? Lựa chọn không tồi đấy Quỳ!",0)))
    party.concat(hqx.call("Trời trời tui mà lị!! Quá là tâm lý!!")); party.concat(narr.call("Dù rằng việc tôi mua viên đá này hoàn toàn là ngẫu nhiên. Chắc chắn không phải cố tình chọn cho giống màu ai đấy.")); party << event_command(119,0,["JEWEL_PARTY_DONE"])
    party << event_command(118,0,["JEWEL_PARTY_KOHI"])
    party.concat(show_picture.call("DiamondCoffee",kohi.call("TR-TRỜI ĐẤT ƠI?! HẠT CÀ PHÊ KIM CƯƠNG!",3))); party.concat(hqx.call("Đúng rồi! Hạt cà phê kim cương!")); party.concat(kohi.call("Cảm ơn Hải Quỳ nha…!!",0)); party << event_command(119,0,["JEWEL_PARTY_DONE"])
    party << event_command(118,0,["JEWEL_PARTY_SHY"])
    party.concat(hqx.call("Giáng sinh an lành Shi-ru-vi! Tui hi vọng ông thích viên đá phong thủy này!")); party.concat(show_picture.call("CongoTourmaline",shy.call("WOW! Congo Tourmaline!!",3)))
    party.concat(shy.call("Bà lại còn tặng đúng viên mà tui muốn nữa chứ!",0)); party.concat(narr.call("Viên đá phát sáng rực rỡ. Một chiếc khiên màu xanh lá dứa trong suốt hiện ra.")); party.concat(shy.call("NÓ LÀ MÓN QUÀ TUYỆT CÀ LÀ VỜI QUỲ Ạ! ĐỈNH CỦA CHÓP!",3)); party << event_command(119,0,["JEWEL_PARTY_DONE"])
    party << event_command(118,0,["JEWEL_PARTY_HAK"])
    party.concat(hqx.call("Đá phong thủy đó Hakase! Đây là Rainbow Fluorite, đá tri thức đó!")); party.concat(show_picture.call("RainbowFluorite",narr.call("Hakase truyền ma lực vào viên đá. Một dãy ký tự dài tỏa sáng và xoay quanh anh ấy.")))
    party.concat(hakase.call("Nó là phép thuật biến nho thành táo, biến báo thành gạch, biến cá trạch thành mèo, biến beo thành chó.",0)); party.concat(shy.call("Giờ nó còn là một viên pin ma lực xịn xò và có thể ghi chép thông tin nữa đó!",0)); party.concat(hakase.call("Cảm ơn Hải Quỳ và Shylvie nha! Nó tuyệt vời quá đi mất!",0))
    party << event_command(118,0,["JEWEL_PARTY_DONE"]); party << event_command(122,0,[stage_var,stage_var,0,0,4]); party.concat(finish_transfer.call(67,8,7,"WCF_SHY_JEWEL_PARTY_EXIT"))
    map66.instance_variable_set(:@events,{1=>event_from_pages(party_template,1,"SCN-SHY-JEWEL-PARTY",0,0,[page_from_template(party_template,party,trigger:3,priority:0,switch_id:active_sw)])})

    # Map067: four next-morning outcomes, then exact route hints 25..28.
    map67 = Marshal.load(Marshal.dump(load_data("Data/Map039.rvdata2")))
    map67.instance_variable_set(:@display_name,"Wanderer Office — Hậu truyện đá phong thủy")
    map67.instance_variable_set(:@note,"[lighting on]\r\n[opacity 255]\r\n[color 000000000]\r\n<full lock parallax>\r\n<tile lock parallax>\r\nShylvie jewel epilogues; KUL only")
    epi_template = map67.instance_variable_get(:@events).fetch(1)
    epi = setup.call(67,"Map_Wanderer_Office_top","WCF_SHY_JEWEL_EPILOGUE")
    {1=>"JEWEL_EPI_LEO",2=>"JEWEL_EPI_KOHI",3=>"JEWEL_EPI_SHY",4=>"JEWEL_EPI_HAK"}.each do |branch,label|
      epi << event_command(111,0,[1,branch_var,0,branch,0]); epi << event_command(119,1,[label]); epi << event_command(412,0,[])
    end
    epi << event_command(118,0,["JEWEL_EPI_LEO"]); epi.concat(leo.call("Thấy sao? Đẹp chứ!",0)); epi.concat(narr.call("Leo đặt lên bàn chiếc chuông gió làm từ những mảnh Purple Garnet đã vỡ. Tiếng leng keng trong trẻo, êm tai.")); epi.concat(hq.call("Ừ! Leo khéo tay thật đó!!",0)); epi << event_command(122,0,[41,41,0,0,25]); epi << event_command(119,0,["JEWEL_EPI_DONE"])
    epi << event_command(118,0,["JEWEL_EPI_KOHI"]); epi.concat(kohi.call("Từ tối qua đến giờ, tui cứ ngủ được 30 phút là gặp ác mộng một lần…",5)); epi.concat(narr.call("Shylvie nhận ra viên kim cương có phép thanh trừng Quỷ. Tôi bóp nát nó, rồi Shylvie dùng phép tái cấu trúc ghép lại.")); epi.concat(hq.call("Bảo sao tôi cảm thấy mệt mệt. Thôi, xuống múc kem ăn thôi!")); epi << event_command(122,0,[41,41,0,0,26]); epi << event_command(119,0,["JEWEL_EPI_DONE"])
    epi << event_command(118,0,["JEWEL_EPI_SHY"]); epi.concat(shy.call("Bà về rồi hả!! Nhìn nè, xịn không!!",0)); epi.concat(narr.call("Chiếc khiên làm hũ kem biến mất, rồi nhân ra hàng chục chiếc hũ cùng kích cỡ.")); epi.concat(hq.call("Chiếc khiên gì xịn đét.")); epi.concat(narr.call("Nhưng tất cả những chiếc hũ đều rỗng không.")); epi.concat(hq.call("Chiếc khiên gì tệ đét.")); epi << event_command(122,0,[41,41,0,0,27]); epi << event_command(119,0,["JEWEL_EPI_DONE"])
    epi << event_command(118,0,["JEWEL_EPI_HAK"]); epi.concat(hakase.call("Mừng Hải Quỳ về nhà, làm miếng cà phê kem socola không?",0)); epi.concat(hakase.call("Viên đá tuyệt vời lắm! Tui đã biến hết nho trong tủ thành táo!",0)); epi.concat(hakase.call("Nếu tặng đá phong thủy cho Leo hay Kohi thì nên cẩn thận. Nó còn có tác dụng xua đuổi ma quỷ đó.",0)); epi.concat(narr.call("Sau đó tôi đứng xem Hakase biến một cục gạch thành chuột lang, thành báo hoa mai, thành khúc gỗ rồi thành quả cam.")); epi.concat(hq.call("Tôi có nên ăn quả cam đó không…?")); epi << event_command(122,0,[41,41,0,0,28])
    epi << event_command(118,0,["JEWEL_EPI_DONE"]); epi.concat([event_command(121,0,[active_sw,active_sw,1]),event_command(121,0,[done_sw,done_sw,0]),event_command(122,0,[stage_var,stage_var,0,0,5])]); epi.concat(finish_transfer.call(36,8,7,"WCF_SHY_JEWEL_EPILOGUE_EXIT"))
    map67.instance_variable_set(:@events,{1=>event_from_pages(epi_template,1,"SCN-SHY-JEWEL-EPILOGUE",0,0,[page_from_template(epi_template,epi,trigger:3,priority:0,switch_id:active_sw)])})

    map36_path = "Data/Map036.rvdata2"; map36 = load_data(map36_path); router = map36.instance_variable_get(:@events).fetch(1)
    hints = {
      25=>["May cho ngươi nhé.","Leo dù là ma cà rồng nhưng đang tại chức Vệ Thần Không Gian.","Nên viên đá phong thủy không thể thanh trừng hắn, thậm chí còn bị Leo hút ngược sức mạnh."],
      26=>["Ngươi đầu óc đơn giản thật đó.","Vì nó có hình hạt cà phê mà ngươi ngay lập tức mua, không mảy may nghĩ về công dụng của đá phong thủy.","Thà rằng ngươi tặng cà phê hay máy pha cà phê đi."],
      27=>["Đến cả một viên ngọc cũng có thể biến thành một chiếc khiên…","Đừng nói đến cả một cục đá ven đường cũng thế nhé?","Èo, chán quá, tặng cho nó món khác đi."],
      28=>["Ai mà ngờ một viên đá phong thủy lại có thể lưu trữ phép thuật.","Giống cuốn sách phép ghê ha!","Nhưng nghe ta nói này: Ma vương phải có áo choàng!","Ta nhớ Leo biết chỗ bán áo choàng hay lắm. Đi hỏi hắn thử xem."]
    }
    pages36 = router.instance_variable_get(:@pages)
    hints.each do |hint_id, lines|
      pages36.reject! { |page| c=page.instance_variable_get(:@condition); c.instance_variable_get(:@variable_valid) && c.instance_variable_get(:@variable_id)==41 && c.instance_variable_get(:@variable_value)==hint_id }
      commands = [event_command(355,0,["$game_player.transparent=true"]),
        event_command(355,0,["$game_map.shadows.set_color(0,0,0); $game_map.shadows.show; $game_map.shadows.set_opacity(185) # WCF_SHY_JEWEL_HINT"])]
      lines.each { |text| commands.concat(aira.call(text,text.include?("!") ? 3 : 1)) }
      commands.concat([event_command(355,0,["$game_map.shadows.set_opacity(255,24)"]),event_command(230,0,[24]),event_command(355,0,["HAIQUY_TITLE.clear_ending_background"]),event_command(354,0,[])])
      pages36 << page_from_template(router,commands,trigger:3,priority:0,variable_id:41,variable_value:hint_id)
    end

    infos_path = "Data/MapInfos.rvdata2"; infos = load_data(infos_path)
    [[64,49,"Tiệm đá phong thủy — Gợi ý Shylvie"],[65,49,"Chuẩn bị quà — Gợi ý Shylvie"],[66,38,"Tiệc đá phong thủy — Gợi ý Shylvie"],[67,39,"Hậu truyện đá phong thủy — Gợi ý Shylvie"]].each do |id,source_id,name|
      raise "MapInfo #{id} belongs to #{infos[id].instance_variable_get(:@name)}" if infos[id] && infos[id].instance_variable_get(:@name)!=name
      info = infos[id] || Marshal.load(Marshal.dump(infos.fetch(source_id))); info.instance_variable_set(:@name,name); info.instance_variable_set(:@parent_id,13); info.instance_variable_set(:@expanded,true)
      info.instance_variable_set(:@order,infos.values.compact.map{|entry| entry.instance_variable_get(:@order).to_i}.max+1) unless infos[id]; infos[id]=info
    end

    save_data(map13_path,map13); save_data("Data/Map064.rvdata2",map64); save_data("Data/Map065.rvdata2",map65)
    save_data("Data/Map066.rvdata2",map66); save_data("Data/Map067.rvdata2",map67); save_data(map36_path,map36); save_data(infos_path,infos); save_data(system_path,system)
    errors=[]; (64..67).each{|id| errors << "Map#{id} missing" unless File.file?(format("Data/Map%03d.rvdata2",id))}
    errors << "Map013 jewel transfer missing" unless page3.instance_variable_get(:@list).any?{|command| command_code(command)==201 && command_parameters(command)[1]==64}
    errors << "Jewel choices missing" unless shop.count{|command| command_code(command)==402}==4
    errors << "Jewel hints missing" unless (25..28).all?{|id| pages36.any?{|page| c=page.instance_variable_get(:@condition); c.instance_variable_get(:@variable_valid) && c.instance_variable_get(:@variable_id)==41 && c.instance_variable_get(:@variable_value)==id}}
    raise "Shylvie jewel route audit failed: #{errors.join(', ')}" unless errors.empty?
    puts "SHY_JEWEL_ROUTES|Map013>064>065>066>067>036>Title|branch=57|switches=76..79|hints=25..28|errors=0"
  end

  # Repair only the branch invariant of the already-authored Leo shop maps.
  # This intentionally does not rebuild any map, so editor/manual positioning
  # and event changes remain untouched.
  def repair_leo_shop_branch_state
    branch_var = 55

    map56_path = "Data/Map056.rvdata2"
    map56 = load_data(map56_path)
    choice_list = map56.instance_variable_get(:@events).fetch(1)
      .instance_variable_get(:@pages).first.instance_variable_get(:@list)
    choice_call = choice_list.index do |command|
      [355, 655].include?(command_code(command)) &&
        command_parameters(command)[0].to_s.include?("GroupChatPreset.leo_shop_choice")
    end
    raise "Map056 Leo choice call missing" unless choice_call
    choice_label = "LEO_SHOP_CHOICE"
    unless choice_list.any? { |command| command_code(command) == 118 && command_parameters(command)[0] == choice_label }
      choice_list.insert(choice_call, event_command(118, 0, [choice_label]))
      choice_call += 1
    end
    sync_marker = "WCF_LEO_SHOP_SYNC_CHOICE"
    sync = choice_list.find { |command| [355, 655].include?(command_code(command)) && command_parameters(command)[0].to_s.include?(sync_marker) }
    sync_script = "chat=$game_temp.group_chat_data; v=$game_temp.group_chat_result; v=chat.selected_choice_value if ![1,2,3].include?(v) && chat && chat.respond_to?(:selected_choice_value); $game_variables[55]=v if [1,2,3].include?(v) # #{sync_marker}"
    if sync
      sync.instance_variable_set(:@parameters, [sync_script])
    else
      insert_at = choice_call + 1
      insert_at += 1 if command_code(choice_list[insert_at]) == 230
      choice_list.insert(insert_at, event_command(355, 0, [sync_script]))
    end

    # Route only explicit values. Invalid state retries the phone choice and is
    # never silently interpreted as branch 3.
    branch_pair = choice_list.each_with_index.find do |command, index|
      index > choice_call && command_code(command) == 111 && command_parameters(command)[0, 2] == [1, branch_var]
    end
    branch_start = branch_pair && branch_pair[1]
    raise "Map056 branch start missing" unless branch_start
    branch_end = (branch_start...choice_list.length).select do |index|
      command_code(choice_list[index]) == 412
    end.last
    unless branch_end
      # Some existing editor saves omit structural Branch End commands at the
      # tail. The route block is the final block, immediately before code 0.
      branch_end = choice_list.length - 1
      branch_end -= 1 if command_code(choice_list[branch_end]) == 0
    end
    routing = [
      event_command(111, 0, [1, branch_var, 0, 1, 0]), event_command(201, 1, [0, 58, 14, 16, 8, 2]),
      event_command(411, 0, []), event_command(111, 1, [1, branch_var, 0, 2, 0]), event_command(201, 2, [0, 59, 15, 22, 8, 2]),
      event_command(411, 1, []), event_command(111, 2, [1, branch_var, 0, 3, 0]), event_command(201, 3, [0, 57, 6, 8, 8, 2]),
      event_command(411, 2, []), event_command(119, 3, [choice_label]),
      event_command(412, 2, []), event_command(412, 1, []), event_command(412, 0, [])
    ]
    choice_list[branch_start..branch_end] = routing
    save_data(map56_path, map56)

    {57 => 3, 58 => 1, 59 => 2}.each do |map_id, branch|
      path = "Data/Map%03d.rvdata2" % map_id
      map = load_data(path)
      event = map.instance_variable_get(:@events).fetch(1)
      page = event.instance_variable_get(:@pages).first
      condition = page.instance_variable_get(:@condition)
      # The destination map already uniquely identifies the selected branch.
      # A variable page condition can only deadlock its autorun, so keep just
      # the route-active switch and canonicalize Variable 55 inside the list.
      condition.instance_variable_set(:@variable_valid, false)
      list = page.instance_variable_get(:@list)
      marker = "WCF_LEO_SHOP_CANONICAL_BRANCH"
      unless list.any? { |command| [355, 655].include?(command_code(command)) && command_parameters(command)[0].to_s.include?(marker) }
        list.unshift(event_command(355, 0,
          ["$game_variables[#{branch_var}]=#{branch} # #{marker}"]))
      end
      save_data(path, map)
    end

    errors = []
    verify56 = load_data(map56_path).instance_variable_get(:@events).fetch(1)
      .instance_variable_get(:@pages).first.instance_variable_get(:@list)
    branch_values = verify56.select do |command|
      command_code(command) == 111 && command_parameters(command)[0, 2] == [1, branch_var]
    end.map { |command| command_parameters(command)[3] }
    transfer_maps = verify56.select { |command| command_code(command) == 201 }
      .map { |command| command_parameters(command)[1] }
    errors << "Map056 explicit branch conditions invalid" unless branch_values == [1, 2, 3]
    errors << "Map056 branch transfers invalid" unless transfer_maps == [58, 59, 57]
    errors << "Map056 invalid-state retry missing" unless verify56.any? { |command| command_code(command) == 119 && command_parameters(command)[0] == choice_label }
    {57 => 3, 58 => 1, 59 => 2}.each do |map_id, branch|
      map = load_data("Data/Map%03d.rvdata2" % map_id)
      page = map.instance_variable_get(:@events).fetch(1)
        .instance_variable_get(:@pages).first
      condition = page.instance_variable_get(:@condition)
      errors << "Map#{map_id} variable page condition remains" if condition.instance_variable_get(:@variable_valid)
      first = page.instance_variable_get(:@list).first
      script = command_parameters(first)[0].to_s
      errors << "Map#{map_id} canonical branch missing" unless command_code(first) == 355 && script.include?("[55]=#{branch}")
    end
    raise errors.join("; ") unless errors.empty?
    puts "LEO_SHOP_BRANCH_REPAIRED|Map057=3|Map058=1|Map059=2|page_variable_conditions=removed|manual_map_edits=preserved"
  end

  # Restore visibility at the Map060 -> Map038 hand-off and before the Leo
  # route enters free roam. Only KUL opacity is used for lighting transitions.
  def repair_leo_shop_map38_kul_reveal
    path = "Data/Map038.rvdata2"
    map = load_data(path)
    event = map.instance_variable_get(:@events).fetch(1)
    page = event.instance_variable_get(:@pages).find do |candidate|
      condition = candidate.instance_variable_get(:@condition)
      condition.instance_variable_get(:@switch1_valid) &&
        condition.instance_variable_get(:@switch1_id) == 72
    end
    raise "Map038 Leo intro page missing" unless page
    list = page.instance_variable_get(:@list)

    # Strip only legacy lighting commands from this route-owned page. Camera
    # common events and manually-authored dialogue remain intact.
    list.reject! do |command|
      [221, 222, 223].include?(command_code(command)) ||
        ([355, 655].include?(command_code(command)) &&
          command_parameters(command)[0].to_s.match?(/start_tone_change|map_effects\.(?:set_tone|set_color)/))
    end

    arrival_marker = "WCF_LEO_SHOP_KUL_OFFICE_REVEAL"
    unless list.any? { |command| [355, 655].include?(command_code(command)) && command_parameters(command)[0].to_s.include?(arrival_marker) }
      layer_refresh = list.index do |command|
        [355, 655].include?(command_code(command)) &&
          command_parameters(command)[0].to_s.include?("refresh_layers")
      end
      raise "Map038 Leo top-layer refresh missing" unless layer_refresh
      list.insert(layer_refresh + 1,
        event_command(355, 0, ["$game_switches[17]=false; $game_switches[18]=false; map_effects.clear; map_effects.active=false"]),
        event_command(355, 0, ["$game_map.shadows.set_color(0,0,0); $game_map.shadows.show; $game_map.shadows.set_opacity(255) # WCF_LEO_SHOP_KUL_OFFICE_BLACK"]),
        event_command(355, 0, ["$game_map.shadows.set_opacity(0,30) # #{arrival_marker}"]),
        event_command(230, 0, [30]))
    end

    free_marker = "WCF_LEO_SHOP_KUL_FREE_REVEAL"
    unless list.any? { |command| [355, 655].include?(command_code(command)) && command_parameters(command)[0].to_s.include?(free_marker) }
      free_switch = list.index do |command|
        command_code(command) == 121 && command_parameters(command)[0] == 73 &&
          command_parameters(command)[2] == 0
      end
      raise "Map038 Leo free-roam switch missing" unless free_switch
      list.insert(free_switch,
        event_command(355, 0, ["$game_map.shadows.set_opacity(0,30) # #{free_marker}"]),
        event_command(230, 0, [30]))
    end
    save_data(path, map)

    verify = load_data(path).instance_variable_get(:@events).fetch(1)
      .instance_variable_get(:@pages).find do |candidate|
        condition = candidate.instance_variable_get(:@condition)
        condition.instance_variable_get(:@switch1_valid) && condition.instance_variable_get(:@switch1_id) == 72
      end.instance_variable_get(:@list)
    scripts = verify.select { |command| [355, 655].include?(command_code(command)) }
      .map { |command| command_parameters(command)[0].to_s }.join("\n")
    raise "Map038 KUL reveal markers missing" unless scripts.include?(arrival_marker) && scripts.include?(free_marker)
    raise "Map038 native fade/tint remains" if verify.any? { |command| [221, 222, 223].include?(command_code(command)) }
    puts "LEO_SHOP_MAP038_KUL_REPAIRED|arrival=255>0/30|free_roam=0/30|native_fade_tint=0|manual_edits=preserved"
  end

  def inspect_system_id_range(first_id, last_id)
    system = load_data("Data/System.rvdata2")
    switches = system.instance_variable_get(:@switches)
    variables = system.instance_variable_get(:@variables)
    (first_id..last_id).each do |id|
      puts "SYSTEM_ID|#{id}|switch=#{switches[id].inspect}|variable=#{variables[id].inspect}"
    end
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
when "configure-map021-house-parallax"
  RVData2Audit.configure_map021_house_parallax
when "create-map022-house"
  RVData2Audit.create_map022_house_parallax
when "add-map022-house-events"
  RVData2Audit.add_map022_house_events
when "fix-map022-main-trigger"
  RVData2Audit.fix_map022_main_trigger
when "add-map022-pop-dialogue-camera"
  RVData2Audit.add_map022_pop_dialogue_camera
when "create-atlantis-route-maps"
  RVData2Audit.create_atlantis_route_maps
when "connect-map022-atlantis"
  RVData2Audit.connect_map022_to_atlantis_shop
when "fix-atlantis-switch-values"
  RVData2Audit.fix_atlantis_switch_values
when "fix-atlantis-scene-triggers-camera"
  RVData2Audit.fix_atlantis_scene_triggers_camera
when "make-map022-exploration-gate"
  RVData2Audit.make_map022_exploration_gate
when "rebuild-map022-interactions"
  RVData2Audit.rebuild_map022_interactions_from_docx
when "correct-map022-source-scope"
  RVData2Audit.correct_map022_source_scope
when "reflow-map022-messages"
  RVData2Audit.reflow_map022_messages
when "rebuild-map022-provided-house"
  RVData2Audit.rebuild_map022_from_provided_house_text
when "split-map022-message-boxes"
  RVData2Audit.split_map022_message_boxes
when "fix-map022-scene-layer"
  RVData2Audit.fix_map022_scene_and_layer
when "restore-map022-arrival-dialogue"
  RVData2Audit.restore_map022_arrival_dialogue
when "dump-actor-graphics"
  RVData2Audit.dump_actor_graphics
when "dump-tilesets"
  RVData2Audit.dump_tilesets
when "dump-map-tiles"
  RVData2Audit.dump_map_tiles(Integer(ARGV.fetch(0)))
when "rebuild-map022-exact-script"
  RVData2Audit.rebuild_map022_exact_script
when "complete-map022-house"
  RVData2Audit.complete_map022_house_sequence
when "create-map026-storage"
  RVData2Audit.create_map026_storage_room
when "correct-map023-shop-arrival"
  RVData2Audit.correct_map023_shop_arrival
when "complete-map023-old-book-shop"
  RVData2Audit.complete_map023_old_book_shop
when "rebuild-map024-memory-intro"
  RVData2Audit.rebuild_map024_memory_intro
when "name-atlantis-flags"
  RVData2Audit.name_atlantis_flags
when "audit-map-state"
  RVData2Audit.audit_map_state
when "replace-script"
  RVData2Audit.replace_runtime_script(ARGV.fetch(0), ARGV.fetch(1))
when "insert-script"
  RVData2Audit.insert_runtime_script(ARGV.fetch(0), ARGV.fetch(1), ARGV[2] || "Main")
when "prepare-map027-demo"
  RVData2Audit.prepare_map027_demo_events
when "create-atlantis-mirror-chase"
  RVData2Audit.create_atlantis_mirror_and_chase_maps
when "remove-khas-awesome-light-effects"
  RVData2Audit.remove_khas_awesome_light_effects
when "fix-atlantis-chase-exit-map"
  RVData2Audit.fix_atlantis_chase_exit_map
when "implement-atlantis-post-chase-scene"
  RVData2Audit.implement_atlantis_post_chase_scene
when "create-atlantis-clone-encirclement-map"
  RVData2Audit.create_atlantis_clone_encirclement_map
when "rebuild-atlantis-vertical-clone-chase"
  RVData2Audit.rebuild_atlantis_vertical_clone_chase
when "fix-atlantis-chase-downward"
  RVData2Audit.fix_atlantis_chase_downward
when "polish-atlantis-chase-staging"
  RVData2Audit.polish_atlantis_chase_staging
when "rebuild-atlantis-paulie-drop"
  RVData2Audit.rebuild_atlantis_paulie_drop
when "fix-atlantis-paulie-transition"
  RVData2Audit.fix_atlantis_paulie_transition
when "stage-atlantis-clone-ambush"
  RVData2Audit.stage_atlantis_clone_ambush
when "expand-atlantis-chase-clones"
  RVData2Audit.expand_atlantis_chase_clones
when "fix-atlantis-clone-chase-lighting-transition"
  RVData2Audit.fix_atlantis_clone_chase_lighting_transition
when "polish-atlantis-post-chase-confrontation"
  RVData2Audit.polish_atlantis_post_chase_confrontation
when "use-player-in-atlantis-bedroom-epilogue"
  RVData2Audit.use_player_in_atlantis_bedroom_epilogue
when "fix-map035-chat-handoff-and-teleport"
  RVData2Audit.fix_map035_chat_handoff_and_teleport
when "apply-atlantis-route-balloons"
  RVData2Audit.apply_atlantis_route_balloons
when "create-atlantis-chase-epilogue"
  RVData2Audit.create_atlantis_chase_epilogue
when "create-supermarket-route-slice"
  RVData2Audit.create_supermarket_route_slice
when "repair-supermarket-item-route-state"
  RVData2Audit.repair_supermarket_item_route_state
when "audit-repeated-route-state"
  RVData2Audit.audit_repeated_route_state_commands
when "integrate-picture-gallery-assets"
  RVData2Audit.integrate_picture_gallery_assets
when "normalize-picture-and-black-scene-messages"
  RVData2Audit.normalize_picture_and_black_scene_messages
when "implement-spicy-noodle-leo-route"
  RVData2Audit.implement_spicy_noodle_leo_route
when "merge-noodle-shared-christmas-office"
  RVData2Audit.merge_noodle_party_into_shared_christmas_office
when "implement-atlantis-teleport-book-shylvie-route"
  RVData2Audit.implement_atlantis_teleport_book_shylvie_route
when "implement-atlantis-ancient-book-hakase-route"
  RVData2Audit.implement_atlantis_ancient_book_hakase_route
when "implement-atlantis-owner-abyss-route"
  RVData2Audit.implement_atlantis_owner_abyss_route
when "implement-leo-shop-routes"
  RVData2Audit.implement_leo_shop_routes
when "implement-shylvie-jewel-routes"
  RVData2Audit.implement_shylvie_jewel_routes
when "repair-leo-shop-branch-state"
  RVData2Audit.repair_leo_shop_branch_state
when "repair-leo-shop-map38-kul-reveal"
  RVData2Audit.repair_leo_shop_map38_kul_reveal
when "fix-invalid-game-screen-calls"
  RVData2Audit.fix_invalid_game_screen_calls
when "inspect-system-id-range"
  RVData2Audit.inspect_system_id_range(Integer(ARGV.fetch(0)), Integer(ARGV.fetch(1)))
when "replace-storage-diaries-with-pictures"
  RVData2Audit.replace_storage_diary_text_with_pictures
when "gate-map026-interactions-behind-light"
  RVData2Audit.gate_map026_interactions_behind_light
when "polish-map026-cassette-player"
  RVData2Audit.polish_map026_cassette_player
when "install-christmas-snowball"
  RVData2Audit.install_christmas_snowball_exploration
when "name-snowball-progress"
  RVData2Audit.name_snowball_progress
when "reconcile-atlantis-v2"
  RVData2Audit.reconcile_atlantis_compact_v2
when "audit-atlantis-v2-dialogue"
  RVData2Audit.audit_atlantis_v2_dialogue
when "reconcile-supermarket-v2"
  RVData2Audit.reconcile_supermarket_christmas_v2
when "organize-route-map-tree"
  RVData2Audit.organize_route_map_tree
when "complete-coffee-route-branches"
  RVData2Audit.complete_coffee_route_branches
when "complete-supermarket-gift-routes"
  RVData2Audit.complete_remaining_supermarket_routes
when "repair-map037-prep-and-fade"
  RVData2Audit.repair_map037_prep_and_fade
when "repair-map037-sleep-transition"
  RVData2Audit.repair_map037_sleep_transition
when "create-haiquy-home-bedroom"
  RVData2Audit.create_haiquy_home_bedroom
when "create-wanderer-private-rooms"
  RVData2Audit.create_wanderer_private_rooms
when "create-wanderer-meeting-and-crafting-rooms"
  RVData2Audit.create_wanderer_meeting_and_crafting_rooms
when "audit-wanderer-private-rooms"
  RVData2Audit.audit_wanderer_private_rooms
when "fix-playable-parallax-notetags"
  RVData2Audit.fix_playable_parallax_notetags
when "apply-map022-ramen-parallax"
  RVData2Audit.apply_map022_ramen_parallax
when "fix-map023-shop-owner-anchor"
  RVData2Audit.fix_map023_shop_owner_anchor
when "apply-route-faces"
  RVData2Audit.apply_atlantis_and_coffee_route_faces
when "dump-common-events"
  RVData2Audit.dump_common_events
when "inspect-animation"
  RVData2Audit.inspect_animation(ARGV.fetch(0))
when "apply-map026-khas-lighting"
  RVData2Audit.apply_map026_khas_lighting
when "create-phone-timeline-presets"
  RVData2Audit.create_phone_timeline_presets
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
when "remove-bus-route-choice-fadeouts"
  RVData2Audit.remove_bus_route_choice_fadeouts
when "animate-supermarket-bus-departure"
  RVData2Audit.animate_supermarket_bus_departure
when "fix-supermarket-coffee-checkout"
  RVData2Audit.fix_supermarket_coffee_checkout
when "rebuild-christmas-office-black-cutscene"
  RVData2Audit.rebuild_christmas_office_black_cutscene
when "create-coffee-atlantis-template"
  RVData2Audit.create_coffee_atlantis_fishing_template
when "apply-authored-coffee-source-variants"
  RVData2Audit.apply_authored_coffee_source_variants
when "repair-coffee-route-final"
  RVData2Audit.repair_coffee_route_faces_fade_and_pictures
when "rename-camera-map013"
  RVData2Audit.rename_and_camera_map013
else
  warn "Usage: ruby tools/rvdata2_audit.rb compare-scripts|diff-script INDEX|dump-map MAP_ID|create-map-021|audit-map-state|replace-script NAME FILE|dump-common-events|create-camera-presets|rename-map003-events|fix-map017-transfer-wait|fix-map017-remove-final-player-route|fix-map017-add-three-step-exit|add-map017-camera-reset|rename-maps-006-007-017|rename-map010-events"
  exit 1
end
