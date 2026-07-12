if Act_1_Race == nil then
  Act_1_Race = SabTaskObjective:Create()
  gsA1Race = "Missions\\act_1\\Race\\"
  Util.SetTime(12, 0)
  Act_1_Race:Configure({
    TaskCount = 999,
    MCDisplayID = 2,
    bFreezeTimeScale = true,
    bStarterless = true,
    tUnlockList = {
      "Act_1_GetCaught"
    },
    bFastComplete = true,
    bSLOverrideFade = true,
    sSaveMissionNameID = "MissionNames_Text.A1M1",
    bForceUnloadNodes = true,
    tSMEDNodes = {
      gsA1Race .. "main",
      gsA1Race .. "racetrack",
      gsA1Race .. "towncrowd",
      gsA1Race .. "part1",
      gsA1Race .. "sound"
    }
  })
end

function Act_1_Race:STARTER_Setup()
  Render.SetGlobalWTF(true)
  Render.FadeScreen(true, 0)
  self._bCinRaceGoLoaded = false
  Sound.LoadSoundBank("m_A1M1_inGame.bnk")
  Sound.DisableSeanChatter()
  WorldSMEDNodes.UnloadNode("Missions\\act_1\\race\\pits")
  Suspicion.EnableGlobal(false)
  Suspicion.EnableEscalation(false)
  Vehicle.EnableTraffic(false)
  if Actor.IsInVehicle(hSab) then
    Actor.UnboardVehicle(hSab)
  end
  Cin.LoadCinematic("113_CinA_RaceGo")
  WorldSMEDNodes.PreLoadCinematicNode("113_cina_racego")
  Util.EnableSuperSpores(false)
end

function Act_1_Race:Activated()
  SabTaskObjective.Activated(self)
  Render.FadeScreen(true)
  Actor.SetDisguise(hSab, "FBS_RS_Sean_Race_Race_NoHat_NoBag")
  self:Task_LoadCarNode()
  self:Task_CutsceneRace()
  self.PitTime = false
  Vehicle.SetRacing(false)
  self.tInfo.REG_FinishLine = gsA1Race .. "main\\REG_FinishLine"
  self.tInfo.LOC_FinishLine = gsA1Race .. "main\\LOC_FinishLine"
  self.tInfo.REG_CP1 = gsA1Race .. "main\\REG_CP1"
  self.tInfo.LOC_CP1 = gsA1Race .. "main\\LOC_CP1"
  self.tInfo.REG_CP2 = gsA1Race .. "main\\REG_CP2"
  self.tInfo.LOC_CP2 = gsA1Race .. "main\\LOC_CP2"
  self.tInfo.REG_CP3 = gsA1Race .. "main\\REG_CP3"
  self.tInfo.LOC_CP3 = gsA1Race .. "main\\LOC_CP3"
  self.tInfo.REG_CP4 = gsA1Race .. "main\\REG_CP4"
  self.tInfo.LOC_CP4 = gsA1Race .. "main\\LOC_CP4"
end

function Act_1_Race:Checkpoint1_Reset()
  self.SetupRace(self)
end

