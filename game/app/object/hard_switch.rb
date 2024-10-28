class HardSwitch < Trigger
  def initialize(col, row, args)
    super(col, row, args, col * TILE_SIZE + 4, row * TILE_SIZE + 4, 2, 2, 'object/hard_switch', 2, 1, img_gap: Vector.new(-3, -3))
  end

  def activate(activator)
    return false unless activator.is_a?(Box)

    @img_index = 1
    super(activator)
  end
end
