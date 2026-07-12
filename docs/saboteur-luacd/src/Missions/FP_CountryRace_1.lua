if FP_CountryRace_1 == nil then
  FP_CountryRace_1 = SabTaskObjective:Create()
  FP_CountryRace_1.PATH = "Missions\\freeplay\\country\\countryrace1\\"
  FP_CountryRace_1:Configure({
    TaskCount = 999,
    sStarter = "Race1_Starter",
    sConvFile = "Country2_FP_Race_Start",
    sSaveMissionNameID = "MissionNames_Text.FP_CountryRace",
    sActNameID = "MissionNames_Text.ACT_Races",
    bEscalationDenial = true,
    tUnlockList = {
      "FP_CountryRace_2"
    },
    tSMEDNodes = {
      FP_CountryRace_1.PATH .. "main"
    },
    tStaticTags = {
      "CountryRace01_Colby"
    }
  })
end

function FP_CountryRace_1:STARTER_Setup()
  Util.EnableRoadsInRegion(false, "Missions\\freeplay\\country\\countryrace1\\PT_NoTraffic_Start")
end

function FP_CountryRace_1:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
  Render.FadeScreen(false, 1)
  Util.LoadStaticENTag("FP_CountryRace_1_VehCol", true)
  Util.UnloadStaticENTag("FP_CountryRace_Remove", true)
  self:RegisterCheckpoint("FP_CountryRace_1.Checkpoint1")
end

function FP_CountryRace_1:Checkpoint1()
  self.bRaceGo = false
  self.TASK_GetCar(self)
  self.SetupRacers(self)
end

function FP_CountryRace_1:GENERAL_Setup()
  self.tStartingRacers = {}
  self.tStartingRacers[1] = {}
  self.tStartingRacers[1].Name = "Racer1"
  self.tStartingRacers[1].Locator = FP_CountryRace_1.PATH .. "main\\LOC_Racer_1"
  self.tStartingRacers[1].Car = "VH_CV_CR_AlfaRom_12C_01"
  self.tStartingRacers[1].Driver = "Human_CV_RaceDriver_Team1"
  self.tStartingRacers[2] = {}
  self.tStartingRacers[2].Name = "Racer2"
  self.tStartingRacers[2].Locator = FP_CountryRace_1.PATH .. "main\\LOC_Racer_2"
  self.tStartingRacers[2].Car = "VH_CV_CR_Allard_01"
  self.tStartingRacers[2].Driver = "Human_CV_RaceDriver_Team2"
  self.tStartingRacers[3] = {}
  self.tStartingRacers[3].Name = "Racer3"
  self.tStartingRacers[3].Locator = FP_CountryRace_1.PATH .. "main\\LOC_Racer_4"
  self.tStartingRacers[3].Car = "VH_CV_CR_AlfaRomera_01"
  self.tStartingRacers[3].Driver = "Human_CV_RaceDriver_Team3"
  self.tStartingRacers[4] = {}
  self.tStartingRacers[4].Name = "Racer4"
  self.tStartingRacers[4].Locator = FP_CountryRace_1.PATH .. "main\\LOC_Racer_3"
  self.tStartingRacers[4].Car = "VH_NZ_CR_Kubelconvert_Race"
  self.tStartingRacers[4].Driver = "Human_CV_RaceDriver_Team4"
  self.tStartingRacers[5] = {}
  self.tStartingRacers[5].Name = "Racer5"
  self.tStartingRacers[5].Locator = FP_CountryRace_1.PATH .. "main\\LOC_Racer_5"
  self.tStartingRacers[5].Car = "VH_NZ_CR_Kubelconvert_Race"
  self.tStartingRacers[5].Driver = "Human_CV_RaceDriver_Team4"
  self.tStartingRacers[6] = {}
  self.tStartingRacers[6].Name = "Racer6"
  self.tStartingRacers[6].Locator = FP_CountryRace_1.PATH .. "main\\LOC_Racer_6"
  self.tStartingRacers[6].Car = "VH_CV_CR_AlfaRom_12C_01"
  self.tStartingRacers[6].Driver = "Human_CV_RaceDriver_Team1"
  self.tStartingRacers[7] = {}
  self.tStartingRacers[7].Name = "Racer7"
  self.tStartingRacers[7].Locator = FP_CountryRace_1.PATH .. "main\\LOC_Racer_7"
  self.tStartingRacers[7].Car = "VH_CV_CR_Allard_01"
  self.tStartingRacers[7].Driver = "Human_CV_RaceDriver_Team2"
  self.tStartingRacers[8] = {}
  self.tStartingRacers[8].Name = "Racer8"
  self.tStartingRacers[8].Locator = FP_CountryRace_1.PATH .. "main\\LOC_Racer_8"
  self.tStartingRacers[8].Car = "VH_CV_CR_AlfaRomera_01"
  self.tStartingRacers[8].Driver = "Human_CV_RaceDriver_Team3"
  self.tStartingRacers[9] = {}
  self.tStartingRacers[9].Name = "Racer9"
  self.tStartingRacers[9].Locator = FP_CountryRace_1.PATH .. "main\\LOC_Racer_9"
  self.tStartingRacers[9].Car = "VH_CV_CR_AlfaRomera_01"
  self.tStartingRacers[9].Driver = "Human_CV_RaceDriver_Team3"
  self.tPointCounter = 0
  Sound.LoadSoundBank("m_fp_CountryRace_1.bnk")
