# encoding: UTF-8
# Four-form transformation: animation 125 -> card selector -> animation 127.
# State is transient; unlocks belong to the current save. Variable 4 is the
# existing event contract (0 normal, 1 Riu, 2 Gamemerr, 3 Sanic, 4 Diana).
module TransformMagic
  TRIGGER_KEY = Input::Z
  CAST_ANIMATION_ID = 125
  REVEAL_ANIMATION_ID = 127
  DIANA_COMMON_EVENT_ID = 21
  BODY_COLOR = [255, 191, 155]
  FormData = Struct.new(:id, :name, :picture, :char_name, :char_idx, :value)
  FORMS = {
    :riu => FormData.new(:riu, 'Hải Quỳ Riu', 'TFCard1', '!$HaiQuyRiu', 0, 1),
    :gamemerr => FormData.new(:gamemerr, 'Gamemerr', 'TFCard2', '!$Gamemerr', 0, 2),
    :sanic => FormData.new(:sanic, 'Sanic', 'TFCard3', '!$Sanic', 0, 3),
    :diana => FormData.new(:diana, 'Diana', 'TFCard4', '!$HaiQuy_Diana', 0, 4)
  }
  class << self
    def form(id)
      id.respond_to?(:to_sym) ? FORMS[id.to_sym] : nil
    end
    def unlocked_forms
      ids = $game_system.tm_unlocked_forms ||= []
      FORMS.values.select { |entry| ids.include?(entry.id) }
    end
    def unlocked?(id)
      entry = form(id)
      entry && ($game_system.tm_unlocked_forms || []).include?(entry.id)
    end
    def unlock(id, notify = true)
      entry = form(id)
      return false unless entry
      $game_system.tm_unlocked_forms ||= []
      fresh = !unlocked?(entry.id)
      $game_system.tm_unlocked_forms << entry.id if fresh
      WCFItemLibrary.encounter_picture(entry.picture) if defined?(WCFItemLibrary)
      if fresh && notify && defined?(WCFEventNotice)
        WCFEventNotice.notify("Đã nhận thẻ biến hình: "+entry.name)
      end
      true
    end
    def reward_score(id, score, map_id)
      return false unless $game_map && $game_map.map_id == map_id
      return false if score < 1000 || unlocked?(id)
      unlock(id)
    end
    def diana_ready?
      $game_map.map_id == 38 && !$game_switches[82] &&
        $game_party.item_number($data_items[18]) >= 10
    end
    def lock(id)
      entry = form(id)
      $game_system.tm_unlocked_forms.delete(entry.id) if entry && $game_system.tm_unlocked_forms
    end
    def state
      $game_temp && $game_temp.tm_state
    end
    def phase
      state && state[:phase]
    end
    def casting?
      !!state
    end
    def smooth(value)
      t = [[value, 0.0].max, 1.0].min
      t * t * (3.0 - 2.0 * t)
    end
    def animation_duration(id)
      animation = $data_animations[id]
      return 2 unless animation
      rate = animation.name =~ /<RATE: ([+-]?\d+)>/i ? [$1.to_i, 1].max : 4
      animation.frame_max * rate + 2
    end
    def body_alpha
      return 0 unless state
      progress = state[:elapsed].to_f / [state[:total] - 2, 1].max
      case phase
      when :cast then (255 * smooth(progress / 0.42)).round
      when :reveal then (255 * (1 - smooth(progress))).round
      else 255
      end
    end
    def map_available?
      return false unless SceneManager.scene_is?(Scene_Map)
      return false if SceneManager.scene.scene_changing?
      return false if $game_message.busy? || $game_message.visible
      return false if $game_system.menu_disabled || $game_map.interpreter.running?
      return false if $game_player.transfer? || $game_player.transparent
      true
    end
    def can_open?
      map_available? && !casting? && $game_player.movable?
    end
    def clear_snapshot
      if $game_temp && $game_temp.tm_snapshot
        bitmap = $game_temp.tm_snapshot
        bitmap.dispose unless bitmap.disposed?
        $game_temp.tm_snapshot = nil
      end
    end
    def finish(scene = nil)
      return unless $game_temp
      $game_temp.tm_state = nil
      $game_temp.tm_requested_map = nil
      clear_snapshot
      scene ||= SceneManager.scene
      if scene.is_a?(Scene_Map) && scene.spriteset
        scene.spriteset.instance_variable_get(:@character_sprites).each do |sprite|
          sprite.tm_stop_animation if sprite.character.equal?($game_player)
        end
      end
      if $game_player && [CAST_ANIMATION_ID, REVEAL_ANIMATION_ID].include?($game_player.animation_id)
        $game_player.animation_id = 0
      end
    end
    def start_phase(next_phase, mode = :menu)
      id = next_phase == :cast ? CAST_ANIMATION_ID : REVEAL_ANIMATION_ID
      $game_temp.tm_state = {:phase=>next_phase, :mode=>mode, :map=>$game_map.map_id,
        :elapsed=>0, :total=>animation_duration(id)}
      pending = next_phase == :reveal && SceneManager.scene_is?(Scene_TransformMagic)
      state[:animation_pending] = pending
      $game_player.animation_id = pending ? 0 : id
    end
    def start_cast
      return false unless can_open? && !unlocked_forms.empty?
      $game_temp.tm_requested_map = nil
      clear_snapshot
      start_phase(:cast)
      true
    end
    def request_cast
      return false if unlocked_forms.empty?
      $game_temp.tm_requested_map = $game_map.map_id
      true
    end
    def start_event_cast
      finish
      start_phase(:cast, :event)
    end
    def begin_reveal
      return unless state
      start_phase(:reveal, state[:mode])
    end
    def open_menu
      start_cast
    end
    def update_map
      if !state && diana_ready? && can_open? && !$game_temp.common_event_reserved?
        $game_temp.reserve_common_event(DIANA_COMMON_EVENT_ID)
        return
      end
      unless state
        if $game_temp.tm_requested_map
          if !SceneManager.scene_is?(Scene_Map) || $game_temp.tm_requested_map != $game_map.map_id
            $game_temp.tm_requested_map = nil
          elsif can_open?
            start_cast
          end
          return
        end
        start_cast if Input.trigger?(TRIGGER_KEY)
        return
      end
      return if phase == :choose
      valid = SceneManager.scene_is?(Scene_Map) && !SceneManager.scene.scene_changing? &&
        state[:map] == $game_map.map_id && !$game_player.transfer?
      valid &&= map_available? if state[:mode] == :menu
      unless valid
        finish
        return
      end
      return if phase == :hold
      state[:elapsed] += 1
      # Freeze the final visible pose before Victor disposes its cells.
      if phase == :cast && state[:mode] == :menu && state[:elapsed] == state[:total] - 2
        clear_snapshot
        $game_temp.tm_snapshot = Graphics.snap_to_bitmap
      end
      return if state[:elapsed] < state[:total]
      if phase == :cast
        state[:phase] = state[:mode] == :menu ? :choose : :hold
        SceneManager.call(Scene_TransformMagic) if phase == :choose
      else
        finish
      end
    end
    def apply(id)
      entry = form(id)
      actor = $game_party.leader
      return false unless entry && actor
      actor.tm_original_character_name ||= actor.character_name
      actor.tm_original_character_index ||= actor.character_index
      actor.set_graphic(entry.char_name, entry.char_idx, actor.face_name, actor.face_index)
      $game_variables[4] = entry.value
      $game_player.refresh
      $game_map.need_refresh = true
      true
    end
    def revert
      actor = $game_party.leader
      return false unless actor && actor.tm_original_character_name
      actor.set_graphic(actor.tm_original_character_name, actor.tm_original_character_index,
        actor.face_name, actor.face_index)
      actor.tm_original_character_name = actor.tm_original_character_index = nil
      $game_variables[4] = 0
      $game_player.refresh
      $game_map.need_refresh = true
      true
    end
  end
