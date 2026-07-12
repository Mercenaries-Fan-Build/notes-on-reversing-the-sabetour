if Act_1_Escape == nil then
  Act_1_Escape = SabTaskObjective:Create()
  gsA1Escape = "Missions\\act_1\\Factory\\"
  gsA1_NewEscape = "Missions\\act_1\\escape\\"
  Act_1_Escape:Configure({
    TaskCount = 99,
    bStarterless = true,
    MCDisplayID = 2,
    tUnlockList = {"Act_1_Farm"},
    bDisableMissionTitle = true,
    sSaveMissionNameID = "MissionNames_Text.A1M4b",
    bDelayClean = true,
    tSMEDNodes = {
      gsA1Escape .. "escape",
      gsA1_NewEscape .. "Act1_Escape_Vehicles"
    },
    tStaticTags = {
      "Static_EscapeProps",
      "escape_gate_open"
    }
  })
end

function Act_1_Escape:STARTER_Setup()
  Actor.SetDisguise(hSab, "FBS_RS_Sean_Shirt_Sab_NoHat_NoBag")
  Util.UnloadStaticENTag("civ_saar", true)
  Util.UnloadStaticENTag("nazi_saar", true)
  Util.UnloadStaticENTag("000_German_Border", true)
  Util.UnloadStaticENTag("saarbrucken_gates", true)
  Render.SetGlobalWTF(false)
  Sound.LoadSoundBank("m_A1M4_planes.bnk")
  Render.EnableLightning(true)
  Vehicle.EnableTraffic(false)
end

function Act_1_Escape:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
  self:RegisterCheckpoint("Act_1_Escape.Checkpoint1")
  Actor.SetLabel(hSab, "InRestrictedArea", true)
  EVENT_PlayerEntersTrigger("Act_1_Escape.DelayTextDisplay", self, "Missions\\act_1\\escape\\act1_escape_vehicles\\REG_Delayed_MT")
end

function Act_1_Escape:DelayTextDisplay()
  local v = 1
  if v == 1 then
    HUD.ShowMissionTitle("MissionNames_Text.A1M4b")
    v = 2
  end
end

function Act_1_Escape:GENERAL_Setup()
  self.tSaveInfo.nPoint = 1
  self.tInfo.VehicleBlockerChaseProx = 12
  Suspicion.SetFixedEscalationLevel(2)
  self.tInfo.tCarTargets = {
    "Missions\\act_1\\factory\\escape\\DUM_MissMe_Front",
    "Missions\\act_1\\factory\\escape\\DUM_MissMe_Front2"
  }
  self.tInfo.Motorcycle = "Missions\\act_1\\factory\\escape\\Motorcycle"
  self.tInfo.tSpawnedVehicle = {}
  self.tInfo.tMountedChaserConfig = {
    Pilot = "Human_WM_Grunt",
    Gunner = "Human_WM_Grunt"
  }
  self.tInfo.tKubelChaserConfig = {
    Pilot = "Human_WM_Grunt",
    Shotgun = "Human_WM_Grunt"
  }
  self.tInfo.tOpelConfig = {
    Pilot = "Human_WM_Grunt",
    Gunner = "Human_WM_Grunt"
  }
  Suspicion.EnableEscalation(true)
  Suspicion.EnableEscalationVehicles(false)
  self:AddOnCancelCallback(Act_1_Escape.Reset)
  self:AddOnCompleteCallback(Act_1_Escape.Reset)
  self.tSaveInfo.bCarDead = false
  self.tInfo.tNaziSquad1 = {
    gsA1_NewEscape .. "Act1_Escape_Vehicles\\GooseStepOfficer_01",
    gsA1_NewEscape .. "Act1_Escape_Vehicles\\GooseStepNazi_02",
    gsA1_NewEscape .. "Act1_Escape_Vehicles\\GooseStepNazi_03",
    gsA1_NewEscape .. "Act1_Escape_Vehicles\\GooseStepNazi_07",
    gsA1_NewEscape .. "Act1_Escape_Vehicles\\GooseStepNazi_08",
    gsA1_NewEscape .. "Act1_Escape_Vehicles\\GooseStepNazi_09",
    gsA1_NewEscape .. "Act1_Escape_Vehicles\\GooseStepNazi_10"
  }
  self.tInfo.tNaziSquad2 = {
    gsA1_NewEscape .. "Act1_Escape_Vehicles\\GooseStep02Officer_01",
    gsA1_NewEscape .. "Act1_Escape_Vehicles\\GooseStep02_02",
    gsA1_NewEscape .. "Act1_Escape_Vehicles\\GooseStep02_04",
    gsA1_NewEscape .. "Act1_Escape_Vehicles\\GooseStep02_06",
    gsA1_NewEscape .. "Act1_Escape_Vehicles\\GooseStep02_08"
  }
  self.tInfo.tNaziSquad3 = {
    gsA1_NewEscape .. "Act1_Escape_Vehicles\\Goose_CaravanNorth_01",
    gsA1_NewEscape .. "Act1_Escape_Vehicles\\Goose_CaravanNorth_03",
    gsA1_NewEscape .. "Act1_Escape_Vehicles\\Goose_CaravanNorth_05",
    gsA1_NewEscape .. "Act1_Escape_Vehicles\\Goose_CaravanNorth_07",
    gsA1_NewEscape .. "Act1_Escape_Vehicles\\Goose_CaravanNorth_09"
  }
