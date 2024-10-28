module TriggerActivator
  def check_triggers(scene)
    scene.triggers.each do |trigger|
      next if trigger.active?

      scene.on_trigger(trigger, self) if trigger.bounds.intersect?(bounds)
    end
  end
end
