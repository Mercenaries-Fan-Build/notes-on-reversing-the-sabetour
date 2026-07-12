if Act_3_Mission_2 == nil then
  Act_3_Mission_2 = SabTaskObjective:Create()
  Act_3_Mission_2.PATH = "Missions\\Act_3\\Mission_2\\"
  Act_3_Mission_2:Configure({
    TaskCount = "auto",
    bStarterless = true,
    sSaveMissionNameID = "MissionNames_Text.A3M2",
    sHQStartPoint = _cHQe_AIRSTRIP,
    sHQNextMissionStartPoint = _cHQ_BELLE,
    tUnlockList = {
      "NOTE_VeroniqueBelle"
    },
    bDisableMissionTitle = true,
    bSLOverrideFade = true,
    tSMEDNodes = {
      Act_3_Mission_2.PATH .. "main",
      Act_3_Mission_2.PATH .. "landingstrip",
      Act_3_Mission_2.PATH .. "Sound",
      "Missions\\act_3\\mission_2\\ExtraEvents"
    },
    tStaticTags = {
      "BattleRoyale",
      "GrandPrix_B",
      "A3M2Props",
      "A3M2Checkpoint",
      "A3M2EiffelProps",
      "A3M2DierkerParty"
    }
  })
end

function Act_3_Mission_2:STARTER_Setup()
  Suspicion.ResetEscalation()
  Util.SetDynamicPriority("VH_CV_CR_TalbotLago_01", 400)
  Util.SpawnEditNode("Missions\\act_3\\mission_2\\SOEGroup.wsd")
  Util.SpawnEditNode("Missions\\act_3\\mission_2\\VeroandCar.wsd")
  Zone.SwitchState("WtF_Zones\\global\\A3M2_DierkerShowdown", cZONESTATE_LOWWTF, cENT_IMMEDIATE)
  OnDisables()
end

function Act_3_Mission_2:Activated()
  SabTaskObjective.Activated(self)
  Util.SetTime(21, 0)
  Sound.LoadSoundBank("m_A3M2_inGame.bnk")
  Sound.LoadSoundBank("vo_m_a3m2_naziscreams.bnk")
  Suspicion.SetFixedEscalationLevel(5)
  Suspicion.EnableEscalationVehicles(false)
  Util.EnableMiniZepShooting(false)
  Combat.SetPlayerTargetPriority(50)
  local hLoc = Handle("Missions\\act_3\\mission_2\\main\\LOC_TeleportConnect")
  Object.PlayerTeleportToLocator(hLoc, false, "Act_3_Mission_2.GENERAL_Setup", self)
  local tPreMisTimer = {EventType = "TimerEvent", Time = 5}
  Util.CreateEvent(tPreMisTimer, "Act_3_Mission_2.Task_LandingCine", self)
end

function Act_3_Mission_2:PlayMissionTitle()
  HUD.ShowMissionTitle("MissionNames_Text.A3M2")
end

function Act_3_Mission_2:WorldSetup()
  Suspicion.EnableEspritDeCorps(false)
  Util.UnloadStaticENTag("RemoveforA3M2", true)
  Util.UnloadStaticENTag("a3m2_mars_sidewalks", true)
  Util.UnloadStaticENTag("000_SHOP_WEAPONS", true)
  Util.UnloadStaticENTag("Garagekeeper_Belle", true)
  Util.DisableShopKeeperBlip("Missions\\freeplay\\garage\\belle_garage\\Spore_RS_Garagekeeper", true)
  Util.UnloadStaticENTag("Garagekeeper_lavillette", true)
  Util.DisableShopKeeperBlip("Missions\\freeplay\\garage\\lavillette_garage\\Spore_RS_Garagekeeper", true)
  Util.UnloadStaticENTag("Garagekeeper_catacombs", true)
  Util.DisableShopKeeperBlip("Missions\\freeplay\\garage\\catacombs_garage\\Spore_RS_Garagekeeper", true)
  Util.UnloadStaticENTag("Garagekeeper_lehavre", true)
  Util.DisableShopKeeperBlip("Missions\\freeplay\\garage\\lehavre_garage\\Spore_RS_Garagekeeper", true)
  Util.UnloadStaticENTag("Garagekeeper_boisdeboulogne", true)
  Util.DisableShopKeeperBlip("Missions\\freeplay\\garage\\boisdeboulogne_garage\\Spore_RS_Garagekeeper", true)
  Util.DisableShopKeeperBlip("Missions\\freeplay\\shopkeepers\\lha\\ShopKeeper_Headnod\\Spore_RS_Shopkeeper_Paris(0)", true)
  Util.DisableShopKeeperBlip("Missions\\freeplay\\shopkeepers\\lna\\ShopKeeper_Headnod(0)\\Spore_RS_Shopkeeper_Paris(0)", true)
  Util.DisableShopKeeperBlip("Missions\\freeplay\\shopkeepers\\p1a\\ShopKeeper_Smoke_A(0)\\Spore_RS_Shopkeeper_Paris(0)", true)
  Util.DisableShopKeeperBlip("Missions\\freeplay\\shopkeepers\\p1b\\ShopKeeper_WallLean(0)\\Spore_RS_Shopkeeper_Paris(0)", true)
  Util.DisableShopKeeperBlip("Missions\\freeplay\\shopkeepers\\p1e\\ShopKeeper_Smoke_A\\Spore_RS_Shopkeeper_Paris", true)
  Util.DisableShopKeeperBlip("Missions\\freeplay\\shopkeepers\\p1h\\ShopKeeper_Smoke_B\\Spore_RS_Shopkeeper_Paris", true)
  Util.DisableShopKeeperBlip("Missions\\freeplay\\shopkeepers\\p1j\\ShopKeeper_Smoke_B\\Spore_RS_Shopkeeper_Paris", true)
  Util.DisableShopKeeperBlip("Missions\\freeplay\\shopkeepers\\p1l\\ShopKeeper_Headnod(3)\\Spore_RS_Shopkeeper_Paris(0)", true)
  Util.DisableShopKeeperBlip("Missions\\freeplay\\shopkeepers\\p2b\\ShopKeeper_Smoke_A\\Spore_RS_Shopkeeper_Paris", true)
  Util.DisableShopKeeperBlip("Missions\\freeplay\\shopkeepers\\p2e\\ShopKeeper_WallLean\\Spore_RS_Shopkeeper_Paris", true)
  Util.DisableShopKeeperBlip("Missions\\freeplay\\shopkeepers\\p2h\\ShopKeeper_WallLean\\Spore_RS_Shopkeeper_Paris", true)
  Util.DisableShopKeeperBlip("Missions\\freeplay\\shopkeepers\\p2i\\ShopKeeper_Smoke_B\\Spore_RS_Shopkeeper_Paris", true)
  Util.DisableShopKeeperBlip("Missions\\freeplay\\shopkeepers\\p3b\\ShopKeeper_Smoke_A\\Spore_RS_Shopkeeper_Paris", true)
  Util.DisableShopKeeperBlip("Missions\\freeplay\\shopkeepers\\p3c\\ShopKeeper_Headnod(0)\\Spore_RS_Shopkeeper_Paris(0)", true)
  Util.DisableShopKeeperBlip("Missions\\freeplay\\shopkeepers\\p3e\\ShopKeeper_Smoke_B\\Spore_RS_Shopkeeper_Paris", true)
  Util.DisableShopKeeperBlip("Missions\\freeplay\\shopkeepers\\p3f\\ShopKeeper_Headnod(3)\\Spore_RS_Shopkeeper_Paris(0)", true)
  Util.DisableShopKeeperBlip("Missions\\freeplay\\shopkeepers\\p3g\\ShopKeeper_WallLean\\Spore_RS_Shopkeeper_Paris(0)", true)
  Util.DisableShopKeeperBlip("Missions\\freeplay\\shopkeepers\\p3i\\ShopKeeper_Headnod(3)\\Spore_RS_Shopkeeper_Paris(0)", true)
  Util.DisableShopKeeperBlip("PARIS\\area01\\lavillette\\interior\\lavillette_int\\Spore_RS_Shopkeeper_HQ", true)
  Util.DisableShopKeeperBlip("PARIS\\area02\\boisdeboulogne\\hq\\boulogne_int\\Spore_RS_Shopkeeper_HQ_BdN", true)
  Util.DisableShopKeeperBlip("PARIS\\area03\\catacombs\\hq\\Spore_RS_Shopkeeper", true)
  Util.DisableShopKeeperBlip("LeHavre\\lehavre_hq\\ShopKeeper_HQ_LH_RubArm\\Spore_RS_Shopkeeper_HQ_LeHavre", true)
  Util.UnloadStaticENTag("marspris", true)
  Util.UnloadStaticENTag("wtf_flags", true)
  Util.LoadStaticENTag("marsdam", true)
end

function Act_3_Mission_2:WorldClear()
  Util.EnableSuperSpores(true)
  Vehicle.EnableTraffic(true)
  Suspicion.EnableEspritDeCorps(true)
  Suspicion.SetFixedEscalationLevel(-1)
  Suspicion.EnableEscalationVehicles(true)
  Util.EnableMiniZepShooting(true)
  Combat.SetPlayerTargetPriority(100)
  Util.LoadStaticENTag("a3m2_mars_sidewalks", true)
  Util.LoadStaticENTag("000_SHOP_WEAPONS", true)
end