end

class Game_Temp
  attr_accessor :tm_state, :tm_snapshot, :tm_requested_map
end
class Game_Actor
  attr_accessor :tm_original_character_name, :tm_original_character_index
end
class Game_System
  attr_accessor :tm_unlocked_forms
  alias tm_initialize initialize
  def initialize
    tm_initialize
    @tm_unlocked_forms = [:riu]
  end
end
class << DataManager
  alias tm_setup_new_game setup_new_game
  def setup_new_game
    result = tm_setup_new_game
    TransformMagic.unlock(:riu, false)
    result
  end
end
class Scene_Invaders
  alias tm_destroy_enemy destroy_enemy
  def destroy_enemy(score)
    result = tm_destroy_enemy(score)
    TransformMagic.reward_score(:gamemerr, $game_variables[Galv_SI::SCORE_VAR], 19)
    result
  end
end
class Game_Player
  alias tm_movable? movable?
  def movable?
    !TransformMagic.casting? && tm_movable?
  end
end

# Optional exact-form page condition. The Database variable threshold alone
# would incorrectly make every form >= 1 use the fish-only NPC dialogue.
class Game_Event
  alias tm_conditions_met? conditions_met?
  def conditions_met?(page)
    return false unless tm_conditions_met?(page)
    page.list.each do |command|
      break unless [108,408].include?(command.code)
      if command.parameters[0] =~ /\A<transform form: (\w+)>\z/i
        form = TransformMagic.form($1.downcase.to_sym)
        return !!form && $game_variables[4] == form.value
      end
    end
    true
  end
