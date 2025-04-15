Box = setmetatable({}, BaseObject)
Box.__index = Box

function Box.new(col, row, args)
  local self = BaseObject.new(col, row, args, 1, 1, TILE_SIZE - 2, TILE_SIZE - 2, "object/box")
  setmetatable(self, Box)
  self.pushable = true
  return self
end

function Box:update(scene)
  scene:check_triggers(self)
end