end

function FP_CountryRace_1:TASK_GetCar()
  self:CreateTask({
    sName = "TASK_GetCar",
    sTaskType = "SabTaskObjectiveEmpty",
    sObjectiveTextID = "GenericObjective_Text.Vehicle_Find_RaceCar",
    bNoFocus = true,
    bNoHUDBlip = true,
    bNoWorldBlip = true,
    tOnActivate = {
      {
        self.CarCheck,
        {self}
      }
    },
    tOnComplete = {}
  })
end

function FP_CountryRace_1:CarCheck()
  if Actor.IsInVehicle(hSab) then
    self:TASK_GetToRace()
  else
    EVENT_PlayerEntersAnyVehicle("FP_CountryRace_1.TASK_GetToRace", self)
  end
end

function FP_CountryRace_1:TASK_GetToRace()
  self:CompleteTaskByName("TASK_GetCar")
  self:CreateTask({
    sName = "TASK_GetToRace",
    sTaskType = "SabTaskObjectiveDeliver",
    Proximity = 5,
    sTaskSubType = "DELIVER",
    bGroundBlip = true,
    sObjectiveTextID = "FP_CountryRace01.TASK_StartingLine",
    tDestProximityObj = {
      FP_CountryRace_1.PATH .. "main\\LOC_Race_Start"
    },
    tDeliverObjs = {hSab},
    tOnActivate = {
      {
        self.ExitVehicleEvent,
        {self}
      },
      {
        self.StartingLineEvent,
        {self}
      }
    },
    tOnComplete = {
      {
        self.Countdown,
        {self}
      }
    }
  })
end

function FP_CountryRace_1:ExitVehicleEvent()
  self.ePreRaceExitVehicle = EVENT_PlayerExitsAnyVehicle("FP_CountryRace_1.CheckRaceObj", self)
  Vehicle.EnableTraffic(false)
end

function FP_CountryRace_1:StartingLineEvent()
  self.eSlowDown = EVENT_ActorEntersTrigger("FP_CountryRace_1.SlowDown", self, hSab, "Missions\\freeplay\\country\\countryrace1\\main\\PT_RaceStart")
end

function FP_CountryRace_1:SlowDown()
  if Actor.IsInVehicle(hSab) then
    local hCar = Actor.GetVehicle(hSab)
    Vehicle.BrakeTo(hCar, 20)
  end
  self.eSpeedUp = EVENT_ActorExitsTrigger("FP_CountryRace_1.SpeedUp", self, hSab, "Missions\\freeplay\\country\\countryrace1\\main\\PT_RaceStart")
end

