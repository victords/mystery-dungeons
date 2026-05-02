require("src.object.index")

Exit = {}
Exit.__index = Exit

function Exit.new(col, row, dest_scene, dest_entrance)
  if type(col) == "table" then
    row = col[2]
    dest_scene = col[3]
    dest_entrance = col[4]
    col = col[1]
  end
  local self = setmetatable({}, Exit)
  self.col = col
  self.row = row
  self.x = col == TILES_X and SCREEN_WIDTH - 1 or (col - 1) * TILE_SIZE
  self.y = row == TILES_Y and SCREEN_HEIGHT - 1 or (row - 1) * TILE_SIZE
  self.w = (col == 1 or col == TILES_X) and 1 or TILE_SIZE
  self.h = (row == 1 or row == TILES_Y) and 1 or TILE_SIZE
  self.dir = row == 1 and 0 or (col == TILES_X and 1 or (row == TILES_Y and 2 or 3))
  self.dest_scene = dest_scene
  self.dest_entrance = dest_entrance
  return self
end

Scene = {}
Scene.__index = Scene

function Scene.new(id, editor, map_col, map_row, save_data)
  local self = setmetatable({}, Scene)
  self.id = id
  self.editor = editor
  self.map_col = map_col or 1
  self.map_row = map_row or 1
  self.tiles = {}
  for i = 1, TILES_X do
    self.tiles[i] = {}
  end
  self.tileset = Res.tileset("walls", 4, 4)
  self.objects = {}
  self.object_layers = {}
  self.solids = {}
  self.triggers = {}
  self.triggered_by = {}
  self.pushables = {}
  self.entrances = {}
  self.exits = {}
  self.ramps = {}

  local content = love.filesystem.read("data/scene/" .. id .. ".txt")
  if content == nil and editor then return self end

  local lines = Utils.split(content, "\r\n")
  for j, line in ipairs(lines) do
    if j == 1 and line ~= "_" then
      for _, e in ipairs(Utils.split(line, "|")) do
        table.insert(self.entrances, Utils.map(Utils.split(e, ","), tonumber))
      end
    elseif j == 2 and line ~= "_" then
      for _, e in ipairs(Utils.split(line, "|")) do
        table.insert(self.exits, Exit.new(Utils.map(Utils.split(e, ","), tonumber)))
      end
    elseif j == 3 and line ~= "_" then
      obj_data = Utils.map(Utils.split(line, "|"), function (o) return Utils.split(o, ",") end)
      for _, data in ipairs(obj_data) do
        local rest = {}
        for i = 4, #data do table.insert(rest, data[i]) end
        local object_id = #self.objects + 1
        local obj = _G[data[1]].new(object_id, tonumber(data[2]), tonumber(data[3]), rest)
        obj.class_name = data[1]
        table.insert(self.objects, obj)
        if obj:is_trigger() then table.insert(self.triggers, obj) end
        if obj.solid then table.insert(self.solids, obj) end
        if obj.pushable then table.insert(self.pushables, obj) end
        if obj.triggered_by_id then
          self.triggered_by[obj.triggered_by_id] = self.triggered_by[obj.triggered_by_id] or {}
          table.insert(self.triggered_by[obj.triggered_by_id], obj)
        end
        if save_data then
          obj:deserialize(save_data[object_id])
        end
        self:ensure_object_layer(obj.layer)
        table.insert(self.object_layers[obj.layer], obj)
      end
    elseif j > 3 then
      local row = j - 3
      for col = 1, #line do
        local char = line:sub(col, col)
        if char ~= "_" then
          self.tiles[col][row] = char == "/" and -1 or 0
        end
      end
    end
  end

  for i = 1, TILES_X do
    for j = 1, TILES_Y do
      self:set_wall_tile(i, j)
    end
  end

  self.canvas = love.graphics.newCanvas(SCREEN_WIDTH, SCREEN_HEIGHT)
  if not editor then
    self.shader = Res.shader("main")
  end

  return self
end

function Scene:obstacles_for(obj)
  local col = math.floor((obj.x + obj.w * 0.5) / TILE_SIZE) + 1
  local row = math.floor((obj.y + obj.h * 0.5) / TILE_SIZE) + 1
  local min_col = col - 2 > 1 and col - 2 or 1
  local max_col = col + 2 < TILES_X and col + 2 or TILES_X
  local min_row = row - 2 > 1 and row - 2 or 1
  local max_row = row + 2 < TILES_Y and row + 2 or TILES_X

  local obstacles = {}
  for i = min_col, max_col do
    for j = min_row, max_row do
      if self:is_wall(i, j) then
        table.insert(obstacles, Block.new((i - 1) * TILE_SIZE, (j - 1) * TILE_SIZE, TILE_SIZE, TILE_SIZE))
      end
    end
  end
  for _, object in ipairs(self.objects) do
    if object.solid and object ~= obj then
      table.insert(obstacles, object)
    end
  end
  return obstacles
