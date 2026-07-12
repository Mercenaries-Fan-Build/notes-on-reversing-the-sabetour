if P2FP_GrandSniper == nil then
  P2FP_GrandSniper = SabTaskObjective:Create()
  P2FP_GrandSniper.PATH = "Missions\\freeplay\\p2\\mis_grandsniper\\"
  P2FP_GrandSniper:Configure({
    TaskCount = 99,
    sStarter = "Margot_Boulogne_Interior",
    sConvFile = "P2FP_GrandSniper_Start",
    sSaveMissionNameID = "MissionNames_Text.P2FP_GrandSniper",
    sActNameID = "MissionNames_Text.ACT_Margot",
    tUnlockList = {
      "P2FP_RadioSwap"
    },
    WTFZoneHigh = P2FP_GrandSniper.PATH .. "WTF",
    tSMEDNodes = {
      P2FP_GrandSniper.PATH .. "main",
      P2FP_GrandSniper.PATH .. "crowd",
      P2FP_GrandSniper.PATH .. "task"
    },
    tStaticTags = {
      "p2_grandsniper_civs"
    }
  })
end

function P2FP_GrandSniper:STARTER_Setup()
end

function P2FP_GrandSniper:Activated()
  self.sDebugLabel = "SNIPER"
  self.bDebugMode = false
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
  self:RegisterCheckpoint("P2FP_GrandSniper.Checkpoint0")
end

function P2FP_GrandSniper.SetupGamepadListener()
  local self = P2FP_GrandSniper
  self.tControllerEvent = {
    EventType = "OnButtonPress",
    Target = Handle("Saboteur")
  }
  local eButtonEvent = Util.CreateEvent(self.tControllerEvent, "P2FP_GrandSniper.OnButtonPress", self, {}, true)
  self:RegisterEvent(eButtonEvent)
end

function P2FP_GrandSniper:OnButtonPress(a_tButtonData)
  local self = P2FP_GrandSniper
  local tButtons = a_tButtonData[1]
  if tButtons.UP == true then
  elseif tButtons.DOWN == true then
  elseif tButtons.X == true then
  elseif tButtons.B == true then
  end
end