function Act_1_Race:GENERAL_Setup()
  self.DEBUGMODE = false
  Actor.SetLabel(hSab, "WPOP_RACE_TIME", true)
  Util.EnableMiniZep(false)
  Util.LoadStaticENTag("A1_GPRace", true)
  Util.LoadStaticENTag("A1M1_GetCaught", true)
  Util.LoadStaticENTag("A1M1_RACE", true)
  Util.LoadStaticENTag("A1M1_RACE_GO", true)
  self.hLap1Car = Util.GetHandleByName("Missions\\act_1\\race\\part2\\VH_CV_CR_Aurora_01")
  self.bEasterEgg = false
  self.bDisDead = false
  self.PitTime = true
  self.iLap = 1
  self.iSabPlace = 25
  self.bRubberBand = false
  self.bTenth = false
  self.bFifth = false
  self.bSecond = false
  self.bCarConvBurn = false
  self.bCarConvLow = false
  self.bCarConvMed = false
  self.bCarConvHigh = false
  self.sRacerStartTrig = gsA1Race .. "main\\PT_StartRacers"
  self.sRacerSTrig = gsA1Race .. "main\\PT_RacerS"
  self.sRacerHillTrig = gsA1Race .. "main\\PT_RacerHill"
  self.sTunnelCrasher = gsA1Race .. "main\\PT_TunnelCrasher"
  self.sCrowdCrasher = gsA1Race .. "main\\PT_CrowdCrash"
  self.tDierker = {}
  self.tDierker[1] = {}
  self.tDierker[1].Name = "Dierker"
  self.tDierker[1].Locator = gsA1Race .. "part1\\LOC_Dierker"
  self.tDierker[1].Car = "VH_CV_CR_SilverDartDierker_01_Race"
  self.tDierker[1].Driver = "Human_NZ_Dierker_RaceDriver"
  self.tSkylar = {}
  self.tSkylar[1] = {}
  self.tSkylar[1].Name = "Skylar"
  self.tSkylar[1].Locator = gsA1Race .. "part1\\LOC_Skylar"
  self.tSkylar[1].Car = "VH_CV_CR_SilverDart_01"
  self.tSkylar[1].Driver = "Human_NZ_RaceDriver"
  self.tDpplRacer = {}
  self.tDpplRacer[1] = {}
  self.tDpplRacer[1].Name = "HotShit"
  self.tDpplRacer[1].Locator = gsA1Race .. "part1\\LOC_Dppl_1"
  self.tDpplRacer[1].Car = "VH_CV_CR_SilverDart_01"
  self.tDpplRacer[1].Driver = "Human_NZ_RaceDriver"
  self.tDpplRacer[2] = {}
  self.tDpplRacer[2].Name = "SpeedRacer"
  self.tDpplRacer[2].Locator = gsA1Race .. "part1\\LOC_Dppl_2"
  self.tDpplRacer[2].Car = "VH_CV_CR_SilverDart_01"
  self.tDpplRacer[2].Driver = "Human_NZ_RaceDriver"
  self.tDpplRacer[3] = {}
  self.tDpplRacer[3].Name = "Dppl_3"
  self.tDpplRacer[3].Locator = gsA1Race .. "part1\\LOC_Dppl_3"
  self.tDpplRacer[3].Car = "VH_CV_CR_SilverDart_01"
  self.tDpplRacer[3].Driver = "Human_NZ_RaceDriver"
  self.tDpplRacer[4] = {}
  self.tDpplRacer[4].Name = "Dppl_4"
  self.tDpplRacer[4].Locator = gsA1Race .. "part1\\LOC_Dppl_4"
  self.tDpplRacer[4].Car = "VH_CV_CR_SilverDart_01"
  self.tDpplRacer[4].Driver = "Human_NZ_RaceDriver"
  self.tDpplRacer[5] = {}
  self.tDpplRacer[5].Name = "Dppl_5"
  self.tDpplRacer[5].Locator = gsA1Race .. "part1\\LOC_Dppl_5"
  self.tDpplRacer[5].Car = "VH_CV_CR_SilverDart_01"
  self.tDpplRacer[5].Driver = "Human_NZ_RaceDriver"
  self.tStartingRacers = {}
  self.tStartingRacers[1] = {}
  self.tStartingRacers[1].Name = "Racer1"
  self.tStartingRacers[1].Locator = gsA1Race .. "part1\\LOC_Racer_1"
  self.tStartingRacers[1].Car = "VH_CV_CR_AlfaRom_12C_01"
  self.tStartingRacers[1].Driver = "Human_CV_RaceDriver_Team1"
  self.tStartingRacers[2] = {}
  self.tStartingRacers[2].Name = "Racer2"
  self.tStartingRacers[2].Locator = gsA1Race .. "part1\\LOC_Racer_2"
  self.tStartingRacers[2].Car = "VH_CV_CR_Allard_01"
  self.tStartingRacers[2].Driver = "Human_CV_RaceDriver_Team2"
  self.tStartingRacers[3] = {}
  self.tStartingRacers[3].Name = "Racer3"
  self.tStartingRacers[3].Locator = gsA1Race .. "part1\\LOC_Racer_3"
  self.tStartingRacers[3].Car = "VH_CV_CR_MaterTipo4CL_01"
  self.tStartingRacers[3].Driver = "Human_CV_RaceDriver_Team3"
  self.tStartingRacers[4] = {}
  self.tStartingRacers[4].Name = "Racer4"
  self.tStartingRacers[4].Locator = gsA1Race .. "part1\\LOC_Racer_4"
  self.tStartingRacers[4].Car = "VH_CV_CR_AlfaRomera_01"
  self.tStartingRacers[4].Driver = "Human_CV_RaceDriver_Team4"
  self.tStartingRacers[5] = {}
  self.tStartingRacers[5].Name = "Racer5"
  self.tStartingRacers[5].Locator = gsA1Race .. "part1\\LOC_Racer_5"
  self.tStartingRacers[5].Car = "VH_CV_CR_AlfaRom_12C_01"
  self.tStartingRacers[5].Driver = "Human_CV_RaceDriver_Team1"
  self.tStartingRacers[6] = {}
  self.tStartingRacers[6].Name = "Racer6"
  self.tStartingRacers[6].Locator = gsA1Race .. "part1\\LOC_Racer_6"
  self.tStartingRacers[6].Car = "VH_CV_CR_MaterTipo4CL_01"
  self.tStartingRacers[6].Driver = "Human_CV_RaceDriver_Team3"
  self.tStartingRacers[7] = {}
  self.tStartingRacers[7].Name = "Racer7"
  self.tStartingRacers[7].Locator = gsA1Race .. "part1\\LOC_Racer_7"
  self.tStartingRacers[7].Car = "VH_CV_CR_AlfaRom_12C_01"
  self.tStartingRacers[7].Driver = "Human_CV_RaceDriver_Team1"
  self.tStartingRacers[8] = {}
  self.tStartingRacers[8].Name = "Racer8"
  self.tStartingRacers[8].Locator = gsA1Race .. "part1\\LOC_Racer_8"
  self.tStartingRacers[8].Car = "VH_CV_CR_AlfaRomera_01"
  self.tStartingRacers[8].Driver = "Human_CV_RaceDriver_Team4"
  self.tStartingRacers[9] = {}
  self.tStartingRacers[9].Name = "Racer9"
  self.tStartingRacers[9].Locator = gsA1Race .. "part1\\LOC_Racer_9"
  self.tStartingRacers[9].Car = "VH_CV_CR_AlfaRom_12C_01"
  self.tStartingRacers[9].Driver = "Human_CV_RaceDriver_Team1"
  self.tStartingRacers[10] = {}
  self.tStartingRacers[10].Name = "Racer10"
  self.tStartingRacers[10].Locator = gsA1Race .. "part1\\LOC_Racer_10"
  self.tStartingRacers[10].Car = "VH_CV_CR_MaterTipo4CL_01"
  self.tStartingRacers[10].Driver = "Human_CV_RaceDriver_Team5"
  self.tStartingRacers[11] = {}
  self.tStartingRacers[11].Name = "Racer11"
  self.tStartingRacers[11].Locator = gsA1Race .. "part1\\LOC_Racer_11"
  self.tStartingRacers[11].Car = "VH_CV_CR_MaterTipo4CL_01"
  self.tStartingRacers[11].Driver = "Human_CV_RaceDriver_Team5"
  self.tStartingRacers[12] = {}
  self.tStartingRacers[12].Name = "Racer12"
  self.tStartingRacers[12].Locator = gsA1Race .. "part1\\LOC_Racer_12"
  self.tStartingRacers[12].Car = "VH_CV_CR_AlfaRomera_01"
  self.tStartingRacers[12].Driver = "Human_CV_RaceDriver_Team6"
  self.tStartingRacers[13] = {}
  self.tStartingRacers[13].Name = "Racer13"
  self.tStartingRacers[13].Locator = gsA1Race .. "part1\\LOC_Racer_13"
  self.tStartingRacers[13].Car = "VH_CV_CR_AlfaRom_12C_01"
  self.tStartingRacers[13].Driver = "Human_CV_RaceDriver_Team6"
  self.tStartingRacers[14] = {}
  self.tStartingRacers[14].Name = "Racer14"
  self.tStartingRacers[14].Locator = gsA1Race .. "part1\\LOC_Racer_14"
  self.tStartingRacers[14].Car = "VH_CV_CR_MaterTipo4CL_01"
  self.tStartingRacers[14].Driver = "Human_CV_RaceDriver_Team4"
  self.tStartingRacers[15] = {}
  self.tStartingRacers[15].Name = "Racer15"
  self.tStartingRacers[15].Locator = gsA1Race .. "part1\\LOC_Racer_15"
  self.tStartingRacers[15].Car = "VH_CV_CR_AlfaRom_12C_01"
  self.tStartingRacers[15].Driver = "Human_CV_RaceDriver_Team6"
  self.tStartingRacers[16] = {}
  self.tStartingRacers[16].Name = "Racer16"
  self.tStartingRacers[16].Locator = gsA1Race .. "part1\\LOC_Racer_16"
  self.tStartingRacers[16].Car = "VH_CV_CR_AlfaRomera_01"
  self.tStartingRacers[16].Driver = "Human_CV_RaceDriver_Team6"
  self.tCrashers = {}
  self.tCrashers[1] = {}
  self.tCrashers[1].sName = "TunnelCrash"
  self.tCrashers[1].vSpawnTarget = gsA1Race .. "part2\\LOC_TunnelCrash"
  self.tCrashers[1].cVehicleType = cVEH_MATERTIPO
  self.tCrashers[1].tSeatConfig = "Human_CV_RaceDriver_Team4"
  self.tCrashers[1].bForceSpawn = true
  self.tCrashers[1].cDespawnType = cDESPAWN_NONE
  self.tCrashers[1].sDeliveryPath = gsA1Race .. "part2\\PATH_TunnelCrash"
  self.tCrashers[1].cUnboardType = cDROPOFF_NONE
  self.tCrashers[1].nPathSpeed = 140
  self.tCrashers[1].tOnArrive = {
    {
      "Act_1_Race.TunnelCrash"
    }
  }
  self.tCrashers[2] = {}
  self.tCrashers[2].sName = "CrowdCrash"
  self.tCrashers[2].vSpawnTarget = gsA1Race .. "part2\\LOC_CrowdCrash"
  self.tCrashers[2].cVehicleType = cVEH_MATERTIPO
  self.tCrashers[2].tSeatConfig = "Human_CV_RaceDriver_Team3"
  self.tCrashers[2].bForceSpawn = true
  self.tCrashers[2].cDespawnType = cDESPAWN_NONE
  self.tCrashers[2].sDeliveryPath = gsA1Race .. "part2\\PATH_CrowdCrash"
  self.tCrashers[2].cUnboardType = cDROPOFF_NONE
  self.tCrashers[2].nPathSpeed = 140
  self.tCrashers[2].tOnArrive = {
    {
      "Act_1_Race.CrowdCrash"
    }
  }
  self.tPlaceChangeFall = {
    "A1M1_Position_Fall_General_Sean",
    "A1M1_Position_Fall_Nazi_Announcer",
    "A1M1_Position_Fall_Nazi_Sean"
  }
  self.tPlaceChangeClimb = {
    "A1M1_Position_Climb_General_Sean",
    "A1M1_Position_Climb_General_Announcer",
    "A1M1_Position_Climb_Nazi_Sean"
  }
  self.tAllConversations = {
    "A1M1_Position_Fall_General_Sean",
    "A1M1_Position_Fall_Nazi_Announcer",
    "A1M1_Position_Fall_Nazi_Sean",
    "A1M1_Position_Climb_General_Sean",
    "A1M1_Position_Climb_General_Announcer",
    "A1M1_Position_Climb_Nazi_Sean",
    "A1M1_CarCrash_AlphaRomeo02",
    "A1M1_CarCrash_Maseriti",
    "A1M1_CarDamage_Burning",
    "A1M1_CarDamage_Low",
    "A1M1_CarDamage_Medium",
    "A1M1_CarDamage_High",
    "A1M1_Announcer_DierkerTalk_01",
    "A1M1_Announcer_DierkerTalk_02",
    "A1M1_Announcer_PlaneFlyBy",
    "A1M1_Dierker_Detected",
    "A1M1_Position_Fall_General_Sean",
    "A1M1_Announcer_Chatter_General",
    "A1M1_Position_Place_02",
    "A1M1_Position_Place_05",
    "A1M1_Position_Place_10"
  }
  Inventory.HolsterWeapons(hSab)
