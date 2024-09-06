class Switch < Trigger
  def initialize(col, row, args)
    super(col, row, args, col * TILE_SIZE + 4, row * TILE_SIZE + 4, 2, 2, 'object/switch', 2, 1, img_gap: Vector.new(-3, -3))
  end

  def activate
    @img_index = 1
    super
  end
end
