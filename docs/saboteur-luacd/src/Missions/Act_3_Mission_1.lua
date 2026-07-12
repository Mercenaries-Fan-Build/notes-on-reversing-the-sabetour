if Act_3_Mission_1 == nil then
  Act_3_Mission_1 = SabTaskObjective:Create()
  gsAct3Mission1Dir = "Missions\\Act_3\\Mission_1\\"
  Act_3_Mission_1:Configure({
    TaskCount = 50,
    sAreaID = "ACT_3",
    bStarterless = true,
    sSaveMissionNameID = "MissionNames_Text.A3M1",
    sHQStartPoint = _cHQ_CATACOMBS,
    sHQNextMissionStartPoint = _cHQe_BELLERETURN,
    tUnlockList = {
      "Connect_A3_M1b_ReturnToBelle"
    },
    bSLOverrideFade = true,
    tSMEDNodes = {
      gsAct3Mission1Dir .. "starter"
    },
    WTFZoneHigh = "WtF_Zones\\global\\A3M2_DierkerShowdown"
  })
end

function Act_3_Mission_1:STARTER_Setup()
  self.bDebugPreserveMission = true
end

function Act_3_Mission_1:Activated()
  SabTaskObjective.Activated(self)
  self.bE3 = false
  self.CinematicCheck(self)
end