end

function Act_1_Race:Task_LoadCarNode()
  self:CreateTask({
    sName = "Task_LoadCarNode",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tSMEDNodes = {
      gsA1Race .. "part2"
    },
    bCompleteOnActivate = true,
    tOnActivate = {},
    tOnComplete = {
      {
        self.GENERAL_Setup,
        {self}
      }
    }
  })
end

function Act_1_Race:Task_CutsceneRace()
  self:CreateTask({
    sName = "Task_CutsceneRace",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "113_CinA_RaceGo",
    tCinematicNodes = {
      "113_cina_racego"
    },
    bOverrideFade = true,
    sMusicLocale = "A1M1_Race",
    tOnActivate = {},
    tOnComplete = {
      {
        Util.SetOverrideLoadScreenFadeIn,
        {false}
      },
      {
        self.Teleport2Race,
        {self}
      }
    }
  })
end

function Act_1_Race:Task_LearnToDrive()
  self:CreateTask({
    sName = "Task_LearnToDrive",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    sToolTipID = "Press A for Gas. Use L-Stick to steer",
    tOnActivate = {
      {
        self.Task_MainRaceCP1,
        {self}
      }
    },
    tOnComplete = {}
  })
end

function Act_1_Race:SetupRace()
  self.bCheatDone = false
  self.bCarGone = false
  if self.bEasterEgg == true then
    Util.SetDisableAuroraGuns(true)
  end
  self.bDisDead = false
  self.iDifficulty = Util.GetRaceDifficulty()
  if self.iDifficulty == 0 then
    self.iExtraHP = 0
    self.iMinSlow = 70
    self.iMaxSlow = 85
    self.iMinFast = 85
    self.iMaxFast = 125
    self.iDierkerFast = 165
  elseif self.iDifficulty == 1 then
    self.iExtraHP = 50
    self.iMinSlow = 90
    self.iMaxSlow = 110
    self.iMinFast = 120
    self.iMaxFast = 150
    self.iDierkerFast = 165
  elseif self.iDifficulty == 2 then
    self.iExtraHP = 100
    self.iMinSlow = 90
    self.iMaxSlow = 120
    self.iMinFast = 120
    self.iMaxFast = 160
    self.iDierkerFast = 175
  elseif self.iDifficulty == 3 then
    self.iExtraHP = 100
    self.iMinSlow = 90
    self.iMaxSlow = 120
    self.iMinFast = 120
    self.iMaxFast = 165
    self.iDierkerFast = 180
  end
  Util.LoadStaticENTag("A1M1_RACE_PIT", true)
  Util.UnloadStaticENTag("wpop", true)
  Util.UnloadStaticENTag("A1M1_RaceClosed", true)
  Util.UnloadStaticENTag("A1M1_PreRace", true)
  WorldSMEDNodes.UnloadNode("wpop\\saarbrucken\\aisidewalk_racetime")
  Vehicle.SetupRace("SaarbruckenRace", "FinishLine", 3, -1, 24)
  Vehicle.SetRaceCollisionMultiplier(1)
  self:CreateRacers(self.tStartingRacers, "SaarbruckenRace", -1, self.iMinSlow, self.iMaxSlow)
  self:CreateRacers(self.tDpplRacer, "SaarbruckenRace", -1, self.iMinFast, self.iMaxFast)
  self:CreateRacers(self.tDierker, "SaarbruckenRace", -1, self.iMinFast + 15, self.iDierkerFast)
  self:CreateRacers(self.tSkylar, "SaarbruckenRace", -1, self.iMinFast, self.iMaxFast)
  self:SpawnRacers(nil, self.tStartingRacers)
  self:SpawnRacers(nil, self.tDpplRacer)
  self:SpawnRacers(nil, self.tDierker)
  self:SpawnRacers(nil, self.tSkylar)
  Actor.BoardVehicle(hSab, self.hLap1Car, "PILOT", true)
  EVENT_PlayerEntersAnyVehicle("Act_1_Race.InCar", self)
