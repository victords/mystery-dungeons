Lantern = setmetatable({}, BaseObject)
Lantern.__index = Lantern

function Lantern.new(col, row, args)
  local self = BaseObject.new(col, row, args, 0, 0, TILE_SIZE, TILE_SIZE, "object/lantern")
  setmetatable(self, Lantern)
  self.shader = love.graphics.newShader("shaders/lantern.glsl")
  self.shader:send("image_size", {self.img.width, self.img.height});
  self.timer = 0.0
  return self
end

function Lantern:update(scene)
  scene:add_light(self, 21)
  self.timer = self.timer + 0.2
  if self.timer > 2 * math.pi then
    self.timer = 0.0
  end
  self.shader:send("time", self.timer)
end

function Lantern:draw()
  love.graphics.setShader(self.shader)
  GameObject.draw(self)
  love.graphics.setShader()
end
