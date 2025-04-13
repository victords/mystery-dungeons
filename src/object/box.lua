require("src.traits.trigger_activator")

Box = setmetatable({}, BaseObject)
Box.__index = Box

function Box.new(col, row, args)
  local self = BaseObject.new(col, row, args, col * TILE_SIZE, row * TILE_SIZE, TILE_SIZE, TILE_SIZE, "object/box")
  setmetatable(self, Box)
  Utils.include(self, TriggerActivator)
  return self
end

function Box:update(scene)
  TriggerActivator.check_triggers(self, scene)
end
