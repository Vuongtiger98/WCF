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
    table = map.instance_variable_get(:@data)
    table_header = table && table.instance_variable_get(:@marshal_data)&.unpack("l<5")
    puts "MAP|#{map_id}|#{map.instance_variable_get(:@display_name)}|" \
         "#{map.instance_variable_get(:@width)}x#{map.instance_variable_get(:@height)}|" \
         "events=#{events.size}|tileset=#{map.instance_variable_get(:@tileset_id)}|" \
         "table=#{table_header ? table_header[1, 3].join('x') : 'unknown'}|" \
         "parallax=#{map.instance_variable_get(:@parallax_name)}"

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
          next unless [101, 102, 108, 117, 121, 122, 123, 201, 205, 212, 213, 214, 221, 222, 225, 230, 354, 355, 401, 402, 403, 404, 408, 655].include?(code)

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
      "Tại sao chỉ có ngươi là còn sống?", "Niềm hi vọng…",
      "Còn sống nhưng thất bại…", "Tại sao không chết đi?",
      "Mì…thịt…kho…", "Không thể chết.", "Thà chết còn hơn.",
      "Thất bại.", "Thành công.", "Thảm hại."
    ]
    clone_positions = [[9,6], [10,7], [9,8], [12,6], [12,8], [16,6],
      [16,8], [18,6], [18,8], [20,6], [20,7], [20,8]]
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
    (3..14).each do |id|
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
      event_command(355, 0, ["(3..14).each {|id| e=$game_map.events[id]; e.drop_light; e.opacity=0 }"]),
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

    puts "CREATED|Map034|clone_cutscene=true|clones=12|transfer=Map029"
    puts "UPDATED|Map029|gameplay_only=true|events=#{events29.size}"
    puts "UPDATED|Map028|transfer_only=Map029->Map034|count=#{changed}"
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

  def apply_map026_khas_lighting
    path = "Data/Map026.rvdata2"
    map = load_data(path)
    events = map.instance_variable_get(:@events) || {}
    required = [1, 2, 14, 15, 20]
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

    [14, 15].each do |event_id|
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
when "apply-atlantis-route-balloons"
  RVData2Audit.apply_atlantis_route_balloons
when "create-atlantis-chase-epilogue"
  RVData2Audit.create_atlantis_chase_epilogue
when "dump-common-events"
  RVData2Audit.dump_common_events
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
when "rename-camera-map013"
  RVData2Audit.rename_and_camera_map013
else
  warn "Usage: ruby tools/rvdata2_audit.rb compare-scripts|diff-script INDEX|dump-map MAP_ID|create-map-021|audit-map-state|replace-script NAME FILE|dump-common-events|create-camera-presets|rename-map003-events|fix-map017-transfer-wait|fix-map017-remove-final-player-route|fix-map017-add-three-step-exit|add-map017-camera-reset|rename-maps-006-007-017|rename-map010-events"
  exit 1
end
