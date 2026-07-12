if Act_1_Farm == nil then
  Act_1_Farm = SabTaskObjective:Create()
  gsA1Farm = "Missions\\act_1\\farm_on_fire\\"
  Act_1_Farm:Configure({
    TaskCount = 999,
    bStarterless = true,
    bFastComplete = true,
    tUnlockList = {
      "Connect_JulesisDeadCin"
    },
    sSaveMissionNameID = "MissionNames_Text.A1M5",
    MCDisplayID = 2,
    tSMEDNodes = {
      gsA1Farm .. "super_main",
      "CountrySide\\champagneardennes\\morinifarm\\buildings\\burningbarn_portal"
    },
    tStaticTags = {
      "Static_BarnProps",
      "burningbarn_building",
      "burningbarn_props",
      "BurningBarn_Effects",
      "drive2effects",
      "planewreckage01",
      "Farm_DeadBodies",
      "burningbarndoor"
    }
  })
end

function Act_1_Farm:STARTER_Setup()
  Actor.SetDisguise(hSab, "FBS_RS_Sean_Shirt_Sab_NoHat_NoBag")
  Render.SetGlobalWTF(false)
  Render.EnableLightning(true)
  Render.Rain(0.2, 1)
  Util.SetTimeScale(1)
  Object.ForceOpen(Util.GetHandleByName("Missions\\act_1\\escape\\temp_bridgenode\\PSEscape_Bridge"))
  Sound.SetMusicLocale("A1M4_Escape")
  Sound.SetMusicLocale("m_A1M4_Escape", "A1M4_driving")
  Suspicion.EnableEscalationVehicles(false)
end

function Act_1_Farm:Activated()
  SabTaskObjective.Activated(self)
  Util.SetTimeScale(1)
  Suspicion.SetFixedEscalationLevel(2)
  self.VittoreDecementHealth = 0
  self.GENERAL_Setup(self)
  self:RegisterCheckpoint("Act_1_Farm.Checkpoint1")
end

function Act_1_Farm:GENERAL_Setup()
  self.tSaveInfo.nPoint = 1
  self.tInfo.TeleportLoc = gsA1Farm .. "farm_on_fire\\main\\LOC_Entrance"
  self.tInfo.TeleportBelleLoc = "PARIS\\area01\\belledenuit\\interior\\hq_ext\\belle_outside\\LOC_TeleportSpot"
  self.tInfo.VittoreCaptured = gsA1Farm .. "vittoreofficeevent\\Vittore_Captured"
  self.tInfo.sPrisoner = gsA1Farm .. "backofficeevent\\Veronique_BackRoom"
  self.tInfo.tVeronGuards = {
    gsA1Farm .. "backofficeevent\\HeavyTorture_01",
    gsA1Farm .. "backofficeevent\\HeavyTorture_02"
  }
  self.tInfo.BadNazi = gsA1Farm .. "vittoreofficeevent\\BadNazi"
  self.tInfo.Fireman3 = "Missions\\act_1\\farm_on_fire\\Drive2Flamers\\Fireman3"
  self.tInfo.FireTarget3 = "Missions\\act_1\\farm_on_fire\\Drive2Flamers\\FireTarget3"
  self.tInfo.Fireman4 = "Missions\\act_1\\farm_on_fire\\Drive2Flamers\\Fireman4"
  self.tInfo.FireTarget4 = "Missions\\act_1\\farm_on_fire\\Drive2Flamers\\FireTarget4"
  self.tInfo.Fireman1 = "Missions\\act_1\\farm_on_fire\\exteriorfight\\Fireman1"
  self.tInfo.FireTarget1 = "Missions\\act_1\\farm_on_fire\\exteriorfight\\FireTarget1"
  self.tInfo.Fireman2 = "Missions\\act_1\\farm_on_fire\\exteriorfight\\Fireman2"
  self.tInfo.FireTarget2 = "Missions\\act_1\\farm_on_fire\\exteriorfight\\FireTarget2"
  Sound.LoadSoundBank("m_A1M5_inGame.bnk")
  Sound.LoadSoundBank("m_A1M4_planes.bnk")
  self.tSaveInfo.NextDamageRegion = 1
  self.tInfo.TotalDamageRegions = 8
  self.tInfo.DamageRegionLoadTimer = 15
  self.tSaveInfo.hHealthBarVittore = nil
  self.tSaveInfo.hHealthBarVeron = nil
  self.tSaveInfo.bActiveHealthTick = false
  self:AddOnCancelCallback(Act_1_Farm.Reset)
  self:AddOnCompleteCallback(Act_1_Farm.Reset)
  Vehicle.EnableTraffic(false)
  local hVeh = Actor.GetVehicle(hSab)
  if hVeh then
    Vehicle.SetForceAIController(hVeh, false)
  end
end

function Act_1_Farm:Reset()
  Render.WTFClearOverrideBlueprint()
  Sound.StopSoundEvent(self.PlaneSoundLoopID)
  Sound.ReleaseSoundBank("m_A1M5_inGame.bnk")
  Sound.UnloadSoundBank("m_A1M4_planes.bnk")
  Sound.UnloadSoundBank("m_A1M5_planes.bnk")
  Render.EnableLightning(false)
  Render.Rain(0, 1)
  Cin.StopCinematic("A1M5_LODPlanesLoop_01", true)
  Squad.Delete("NaziFighters")
  Squad.Delete("FrenchFarmers")
  Suspicion.EnableEscalationVehicles(true)
  Suspicion.ResetEscalation()
  self:RemoveHealthBar()
  Suspicion.SetFixedEscalationLevel(0)
  Suspicion.EnableGlobal(true)
  Suspicion.EnableEscalation(true)
  Suspicion.EnableEscalationVehicles(true)
  Vehicle.EnableTraffic(true)
  HUD.ClearWaypoint()
