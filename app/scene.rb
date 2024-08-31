class Scene
  attr_reader :obstacles

  def initialize
    @obstacles = [
      Block.new(0, -1, Window.width, 1),
      Block.new(-1, 0, 1, Window.height),
      Block.new(Window.width, 0, 1, Window.height),
      Block.new(0, Window.height, Window.width, 1),
    ]
  end

  def draw
    # TODO
  end
end
