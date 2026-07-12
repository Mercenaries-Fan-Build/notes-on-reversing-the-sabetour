if Paris_4_Mission_1 == nil then
  Paris_4_Mission_1 = SabTaskObjective:Create()
  gsParis4Mission1Dir = "Missions\\paris_4\\mission_1\\"
  Paris_4_Mission_1:Configure({
    tDependencyList = {},
    tUnlockList = {
      "Paris_4_Mission_1B"
    },
    TaskCount = "auto",
    sStarter = "Moreau_Exterior",
    sConvFile = "216_Con_Cemetary",
    sSaveMissionNameID = "MissionNames_Text.P4M1",
    bEscalationDenial = true,
    tSMEDNodes = {
      gsParis4Mission1Dir .. "main",
      gsParis4Mission1Dir .. "disposabletruck",
      gsParis4Mission1Dir .. "Underground",
      "Missions\\hq_dropoff\\belle"
    }
  })
end

function Paris_4_Mission_1:STARTER_Setup()
  self.sDebugLabel = "P4M1"
  self.bDebugMode = false
  Util.LoadStaticENTag("P4M1Box", true)
  if SabTask:IsCompletedMission("Paris_1_Mission_1B") then
  else
    Util.UnloadStaticENTag("lavillette_occupation", true)
    Zone.SwitchState("WtF_Zones\\global\\P1M1B_SlaughterhouseLiberate", cZONESTATE_HIGHCOLOR_HIGHTAG, cENT_DURINGSTREAM)
  end
end

function Paris_4_Mission_1:Activated()
  dprint(self, "P4M1 Active")
  self:GENERAL_Setup()
  SabTaskObjective.Activated(self)
  self:SetupCheckPoint1()
end

function Paris_4_Mission_1:GENERAL_Setup()
  Sound.SetMusicLocale("P4M1_Cemetary")
  Sound.SetMusicLocale("m_P4M1_Cemetary", "P4M1_start")
  self:AddOnCancelCallback(Paris_4_Mission_1.Cleanup)
  self:AddOnCompleteCallback(Paris_4_Mission_1.Cleanup)
  self.nNaziTicker = 0
  self.nTimer = 60
  Sound.LoadSoundBank("m_P4M1_inGame.bnk")
  self.nRainValue = 1
  Object.SetHealth(Util.GetHandleByName("Missions\\paris_4\\characters\\cemetary\\exterior\\moreau\\Moreau_Exterior"), 7000)
  self.tInfo = {}
  self.tInfo.TRUCKMAXHEALTH = 100
  self.tInfo.TRUCKHEALTH = self.tInfo.TRUCKMAXHEALTH
  self.nBoxValue = 0
  self.sSkyEntryPath1 = "Missions\\paris_4\\mission_1\\main\\New Path"
  self.sSkyEntryPath2 = "Missions\\paris_4\\mission_1\\main\\New Path(2)"
  self.sExitSkylar = "Missions\\paris_4\\mission_1\\escape\\Spore_RS_Skylar"
  self.sExitTruck = "Missions\\paris_4\\mission_1\\escape\\VH_NZ_TR_OpelCanvas_01"
  self.sEncounter2Path = "Missions\\paris_4\\mission_1\\escape\\New Path(3)"
  self.sDepotTruck = "PARIS\\area04\\cem_lachaise\\occupation\\outer\\motor pool\\props\\VH_NZ_TR_OpelCanvas_01(1)"
  self.sTruckDisposablePath = "Missions\\paris_4\\mission_1\\main\\TruckLeavingPath"
  self.sTruckDisposable = "Missions\\paris_4\\mission_1\\disposabletruck\\VH_NZ_TR_OpelCanvas_01(1)"
  self.sTruckDriver = "PARIS\\area04\\cem_lachaise\\occupation\\outer\\motor pool\\nazis\\Spore_WM_Rifleman_RF(3)"
  self.sVineDoor = "Missions\\paris_4\\mission_1\\Door\\AnimatedObject_CEM_VineDoor\\Door"
  self.sSittingDepotNazi1 = "PARIS\\area04\\cem_lachaise\\occupation\\outer\\motor pool\\nazis\\Spore_WM_Grunt_MG(4)"
  self.sSittingDepotNazi2 = "PARIS\\area04\\cem_lachaise\\occupation\\outer\\motor pool\\nazis\\Spore_WM_Grunt_MG(2)"
  self.sEncounter2Gate = "PARIS\\area04\\cem_lachaise\\occupation\\inner\\props\\Occ_SecFence_PedGate5m_DoorFrame(8)\\AnimatedObject_Occ_PedGate5m"
  self.sRunn1Enc1 = "Missions\\paris_4\\mission_1\\escape\\Spore_TS_Commander_SH(28)"
  self.sTrigRunEnc1 = "Missions\\paris_4\\mission_1\\main\\SetRunnersEnc1"
  self.sMausSpawner = "Missions\\paris_4\\mission_1\\main\\CoDSpawner"
  self.sDepotTruckPassenger = "PARIS\\area04\\cem_lachaise\\occupation\\outer\\motor pool\\nazis\\Spore_WM_Rifleman_RF(1)"
  self.sMoveToGatePath = "PARIS\\area04\\cem_lachaise\\occupation\\outer\\motor pool\\nazis\\MoveToGate"
  self.sSkylarDepotTruck = "Missions\\paris_4\\mission_1\\disposabletruck\\VH_NZ_TR_OpelCanvas_01(2)"
  self.sUG1PatrolRoute = "PARIS\\area04\\cem_lachaise\\occupation\\outer\\general\\nazis\\UG1PatrolRoute"
  self.sUGPatNazi1 = "PARIS\\area04\\cem_lachaise\\occupation\\outer\\general\\nazis\\Spore_TS_Trooper_MG(5)"
  self.tCryptEncNazis = {
    "Missions\\paris_4\\mission_1\\CryptEncounter\\Spore_WM_Grunt_MG(5)",
    "Missions\\paris_4\\mission_1\\CryptEncounter\\Spore_WM_Grunt_MG",
    "Missions\\paris_4\\mission_1\\CryptEncounter\\Spore_WM_Grunt_MG(2)",
    "Missions\\paris_4\\mission_1\\CryptEncounter\\Spore_WM_Grunt_MG(3)",
    "Missions\\paris_4\\mission_1\\CryptEncounter\\Spore_WM_Grunt_MG(4)"
  }
  self.sEscapeTruckPullupTrig1 = "Missions\\paris_4\\mission_1\\main\\EscapeTruckPullUpTrig"
  self.sEscapeChaser = "Missions\\paris_4\\mission_1\\escape\\VH_NZ_CR_Kubelwagen_mount"
  self.sEscapePullupPath = "Missions\\paris_4\\mission_1\\escape\\TruckPullUpPath"
  self.sEscapeChaser2 = "Missions\\paris_4\\mission_1\\escapechasekubel\\VH_NZ_CR_Kubelwagen_mount(3)"
  self.sEscapeChaser2Path = "Missions\\paris_4\\mission_1\\escapechasekubel\\Chaser2Path"
  self.sEscapeChaser2Trig = "Missions\\paris_4\\mission_1\\main\\EscapeTruckPullUpTrig2"
  self.sSkylarWalkAwayPath = "Missions\\paris_4\\characters\\cemetary\\exterior\\moreau\\SkylarGoAwayPath"
  self.sFightBackTrig = "Missions\\paris_4\\mission_1\\main\\FightbackTrig"
  self.bForceEscalation = true
end

function Paris_4_Mission_1:CompleteMission()
  CompleteCurrentMission()
end

function Paris_4_Mission_1:FailMission()
  Object.Kill(hSab)
end

function Paris_4_Mission_1:Cleanup()
  gsParis4Mission1Dir = nil
end

function Paris_4_Mission_1:SkylarRunAway()
  self:DespawnSkylar()
end

function Paris_4_Mission_1:DespawnSkylar()
  Util.KillEvent("SkyStartFail")
  RewardsManager.HideStarter("Moreau_Exterior")
end

function Paris_4_Mission_1:TASK_MausoleumWaypoint()
  self:CreateTask({
    sName = "TASK_MausoleumWaypoint",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "GOTO",
    ParentObjectID = self:GetTaskObjectiveID("TASK_MausoleumWaypoint"),
    sObjectiveTextID = "P4M1_Text.TASK_MausoleumWaypoint",
    bNoWorldBlip = true,
    tLocators = {
      "Missions\\paris_4\\mission_1\\main\\CryptLocator"
    },
    tOnActivate = {
      {
        self.SetupCancelListenener,
        {self}
      }
    },
    tOnComplete = {}
  })
end

function Paris_4_Mission_1:TASK_FollowSkylar()
  self:CreateTask({
    sName = "TASK_FollowSkylar",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "empty",
    sObjectiveTextID = "P4M1_Text.TASK_FollowSkylar",
    ParentObjectID = self:GetTaskObjectiveID("TASK_MausoleumWaypoint"),
    tLocators = {},
    tOnActivate = {},
    tOnComplete = {}
  })
end

function Paris_4_Mission_1:SetupCheckPoint1()
  self.RegisterCheckpoint(self, "Paris_4_Mission_1.CheckPoint1")
end

function Paris_4_Mission_1:CheckPoint1()
  local hVindedoor = Util.GetHandleByName(self.sVineDoor)
  self:SkylarRunAway()
  self:SetupSkylarOutsideDeathFail()
  self:SetupAreaFailListener()
  self:SetEntryListener()
  self:TASK_MausoleumWaypoint()
end

function Paris_4_Mission_1:SetupSkylarOutsideDeathFail()
end

function Paris_4_Mission_1:SetupCheckPoint2()
  self.RegisterCheckpoint(self, "Paris_4_Mission_1.CheckPoint2")
end

function Paris_4_Mission_1:CheckPoint2()
  self.CompleteTaskByName(self, "TASK_LookAroundSean")
  self.CompleteTaskByName(self, "TASK_MausoleumWaypoint")
  self:AndtheConvoListener()
  self:TASK_MasterInvestigate()
end

function Paris_4_Mission_1:SetupCheckPoint3()
  self.RegisterCheckpoint(self, "Paris_4_Mission_1.CheckPoint3")
end

function Paris_4_Mission_1:CheckPoint3()
  if self.tInfo.hSkylarsTruckObj then
    HUD.RemoveObjective(self.tInfo.hSkylarsTruckObj)
    self.tInfo.hSkylarsTruckObj = nil
  end
  Suspicion.SetFixedEscalationLevel(3)
  Suspicion.SetEscalationLevel(3)
  self:SetupNegProxyEvent()
  self:TASK_ProtectSkylar()
  self:HealthBarStuff()
  self:SetupTruckTrig()
  self:SetupTruck2Listener()
  self:TASK_ExitCemetary()
  self:SetupNearHQ()
  EVENT_ActorDeath("Paris_4_Mission_1.FailMissionByProxy", self, self.hTruck)
end

function Paris_4_Mission_1:SetupCheckPoint4()
  self.RegisterCheckpoint(self, "Paris_4_Mission_1.CheckPoint4")