end

function Act_1_Farm:SetupFights()
  local FightStartDistance = 90
  Squad.Create("NaziFighters")
  Squad.Create("FrenchFarmers")
  Squad.SetEnemy("NaziFighters", "FrenchFarmers")
  Squad.SetLethal("NaziFighters")
  Squad.SetLethal("FrenchFarmers")
  EVENT_PlayerToActorProximity("Act_1_Farm.GoFight", self, gsA1Farm .. "drive_battle00\\Locator", FightStartDistance, {
    gsA1Farm .. "drive_battle00"
  })
  EVENT_PlayerToActorProximity("Act_1_Farm.GoFight", self, gsA1Farm .. "drive_battle01\\LOC_BattleLocator", FightStartDistance, {
    gsA1Farm .. "drive_battle01"
  })
  EVENT_PlayerToActorProximity("Act_1_Farm.GoFight", self, gsA1Farm .. "drive_battle02\\Locator", FightStartDistance, {
    gsA1Farm .. "drive_battle02"
  })
  EVENT_PlayerToActorProximity("Act_1_Farm.GoFight", self, gsA1Farm .. "drive_battle02r\\Locator", FightStartDistance, {
    gsA1Farm .. "drive_battle02r"
  })
  EVENT_PlayerToActorProximity("Act_1_Farm.GoFight", self, gsA1Farm .. "drive_battle03r\\Locator", FightStartDistance, {
    gsA1Farm .. "drive_battle03r"
  })
  EVENT_PlayerToActorProximity("Act_1_Farm.GoFight", self, gsA1Farm .. "drive_battle03\\Locator", FightStartDistance, {
    gsA1Farm .. "drive_battle03"
  })
end

function Act_1_Farm:SetupFights2()
  local FightStartDistance = 90
  EVENT_PlayerToActorProximity("Act_1_Farm.GoFight", self, gsA1Farm .. "drive_battle05\\Locator", FightStartDistance, {
    gsA1Farm .. "drive_battle05"
  })
  EVENT_PlayerToActorProximity("Act_1_Farm.GoFight", self, gsA1Farm .. "drive_battle06\\Locator", FightStartDistance, {
    gsA1Farm .. "drive_battle06"
  })
  EVENT_PlayerToActorProximity("Act_1_Farm.GoFight", self, gsA1Farm .. "drive_battle_monument\\Locator", FightStartDistance, {
    gsA1Farm .. "drive_battle_monument"
  })
end

function Act_1_Farm:GoFight(sNode)
  local tNazis = {}
  local tResist = {}
  print("go fight ", sNode)
  local tNodeContents = {}
  tNodeContents = Util.GetEditNodeContents(sNode)
  if tNodeContents then
    for i, hThing in pairs(tNodeContents) do
      if Object.IsHuman(hThing) then
        Combat.SetAlwaysSeeTarget(hThing, true)
        Combat.AddTargetFlag(hThing, cTARGET_ALLENEMIES)
        self:CombatJunk(hThing)
      end
    end
  end
end

function Act_1_Farm:CombatJunk(hThing)
  Combat.SetSquadAssist(hThing, true)
  Combat.SetLethalForce(hThing, true)
end

function Act_1_Farm:Bombers()
  if not self.tSaveInfo.eBomber1 then
    print("setup bomber 1")
    self.tSaveInfo.eBomber1 = EVENT_PlayerToActorProximity("Act_1_Farm.BomberdaBuilding01", self, gsA1Farm .. "drive_battle04\\Locator", 160)
  end
  if not self.tSaveInfo.eBomber2 then
    print("setup bomber 2")
    self.tSaveInfo.eBomber2 = EVENT_PlayerToActorProximity("Act_1_Farm.BomberdaBuilding02", self, gsA1Farm .. "drive_battle04\\Locator2", 160)
  end
end

function Act_1_Farm:FlammersSteamEvent()
  EVENT_Stream("Act_1_Farm.FireAtLocator", self, self.tInfo.Fireman1, true, {
    self.tInfo.Fireman1,
    self.tInfo.FireTarget1
  })
  EVENT_Stream("Act_1_Farm.FireAtLocator", self, self.tInfo.Fireman2, true, {
    self.tInfo.Fireman2,
    self.tInfo.FireTarget2
  })
  EVENT_Stream("Act_1_Farm.FireAtLocator", self, self.tInfo.Fireman3, true, {
    self.tInfo.Fireman3,
    self.tInfo.FireTarget3
  })
  EVENT_Stream("Act_1_Farm.FireAtLocator", self, self.tInfo.Fireman4, true, {
    self.tInfo.Fireman4,
    self.tInfo.FireTarget4
  })
end

function Act_1_Farm:SetupVittoreFail()
  self.tInfo.eDeathVittore = EVENT_ActorDeath("Act_1_Farm.CharacterDeath", self, self.tInfo.VittoreCaptured, {
    "Char_Death.RS_Vittore"
  })