function Act_3_Mission_1:GENERAL_Setup()
  self.DEBUGMODE = true
  self.sTrigLap1 = gsAct3Mission1Dir .. "main\\PT_lap1setup"
  self.sTrigStartRacers = gsAct3Mission1Dir .. "main\\PT_startracers"
  self.sTrigArcRacers = gsAct3Mission1Dir .. "main\\PT_ArcRacers"
  self.sTrigPantheonRacers = gsAct3Mission1Dir .. "main\\PT_PantheonRacers"
  self.sTrigBridgeRacers = gsAct3Mission1Dir .. "main\\PT_BridgeRacers"
  self.sTrigLap1Racers = gsAct3Mission1Dir .. "main\\PT_Lap1Racers"
  self.sAngryNazis = gsAct3Mission1Dir .. "main\\PT_AngryNazis"
  self.sTrigRiverCrash = gsAct3Mission1Dir .. "main\\PT_RiverCrash"
  self.sTrigRiverSquib = gsAct3Mission1Dir .. "main\\PT_RiverCrash_Squib"
  self.sTrigBridgeCrash = gsAct3Mission1Dir .. "main\\PT_BridgeCrash"
  self.sTrigBridgeSquib = gsAct3Mission1Dir .. "main\\PT_BridgeCrash_Squib"
  self.sTrigStartCrash = gsAct3Mission1Dir .. "main\\PT_StartCrash"
  self.sTrigStartSquib = gsAct3Mission1Dir .. "main\\PT_StartCrash_Squib"
  self.sTrigPorthos = gsAct3Mission1Dir .. "main\\PT_Porthos"
  self.sTrigAthos = gsAct3Mission1Dir .. "main\\PT_Athos"
  self.sTrigAramis = gsAct3Mission1Dir .. "main\\PT_Aramis"
  self.sTrigDartagnan = gsAct3Mission1Dir .. "main\\PT_Dartagnan"
  self.sStartSquib = gsAct3Mission1Dir .. "main\\Squib_StartCrash"
  self.sRiverSquib = gsAct3Mission1Dir .. "main\\Squib_RiverCrash"
  self.sBridgeSquib = gsAct3Mission1Dir .. "main\\Squib_BridgeCrash"
  self.sBridgePlaneSquib = gsAct3Mission1Dir .. "main\\Squib_BridgePlane"
  self.sTrigStartingLine = gsAct3Mission1Dir .. "main\\startingline"
  self.sTrigCheckpoint1 = gsAct3Mission1Dir .. "checkpoints\\1"
  self.sTrigCheckpoint2 = gsAct3Mission1Dir .. "checkpoints\\2"
  self.sTrigCheckpoint3 = gsAct3Mission1Dir .. "checkpoints\\3"
  self.sTrigCheckpoint4 = gsAct3Mission1Dir .. "checkpoints\\4"
  self.sTrigCheckpoint5 = gsAct3Mission1Dir .. "checkpoints\\5"
  self.sTrigCheckpoint6 = gsAct3Mission1Dir .. "checkpoints\\6"
  self.sTrigCheckpoint7 = gsAct3Mission1Dir .. "checkpoints\\7"
  self.sTrigCheckpoint8 = gsAct3Mission1Dir .. "checkpoints\\8"
  self.sTrigCheckpoint9 = gsAct3Mission1Dir .. "checkpoints\\9"
  self.sTrigCheckpoint10 = gsAct3Mission1Dir .. "checkpoints\\10"
  self.sTrigCheckpoint11 = gsAct3Mission1Dir .. "checkpoints\\11"
  self.sTrigCheckpoint12 = gsAct3Mission1Dir .. "checkpoints\\12"
  self.sLOCStartingLine = gsAct3Mission1Dir .. "main\\LOC_StartingLine"
  self.sLOCCheckpoint1 = gsAct3Mission1Dir .. "checkpoints\\LOC_StartingLine"
  self.sLOCCheckpoint2 = gsAct3Mission1Dir .. "checkpoints\\LOC_Dierker"
  self.sLOCCheckpoint3 = gsAct3Mission1Dir .. "checkpoints\\LOC_SSHQ"
  self.sLOCCheckpoint4 = gsAct3Mission1Dir .. "checkpoints\\LOC_StSulpice"
  self.sLOCCheckpoint5 = gsAct3Mission1Dir .. "checkpoints\\LOC_IledeCite"
  self.sLOCCheckpoint6 = gsAct3Mission1Dir .. "checkpoints\\LOC_OperaHouse"
  self.sLOCCheckpoint7 = gsAct3Mission1Dir .. "checkpoints\\LOC_Madeline"
  self.sLOCCheckpoint8 = gsAct3Mission1Dir .. "checkpoints\\LOC_ParcMarceau"
  self.sLOCCheckpoint9 = gsAct3Mission1Dir .. "checkpoints\\LOC_Arc"
  self.sLOCCheckpoint10 = gsAct3Mission1Dir .. "checkpoints\\LOC_ChampsTheatre"
  self.sLOCCheckpoint11 = gsAct3Mission1Dir .. "checkpoints\\LOC_GrandPalais"
  self.sLOCCheckpoint12 = gsAct3Mission1Dir .. "checkpoints\\LOC_HotelInvalides"
  self.tPorthos = {}
  self.tPorthos.Name = "Porthos"
  self.tPorthos.Locator = gsAct3Mission1Dir .. "main\\LOC_Porthos"
  self.tPorthos.Car = "VH_CV_CR_SilverDartDierker_01_Race"
  self.tPorthos.Driver = "Human_NZ_RaceDriver"
  self.tAthos = {}
  self.tAthos.Name = "Athos"
  self.tAthos.Locator = gsAct3Mission1Dir .. "main\\LOC_Athos"
  self.tAthos.Car = "VH_CV_CR_SilverDartDierker_01_Race"
  self.tAthos.Driver = "Human_NZ_RaceDriver"
  self.tAramis2 = {}
  self.tAramis2.Name = "Aramis2"
  self.tAramis2.Locator = gsAct3Mission1Dir .. "main\\LOC_Aramis2"
  self.tAramis2.Car = "VH_CV_CR_SilverDartDierker_01_Race"
  self.tAramis2.Driver = "Human_NZ_RaceDriver"
  self.tDartagnan2 = {}
  self.tDartagnan2.Name = "Dartagnan2"
  self.tDartagnan2.Locator = gsAct3Mission1Dir .. "main\\LOC_Dartagnan2"
  self.tDartagnan2.Car = "VH_CV_CR_SilverDartDierker_01_Race"
  self.tDartagnan2.Driver = "Human_NZ_RaceDriver"
  self.tAramis = {}
  self.tAramis.Name = "Aramis"
  self.tAramis.Locator = gsAct3Mission1Dir .. "main\\LOC_Aramis"
  self.tAramis.Car = "VH_CV_CR_SilverDartDierker_01_Race"
  self.tAramis.Driver = "Human_NZ_RaceDriver"
  self.tDartagnan = {}
  self.tDartagnan.Name = "Dartagnan"
  self.tDartagnan.Locator = gsAct3Mission1Dir .. "main\\LOC_Dartagnan"
  self.tDartagnan.Car = "VH_CV_CR_SilverDartDierker_01_Race"
  self.tDartagnan.Driver = "Human_NZ_RaceDriver"
  self.tDierker = {}
  self.tDierker.Name = "Dierker"
  self.tDierker.Locator = gsAct3Mission1Dir .. "main\\LOC_Dierker"
  self.tDierker.Car = "VH_CV_CR_Dierker_01_Race"
  self.tDierker.Driver = "Human_NZ_Dierker_RaceDriver"
  self.tStartingRacers = {}
  self.tStartingRacers[1] = {}
  self.tStartingRacers[1].Name = "RacerX"
  self.tStartingRacers[1].Locator = gsAct3Mission1Dir .. "main\\LOC_RacerX"
  self.tStartingRacers[1].Car = "VH_CV_CR_SilverDart_01"
  self.tStartingRacers[1].Driver = "Human_NZ_RaceDriver"
  self.tStartingRacers[2] = {}
  self.tStartingRacers[2].Name = "SpeedRacer"
  self.tStartingRacers[2].Locator = gsAct3Mission1Dir .. "main\\LOC_SpeedRacer"
  self.tStartingRacers[2].Car = "VH_CV_CR_Allard_01"
  self.tStartingRacers[2].Driver = "Human_NZ_RaceDriver"
  self.tStartingRacers[3] = {}
  self.tStartingRacers[3].Name = "RacerA"
  self.tStartingRacers[3].Locator = gsAct3Mission1Dir .. "main\\LOC_RacerA"
  self.tStartingRacers[3].Car = "VH_CV_CR_AlfaRom_12C_01"
  self.tStartingRacers[3].Driver = "Human_NZ_RaceDriver"
  self.tStartingRacers[4] = {}
  self.tStartingRacers[4].Name = "RacerB"
  self.tStartingRacers[4].Locator = gsAct3Mission1Dir .. "main\\LOC_RacerB"
  self.tStartingRacers[4].Car = "VH_CV_CR_AlfaRomera_01"
  self.tStartingRacers[4].Driver = "Human_NZ_RaceDriver"
  self.tStartingRacers[5] = {}
  self.tStartingRacers[5].Name = "RacerC"
  self.tStartingRacers[5].Locator = gsAct3Mission1Dir .. "main\\LOC_RacerC"
  self.tStartingRacers[5].Car = "VH_CV_CR_MaterTipo4CL_01"
  self.tStartingRacers[5].Driver = "Human_NZ_RaceDriver"
  self.tStartingRacers[6] = {}
  self.tStartingRacers[6].Name = "RacerD"
  self.tStartingRacers[6].Locator = gsAct3Mission1Dir .. "main\\LOC_RacerD"
  self.tStartingRacers[6].Car = "VH_CV_CR_AlfaRomera_01"
  self.tStartingRacers[6].Driver = "Human_NZ_RaceDriver"
  self.tStartingRacers[7] = {}
  self.tStartingRacers[7].Name = "RacerCC"
  self.tStartingRacers[7].Locator = gsAct3Mission1Dir .. "main\\LOC_RacerCC"
  self.tStartingRacers[7].Car = "VH_CV_CR_AlfaRom_12C_01"
  self.tStartingRacers[7].Driver = "Human_NZ_RaceDriver"
  self.tStartingRacers[8] = {}
  self.tStartingRacers[8].Name = "RacerDD"
  self.tStartingRacers[8].Locator = gsAct3Mission1Dir .. "main\\LOC_RacerDD"
  self.tStartingRacers[8].Car = "VH_CV_CR_AlfaRomera_01"
  self.tStartingRacers[8].Driver = "Human_NZ_RaceDriver"
  self.tLap1Racers = {}
  self.tLap1Racers[1] = {}
  self.tLap1Racers[1].Name = "Lap1Racer_A"
  self.tLap1Racers[1].Locator = gsAct3Mission1Dir .. "main\\LOC_Lap1Racer_A"
  self.tLap1Racers[1].Car = "VH_CV_CR_SilverDartDierker_01_Race"
  self.tLap1Racers[1].Driver = "Human_NZ_RaceDriver"
  self.tLap1Racers[2] = {}
  self.tLap1Racers[2].Name = "Lap1Racer_B"
  self.tLap1Racers[2].Locator = gsAct3Mission1Dir .. "main\\LOC_Lap1Racer_B"
  self.tLap1Racers[2].Car = "VH_CV_CR_SilverDartDierker_01_Race"
  self.tLap1Racers[2].Driver = "Human_NZ_RaceDriver"
  self.tStartDarts = {}
  self.tStartDarts[1] = {}
  self.tStartDarts[1].Name = "DartStart0"
  self.tStartDarts[1].Locator = gsAct3Mission1Dir .. "main\\LOC_DartStart_0"
  self.tStartDarts[1].Car = "VH_CV_CR_SilverDartDierker_01_Race"
  self.tStartDarts[1].Driver = "Human_NZ_RaceDriver"
  self.tStartDarts[2] = {}
  self.tStartDarts[2].Name = "DartStart1"
  self.tStartDarts[2].Locator = gsAct3Mission1Dir .. "main\\LOC_DartStart_1"
  self.tStartDarts[2].Car = "VH_CV_CR_SilverDartDierker_01_Race"
  self.tStartDarts[2].Driver = "Human_NZ_RaceDriver"
  self.tStartDarts[3] = {}
  self.tStartDarts[3].Name = "DartStart2"
  self.tStartDarts[3].Locator = gsAct3Mission1Dir .. "main\\LOC_DartStart_2"
  self.tStartDarts[3].Car = "VH_CV_CR_SilverDartDierker_01_Race"
  self.tStartDarts[3].Driver = "Human_NZ_RaceDriver"
  self.tStartDarts[4] = {}
  self.tStartDarts[4].Name = "DartStart3"
  self.tStartDarts[4].Locator = gsAct3Mission1Dir .. "main\\LOC_DartStart_3"
  self.tStartDarts[4].Car = "VH_CV_CR_SilverDartDierker_01_Race"
  self.tStartDarts[4].Driver = "Human_NZ_RaceDriver"
  self.tPantheonRacers = {}
  self.tPantheonRacers[1] = {}
  self.tPantheonRacers[1].Name = "Nazi1"
  self.tPantheonRacers[1].Locator = gsAct3Mission1Dir .. "main\\LOC_Nazi1"
  self.tPantheonRacers[1].Car = "VH_CV_CR_SilverDart_01"
  self.tPantheonRacers[1].Driver = "Human_NZ_RaceDriver"
  self.tPantheonRacers[2] = {}
  self.tPantheonRacers[2].Name = "Nazi2"
  self.tPantheonRacers[2].Locator = gsAct3Mission1Dir .. "main\\LOC_Nazi2"
  self.tPantheonRacers[2].Car = "VH_CV_CR_MaterTipo4CL_01"
  self.tPantheonRacers[2].Driver = "Human_NZ_RaceDriver"
  self.tBridgeRacers = {}
  self.tBridgeRacers[1] = {}
  self.tBridgeRacers[1].Name = "RacerBridgeA"
  self.tBridgeRacers[1].Locator = gsAct3Mission1Dir .. "main\\LOC_RacerBridgeA"
  self.tBridgeRacers[1].Car = "VH_CV_CR_SilverDart_01"
  self.tBridgeRacers[1].Driver = "Human_NZ_RaceDriver"
  self.tTheCardinalsMen = {
    "DartStart0",
    "DartStart1",
    "Athos",
    "Porthos",
    "Aramis",
    "Aramis2",
    "Dartagnan",
    "Dartagnan2"
  }
  self.tNaziChasers = {}
  self.tNaziChasers[1] = {}
  self.tNaziChasers[1].sName = "NaziChaser1"
  self.tNaziChasers[1].vSpawnTarget = gsAct3Mission1Dir .. "main\\LOC_AttackTruck"
  self.tNaziChasers[1].cVehicleType = cVEH_KUBELTURRET
  self.tNaziChasers[1].tSeatConfig = "Human_NZ_RaceDriver"
  self.tNaziChasers[1].bForceSpawn = true
  self.tNaziChasers[1].cDespawnType = cDESPAWN_NONE
  self.tNaziChasers[1].sDeliveryPath = gsAct3Mission1Dir .. "main\\PATH_ChaserEnter"
  self.tNaziChasers[1].cUnboardType = cDROPOFF_NONE
  self.tNaziChasers[1].nPathSpeed = 80
  self.tNaziChasers[1].tOnArrive = {
    {
      "Act_3_Mission_1.ChaserRace",
      {
        self.tNaziChasers[1].sName
      }
    }
  }
  self.tNaziChasers[2] = {}
  self.tNaziChasers[2].sName = "NaziChaser2"
  self.tNaziChasers[2].vSpawnTarget = gsAct3Mission1Dir .. "main\\LOC_AttackTruck(2)"
  self.tNaziChasers[2].cVehicleType = cVEH_KUBELTURRET
  self.tNaziChasers[2].tSeatConfig = "Human_NZ_RaceDriver"
  self.tNaziChasers[2].bForceSpawn = true
  self.tNaziChasers[2].cDespawnType = cDESPAWN_NONE
  self.tNaziChasers[2].sDeliveryPath = gsAct3Mission1Dir .. "main\\PATH_ChaserJump"
  self.tNaziChasers[2].cUnboardType = cDROPOFF_NONE
  self.tNaziChasers[2].nPathSpeed = 80
  self.tNaziChasers[2].tOnArrive = {
    {
      "Act_3_Mission_1.ChaserRace",
      {
        self.tNaziChasers[2].sName
      }
    }
  }
  self.tPreStartSpeakers = {
    Util.GetHandleByName(gsAct3Mission1Dir .. "main\\Race_loudspeaker_prestart"),
    Util.GetHandleByName(gsAct3Mission1Dir .. "main\\Race_loudspeaker_prestart2"),
    Util.GetHandleByName(gsAct3Mission1Dir .. "main\\Race_loudspeaker_prestart3"),
    Util.GetHandleByName(gsAct3Mission1Dir .. "main\\Race_loudspeaker_prestart4")
  }
  self.tPitRoadSpeakers = {
    Util.GetHandleByName(gsAct3Mission1Dir .. "main\\Race_loudspeaker_prestart5"),
    Util.GetHandleByName(gsAct3Mission1Dir .. "main\\Race_loudspeaker_prestart6"),
    Util.GetHandleByName(gsAct3Mission1Dir .. "main\\Race_loudspeaker_prestart7"),
    Util.GetHandleByName(gsAct3Mission1Dir .. "main\\Race_loudspeaker_prestart8")
  }
  self.tStartSpeakers = {
    Util.GetHandleByName(gsAct3Mission1Dir .. "main\\Race_loudspeaker_start1"),
    Util.GetHandleByName(gsAct3Mission1Dir .. "main\\Race_loudspeaker_start2"),
    Util.GetHandleByName(gsAct3Mission1Dir .. "main\\Race_loudspeaker_start3"),
    Util.GetHandleByName(gsAct3Mission1Dir .. "main\\Race_loudspeaker_start4"),
    Util.GetHandleByName(gsAct3Mission1Dir .. "main\\Race_loudspeaker_start5"),
    Util.GetHandleByName(gsAct3Mission1Dir .. "main\\Race_loudspeaker_start6"),
    Util.GetHandleByName(gsAct3Mission1Dir .. "main\\Race_loudspeaker_start7"),
    Util.GetHandleByName(gsAct3Mission1Dir .. "main\\Race_loudspeaker_start8"),
    Util.GetHandleByName(gsAct3Mission1Dir .. "main\\Race_loudspeaker_start9"),
    Util.GetHandleByName(gsAct3Mission1Dir .. "main\\Race_loudspeaker_start10"),
    Util.GetHandleByName(gsAct3Mission1Dir .. "main\\Race_loudspeaker_start11"),
    Util.GetHandleByName(gsAct3Mission1Dir .. "main\\Race_loudspeaker_start12"),
    Util.GetHandleByName(gsAct3Mission1Dir .. "main\\Race_loudspeaker_start13"),
    Util.GetHandleByName(gsAct3Mission1Dir .. "main\\Race_loudspeaker_start14"),
    Util.GetHandleByName(gsAct3Mission1Dir .. "main\\Race_loudspeaker_start15"),
    Util.GetHandleByName(gsAct3Mission1Dir .. "main\\Race_loudspeaker_start16"),
    Util.GetHandleByName(gsAct3Mission1Dir .. "main\\Race_loudspeaker_start17"),
    Util.GetHandleByName(gsAct3Mission1Dir .. "main\\Race_loudspeaker_start18")
  }
  self.bCarConvBurn = false
  self.bCarConvLow = false
  self.bCarConvMed = false
  self.bCarConvHigh = false
  if self.bE3 == true then
    self.E3_Setup(self)
  end
  self:AddOnCancelCallback(Act_3_Mission_1.CancelCleanup)
  self:AddOnCompleteCallback(Act_3_Mission_1.Cleanup)