end
class Scene_Map
  alias tm_start start
  def start
    tm_start
    # Galv's character-effects initializer recreates the character sprites.
    # Start the continuation only after the final spriteset exists.
    if TransformMagic.phase == :reveal && TransformMagic.state[:animation_pending]
      TransformMagic.state[:animation_pending] = false
      player = spriteset.instance_variable_get(:@character_sprites).find do |sprite|
        sprite.character.equal?($game_player)
      end
      player.start_animation($data_animations[TransformMagic::REVEAL_ANIMATION_ID])
      animation = player.animation
      # Victor assigns a cell's bitmap only on a rate boundary. Draw pose 0
      # while duration is still divisible by rate, avoiding two blank frames.
      player.animation_set_sprites(animation, animation.frames[0])
    end
  end
  alias tm_update update
  def update
    tm_update
    TransformMagic.update_map
  end
  alias tm_update_call_menu update_call_menu
  def update_call_menu
    return if TransformMagic.casting?
    tm_update_call_menu
  end
  alias tm_terminate terminate
  def terminate
    choosing = TransformMagic.phase == :choose && SceneManager.scene_is?(Scene_TransformMagic)
    TransformMagic.finish(self) unless choosing
    tm_terminate
  end
end

# Tint only the player's non-transparent pixels. Do not tint the map or the
# animation cells, and restore any pre-existing sprite colour on interruption.
class Sprite_Character
  alias tm_update update
  def update
    tm_update
    tm_update_body_color
  end
  def tm_update_body_color
    return unless @character.equal?($game_player)
    if TransformMagic.casting?
      @tm_previous_color ||= self.color.clone
      self.color.set(*(TransformMagic::BODY_COLOR + [TransformMagic.body_alpha]))
    elsif @tm_previous_color
      self.color.set(@tm_previous_color)
      @tm_previous_color = nil
    end
  end
  def tm_stop_animation
    if @animation.is_a?(Hash)
      @animation.keys.each do |index|
        dispose_animations(index) if [125,127].include?(@animation[index].id)
      end
    end
    tm_update_body_color
  end
