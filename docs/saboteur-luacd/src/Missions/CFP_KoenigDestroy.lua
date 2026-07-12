if CFP_KoenigDestroy == nil then
  CFP_KoenigDestroy = SabTaskObjective:Create()
  CFP_KoenigDestroy.sPATH = "Missions\\freeplay\\country\\mis_koenig_destroy\\"
  CFP_KoenigDestroy:Configure({
    TaskCount = 999,
    sStarter = "wilcox_lehavre_interior",
    bFreeplay = true,
    sConvFile = "CFP_KoenigDestroy_Start",
    sSaveMissionNameID = "MissionNames_Text.CFP_KoenigDestroy",
    tUnlockList = {},
    WTFZoneHigh = "WtF_Zones\\global\\FP_Kroenigsbourg",
    tSMEDNodes = {
      CFP_KoenigDestroy.sPATH .. "task",
      CFP_KoenigDestroy.sPATH .. "main"
    }
  })
end

function CFP_KoenigDestroy:STARTER_Setup()
end

function CFP_KoenigDestroy:Activated()
  SabTaskObjective.Activated(self)
  self.sDebugLabel = "KOENIGDESTROY"
  self.bDebugMode = false
  Tips.Print(self, "Running KoenigDestroy.")
  self.GENERAL_Setup(self)
  self.SetupCheckpoint(self, 5)
end

function CFP_KoenigDestroy:GENERAL_Setup()
end

function CFP_KoenigDestroy:SetupVariables()
  self.hSab = Handle("Saboteur")
  self.bVariablesSet = true
  self.bStreamFuelDone = false
  self.bStreamRocketsDone = false
  self.sKoenigLoc = self.sPATH .. "task\\LOC_KoenigLoc"
  self.sKoenigTrig = self.sPATH .. "task\\PT_KoenigTrig"
  self.tRockets = {
    self.sPATH .. "wtf_low\\mission\\OccMed_V2Rocket02\\OccMed_V2Rocket",
    self.sPATH .. "wtf_low\\mission\\OccMed_V2Rocket03\\OccMed_V2Rocket",
    self.sPATH .. "wtf_low\\mission\\OccMed_V2Rocket04\\OccMed_V2Rocket"
  }
  self.nNumRockets = #self.tRockets
  self.sRadar = self.sPATH .. "wtf_low\\mission\\Radar01"
  self.sJet = self.sPATH .. "wtf_low\\Jet01"
  self.nNumKilled = 0
  self.hJetUsePt = Handle(self.sPATH .. "main\\JetUsePt")
  self.sSeeGrate = self.sPATH .. "main\\LOC_SeeGrate"
  self.sGrateFocus = self.sPATH .. "main\\LOC_GrateFocus"
  self.tGrates = {
    "CountrySide\\champagneardennes\\koenigsbourg\\Haut_Tunnel_Exhaust_Grill2(3)",
    "CountrySide\\champagneardennes\\koenigsbourg\\Haut_Tunnel_Exhaust_Grill2",
    "CountrySide\\champagneardennes\\koenigsbourg\\Haut_Tunnel_Exhaust_Grill2(4)"
  }
  self.sFuelStationLoc = self.sPATH .. "wtf_low\\mission\\LOC_FuelStationLoc"
  self.tFuelObjs = {
    self.sPATH .. "wtf_low\\mission\\Tank01",
    self.sPATH .. "wtf_low\\mission\\Tank02",
    self.sPATH .. "wtf_low\\mission\\Tank03",
    self.sPATH .. "wtf_low\\mission\\Oil01\\OccMed_OilTank_Combo_A_X6Z3",
    self.sPATH .. "wtf_low\\mission\\Oil02\\OccMed_OilTank_Combo_A_X6Z3",
    self.sPATH .. "wtf_low\\mission\\Oil03\\OccMed_OilTank_Combo_A_X6Z3",
    self.sPATH .. "wtf_low\\mission\\Oil04\\OccMed_OilTank_Combo_A_X6Z3"
  }
  self.tTanks = {
    self.sPATH .. "wtf_low\\mission\\Tank01",
    self.sPATH .. "wtf_low\\mission\\Tank02",
    self.sPATH .. "wtf_low\\mission\\Tank03"
  }
  self.tTankLocs = {
    self.sPATH .. "wtf_low\\mission\\LOC_CheckTank01",
    self.sPATH .. "wtf_low\\mission\\LOC_CheckTank02",
    self.sPATH .. "wtf_low\\mission\\LOC_CheckTank03",
    self.sPATH .. "wtf_low\\mission\\LOC_CheckEngine"
  }
  self.sTankMechanic = self.sPATH .. "wtf_low\\mission\\TankMechanic"
  self.sMechBackupPath = self.sPATH .. "wtf_low\\mission\\PA_MechBackupPath"
  self.nNumFuelObjsDead = 0
  self.nNumFuelObjs = #self.tFuelObjs
  local sTag = "mis_koenig_destroy_mission"
  if not Util.IsCustomTagLoaded(sTag) then
    Util.LoadStaticENTag(sTag, false)
    local tStreamEvent = {
      EventType = "StreamEvent",
      Objects = {
        self.sTankMechanic
      },
      WaitForGameObj = true
    }
    self:RegisterEvent(Util.CreateEvent(tStreamEvent, "CFP_KoenigDestroy.MechanicSpawned", self))
  end
  local tSeeLoc = {
    EventType = "SeeLocatorEvent",
    InViewTime = 0.5,
    Locator = self.sSeeGrate,
    Proximity = 50
  }
  self:RegisterEvent(Util.CreateEvent(tSeeLoc, "CFP_KoenigDestroy.SeenGrate", self))