function P2FP_GrandSniper:GENERAL_Setup()
  Util.LoadStaticENTag("mis_grandsniperProps", true)
  self.sLimoSpawnLoc = self.PATH .. "main\\LOC_LimoSpawn"
  self.sLimoDestLoc = self.PATH .. "main\\LOC_LimoDest"
  self.sLimoCorner = self.PATH .. "main\\LOC_LimoCorner"
  self.nLimoSpeed = 10
  self.sStreetGuard1 = self.PATH .. "main\\NZ_StreetGuard_1"
  self.sStreetGuard2 = self.PATH .. "main\\NZ_StreetGuard_2"
  self.sStreetGuard3 = self.PATH .. "main\\NZ_StreetGuard_3"
  self.sStreetGuard4 = self.PATH .. "main\\NZ_StreetGuard_4"
  self.sNestLocator = self.PATH .. "main\\LOC_Nest"
  self.sNestTrigger = self.PATH .. "main\\PT_Nest"
  self.sRadioManager = self.PATH .. "wtf_low\\occupation\\ShortwaveRadio"
  self.tConvSpots = {}
  self.tConvSpots[1] = {
    self.PATH .. "main\\LOC_ConvA_Gen1",
    self.PATH .. "main\\LOC_ConvA_Gen2"
  }
  self.tConvSpots[2] = {
    self.PATH .. "main\\LOC_ConvB_Gen1",
    self.PATH .. "main\\LOC_ConvB_Gen2"
  }
  self.tConvSpots[3] = {
    self.PATH .. "main\\LOC_ConvC_Gen1",
    self.PATH .. "main\\LOC_ConvC_Gen2"
  }
  self.bGeneralsSpooked = false
  self.hTowerLoc = self.PATH .. "main\\LOC_TowerNest"
  self.sTowerTrigger = self.PATH .. "main\\PT_TowerNest"
  self.tOfficers = {}
  self.sOfficerBlueprint = "Human_WM_Officer_PS"
  self.sOfficerASpawn = self.PATH .. "main\\SPAWN_OfficerA"
  self.sOfficerBSpawn = self.PATH .. "main\\SPAWN_OfficerB"
  self.hOfficerAGreetSpot = self.PATH .. "main\\LOC_Officer1SpawnDest"
  self.hOfficerBGreetSpot = self.PATH .. "main\\LOC_Officer2SpawnDest"
  self.hGeneralGreetSpot = self.PATH .. "main\\LOC_GeneralUnboardDest"
  self.tTargets = {}
  self.tKubelPassengers = {}
  self.tLimoPassengers = {}
  self.tAPCPassengers = {}
  self.sFrontKubel = "Missions\\freeplay\\p2\\mis_grandsniper\\motorcade\\VH_NZ_CR_Kubelwagen_01"
  self.sLeftBike = "Missions\\freeplay\\p2\\mis_grandsniper\\motorcade\\VH_NZ_MO_KS750Sidecar_01(3)"
  self.sRightBike = "Missions\\freeplay\\p2\\mis_grandsniper\\motorcade\\VH_NZ_MO_KS750Sidecar_01"
  self.sBackAPC = "Missions\\freeplay\\p2\\mis_grandsniper\\motorcade\\VH_NZ_TR_HalfTrack_01(3)"
  self.sLimoTarget = "Missions\\freeplay\\p2\\mis_grandsniper\\motorcade\\VH_NZ_CR_6WheelNaziLimo_Bproof"
  self.tConvoy = {
    self.sFrontKubel,
    self.sLeftBike,
    self.sRightBike,
    self.sBackAPC,
    self.sLimoTarget
  }
  self.tStreamConvoy = {
    self.sFrontKubel,
    self.sLeftBike,
    self.sRightBike,
    self.sBackAPC,
    self.sLimoTarget,
    self.sGeneral
  }
  self.sKubelPath = "Missions\\freeplay\\p2\\mis_grandsniper\\main\\PA_KubelA"
  self.sLimoPath = "Missions\\freeplay\\p2\\mis_grandsniper\\main\\PA_LimoA"
  self.sCyclePathLeft = "Missions\\freeplay\\p2\\mis_grandsniper\\main\\PA_CycleLeft"
  self.sCyclePathLeft2 = "Missions\\freeplay\\p2\\mis_grandsniper\\main\\PA_CycleRight"
  self.sAPCPath = "Missions\\freeplay\\p2\\mis_grandsniper\\main\\PA_APCA"
  self.tSeatList = {
    "PILOT",
    "SHOTGUN",
    "BACKSEAT_L"
  }
  self.tAPCSeatList = {
    "PILOT",
    "SHOTGUN",
    "REAR_R1",
    "REAR_R2",
    "REAR_R3",
    "REAR_L1",
    "REAR_L2",
    "REAR_L3"
  }
  self.sGruntBP = "Human_WM_Grunt_MG"
  self.sGeneral = "Missions\\freeplay\\p2\\mis_grandsniper\\motorcade\\Spore_GS_General_PS"
  self.sKubelEscape = "Missions\\freeplay\\p2\\mis_grandsniper\\main\\LOC_KubelEscape"
  self.sLimoEscape = "Missions\\freeplay\\p2\\mis_grandsniper\\main\\PA_LimoEscape"
  self.sLimoEscape2 = "Missions\\freeplay\\p2\\mis_grandsniper\\main\\LOC_LimoEscape2"
  self.tNazisinWaiting = {
    "Missions\\freeplay\\p2\\mis_grandsniper\\crowd\\NZ_N_Arc(20)",
    "Missions\\freeplay\\p2\\mis_grandsniper\\crowd\\NZ_N_Arc(19)",
    "Missions\\freeplay\\p2\\mis_grandsniper\\crowd\\NZ_N_Arc(18)",
    "Missions\\freeplay\\p2\\mis_grandsniper\\crowd\\NZ_N_Arc(17)"
  }
  self.tMinesweepers = {
    "Missions\\freeplay\\p2\\mis_grandsniper\\minesweepers\\Spore_WNZ_Grunt_RF",
    "Missions\\freeplay\\p2\\mis_grandsniper\\minesweepers\\Spore_WNZ_Grunt_RF(2)",
    "Missions\\freeplay\\p2\\mis_grandsniper\\minesweepers\\Spore_WNZ_Grunt_RF(4)",
    "Missions\\freeplay\\p2\\mis_grandsniper\\minesweepers\\Spore_WNZ_Grunt_RF(6)"
  }
  self.tInfo.bCheckpt2Esc = false
  self.bGeneralInCar = false
  self.nHideLocation = 0
  self:AddOnCancelCallback(P2FP_GrandSniper.Reset)
  self:AddOnCompleteCallback(P2FP_GrandSniper.Reset)
end

function P2FP_GrandSniper:Sound1()
end

function P2FP_GrandSniper:Sound2()
  Sound.SetMusicLocale("fp_P2FP_GrandSniper")
  Sound.SetMusicLocale("fp_P2FP_GrandSniper", "paradeStart")
end

function P2FP_GrandSniper:Checkpoint0()
  dprint(self, "Registered: CHECKPOINT 0")
  self.TASK_GotoGrandPalais(self)
  self.Task_ExitHQ(self)
end

function P2FP_GrandSniper:Task_ExitHQ()
  self:CreateTask({
    sName = "P2FP_GrandSniper.Task_ExitHQ",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "ExitInterior",
    sInteriorName = "Boulogne",
    bInteriorTask = true,
    bNoGPS = true,
    MarkerHeight = 2.5,
    tLocators = {},
    tOnComplete = {
      {
        self.RegisterCheckpoint,
        {
          self,
          "P2FP_GrandSniper.Checkpoint1"
        }
      }
    }
  })
