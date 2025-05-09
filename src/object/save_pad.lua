SavePad = setmetatable({}, Trigger)
SavePad.__index = SavePad

function SavePad.new(id, col, row, args)
  local self = Trigger.new(id, col, row, args, 0, 0, TILE_SIZE, TILE_SIZE, "object/save_pad")
  setmetatable(self, SavePad)
  self.shader = love.graphics.newShader("shaders/pulse.glsl")
  self.timer = 0
  self.trigger_on_touch = false
  self.trigger_key = "space"
  self.global_trigger_type = "save"
  return self
end

function SavePad:activate(_activator)
  return true
end

function SavePad:update(scene)
  self.timer = self.timer + love.timer.getDelta()
  if self.timer > 2 then
    self.timer = self.timer - 4
  end
  self.shader:send("time", self.timer)
end

function SavePad:draw()
  love.graphics.setShader(self.shader)
  GameObject.draw(self)
  love.graphics.setShader()
end
