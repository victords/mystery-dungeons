Box = setmetatable({}, BaseObject)
Box.__index = Box

function Box.new(col, row, args)
  local self = BaseObject.new(col, row, args, 0, 0, TILE_SIZE, TILE_SIZE, "object/box")
  setmetatable(self, Box)
  Utils.include(self, TriggerActivator)
  return self
end

function Box:update(scene)
  scene:check_triggers(self)
end