function Act_3_Mission_2:GENERAL_Setup()
  self.DEBUGMODE = true
  self.sScotchCar = "Missions\\act_3\\mission_2\\VeroandCar\\VH_CV_CR_TalbotLago_01"
  Util.EnableSuperSpores(false)
  self.sBishop = "Missions\\act_3\\mission_2\\SOEGroup\\Spore_RS_Bishop"
  self.sWilcox = "Missions\\act_3\\mission_2\\SOEGroup\\Spore_RS_Wilcox"
  self.sSOECar = "Missions\\act_3\\mission_2\\SOEGroup\\VH_CV_CR_TalbotLago_01"
  self.sSOEDriveAwayPath = "Missions\\act_3\\mission_2\\SOEGroup\\SOEWalkDriveAwayPath"
  self.sSkylar = "Missions\\act_3\\mission_2\\landingstrip\\Spore_RS_Skylar"
  self.sVeronique = "Missions\\act_3\\mission_2\\VeroandCar\\Spore_RS_Veronique"
  self.tKazes = {}
  self.tKazes[1] = {}
  self.tKazes[1].sName = "Kaze_1"
  self.tKazes[1].vSpawnTarget = Act_3_Mission_2.PATH .. "main\\LOC_Kaze_1"
  self.tKazes[1].cVehicleType = cVEH_OPEL
  self.tKazes[1].tSeatConfig = {
    Pilot = "Human_TS_Trooper_MG",
    Shotgun = "Human_TS_Trooper_MG",
    Passengers = {
      "Human_TS_Trooper_MG",
      "Human_TS_Trooper_MG",
      "Human_TS_Trooper_MG",
      "Human_TS_Trooper_MG"
    }
  }
  self.tKazes[1].bForceSpawn = true
  self.tKazes[1].cDespawnType = cDESPAWN_NONE
  self.tKazes[1].sDeliveryPath = Act_3_Mission_2.PATH .. "main\\PATH_Kaze_1"
  self.tKazes[1].cUnboardType = cDROPOFF_ALL
  self.tKazes[1].nPathSpeed = 60
  self.tKazes[1].tOnUnboard = {
    {
      "Act_3_Mission_2.FightStarter_Ele",
      {"EleNazis"}
    }
  }
  self.tKazes[2] = {}
  self.tKazes[2].sName = "Kaze_2"
  self.tKazes[2].vSpawnTarget = Act_3_Mission_2.PATH .. "main\\LOC_Kaze_2"
  self.tKazes[2].cVehicleType = cVEH_OPEL
  self.tKazes[2].tSeatConfig = "RndHuman_RS_Fighter_Random"
  self.tKazes[2].bForceSpawn = true
  self.tKazes[2].cDespawnType = cDESPAWN_NONE
  self.tKazes[2].sDeliveryPath = Act_3_Mission_2.PATH .. "main\\PATH_Kaze_2"
  self.tKazes[2].cUnboardType = cDROPOFF_NONE
  self.tKazes[2].nPathSpeed = 140
  self.tKazes[2].tOnArrive = {
    {
      "Act_3_Mission_2.KazeCrash"
    }
  }
  self.tKazes[2].tOnSpawn = {
    {
      "Act_3_Mission_2.KazeSetup"
    }
  }
  self.tKazes[3] = {}
  self.tKazes[3].sName = "Checkpoint_Troops"
  self.tKazes[3].vSpawnTarget = Act_3_Mission_2.PATH .. "main\\LOC_Checkpoint_Troops"
  self.tKazes[3].cVehicleType = cVEH_OPEL
  self.tKazes[3].tSeatConfig = {
    Pilot = "Human_SS_Heavy_MG",
    Shotgun = "Human_SS_Heavy_MG",
    Passengers = {
      "Human_SS_Heavy_MG",
      "Human_SS_Heavy_MG",
      "Human_SS_Heavy_MG",
      "Human_SS_Heavy_MG"
    }
  }
  self.tKazes[3].bForceSpawn = true
  self.tKazes[3].cDespawnType = cDESPAWN_NONE
  self.tKazes[3].sDeliveryPath = Act_3_Mission_2.PATH .. "main\\PATH_Checkpoint_Troops"
  self.tKazes[3].cUnboardType = cDROPOFF_ALL
  self.tKazes[3].nPathSpeed = 60
  self.tKazes[3].tOnUnboard = {
    {
      "Act_3_Mission_2.FightStarter",
      {
        "CheckpointNazis"
      }
    }
  }
  self.tKazes[4] = {}
  self.tKazes[4].sName = "Statue_Troops"
  self.tKazes[4].vSpawnTarget = Act_3_Mission_2.PATH .. "main\\LOC_Statue_Troops"
  self.tKazes[4].cVehicleType = cVEH_OPEL
  self.tKazes[4].tSeatConfig = {
    Pilot = "Human_SS_Heavy_MG",
    Shotgun = "Human_SS_Heavy_MG",
    Passengers = {
      "Human_SS_Heavy_MG",
      "Human_SS_Heavy_MG",
      "Human_SS_Heavy_MG",
      "Human_SS_Heavy_MG"
    }
  }
  self.tKazes[4].bForceSpawn = true
  self.tKazes[4].cDespawnType = cDESPAWN_NONE
  self.tKazes[4].sDeliveryPath = Act_3_Mission_2.PATH .. "main\\PATH_Statue_Troops"
  self.tKazes[4].cUnboardType = cDROPOFF_ALL
  self.tKazes[4].nPathSpeed = 60
  self.tKazes[4].tOnUnboard = {
    {
      "Act_3_Mission_2.FightStarter",
      {
        "StatueNazis"
      }
    }
  }
  self.tKazes[5] = {}
  self.tKazes[5].sName = "Statue_Truck1"
  self.tKazes[5].vSpawnTarget = Act_3_Mission_2.PATH .. "main\\LOC_Statue_Truck_1"
  self.tKazes[5].cVehicleType = cVEH_OPEL
  self.tKazes[5].tSeatConfig = {
    Pilot = "RndHuman_RS_Fighter_Random",
    Shotgun = "RndHuman_RS_Fighter_Random",
    Passengers = {
      "RndHuman_RS_Fighter_Random",
      "RndHuman_RS_Fighter_Random",
      "RndHuman_RS_Fighter_Random",
      "RndHuman_RS_Fighter_Random"
    }
  }
  self.tKazes[5].bForceSpawn = true
  self.tKazes[5].cDespawnType = cDESPAWN_NONE
  self.tKazes[5].sDeliveryPath = Act_3_Mission_2.PATH .. "main\\PATH_StatueTruck_2"
  self.tKazes[5].cUnboardType = cDROPOFF_ALL
  self.tKazes[5].nPathSpeed = 60
  self.tKazes[5].tOnUnboard = {
    {
      "Act_3_Mission_2.FightStarter",
      {"StatueRebs"}
    }
  }
  self.tKazes[6] = {}
  self.tKazes[6].sName = "Statue_Truck2"
  self.tKazes[6].vSpawnTarget = Act_3_Mission_2.PATH .. "main\\LOC_Statue_Truck_2"
  self.tKazes[6].cVehicleType = cVEH_OPEL
  self.tKazes[6].tSeatConfig = {
    Pilot = "RndHuman_RS_Fighter_Random",
    Shotgun = "RndHuman_RS_Fighter_Random",
    Passengers = {
      "RndHuman_RS_Fighter_Random",
      "RndHuman_RS_Fighter_Random",
      "RndHuman_RS_Fighter_Random",
      "RndHuman_RS_Fighter_Random"
    }
  }
  self.tKazes[6].bForceSpawn = true
  self.tKazes[6].cDespawnType = cDESPAWN_NONE
  self.tKazes[6].sDeliveryPath = Act_3_Mission_2.PATH .. "main\\PATH_StatueTruck_1"
  self.tKazes[6].cUnboardType = cDROPOFF_ALL
  self.tKazes[6].nPathSpeed = 60
  self.tKazes[6].tOnUnboard = {
    {
      "Act_3_Mission_2.FightStarter_Ele",
      {"EleRebs"}
    }
  }
  self.tKazes[7] = {}
  self.tKazes[7].sName = "Strip_Truck1"
  self.tKazes[7].vSpawnTarget = Act_3_Mission_2.PATH .. "main\\LOC_StripAttackers"
  self.tKazes[7].cVehicleType = cVEH_OPEL
  self.tKazes[7].tSeatConfig = {
    Pilot = "RndHuman_RS_Fighter_Random",
    Shotgun = "RndHuman_RS_Fighter_Random",
    Passengers = {
      "RndHuman_RS_Fighter_Random",
      "RndHuman_RS_Fighter_Random",
      "RndHuman_RS_Fighter_Random",
      "RndHuman_RS_Fighter_Random"
    }
  }
  self.tKazes[7].bForceSpawn = true
  self.tKazes[7].cDespawnType = cDESPAWN_NONE
  self.tKazes[7].sDeliveryPath = Act_3_Mission_2.PATH .. "main\\PATH_CheckpointFighters"
  self.tKazes[7].cUnboardType = cDROPOFF_ALL
  self.tKazes[7].nPathSpeed = 40
  self.tKazes[7].tOnUnboard = {
    {
      "Act_3_Mission_2.FightStarter",
      {
        "CheckpointRebs"
      }
    }
  }
  self.tKazes[8] = {}
  self.tKazes[8].sName = "Ele_Truck"
  self.tKazes[8].vSpawnTarget = Act_3_Mission_2.PATH .. "main\\LOC_Elevator_Rebs"
  self.tKazes[8].cVehicleType = cVEH_OPEL
  self.tKazes[8].tSeatConfig = {
    Pilot = "RndHuman_RS_Fighter_Random",
    Shotgun = "RndHuman_RS_Fighter_Random",
    Passengers = {
      "RndHuman_RS_Fighter_Random",
      "RndHuman_RS_Fighter_Random",
      "RndHuman_RS_Fighter_Random",
      "RndHuman_RS_Fighter_Random"
    }
  }
  self.tKazes[8].bForceSpawn = true
  self.tKazes[8].cDespawnType = cDESPAWN_NONE
  self.tKazes[8].sDeliveryPath = Act_3_Mission_2.PATH .. "main\\PATH_Elevator_Rebs"
  self.tKazes[8].cUnboardType = cDROPOFF_ALL
  self.tKazes[8].nPathSpeed = 50
  self.tKazes[8].tOnUnboard = {
    {
      "Act_3_Mission_2.FightStarter_Ele",
      {"EleRebs"}
    }
  }
  self.sConstCheckpoint = Act_3_Mission_2.PATH .. "main\\PT_ConstCheckpoint"
  self.sFreightElevator = Act_3_Mission_2.PATH .. "main\\PT_FreightElevator"
  self.sTowerLevel_1 = Act_3_Mission_2.PATH .. "main\\PT_Elevator_Checkpoint"
  self.sMarsAttacks = Act_3_Mission_2.PATH .. "main\\PT_TowerLevel_1"
  self.sTowerLevel_1Lift = Act_3_Mission_2.PATH .. "main\\PT_TowerLevel_1Lift"
  self.sTowerLevel_2 = Act_3_Mission_2.PATH .. "main\\PT_TowerLevel_2"
  self.sTowerLevel_Top = Act_3_Mission_2.PATH .. "main\\PT_TowerTop"
  self.sLOC_ConstCheckpoint = Act_3_Mission_2.PATH .. "main\\LOC_ConstCheckpoint"
  self.sLOC_FreightElevator = Act_3_Mission_2.PATH .. "main\\LOC_FreightElevator"
  self.sLOC_TowerLevel_1 = Act_3_Mission_2.PATH .. "main\\LOC_TowerLevel_1"
  self.sLOC_TowerLevel_1Lift = Act_3_Mission_2.PATH .. "main\\LOC_TowerLevel_1Lift"
  self.sLOC_TowerLevel_2 = Act_3_Mission_2.PATH .. "main\\LOC_TowerLevel_2"
  self.sLOC_TowerLevel_Top = Act_3_Mission_2.PATH .. "main\\LOC_TowerLevel_Top"
  self.sPT_EiffelZone = "Missions\\act_3\\mission_2\\main\\PT_TourDEiffel"
  self.bIsOkayToDrop = true
  self.sDierker = Act_3_Mission_2.PATH .. "nazis\\CH_NZ_Dierker"
  self.sPT_NaziWarning = "Missions\\act_3\\mission_2\\main\\PT_NaziWarning"
  self.sExecuteChief = "Missions\\act_3\\mission_2\\level_2\\Spore_TS_Execute_Chief"
  self.sExecuteFlamer = "Missions\\act_3\\mission_2\\level_2\\Spore_TS_Execute_1"
  self.sBillyJoel = "Missions\\act_3\\mission_2\\level_2\\Spore_Piano_SS"
  self.sRoulettePlayer = "Missions\\act_3\\mission_2\\level_2\\Spore_Roulette_SS"
  self.sBartender = "Missions\\act_3\\mission_2\\level_2\\Spore_Roulette_SS"
  self.sDrunkSS = "Missions\\act_3\\mission_2\\level_2\\Spore_Drunk_SS"
  self.sNaziGit = "Missions\\act_3\\mission_2\\level_2\\Spore_Nazis_CallGirl"
  self.sVictim1 = "Missions\\act_3\\mission_2\\level_2\\Spore_SS_KickedOff"
  self.sVictim2 = "Missions\\act_3\\mission_2\\level_2\\Spore_SS_OnFire"
  self.sCancelGPSTrig = "Missions\\act_3\\mission_2\\main\\PT_AbandonGPS"
  self.tWtFHack = {
    "WtF_Zones\\global\\P3M1_Catacombs",
    "WtF_Zones\\global\\FP_OKCoral",
    "WtF_Zones\\global\\A3M1_ParisRace"
  }
  self.WtFHack(self)
  self:AddOnCancelCallback(Act_3_Mission_2.OnCancelComplete)
  self:AddOnCompleteCallback(Act_3_Mission_2.OnCancelComplete)
end

function Act_3_Mission_2:WtFHack()
  for i, v in ipairs(self.tWtFHack) do
    Zone.SwitchState(v, cZONESTATE_HIGHWTF, cENT_NOCHANGE)
  end
end

function Act_3_Mission_2:FightEvents()
  Vehicle.EnableTraffic(false, true)
  self:AddEvent(EVENT_PlayerEntersTrigger("Act_3_Mission_2.TASK_CheckpointFight", self, "Missions\\act_3\\mission_2\\main\\PT_CheckpointFight", false))
  self:AddEvent(EVENT_PlayerEntersTrigger("Act_3_Mission_2.PlayPlaneSulpice", self, "Missions\\act_3\\mission_2\\main\\PT_PlaneSulpice", false))
  self:AddEvent(EVENT_PlayerEntersTrigger("Act_3_Mission_2.GoGoFlyBy2", self, "Missions\\act_3\\mission_2\\main\\PT_NearStatueTrig", false))
  self:AddEvent(EVENT_PlayerEntersTrigger("Act_3_Mission_2.GogoSecondExplosion", self, "Missions\\act_3\\mission_2\\main\\PT_CarSplode", false))
  self:AddEvent(EVENT_PlayerEntersTrigger("Act_3_Mission_2.Planes_1", self, "Missions\\act_3\\mission_2\\main\\PT_Planes_1", false))
  self:AddEvent(EVENT_PlayerEntersTrigger("Act_3_Mission_2.Planes_1Conv", self, "Missions\\act_3\\mission_2\\main\\PT_Planes_1Conv", false))
  self:AddEvent(EVENT_PlayerEntersTrigger("Act_3_Mission_2.TASK_Barracade_Plane", self, "Missions\\act_3\\mission_2\\main\\PT_BarracadeLoad", false))
  self:AddEvent(EVENT_PlayerEntersTrigger("Act_3_Mission_2.Barracade_Plane", self, "Missions\\act_3\\mission_2\\main\\PT_Barracade_Plane", false))
  self:AddEvent(EVENT_PlayerEntersTrigger("Act_3_Mission_2.GoGoBoomGuide1", self, "Missions\\act_3\\mission_2\\main\\PT_SetExplosionGuides", false))
  self:AddEvent(EVENT_PlayerEntersTrigger("Act_3_Mission_2.ExplodeyBoom", self, "Missions\\act_3\\mission_2\\main\\ExplodeBoomTrig", false))
  self:AddEvent(EVENT_PlayerEntersTrigger("Act_3_Mission_2.SetMiniZep", self, "Missions\\act_3\\mission_2\\main\\PT_StartZep", false))
  self:AddEvent(EVENT_PlayerEntersTrigger("Act_3_Mission_2.FireAtZeppy", self, "Missions\\act_3\\mission_2\\main\\FireAtZepTrig", false))
  self:AddEvent(EVENT_PlayerEntersTrigger("Act_3_Mission_2.SetRainGo", self, "Missions\\act_3\\mission_2\\main\\PT_ElevatorFight", false))
  self:AddEvent(EVENT_PlayerEntersTrigger("Act_3_Mission_2.FireNoPartyConv", self, "Missions\\act_3\\mission_2\\main\\PT_FireNoParty", false))
  self:AddEvent(EVENT_PlayerEntersTrigger("Act_3_Mission_2.FireHangingConvo", self, "Missions\\act_3\\mission_2\\main\\PT_TowerLevel_2[1]", false))
  self:AddEvent(EVENT_PlayerEntersTrigger("Act_3_Mission_2.FireTankSeesConvo", self, "Missions\\act_3\\mission_2\\main\\PT_TANKSees", false))
  self:AddEvent(EVENT_PlayerEntersTrigger("Act_3_Mission_2.KaboomSequence2", self, "Missions\\act_3\\mission_2\\main\\PT_LoadTank", false))
  self:AddEvent(EVENT_PlayerEntersTrigger("Act_3_Mission_2.LoadDeadGuys", self, "Missions\\act_3\\mission_2\\main\\PT_DierkerStatue", false))
  self:AddEvent(EVENT_PlayerEntersTrigger("Act_3_Mission_2.PlayMurderSuiConvo", self, "Missions\\act_3\\mission_2\\main\\PT_MurderSuiConvos", false))
  self:AddEvent(EVENT_PlayerEntersTrigger("Act_3_Mission_2.CancelGPS", self, self.sCancelGPSTrig, false))
  self:CrazyNaziStreamEvent()
  Squad.Create("EleNazis")
  Squad.Create("EleRebs")
  Squad.Create("CheckpointNazis")
  Squad.Create("CheckpointRebs")
