AttractionPt_SuspKiss = AttractionPt_SuspKiss or {}
AttractionPt = AttractionPt or {}
setmetatable(AttractionPt_SuspKiss, {__index = AttractionPt})

function AttractionPt_SuspKiss:OnEnter()
end

function AttractionPt_SuspKiss:OnExit()
end

function AttractionPt_SuspKiss:OnActorEnter(actorHandle, nState)
  if self.SMEDTable.PairedAttrPt and self.SMEDTable.PairedAttrPtUser then
    Actor.CancelAttrPt(self.SMEDTable.PairedAttrPtUser, true)
    Actor.RequestAttrPt(self.SMEDTable.PairedAttrPtUser, self.SMEDTable.PairedAttrPt)
    Actor.SetPanicEnabled(self.SMEDTable.PairedAttrPtUser, false)
    Actor.SetReactorEnabled(self.SMEDTable.PairedAttrPtUser, false)
    Object.SetInvincible(self.SMEDTable.PairedAttrPtUser, true)
    Actor.SetNonKnockdownable(self.SMEDTable.PairedAttrPtUser, true)
  end
end

function AttractionPt_SuspKiss:OnActorIdleBegin(actorHandle, nState)
end

function AttractionPt_SuspKiss:OnActorOutOfBegin(actorHandle, nState)
  if self.SMEDTable.PairedAttrPtUser then
    Actor.CancelAttrPt(self.SMEDTable.PairedAttrPtUser)
    Actor.SetPanicEnabled(self.SMEDTable.PairedAttrPtUser, true)
    Actor.SetReactorEnabled(self.SMEDTable.PairedAttrPtUser, true)
    Object.SetInvincible(self.SMEDTable.PairedAttrPtUser, false)
    Actor.SetNonKnockdownable(self.SMEDTable.PairedAttrPtUser, false)
    if Actor.IsDisguised(actorHandle) then
      AttractionPt.SetAnimation(self.hController, cATTRPT_ONOUTOFENTER, "Mel_kiss_to_stop1")
      AttractionPt.SetAnimation(self.SMEDTable.PairedAttrPt, cATTRPT_ONOUTOFENTER, "Mel_v_kiss_to_stop1")
    end
  end
end

function AttractionPt_SuspKiss:OnActorComplete(actorHandle, nState)
end
