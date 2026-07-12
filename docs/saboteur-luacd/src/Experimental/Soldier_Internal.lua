if not Soldier then
  Soldier = {}
end

function Soldier:AttackTarget(a_hTarget)
  local tArgs = {}
  tArgs.hTarget = a_hTarget
  Soldier.EnterState(self, cSTATE_COMBAT, tArgs)
end

function Soldier.Attack(a_vSoldier, a_vTarget)
  local tSoldierSelf = Actor.GetSelf(Tips.CheckForHandle(a_vSoldier))
  local tArgs = {}
  tArgs.hTarget = Tips.CheckForHandle(a_vTarget)
  Soldier.EnterState(tSoldierSelf, cSTATE_COMBAT, tArgs)
end

function Soldier:SetSuspicion(a_NewState)
  Suspicion.SetState(self.hController, a_NewState)
end

function Soldier:UsePath(a_sPathName, a_nMoveType, a_bUrgent)
  self.sCurrentPathName = a_sPathName
  self.nCurrentPathMode = a_nMoveType
  Nav.SetScriptedPath(self.hController, a_sPathName, true)
  Nav.SetScriptedPathType(self.hController, a_nMoveType)
  Nav.SetScriptedPathMoveMode(self.hController, a_bUrgent)
end

function Soldier.BlowWhistle(a_vSoldier)
  local hSoldier = Tips.CheckForHandle(a_vSoldier)
  local tSelf = Actor.GetSelf(hSoldier)
  Sound.AttachSoundEvent(hSoldier, "whistle_nazi")
  Actor.PlayAnimation(hSoldier, "shrd_M_LH_whistle_alert")
  Soldier.AttackTarget(tSelf, Util.GetHandleByName("Saboteur"))
  local hWhistleFilter = Filter.New("Human || ReinforcementPoint")
  Util.BroadcastFunction(hSoldier, 30, "OnHeardWhistle", {hSoldier}, hWhistleFilter)
  Filter.Delete(hWhistleFilter)
end

function Soldier:BlowWhistleEvent()
  Sound.AttachSoundEvent(self.hController, "whistle_nazi")
  Actor.PlayAnimation(self.hController, "shrd_M_LH_whistle_alert")
  Soldier.AttackTarget(self, Util.GetHandleByName("Saboteur"))
  local hWhistleFilter = Filter.New("Human || ReinforcementPoint")
  Util.BroadcastFunction(self.hController, 30, "OnHeardWhistle", {hSoldier}, hWhistleFilter)
  Filter.Delete(hWhistleFilter)
end

function Soldier:CheckPapers(a_hTarget, a_sRequiredPapers)
  local tArgs = {}
  tArgs.hTarget = a_hTarget
  tArgs.sRequiredPapers = a_sRequiredPapers
  if Actor.HasLabel(a_hTarget, "IsBeingHarassed") == true then
    Soldier.PrintToConsole(self, "Target is being harassed already. Entering backup state.")
    Soldier.EnterState(self, cSTATE_PAPERCHECK_BACKUP, tArgs)
    return
  else
    Soldier.PrintToConsole(self, "Target is not being harassed. Entering leader state.")
    Soldier.EnterState(self, cSTATE_PAPERCHECK_LEADER, tArgs)
  end
end

function Soldier:SpikeAlarmNeed()
  Soldier.PrintToConsole(self, "Spiking alarm need")
  if self.bHasWhistle == true and self.bHasDroppedWhistle == false then
    return
  end
  Actor.AddNeed(self.hController, cNEED_ALARM, 100)
end

function Soldier:InvestigateTarget(a_hTarget, a_bUrgent, a_bSurpriseDelay)
  Nav.CancelScriptedPath(self.hController)
  Nav.StopMoving(self.hController)
  Soldier.PrintToConsole(self, "Invoking Combat.SetInvestigate")
  Combat.SetInvestigate(self.hController, a_hTarget, a_bUrgent, a_bSurpriseDelay, "Soldier.EvaluateFailedInvestigation", self)
end

function Soldier:InvestigateLocation(a_x, a_y, a_z, a_bUrgent, a_bSurpriseDelay, a_fRandomOffsetDist)
  local fOffsetX = a_fRandomOffsetDist * math.random()
  if math.random(2) == 1 then
    fOffsetX = -1 * fOffsetX
  end
  local fOffsetZ = a_fRandomOffsetDist * math.random()
  if math.random(2) == 2 then
    fOffsetZ = -1 * fOffsetZ
  end
  Nav.CancelScriptedPath(self.hController)
  Nav.StopMoving(self.hController)
  Combat.SetInvestigate(self.hController, a_x + fOffsetX, a_y + 0.5, a_z + fOffsetZ, a_bUrgent, a_bSurpriseDelay, "Soldier.EvaluateFailedInvestigation", self)
end

function Soldier:EvaluateFailedInvestigation()
  Soldier.PrintToConsole(self, "SetInvestigate failed to find any targets")
  Soldier.EnterState(self, cSTATE_IDLE)
