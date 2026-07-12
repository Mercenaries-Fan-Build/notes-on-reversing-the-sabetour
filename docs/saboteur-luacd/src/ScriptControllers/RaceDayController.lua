if not RaceDayController then
  RaceDayController = {}
end

function RaceDayController:OnEnter()
  RaceDayController.Setup(self)
  Util.LoadStaticENTag("A1_GPRace", true)
  Util.LoadStaticENTag("A1M1_GetCaught", true)
  Util.LoadStaticENTag("A1M1_RACE_PIT", true)
  Util.UnloadStaticENTag("A1M1_RaceClosed", true)
end

function RaceDayController:Setup()
  gsA1Race = "Missions\\act_1\\Race\\"
  self.sSetupPits = gsA1Race .. "pits\\PT_SetupPits"
  self.sPitCrowd = gsA1Race .. "pits\\PT_PitCrowd"
  self.tPittedRacers = {}
  self.tAllKrews = {
    DopplPitKrew_000 = {
      tMecs = {
        gsA1Race .. "pits\\Spore_NZ_DpplzgPit_1",
        gsA1Race .. "pits\\Spore_NZ_DpplzgPit_2"
      },
      tRestPts = {
        gsA1Race .. "pits\\AttractionPT_DoppleMecRest_1",
        gsA1Race .. "pits\\AttractionPT_DoppleMecRest_2"
      },
      iCount = 0
    },
    DopplPitKrew_001 = {
      tMecs = {
        gsA1Race .. "pits\\Spore_NZ_DpplzgPit_3",
        gsA1Race .. "pits\\Spore_NZ_DpplzgPit_4"
      },
      tRestPts = {
        gsA1Race .. "pits\\AttractionPT_DoppleMecRest_3",
        gsA1Race .. "pits\\AttractionPT_DoppleMecRest_4"
      },
      iCount = 0
    },
    DopplPitKrew_002 = {
      tMecs = {
        gsA1Race .. "pits\\Spore_NZ_DpplzgPit_5",
        gsA1Race .. "pits\\Spore_NZ_DpplzgPit_6",
        gsA1Race .. "pits\\Spore_NZ_DpplzgPit_7"
      },
      tRestPts = {
        gsA1Race .. "pits\\AttractionPT_DoppleMecRest_5",
        gsA1Race .. "pits\\AttractionPT_DoppleMecRest_6",
        gsA1Race .. "pits\\AttractionPT_DoppleMecRest_7"
      },
      iCount = 0
    },
    AllardPitKrew = {
      tMecs = {
        gsA1Race .. "pits\\Spore_CV_AllardKrew_1",
        gsA1Race .. "pits\\Spore_CV_AllardKrew_2",
        gsA1Race .. "pits\\Spore_CV_AllardKrew_3"
      },
      tRestPts = {
        gsA1Race .. "pits\\AttractionPT_AllardMecRest_1",
        gsA1Race .. "pits\\AttractionPT_AllardMecRest_2",
        gsA1Race .. "pits\\AttractionPT_AllardMecRest_3"
      },
      iCount = 0
    },
    AlfaPit = {
      tMecs = {
        gsA1Race .. "pits\\Spore_CV_AlphaKrew_1",
        gsA1Race .. "pits\\Spore_CV_AlphaKrew_2"
      },
      tRestPts = {
        gsA1Race .. "pits\\AttractionPT_AlfaMecRest_1",
        gsA1Race .. "pits\\AttractionPT_AlfaMecRest_2"
      },
      iCount = 0
    },
    Alfa12Pit = {
      tMecs = {
        gsA1Race .. "pits\\Spore_CV_Alfa12Krew_1",
        gsA1Race .. "pits\\Spore_CV_Alfa12Krew_2",
        gsA1Race .. "pits\\Spore_CV_Alfa12Krew_3"
      },
      tRestPts = {
        gsA1Race .. "pits\\AttractionPT_Alfa12MecRest_1",
        gsA1Race .. "pits\\AttractionPT_Alfa12MecRest_2",
        gsA1Race .. "pits\\AttractionPT_Alfa12MecRest_3"
      },
      iCount = 0
    },
    MaterPit = {
      tMecs = {
        gsA1Race .. "pits\\Spore_CV_MaterCrew_1",
        gsA1Race .. "pits\\Spore_CV_MaterCrew_2"
      },
      tRestPts = {
        gsA1Race .. "pits\\AttractionPT_MaterMecRest_1",
        gsA1Race .. "pits\\AttractionPT_MaterMecRest_2"
      },
      iCount = 0
    },
    Mater2Pit = {
      tMecs = {
        gsA1Race .. "pits\\Spore_CV_Mater2Crew_1",
        gsA1Race .. "pits\\Spore_CV_Mater2Crew_2"
      },
      tRestPts = {
        gsA1Race .. "pits\\AttractionPT_Mater2MecRest_1",
        gsA1Race .. "pits\\AttractionPT_Mater2MecRest_2"
      },
      iCount = 0
    }
  }
  self.tEvents = {}
  self.tPitRacers = {}
  self.tPitRacers[1] = {}
  self.tPitRacers[1].Name = "PitRacerA"
  self.tPitRacers[1].Locator = gsA1Race .. "pits\\LOC_PitRacerA"
  self.tPitRacers[1].Car = "VH_CV_CR_SilverDart_01"
  self.tPitRacers[1].Driver = "Human_NZ_RaceDriver"
  self.tPitRacers[2] = {}
  self.tPitRacers[2].Name = "PitRacerB"
  self.tPitRacers[2].Locator = gsA1Race .. "pits\\LOC_PitRacerB"
  self.tPitRacers[2].Car = "VH_CV_CR_AlfaRomera_01"
  self.tPitRacers[2].Driver = "Human_CV_RaceDriver_Team4"
  self.tPitRacers[3] = {}
  self.tPitRacers[3].Name = "PitRacerC"
  self.tPitRacers[3].Locator = gsA1Race .. "pits\\LOC_PitRacerC"
  self.tPitRacers[3].Car = "VH_CV_CR_SilverDart_01"
  self.tPitRacers[3].Driver = "Human_NZ_RaceDriver"
  self.tPitRacers[4] = {}
  self.tPitRacers[4].Name = "PitRacerD"
  self.tPitRacers[4].Locator = gsA1Race .. "pits\\LOC_PitRacerD"
  self.tPitRacers[4].Car = "VH_CV_CR_SilverDart_01"
  self.tPitRacers[4].Driver = "Human_NZ_RaceDriver"
  self.tPitRacers[5] = {}
  self.tPitRacers[5].Name = "PitRacerE"
  self.tPitRacers[5].Locator = gsA1Race .. "pits\\LOC_PitRacerE"
  self.tPitRacers[5].Car = "VH_CV_CR_Allard_01"
  self.tPitRacers[5].Driver = "Human_CV_RaceDriver_Team2"
  self.tPitStops = {}
  self.tPitStops[1] = {}
  self.tPitStops[1].sName = "MaterPit"
  self.tPitStops[1].vSpawnTarget = gsA1Race .. "pits\\LOC_MaterPit"
  self.tPitStops[1].cVehicleType = cVEH_MATERTIPO
  self.tPitStops[1].tSeatConfig = "Human_CV_RaceDriver_Team3"
  self.tPitStops[1].bForceSpawn = true
  self.tPitStops[1].cDespawnType = cDESPAWN_NONE
  self.tPitStops[1].sDeliveryPath = gsA1Race .. "pits\\PATH_MaterPit"
  self.tPitStops[1].cUnboardType = cDROPOFF_NONE
  self.tPitStops[1].nPathSpeed = 40
  self.tPitStops[1].tOnArrive = {
    {
      "A1FP_CarSmashup.RacerPit",
      {"MaterPit"}
    }
  }
  self.tPitStops[2] = {}
  self.tPitStops[2].sName = "AlfaPit"
  self.tPitStops[2].vSpawnTarget = gsA1Race .. "pits\\LOC_AlfaPit"
  self.tPitStops[2].cVehicleType = cVEH_ALFAROMERA
  self.tPitStops[2].tSeatConfig = "Human_CV_RaceDriver_Team4"
  self.tPitStops[2].bForceSpawn = true
  self.tPitStops[2].cDespawnType = cDESPAWN_NONE
  self.tPitStops[2].sDeliveryPath = gsA1Race .. "pits\\PATH_AlfaPit"
  self.tPitStops[2].cUnboardType = cDROPOFF_NONE
  self.tPitStops[2].nPathSpeed = 45
  self.tPitStops[2].tOnArrive = {
    {
      "A1FP_CarSmashup.RacerPit",
      {"AlfaPit"}
    }
  }
  self.tPitStops[3] = {}
  self.tPitStops[3].sName = "Alfa12Pit"
  self.tPitStops[3].vSpawnTarget = gsA1Race .. "pits\\LOC_Alfa12Pit"
  self.tPitStops[3].cVehicleType = cVEH_ALFAROM12C
  self.tPitStops[3].tSeatConfig = "Human_CV_RaceDriver_Team1"
  self.tPitStops[3].bForceSpawn = true
  self.tPitStops[3].cDespawnType = cDESPAWN_NONE
  self.tPitStops[3].sDeliveryPath = gsA1Race .. "pits\\PATH_Alfa12Pit"
  self.tPitStops[3].cUnboardType = cDROPOFF_NONE
  self.tPitStops[3].nPathSpeed = 30
  self.tPitStops[3].tOnArrive = {
    {
      "A1FP_CarSmashup.RacerPit",
      {"Alfa12Pit"}
    }
  }
  self.tPitStops[4] = {}
  self.tPitStops[4].sName = "Mater2Pit"
  self.tPitStops[4].vSpawnTarget = gsA1Race .. "pits\\LOC_MaterPit2"
  self.tPitStops[4].cVehicleType = cVEH_MATERTIPO
  self.tPitStops[4].tSeatConfig = "Human_CV_RaceDriver_Team3"
  self.tPitStops[4].bForceSpawn = true
  self.tPitStops[4].cDespawnType = cDESPAWN_NONE
  self.tPitStops[4].sDeliveryPath = gsA1Race .. "pits\\PATH_MaterPit2"
  self.tPitStops[4].cUnboardType = cDROPOFF_NONE
  self.tPitStops[4].nPathSpeed = 40
  self.tPitStops[4].tOnArrive = {
    {
      "A1FP_CarSmashup.RacerPit",
      {"Mater2Pit"}
    }
  }
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
  self.tGroupies = {
    gsA1Race .. "arrivals\\Spore_PitWalker_1",
    gsA1Race .. "arrivals\\Spore_PitWalker_2",
    gsA1Race .. "arrivals\\Spore_PitWalker_3",
    gsA1Race .. "arrivals\\Spore_PitWalker_4",
    gsA1Race .. "arrivals\\Spore_PitWalker_30"
  }
  WorldSMEDNodes.LoadNode("Missions\\act_1\\race\\arrivals")
  WorldSMEDNodes.LoadNode("Missions\\act_1\\race\\pits", "RaceDayController.PreStart", self)
  WorldSMEDNodes.LoadNode("Missions\\act_1\\freeplay_smashup\\racetrack")
  WorldSMEDNodes.LoadNode("Missions\\act_1\\race\\part1")
  WorldSMEDNodes.LoadNode("wpop\\saarbrucken\\aisidewalk_racetime")
