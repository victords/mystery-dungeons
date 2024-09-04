class Trigger < BaseObject
  attr_reader :id

  def initialize(args, x, y, w, h, img, cols = 1, rows = 1, img_gap: Vector.new)
    @id = args[0]
    super(x, y, w, h, img, cols, rows, img_gap: img_gap)
  end

  def trigger?; true; end

  def activate
    @active = true
  end

  def active?
    @active
  end
end
