#=======================================================
#         Lune Smooth Camera Sliding
# Author: Raizen
# Comunity: www.centrorpg.com
# The scripts allow a much smoother movement, making the move much more realistic.
#=======================================================
module Lune_cam_slide
# Constant of the slide, the greater the faster, the lower the slower..(default = 0.001)
Slide = 0.001

 
# To set the camera focus on an event instead of a player
# Script Call: set_camera_focus(id)
# where id is the id of the event, to put back the focus on the player,
# id = 0
 
end
 
 
 
#==============================================================================
# ** Game_Player
#------------------------------------------------------------------------------
#  Esta classe gerencia o jogador.
# A instância desta classe é referenciada por $game_player.
#==============================================================================
 
class Game_Player < Game_Character
alias :lune_camera_slide_initialize :initialize
  #--------------------------------------------------------------------------
  # * Inicialização do objeto
  #--------------------------------------------------------------------------
  def initialize(*args)
    @camera_slide_focus = 0
    lune_camera_slide_initialize(*args)
  end
  #--------------------------------------------------------------------------
  # * Atualização da rolagem
  #     last_real_x : ultima coordenada X real
  #     last_real_y : ultima coordenada Y real
  #--------------------------------------------------------------------------
  def update_scroll(last_real_x, last_real_y)
    return if $game_map.scrolling?
    if @camera_slide_focus == 0
      screen_focus_x = screen_x
      screen_focus_y = screen_y
    else
      screen_focus_x = $game_map.events[@camera_slide_focus].screen_x
      screen_focus_y = $game_map.events[@camera_slide_focus].screen_y
    end
    sc_x = (screen_focus_x - Graphics.width/2).abs
    sc_y = (screen_focus_y - 16 - Graphics.height/2).abs
    $game_map.scroll_down(Lune_cam_slide::Slide*sc_y) if screen_focus_y - 16 > Graphics.height/2
    $game_map.scroll_left(Lune_cam_slide::Slide*sc_x) if screen_focus_x < Graphics.width/2
    $game_map.scroll_right(Lune_cam_slide::Slide*sc_x) if screen_focus_x > Graphics.width/2
    $game_map.scroll_up(Lune_cam_slide::Slide*sc_y) if screen_focus_y - 16 < Graphics.height/2
  end
  def set_camera_focus(event = 0)
    @camera_slide_focus = event
  end
end
 
 
#==============================================================================
# ** Spriteset_Map
#------------------------------------------------------------------------------
#  Esta classe reune os sprites da tela de mapa e tilesets. Esta classe é
# usada internamente pela classe Scene_Map.
#==============================================================================
 
class Spriteset_Map
    #--------------------------------------------------------------------------
  # * Atualização do tilemap
  #--------------------------------------------------------------------------
  def update_tilemap
    @tilemap.map_data = $game_map.data
    @tilemap.ox = ($game_map.display_x * 32)
    @tilemap.oy = ($game_map.display_y * 32)
    @tilemap.ox += 1 if $game_map.adjust_tile_slide_x
    @tilemap.oy += 1 if $game_map.adjust_tile_slide_y
    @tilemap.update
  end
end
#==============================================================================
# ** Game_Map
#------------------------------------------------------------------------------
#  Esta classe gerencia o mapa. Inclui funções de rolagem e definição de
# passagens. A instância desta classe é referenciada por $game_map.
#==============================================================================
 
class Game_Map
  #--------------------------------------------------------------------------
  # * Variáveis públicas
  #--------------------------------------------------------------------------
  def adjust_tile_slide_x
    @display_x != 0 && @display_x != (@map.width - screen_tile_x) && !scrolling?
  end
  def adjust_tile_slide_y
    @display_y != 0 && @display_y != (@map.height - screen_tile_y) && !scrolling?
  end
end
#==============================================================================
# ** Game_Interpreter
#------------------------------------------------------------------------------
#  Um interpretador para executar os comandos de evento. Esta classe é usada
# internamente pelas classes Game_Map, Game_Troop e Game_Event.
#==============================================================================
 
class Game_Interpreter
  def set_camera_focus(event = 0)
    $game_player.set_camera_focus(event)
  end
end