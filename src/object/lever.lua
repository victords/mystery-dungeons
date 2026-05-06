Lever = setmetatable({}, Trigger)
Lever.__index = Lever

function Lever.new(id, col, row, args)
  local self = Trigger.new(id, col, row, args, 4, 0, 9, 12, "object/lever" .. (args[2] or "1"), nil, 2, 1)
  setmetatable(self, Lever)
  self.trigger_on_touch = false
  self.trigger_key = "space"
  return self
end

function Lever:activate(activator)
  self.img_index = self.img_index % 2 + 1
  return true
end
