class BaseObject < GameObject
  attr_reader :col, :row, :args

  def initialize(col, row, args, *rest)
    @col = col
    @row = row
    @args = args
    super(*rest)
  end

  def update(_scene); end

  def solid?; false; end

  def trigger?; false; end

  def triggered_by_id; nil; end
end