end

function CFP_KoenigDestroy:SetupCheckpoint(a_nCP)
  self.tSaveInfo.nCheckpointNum = a_nCP
  self.RegisterCheckpoint(self, "CFP_KoenigDestroy.DoCheckpoint")
end

function CFP_KoenigDestroy:DoCheckpoint()
  local nCP = self.tSaveInfo.nCheckpointNum
  if not self.bVariablesSet and nCP < 5 then
    self.SetupVariables(self)
  end
  if nCP == 1 then
    if not self:IsMissionTaskActive("CFP_KoenigDestroy_TASK_GotoKoenig") then
      self.TASK_GotoKoenig(self)
    end
  elseif nCP == 2 then
    self.DoStreamEvent(self, 1)
    self.DoStreamEvent(self, 2)
  elseif nCP == 3 then
    if not self.bStreamRocketsDone then
      self.bStreamRocketsDone = true
    end
    self.DoStreamEvent(self, 2)
    self.Task_DestroyFuelStation(self)
  elseif nCP == 4 then
    self.Task_DestroyRadar(self)
  elseif nCP == 5 then
    self.SetupVariables(self)
    self.ExitHQ(self)
    self.TASK_GotoKoenig(self)
  end
end

function CFP_KoenigDestroy:DoStreamEvent(a_nWhich)
  if a_nWhich == 1 then
    if not self.bStreamRocketsDone then
      local tStreamEvent = {
        EventType = "StreamEvent",
        Objects = self.tRockets,
        WaitForGameObject = true
      }
      self:RegisterEvent(Util.CreateEvent(tStreamEvent, "CFP_KoenigDestroy.ObjectsStreamed", self, {a_nWhich}))
      self.bStreamRocketsDone = true
    end
  elseif a_nWhich == 2 and not self.bStreamFuelDone then
    local tStreamEvent = {
      EventType = "StreamEvent",
      Objects = self.tFuelObjs,
      WaitForGameObject = true
    }
    self:RegisterEvent(Util.CreateEvent(tStreamEvent, "CFP_KoenigDestroy.ObjectsStreamed", self, {a_nWhich}))
    self.bStreamFuelDone = true
  end
end

function CFP_KoenigDestroy:ExitHQ()
  self:CreateTask({
    sName = "CFP_KoenigDestroy_ExitHQ",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "ExitInterior",
    sInteriorName = "LeHavre",
    tOnComplete = {
      {
        self.SetupCheckpoint,
        {self, 1}
      }
    }
  })
end

function CFP_KoenigDestroy:TASK_GotoKoenig()
  self:CreateTask({
    sName = "CFP_KoenigDestroy_TASK_GotoKoenig",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tLocators = {
      self.sKoenigLoc
    },
    tDestRegion = {
      self.sKoenigTrig
    },
    tDeliverObjs = {
      self.hSab
    },
    sObjectiveTextID = "CFP_KoenigDestroy_Text.TASK_GotoKoenig",
    tOnActivate = {},
    tOnComplete = {
      {
        self.SetupCheckpoint,
        {self, 2}
      }
    }
  })
end

function CFP_KoenigDestroy:Task_MainTask()
  self:CreateTask({
    sName = "CFP_KoenigDestroy_Task_MainTask",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "NONE",
    sObjectiveTextID = "CFP_KoenigDestroy_Text.Task_MainTask",
    bPersistentParent = true,
    tOnActivate = {},
    tOnComplete = {}
  })