end

function Act_1_Escape:SetupEvents()
  EVENT_PlayerEntersTrigger("Act_1_Escape.BridgeMove", self, gsA1_NewEscape .. "act1_escape_vehicles\\REG_BridgeMove")
  EVENT_PlayerEntersTrigger("Act_1_Escape.CaravanSpeed", self, gsA1_NewEscape .. "Act1_Escape_Vehicles\\REG_GooseStepTrig_01")
  self:CarSpawnerChaser(gsA1_NewEscape .. "Act1_Escape_Vehicles\\REG_SpawnKubelwagen_02", gsA1_NewEscape .. "Act1_Escape_Vehicles\\LOC_SpawnKubelwagen_04_01", 1)
  self:CarSpawnerChaser(gsA1_NewEscape .. "Act1_Escape_Vehicles\\REG_SpawnKubelwagen_02_1", gsA1_NewEscape .. "Act1_Escape_Vehicles\\LOC_SpawnKubelwagen_02_1_02", 1)
  self:CarSpawnerChaser(gsA1_NewEscape .. "Act1_Escape_Vehicles\\REG_SpawnZBike_01", gsA1_NewEscape .. "Act1_Escape_Vehicles\\LOC_SpawnZKubel_04", 1)
  self:CarSpawnerChaser(gsA1_NewEscape .. "Act1_Escape_Vehicles\\REG_TownCen_SpawnAPC_01", gsA1_NewEscape .. "Act1_Escape_Vehicles\\LOC_Kubel_Cen_01", 1)
  self:CarSpawnerChaser(gsA1_NewEscape .. "Act1_Escape_Vehicles\\REG_LastAlley_VehSpawn_01", gsA1_NewEscape .. "Act1_Escape_Vehicles\\LOC_Opel_SLastAlley_01", 2)
  self:CarSpawnerChaser(gsA1_NewEscape .. "Act1_Escape_Vehicles\\REG_LastAlley_VehSpawn_01", gsA1_NewEscape .. "Act1_Escape_Vehicles\\LOC_Kubel_SLastAlley_01", 1)
  self:CarSpawnerChaser(gsA1_NewEscape .. "Act1_Escape_Vehicles\\REG_LastAlley_VehSpawn_01", gsA1_NewEscape .. "Act1_Escape_Vehicles\\LOC_Kubel_SLastAlley_02", 1)
  self:CarSpawnerChaser(gsA1_NewEscape .. "Act1_Escape_Vehicles\\REG_GooseStepTrig_01", gsA1_NewEscape .. "Act1_Escape_Vehicles\\LOC_Kubel_ExitSarAlley_02", 1)
  self:SetupRocketLauncher(gsA1_NewEscape .. "Act1_Escape_Vehicles\\REG_SpawnKubelwagen_01", gsA1_NewEscape .. "Act1_Escape_Vehicles\\Run_RocketMan_01", hSab, gsA1_NewEscape .. "Act1_Escape_Vehicles\\RunRocket_Target_01", 1)
  self:SetupRocketLauncher(gsA1_NewEscape .. "Act1_Escape_Vehicles\\REG_SpawnKubelwagen_01", gsA1_NewEscape .. "Act1_Escape_Vehicles\\Run_RocketMan_02", hSab, gsA1_NewEscape .. "Act1_Escape_Vehicles\\RunRocket_Target_02", 1)
  self:SetupVehicleBlocker(gsA1_NewEscape .. "Act1_Escape_Vehicles\\REG_SpawnKubelwagen_01", gsA1_NewEscape .. "Act1_Escape_Vehicles\\OpelGun_01_FULL_01", gsA1_NewEscape .. "Act1_Escape_Vehicles\\PTH_OpelGun_01_FULL_01", true, 80)
  self:SetupVehicleBlocker(gsA1_NewEscape .. "Act1_Escape_Vehicles\\REG_NSquare_Ambush06", gsA1_NewEscape .. "Act1_Escape_Vehicles\\OpelGun_Ambush06_01", gsA1_NewEscape .. "Act1_Escape_Vehicles\\PTH_OpelGun_Ambush06_01", false, 30)
  self:SetupVehicleBlocker(gsA1_NewEscape .. "Act1_Escape_Vehicles\\REG_TownCen_SpawnAPC_01", gsA1_NewEscape .. "Act1_Escape_Vehicles\\APC_Cen_02", gsA1_NewEscape .. "Act1_Escape_Vehicles\\PTH_APC_Cen_02", false, 30)
  self:SetupVehicleBlocker(gsA1_NewEscape .. "Act1_Escape_Vehicles\\REG_NCaravan_01", gsA1_NewEscape .. "Act1_Escape_Vehicles\\NCaravan_LVEH_03", gsA1_NewEscape .. "Act1_Escape_Vehicles\\PTH_NCaravan_LVEH", false, 15, 4)
  self:SetupVehicleBlocker(gsA1_NewEscape .. "Act1_Escape_Vehicles\\REG_NCaravan_01", gsA1_NewEscape .. "Act1_Escape_Vehicles\\NCaravan_RVEH_03", gsA1_NewEscape .. "Act1_Escape_Vehicles\\PTH_NCaravan_RVEH", false, 15, 4)
  self:SetupVehicleBlocker(gsA1_NewEscape .. "Act1_Escape_Vehicles\\REG_NCaravan_01", gsA1_NewEscape .. "Act1_Escape_Vehicles\\VEH_ZBike06", gsA1_NewEscape .. "Act1_Escape_Vehicles\\PTH_NCaravan_LVEH", false, 15, 4)
  self:SetupVehicleBlocker(gsA1_NewEscape .. "Act1_Escape_Vehicles\\REG_NCaravan_01", gsA1_NewEscape .. "Act1_Escape_Vehicles\\VEH_ZBike07", gsA1_NewEscape .. "Act1_Escape_Vehicles\\PTH_NCaravan_RVEH", false, 15, 4)
  self:SetupVehicleBlocker(gsA1_NewEscape .. "Act1_Escape_Vehicles\\REG_SpawnKubelwagenJumpN_01", gsA1_NewEscape .. "Act1_Escape_Vehicles\\Jump_Kubelwagen_01", gsA1_NewEscape .. "Act1_Escape_Vehicles\\PTH_Jump_Kubelwagen_01", false, 120, 40)
  self:SetupVehicleBlocker(gsA1_NewEscape .. "Act1_Escape_Vehicles\\REG_AlleyAPCMove_01", gsA1_NewEscape .. "Act1_Escape_Vehicles\\APC_AlleyAPCMove_01", gsA1_NewEscape .. "Act1_Escape_Vehicles\\PTH_APC_AlleyAPCMove_01", false, 30)
  self:SetupVehicleBlocker(gsA1_NewEscape .. "Act1_Escape_Vehicles\\REG_Opel_Alley03_01", gsA1_NewEscape .. "Act1_Escape_Vehicles\\Opel_Alley03_01", gsA1_NewEscape .. "Act1_Escape_Vehicles\\PTH_Opel_Alley03_01", false, 30, 10)
  self:SetupVehicleBlocker(gsA1_NewEscape .. "Act1_Escape_Vehicles\\REG_TownSquareTankMove_01", gsA1_NewEscape .. "Act1_Escape_Vehicles\\TownSquareTankMove_01", gsA1_NewEscape .. "Act1_Escape_Vehicles\\PTH_TownSquareTankMove_01", false, 70)
  self:SetupVehicleBlocker(gsA1_NewEscape .. "Act1_Escape_Vehicles\\REG_TownSquareKubelMove_01", gsA1_NewEscape .. "Act1_Escape_Vehicles\\TownSquareBlock_01", gsA1_NewEscape .. "Act1_Escape_Vehicles\\PTH_TownSquareBlock_01", false, 20)
  self:SetupVehicleBlocker(gsA1_NewEscape .. "Act1_Escape_Vehicles\\REG_VEH_FullZKubel_01", gsA1_NewEscape .. "Act1_Escape_Vehicles\\VEH_FullZKubel_01", gsA1_NewEscape .. "Act1_Escape_Vehicles\\PTH_VEH_FullZKubel_01", true, 60)
  self:SetupVehicleBlocker(gsA1_NewEscape .. "Act1_Escape_Vehicles\\REG_VEH_FullZKubel_01", gsA1_NewEscape .. "Act1_Escape_Vehicles\\VEH_ZBike11", gsA1_NewEscape .. "Act1_Escape_Vehicles\\PTH_VEH_ZBike11", true, 60, 100)
  self:SetupVehicleBlocker(gsA1_NewEscape .. "Act1_Escape_Vehicles\\REG_VEH_FullZKubel_01", gsA1_NewEscape .. "Act1_Escape_Vehicles\\VEH_ZBike10", gsA1_NewEscape .. "Act1_Escape_Vehicles\\PTH_VEH_ZBike10", true, 60, 100)
  self:SetupVehicleBlocker(gsA1_NewEscape .. "Act1_Escape_Vehicles\\TRG_APC_SExitSar_01", gsA1_NewEscape .. "Act1_Escape_Vehicles\\APC_SSar_Am33p_01", gsA1_NewEscape .. "Act1_Escape_Vehicles\\PTH_APC_SSar_Am33p_01", false, 30)
  self:SetupVehicleBlocker(gsA1_NewEscape .. "Act1_Escape_Vehicles\\REG_VEH_ZBike08_09", gsA1_NewEscape .. "Act1_Escape_Vehicles\\VEH_ZBike08", gsA1_NewEscape .. "Act1_Escape_Vehicles\\PTH_VEH_ZBike08", false, 40)
  self:SetupVehicleBlocker(gsA1_NewEscape .. "Act1_Escape_Vehicles\\REG_SpawnZBike_01", gsA1_NewEscape .. "Act1_Escape_Vehicles\\VEH_ZBike01", gsA1_NewEscape .. "Act1_Escape_Vehicles\\PTH_VEH_ZBike01", false, 8, 40)
  self:SetupVehicleBlocker(gsA1_NewEscape .. "Act1_Escape_Vehicles\\REG_SpawnZBike_01", gsA1_NewEscape .. "Act1_Escape_Vehicles\\VEH_ZBike02", gsA1_NewEscape .. "Act1_Escape_Vehicles\\PTH_VEH_ZBike02", false, 8, 40)
  self:SetupVehicleBlocker(gsA1_NewEscape .. "Act1_Escape_Vehicles\\TRG_APC_SExitSar_01", gsA1_NewEscape .. "Act1_Escape_Vehicles\\STank_KingTiger_02", gsA1_NewEscape .. "Act1_Escape_Vehicles\\PTH_STank_KingTiger_02", false, 8, 8)
  self:SetupVehicleBlocker(gsA1_NewEscape .. "Act1_Escape_Vehicles\\TRG_APC_SExitSar_01", gsA1_NewEscape .. "Act1_Escape_Vehicles\\STank_KingTiger_031", gsA1_NewEscape .. "Act1_Escape_Vehicles\\PTH_STank_KingTiger_03", false, 8, 8)
  self:SetupVehicleBlocker(gsA1_NewEscape .. "Act1_Escape_Vehicles\\REG_2ndtoLast2", gsA1_NewEscape .. "Act1_Escape_Vehicles\\VEH_Truck2nd2Last01", gsA1_NewEscape .. "Act1_Escape_Vehicles\\PTH_VEH_Truck2nd2Last01", false, 8, 8)
  self:SetupVehicleBlocker(gsA1_NewEscape .. "Act1_Escape_Vehicles\\REG_2ndtoLast2", gsA1_NewEscape .. "Act1_Escape_Vehicles\\VEH_Truck2nd2Last03", gsA1_NewEscape .. "Act1_Escape_Vehicles\\PTH_VEH_Truck2nd2Last02", false, 8, 8)
  self:SetupVehicleBlocker(gsA1_NewEscape .. "Act1_Escape_Vehicles\\TRG_APC_SExitSar_01", gsA1_NewEscape .. "Act1_Escape_Vehicles\\Kubel_ExitSaarEvent_02", gsA1_NewEscape .. "Act1_Escape_Vehicles\\PTH_Kubel_ExitSaarEvent_02", false, 8, 1)
  self:SetupVehicleBlocker(gsA1_NewEscape .. "Act1_Escape_Vehicles\\TRG_APC_SExitSar_01", gsA1_NewEscape .. "Act1_Escape_Vehicles\\Kubel_ExitSaarEvent_03", gsA1_NewEscape .. "Act1_Escape_Vehicles\\PTH_Kubel_ExitSaarEvent_03", false, 8, 1)
  self:SetupVehicleBlocker(gsA1_NewEscape .. "Act1_Escape_Vehicles\\TRG_APC_SExitSar_01", gsA1_NewEscape .. "Act1_Escape_Vehicles\\Kubel_ExitSaarEvent_backR", gsA1_NewEscape .. "Act1_Escape_Vehicles\\PTH_ExitSaar_Right_01", false, 8, 8)
  self:SetupVehicleBlocker(gsA1_NewEscape .. "Act1_Escape_Vehicles\\TRG_APC_SExitSar_01", gsA1_NewEscape .. "Act1_Escape_Vehicles\\Kubel_ExitSaarEvent_backL", gsA1_NewEscape .. "Act1_Escape_Vehicles\\PTH_ExitSaar_LeftCen_01", false, 8, 8)
  self:SetupVehicleBlocker(gsA1_NewEscape .. "Act1_Escape_Vehicles\\TRG_APC_SExitSar_01", gsA1_NewEscape .. "Act1_Escape_Vehicles\\APC_ExitSaarEvent_02", gsA1_NewEscape .. "Act1_Escape_Vehicles\\PTH_APC_ExitSaarEvent_02", false, 8, 8)
  self:SetupVehicleBlocker(gsA1_NewEscape .. "Act1_Escape_Vehicles\\TRG_APC_SExitSar_01", gsA1_NewEscape .. "Act1_Escape_Vehicles\\APC_ExitSaarEvent_04", gsA1_NewEscape .. "Act1_Escape_Vehicles\\PTH_APC_ExitSaarEvent_04", false, 8, 5)
  self:SetupVehicleBlocker(gsA1_NewEscape .. "Act1_Escape_Vehicles\\TRG_APC_SExitSar_01", gsA1_NewEscape .. "Act1_Escape_Vehicles\\STank_KingTiger_01", gsA1_NewEscape .. "Act1_Escape_Vehicles\\PTH_STank_KingTiger_01", false, 8, 8)
  self:SetupVehicleBlocker(gsA1_NewEscape .. "Act1_Escape_Vehicles\\TRG_APC_SExitSar_01", gsA1_NewEscape .. "Act1_Escape_Vehicles\\Kubel_ExitSaarEvent_05", gsA1_NewEscape .. "Act1_Escape_Vehicles\\PTH_Kubel_ExitSaarEvent_05", false, 8, 8)
  self:SetupVehicleBlocker(gsA1_NewEscape .. "Act1_Escape_Vehicles\\TRG_APC_SExitSar_01", gsA1_NewEscape .. "Act1_Escape_Vehicles\\Kubel_ExitSaarEvent_07", gsA1_NewEscape .. "Act1_Escape_Vehicles\\PTH_Kubel_ExitSaarEvent_07", false, 8, 5)
  self:SetupVehicleBlocker(gsA1_NewEscape .. "Act1_Escape_Vehicles\\TRG_APC_SExitSar_01", gsA1_NewEscape .. "Act1_Escape_Vehicles\\VH_NZ_MO_KS750Sidecar_01", gsA1_NewEscape .. "Act1_Escape_Vehicles\\PTH_VH_NZ_MO_KS750Sidecar_01", false, 8, 8)
  self:SetupVehicleBlocker(gsA1_NewEscape .. "Act1_Escape_Vehicles\\TRG_APC_SExitSar_01", gsA1_NewEscape .. "Act1_Escape_Vehicles\\VH_NZ_MO_KS750Sidecar_03", gsA1_NewEscape .. "Act1_Escape_Vehicles\\PTH_VH_NZ_MO_KS750Sidecar_03", false, 8, 8)
  self:SetupNaziSquad(gsA1_NewEscape .. "Act1_Escape_Vehicles\\REG_SpawnKubelwagen_01", self.tInfo.tNaziSquad1, gsA1_NewEscape .. "Act1_Escape_Vehicles\\PTH_GooseStepNazi_01")
  self:SetupNaziSquad(gsA1_NewEscape .. "Act1_Escape_Vehicles\\REG_GooseStepTrig_01", self.tInfo.tNaziSquad2, gsA1_NewEscape .. "Act1_Escape_Vehicles\\PTH_GooseStep_SaarExit")
  self:SetupNaziSquad(gsA1_NewEscape .. "Act1_Escape_Vehicles\\REG_NCaravan_02", self.tInfo.tNaziSquad3, gsA1_NewEscape .. "Act1_Escape_Vehicles\\PTH_NCaravanGoose01")