end

function Act_1_Farm:SetupVeronFail()
  self.tInfo.eDeathVeron = EVENT_ActorDeath("Act_1_Farm.CharacterDeath", self, self.tInfo.sPrisoner, {
    "Char_Death.RS_Veronique"
  })
  self:AddVeronHealthBar()
end

function Act_1_Farm:CharacterDeath(textid)
  if not textid then
    print("FAIL: kick --> cfrench in da groin")
  end
  self:RemoveHealthBar()
  self:MissionTaskFail(textid)
end

function Act_1_Farm:AddVittHealthBar()
  if not self.tInfo.hHealthBarVittore then
    self.tInfo.hHealthBarVittore = HUD.AddObjective(eOT_HEART, "GenericObjective_Text.BAR_Health", 2)
    HUD.SetupProgressBar(self.tInfo.hHealthBarVittore, Handle(self.tInfo.VittoreCaptured))
  end
end

function Act_1_Farm:AddVeronHealthBar()
  if not self.tInfo.hHealthBarVeron then
    self.tInfo.hHealthBarVeron = HUD.AddObjective(eOT_HEART, "GenericObjective_Text.BAR_Health", 2)
    HUD.SetupProgressBar(self.tInfo.hHealthBarVeron, Handle(self.tInfo.sPrisoner))
  end
end

function Act_1_Farm:RemoveHealthBar()
  if self.tInfo.hHealthBarVeron then
    print("Removing veronique healthbar")
    HUD.RemoveObjective(self.tInfo.hHealthBarVeron)
    self.tInfo.hHealthBarVeron = nil
  end
  if self.tInfo.hHealthBarVittore then
    print("Removing vittore healthbar")
    HUD.RemoveObjective(self.tInfo.hHealthBarVittore)
    self.tInfo.hHealthBarVittore = nil
  end
end

function Act_1_Farm:StartVeronHealthTick()
  self.tSaveInfo.bActiveHealthTick = true
end

function Act_1_Farm:HealthTimer()
  if self.tSaveInfo.bActiveHealthTick then
    self.tInfo.eTickTimer = EVENT_Timer("Act_1_Farm.VeronHealthTick", self, 3)
  end
end

function Act_1_Farm:StopVeronHealthTick()
  self.tSaveInfo.bActiveHealthTick = false
  if self.tInfo.eTickTimer then
    Util.KillEvent(self.tInfo.eTickTimer)
  end
end

function Act_1_Farm:VeronHealthTick()
  if not self.tSaveInfo.bActiveHealthTick then
    return
  end
  local hVeron = Handle(self.tInfo.sPrisoner)
  if hVeron then
    local health = Object.GetHealth(hVeron)
    local maxhealth = Object.GetMaxHealth(hVeron)
    local ThreePercentDamage = maxhealth * 0.03
    if health then
      Object.SetHealth(hVeron, health - ThreePercentDamage)
    end
    self:HealthTimer()
  end
end

function Act_1_Farm:Task_Arrival()
  self:CreateTask({
    sName = "Task_Arrival",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    sObjectiveTextID = "A1M5_Text.Task_Arrival",
    tDestRegion = {
      gsA1Farm .. "super_main\\REG_FarmStart"
    },
    tDeliverObjs = {hSab},
    tLocators = {
      "Missions\\act_1\\farm_on_fire\\super_main\\LOC_Farm"
    },
    tOnActivate = {
      {
        self.SetGPS,
        {self}
      }
    },
    tOnComplete = {
      {
        self.RegisterCheckpoint,
        {
          self,
          "Act_1_Farm.Checkpoint2"
        }
      }
    }
  })
end

function Act_1_Farm:Checkpoint1()
  print("_Checkpoint 1")
  if not self:IsMissionTaskActive("Task_Arrival") then
    self:Task_Arrival()
  end
  self:Task_BigLoad()
  self:StreamBadNazi()
  self:StreamVittore()
  self.VittoreDecementHealth = 0
  Sound.PlayOwnerlessSoundEvent("Amb_Veh_SquadronOfPlanes")
  Object.ForceOpen(Util.GetHandleByName("Missions\\act_1\\escape\\temp_bridgenode\\PSEscape_Bridge"))
  Render.Rain(0.2, 1)
  Suspicion.SetFixedEscalationLevel(2)
end

function Act_1_Farm:Task_BigLoad()
  self:CreateTask({
    sName = "Task_BigLoad",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tSMEDNodes = {
      gsA1Farm .. "main",
      gsA1Farm .. "Drive_Battle00",
      gsA1Farm .. "Drive_Battle01",
      gsA1Farm .. "Drive_Battle02",
      gsA1Farm .. "Drive_Battle02r",
      gsA1Farm .. "drive_battle03r",
      gsA1Farm .. "drive_battle03",
      gsA1Farm .. "Drive2Flamers"
    },
    tOnActivate = {
      {
        self.FlammersSteamEvent,
        {self}
      },
      {
        self.SetupFights,
        {self}
      },
      {
        self.Task_BigLoad2,
        {self}
      },
      {
        self.WarVO,
        {self}
      }
    }
  })
end

function Act_1_Farm:WarVO()
  Util.CreateEvent({
    EventType = "TimerEvent",
    EventName = "VODelay_WAR",
    Time = 10
  }, "Act_1_Farm.WarVOPlay", self)
end

