if P1FP_Jailbreak == nil then
  P1FP_Jailbreak = SabTaskObjective:Create()
  P1FP_Jailbreak.sPATH = "Missions\\freeplay\\p1\\mis_jailbreak\\"
  P1FP_Jailbreak:Configure({
    TaskCount = 99,
    sStarter = "Luc_LaVillette_Interior",
    bFreeplay = true,
    sSaveMissionNameID = "MissionNames_Text.P1FP_JailBreak",
    tDependencyList = {
      "P1FP_Carbomb",
      "P1FP_Traitor"
    },
    sConvFile = "211_Con_Backup",
    tUnlockList = {
      "Connect_ST_212_ResistanceBackup"
    },
    sMissionStartTime = cNIGHT,
    bFreezeTimeScale = bFREEZE,
    tSMEDNodes = {
      P1FP_Jailbreak.sPATH .. "task",
      P1FP_Jailbreak.sPATH .. "main",
      P1FP_Jailbreak.sPATH .. "locators"
    }
  })
end

function P1FP_Jailbreak:STARTER_Setup()
  if not IsMissionCompleted("Paris_1_Mission_1B") then
    Zone.SwitchState("WtF_Zones\\global\\P1M1B_SlaughterhouseLiberate", cZONESTATE_HIGHCOLOR_HIGHTAG, cENT_IMMEDIATE)
  end
end

function P1FP_Jailbreak:Activated()
  SabTaskObjective.Activated(self)
  self.sDebugLabel = "JAILBREAK"
  self.bDebugMode = false
  self.sWTFZone = self.sPATH .. "WTF"
  dprint(self, "Running Jailbreak.")
  self.GENERAL_Setup(self)
  Sound.LoadSoundBank("m_P1fP_Jailbreak.bnk")
  self.SetupCheckpoint(self, 3)
end

function P1FP_Jailbreak:GENERAL_Setup()
  EVENT_PlayerEntersTrigger("P1FP_Jailbreak.DisableEscalationVehicles", self, "Missions\\freeplay\\p1\\mis_jailbreak\\task\\TurnOffVehEsc")
end

