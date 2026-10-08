# frozen_string_literal: true

# Tạo data/dialogues.js trực tiếp từ dữ liệu RPG Maker VX Ace hiện tại.
# Chạy lại file này mỗi khi thoại trong game thay đổi:
#   ruby WonderChristmas_QA_Offline_V2/WonderChristmas_QA_Offline_V2/tools/generate_dialogues.rb

require "json"
require "digest"

module RPG
  class Map; end
  class MapInfo; end
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
  class Troop; end
  class Troop::Member; end
  class Troop::Page; end
  class Troop::Page::Condition; end
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
end

class Color
  def self._load(data)
    object = allocate
    object.instance_variable_set(:@marshal_data, data)
    object
  end
end

class Tone
  def self._load(data)
    object = allocate
    object.instance_variable_set(:@marshal_data, data)
    object
  end
end

APP_ROOT = File.expand_path("..", __dir__)
PROJECT_ROOT = File.expand_path("../../..", __dir__)
DATA_ROOT = File.join(PROJECT_ROOT, "Data")
OUTPUT = File.join(APP_ROOT, "data", "dialogues.js")
POP_PATTERN = /\\bm\[(-?\d+)\]\s*/i

def load_data(path)
  Marshal.load(File.binread(path))
end

def iv(object, name, fallback = nil)
  object&.instance_variable_get("@#{name}") || fallback
end

def code(command)
  iv(command, :code, 0)
end

def parameters(command)
  iv(command, :parameters, [])
end

def speaker_from_face(face)
  return "" if face.to_s.empty?

  name = face.to_s
      .sub(/\.(png|jpg)\z/i, "")
      .sub(/_(Giangsinh|Thuongphuc|Dongphuc|Normal).*\z/i, "")
      .sub(/_Emote.*\z/i, "")
      .tr("_", " ")
  {
    "AlphaC61" => "Alpha C-61", "BetaM34" => "Beta M-34",
    "HaiQuy" => "Hải Quỳ", "Quy" => "Hải Quỳ"
  }.fetch(name, name)
end

def speaker_from_pop(target, events)
  return "Hải Quỳ" if target == 0 || target == -1

  event = events[target]
  name = iv(event, :name, "").to_s
  return "Event #{target}" if name.empty?

  name.sub(/\s*\[E\d+\].*\z/i, "").sub(/^[A-Z]+[-_]/, "").tr("_-", " ").strip
end

def extract_command_frames(list, prefix:, source_base:, events: {})
  frames = []
  index = 0
  while index < list.length
    command = list[index]
    case code(command)
    when 101
      params = parameters(command)
      lines = []
      cursor = index + 1
      while cursor < list.length && code(list[cursor]) == 401
        lines << parameters(list[cursor])[0].to_s
        cursor += 1
      end
      raw = lines.map(&:rstrip).join("\n")
      pop_match = raw.match(POP_PATTERN)
      pop_target = pop_match ? pop_match[1].to_i : nil
      text = raw.sub(POP_PATTERN, "")
      face = params[0].to_s
      face_file = face.empty? || face.match?(/\.(png|jpg)\z/i) ? face : "#{face}.png"
      frame = {
        id: format("%s-c%04d", prefix, index + 1), kind: "dialogue",
        speaker: face.empty? ? (pop_target.nil? ? "" : speaker_from_pop(pop_target, events)) : speaker_from_face(face),
        text: text, face: face_file, faceName: face, faceIndex: params[1].to_i, pop: !pop_target.nil?,
        popTarget: pop_target, background: params[2], position: params[3],
        source: "#{source_base} / Lệnh #{index + 1}"
      }
      frames << frame unless text.empty?
      index = cursor
      next
    when 102
      choices = Array(parameters(command)[0]).map(&:to_s)
      unless choices.empty?
        frames << {
          id: format("%s-choice-c%04d", prefix, index + 1), kind: "choice",
          title: "Lựa chọn xuất hiện trong game",
          text: choices.each_with_index.map { |choice, choice_index| "#{choice_index + 1}. #{choice}" }.join("\n"),
          choices: choices, source: "#{source_base} / Lệnh #{index + 1}"
        }
      end
    when 105
      lines = []
      cursor = index + 1
      while cursor < list.length && code(list[cursor]) == 405
        lines << parameters(list[cursor])[0].to_s
        cursor += 1
      end
      unless lines.empty?
        frames << {
          id: format("%s-scroll-c%04d", prefix, index + 1), kind: "scrolling",
          title: "Văn bản cuộn", text: lines.join("\n"),
          source: "#{source_base} / Lệnh #{index + 1}"
        }
      end
      index = cursor
      next
    end
    index += 1
  end
  frames
