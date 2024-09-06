class Graphic < BaseObject
  def initialize(col, row, args)
    type = args[0].to_i
    offset_x, offset_y =
      case type
      when 1 then [-5, -5]
      else        [0, 0]
      end
    super(col, row, col * TILE_SIZE + offset_x, row * TILE_SIZE + offset_y, 1, 1, "graphic/#{type}")
  end
end
