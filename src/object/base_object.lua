BaseObject = setmetatable({}, GameObject)
BaseObject.__index = BaseObject

function BaseObject.new(col, row, args, offset_x, offset_y, w, h, img_path, img_gap, cols, rows)
  local x = (col - 1) * TILE_SIZE
  local y = (row - 1) * TILE_SIZE
  local self = GameObject.new(x + offset_x, y + offset_y, w, h, img_path, img_gap, cols, rows)
  setmetatable(self, BaseObject)
  self.col = col
  self.row = row
  self.args = args
  self.solid = false
  return self
end

function BaseObject:update(_scene) end

function BaseObject:is_trigger()
  return false
end
