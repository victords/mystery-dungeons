WorldMap = {}
WorldMap.__index = WorldMap

function WorldMap.new(known_scenes)
  local self = setmetatable({}, WorldMap)
  self.known_scenes = known_scenes
  self.current_scene_id = 1
  return self
end

function WorldMap:draw()
  local scene = self.known_scenes[self.current_scene_id]
  for i = 1, TILES_X do
    for j = 1, TILES_Y do
      if scene:is_wall(i, j) then
        Window.draw_rectangle(i - 1, j - 1, 1, 1)
      end
    end
  end
end
