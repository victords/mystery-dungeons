Graphic = setmetatable({}, BaseObject)
Graphic.__index = Graphic

function Graphic.new(col, row, args)
  local type = args[1]
  -- TODO offsets depending on type
  local offset_x = 0
  local offset_y = 0
  local self = BaseObject.new(col, row, args, col * TILE_SIZE + offset_x, row * TILE_SIZE + offset_y, "graphic/" .. type)
  setmetatable(self, Graphic)
  return self
end