end

function P2FP_GrandSniper:Checkpoint1()
  dprint(self, "Registered: CHECKPOINT 1")
  self.bGeneralInCar = false
  EVENT_Stream("P2FP_GrandSniper.SetupGuardWarns", self, self.sStreetGuard3, true)
  local sPropPath = "Missions\\freeplay\\p2\\mis_grandsniper\\main\\Radio_Use"
  EVENT_Stream("P2FP_GrandSniper.OnRadioPropStreams", self, sPropPath, false)
  if not self:IsMissionTaskActive("P2FP_GrandSniper.TASK_GotoGrandPalais") then
    self.TASK_GotoGrandPalais(self)
  end
  Vehicle.EnableTraffic(false, true)
end

function P2FP_GrandSniper:SetupGuardWarns()
  EVENT_ActorToActorProximity("P2FP_GrandSniper.StreetGuardWarns", self, hSab, Handle(self.sStreetGuard3), 30)
end

function P2FP_GrandSniper:StreetGuardWarns()
  if not Actor.IsDisguised(hSab) then
    if Actor.IsInVehicle(hSab) then
      Actor.SetFacingDir(Handle(self.sStreetGuard3), hSab)
      Actor.PlayAnimation(Handle(self.sStreetGuard2), "nazi_halt_1")
      Actor.PlayAnimation(Handle(self.sStreetGuard3), "nazi_halt_1")
      Cin.PlayConversationWith("P2FP_GrandSniper_NaziGuard", {
        Handle(self.sStreetGuard3)
      })
    else
      EVENT_ActorToActorProximity("P2FP_GrandSniper.CloseGuardWarns", self, hSab, Handle(self.sStreetGuard3), 10)
    end
  end
end

function P2FP_GrandSniper:CloseGuardWarns()
  Actor.SetFacingDir(Handle(self.sStreetGuard3), hSab)
  Actor.PlayAnimation(Handle(self.sStreetGuard2), "nazi_halt_1")
  Actor.PlayAnimation(Handle(self.sStreetGuard3), "nazi_halt_1")
  Cin.PlayConversationWith("P2FP_GrandSniper_NaziGuard", {
    Handle(self.sStreetGuard3)
  })
end

function P2FP_GrandSniper:TASK_GotoGrandPalais()
  self:CreateTask({
    sName = "P2FP_GrandSniper.TASK_GotoGrandPalais",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    sObjectiveTextID = "P2FP_GrandSniper_Text.TASK_GotoGrandPalais",
    tDeliverObjs = {
      Handle("Saboteur")
    },
    tDestRegion = {
      "Missions\\freeplay\\p2\\mis_grandsniper\\task\\PantheonDeliver"
    },
    tLocators = {
      "Missions\\freeplay\\p2\\mis_grandsniper\\task\\PantheonDeliverLoc"
    },
    tOnActivate = {},
    tOnComplete = {
      {
        self.TASK_UseElevator,
        {self}
      }
    }
  })
end

function P2FP_GrandSniper:TASK_UseElevator()
  self:CreateTask({
    sName = "P2FP_GrandSniper.TASK_UseElevator",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    bNoGPS = true,
    sObjectiveTextID = "P2FP_GrandSniper_Text.TASK_UseElevator",
    tDeliverObjs = {
      Handle("Saboteur")
    },
    tDestRegion = {
      "Missions\\freeplay\\p2\\mis_grandsniper\\main\\PT_Checkpoint2"
    },
    tLocators = {
      "Missions\\freeplay\\p2\\mis_grandsniper\\main\\LOC_TopOfElevator"
    },
    tOnActivate = {},
    tOnComplete = {
      {
        self.RegisterCheckpoint,
        {
          self,
          "P2FP_GrandSniper.Checkpoint2"
        }
      },
      {
        self.ShotsFiredCheck,
        {self}
      },
      {
        self.NearRadioCheck,
        {self}
      }
    }
  })
end

function P2FP_GrandSniper:Checkpoint2()
  dprint(self, "Registered: CHECKPOINT 2")
  self.bGeneralInCar = false
  if self.tInfo.bCheckpt2Esc == true then
    Suspicion.SetEscalated()
  end
  if Suspicion.GetEscalation() > 0 then
    self.tInfo.bCheckpt2Esc = true
  end
  if not self:IsMissionTaskActive("P2FP_GrandSniper.TASK_GiveConfirmation") then
    self.TASK_GiveConfirmation(self)
    AttractionPt.EnableUse(self.hRadioAttrPt, true)
  end
end

