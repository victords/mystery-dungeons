NisledText = setmetatable({}, BaseObject)
NisledText.__index = NisledText

NisledText.font = Res.img_font("nisled", "abkdefghijlmnoprstuvxz1234567890 ", 1)

function NisledText.new(id, col, row, args)
  local center = args[2] == "c"
  local offset_x_index = center and 3 or 2
  local offset_y_index = center and 4 or 3
  local offset_x = args[offset_x_index] or 0
  local offset_y = args[offset_y_index] or 0
  local self = BaseObject.new(id, col, row, args, offset_x + (center and (0.5 * TILE_SIZE) or 0), offset_y)
  setmetatable(self, NisledText)
  self.text = args[1]
  self.center = center
  return self
end

function NisledText:draw()
  self.font:draw_text_rel(self.text, self.x, self.y, self.center and 0.5 or 0)
end