end

function CFP_KoenigDestroy:Task_DestroyRockets()
  self:CreateTask({
    sName = "CFP_KoenigDestroy_Task_DestroyRockets",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "KILL",
    tTgtInclude = self.tRockets,
    sObjectiveTextID = "CFP_KoenigDestroy_Text.Task_DestroyRocketsStart",
    ParentObjectID = -1,
    tOnActivate = {},
    tOnComplete = {
      {
        self.SetupCheckpoint,
        {self, 3}
      },
      {
        Cin.PlayConversation,
        {
          "CFP_KoenigDestroy_DestroyRockets"
        }
      }
    }
  })
end

function CFP_KoenigDestroy:Task_DestroyFuelStation()
  self:CreateTask({
    sName = "CFP_KoenigDestroy_Task_DestroyFuelStation",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "KILL",
    tTgtInclude = self.tFuelObjs,
    sObjectiveTextID = "CFP_KoenigDestroy_Text.Task_DestroyFuelStation",
    ParentObjectID = -1,
    tOnActivate = {},
    tOnComplete = {
      {
        self.SetupCheckpoint,
        {self, 4}
      }
    }
  })
end

function CFP_KoenigDestroy:Task_DestroyRadar()
  self:CreateTask({
    sName = "CFP_KoenigDestroy_Task_DestroyRadar",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "KILL",
    tTgtInclude = {
      self.sRadar
    },
    sObjectiveTextID = "CFP_KoenigDestroy_Text.Task_DestroyRadar",
    ParentObjectID = -1,
    tOnActivate = {},
    tOnComplete = {
      {
        Cin.PlayConversation,
        {
          "CFP_KoenigDestroy_DestroyRadar",
          "CFP_KoenigDestroy.DoCleanup",
          self
        }
      }
    }
  })
end

function CFP_KoenigDestroy:Task_DestroyJet()
  self:CreateTask({
    sName = "CFP_KoenigDestroy_Task_DestroyJet",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "KILL",
    tTgtInclude = {
      self.sJet
    },
    sObjectiveTextID = "CFP_KoenigDestroy_Text.Task_DestroyJet",
    ParentObjectID = -1,
    tOnActivate = {},
    tOnComplete = {}
  })
end

function CFP_KoenigDestroy:ObjectsStreamed(a_nObjectIndex)
  if a_nObjectIndex == 1 then
    for i, sObj in ipairs(self.tRockets) do
      local hObj = Handle(sObj)
      local tDeathEvent = {EventType = "DeathEvent", ObjectHandle = hObj}
      Util.CreateEvent(tDeathEvent, "CFP_KoenigDestroy.ObjectDied", self, {hObj, a_nObjectIndex})
    end
    self.Task_DestroyRockets(self)
  end
end

function CFP_KoenigDestroy:OnJetUsePt()
  Object.Kill(Handle(self.sJet))
end

function CFP_KoenigDestroy:UpdateObjText()
  local nObjID = self:GetTaskObjectiveID("CFP_KoenigDestroy_Task_DestroyRockets")
  if not nObjID then
    local tTimerEvent = {EventType = "TimerEvent", Time = 0.25}
    self:RegisterEvent(Util.CreateEvent(tTimerEvent, "CFP_KoenigDestroy.UpdateObjText", self))
  else
    HUD.SetObjectiveText(nObjID, "CFP_KoenigDestroy_Text.Task_DestroyRockets", 2, self.nNumKilled, self.nNumRockets)
  end
end

function CFP_KoenigDestroy:ObjectDied(a_hObject, a_nObjectIndex)
  if a_nObjectIndex == 1 then
    self.RemoveFocusPoint(self)
    self.nNumKilled = self.nNumKilled + 1
    self.UpdateObjText(self)
  else
  end
end

function CFP_KoenigDestroy:DoFuelStationTaskDoneCheck()
  if self:IsMissionTaskActive("CFP_KoenigDestroy_Task_DestroyFuelStation") and self.nNumFuelObjsDead == self.nNumFuelObjs then
    self:CompleteTaskByName("CFP_KoenigDestroy_Task_DestroyFuelStation")
  end
end