function P2FP_GrandSniper:TASK_GetToTheNest()
  self:CreateTask({
    sName = "P2FP_GrandSniper.TASK_GetToTheNest",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    sObjectiveTextID = "P2FP_GrandSniper_Text.TASK_GetToTheNest",
    tDeliverObjs = {
      Handle("Saboteur")
    },
    tDestRegion = {
      self.sNestTrigger
    },
    tLocators = {
      self.sNestLocator
    },
    bNoGPS = true,
    tOnActivate = {},
    tOnComplete = {
      {
        self.TASK_GiveConfirmation,
        {self}
      },
      {
        self.NearRadioCheck,
        {self}
      },
      {
        self.ShotsFiredCheck,
        {self}
      }
    }
  })
end

function P2FP_GrandSniper:TASK_GiveConfirmation()
  self:CreateTask({
    sName = "P2FP_GrandSniper.TASK_GiveConfirmation",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "USE",
    sObjectiveTextID = "P2FP_GrandSniper_Text.TASK_GiveConfirmation",
    tTgtInclude = {
      self.hRadioAttrPt
    },
    bNoGPS = true,
    tSMEDNodes = {},
    tStaticTags = {
      "p2fp_grandsniper_bazookas"
    },
    tOnActivate = {
      {
        self.EscalationListener,
        {self}
      }
    },
    tOnComplete = {
      {
        self.WaitForStreamCars,
        {self}
      },
      {
        self.KillUsePoint,
        {self}
      },
      {
        self.PreScanStreets,
        {self}
      },
      {
        self.KillEscEvent,
        {self}
      },
      {
        self.SabNearRadio,
        {self}
      },
      {
        self.Sound2,
        {self}
      },
      {
        self.LeaveMissionFail,
        {self}
      }
    }
  })
end

function P2FP_GrandSniper:KillEscEvent()
  Util.KillEvent(self.eEscDetect)
end

function P2FP_GrandSniper:LeaveMissionFail()
  self.eLeftMission = EVENT_PlayerExitsTrigger("P2FP_GrandSniper.FailLeftMission", self, "Missions\\freeplay\\p2\\mis_grandsniper\\main\\PT_MissionArea", false)
end

function P2FP_GrandSniper:PreScanStreets()
  Util.SetDynamicPriority("VH_NZ_MO_KS750Sidecar_01", 10001)
  Util.SetDynamicPriority("VH_NZ_TR_HalfTrack_01", 10001)
  Util.SetDynamicPriority("VH_NZ_CR_6WheelNaziLimo_Bproof", 10001)
  self:TASK_ScanStreets()
end

function P2FP_GrandSniper:TASK_ScanStreets()
  self:CreateTask({
    sName = "P2FP_GrandSniper.TASK_ScanStreets",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "NONE",
    sObjectiveTextID = "P2FP_GrandSniper_Text.TASK_ScanStreets",
    tSMEDNodes = {
      P2FP_GrandSniper.PATH .. "motorcade",
      P2FP_GrandSniper.PATH .. "minesweepers"
    },
    tOnActivate = {
      {
        AttractionPt.EnableBroadcast,
        {
          self.hRadioAttrPt,
          false
        }
      },
      {
        self.RunOnEscalation,
        {self}
      },
      {
        self.GoMinesweepers,
        {self}
      }
    },
    tOnComplete = {
      {
        self.TASK_KillGeneral,
        {self}
      }
    }
  })
end

function P2FP_GrandSniper:RunOnEscalation()
  self.eEscEscape = EVENT_OnEscalation("P2FP_GrandSniper.GunFireListener", self, nil, false)
  self.eEscLiteEscape = EVENT_OnEscalationLite("P2FP_GrandSniper.GunFireListener", self, nil)
end

function P2FP_GrandSniper:GoMinesweepers()
  EVENT_Stream("P2FP_GrandSniper.MinesweepsReady", self, self.tMinesweepers, true)
end

function P2FP_GrandSniper:MinesweepsReady()
  local hMS1 = Handle("Missions\\freeplay\\p2\\mis_grandsniper\\minesweepers\\Spore_WNZ_Grunt_RF")
  local hMS2 = Handle("Missions\\freeplay\\p2\\mis_grandsniper\\minesweepers\\Spore_WNZ_Grunt_RF(2)")
  local hMS3 = Handle("Missions\\freeplay\\p2\\mis_grandsniper\\minesweepers\\Spore_WNZ_Grunt_RF(4)")
  local hMS4 = Handle("Missions\\freeplay\\p2\\mis_grandsniper\\minesweepers\\Spore_WNZ_Grunt_RF(6)")
  local hHuntSpot1 = Handle("Missions\\freeplay\\p2\\mis_grandsniper\\main\\LOC_HuntSpot1")
  local hHuntSpot2 = Handle("Missions\\freeplay\\p2\\mis_grandsniper\\main\\LOC_HuntSpot2")
  local hHuntSpot3 = Handle("Missions\\freeplay\\p2\\mis_grandsniper\\main\\LOC_HuntSpot3")
  local hHuntSpot4 = Handle("Missions\\freeplay\\p2\\mis_grandsniper\\main\\LOC_HuntSpot4")
  Nav.MoveToObject(hMS1, hHuntSpot4, 2, true)
  Nav.MoveToObject(hMS2, hHuntSpot3, 2, true)
  Nav.MoveToObject(hMS3, hHuntSpot1, 2, true)
  Nav.MoveToObject(hMS4, hHuntSpot2, 2, true)
