class PlayerCharacter < GameObject
  RAMPS = [].freeze

  attr_writer :on_exit

  def initialize
    super(0, 0, 6, 6, :char, img_gap: Vector.new(-1, -1))
    @angle = 0
  end

  def set_position(col, row)
    @x = col * TILE_SIZE + 2
    @y = row * TILE_SIZE + 2
  end

  def update(scene)
    forces = Vector.new
    if KB.key_down?(:left_arrow)
      forces.x = -1
      @angle = -90
    elsif KB.key_down?(:right_arrow)
      forces.x = 1
      @angle = 90
    elsif KB.key_down?(:up_arrow)
      forces.y = -1
      @angle = 0
    elsif KB.key_down?(:down_arrow)
      forces.y = 1
      @angle = 180
    end
    move(forces, scene.obstacles_for(self), RAMPS, set_speed: true)
    scene.add_light(self, 3)

    exit_obj = scene.exits.find { |e| bounds.intersect?(e) }
    if exit_obj
      @on_exit&.call(exit_obj)
      return
    end

    scene.triggers.each do |trigger|
      next if trigger.active?
      scene.on_trigger(trigger) if trigger.bounds.intersect?(bounds)
    end
  end

  def draw
    super(angle: @angle, round: true)
  end
end