end

function Paris_4_Mission_1:CheckPoint4()
  self:TASK_TaketheWheel()
end

function Paris_4_Mission_1:OPTIONAL_TakeUnderPassage()
  self:CreateTask({
    sName = "Paris_4_Mission_1_Task_TakeTheUnderPassage",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    bOptional = true,
    ParentObjectID = self:GetTaskObjectiveID("TASK_MausoleumWaypoint"),
    sObjectiveTextID = "P4M1_Text.OPTIONAL_TakeUnderPassage",
    tDeliverObjs = {hSab},
    tDestRegion = {
      "Missions\\paris_4\\mission_1\\main\\crypts\\PT_Enterance"
    },
    tLocators = {
      "Missions\\paris_4\\mission_1\\Underground\\TaskgotoLoc"
    },
    tOnActivate = {
      {
        self.SetupCancelListenener,
        {self}
      },
      {
        self.SetupUnderPassListener,
        {self}
      },
      {
        self.SetupUGExitListener,
        {self}
      },
      {
        self.SetupUG2Enter,
        {self}
      },
      {
        self.SetupTallCryptSee,
        {self}
      },
      {
        self.SetupMausSee,
        {self}
      },
      {
        self.WaitforUGNazi,
        {self}
      }
    },
    tOnComplete = {}
  })
end

function Paris_4_Mission_1:SetupMausSee()
  local tMausSee = {
    EventType = "SeeLocatorEvent",
    InViewTime = 0.7,
    Locator = "Missions\\paris_4\\mission_1\\main\\Locator(7)",
    Proximity = 20
  }
  Util.CreateEvent(tMausSee, "Paris_4_Mission_1.FireMausSee", self)
end

function Paris_4_Mission_1:FireMausSee()
  Cin.PlayConversation("P4M1_Mausoleum_Discovered")
end

function Paris_4_Mission_1:SetupUnderPassListener()
  local tLocSee = {
    EventType = "SeeLocatorEvent",
    InViewTime = 2,
    Locator = "Missions\\paris_4\\mission_1\\main\\crypts\\Loc_Cover"
  }
  Util.CreateEvent(tLocSee, "Paris_4_Mission_1.FireUGSeenConvo", self)
end

function Paris_4_Mission_1:SetupUGExitListener()
  local tLocSExit = {
    EventType = "SeeLocatorEvent",
    InViewTime = 0.5,
    Locator = "Missions\\paris_4\\mission_1\\main\\Locator(1)"
  }
  Util.CreateEvent(tLocSExit, "Paris_4_Mission_1.FireUGExitConvo", self)
end

function Paris_4_Mission_1:SetupUG2Enter()
  local tUG2LocEnter = {
    EventType = "SeeLocatorEvent",
    InViewTime = 0.5,
    Locator = "Missions\\paris_4\\mission_1\\main\\Locator(4)",
    Proximity = 10
  }
  Util.CreateEvent(tUG2LocEnter, "Paris_4_Mission_1.FireSecondUGEnt", self)
end

function Paris_4_Mission_1:SetupTallCryptSee()
  local tTallCryptSee = {
    EventType = "SeeLocatorEvent",
    InViewTime = 1,
    Locator = "Missions\\paris_4\\mission_1\\main\\Locator(6)",
    Proximity = 10
  }
  Util.CreateEvent(tTallCryptSee, "Paris_4_Mission_1.FireTallCryptSee", self)
end

function Paris_4_Mission_1:FireTallCryptSee()
  Cin.PlayConversation("P4M1_TallCrypt_Discovered")
  self:CancelTask()
end

function Paris_4_Mission_1:FireSecondUGEnt()
  Cin.PlayConversation("P4M1_Underground02_Discovered")
end

function Paris_4_Mission_1:FireUGSeenConvo()
  Cin.PlayConversation("P4M1_Underground01_Discovered")
end

function Paris_4_Mission_1:FireUGExitConvo()
  Cin.PlayConversation("P4M1_Underground01_Exit")
end

function Paris_4_Mission_1:OPTIONAL_TakeSecondPassage()
  self:CreateTask({
    sName = "OPTIONAL_TakeSecondPassage",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    bOptional = true,
    ParentObjectID = self:GetTaskObjectiveID("TASK_MausoleumWaypoint"),
    sObjectiveTextID = "P4M1_Text.OPTIONAL_TakeSecondPassage",
    tDeliverObjs = {hSab},
    tDestRegion = {
      "Missions\\paris_4\\mission_1\\main\\PT_New[5]"
    },
    tLocators = {
      "Missions\\paris_4\\mission_1\\main\\Locator(2)"
    },
    tOnActivate = {
      {
        self.SetupCancelListenener,
        {self}
      }
    },
    tOnComplete = {}
  })
end

function Paris_4_Mission_1:TestActuate()
  Object.Actuate(Util.GetHandleByName("PARIS\\area04\\cem_lachaise\\occupation\\DOOR_Crypt_Entrance"), true)
end

function Paris_4_Mission_1:SetupCancelListenener()
  local sDisguisedConvoTrig = "Missions\\paris_4\\mission_1\\main\\DisguisedEncounterTrig"
  Trigger.WaitFor("Missions\\paris_4\\mission_1\\main\\PT_New[3]", hSab, "Paris_4_Mission_1.CancelTask", self, nil, cTRIGGEREVENT_ONENTER, false)
  Trigger.WaitFor(sDisguisedConvoTrig, hSab, "Paris_4_Mission_1.PlayUG2DisguisedConvo", self, nil, cTRIGGEREVENT_ONENTER, false)
  Trigger.WaitFor("Missions\\paris_4\\mission_1\\main\\PT_AmbConvo2", hSab, "Paris_4_Mission_1.PlayAmbConvo2", self, nil, cTRIGGEREVENT_ONENTER, false)
  Trigger.WaitFor("Missions\\paris_4\\mission_1\\main\\PT_AmbConvo3", hSab, "Paris_4_Mission_1.PlayAmbConvo3", self, nil, cTRIGGEREVENT_ONENTER, false)
end

function Paris_4_Mission_1:PlayAmbConvo2()
  if Suspicion.GetEscalation() == 0 then
    Cin.PlayConversation("P4M1_Ambient_NaziConv03")
  else
  end
end

function Paris_4_Mission_1:PlayAmbConvo3()
  if Suspicion.GetEscalation() == 0 then
    Cin.PlayConversation("P4M1_Ambient_NaziConv02")
  else
  end
end

function Paris_4_Mission_1:CancelTask()
  self:KillTaskByName("Paris_4_Mission_1_Task_TakeTheUnderPassage")
  self:KillTaskByName("OPTIONAL_TakeSecondPassage")
  self:TASK_LoadWaypointindicator()
  self:SetupKubelSpawnReinF()
end

function Paris_4_Mission_1:SetupEventListeners()
  local tSeeLocEvent = {
    EventType = "SeeLocatorEvent",
    InViewTime = 2,
    Locator = "Missions\\paris_4\\mission_1\\Underground\\TaskVisLoc"
  }
  Util.CreateEvent(tSeeLocEvent, "Paris_4_Mission_1.OPTIONAL_TakeUnderPassage", self)
end

function Paris_4_Mission_1:RainStatesListeners()
  Trigger.WaitFor("Missions\\paris_4\\mission_1\\underground\\UGTrigger", hSab, "Paris_4_Mission_1.RainToggler", self, nil, cTRIGGEREVENT_ONENTER, true)
  Trigger.WaitFor("Missions\\paris_4\\mission_1\\main\\PT_New", hSab, "Paris_4_Mission_1.RainToggler", self, nil, cTRIGGEREVENT_ONENTER, true)
  Trigger.WaitFor("Missions\\paris_4\\mission_1\\main\\PT_RainOccluder", hSab, "Paris_4_Mission_1.RainToggler", self, nil, cTRIGGEREVENT_ONENTER, true)
  Trigger.WaitFor("Missions\\paris_4\\mission_1\\main\\PT_New[1]", hSab, "Paris_4_Mission_1.RainToggler", self, nil, cTRIGGEREVENT_ONENTER, true)
  Trigger.WaitFor("Missions\\paris_4\\mission_1\\main\\PT_New[2]", hSab, "Paris_4_Mission_1.RainToggler", self, nil, cTRIGGEREVENT_ONENTER, true)
end

function Paris_4_Mission_1:RainToggler(tTriggerTable)
  local hTriggerHandle = tTriggerTable[1]
  dprint(self, "Calling Rain interior cancel hack")
  if self.nRainValue == 1 then
    dprint(self, "Rain is now off")
    Render.Rain(0, 1)
    self.nRainValue = 0
  elseif self.nRainValue == 0 then
    dprint(self, "Rain is now on at 2.0 intensity")
    Render.Rain(1, 2)
    self.nRainValue = 1
  end
end

function Paris_4_Mission_1:TASK_LoadWaypointindicator()
  self:CreateTask({
    sName = "TASK_LoadWaypointindicator",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    ParentObjectID = self:GetTaskObjectiveID("TASK_MausoleumWaypoint"),
    sObjectiveTextID = "P4M1_Text.TASK_LoadWaypointindicator",
    tDeliverObjs = {hSab},
    tDestRegion = {
      "Missions\\paris_4\\mission_1\\underground\\TriggerMaus"
    },
    tLocators = {},
    tOnActivate = {},
    tOnComplete = {
      {
        self.SetupCheckPoint2,
        {self}
      }
    }
  })
end

function Paris_4_Mission_1:AndtheConvoListener()
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\paris_4\\mission_1\\main\\PT_New[6]", hSab, "Paris_4_Mission_1.PlayUGConvos", self, nil, cTRIGGEREVENT_ONENTER, false), "Missions\\paris_4\\mission_1\\main\\PT_New[6]")
  self:SetupAmbientUG2StealthTrig()
end

function Paris_4_Mission_1:TASK_TalkinDepot()
  self:CreateTask({
    sName = "TASK_TalkinDepot",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "TALK",
    sObjectiveTextID = "P4M1_Text.TASK_TalkinDepot",
    ParentObjectID = self:GetTaskObjectiveID("TASK_MausoleumWaypoint"),
    bAutofire = true,
    Proximity = 7,
    sConvFile = "P4M1_VehicleDepot_Post",
    tTgtInclude = {
      "Missions\\paris_4\\characters\\cemetary\\exterior\\moreau\\Moreau_Exterior"
    },
    tOnComplete = {
      {
        self.GetSkylarinPosition,
        {self}
      }
    },
    tOnActivate = {
      {
        self.GetSkylartoStopMoving,
        {self}
      }
    }
  })
end

function Paris_4_Mission_1:GetSkylartoStopMoving()
  Nav.StopMoving(Util.GetHandleByName("Missions\\paris_4\\characters\\cemetary\\exterior\\moreau\\Moreau_Exterior"))
  Combat.SetIdleScripted(Util.GetHandleByName("Missions\\paris_4\\characters\\cemetary\\exterior\\moreau\\Moreau_Exterior"), true)
