Lantern = setmetatable({}, BaseObject)
Lantern.__index = Lantern

function Lantern.new(col, row, args)
  local self = BaseObject.new(col, row, args, 0, 0, TILE_SIZE, TILE_SIZE, "object/lantern", Vector.new(-6, -6), 3, 1)
  setmetatable(self, Lantern)
  return self
end

function Lantern:update(scene)
  scene:add_light(self, 2)
  self:animate({1, 2, 3, 2}, 10)
end
