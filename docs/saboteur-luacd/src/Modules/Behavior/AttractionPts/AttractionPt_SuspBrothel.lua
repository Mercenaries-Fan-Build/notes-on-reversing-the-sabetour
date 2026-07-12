AttractionPt_SuspBrothel = AttractionPt_SuspBrothel or {}
AttractionPt = AttractionPt or {}
setmetatable(AttractionPt_SuspBrothel, {__index = AttractionPt})

function AttractionPt_SuspBrothel:OnEnter()
end

function AttractionPt_SuspBrothel:OnExit()
end

function AttractionPt_SuspBrothel:OnActorEnter(actorHandle, nState)
end

function AttractionPt_SuspBrothel:OnActorIdleBegin(actorHandle, nState)
  local e = {EventType = "TimerEvent", Time = 3.5}
  Util.CreateEvent(e, "AttractionPt_SuspBrothel.PlayGiggle")
end

function AttractionPt_SuspBrothel:PlayGiggle()
  Sound.PlayOwnerlessSoundEvent("E3_2009_P1M1_girlGiggle")
end

function AttractionPt_SuspBrothel:OnActorOutOfBegin(actorHandle, nState)
end

function AttractionPt_SuspBrothel:OnActorComplete(actorHandle, nState)
end
