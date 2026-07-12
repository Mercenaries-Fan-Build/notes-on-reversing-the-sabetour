if not Soldier then
  Soldier = {}
end

function Soldier:CombatState_Enter(a_vTarget)
  local hTarget = a_vTarget
  if hTarget ~= nil then
    hTarget = Tips.CheckForHandle(a_vTarget)
  else
    Soldier.PrintToConsole(self, "CombatState_Enter() hTarget is nil, defaulting to Saboteur's handle")
    hTarget = Util.GetHandleByName("Saboteur")
  end
  Soldier.PrintToConsole(self, "Entering COMBAT State")
  Actor.CancelAnimation(self.hController)
  if Actor.IsUsingAttrPt(self.hController) then
    Soldier.PrintToConsole(self, "Soldier is using attraction point. Exiting attraction point")
    Actor.CancelAttrPt(self.hController)
  end
  Nav.CancelScriptedPath(self.hController)
  Nav.StopMoving(self.hController)
  Combat.SetCombat(self.hController)
  Combat.SetStationary(self.hController, self.SMEDTable.bIsTurret)
  Combat.SetTarget(self.hController, hTarget)
  Combat.SetFriendlyFire(self.hController, false)
  Combat.SetAutoFire(self.hController, true)
  Suspicion.SetState(self.hController, "Red")
  Soldier.PrintToConsole(self, "Letting other Nazis nearby know that a target has been spotted")
  Util.BroadcastFunction(self.hController, cDISTANCE_YELL, "OnHeardFriendlyEnterCombat", {
    self.hController
  })
  local tCanSeeSoldier = Sensory.GetAllCanSee(self.hController)
  if tCanSeeSoldier ~= nil then
    for i = 1, #tCanSeeSoldier do
      if Actor.HasLabel(tCanSeeSoldier[i], "Nazi") then
        Soldier.PrintToConsole(self, "(" .. Util.GetNameFromHandle(tCanSeeSoldier[i]) .. ") has seen the soldier go into combat!")
        Util.BroadcastFunction(tCanSeeSoldier[i], "AttackTarget", {hTarget})
      end
    end
  end
  if self.SMEDTable.bHasWhistle == true and self.bHasDroppedWhistle == false then
    Soldier.PrintToConsole(self, "Soldier is attempting to blow the whistle")
    Util.CreateEvent({
      EventType = "TimerEvent",
      Time = math.random(2, 7)
    }, "Soldier.BlowWhistleEvent", self)
  end
end

function Soldier:CombatState_Exit()
  Soldier.PrintToConsole(self, "Exiting COMBAT State")
end
