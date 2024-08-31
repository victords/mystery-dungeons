class PlayerCharacter < GameObject
  RAMPS = [].freeze

  def initialize
    super(0, 0, 8, 8, :char)
    @angle = 0
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
    move(forces, scene.obstacles, RAMPS, set_speed: true)
  end

  def draw
    super(angle: @angle, round: true)
  end
end
