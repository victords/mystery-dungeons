HardSwitch = setmetatable({}, Trigger)
HardSwitch.__index = HardSwitch

function HardSwitch.new(id, col, row, args)
  local self = Trigger.new(id, col, row, args, 7, 7, 2, 2, "object/hard_switch" .. (args[2] or "1"), Vector.new(-5, -5), 2, 1)
  setmetatable(self, HardSwitch)
  self.serializable_attrs = {"img_index", "active"}
  return self
end

function HardSwitch:activate(activator)
  if getmetatable(activator) ~= Box then
    return false
  end

  self.img_index = 2
  return Trigger.activate(self, activator)
end
