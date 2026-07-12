RedZone = RedZone or {}
Trigger = Trigger or {}
setmetatable(RedZone, {__index = Trigger})

function RedZone:OnEnter(a_hController)
  Trigger.CreateRedZone(a_hController)
end

function RedZone:OnTriggerEnter(a_hActor)
  if a_hActor ~= hSab then
    Util.Assert(a_hActor == hSab, "This red zone is not set to player-only!  I do not approve!")
    return
  end
end

function RedZone:OnTriggerExit(a_hActor)
  if a_hActor ~= hSab then
    Util.Assert(a_hActor == hSab, "This red zone is not set to player-only!  I do not approve!")
    return
  end
end