end

function RaceDayController:PreStart()
  Sound.LoadSoundBank("m_A1M1_inGame.bnk")
  Sound.ActivateSoundEmitter(Util.GetHandleByName("Missions\\act_1\\race\\pits\\Race_startengines(2)"))
  RaceDayController.AddEvent(self, EVENT_ActorEntersTrigger("RaceDayController.SetupPit", self, hSab, self.sSetupPits))
  RaceDayController.AddEvent(self, EVENT_ActorEntersTrigger("RaceDayController.PitCrowd", self, hSab, self.sSetupPits))
  RaceDayController.AddEvent(self, EVENT_ActorEntersTrigger("RaceDayController.PitConv", self, hSab, self.sPitCrowd))
end

function RaceDayController:PitCrowd()
  Cin.PlayConversation("A1M2c_Taxi_OffWeGo")
  self.tPitWalkers = Tips.GetListFromNames("Missions\\act_1\\race\\arrivals\\Spore_PitWalker_")
  self.tPitCrowdPts = Tips.GetListFromNames("Missions\\act_1\\race\\pits\\AIAttractionPt_PitCrowd_")
  RaceDayController.CrowdWait(self, self.tPitWalkers, "Missions\\act_1\\race\\arrivals\\PATH_PitWalk", 5, 35)