end

function Act_3_Mission_1:RaceSetup()
  self.iDifficulty = Util.GetRaceDifficulty()
  if self.iDifficulty == 0 then
    self.iExtraHP = 0
    self.iMinSlow = 70
    self.iMaxSlow = 85
    self.iMinFast = 85
    self.iMaxFast = 110
  elseif self.iDifficulty == 1 then
    self.iExtraHP = 50
    self.iMinSlow = 90
    self.iMaxSlow = 110
    self.iMinFast = 120
    self.iMaxFast = 140
  elseif self.iDifficulty == 2 then
    self.iExtraHP = 100
    self.iMinSlow = 70
    self.iMaxSlow = 125
    self.iMinFast = 125
    self.iMaxFast = 170
  elseif self.iDifficulty == 3 then
    self.iExtraHP = 100
    self.iMinSlow = 70
    self.iMaxSlow = 125
    self.iMinFast = 125
    self.iMaxFast = 170
  end
  Sound.LoadSoundBank("m_A3M1_inGame.bnk")
  Sound.SetMusicLocale("A3M1_RaceForParis")
  Sound.SetMusicLocale("m_A3M1_RaceForParis", "A3M1_Lap1")
  Vehicle.SetupRace("ParisGrandPrix", "FinishLine", 2, 0, 32)
  self.CreateRacers(self, self.tStartingRacers, 0, self.iMinSlow, self.iMaxSlow)
  self.CreateRacers(self, self.tStartDarts, 0, self.iMinFast - 5, self.iMaxFast + 5)
  self.CreateRacers(self, self.tLap1Racers, 0, self.iMinFast - 5, self.iMaxFast + 5)
  self.CreateRacers(self, self.tPantheonRacers, 1, self.iMinFast, self.iMaxFast)
  self.CreateRacers(self, self.tBridgeRacers, 0, self.iMinFast, self.iMaxFast)
  self.CreateRacer_2(self, self.tPorthos, 1, self.iMinFast, self.iMaxFast)
  self.CreateRacer_2(self, self.tAthos, 1, self.iMinFast, self.iMaxFast)
  self.CreateRacer_2(self, self.tAramis, 1, self.iMinFast, self.iMaxFast)
  self.CreateRacer_2(self, self.tAramis2, 1, self.iMinFast, self.iMaxFast)
  self.CreateRacer_2(self, self.tDartagnan, 1, self.iMinFast, self.iMaxFast)
  self.CreateRacer_2(self, self.tDartagnan2, 1, self.iMinFast, self.iMaxFast)
  self.CreateRacer_2(self, self.tDierker, 1, self.iMinFast + 5, self.iMaxFast + 5)
  self.AIRacers(self, nil, self.tStartingRacers)
  self.AIRacers(self, nil, self.tStartDarts)
  self.hCar = Util.GetHandleByName("Missions\\act_3\\mission_1\\main\\VH_CV_CR_Aurora_01(1)")
  Actor.BoardVehicle(hSab, self.hCar, "PILOT", true)
  EVENT_PlayerEntersAnyVehicle("Act_3_Mission_1.InCar", self)