end

function P2FP_GrandSniper:TASK_KillGeneral()
  self:CreateTask({
    sName = "P2FP_GrandSniper.TASK_KillGeneral",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "KILL",
    bNoGPS = true,
    sObjectiveTextID = "P2FP_GrandSniper_Text.TASK_KillGeneral",
    tTgtInclude = {
      self.hGeneral
    },
    tOnActivate = {
      {
        self.GunFireListener,
        {self}
      }
    },
    tOnComplete = {
      {
        self.TASK_EscapeTheRetribution,
        {self}
      },
      {
        self.KillLeftMissionEvent,
        {self}
      }
    }
  })
end

function P2FP_GrandSniper:KillLeftMissionEvent()
  Trigger.ClearCallback("Missions\\freeplay\\p2\\mis_grandsniper\\main\\PT_MissionArea", self.eLeftMission)
end

function P2FP_GrandSniper:TASK_EscapeTheRetribution()
  self:CreateTask({
    sName = "TASK_EscapeTheRetribution",
    sTaskType = "SabTaskObjectiveEscalation",
    sTaskSubType = "None",
    sObjectiveTextID = "GenericObjective_Text.Escalation_Lose",
    EscalationLevel = 0,
    tOnComplete = {
      {
        self.FinishThisMission,
        {self}
      }
    },
    tOnActivate = {}
  })
end

function P2FP_GrandSniper:TASK_LoseEscalation()
  self:CreateTask({
    sName = "TASK_LoseEscalation",
    sTaskType = "SabTaskObjectiveEscalation",
    sTaskSubType = "None",
    sObjectiveTextID = "GenericObjective_Text.Escalation_Lose",
    EscalationLevel = 0,
    bRepeatable = true,
    bNoRepeatAutoRebuild = true,
    tOnComplete = {
      {
        self.TASK_GiveConfirmation,
        {self}
      }
    },
    tOnActivate = {}
  })
end

function P2FP_GrandSniper:OnRadioPropStreams()
  dprint(self, "Radio has streamed in. Setting variables.")
  self.hRadioAttrPt = Handle("Missions\\freeplay\\p2\\mis_grandsniper\\main\\Radio_Use")
end

function P2FP_GrandSniper:RideInFormation()
  local nKubelLimoDist = Object.GetDistance(self.hLimo, self.hKubel)
  local nLimoSpeed = Vehicle.GetSpeed(self.hLimo)
  if nKubelLimoDist < 7 then
    nLimoSpeed = nLimoSpeed - 2
    Nav.SetScriptedPathSpeed(self.hLimo, nLimoSpeed)
  elseif 9 < nKubelLimoDist then
    nLimoSpeed = nLimoSpeed + 2
    Nav.SetScriptedPathSpeed(self.hLimo, nLimoSpeed)
  end
  local nLimoAPCDist = Object.GetDistance(self.hLimo, self.hAPC)
  local nAPCSpeed = Vehicle.GetSpeed(self.hAPC)
  if nLimoAPCDist < 9 then
    nAPCSpeed = nAPCSpeed - 2
    Nav.SetScriptedPathSpeed(self.hAPC, nAPCSpeed)
  elseif 11 < nLimoAPCDist then
    nAPCSpeed = nAPCSpeed + 2
    Nav.SetScriptedPathSpeed(self.hAPC, nAPCSpeed)
  end
  self.eFormationTimer = EVENT_Timer("P2FP_GrandSniper.RideInFormation", self, 3)
end

function P2FP_GrandSniper:KillFormationTimer()
  Util.KillEvent(self.eFormationTimer)
end

function P2FP_GrandSniper:OnLimoReachesCorner()
  Nav.SetScriptedPathSpeed(self.hLeftBike, 12)
  Nav.SetScriptedPathSpeed(self.hRightBike, 12)
  EVENT_ActorToActorProximity("P2FP_GrandSniper.NaziSalute", self, self.hLimo, Handle("Missions\\freeplay\\p2\\mis_grandsniper\\crowd\\NZ_N_Arc(17)"), 15)
  EVENT_ActorToActorProximity("P2FP_GrandSniper.MoveStreetGuard", self, self.hKubel, Handle(self.sStreetGuard3), 40)
end

function P2FP_GrandSniper:UpdateObjective()
  self:CompleteTaskByName("P2FP_GrandSniper.TASK_ScanStreets")
end