end

function Paris_4_Mission_1:GetSkylarinPosition()
  local hSkylarDepotTruck = Util.GetHandleByName(self.sSkylarDepotTruck)
  self.hSkylarDepotTruck = hSkylarDepotTruck
  Nav.BoardVehicle(self.hSkylar, hSkylarDepotTruck, "PILOT", cMOVE_FAST, "Paris_4_Mission_1.GetSkylarsDepTruckMoving", self)
end

function Paris_4_Mission_1:GetSkylarsDepTruckMoving()
  local sSkyDepotPath = "Missions\\paris_4\\mission_1\\disposabletruck\\SkylarDepotPath"
  Nav.SetScriptedPath(self.hSkylarDepotTruck, sSkyDepotPath, false, "Paris_4_Mission_1.CleanupSkylarDepotHere", self)
  Nav.SetScriptedPathSpeed(self.hSkylarDepotTruck, 30)
end

function Paris_4_Mission_1:CleanupSkylarDepotHere()
  Util.UnloadEditNode("Missions\\paris_4\\characters\\cemetary\\exterior\\moreau.wsd", true, false)
  Util.UnloadEditNode("Missions\\paris_4\\mission_1\\DisposableTruck.wsd", true, false)
end

function Paris_4_Mission_1:SkylarInPosition()
  Object.Actuate(Util.GetHandleByName("PARIS\\area04\\cem_lachaise\\occupation\\inner\\props\\Occ_SecFence_PedGate5m_DoorFrame(4)\\AnimatedObject_Occ_PedGate5m"), true)
end

function Paris_4_Mission_1:SendSkylarBack()
  local x, y, z = Object.GetPosition(hSab)
  Nav.MoveToPoint(Util.GetHandleByName("Missions\\paris_4\\characters\\cemetary\\exterior\\moreau\\Moreau_Exterior"), x, y, z, cMOVE_FAST)
end

function Paris_4_Mission_1:TASK_GuardSkylarDepot()
  self:CreateTask({
    sName = "TASK_GuardSkylarDepot",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "DEFEND",
    bNoHUDBlip = false,
    tTgtInclude = {
      "Missions\\paris_4\\characters\\cemetary\\exterior\\moreau\\Moreau_Exterior"
    },
    tOnComplete = {},
    tOnCancel = {},
    tOnFailure = {
      {
        self.FailTaskByName,
        {
          self,
          "TASK_GuardSkylarDepot"
        }
      }
    },
    tOnDamage = {},
    tOnActivate = {}
  })
end

function Paris_4_Mission_1:StreamnWaitNazis()
  dprint(self, "Nazis streaming...")
  local tStreamNazis = {
    EventType = "StreamEvent",
    Objects = {
      "PARIS\\area04\\cem_lachaise\\occupation\\outer\\motor pool\\nazis\\Spore_WM_Grunt_MG(4)",
      "PARIS\\area04\\cem_lachaise\\occupation\\outer\\motor pool\\nazis\\Spore_WM_Rifleman_RF(1)",
      "PARIS\\area04\\cem_lachaise\\occupation\\outer\\motor pool\\nazis\\Spore_WM_Grunt_MG(2)"
    }
  }
  Util.CreateEvent(tStreamNazis, "Paris_4_Mission_1.NaziKillinCounter", self)
end

function Paris_4_Mission_1:NaziKillinCounter()
  dprint(self, "Nazis streamed in, setting up listeners")
  local tNaziTable = {
    Util.GetHandleByName("PARIS\\area04\\cem_lachaise\\occupation\\outer\\motor pool\\nazis\\Spore_WM_Grunt_MG(4)"),
    Util.GetHandleByName("PARIS\\area04\\cem_lachaise\\occupation\\outer\\motor pool\\nazis\\Spore_WM_Rifleman_RF(1)"),
    Util.GetHandleByName("PARIS\\area04\\cem_lachaise\\occupation\\outer\\motor pool\\nazis\\Spore_WM_Rifleman_RF(1)"),
    Util.GetHandleByName("PARIS\\area04\\cem_lachaise\\occupation\\outer\\motor pool\\nazis\\Spore_WM_Grunt_MG(2)")
  }
  for i = 1, 4 do
    local tDeathEvent = {
      EventType = "DeathEvent",
      ObjectHandle = tNaziTable[i]
    }
    Util.CreateEvent(tDeathEvent, "Paris_4_Mission_1.OnNaziDeaths", self)
  end
end

function Paris_4_Mission_1:OnNaziDeaths()
  local nNazisDead = self.nNaziTicker
  dprint(self, nNazisDead)
  if nNazisDead == 3 then
    self:CompleteTaskByName("TASK_GuardSkylarDepot")
    self:CompleteTaskByName("TASK_ClearTheDepot")
  else
    self.nNaziTicker = nNazisDead + 1
  end
end

function Paris_4_Mission_1:SetupAutoCompleteTimer()
  EVENT_Timer("Paris_4_Mission_1.AutoCompleteAllTasks", self, 120)
end

function Paris_4_Mission_1:AutoCompleteAllTasks()
  dprint(self, "Pity AutoComplete, Player has taken more than 2 minutes to fight off the nazis, put in some witty dialogue here?")
  self:CompleteTaskByName("TASK_GuardSkylarDepot")
  self:CompleteTaskByName("TASK_ClearTheDepot")
  Cin.PlayConversation("P4M1_VehicleDepot_Pre")
end

function Paris_4_Mission_1:WalktheLine()
  local hDepotTruck = Util.GetHandleByName(self.sDepotTruck)
  self.hDepotTruck = hDepotTruck
  local hSkylar = Util.GetHandleByName("Missions\\paris_4\\characters\\cemetary\\exterior\\moreau\\Moreau_Exterior")
  self.hSkylar = hSkylar
  Actor.CancelAttrPt(hSkylar)
  Combat.SetIdleScripted(hSkylar, true)
  Actor.OverrideCombatAI(hSkylar, true)
  Nav.SetScriptedPath(hSkylar, self.sSkyEntryPath1, false, "Paris_4_Mission_1.InterimWalkPath", self)
  Nav.SetScriptedPathMoveMode(hSkylar, cMOVE_FAST)
  Inventory.GiveItem(hSkylar, "WP_MG_MP40", true)
  self:EscalationBailSetup()
end

function Paris_4_Mission_1:InterimWalkPath()
  dprint(self, "Get Near Skylar!")
  local tSkyDepotProx = {
    EventType = "ProximityEvent",
    ObjectA = hSab,
    ObjectB = self.hSkylar,
    Proximity = 3
  }
  Util.CreateEvent(tSkyDepotProx, "Paris_4_Mission_1.ChrisWalken", self)
end

function Paris_4_Mission_1:StartVehRecording()
  Vehicle.StartPlayback(self.hDepotTruck, "CemDepotTruck.vcr")
end

function Paris_4_Mission_1:StopVehPlay()
end

function Paris_4_Mission_1:ChrisWalken()
  Nav.SetScriptedPath(self.hSkylar, self.sSkyEntryPath2, true, "Paris_4_Mission_1.BridgetoKickoff", self)
  Nav.SetScriptedPathMoveMode(self.hSkylar, cMOVE_FAST)
  Actor.CancelAttrPtRequest(self.hSkylar)
end

function Paris_4_Mission_1:BridgetoKickoff()
  Combat.SetIdleScripted(hSkylar, true)
  local tSkyDepot2Prox = {
    EventType = "ProximityEvent",
    ObjectA = hSab,
    ObjectB = self.hSkylar,
    Proximity = 3
  }
  Util.CreateEvent(tSkyDepot2Prox, "Paris_4_Mission_1.WalkityDone", self)
end

function Paris_4_Mission_1:WalkityDone()
  local hDepotNazi1 = Util.GetHandleByName(self.sSittingDepotNazi1)
  Actor.CancelAttrPt(hDepotNazi1)
  Actor.CancelAttrPtRequest(hDepotNazi1)
  self.hDepotNazi1 = hDepotNazi1
  Combat.SetIdleScripted(hDepotNazi1, true)
  Nav.SetScriptedPath(hDepotNazi1, self.sMoveToGatePath, false, "Paris_4_Mission_1.ChainToDepotPatrol", self)
end

function Paris_4_Mission_1:ChainToDepotPatrol()
  local sDepotPath = "PARIS\\area04\\cem_lachaise\\occupation\\outer\\motor pool\\nazis\\ReinforceMainGatePAT"
  local sDepotPath2 = "PARIS\\area04\\cem_lachaise\\occupation\\outer\\motor pool\\nazis\\DepotPatrol"
  local hDepotNazi2 = Util.GetHandleByName("PARIS\\area04\\cem_lachaise\\occupation\\outer\\motor pool\\nazis\\Spore_WM_Rifleman_RF(1)")
  Nav.SetScriptedPath(hDepotNazi2, sDepotPath, false)
  Nav.SetScriptedPath(self.hDepotNazi1, sDepotPath2, false)
end

function Paris_4_Mission_1:MovethatTruck()
  local hDisposableTruck = Util.GetHandleByName(self.sTruckDisposable)
  local hPassengerDude = Util.GetHandleByName(self.sDepotTruckPassenger)
  self.hDisposableTruck = hDisposableTruck
  Nav.SetScriptedPath(hDisposableTruck, self.sTruckDisposablePath, false)
  Nav.SetScriptedPathSpeed(hDisposableTruck, 12)
  self:WalkityDone()
end

function Paris_4_Mission_1:MoveTruckFaster()
  Nav.SetScriptedPathSpeed(self.hDisposableTruck, 25)
end

function Paris_4_Mission_1:OnEscalateInDepot()
  Nav.StopMoving(self.hSkylar)
  self:CompleteTaskByName("TASK_FollowSkylar")
  local hDepotNazi1 = Util.GetHandleByName(self.sSittingDepotNazi1)
  Actor.CancelAttrPt(hDepotNazi1)
  Combat.SetStationary(self.hSkylar, true)
  Cin.PlayConversation("P4M1_VehicleDepot_Pre")
  self:CompleteTaskByName("TASK_FollowSkylar")
end

function Paris_4_Mission_1:SetWorldEscalated()
  Actor.OverrideCombatAI(self.hSkylar, false)
  local tDamageEventSky = {
    EventName = "DamageEvent",
    ObjectHandle = self.hSkylar
  }
  Util.CreateEvent(tDamageEventSky, "Paris_4_Mission_1.ReleaseDepotSkylar", self)
  self:ForceEscalation()
end

function Paris_4_Mission_1:ReleaseDepotSkylar()
  Combat.SetStationary(self.hSkylar, false)
end

function Paris_4_Mission_1:TASK_ClearTheDepot()
  self:CreateTask({
    sName = "TASK_ClearTheDepot",
    sTaskType = "SabTaskObjective",
    sTaskSubType = "empty",
    sObjectiveTextID = "P4M1_Text.TASK_ClearTheDepot",
    ParentObjectID = self:GetTaskObjectiveID("TASK_MausoleumWaypoint"),
    tOnActivate = {
      {
        self.TASK_GuardSkylarDepot,
        {self}
      },
      {
        self.StreamnWaitNazis,
        {self}
      },
      {
        self.SetupAutoCompleteTimer,
        {self}
      }
    },
    tOnComplete = {
      {
        self.SendSkylarBack,
        {self}
      },
      {
        self.TASK_TalkinDepot,
        {self}
      }
    }
  })
