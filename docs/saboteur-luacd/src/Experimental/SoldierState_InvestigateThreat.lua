if not Soldier then
  Soldier = {}
end

function Soldier:InvestigateThreatState_Enter(a_tArgs)
  Soldier.PrintToConsole(self, "Entering INVESTIGATE THREAT state")
  Suspicion.SetState(self.hController, "YellowThreatInvestigate")
  Nav.CancelScriptedPath(self.hController)
  Nav.StopMoving(self.hController)
  local x, y, z = Object.GetPosition(a_tArgs.hSoundSource)
  Combat.SetInvestigate(self.hController, x, y, z, true, false, "Soldier.InvestigateThreatState_OnFail", self)
  local tCues = {
    "vo_nazi1_chatter_suspiciousnoise_01",
    "vo_nazi2_chatter_suspiciousnoise_01",
    "vo_nazi1_chatter_noisenoinvestigate_01",
    "vo_nazi2_chatter_noisenoinvestigate_01"
  }
  Soldier.Speak(self, tCues, 0.4, 1, true)
end

function Soldier.InvestigateThreat(a_vSoldier, a_vTarget)
  local tSoldierSelf = Actor.GetSelf(Tips.CheckForHandle(a_vSoldier))
  local tArgs = {}
  tArgs.hSoundSource = Tips.CheckForHandle(a_vTarget)
  Soldier.EnterState(tSoldierSelf, cSTATE_INVESTIGATE_THREAT, tArgs)
end

function Soldier:InvestigateThreatState_OnFail()
  Soldier.PrintToConsole(self, "Investigation of threatening sound FAILED")
  Suspicion.SetState(self.hController, "Green")
  local tCues = {
    "vo_nazi1_chatter_suspiciousnoisegiveup_01",
    "vo_nazi2_chatter_suspiciousnoisegiveup_01"
  }
  Soldier.Speak(self, tCues, 7, 1.5)
end

function Soldier:InvestigateThreatState_Exit(a_tArgs)
  Soldier.PrintToConsole(self, "Exiting INVESTIGATE THREAT state")
end