end

function Act_1_Race:InCar()
  Vehicle.SetRaceLoadedCallback("Act_1_Race.Countdown", self)
end

function Act_1_Race:Teleport2Race()
  self:UnloadTaskNodes("Task_CutsceneRace", true)
  Object.PlayerTeleportToLocator(Util.GetHandleByName("Missions\\act_1\\race\\part1\\LOC_Sean"), false, true, "Act_1_Race.EnterAurora", self)
end

function Act_1_Race:EnterAurora()
  self.RegisterCheckpoint(self, "Act_1_Race.Checkpoint1_Reset", nil, true)
  Sound.SetMusicLocale("A1M1_Race")
  Sound.SetMusicLocale("m_A1M1_Race", "A1M1_start")
  Sound.ActivateSoundEmitter(Util.GetHandleByName("Missions\\act_1\\race\\main\\Race_startengines"))
  Sound.PlayOwnerlessSoundEvent("A1M1_Race_Start")
end

function Act_1_Race:Countdown()
  HUD.SetGPSCourse("Saarbrucken")
  Render.FadeScreen(false, 0)
  Vehicle.SetForceAIController(self.hLap1Car, true)
  Vehicle.SetRacing(true, true)
  Vehicle.SetRaceStartCallback("Act_1_Race.StartRace", self)
  if self.DEBUGMODE == false then
    Util.SetDisableControls("EnterExitVehicle", true)
  end
end

function Act_1_Race:StartRace()
  local hRaceMarshall = Util.GetHandleByName("Missions\\act_1\\race\\main\\Spore_CG_RaceMarshall")
  local aFacing = Actor.CalcFacingTo(hRaceMarshall, hSab)
  Actor.PlayAnimation(hRaceMarshall, "civ_M_wave_race_flag_loop", 10, false, aFacing)
  self.bConvBusy = true
  Cin.PlayConversation("A1M1_Announcer_AndTheyreOff", "Act_1_Race.ResetConvBusy", self)
  Vehicle.SetForceAIController(self.hLap1Car, false)
  self.tGroup1 = {
    Util.GetHandleByName("Skylar"),
    Util.GetHandleByName("HotShit"),
    Util.GetHandleByName("SpeedRacer"),
    Util.GetHandleByName("Dppl_3"),
    Util.GetHandleByName("Dppl_4"),
    Util.GetHandleByName("Dppl_5")
  }
  self.tOtherRacers = {}
  for i, v in ipairs(self.tStartingRacers) do
    local hName = Util.GetHandleByName(v.Name)
    table.insert(self.tOtherRacers, hName)
  end
  for i, v in ipairs(self.tGroup1) do
    Vehicle.OverrideHorsepower(v, true, 275 + self.iExtraHP)
  end
  Vehicle.OverrideHorsepower(Util.GetHandleByName("Dierker"), true, 400)
  self.bLost = false
  self.bOver = false
  Sound.SetMusicLocale("m_A1M1_Race", "A1M1_behind")
  Sound.DeactivateSoundEmitter(Util.GetHandleByName("Missions\\act_1\\race\\main\\Race_startengines"))
  self.Task_MainRaceCP1(self)
  self.Task_BeatDierker(self)
  EVENT_ActorEntersTrigger("Act_1_Race.StepOne", self, hSab, self.sTunnelCrasher)
  EVENT_ActorEntersTrigger("Act_1_Race.SetYourBuddies", self, hSab, self.sRacerSTrig)
  Vehicle.SetRacerNearPlayerCallback(5, "Act_1_Race.SetBuddyTalk", self)
  Vehicle.SetRaceFinishedCallback("Act_1_Race.WinLose", self)
  Vehicle.SetRaceOffTrackCallback("Act_1_Race.OffTrack", self)
  Vehicle.SetPlayerLappedCallback("Act_1_Race.Lapped", self)
  self:AuroraDamageCheck()
  EVENT_ActorDeath("Act_1_Race.CarDestroyed", self, self.hLap1Car)
  Vehicle.SetSuperHeavy(Util.GetHandleByName("Dierker"), true)
  Vehicle.SetForceSelfRight(Util.GetHandleByName("Dierker"), true)
  Vehicle.SetForceNeverFlip(Util.GetHandleByName("Dierker"), true)
  Object.SetInvincible(Util.GetHandleByName("Dierker"), true)
  local hDierker = Vehicle.GetPilot(Util.GetHandleByName("Dierker"))
  EVENT_ActorDeath("Act_1_Race.WhatdYouDo", self, hDierker)
  EVENT_ActorDeath("Act_1_Race.CrashVO", self, Util.GetHandleByName("SpeedRacer"), {
    "A1M1_CarCrash_Nazi"
  })
  EVENT_ActorDeath("Act_1_Race.CrashVO", self, Util.GetHandleByName("Skylar"), {
    "A1M1_CarCrash_Allard"
  })
  EVENT_ActorDeath("Act_1_Race.CrashVO", self, Util.GetHandleByName("Racer1"), {
    "A1M1_CarCrash_AlphaRomeo02"
  })
  EVENT_ActorDeath("Act_1_Race.CrashVO", self, Util.GetHandleByName("Racer10"), {
    "A1M1_CarCrash_General"
  })
end

function Act_1_Race:CrashVO(a_sConv)
  Cin.PlayConversation(a_sConv)
end

function Act_1_Race:AuroraDamageCheck()
  local tDamageConvos = {
    "A1M1_CarDamage_High",
    "A1M1_CarDamage_Medium",
    "A1M1_CarDamage_Low",
    "A1M1_CarDamage_Burning"
  }
  ConvoHelper.VehicleDamage(self.hLap1Car, tDamageConvos, "A1Race_DamagedConvo", {bInCar = false})
end

