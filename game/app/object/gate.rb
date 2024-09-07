class Gate < BaseObject
  attr_reader :triggered_by_id

  def initialize(col, row, args)
    @triggered_by_id = args[0]
    @solid = true
    super(col, row, args, col * TILE_SIZE, row * TILE_SIZE, TILE_SIZE, TILE_SIZE, 'object/gate', 2, 2)
  end

  def solid?
    @solid
  end

  def on_trigger
    @solid = false
  end

  def update(_scene)
    return if @solid

    animate_once([1, 2, 3], 7)
  end
end