end

function RaceDayController:FailDead(a_sConv)
  Cin.PlayConversation(a_sConv, "RaceDayController.FailNow")
end

function RaceDayController:PitConv()
  Cin.PlayConversation("A1M2c_Taxi_NearDestination")
end

function RaceDayController:GitWait(a_tArgs, a_hGit, a_sPath, a_fMin, a_fMax, a_bCheer)
  RaceDayController.CrowdWait(self, {a_hGit}, a_sPath, a_fMin, a_fMax)
end

function RaceDayController:ArrivalWait(a_tCrowd, a_sPath, a_fMin, a_fMax, a_bCheer)
  Combat.SetIdleScripted(a_tCrowd[1], true)
  RaceDayController.CrowdWait(self, {
    a_tCrowd[1]
  }, a_sPath, a_fMin, a_fMax)
end

function RaceDayController:CrowdWait(a_tCrowd, a_sPath, a_fMin, a_fMax, a_bCheer)
  for i, v in ipairs(a_tCrowd) do
    local a_hDude = v
    local e = Util.CreateEvent({
      EventType = "StreamEvent",
      WaitForGameObject = true,
      Objects = {a_hDude}
    }, "RaceDayController.CrowdWalkaway", self, {a_hDude, a_sPath})
    RaceDayController.AddEvent(self, e)
  end
