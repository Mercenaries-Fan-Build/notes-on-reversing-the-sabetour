AttractionPt_SuspBrothelDLC = AttractionPt_SuspBrothelDLC or {}
AttractionPt = AttractionPt or {}
setmetatable(AttractionPt_SuspBrothelDLC, {__index = AttractionPt})

function AttractionPt_SuspBrothelDLC:OnEnter()
end

function AttractionPt_SuspBrothelDLC:OnExit()
end

function AttractionPt_SuspBrothelDLC:OnActorEnter(actorHandle, nState)
  if self.SMEDTable.PairedAttrPt and self.SMEDTable.PairedAttrPtUser then
    Actor.CancelAttrPt(self.SMEDTable.PairedAttrPtUser, true)
    Actor.UseAttrPt(self.SMEDTable.PairedAttrPtUser, self.SMEDTable.PairedAttrPt)
  end
  if self.SMEDTable.SecondaryAttrPt and self.SMEDTable.SecondaryAttrPtUser then
    Actor.CancelAttrPt(self.SMEDTable.SecondaryAttrPtUser, true)
    Actor.RequestAttrPt(self.SMEDTable.SecondaryAttrPtUser, self.SMEDTable.SecondaryAttrPt)
  end
end

function AttractionPt_SuspBrothelDLC:OnActorIdleBegin(actorHandle, nState)
  local e = {EventType = "TimerEvent", Time = 3.5}
  Util.CreateEvent(e, "AttractionPt_SuspBrothelDLC.PlayGiggle")
end

function AttractionPt_SuspBrothelDLC:PlayGiggle()
  Sound.PlayOwnerlessSoundEvent("E3_2009_P1M1_girlGiggle")
end

function AttractionPt_SuspBrothelDLC:OnActorOutOfBegin(actorHandle, nState)
  if self.SMEDTable.PairedAttrPtUser then
    Actor.CancelAttrPt(self.SMEDTable.PairedAttrPtUser)
  end
  if self.SMEDTable.SecondaryAttrPtUser then
    Actor.CancelAttrPt(self.SMEDTable.SecondaryAttrPtUser)
  end
end

function AttractionPt_SuspBrothelDLC:OnActorComplete(actorHandle, nState)
end
