AttractionPt_SuspBrothelHat = AttractionPt_SuspBrothelHat or {}
AttractionPt = AttractionPt or {}
setmetatable(AttractionPt_SuspBrothelHat, {__index = AttractionPt})

function AttractionPt_SuspBrothelHat:OnEnter()
end

function AttractionPt_SuspBrothelHat:OnExit()
end

function AttractionPt_SuspBrothelHat:OnActorEnter(actorHandle, nState)
  if self.SMEDTable.PairedAttrPt and self.SMEDTable.PairedAttrPtUser then
    Actor.CancelAttrPt(self.SMEDTable.PairedAttrPtUser, true)
    Actor.UseAttrPt(self.SMEDTable.PairedAttrPtUser, self.SMEDTable.PairedAttrPt)
  end
  if self.SMEDTable.SecondaryAttrPt and self.SMEDTable.SecondaryAttrPtUser then
    Actor.CancelAttrPt(self.SMEDTable.SecondaryAttrPtUser, true)
    Actor.RequestAttrPt(self.SMEDTable.SecondaryAttrPtUser, self.SMEDTable.SecondaryAttrPt)
  end
end

function AttractionPt_SuspBrothelHat:OnActorIdleBegin(actorHandle, nState)
  local e = {EventType = "TimerEvent", Time = 3.5}
  Util.CreateEvent(e, "AttractionPt_SuspBrothelHat.PlayGiggle")
end

function AttractionPt_SuspBrothelHat:PlayGiggle()
  Sound.PlayOwnerlessSoundEvent("E3_2009_P1M1_girlGiggle")
end

function AttractionPt_SuspBrothelHat:OnActorOutOfBegin(actorHandle, nState)
  if self.SMEDTable.PairedAttrPtUser then
    Actor.CancelAttrPt(self.SMEDTable.PairedAttrPtUser)
  end
  if self.SMEDTable.SecondaryAttrPtUser then
    Actor.CancelAttrPt(self.SMEDTable.SecondaryAttrPtUser)
  end
end

function AttractionPt_SuspBrothelHat:OnActorComplete(actorHandle, nState)
end