end

function Act_3_Mission_1:InCar()
  Vehicle.SetForceAIController(self.hCar, true)
  Util.SetDisableControls("EnterExitVehicle", true)
  if self.DEBUGMODE ~= true then
    Object.SetHealth(self.hCar, 1500)
  else
    Object.SetHealth(self.hCar, 1500)
  end
  Vehicle.SetRaceLoadedCallback("Act_3_Mission_1.Countdown", self)
end

function Act_3_Mission_1:Lap1Events()
  EVENT_ActorEntersTrigger("Act_3_Mission_1.AIRacers", self, hSab, self.sTrigLap1Racers, {
    self.tLap1Racers
  })
  EVENT_ActorEntersTrigger("Act_3_Mission_1.AIRacers", self, hSab, self.sTrigBridgeRacers, {
    self.tBridgeRacers
  })
  EVENT_ActorEntersTrigger("Act_3_Mission_1.StartCrash", self, hSab, self.sTrigStartCrash)
  EVENT_ActorEntersTrigger("Act_3_Mission_1.BridgeCrash", self, hSab, self.sTrigBridgeCrash)
end

function Act_3_Mission_1:Lap2Events()
  EVENT_ActorEntersTrigger("Act_3_Mission_1.StrafeMe", self, hSab, gsAct3Mission1Dir .. "main\\PT_StrafeMe")
  EVENT_ActorEntersTrigger("Act_3_Mission_1.Madelplane", self, hSab, gsAct3Mission1Dir .. "main\\PT_Madelplane")
  EVENT_ActorEntersTrigger("Act_3_Mission_1.AIRacers", self, hSab, self.sTrigPantheonRacers, {
    self.tPantheonRacers
  })
  EVENT_ActorEntersTrigger("Act_3_Mission_1.RiverCrash", self, hSab, self.sTrigRiverCrash)
  EVENT_ActorEntersTrigger("Act_3_Mission_1.BridgePlane", self, hSab, gsAct3Mission1Dir .. "main\\PT_BridgePlane")
end

function Act_3_Mission_1:TASK_Things()
  self:CreateTask({
    sName = "TASK_Things",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    bCompleteOnActivate = true,
    tSMEDNodes = {
      gsAct3Mission1Dir .. "main",
      gsAct3Mission1Dir .. "checkpoints",
      gsAct3Mission1Dir .. "roadnodereplace"
    },
    tOnActivate = {},
    tOnComplete = {
      {
        self.RaceSetup,
        {self}
      }
    }
  })
end

function Act_3_Mission_1:Lap3Events()
  EVENT_ActorEntersTrigger("Act_3_Mission_1.BombRun", self, hSab, gsAct3Mission1Dir .. "main\\PT_BridgeCrash")
  EVENT_ActorEntersTrigger("Act_3_Mission_1.PlaneCrash", self, hSab, gsAct3Mission1Dir .. "main\\PT_PlaneCrash")
  EVENT_ActorEntersTrigger("Act_3_Mission_1.SpawnAndZoom", self, hSab, self.sTrigPorthos, {
    self.tPorthos,
    450
  })
  EVENT_ActorEntersTrigger("Act_3_Mission_1.SpawnAndZoom", self, hSab, self.sTrigAthos, {
    self.tAthos,
    450
  })
  EVENT_ActorEntersTrigger("Act_3_Mission_1.Posse1", self, hSab, self.sTrigArcRacers)
end

function Act_3_Mission_1:SpawnAndZoom(tArgs, a_tRacer, a_iHP)
  local x, y, z = Object.GetPosition(Util.GetHandleByName(a_tRacer.Locator))
  Vehicle.SpawnRacer(a_tRacer.Name, x, y, z)
  self:Delay("Act_3_Mission_1.ZoomZoom2", 5, {a_tRacer, a_iHP})
end

function Act_3_Mission_1:Loudspeakers(a_tSpeakerlist, a_sCueName)
end

function Act_3_Mission_1:StartCrash()
  self.CrashAIRacer(self, self.tStartDarts[4].Name)
  EVENT_ActorEntersTrigger("Act_3_Mission_1.CrashSquib", self, Util.GetHandleByName(self.tStartDarts[4].Name), self.sTrigStartSquib, self.sStartSquib)
end

function Act_3_Mission_1:RiverCrash()
  self.CrashAIRacer(self, self.tPantheonRacers[1].Name)
  EVENT_ActorEntersTrigger("Act_3_Mission_1.CrashSquib", self, self.tPantheonRacers[1].Name, self.sTrigRiverSquib, self.sRiverSquib)
end

function Act_3_Mission_1:BridgeCrash()
  self.CrashAIRacer(self, self.tBridgeRacers[1].Name)
  EVENT_ActorEntersTrigger("Act_3_Mission_1.CrashSquib", self, self.tBridgeRacers[1].Name, self.sTrigBridgeSquib, self.sBridgeSquib)
end

function Act_3_Mission_1:CreateRacers(tTestRaceData, a_iLap, a_fMinSpeed, a_fMaxSpeed)
  self:PrintDebug("Assemble the Field")
  for i, v in ipairs(tTestRaceData) do
    local a_tRacer = v
    if a_fMinSpeed ~= nil then
      Vehicle.CreateRacer(a_tRacer.Name, a_tRacer.Car, "PILOT", a_tRacer.Driver, "ParisGrandPrix", a_iLap, a_fMinSpeed, a_fMaxSpeed)
    else
      Vehicle.CreateRacer(a_tRacer.Name, a_tRacer.Car, "PILOT", a_tRacer.Driver, "ParisGrandPrix", a_iLap)
    end
  end