end

function Scene:add_light(obj, radius)
  local x = obj.x + obj.w * 0.5
  local y = obj.y + obj.h * 0.5
  table.insert(self.lights, {x, y, radius})
end

function Scene:check_triggers(obj)
  for _, trigger in ipairs(self.triggers) do
    if trigger:is_triggered(obj) then
      if not trigger:activate(obj) then return end
      if trigger.global_trigger_type then
        self.on_trigger(trigger.global_trigger_type, trigger.global_trigger_args)
        return
      end
      if self.triggered_by[trigger.trigger_id] == nil then return end

      for _, obj in ipairs(self.triggered_by[trigger.trigger_id]) do
        obj:on_trigger()
      end
    end
  end
end

function Scene:check_pushables(obj)
  local obj_bounds = obj:bounds()
  for _, pushable in ipairs(self.pushables) do
    if pushable:bounds():intersect(obj_bounds) then
      pushable:move(obj.speed, self:obstacles_for(pushable), self.ramps, true)
      if pushable:bounds():intersect(obj_bounds) then
        if obj.speed.x > 0 then
          obj.x = pushable.x - obj.w
        elseif obj.speed.x < 0 then
          obj.x = pushable.x + pushable.w
        elseif obj.speed.y > 0 then
          obj.y = pushable.y - obj.h
        elseif obj.speed.y < 0 then
          obj.y = pushable.y + pushable.h
        end
      end
      break
    end
  end
end

function Scene:get_save_data()
  return Utils.map(self.objects, function (obj) return obj:serialize() end)
end

function Scene:update()
  if KB.pressed("r") then
    self.on_reset()
    return
  end

  self.lights = {}
  for _, obj in ipairs(self.objects) do obj:update(self) end
end

function Scene:draw()
  Window.set_canvas(self.canvas)
  love.graphics.clear(BG_COLOR)

  for i = 1, TILES_X do
    for j = 1, TILES_Y do
      if self:is_wall(i, j) then
        self.tileset[self.tiles[i][j] + 1]:draw((i - 1) * TILE_SIZE, (j - 1) * TILE_SIZE)
      end
    end
  end

  for i = 1, TILES_X + 1 do
    for j = 1, TILES_Y + 1 do
      local tl = i == 1 or j == 1 or self.tiles[i - 1][j - 1]
      local tr = i == TILES_X + 1 or j == 1 or self.tiles[i][j - 1]
      local bl = i == 1 or j == TILES_Y + 1 or self.tiles[i - 1][j]
      local br = i == TILES_X + 1 or j == TILES_Y + 1 or self.tiles[i][j]
      if tl and tr and bl and br then
        Window.draw_rectangle((i - 1.5) * TILE_SIZE, (j - 1.5) * TILE_SIZE, 1, TILE_SIZE, TILE_SIZE, BG_COLOR)
      end
    end
  end

  for _, objs in ipairs(self.object_layers) do
    for _, obj in ipairs(objs) do obj:draw() end
  end

  if self.editor then return end

  if self.shader then
    self.shader:send("light_sources", unpack(self.lights))
    self.shader:send("light_source_count", #self.lights)
  end

  Window.set_canvas()
  Window.draw_canvas(self.canvas, 0, 0, 1, nil, 1, 1, self.shader)
end

function Scene:ensure_object_layer(layer)
  for i = 1, layer do
    self.object_layers[i] = self.object_layers[i] or {}
  end
end

function Scene:is_wall(i, j)
  return self.tiles[i][j] and self.tiles[i][j] >= 0
end

function Scene:set_wall_tile(i, j)
  if not self:is_wall(i, j) then return end

  local up = (j == 1 or self:is_wall(i, j - 1)) and 1 or 0
  local rt = (i == TILES_X or self:is_wall(i + 1, j)) and 2 or 0
  local dn = (j == TILES_Y or self:is_wall(i, j + 1)) and 4 or 0
  local lf = (i == 1 or self:is_wall(i - 1, j)) and 8 or 0
  self.tiles[i][j] = up + rt + dn + lf
end
