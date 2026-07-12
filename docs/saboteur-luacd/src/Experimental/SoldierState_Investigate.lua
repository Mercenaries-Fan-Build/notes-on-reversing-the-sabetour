if not Soldier then
  Soldier = {}
end

function Soldier:InvestigateState_Enter()
  Soldier.PrintToConsole(self, "Entering INVESTIGATE State")
  Soldier.PrintToConsole(self, "Setting up event to look for OnPaperCheckSuccess")
  self.hPaperCheckSuccessEvent = Util.CreateEvent({
    EventType = "OnPaperCheckSuccess",
    Target = Util.GetHandleByName("Saboteur")
  }, "Soldier.OnPaperCheckTargetDismissal", self)
  self.hPaperCheckFailEvent = Util.CreateEvent({
    EventType = "OnPaperCheckFail",
    Target = Util.GetHandleByName("Saboteur")
  }, "Soldier.OnPaperCheckTargetFail", self)
  local tCanSeeSoldier = Sensory.GetAllCanSee(self.hController)
  local bShouldWave = false
  if tCanSeeSoldier ~= nil then
    for i = 1, #tCanSeeSoldier do
      if Actor.HasLabel(tCanSeeSoldier[i], "Nazi") then
        local tActorSelf = Actor.GetSelf(tCanSeeSoldier[i])
        if tActorSelf.State == cSTATE_IDLE then
          local nRelativeFacing = Tips.GetRelativeFacing(self.hController, tCanSeeSoldier[i])
          if 90 < nRelativeFacing and nRelativeFacing < 170 then
            bShouldWave = true
          end
          local dist = Actor.GetActorDist(self.hController, tCanSeeSoldier[i])
          if dist < 10 then
            Suspicion.SetState(tCanSeeSoldier[i], "Yellow")
          end
        end
      end
    end
  end
  if bShouldWave == true then
    local tSequence = {
      {
        "PLAYANIMATION",
        {"nazi_point"}
      },
      {
        "DELAY",
        {0.9}
      },
      {
        "PLAYANIMATION",
        {
          "shrd_M_LH_wave_alert"
        }
      }
    }
    ScriptSequence.Run(self.hController, tSequence)
  end
  Util.BroadcastFunction(self.hController, 2, "SetSuspicion", {"Yellow"}, "Nazi")
end

function Soldier:InvestigateState_Exit()
  Soldier.PrintToConsole(self, "Exiting INVESTIGATE State")
  Util.KillEvent(self.hPaperCheckSuccessEvent)
  self.hPaperCheckSuccessEvent = nil
  Util.KillEvent(self.hPaperCheckFailEvent)
  self.hPaperCheckFailEvent = nil
end