end

function Paris_4_Mission_1:PlayCondConv()
  if self.nBoxValue == 1 then
    Cin.PlayConversation("P4M1_MausUnderground_SeesTrunk_Post")
  elseif self.nBoxValue == 0 then
    Cin.PlayConversation("P4M1_MausUnderground_PostFight")
  end
end

function Paris_4_Mission_1:TASK_WarningCall()
  dprint(self, "Object Has Been Triggered")
  self:CreateTask({
    sName = "TASK_WarningCall",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "217_CinB_Box",
    bOverrideFade = true,
    tOnActivate = {},
    tOnComplete = {
      {
        self.SetupPreCheckpointHelper,
        {self}
      }
    },
    tSMEDNodes = {
      "Missions\\paris_4\\mission_1\\escape"
    }
  })
end

function Paris_4_Mission_1:SetupPreCheckpointHelper()
  AchievementsManager.AchievementGrant("RESISTANCE_BORN")
  Sound.SetMusicLocale("P4M1_Cemetary")
  Sound.SetMusicLocale("m_P4M1_Cemetary", "P4M1_escape")
  self:CancelAreaFailTrig()
  self:SetClearWTFBlueprint()
  self:StartSeanTeleport()
end

function Paris_4_Mission_1:TASK_TalktoSkylar()
  Suspicion.SetFixedEscalationLevel(3)
  Suspicion.SetEscalationLevel(3)
  self:CreateTask({
    sName = "TASK_TalktoSkylar",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "TALK",
    sObjectiveTextID = "P4M1_Text.TASK_TalktoSkylar",
    sConvFile = "P4M1_Escape_Start",
    bAutofire = true,
    Proximity = 15,
    tTgtInclude = {
      self.sExitSkylar
    },
    tOnComplete = {
      {
        self.SetupExitStarter,
        {self}
      }
    },
    tOnActivate = {
      {
        self.SimmerDownSkylar,
        {self}
      }
    }
  })
end

function Paris_4_Mission_1:SimmerDownSkylar()
  local hSkylar = Handle(self.sExitSkylar)
  Actor.OverrideCombatAI(hSkylar, true)
end

function Paris_4_Mission_1:TruckPreDamListener()
  Vehicle.SetDeathCallback(self.hTruck, "Paris_4_Mission_1.FailMissionByProxy", self)
end

function Paris_4_Mission_1:RedotheRedo()
  self:CompleteTaskByName("TASK_TalktoSkylar")
end

function Paris_4_Mission_1:SetupNegProxyEvent()
  dprint(self, "Sab is in range of Skylar")
  local tFailEvent = {
    EventType = "ProximityEvent",
    EventName = "SkylarFailEvent",
    ObjectA = hSab,
    ObjectB = self.hTruck,
    Proximity = 75,
    Negate = true
  }
  self:RegisterEvent(Util.CreateEvent(tFailEvent, "Paris_4_Mission_1.SetupPosProxyEvent", self))
end

function Paris_4_Mission_1:SetupPosProxyEvent()
  Cin.PlayConversation("P4M1_MissionAbandon_Fail")
  dprint(self, "Get Back to the Car!")
  local tFailTimer = {
    EventType = "TimerEvent",
    EventName = "FailTimer",
    Time = 15
  }
  self:RegisterEvent(Util.CreateEvent(tFailTimer, "Paris_4_Mission_1.FailWhenFarFromTruck", self))
  local tRedeemEvent = {
    EventType = "Proximity Event",
    EventName = "SkylarRedeemEvent",
    ObjectA = hSab,
    ObjectB = self.hTruck,
    Proximity = 60,
    Negate = false
  }
  self:RegisterEvent(Util.CreateEvent(tRedeemEvent, "Paris_4_Mission_1.SetupByProxy", self))
end

function Paris_4_Mission_1:FailWhenFarFromTruck()
  self:MissionTaskFail("P4M1_Text.FAILBYTOOFAR")
end

function Paris_4_Mission_1:SetupByProxy()
  self.KillEvent("FailTimer")
  self:SetupNegProxyEvent()
end

function Paris_4_Mission_1:FailMissionByProxy()
  dprint(self, "Oh Noes! You fail!")
  self:MissionTaskFail("P4M1_Text.FAILBYDEATH")
end

function Paris_4_Mission_1:StartSeanTeleport()
  Util.UnloadStaticENTag("P4M1MausoleumNazis", true)
  Util.UnloadStaticENTag("CemAmbientNazis", true)
  Util.LoadStaticENTag("vehicle_collision", true)
  Util.UnloadStaticENTag("P4M1Box", true)
  Util.SetTime(21, 0)
  Render.Rain(0, 1)
  local hLocHappy = Util.GetHandleByName("Missions\\paris_4\\mission_1\\escape\\EscapeLocPointer")
  Object.PlayerTeleportToLocator(hLocHappy, true, "Paris_4_Mission_1.TASK_TalktoSkylar", self)
end

function Paris_4_Mission_1:WaitForOutsideTruckToStream()
  local tExitTruckStream = {
    EventType = "StreamEvent",
    Objects = {
      self.sExitTruck
    }
  }
  self:RegisterEvent(Util.CreateEvent(tExitTruckStream, "Paris_4_Mission_1.SetupExitStarter", self))
end

function Paris_4_Mission_1:SetupExitStarter()
  dprint(self, "Setting Handles")
  local hTruck = Util.GetHandleByName(self.sExitTruck)
  self.hTruck = hTruck
  local hExitSkylar = Util.GetHandleByName(self.sExitSkylar)
  self.hExitSkylar = hExitSkylar
  Vehicle.SetAsMissionCritical(self.hTruck, true)
  self:SetupCheckPoint3()
end

function Paris_4_Mission_1:FailBySkyDeath()
  self:MissionTaskFail("Char_Death.RS_Skylar")
end

function Paris_4_Mission_1:GoGoTruck()
  Nav.BoardVehicle(self.hExitSkylar, self.hTruck, "PILOT", cMOVE_FAST, "Paris_4_Mission_1.SkylarontheMove", self)
  Util.UnloadStaticENTag("CemAmbientNazis", true)
  Trigger.WaitFor(self.sTrigRunEnc1, self.hTruck, "Paris_4_Mission_1.SetRunnersEnc1", self, nil, cTRIGGEREVENT_ONENTER, false)
end

function Paris_4_Mission_1:SkylarontheMove()
  Object.SetHealth(self.hTruck, 17000)
  Nav.SetScriptedPath(self.hTruck, "Missions\\paris_4\\mission_1\\escape\\New Path", true, "Paris_4_Mission_1.TASK_OpenGate", self)
  Nav.SetScriptedPathSpeed(self.hTruck, 12)
  Vehicle.SetCrashThrough(self.hTruck, true)
end

function Paris_4_Mission_1:SetRunnersEnc1()
  local hEnc1Soldier = Util.GetHandleByName("Missions\\paris_4\\mission_1\\escape\\Spore_TS_Commander_SH(28)")
  local hSoldierRuntoEnc1 = Util.GetHandleByName("Missions\\paris_4\\mission_1\\escape\\Runn1Enc1Loc")
  local hEnc1Soldier2 = Util.GetHandleByName("Missions\\paris_4\\mission_1\\escape\\Spore_TS_Commander_SH(30)")
  local hSoldierRunto2 = Util.GetHandleByName("Missions\\paris_4\\mission_1\\escape\\Runn1Enc1Loc(2)")
  Combat.SetObjective(hEnc1Soldier, hSoldierRuntoEnc1, true, 3, false)
end

function Paris_4_Mission_1:TASK_ProtectSkylar()
  self:CreateTask({
    sName = "TASK_ProtectSkylar",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "DEFEND",
    tTgtInclude = {
      self.sExitTruck
    },
    tOnComplete = {},
    tOnCancel = {},
    tOnFailure = {},
    tOnDamage = {
      {
        self.OnDamageUpdater,
        {self}
      }
    },
    tOnActivate = {
      {
        self.NowSetWorldEscalated,
        {self}
      }
    }
  })
end

function Paris_4_Mission_1:NowSetWorldEscalated()
  Actor.OverrideCombatAI(self.hExitSkylar, false)
  Combat.SetHostileTargetsOnly(self.hExitSkylar, true)
  self:ForceEscalation()
end

function Paris_4_Mission_1:PlayObjectiveOneConvo()
  Cin.PlayConversation("P4M1_Escape_Enc01_Discovered")
end

function Paris_4_Mission_1:OnDamageUpdater()
  local nTruckHP = Object.GetHealth(self.hTruck)
  self.tInfo.TRUCKHEALTH = nTruckHP / 17000 * 1000 - 10
  dprint(self, self.tInfo.TRUCKHEALTH)
  HUD.SetProgressBarValue(self.tInfo.hSkylarsTruckObj, self.tInfo.TRUCKHEALTH)
  if self.tInfo.TRUCKHEALTH > 55 and self.tInfo.TRUCKHEALTH < 55.4 then
    Cin.PlayConversation("P4M1_Escape_TruckDam_Skylar_Light")
  elseif self.tInfo.TRUCKHEALTH > 44 and self.tInfo.TRUCKHEALTH < 44.5 then
    Cin.PlayConversation("P4M1_Escape_TruckDam_Skylar_Medium")
  elseif self.tInfo.TRUCKHEALTH > 28 and self.tInfo.TRUCKHEALTH < 28.5 then
    Cin.PlayConversation("P4M1_Escape_TruckDam_Skylar_Heavily")
  end
end

function Paris_4_Mission_1:HealthBarStuff()
  local hTruck = Util.GetHandleByName("Missions\\paris_4\\mission_1\\escape\\VH_NZ_TR_OpelCanvas_01")
  self.tInfo.TRUCKHEALTH = Object.GetHealth(hTruck) / 17000 * 1000
  self.tInfo.TRUCKMAXHEALTH = self.tInfo.TRUCKHEALTH - 10
  self.tInfo.hSkylarsTruckObj = HUD.AddObjective(eOT_HEART, self:GetLocalizedText("GenericObjective_Text.BAR_Health_Truck"), 2)
  HUD.SetupProgressBar(self.tInfo.hSkylarsTruckObj, 0, self.tInfo.TRUCKMAXHEALTH, self.tInfo.TRUCKMAXHEALTH)
  HUD.AddProgressBarCallback(self.tInfo.hSkylarsTruckObj, "Paris_4_Mission_1.TruckDead", 0, self, {})
end

function Paris_4_Mission_1:TruckDead()
  Cin.PlayConversation("P4M1_Escape_TruckDam_Skylar_Exploding")
  self:MissionTaskFail("P4M1B_Text.FAILBYTRUCKDESTROYED")
