class BaseObject < GameObject
  def update(_scene); end

  def solid?; false; end

  def trigger?; false; end

  def triggered_by_id; nil; end
end