end

function RaceDayController:CrowdWalkaway(a_hDude, a_sPath)
  local iCoin = math.random(1, 2)
  local tPitPaths = {
    "Missions\\act_1\\race\\arrivals\\PATH_PitWalk",
    "Missions\\act_1\\race\\arrivals\\PATH_PitWalk_2"
  }
  a_sPath = tPitPaths[iCoin]
  if Util.IsHandleValid(a_hDude) then
    Actor.EnableNeeds(a_hDude, false)
    Nav.SetScriptedPath(a_hDude, a_sPath, true, "RaceDayController.Disperse", self, {a_hDude})
  end
end

function RaceDayController:Disperse(a_hDude, a_TEST2, a_TEST3)
  local a = a_hDude
  local b = a_TEST2
  local c = a_TEST3
  if Util.IsHandleValid(a_hDude) then
    Actor.EnableNeeds(a_hDude, true)
    Actor.RequestAttrPt(a_hDude, self.tPitCrowdPts[1])
    table.remove(self.tPitCrowdPts, 1)
  end
end

function RaceDayController:CreateRacers(tTestRaceData, a_sTrack, a_iLap, a_fMinSpeed, a_fMaxSpeed)
  for i, v in ipairs(tTestRaceData) do
    local a_tRacer = v
    if a_fMinSpeed ~= nil then
      Vehicle.CreateRacer(a_tRacer.Name, a_tRacer.Car, "PILOT", a_tRacer.Driver, a_sTrack, a_iLap, a_fMinSpeed, a_fMaxSpeed)
    else
      Vehicle.CreateRacer(a_tRacer.Name, a_tRacer.Car, "PILOT", a_tRacer.Driver, a_sTrack, a_iLap)
    end
  end
end

function RaceDayController:SpawnRacers(tEventArgs, tTestRaceData)
  for i, v in ipairs(tTestRaceData) do
    local a_tRacer = v
    local x, y, z = Object.GetPosition(Util.GetHandleByName(a_tRacer.Locator))
    Vehicle.SpawnRacer(a_tRacer.Name, x, y, z)
  end
end

function RaceDayController:SetupPit()
  Vehicle.SetupRace("SaarbruckenPreRace", "FinishLine", 100, -1, 25)
  Vehicle.SetRacing(true, false, cRH_None)
  RaceDayController.CreateRacers(self, self.tPitRacers, "SaarbruckenPreRace", -1, 90, 125)
  RaceDayController.SpawnRacers(self, nil, self.tPitRacers)
  RaceDayController.SetupMecs(self, "DopplPitKrew_000")
  RaceDayController.SetupMecs(self, "DopplPitKrew_001")
  RaceDayController.SetupMecs(self, "DopplPitKrew_002")
  RaceDayController.SetupMecs(self, "AllardPitKrew")
  RaceDayController.SetupMecs(self, "AlfaPit")
  RaceDayController.SetupMecs(self, "Alfa12Pit")
  RaceDayController.SetupMecs(self, "MaterPit")
  RaceDayController.SetupMecs(self, "Mater2Pit")
  Veh.SafeSpawnAtObj(cVEH_SILVERDART, "Missions\\act_1\\race\\pits\\LOC_DopplPit000", {
    Pilot = "Human_NZ_RaceDriver"
  }, false, RaceDayController.RacerPit, self, {
    "DopplPitKrew_000"
  })
  Veh.SafeSpawnAtObj(cVEH_SILVERDART, "Missions\\act_1\\race\\pits\\LOC_DopplPit001", {
    Pilot = "Human_NZ_RaceDriver"
  }, false, RaceDayController.RacerPit, self, {
    "DopplPitKrew_001"
  })
  Veh.SafeSpawnAtObj(cVEH_SILVERDART, "Missions\\act_1\\race\\pits\\LOC_DopplPit002", {
    Pilot = "Human_NZ_RaceDriver"
  }, false, RaceDayController.RacerPit, self, {
    "DopplPitKrew_002"
  })
  Veh.SafeSpawnAtObj(cVEH_ALLARD, "Missions\\act_1\\race\\pits\\LOC_AllardPit", {
    Pilot = "Human_CV_RaceDriver_Team2"
  }, false, RaceDayController.RacerPit, self, {
    "AllardPitKrew"
  })
  Veh.SpawnDelivery(self, self.tPitStops[1])
  Veh.SpawnDelivery(self, self.tPitStops[2])
  Veh.SpawnDelivery(self, self.tPitStops[3])
  Veh.SpawnDelivery(self, self.tPitStops[4])
  for i, v in ipairs(self.tGroupies) do
    EVENT_PlayerToActorProximity("RaceDayController.GitTalk", self, v, 5, {v})
  end