function Act_1_Race:AuroraDamaged()
  local iHealth = Object.GetHealth(self.hLap1Car)
  local iMaxHealth = Object.GetMaxHealth(self.hLap1Car)
  if iHealth < 150 and self.bCarConvBurn == false then
    Cin.PlayConversation("A1M1_CarDamage_Burning")
    self.bCarConvBurn = true
  elseif iHealth < iMaxHealth * 0.25 and self.bCarConvLow == false then
    self.bCarConvLow = true
    Cin.PlayConversation("A1M1_CarDamage_Low")
  elseif iHealth < iMaxHealth * 0.5 and self.bCarConvMed == false then
    self.bCarConvMed = true
    Cin.PlayConversation("A1M1_CarDamage_Medium")
  elseif iHealth < iMaxHealth * 0.75 and self.bCarConvHigh == false then
    self.bCarConvHigh = true
    Cin.PlayConversation("A1M1_CarDamage_High")
  end
end

function Act_1_Race:Lapped()
  self:PrintDebug("way to go numbnutz")
  self.bLost = true
  self.bOver = true
  self:MissionFail("blah", "A1M1_Text.Fail_Lapped")
end

function Act_1_Race:OffTrack()
  self:PrintDebug("way to go numbnutz")
end

function Act_1_Race:CarDestroyed()
  Cin.PlayConversation("A1M1_CarDamage_Destroyed", "Act_1_Race.MissionFail", self, {
    "GenericFail_Text.DESTROYED_Aurora"
  })
end

function Act_1_Race:MissionFail(a_tBlah, a_sFailString)
  self:PrintDebug("way to go dumkoff")
  Vehicle.SetRacing(false)
  self:MissionTaskFail(a_sFailString)
end

function Act_1_Race:WinLose(a_tDude)
  if self.bLost == false and a_tDude[1] ~= Util.GetHandleByName("Saboteur") then
    self.bLost = true
    Cin.PlayConversation("A1M1_Announcer_Winner_Dierker", "Act_1_Race.MissionFail", self, {
      "A1M1_Text.Fail_DierkerWins"
    })
  end
end

function Act_1_Race:Reboot()
  SaveLoad.LoadCheckpoint()
end

function Act_1_Race:MissedRace()
  self:PrintDebug("way to go numbnutz")
  self:ShowToolTip("If you don't want to drive maybe you should have stayed a mechanic.")
  EVENT_Timer("Act_1_Race.Reboot", self, 3)
end

function Act_1_Race:SetBuddyTalk(a_tDude)
  if a_tDude[1] ~= Util.GetHandleByName("Skylar") and a_tDude[1] ~= Util.GetHandleByName("Dierker") then
    local hDriver = Vehicle.GetPilot(a_tDude[1])
    for i, v in ipairs(self.tDpplRacer) do
      if a_tDude[1] == Util.GetHandleByName(v.Name) then
        self:PrintDebug("Zwineschtink Schmellin")
        local iCoin = math.random(1, 4)
        if iCoin == 1 then
        end
      end
    end
    for i, v in ipairs(self.tStartingRacers) do
      if a_tDude[1] == Util.GetHandleByName(v.Name) then
        self:PrintDebug("Hnh Hnh Hnh")
      end
    end
  end
end

function Act_1_Race:SetBuddy(a_tDude)
  self:PrintDebug("who dis?")
  if self.bRubberBand == true then
    if a_tDude[2] == true then
      if a_tDude[1] == Util.GetHandleByName("HotShit") or a_tDude[1] == Util.GetHandleByName("SpeedRacer") or a_tDude[1] == Util.GetHandleByName("Dierker") or a_tDude[1] == Util.GetHandleByName("Skylar") then
        Vehicle.SetRacerSpeed(a_tDude[1], self.iMinFast - 40, self.iMaxFast - 40)
        if a_tDude[1] == Util.GetHandleByName("Dierker") then
          Vehicle.SetRacerSpeed(a_tDude[1], self.iMinFast - 35, self.iMaxFast - 35)
        end
      else
        Vehicle.SetRacerSpeed(a_tDude[1], self.iMinFast, self.iMaxFast)
      end
    else
      if a_tDude[1] == Util.GetHandleByName("HotShit") then
        Vehicle.SetRacerSpeed(a_tDude[1], self.iMinSlow, self.iMaxSlow)
        Vehicle.SetRacerTarget(a_tDude[1], hSab, 10)
      end
      if a_tDude[1] == Util.GetHandleByName("SpeedRacer") then
        Vehicle.SetRacerSpeed(a_tDude[1], self.iMinSlow, self.iMaxSlow)
        Vehicle.SetRacerTarget(a_tDude[1], hSab, 1)
      end
      if a_tDude[1] == Util.GetHandleByName("Racer1") and self.iLap ~= 1 then
        Vehicle.SetRacerSpeed(a_tDude[1], self.iMinSlow - 20, self.iMaxSlow - 20)
        Object.SetHealth(a_tDude[1], 100)
      end
      if a_tDude[1] == Util.GetHandleByName("Racer10") and self.iLap == 1 then
        Vehicle.SetRacerSpeed(a_tDude[1], self.iMinSlow - 20, self.iMaxSlow - 20)
        Object.SetHealth(a_tDude[1], 100)
      end
      if a_tDude[1] == Util.GetHandleByName("Dierker") then
        Vehicle.SetRacerSpeed(a_tDude[1], self.iMinFast, self.iMaxFast - 35)
        Vehicle.SetRacerTarget(a_tDude[1], hSab, 2)
      end
      if a_tDude[1] == Util.GetHandleByName("Skylar") then
        Vehicle.SetRacerSpeed(a_tDude[1], self.iMinFast, self.iMaxFast - 45)
        Vehicle.SetRacerTarget(a_tDude[1], Util.GetHandleByName("Dierker"), -15)
      end
    end
  end
end

function Act_1_Race:SetBuddyShort(a_tDude)
  self:PrintDebug("who dis?")
  if a_tDude[1] == Util.GetHandleByName("Dierker") then
    local hDriver = Vehicle.GetPilot(a_tDude[1])
    if a_tDude[2] == true and a_tDude[3] == false then
      Cin.StopCinematic("StuntJump_Saar_Rock06")
      Util.SetTimeScale(1)
      Sound.SetMusicLocale("A1M1_Race")
      Sound.SetMusicLocale("m_A1M1_Race", "A1M1_ahead")
      if self.bDisDead == false then
        self:CheatCinematicSetup()
      end
    end
  end
end