end

function Act_3_Mission_2:RunwaySetup()
  self.hFireDudeRight = Util.GetHandleByName("Missions\\act_3\\mission_2\\landingstrip\\Spore_RS_Douse_Right")
  self.hFireDudeLeft = Util.GetHandleByName("Missions\\act_3\\mission_2\\landingstrip\\Spore_RS_Douse_Left")
  self.tRunwayFireRight = Tips.GetListFromNames("Missions\\act_3\\mission_2\\landingstrip\\LOC_FireRight_")
  self.tRunwayFireLeft = Tips.GetListFromNames("Missions\\act_3\\mission_2\\landingstrip\\LOC_FireLeft_")
  self.tRunwayDouseRight = Tips.GetListFromNames("Missions\\act_3\\mission_2\\landingstrip\\LOC_DouseRight_")
  self.tRunwayDouseLeft = Tips.GetListFromNames("Missions\\act_3\\mission_2\\landingstrip\\LOC_DouseLeft_")
  self.tRunwayAttPtLeft = Tips.GetListFromNames("Missions\\act_3\\mission_2\\landingstrip\\AttractionPT_DouseLeft_")
  self.tRunwayAttPtRight = Tips.GetListFromNames("Missions\\act_3\\mission_2\\landingstrip\\AttractionPT_DouseRight_")
  for i, v in ipairs(self.tRunwayFireRight) do
    Render.StartFX(v, "0FX_Fire06_Small_Torch", nil)
  end
  for i, v in ipairs(self.tRunwayFireLeft) do
    Render.StartFX(v, "0FX_Fire06_Small_Torch", nil)
  end
  self:AddEvent(EVENT_ActorDeath("Act_3_Mission_2.CarDestroyedConv", self, self.sScotchCar, {
    "A3M2_CarDestroyed_Scotch"
  }, false))
  Object.SetShouldNeverRegisterGameObjectEvents(Handle(self.sScotchCar), true)
end

function Act_3_Mission_2:RunwayShutdown()
  self.RunwayDouseRight(self, 1)
  self.RunwayDouseLeft(self, 1)
end

function Act_3_Mission_2:RunwayDouseRight(a_iIndex)
  local hRunTo = self.tRunwayDouseRight[a_iIndex]
  local a_hAttPt = self.tRunwayAttPtRight[a_iIndex]
  local tDouseSequence = {
    {
      "ISIDLESEQUENCE",
      {true}
    },
    {
      "RUNTOOBJECT",
      {hRunTo}
    },
    {
      "REQUESTATTRPT_NOWAIT",
      {a_hAttPt}
    },
    {
      "DELAYFORRANDOM",
      {3, 8}
    }
  }
  ScriptSequence.Run(self.hFireDudeRight, tDouseSequence, self.DouseFire, {
    self,
    a_iIndex,
    "RIGHT"
  })
end

function Act_3_Mission_2:RunwayDouseLeft(a_iIndex)
  local hRunTo = self.tRunwayDouseLeft[a_iIndex]
  local a_hAttPt = self.tRunwayAttPtLeft[a_iIndex]
  local tDouseSequence = {
    {
      "ISIDLESEQUENCE",
      {true}
    },
    {
      "RUNTOOBJECT",
      {hRunTo}
    },
    {
      "REQUESTATTRPT_NOWAIT",
      {a_hAttPt}
    },
    {
      "DELAYFORRANDOM",
      {3, 8}
    }
  }
  ScriptSequence.Run(self.hFireDudeLeft, tDouseSequence, self.DouseFire, {
    self,
    a_iIndex,
    "LEFT"
  })
end

function Act_3_Mission_2:DouseFire(a_iIndex, a_sSide)
  if a_sSide == "RIGHT" then
    Render.EndFX(self.tRunwayFireRight[a_iIndex], "0FX_Fire06_Small_Torch", nil)
    a_iIndex = a_iIndex + 1
    self:RunwayDouseRight(a_iIndex)
  else
    Render.EndFX(self.tRunwayFireLeft[a_iIndex], "0FX_Fire06_Small_Torch", nil)
    a_iIndex = a_iIndex + 1
    self:RunwayDouseLeft(a_iIndex)
  end
end

function Act_3_Mission_2:AttackersToCheckpoint()
  Veh.SpawnDelivery(self, self.tKazes[7])
end

function Act_3_Mission_2:EnterScotchConv()
  Cin.PlayConversation("A3M2_CarEntered_Scotch")
end

function Act_3_Mission_2:CarDestroyedConv(a_tConv)
  Cin.PlayConversation(a_tConv[1])
end

function Act_3_Mission_2:TASK_CheckpointFight()
  self:CreateTask({
    sName = "TASK_CheckpointFight",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    bCompleteOnActivate = true,
    tSMEDNodes = {
      Act_3_Mission_2.PATH .. "checkpointfight"
    },
    tOnActivate = {
      {
        self.CheckpointFight,
        {self}
      }
    }
  })
end

function Act_3_Mission_2:TASK_Tanks()
  self:CreateTask({
    sName = "TASK_Tanks",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    bCompleteOnActivate = true,
    tSMEDNodes = {
      Act_3_Mission_2.PATH .. "tanks"
    },
    tOnActivate = {
      {
        self.GoTanks,
        {self}
      }
    }
  })
end

function Act_3_Mission_2:GoTanks()
end

function Act_3_Mission_2:TASK_Barracade_Plane()
  self:CreateTask({
    sName = "TASK_Barracade_Plane",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    bCompleteOnActivate = true,
    tSMEDNodes = {
      Act_3_Mission_2.PATH .. "barricade_A"
    },
    tOnActivate = {
      {
        self.Barracade_Plane,
        {self}
      }
    }
  })
end

function Act_3_Mission_2:TASK_StatueFight()
  self:CreateTask({
    sName = "TASK_StatueFight",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    bCompleteOnActivate = true,
    tSMEDNodes = {
      Act_3_Mission_2.PATH .. "statuefight"
    },
    tOnActivate = {
      {
        self.StatueFight,
        {self}
      }
    }
  })
end

function Act_3_Mission_2:TASK_ElevatorFight()
  self:CreateTask({
    sName = "TASK_ElevatorFight",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    bCompleteOnActivate = true,
    tSMEDNodes = {
      Act_3_Mission_2.PATH .. "elevatorfight"
    },
    tOnActivate = {
      {
        self.ElevatorFight,
        {self}
      }
    }
  })
end

function Act_3_Mission_2:ElevatorFight()
  self:PrintDebug("Going Up?")
  self.tEleRebs = Tips.GetListFromNames("Missions\\act_3\\mission_2\\elevatorfight\\Spore_RS_EleFight_")
  self.tEleNazis = Tips.GetListFromNames("Missions\\act_3\\mission_2\\elevatorfight\\Spore_TS_EleFight_")
  for i, v in ipairs(self.tEleRebs) do
    self:FightStarter({v}, "EleRebs")
  end
  for i, v in ipairs(self.tEleNazis) do
    self:FightStarter({v}, "EleNazis")
  end
  self:FightStarter({v}, "EleNazis")
  Squad.SetEnemy("EleNazis", "EleRebs")
  Combat.SetTarget(self.tEleRebs[1], self.tEleNazis[1])
  Combat.SetTarget(self.tEleRebs[2], self.tEleNazis[1])
  Cin.PlayConversation("A3M2_BaseFight_Sees")
  self:AddEvent(EVENT_PlayerEntersTrigger("Act_3_Mission_2.SpawnKaze", self, "Missions\\act_3\\mission_2\\main\\PT_Kaze_1", false, {
    self.tKazes[2]
  }))
  self:AddEvent(EVENT_PlayerEntersTrigger("Act_3_Mission_2.In_Elevator", self, "Missions\\act_3\\mission_2\\main\\PT_InElevator", false))
  Object.SetHealth(Util.GetHandleByName("Missions\\act_3\\mission_2\\elevatorfight\\VH_CV_CR_Citroen7C_01"), 200)
end

function Act_3_Mission_2:SpawnKaze(a_tStuff, a_tKaze)
  self:PrintDebug("Kaze")
  Veh.SpawnDelivery(self, a_tKaze)
end

function Act_3_Mission_2:KazeSetup(a_hCrasher)
  self:AddEvent(EVENT_ActorEntersTrigger("Act_3_Mission_2.KazeCrash", self, a_hCrasher, "Missions\\act_3\\mission_2\\main\\PT_Kaze_Boom"))
end

function Act_3_Mission_2:KazeCrash(a_hCrasher)
  Object.Kill(a_hCrasher)
  Cin.PlayConversation("A3M2_SuicideCar_Sees")
  self:AddEvent(EVENT_PlayerEntersTrigger("Act_3_Mission_2.SpawnKaze", self, "Missions\\act_3\\mission_2\\main\\PT_Elevator_Rebs", false, {
    self.tKazes[8]
  }))
  self:DramaticPause(20, "Act_3_Mission_2.TowerReinforcements")
end

function Act_3_Mission_2:TowerReinforcements()
  Veh.SpawnDelivery(self, self.tKazes[1])
end

function Act_3_Mission_2:In_Elevator()
  self.Tower_Plane(self)
end

function Act_3_Mission_2:Tower_Plane()
  local x, y, z = Object.GetPosition(Util.GetHandleByName("Missions\\act_3\\mission_2\\main\\LOC_Plane3_Target"))
  Util.AddSplinePlaneAttackLocation("Missions\\act_3\\mission_2\\main\\spline_plane3", 100, false, x, y, z)
end

function Act_3_Mission_2:Barracade_Plane()
  self:PrintDebug("He's shooting at the cans!!")
  local x, y, z = Object.GetPosition(Util.GetHandleByName("Missions\\act_3\\mission_2\\barricade_A\\VH_CV_CR_RenaultPolice_01"))
  Util.AddSplinePlaneAttackLocation("Missions\\act_3\\mission_2\\main\\spline_barracadeplane", 100, false, x, y, z)
  self:DramaticPause(5, "Act_3_Mission_2.BlowBarracade")
  self:AddEvent(EVENT_PlayerExitsTrigger("Act_3_Mission_2.BarracadeUnload", self, "Missions\\act_3\\mission_2\\main\\PT_BarracadeLoad", false))
end

function Act_3_Mission_2:BarracadeUnload()
  self:UnloadTaskNodes("TASK_Barracade_Plane", false)
end

function Act_3_Mission_2:BlowBarracade()
  Object.Kill(Util.GetHandleByName("Missions\\act_3\\mission_2\\main\\Squib_BlowBarracade"))
  Cin.PlayConversation("A3M2_Barricade_Explosion")
end

function Act_3_Mission_2:Planes_1()
  self:PrintDebug("planes_1")
  Cin.PlayCinematic("spline_plane1")
  self:UnloadTaskNodes("Task_EnterTower", false)
end

function Act_3_Mission_2:Planes_1Conv()
end

function Act_3_Mission_2:StatueFight()
  self:PrintDebug("Statue Fight")
  self.tStatueRebs = Tips.GetListFromNames("Missions\\act_3\\mission_2\\statuefight\\Spore_RS_StatueFight_")
  self.tStatueNazis = Tips.GetListFromNames("Missions\\act_3\\mission_2\\statuefight\\Spore_SS_StatueFight_")
  Squad.Create("StatueNazis")
  Squad.Create("StatueRebs")
  Squad.SetEnemy("StatueNazis", "StatueRebs")
  for i, v in ipairs(self.tStatueRebs) do
    self:FightStarter({v}, "StatueRebs")
  end
  for i, v in ipairs(self.tStatueNazis) do
    self:FightStarter({v}, "StatueNazis")
  end
  Combat.SetTarget(self.tStatueRebs[1], self.tStatueNazis[1])
  Combat.SetTarget(self.tStatueRebs[4], self.tStatueNazis[4])
  self:AddEvent(EVENT_PlayerEntersTrigger("Act_3_Mission_2.StatueTroops", self, "Missions\\act_3\\mission_2\\main\\PT_Statue_Troops", false))
  self:AddEvent(EVENT_PlayerEntersTrigger("Act_3_Mission_2.StatueTrucks", self, "Missions\\act_3\\mission_2\\main\\PT_StatueTrucks", false))
end

function Act_3_Mission_2:StatueUnload()
  self:UnloadTaskNodes("TASK_StatueFight", true)
end

function Act_3_Mission_2:StatueTroops()
  Veh.SpawnDelivery(self, self.tKazes[4])
  self:AddEvent(EVENT_PlayerExitsTrigger("Act_3_Mission_2.StatueUnload", self, "Missions\\act_3\\mission_2\\main\\PT_StatueFight", false))
  self:AddEvent(EVENT_PlayerEntersTrigger("Act_3_Mission_2.StatueConv", self, "Missions\\act_3\\mission_2\\main\\PT_DierkerStatue", false))
