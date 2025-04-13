class Graphic < BaseObject
  def initialize(col, row, args)
    type = args[0].to_i
    offset_x, offset_y = [0, 0] # TODO case type
    super(col, row, args, col * TILE_SIZE + offset_x, row * TILE_SIZE + offset_y, 1, 1, "graphic/#{type}")
  end
end