end

function Soldier:WalkDefaultPath()
  self.bDefaultPathTriggered = true
  Soldier.UsePath(self, self.SMEDTable.sPatrolPathName, self.SMEDTable.nPatrolMoveType, false)
end

function Soldier:KillDefaultPathEvent()
  if self.ePathStart ~= nil then
    Util.KillEvent(self.ePathStart)
    self.ePathStart = nil
  end
end

function Soldier:Speak(a_vDialogue, a_nChanceToPlay, a_nDelayRange, a_bMuteOnFailedChance)
  local nChanceToPlay = 1
  if a_nChanceToPlay ~= nil then
    nChanceToPlay = a_nChanceToPlay
  end
  local bMuteOnFailedChance = false
  if a_bMuteOnFailedChance ~= nil then
    bMuteOnFailedChance = a_bMuteOnFailedChance
  end
  if self.nLastSpeakTime == nil then
    self.nLastSpeakTime = 0
  end
  if Util.GetGameTime() < self.nLastSpeakTime + 2 then
    return
  end
  if type(a_vDialogue) == "table" then
    if nChanceToPlay > math.random() then
      if a_nDelayRange ~= nil and 0 < a_nDelayRange then
        self.nLastSpeakTime = Util.GetGameTime()
        Util.CreateEvent({
          EventType = "TimerEvent",
          Time = math.random() * a_nDelayRange
        }, "Soldier._Speak", self, {
          a_vDialogue[math.random(#a_vDialogue)]
        })
      else
        local sCueName = a_vDialogue[math.random(#a_vDialogue)]
        Soldier.PrintToConsole(self, "Playing sound (" .. sCueName .. ")")
        self.nLastSpeakTime = Util.GetGameTime()
        Sound.AttachSoundEvent(self.hController, sCueName)
      end
    elseif bMuteOnFailedChance == true then
      self.nLastSpeakTime = Util.GetGameTime()
    end
  elseif type(a_vDialogue == "string") then
    if nChanceToPlay > math.random() then
      if a_nDelayRange ~= nil and 0 < a_nDelayRange then
        self.nLastSpeakTime = Util.GetGameTime()
        Util.CreateEvent({
          EventType = "TimerEvent",
          Time = math.random() * a_nDelayRange
        }, "Soldier._Speak", self, {a_vDialogue})
      else
        Soldier.PrintToConsole(self, "Playing sound (" .. a_vDialogue .. ")")
        self.nLastSpeakTime = Util.GetGameTime()
        Sound.AttachSoundEvent(self.hController, a_vDialogue)
      end
    elseif bMuteOnFailedChance == true then
      self.nLastSpeakTime = Util.GetGameTime()
    end
  end
end

function Soldier:_Speak(a_sCueName)
  Soldier.PrintToConsole(self, "Playing delayed sound (" .. a_sCueName .. ")")
  self.nLastSpeakTime = Util.GetGameTime()
  Sound.AttachSoundEvent(self.hController, a_sCueName)
end

function Soldier.Debug(a_vSoldier, a_bOn)
  local hSoldier = Tips.CheckForHandle(a_vSoldier)
  local tSoldierSelf = Actor.GetSelf(hSoldier)
  if a_bOn == nil then
    if tSoldierSelf.bDebugMode == false then
      Object.Blip(hSoldier, true)
      tSoldierSelf.bDebugMode = true
      Soldier.PrintToConsole(tSoldierSelf, "SOLDIER DEBUG MODE ENABLED")
      return
    else
      Object.Blip(hSoldier, false)
      Soldier.PrintToConsole(tSoldierSelf, "SOLDIER DEBUG MODE DISABLED")
      tSoldierSelf.bDebugMode = false
      return
    end
  elseif a_bOn == false then
    Object.Blip(hSoldier, false)
    Soldier.PrintToConsole(tSoldierSelf, "SOLDIER DEBUG MODE DISABLED")
    tSoldierSelf.bDebugMode = false
    return
  else
    Object.Blip(hSoldier, true)
    tSoldierSelf.bDebugMode = true
    Soldier.PrintToConsole(tSoldierSelf, "SOLDIER DEBUG MODE ENABLED")
    return
  end
  return
end

function Soldier:PrintToConsole(a_sMessageString)
  if self.bDebugMode == true then
    print("::: " .. Tips.GetDebugTime() .. " SOLDIER (" .. Util.GetNameFromHandle(self.hController) .. "): " .. a_sMessageString)
    Render.PrintMessage(Tips.GetDebugTime() .. " (" .. Util.GetNameFromHandle(self.hController) .. "): " .. a_sMessageString)
  end
end

function Soldier:PrintSelfTable()
  Soldier.PrintToConsole(self, "::: BEGIN SELF TABLE")
  for i, v in pairs(self) do
    print("self i, v", i, v)
    if type(v) == "table" then
      for a, s in pairs(v) do
        print("\ttable", a, s)
      end
    end
  end
  Soldier.PrintToConsole(self, "::: END SELF TABLE")
end