function FP_CountryRace_1:SpeedUp()
  if Actor.IsInVehicle(hSab) then
    local hCar = Actor.GetVehicle(hSab)
    Vehicle.BrakeTo(hCar, 200)
  end
  self:StartingLineEvent()
end

function FP_CountryRace_1:CheckRaceObj()
  if self:IsMissionTaskActive("TASK_GetToRace") then
    self:ResetTaskByName("TASK_GetToRace", true)
    self:ResetTaskByName("TASK_GetCar")
  end
end

function FP_CountryRace_1:Countdown()
  self.hSabCar = Actor.GetVehicle(hSab)
  if self.ePreRaceExitVehicle then
    Util.KillEvent(self.ePreRaceExitVehicle)
  end
  if self.eSpeedUp or self.eSlowDown then
    Trigger.DoNotWaitFor(Handle("Missions\\freeplay\\country\\countryrace1\\main\\PT_RaceStart"), hSab)
    Vehicle.BrakeTo(self.hSabCar, 200)
  end
  self.bLost = false
  self.bLeft = false
  self.bOver = false
  Util.SetDisableControls("EnterExitVehicle", true)
  self.eCycleExit = EVENT_ActorExitsAnyVehicle("FP_CountryRace_1.Ejected", self, hSab)
  HUD.SetGPSCourse("FP_CountryRace_1")
  EVENT_ActorDeath("FP_CountryRace_1.CarDestroyed", self, self.hSabCar)
  Vehicle.HardSetLinVel(Actor.GetVehicle(hSab), 0)
  Vehicle.SetForceAIController(Actor.GetVehicle(hSab), true)
  Vehicle.SetRacing(true, true)
  Vehicle.SetRaceStartCallback("FP_CountryRace_1.StartRace", self)
end

function FP_CountryRace_1:Ejected()
  if self.bOver == false then
    Object.Kill(hSab)
  end
end

function FP_CountryRace_1:CarDestroyed()
  Vehicle.SetRacing(false)
  self:MissionTaskFail("GenericFail_Text.DESTROYED_Car_Your")
end

function FP_CountryRace_1:StartRace()
  EVENT_PlayerExitsTrigger("FP_CountryRace_1.LeftRace", self, "Missions\\freeplay\\country\\countryrace1\\main\\PT_LeftRace")
  self.bRaceGo = true
  Sound.SetMusicLocale("fp_CountryRace1")
  Sound.SetMusicLocale("fp_CountryRace1", "startRace")
  Vehicle.SetRaceFinishedCallback("FP_CountryRace_1.WinLose", self)
  Vehicle.SetForceAIController(Actor.GetVehicle(hSab), false)
  for i, v in ipairs(self.tRacerHandles) do
    Vehicle.OverrideHorsepower(v, true, 350 + self.iExtraHP)
  end
  self.Task_Race(self)
end

function FP_CountryRace_1:WinLose(a_tDude)
  if self.bOver == false then
    self.bOver = true
    if a_tDude[1] ~= Util.GetHandleByName("Saboteur") then
      self.bLost = true
    else
      self.bLost = false
    end
    self:CleanupRace()
  end
end

function FP_CountryRace_1:LeftRace()
  self.bLost = true
  self.bLeft = true
  self:CleanupRace()
end

function FP_CountryRace_1:CleanupRace()
  if self.bLost == false then
    Util.SendPerkMessage("FreeplayRacePlace")
    Util.EnableRoadsInRegion(true, "Missions\\freeplay\\country\\countryrace1\\PT_NoTraffic_Start")
    self.CompleteThisMission(self)
  else
    Util.EnableRoadsInRegion(true, "Missions\\freeplay\\country\\countryrace1\\PT_NoTraffic_Start")
    if self.bLeft == true then
      self:MissionTaskFail("FP_CountryRace01.FAIL_LeftTrack")
    else
      self:MissionTaskFail("FP_CountryRace01.FAIL_Lost")
    end
  end
  Util.UnloadStaticENTag("FP_CountryRace_1_VehCol", true)
  Util.LoadStaticENTag("FP_CountryRace_Remove", true)
end

