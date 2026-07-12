if CFP_GiselleRescue == nil then
  CFP_GiselleRescue = SabTaskObjective:Create()
  CFP_GiselleRescue.sPATH = "Missions\\freeplay\\country\\mis_giselle_rescue\\"
  CFP_GiselleRescue:Configure({
    TaskCount = 99,
    bStarterless = true,
    bFreeplay = true,
    sSaveMissionNameID = "MissionNames_Text.CFP_GiselleRescue",
    tUnlockList = {},
    WTFZoneHigh = "WtF_Zones\\global\\FP_Chenonceaux",
    tSMEDNodes = {
      CFP_GiselleRescue.sPATH .. "task",
      CFP_GiselleRescue.sPATH .. "main"
    }
  })
end

function CFP_GiselleRescue:STARTER_Setup()
end

function CFP_GiselleRescue:Activated()
  SabTaskObjective.Activated(self)
  self.sDebugLabel = "GISELLERESCUE"
  self.bDebugMode = false
  dprint(self, "Running GiselleRescue.")
  self.SetupVariables(self)
  self.ExitHQ(self)
  self.Task_FindChateau(self)
end

function CFP_GiselleRescue:GENERAL_Setup()
  dprint(self, "GeneralSetup()")
end

function CFP_GiselleRescue:SetupVariables()
  dprint(self, "SetupVariables()")
  self.hSab = Handle("Saboteur")
  self.bVariablesSet = true
  self.sChateauLoc = self.sPATH .. "task\\LOC_ChateauLoc"
  self.sChateauTrig = self.sPATH .. "task\\PT_ChateauTrig"
  self.sGiselle = self.sPATH .. "main\\Giselle"
  self.sSmoker = self.sPATH .. "main\\SmokerGuard01"
  self.sSmokerPath = self.sPATH .. "main\\PA_SmallSqSmoke01"
  self.tCaptors = {
    self.sPATH .. "main\\Guard01",
    self.sPATH .. "main\\Guard02",
    self.sPATH .. "main\\Guard03",
    self.sPATH .. "main\\Officer"
  }
  self.tCondoms = {
    self.sPATH .. "mission\\Condoms01\\Crate",
    self.sPATH .. "mission\\Condoms02\\Crate"
  }
  self.tNaziPathers = {
    self.sPATH .. "wtf_low\\Pather01",
    self.sPATH .. "wtf_low\\Pather02",
    self.sPATH .. "wtf_low\\Pather03",
    self.sPATH .. "wtf_low\\Pather04",
    self.sPATH .. "wtf_low\\Pather05",
    self.sPATH .. "main\\Guard04",
    self.sPATH .. "main\\Guard05",
    self.sPATH .. "main\\VarGuard01"
  }
  self.tNaziPaths = {
    {
      self.sPATH .. "wtf_low\\PA_BigSqInner",
      cPATHTYPE_LOOP
    },
    {
      self.sPATH .. "wtf_low\\PA_BigSqOuter",
      cPATHTYPE_BOUNCE
    },
    {
      self.sPATH .. "wtf_low\\PA_Center01",
      cPATHTYPE_BOUNCE
    },
    {
      self.sPATH .. "wtf_low\\PA_SmallSqInner",
      cPATHTYPE_LOOP
    },
    {
      self.sPATH .. "wtf_low\\PA_SmallSqOuter",
      cPATHTYPE_LOOP
    },
    {
      self.sPATH .. "main\\PA_Storage01",
      cPATHTYPE_BOUNCE
    },
    {
      self.sPATH .. "main\\PA_Garden01",
      cPATHTYPE_LOOP
    },
    {
      self.sPATH .. "main\\PA_SmallSqVar",
      cPATHTYPE_LOOP
    }
  }
  local sTag = "mis_giselle_rescue_mission"
  if not Util.IsCustomTagLoaded(sTag) then
    Util.LoadStaticENTag(sTag, true)
  end
  for i, sEnt in ipairs(self.tNaziPathers) do
    local tStreamEvent = {
      EventType = "StreamEvent",
      Objects = {sEnt},
      WaitForGameObject = true
    }
    self:RegisterEvent(Util.CreateEvent(tStreamEvent, "CFP_GiselleRescue.PatherSpawned", self, {sEnt, i}))
  end
end

function CFP_GiselleRescue:SetupCheckpoint(a_nCP)
  dprint(self, "SetupCheckpoint()")
  self.tSaveInfo.nCheckpointNum = a_nCP
  self.RegisterCheckpoint(self, "CFP_GiselleRescue.DoCheckpoint")