function CFP_KoenigDestroy:SeenGrate()
  Cin.PlayConversation("CFP_KoenigDestroy_WayInside")
  local hGrate = Handle(self.sGrateFocus)
  local x, y, z = Object.GetPosition(hGrate)
  self.nGrateFocusPt = FocusPt.Create(x, y, z, 50, 100, true, true)
  self.tFocusPtDeathEvent = self.tFocusPtDeathEvent or {}
  for i, sGrate in ipairs(self.tGrates) do
    local tDeathEvent = {
      EventType = "DeathEvent",
      ObjectHandle = Handle(sGrate)
    }
    self.tFocusPtDeathEvent[i] = Util.CreateEvent(tDeathEvent, "CFP_KoenigDestroy.RemoveFocusPoint", self)
    self:RegisterEvent(self.tFocusPtDeathEvent[i])
  end
end

function CFP_KoenigDestroy:RemoveFocusPoint()
  if self.nGrateFocusPt then
    FocusPt.Delete(self.nGrateFocusPt)
    self.nGrateFocusPt = nil
  end
end

function CFP_KoenigDestroy:AddTankDamageCallback()
  for i, sTank in ipairs(self.tTanks) do
    local hTank = Handle(sTank)
    local tDamageEvent = {
      EventType = "DamageEvent",
      ObjectHandle = hTank,
      MinDamage = 500
    }
    self:RegisterEvent(Util.CreateEvent(tDamageEvent, "CFP_KoenigDestroy.DestroyTank", self, {hTank}))
  end
end

function CFP_KoenigDestroy:DestroyTank(a_tCallbackData, a_hEntity)
  local x, y, z = Object.GetPosition(a_hEntity)
  if Object.GetHealth(a_hEntity) > 0 then
    Object.SetHealth(a_hEntity, 1)
    Object.Kill(a_hEntity)
    Util.CreateExplosion("Explosion_Large", x, y, z)
  end
end

function CFP_KoenigDestroy:MechanicSpawned()
  self.hTankMechanic = Handle(self.sTankMechanic)
  local hRndPt = Handle(Tips.GetRandomElement(self.tTankLocs))
  Combat.SetIdleScripted(self.hTankMechanic, true)
  Nav.MoveToObject(self.hTankMechanic, hRndPt, 1, false, "CFP_KoenigDestroy.MechanicPickNewPt", self, {hRndPt})
end

function CFP_KoenigDestroy:MechanicPickNewPt(a_hPreviousPoint)
  local hRndPt = a_hPrevousPoint
  local nAlive = 0
  for i, sTank in ipairs(self.tTanks) do
    if Object.IsAlive(Handle(sTank)) then
      nAlive = nAlive + 1
    end
  end
  if nAlive == 0 then
    local tTimerEvent = {EventType = "TimerEvent", Time = 10}
    self:RegisterEvent(Util.CreateEvent(tTimerEvent, "CFP_KoenigDestroy.MechanicDoMove", self, {2}))
  else
    while hRndPt == a_hPreviousPoint do
      local nIndex
      local nIter = 0
      if nIter < 5 then
        nIndex = math.random(#self.tTankLocs)
      else
        nIndex = nIndex + 1
        if 4 < nIndex then
          nIndex = 1
        end
      end
      if 50 < nIter then
        break
      end
      hRndPt = Handle(self.tTankLocs[nIndex])
      if nIndex < 4 and not Object.IsAlive(Handle(self.tTanks[nIndex])) then
        hRndPt = a_hPreviousPoint
        nIter = nIter + 1
      end
    end
    local tTimerEvent = {EventType = "TimerEvent", Time = 10}
    self:RegisterEvent(Util.CreateEvent(tTimerEvent, "CFP_KoenigDestroy.MechanicDoMove", self, {1, hRndPt}))
  end
end

function CFP_KoenigDestroy:MechanicDoMove(a_nMode, a_hPoint)
  if a_nMode == 1 then
    Nav.MoveToObject(self.hTankMechanic, a_hPoint, 1, false, "CFP_KoenigDestroy.MechanicPickNewPt", self, {a_hPoint})
  elseif a_nMode == 2 then
    Nav.SetScriptedPath(self.hTankMechanic, self.sMechBackupPath, false, "CFP_KoenigDestroy.MechanicDoMove", self, {2})
    Nav.SetScriptedPathMoveMode(self.hTankMechanic, false)
    Nav.SetScriptedPathMoveType(self.hTankMechanic, cPATHTYPE_ONCE)
  end
end

function CFP_KoenigDestroy:DoCleanup()
  local sTag = "mis_koenig_destroy_mission"
  if Util.IsCustomTagLoaded(sTag) then
    Util.UnloadStaticENTag(sTag, false)
  end
  self:CompleteThisMission()
end
