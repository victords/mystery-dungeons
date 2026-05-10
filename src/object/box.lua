Box = setmetatable({}, BaseObject)
Box.__index = Box

function Box.new(id, col, row, args)
  local self = BaseObject.new(id, col, row, args, 1, 1, TILE_SIZE - 2, TILE_SIZE - 2, "object/box" .. (args[1] or "1"), Vector.new(0, -4))
  setmetatable(self, Box)
  self.pushable = true
  self.layer = 2
  return self
end

function Box:update(scene)
  scene:check_triggers(self)
end
