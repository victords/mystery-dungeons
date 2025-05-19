Switch = setmetatable({}, Trigger)
Switch.__index = Switch

function Switch.new(id, col, row, args)
  local self = Trigger.new(id, col, row, args, 4, 4, 2, 2, "object/switch", Vector.new(-3, -3), 2, 1)
  setmetatable(self, Switch)
  self.serializable_attrs = {"img_index", "active"}
  return self
end

function Switch:activate(activator)
  self.img_index = 2
  return Trigger.activate(self, activator)
end
