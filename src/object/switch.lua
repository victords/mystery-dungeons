Switch = setmetatable({}, Trigger)
Switch.__index = Switch

function Switch.new(col, row, args)
  local self = Trigger.new(col, row, args, col * TILE_SIZE + 4, row * TILE_SIZE + 4, 2, 2, "object/switch", Vector.new(-3, -3), 2, 1)
  setmetatable(self, Switch)
  return self
end

function Switch:activate(activator)
  self.img_index = 1
  Trigger.activate(self, activator)
end