end

function CFP_GiselleRescue:DoCheckpoint()
  dprint(self, "DoCheckpoint()")
  local nCP = self.tSaveInfo.nCheckpointNum
  if not self.bVariablesSet then
    self.SetupVariables(self)
  end
  self.DoStreamEvent(self)
  if nCP == 1 then
    if not self:IsMissionTaskActive("CFP_GiselleRescue_Task_FindChateau") then
      self.Task_FindChateau(self)
    end
  elseif nCP == 2 then
    self.Task_KillCaptors(self)
    self.SmokerDoPath(self, false)
  elseif nCP == 3 then
    self.Task_TalkToGiselle(self)
  elseif nCP == 4 then
    self.Task_DestroyCondoms(self)
  end
end

function CFP_GiselleRescue:DoStreamEvent()
  dprint(self, "DoStreamEvent()")
  local tStreamEvent
  tStreamEvent = {
    EventType = "StreamEvent",
    Objects = {
      self.sGiselle
    },
    WaitForGameObject = true
  }
  self:RegisterEvent(Util.CreateEvent(tStreamEvent, "CFP_GiselleRescue.ObjectLoaded", self, {
    self.sGiselle
  }))
  tStreamEvent = {
    EventType = "StreamEvent",
    Objects = {
      self.sSmoker
    },
    WaitForGameObject = true
  }
  self:RegisterEvent(Util.CreateEvent(tStreamEvent, "CFP_GiselleRescue.ObjectLoaded", self, {
    self.sSmoker
  }))
  tStreamEvent = {
    EventType = "StreamEvent",
    Objects = self.tCaptors,
    WaitForGameObject = true
  }
  self:RegisterEvent(Util.CreateEvent(tStreamEvent, "CFP_GiselleRescue.ObjectLoaded", self, {
    self.tCaptors
  }))
end

function CFP_GiselleRescue:ExitHQ()
  dprint(self, "ExitHQ()")
  self:CreateTask({
    sName = "CFP_GiselleRescue_ExitHQ",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "ExitInterior",
    sInteriorName = "Belle",
    tOnComplete = {
      {
        self.SetupCheckpoint,
        {self, 1}
      }
    }
  })
end

function CFP_GiselleRescue:Task_MainTask()
  dprint(self, "Task_MainTask()")
  self:CreateTask({
    sName = "CFP_GiselleRescue_Task_MainTask",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "NONE",
    sObjectiveTextID = "CFP_GiselleRescue_Text.Task_MainTask",
    bPersistentParent = true,
    tOnActivate = {},
    tOnComplete = {
      {
        self.SetupCheckpoint,
        {self, 4}
      }
    }
  })
end

function CFP_GiselleRescue:Task_FindChateau()
  dprint(self, "Task_FindChateau()")
  self:CreateTask({
    sName = "CFP_GiselleRescue_Task_FindChateau",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tLocators = {
      self.sChateauLoc
    },
    tDestRegion = {
      self.sChateauTrig
    },
    tDeliverObjs = {
      self.hSab
    },
    sObjectiveTextID = "CFP_GiselleRescue_Text.Task_FindChateau",
    ParentObjectID = -1,
    tOnActivate = {},
    tOnComplete = {
      {
        self.SetupCheckpoint,
        {self, 2}
      }
    }
  })
end

function CFP_GiselleRescue:Task_KillCaptors()
  dprint(self, "Task_KillCaptors()")
  self:CreateTask({
    sName = "CFP_GiselleRescue_Task_KillCaptors",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "KILL",
    tTgtInclude = self.tCaptors,
    sObjectiveTextID = "CFP_GiselleRescue_Text.Task_KillCaptors",
    ParentObjectID = -1,
    tOnActivate = {},
    tOnComplete = {
      {
        self.SetupCheckpoint,
        {self, 3}
      }
    }
  })
end

function CFP_GiselleRescue:Task_TalkToGiselle()
  dprint(self, "Task_TalkToGiselle()")
  self:CreateTask({
    sName = "CFP_GiselleRescue_Task_TalkToGiselle",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "TALK",
    sObjectiveTextID = "CFP_GiselleRescue_Text.Task_TalkToGiselle",
    ParentObjectID = -1,
    sConvFile = "CFP_GiselleRescue_SeanSaves",
    tTgtInclude = {
      self.sGiselle
    },
    bAutofire = true,
    tOnActivate = {},
    tOnComplete = {
      {
        self.SetupCheckpoint,
        {self, 4}
      }
    }
  })