end

function Act_1_Escape:Checkpoint1()
  print("CHECKPOINT 1")
  Sound.SetMusicLocale("A1M4_Escape")
  Sound.SetMusicLocale("m_A1M4_Escape", "A1M4_lobbyfight")
  Actor.SetLabel(hSab, "InRestrictedArea", true)
  Sound.PlayOwnerlessSoundEvent("Amb_Veh_SquadronOfPlanes")
  local tStreamEvent = {
    EventType = "StreamEvent",
    EventName = "GateOpenStreamEvent",
    Objects = {
      "CountrySide\\alsace\\german_border\\PSBridge_HydroStation\\PSBridge_HS_Gate_L"
    },
    WaitForGameObject = true,
    WaitForPathfinding = false,
    WaitForPhysics = true,
    WaitForStreamOut = false
  }
  self.GateOpenStreamEvent = Util.CreateEvent(tStreamEvent, "Act_1_Escape.OpenNewGate", self)
  self:RegisterEvent(self.GateOpenStreamEvent)
  EVENT_Stream("Act_1_Escape.SetupVehicleDummyTarget", self, {
    self.tInfo.Motorcycle
  }, false)
  EVENT_PlayerEntersTrigger("Act_1_Escape.JumpsWall", self, "Missions\\act_1\\escape\\act1_escape_vehicles\\REG_JumpsWall")
  Util.UnloadStaticENTag("wpop_doppNazis", true)
  Util.UnloadStaticENTag("Dopp_ClosedDoor", true)
  Util.UnloadStaticENTag("doppel_nazis", true)
  self:Task_GetMotorcycle()
  self:Task_SafetyStart()
  self:Task_GetToBorder()
  self:TASK_Bridge()
  self:SetupEvents()
  Suspicion.SetFixedEscalationLevel(2)
