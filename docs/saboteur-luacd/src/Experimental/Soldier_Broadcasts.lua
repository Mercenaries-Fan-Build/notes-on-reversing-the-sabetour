if not Soldier then
  Soldier = {}
end

function Soldier:OnHeardAlarm(a_hAlarm, a_hAlarmPusher)
  if self.State == cSTATE_COMBAT then
    return
  end
  if self.bRespondsToAlarms == false then
    return
  end
  Soldier.PrintToConsole(self, "HEARD (Alarm)")
  local x, y, z = Object.GetPosition(self.hController)
  Soldier.HuntLocation(self.hController, x, y, z, true)
end

function Soldier:OnHeardWhistle(a_hWhistleBlower)
  if self.State == cSTATE_COMBAT then
    return
  end
  if self.bRespondsToAlarms == false then
    return
  end
  Soldier.PrintToConsole(self, "HEARD (Whistle)")
  local x, y, z = Object.GetPosition(a_hWhistleBlower)
  Soldier.HuntLocation(self.hController, x, y, z, true)
end

function Soldier:OnHeardFriendlyDamage(a_hFriendly, a_hAttacker)
  if self.hController == a_hFriendly then
    return
  end
  if a_hAttacker == nil or Tips.IsUserdataZero(a_hAttacker) then
    Soldier.InvestigateThreat(self.hController, a_hFriendly)
    return
  end
  if Actor.HasLabel(a_hAttacker, "Nazi") == false then
    Soldier.AttackTarget(self, a_hAttacker)
  end
end

function Soldier:OnHeardFriendlyEnterCombat(a_hYeller)
  if self.State == cSTATE_COMBAT then
    return
  end
  if Actor.IsInVehicle(self.hController) then
    return
  end
  Nav.StopMoving(self.hController)
  local nDistanceFromYeller = Actor.GetActorDist(a_hYeller, self.hController)
  local hEnemy = Combat.GetTarget(a_hYeller)
  if hEnemy ~= nil then
    Soldier.AttackTarget(self, hEnemy)
  end
end

function Soldier:OnHeardThreateningSound(a_hSoundSource)
  if self.SMEDTable.bRespondsToGunfire == false and self.SMEDTable.bRespondsToGunfire ~= nil then
    return
  end
  if self.State == cSTATE_COMBAT then
    return
  end
  if Actor.IsInVehicle(self.hController) == true then
    return
  end
  Soldier.PrintToConsole(self, "Soldier has heard (" .. Util.GetNameFromHandle(a_hSoundSource) .. ") broadcast a threatening sound")
  if Actor.IsUsingAttrPt(self.hController) then
    Soldier.PrintToConsole(self, "Soldier is using attraction point. Cancelling usage")
    Actor.CancelAttrPt(self.hController)
  end
  if Actor.HasLabel(a_hSoundSource, "Nazi") then
    Soldier.PrintToConsole(self, "Soldier has heard another Nazi fire his weapon. Grabbing his target.")
    local hNaziTarget = Combat.GetTarget(a_hSoundSource)
    if hNaziTarget ~= nil and Sensory.CanSee(self.hController, hNaziTarget) == true then
      Soldier.AttackTarget(self, hNaziTarget)
      return
    end
  end
  local tArgs = {}
  tArgs.hSoundSource = a_hSoundSource
  Soldier.EnterState(self, cSTATE_INVESTIGATE_THREAT, tArgs)
end

function Soldier:OnHeardExplosion(a_hSoundSource)
  Soldier.PrintToConsole(self, "HEARD (Explosion)")
  if self.SMEDTable.bRespondsToExplosions == false and self.SMEDTable.bRespondsToExplosions ~= nil then
    return
  end
  Soldier.PrintToConsole(self, "Passed explosion check!")
  local nDistFromSource = Actor.GetActorDist(self.hController, a_hSoundSource)
  if nDistFromSource < 20 then
    local tExplosionReactionSequence = {
      {
        "PLAYANIMATION",
        {
          "civ_cower_idle"
        }
      },
      {
        "DELAYFORRANDOM",
        {1, 3}
      },
      {
        "CANCELANIMATION"
      },
      {
        "BROADCASTTOSELF",
        {
          "OnHeardThreateningSound",
          {a_hSoundSource}
        }
      }
    }
    ScriptSequence.Run(self.hController, tExplosionReactionSequence)
  else
    NewSoldierPrintToConsole(self, "Running Threatening Sound!!")
    Soldier.OnHeardThreateningSound(self, a_hSoundSource)
  end
end

function Soldier:OnHeardInterestingSound(a_hSoundSource)
  Render.PrintDialogue(self.hController, "I've heard an interesting sound!", 3)
end

function Soldier:OnVehicleEnter(a_hVehicle)
end

function Soldier:OnVehicleExit(a_hVehicle)
end

function Soldier:OnChangeScript(a_sNewScriptName)
  Actor.ChangeModule(self.hController, a_sNewScriptName)
end