end

function Act_3_Mission_1:CreateRacer_2(a_tRacer, a_iLap, a_fMinSpeed, a_fMaxSpeed)
  self:PrintDebug("Assemble the Field")
  if a_fMinSpeed ~= nil then
    Vehicle.CreateRacer(a_tRacer.Name, a_tRacer.Car, "PILOT", a_tRacer.Driver, "ParisGrandPrix", a_iLap, a_fMinSpeed, a_fMaxSpeed)
  else
    Vehicle.CreateRacer(a_tRacer.Name, a_tRacer.Car, "PILOT", a_tRacer.Driver, "ParisGrandPrix", a_iLap)
  end
end

function Act_3_Mission_1:AIRacers(tEventArgs, tTestRaceData)
  self:PrintDebug("Go Speed Racer, Go")
  for i, v in ipairs(tTestRaceData) do
    local a_tRacer = v
    local x, y, z = Object.GetPosition(Util.GetHandleByName(a_tRacer.Locator))
    Vehicle.SpawnRacer(a_tRacer.Name, x, y, z)
  end
end

function Act_3_Mission_1:ZoomZoom(a_tRacers, iHP)
  for i, v in ipairs(a_tRacers) do
    local hRacer = Util.GetHandleByName(v.Name)
    Vehicle.OverrideHorsepower(hRacer, true, iHP)
    Vehicle.SetMagicRacer(hRacer, true)
  end
end

function Act_3_Mission_1:ZoomZoom2(a_tArgs, iHP)
  local hRacer = Util.GetHandleByName(a_tArgs[1].Name)
  Vehicle.OverrideHorsepower(hRacer, true, a_tArgs[2])
  Vehicle.SetMagicRacer(hRacer, true)
end

function Act_3_Mission_1:Posse1()
  self:PrintDebug("German Assholes")
  Cin.PlayConversation("332_InG_RaceTalk")
  Sound.SetMusicLocale("A3M1_RaceForParis")
  Sound.SetMusicLocale("m_A3M1_RaceForParis", "A3M1_Lap2")
  if self.iSabPlace <= 6 then
    self.SpawnAndZoom(self, nil, self.tDierker, 450)
    self.SpawnAndZoom(self, nil, self.tAramis, 400)
    self.SpawnAndZoom(self, nil, self.tAramis2, 400)
    self.SpawnAndZoom(self, nil, self.tDartagnan, 400)
    self.SpawnAndZoom(self, nil, self.tDartagnan2, 400)
  else
    EVENT_ActorEntersTrigger("Act_3_Mission_1.Posse2", self, hSab, self.sTrigBridgeRacers)
  end
end

function Act_3_Mission_1:Posse2()
  self:PrintDebug("German Assholes")
  if self.iSabPlace <= 6 then
    self:Posse2_Spawn(self.tAramis)
    self:Posse2_Spawn(self.tAramis2)
    self:Posse2_Spawn(self.tDartagnan)
    self:Posse2_Spawn(self.tDartagnan2)
    self:Posse2_Spawn(self.tDierker)
  else
    Cin.PlayConversation("A3M1_Announcer_Winner_Dierker", "Act_3_Mission_1.MissionFailed", self, {
      "A3M1_Text.FAIL_LostRace"
    })
  end
end

function Act_3_Mission_1:Posse2_Spawn(a_tRacer)
  local x, y, z = Object.GetPosition(Util.GetHandleByName(a_tRacer.Locator .. "_2"))
  Vehicle.SpawnRacer(a_tRacer.Name, x, y, z)
  self:Delay("Act_3_Mission_1.ZoomZoom2", 5, {a_tRacer, 400})
end

function Act_3_Mission_1:NaziChasers()
  self:PrintDebug("Gun Trucks")
  Veh.SpawnDelivery(self, self.tNaziChasers[1])
  Veh.SpawnDelivery(self, self.tNaziChasers[2])
end

function Act_3_Mission_1:ChaserRace(a_hTruck, a_sName)
  self:PrintDebug("Set Chaser to Race")
  Vehicle.AddRacer(a_sName, a_hTruck, "ParisGrandPrix")
end

function Act_3_Mission_1:CrashAIRacer(a_sRacer)
  self:PrintDebug("SCREEECH")
  Vehicle.SetRacerRoad(a_sRacer, "ParisGPCrash")
end

function Act_3_Mission_1:CrashSquib(tEventArgs, a_sSquib)
  self:PrintDebug("boom")
  Cin.PlayConversation("A3M1_Announcer_CarCrash_General")
  Object.Kill(Util.GetHandleByName(a_sSquib))
  Object.Kill(tEventArgs[2])
  Vehicle.RemoveRacer(tEventArgs[2])
end

function Act_3_Mission_1:Flyby()
  self:PrintDebug("Incomming!")
  Cin.PlayCinematic("CIN_A3M1_StartFlyby")
end

function Act_3_Mission_1:PlaneCrash()
  self:PrintDebug("Incomming!")
  Cin.PlayCinematic("CIN_A3M1_PlaneCrash")
end

function Act_3_Mission_1:Madelplane()
  self:PrintDebug("Incomming!")
  Cin.PlayCinematic("CIN_A3M1_Madelplane")
  EVENT_Timer("Act_3_Mission_1.AnnouncerChatter2", self, 2)
end

function Act_3_Mission_1:StrafeMe()
  self:PrintDebug("Incomming!")
  Cin.PlayCinematic("CIN_A3M1_Strafe")
end

function Act_3_Mission_1:BridgePlane()
  self:PrintDebug("Incomming!")
  Cin.PlayCinematic("CIN_A3M1_BridgePlanes")
end

function Act_3_Mission_1:BombRun()
  self:PrintDebug("Incomming!")
  Cin.PlayCinematic("CIN_A3M1_BombRun")
end

function Act_3_Mission_1:AnnouncerChatter1()
  self:PrintDebug("Announcer VO")
  if self.iLap == 1 then
    Cin.PlayConversation("A3M1_Announcer_Chatter_General")
  end
end

function Act_3_Mission_1:AnnouncerChatter2()
  self:PrintDebug("Announcer VO")
  Cin.PlayConversation("A3M1_Announcer_PlaneFlyBy")
end

function Act_3_Mission_1:LapCheck()
  if self.iLap == 1 then
    self.Task_Checkpoint1(self)
    self.Lap2Events(self)
    self.Lap3Events(self)
    self.iLap = self.iLap + 1
  end
end

function Act_3_Mission_1:LapIncrement()
  if self.iLap == 1 then
  end
end

function Act_3_Mission_1:CinematicCheck()
  local tSabSelf = Actor.GetSelf(hSab)
  if tSabSelf.sPlayersCurrentInterior == "Catacombs" then
    self.bE3 = false
    self.Task_PlayStartCin(self)
  elseif self.bE3 == false then
    Util.SetOverrideLoadScreenFadeIn(false)
    Util.AddInteriorLoadCallback("Catacombs", "Act_3_Mission_1.Task_PlayStartCin", self)
  else
    Render.FadeScreen(true, 0)
  end
  self.GENERAL_Setup(self)
end

