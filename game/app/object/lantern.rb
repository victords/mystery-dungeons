class Lantern < GameObject
  def initialize(col, row, _args)
    super(col * TILE_SIZE, row * TILE_SIZE, TILE_SIZE, TILE_SIZE, 'object/lantern', 3, 1, img_gap: Vector.new(-6, -6))
  end

  def update(scene)
    scene.add_light(self, 2)
    animate([0, 1, 2, 1], 10)
  end
end