function Act_1_Race:SetBuddyLong(a_tDude)
  self:PrintDebug("who dis?")
  if self.bRubberBand == true then
    if a_tDude[2] == true then
      Vehicle.SetRacerSpeed(a_tDude[1], self.iMinSlow - 20, self.iMaxSlow - 20)
      Vehicle.SetRacerTarget(a_tDude[1], hSab, 2)
    elseif a_tDude[1] == Util.GetHandleByName("Dierker") then
      Sound.SetMusicLocale("m_A1M1_Race", "A1M1_behind")
      if 20 < self.iSabPlace then
        Cin.PlayConversation("A1M1_Announcer_DierkerTalk_01")
      elseif self.iSabPlace > 10 then
        Cin.PlayConversation("A1M1_Announcer_DierkerTalk_02")
      end
      Vehicle.SetRacerSpeed(a_tDude[1], self.iMinFast - 15, self.iMaxFast - 30)
      Vehicle.SetRacerTarget(a_tDude[1], hSab, 2)
    elseif a_tDude[1] == Util.GetHandleByName("Skylar") then
      Vehicle.SetRacerSpeed(a_tDude[1], self.iMinSlow, self.iMaxSlow)
      Vehicle.SetRacerTarget(a_tDude[1], Util.GetHandleByName("Dierker"), -25)
    else
      Vehicle.SetRacerSpeed(a_tDude[1], self.iMinSlow - 10, self.iMaxSlow - 10)
      Vehicle.SetRacerTarget(a_tDude[1], hSab, 2)
    end
  end
end

function Act_1_Race:PlaneStart()
  Cin.PlayCinematic("A1M1_PlaneStart")
  Cin.PlayConversation("A1M1_Announcer_PlaneFlyBy")
end

function Act_1_Race:PlaneFarm()
  Cin.PlayCinematic("A1M1_PlaneFarm")
end

function Act_1_Race:CreateRacers(tTestRaceData, a_sTrack, a_iLap, a_fMinSpeed, a_fMaxSpeed)
  self:PrintDebug("Assemble the Field")
  for i, v in ipairs(tTestRaceData) do
    local a_tRacer = v
    if a_fMinSpeed ~= nil then
      local iRandom = math.random(1, 10)
      Vehicle.CreateRacer(a_tRacer.Name, a_tRacer.Car, "PILOT", a_tRacer.Driver, a_sTrack, a_iLap, a_fMinSpeed, a_fMaxSpeed + iRandom)
    else
      Vehicle.CreateRacer(a_tRacer.Name, a_tRacer.Car, "PILOT", a_tRacer.Driver, a_sTrack, a_iLap)
    end
  end
end

function Act_1_Race:SpawnRacers(tEventArgs, tTestRaceData)
  self:PrintDebug("Go Speed Racer, Go")
  for i, v in ipairs(tTestRaceData) do
    local a_tRacer = v
    local x, y, z = Object.GetPosition(Util.GetHandleByName(a_tRacer.Locator))
    Vehicle.SpawnRacer(a_tRacer.Name, x, y, z)
  end
end

function Act_1_Race:BreakShit(a_hCar, a_sDamageGroup)
  Damage.SetDamageState(a_hCar, a_sDamageGroup, 1)
end

function Act_1_Race:Task_BeatDierker()
  self:CreateTask({
    sName = "Task_BeatDierker",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestProximityObj = {
      Util.GetHandleByName("Dierker")
    },
    tDeliverObjs = {hSab},
    Proximity = 1,
    bNoGroundBlip = true,
    bNoGPS = true,
    tOnActivate = {
      {
        HUD.ClearGPSTarget,
        {}
      }
    },
    tOnComplete = {}
  })
end

function Act_1_Race:Task_MainRaceCP1()
  self:CreateTask({
    sName = "Task_MainRaceCP1" .. self.iLap,
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = self.tInfo.REG_CP1,
    bNoWorldBlip = true,
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        self.Task_MainRaceCP2,
        {self}
      }
    }
  })
end

function Act_1_Race:SetYourBuddies()
  Vehicle.SetRacerNearPlayerCallback(20, "Act_1_Race.SetBuddy", self)
  Vehicle.SetRacerNearPlayerCallback(10, "Act_1_Race.SetBuddyShort", self)
  Vehicle.SetRacerNearPlayerCallback(75, "Act_1_Race.SetBuddyLong", self)
  self.bDierkerSpotted = false
  local tLocSee = {
    EventType = "SeeLocatorEvent",
    InViewTime = 2,
    Locator = Util.GetHandleByName("Dierker")
  }
  self:AddEvent(Util.CreateEvent(tLocSee, "Act_1_Race.SpotDierker", self))
end

function Act_1_Race:SpotDierker()
  if self.bDierkerSpotted == false then
    Cin.PlayConversation("A1M1_Dierker_Detected")
    self.bDierkerSpotted = true
  end
end

function Act_1_Race:PlaceChange(a_tPlace)
  local iPlace = a_tPlace[1]
  if iPlace == 1 and self.bLost == false then
    self.bOver = true
    Cin.StopCinematic("StuntJump_Saar_Rock06")
    Util.SetTimeScale(1)
    Sound.SetMusicLocale("A1M1_Race")
    Sound.SetMusicLocale("m_A1M1_Race", "A1M1_ahead")
    if self.bDisDead == false then
      self:CheatCinematicSetup()
    end
  elseif self.bConvBusy == false and self.bOver == false then
    if 1 < self.iLap then
      self.bRubberBand = true
    else
      self.bRubberBand = false
    end
    if iPlace == 10 and self.bTenth == false then
      self.bTenth = true
      self:PlaceConv("A1M1_Position_Place_10")
    elseif iPlace == 6 and self.bFifth == false then
      self.bFifth = true
      self:PlaceConv("A1M1_Position_Place_05")
    elseif iPlace == 2 and self.bSecond == false then
      self.bSecond = true
      self:PlaceConv("A1M1_Position_Place_02")
    elseif iPlace < self.iSabPlace then
      local iCoin = math.random(1, 5)
      if iCoin == 1 and #self.tPlaceChangeClimb > 0 then
        local iRand = math.random(1, #self.tPlaceChangeClimb)
        self:PlaceConv(self.tPlaceChangeClimb[iRand])
        table.remove(self.tPlaceChangeClimb, iRand)
      end
    else
      local iCoin = math.random(1, 5)
      if iCoin == 1 and 0 < #self.tPlaceChangeFall then
        local iRand = math.random(1, #self.tPlaceChangeFall)
        self:PlaceConv(self.tPlaceChangeFall[iRand])
        table.remove(self.tPlaceChangeFall, iRand)
      else
      end
    end
  end
  self.iSabPlace = iPlace
  self:PrintDebug(self.iSabPlace)
end

function Act_1_Race:PlaceConv(a_sConv)
  self.bConvBusy = true
  Cin.PlayConversation(a_sConv, "Act_1_Race.ResetConvBusy", self)
end

function Act_1_Race:GeneralConv(a_sConv)
  if self.bConvBusy == false then
    self.bConvBusy = true
    Cin.PlayConversation(a_sConv, "Act_1_Race.ResetConvBusy", self)
  end
end

function Act_1_Race:ConvDelay()
  self:DramaticPause(4, "Act_1_Race.ResetConvBusy")
end

function Act_1_Race:ResetConvBusy()
  self.bConvBusy = false
end

function Act_1_Race:Task_MainRaceCP2()
  self:CreateTask({
    sName = "Task_MainRaceCP2" .. self.iLap,
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = self.tInfo.REG_CP2,
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        self.GeneralConv,
        {
          self,
          "A1M1_Announcer_Chatter_General"
        }
      },
      {
        self.Task_MainRaceCP3,
        {self}
      }
    }
  })