end

function Paris_4_Mission_1:TASK_OpenGate()
  self:CreateTask({
    sName = "TASK_OpenGate",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "USE",
    sObjectiveTextID = "P4M1_Text.TASK_OpenGate",
    ParentObjectID = self:GetTaskObjectiveID("TASK_ProtectSkylar"),
    tTgtInclude = {
      "Missions\\paris_4\\mission_1\\escape\\Light_Lever_Pull"
    },
    tOnComplete = {
      {
        self.FirstGateActuate,
        {self}
      },
      {
        self.KeepMoving,
        {self}
      },
      {
        self.PlayObjectiveOneFinishConv,
        {self}
      }
    },
    tOnActivate = {
      {
        self.PlayObjectiveOneConvo,
        {self}
      }
    }
  })
end

function Paris_4_Mission_1:PlayObjectiveOneFinishConv()
  Cin.PlayConversation("P4M1_Escape_Enc01_Complete")
end

function Paris_4_Mission_1:FirstGateActuate()
  Object.Actuate(Util.GetHandleByName(self.sEncounter2Gate), true)
  AttractionPt.EnableUse(Util.GetHandleByName("Missions\\paris_4\\mission_1\\escape\\Generic_Use"), false)
end

function Paris_4_Mission_1:KeepMoving()
  Nav.SetScriptedPath(self.hTruck, "Missions\\paris_4\\mission_1\\escape\\New Path(2)", true, "Paris_4_Mission_1.AlmostThere", self)
  Nav.SetScriptedPathSpeed(self.hTruck, 12)
end

function Paris_4_Mission_1:CryptUGListener()
  local tCryptSeeOh = {
    EventType = "SeeLocatorEvent",
    InViewTime = 0.5,
    Locator = "Missions\\paris_4\\mission_1\\main\\CryptLocator(2)",
    Proximity = 15
  }
  Util.CreateEvent(tCryptSeeOh, "Paris_4_Mission_1.SetupCheckPoint2", self)
end

function Paris_4_Mission_1:TASK_GotoMaus()
  self:CreateTask({
    sName = "Paris_4_Mission_1_Task_InvestigatetheMausoleum",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    ParentObjectID = self:GetTaskObjectiveID("TASK_MasterInvestigate"),
    sObjectiveTextID = "P4M1_Text.TASK_GotoMaus",
    bNoGroundBlip = true,
    tDeliverObjs = {hSab},
    tDestRegion = {
      "Missions\\paris_4\\mission_1\\main\\MausoleumGeneral"
    },
    tLocators = {
      "Missions\\paris_4\\mission_1\\main\\BoomLocCrypt"
    },
    tOnActivate = {},
    tOnComplete = {
      {
        self.TASK_GetUnderground,
        {self}
      }
    }
  })
end

function Paris_4_Mission_1:SetSpawnTriggerEvent()
  local tSpawnTrigEvent = {
    EventType = "OnEscalation1",
    EventName = "MausOnEscalation1",
    Target = hSab
  }
  Util.CreateEvent(tSpawnTrigEvent, "Paris_4_Mission_1.TriggerMausSpawners", self)
  local tSpawnTrigEvent2 = {
    EventType = "OnEscalation2",
    EventName = "MausOnEscalation2",
    Target = hSab
  }
  Util.CreateEvent(tSpawnTrigEvent2, "Paris_4_Mission_1.TriggerMausSpawners", self)
  local tSpawnTrigEvent3 = {
    EventType = "OnEscalation3",
    EventName = "MausOnEscalation3",
    Target = hSab
  }
  Util.CreateEvent(tSpawnTrigEvent3, "Paris_4_Mission_1.TriggerMausSpawners", self)
end

function Paris_4_Mission_1:TriggerMausSpawners()
  local hMausCODSpawner = Util.GetHandleByName(self.sMausSpawner)
  Object.EnableSpawner(hMausCODSpawner, true)
end

function Paris_4_Mission_1:TASK_MasterInvestigate()
  self:CreateTask({
    sName = "TASK_MasterInvestigate",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "empty",
    tLocators = {},
    tOnActivate = {
      {
        self.TASK_GotoMaus,
        {self}
      }
    },
    tOnComplete = {}
  })
end

function Paris_4_Mission_1:TASK_GetUnderground()
  self:CreateTask({
    sName = "TASK_GetUnderground",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    sObjectiveTextID = "P4M1_Text.TASK_GetUnderground",
    ParentObjectID = self:GetTaskObjectiveID("TASK_MasterInvestigate"),
    tDeliverObjs = {hSab},
    tDestRegion = {
      "Missions\\paris_4\\mission_1\\main\\PT_New[4]"
    },
    tLocators = {
      "Missions\\paris_4\\mission_1\\main\\Locator"
    },
    tOnActivate = {},
    tOnComplete = {
      {
        self.TASK_ClearScientists,
        {self}
      }
    }
  })
end

function Paris_4_Mission_1:PlayUGConvos()
  sUGConvoNazi = "PARIS\\area04\\cem_lachaise\\occupation\\outer\\general\\nazis\\Und_Nazi1"
  EVENT_ActorEntersCombat("Paris_4_Mission_1.KillUGConvos", self, sUGConvoNazi, nil, false)
  Cin.PlayConversation("P4M1_MausUnderground_Nazi_Ready", "Paris_4_Mission_1.AnimatePlay", self)
end

function Paris_4_Mission_1:KillUGConvos()
  Cin.StopConversation("P4M1_MausUnderground_Nazi_Ready")
  Cin.StopConversation("P4M1_MausUnderground_Nazi_CheckIn")
end

function Paris_4_Mission_1:AnimatePlay()
  Nav.SetScriptedPath(Util.GetHandleByName("PARIS\\area04\\cem_lachaise\\occupation\\outer\\general\\nazis\\Und_NaziOfficer"), "PARIS\\area04\\cem_lachaise\\occupation\\outer\\general\\nazis\\New Path(6)", true, "Paris_4_Mission_1.PlayCheckinConv", self)
end

function Paris_4_Mission_1:PlayCheckinConv()
  repeat
    local hUGConvoNazi1 = Handle("PARIS\\area04\\cem_lachaise\\occupation\\outer\\general\\nazis\\Und_Nazi1")
    local hUGConvoNazi2 = Handle("PARIS\\area04\\cem_lachaise\\occupation\\outer\\general\\nazis\\Und_NaziRadio")
    if hUGConvoNazi1 and Actor.IsInCombat(hUGConvoNazi1) == false and Actor.IsInCombat(hUGConvoNazi2) == false then
      Cin.PlayConversation("P4M1_MausUnderground_Nazi_CheckIn")
    else
    end
    break -- pseudo-goto
  until true
end

function Paris_4_Mission_1:TASK_ClearScientists()
  self:CreateTask({
    sName = "TASK_ClearScientists",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "KILL",
    sObjectiveTextID = "P4M1_Text.TASK_ClearScientists",
    bNoWorldBlip = true,
    ParentObjectID = self:GetTaskObjectiveID("TASK_MasterInvestigate"),
    tTgtInclude = {
      "PARIS\\area04\\cem_lachaise\\occupation\\outer\\general\\nazis\\Und_NaziRadio",
      "PARIS\\area04\\cem_lachaise\\occupation\\outer\\general\\nazis\\Spore_GS_Sympathizer(6)",
      "PARIS\\area04\\cem_lachaise\\occupation\\outer\\general\\nazis\\Und_Nazi1",
      "PARIS\\area04\\cem_lachaise\\occupation\\outer\\general\\nazis\\Und_NaziOfficer",
      "PARIS\\area04\\cem_lachaise\\occupation\\outer\\general\\nazis\\Spore_GS_Sympathizer(2)",
      "PARIS\\area04\\cem_lachaise\\occupation\\outer\\general\\nazis\\Spore_GS_Sympathizer(4)",
      "PARIS\\area04\\cem_lachaise\\occupation\\outer\\general\\nazis\\Spore_SS_Flame_FT(3)",
      "PARIS\\area04\\cem_lachaise\\occupation\\outer\\general\\nazis\\Spore_SS_Flame_FT(1)"
    },
    tOnComplete = {
      {
        self.TASK_CINETRANS,
        {self}
      }
    },
    tOnCancel = {},
    tOnFailure = {},
    tOnActivate = {
      {
        self.SetShootingListener,
        {self}
      },
      {
        self.ProtectCrate,
        {self}
      }
    },
    tSMEDNodes = {}
  })
end

function Paris_4_Mission_1:TASK_CINETRANS()
  Sound.SetMusicLocale("P4M1_Cemetary")
  Sound.SetMusicLocale("m_P4M1_Cemetary", "P4M1_wtfChange")
  self:CreateTask({
    sName = "TASK_CINETRANS",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "WTF_P4M1_Cemetery",
    tOnActivate = {},
    tOnComplete = {
      {
        self.CompleteTaskByName,
        {
          self,
          "TASK_MasterInvestigate"
        }
      },
      {
        self.TASK_ApproachChest,
        {self}
      }
    },
    tSMEDNodes = {}
  })
end

function Paris_4_Mission_1:CallNextTask()
  EVENT_Timer("Paris_4_Mission_1.TASK_WarningCall", self, 7.5)
end

function Paris_4_Mission_1:ProtectCrate()
  local sBox = "PARIS\\area04\\cem_lachaise\\box\\OccMed_SpearOfDestinyCrate"
  local hBox = Handle(sBox)
end

function Paris_4_Mission_1:SetShootingListener()
  EVENT_ActorFiresAnyWeapon("Paris_4_Mission_1.OnWeaponFired", self, hSab)
end

function Paris_4_Mission_1:OnWeaponFired()
  local sCrytpNode = "Missions\\paris_4\\mission_1\\cryptencounter"
  self:KillUGConvos()
end

function Paris_4_Mission_1:TASK_GetNearChest()
  self:CreateTask({
    sName = "TASK_GetNearChest",
    sTaskType = "SabTaskObjectiveDeliver",
    Proximity = 5,
    sTaskSubType = "DELIVER",
    sObjectiveTextID = "P4M1_Text.TASK_ApproachChest",
    tDestProximityObj = {
      "Missions\\paris_4\\mission_1\\main\\Locator(5)"
    },
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.SpawnCryptEncNode,
        {self}
      }
    },
    tOnActivate = {}
  })
end

function Paris_4_Mission_1:TASK_DefendGround()
  self:CreateTask({
    sName = "TASK_DefendGround",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "KILL",
    sObjectiveTextID = "Kill the reinforcements",
    bNoWorldBlip = true,
    WTFZoneHigh = "WtF_Zones\\global\\P4M1_Cemetary",
    tTgtInclude = self.tCryptEncNazis,
    tOnComplete = {
      {
        self.SetClearWTFBlueprint,
        {self}
      },
      {
        self.TASK_ApproachChest,
        {self}
      }
    },
    tOnCancel = {},
    tOnFailure = {},
    tOnActivate = {},
    tSMEDNodes = {}
  })
end

