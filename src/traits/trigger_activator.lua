TriggerActivator = {}
TriggerActivator.__index = TriggerActivator

function TriggerActivator:check_triggers(scene)
  for _, trigger in ipairs(scene.triggers) do
    if trigger:bounds():intersect(self:bounds()) and not trigger.active then
      scene:on_trigger(trigger, self)
    end
  end
end
