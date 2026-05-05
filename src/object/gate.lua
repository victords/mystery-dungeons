Gate = setmetatable({}, BaseObject)
Gate.__index = Gate

function Gate.new(id, col, row, args)
  local self = BaseObject.new(id, col, row, args, 0, 0, TILE_SIZE, TILE_SIZE, "object/gate" .. args[1], Vector.new(-1, -1), 4, 1)
  setmetatable(self, Gate)
  self.triggered_by_id = args[2]
  self.vertical = args[3] == nil or not args[3]:find("h")
  self.solid = args[3] == nil or not args[3]:find("o")
  self.serializable_attrs = {"solid", "img_index"}
  if not self.solid then self.img_index = 4 end
  return self
end

function Gate:on_trigger()
  self.solid = not self.solid
  self.animation_indices = self.solid and {3, 2, 1} or {2, 3, 4}
  self:reset_animation()
end

function Gate:update(scene)
  if self.animation_indices == nil then return end

  self:animate_once(self.animation_indices, 7, function () self.animation_indices = nil end)
end

function Gate:draw()
  GameObject.draw(self, 1, 1, nil, self.vertical and 0 or math.pi * 0.5)
end
