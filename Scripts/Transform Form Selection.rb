#==============================================================================
# ** Transform Magic
#------------------------------------------------------------------------------
# Press a key on the map -> cast animation -> open form selector -> transform
#------------------------------------------------------------------------------
# Put form preview images in: Graphics/Pictures
# Put character sprites in: Graphics/Characters
#==============================================================================
module TransformMagic
  #--------------------------------------------------------------------------
  # CONFIG
  #--------------------------------------------------------------------------
  TRIGGER_KEY = Input::Z
  CAST_ANIMATION_ID = 123
  CAST_WAIT_FRAMES = 250
  APPLY_TO_LEADER = true

  #--------------------------------------------------------------------------
  # FORM DATA - Added :value for Variable 4
  #--------------------------------------------------------------------------
  FormData = Struct.new(:id, :name, :picture, :char_name, :char_idx, :value)

  FORMS = {
    :nguyenthuy => FormData.new(:nguyenthuy, "Nguyên thuỷ", "QuyRiu", "Chimera01_cip", 1, 1),
    :trunguy  => FormData.new(:trunguy,  "Trung Uý",   "QuyTrungUy", "$Erufu_Sprite", 0, 2),
    :chienthan  => FormData.new(:chienthan,  "Chiến thần",   "QuyChienThan", "$a_gyoei", 0, 3),
    :wtf  => FormData.new(:wtf,  "WTF",   "QuyWTF", "$a_gyoei", 0, 4)
    # Add more forms here like this:
    # :newform => FormData.new(:newform, "Form Name", "PictureName", "CharName", 0, 4),
  }

  #--------------------------------------------------------------------------
  # HELPERS
  #--------------------------------------------------------------------------
  class << self
    def form(id)
      FORMS[id.to_sym]
    end

    def unlocked_forms
      $game_system.tm_unlocked_forms ||= []
      $game_system.tm_unlocked_forms.select { |id| FORMS.key?(id) }.map { |id| FORMS[id] }
    end

    def unlocked?(id)
      $game_system.tm_unlocked_forms ||= []
      $game_system.tm_unlocked_forms.include?(id.to_sym)
    end

    def unlock(id)
      $game_system.tm_unlocked_forms ||= []
      id = id.to_sym
      $game_system.tm_unlocked_forms << id unless $game_system.tm_unlocked_forms.include?(id)
    end

    def lock(id)
      $game_system.tm_unlocked_forms ||= []
      $game_system.tm_unlocked_forms.delete(id.to_sym)
    end

    def can_open?
      return false if $game_message.busy?
      return false if $game_player.moving?
      true
    end

    def start_cast
      return unless can_open?
      return if unlocked_forms.empty?
      $game_player.animation_id = CAST_ANIMATION_ID if CAST_ANIMATION_ID > 0
      $game_temp.tm_form_menu_wait = CAST_WAIT_FRAMES
      $game_temp.tm_form_menu_pending = true
    end

    def update_map
      return if $game_message.busy?
      if $game_temp.tm_form_menu_pending
        $game_temp.tm_form_menu_wait -= 1
        if $game_temp.tm_form_menu_wait <= 0
          $game_temp.tm_form_menu_pending = false
          SceneManager.call(Scene_TransformMagic)
        end
        return
      end

      if Input.trigger?(TRIGGER_KEY)
        start_cast
      end
    end

    #--------------------------------------------------------------------------
    # Apply Form + Set Variable 4
    #--------------------------------------------------------------------------
    def apply(id)
      f = form(id)
      return unless f
      actor = leader_actor
      return unless actor

      # Save original only once
      actor.tm_original_character_name ||= actor.character_name
      actor.tm_original_character_index ||= actor.character_index

      # Change graphic
      actor.set_graphic(f.char_name, f.char_idx, actor.face_name, actor.face_index)

      # === NEW: Set Variable 4 to form value ===
      $game_variables[4] = f.value

      $game_player.refresh
      $game_map.need_refresh = true
    end

    #--------------------------------------------------------------------------
    # Revert + Reset Variable 4 to 0
    #--------------------------------------------------------------------------
    def revert
      actor = leader_actor
      return unless actor
      return unless actor.tm_original_character_name

      actor.set_graphic(actor.tm_original_character_name, actor.tm_original_character_index)

      # Reset original data
      actor.tm_original_character_name = nil
      actor.tm_original_character_index = nil

      # === NEW: Reset Variable 4 ===
      $game_variables[4] = 0

      $game_player.refresh
      $game_map.need_refresh = true
    end

    def open_menu
      return if unlocked_forms.empty?
      SceneManager.call(Scene_TransformMagic)
    end

    def leader_actor
      $game_party.leader
    end
  end
