if not Soldier then
  Soldier = {}
end

function Soldier:PaperCheckBackupState_Enter(a_tArgs)
  Soldier.PrintToConsole(self, "Entering PAPER CHECK BACKUP state")
  local nFollowDistance = cSUSPICION_BACKUPFOLLOWDIST
  local nFollowDistanceVariance = cSUSPICION_BACKUPFOLLOWDIST_RANGE
  if math.random(1) == 1 then
    nFollowDistance = nFollowDistance + nFollowDistanceVariance * math.random()
  else
    nFollowDistance = nFollowDistance - nFollowDistanceVariance * math.random()
  end
  if a_tArgs ~= nil then
    Nav.FollowObject(self.hController, a_tArgs.hTarget, nFollowDistance, false)
  else
    Nav.FollowObject(self.hController, Util.GetHandleByName("Saboteur"), nFollowDistance, false)
  end
  Soldier.PrintToConsole(self, "Setting up event to look for OnPaperCheckSuccess")
  self.hPaperCheckSuccessEvent = Util.CreateEvent({
    EventType = "OnPaperCheckSuccess",
    Target = Util.GetHandleByName("Saboteur")
  }, "Soldier.OnPaperCheckTargetDismissal", self)
  self.hPaperCheckFailEvent = Util.CreateEvent({
    EventType = "OnPaperCheckFail",
    Target = Util.GetHandleByName("Saboteur")
  }, "Soldier.OnPaperCheckTargetFail", self)
end

function Soldier:OnPaperCheckTargetDismissal()
  Soldier.PrintToConsole(self, "Paper check leader has dismissed the target. Reverting to idle")
  Suspicion.SetState(self.hController, "Green")
  Suspicion.Suspend(self.hController, 5)
end

function Soldier:OnPaperCheckTargetFail()
  Soldier.PrintToConsole(self, "Player has failed paper check. Going into combat.")
  Soldier.AttackTarget(self)
end

function Soldier:ConfrontAssist(a_hTarget)
  local tArgs = {}
  tArgs.hTarget = a_hTarget
  Soldier.EnterState(self, cSTATE_PAPERCHECK_BACKUP, tArgs)
end

function Soldier:PaperCheckBackupState_Exit()
  Soldier.PrintToConsole(self, "Exiting PAPER CHECK BACKUP state")
  Nav.CancelFollowObject(self.hController)
  Util.KillEvent(self.hPaperCheckSuccessEvent)
  self.hPaperCheckSuccessEvent = nil
  Util.KillEvent(self.hPaperCheckFailEvent)
  self.hPaperCheckFailEvent = nil
end
