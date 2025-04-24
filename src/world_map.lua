WorldMap = {}
WorldMap.__index = WorldMap

function WorldMap.new(known_scenes)
  local self = setmetatable({}, WorldMap)
  self.scenes = {}
  for _, scene in pairs(known_scenes) do
    self.scenes[scene.map_col] = self.scenes[scene.map_col] or {}
    self.scenes[scene.map_col][scene.map_row] = scene
  end
  self.current_col = 1
  self.current_row = 1
  self.visible = false
  return self
end

function WorldMap:set_current_scene(scene)
  self.scenes[scene.map_col] = self.scenes[scene.map_col] or {}
  self.scenes[scene.map_col][scene.map_row] = scene
  self.current_col = scene.map_col
  self.current_row = scene.map_row
end

function WorldMap:update()
  if KB.pressed("tab") then
    self.visible = not self.visible
  end
end

function WorldMap:draw()
  if not self.visible then return end

  Window.draw_rectangle(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, {0, 0, 0, 0.5})
  for i = self.current_col - 4, self.current_col + 4 do
    for j = self.current_row - 4, self.current_row + 4 do
      local scene = self.scenes[i] and self.scenes[i][j]
      if scene then
        local x = (i + 4) * TILES_X
        local y = (j + 4) * TILES_Y
        for k = 1, TILES_X do
          for l = 1, TILES_Y do
            if scene:is_wall(k, l) then
              Window.draw_rectangle(x + k - 1, y + l - 1, 1, 1)
            end
          end
        end
      end
    end
  end
end