function Act_1_Farm:WarVOPlay()
  Cin.PlayConversation("A1M5_War_Started_02")
end

function Act_1_Farm:Task_BigLoad2()
  self:CreateTask({
    sName = "Task_BigLoad2",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tSMEDNodes = {
      gsA1Farm .. "exteriorfight",
      gsA1Farm .. "PlanesNBombs",
      gsA1Farm .. "sound",
      gsA1Farm .. "drive_battle04",
      gsA1Farm .. "drive_battle04r",
      gsA1Farm .. "drive_battle05",
      gsA1Farm .. "drive_battle06",
      gsA1Farm .. "drive_battle_monument",
      gsA1Farm .. "Civilians2Die",
      gsA1Farm .. "BarnExplosions"
    },
    tOnActivate = {
      {
        self.SetupFights2,
        {self}
      },
      {
        self.Bombers,
        {self}
      }
    }
  })
end

function Act_1_Farm:Checkpoint2()
  print("_Checkpoint 2")
  Sound.PlayOwnerlessSoundEvent("Amb_Veh_SquadronOfPlanes")
  self:StreamBadNazi()
  self:StreamVittore()
  HUD.ClearWaypoint()
  self:RemoveHealthBar()
  self:SetupFights()
  self:Bombers()
  self:FlammersSteamEvent()
  Object.SpawnInVehicle("Human_WM_Grunt_MG", "GUNNER", Util.GetHandleByName("Missions\\act_1\\farm_on_fire\\exteriorfight\\VH_NZ_CR_Kubelwagen_mount"), "Act_1_Farm.TurnoffDude")
  Sound.SetMusicLocale("A1M4_Escape")
  Sound.SetMusicLocale("m_A1M4_Escape", "A1M5_arriveAtFarm")
  self.VittoreDecementHealth = 0
  self:Task_GetToVittore()
  self:SetupGodCharacter(self.tInfo.sPrisoner)
  Suspicion.SetFixedEscalationLevel(2)
  Render.Rain(0.2, 1)
end

function Act_1_Farm:TurnoffDude(tHandle)
  Combat.SetStationary(tHandle[1], tHandle[1], 17)
end

function Act_1_Farm:Task_GetToVittore()
  self:CreateTask({
    sName = "Task_GetToVittore",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "Goto",
    Proximity = 60,
    sObjectiveTextID = "A1M5_Text.Task_Entrance",
    tDestProximityObj = {
      self.tInfo.VittoreCaptured
    },
    tDeliverObjs = {hSab},
    bNoGroundBlip = true,
    tSMEDNodes = {
      gsA1Farm .. "vittoreofficeevent"
    },
    tOnComplete = {
      {
        self.StopAnyVehicle,
        {self}
      },
      {
        self.Task_CutsceneVitt,
        {self}
      }
    },
    tOnActivate = {
      {
        self.SetupVittoreFail,
        {self}
      },
      {
        self.ReachedVittoreCaptured,
        {self}
      },
      {
        self.SetupGodCharacter,
        {
          self,
          self.tInfo.VittoreCaptured
        }
      }
    }
  })
end

function Act_1_Farm:Task_CutsceneVitt()
  self:CreateTask({
    sName = "Task_CutsceneVitt",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "CIN_A1_FarmVitt",
    tOnActivate = {
      {
        Object.SetInvincible,
        {hSab, true}
      },
      {
        self.GestapoVittoreConvo,
        {self}
      },
      {
        self.ReachedVittoreCaptured,
        {self}
      }
    },
    tOnComplete = {
      {
        self.SetVittoreHealth,
        {self}
      },
      {
        self.AddVittHealthBar,
        {self}
      },
      {
        self.FreeAnyVehicle,
        {self}
      },
      {
        self.SetupTriggerEvents,
        {self}
      },
      {
        Object.SetInvincible,
        {hSab, false}
      },
      {
        self.TASK_KillNazi,
        {self}
      },
      {
        self.VittoreHealthTimer,
        {self}
      },
      {
        self.Task_FailIfYouSuck,
        {self}
      }
    }
  })
end

function Act_1_Farm:SetVittoreHealth()
  local hVitt = Handle(self.tInfo.VittoreCaptured)
  if hVitt then
    local VittoreHealth = Object.GetMaxHealth(hVitt)
    if VittoreHealth and type(VittoreHealth) == "number" then
      local lesshealth = 0.75 * VittoreHealth
      Object.SetHealth(hVitt, lesshealth)
    end
    Actor.SetUseHitReactions(hVitt, false)
  end
end

function Act_1_Farm:TASK_KillNazi()
  self:CreateTask({
    sName = "TASK_KillNazi",
    sTaskType = "SabTaskObjectiveDestroy",
    sObjectiveTextID = "A1M5_Text.TASK_KillNazi",
    sTaskSubType = "Kill",
    tTgtInclude = {
      self.tInfo.BadNazi
    },
    tOnComplete = {
      {
        self.TASK_TalkToVittore,
        {self}
      }
    },
    tOnActivate = {}
  })
end