end

function Act_1_Escape:Reset()
  Util.LoadStaticENTag("saarbrucken_gates", false)
  Util.LoadStaticENTag("Dopp_ClosedDoor", false)
  Sound.ReleaseSoundBank("M_A1M4_InGame.bnk")
  Render.Rain(0, 1)
  if self.tInfo.tSpawnedVehicle then
    for i, hVehicle in pairs(self.tInfo.tSpawnedVehicle) do
      Vehicle.AddToTraffic(WRAPPER_CheckForHandle(hVehicle))
    end
  end
  WorldSMEDNodes.UnloadNode("Missions\\act_1\\escape\\escape_lights2")
  Actor.SetLabel(hSab, "InRestrictedArea", false)
  Sound.ResetMusicLocale()
  Util.LoadStaticENTag("nazi_saar", false)
  Util.LoadStaticENTag("civ_saar", false)
end

function Act_1_Escape:SetupVehicleDummyTarget()
  local hParent = Util.GetHandleByName(self.tInfo.Motorcycle)
  for i, Target in pairs(self.tInfo.tCarTargets) do
    local hTarget = Util.GetHandleByName(Target)
    if hTarget and hParent then
      Object.LocatorSetParent(hTarget, hParent)
    else
      print("ERROR:: hTarget or hParent is not valid ", hTarget, Target, hParent, self:GetName())
    end
  end
