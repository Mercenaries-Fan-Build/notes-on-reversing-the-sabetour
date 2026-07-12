if not Soldier then
  Soldier = {}
end

function Soldier:OnCombatEnter(a_hTarget)
  Soldier.EnterState(self, cSTATE_COMBAT)
end

function Soldier:OnCombatExit()
end

function Soldier:OnWeaponFire(a_hWeapon)
  local hHumanFilter = Filter.New("Human")
  Util.BroadcastFunction(self.hController, cDISTANCE_GUNFIRE, "OnHeardThreateningSound", {
    self.hController
  }, hHumanFilter)
  Filter.Delete(hHumanFilter)
end

function Soldier:OnDamage(a_hDamageDoer, a_cDamageType)
  if Tips.IsUserdataZero(a_hDamageDoer) then
    return
  end
  local hFriendlyDamageFilter = Filter.New("Human && Nazi")
  Util.BroadcastFunction(self.hController, cDISTANCE_PAIN, "OnHeardFriendlyDamage", {
    self.hController,
    a_hDamageDoer,
    a_cDamageType
  }, hFriendlyDamageFilter)
  Filter.Delete(hFriendlyDamageFilter)
  local hCivilianDamageFilter = Filter.New("Human && Civilian")
  Util.BroadcastFunction(self.hController, cDISTANCE_PAIN + 8, "OnHeardNaziDamage", {
    self.hController,
    a_hDamageDoer,
    a_cDamageType
  }, hCivilianDamageFilter)
  Filter.Delete(hCivilianDamageFilter)
  if self.SMEDTable.bHasWhistle == true and self.bHasDroppedWhistle == false then
    self.bHasDroppedWhistle = true
    Render.PrintDialogue(self.hController, "*drops whistle*", 3)
  end
  if self.State ~= cSTATE_COMBAT and Actor.HasLabel(a_hDamageDoer, "Nazi") == false then
    Soldier.AttackTarget(self, a_hDamageDoer)
    ScriptSequence.Pause(self.hController)
  end
  local tCanSeeSoldier = Sensory.GetAllCanSee(self.hController)
  if tCanSeeSoldier ~= nil then
    for i = 1, #tCanSeeSoldier do
      if Actor.HasLabel(tCanSeeSoldier[i], "Nazi") == true and Actor.HasLabel(a_hDamageDoer, "Nazi") == false then
        local tActorSelf = Actor.GetSelf(tCanSeeSoldier[i])
        if tActorSelf.State ~= cSTATE_COMBAT then
          Soldier.PrintToConsole(self, "(" .. Util.GetNameFromHandle(a_hDamageDoer) .. ") has seen the soldier get damaged!")
          Util.BroadcastFunction(tCanSeeSoldier[i], "AttackTarget", {a_hDamageDoer})
        end
      end
    end
  end
end

function Soldier:OnDefaultPathTriggerEntered(a_tArgs)
  local hTriggerCrosser = a_tArgs[2]
  local hSab = Util.GetHandleByName("Saboteur")
  if hTriggerCrosser == hSab then
    Soldier.WalkDefaultPath(self)
  end
end

function Soldier:OnCivilianKissed()
  Suspicion.SetState(self.hController, "Green")
end

function Soldier:OnHuntFail(a_hTarget)
end

function Soldier:OnDeath(a_hDamageDoer)
  Soldier.PrintToConsole(self, "Soldier has died! by the hand of ", Util.GetNameFromHandle(a_hDamageDoer))
  Soldier.EnterState(self, cSTATE_NULL)
  local hSab = Util.GetHandleByName("Saboteur")
end

function Soldier:OnSuspicionEnterIdle()
  Soldier.EnterState(self, cSTATE_IDLE)
end

function Soldier:OnSuspicionEnterGreen()
  if self.State == cSTATE_NULL then
    Soldier.EnterState(self, cSTATE_CONFIGURE)
  elseif self.State == cSTATE_CONFIGURE then
  else
    Soldier.EnterState(self, cSTATE_IDLE)
  end
end

function Soldier:OnSuspicionEnterYellow()
  Soldier.EnterState(self, cSTATE_INVESTIGATE)
end

function Soldier:OnSuspicionEnterFlashingYellow(a_hTarget)
  if self.State ~= cSTATE_PAPERCHECK_LEADER then
    Soldier.CheckPapers(self, a_hTarget)
  end
end

function Soldier:OnSuspicionEnterOrange()
  Soldier.EnterState(self, cSTATE_HUNT)
end

function Soldier:OnSuspicionEnterRed(a_hTarget)
  Soldier.AttackTarget(self, a_hTarget)
end