function Act_1_Farm:TASK_TalkToVittore()
  self:CreateTask({
    sName = "TASK_TalkToVittore",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "TALK",
    sObjectiveTextID = "A1M5_Text.TASK_TalkToVittore",
    bAutofire = true,
    Proximity = 10,
    bUseOldAutofire = true,
    sConvFile = "125_InG_FarmSave-VeroniqueStart",
    tTgtInclude = {
      self.tInfo.VittoreCaptured
    },
    tOnActivate = {
      {
        self.ClearVittore,
        {self}
      }
    },
    tOnComplete = {
      {
        self.Task_SilentFindRoom,
        {self}
      },
      {
        self.Task_GotoDoor1,
        {self}
      },
      {
        self.RemoveHealthBar,
        {self}
      },
      {
        self.VittoreKickAss,
        {self}
      }
    }
  })
end

function Act_1_Farm:StopAnyVehicle()
  local hVeh = Actor.GetVehicle(hSab)
  if hVeh then
    print("stoping vehicle")
    Vehicle.HardSetLinVel(hVeh, 0.3)
    Common.DisableVehControls(true)
  end
end

function Act_1_Farm:FreeAnyVehicle()
  local hVeh = Actor.GetVehicle(hSab)
  print("releasing vehicle")
  Common.DisableVehControls(false)
end

function Act_1_Farm:SetupTriggerEvents()
  EVENT_PlayerEntersTrigger("Act_1_Farm.Explosion1", self, gsA1Farm .. "BarnExplosions\\REG_Explosion_01")
  EVENT_PlayerEntersTrigger("Act_1_Farm.Explosion2", self, gsA1Farm .. "BarnExplosions\\REG_Explosion_02")
  EVENT_PlayerEntersTrigger("Act_1_Farm.Explosion3", self, gsA1Farm .. "BarnExplosions\\REG_Explosion_03")
  EVENT_PlayerEntersTrigger("Act_1_Farm.Explosion4", self, gsA1Farm .. "BarnExplosions\\REG_Explosion_04")
  EVENT_PlayerEntersTrigger("Act_1_Farm.Explosion5", self, gsA1Farm .. "BarnExplosions\\REG_Explosion_05")
end

function Act_1_Farm:PrepVitt()
  local hVit = Util.GetHandleByName(self.tInfo.VittoreCaptured)
  if hVit then
    print("prep vittor")
    Inventory.GiveItem(hVit, "WP_MG_Thompson", true)
    Combat.SetIdleHoldWeapon(hVit, true)
    Combat.SetStationary(hVit, true)
    Combat.SetReactImmediately(hVit, true)
  end
end

function Act_1_Farm:DummyChaseSequence()
  local hVit = Util.GetHandleByName(self.tInfo.VittoreFireFight)
  for i, Nazi in pairs(self.tInfo.tDummyNazis) do
    local hNazi = Util.GetHandleByName(Nazi)
    if hNazi then
      print("Nazi chasing vittore ", hNazi)
      Actor.OverrideCombatAI(hNazi, false)
      Combat.SetIdleScripted(hNazi, true)
      Nav.SetScriptedPath(hNazi, gsA1Farm .. "vittorefireevent\\PATH_NaziRun", true)
      Nav.SetScriptedPathMoveMode(hNazi, true)
    end
  end
end

function Act_1_Farm:VittoreReachedFireEventFinish()
  print("unloading vittore fire fight node")
  self.tSaveInfo.bUnloadVittoreFireFight = true
  self:UnloadTaskNodes("Task_VittoreFireFight", true)
end

function Act_1_Farm:StartDamageRegionTimer()
  self.tSaveInfo.eDamageRegionTimer = EVENT_Timer("Act_1_Farm.Task_LoadDamageRegion", self, 5)
end

function Act_1_Farm:SetupGestapoVittoreConvo()
  EVENT_PlayerEntersTrigger("Act_1_Farm.GestapoVittoreConvo", self, gsA1Farm .. "vittoreofficeevent\\REG_OfficeEvent_Dialog")
end

function Act_1_Farm:ReachedVittoreCaptured()
  local hVitt = Util.GetHandleByName(self.tInfo.VittoreCaptured)
  if hVitt then
    Actor.PlayAnimation(hVitt, "Civ_lay_ground_sad")
  end
end

function Act_1_Farm:ReachedVeronCaptured()
  local hVeron = Util.GetHandleByName(self.tInfo.sPrisoner)
  if hVeron then
    Actor.SetUseHitReactions(hVeron, false)
    Actor.SetNonKnockdownable(hVeron, true)
    Combat.SetIdleScripted(hVeron, true)
    Actor.OverrideCombatAI(hVeron, true)
    Actor.PlayAnimation(hVeron, "Civ_lay_ground_sad")
  end
  local hNazi1 = Handle()
  for i, sNazi in pairs(self.tInfo.tVeronGuards) do
    EVENT_ActorEntersCombat("Act_1_Farm.ClearNazis", self, sNazi)
  end
  self:OverrideVeronNazis(false)
end

function Act_1_Farm:OverrideVeronNazis(bOverride)
  for i, sNazi in pairs(self.tInfo.tVeronGuards) do
    local hNazi = Handle(sNazi)
    if hNazi then
      Actor.OverrideCombatAI(hNazi, bOverride)
    end
  end
end

function Act_1_Farm:ClearNazis()
  print("clear nazis")
  for i, sNazi in pairs(self.tInfo.tVeronGuards) do
    local hNazi = Handle(sNazi)
    if hNazi then
      print("clearing attrpt, ", sNazi)
      Actor.CancelAttrPt(hNazi)
    end
  end
end

function Act_1_Farm:StreamBadNazi()
  EVENT_Stream("Act_1_Farm.SetupBadNazi", self, {
    self.tInfo.BadNazi
  }, true)