end

function Act_1_Escape:Task_GetMotorcycle()
  self:CreateTask({
    sName = "Task_GetMotorcycle",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "fetch",
    sObjectiveTextID = "A1M4_Text.Task_GetMotorcycle",
    tDeliverObjs = {
      self.tInfo.Motorcycle
    },
    tOnActivate = {
      {
        Render.Rain,
        {0.3, 0.1}
      }
    },
    tOnVehicleDeath = {
      {
        self.CarDeath,
        {self}
      }
    },
    tOnComplete = {
      {
        self.CheckCar,
        {self}
      },
      {
        Sound.SetMusicLocale,
        {
          "A1M4_Escape"
        }
      },
      {
        Sound.SetMusicLocale,
        {
          "m_A1M4_Escape",
          "A1M4_driving"
        }
      },
      {
        self.SetGPSBorder,
        {self}
      },
      {
        EVENT_ActorDeath,
        {
          "Act_1_Escape.CheckCar",
          self,
          self.tInfo.Motorcycle
        }
      }
    }
  })
end

function Act_1_Escape:CheckCar()
  if self:IsMissionTaskActive("Task_BustGate") then
    self:CompleteTaskByName("Task_BustGate")
    if self:IsMissionTaskActive("Task_SafetyStart") then
      self:CompleteTaskByName("Task_SafetyStart")
    end
    return
  end
  local bInVehicle = Actor.IsInVehicle(hSab)
  local bOnFoot = not bInVehicle
  if not self.tSaveInfo.bCarDead and not bOnFoot then
    self:Task_BustGate()
  end