end

function Act_3_Mission_2:StatueTrucks()
  Veh.SpawnDelivery(self, self.tKazes[5])
  Veh.SpawnDelivery(self, self.tKazes[6])
  Util.SpawnEditNode("Missions\\act_3\\mission_2\\truckshooters.wsd", "Act_3_Mission_2.TruckShooters", self)
end

function Act_3_Mission_2:TruckShooters()
  local tTruckShooters = Tips.GetListFromNames("Missions\\act_3\\mission_2\\truckshooters\\Spore_SS_TruckShooter_")
  local tTruckDefenders = Tips.GetListFromNames("Missions\\act_3\\mission_2\\truckshooters\\Spore_RS_TruckDefense_")
  for i, v in ipairs(tTruckShooters) do
    self:FightStarter({v}, "EleNazis")
  end
  for i, v in ipairs(tTruckDefenders) do
    self:FightStarter({v}, "EleRebs")
  end
  Util.UnloadEditNode("Missions\\act_3\\mission_2\\truckshooters.wsd", false)
end

function Act_3_Mission_2:StatueConv()
  if Object.GetHealth(Util.GetHandleByName("PARIS\\area03\\catacombs\\props\\MN_Breteuill_Statue")) < 5 then
    Cin.PlayConversation("A3M2_DierkerStatue_Destroyed")
  else
  end
end

function Act_3_Mission_2:CheckpointFight()
  self:PrintDebug("We Don't Need No Stinking Papers!")
  Object.Kill(Util.GetHandleByName("Missions\\act_3\\mission_2\\checkpointfight\\VH_NZ_CR_Kubelwagen_mount"))
end

function Act_3_Mission_2:CheckpointUnload()
  self:UnloadTaskNodes("TASK_CheckpointFight", true)
end

function Act_3_Mission_2:CheckpointRocket()
  local x, y, z = Object.GetPosition(Util.GetHandleByName("Missions\\act_3\\mission_2\\checkpointfight\\VH_NZ_CR_Kubelwagen_mount(3)"))
  local X, Y, Z = Object.GetPosition(Util.GetHandleByName("Missions\\act_3\\mission_2\\main\\LOC_RocketShot"))
  Util.SpawnRocket("SmallRocket", x, y + 3, z, X, Y, Z)
  Veh.SpawnDelivery(self, self.tKazes[3])
  Cin.PlayConversation("A3M2_StreetChaos_Sees")
end

function Act_3_Mission_2:FightStarter(a_tStuff, a_sSquad)
  local a_hDude = a_tStuff[1]
  Combat.SetIdleHoldWeapon(a_hDude, true)
  Squad.AddMember(a_sSquad, a_hDude)
  Combat.SetReactImmediately(a_hDude, true)
  Combat.SetAlwaysSeeTarget(a_hDude, true)
  Combat.SetLethalForce(a_hDude, true)
  Combat.SetSquadAssist(a_hDude, true)
  Combat.SetCombat(a_hDude)
end

