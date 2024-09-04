class BaseObject < GameObject
  def update(_scene); end

  def solid?; false; end

  def trigger?; false; end
end
