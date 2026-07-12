NoBirdZone = NoBirdZone or {}
Trigger = Trigger or {}
setmetatable(NoBirdZone, {__index = Trigger})

function NoBirdZone:OnEnter(a_hController)
end

function NoBirdZone:OnTriggerEnter(a_hActor)
  if a_hActor ~= hSab then
    Util.Assert(a_hActor == hSab, "This no bird zone is not set to player-only!  I do not approve!")
    return
  end
  Util.EnableBirds(false)
end

function NoBirdZone:OnTriggerExit(a_hActor)
  if a_hActor ~= hSab then
    Util.Assert(a_hActor == hSab, "This no bird zone is not set to player-only!  I do not approve!")
    return
  end
  Util.EnableBirds(true)
end

function NoBirdZone:OnExit(a_hActor)
  Util.EnableBirds(true)
end