function FP_CountryRace_1:MISSION_ONRESET()
  Sound.UnloadSoundBank("m_fp_CountryRace_1.bnk")
  Vehicle.SetRacing(false)
  Vehicle.EnableTraffic(true)
  if self.eCycleExit then
    Util.KillEvent(self.eCycleExit)
  end
  Util.SetDisableControls("EnterExitVehicle", false)
  HUD.ClearGPSCourse()
  Sound.ResetMusicLocale()
end

function FP_CountryRace_1:SetupRacers()
  Vehicle.SetupRace("ParisGrandPrix", "FinishLine", 2, -1)
  self.iDifficulty = Util.GetRaceDifficulty()
  if self.iDifficulty == 0 then
    self.iExtraHP = 50
    self.iMinFast = 85
    self.iMaxFast = 130
  elseif self.iDifficulty == 1 then
    self.iExtraHP = 100
    self.iMinFast = 120
    self.iMaxFast = 150
  elseif self.iDifficulty == 2 then
    self.iExtraHP = 150
    self.iMinFast = 125
    self.iMaxFast = 190
  elseif self.iDifficulty == 3 then
    self.iExtraHP = 175
    self.iMinFast = 135
    self.iMaxFast = 200
  end
  self:CreateRacers(self.tStartingRacers, "ParisGrandPrix", -1, self.iMinFast, self.iMaxFast)
  self:SpawnRacers(nil, self.tStartingRacers)
  Vehicle.SetRaceLoadedCallback("FP_CountryRace_1.ProtectRacers", self)
end

function FP_CountryRace_1:ProtectRacers()
  self.tRacerHandles = {
    Util.GetHandleByName("Racer1"),
    Util.GetHandleByName("Racer2"),
    Util.GetHandleByName("Racer3"),
    Util.GetHandleByName("Racer4"),
    Util.GetHandleByName("Racer5"),
    Util.GetHandleByName("Racer6"),
    Util.GetHandleByName("Racer7"),
    Util.GetHandleByName("Racer8"),
    Util.GetHandleByName("Racer9")
  }
  for i, v in ipairs(self.tRacerHandles) do
    EVENT_ActorDeath("FP_CountryRace_1.RacerDestroyed", self, v)
  end
  self.tDriverHandles = {}
  for i, v in ipairs(self.tRacerHandles) do
    local hDriver = Vehicle.GetPilot(v)
    if hDriver ~= nil then
      table.insert(self.tDriverHandles, hDriver)
    end
  end
  for i, v in ipairs(self.tDriverHandles) do
    EVENT_ActorDeath("FP_CountryRace_1.RacerDestroyed", self, v)
  end
end

function FP_CountryRace_1:RacerDestroyed()
  if self.bRaceGo == false then
    self:MissionTaskFail("FP_CountryRace01.FAIL_OtherCarBoom")
  end
end

function FP_CountryRace_1:CreateRacers(tTestRaceData, a_sTrack, a_iLap, a_fMinSpeed, a_fMaxSpeed)
  for i, v in ipairs(tTestRaceData) do
    local a_tRacer = v
    if a_fMinSpeed ~= nil then
      Vehicle.CreateRacer(a_tRacer.Name, a_tRacer.Car, "PILOT", a_tRacer.Driver, a_sTrack, a_iLap, a_fMinSpeed, a_fMaxSpeed)
    else
      Vehicle.CreateRacer(a_tRacer.Name, a_tRacer.Car, "PILOT", a_tRacer.Driver, a_sTrack, a_iLap)
    end
  end
end

function FP_CountryRace_1:SpawnRacers(tEventArgs, tTestRaceData)
  for i, v in ipairs(tTestRaceData) do
    local a_tRacer = v
    local x, y, z = Object.GetPosition(Util.GetHandleByName(a_tRacer.Locator))
    Vehicle.SpawnRacer(a_tRacer.Name, x, y, z)
  end
end

function FP_CountryRace_1:Task_Race()
  self:CreateTask({
    sName = "Task_Race",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tOnActivate = {},
    tOnComplete = {}
  })
end
