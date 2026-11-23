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

# NPC_FORM_REACTIONS: shared manual-interaction layer; no event data edits.
module NPCFormReaction
  SPECIAL = {
    :leo => {
      :riu => 'Quỳ hả? Bà định nói gì thì biến lại một chút coi. Tui chưa học tiếng ọc ọc đâu!',
      :gamemerr => 'Bà chơi game tới mức biến thành máy luôn hả? Có chạy được đống đĩa trong phòng tui không?',
      :sanic => 'Chạy nhanh vậy thì tiện ghê! Tui còn một chồng hồ sơ cần chuyển—Ơ, đứng lại coi!',
      :diana => 'Ủa, khách tới nữa hả? …Quỳ? Bà lại tính để tui chào nhầm thêm lần nữa đúng không?'
    },
    :shylvie => {
      :riu => 'Ọc ọc cái gì. Muốn nhờ tôi làm việc thì ít nhất phải để tôi hiểu bà đang nhờ gì chứ.',
      :gamemerr => 'Có hình dạng chuyên chơi game rồi, chắc lần này bà thắng được chứ?',
      :sanic => 'Chạy nhanh thế thì tự đi mua đồ nhé. Đừng có đứng đây nhờ tôi dịch chuyển nữa.',
      :diana => 'Lại một bé gái dễ thương. Gu chọn hình dạng của bà nhất quán thật đấy.'
    },
    :kohi => {
      :riu => 'Quỳ có uống cà phê được trong dạng này không? …Thôi, đừng thử ngay trên bàn làm việc của tôi.',
      :gamemerr => 'Nếu tôi đặt ly cà phê cạnh bà thì có cần giữ khoảng cách như với máy tính không?',
      :sanic => 'Quỳ đi chậm chút coi! Tôi vừa pha xong ly này, chưa muốn lau sàn đâu!',
      :diana => 'Dễ thương ghê! Nhưng nếu Quỳ đói thì báo trước nha. Chỗ RAM của Hakase tôi không dám tự lấy đâu.'
    },
    :hakase => {
      :riu => 'Nhí nhí, mấy cái tua đó cử động riêng được hả? Cậu thử vẫy từng cái một coi!',
      :gamemerr => 'Nhí nhí, tôi có mấy ý tưởng nâng cấp! …Sao cậu lùi lại? Tôi còn chưa lấy dụng cụ ra mà!',
      :sanic => 'Nếu vừa chạy vừa lắp mô hình thì có nhanh hơn không ta? …Không được hả?',
      :diana => 'Khoan, để tôi nhìn kỹ chút! …Chỉ nhìn thôi mà! Tôi cất tua vít rồi, thấy chưa?'
    },
    :alpha => {:gamemerr => 'D-13, bà biến thành máy chơi game luôn rồi hả? Cho tôi mượn một lát—Beta, đừng nhìn tôi như thế!'},
    :beta => {:sanic => 'Nếu di chuyển nhanh hơn thì tốt. Nhưng nhớ giao hồ sơ đúng bàn, đừng thả chúng bay khắp phòng.'},
    :diana => {:diana => 'Ơ? Sao chị lại giống em vậy? Chị cũng đang đói RAM ạ?'}
  }
  SHORT = {
    :leo => {:riu=>'Tui hiểu mỗi đoạn bà đang bất mãn thôi.',
      :gamemerr=>'Có chạy được đống đĩa trong phòng tui không?', :sanic=>'Ơ, đứng lại coi!',
      :diana=>'Bà lại tính để tui chào nhầm thêm lần nữa đúng không?'},
    :shylvie => {:riu=>'Ọc ọc cái gì.', :gamemerr=>'Tôi đang nhớ lại kết quả lần trước.',
      :sanic=>'Đừng có đứng đây nhờ tôi dịch chuyển nữa.', :diana=>'Gu chọn hình dạng của bà nhất quán thật đấy.'},
    :kohi => {:riu=>'…Thôi, đừng thử ngay trên bàn làm việc của tôi.',
      :gamemerr=>'Nếu tôi đặt ly cà phê cạnh bà thì có cần giữ khoảng cách như với máy tính không?',
      :sanic=>'Tôi vừa pha xong ly này, chưa muốn lau sàn đâu!', :diana=>'Chỗ RAM của Hakase tôi không dám tự lấy đâu.'},
    :hakase => {:riu=>'Cậu thử vẫy từng cái một coi!',
      :gamemerr=>'…Sao cậu lùi lại? Tôi còn chưa lấy dụng cụ ra mà!',
      :sanic=>'…Không được hả?', :diana=>'Tôi cất tua vít rồi, thấy chưa?'}
  }
  COMMON = {
    :riu => ['Ơ? Bé này đi lạc à?', 'Mấy cái tua kia cử động được thật kìa.',
      'Bạn đang muốn nói gì với tôi sao?', 'Nhìn dễ thương ghê. Nhưng tôi không biết nên chào kiểu gì.'],
    :gamemerr => ['Người máy này tự đi mua sắm luôn à?', 'Trông như bước ra từ một trò chơi cũ vậy.',
      'Bạn tới chơi hay tới tìm người chơi cùng?', 'Tôi chưa thấy mẫu người máy này bao giờ.'],
    :sanic => ['Tôi vừa thấy một vệt xanh chạy ngang… Là bạn hả?', 'Đi chậm chút nhé, ở đây đông người lắm.',
      'Nhìn quen quen, nhưng có gì đó hơi khác.', 'Bạn không cần lấy đà chỉ để bước tới đây đâu.'],
    :diana => ['Bé đi cùng ai vậy?', 'Ồ, là người máy à? Trông giống người thật ghê.',
      'Chào bé. Bé đang tìm ai sao?', 'Mẫu người máy này dễ thương thật.']
  }
  SHOP = {:riu=>'Bạn chỉ vào món muốn xem nhé.',
    :gamemerr=>'Nếu muốn xem máy chơi game thì ở phía bên kia.',
    :sanic=>'Trong cửa hàng mình đi bộ thôi nhé!', :diana=>'Bé muốn xem món nào?'}
  # Baked NPCs have no character filename. Use IDs, never tile coordinates.
  PARALLAX = {
    3=>{22=>[:beta,4],27=>[:alpha,5]}, 13=>{97=>[:leo,97],98=>[:shylvie,98]},
    19=>{5=>[:shop,5],8=>[:shop,8]},
    58=>{2=>[:shop,9],6=>[:common,6],8=>[:common,8],11=>[:common,11],
      12=>[:common,12],18=>[:common,18],20=>[:common,20],25=>[:common,25]}
  }
  NORMAL_FACES = {:leo=>'Leo_Normal_Emote',:shylvie=>'CV_Normal',
    :alpha=>'AlphaC61_Emote',:beta=>'BetaM34_Emote'}
  CHRISTMAS_FACES = {:leo=>'Leo_Giangsinh_Emote',:shylvie=>'CV_Giangsinh_Emote1',
    :kohi=>'Kohi_Giangsinh_Emote1',:hakase=>'Hakase_Giangsinh_Emote'}
  STORY_CODES = [103,104,126,127,128,201,202,301,302,303,351,352,353,354]
  class << self
    def action?; $game_temp && $game_temp.nfr_action_depth.to_i > 0; end
    def iv(object,name); object.instance_variable_get('@'+name.to_s); end
    def current_form
      return nil unless $game_player && $game_variables && !TransformMagic.casting?
      TransformMagic::FORMS.values.find do |entry|
        entry.value == $game_variables[4] && entry.char_name == $game_player.character_name &&
          entry.char_idx == $game_player.character_index
      end
    end
    def legacy_riu_page?(map_id,event_id,page)
      return false unless map_id == 13 && [97,98].include?(event_id)
      first = page.list[0]
      first && first.code == 108 && first.parameters == ['<transform form: riu>']
    end
    def empty_diana?(event)
      action? && $game_map.map_id == 38 && event.id == 18 && $game_switches[48] &&
        $game_switches[82] && event.character_name == '!$Diana' && current_form
    end
    def resolve(event)
      visited = []
      8.times do
        return nil unless event && event.list && !iv(event,:erased) && !visited.include?(event.id)
        visited << event.id
        commands = event.list.reject { |entry| [0,108,408].include?(entry.code) }
        break unless commands.size == 1 && commands[0].code == 355 &&
          commands[0].parameters[0] =~ /\A\$game_map\.events\[(\d+)\]\.start\s*# WCF_CAFE_HITBOX_/
        event = $game_map.events[$1.to_i]
      end
      event
    end
    def profile(event)
      event = resolve(event)
      return nil unless event
      map_id = $game_map.map_id
      configured = PARALLAX[map_id] && PARALLAX[map_id][event.id]
      role, anchor = configured if configured
      name = iv(event,:event).name
      unless role
        name_role = name[/\ANPC-(SHYLVIE|KOHI|LEO|HAKASE)\b/,1]
        role = name_role.downcase.to_sym if name_role
        role = :kohi if map_id == 46 && event.id == 14
        role = :diana if map_id == 38 && event.id == 18 && $game_switches[82]
        role = :common if event.character_name =~ /\A\$(?:NPC_Chart\d*|Oguri_nomnom)\z/i
        anchor = event.id
      end
      return nil unless role
      if map_id == 58 && event.id == 25
        focus = event.list.find { |c| c.code == 355 && c.parameters[0] =~ /ms_pro_cam_focus_on\((25|26)\)/ }
        anchor = focus.parameters[0][/ms_pro_cam_focus_on\((25|26)\)/,1].to_i if focus
      end
      return nil unless $game_map.events[anchor]
      identity = SPECIAL.key?(role) ? role : [map_id,event.id]
      seasonal = event.character_name =~ /giangsinh/i
      face = seasonal ? CHRISTMAS_FACES[role] : NORMAL_FACES[role]
      face ||= CHRISTMAS_FACES[role] if [:kohi,:hakase].include?(role)
      {:role=>role,:anchor=>anchor,:identity=>identity,:face=>face.to_s,:event=>event}
    end
    def eligible?(interpreter,event_id)
      return false unless action? && interpreter.equal?($game_map.interpreter) && event_id > 0
      return false unless SceneManager.scene_is?(Scene_Map) && !SceneManager.scene.scene_changing?
      return false if $game_system.menu_disabled || $game_player.transparent || $game_player.transfer?
      return false if $game_message.busy? || $game_message.visible || $game_temp.common_event_reserved? || !current_form
      event = $game_map.events[event_id]
      event && event.trigger_in?([0])
    end
    def state; $game_system.npc_form_reactions; end
    def commit(identity,form)
      key = [identity,form]
      state[:seen][key] = true
    end
    def pick_common(data,form)
      group = data[:role] == :shop ? :shop : :common
      pool = COMMON.fetch(form).dup
      pool << SHOP.fetch(form) if group == :shop
      key = [data[:identity],form]
      bag = state[:bags][key] ||= []
      bag.reject! { |i| !i.is_a?(Integer) || i < 0 || i >= pool.size }
      bag.concat((0...pool.size).to_a.shuffle) if bag.empty?
      last = state[:last][[group,form]]
      local_key = [:npc,data[:identity],form]
      local_last = state[:last][local_key]
      chosen = bag.index { |i| pool[i] != last && pool[i] != local_last }
      # A neighbouring NPC can have just used the bag's final candidate.
      # Defer that candidate and draw a safe alternative without losing it.
      index = chosen ? bag.delete_at(chosen) :
        (0...pool.size).to_a.select { |i| pool[i] != last && pool[i] != local_last }.sample
      text = pool[index]
      state[:last][[group,form]] = text
      state[:last][local_key] = text
      text
    end
    # Count a Vietnamese base letter plus combining marks as one column.
    # RGSS Ruby 1.9.2 does not provide String#unicode_normalize.
    def letters(text); text.scan(/\P{M}\p{M}*|\p{M}+/); end
    def wrap(text,width)
      lines = []; line = ''
      text.split(/\s+/).each do |word|
        candidate = line.empty? ? word : line+' '+word
        if letters(candidate).size <= width
          line = candidate
        else
          lines << line unless line.empty?
          parts = letters(word)
          lines << parts.shift(width).join while parts.size > width
          line = parts.join
        end
      end
      lines << line unless line.empty?
      lines
    end
    def command(code,parameters=[]); RPG::EventCommand.new(code,0,parameters); end
    def speech(list,text,anchor,face='')
      wrap(text,face.empty? ? 40 : 33).each_slice(4) do |lines|
        list << command(101,[face,0,0,2])
        lines.each_with_index do |line,i|
          list << command(401,[(i == 0 ? "\\bm[#{anchor}] " : '')+line])
        end
      end
    end
    def reaction_list(data,form)
      role = data[:role]; identity = data[:identity]
      first = !state[:seen][[identity,form]]
      special = SPECIAL[role] && SPECIAL[role][form]
      text = nil
      if special
        short = SHORT[role] && SHORT[role][form]
        pool = [short,special].compact.uniq
        last_key = [:special,identity,form]
        text = first ? special : (pool.find { |line| line != state[:last][last_key] } || pool[0])
        state[:last][last_key] = text
      end
      text ||= pick_common(data,form)
      list = [command(355,["NPCFormReaction.commit(#{identity.inspect}, #{form.inspect})"])]
      balloon = role == :hakase ? 9 : form == :sanic ? 1 : form == :diana ? 4 : 2
      balloon = 2 if role == :beta
      list << command(213,[data[:anchor],balloon,false]) if first
      speech(list,'Ọc ọc ọc!',0) if first && form == :riu && [:leo,:shylvie].include?(role)
      speech(list,text,data[:anchor],data[:face])
      if first && role == :shylvie && form == :gamemerr
        speech(list,'Bà đang nghi ngờ trình độ của tôi à?',0)
        speech(list,'Tôi đang nhớ lại kết quả lần trước.',data[:anchor],data[:face])
      end
      list << command(0)
      list
    end
    def correct_legacy_anchor(list,event_id)
      return list unless $game_map.map_id == 13 && event_id == 98
      page = iv($game_map.events[event_id],:page)
      return list unless page && page.condition.switch2_valid && page.condition.switch2_id == 3
      list.map do |entry|
        next entry unless entry.code == 401 && entry.parameters[0].include?('\\bm[97]')
        command(401,[entry.parameters[0].sub('\\bm[97]','\\bm[98]')])
      end
    end
    def interaction_list(interpreter,list,event_id)
      return list unless action? && interpreter.equal?($game_map.interpreter)
      original = correct_legacy_anchor(list,event_id)
      return original unless eligible?(interpreter,event_id)
      data = profile($game_map.events[event_id])
      return original unless data
      source = data[:event].list
      return original if source.any? { |c| STORY_CODES.include?(c.code) }
      return original if data[:event].trigger_in?([3,4])
      return original if data[:role] == :diana && !$game_switches[48]
      reaction_list(data,current_form.id)
    end
  end