function Paris_4_Mission_1:SetClearWTFBlueprint()
  Render.WTFClearOverrideBlueprint()
  Render.WTFExitActivePortal()
end

function Paris_4_Mission_1:SetupBruteListener()
  local hBrute = Util.GetHandleByName("Missions\\paris_4\\mission_1\\UGCryptEncounter\\Spore_WM_Heavy")
  self.hBrute = hBrute
  local tBruteProxEvent = {
    EventType = "ProximityEvent",
    ObjectA = hSab,
    ObjectB = hBrute,
    Proximity = 12,
    Check3D = true
  }
  Util.CreateEvent(tBruteProxEvent, "Paris_4_Mission_1.BruteFrenzy", self)
end

function Paris_4_Mission_1:BruteFrenzy()
  Actor.RemoveDisguise(hSab)
  Combat.SetTarget(self.hBrute, hSab)
  Combat.SetCombat(self.hBrute)
end

function Paris_4_Mission_1:SeelocBoxListener()
  local tBoxOh = {
    EventType = "SeeLocatorEvent",
    InViewTime = 1,
    Locator = "Missions\\paris_4\\mission_1\\main\\Locator(5)"
  }
  Util.CreateEvent(tBoxOh, "Paris_4_Mission_1.EnumeratorSee", self)
end

function Paris_4_Mission_1:EnumeratorSee()
  Cin.PlayConversation("P4M1_MausUnderground_SeesTrunk_Pre")
  self.nBoxValue = 1
end

function Paris_4_Mission_1:TASK_ApproachChest()
  self:CreateTask({
    sName = "TASK_ApproachChest",
    sTaskType = "SabTaskObjectiveDeliver",
    Proximity = 5,
    sTaskSubType = "DELIVER",
    sObjectiveTextID = "P4M1_Text.TASK_ApproachChest",
    ParentObjectID = self:GetTaskObjectiveID("TASK_MasterInvestigate"),
    tDestProximityObj = {
      "Missions\\paris_4\\mission_1\\main\\Locator(5)"
    },
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.CompleteTaskByName,
        {
          self,
          "TASK_MasterInvestigate"
        }
      },
      {
        self.PlayBridgeConvoToCine,
        {self}
      }
    },
    tOnActivate = {}
  })
end

function Paris_4_Mission_1:PlayBridgeConvoToCine()
  Cin.PlayConversation("P4M1_MausUnderground_SeesTrunk_Post", "Paris_4_Mission_1.SetReqDelayForCine", self)
end

function Paris_4_Mission_1:SetReqDelayForCine()
  EVENT_Timer("Paris_4_Mission_1.HelperFadeToCine", self, 3)
end

function Paris_4_Mission_1:HelperFadeToCine()
  Render.FadeScreen(true, 0.5)
  self:TASK_WarningCall()
end

function Paris_4_Mission_1:DelaytoAT()
  EVENT_Timer("Paris_4_Mission_1.AlmostThere", self, 8)
end

function Paris_4_Mission_1:LockAPCDoors()
  Vehicle.LockAllSeats(Util.GetHandleByName("Missions\\paris_4\\mission_1\\escape\\VH_NZ_TR_HalfTrack_01"), true)
end

function Paris_4_Mission_1:PlaySecondEncConvo()
  Cin.PlayConversation("P4M1_Escape_Enc02_Discovered")
end

function Paris_4_Mission_1:SecondEncEndConvo()
  Cin.PlayConversation("P4M1_Escape_Enc02_Complete")
end

function Paris_4_Mission_1:AlmostThere()
  Nav.SetScriptedPath(self.hTruck, self.sEncounter2Path, true, "Paris_4_Mission_1.TASK_BlowtheGate", self)
  Nav.SetScriptedPathSpeed(self.hTruck, 5)
end

function Paris_4_Mission_1:TASK_BlowtheGate()
  self:CreateTask({
    sName = "TASK_BlowtheGate",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "KILL",
    ParentObjectID = self:GetTaskObjectiveID("TASK_ProtectSkylar"),
    sObjectiveTextID = "P4M1_Text.TASK_BlowtheGate",
    tTgtInclude = {
      "PARIS\\area04\\cem_lachaise\\props\\Cem_Gate_Entrance"
    },
    tOnComplete = {
      {
        self.MoveSkylarOut,
        {self}
      },
      {
        self.ThirdEncEndConv,
        {self}
      }
    },
    tOnCancel = {},
    tOnFailure = {},
    tOnActivate = {
      {
        self.PlayThirdEncConv,
        {self}
      }
    }
  })
end

function Paris_4_Mission_1:PlayThirdEncConv()
  Cin.PlayConversation("P4M1_Escape_Enc03_Discovered")
end

function Paris_4_Mission_1:ThirdEncEndConv()
  Cin.PlayConversation("P4M1_Escape_Enc03_Complete")
end

function Paris_4_Mission_1:MoveSkylarOut()
  Nav.SetScriptedPath(self.hTruck, "Missions\\paris_4\\mission_1\\escape\\New Path(4)", true, "Paris_4_Mission_1.SetupCheckPoint4", self)
  Nav.SetScriptedPathSpeed(self.hTruck, 25)
end

function Paris_4_Mission_1:TASK_TaketheWheel()
  self:CreateTask({
    sName = "TASK_TaketheWheel",
    sTaskType = "SabTaskObjectiveDeliver",
    Proximity = 2,
    ParentObjectID = self:GetTaskObjectiveID("TASK_ProtectSkylar"),
    sTaskSubType = "DELIVER",
    sObjectiveTextID = "P4M1_Text.TASK_TaketheWheel",
    sConvFile = "P4M1_Escape_ExitCemetery",
    tDestProximityObj = {
      self.sExitTruck
    },
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        Cin.PlayConversation,
        {
          "P4M1_Escape_ExitToHQ"
        }
      },
      {
        self.TASK_DelivertoLeHavre,
        {self}
      }
    },
    tOnActivate = {
      {
        self.UnlockDriver,
        {self}
      }
    }
  })
end

function Paris_4_Mission_1:UnlockDriver()
  Vehicle.LockSeat(self.hTruck, "PILOT", false)
end

function Paris_4_Mission_1:TASK_ExitCemetary()
  self:CreateTask({
    sName = "TASK_ExitCemetary",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "TAXI",
    sObjectiveTextID = "P4M1_Text.TASK_ExitCemetary",
    tDestLocators = {
      "Missions\\paris_4\\mission_1\\main\\CemExitLocator"
    },
    tPickupProxObj = {
      self.sExitSkylar
    },
    Proximity = 10,
    tDestRegion = {
      "Missions\\paris_4\\mission_1\\main\\ExitCemTrig"
    },
    tDeliverObjs = {
      self.sExitSkylar
    },
    bSpecialCaseBrakeOverride = true,
    sVehicleFetchID = "P4M1_Text.TASK_ExitCemetray_VehFetch",
    bDontClearFollower = true,
    bNoDumping = true,
    tOnEarlyExit = {},
    tOnPickup = {},
    tOnComplete = {
      {
        self.PlayGotoAmbushConvo,
        {self}
      },
      {
        self.EnableTraffAgain,
        {self}
      },
      {
        Suspicion.SetEscalatedWithWhistle,
        {}
      },
      {
        Suspicion.SetInescapableEscalation,
        {true}
      },
      {
        self.TASK_GotoFightBackZone,
        {self}
      },
      {
        Util.LoadStaticENTag,
        {
          "LaV_FightBackConfig1",
          true
        }
      },
      {
        self.ListenforDeEscalation,
        {self}
      }
    },
    tOnActivate = {
      {
        Actor.SetAutoSeatTransition,
        {
          Handle(self.sExitSkylar),
          false
        }
      }
    },
    tSMEDNodes = {}
  })
end

function Paris_4_Mission_1:EnableTraffAgain()
end

function Paris_4_Mission_1:TASK_DelivertoLeHavre()
  Suspicion.SetInescapableEscalation(false)
  self:CreateTask({
    sName = "TASK_DelivertoLeHavre",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "TAXI",
    sObjectiveTextID = "P4M1_Text.TASK_DelivertoLeHavre",
    sVehicleFetchID = "P4M1_Text.TASK_DelivertoLeHavre_Pickup",
    tDestLocators = {
      "Missions\\hq_dropoff\\belle\\BelleHQ_Garage_LC"
    },
    tPickupProxObj = {
      self.sExitSkylar
    },
    Proximity = 60,
    tDestRegion = {
      "Missions\\hq_dropoff\\belle\\BelleHQ_Garage_PT"
    },
    tDeliverObjs = {
      self.sExitSkylar
    },
    sRequiredVehicle = self.sExitTruck,
    bGroundBlip = true,
    bEscalationDenial = true,
    tOnEarlyExit = {},
    tOnPickup = {},
    tOnComplete = {
      {
        self.FinalCleanHouse,
        {self}
      },
      {
        self.PlayConvToEnd,
        {self}
      },
      {
        Sound.ReleaseSoundBank,
        {
          "m_P4M1_inGame.bnk"
        }
      }
    },
    tOnActivate = {
      {
        Combat.SetLeader,
        {
          self.hExitSkylar,
          hSab
        }
      },
      {
        Vehicle.EnableTraffic,
        {true}
      }
    },
    tOnEscalationClear = {
      {
        Sound.ResetMusicLocale,
        {}
      }
    },
    tSMEDNodes = {}
  })
end

function Paris_4_Mission_1:FinalCleanHouse()
  HUD.RemoveObjective(self.tInfo.hSkylarsTruckObj)
  self.tInfo.hSkylarsTruckObj = nil
end

function Paris_4_Mission_1:SkylarTails()
  Actor.OverrideCombatAI(self.hExitSkylar, false)
  local tYoProxy = {
    EventType = "ProximityEvent",
    EventName = "SkylarProxySean",
    ObjectA = hSab,
    ObjectB = Util.GetHandleByName("Missions\\paris_4\\mission_1\\main\\LaVilletteObjectiveDot"),
    Proximity = 50
  }
  Util.CreateEvent(tYoProxy, "Paris_4_Mission_1.GoGoFinalConvo", self)
end

function Paris_4_Mission_1:GoGoFinalConvo()
  Cin.PlayConversation("P4M1_Escape_AtHQ")
end

function Paris_4_Mission_1:TASK_LookAroundSean()
  self:CreateTask({
    sName = "TASK_LookAroundSean",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "empty",
    ParentObjectID = self:GetTaskObjectiveID("TASK_MausoleumWaypoint"),
    sObjectiveTextID = "P4M1_Text.TASK_LookAroundSean",
    bNoHUDBlip = true,
    bNoWorldBlip = true,
    bHighPriorityFocus = true,
    tLocators = {
      "Missions\\paris_4\\mission_1\\main\\CryptLocator(4)",
      "Missions\\paris_4\\mission_1\\main\\BillBoardLoc",
      "Missions\\paris_4\\mission_1\\main\\BillBoardLoc(2)",
      "Missions\\paris_4\\mission_1\\main\\BillBoardLoc(4)"
    },
    tOnActivate = {},
    tOnComplete = {}
  })