end

function CFP_GiselleRescue:Task_DestroyCondoms()
  dprint(self, "Task_DestroyCondoms()")
  self:CreateTask({
    sName = "CFP_GiselleRescue_Task_DestroyCondoms",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "KILL",
    tTgtInclude = self.tCondoms,
    sObjectiveTextID = "CFP_GiselleRescue_Text.Task_DestroyCondoms",
    ParentObjectID = -1,
    tOnActivate = {},
    tOnComplete = {
      {
        self.DoCleanup,
        {self}
      }
    }
  })
end

function CFP_GiselleRescue:ObjectLoaded(a_vObject)
  dprint(self, "ObjectLoaded()")
  if type(a_vObject) == "table" then
    local tTimerEvent = {
      EventType = "TimerEvent",
      Time = 15 + math.random(3, 7)
    }
    self.eScreamEvent = Util.CreateEvent(tTimerEvent, "CFP_GiselleRescue.DoGiselleScream", self)
    self:RegisterEvent(self.eScreamEvent)
    for i, sEntity in ipairs(self.tCaptors) do
      local hEnt = Handle(sEntity)
      local tCombatEnter = {
        EventType = "OnCombatEnter",
        Target = hEnt
      }
      self:RegisterEvent(Util.CreateEvent(tCombatEnter, "CFP_GiselleRescue.CaptorCombatEnter", self, {hEnt}))
    end
  elseif a_vObject == self.sGiselle then
    self.hGiselle = Handle(a_vObject)
    Object.SetHealth(self.hGiselle, 500)
    Actor.SetPanicEnabled(self.hGiselle, false)
    Object.SetInvincibleToAI(self.hGiselle, true)
    Actor.OverrideCombatAI(self.hGiselle, true)
    local tDeathEvent = {
      EventType = "DeathEvent",
      ObjectHandle = self.hGiselle
    }
    self.eGisDeath = Util.CreateEvent(tDeathEvent, "CFP_GiselleRescue.EntityDied", self)
    self:RegisterEvent(self.eGisDeath)
  elseif a_vObject == self.sSmoker then
    self.hSmoker = Handle(a_vObject)
    local tCombatEnter = {
      EventType = "OnCombatEnter",
      Target = self.hSmoker
    }
    self:RegisterEvent(Util.CreateEvent(tCombatEnter, "CFP_GiselleRescue.SmokerCombatEnter", self))
  end
end

function CFP_GiselleRescue:SmokerDoPath(a_bNearest, a_nX, a_nY, a_nZ)
  dprint(self, "SmokerDoPath()")
  Actor.CancelAnimation(self.hSmoker)
  if a_nX ~= nil and a_nY ~= nil and a_nZ ~= nil then
    Combat.SetTether(self.hSmoker, a_nX, a_nY, a_nZ, -1)
  end
  Nav.SetScriptedPath(self.hSmoker, self.sSmokerPath, a_bNearest, "CFP_GiselleRescue.SmokerPathFinished", self)
  Nav.SetScriptedPathType(self.hSmoker, cPATHTYPE_ONCE)
end

function CFP_GiselleRescue:SmokerPathFinished()
  dprint(self, "SmokerPathFinished()")
  Actor.ForceSmoking(self.hSmoker)
  local nTime = math.random(22, 27)
  local tTimerEvent = {EventType = "TimerEvent", Time = nTime}
  self.eSmokerEvent = Util.CreateEvent(tTimerEvent, "CFP_GiselleRescue.SmokerDoPath", self, {false})
  self:RegisterEvent(self.eSmokerEvent)
end

function CFP_GiselleRescue:SmokerCombatEnter()
  dprint(self, "SmokerCombatEnter()")
  Util.KillEvent(self.eSmokerEvent)
  local x, y, z = Object.GetPosition(self.hSmoker)
  Nav.CancelScriptedPath(self.hSmoker)
  Combat.SetTether(self.hSmoker, x, y, z, 20, 15)
  local tCombatExit = {
    EventType = "OnCombatExit",
    Target = self.hSmoker
  }
  self:RegisterEvent(Util.CreateEvent(tCombatExit, "CFP_GiselleRescue.SmokerDoPath", self, {
    true,
    x,
    y,
    z
  }))
end

function CFP_GiselleRescue:EntityDied()
  dprint(self, "EntityDied()")
  self:MissionTaskFail("You let Giselle die!")
