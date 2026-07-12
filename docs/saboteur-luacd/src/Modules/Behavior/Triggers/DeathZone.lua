DeathZone = DeathZone or {}
Trigger = Trigger or {}
setmetatable(DeathZone, {__index = Trigger})

function DeathZone:OnEnter(a_hController)
end

function DeathZone:OnTriggerEnter(a_hActor)
  if a_hActor ~= hSab then
    Object.Kill(a_hActor)
    return
  end
  CodeCallBackMissionTaskFail("Global.DeathZone")
end