function Act_3_Mission_1:Task_PlayStartCin()
  self:CreateTask({
    sName = "Task_PlayStartCin",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "330_RaceBrief",
    bOverrideFade = true,
    tCinematicNodes = {
      "330_cinb_racebrief"
    },
    tOnActivate = {
      {
        Vehicle.EnableTraffic,
        {false, true}
      },
      {
        self.RemoveLucsGun,
        {self}
      }
    },
    tOnComplete = {
      {
        Util.SetOverrideLoadScreenFadeIn,
        {false}
      },
      {
        self.Task_ExitCatacombs,
        {self}
      },
      {
        self.UnloadTaskNodes,
        {
          self,
          "Task_PlayStartCin",
          true
        }
      },
      {
        Actor.SetDisguise,
        {
          hSab,
          "FBS_RS_Sean_Racer"
        }
      },
      {
        InteriorManager.ExitInterior,
        {
          "Catacombs",
          "Missions\\act_3\\mission_1\\starter\\LOC_SeanStartingLine"
        }
      }
    }
  })
end

function Act_3_Mission_1:RemoveLucsGun()
  local hLuc = Util.GetHandleByName("Missions\\paris_3\\characters\\hq\\luc_interior\\luc_cat_int")
  Inventory.RemoveAllWeapons(hLuc)
end

function Act_3_Mission_1:Task_ExitCatacombs()
  self:CreateTask({
    sName = "Task_ExitCatacombs",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "ExitInterior",
    sInteriorName = "Catacombs",
    bInteriorTask = true,
    MarkerHeight = 0.9,
    tLocators = {},
    tSMEDNodes = {},
    tOnActivate = {},
    tOnComplete = {
      {
        self.TASK_StaticThings,
        {self}
      },
      {
        self.Teleport2Race,
        {self}
      },
      {
        Util.EnableAmbientEvents,
        {false}
      },
      {
        Freeplay.UnloadAmbientFreeplay,
        {true}
      }
    }
  })
end

function Act_3_Mission_1:TASK_StaticThings()
  self:CreateTask({
    sName = "TASK_StaticThings",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    bCompleteOnActivate = true,
    tStaticTags = {
      "GrandPrix",
      "GrandPrix2",
      "GrandPrix_B",
      "winners_remove",
      "GRANDPRIX_Pristine"
    },
    tOnActivate = {
      {
        self.RemoveThings,
        {self}
      }
    },
    tOnComplete = {
      {
        self.Task_PlayStartingLineCin,
        {self}
      }
    }
  })
end

function Act_3_Mission_1:RemoveThings()
  self.tAllTheTags = {
    "GrandPrixRemove",
    "PrisonBreakRemove",
    "IslandRestrictedArea",
    "fp_amb_p1_snipernest_51",
    "a3m2_mars_sidewalks",
    "000_SHOP_WEAPONS",
    "FP_LWTF_Champange_Ardeness",
    "FP_HWTF_Champange_Ardeness",
    "FP_LWTF_TheFarm",
    "FP_HWTF_TheFarm",
    "FP_LWTF_ParisRace",
    "FP_HWTF_ParisRace",
    "FP_LWTF_DierkerShowdown",
    "FP_HWTF_DierkerShowdown",
    "FP_LWTF_Walhal",
    "FP_HWTF_Walhal",
    "FP_LWTF_Bercy",
    "FP_HWTF_Bercy",
    "FP_LWTF_BiggerGun",
    "FP_HWTF_BiggerGun",
    "FP_LWTF_Bombay",
    "FP_HWTF_Bombay",
    "FP_LWTF_Chambord",
    "FP_HWTF_Chambord",
    "FP_LWTF_Chenonceaux",
    "FP_HWTF_Chenonceaux",
    "FP_LWTF_FinalFreeplay",
    "FP_HWTF_FinalFreeplay",
    "FP_LWTF_GrandSnipe",
    "FP_HWTF_GrandSnipe",
    "FP_LWTF_Kroenigsbourg",
    "FP_HWTF_Kroenigsbourg",
    "FP_LWTF_NaziParty",
    "FP_HWTF_NaziParty",
    "FP_LWTF_OKCoral",
    "FP_HWTF_OKCoral",
    "FP_LWTF_Ossuaire",
    "FP_HWTF_Ossuaire",
    "FP_LWTF_FuelDepot",
    "FP_HWTF_FuelDepot",
    "lavillette_occupation",
    "lavillette_resistance",
    "FP_LWTF_BoilingPoint",
    "FP_HWTF_BoilingPoint",
    "FP_LWTF_Catacombs",
    "FP_HWTF_Catacombs",
    "FP_LWTF_Cemetary",
    "FP_HWTF_Cemetary",
    "FP_LWTF_BigGun",
    "FP_HWTF_BigGun",
    "FP_LWTF_PrisonBreak",
    "FP_HWTF_PrisonBreak",
    "FP_LWTF_Zeppelin",
    "FP_HWTF_Zeppelin",
    "Chateau_Outside_Nazi_LWTF",
    "FP_HWTF_GetAurora",
    "FP_LWTF_Train",
    "FP_HWTF_Train",
    "FP_LWTF_Train_2",
    "FP_HWTF_Train_2",
    "P1FP_KillCourtyard01"
  }
  self.tLoadedTags = {}
  for i, v in ipairs(self.tAllTheTags) do
    if Util.IsCustomTagLoaded(v) then
      table.insert(self.tLoadedTags, v)
    end
  end
  for i, v in ipairs(self.tLoadedTags) do
    Util.UnloadStaticENTag(v, true)
  end
  Util.EnableSuperSpores(false)
end

function Act_3_Mission_1:Task_PlayStartingLineCin()
  self:CreateTask({
    sName = "Task_PlayStartingLineCin",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "331_CinA_ParisRaceGo",
    tCinematicNodes = {
      "331_cina_parisracego"
    },
    bOverrideFade = true,
    bOverrideFade = true,
    tOnActivate = {},
    tOnComplete = {
      {
        self.UnloadTaskNodes,
        {
          self,
          "Task_PlayStartingLineCin",
          true
        }
      },
      {
        self.RegisterCheckpoint,
        {
          self,
          "Act_3_Mission_1.CheckpointStart",
          nil,
          true
        }
      }
    }
  })
end

function Act_3_Mission_1:Teleport2Race()
  Util.UnloadStaticENTag("p1_mis_jailbreak_low", true)
  Util.SetTime(15, 0)
  Suspicion.EnableEscalation(false)
  Suspicion.EnableGlobal(false)
  Util.EnableGooseSteppers(false)
end

function Act_3_Mission_1:Task_PlayFinishCin()
  self:CreateTask({
    sName = "Task_PlayFinishCin",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "333_CinA_RaceBoomBINK",
    tCinematicNodes = {
      "333_raceboom"
    },
    tOnActivate = {},
    tOnComplete = {
      {
        self.Cleanup,
        {self}
      },
      {
        self.MissionComplete,
        {self}
      }
    }
  })
end

function Act_3_Mission_1:CheckpointStart()
  self.iLap = 1
  self.iSabPlace = 30
  self.TASK_Things(self)
end

function Act_3_Mission_1:Countdown()
  HUD.SetGPSCourse("ParisRace")
  Render.FadeScreen(false, 0)
  self.bOver = false
  self.bLost = false
  self.bLeadTaken = false
  self.bLeadLost = false
  self.bClosingFront = false
  Vehicle.SetRacing(true, true)
  Vehicle.SetRaceStartCallback("Act_3_Mission_1.StartRace", self)
  self.Flyby(self)
  self.hStartingEngines = Util.GetHandleByName(gsAct3Mission1Dir .. "main\\Race_startengines")
  Sound.ActivateSoundEmitter(self.hStartingEngines)
