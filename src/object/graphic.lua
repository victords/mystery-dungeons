Graphic = setmetatable({}, BaseObject)
Graphic.__index = Graphic

function Graphic.new(id, col, row, args)
  local type = args[1]
  -- TODO offsets depending on type
  local offset_x = 0
  local offset_y = 0
  local self = BaseObject.new(id, col, row, args, offset_x, offset_y, 1, 1, "graphic/" .. type)
  setmetatable(self, Graphic)
  return self
end