function Act_3_Mission_2:FightStarter_Ele(a_tStuff, a_sSquad)
  local tLoqs = Tips.GetListFromNames("Missions\\act_3\\mission_2\\main\\LOC_EleCover_")
  local a_hDude = a_tStuff[1]
  local i = math.random(1, #tLoqs)
  local tEle_AttackSeq = {
    {
      "ISIDLESEQUENCE",
      {true}
    },
    {
      "DELAYFORRANDOM",
      {0.2, 4}
    },
    {
      "RUNTOOBJECT",
      {
        tLoqs[i]
      },
      3
    }
  }
  Combat.SetIdleHoldWeapon(a_hDude, true)
  Squad.AddMember(a_sSquad, a_hDude)
  ScriptSequence.Run(a_hDude, tEle_AttackSeq, self.FightStarter_Ele2, {self, a_hDude})
end

function Act_3_Mission_2:FightStarter_Ele2(a_hDude)
  Combat.SetReactImmediately(a_hDude, true)
  Combat.SetAlwaysSeeTarget(a_hDude, true)
  Combat.SetLethalForce(a_hDude, true)
  Combat.SetSquadAssist(a_hDude, true)
  Combat.SetCombat(a_hDude)
end

function Act_3_Mission_2:Task_EnterTower()
  self:CreateTask({
    sName = "Task_EnterTower",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "TAXI",
    sObjectiveTextID = "A3M2_Text.GetToTower",
    tDestLocators = {
      "Missions\\act_3\\mission_2\\main\\NearEiffelLoc"
    },
    tPickupProxObj = {
      "Missions\\act_3\\mission_2\\VeroandCar\\Spore_RS_Veronique"
    },
    Proximity = 10,
    tDestRegion = {
      self.sPT_EiffelZone
    },
    tDeliverObjs = {
      "Missions\\act_3\\mission_2\\VeroandCar\\Spore_RS_Veronique"
    },
    bNoCarRequired = true,
    bGroundBlip = true,
    bNoDumping = true,
    tOnEarlyExit = {},
    tOnPickup = {},
    tOnComplete = {
      {
        Sound.DisableAllChatter,
        {}
      },
      {
        self.TASK_PlayAtTowerConvo,
        {self}
      }
    },
    tOnActivate = {
      {
        self.SetGPSWayPoints,
        {self}
      }
    }
  })
end

function Act_3_Mission_2:SetGPSWayPoints()
  local hWayPointObj = Handle("Missions\\act_3\\mission_2\\main\\GPSWaypoint1")
  local x, y, z = Object.GetPosition(hWayPointObj)
  HUD.SetWaypoint(x, z)
end

function Act_3_Mission_2:MoveSOEAway()
  local hBishop = Handle(self.sBishop)
  self.hBishop = hBishop
  local hWilcox = Handle(self.sWilcox)
  self.hWilcox = hWilcox
  local hSOECar = Handle(self.sSOECar)
  self.hSOECar = hSOECar
  local hSkylar = Handle(self.sSkylar)
  local hSkylarSmoke = Handle("Missions\\act_3\\mission_2\\landingstrip\\ATTRPT_CIV_Smoke_PERM(1)")
  Vehicle.LockAllSeats(hSOECar, true)
  Nav.BoardVehicle(hBishop, hSOECar, "SHOTGUN")
  Nav.BoardVehicle(hWilcox, hSOECar, "PILOT")
  EVENT_ActorEntersAnyVehicle("Act_3_Mission_2.OnBishopEntersVehicle", self, self.sBishop)
  Actor.RequestAttrPt(hSkylar, hSkylarSmoke)
end

function Act_3_Mission_2:OnBishopEntersVehicle()
  Nav.SetScriptedPath(self.hSOECar, self.sSOEDriveAwayPath, false, "Act_3_Mission_2.DespawnSOEGroup", self)
  Nav.SetScriptedPathSpeed(self.hSOECar, 35)
end

function Act_3_Mission_2:DespawnSOEGroup()
  Util.UnloadEditNode("Missions\\act_3\\mission_2\\SOEGroup.wsd", true, false)
end

function Act_3_Mission_2:RunExitListener()
  EVENT_PlayerExitsAnyVehicle("Act_3_Mission_2.PlayAtTowerConvo", self)
end

function Act_3_Mission_2:RunSeanandVeroSequence()
  if Actor.IsInVehicle(hSab) == true then
    EVENT_PlayerExitsAnyVehicle("Act_3_Mission_2.TASK_PlayAtTowerConvo", self)
    Actor.UnboardVehicle(hSab)
  else
    self:TASK_PlayAtTowerConvo()
  end
end

function Act_3_Mission_2:TASK_PlayAtTowerConvo()
  Sound.SetMusicLocale("A3M2_Dierker")
  Sound.SetMusicLocale("m_A3M2_Dierker", "arriveAtTower")
  Sound.SetMusicLocale("A3M2_Dierker")
  Sound.SetMusicLocale("m_A3M2_Dierker", "arriveAtTower")
  self:CreateTask({
    sName = "TASK_PlayAtTowerConvo",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "M23_KillDierker_AtTower",
    tOnActivate = {},
    tOnComplete = {
      {
        Util.UnloadEditNode,
        {
          "Missions\\act_3\\mission_2\\VeroandCar.wsd",
          true,
          false
        }
      },
      {
        self.Checkpoint2Setup,
        {self}
      }
    },
    tCinematicNodes = {
      "m23_dierkerkill_attower"
    },
    tSMEDNodes = {}
  })
end

function Act_3_Mission_2:Checkpoint2Setup()
  WorldSMEDNodes.UnloadCinematicNode("m23_dierkerkill_attower", true)
  self.RegisterCheckpoint(self, "Act_3_Mission_2.CheckPoint2")
end

function Act_3_Mission_2:CheckPoint2()
  self.tSaveInfo.bPassingThrough = false
  Sound.SetMusicLocale("A3M2_Dierker")
  Sound.SetMusicLocale("m_A3M2_Dierker", "arriveAtTower")
  Sound.ActivateSoundEmitter(Util.GetHandleByName("missions\\act_3\\mission_2\\sound\\a3m2_piano_player"))
  self:TASK_GotoElevator()
  self:AddEvent(EVENT_PlayerEntersTrigger("Act_3_Mission_2.CheckforClimbing", self, "Missions\\act_3\\mission_2\\main\\PT_Level1Bail", false))
  self:AddEvent(EVENT_PlayerEntersTrigger("Act_3_Mission_2.CheckforHigherClimbing", self, "Missions\\act_3\\mission_2\\main\\PT_Level2Bail", false))
end

function Act_3_Mission_2:FinishNowYo()
  Sound.EnableAllChatter()
  self:CompleteThisMission()
end

function Act_3_Mission_2:DelaytoVeronMove()
  EVENT_Timer("Act_3_Mission_2.MoveVeronTo", self, 1)
end

function Act_3_Mission_2:MoveVeronTo()
  local hVeronique = Handle("Missions\\act_3\\mission_2\\VeroandCar\\Spore_RS_Veronique")
  self.hVeronique = hVeronique
  local hVeronMoveTo = Handle("Missions\\act_3\\mission_2\\main\\VeroMoveTo")
  Nav.MoveToObject(hVeronique, hVeronMoveTo, 3, cMOVE_FAST)
  self:RunSeanandVeroSequence()
  Nav.MoveToObject(hVeronique, hVeronMoveTo, 3, cMOVE_FAST)
end

function Act_3_Mission_2:TASK_PlayVeronConvo()
  OffDisables()
  self:CreateTask({
    sName = "TASK_PlayVeronConvo",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "TALK",
    sObjectiveTextID = "A3M2_Text.TASK_PlayVeronConvo",
    bAutofire = true,
    Proximity = 5,
    sConvFile = "M23_KillDierker_Veronique",
    tTgtInclude = {
      "Missions\\act_3\\mission_2\\VeroandCar\\Spore_RS_Veronique"
    },
    tOnActivate = {},
    tOnComplete = {
      {
        self.Task_EnterTower,
        {self}
      }
    },
    tSMEDNodes = {}
  })
end

function Act_3_Mission_2:WaitForVeronToEnterVeh()
  EVENT_ActorEntersAnyVehicle("Act_3_Mission_2.PlayInCarConvoWithVero", self, "Missions\\act_3\\mission_2\\VeroandCar\\Spore_RS_Veronique")
end

function Act_3_Mission_2:PlayInCarConvoWithVero()
  Cin.PlayConversation("M23_KillDierker_InCar")
end

function Act_3_Mission_2:TASK_GotoElevator()
  self:CreateTask({
    sName = "TASK_GotoElevator",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = {
      self.sTowerLevel_1
    },
    tLocators = {
      self.sLOC_TowerLevel_1
    },
    tDeliverObjs = {hSab},
    sObjectiveTextID = "A3M2_Text.GetToTower",
    tOnActivate = {
      {
        self.FallingNazisCustomEvents,
        {self}
      }
    },
    tOnComplete = {
      {
        self.RegisterCheckpoint,
        {
          self,
          "Act_3_Mission_2.CheckpointTower"
        }
      }
    },
    tSMEDNodes = {}
  })
end

function Act_3_Mission_2:FallingNazisCustomEvents()
  self.sFallingNaziPT1 = "Missions\\act_3\\mission_2\\main\\PT_FallingNazi1"
  self.sFallingNaziPT2 = "Missions\\act_3\\mission_2\\main\\PT_NaziDrop2"
  self.sFallingNaziPT3 = "Missions\\act_3\\mission_2\\main\\PT_NaziDrop3"
  self:AddEvent(EVENT_PlayerEntersTrigger("Act_3_Mission_2.DropNazi1", self, self.sFallingNaziPT1, false))
  self:AddEvent(EVENT_PlayerEntersTrigger("Act_3_Mission_2.DropNazi2", self, self.sFallingNaziPT2, false))
  self:AddEvent(EVENT_PlayerEntersTrigger("Act_3_Mission_2.DropNazi3", self, self.sFallingNaziPT3, false))
end

function Act_3_Mission_2:DropNazi1()
  Util.SpawnEditNode("Missions\\act_3\\mission_2\\Nazidrop1.wsd")
  local tStream1 = {
    EventType = "StreamEvent",
    WaitForGameObject = true,
    Objects = {
      "Missions\\act_3\\mission_2\\Nazidrop1\\Spore_WM_Grunt"
    }
  }
  self:RegisterEvent(Util.CreateEvent(tStream1, "Act_3_Mission_2.OnDropNaz1Spawn", self))
end

function Act_3_Mission_2:OnDropNaz1Spawn()
  local hDropNazi1 = Handle("Missions\\act_3\\mission_2\\Nazidrop1\\Spore_WM_Grunt")
  Actor.SetDistantRagdollSound(hDropNazi1)
  Actor.Ragdoll(hDropNazi1)
end

function Act_3_Mission_2:DropNazi2()
  Util.SpawnEditNode("Missions\\act_3\\mission_2\\Nazidrop2.wsd")
  local tStream2 = {
    EventType = "StreamEvent",
    WaitForGameObject = true,
    Objects = {
      "Missions\\act_3\\mission_2\\Nazidrop2\\Spore_WM_Grunt"
    }
  }
  self:RegisterEvent(Util.CreateEvent(tStream2, "Act_3_Mission_2.OnDropNaz2Spawn", self))
end

function Act_3_Mission_2:OnDropNaz2Spawn()
  local hDropNazi2 = Handle("Missions\\act_3\\mission_2\\Nazidrop2\\Spore_WM_Grunt")
  Actor.SetDistantRagdollSound(hDropNazi2)
  Actor.Ragdoll(hDropNazi2)
end

function Act_3_Mission_2:DropNazi3()
  Util.SpawnEditNode("Missions\\act_3\\mission_2\\Nazidrop3.wsd")
  local tStream3 = {
    EventType = "StreamEvent",
    WaitForGameObject = true,
    Objects = {
      "Missions\\act_3\\mission_2\\Nazidrop3\\Spore_WM_Grunt"
    }
  }
  self:RegisterEvent(Util.CreateEvent(tStream3, "Act_3_Mission_2.OnDropNaz3Spawn", self))
end

function Act_3_Mission_2:OnDropNaz3Spawn()
  local hDropNazi3 = Handle("Missions\\act_3\\mission_2\\Nazidrop3\\Spore_WM_Grunt")
  Actor.SetDistantRagdollSound(hDropNazi3)
  Actor.Ragdoll(hDropNazi3)
end

function Act_3_Mission_2:GoVeroniqueFollower()
  local hVeronique = Handle("Missions\\act_3\\mission_2\\VeroandCar\\Spore_RS_Veronique")
  self.hVeronique = hVeronique
end

function Act_3_Mission_2:CheckpointTower()
  self.tSaveInfo.bPassingThrough = true
  Sound.ActivateSoundEmitter(Util.GetHandleByName("missions\\act_3\\mission_2\\sound\\a3m2_piano_player"))
  self:AddEvent(EVENT_PlayerEntersTrigger("Act_3_Mission_2.FireNaziWarningConv", self, self.sPT_NaziWarning, false))
  self:WatchTheSuicide()
  self:TASK_UseElevator1()
end

function Act_3_Mission_2:TASK_UseElevator1()
  self:CreateTask({
    sName = "TASK_UseElevator1",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = {
      "Missions\\act_3\\mission_2\\main\\PT_SecondFloor"
    },
    tLocators = {
      "Missions\\act_3\\mission_2\\main\\LOC_2ndFloor"
    },
    tDeliverObjs = {hSab},
    sObjectiveTextID = "A3M2_Text.TASK_UseElevator1",
    tSMEDNodes = {
      Act_3_Mission_2.PATH .. "mars_attacks",
      Act_3_Mission_2.PATH .. "level_1"
    },
    tOnActivate = {},
    tOnComplete = {
      {
        self.TASK_GotoElevator2,
        {self}
      }
    }
  })
end

function Act_3_Mission_2:TASK_GotoElevator2()
  self:CreateTask({
    sName = "TASK_GotoElevator2",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = {
      "Missions\\act_3\\mission_2\\main\\PT_2ndEle"
    },
    tLocators = {
      "Missions\\act_3\\mission_2\\main\\LOC_Elevator2"
    },
    tDeliverObjs = {hSab},
    sObjectiveTextID = "A3M2_Text.TASK_GotoElevator2",
    tOnActivate = {},
    tOnComplete = {
      {
        self.Task_ClimbHigher,
        {self}
      }
    }
  })
end

function Act_3_Mission_2:Task_ClimbHigher()
  self:CreateTask({
    sName = "Task_ClimbHigher",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = {
      self.sTowerLevel_1Lift
    },
    tLocators = {
      self.sLOC_TowerLevel_1Lift
    },
    tDeliverObjs = {hSab},
    sObjectiveTextID = "A3M2_Text.AscendSecond",
    tOnActivate = {},
    tOnComplete = {
      {
        self.Task_ToBar,
        {self}
      }
    }
  })
end

function Act_3_Mission_2:LoadMars()
  self:AddEvent(EVENT_PlayerEntersTrigger("Act_3_Mission_2.MarsAttack", self, self.sMarsAttacks, false))
end

function Act_3_Mission_2:MarsAttack()
  Object.Kill(Util.GetHandleByName("Missions\\act_3\\mission_2\\mars_attacks\\Squib_Mars"))
  self.tGSSnipers = Tips.GetListFromNames("Missions\\act_3\\mission_2\\level_1\\Spore_GS_Sniper_")
  self.tSnipeSpots = Tips.GetListFromNames("Missions\\act_3\\mission_2\\main\\LOC_Sniper_")
  for i, v in ipairs(self.tGSSnipers) do
    local tSnipeSequence = {
      {
        "ISIDLESEQUENCE",
        {true}
      },
      {
        "DELAYFORRANDOM",
        {0.2, 4}
      },
      {
        "RUNTOOBJECT",
        {
          self.tSnipeSpots[i]
        }
      }
    }
  end
  self:AddEvent(EVENT_PlayerEntersTrigger("Act_3_Mission_2.SpawnBody", self, "Missions\\act_3\\mission_2\\main\\PT_BodyDrop", false))
  self:AddEvent(EVENT_PlayerEntersTrigger("Act_3_Mission_2.SpawnBody2", self, "Missions\\act_3\\mission_2\\main\\PT_BodyDrop2", false))
  self:DramaticPause(4, "Act_3_Mission_2.TowerRocket")
  self:DramaticPause(7, "Act_3_Mission_2.TowerRocket2")
end

function Act_3_Mission_2:TowerRocket()
  local x, y, z = Object.GetPosition(Util.GetHandleByName("Missions\\act_3\\mission_2\\main\\LOC_TowerRocket_Start"))
  local X, Y, Z = Object.GetPosition(Util.GetHandleByName("Missions\\act_3\\mission_2\\main\\LOC_TowerRocket_Target"))
  Util.SpawnRocket("SmallRocket", x, y, z, X, Y, Z)
end

function Act_3_Mission_2:TowerRocket2()
  local x, y, z = Object.GetPosition(Util.GetHandleByName("Missions\\act_3\\mission_2\\main\\LOC_TowerRocket_Start2"))
  local X, Y, Z = Object.GetPosition(Util.GetHandleByName("Missions\\act_3\\mission_2\\main\\LOC_TowerRocket_Target2"))
  Util.SpawnRocket("SmallRocket", x, y, z, X, Y, Z)
end

function Act_3_Mission_2:SpawnBody()
  Util.SpawnEditNode("Missions\\act_3\\mission_2\\bodydrop.wsd", "Act_3_Mission_2.BodyDrop", self, {
    "Missions\\act_3\\mission_2\\bodydrop\\Spore_Body_1"
  })
end

function Act_3_Mission_2:SpawnBody2()
  Util.SpawnEditNode("Missions\\act_3\\mission_2\\bodydrop2.wsd", "Act_3_Mission_2.BodyDrop", self, {
    "Missions\\act_3\\mission_2\\bodydrop2\\Spore_Body_2"
  })
end

function Act_3_Mission_2:SpawnBody_Top()
  Util.SpawnEditNode("Missions\\act_3\\mission_2\\bodydrop_top.wsd", "Act_3_Mission_2.BodyDrop", self, {
    "Missions\\act_3\\mission_2\\bodydrop_top\\Spore_Body_Top"
  })
end

function Act_3_Mission_2:BodyDrop(a_sBody)
  if a_sBody == "Missions\\act_3\\mission_2\\bodydrop\\Spore_Body_1" then
    self:AddEvent(EVENT_ActorEntersTrigger("Act_3_Mission_2.BodyTalk", self, a_sBody, "Missions\\act_3\\mission_2\\main\\PT_BodyDrop"))
  end
  local hBody = Util.GetHandleByName(a_sBody)
  local e = Util.CreateEvent({
    EventType = "StreamEvent",
    WaitForGameObject = true,
    Objects = {hBody}
  }, "Act_3_Mission_2.KillBody", self, {hBody})
  self:AddEvent(e)
end

function Act_3_Mission_2:KillBody(a_hBody)
  Actor.Ragdoll(a_hBody)
end

function Act_3_Mission_2:BodyTalk()
  Render.StartFX(Util.GetHandleByName("Missions\\act_3\\mission_2\\main\\LOC_BodySplat"), "0FX_Blood05_Large_Burst", nil)
  Cin.PlayConversation("A3M2_BodyDrop_Sees")
end

function Act_3_Mission_2:DummyShoot(a_hDude, a_i)
  local hHandle = a_hDude
  local hTarget
  if a_i <= 6 then
    hTarget = WRAPPER_CheckForHandle("Missions\\act_3\\mission_2\\level_1\\DummyTarget_Mars")
  else
    hTarget = WRAPPER_CheckForHandle("Missions\\act_3\\mission_2\\level_1\\DummyTarget_Mars2")
  end
  Combat.SetReactImmediately(hHandle, true)
  Combat.SetAimAndHitNoMiss(hHandle, true)
  Combat.SetRespondToEvents(hHandle, false)
  Combat.SetAlwaysSeeTarget(hHandle, true)
  Combat.SetStationary(hHandle, true)
  Combat.LockIntoRanged(hHandle)
  Combat.SetTarget(hHandle, hTarget)
  Combat.SetLethalForce(hHandle, true)
  Combat.SetCombat(hHandle)
end

function Act_3_Mission_2:Task_ToBar()
  self:CreateTask({
    sName = "Task_ToBar",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = {
      self.sTowerLevel_2
    },
    tLocators = {
      self.sLOC_TowerLevel_2
    },
    tDeliverObjs = {hSab},
    sObjectiveTextID = "A3M2_Text.GoToBar",
    tSMEDNodes = {
      Act_3_Mission_2.PATH .. "level_2"
    },
    tOnActivate = {
      {
        self.SetupBar,
        {self}
      },
      {
        self.SetupExecution,
        {self}
      }
    },
    tOnComplete = {
      {
        self.Task_Elevator3,
        {self}
      }
    }
  })
end

function Act_3_Mission_2:Task_Elevator3()
  self:CreateTask({
    sName = "Task_Elevator3",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = {
      "Missions\\act_3\\mission_2\\main\\PT_Elevator3"
    },
    tLocators = {
      "Missions\\act_3\\mission_2\\main\\LOC_Elevator3"
    },
    tDeliverObjs = {hSab},
    sObjectiveTextID = "A3M2_Text.Task_Elevator3",
    tOnActivate = {},
    tOnComplete = {
      {
        Cin.LoadCinematic,
        {
          "411_CinA_Tower-DierkerStart"
        }
      },
      {
        self.Task_ToObservation,
        {self}
      }
    }
  })
end

function Act_3_Mission_2:Task_ToObservation()
  self:CreateTask({
    sName = "Task_ToObservation",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = {
      self.sTowerLevel_Top
    },
    tLocators = {
      self.sLOC_TowerLevel_Top
    },
    tDeliverObjs = {hSab},
    sObjectiveTextID = "A3M2_Text.ObservationDeck",
    tOnActivate = {},
    tOnComplete = {
      {
        Render.Rain,
        {0, 1}
      },
      {
        self.NodeLoadToDStart,
        {self}
      }
    }
  })
end

function Act_3_Mission_2:NodeLoadToDStart()
  if Actor.IsInVehicle(hSab) == true then
    Actor.UnboardVehicle(hSab)
  else
  end
  Util.SpawnCinematicNode("411cinprops", "Act_3_Mission_2.Task_TowerCinematic", self)
end

function Act_3_Mission_2:Task_TowerCinematic()
  self:CreateTask({
    sName = "Task_TowerCinematic",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "411_CinA_Tower-DierkerStart",
    tCinematicNodes = {
      "411_cina_tower"
    },
    bOverrideFade = true,
    tOnActivate = {},
    tOnComplete = {
      {
        self.CompleteTaskByName,
        {
          self,
          "TASK_TheEnd"
        }
      },
      {
        self.LoadDeadOfficer,
        {self}
      },
      {
        self.UnloadSomeTaskCin,
        {self}
      }
    }
  })
end

function Act_3_Mission_2:LoadDeadOfficer()
  Util.SpawnEditNode("Missions\\act_3\\mission_2\\411DeadOfficer.wsd", "Act_3_Mission_2.SetDeathDelay", self)
end

function Act_3_Mission_2:SetDeathDelay()
  EVENT_Timer("Act_3_Mission_2.Task_KillDierker", self, 2)
end

function Act_3_Mission_2:UnloadSomeTaskCin()
  WorldSMEDNodes.UnloadCinematicNode("411_cina_tower", true)
end

function Act_3_Mission_2:Task_DierkerKilledCine()
  Actor.ExitSpecialKillMode()
  self:CreateTask({
    sName = "Task_DierkerKilledCine",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "411_CinA_Tower-DierkerKilled",
    bOverrideFade = true,
    tOnActivate = {
      {
        Util.KillEvent,
        {
          self.eDierkerSpared
        }
      }
    },
    tOnComplete = {
      {
        WorldSMEDNodes.UnloadCinematicNode,
        {
          "412_cinb_dierkerdead",
          true
        }
      },
      {
        self.LoadCredits,
        {self}
      }
    },
    tCinematicNodes = {
      "412_cinb_dierkerdead"
    },
    tSMEDNodes = {
      "Missions\\act_3\\mission_2\\towerveronique"
    }
  })
end

function Act_3_Mission_2:LoadCredits()
  Sound.UnloadSoundBank("m_A3M2_inGame.bnk")
  Sound.UnloadSoundBank("vo_m_a3m2_naziscreams.bnk")
  Util.LoadDynamicNode("end_credits", "Act_3_Mission_2.TASK_Credits", self)
end

function Act_3_Mission_2:MISSION_ONRESET()
  if Util.IsBlockLoaded("FranceEditNodesMissionsAct_3Mission_2level_1.wsd") then
    Util.UnloadEditNode("FranceEditNodesMissionsAct_3Mission_2level_1.wsd", true)
  end
  if Util.IsBlockLoaded("Missions\\Act_3\\Mission_2\\main.wsd") then
    Util.UnloadEditNode("Missions\\Act_3\\Mission_2\\main.wsd", true)
  end
  if Util.IsBlockLoaded("Missions\\Act_3\\Mission_2\\Sound.wsd") then
    Util.UnloadEditNode("Missions\\Act_3\\Mission_2\\Sound.wsd", true)
  end
  if Util.IsBlockLoaded("Missions\\Act_3\\Mission_2\\checkpointfight.wsd") then
    Util.UnloadEditNode("Missions\\Act_3\\Mission_2\\checkpointfight.wsd", true)
  end
  if Util.IsBlockLoaded("Missions\\Act_3\\Mission_2\\mars_attacks.wsd") then
  end
  if Util.IsBlockLoaded("Missions\\act_3\\mission_2\\ExtraEvents.wsd") then
    Util.UnloadEditNode("Missions\\act_3\\mission_2\\ExtraEvents.wsd", true)
  end
  if Util.IsBlockLoaded("Missions\\Act_3\\Mission_2\\landingstrip.wsd") then
    Util.UnloadEditNode("Missions\\Act_3\\Mission_2\\landingstrip.wsd", true)
  end
  if Util.IsBlockLoaded("Missions\\Act_3\\Mission_2\\DeadLikeMe.wsd") then
    Util.UnloadEditNode("Missions\\Act_3\\Mission_2\\DeadLikeMe.wsd", true)
  end
  if Util.IsBlockLoaded("Missions\\Act_3\\Mission_2\\level_2.wsd") then
    Util.UnloadEditNode("Missions\\Act_3\\Mission_2\\level_2.wsd", true)
  end
  if Util.IsBlockLoaded("Missions\\act_3\\mission_2\\AreaFights.wsd") then
    Util.UnloadEditNode("Missions\\act_3\\mission_2\\AreaFights.wsd", true)
  end
  Sound.UnloadSoundBank("m_A3M2_inGame.bnk")
  Sound.UnloadSoundBank("vo_m_a3m2_naziscreams.bnk")
  Sound.ResetMusicLocale()
  Suspicion.EnableEscalation(true)
  Suspicion.EnableGlobal(true)
  self:WorldClear()
  Util.LoadStaticENTag("Garagekeeper_Belle", true)
  Util.DisableShopKeeperBlip("Missions\\freeplay\\garage\\belle_garage\\Spore_RS_Garagekeeper", false)
  Util.LoadStaticENTag("Garagekeeper_lavillette", true)
  Util.DisableShopKeeperBlip("Missions\\freeplay\\garage\\lavillette_garage\\Spore_RS_Garagekeeper", false)
  Util.LoadStaticENTag("Garagekeeper_catacombs", true)
  Util.DisableShopKeeperBlip("Missions\\freeplay\\garage\\catacombs_garage\\Spore_RS_Garagekeeper", false)
  Util.LoadStaticENTag("Garagekeeper_lehavre", true)
  Util.DisableShopKeeperBlip("Missions\\freeplay\\garage\\lehavre_garage\\Spore_RS_Garagekeeper", false)
  Util.LoadStaticENTag("Garagekeeper_boisdeboulogne", true)
  Util.DisableShopKeeperBlip("Missions\\freeplay\\garage\\boisdeboulogne_garage\\Spore_RS_Garagekeeper", false)
  Util.DisableShopKeeperBlip("Missions\\freeplay\\shopkeepers\\lha\\ShopKeeper_Headnod\\Spore_RS_Shopkeeper_Paris(0)", false)
  Util.DisableShopKeeperBlip("Missions\\freeplay\\shopkeepers\\lna\\ShopKeeper_Headnod(0)\\Spore_RS_Shopkeeper_Paris(0)", false)
  Util.DisableShopKeeperBlip("Missions\\freeplay\\shopkeepers\\p1a\\ShopKeeper_Smoke_A(0)\\Spore_RS_Shopkeeper_Paris(0)", false)
  Util.DisableShopKeeperBlip("Missions\\freeplay\\shopkeepers\\p1e\\ShopKeeper_Smoke_A\\Spore_RS_Shopkeeper_Paris", false)
  Util.DisableShopKeeperBlip("Missions\\freeplay\\shopkeepers\\p1b\\ShopKeeper_WallLean(0)\\Spore_RS_Shopkeeper_Paris(0)", false)
  Util.DisableShopKeeperBlip("Missions\\freeplay\\shopkeepers\\p1h\\ShopKeeper_Smoke_B\\Spore_RS_Shopkeeper_Paris", false)
  Util.DisableShopKeeperBlip("Missions\\freeplay\\shopkeepers\\p1j\\ShopKeeper_Smoke_B\\Spore_RS_Shopkeeper_Paris", false)
  Util.DisableShopKeeperBlip("Missions\\freeplay\\shopkeepers\\p1l\\ShopKeeper_Headnod(3)\\Spore_RS_Shopkeeper_Paris(0)", false)
  Util.DisableShopKeeperBlip("Missions\\freeplay\\shopkeepers\\p2b\\ShopKeeper_Smoke_A\\Spore_RS_Shopkeeper_Paris", false)
  Util.DisableShopKeeperBlip("Missions\\freeplay\\shopkeepers\\p2e\\ShopKeeper_WallLean\\Spore_RS_Shopkeeper_Paris", false)
  Util.DisableShopKeeperBlip("Missions\\freeplay\\shopkeepers\\p2h\\ShopKeeper_WallLean\\Spore_RS_Shopkeeper_Paris", false)
  Util.DisableShopKeeperBlip("Missions\\freeplay\\shopkeepers\\p2i\\ShopKeeper_Smoke_B\\Spore_RS_Shopkeeper_Paris", false)
  Util.DisableShopKeeperBlip("Missions\\freeplay\\shopkeepers\\p3b\\ShopKeeper_Smoke_A\\Spore_RS_Shopkeeper_Paris", false)
  Util.DisableShopKeeperBlip("Missions\\freeplay\\shopkeepers\\p3c\\ShopKeeper_Headnod(0)\\Spore_RS_Shopkeeper_Paris(0)", false)
  Util.DisableShopKeeperBlip("Missions\\freeplay\\shopkeepers\\p3e\\ShopKeeper_Smoke_B\\Spore_RS_Shopkeeper_Paris", false)
  Util.DisableShopKeeperBlip("Missions\\freeplay\\shopkeepers\\p3f\\ShopKeeper_Headnod(3)\\Spore_RS_Shopkeeper_Paris(0)", false)
  Util.DisableShopKeeperBlip("Missions\\freeplay\\shopkeepers\\p3g\\ShopKeeper_WallLean\\Spore_RS_Shopkeeper_Paris(0)", false)
  Util.DisableShopKeeperBlip("Missions\\freeplay\\shopkeepers\\p3i\\ShopKeeper_Headnod(3)\\Spore_RS_Shopkeeper_Paris(0)", false)
  Util.DisableShopKeeperBlip("PARIS\\area01\\lavillette\\interior\\lavillette_int\\Spore_RS_Shopkeeper_HQ", false)
  Util.DisableShopKeeperBlip("PARIS\\area02\\boisdeboulogne\\hq\\boulogne_int\\Spore_RS_Shopkeeper_HQ_BdN", false)
  Util.DisableShopKeeperBlip("PARIS\\area03\\catacombs\\hq\\Spore_RS_Shopkeeper", false)
  Util.DisableShopKeeperBlip("LeHavre\\lehavre_hq\\ShopKeeper_HQ_LH_RubArm\\Spore_RS_Shopkeeper_HQ_LeHavre", false)
end

function Act_3_Mission_2:TASK_Credits()
  self:CreateTask({
    sName = "TASK_Credits",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "Credit_Splines",
    tOnActivate = {},
    tOnComplete = {
      {
        Sound.EnableAllChatter,
        {}
      },
      {
        Util.SpawnEditNode,
        {
          "Missions\\act_3\\mission_2\\DeadDierker.wsd"
        }
      },
      {
        self.CompleteThisMission,
        {self}
      }
    },
    tSMEDNodes = {
      "Missions\\cinematics\\credits"
    },
    tStaticTags = {}
  })
end

function Act_3_Mission_2:DierkerSparedCheck()
  self.eDierkerSpared = EVENT_PlayerEntersTrigger("Act_3_Mission_2.Task_DierkerSparedCine", self, "Missions\\act_3\\mission_2\\main\\PT_DierkerSpared", false)
  self:AddEvent(self.eDierkerSpared)
end

function Act_3_Mission_2:Task_DierkerSparedCine()
  self:CreateTask({
    sName = "Task_DierkerSparedCine",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "411_CinA _Tower-DierkerSpared",
    tOnActivate = {},
    tOnComplete = {
      {
        self.CompleteThisMission,
        {self}
      }
    }
  })
end

function Act_3_Mission_2:ElevatorStall()
  Cin.PlayConversation("A3M2_Elevator_Stops")
end

function Act_3_Mission_2:SetupExecution()
  Suspicion.EnableEscalation(false, true)
  Suspicion.EnableGlobal(false)
  self:AddEvent(EVENT_PlayerEntersTrigger("Act_3_Mission_2.NearPiano", self, "Missions\\act_3\\mission_2\\main\\PT_NearPiano", false))
  self:AddEvent(EVENT_PlayerEntersTrigger("Act_3_Mission_2.CommentRoulette", self, "Missions\\act_3\\mission_2\\main\\PT_Roulette_Conv", false))
end

function Act_3_Mission_2:Execute1()
  local hExecuteChief = Util.GetHandleByName(self.sExecuteChief)
  Util.CreateExecutionScene(hExecuteChief, {
    Util.GetHandleByName(self.sVictim1)
  }, cEXECUTION_ONEBYONE_STANDING)
  self:DramaticPause(3, "Act_3_Mission_2.RoastEm")
  self:DramaticPause(1, "Act_3_Mission_2.Execute2")
end

function Act_3_Mission_2:Execute2()
  Util.CreateExecutionScene(Util.GetHandleByName("Missions\\act_3\\mission_2\\level_2\\Spore_TS_Executor_1"), self.tGroupicute, cEXECUTION_ONEBYONE_STANDING)
end

function Act_3_Mission_2:ExecuteOver()
  for i, v in ipairs(self.tExecutors) do
    Combat.SetIdleScripted(v, false)
    Combat.SetRespondToEvents(v, true)
    Combat.SetRespondToSound(v, true)
    Combat.SetRespondToDamage(v, true)
    Combat.SetSquadAssist(v, true)
  end
  for i, v in ipairs(self.tGroupicute) do
    local a_Delay = math.random(2, 5)
    local e = Util.CreateEvent({EventType = "TimerEvent", Time = a_Delay}, "Act_3_Mission_2.FightBack", self, {v})
    self:AddEvent(e)
  end
end

function Act_3_Mission_2:FightBack(h_Dude)
  local iCoin = math.random(1, 4)
  if iCoin == 1 then
    Squad.AddMember("Groupicute", h_Dude)
    Combat.SetIdleScripted(h_Dude, false)
    Combat.SetRespondToEvents(h_Dude, true)
    Combat.SetRespondToSound(h_Dude, true)
    Combat.SetRespondToDamage(h_Dude, true)
    Combat.SetSquadAssist(h_Dude, true)
    Combat.SetCombat(h_Dude)
    Object.SetHealth(h_Dude, 20)
  else
    local a_Delay = math.random(5, 15)
    local e = Util.CreateEvent({EventType = "TimerEvent", Time = a_Delay}, "Act_3_Mission_2.FightBack", self, {h_Dude})
    self:AddEvent(e)
  end
end

function Act_3_Mission_2:ChuckEm()
  Combat.DoMeleeMove(self.hExecuteChief, "gr_lapel_throw_front", Util.GetHandleByName(self.sVictim1), true)
  self:DramaticPause(3, "Act_3_Mission_2.RoastEm")
end

function Act_3_Mission_2:RoastEm()
  Actor.CancelAttrPt(Util.GetHandleByName(self.sVictim2))
  Actor.FireCurrentWeapon(Util.GetHandleByName(self.sExecuteFlamer), 3)
end

function Act_3_Mission_2:ToBarConv()
  Cin.PlayConversation("A3M2_Bar_GoTo")
end

function Act_3_Mission_2:SetupBarDudes(a_hActor)
  if Combat.IsCombatant(a_hActor) == true then
    Combat.SetIdleScripted(a_hActor, true)
    Combat.SetRespondToEvents(a_hActor, false)
    Combat.SetRespondToSound(a_hActor, false)
    Combat.SetRespondToDamage(a_hActor, false)
    Combat.SetSquadAssist(a_hActor, false)
  end
end

function Act_3_Mission_2:SetupBarStream()
  local tBarGnats = {
    "Missions\\act_3\\mission_2\\level_2\\Spore_GS_GeneralShow",
    "Missions\\act_3\\mission_2\\level_2\\Spore_Nazis_CallGirl(2)",
    self.sBillyJoel,
    self.sRoulettePlayer,
    self.sNaziGit,
    "PARIS\\area05\\eifeltower\\props\\Spore_Drunk_SS(7)"
  }
  local tBarStream = {
    EventType = "StreamEvent",
    Objects = tBarGnats
  }
  self.eBarStreamStuff = Util.CreateEvent(tBarStream, "Act_3_Mission_2.SetupBar", self)
end

function Act_3_Mission_2:SetupBar()
  self.hNaziMurder = Util.GetHandleByName("Missions\\act_3\\mission_2\\level_2\\Spore_GS_GeneralShow")
  self.hVictimGirl = Util.GetHandleByName("Missions\\act_3\\mission_2\\level_2\\Spore_Nazis_CallGirl(2)")
  self.hBillyJoel = Util.GetHandleByName(self.sBillyJoel)
  local tBarFlys = {
    {
      Util.GetHandleByName(self.sBillyJoel)
    },
    {
      Util.GetHandleByName(self.sRoulettePlayer)
    },
    {
      Util.GetHandleByName(self.sNaziGit)
    },
    {
      Util.GetHandleByName("PARIS\\area05\\eifeltower\\props\\Spore_Drunk_SS(7)")
    },
    {
      self.hNaziMurder
    },
    {
      self.hVictimGirl
    }
  }
  Inventory.GiveItem(Util.GetHandleByName(self.sRoulettePlayer), "WP_PS_MAS_Revolver", true)
  Inventory.GiveItem(Util.GetHandleByName("Missions\\act_3\\mission_2\\level_2\\Spore_GS_GeneralShow"), "WP_PS_MAS_Revolver", true)
  local hRoulettePlayer = Handle(self.sRoulettePlayer)
  if hRoulettePlayer then
    Combat.SetGrabbable(hRoulettePlayer, false)
    Actor.SetNonKnockdownable(hRoulettePlayer, true)
    Actor.SetLabel(hRoulettePlayer, "nopush", true)
    Actor.SetUseHitReactions(hRoulettePlayer, false)
  end
  for i, v in ipairs(tBarFlys) do
    self:SetupBarDudes(v)
  end
  Actor.RequestAttrPt(Util.GetHandleByName(self.sRoulettePlayer), Util.GetHandleByName("Missions\\act_3\\mission_2\\main\\AttractionPt_Russian_Roulette"))
  local tPianoManEvent = {
    EventType = "DeathEvent",
    ObjectHandle = Util.GetHandleByName(self.sBillyJoel)
  }
  local tSingUsASong = {
    EventType = "DamageEvent",
    ObjectHandle = Util.GetHandleByName(self.sBillyJoel),
    MinDamage = 10
  }
  self.ePianoDeath = self:RegisterEvent(Util.CreateEvent(tPianoManEvent, "Act_3_Mission_2.CantStopTheMusic", self))
  self.ePianoDamage = self:RegisterEvent(Util.CreateEvent(tSingUsASong, "Act_3_Mission_2.CantStopTheMusic", self))
  local sWipe1 = "Missions\\act_3\\mission_2\\main\\AttractionPT_Bar_wipe(1)"
  local sWipe2 = "Missions\\act_3\\mission_2\\main\\AttractionPT_Bar_wipe"
  local nDefaultDelay = 10
  local tJumpLabels = {"A", "B"}
  local tMurderSequence = {
    {
      "ISIDLESEQUENCE",
      {true}
    },
    {
      "PLAYANIMATION",
      {
        "nazi_murder_idle"
      }
    },
    {
      "DELAY",
      {1}
    },
    {"STARTOVER"}
  }
  ScriptSequence.Run(Handle("Missions\\act_3\\mission_2\\level_2\\Spore_GS_GeneralShow"), tMurderSequence)
end

function Act_3_Mission_2:CantStopTheMusic()
  if self.ePianoDeath then
    Util.KillEvent(self.ePianoDeath)
  end
  if self.ePianoDamage then
    Util.KillEvent(self.ePianoDamage)
  end
  Sound.DeactivateSoundEmitter(Util.GetHandleByName("missions\\act_3\\mission_2\\sound\\a3m2_piano_player"))
end

function Act_3_Mission_2:WatchTheSuicide()
  EVENT_ActorEntersTrigger("Act_3_Mission_2.FinishMurderSui", self, hSab, "Missions\\act_3\\mission_2\\main\\PT_MurderSui")
end

function Act_3_Mission_2:FinishMurderSui()
  ScriptSequence.Kill(self.hNaziMurder)
  local tSuicideSequence = {
    {
      "ISIDLESEQUENCE",
      {true}
    },
    {
      "PLAYANIMATION",
      {
        "nazi_murder"
      }
    },
    {
      "FUNCTION",
      {
        self.KillVictimGirl,
        {self}
      }
    },
    {
      "DELAY",
      {6}
    },
    {
      "FUNCTION",
      {
        self.KillNaziSelf,
        {self}
      }
    }
  }
  ScriptSequence.Run(self.hNaziMurder, tSuicideSequence)
end

function Act_3_Mission_2:KillVictimGirl()
  Object.Kill(self.hVictimGirl)
end

function Act_3_Mission_2:KillNaziSelf()
  Object.Kill(self.hNaziMurder)
end

function Act_3_Mission_2:NearPiano()
  Cin.PlayConversation("A3M2_PianoPlayer_Near")
end

function Act_3_Mission_2:NearRoulette()
  Cin.PlayConversation("A3M2_Tower_RoulettePlayer_Nazi_01", "Act_3_Mission_2.CommentRoulette", self)
end

function Act_3_Mission_2:CommentRoulette()
  Cin.PlayConversation("A3M2_RoulettePlayer_Sees")
end

function Act_3_Mission_2:Task_KillDierker()
  self:CreateTask({
    sName = "Task_KillDierker",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "KILL",
    tTgtInclude = {
      "Missions\\act_3\\mission_2\\dierker\\CH_NZ_Dierker"
    },
    sObjectiveTextID = "A3M2_Text.KillDierker",
    bNoWorldBlip = true,
    bNoHUDBlip = true,
    tOnActivate = {
      {
        Render.FadeScreen,
        {false}
      },
      {
        self.RunDierkerCam,
        {self}
      },
      {
        self.DelaytoStartDierkerLoop,
        {self}
      }
    },
    tOnComplete = {
      {
        self.BridgeToUnloadDierker,
        {self}
      },
      {
        self.BridgetoKillCine,
        {self}
      }
    },
    tSMEDNodes = {
      "Missions\\act_3\\mission_2\\dierker",
      "Missions\\act_3\\mission_2\\DierkerGun"
    }
  })
end

function Act_3_Mission_2:BridgetoKillCine()
  EVENT_Timer("Act_3_Mission_2.Task_DierkerKilledCine", self, 2)
end

function Act_3_Mission_2:BridgeToUnloadDierker()
  EVENT_Timer("Act_3_Mission_2.UnloadDierker", self, 5)
end

function Act_3_Mission_2:UnloadDierker()
  Util.UnloadEditNode("Missions\\act_3\\mission_2\\dierker.wsd", true, false)
end

function Act_3_Mission_2:DelaytoStartDierkerLoop()
  EVENT_Timer("Act_3_Mission_2.StartDierkerConvoLoop", self, 3)
end

function Act_3_Mission_2:StartDierkerConvoLoop()
  if Object.IsAlive(Handle("Missions\\act_3\\mission_2\\dierker\\CH_NZ_Dierker")) == true then
    Cin.PlayConversation("A3M2_DierkerTaunt_Armed")
    EVENT_Timer("Act_3_Mission_2.PlayNextLoop", self, 7)
  else
  end
end

function Act_3_Mission_2:PlayNextLoop()
  if Object.IsAlive(Handle("Missions\\act_3\\mission_2\\dierker\\CH_NZ_Dierker")) == true then
    Cin.PlayConversation("A3M2_DierkerTaunt_Armed")
  else
  end
end

function Act_3_Mission_2:RunDierkerCam()
  local hPistol = Handle("Missions\\act_3\\mission_2\\dierker\\WP_PS_DierkerGun")
  local hDierkerKill = Handle("Missions\\act_3\\mission_2\\dierker\\CH_NZ_Dierker")
  self.hDierkerKill = hDierkerKill
  Actor.EnterSpecialKillMode(Handle("Missions\\act_3\\mission_2\\dierker\\CH_NZ_Dierker"), hPistol, 40)
  Actor.PlayAnimation(hDierkerKill, "Dierker_Final", -1, false, nil, nil, self, nil, false, nil, true)
  EVENT_Timer("Act_3_Mission_2.DeirkerSuicide", self, 16)
end

function Act_3_Mission_2:DeirkerSuicide()
  if Object.IsAlive(self.hDierkerKill) then
    Object.Kill(self.hDierkerKill)
  else
  end
end

function Act_3_Mission_2:Task_LandingCine()
  self:CreateTask({
    sName = "Task_LandingCine",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    tOnActivate = {
      {
        Render.FadeScreen,
        {false, 0}
      }
    },
    tOnComplete = {
      {
        self.RegisterCheckpoint,
        {
          self,
          "Act_3_Mission_2.Checkpoint1"
        }
      }
    }
  })
end

function Act_3_Mission_2:Checkpoint1()
  Sound.SetMusicLocale("A3M2_Dierker")
  Sound.SetMusicLocale("m_A3M2_Dierker", "Drive")
  Util.SetOverrideLoadScreenFadeIn(false)
  Render.FadeScreen(false, 0)
  self:LoadFightZones()
  EVENT_Timer("Act_3_Mission_2.TASK_ConvoDelayed", self, 0.1)
end

function Act_3_Mission_2:TASK_ConvoDelayed()
  self:CreateTask({
    sName = "TASK_ConvoDelayed",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "TALK",
    bAutofire = true,
    bUseOldAutofire = true,
    Proximity = 100,
    sConvFile = "M23_KillDierker_Start",
    tTgtInclude = {
      self.sBishop
    },
    tOnActivate = {},
    tOnComplete = {
      {
        self.CalltoSet,
        {self}
      }
    },
    tSMEDNodes = {}
  })
end

function Act_3_Mission_2:CalltoSet()
  self:PlayMissionTitle()
  self:WorldSetup(self)
  self:MoveSOEAway(self)
  self:TASK_PlayVeronConvo(self)
  self:FightEvents(self)
  self:RunwaySetup(self)
  self:WaitForVeronToEnterVeh(self)
end

function Act_3_Mission_2:ConvPlayer(a_sConvFile, a_Delay)
  self:PrintDebug(a_sConvFile)
  local e = Util.CreateEvent({EventType = "TimerEvent", Time = a_Delay}, "Act_3_Mission_2.ConvPlayerDelay", self, {a_sConvFile})
end

function Act_3_Mission_2:ConvPlayerDelay(a_sConvFile)
  self:PrintDebug(a_sConvFile)
  Cin.PlayConversation(a_sConvFile)
end

function Act_3_Mission_2:ElevatorManager()
  self:PrintDebug("Listen 4 Elevators")
  self.eElevatorListen = Util.CreateEvent({
    EventType = "OnActivated",
    Target = Util.GetHandleByName(self.sElevatorFloor0)
  }, "Act_3_Mission_2.ElevatorActivated", self)
end

function Act_3_Mission_2:ElevatorActivated()
  self:PrintDebug("Going.. somewhere")
end

function Act_3_Mission_2:AddEvent(a_eEvent)
  if not self.tEvents then
    self.tEvents = {}
  end
  table.insert(self.tEvents, a_eEvent)
end

function Act_3_Mission_2:ClearEvents()
  if self.tEvents then
    for i, e in ipairs(self.tEvents) do
      Util.KillEvent(e)
    end
    self.tEvents = {}
  end
end

function Act_3_Mission_2:FailedConv(a_sConv, a_sFailString)
  Cin.PlayConversation(a_sConv, "Act_3_Mission_2.Failed", self, {a_sFailString})
end

function Act_3_Mission_2:Failed(a_tBlah, a_sFailString)
  self:ClearEvents()
  self:MissionTaskFail(a_sFailString)
end

function Act_3_Mission_2:DramaticPause(a_nTime, a_sCallbackFunction)
  self:AddEvent(EVENT_Timer(a_sCallbackFunction, self, a_nTime))
end

function Act_3_Mission_2:PrintDebug(a_sMessage)
  if self.DEBUGMODE == true then
    Render.PrintMessage(a_sMessage)
  end
end

function Act_3_Mission_2:StartFiringRange()
  local tTargets = {
    "Missions\\act_3\\mission_2\\landingstrip\\DummyTarget",
    "Missions\\act_3\\mission_2\\landingstrip\\DummyTarget(1)"
  }
  local tShooters = {
    "Missions\\act_3\\mission_2\\landingstrip\\Spore_RS_LS_3(11)",
    "Missions\\act_3\\mission_2\\landingstrip\\Spore_RS_LS_3(13)"
  }
  for i = 1, #tShooters do
    local hShooter = Handle(tShooters[i])
    local hTarget = Handle(tTargets[i])
    Combat.SetBroadcastWeaponFire(hShooter, false)
    Combat.SetBroadcastEnteredCombat(hShooter, false)
    Combat.SetReactImmediately(hShooter, false)
    Combat.LockIntoRanged(hShooter)
    Combat.SetTarget(hShooter, hTarget)
    Combat.SetAlwaysSeeTarget(hShooter, true)
    Combat.SetStationary(hShooter, true)
    Combat.SetCombat(hShooter)
    Actor.FireCurrentWeapon(hShooter, 180)
  end
end

function Act_3_Mission_2:GoGoBoomGuide1()
  local sExpSpot = "Missions\\act_3\\mission_2\\main\\Locator"
  local sExpSpot2 = "Missions\\act_3\\mission_2\\main\\Locator(2)"
  Joe.SpawnExplosiononObject(sExpSpot, 2)
  Joe.SpawnExplosiononObject(sExpSpot2, 3)
end

function Act_3_Mission_2:SpawnPreCheckGroup()
  Util.SpawnEditNode("Missions\\act_3\\mission_2\\CheckpointPreFight.wsd", "Act_3_Mission_2.GoStreamCheckGroup", self)
end

function Act_3_Mission_2:GoStreamCheckGroup()
  Render.PrintMessage("PrecheckpointObjectsLoaded")
  local tPreCheckObjs = {
    "Missions\\act_3\\mission_2\\CheckpointPreFight\\Spore_RS_Fighter_MG(4)",
    "Missions\\act_3\\mission_2\\CheckpointPreFight\\Spore_RS_Fighter_MG",
    "Missions\\act_3\\mission_2\\CheckpointPreFight\\Spore_RS_Fighter_MG(2)",
    "Missions\\act_3\\mission_2\\CheckpointProps\\DummyTarget(1)",
    "Missions\\act_3\\mission_2\\CheckpointProps\\DummyTarget"
  }
  local tCheckpointStreamObjs = {
    EventType = "StreamEvent",
    Objects = tPreCheckObjs
  }
  Util.CreateEvent(tCheckpointStreamObjs, "Act_3_Mission_2.GoPreCheckPointGroup", self)
end

function Act_3_Mission_2:GoPreCheckPointGroup()
  Render.PrintMessage("PrecheckpointObjectsStreamed")
  local tPreCheckGroup = {
    "Missions\\act_3\\mission_2\\CheckpointPreFight\\Spore_RS_Fighter_MG(4)",
    "Missions\\act_3\\mission_2\\CheckpointPreFight\\Spore_RS_Fighter_MG",
    "Missions\\act_3\\mission_2\\CheckpointPreFight\\Spore_RS_Fighter_MG(2)"
  }
  local tPreCheckTargets = {
    "Missions\\act_3\\mission_2\\CheckpointProps\\DummyTarget(1)",
    "Missions\\act_3\\mission_2\\CheckpointProps\\DummyTarget"
  }
  for i = 1, #tPreCheckGroup do
    local hResFighter = Handle(tPreCheckGroup[i])
    Joe.SetEnemyOfTheState(hResFighter, "A3M2PreCheck")
  end
end

function Act_3_Mission_2:StartFallingNazis()
  local tDropPoints = {
    "Missions\\act_3\\mission_2\\main\\Locator(8)",
    "Missions\\act_3\\mission_2\\main\\Locator(1)",
    "Missions\\act_3\\mission_2\\main\\Locator(4)",
    "Missions\\act_3\\mission_2\\main\\Locator(6)",
    "Missions\\act_3\\mission_2\\main\\Locator(11)",
    "Missions\\act_3\\mission_2\\main\\Locator(9)",
    "Missions\\act_3\\mission_2\\main\\Locator(13)",
    "Missions\\act_3\\mission_2\\main\\Locator(15)",
    "Missions\\act_3\\mission_2\\main\\Locator(17)",
    "Missions\\act_3\\mission_2\\main\\Locator(19)",
    "Missions\\act_3\\mission_2\\main\\Locator(21)",
    "Missions\\act_3\\mission_2\\main\\Locator(23)",
    "Missions\\act_3\\mission_2\\main\\Locator(25)",
    "Missions\\act_3\\mission_2\\main\\Locator(7)"
  }
  local sDropLoc = tDropPoints[math.random(1, #tDropPoints)]
  self.SpawnDudeinAir(self, sDropLoc)
  self.eNaziDropLoop = EVENT_Timer("Act_3_Mission_2.StartFallingNazis", self, 6)
end

function Act_3_Mission_2:SpawnDudeinAir(a_sLocator)
  if self.bIsOkayToDrop == true then
    local hLocator = Handle(a_sLocator)
    local x, y, z = Object.GetPosition(hLocator)
    Object.Spawn("Spore_WM_Grunt_MG", x, y, z, 0, nil, "Act_3_Mission_2.KillSpawnedDude", self)
  else
  end
end

function Act_3_Mission_2:StopNaziDrops()
  Util.KillEvent(self.eNaziDropLoop)
  self.bIsOkayToDrop = false
end

function Act_3_Mission_2:KillSpawnedDude(a_hDude)
  local hFallingNazi = a_hDude[1]
  Actor.SetDistantRagdollSound(hFallingNazi)
  Actor.Ragdoll(hFallingNazi)
end

function Act_3_Mission_2:TASK_TheEnd()
  self:CreateTask({
    sName = "TASK_TheEnd",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    sObjectiveTextID = "A3M2_Text.TASK_EndThis",
    tSMEDNodes = {},
    tOnActivate = {}
  })
end

function Act_3_Mission_2:LoadFightZones()
  Util.SpawnEditNode("Missions\\act_3\\mission_2\\AreaFights.wsd")
end

function Act_3_Mission_2:LoadDeadGuys()
end

function Act_3_Mission_2:StreamCarsForDeath()
  local tCarDeathStream = {
    EventType = "StreamEvent",
    EventName = "tCarDeathStream",
    Objects = {
      "Missions\\act_3\\mission_2\\checkpointfight\\VH_CV_CR_CeltaQuatre_01(9)"
    }
  }
  Util.CreateEvent(tCarDeathStream, "Act_3_Mission_2.OnDeathCar1Streams", self)
end

function Act_3_Mission_2:OnDeathCar1Streams()
  Render.PrintMessage("Death Car 1 Streamed, should die now")
  local hDeathCar = Handle("Missions\\act_3\\mission_2\\checkpointfight\\VH_CV_CR_CeltaQuatre_01(9)")
  Object.Kill(hDeathCar)
end

function Act_3_Mission_2:PlayPlaneSulpice()
  Util.AddSplinePlaneAttackObject("Missions\\act_3\\mission_2\\main\\PlaneStSulpice", 1, false, hSab, false, 1, "a", nil, nil, "VH_OP_ME109_SPLINE")
  EVENT_Timer("Act_3_Mission_2.GoGoFlyBy1", self, 2.5)
end

function Act_3_Mission_2:GogoSecondExplosion()
  local sExSpott1 = "Missions\\act_3\\mission_2\\main\\CarsplodeLoc"
  Joe.SpawnExplosiononObject(sExSpott1, 2)
end

function Act_3_Mission_2:GogoPlaneExplosion()
  local sPlanExSpot1 = "Missions\\act_3\\mission_2\\main\\PlaneSplodeLoc"
  Joe.SpawnExplosiononObject(sPlanExSpot1, 3, "Explosion_Large_Oil")
end

function Act_3_Mission_2:GoGoFlyBy1()
  Util.AddSplinePlaneAttackObject("Missions\\act_3\\mission_2\\main\\SulpiceFlyBy", 1, false, hSab, false, 1, "a", nil, nil, "VH_OP_ME109_SPLINE")
end

function Act_3_Mission_2:GoGoFlyBy2()
  Util.AddSplinePlaneAttackObject("Missions\\act_3\\mission_2\\main\\StatueFlyWing", 1, false, hSab, false, 1, "a", nil, nil, "VH_OP_ME109_SPLINE")
  Util.AddSplinePlaneAttackObject("Missions\\act_3\\mission_2\\main\\StatueFlyBy", 1, false, hSab, false, 1, "a", nil, nil, "VH_OP_ME109_SPLINE")
end

function Act_3_Mission_2:ExplodeyBoom()
  local sPlanExSpotty = "Missions\\act_3\\mission_2\\main\\Locator(3)"
  Joe.SpawnExplosiononObject(sPlanExSpotty, 2)
end

function Act_3_Mission_2:SetMiniZep()
  local hLocoZeppelin = Handle("Missions\\act_3\\mission_2\\main\\MiniZepStart")
  Util.TeleportMiniZep(hLocoZeppelin)
  Util.FreezeMiniZep(true)
  EVENT_Timer("Act_3_Mission_2.MakeMiniZepGo", self, 3)
end

function Act_3_Mission_2:MakeMiniZepGo()
  Util.FreezeMiniZep(false)
  Util.SetMiniZepSpline("Missions\\act_3\\mission_2\\main\\MiniZepSplineSpline")
end

function Act_3_Mission_2:FireAtZeppy()
  Util.KillMiniZep()
end

function Act_3_Mission_2:SetRainGo()
  Render.EnableLightning(true)
  EVENT_Timer("Act_3_Mission_2.SetLightning", self, 4)
end

function Act_3_Mission_2:SetLightning()
  Render.Rain(1, 10)
end

function Act_3_Mission_2:FireNaziWarningConv()
  Cin.PlayConversation("A3M2_EiffelTower_NaziWarning", "Act_3_Mission_2.PostNaziWarn", self)
end

function Act_3_Mission_2:PostNaziWarn()
  local hCrazedNazi = Handle("Missions\\act_3\\mission_2\\level_1\\CrazedNazi")
  Object.Kill(hCrazedNazi)
end

function Act_3_Mission_2:CrazyNaziStreamEvent()
  local tCrazyNaziEvent = {
    EventType = "StreamEvent",
    Objects = {
      "Missions\\act_3\\mission_2\\level_1\\CrazedNazi"
    }
  }
  Util.CreateEvent(tCrazyNaziEvent, "Act_3_Mission_2.SetupCrazedNazi", self)
end

function Act_3_Mission_2:SetupCrazedNazi()
  local hCrazedNazi = Handle("Missions\\act_3\\mission_2\\level_1\\CrazedNazi")
  self:SetupBarDudes(hCrazedNazi)
end

function Act_3_Mission_2:FireNoPartyConv()
  Cin.PlayConversation("A3M2_EiffelTower_NoParty")
end

function Act_3_Mission_2:FireHangingConvo()
  Cin.PlayConversation("A3M2_EiffelTower_Hanging")
end

function Act_3_Mission_2:FireTankSeesConvo()
  Cin.PlayConversation("A3M2_Tanks_Sees")
end

function Act_3_Mission_2:KaboomSequence2()
  local sExpLoc1 = "Missions\\act_3\\mission_2\\main\\Locator(5)"
  local sExpLoc2 = "Missions\\act_3\\mission_2\\main\\Locator(16)"
  local sExpLoc3 = "Missions\\act_3\\mission_2\\main\\Locator(12)"
  Joe.SpawnExplosiononObject(sExpLoc1, 2)
  Joe.SpawnExplosiononObject(sExpLoc2, 3)
  Joe.SpawnExplosiononObject(sExpLoc2, 4)
  Util.AddSplinePlaneAttackObject("Missions\\act_3\\mission_2\\main\\Plane1GPSRoute", 1, false, hSab, false, 1, "a", nil, nil, "VH_OP_ME109_SPLINE")
  Util.AddSplinePlaneAttackObject("Missions\\act_3\\mission_2\\main\\Plane2GPSRoute", 1, false, hSab, false, 1, "a", nil, nil, "VH_OP_ME109_SPLINE")
end

function Act_3_Mission_2:PlayMurderSuiConvo()
  Cin.PlayConversation("A3M2_Tower_NaziShootWoman_FemaleFrenchCiv_01", "Act_3_Mission_2.FireNaziMurSuiConv", self)
end

function Act_3_Mission_2:FireNaziMurSuiConv()
  Cin.PlayConversation("A3M2_Tower_NaziShootWoman_Nazi_02")
end

function Act_3_Mission_2:CheckforClimbing()
  if self:IsMissionTaskComplete("TASK_GotoElevator") == false then
    self:CompleteTaskByName("TASK_GotoElevator")
  else
  end
  if self.tSaveInfo.bPassingThrough == false then
    self:WatchTheSuicide()
    self:AddEvent(EVENT_PlayerEntersTrigger("Act_3_Mission_2.FireNaziWarningConv", self, self.sPT_NaziWarning, false))
  else
  end
  EVENT_Timer("Act_3_Mission_2.Delayedtaskcancel", self, 2)
end

function Act_3_Mission_2:Delayedtaskcancel()
  self:CompleteTaskByName("TASK_UseElevator1")
end

function Act_3_Mission_2:CheckforHigherClimbing()
  if self:IsMissionTaskComplete("TASK_GotoElevator2") == false then
    self:CompleteTaskByName("TASK_GotoElevator2")
  else
  end
end

function Act_3_Mission_2:Delayedtaskcancel2()
  self:CompleteTaskByName("Task_ClimbHigher")
end

function Act_3_Mission_2:OnCancelComplete()
end

function Act_3_Mission_2:CancelGPS()
  HUD.ClearWaypoint()
end