end

function Act_1_Race:Task_MainRaceCP3()
  self:CreateTask({
    sName = "Task_MainRaceCP3" .. self.iLap,
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = self.tInfo.REG_CP3,
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        self.Task_MainRaceCP4,
        {self}
      }
    }
  })
end

function Act_1_Race:Task_MainRaceCP4()
  self:CreateTask({
    sName = "Task_MainRaceCP4" .. self.iLap,
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = self.tInfo.REG_CP4,
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        self.LapCheck,
        {self}
      },
      {
        self.Task_MainRaceCP1,
        {self}
      }
    }
  })
end

function Act_1_Race:LapCheck()
  if self.iLap == 1 then
    EVENT_ActorEntersTrigger("Act_1_Race.PlaneStart", self, hSab, self.sRacerStartTrig)
    EVENT_ActorEntersTrigger("Act_1_Race.PlaneFarm", self, hSab, "Missions\\act_1\\race\\main\\PT_FarmFlyby")
    for i, v in ipairs(self.tGroup1) do
      Vehicle.SetRacerSpeed(v, self.iMinSlow - 10, self.iMaxSlow - 10)
      Vehicle.OverrideHorsepower(v, true, 200)
      Vehicle.SetRacerTarget(v, Util.GetHandleByName("Dierker"), -15)
    end
    for i, v in ipairs(self.tOtherRacers) do
      Vehicle.SetRacerSpeed(v, self.iMinSlow - 10, self.iMaxSlow - 10)
      Vehicle.OverrideHorsepower(v, true, 200)
      Vehicle.SetRacerTarget(v, Util.GetHandleByName("Dierker"), -15)
    end
    Vehicle.SetRacerSpeed(Util.GetHandleByName("Dierker"), self.iMinSlow - 10, self.iMaxSlow - 10)
  end
  self.iLap = self.iLap + 1
end

function Act_1_Race:Task_MainRaceCPFinishLine()
  self:CreateTask({
    sName = "Task_MainRaceCPFinishLine",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = self.tInfo.REG_FinishLine,
    tLocators = {
      self.tInfo.LOC_FinishLine
    },
    tDeliverObjs = {hSab},
    tOnActivate = {
      {
        self.SlowDierker,
        {self}
      }
    },
    tOnComplete = {}
  })
end

function Act_1_Race:CheatCinematicSetup()
  if self.bLost == false then
    self.bOver = true
    self.bLost = true
    ConvoHelper.ClearAll()
    for i, v in ipairs(self.tAllConversations) do
      Cin.StopConversation(v)
    end
    self:Task_CheatBink()
    self:DramaticPause(1, "Act_1_Race.StopCar")
  end
end

function Act_1_Race:StopCar()
  Vehicle.SetRacing(false)
  Vehicle.HardSetLinVel(self.hLap1Car, 0)
  if Actor.IsInVehicle(hSab) then
    Actor.UnboardVehicle(hSab)
    EVENT_PlayerExitsAnyVehicle("Act_1_Race.Teleport2Cheat", self)
  else
    self:Teleport2Cheat()
  end
end

function Act_1_Race:Teleport2Cheat()
  self:UnloadTaskNodes("Task_LoadCarNode", true)
  self.bCarGone = true
  if self.bCheatDone == true then
    self:CompleteThisMission()
  end
end

function Act_1_Race:QuitCheck()
  self.bCheatDone = true
  if self.bCarGone == true then
    self:CompleteThisMission()
  end
end

function Act_1_Race:TunnelCrashSquib(tEventArgs)
  self:PrintDebug("boom")
  Object.Kill(tEventArgs[2])
  Object.Kill(Util.GetHandleByName("Missions\\act_1\\race\\main\\Squib_TunnelCrash"))
  Cin.PlayConversation("A1M1_CarCrash_AlphaRomeo02")
end

function Act_1_Race:CrashSquib(tEventArgs)
  self:PrintDebug("boom")
  Object.Kill(Util.GetHandleByName("Missions\\act_1\\race\\main\\Squib_CrowdCrash_Fire"))
  Object.Kill(tEventArgs[2])
end

function Act_1_Race:StepOne()
  Vehicle.SetRacePlaceChangeCallback("Act_1_Race.PlaceChange", self)
end

function Act_1_Race:SpawnTunnelCrash()
  Veh.SpawnDelivery(self, self.tCrashers[1])
  Vehicle.SetRacePlaceChangeCallback("Act_1_Race.PlaceChange", self)
end

function Act_1_Race:Gopher_1()
  ACTOR_RunPathOnce("Missions\\act_1\\race\\towncrowd\\Spore_CV_Gopher_1", "Missions\\act_1\\race\\towncrowd\\PATH_Gopher_1")
end

function Act_1_Race:SpawnCrowdCrash()
  if self.iSabPlace > 5 then
    Veh.SpawnDelivery(self, self.tCrashers[2])
  end
end

function Act_1_Race:CrowdCrashCam()
  Util.SetTimeScale(0.5)
  Cin.PlayCinematic("A1M1_CrashCam")
  EVENT_Timer("Act_1_Race.EndCrowdCrashCam", self, 2)
end

function Act_1_Race:EndCrowdCrashCam()
  Util.SetTimeScale(1)
end

function Act_1_Race:TunnelCrash(a_hTunnelCrasher)
  local hDude = Vehicle.GetPilot(a_hTunnelCrasher)
  Actor.SetBailWhenVehicleOnFire(hDude, false)
  EVENT_ActorEntersTrigger("Act_1_Race.TunnelCrashSquib", self, a_hTunnelCrasher, "Missions\\act_1\\race\\main\\PT_TunnelBoom")
  Vehicle.StartPlayback(a_hTunnelCrasher, "A1Race_Crash1.vcr")
  self.BreakShit(self, a_hTunnelCrasher, "wheel_fr")
  Vehicle.StartFireEffect(a_hTunnelCrasher)
  Sound.ActivateSoundEmitter("CountrySide\\alsace\\racetracks\\sound\\A1M1_TunnelCrash")