end

function Act_1_Escape:CarDeath()
  self.tSaveInfo.bCarDead = true
  if self:IsMissionTaskActive("Task_GetMotorcycle") then
    self:CompleteTaskByName("Task_GetMotorcycle")
    self:CompleteTaskByName("Task_SafetyStart")
  end
end

function Act_1_Escape:Task_ParentEscape()
  self:CreateTask({
    sName = "Task_ParentEscape",
    sTaskType = "SabTaskObjectiveEmpty",
    sObjectiveTextID = "A1M4_Text.Task_ParentEscape",
    tOnActivate = {}
  })
end

function Act_1_Escape:Task_GetToBorder()
  self:CreateTask({
    sName = "Task_GetToBorder",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "goto",
    tDestRegion = {
      "Missions\\act_1\\factory\\escape\\REG_Return2FullSpeed"
    },
    tDeliverObjs = {hSab},
    tLocators = {
      "Missions\\act_1\\factory\\escape\\LOC_Border"
    },
    vGPSTarget = "Missions\\act_1\\factory\\escape\\LOC_Border",
    tOnActivate = {},
    tOnComplete = {
      {
        self.StopSlowMotion,
        {self}
      }
    }
  })
end

function Act_1_Escape:Task_BustGate()
  self:CreateTask({
    sName = "Task_BustGate",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "Escape",
    tDestRegion = {
      "Missions\\act_1\\escape\\act1_escape_vehicles\\REG_RedZone"
    },
    tLocators = {
      "Missions\\act_1\\escape\\act1_escape_vehicles\\LOC_Gate"
    },
    tDeliverObjs = {hSab},
    bWorldBlip = true,
    bNoGPS = true,
    sObjectiveTextID = "A1M4_Text.Task_BustGate",
    tOnActivate = {},
    tOnComplete = {}
  })
end

function Act_1_Escape:Task_SafetyStart()
  self:CreateTask({
    sName = "Task_SafetyStart",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "Escape",
    tDestRegion = {
      "Missions\\act_1\\escape\\act1_escape_vehicles\\REG_RedZone"
    },
    tDeliverObjs = {hSab},
    bNoBlips = true,
    tOnActivate = {},
    tOnComplete = {
      {
        self.CompleteTaskByName,
        {
          self,
          "Task_GetMotorcycle"
        }
      },
      {
        self.Task_ParentEscape,
        {self}
      }
    }
  })
end

function Act_1_Escape:Task_TriggerChase()
  self:CreateTask({
    sName = "Task_TriggerChase",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = {
      "Missions\\act_1\\factory\\main\\REG_StartChase"
    },
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        self.ChaseTrigger1,
        {self}
      }
    }
  })
end

function Act_1_Escape:CarSpawnerChaser(sRegion, sLocator, cVehicleConst)
  if not sRegion and not sLocator then
    Util.Assert(false, "Cfrench CarSpawnerChaser failed , incorrect params")
    print("ERROR: CarSpawnerChaser failed, incorrect params")
  end
  EVENT_PlayerEntersTrigger("Act_1_Escape.SpawnMountChaser", self, sRegion, false, {sLocator, cVehicleConst})
end

function Act_1_Escape:SpawnMountChaser(tUserdata, locator, cVehicleConst)
  hLoc = Util.GetHandleByName(locator)
  if not hLoc then
    Util.Assert(false, "Cfrench, a1 escape trying to spawn vehicle on nil locator")
    print("ERROR:a1 escape trying to spawn vehicle on nil locator ", sLocator)
    return
  end
  local cVEHICLE, tVehicleConfig
  if cVehicleConst == 1 then
    cVEHICLE = cVEH_KUBEL
    tVehicleConfig = self.tInfo.tKubelChaserConfig
  else
    cVEHICLE = cVEH_OPEL
    tVehicleConfig = self.tInfo.tOpelConfig
  end
  Veh.SafeSpawnAtObj(cVEHICLE, hLoc, tVehicleConfig, true, Act_1_Escape.FollowHim, self)
end

function Act_1_Escape:FollowHim(hVehicle)
  local hPilot
  if hVehicle then
    table.insert(self.tInfo.tSpawnedVehicle, hVehicle)
    Vehicle.SetCanJoinEscalation(hVehicle, true)
    EVENT_PlayerToActorProximityNegated("Act_1_Escape.RemoveVehicle", self, hVehicle, 250, {hVehicle})
  end
