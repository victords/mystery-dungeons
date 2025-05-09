require("src.constants")
require("src.scene")
require("src.player_character")
require("src.world_map")

SCENE_MEMORY_THRESHOLD = 5

Game = {
  init = function ()
    Window.set_size(false, WINDOW_WIDTH, WINDOW_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT)
    Game.scenes = {}
    Game.transitions = {}
    Game.set_scene(1)
    Game.player = PlayerCharacter.new()
    local entrance = Game.scene.entrances[1]
    Game.current_entrance = entrance
    Game.player:set_position(entrance[1], entrance[2])
    Game.player.on_exit = Game.on_player_exit
    Game.world_map = WorldMap.new(Game.scenes)
  end,
  set_scene = function(id, col, row)
    Game.scenes[id] = Game.scenes[id] or Scene.new(id, false, col, row)
    Game.scene = Game.scenes[id]
    Game.scene.on_reset = Game.on_scene_reset
    Game.scene.on_trigger = Game.on_trigger
  end,
  on_player_exit = function (exit_obj)
    local col = Game.scene.map_col
    local row = Game.scene.map_row
    if exit_obj.dir == 0 then
      row = row - 1
    elseif exit_obj.dir == 1 then
      col = col + 1
    elseif exit_obj.dir == 2 then
      row = row + 1
    else
      col = col - 1
    end
    Game.set_scene(exit_obj.dest_scene, col, row)
    Game.world_map:set_current_scene(Game.scene)
    local entrance = Game.scene.entrances[exit_obj.dest_entrance]
    Game.current_entrance = entrance
    Game.player:set_position(entrance[1], entrance[2])
    Game.transitioning = true
  end,
  on_scene_reset = function()
    Game.scenes[Game.scene.id] = nil
    Game.set_scene(Game.scene.id)
    Game.player:set_position(Game.current_entrance[1], Game.current_entrance[2])
    Game.transitioning = true
  end,
  on_trigger = function(type, args)
    if type == "save" then
      print("saving game...")
    end
  end,
  update = function ()
    KB.update()
    Game.transitioning = false
    Game.scene:update()
    if Game.transitioning then return end

    Game.player:update(Game.scene)
    Game.world_map:update(Game.player)
  end,
  draw = function ()
    if Game.transitioning then return end

    Window.draw(function ()
      Game.scene:draw()
      Game.player:draw()
      Game.world_map:draw()
    end)
  end
}