end

function Act_3_Mission_1:StartRace()
  Sound.DeactivateSoundEmitter(self.hStartingEngines)
  Util.QueueTutorial("TutorialTip_Text.Nitrous_Title", "TutorialTip_Text.Nitrous", 20, true)
  self:ZoomZoom(self.tStartDarts, 400)
  self:ZoomZoom(self.tStartingRacers, 350)
  Vehicle.SetForceAIController(self.hCar, false)
  Act_3_Mission_1.Task_Checkpoint2(self)
  self.Lap1Events(self)
  Vehicle.SetRacerNearPlayerCallback(170, "Act_3_Mission_1.SetBuddySuperLong", self)
  Vehicle.SetRacerNearPlayerCallback(90, "Act_3_Mission_1.SetBuddyLong", self)
  Vehicle.SetRacerNearPlayerCallback(5, "Act_3_Mission_1.SetBuddyShort", self)
  Vehicle.SetRacePlaceChangeCallback("Act_3_Mission_1.PlaceChange", self)
  Vehicle.SetRaceFinishedCallback("Act_3_Mission_1.WinLose", self)
  Vehicle.SetPlayerLappedCallback("Act_3_Mission_1.Lapped", self)
  Cin.PlayConversation("A3M1_Announcer_AndTheyreOff")
  self:AuroraDamageCheck()
  EVENT_ActorDeath("Act_3_Mission_1.CarDestroyed", self, self.hCar, nil, false)
end

function Act_3_Mission_1:Lapped()
  self:PrintDebug("way to go numbnutz")
  self:MissionFailed("blah", "A1M1_Text.Fail_Lapped")
end

function Act_3_Mission_1:AuroraDamageCheck()
  local tDamageEvent = {
    EventType = "DamageEvent",
    ObjectHandle = self.hCar,
    EventName = "BeenHit"
  }
  self.eCarDamage = Util.CreateEvent(tDamageEvent, "Act_3_Mission_1.AuroraDamaged", self, {}, true)
  self:AddEvent(self.eCarDamage)
end

function Act_3_Mission_1:AuroraDamaged()
  local iHealth = Object.GetHealth(self.hCar)
  local iMaxHealth = Object.GetMaxHealth(self.hCar)
  if iHealth < 150 and self.bCarConvBurn == false then
    self.bCarConvBurn = true
    Cin.PlayConversation("A3M1_CarDamage_Burning")
  elseif iHealth < iMaxHealth * 0.25 and self.bCarConvLow == false then
    self.bCarConvLow = true
    Cin.PlayConversation("A3M1_CarDamage_Low")
  elseif iHealth < iMaxHealth * 0.5 and self.bCarConvMed == false then
    self.bCarConvMed = true
    Cin.PlayConversation("A3M1_CarDamage_Medium")
  elseif iHealth < iMaxHealth * 0.75 and self.bCarConvHigh == false then
    self.bCarConvHigh = true
    Cin.PlayConversation("A3M1_CarDamage_High")
  end
end

function Act_3_Mission_1:CarDestroyed()
  Util.KillEvent(self.eCarDamage)
  EVENT_Timer("Act_3_Mission_1.CarDestroyedFail", self, 5)
end

function Act_3_Mission_1:CarDestroyedFail()
  self:MissionFailed(nil, "GenericFail_Text.DESTROYED_Car_Your")
end

function Act_3_Mission_1:PlaceChange(a_tPlace)
  if self.bOver == false then
    local iPlace = a_tPlace[1]
    if iPlace == 1 then
      if self.bLeadTaken == false then
        self.bLeadTaken = true
        Cin.PlayConversation("A3M1_Announcer_Position_LeadTaken")
      end
    elseif iPlace == 2 and self.iSabPlace == 1 then
      if self.bLeadLost == false then
        self.bLeadLost = true
        Cin.PlayConversation("A3M1_Announcer_Position_LeadLost")
      end
    elseif iPlace == 7 and self.iSabPlace == 8 and self.bClosingFront == false then
      self.bClosingFront = true
      Cin.PlayConversation("A3M1_Announcer_Position_ClosingFront")
    end
    self.iSabPlace = iPlace
  end
end

function Act_3_Mission_1:SetBuddyLong(a_tDude)
  self:PrintDebug("who dis?")
  if a_tDude[3] == true then
    if a_tDude[1] ~= Util.GetHandleByName("Dierker") then
      if a_tDude[2] == true then
        Vehicle.SetRacerSpeed(a_tDude[1], self.iMinSlow, self.iMaxSlow)
      else
        Vehicle.SetRacerSpeed(a_tDude[1], self.iMinSlow - 5, self.iMaxSlow + 25)
      end
    elseif a_tDude[2] == true then
      Vehicle.SetRacerSpeed(a_tDude[1], self.iMinSlow - 10, self.iMaxSlow + 5)
    else
      Vehicle.SetRacerSpeed(a_tDude[1], self.iMinSlow, self.iMaxSlow + 5)
    end
  end
end

function Act_3_Mission_1:SetBuddySuperLong(a_tDude)
  self:PrintDebug("who dis?")
  if a_tDude[1] ~= Util.GetHandleByName("Dierker") and a_tDude[3] == true then
    if a_tDude[2] == true then
      Vehicle.SetRacerSpeed(a_tDude[1], self.iMinSlow - 10, self.iMaxSlow)
    else
      Vehicle.SetRacerSpeed(a_tDude[1], self.iMinSlow, self.iMaxSlow + 25)
    end
  end
end

function Act_3_Mission_1:SetBuddyShort(a_tDude)
  self:PrintDebug("close")
end

function Act_3_Mission_1:RaceAgain(a_bSlowing, a_hDude)
  Nav.CancelFollowObject(a_hDude)
end

function Act_3_Mission_1:WinLose(a_tDude)
  if self.bOver ~= true then
    self.bOver = true
    if a_tDude[1] ~= Util.GetHandleByName("Saboteur") then
      self.bLost = true
      if a_tDude[1] == Util.GetHandleByName("Dierker") then
        Cin.PlayConversation("A3M1_Announcer_Winner_Dierker", "Act_3_Mission_1.MissionFailed", self, {
          "A3M1_Text.FAIL_LostRace"
        })
      else
        self:MissionFailed("blah", "A3M1_Text.FAIL_LostRace2")
      end
    else
      Object.SetInvincible(self.hCar, true)
      self:QuickFade()
    end
  end
end

function Act_3_Mission_1:QuickFade()
  Sound.SetMusicLocale("A3M1_RaceForParis")
  Sound.SetMusicLocale("m_A3M1_RaceForParis", "to_Cin333")
  Render.FadeScreen(true, 0)
  EVENT_Timer("Act_3_Mission_1.QuickChange", self, 2)
end

function Act_3_Mission_1:QuickChange()
  Util.UnloadStaticENTag("winners_remove", true)
  Vehicle.SetRacing(false)
  if Actor.IsInVehicle(hSab) then
    Actor.UnboardVehicle(hSab)
    EVENT_PlayerExitsAnyVehicle("Act_3_Mission_1.QuickChange2", self)
  else
    self:QuickChange2()
  end
end

function Act_3_Mission_1:QuickChange2()
  Object.PlayerTeleportToLocator(Util.GetHandleByName("Missions\\act_3\\mission_1\\main\\LOC_ConnectStart"), false, true, "Act_3_Mission_1.Task_PlayFinishCin", self)
  self:UnloadTaskNodes("TASK_Things", true)
