Switch = setmetatable({}, Trigger)
Switch.__index = Switch

function Switch.new(id, col, row, args)
  local self = Trigger.new(id, col, row, args, 7, 7, 2, 2, "object/switch" .. (args[2] or "1"), Vector.new(-5, -5), 2, 1)
  setmetatable(self, Switch)
  self.serializable_attrs = {"img_index", "active"}
  return self
end

function Switch:activate(activator)
  self.img_index = 2
  return Trigger.activate(self, activator)
end