end

class Game_System
  def npc_form_reactions
    @npc_form_reactions ||= {:seen=>{},:bags=>{},:last=>{}}
    # Older development saves alternated reactions and normal dialogue.
    # Keep history/random bags, but discard that obsolete turn flag.
    @npc_form_reactions.delete(:base_next)
    @npc_form_reactions
  end
end
class Game_Temp
  attr_accessor :nfr_action_depth
end
class Game_Player
  alias nfr_check_action_event check_action_event
  def check_action_event
    $game_temp.nfr_action_depth = $game_temp.nfr_action_depth.to_i + 1
    nfr_check_action_event
  ensure
    $game_temp.nfr_action_depth = [$game_temp.nfr_action_depth.to_i - 1,0].max
  end
end
class Game_Interpreter
  alias nfr_setup setup
  def setup(list,event_id=0)
    nfr_setup(NPCFormReaction.interaction_list(self,list,event_id),event_id)
  end
end
class Game_Event
  alias nfr_conditions_met? conditions_met?
  def conditions_met?(page)
    return false if NPCFormReaction.legacy_riu_page?(@map_id,@id,page)
    nfr_conditions_met?(page)
  end
  alias nfr_empty? empty?
  def empty?
    return false if NPCFormReaction.empty_diana?(self)
    nfr_empty?
  end
end
