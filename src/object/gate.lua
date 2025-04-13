Gate = setmetatable({}, BaseObject)
Gate.__index = Gate

function Gate.new(col, row, args)
  local self = BaseObject.new(col, row, args, 0, 0, TILE_SIZE, TILE_SIZE, "object/gate", Vector.new(), 2, 2)
  setmetatable(self, Gate)
  self.solid = true
  self.triggered_by_id = args[1]
  return self
end

function Gate:on_trigger(_trigger, _activator)
  self.solid = false
end

function Gate:update(scene)
  if self.solid then return end

  self:animate_once({2, 3, 4}, 7)
end