end

function RaceDayController:GitTalk(a_sGroupie)
  local a_hGroupie = Util.GetHandleByName(a_sGroupie)
  Nav.CancelScriptedPath(a_hGroupie)
end

function RaceDayController:SetupMecs(a_sKrew)
  local a_tTest = 1
  local a_tMecs = self.tAllKrews[a_sKrew].tMecs
  for i, v in ipairs(a_tMecs) do
    local a_hActor = Util.GetHandleByName(v)
    Actor.EnableNeeds(a_hActor, false)
    if Combat.IsCombatant(a_hActor) == true then
      Combat.SetIdleScripted(a_hActor, true)
      Combat.SetRespondToEvents(a_hActor, false)
      Combat.SetRespondToSound(a_hActor, false)
      Combat.SetSquadAssist(a_hActor, false)
      Suspicion.Enable(a_hActor, false)
    end
    Actor.SetVehicleAvoidance(a_hActor, false)
    EVENT_ActorDeath("RaceDayController.RacerDead", self, a_hActor, {i, a_sKrew})
  end
end

function RaceDayController:RacerDead(a_iDeadDude, a_sKrew)
  table.remove(self.tAllKrews[a_sKrew].tMecs, a_iDeadDude)
  if self.tAllKrews[a_sKrew].iCount == #self.tAllKrews[a_sKrew].tMecs then
    RaceDayController.PitDriveAway(self, a_sKrew, self.tAllKrews[a_sKrew].hCar)
  end
end

function RaceDayController:RacerPit(a_hRacer, a_sKrew)
  table.insert(self.tPittedRacers, a_hRacer)
  local a_tMecs = self.tAllKrews[a_sKrew].tMecs
  self.tAllKrews[a_sKrew].hCar = a_hRacer
  if Vehicle.GetSpeed(a_hRacer) > 2 then
    Nav.StopMoving(a_hRacer)
    Nav.CancelScriptedPath(a_hRacer)
  end
  local tMecPoints = Object.GetAttrPtAttachments(a_hRacer)
  if tMecPoints ~= nil then
    for i = 1, #a_tMecs do
      if tMecPoints[i] ~= nil then
        local tMecPitSequence = {
          {
            "DELAYFORRANDOM",
            {0.1, 5}
          },
          {
            "USEATTRPT_NOWAIT",
            {
              tMecPoints[i]
            }
          },
          {
            "DELAYFORRANDOM",
            {8, 12}
          },
          {
            "RUNTOOBJECT",
            {
              self.tAllKrews[a_sKrew].tRestPts[i]
            }
          },
          {
            "USEATTRPT_NOWAIT",
            {
              Util.GetHandleByName(self.tAllKrews[a_sKrew].tRestPts[i])
            }
          }
        }
        ScriptSequence.Run(a_tMecs[i], tMecPitSequence, self.PitMechanics, {
          self,
          a_sKrew,
          a_hRacer
        })
      end
    end
  end
end

function RaceDayController:PitMechanics(a_sKrew, a_hCar)
  self.tAllKrews[a_sKrew].iCount = self.tAllKrews[a_sKrew].iCount + 1
  if self.tAllKrews[a_sKrew].iCount == #self.tAllKrews[a_sKrew].tMecs then
    RaceDayController.PitDriveAway(self, a_sKrew, a_hCar)
  end
end

function RaceDayController:PitDriveAway(a_sRacer, a_hCar)
  Vehicle.AddRacer(a_sRacer, a_hCar, "SaarbruckenPreRace", -3, 100, 150)
  for i, v in ipairs(self.tPittedRacers) do
    if v == a_hCar then
      table.remove(self.tPittedRacers, i)
    end
  end
end

function RaceDayController:AddEvent(a_eEvent)
  table.insert(self.tEvents, a_eEvent)
end

function RaceDayController:OnExit()
  Vehicle.SetRacing(false)
  for i, v in ipairs(self.tEvents) do
    Util.KillEvent(v)
  end
end