end
class Sprite_Base
  alias tm_setup_sprite_position setup_sprite_position
  def setup_sprite_position(animation, cells, sprite, index)
    tm_setup_sprite_position(animation, cells, sprite, index)
    return unless [125,127].include?(animation.id)
    centre_y = cells[index,2]
    if cells[index,0] < 10
      centres = [39.5,39.5,44,38.5,44.5,150,158,154,154,150.5]
      centre_y += (centres[cells[index,0]]-96)*cells[index,3]/100.0
    end
    sprite.z = self.z + (centre_y < -30 ? -1 : 3)
  end
end

# Authored story sprite changes use the same two halves without opening the
# player-controlled selector. Only the interpreter owning the scene yields.
class Game_Interpreter
  def tm_change_actor_graphic(actor_id, character_name, character_index, face_name, face_index)
    actor = $game_actors[actor_id]
    if actor.equal?($game_party.leader)
      TransformMagic.start_event_cast
      wait(1) while TransformMagic.phase == :cast
    end
    actor.set_graphic(character_name, character_index, face_name, face_index)
    if actor.equal?($game_party.leader)
      form = TransformMagic::FORMS.values.find do |entry|
        entry.char_name == character_name && entry.char_idx == character_index
      end
      $game_variables[4] = form ? form.value : 0
      unless form
        actor.tm_original_character_name = actor.tm_original_character_index = nil
      end
    end
    $game_player.refresh
    if TransformMagic.phase == :hold
      TransformMagic.begin_reveal
      wait(1) while TransformMagic.casting?
    end
  end
end

class Scene_TransformMagic < Scene_Base
  def start
    super
    @forms = TransformMagic.unlocked_forms
    @index = 0
    @map_sprite = Sprite.new
    @map_sprite.bitmap = $game_temp.tm_snapshot || SceneManager.background_bitmap
    @shade = Sprite.new
    @shade.bitmap = Bitmap.new(Graphics.width, Graphics.height)
    @shade.bitmap.fill_rect(@shade.bitmap.rect, Color.new(0,0,0,180))
    @preview = Sprite.new
    @preview.x = Graphics.width / 2
    @preview.y = (Graphics.height - 96) / 2
    @preview.z = 200
    @help_window = Window_Base.new(0, Graphics.height - 96, Graphics.width, 96)
    @help_window.opacity = 0
    refresh_form
  end
  def update
    super
    if @forms.empty? || Input.trigger?(:B)
      Sound.play_cancel
      TransformMagic.revert
      TransformMagic.begin_reveal
      SceneManager.return
    elsif Input.trigger?(:LEFT) || Input.trigger?(:RIGHT)
      Sound.play_cursor
      @index = (@index + (Input.trigger?(:RIGHT) ? 1 : -1)) % @forms.size
      refresh_form
    elsif Input.trigger?(:C)
      Sound.play_ok
      TransformMagic.apply(@forms[@index].id)
      TransformMagic.begin_reveal
      SceneManager.return
    end
  end
  def refresh_form
    return if @forms.empty?
    entry = @forms[@index]
    @preview.bitmap = Cache.picture(entry.picture)
    @preview.ox = @preview.bitmap.width / 2
    @preview.oy = @preview.bitmap.height / 2
    scale = [1.0,(Graphics.width-48).to_f/@preview.bitmap.width,
      (Graphics.height-112).to_f/@preview.bitmap.height].min
    @preview.zoom_x = @preview.zoom_y = scale
    @help_window.contents.clear
    @help_window.draw_text(0,0,@help_window.contents.width,24,entry.name,1)
    @help_window.draw_text(0,24,@help_window.contents.width,24,'← → Đổi bài    Z: Biến hình    X: Huỷ, về dạng gốc',1)
  end
  def terminate
    super
    @preview.dispose
    @map_sprite.dispose
    @shade.bitmap.dispose
    @shade.dispose
    TransformMagic.clear_snapshot
    # Non-map exits must not leave the player in a tinted/locked state.
    TransformMagic.finish unless SceneManager.scene_is?(Scene_Map)
  end
end
