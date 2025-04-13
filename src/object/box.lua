require 'app/traits/trigger_activator'

class Box < BaseObject
  include TriggerActivator

  def initialize(col, row, args)
    super(col, row, args, col * TILE_SIZE, row * TILE_SIZE, TILE_SIZE, TILE_SIZE, 'object/box')
  end

  def update(scene)
    check_triggers(scene)
  end
end