end

function Act_1_Farm:StreamVittore()
  EVENT_Stream("Act_1_Farm.SetupVittore", self, {
    self.tInfo.VittoreCaptured
  }, true)
end

function Act_1_Farm:SetupBadNazi()
  local hVit = Util.GetHandleByName(self.tInfo.VittoreFireFight)
  local hNazi = Util.GetHandleByName(self.tInfo.BadNazi)
  if hNazi then
    Combat.SetIdleScripted(hNazi, true)
    Combat.SetRespondToEvents(hNazi, false)
    Combat.SetStationary(hNazi, true)
    print("nazis cowering at vittore")
  end
end

function Act_1_Farm:SetupVittore()
  local hVit = Util.GetHandleByName(self.tInfo.VittoreCaptured)
  if hVit then
    Actor.OverrideCombatAI(hVit, true)
    Combat.SetRespondToEvents(hVit, false)
    print("nazis cowering at vittore")
  end
end

function Act_1_Farm:VittoreKickAss()
  local hVit = Util.GetHandleByName(self.tInfo.VittoreCaptured)
  if hVit then
    Actor.OverrideCombatAI(hVit, false)
    Combat.SetRespondToEvents(hVit, true)
    Object.SetInvincible(hVit, true)
    Combat.AddTargetFlag(hVit, cTARGET_ALLENEMIES)
    print("nazis cowering at vittore")
  end
end

function Act_1_Farm:ClearVittore()
  local hVitt = Handle(self.tInfo.VittoreCaptured)
  if hVitt then
    self.VittoreDecementHealth = 1
    Actor.Ragdoll(hVitt)
    Combat.AddTargetFlag(hVitt, cTARGET_ALLENEMIESHOSTILE)
    Actor.SetUseHitReactions(hVitt, true)
    Object.SetInvincibleToAI(hVitt, true)
  end
end

function Act_1_Farm:GestapoVittoreConvo()
  Cin.PlayConversation("125_InG_FarmSave-VittoreBeatdown")
end

function Act_1_Farm:VittoreSeanConvo()
  Cin.PlayConversation("125_InG_FarmSave-VeroniqueStart")
end

function Act_1_Farm:Task_FindRoom()
  self:CreateTask({
    sName = "Task_FindRoom",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tLocators = {
      gsA1Farm .. "main\\LOC_BagRoom"
    },
    bNoGroundBlip = true,
    tOnComplete = {}
  })
end

function Act_1_Farm:Task_SilentFindRoom()
  self:CreateTask({
    sName = "Task_SilentFindRoom",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = {
      gsA1Farm .. "main\\REG_BagRoom"
    },
    tDeliverObjs = {hSab},
    sObjectiveTextID = "A1M5_Text.Task_FindRoom",
    sTaskEndConv = "125_InG_FarmSave-VeroniqueTortured",
    tOnActivate = {},
    tOnComplete = {
      {
        self.ReachedVeronCaptured,
        {self}
      },
      {
        self.CompleteTaskByName,
        {
          self,
          "Task_FindRoom"
        }
      },
      {
        self.TASK_KillTheNotNiceNazis,
        {self}
      },
      {
        self.KillTaskByName,
        {
          self,
          "TASK_TalkToVittore"
        }
      }
    }
  })
end

function Act_1_Farm:Task_GotoDoor1()
  self:CreateTask({
    sName = "Task_GotoDoor1",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = {
      gsA1Farm .. "main\\REG_Goto1"
    },
    tDeliverObjs = {hSab},
    tLocators = {
      gsA1Farm .. "main\\LOC_Goto1"
    },
    bNoGroundBlip = true,
    tSMEDNodes = {
      gsA1Farm .. "BackOfficeEvent"
    },
    tOnActivate = {
      {
        self.SetupVeronFail,
        {self}
      },
      {
        self.StartVeronHealthTick,
        {self}
      },
      {
        self.HealthTimer,
        {self}
      },
      {
        self.OverrideVeronNazis,
        {self, true}
      }
    },
    tOnComplete = {
      {
        self.Task_FindRoom,
        {self}
      }
    }
  })
end

function Act_1_Farm:Task_FailIfYouSuck()
  self:CreateTask({
    sName = "Task_FailIfYouSuck",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = {
      gsA1Farm .. "vittoreofficeevent\\REG_VittoreFail"
    },
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        self.CheckVittore,
        {self}
      }
    }
  })
end

function Act_1_Farm:CheckVittore()
  if self:IsMissionTaskActive("TASK_KillNazi") or self:IsMissionTaskActive("TASK_TalkToVittore") then
    local hVitt = Handle(self.tInfo.VittoreCaptured)
    if hVitt then
      print("killing vittore")
      self:VittoreHealthTick()
    end
  end
end

function Act_1_Farm:VittoreHealthTick()
  local hVitt = Handle(self.tInfo.VittoreCaptured)
  if hVitt and Object.IsAlive(hVitt) and self.VittoreDecementHealth == 0 then
    local health = Object.GetHealth(hVitt)
    local maxhealth = Object.GetMaxHealth(hVitt)
    if health then
      Object.SetHealth(hVitt, health - 8)
      print("die vittore!", health)
    end
    self:VittoreHealthTimer()
  end
end

