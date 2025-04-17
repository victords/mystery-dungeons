Lantern = setmetatable({}, BaseObject)
Lantern.__index = Lantern

function Lantern.new(col, row, args)
  local self = BaseObject.new(col, row, args, 0, 0, TILE_SIZE, TILE_SIZE, "object/lantern")
  setmetatable(self, Lantern)
  self.shader = love.graphics.newShader("shaders/lantern.glsl")
  return self
end

function Lantern:update(scene)
  scene:add_light(self, 2)
end

function Lantern:draw()
  love.graphics.setShader(self.shader)
  GameObject.draw(self)
  love.graphics.setShader()
end