end

function Paris_4_Mission_1:SpeedCycler()
  local nTruckSpeed = Vehicle.GetSpeed(self.hTruck)
  local nSeanandTruckDistance = Actor.GetActorDist(hSab, self.hExitSkylar)
  if 30 <= nSeanandTruckDistance then
  elseif nSeanandTruckDistance < 30 then
  end
end

function Paris_4_Mission_1:EscalationBailSetup()
  local tEscalationEvent = {
    EventType = "OnEscalation1",
    EventName = "CemEscalation1",
    Target = hSab
  }
  Util.CreateEvent(tEscalationEvent, "Paris_4_Mission_1.OnEscalateInDepot", self)
  local tEscalation2Event = {
    EventType = "OnEscalation2",
    EventName = "CemEscalation2",
    Target = hSab
  }
  Util.CreateEvent(tEscalation2Event, "Paris_4_Mission_1.OnEscalateInDepot", self)
  local tEscalation3Event = {
    EventType = "OnEscalation3",
    EventName = "CemEscalation3",
    Target = hSab
  }
  Util.CreateEvent(tEscalation3Event, "Paris_4_Mission_1.OnEscalateInDepot", self)
end

function Paris_4_Mission_1:ListenForEscalation()
  local tEscavent = {
    EventType = "OnEscalation1",
    Target = hSab
  }
  Util.CreateEvent(tEscavent, "Paris_4_Mission_1.OnEscalation", self)
end

function Paris_4_Mission_1:OnEscalation()
end

function Paris_4_Mission_1:Encounter2Prep()
  local sExitEncTruckSpawn = "Missions\\paris_4\\mission_1\\escapeenc2\\2ndEncTruckSpawn"
  local tSeatConfig = {
    Pilot = "Human_WM_Grunt_MG",
    Shotgun = "Human_WM_Grunt_MG"
  }
  Veh.SafeSpawnAtObj(cVEH_OPEL, sExitEncTruckSpawn, tSeatConfig, true, self.OnTruckSpawns, self, nil)
end

function Paris_4_Mission_1:OnTruckSpawns(a_hTruck)
  local hNaziTruck = a_hTruck
  self.hNaziTruck = hNaziTruck
  local s2ndEncPath = "Missions\\paris_4\\mission_1\\escapeenc2\\2ndEncTruckPath"
  Nav.SetScriptedPath(hNaziTruck, s2ndEncPath, false, "Paris_4_Mission_1.OnNaziTruckEndsPath", self)
  Nav.SetScriptedPathSpeed(hNaziTruck, 35)
end

function Paris_4_Mission_1:OnNaziTruckEndsPath()
end

function Paris_4_Mission_1:TASK_TEMPFILLER()
  self:CreateTask({
    sName = "TASK_TEMPFILLER",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "empty",
    ParentObjectID = self:GetTaskObjectiveID("TASK_ProtectSkylar"),
    sObjectiveTextID = "TEMP",
    tLocators = {},
    tOnActivate = {
      {
        self.Encounter2Prep,
        {self}
      }
    },
    tOnComplete = {
      {
        self.AlmostThere,
        {self}
      }
    }
  })
end

function Paris_4_Mission_1:SetEntryListener()
  local sEntryTrig = "Missions\\paris_4\\mission_1\\main\\EntryTrig"
  Trigger.WaitFor(sEntryTrig, hSab, "Paris_4_Mission_1.GoGoTruckDriver", self, nil, cTRIGGEREVENT_ONENTER, false)
end

function Paris_4_Mission_1:GoGoTruckDriver()
  local hTruckDriver = Util.GetHandleByName(self.sTruckDriver)
  local hDepotGoTruck = Util.GetHandleByName(self.sTruckDisposable)
  Nav.BoardVehicle(hTruckDriver, hDepotGoTruck, "PILOT", cMOVE_NORMAL, "Paris_4_Mission_1.MovethatTruck", self)
  Render.Rain(1, 5)
end

function Paris_4_Mission_1:TASK_Hide()
  self:CreateTask({
    sName = "TASK_Hide",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "empty",
    ParentObjectID = self:GetTaskObjectiveID("TASK_MausoleumWaypoint"),
    sObjectiveTextID = "Hide and Wait!",
    bNoWorldBlip = true,
    tLocators = {},
    tOnActivate = {
      {
        self.SetupAreaFailListener,
        {self}
      }
    },
    tOnComplete = {
      {
        self.TASK_KillDepotGuardQuietly,
        {self}
      }
    }
  })
end

function Paris_4_Mission_1:TASK_KillDepotGuardQuietly()
  self:CreateTask({
    sName = "TASK_KillDepotGuardQuietly",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "KILL",
    ParentObjectID = self:GetTaskObjectiveID("TASK_MausoleumWaypoint"),
    sObjectiveTextID = "Kill the Depot Guard Quietly",
    tTgtInclude = {
      "PARIS\\area04\\cem_lachaise\\occupation\\outer\\motor pool\\nazis\\Spore_WM_Grunt_MG(4)"
    },
    bNoHUDBlip = false,
    tOnComplete = {
      {
        self.TASK_TalkinDepot,
        {self}
      }
    },
    tOnCancel = {},
    tOnActivate = {}
  })
end

function Paris_4_Mission_1:WaitforUGNazi()
  local tUG1NaziStream = {
    EventType = "StreamEvent",
    EventName = "UG1NaziStream",
    Objects = {
      self.sUGPatNazi1
    }
  }
  Util.CreateEvent(tUG1NaziStream, "Paris_4_Mission_1.SetupUG1Prox", self)
end

function Paris_4_Mission_1:SetupUG1Prox()
  local sUG1PatTrigger = "Missions\\paris_4\\mission_1\\main\\crypts\\UG1PatStartWalk"
  self.sUG1PatTrigger = sUG1PatTrigger
  Trigger.WaitFor(sUG1PatTrigger, hSab, "Paris_4_Mission_1.UG1PatStart", self, nil, cTRIGGEREVENT_ONENTER, false)
end

function Paris_4_Mission_1:UG1PatStart()
  local hUGPatNazi1 = Util.GetHandleByName(self.sUGPatNazi1)
  Nav.SetScriptedPath(hUGPatNazi1, self.sUG1PatrolRoute, false)
end

function Paris_4_Mission_1:PlayUG2DisguisedConvo()
  local hUG2NaziSpeaker = Util.GetHandleByName("PARIS\\area04\\cem_lachaise\\occupation\\outer\\general\\nazis\\Spore_SS_Flame_FT(12)")
  if Actor.IsDisguised(hSab) == true and Suspicion.GetEscalation() == 0 then
    Cin.PlayConversation("P4M1_Ambient_NaziConv01")
  else
    dprint(self, "dude is dead, not firing convo")
  end
end

function Paris_4_Mission_1:MoveUG2GuysAside()
  local sUGGuard1Path = "PARIS\\area04\\cem_lachaise\\occupation\\outer\\general\\nazis\\UG2GuardPath1"
  local hUG2Guard1 = Util.GetHandleByName("PARIS\\area04\\cem_lachaise\\occupation\\outer\\general\\nazis\\Spore_SS_Flame_FT(11)")
  Nav.SetScriptedPath(hUG2Guard1, sUGGuard1Path, false)
  EVENT_Timer("Paris_4_Mission_1.ReenableSuspicion", self, 8)
end

function Paris_4_Mission_1:ReenableSuspicion()
  Suspicion.EnableEscalation(true)
end

function Paris_4_Mission_1:FailConvtoEnd()
  Cin.PlayConversation("P4M1_MissionAbandon_Fail", "Paris_4_Mission_1.FailOnThisCall", self)
end

function Paris_4_Mission_1:FailOnThisCall()
  self:MissionTaskFail("P4M1_Text.FAILBYABANDON")
end

function Paris_4_Mission_1:WarnOnThisCall()
  Cin.PlayConversation("P4M1_MissionAbandon_Warning")
end

function Paris_4_Mission_1:SetupAreaFailListener()
  local sFailAreaTrig = "Missions\\paris_4\\mission_1\\main\\FailZoneTrig"
  local sWarnZoneTrig = "Missions\\paris_4\\mission_1\\main\\WarnZoneTrig"
  self:RegisterTriggerEvent(Trigger.WaitFor(sFailAreaTrig, hSab, "Paris_4_Mission_1.FailOnThisCall", self, nil, cTRIGGEREVENT_ONEXIT, false), sFailAreaTrig)
  self:RegisterTriggerEvent(Trigger.WaitFor(sWarnZoneTrig, hSab, "Paris_4_Mission_1.WarnOnThisCall", self, nil, cTRIGGEREVENT_ONEXIT, false), sWarnZoneTrig)
end

function Paris_4_Mission_1:CancelAreaFailTrig()
  local sFailAreaTrig = "Missions\\paris_4\\mission_1\\main\\FailZoneTrig"
  local sWarnZoneTrig = "Missions\\paris_4\\mission_1\\main\\WarnZoneTrig"
  Trigger.Enable(sFailAreaTrig, false)
  Trigger.Enable(sWarnZoneTrig, false)
end

function Paris_4_Mission_1:SetupKubelSpawnReinF()
  local sKubelSpawnLoc = "Missions\\paris_4\\mission_1\\mausoleum\\KubelSpawn"
  local tKSeatConfig = {
    Pilot = "Human_WM_Grunt_MG",
    Shotgun = "Human_WM_Grunt_MG"
  }
  Veh.SafeSpawnAtObj(cVEH_KUBEL, sKubelSpawnLoc, tKSeatConfig, true, self.OnKubel1Spawns, self, nil)
end

function Paris_4_Mission_1:OnKubel1Spawns(a_hKubel)
  local hSpawnedKubel = a_hKubel
  local sKubelSpawnPath = "Missions\\paris_4\\mission_1\\mausoleum\\KubelSpawnPath"
  Nav.SetScriptedPath(hSpawnedKubel, sKubelSpawnPath, false)
  Nav.SetScriptedPathSpeed(hSpawnedKubel, 35)
end

function Paris_4_Mission_1:SetupAmbientUG2StealthTrig()
  dprint(self, "ambtrigsetup")
  local sAmbientUG2StealthTrig = "PARIS\\area04\\cem_lachaise\\cem_underground\\AmbientSUGRoomTrig"
  Trigger.WaitFor(sAmbientUG2StealthTrig, hSab, "Paris_4_Mission_1.PlayUG2StealthConv", self, nil, cTRIGGEREVENT_ONENTER, false)
end

function Paris_4_Mission_1:PlayUG2StealthConv()
  Cin.PlayConversation("P4M1TEMP_Disguised2UG2")
end

function Paris_4_Mission_1:SetWaitReinforceTrig()
end

function Paris_4_Mission_1:SpawnCryptEncNode()
  Util.SpawnEditNode("Missions\\paris_4\\mission_1\\CryptEncounter.wsd", "Paris_4_Mission_1.DelaytoCallReinforcements", self)
end

