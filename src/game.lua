require("src.constants")
require("src.scene")
require("src.player_character")
require("src.world_map")

SCENE_MEMORY_THRESHOLD = 5

Game = {
  init = function ()
    Window.set_size(false, WINDOW_WIDTH, WINDOW_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT)
    Game.scene = Scene.new(1)
    Game.scenes = {[1] = Game.scene}
    Game.transitions = {}
    Game.player = PlayerCharacter.new()
    local entrance = Game.scene.entrances[1]
    Game.player:set_position(entrance[1], entrance[2])
    Game.player.on_exit = Game.on_player_exit
    Game.world_map = WorldMap.new(Game.scenes)
  end,
  on_player_exit = function (exit_obj)
    local dest_scene_id = exit_obj.dest_scene
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
    Game.scenes[dest_scene_id] = Game.scenes[dest_scene_id] or Scene.new(dest_scene_id, false, col, row)
    Game.scene = Game.scenes[dest_scene_id]
    Game.world_map:set_current_scene(Game.scene)
    local entrance = Game.scene.entrances[exit_obj.dest_entrance]
    Game.player:set_position(entrance[1], entrance[2])
    Game.transitioning = true
  end,
  update = function ()
    KB.update()
    Game.transitioning = false
    Game.scene:update()
    Game.player:update(Game.scene)
    Game.world_map:update(Game.player)
    print(love.timer.getFPS())
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
