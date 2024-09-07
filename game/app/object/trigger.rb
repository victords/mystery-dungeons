class Trigger < BaseObject
  attr_reader :id

  def initialize(col, row, args, *rest)
    @id = args[0]
    super(col, row, args, *rest)
  end

  def trigger?; true; end

  def activate
    @active = true
  end

  def active?
    @active
  end
end