end

map_infos = load_data(File.join(DATA_ROOT, "MapInfos.rvdata2"))
items = []
by_map = Hash.new { |hash, key| hash[key] = [] }
map_message_count = 0

Dir.glob(File.join(DATA_ROOT, "Map[0-9][0-9][0-9].rvdata2")).sort.each do |path|
  map_id = File.basename(path)[/\d+/].to_i
  map = load_data(path)
  events = iv(map, :events, {})
  map_name = iv(map_infos[map_id], :name, "").to_s
  display_name = iv(map, :display_name, "").to_s
  friendly_name = [map_name, display_name].reject(&:empty?).uniq.join(" — ")
  friendly_name = "Không có tên" if friendly_name.empty?

  events.keys.compact.sort.each do |event_id|
    event = events[event_id]
    event_name = iv(event, :name, "Event #{event_id}").to_s
    Array(iv(event, :pages, [])).each_with_index do |page, page_index|
      source = format("Map%03d / Event %d %s / Trang %d", map_id, event_id, event_name, page_index + 1)
      prefix = format("m%03d-e%03d-p%02d", map_id, event_id, page_index + 1)
      frames = extract_command_frames(iv(page, :list, []), prefix: prefix, source_base: source, events: events)
      next if frames.empty?

      by_map[map_id.to_s].concat(frames)
      map_message_count += frames.count { |frame| frame[:kind] == "dialogue" }
      items << {
        id: prefix, title: "Map#{map_id} · #{event_name} · Trang #{page_index + 1}",
        group: "Map#{map_id} (#{friendly_name})", start: source,
        end: "Hết nội dung của event/page này", frames: frames,
        mapId: map_id, eventId: event_id, pageIndex: page_index + 1,
        search: "#{map_id} #{friendly_name} #{event_name}"
      }
    end
  end
end

common_events = load_data(File.join(DATA_ROOT, "CommonEvents.rvdata2"))
common_message_count = 0
Array(common_events).each_with_index do |common_event, common_id|
  next unless common_event

  name = iv(common_event, :name, "Common Event #{common_id}").to_s
  prefix = format("ce%03d", common_id)
  source = "Common Event #{common_id} #{name}"
  frames = extract_command_frames(iv(common_event, :list, []), prefix: prefix, source_base: source)
  next if frames.empty?

  common_message_count += frames.count { |frame| frame[:kind] == "dialogue" }
  items << {
    id: prefix, title: "Common Event #{common_id} · #{name}", group: "Common Event",
    start: source, end: "Hết Common Event", frames: frames, commonEventId: common_id,
    search: "common event #{common_id} #{name}"
  }
end

troops = load_data(File.join(DATA_ROOT, "Troops.rvdata2"))
troop_message_count = 0
Array(troops).each_with_index do |troop, troop_id|
  next unless troop

  name = iv(troop, :name, "Troop #{troop_id}").to_s
  Array(iv(troop, :pages, [])).each_with_index do |page, page_index|
    prefix = format("troop%03d-p%02d", troop_id, page_index + 1)
    source = "Troop #{troop_id} #{name} / Trang #{page_index + 1}"
    frames = extract_command_frames(iv(page, :list, []), prefix: prefix, source_base: source)
    next if frames.empty?

    troop_message_count += frames.count { |frame| frame[:kind] == "dialogue" }
    items << {
      id: prefix, title: "Battle Event · #{name} · Trang #{page_index + 1}",
      group: "Battle Event / Troop", start: source, end: "Hết Battle Event",
      frames: frames, troopId: troop_id, pageIndex: page_index + 1,
      search: "battle troop #{troop_id} #{name}"
    }
  end