function P1FP_Jailbreak:SetupVariables()
  self.hSab = self.hSab or Handle("Saboteur")
  self.nNumDoors = self.nNumDoors or 3
  self.nNumDoorsOpened = self.nNumDoorsOpened or 0
  self.bCanRetryIndefinitely = self.bCanRetryIndefinitely or false
  self.bSeenGateLoc = self.bSeenGateLoc or {}
  self.bGateOpened = self.bGateOpened or {}
  self.bPrisonersKeepChecking = self.bPrisonersKeepChecking or {}
  self.tSpawnClosetQueue = self.tSpawnClosetQueue or {}
  self.tClosetQueueRecheckID = self.tClosetQueueRecheckID or {}
  self.nNumTimesRetriedQueue = self.nNumTimesRetriedQueue or {}
  self.sCells = self.sCells or self.sPATH .. "task\\LOC_Cells"
  self.sTargetArea = self.sTargetArea or self.sPATH .. "task\\TargetArea"
  self.nNumResDead = self.nNumResDead or 0
  self.nRescuedPris = self.nRescuedPris or 0
  self.nHealthAdjust = self.nHealthAdjust or 400
  self.nPrisonerTimeWait = self.nPrisonerTimeWait or 20
  self.sCouteau = self.sCouteau or self.sPATH .. "main\\Cage1Res4"
  self.tEmitters = self.tEmitters or {
    self.sPATH .. "sound\\Emt_P1FP_Jailbreak_Alarm",
    self.sPATH .. "sound\\Emt_P1FP_Jailbreak_Alarm(1)"
  }
  self.tCageDoors = self.tCageDoors or {
    self.sPATH .. "wtf_low\\OccLt_Cage_Prison_Door\\Cage1",
    self.sPATH .. "wtf_low\\OccLt_Cage_Prison_Door(2)\\Cage1",
    self.sPATH .. "wtf_low\\OccLt_Cage_Prison_Door(3)\\Cage1",
    self.sPATH .. "wtf_low\\OccLt_Cage_Prison_Door(4)\\Cage1"
  }
  self.tCageLevers = self.tCageLevers or {
    self.sPATH .. "wtf_low\\CageLever1",
    self.sPATH .. "wtf_low\\CageLever2",
    self.sPATH .. "wtf_low\\CageLever3",
    self.sPATH .. "wtf_low\\CageLever4"
  }
  self.tAttrPt = self.tAttrPt or {
    self.sPATH .. "main\\ATPT_CageLever1",
    self.sPATH .. "main\\ATPT_CageLever2",
    self.sPATH .. "main\\ATPT_CageLever3",
    self.sPATH .. "main\\ATPT_CageLever4"
  }
  self.tOtherUsePts = {
    self.sPATH .. "main\\ATPT_CageLever2",
    self.sPATH .. "main\\ATPT_CageLever3",
    self.sPATH .. "main\\ATPT_CageLever4"
  }
  self.tCageGuards = self.tCageGuards or {
    self.sPATH .. "main\\GuardCage1",
    self.sPATH .. "main\\GuardCage2",
    self.sPATH .. "main\\GuardCage3",
    self.sPATH .. "main\\GuardCage4"
  }
  self.tPrisoners = self.tPrisoners or {
    {
      self.sPATH .. "main\\Cage1Res4"
    },
    {
      self.sPATH .. "main\\Cage2Res3",
      self.sPATH .. "main\\Cage2Res4"
    },
    {
      self.sPATH .. "main\\Cage3Res1",
      self.sPATH .. "main\\Cage3Res3"
    },
    {
      self.sPATH .. "main\\Cage4Res2",
      self.sPATH .. "main\\Cage4Res3"
    }
  }
  self.tCagePaths = self.tCagePaths or {
    {
      self.sPATH .. "main\\PA_Cage1Path04"
    },
    {
      self.sPATH .. "main\\PA_Cage2Path02",
      self.sPATH .. "main\\PA_Cage2Path03",
      self.sPATH .. "main\\PA_Cage2Path04",
      self.sPATH .. "main\\PA_Cage2Path05"
    },
    {
      self.sPATH .. "main\\PA_Cage3Path01",
      self.sPATH .. "main\\PA_Cage3Path02",
      self.sPATH .. "main\\PA_Cage3Path03",
      self.sPATH .. "main\\PA_Cage3Path04"
    },
    {
      self.sPATH .. "main\\PA_Cage4Path01",
      self.sPATH .. "main\\PA_Cage4Path02",
      self.sPATH .. "main\\PA_Cage4Path03",
      self.sPATH .. "main\\PA_Cage4Path04"
    }
  }
  self.tCagePts = self.tCagePts or {
    {
      self.sPATH .. "locators\\LOC_Cage1Fight04"
    },
    {
      self.sPATH .. "locators\\LOC_Cage2Fight02",
      self.sPATH .. "locators\\LOC_Cage2Fight03",
      self.sPATH .. "locators\\LOC_Cage2Fight04",
      self.sPATH .. "locators\\LOC_Cage2Fight05"
    },
    {
      self.sPATH .. "locators\\LOC_Cage3Fight01",
      self.sPATH .. "locators\\LOC_Cage3Fight02",
      self.sPATH .. "locators\\LOC_Cage3Fight03",
      self.sPATH .. "locators\\LOC_Cage3Fight04"
    },
    {
      self.sPATH .. "locators\\LOC_Cage4Fight01",
      self.sPATH .. "locators\\LOC_Cage4Fight02",
      self.sPATH .. "locators\\LOC_Cage4Fight03",
      self.sPATH .. "locators\\LOC_Cage4Fight04"
    }
  }
  self.tCageExits = self.tCageExits or {
    {
      self.sPATH .. "locators\\LOC_Cage1Exit4"
    },
    {
      self.sPATH .. "locators\\LOC_Cage2Exit2",
      self.sPATH .. "locators\\LOC_Cage2Exit3",
      self.sPATH .. "locators\\LOC_Cage2Exit4",
      self.sPATH .. "locators\\LOC_Cage2Exit5"
    },
    {
      self.sPATH .. "locators\\LOC_Cage3Exit1",
      self.sPATH .. "locators\\LOC_Cage3Exit2",
      self.sPATH .. "locators\\LOC_Cage3Exit3",
      self.sPATH .. "locators\\LOC_Cage3Exit4"
    },
    {
      self.sPATH .. "locators\\LOC_Cage4Exit1",
      self.sPATH .. "locators\\LOC_Cage4Exit2",
      self.sPATH .. "locators\\LOC_Cage4Exit3",
      self.sPATH .. "locators\\LOC_Cage4Exit4"
    }
  }
  self.tNaziPathers = self.tNaziPathers or {
    self.sPATH .. "wtf_low\\NaziBarracks05",
    self.sPATH .. "wtf_low\\NaziInner1",
    self.sPATH .. "wtf_low\\NaziOuter1",
    self.sPATH .. "wtf_low\\NaziOuter2",
    self.sPATH .. "wtf_low\\NaziWest1",
    self.sPATH .. "main\\GestapoNorth",
    self.sPATH .. "main\\GestapoSouth"
  }
  self.tNaziPaths = self.tNaziPaths or {
    {
      self.sPATH .. "wtf_low\\BunkerPath01",
      cPATHTYPE_BOUNCE
    },
    {
      self.sPATH .. "wtf_low\\MonumentPath1",
      cPATHTYPE_LOOP
    },
    {
      self.sPATH .. "wtf_low\\MonumentPath2",
      cPATHTYPE_LOOP
    },
    {
      self.sPATH .. "wtf_low\\MonumentPath3",
      cPATHTYPE_LOOP
    },
    {
      self.sPATH .. "wtf_low\\WestPath01",
      cPATHTYPE_BOUNCE
    },
    {
      self.sPATH .. "main\\PA_GestNorth",
      cPATHTYPE_BOUNCE
    },
    {
      self.sPATH .. "main\\PA_GestSouth",
      cPATHTYPE_BOUNCE
    }
  }
  self.tCageTriggers = self.tCageTriggers or {
    self.sPATH .. "main\\PT_Cage1",
    self.sPATH .. "main\\PT_Cage2",
    self.sPATH .. "main\\PT_Cage3",
    self.sPATH .. "main\\PT_Cage4"
  }
end

function P1FP_Jailbreak:SetupEvents()
  for i, sObject in ipairs(self.tAttrPt) do
    local tDoorUseEvent = {
      EventType = "OnActorComplete",
      Target = Handle(sObject)
    }
    self:RegisterEvent(Util.CreateEvent(tDoorUseEvent, "P1FP_Jailbreak.OnDoorUse", self, {sObject}))
  end
  for i = 1, 4 do
    for j, sEnt in ipairs(self.tPrisoners[i]) do
      local hEnt = Handle(sEnt)
      local tStreamEvent = {
        EventType = "StreamEvent",
        Objects = {sEnt},
        WaitForGameObject = true
      }
      self:RegisterEvent(Util.CreateEvent(tStreamEvent, "P1FP_Jailbreak.PrisonerSpawned", self, {hEnt}))
      local tDeathEvent = {EventType = "DeathEvent", ObjectHandle = hEnt}
      self:RegisterEvent(Util.CreateEvent(tDeathEvent, "P1FP_Jailbreak.ResSoldierDead", self, {hEnt}))
    end
  end
  for i, sEnt in ipairs(self.tNaziPathers) do
    local tStreamEvent = {
      EventType = "StreamEvent",
      Objects = {sEnt},
      WaitForGameObject = true
    }
    self:RegisterEvent(Util.CreateEvent(tStreamEvent, "P1FP_Jailbreak.PatherSpawned", self, {sEnt, i}))
  end
  for i, sEnt in ipairs(self.tOtherUsePts) do
    local tStreamEvent = {
      EventType = "StreamEvent",
      Objects = {sEnt},
      WaitForGameObject = true
    }
    self:RegisterEvent(Util.CreateEvent(tStreamEvent, "P1FP_Jailbreak.LockOtherCells", self, {}))
  end
