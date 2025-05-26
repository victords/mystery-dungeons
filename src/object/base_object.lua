require("src.serializable")

BaseObject = setmetatable({}, GameObject)
BaseObject.__index = BaseObject

Utils.include(BaseObject, Serializable)

function BaseObject.new(id, col, row, args, offset_x, offset_y, w, h, img_path, img_gap, cols, rows)
  local x = (col - 1) * TILE_SIZE
  local y = (row - 1) * TILE_SIZE
  local self
  if img_path then
    self = GameObject.new(x + offset_x, y + offset_y, w, h, img_path, img_gap, cols, rows)
    setmetatable(self, BaseObject)
  else
    self = setmetatable({}, BaseObject)
    self.x = x + offset_x
    self.y = y + offset_y
  end

  self.id = id
  self.col = col
  self.row = row
  self.args = args
  self.solid = false
  self.layer = 1
  return self
end

function BaseObject:update(_scene) end

function BaseObject:is_trigger()
  return false
end
