Trigger = setmetatable({}, BaseObject)
Trigger.__index = Trigger

function Trigger.new(col, row, args, offset_x, offset_y, w, h, img_path, img_gap, cols, rows)
  local self = BaseObject.new(col, row, args, offset_x, offset_y, w, h, img_path, img_gap, cols, rows)
  setmetatable(self, Trigger)
  self.id = args[1]
  self.trigger_on_touch = true
  return self
end

function Trigger:is_trigger()
  return true
end

function Trigger:is_triggered(activator)
  if self.active then return false end

  return self:bounds():intersect(activator:bounds()) and
         (self.trigger_on_touch or self.trigger_key and KB.pressed(self.trigger_key))
end

function Trigger:activate(_activator)
  self.active = true
  return true
end