end

function P1FP_Jailbreak:LockOtherCells()
  for i, sEnt in ipairs(self.tOtherUsePts) do
    AttractionPt.EnableUse(Handle(sEnt), false)
  end
end

function P1FP_Jailbreak:UnlockCells()
  for i, sEnt in ipairs(self.tOtherUsePts) do
    AttractionPt.EnableUse(Handle(sEnt), true)
  end
end

function P1FP_Jailbreak:DisableEscalationVehicles()
  Suspicion.EnableEscalationVehicles(false)
end

function P1FP_Jailbreak:SetupCheckpoint(a_nCP)
  self.tSaveInfo.nCheckpointNum = a_nCP
  self.RegisterCheckpoint(self, "P1FP_Jailbreak.DoCheckpoint")
end

function P1FP_Jailbreak:DoCheckpoint()
  local nCP = self.tSaveInfo.nCheckpointNum
  if nCP == 1 then
    if not self:IsMissionTaskActive("P1FP_Jailbreak_Task_FindJailCells") then
      self.Task_FindJailCells(self)
    end
  elseif nCP == 2 then
    self.nNumDoorsOpened = 0
    self.SetupVariables(self)
    self.SetupEvents(self)
    Suspicion.EnableEscalationVehicles(false)
    self.Task_RescueCrochet(self)
    self.Task_HighlightCrochetCell(self)
  elseif nCP == 3 then
    self.SetupVariables(self)
    self.Task_FindJailCells(self)
    self.ExitHQ(self)
  end
end

function P1FP_Jailbreak:ExitHQ()
  self:CreateTask({
    sName = "P1FP_Jailbreak_ExitHQ",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "ExitInterior",
    sInteriorName = "LaVillette",
    bInteriorTask = true,
    tOnComplete = {
      {
        self.SetupCheckpoint,
        {self, 1}
      }
    }
  })
end

function P1FP_Jailbreak:Task_RescueCrochet()
  self:CreateTask({
    sName = "P1FP_Jailbreak_Task_RescueCrochet",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "NONE",
    sObjectiveTextID = "P1FP_Jailbreak_Text.Task_RescueCrochet",
    tOnActivate = {},
    tOnComplete = {
      {
        self.Task_RescuePrisoners,
        {self}
      },
      {
        self.UnlockCells,
        {self}
      }
    }
  })
end

function P1FP_Jailbreak:Task_RescuePrisoners()
  self:CreateTask({
    sName = "P1FP_Jailbreak_Task_RescuePrisoners",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "NONE",
    sObjectiveTextID = "P1FP_Jailbreak_Text.Task_RescuePrisoners",
    tObjVars = {
      self.nNumDoorsOpened
    },
    tOnActivate = {},
    tOnComplete = {}
  })
end

function P1FP_Jailbreak:Task_FindJailCells()
  self:CreateTask({
    sName = "P1FP_Jailbreak_Task_FindJailCells",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tLocators = {
      self.sCells
    },
    tDestRegion = {
      self.sTargetArea
    },
    tDeliverObjs = {
      self.hSab
    },
    sObjectiveTextID = "P1FP_Jailbreak_Text.Task_FindJailCells",
    tOnActivate = {},
    tOnComplete = {
      {
        Cin.PlayConversation,
        {
          "P1FP_Jailbreak_Stealth"
        }
      },
      {
        self.SetupCheckpoint,
        {self, 2}
      }
    }
  })
end

function P1FP_Jailbreak:Task_HighlightCrochetCell()
  self:CreateTask({
    sName = "P1FP_Jailbreak_Task_HighlightCrochetCell",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "USE",
    tTgtInclude = {
      self.tAttrPt[1]
    },
    MarkerHeight = 0.75,
    bNoGPS = true,
    tOnActivate = {
      {
        EVENT_ActorDeath,
        {
          "P1FP_Jailbreak.DoorBlownOpen1",
          self,
          "Missions\\freeplay\\p1\\mis_jailbreak\\wtf_low\\OccLt_Cage_Prison_Door\\Cage1"
        }
      }
    },
    tOnComplete = {
      {
        self.Task_FreePrisoners2,
        {self}
      },
      {
        self.Task_FreePrisoners3,
        {self}
      },
      {
        self.Task_FreePrisoners4,
        {self}
      }
    }
  })
end

function P1FP_Jailbreak:DoorBlownOpen1()
  a_tCallbackdata = {}
  a_tCallbackdata[1] = Handle(self.tAttrPt[1])
  a_sObject = "Missions\\freeplay\\p1\\mis_jailbreak\\main\\ATPT_CageLever1"
  self.OnDoorUse(self, a_tCallbackdata, a_sObject)
end

