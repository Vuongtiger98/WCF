# frozen_string_literal: true

# Lightweight RGSS3 stubs used to regression-test Pop Message's width
# calculation with UTF-8 Vietnamese text outside RPG Maker.
class Font
  attr_accessor :name, :size, :bold, :italic, :outline, :shadow

  def initialize
    @name = self.class.default_name
    @size = self.class.default_size
    @bold = @italic = @shadow = false
    @outline = true
  end

  def self.default_name; "Verdana"; end
  def self.default_size; 24; end
end

Size = Struct.new(:width)

module Graphics
  def self.width; 640; end
  def self.height; 480; end
end

class FakeContents
  attr_accessor :font

  def initialize
    @font = Font.new
  end

  # Deliberately make whole-string measurement narrower than the sum of glyph
  # advances. This reproduces the contract mismatch that clipped Vietnamese
  # text in RGSS3 without depending on the Windows graphics runtime.
  def text_size(text)
    glyph_sum = text.each_char.inject(0) do |sum, char|
      accent = char =~ /[À-ỹ]/ ? 3 : 0
      sum + 7 + accent + (@font.size - 24) / 4
    end
    Size.new(text.length > 1 ? glyph_sum - 18 : glyph_sum)
  end
end

class Window_Base
  attr_accessor :x, :y, :z, :width, :height, :visible, :pause, :opacity,
                :contents_opacity, :openness

  def initialize(*)
    @contents = FakeContents.new
  end

  def contents; @contents; end
  def text_size(text); contents.text_size(text); end
  def reset_font_settings
    contents.font.name = Font.default_name
    contents.font.size = Font.default_size
    contents.font.bold = false
    contents.font.italic = false
    contents.font.outline = true
    contents.font.shadow = false
  end
  def make_font_bigger; contents.font.size += 8; end
  def make_font_smaller; contents.font.size -= 8; end
  def obtain_escape_code(text); text.slice!(/^[\$\.\|\^!><\{\}\\]|^[A-Z]+/i); end
  def obtain_escape_param(text); text.slice!(/^\[\d+\]/)[/\d+/].to_i rescue 0; end

  # Alias targets required while loading the original script.
  def convert_escape_characters(text); text; end
  def draw_face(*); end
  def update_placement; end
  def process_all_text; end
  def open_and_wait; end
  def close_and_wait; end
  def update; end
  def window_width; 544; end
  def window_height; 120; end
  def standard_padding; 12; end
  def fitting_height(lines); lines * 24 + 24; end
  def create_contents; @contents = FakeContents.new; end
  def open; end
  def close; end
  def dispose; end
end

module SceneManager
  def self.scene; nil; end
end

load File.expand_path("../Scripts/Pop Message.rb", __dir__)

window = Window_Message.new
text = "Máy quét kêu “bíp” một tiếng.\nMón quà được đặt gọn vào một chiếc túi lớn."
lines = text.split("\n")
glyph_width = lambda do |line|
  advances = line.each_char.map { |char| window.text_size(char).width }
  advances.inject(0, :+) + advances.last.to_i +
    YES::POP_MESSAGE::LIMIT_SETTING[:width_guard]
end
expected = lines.map { |line| glyph_width.call(line) }.max
actual = window.cal_width_line(text)
raise "Vietnamese width mismatch: expected #{expected}, got #{actual}" unless actual == expected

escaped = "Cà phê \eI[12] Atlantis"
raise "Icon width was not included" unless window.cal_width_line(escaped) > window.cal_width_line("Cà phê Atlantis")

puts "POP_MESSAGE_WIDTH_TEST|ok|vietnamese=#{actual}|icon=true"

class ContinuingPopWindow < Window_Message
  attr_reader :resized_target

  def adjust_window_size
    @resize_called = true
  end

  def adjust_window_position(id)
    @resized_target = id if @resize_called
  end
end

continuing = ContinuingPopWindow.new
continuing.instance_variable_set(:@pop_message_id, 8)
continuing.pop_message_initialize("Máy quét kêu “bíp” một tiếng.")
raise "Continuing pop message was not resized" unless continuing.resized_target == 8

puts "POP_MESSAGE_CONTINUATION_TEST|ok|target=8|resized=true"

window.width = 640
raise "Oversized pop window was not clamped left" unless
  window.pop_message_window_x(0) == 0
raise "Oversized pop window was not clamped right" unless
  window.pop_message_window_x(640) == 0

window.width = 300
raise "Left-edge pop window escaped screen" unless
  window.pop_message_window_x(20) == 0
raise "Right-edge pop window escaped screen" unless
  window.pop_message_window_x(620) == 340

puts "POP_MESSAGE_POSITION_TEST|ok|screen=640|clamped=true"

class FakeMapEffects
  attr_accessor :x, :y, :ox, :oy, :zoom_x, :zoom_y, :angle, :mirror

  def initialize
    @x = @ox = 320
    @y = @oy = 240
    @zoom_x = @zoom_y = 1.3
    @angle = 0
    @mirror = false
  end

  def active?; true; end
end

class FakeGameMap
  attr_reader :effects

  def initialize
    @effects = FakeMapEffects.new
  end
end

$game_map = FakeGameMap.new
zoomed_anchor = window.pop_message_map_effect_point(400, 200)
raise "Map Effects zoom anchor mismatch: #{zoomed_anchor.inspect}" unless
  zoomed_anchor == [424, 188]
$game_map.effects.angle = 90
rotated_anchor = window.pop_message_map_effect_point(400, 240)
raise "Map Effects rotation anchor mismatch: #{rotated_anchor.inspect}" unless
  rotated_anchor == [320, 136]
$game_map = nil

puts "POP_MESSAGE_MAP_EFFECTS_TEST|ok|zoom=true|rotation=true"

class PopToNormalWindow < Window_Message
  attr_reader :transition_order, :placement_height

  def initialize
    super
    @transition_order = []
  end

  def reset_size
    @transition_order << :reset_size
    self.width = window_width
    self.height = window_height
  end

  def update_placement
    @transition_order << :update_placement
    @placement_height = height
    self.y = 2 * (Graphics.height - height) / 2
  end

  def create_bubble_sprite(*)
    @transition_order << :hide_bubble
  end
end

transition = PopToNormalWindow.new
transition.width = 220
transition.height = 48
transition.instance_variable_set(:@pop_message_id, 3)
transition.cancel_pop_message
raise "Normal size was not restored before placement" unless
  transition.transition_order[0, 2] == [:reset_size, :update_placement]
raise "Placement still used pop height #{transition.placement_height}" unless
  transition.placement_height == transition.window_height
raise "Normal bottom message escaped screen" unless
  transition.y + transition.height == Graphics.height

puts "POP_TO_NORMAL_PLACEMENT_TEST|ok|height=#{transition.height}|bottom=#{transition.y + transition.height}"
