class BaseObject < GameObject
  attr_reader :col
  attr_reader :row

  def initialize(col, row, *rest)
    @col = col
    @row = row
    super(*rest)
  end

  def update(_scene); end

  def solid?; false; end

  def trigger?; false; end

  def triggered_by_id; nil; end
end