function P2FP_GrandSniper:NaziSalute()
  local tGroupSequence = {
    {
      "PLAYANIMATION",
      {"nazi_hail"}
    },
    {
      "DELAY",
      {4}
    },
    {
      "PLAYANIMATION",
      {"nazi_hail"}
    },
    {
      "DELAY",
      {4}
    },
    {
      "PLAYANIMATION",
      {"nazi_hail"}
    },
    {
      "DELAY",
      {4}
    },
    {
      "PLAYANIMATION",
      {"nazi_hail"}
    },
    {
      "DELAY",
      {4}
    }
  }
  for i = 1, #self.tNazisinWaiting do
    local hNazi = Util.GetHandleByName(self.tNazisinWaiting[i])
    ScriptSequence.Run(hNazi, tGroupSequence)
  end
end

function P2FP_GrandSniper:MoveStreetGuard()
  Combat.SetIdleScripted(Handle(self.sStreetGuard1), true)
  Combat.SetIdleScripted(Handle(self.sStreetGuard2), true)
  Combat.SetIdleScripted(Handle(self.sStreetGuard3), true)
  Combat.SetIdleScripted(Handle(self.sStreetGuard4), true)
  Nav.MoveToObject(Handle(self.sStreetGuard1), Handle("Missions\\freeplay\\p2\\mis_grandsniper\\main\\LOC_StreetGuard_1"), 1)
  Nav.MoveToObject(Handle(self.sStreetGuard2), Handle("Missions\\freeplay\\p2\\mis_grandsniper\\main\\LOC_StreetGuard_2"), 1)
  Nav.MoveToObject(Handle(self.sStreetGuard3), Handle("Missions\\freeplay\\p2\\mis_grandsniper\\main\\LOC_StreetGuard_3"), 1)
  Nav.MoveToObject(Handle(self.sStreetGuard4), Handle("Missions\\freeplay\\p2\\mis_grandsniper\\main\\LOC_StreetGuard_4"), 1)
end

function P2FP_GrandSniper:CarsReceiveDamageEvent()
  dprint(self, "Setting Up Car Damage Event")
  for i = 1, #self.tConvoy do
    Util.CreateEvent({
      EventType = "DamageEvent",
      ObjectName = self.tConvoy[i],
      MinDamage = 25
    }, "P2FP_GrandSniper.OnCarsReceiveDamage", self, a_tPassTable)
  end
end

function P2FP_GrandSniper:OnCarsReceiveDamage(a_tArgs)
  dprint(self, "One of the Cars has taken over 25 health in damage")
  local tDamageArgs = a_tArgs
  local DamageDoer = tDamageArgs[1]
  local DamageAmt = tDamageArgs[3]
  if DamageDoer == hSab then
    self:VehicleandPassengerReactions()
  end
end

function P2FP_GrandSniper:WaitForStreamCars()
  EVENT_Stream("P2FP_GrandSniper.SpawnAllActors", self, self.tStreamConvoy, true)
end

function P2FP_GrandSniper:SpawnAllActors()
  local hKubel = Util.GetHandleByName(self.sFrontKubel)
  local hLimo = Util.GetHandleByName(self.sLimoTarget)
  local hLeftCycle = Util.GetHandleByName(self.sLeftBike)
  local hRightCycle = Util.GetHandleByName(self.sRightBike)
  local hAPC = Util.GetHandleByName(self.sBackAPC)
  Object.SpawnInVehicle(self.sGruntBP, "PILOT", hRightCycle)
  Object.SpawnInVehicle(self.sGruntBP, "PILOT", hLeftCycle)
  self.hGeneral = Handle("Missions\\freeplay\\p2\\mis_grandsniper\\motorcade\\Spore_GS_General_PS")
  self.hLimo = hLimo
  self.hLeftBike = hLeftCycle
  self.hRightBike = hRightCycle
  self.hKubel = hKubel
  self.hAPC = hAPC
  self.tHandlesConvoy = {
    self.hLeftBike,
    self.hRightBike,
    self.hAPC
  }
  for i = 1, #self.tSeatList do
    Object.SpawnInVehicle(self.sGruntBP, self.tSeatList[i], hKubel)
  end
  for i = 1, #self.tSeatList do
    if i == 3 then
      Nav.BoardVehicle(self.hGeneral, self.hLimo, "BACKSEAT_L", true, "P2FP_GrandSniper.SetupGeneralBeh", self, {})
    else
      Object.SpawnInVehicle(self.sGruntBP, self.tSeatList[i], hLimo)
    end
  end
  for i = 1, #self.tAPCSeatList do
    Object.SpawnInVehicle(self.sGruntBP, self.tAPCSeatList[i], hAPC)
  end
  local tProxEvent = {
    EventType = "ProximityEvent",
    EventName = "ProxyLimo",
    ObjectA = Util.GetHandleByName(self.sLimoCorner),
    ObjectB = self.hLimo,
    Proximity = 20
  }
  Util.CreateEvent(tProxEvent, "P2FP_GrandSniper.OnLimoReachesCorner", self)
  local tProxEvent2 = {
    EventType = "SeeLocatorEvent",
    EventName = "SeeLimo",
    InViewTime = 0.25,
    Locator = Handle("Missions\\freeplay\\p2\\mis_grandsniper\\main\\LOC_SeeLimo"),
    Proximity = 200
  }
  Util.CreateEvent(tProxEvent2, "P2FP_GrandSniper.UpdateObjective", self)
