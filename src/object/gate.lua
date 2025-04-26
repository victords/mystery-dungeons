Gate = setmetatable({}, BaseObject)
Gate.__index = Gate

function Gate.new(col, row, args)
  local self = BaseObject.new(col, row, args, 0, 0, TILE_SIZE, TILE_SIZE, "object/gate", Vector.new(), 2, 2)
  setmetatable(self, Gate)
  self.solid = true
  self.triggered_by_id = args[1]
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