function Paris_4_Mission_1:DelaytoCallReinforcements()
  EVENT_Timer("Paris_4_Mission_1.SendCryptReinforcementsIn", self, 3)
end

function Paris_4_Mission_1:SendCryptReinforcementsIn()
  local hReinforceLoc = Util.GetHandleByName("Missions\\paris_4\\mission_1\\CryptEncounter\\ReinforcementsEncLoc")
  for i = 1, #self.tCryptEncNazis do
    local hNazi = Util.GetHandleByName(self.tCryptEncNazis[i])
    Nav.MoveToObject(hNazi, hReinforceLoc, 3)
  end
  self:TASK_DefendGround()
end

function Paris_4_Mission_1:SetupTruckTrig()
  Trigger.WaitFor(self.sEscapeTruckPullupTrig1, hSab, "Paris_4_Mission_1.SetupTruckandPullup", self, nil, cTRIGGEREVENT_ONENTER, false)
end

function Paris_4_Mission_1:SetupTruckandPullup()
  local hEscapeChaser = Util.GetHandleByName(self.sEscapeChaser)
  self.hEscapeChaser = hEscapeChaser
end

function Paris_4_Mission_1:SetFollowDelay()
end

function Paris_4_Mission_1:SetTruckChaser()
  Object.FollowObject(self.hEscapeChaser, self.hTruck, 10)
end

function Paris_4_Mission_1:SetupTruck2Listener()
  Trigger.WaitFor(self.sEscapeChaser2Trig, hSab, "Paris_4_Mission_1.SetupTruck2Pullup", self, nil, cTRIGGEREVENT_ONENTER, false)
end

function Paris_4_Mission_1:SetupTruck2Pullup()
  Util.SpawnEditNode("Missions\\paris_4\\mission_1\\escapechasekubel.wsd", "Paris_4_Mission_1.MoveForward", self)
end

function Paris_4_Mission_1:MoveForward()
  local hEscapeChaser2 = Util.GetHandleByName(self.sEscapeChaser2)
  self.hEscapeChaser2 = hEscapeChaser2
  Nav.SetScriptedPath(hEscapeChaser2, self.sEscapeChaser2Path, false)
  Nav.SetScriptedPathSpeed(hEscapeChaser2, 40)
end

function Paris_4_Mission_1:SkyWalkToConvPoint()
  Joe.ClearSabFollower(self.hExitSkylar, true)
  Actor.UnboardVehicle(self.hExitSkylar)
  EVENT_Timer("Paris_4_Mission_1.SetSkyWalking", self, 1.5)
end

function Paris_4_Mission_1:SetSkyWalking()
  local sSkylarWalkUpPath = "Missions\\paris_4\\mission_1\\main\\SkylarExitWalkConv"
  Nav.SetScriptedPath(self.hExitSkylar, sSkylarWalkUpPath, false, "Paris_4_Mission_1.PlayConvToEnd", self)
end

function Paris_4_Mission_1:PlayConvToEnd()
  OnDisables()
  Cin.PlayConversation("P4M1_MissionComplete", "Paris_4_Mission_1.ReleaseNodes", self)
end

function Paris_4_Mission_1:ReleaseNodes()
  Vehicle.SetAsMissionCritical(self.hTruck, false)
  if Actor.IsInVehicle(hSab) == true then
    Actor.UnboardVehicle(hSab)
  else
  end
  Render.FadeScreen(true)
  EVENT_Timer("Paris_4_Mission_1.DelayUnload", self, 2)
end

function Paris_4_Mission_1:DelayUnload()
  self:UnloadTaskNodes("TASK_WarningCall", true)
  EVENT_Timer("Paris_4_Mission_1.CompleteThisNow", self, 1)
end

function Paris_4_Mission_1:CompleteThisNow()
  OffDisables()
  Render.FadeScreen(false)
  self:CompleteThisMission()
end

function Paris_4_Mission_1:SkylarRunOffToNowhere()
end

function Paris_4_Mission_1:TASK_GotoFightBackZone()
  self:CreateTask({
    sName = "TASK_GotoFightBackZone",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "TAXI",
    sObjectiveTextID = "P4M1_Text.TASK_GotoFightBackZone",
    tDestLocators = {
      "Missions\\paris_4\\mission_1\\main\\FightBackLoc"
    },
    tPickupProxObj = {
      self.sExitSkylar
    },
    Proximity = 10,
    tDestRegion = {
      self.sFightBackTrig
    },
    tDeliverObjs = {
      self.sExitSkylar
    },
    bNoDumping = true,
    tOnEarlyExit = {},
    tOnPickup = {},
    tOnComplete = {
      {
        Sound.SetMusicLocale,
        {
          "P4M1_Cemetary"
        }
      },
      {
        Sound.SetMusicLocale,
        {
          "m_P4M1_Cemetary",
          "P4M1_fightback"
        }
      },
      {
        self.StopForcedEscalation,
        {self}
      },
      {
        self.KillSwitchListener,
        {self}
      },
      {
        self.TASK_LostEscalation,
        {self}
      },
      {
        Util.ActivateAmbush,
        {
          "LaV_FightBackConfig1",
          true,
          70
        }
      },
      {
        Vehicle.EnableTraffic,
        {false, true}
      }
    },
    tOnActivate = {},
    tSMEDNodes = {}
  })
end

function Paris_4_Mission_1:SetupCheckPointX()
  self.RegisterCheckpoint(self, "Paris_4_Mission_1.CheckPointX")
end

function Paris_4_Mission_1:CheckPointX()
  self:StopForcedEscalation()
  self:KillSwitchListener()
  self.TASK_LostEscalation()
  Saboteur.ShowToolTip("TutorialTip_Text.Fightback_Zones", 40, nil, true)
  Vehicle.EnableTraffic(false, true)
end

function Paris_4_Mission_1:PlayGotoAmbushConvo()
  if Cin.IsHumanInConversation(hSab) == false and Cin.IsHumanInConversation(self.hExitSkylar) == false then
    Cin.PlayConversation("P4M1_Escape_ToAmbush")
  else
    Cin.StopConversation("P4M1_Escape_TruckDam_Skylar_Light")
    Cin.StopConversation("P4M1_Escape_TruckDam_Skylar_Medium")
    Cin.StopConversation("P4M1_Escape_TruckDam_Skylar_Heavily")
    Cin.StopConversation("P4M1_Escape_Start")
    Cin.PlayConversation("P4M1_Escape_ToAmbush")
  end
end

function Paris_4_Mission_1:StopGotoAmbConvo()
  Cin.StopConversation("P4M1_Escape_ToAmbush")
end

function Paris_4_Mission_1:TASK_LostEscalation()
  self:CreateTask({
    sName = "TASK_LostEscalation",
    sTaskType = "SabTaskObjectiveEscalation",
    sTaskSubType = "None",
    sObjectiveTextID = "P4M1_Text.TASK_LostEscalation",
    EscalationLevel = 0,
    tOnComplete = {
      {
        self.TASK_DelivertoLeHavre,
        {self}
      },
      {
        self.FightbackConvoDelay,
        {self}
      },
      {
        Suspicion.SetFixedEscalationLevel,
        {0}
      },
      {
        RewardsManager.EnableEspritDeCorps,
        {true}
      },
      {
        Util.QueueTutorial,
        {
          "TutorialTip_Text.Fightback_Zones_Title",
          "TutorialTip_Text.Fightback_Zones_Intro",
          20,
          true
        }
      },
      {
        Vehicle.EnableTraffic,
        {true}
      }
    },
    tOnActivate = {
      {
        self.PlayAtBarricadeConvo,
        {self}
      }
    }
  })
end

function Paris_4_Mission_1:PlayAtBarricadeConvo()
  Cin.PlayConversation("P4M1_Escape_Barricade")
end

function Paris_4_Mission_1:FightbackConvoDelay()
  EVENT_Timer("Paris_4_Mission_1.PlayFightBackDoneConvo", self, 5)
end

function Paris_4_Mission_1:PlayFightBackDoneConvo()
  Cin.PlayConversation("P4M1_Escape_Barricade_Done")
end

function Paris_4_Mission_1:ListenforDeEscalation()
  local tDESCAVENT = {
    EventType = "OnEscalation0",
    Target = hSab
  }
  self.eSwitchEvent = self:RegisterEvent(Util.CreateEvent(tDESCAVENT, "Paris_4_Mission_1.SwitchBabySwitch", self))
end

function Paris_4_Mission_1:SwitchBabySwitch()
  self:StopGotoAmbConvo()
  self:FailTaskByName("TASK_GotoFightBackZone")
  self.StopForcedEscalation(self)
  Vehicle.EnableTraffic(false, true)
  self:TASK_DelivertoLeHavre()
end

function Paris_4_Mission_1:KillSwitchListener()
  Inventory.GiveItem(self.hExitSkylar, "WP_MG_MP40", true)
  Combat.SetCombat(self.hExitSkylar)
  Util.KillEvent(self.eSwitchEvent)
end

function Paris_4_Mission_1:MISSION_ONCANCEL()
  if self.tInfo.hSkylarsTruckObj then
    HUD.RemoveObjective(self.tInfo.hSkylarsTruckObj)
    self.tInfo.hSkylarsTruckObj = nil
  end
  RewardsManager.EnableEspritDeCorps(false)
  RewardsManager.ShowStarter("Moreau_Exterior")
  Zone.SwitchState("WtF_Zones\\global\\P4M1_Cemetary", cZONESTATE_LOWWTF, cENT_IMMEDIATE)
end

function Paris_4_Mission_1:MISSION_ONRESET()
  if Util.IsBlockLoaded("Missions\\paris_4\\mission_1\\escapechasekubel.wsd") then
    Util.UnloadEditNode("Missions\\paris_4\\mission_1\\escapechasekubel.wsd", true)
  end
  Suspicion.SetInescapableEscalation(false)
  Sound.ResetMusicLocale()
  Vehicle.EnableTraffic(true)
end

function Paris_4_Mission_1:ForceEscalation()
  Suspicion.SetEscalated()
  if self.nForceEscalation == true then
    self.eForceEscalation = EVENT_Timer("Paris_4_Mission_1.ForceEscalation", self, 1)
  else
  end
end

function Paris_4_Mission_1:StopForcedEscalation()
  if self.eForceEscalation then
    Util.KillEvent(self.eForceEscalation)
  else
    self.bForceEscalation = false
  end
end

function Paris_4_Mission_1:SetupNearHQ()
  EVENT_PlayerEntersTrigger("Paris_4_Mission_1.PlayNearHQConv", self, "Missions\\paris_4\\mission_1\\main\\PT_NearHQ_VOTrig", false)
end

function Paris_4_Mission_1:PlayNearHQConv()
  Cin.PlayConversation("P4M1_Escape_NearHQ")
end

function Paris_4_Mission_1:TASK_GetInTheExitTruck()
end

function Paris_4_Mission_1:PlayFightbackZoneTut()
  local self = Paris_4_Mission_1
  Saboteur.ShowToolTip("TutorialTip_Text.Fightback_Zones", 40, nil, true)
end
