OutOfBoundsDeathZone = OutOfBoundsDeathZone or {}
Trigger = Trigger or {}
setmetatable(OutOfBoundsDeathZone, {__index = Trigger})

function OutOfBoundsDeathZone:OnEnter(a_hController)
end

function OutOfBoundsDeathZone:OnTriggerEnter(a_hActor)
  if a_hActor ~= hSab then
    Util.Assert(a_hActor == hSab, "This out of bounds zone is not set to player-only!  I do not approve!")
    return
  end
  CodeCallBackMissionTaskFail("Global.OutOfBoundsFail")
end
