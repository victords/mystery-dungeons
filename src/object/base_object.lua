BaseObject = setmetatable({}, GameObject)
BaseObject.__index = BaseObject

function BaseObject.new(col, row, args, x, y, w, h, img_path, img_gap, cols, rows)
  local self = GameObject.new(x, y, w, h, img_path, img_gap, cols, rows)
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
