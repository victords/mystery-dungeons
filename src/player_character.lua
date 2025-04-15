PlayerCharacter = setmetatable({}, GameObject)
PlayerCharacter.__index = PlayerCharacter

function PlayerCharacter.new()
  local self = GameObject.new(0, 0, 6, 6, "char", Vector.new(-1, -1))
  setmetatable(self, PlayerCharacter)
  self.angle = 0
  return self
end

function PlayerCharacter:set_position(col, row)
  self.x = (col - 1) * TILE_SIZE + 2
  self.y = (row - 1) * TILE_SIZE + 2
end

function PlayerCharacter:update(scene)
  local forces = Vector.new()
  if KB.down("left") then
    forces.x = -1
    self.angle = -math.pi / 2
  elseif KB.down("right") then
    forces.x = 1
    self.angle = math.pi / 2
  elseif KB.down("up") then
    forces.y = -1
    self.angle = 0
  elseif KB.down("down") then
    forces.y = 1
    self.angle = math.pi
  end
  self:move(forces, scene:obstacles_for(self), scene.ramps, true)
  scene:add_light(self, 3)

  if self.on_exit then
    local exit_obj
    for _, e in ipairs(scene.exits) do
      if self:bounds():intersect(e) then
        exit_obj = e
        break
      end
    end
    if exit_obj then
      self.on_exit(exit_obj)
      return
    end
  end

  scene:check_triggers(self)
  scene:check_pushables(self)
end

function PlayerCharacter:draw()
  GameObject.draw(self, nil, nil, nil, self.angle, nil, nil, true)
end