end

function Act_1_Escape:RemoveVehicle(hVehicle)
  if hVehicle then
    print("Despawning ", hVehicle)
    Object.Despawn(hVehicle)
  end
end

function Act_1_Escape:SetupRocketLauncher(sRegion, sSoldier, sTarget, sRunTo, cType)
  if not sRegion and not sSoldier and not sTarget then
    Util.Assert(false, "Cfrench SetupRockerLauncher failed , incorrect params")
    print("ERROR: CarSpawnerChaser failed, incorrect params")
  end
  local hSoldier = WRAPPER_CheckForHandle(sSoldier)
  if hSoldier then
    Combat.SetRespondToEvents(hSoldier, false)
  end
  EVENT_PlayerEntersTrigger("Act_1_Escape.GoRocketLauncher", self, sRegion, false, {
    sSoldier,
    sTarget,
    sRunTo,
    cType
  })
end

function Act_1_Escape:GoRocketLauncher(tUserData, sSoldier, sTarget, sRunTo, cType)
  if not sSoldier and not sSoldier then
    Util.Assert(false, "Cfrench RockerLauncher failed , incorrect params")
    print("ERROR: RockerLauncher failed, incorrect params")
  end
  local hSoldier = WRAPPER_CheckForHandle(sSoldier)
  local hTarget = WRAPPER_CheckForHandle(sTarget)
  if hSoldier and hTarget then
    Combat.SetReactImmediately(hSoldier, true)
    Combat.SetAimAndHitNoMiss(hSoldier, true)
    Combat.SetRespondToEvents(hSoldier, false)
    Suspicion.Enable(hSoldier, false)
    if cType == 1 then
      local hLoc = Util.GetHandleByName(sRunTo)
      Nav.MoveToObject(hSoldier, hLoc, 0.75, true, "Act_1_Escape.FireAtLocator", self, {hSoldier, sTarget})
    elseif cType == 2 then
      Nav.SetScriptedPath(hSoldier, sRunTo, true, "Act_1_Escape.FireAtLocator", self, {hSoldier, sTarget})
      Nav.SetScriptedPathMoveMode(hSoldier, true)
      Nav.SetScriptedPathType(hSoldier, cPATHTYPE_ONCE)
    else
      self:FireAtLocator(hSoldier, sTarget)
    end
  end
end

function Act_1_Escape:FireAtLocator(hSoldier, sTarget)
  if hSoldier and Object.GetHealth(hSoldier) > 0 then
    local hTarget = WRAPPER_CheckForHandle(sTarget)
    Combat.SetAlwaysSeeTarget(hSoldier, true)
    Combat.SetStationary(hSoldier, true)
    Combat.SetReactImmediately(hSoldier, true)
    Combat.SetTarget(hSoldier, hTarget)
    Combat.SetLethalForce(hSoldier, true)
    Combat.SetCombat(hSoldier)
  end
end

function Act_1_Escape:SetupVehicleBlocker(sRegion, sVehicle, sPath, bUnboard, Speed, ChaserActivationDist)
  if not sRegion and not sVehicle and not sPath then
    Util.Assert(false, "Cfrench SetupVehicleBlocker failed , incorrect params")
    print("ERROR: VehicleBlocker failed, incorrect params")
  end
  EVENT_PlayerEntersTrigger("Act_1_Escape.GoVehicleBlocker", self, sRegion, false, {
    sVehicle,
    sPath,
    bUnboard,
    Speed,
    ChaserActivationDist
  })
end

function Act_1_Escape:GoVehicleBlocker(tUserData, sVehicle, sPath, bUnboard, Speed, ChaserActivationDist)
  if not sVehicle and not sPath then
    Util.Assert(false, "Cfrench GoVehicleBlocker failed , incorrect params")
    print("ERROR: GoVehicleBlocker failed, incorrect params")
  end
  local hVehicle = Util.GetHandleByName(sVehicle)
  local ChaserActDist = ChaserActivationDist or self.tInfo.VehicleBlockerChaseProx
  if hVehicle and ChaserActDist then
    EVENT_PlayerToActorProximity("Act_1_Escape.FollowHim", self, hVehicle, ChaserActDist, {hVehicle})
  end
  if hVehicle and sPath then
    Nav.SetScriptedPath(hVehicle, sPath, true, "Act_1_Escape.FinishedPath", self, {hVehicle, bUnboard})
    Nav.SetScriptedPathSpeed(hVehicle, Speed)
    Nav.SetScriptedPathType(hVehicle, cPATHTYPE_ONCE)
  else
    print("no vehicle or path found to block ")
  end
end

function Act_1_Escape:FinishedPath(hVehicle, bUnboard)
  if hVehicle and bUnboard then
    VEHICLE_UnboardAll(hVehicle)
  end
end

function Act_1_Escape:SetupNaziSquad(sRegion, tSquad, sPath)
  if not sRegion and not sPath then
    Util.Assert(false, "Cfrench SetupNaziSquad failed , incorrect params")
    print("ERROR: SetupNaziSquad failed, incorrect params")
  end
  EVENT_PlayerEntersTrigger("Act_1_Escape.MoveNaziSquad", self, sRegion, false, {tSquad, sPath})