end

function P2FP_GrandSniper:SetKubelMoving()
  Nav.SetScriptedPath(self.hKubel, self.sKubelPath)
  Nav.SetScriptedPathSpeed(self.hKubel, 10)
  EVENT_Timer("P2FP_GrandSniper.SetLimoMoving", self, 2)
end

function P2FP_GrandSniper:SetLimoMoving()
  if Suspicion.IsEscalatedLite() then
    self:VehicleandPassengerReactions()
  else
    Nav.SetScriptedPath(self.hLimo, self.sLimoPath, false, "P2FP_GrandSniper.FailThisMissionNow_LimoEnd", self)
    Nav.SetScriptedPathSpeed(self.hLimo, 10)
    Nav.SetScriptedPath(self.hLeftBike, self.sCyclePathLeft)
    Nav.SetScriptedPathSpeed(self.hLeftBike, 11)
    Nav.SetScriptedPath(self.hRightBike, self.sCyclePathLeft2)
    Nav.SetScriptedPathSpeed(self.hRightBike, 11)
    EVENT_Timer("P2FP_GrandSniper.SetAPCMoving", self, 0.4)
  end
end

function P2FP_GrandSniper:SetAPCMoving()
  Nav.SetScriptedPath(self.hAPC, self.sAPCPath)
  Nav.SetScriptedPathSpeed(self.hAPC, 10)
  EVENT_Timer("P2FP_GrandSniper.RideInFormation", self, 4)
end

function P2FP_GrandSniper:SetupGeneralBeh()
  self.bGeneralInCar = true
  self.nTargetMaxHealth = Object.GetMaxHealth(self.hGeneral)
  dprint(self, "General is spawned")
  self:SetKubelMoving()
  self:CollectAllPassengers()
  self:CarsReceiveDamageEvent()
end

function P2FP_GrandSniper:CollectAllPassengers()
  for i = 1, #self.tSeatList do
    self.tKubelPassengers[i] = Vehicle.GetActorInSeat(self.hKubel, self.tSeatList[i])
    Combat.SetIdleScripted(self.tKubelPassengers[i], true)
    Combat.SetIgnoreCombatInVehicle(self.tKubelPassengers[i], true)
  end
  self.hLeftBikePilot = Vehicle.GetActorInSeat(self.hLeftBike, "PILOT")
  self.hRightBikePilot = Vehicle.GetActorInSeat(self.hRightBike, "PILOT")
  self.hLimoDriver = Vehicle.GetPilot(self.hLimo)
  for i = 1, #self.tSeatList do
    self.tLimoPassengers[i] = Vehicle.GetActorInSeat(self.hLimo, self.tSeatList[i])
    Combat.SetIdleScripted(self.tLimoPassengers[i])
    Combat.SetIgnoreCombatInVehicle(self.tLimoPassengers[i], true)
  end
  for i = 1, #self.tAPCSeatList do
    self.tAPCPassengers[i] = Vehicle.GetActorInSeat(self.hAPC, self.tAPCSeatList[i])
  end
  self.tAllPassHandles = {
    self.hLeftBikePilot,
    self.hRightBikePilot,
    self.tAPCPassengers[1],
    self.tAPCPassengers[2],
    self.tAPCPassengers[3],
    self.tAPCPassengers[4],
    self.tAPCPassengers[5],
    self.tAPCPassengers[6],
    self.tAPCPassengers[7],
    self.tAPCPassengers[8]
  }
end

function P2FP_GrandSniper:VehicleandPassengerReactions()
  if self.bGeneralInCar == true then
    for i = 1, #self.tHandlesConvoy do
      Nav.StopMoving(self.tHandlesConvoy[i])
      Vehicle.UnboardAll(self.tHandlesConvoy[i], false)
    end
    Util.KillEvent(self.eFormationTimer)
    Nav.SetScriptedPath(self.hKubel, self.sLimoEscape, true)
    Nav.SetScriptedPathSpeed(self.hKubel, 140)
    Nav.SetScriptedPath(self.hLimo, self.sLimoEscape, true)
    Nav.SetScriptedPathSpeed(self.hLimo, 100)
    Suspicion.SetEscalatedWithWhistle()
    EVENT_ActorEntersTrigger("P2FP_GrandSniper.LimoTurnsLeft", self, self.hLimo, "Missions\\freeplay\\p2\\mis_grandsniper\\main\\PT_LimoTurnsLeft")
    Cin.PlayConversation("P2FP_GrandSniper_Abort")
  else
    EVENT_Timer("P2FP_GrandSniper.VehicleandPassengerReactions", self, 0.5)
  end
