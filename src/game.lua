require("src.constants")
require("src.scene")
require("src.player_character")

Game = {
  init = function ()
    Window.set_size(false, WINDOW_WIDTH, WINDOW_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT)
    Game.scene = Scene.new(1)
    Game.scenes = { scene }
    Game.player = PlayerCharacter.new()
    local entrance = Game.scene.entrances[1]
    Game.player:set_position(entrance[1], entrance[2])
    Game.player.on_exit = Game.on_player_exit
  end,
  on_player_exit = function(exit_obj)
    local dest_scene_id = exit_obj.dest_scene
    Game.scenes[dest_scene_id] = Game.scenes[dest_scene_id] or Scene.new(dest_scene_id)
    Game.scene = Game.scenes[dest_scene_id]
    local entrance = Game.scene.entrances[exit_obj.dest_entrance]
    Game.player:set_position(entrance[1], entrance[2])
    Game.transitioning = true
  end,
  update = function ()
    Game.transitioning = false
    Game.scene:update()
    Game.player:update(Game.scene)
  end,
  draw = function ()
    if Game.transitioning then return end

    Game.scene:draw()
    Game.player:draw()
  end
}