end

function Act_1_Race:CrowdCrash(a_hCrasher)
  local hDude = Vehicle.GetPilot(a_hCrasher)
  Actor.SetBailWhenVehicleOnFire(hDude, false)
  EVENT_ActorEntersTrigger("Act_1_Race.CrashSquib", self, a_hCrasher, "Missions\\act_1\\race\\main\\PT_CrowdCrash_Boom", "Missions\\act_1\\race\\main\\Squib_CrowdCrash_Fire")
  Vehicle.StartPlayback(a_hCrasher, "A1Race_Crash2.vcr")
  self.BreakShit(self, a_hCrasher, "wheel_fr")
  Vehicle.StartFireEffect(a_hCrasher)
  Sound.ActivateSoundEmitter("CountrySide\\alsace\\racetracks\\sound\\A1M1_CarCrash")
  local tPanicGroup = {}
  local tCrowdnames = {
    "\\Spore_WPop_MiddleClass",
    "\\Spore_WPop_MiddleClass(2)",
    "\\Spore_WPop_MiddleClass(3)",
    "\\Spore_WPop_MiddleClass(4)",
    "\\Spore_WPop_MiddleClass(5)",
    "\\Spore_WPop_MiddleClass(6)",
    "\\Spore_WPop_MiddleClass(7)",
    "\\Spore_WPop_MiddleClass(8)"
  }
  local sPrefix = "Missions\\act_1\\race\\towncrowd\\PRaceCPRS_PanicCrowd_"
  for nCount = 1, 10 do
    for i, v in ipairs(tCrowdnames) do
      local sWhatsThis = sPrefix .. tostring(nCount) .. tCrowdnames[i]
      table.insert(tPanicGroup, sPrefix .. tostring(nCount) .. tCrowdnames[i])
    end
  end
  for i, v in ipairs(tPanicGroup) do
    if Util.GetHandleByName(v) ~= nil then
      Actor.AddSafetyNeed(Util.GetHandleByName(v), -100, a_hCrasher)
    end
  end
  Cin.PlayConversation("A1M1_CarCrash_Maseriti")
end

function Act_1_Race:Task_CheatBink()
  Cin.SetExitMusicOverride("cin_116_CinB_FollowD", "Cinematic", "In", "Cinematic")
  self:CreateTask({
    sName = "Task_CheatBink",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "115_CinA_CheatBINK",
    bOverrideFade = true,
    tOnActivate = {},
    tOnComplete = {
      {
        self.QuitCheck,
        {self}
      }
    }
  })
end

function Act_1_Race:MISSION_ONRESET()
  print("CLEANUP RACE")
  Util.SetDisableControls("EnterExitVehicle", false)
  HUD.ClearGPSCourse()
  Suspicion.EnableGlobal(true)
  Suspicion.EnableEscalation(true)
  Vehicle.EnableTraffic(true)
  Vehicle.SetRacing(false)
  Sound.ResetMusicLocale()
  Sound.UnloadSoundBank("m_A1M1_inGame.bnk")
  Sound.EnableSeanChatter()
  self:ClearEvents()
  Util.LoadStaticENTag("wpop", true)
  Util.LoadStaticENTag("A1M1_RaceClosed", true)
  Util.UnloadStaticENTag("A1M1_RACE", true)
  Util.UnloadStaticENTag("A1M1_RACE_GO", true)
  Util.UnloadStaticENTag("A1M1_RACE_PIT", true)
  Util.UnloadStaticENTag("A1_GPRace", true)
  Util.EnableSuperSpores(true)
  Util.SetDisableAuroraGuns(false)
  WorldSMEDNodes.UnloadNode("Missions\\act_1\\race\\arrivals", true)
  WorldSMEDNodes.UnloadNode("Missions\\act_1\\race\\part1", true)
  Actor.RemoveDisguise(hSab)
end

function Act_1_Race:AddEvent(a_eEvent)
  if not self.tEvents then
    self.tEvents = {}
  end
  table.insert(self.tEvents, a_eEvent)
  self:RegisterEvent(a_eEvent)
end

function Act_1_Race:ClearEvents()
  if self.tEvents then
    for i, e in ipairs(self.tEvents) do
      Util.KillEvent(e)
    end
    self.tEvents = {}
  end
end

function Act_1_Race:DramaticPause(a_nTime, a_sCallbackFunction)
  EVENT_Timer(a_sCallbackFunction, self, a_nTime)
end

function Act_1_Race:PrintDebug(a_sMessage)
  if self.DEBUGMODE == true then
    Render.PrintMessage(a_sMessage)
  end
end

function Act_1_Race:WhatdYouDo()
  Render.FadeScreen(true)
  self.bDisDead = true
  if Actor.IsInVehicle(hSab) then
    Actor.UnboardVehicle(hSab)
    EVENT_PlayerExitsAnyVehicle("Act_1_Race.Suprise", self)
  else
    self:Suprise()
  end
end

function Act_1_Race:Suprise()
  self:CreateTask({
    sName = "Suprise",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tSMEDNodes = {
      gsA1Race .. "speedrun"
    },
    bCompleteOnActivate = true,
    tOnActivate = {},
    tOnComplete = {
      {
        self.SpeedRun,
        {self}
      }
    }
  })
end

function Act_1_Race:SpeedRun()
  Object.PlayerTeleportToLocator(Util.GetHandleByName("Missions\\act_1\\race\\speedrun\\LOC_SpeedRun"), false, true, "Act_1_Race.Easter", self)
end

function Act_1_Race:Easter()
  Util.LoadDynamicNode("end_credits", "Act_1_Race.TASK_Credits", self)
end

function Act_1_Race:TASK_Credits()
  self:CreateTask({
    sName = "TASK_Credits",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "Credit_Splines",
    tOnActivate = {},
    tOnComplete = {
      {
        RewardsManager.AchievementGrant,
        {"DIERKER"}
      },
      {
        self.Redo,
        {self}
      }
    },
    tSMEDNodes = {
      "Missions\\cinematics\\credits"
    },
    tStaticTags = {}
  })
end

function Act_1_Race:Redo()
  self.bEasterEgg = true
  Util.SetDisableAuroraGuns(true)
  Util.UnloadDynamicNode("end_credits")
  self:UnloadTaskNodes("TASK_Credits", true)
  self:UnloadTaskNodes("Suprise", true)
  self:MissionTaskFail("FP_CountryRace01.FAIL_OtherCarBoom")
end