end

function Act_3_Mission_1:MissionFailed(stuff, a_sFailText)
  self:MissionTaskFail(a_sFailText)
end

function Act_3_Mission_1:MissionComplete()
  CompleteCurrentMission()
end

function Act_3_Mission_1:CancelCleanup()
  Actor.RemoveDisguise(hSab)
  self:Cleanup()
end

function Act_3_Mission_1:Cleanup()
  Sound.ResetMusicLocale()
  Sound.UnloadSoundBank("m_A3M1_inGame.bnk")
  HUD.ClearGPSCourse("ParisRace")
  Util.UnloadStaticENTag("GrandPrix", false, true)
  Util.UnloadStaticENTag("GRANDPRIX_Pristine", true)
  Util.UnloadStaticENTag("GrandPrix_B", false, true)
  for i, v in ipairs(self.tLoadedTags) do
    Util.LoadStaticENTag(v, true)
  end
  Util.SetDisableControls("EnterExitVehicle", false)
  Vehicle.SetRacing(false)
  Suspicion.EnableEscalation(true)
  Suspicion.EnableGlobal(true)
  Util.EnableGooseSteppers(true)
  Vehicle.EnableTraffic(true)
  Util.EnableAmbientEvents(true)
  Freeplay.UnloadAmbientFreeplay(false)
end

function Act_3_Mission_1:Delay(a_sCallback, a_Delay, a_tArgs)
  self:PrintDebug(a_sCallback)
  local e = Util.CreateEvent({EventType = "TimerEvent", Time = a_Delay}, a_sCallback, self, {a_tArgs})
  self:AddEvent(e)
end

function Act_3_Mission_1:ConvPlayer(a_sConvFile, a_Delay)
  self:PrintDebug(a_sConvFile)
  local e = Util.CreateEvent({EventType = "TimerEvent", Time = a_Delay}, "Act_3_Mission_1.ConvPlayerDelay", self, {a_sConvFile})
end

function Act_3_Mission_1:ConvPlayerHack(JUNK, a_sConvFile, a_Delay)
  self:PrintDebug(a_sConvFile)
  local e = Util.CreateEvent({EventType = "TimerEvent", Time = a_Delay}, "Act_3_Mission_1.ConvPlayerDelay", self, {a_sConvFile})
end

function Act_3_Mission_1:ConvPlayerDelay(a_sConvFile)
  self:PrintDebug(a_sConvFile)
  Cin.PlayConversation(a_sConvFile)
end

function Act_3_Mission_1:CueConvPlayer(JUNK, a_sConvFile, a_sConvFile2, a_Delay)
  self:PrintDebug(a_sConvFile)
  self:PrintDebug(a_sConvFile2)
  Cin.PlayConversation(a_sConvFile, "Act_3_Mission_1.ConvPlayerHack", self, {a_sConvFile2, a_Delay})
end

function Act_3_Mission_1:HACKCueConvPlayer3(a_sConvFile, a_sConvFile2, a_sConvFile3, a_Delay)
  self:PrintDebug(a_sConvFile)
  self:PrintDebug(a_sConvFile2)
  self:PrintDebug(a_sConvFile3)
  Cin.PlayConversation(a_sConvFile, "Act_3_Mission_1.CueConvPlayer", self, {
    a_sConvFile2,
    a_sConvFile3,
    a_Delay
  })
end

function Act_3_Mission_1:AddEvent(a_eEvent)
  if not self.tEvents then
    self.tEvents = {}
  end
  table.insert(self.tEvents, a_eEvent)
end

function Act_3_Mission_1:PrintDebug(a_sMessage)
  if self.DEBUGMODE == true then
    Render.PrintMessage(a_sMessage)
  end
end

function Act_3_Mission_1:Task_Checkpoint1()
  self:CreateTask({
    sName = "Checkpoint1.Lap" .. self.iLap,
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = self.sTrigCheckpoint1,
    bNoWorldBlip = true,
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        self.Task_Checkpoint2,
        {self}
      }
    }
  })
end

function Act_3_Mission_1:Task_Checkpoint2()
  self:CreateTask({
    sName = "Checkpoint2.Lap" .. self.iLap,
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = self.sTrigCheckpoint2,
    bNoWorldBlip = true,
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        self.Task_Checkpoint3,
        {self}
      }
    }
  })
end

function Act_3_Mission_1:Task_Checkpoint3()
  self:CreateTask({
    sName = "Checkpoint3.Lap" .. self.iLap,
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = self.sTrigCheckpoint3,
    bNoWorldBlip = true,
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        self.Task_Checkpoint4,
        {self}
      }
    }
  })
end

function Act_3_Mission_1:Task_Checkpoint4()
  self:CreateTask({
    sName = "Checkpoint4.Lap" .. self.iLap,
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = self.sTrigCheckpoint4,
    bNoWorldBlip = true,
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        self.Task_Checkpoint5,
        {self}
      }
    }
  })
end

function Act_3_Mission_1:Task_Checkpoint5()
  self:CreateTask({
    sName = "Checkpoint5.Lap" .. self.iLap,
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = self.sTrigCheckpoint5,
    bNoWorldBlip = true,
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        self.Task_Checkpoint6,
        {self}
      },
      {
        self.AnnouncerChatter1,
        {self}
      }
    }
  })
end

function Act_3_Mission_1:Task_Checkpoint6()
  self:CreateTask({
    sName = "Checkpoint6.Lap" .. self.iLap,
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = self.sTrigCheckpoint6,
    bNoWorldBlip = true,
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        self.Task_Checkpoint7,
        {self}
      }
    }
  })
end

function Act_3_Mission_1:Task_Checkpoint7()
  self:CreateTask({
    sName = "Checkpoint7.Lap" .. self.iLap,
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = self.sTrigCheckpoint7,
    bNoWorldBlip = true,
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        self.Task_Checkpoint8,
        {self}
      }
    }
  })
end

function Act_3_Mission_1:Task_Checkpoint8()
  self:CreateTask({
    sName = "Checkpoint8.Lap" .. self.iLap,
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = self.sTrigCheckpoint8,
    bNoWorldBlip = true,
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        self.Task_Checkpoint9,
        {self}
      }
    }
  })
end

function Act_3_Mission_1:Task_Checkpoint9()
  self:CreateTask({
    sName = "Checkpoint9.Lap" .. self.iLap,
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = self.sTrigCheckpoint9,
    bNoWorldBlip = true,
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        self.Task_Checkpoint10,
        {self}
      }
    }
  })
end

function Act_3_Mission_1:Task_Checkpoint10()
  self:CreateTask({
    sName = "Checkpoint10.Lap" .. self.iLap,
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = self.sTrigCheckpoint10,
    bNoWorldBlip = true,
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        self.Task_Checkpoint11,
        {self}
      }
    }
  })
end

function Act_3_Mission_1:Task_Checkpoint11()
  self:CreateTask({
    sName = "Checkpoint11.Lap" .. self.iLap,
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = self.sTrigCheckpoint11,
    bNoWorldBlip = true,
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        self.Task_Checkpoint12,
        {self}
      }
    }
  })
end

function Act_3_Mission_1:Task_Checkpoint12()
  self:CreateTask({
    sName = "Checkpoint12.Lap" .. self.iLap,
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = self.sTrigCheckpoint12,
    bNoWorldBlip = true,
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        self.LapCheck,
        {self}
      }
    }
  })
end