function Act_1_Farm:VittoreHealthTimer()
  local hVitt = Handle(self.tInfo.VittoreCaptured)
  if hVitt and self.VittoreDecementHealth == 0 then
    self.tInfo.eTickTimer = EVENT_Timer("Act_1_Farm.VittoreHealthTick", self, 2)
  end
end

function Act_1_Farm:TASK_KillTheNotNiceNazis()
  self:CreateTask({
    sName = "TASK_KillTheNotNiceNazis",
    sTaskType = "SabTaskObjectiveDestroy",
    sObjectiveTextID = "A1M5_Text.TASK_KillTheNotNiceNazis",
    sTaskSubType = "Kill",
    tTgtInclude = self.tInfo.tVeronGuards,
    tOnComplete = {
      {
        self.Task_BeNearCaptive,
        {self}
      }
    },
    tOnActivate = {}
  })
end

function Act_1_Farm:Task_BeNearCaptive()
  self:CreateTask({
    sName = "Task_BeNearCaptive",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "deliver",
    sObjectiveTextID = "A1M5_Text.Task_BeNearCaptive",
    tDestProximityObj = {
      self.tInfo.sPrisoner
    },
    Proximity = 6,
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.Task_CutsceneExit1,
        {self}
      },
      {
        self.StopVeronHealthTick,
        {self}
      },
      {
        self.RemoveHealthBar,
        {self}
      }
    },
    tOnActivate = {
      {
        Cin.LoadCinematic,
        {
          "126_CinB_ToParis"
        }
      }
    }
  })
end

function Act_1_Farm:Task_CutsceneExit1()
  self:CreateTask({
    sName = "Task_CutsceneExit1",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "126_CinB_ToParis",
    bOverrideFade = true,
    tCinematicNodes = {
      "126_toparis"
    },
    tOnActivate = {},
    tOnComplete = {
      {
        self.CompleteThisMission,
        {self}
      }
    },
    tOnCinematicFail = {
      {
        Render.FadeScreen,
        {true}
      }
    }
  })
end

function Act_1_Farm:FireAtLocator(sSoldier, sTarget)
  local hSoldier = WRAPPER_CheckForHandle(sSoldier)
  if hSoldier and Object.GetHealth(hSoldier) > 0 then
    local hTarget = WRAPPER_CheckForHandle(sTarget)
    Combat.SetAlwaysSeeTarget(hSoldier, true)
    Combat.SetBroadcastWeaponFire(hSoldier, false)
    Combat.SetReactImmediately(hSoldier, true)
    Combat.SetLethalForce(hSoldier, true)
    Combat.SetCombat(hSoldier)
    Combat.AddTargetFlag(hSoldier, cTARGET_ENEMYLIST, {
      {hTarget, 10},
      {hSab, 1}
    })
  end
end

function Act_1_Farm:SetupGodCharacter(sChar)
  EVENT_Stream("Act_1_Farm.GodCharacter", self, sChar, true, sChar)
end

function Act_1_Farm:GodCharacter(sChar)
  print("god char ", sChar)
  local hChar = Util.GetHandleByName(sChar)
  if hChar then
    Object.SetInvincibleToAI(hChar, true)
    Actor.SetRunsFromFire(hChar, false)
    Actor.SetPanicEnabled(hChar, false)
  end
end

function Act_1_Farm:StraffingRun_001()
  Util.AddSplinePlaneAttackLocation("Missions\\act_1\\farm_on_fire\\planesnbombs\\CIN_PlaneAttack01_05_1", 100, false, 2125, 30, -2031, true)
end

function Act_1_Farm:StraffingRun_002()
  Util.AddSplinePlaneAttackLocation("Missions\\act_1\\farm_on_fire\\planesnbombs\\CIN_PlaneAttack01_07_1", 100, false, 2125, 30, -2031, true)
end

function Act_1_Farm:BomberPlane01()
  Util.AddSplinePlaneAttackLocation("Missions\\act_1\\farm_on_fire\\planesnbombs\\TEST_Bomber", 10, true, 2119, 29, -2002, true)
end

function Act_1_Farm:BomberPlane02()
  Util.AddSplinePlaneAttackLocation("Missions\\act_1\\farm_on_fire\\planesnbombs\\TEST_Bomber", 10, true, 2119, 29, -2002, true)
end

function Act_1_Farm:BomberPlane03()
  Util.AddSplinePlaneAttackLocation("Missions\\act_1\\farm_on_fire\\planesnbombs\\TEST_Bomber", 10, true, 2119, 29, -2002, true)
end

function Act_1_Farm:BomberPlane04()
  Util.AddSplinePlaneAttackLocation("Missions\\act_1\\farm_on_fire\\planesnbombs\\TEST_Bomber", 10, true, 2119, 29, -2002, true)
end

function Act_1_Farm:BomberPlane05()
  Util.AddSplinePlaneAttackLocation("Missions\\act_1\\farm_on_fire\\planesnbombs\\TEST_Bomber", 10, true, 2119, 29, -2002, true)
end

function Act_1_Farm:StraffingRun_01()
  Util.AddSplinePlaneAttackLocation("Missions\\act_1\\farm_on_fire\\drive_battle02\\CIN_StraffingRun_01", 100, false, 1875, 68, -1828, true)
end

function Act_1_Farm:StraffingRun_02()
  Util.AddSplinePlaneAttackLocation("Missions\\act_1\\farm_on_fire\\drive_battle02\\CIN_StraffingRun_02", 100, false, 1875, 68, -1828, true)