end

function CFP_GiselleRescue:DoGiselleScream()
  local nLimit = #self.tCaptors
  local nRandNazi = math.random(1, nLimit)
  local i = nRandNazi
  local bLooped = false
  local bCanDoScream = false
  local hEnt, tTimerEvent
  while 0 < i do
    if nLimit < i then
      i = 1
      bLooped = true
    end
    if i == nRandNazi and bLooped == true then
      break
    end
    local hEnt = Handle(self.tCaptors[i])
    if Object.IsAlive(hEnt) and not Actor.IsInCombat(hEnt) then
      bCanDoScream = true
      break
    end
    i = i + 1
  end
  if bCanDoScream == true then
    Cin.PlayConversation("CFP_GiselleRescue_Scream")
    tTimerEvent = {
      EventType = "TimerEvent",
      Time = math.random(25, 75) / 100
    }
    self.eGruntEvent = Util.CreateEvent(tTimerEvent, "CFP_GiselleRescue.DoSoldierRetort", self, {i})
    self:RegisterEvent(self.eGruntEvent)
  else
    Cin.PlayConversation("CFP_GiselleRescue_Scream")
  end
  if bCanDoScream then
    tTimerEvent = {
      EventType = "TimerEvent",
      Time = 15 + math.random(3, 7)
    }
  else
    tTimerEvent = {
      EventType = "TimerEvent",
      Time = 25 + math.random(3, 7)
    }
  end
  self.eScreamEvent = Util.CreateEvent(tTimerEvent, "CFP_GiselleRescue.DoGiselleScream", self)
  self:RegisterEvent(self.eScreamEvent)
end

function CFP_GiselleRescue:DoSoldierRetort(a_nIndex)
  Cin.PlayConversationWith("CFP_GiselleRescue_NaziTaunt", {
    Handle(self.tCaptors[i])
  })
end

function CFP_GiselleRescue:CaptorCombatEnter(a_hEntity)
  if self.eGruntEvent then
    Util.KillEvent(self.eGruntEvent)
    self.eGruntEvent = nil
  end
  local tCombatEnter = {
    EventType = "OnCombatEnter",
    Target = a_hEntity
  }
  self:RegisterEvent(Util.CreateEvent(tCombatEnter, "CFP_GiselleRescue.CaptorCombatEnter", self, {a_hEntity}))
end

function CFP_GiselleRescue:DoCleanup()
  dprint(self, "DoCleanup()")
  local sTag = "mis_giselle_rescue_mission"
  if not Util.IsCustomTagLoaded(sTag) then
    Util.UnloadStaticENTag(sTag, false)
  end
  self:CompleteThisMission()
end

function CFP_GiselleRescue:PatherSpawned(a_sEntity, a_nTableIndex)
  local hEnt = Handle(a_sEntity)
  local tCombatEnter = {
    EventType = "OnCombatEnter",
    Target = hEnt
  }
  self:RegisterEvent(Util.CreateEvent(tCombatEnter, "CFP_GiselleRescue.CombatEnter", self, {hEnt, a_nTableIndex}))
end

function CFP_GiselleRescue:CombatEnter(a_tCallbackData, a_hEntity, a_nTableIndex)
  local x, y, z = Object.GetPosition(a_hEntity)
  Nav.CancelScriptedPath(a_hEntity)
  Combat.SetTether(a_hEntity, x, y, z, 20, 15)
  local tCombatExit = {
    EventType = "OnCombatExit",
    Target = a_hEntity
  }
  self:RegisterEvent(Util.CreateEvent(tCombatExit, "CFP_GiselleRescue.CombatExit", self, {
    a_hEntity,
    a_nTableIndex,
    x,
    y,
    z
  }))
end

function CFP_GiselleRescue:CombatExit(a_tCallbackData, a_hEntity, a_nTableIndex, a_nX, a_nY, a_nZ)
  Combat.SetTether(a_hEntity, a_nX, a_nY, a_nZ, -1)
  Nav.SetScriptedPath(a_hEntity, self.tNaziPaths[a_nTableIndex][1], true)
  Nav.SetScriptedPathType(a_hEntity, self.tNaziPaths[a_nTableIndex][2])
  local tCombatEnter = {
    EventType = "OnCombatEnter",
    Target = a_hEntity
  }
  self:RegisterEvent(Util.CreateEvent(tCombatEnter, "CFP_GiselleRescue.CombatEnter", self, {a_hEntity, a_nTableIndex}))
end