end

#==============================================================================
# ** Game_Temp
#==============================================================================
class Game_Temp
  attr_accessor :tm_form_menu_pending
  attr_accessor :tm_form_menu_wait

  alias tm_init initialize
  def initialize
    tm_init
    @tm_form_menu_pending = false
    @tm_form_menu_wait = 0
  end
end

#==============================================================================
# ** Game_Actor
#==============================================================================
class Game_Actor
  attr_accessor :tm_original_character_name
  attr_accessor :tm_original_character_index
end

#==============================================================================
# ** Game_System
#==============================================================================
class Game_System
  attr_accessor :tm_unlocked_forms

  alias tm_init initialize
  def initialize
    tm_init
    @tm_unlocked_forms = []
  end
end

#==============================================================================
# ** Scene_Map
#==============================================================================
class Scene_Map < Scene_Base
  alias tm_update update
  def update
    tm_update
    TransformMagic.update_map
  end
end

#==============================================================================
# ** Scene_TransformMagic
#==============================================================================
class Scene_TransformMagic < Scene_Base
  def start
    super
    @forms = TransformMagic.unlocked_forms
    @index = 0
    create_sprites
    create_help_window
    refresh_form
  end

  def terminate
    dispose_sprites
    super
  end

  def update
    super
    return if @forms.empty?

    if Input.trigger?(Input::LEFT)
      Sound.play_cursor
      @index = (@index - 1) % @forms.size
      refresh_form
    elsif Input.trigger?(Input::RIGHT)
      Sound.play_cursor
      @index = (@index + 1) % @forms.size
      refresh_form
    elsif Input.trigger?(Input::C)
      Sound.play_ok
      TransformMagic.apply(@forms[@index].id)
      SceneManager.return
    elsif Input.trigger?(Input::B)
      Sound.play_cancel
      SceneManager.return
    end
  end

  private

  def create_sprites
    @bg_sprite = Sprite.new
    @bg_sprite.bitmap = Bitmap.new(Graphics.width, Graphics.height)
    @bg_sprite.bitmap.fill_rect(0, 0, Graphics.width, Graphics.height, Color.new(0, 0, 0, 180))

    @pic_sprite = Sprite.new
    @pic_sprite.x = Graphics.width / 2
    @pic_sprite.y = Graphics.height / 2 - 20
    @pic_sprite.z = 200
  end

  def create_help_window
    @help_window = Window_Base.new(0, Graphics.height - 96, Graphics.width, 96)
    @help_window.opacity = 0
    @help_window.back_opacity = 160
  end

  def refresh_form
    return if @forms.empty?
    form = @forms[@index]
    @pic_sprite.bitmap = Cache.picture(form.picture)
    @pic_sprite.ox = @pic_sprite.bitmap.width / 2
    @pic_sprite.oy = @pic_sprite.bitmap.height / 2

    @help_window.contents.clear
    @help_window.draw_text(0, 0, @help_window.contents.width, 24, form.name, 1)
    @help_window.draw_text(0, 24, @help_window.contents.width, 24,
      "Phím mũi tên: Đổi bài  OK: Biến hình  Cancel: Huỷ phép", 1)
  end

  def dispose_sprites
    @help_window.dispose if @help_window
    @pic_sprite.bitmap.dispose if @pic_sprite.bitmap
    @pic_sprite.dispose if @pic_sprite
    @bg_sprite.bitmap.dispose if @bg_sprite.bitmap
    @bg_sprite.dispose if @bg_sprite
  end
end