end

function Act_1_Farm:StraffingRun_03()
end

function Act_1_Farm:BomberdaBuilding01()
  local hHouse01 = Util.GetHandleByName("Missions\\act_1\\farm_on_fire\\temp_buildingtest\\FBuilding_DesCottage_C(2)\\FBuilding_DesCottage_C")
  if self.tSaveInfo.eBomber1 then
    self.tSaveInfo.eBomber1 = nil
  end
  if not hHouse01 then
    print(" no house1  ")
    return
  end
  print(" BomberdaBuilding01  ")
  Util.AddSplinePlaneAttackObject(gsA1Farm .. "drive_battle04\\CIN_StraffingRun_01", 100, false, hHouse01, true)
  Util.AddSplinePlaneAttackObject(gsA1Farm .. "drive_battle04\\CIN_StraffingRun_04", 60, true, hHouse01, true)
  Util.AddSplinePlaneAttackObject(gsA1Farm .. "drive_battle04\\CIN_StraffingRun_05", 60, true, hHouse01, true)
end

function Act_1_Farm:BomberdaBuilding02()
  if self.tSaveInfo.eBomber2 then
    self.tSaveInfo.eBomber2 = nil
  end
  local hHouse01 = Util.GetHandleByName("Missions\\act_1\\farm_on_fire\\temp_buildingtest\\FBuilding_DesCottage_A(4)")
  if not hHouse01 then
    print(" no house2  ")
    return
  end
  print(" BomberdaBuilding02  ")
  Util.AddSplinePlaneAttackObject(gsA1Farm .. "drive_battle04\\CIN_StraffRun_01", 1, true, hHouse01, true)
  Util.AddSplinePlaneAttackObject(gsA1Farm .. "drive_battle04\\CIN_StraffRun_02", 1, true, hHouse01, true)
end

function Act_1_Farm:StartTrain01()
  Train.TrainCreate("CountrySide\\champagneardennes\\traintracks\\DTrain_TEST", "Dtrain3")
  Train.TrainSetMaxSpeed("CountrySide\\champagneardennes\\traintracks\\DTrain_TEST", "28")
end

function Act_1_Farm:SetGPS()
  HUD.SetWaypoint(1183, -1710)
  EVENT_PlayerEntersTrigger("Act_1_Farm.SetGPSFarm", self, "Missions\\act_1\\farm_on_fire\\super_main\\REG_SwitchGPS")
end

function Act_1_Farm:SetGPSFarm()
  HUD.SetGPSTarget(1114, -2092)
end

function Act_1_Farm:Explosion1()
  Cin.PlayCinematic("A1M5_FarmDestruction_01", false)
end

function Act_1_Farm:Explosion2()
  Cin.PlayCinematic("A1M5_FarmDestruction_02", false)
  Object.Kill(Util.GetHandleByName("Missions\\act_1\\farm_on_fire\\exteriorfight\\Fireman1"))
  Object.Kill(Util.GetHandleByName("Missions\\act_1\\farm_on_fire\\exteriorfight\\Fireman2"))
end

function Act_1_Farm:Explosion3()
  Cin.PlayCinematic("A1M5_FarmDestruction_03", false)
end

function Act_1_Farm:Explosion4()
  Cin.PlayCinematic("A1M5_FarmDestruction_04", false)
end

function Act_1_Farm:Explosion5()
  Cin.PlayCinematic("A1M5_FarmDestruction_05", false)
  local hProp = Util.GetHandleByName("CountrySide\\champagneardennes\\morinifarm\\buildings\\burningbarn_props\\Platform_Drop\\Canal_Scaffold_Med(9)")
  if hProp then
    Damage.SetDamageState(hProp, "Canal_Scaffold_Med", 1)
  end
  local hProp = Util.GetHandleByName("CountrySide\\champagneardennes\\morinifarm\\buildings\\burningbarn_props\\Platform_Drop(2)\\Canal_Scaffold_Med(9)")
  if hProp then
    Damage.SetDamageState(hProp, "Canal_Scaffold_Med", 1)
  end
end

function Act_1_Farm:DestroyWindow()
  Object.Kill(Util.GetHandleByName("CountrySide\\champagneardennes\\morinifarm\\buildings\\burningbarn_building\\MoriniBarn_2X4_WindowC"))
  Object.Kill(Util.GetHandleByName("CountrySide\\champagneardennes\\morinifarm\\buildings\\burningbarn_building\\MoriniBarn_2X4_WindowB(2)"))
  Object.Kill(Util.GetHandleByName("CountrySide\\champagneardennes\\morinifarm\\buildings\\burningbarn_building\\MoriniBarn_2X4_WindowB(1)"))
  Object.Kill(Util.GetHandleByName("CountrySide\\champagneardennes\\morinifarm\\buildings\\burningbarn_building\\MoriniBarn_2X4_WindowB"))
  Object.Kill(Util.GetHandleByName("CountrySide\\champagneardennes\\morinifarm\\buildings\\burningbarn_building\\MoriniBarn_2X4_WindowA"))
end

function Act_1_Farm:DestroyCeiling()
  Object.Kill(Util.GetHandleByName("CountrySide\\champagneardennes\\morinifarm\\buildings\\burningbarn_building\\MoriniBarn_MainRoofB_BigHole_DAM(1)"))
end