end

function P2FP_GrandSniper:LimoTurnsLeft()
  Nav.MoveToObject(self.hLimo, Handle(self.sLimoEscape2), 3, true)
  EVENT_StreamOut("P2FP_GrandSniper.FailThisMissionNow_StreamOut", self, self.hLimoDriver, nil)
  EVENT_ActorEntersTrigger("P2FP_GrandSniper.FailThisMissionNow_Limo", self, self.hLimo, "Missions\\freeplay\\p2\\mis_grandsniper\\main\\PT_LimoEscaped")
end

function P2FP_GrandSniper:GunFireListener()
  EVENT_ActorFiresAnyWeapon("P2FP_GrandSniper.DelayReactions", self, hSab)
end

function P2FP_GrandSniper:DelayReactions()
  EVENT_Timer("P2FP_GrandSniper.VehicleandPassengerReactions", self, 5)
end

function P2FP_GrandSniper:EscalationListener()
  dprint(self, "Setting Escalation Listener...")
  AttractionPt.EnableUse(self.hRadioAttrPt, true)
  self.eEscDetect = EVENT_OnEscalation("P2FP_GrandSniper.TurnOffRadio", self, nil, false)
end

function P2FP_GrandSniper:KillUsePoint()
  dprint(self, "Turning off Radio Use Pt.")
  AttractionPt.EnableUse(self.hRadioAttrPt, false)
end

function P2FP_GrandSniper:TurnOffRadio()
  dprint(self, "Escalated. Setting Deescalation Listener")
  AttractionPt.EnableUse(self.hRadioAttrPt, false)
  self:ResetTaskByName("P2FP_GrandSniper.TASK_GiveConfirmation", true)
  self:TASK_LoseEscalation()
end

function P2FP_GrandSniper:FinishThisMission()
  Util.UnloadStaticENTag("mis_grandsniperProps", true)
  self:CompleteThisMission()
end

function P2FP_GrandSniper:NearRadioCheck()
  self.hRadioProp = Handle(self.PATH .. "wtf_low\\occupation\\OccMed_Radio_Static\\OccMed_Radio_A_Static")
  EVENT_ActorToActorProximity("P2FP_GrandSniper.RadioVO2", self, hSab, self.hRadioProp, 10)
end

function P2FP_GrandSniper:SabNearRadio()
  Cin.PlayConversation("P2FP_GrandSniper_Radio1")
end

function P2FP_GrandSniper:RadioVO2()
  if self:IsMissionTaskActive("P2FP_GrandSniper.TASK_GiveConfirmation") then
    Cin.PlayConversation("P2FP_GrandSniper_Radio2")
  end
end

function P2FP_GrandSniper:RadioVO3()
  if self:IsMissionTaskActive("P2FP_GrandSniper.TASK_GiveConfirmation") then
    Cin.PlayConversation("P2FP_GrandSniper_Radio3")
  end
end

function P2FP_GrandSniper:ShotsFiredCheck()
  EVENT_ActorFiresAnyWeapon("P2FP_GrandSniper.CheckFirstShot", self, hSab)
end

function P2FP_GrandSniper:CheckFirstShot()
  if Util.IsHandleValid(self.hGeneral) == true then
    local targetHealth = Object.GetHealth(self.hGeneral)
    if targetHealth == self.nTargetMaxHealth then
      Cin.PlayConversation("P2FP_GrandSniper_GenMiss")
    elseif targetHealth < self.nTargetMaxHealth then
      Cin.PlayConversation("P2FP_GrandSniper_GenHit")
    end
  elseif Util.IsHandleValid(self.hTargetCollaborator) == false then
    dprint(self, "TARGET HANDLE ISN'T VALID... WHY?")
  end
end

function P2FP_GrandSniper:FailThisMissionNow_Limo()
  self:MissionTaskFail("P2FP_GrandSniper_Text.Fail_TargetEscaped")
end

function P2FP_GrandSniper:FailThisMissionNow_StreamOut()
  self:MissionTaskFail("P2FP_GrandSniper_Text.Fail_TargetEscaped")
end

function P2FP_GrandSniper:FailThisMissionNow_LimoEnd()
  self:MissionTaskFail("P2FP_GrandSniper_Text.Fail_TargetEscaped")
end

function P2FP_GrandSniper:FailLeftMission()
  self:MissionTaskFail("P2FP_GrandSniper_Text.Fail_LeftMission")
end

function P2FP_GrandSniper:Reset()
  Vehicle.EnableTraffic(true)
  Sound.ResetMusicLocale()
end