end

# Hội thoại điện thoại là dữ liệu Ruby chứ không phải Show Text, nên lấy riêng.
group_chat_path = File.join(PROJECT_ROOT, "Scripts", "Cutscene Group Chat.rb")
group_chat_source = File.read(group_chat_path, encoding: "UTF-8")
current_method = nil
method_frames = Hash.new { |hash, key| hash[key] = [] }
actor_names = { "quy" => "Hải Quỳ", "leo" => "Leo", "shylvie" => "Shylvie", "kohi" => "Kohi", "hakase" => "Hakase" }

group_chat_source.each_line.with_index(1) do |line, line_number|
  if (method_match = line.match(/^\s*def self\.([a-zA-Z0-9_!?]+)/))
    current_method = method_match[1]
    next
  end
  next unless current_method

  method = nil
  branch = nil
  actor = nil
  literal = nil
  if (match = line.match(/chat\.add_text\(:(\w+),\s*("(?:\\.|[^"\\])*")/))
    method = "text"; actor = match[1]; literal = match[2]
  elsif (match = line.match(/chat\.add_branch_text\((\d+),\s*:(\w+),\s*("(?:\\.|[^"\\])*")/))
    method = "text"; branch = match[1].to_i; actor = match[2]; literal = match[3]
  elsif (match = line.match(/chat\.add_(?:branch_)?system\((?:(\d+),\s*)?("(?:\\.|[^"\\])*")/))
    method = "system"; branch = match[1]&.to_i; literal = match[2]
  elsif (match = line.match(/chat\.add_choice\(("(?:\\.|[^"\\])*")/))
    method = "choice"; literal = match[1]
  end
  next unless method && literal

  # Các lời thoại ở đây là string dấu ngoặc kép và tương thích JSON; JSON.parse
  # xử lý Unicode trực tiếp, không có giới hạn ASCII của String#undump.
  text = JSON.parse(literal)
  frame_number = method_frames[current_method].length + 1
  method_frames[current_method] << {
    id: format("chat-%s-%03d", current_method.tr("_", "-"), frame_number),
    kind: method == "choice" ? "choice" : "chat",
    speaker: method == "system" ? "Hệ thống" : actor_names.fetch(actor.to_s, actor.to_s),
    text: text, branch: branch, pop: false,
    source: "Scripts/Cutscene Group Chat.rb / #{current_method} / dòng #{line_number}"
  }
end

group_chat_count = 0
method_frames.each do |method_name, frames|
  next if frames.empty?

  group_chat_count += frames.length
  items << {
    id: "chat-#{method_name.tr('_', '-')}", title: "Group Chat · #{method_name}",
    group: "Điện thoại / Group Chat", start: "Cutscene Group Chat · #{method_name}",
    end: "Hết cuộc trò chuyện", frames: frames, search: "group chat phone #{method_name}"
  }
end

payload = {
  schemaVersion: 1,
  sourceDigest: Digest::SHA256.hexdigest(
    Dir.glob(File.join(DATA_ROOT, "*.rvdata2")).sort.map { |path| File.binread(path) }.join + group_chat_source.b
  ),
  stats: {
    items: items.length,
    mapMessages: map_message_count,
    commonEventMessages: common_message_count,
    troopMessages: troop_message_count,
    groupChatEntries: group_chat_count,
    totalFrames: items.sum { |item| item[:frames].length },
    mapsWithDialogue: by_map.length
  },
  items: items
}

File.write(OUTPUT, "window.WCF_DIALOGUE_DATA = #{JSON.pretty_generate(payload)};\n", encoding: "UTF-8")
puts JSON.pretty_generate(payload[:stats])
puts "Wrote #{OUTPUT}"
