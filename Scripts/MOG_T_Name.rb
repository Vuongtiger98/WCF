if true
#==============================================================================
# +++ MOG - Title Name - [Stand Alone Series] (V1.1) +++
#==============================================================================
# By Moghunter 
# https://atelierrgss.wordpress.com/
#==============================================================================
# Adiciona o nome do título em imagem.
#==============================================================================
module MOG_TITLE_NAME
  #--------------------------------------------------------------------------
  # Definição da posição X da imagem.
  #--------------------------------------------------------------------------
  X_POS = Graphics.width / 2
  #--------------------------------------------------------------------------
  # Definição da posição Y da imagem
  #--------------------------------------------------------------------------
  Y_POS = 250
  #--------------------------------------------------------------------------
  # Ativar o efeito Wave.
  #--------------------------------------------------------------------------
  WAVE_EFFECT = false
  #--------------------------------------------------------------------------
  # Poder do efeito Wave.
  #--------------------------------------------------------------------------
  WAVE_POWER = 5
  #--------------------------------------------------------------------------
  # Velocidade do efeito Wave.
  #--------------------------------------------------------------------------
  WAVE_SPEED = 2
  #--------------------------------------------------------------------------
  # Definição do nome do arquivo.
  #--------------------------------------------------------------------------
  FILE_NAME = "Title_Name"  
end

$imported = {} if $imported.nil?
$imported[:mog_title_name] = true

#==============================================================================
# ■ Scene Tittle
#==============================================================================
class Scene_Title < Scene_Base  
  
 #--------------------------------------------------------------------------
 # ● Draw Game Title
 #--------------------------------------------------------------------------             
 def draw_game_title
     @foreground_sprite.bitmap = Cache.title1(MOG_TITLE_NAME::FILE_NAME.to_s)
     @foreground_sprite.opacity = 0
     @foreground_sprite.ox = @foreground_sprite.bitmap.width / 2
     @foreground_sprite.oy = @foreground_sprite.bitmap.height / 2
     @foreground_sprite.x = MOG_TITLE_NAME::X_POS + (MOG_TITLE_NAME::WAVE_POWER / 2)
     @foreground_sprite.y = MOG_TITLE_NAME::Y_POS
     return if !MOG_TITLE_NAME::WAVE_EFFECT
     @foreground_sprite.wave_amp = MOG_TITLE_NAME::WAVE_POWER
     @foreground_sprite.wave_length = @foreground_sprite.bitmap.width
     @foreground_sprite.wave_speed = 100 + 100 * MOG_TITLE_NAME::WAVE_SPEED
 end
 
 #--------------------------------------------------------------------------
 # ● Update
 #--------------------------------------------------------------------------             
 alias mog_t_foreground_sprite_update update
 def update
     mog_t_foreground_sprite_update
     @foreground_sprite.opacity += 3 ; @foreground_sprite.update
 end
 
end

end