function P1FP_Jailbreak:Task_FreePrisoners2()
  self:CreateTask({
    sName = "P1FP_Jailbreak_Task_FreePrisoners2",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "USE",
    tTgtInclude = {
      self.tAttrPt[2]
    },
    MarkerHeight = 0.75,
    bNoGPS = true,
    tOnActivate = {
      {
        EVENT_ActorDeath,
        {
          "P1FP_Jailbreak.DoorBlownOpen2",
          self,
          "Missions\\freeplay\\p1\\mis_jailbreak\\wtf_low\\OccLt_Cage_Prison_Door(2)\\Cage1"
        }
      }
    },
    tOnComplete = {}
  })
end

function P1FP_Jailbreak:DoorBlownOpen2()
  self:CompleteTaskByName("P1FP_Jailbreak_Task_FreePrisoners2")
  a_tCallbackdata = {}
  a_tCallbackdata[1] = Handle(self.tAttrPt[2])
  a_sObject = "Missions\\freeplay\\p1\\mis_jailbreak\\main\\ATPT_CageLever2"
  self.OnDoorUse(self, a_tCallbackdata, a_sObject)
end

function P1FP_Jailbreak:Task_FreePrisoners3()
  self:CreateTask({
    sName = "P1FP_Jailbreak_Task_FreePrisoners3",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "USE",
    tTgtInclude = {
      self.tAttrPt[3]
    },
    MarkerHeight = 0.75,
    bNoGPS = true,
    tOnActivate = {
      {
        EVENT_ActorDeath,
        {
          "P1FP_Jailbreak.DoorBlownOpen3",
          self,
          "Missions\\freeplay\\p1\\mis_jailbreak\\wtf_low\\OccLt_Cage_Prison_Door(3)\\Cage1"
        }
      }
    },
    tOnComplete = {}
  })
end

function P1FP_Jailbreak:DoorBlownOpen3()
  self:CompleteTaskByName("P1FP_Jailbreak_Task_FreePrisoners3")
  a_tCallbackdata = {}
  a_tCallbackdata[1] = Handle(self.tAttrPt[3])
  a_sObject = "Missions\\freeplay\\p1\\mis_jailbreak\\main\\ATPT_CageLever3"
  self.OnDoorUse(self, a_tCallbackdata, a_sObject)
end

function P1FP_Jailbreak:Task_FreePrisoners4()
  self:CreateTask({
    sName = "P1FP_Jailbreak_Task_FreePrisoners4",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "USE",
    tTgtInclude = {
      self.tAttrPt[4]
    },
    MarkerHeight = 0.75,
    bNoGPS = true,
    tOnActivate = {
      {
        EVENT_ActorDeath,
        {
          "P1FP_Jailbreak.DoorBlownOpen4",
          self,
          "Missions\\freeplay\\p1\\mis_jailbreak\\wtf_low\\OccLt_Cage_Prison_Door(4)\\Cage1"
        }
      }
    },
    tOnComplete = {}
  })
end

function P1FP_Jailbreak:DoorBlownOpen4()
  self:CompleteTaskByName("P1FP_Jailbreak_Task_FreePrisoners4")
  a_tCallbackdata = {}
  a_tCallbackdata[1] = Handle(self.tAttrPt[4])
  a_sObject = "Missions\\freeplay\\p1\\mis_jailbreak\\main\\ATPT_CageLever4"
  self.OnDoorUse(self, a_tCallbackdata, a_sObject)
end

function P1FP_Jailbreak:Task_LoseEscalation()
  self:CreateTask({
    sName = "P1FP_Jailbreak_Task_LoseEscalation",
    sTaskType = "SabTaskObjectiveEscalation",
    sObjectiveTextID = "GenericObjective_Text.Escalation_Lose",
    EscalationLevel = 0,
    tOnActivate = {
      {
        Suspicion.EnableEscalationVehicles,
        {true}
      }
    },
    tOnComplete = {
      {
        self.ResetTaskByName,
        {
          self,
          "P1FP_Jailbreak_Task_LoseEscalation",
          true
        }
      },
      {
        self.CheckEscalation,
        {self, true}
      }
    }
  })
end

function P1FP_Jailbreak:PrisonerSpawned(a_hEntity)
  self.SetupPrisonerIdle(self, a_hEntity)
  HUD.SetObjectiveMarker(a_hEntity, cMMI_Escort, cOM_Escort, true, false, false)
  if a_hEntity == Handle(self.sCouteau) then
    Object.SetHealth(a_hEntity, self.nHealthAdjust + self.nHealthAdjust * 0.25)
  else
    Object.SetHealth(a_hEntity, self.nHealthAdjust)
  end
  Object.SetInvincible(a_hEntity, true)
  Combat.SetIdleScripted(a_hEntity, true)
  Actor.SetPanicEnabled(a_hEntity, false)
  Actor.SetVehicleAvoidance(a_hEntity, false)
  Combat.SetRespondToSound(a_hEntity, false)
  Combat.SetRespondToDamage(a_hEntity, false)
  Combat.SetRespondToEvents(a_hEntity, false)
end

