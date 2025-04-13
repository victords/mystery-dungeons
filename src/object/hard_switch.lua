HardSwitch = setmetatable({}, Trigger)
HardSwitch.__index = HardSwitch

function HardSwitch.new(col, row, args)
  local self = Trigger.new(col, row, args, 4, 4, 2, 2, "object/hard_switch", Vector.new(-3, -3), 2, 1)
  setmetatable(self, HardSwitch)
  return self
end

function HardSwitch:activate(activator)
  if getmetatable(activator) ~= Box then
    return false
  end

  self.img_index = 2
  return Trigger.activate(self, activator)
end