end

function Act_1_Escape:MoveNaziSquad(tUserData, tSquad, sPath)
  local NaziFormationID = Nav.CreateFormation()
  for _, Nazi in pairs(tSquad) do
    local hNazi = Util.GetHandleByName(Nazi)
    if hNazi then
      Combat.SetRespondToSound(hNazi, false)
      Combat.SetRespondToEvents(hNazi, false)
      Nav.AddMemberToFormation(NaziFormationID, hNazi)
    end
  end
  Nav.FormationMoveOnPath(NaziFormationID, sPath, cPATHTYPE_ONCE)
end

function Act_1_Escape:BridgeMove()
  local hBridgeobj = Util.GetHandleByName("Missions\\act_1\\escape\\temp_bridgenode\\PSEscape_Bridge")
  Object.Actuate(hBridgeobj)
  Cin.PlayConversation("A1M5_War_Started_01")
end

function Act_1_Escape:OpenNewGate()
  Object.ForceOpen(Util.GetHandleByName("CountrySide\\alsace\\german_border\\PSBridge_HydroStation\\PSBridge_HS_Gate_L"))
end

function Act_1_Escape:CaravanSpeed()
  local hCaravan_01 = Util.GetHandleByName(gsA1_NewEscape .. "Act1_Escape_Vehicles\\Kubel_ExitSaarEvent_07")
  Nav.SetScriptedPathSpeed(hCaravan_01, 1)
end

function Act_1_Escape:TASK_Bridge()
  self:CreateTask({
    sName = "TASK_Bridge",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = {
      "Missions\\act_1\\factory\\escape\\Jumpcin"
    },
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.CheckForCar,
        {self}
      }
    }
  })
end

function Act_1_Escape:CheckForCar()
  local bInVehicle = Actor.IsInVehicle(hSab)
  if bInVehicle then
    print("player is in vehicle")
    EVENT_PlayerEntersTrigger("Act_1_Escape.ENDMISSION", self, gsA1_NewEscape .. "Act1_Escape_Vehicles\\REG_ENDMISSION")
    self:Task_BridgeCin()
  else
    HUD.SetObjectiveMarker(Util.GetHandleByName("Missions\\act_1\\factory\\escape\\LOC_Border2"), cMMI_Objective, cOM_Goto, true, true, true)
    HUD.RemoveObjectiveMarker(Util.GetHandleByName("Missions\\act_1\\factory\\escape\\LOC_Border"))
    print("player is on foot")
  end
end

function Act_1_Escape:Task_BridgeCin()
  self:CreateTask({
    sName = "Task_BridgeCin",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "CIN_A1M3_BridgeEscapeNew",
    tOnActivate = {
      {
        self.StartSlowMotion,
        {self}
      },
      {
        WorldSMEDNodes.LoadNode,
        {
          "Missions\\act_1\\escape\\escape_lights2"
        }
      }
    },
    tOnComplete = {}
  })
end

function Act_1_Escape:StartSlowMotion()
  Sound.PlayOwnerlessSoundEvent("SweetJumpStart")
  Util.SetTimeScale(0.185)
  local hVeh = Actor.GetVehicle(hSab)
  if hVeh then
    Vehicle.SetForceAIController(hVeh, true)
    Vehicle.MakeInvincible(hVeh, true)
    Nav.SetScriptedPath(hVeh, "Missions\\act_1\\factory\\escape\\PATH_PlayerCar", true)
    Nav.SetScriptedPathSpeed(hVeh, 300)
  end
end

function Act_1_Escape:StopSlowMotion()
  Sound.PlayOwnerlessSoundEvent("SweetJumpStop")
  Util.SetTimeScale(1)
  local hVeh = Actor.GetVehicle(hSab)
  if hVeh then
    Vehicle.SetForceAIController(hVeh, false)
    Vehicle.MakeInvincible(hVeh, false)
  else
    self:CompleteThisMission()
    HUD.RemoveObjectiveMarker(Util.GetHandleByName("Missions\\act_1\\factory\\escape\\LOC_Border2"))
  end
end

function Act_1_Escape:StuntJumpSlow()
  Util.SetTimeScale(0.185)
end

function Act_1_Escape:StuntJumpReturn()
  Util.SetTimeScale(1)
end

function Act_1_Escape:SetGPSBorder()
  HUD.SetGPSTarget(2257, -2072)
end

function Act_1_Escape:GrabsOtherVehicle()
  print("Welcome to awesometown")
  if Actor.IsInVehicle(hSab) == true then
    self:CallbackEnteredAVehicle()
  else
    EVENT_PlayerEntersAnyVehicle("Act_1_Escape.CallbackEnteredAVehicle", self)
  end
end

function Act_1_Escape:CallbackEnteredAVehicle()
  print("booyah")
  self:CompleteTaskByName("Task_GetMotorcycle")
end

function Act_1_Escape:JumpsWall()
  self:CompleteTaskByName("Task_GetMotorcycle")
end

function Act_1_Escape:ENDMISSION()
  local hVeh = Actor.GetVehicle(hSab)
  Vehicle.SetForceAIController(hVeh, false)
  self:CompleteThisMission()
end