function P1FP_Jailbreak:SetupPrisonerIdle(a_hEntity)
  local sRand, tTable
  local tAnimsWall = {
    "shrd_M_prisoner_shuffle_feet",
    "shrd_M_tavern_drunk_sick",
    "shrd_M_prisoner_wall_lean",
    "shrd_M_prisoner_wall_pound",
    "shrd_prisoner_face_wall",
    "civ_M_harass_wall_idle_1",
    "civ_M_HR_wall_idle_1",
    "civ_M_HR_wall_idle_2"
  }
  local tAnimsReg = {
    "shrd_M_depressed_idle_lf",
    "civ_M_HR_knee_idle",
    "conv_M_concern",
    "conv_Angry_idle",
    "conv_Angry_WTF"
  }
  local tWallEnts = {
    self.sPATH .. "main\\Cage4Res3"
  }
  local tRegEnts = {
    self.sPATH .. "main\\Cage1Res4",
    self.sPATH .. "main\\Cage2Res3",
    self.sPATH .. "main\\Cage2Res4",
    self.sPATH .. "main\\Cage3Res1",
    self.sPATH .. "main\\Cage3Res3",
    self.sPATH .. "main\\Cage4Res2"
  }
  for i, sEnt in ipairs(tWallEnts) do
    local hEnt = Handle(sEnt)
    if a_hEntity == hEnt then
      tTable = tAnimsWall
      break
    end
  end
  tTable = tTable or tAnimsReg
  sRand = tTable[math.random(#tTable)]
  self.tPlayingAnim = self.tPlayingAnim or {}
  self.tPlayingAnim[a_hEntity] = sRand
  Actor.PlayAnimation(a_hEntity, sRand)
end

function P1FP_Jailbreak:CleanupTask()
  self:CompleteTaskByName("P1FP_Jailbreak_Task_RescuePrisoners")
end

function P1FP_Jailbreak:CheckEscalation(a_bDoSuccess)
  if not a_bDoSuccess then
    local nSusp = Suspicion.GetEscalation()
    if nSusp == 0 then
      self.CheckEscalation(self, true)
    else
      self.Task_LoseEscalation(self)
    end
  else
    self.ClearSquads(self)
    Util.UnloadStaticENTag("p1_mis_jailbreak_low", false)
    Suspicion.EnableEscalationVehicles(true)
    self:CompleteThisMission()
  end
end

function P1FP_Jailbreak:OnDoorUse(a_tCallbackdata, a_sObject)
  local hObject = a_tCallbackdata[1]
  local nIndex
  for i, sObj in ipairs(self.tAttrPt) do
    if sObj == a_sObject then
      nIndex = i
      break
    end
  end
  if self:IsMissionTaskActive("P1FP_Jailbreak_Task_HighlightCrochetCell") and 1 < nIndex then
    local tDoorUseEvent = {
      EventType = "OnActorComplete",
      Target = Handle(a_sObject)
    }
    self:RegisterEvent(Util.CreateEvent(tDoorUseEvent, "P1FP_Jailbreak.OnDoorUse", self, {a_sObject}))
    return
  end
  if a_sObject ~= self.tAttrPt[1] then
    self.nNumDoorsOpened = self.nNumDoorsOpened + 1
    local nTaskID = self:GetTaskObjectiveID("P1FP_Jailbreak_Task_RescuePrisoners")
    HUD.SetObjectiveText(nTaskID, "P1FP_Jailbreak_Text.Task_RescuePrisoners", 1, self.nNumDoorsOpened)
  else
    for i, sEmitter in ipairs(self.tEmitters) do
      local hEm = Handle(sEmitter)
      Sound.ActivateSoundEmitter(hEm)
    end
    local tTimerEvent = {EventType = "TimerEvent", Time = 15}
    self:RegisterEvent(Util.CreateEvent(tTimerEvent, "P1FP_Jailbreak.TurnOffEmitters", self))
    self.eSuspCircle = Suspicion.SetupSuspicionRadius(Handle(self.tAttrPt[1]), 10)
    tTimerEvent = {EventType = "TimerEvent", Time = 15}
    self:RegisterEvent(Util.CreateEvent(tTimerEvent, "P1FP_Jailbreak.RemoveSuspCircle", self))
  end
  local tTimerEvent = {EventType = "TimerEvent", Time = 3}
  self:RegisterEvent(Util.CreateEvent(tTimerEvent, "P1FP_Jailbreak.DoEscapedCheck", self))
  local sDoor = self.tCageDoors[nIndex]
  local hDoor = Handle(sDoor)
  if not Object.IsDoorOpen(Handle(self.tCageDoors[nIndex])) then
    Object.Actuate(Handle(self.tCageDoors[nIndex]))
    AttractionPt.EnableUse(Handle(a_sObject), false)
    self.bGateOpened[nIndex] = true
    self.DoConversation(self, nIndex)
    for i, sEntity in ipairs(self.tPrisoners[nIndex]) do
      local hEnt = Handle(sEntity)
      Object.SetInvincible(hEnt, false)
      if self.tPlayingAnim[hEnt] == "civ_M_HR_knee_idle" then
        Actor.PlayAnimation(hEnt, "civ_M_HR_knee_tran_stand")
        local tTimerEvent = {EventType = "TimerEvent", Time = 2.467}
        self:RegisterEvent(Util.CreateEvent(tTimerEvent, "P1FP_Jailbreak.DoCancelAnimation", self, {
          hEnt,
          sEntity,
          nIndex,
          i
        }))
      else
        self.DoCancelAnimation(self, hEnt, sEntity, nIndex, i, 1)
      end
    end
    self.DoSightCheck(self, 3, false)
  end
end

function P1FP_Jailbreak:TurnOffEmitters()
  for i, sEmitter in ipairs(self.tEmitters) do
    local hEm = Handle(sEmitter)
    Sound.DeactivateSoundEmitter(hEm)
  end
end

function P1FP_Jailbreak:RemoveSuspCircle()
  if self.eSuspCircle then
    Suspicion.KillSuspicionRadius(self.eSuspCircle)
    self.eSuspCircle = nil
  end
end

function P1FP_Jailbreak:WrapUpCrochetTask()
  self:CompleteTaskByName("P1FP_Jailbreak_Task_RescueCrochet")
  self:CompleteTaskByName("P1FP_Jailbreak_Task_HighlightCrochetCell")
end

function P1FP_Jailbreak:DoCancelAnimation(a_hEntity, a_sEntity, a_nIndex, a_nSubIndex, a_nTime)
  Actor.CancelAnimation(a_hEntity)
  if not a_nTime then
    self.ExitCell(self, a_sEntity, a_nIndex, a_nSubIndex)
  else
    local tExitEvent = {EventType = "TimerEvent", Time = a_nTime}
    self:RegisterEvent(Util.CreateEvent(tExitEvent, "P1FP_Jailbreak.ExitCell", self, {
      a_sEntity,
      a_nIndex,
      a_nSubIndex
    }))
  end
end

function P1FP_Jailbreak:ExitCell(a_sEntity, a_nIndex, a_nSubIndex)
  local hEntity = Handle(a_sEntity)
  local szSquad = "Jailbreak_Prisoners" .. a_nIndex
  self.bSetupSquad = self.bSetupSquad or {}
  self.bSetupSquadLeader = self.bSetupSquadLeader or {}
  self.tNaziTargetList = self.tNaziTargetList or {}
  table.insert(self.tNaziTargetList, {hEntity, 10})
  if not self.bSetupSquad[a_nIndex] then
    Squad.Create(szSquad)
    self.bSetupSquad[a_nIndex] = true
  end
  if Suspicion.GetEscalation() > 0 then
    Squad.AddMember(szSquad, hEntity)
    if not self.bSetupSquadLeader[a_nIndex] then
      Squad.SetLeader(szSquad, hEntity)
      self.bSetupSquadLeader[a_nIndex] = true
    end
    Actor.OverrideCombatAI(hEntity, true)
    Nav.MoveToObject(hEntity, Handle(self.tCagePts[a_nIndex][a_nSubIndex]), 0.5, true, "P1FP_Jailbreak.ExitedCell", self, {
      hEntity,
      a_nIndex,
      a_nSubIndex
    }, false, false, cDESTINATION_GO_NO_MATTER_WHAT)
  else
    self.MoveToExitPoint(self, hEntity, a_nIndex, a_nSubIndex)
    self.bPrisonersKeepChecking[hEntity] = true
    local tNaziList = self.SetupSightCheckNaziList(self)
    self.tSightCheckList = self.tSightCheckList or tNaziList
    for i, hNazi in ipairs(tNaziList) do
      Combat.AddTargetFlag(hNazi, cTARGET_ENEMYLIST, self.tNaziTargetList)
    end
  end
end

function P1FP_Jailbreak:MoveToExitPoint(a_hEntity, a_nIndex, a_nSubIndex)
  Actor.OverrideCombatAI(a_hEntity, true)
  Nav.SetScriptedPath(a_hEntity, self.tCagePaths[a_nIndex][a_nSubIndex], true, "P1FP_Jailbreak.PrisFinishedPath", self, {
    a_hEntity,
    a_nIndex,
    a_nSubIndex
  })
  Nav.SetScriptedPathMoveMode(a_hEntity, true)
end

function P1FP_Jailbreak:ExitedCell(a_hEntity, a_nIndex, a_nSubIndex)
  local szSquad = "Jailbreak_Prisoners" .. a_nIndex
  Squad.SetEnemy("GenericNazi", szSquad, true)
  Actor.OverrideCombatAI(a_hEntity, false)
  Combat.SetIdleScripted(a_hEntity, false)
  Combat.SetTargetAggressively(a_hEntity, true)
  Combat.SetReactImmediately(a_hEntity, true)
  Combat.SetRespondToSound(a_hEntity, true)
  Combat.SetRespondToDamage(a_hEntity, true)
  Combat.SetRespondToEvents(a_hEntity, true)
  local tTimerEvent = {
    EventType = "TimerEvent",
    Time = self.nPrisonerTimeWait
  }
  self:RegisterEvent(Util.CreateEvent(tTimerEvent, "P1FP_Jailbreak.TimeFinished", self, {
    a_hEntity,
    a_nIndex,
    a_nSubIndex
  }))
end

function P1FP_Jailbreak:TimeFinished(a_hEntity, a_nIndex, a_nSubIndex)
  local szSquad = "Jailbreak_Prisoners" .. a_nIndex
  Squad.RemoveMember(szSquad, a_hEntity)
  Combat.SetTargetAggressively(a_hEntity, false)
  Combat.SetReactImmediately(a_hEntity, false)
  Combat.SetRespondToSound(a_hEntity, false)
  Combat.SetRespondToDamage(a_hEntity, false)
  Combat.SetRespondToEvents(a_hEntity, false)
  Combat.Exit(a_hEntity)
  Combat.SetIdleScripted(a_hEntity, true)
  Actor.OverrideCombatAI(a_hEntity, true)
  Cin.PlayConversationWith("P1FP_Jailbreak_PrisonersFlee", {a_hEntity})
  self.MoveToExitPoint(self, a_hEntity, a_nIndex, a_nSubIndex)
end

function P1FP_Jailbreak:PrisFinishedPath(a_hEntity, a_nIndex, a_nSubIndex)
  Nav.MoveToObject(a_hEntity, Handle(self.tCageExits[a_nIndex][a_nSubIndex]), 1, true, "P1FP_Jailbreak.EnableRunToDespawn", self, {a_hEntity})
  HUD.RemoveObjectiveMarker(a_hEntity)
  if self.bPrisonersKeepChecking and self.bPrisonersKeepChecking[a_hEntity] == true then
    self.bPrisonersKeepChecking[a_hEntity] = false
  end
  Object.Despawn(a_hEntity, 60, true)
  self.tSpawnClosetQueue[a_nIndex] = self.tSpawnClosetQueue[a_nIndex] or {}
  table.insert(self.tSpawnClosetQueue[a_nIndex], a_hEntity)
end

function P1FP_Jailbreak:EnableRunToDespawn(a_hEntity)
  if a_hEntity and Object.IsAlive(a_hEntity) then
    Actor.WalkToDespawnLocation(a_hEntity, true)
    local tTimerEvent = {EventType = "TimerEvent", Time = 5}
    self:RegisterEvent(Util.CreateEvent(tTimerEvent, "P1FP_Jailbreak.EnableRunToDespawn", self, {a_hEntity}))
  end
end

function P1FP_Jailbreak:CheckDespawnQueue(a_nIndex)
  local function fCreateTimerEvent()
    local tTimerEvent = {EventType = "TimerEvent", Time = 1}
    
    self.tClosetQueueRecheckID[a_nIndex] = Util.CreateEvent(tTimerEvent, "P1FP_Jailbreak.CheckDespawnQueue", self, {a_nIndex})
    self:RegisterEvent(self.tClosetQueueRecheckID[a_nIndex])
  end
  
  local function fUpdateQueue()
    table.remove(self.tSpawnClosetQueue[a_nIndex], 1)
    self.tClosetQueueRecheckID[a_nIndex] = nil
    self.nNumTimesRetriedQueue[a_nIndex] = 0
    if #self.tSpawnClosetQueue[a_nIndex] > 0 then
      self.CheckDespawnQueue(self, a_nIndex)
    end
  end
  
  if #self.tSpawnClosetQueue[a_nIndex] > 0 then
    if Object.IsAlive(self.tSpawnClosetQueue[a_nIndex][1]) then
      if not self.tClosetQueueRecheckID[a_nIndex] then
        Actor.WalkToDespawnLocation(self.tSpawnClosetQueue[a_nIndex][1], true)
        fCreateTimerEvent()
      else
        self.nNumTimesRetriedQueue[a_nIndex] = self.nNumTimesRetriedQueue[a_nIndex] or 0
        self.nNumTimesRetriedQueue[a_nIndex] = self.nNumTimesRetriedQueue[a_nIndex] + 1
        if self.nNumTimesRetriedQueue[a_nIndex] <= 20 and self.nNumTimesRetriedQueue[a_nIndex] % 5 == 0 then
          Actor.WalkToDespawnLocation(self.tSpawnClosetQueue[a_nIndex][1], true)
          fCreateTimerEvent()
        elseif self.nNumTimesRetriedQueue[a_nIndex] > 20 and self.nNumTimesRetriedQueue[a_nIndex] <= 40 then
          fCreateTimerEvent()
        else
          Combat.SetIdleDisperse(self.tSpawnClosetQueue[a_nIndex][1], true)
          fUpdateQueue()
        end
      end
    else
      fUpdateQueue()
    end
  end
end

function P1FP_Jailbreak:DoEscapedCheck()
  if self.nNumDoorsOpened == self.nNumDoors then
    self.CleanupTask(self)
    self.CheckEscalation(self)
  end
end

function P1FP_Jailbreak:ResSoldierDead(a_hEntity)
  self.nNumResDead = self.nNumResDead + 1
  HUD.RemoveObjectiveMarker(a_hEntity)
  if a_hEntity == Handle(self.sCouteau) then
    self:MissionTaskFail("Char_Death.RS_LeCouteau")
  end
end

function P1FP_Jailbreak:ClearSquads()
  for i = 1, 4 do
    local szSquad = "Jailbreak_Prisoners" .. i
    Squad.Delete(szSquad)
  end
end

function P1FP_Jailbreak:PatherSpawned(a_sEntity, a_nTableIndex)
  local hEnt = Handle(a_sEntity)
  local tCombatEnter = {
    EventType = "OnCombatEnter",
    Target = hEnt
  }
  self:RegisterEvent(Util.CreateEvent(tCombatEnter, "P1FP_Jailbreak.CombatEnter", self, {hEnt, a_nTableIndex}))
end

function P1FP_Jailbreak:CombatEnter(a_tCallbackData, a_hEntity, a_nTableIndex)
  local x, y, z = Object.GetPosition(a_hEntity)
  Nav.CancelScriptedPath(a_hEntity)
  Combat.SetTether(a_hEntity, x, y, z, 30, 30)
  local tCombatExit = {
    EventType = "OnCombatExit",
    Target = a_hEntity
  }
  self:RegisterEvent(Util.CreateEvent(tCombatExit, "P1FP_Jailbreak.CombatExit", self, {
    a_hEntity,
    a_nTableIndex,
    x,
    y,
    z
  }))
end

function P1FP_Jailbreak:CombatExit(a_tCallbackData, a_hEntity, a_nTableIndex, a_nX, a_nY, a_nZ)
  Combat.SetTether(a_hEntity, a_nX, a_nY, a_nZ, -1)
  Nav.SetScriptedPath(a_hEntity, self.tNaziPaths[a_nTableIndex][1], true)
  Nav.SetScriptedPathType(a_hEntity, self.tNaziPaths[a_nTableIndex][2])
  local tCombatEnter = {
    EventType = "OnCombatEnter",
    Target = a_hEntity
  }
  self:RegisterEvent(Util.CreateEvent(tCombatEnter, "P1FP_Jailbreak.CombatEnter", self, {a_hEntity, a_nTableIndex}))
end

function P1FP_Jailbreak:DoConversation(a_nIndex)
  local tConvOpenEsc = {
    "P1FP_Jailbreak_JailCell1_Esc",
    "P1FP_Jailbreak_JailCell2_Esc",
    "P1FP_Jailbreak_JailCell3_Esc",
    "P1FP_Jailbreak_JailCell4_Esc"
  }
  local tConvOpenNoEsc = {
    "P1FP_Jailbreak_JailCell1_NoEsc",
    "P1FP_Jailbreak_JailCell2_NoEsc",
    "P1FP_Jailbreak_JailCell3_NoEsc",
    "P1FP_Jailbreak_JailCell4_NoEsc"
  }
  if Suspicion.GetEscalation() > 0 then
    if self:IsMissionTaskActive("P1FP_Jailbreak_Task_HighlightCrochetCell") then
      Cin.PlayConversation("P1FP_Jailbreak_Crochet_Escalate", "P1FP_Jailbreak.WrapUpCrochetTask", self)
    else
      Cin.PlayConversation(tConvOpenEsc[a_nIndex])
    end
  elseif self:IsMissionTaskActive("P1FP_Jailbreak_Task_HighlightCrochetCell") then
    Cin.PlayConversation("P1FP_Jailbreak_Crochet_NoEscalate", "P1FP_Jailbreak.WrapUpCrochetTask", self)
  else
    Cin.PlayConversation(tConvOpenNoEsc[a_nIndex])
  end
end

function P1FP_Jailbreak:DoSightCheck(a_vRetryDuration, a_bConsiderDisguise)
  local hSuspCheckZone = Handle(self.sPATH .. "wtf_low\\SuspicionZone01")
  local tNaziList = self.tSightCheckList or Trigger.GetAllWithin(hSuspCheckZone)
  local bRetry = true
  if not self.tSightCheckList then
    tNaziList = self.SetupSightCheckNaziList(self)
  end
  self.tSightCheckList = self.tSightCheckList or tNaziList
  if a_vRetryDuration ~= false then
    for i, hEntity in ipairs(tNaziList) do
      if Object.IsAlive(hEntity) and Sensory.CanSee(hEntity, self.hSab) then
        if not a_bConsiderDisguise then
          Suspicion.SetEscalatedWithWhistle()
          bRetry = false
          break
        elseif not Actor.IsDisguised(self.hSab) then
          Suspicion.SetEscalatedWithWhistle()
          bRetry = false
          break
        end
      end
    end
  end
  if bRetry == true then
    if a_vRetryDuration == nil then
      if self.bCanRetryIndefinitely == false then
        return
      end
      local tTimerEvent = {EventType = "TimerEvent", Time = 0.25}
      self:RegisterEvent(Util.CreateEvent(tTimerEvent, "P1FP_Jailbreak.DoSightCheck", self, {nil, a_bConsiderDisguise}))
    elseif type(a_vRetryDuration) == "number" and 0 < a_vRetryDuration then
      local tTimerEvent = {EventType = "TimerEvent", Time = 0.25}
      self:RegisterEvent(Util.CreateEvent(tTimerEvent, "P1FP_Jailbreak.DoSightCheck", self, {
        a_vRetryDuration - 0.25,
        a_bConsiderDisguise
      }))
    elseif type(a_vRetryDuration) == "boolean" then
      self.bCanRetryIndefinitely = a_vRetryDuration
    end
  end
end

function P1FP_Jailbreak:DoSightCheckPrisoner(a_hEntity, a_nIndex)
  if Suspicion.GetEscalation() >= 1 then
    if self.bPrisonersKeepChecking and self.bPrisonersKeepChecking[a_hEntity] == true then
      self.bPrisonersKeepChecking[a_hEntity] = false
    end
    return
  end
  local hSuspCheckZone = Handle(self.sPATH .. "wtf_low\\SuspicionZone01")
  local tNaziList = self.tSightCheckList or Trigger.GetAllWithin(hSuspCheckZone)
  local bRetry = true
  if not self.tSightCheckList then
    tNaziList = self.SetupSightCheckNaziList(self)
  end
  self.tSightCheckList = self.tSightCheckList or tNaziList
  self.bSeenPrisoners = self.bSeenPrisoners or {}
  for i, hEnt in ipairs(tNaziList) do
    if Object.IsAlive(hEnt) and Object.IsAlive(a_hEntity) and Sensory.CanSee(hEnt, a_hEntity) then
      if self.bSeenPrisoners[a_nIndex] == false then
        self.bSeenPrisoners[a_nIndex] = true
      end
      Suspicion.SetEscalatedWithWhistle()
      if Actor.IsDisguised(self.hSab) then
        Actor.RemoveDisguise(self.hSab)
      end
      bRetry = false
      break
    end
  end
  if bRetry == true and self.bPrisonersKeepChecking[a_hEntity] == true then
    local tTimerEvent = {EventType = "TimerEvent", Time = 0.25}
    self:RegisterEvent(Util.CreateEvent(tTimerEvent, "P1FP_Jailbreak.DoSightCheckPrisoner", self, {a_hEntity, a_nIndex}))
  end
end

function P1FP_Jailbreak:SetupSightCheckNaziList()
  local hSuspCheckZone = Handle(self.sPATH .. "wtf_low\\SuspicionZone01")
  local tNaziList = self.tSightCheckList or Trigger.GetAllWithin(hSuspCheckZone)
  local i = 1
  while i <= #tNaziList do
    local hEntity = tNaziList[i]
    local bBreak = false
    local bCanInc = true
    if hEntity == self.hSab then
      table.remove(tNaziList, i)
      bCanInc = false
    end
    if bCanInc == true then
      for j, tCage in ipairs(self.tPrisoners) do
        for k, sEntity in ipairs(tCage) do
          local hEnt = Handle(sEntity)
          if hEnt == hEntity then
            table.remove(tNaziList, i)
            bBreak = true
            bCanInc = false
            break
          end
        end
        if bBreak == true then
          break
        end
      end
    end
    if bCanInc == true then
      i = i + 1
    end
  end
  return tNaziList
end

function P1FP_Jailbreak:MISSION_ONRESET()
  Sound.ReleaseSoundBank("m_P1fP_Jailbreak.bnk")
  self.TurnOffEmitters(self)
  self.RemoveSuspCircle(self)
end
