require("src.constants")
require("src.scene")
require("src.player_character")
require("src.world_map")

SCENE_MEMORY_THRESHOLD = 5

Game = {
  init = function ()
    Window.set_size(false, WINDOW_WIDTH, WINDOW_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT)
    Game.scene = Scene.new(1)
    Game.scenes = {[1] = {0, Game.scene}}
    Game.known_scenes = {[1] = Game.scene}
    Game.transitions = {}
    Game.player = PlayerCharacter.new()
    local entrance = Game.scene.entrances[1]
    Game.player:set_position(entrance[1], entrance[2])
    Game.player.on_exit = Game.on_player_exit
    Game.world_map = WorldMap.new(Game.known_scenes)
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
    Game.scenes[dest_scene_id] = Game.scenes[dest_scene_id] or {0, Scene.new(dest_scene_id, false, col, row)}
    Game.update_scene_distances(Game.scene.id, dest_scene_id)
    Game.scene = Game.scenes[dest_scene_id][2]
    Game.known_scenes[dest_scene_id] = Game.scene
    Game.world_map:set_current_scene(Game.scene)
    local entrance = Game.scene.entrances[exit_obj.dest_entrance]
    Game.player:set_position(entrance[1], entrance[2])
    Game.transitioning = true
  end,
  update_scene_distances = function (from_id, to_id)
    Game.transitions[from_id] = Game.transitions[from_id] or {}
    Game.transitions[to_id] = Game.transitions[to_id] or {}
    Game.transitions[from_id][to_id] = 1
    Game.transitions[to_id][from_id] = 1

    Game.scenes[to_id][1] = 0
    local scenes_to_update = {}
    for id, scene_data in pairs(Game.scenes) do
      scene_data[1] = id == to_id and 0 or 1000000
      table.insert(scenes_to_update, id)
    end
    while #scenes_to_update > 0 do
      local min_distance = 1000000
      local index
      for i, scene_id in ipairs(scenes_to_update) do
        if Game.scenes[scene_id][1] < min_distance then
          min_distance = Game.scenes[scene_id][1]
          index = i
        end
      end
      local id = table.remove(scenes_to_update, index)
      for neighbor_id, distance in pairs(Game.transitions[id]) do
        local new_distance = Game.scenes[id][1] + distance
        if Game.scenes[neighbor_id] and new_distance < Game.scenes[neighbor_id][1] then
          Game.scenes[neighbor_id][1] = new_distance
        end
      end
    end

    for id, data in pairs(Game.scenes) do
      if data[1] > SCENE_MEMORY_THRESHOLD then
        Game.scenes[id] = nil
      end
    end
  end,
  update = function ()
    KB.update()
    Game.transitioning = false
    Game.scene:update()
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
