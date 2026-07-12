if FP_CountryRace_2 == nil then
  FP_CountryRace_2 = SabTaskObjective:Create()
  FP_CountryRace_2.PATH = "Missions\\freeplay\\country\\countryrace3\\"
  FP_CountryRace_2:Configure({
    TaskCount = 999,
    sStarter = "Race2_Starter",
    sConvFile = "Country_FP_Race_Start",
    sSaveMissionNameID = "MissionNames_Text.FP_CountryRace_2",
    sActNameID = "MissionNames_Text.ACT_Races",
    bEscalationDenial = true,
    tDependencyList = {
      "FP_CountryRace_1",
      "Connect_P3_M1b_KesslerAtDoppelsieg"
    },
    tSMEDNodes = {
      FP_CountryRace_2.PATH .. "main"
    },
    tStaticTags = {"CR2"}
  })
end

function FP_CountryRace_2:STARTER_Setup()
end

function FP_CountryRace_2:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
  Render.FadeScreen(false, 1)
  self:RegisterCheckpoint("FP_CountryRace_2.Checkpoint1")
end

function FP_CountryRace_2:Checkpoint1()
  self.TASK_GetCar(self)
  self.SetupRacers(self)
  self.bRaceGo = false
end

function FP_CountryRace_2:GENERAL_Setup()
  self.tStartingRacers = {}
  self.tStartingRacers[1] = {}
  self.tStartingRacers[1].Name = "Racer1"
  self.tStartingRacers[1].Locator = FP_CountryRace_2.PATH .. "main\\LOC_Racer_1"
  self.tStartingRacers[1].Car = "VH_CV_CR_AlfaRom_12C_01"
  self.tStartingRacers[1].Driver = "Human_CV_RaceDriver_Team1"
  self.tStartingRacers[2] = {}
  self.tStartingRacers[2].Name = "Racer2"
  self.tStartingRacers[2].Locator = FP_CountryRace_2.PATH .. "main\\LOC_Racer_2"
  self.tStartingRacers[2].Car = "VH_NZ_CR_Kubelconvert_Race"
  self.tStartingRacers[2].Driver = "Human_CV_RaceDriver_Team2"
  self.tStartingRacers[3] = {}
  self.tStartingRacers[3].Name = "Racer3"
  self.tStartingRacers[3].Locator = FP_CountryRace_2.PATH .. "main\\LOC_Racer_3"
  self.tStartingRacers[3].Car = "VH_CV_CR_Allard_01"
  self.tStartingRacers[3].Driver = "Human_CV_RaceDriver_Team3"
  self.tStartingRacers[4] = {}
  self.tStartingRacers[4].Name = "Racer4"
  self.tStartingRacers[4].Locator = FP_CountryRace_2.PATH .. "main\\LOC_Racer_4"
  self.tStartingRacers[4].Car = "VH_CV_CR_Allard_01"
  self.tStartingRacers[4].Driver = "Human_CV_RaceDriver_Team4"
  self.tStartingRacers[5] = {}
  self.tStartingRacers[5].Name = "Racer5"
  self.tStartingRacers[5].Locator = FP_CountryRace_2.PATH .. "main\\LOC_Racer_5"
  self.tStartingRacers[5].Car = "VH_CV_CR_MaterTipo4CL_01"
  self.tStartingRacers[5].Driver = "Human_CV_RaceDriver_Team4"
  self.tStartingRacers[6] = {}
  self.tStartingRacers[6].Name = "Racer6"
  self.tStartingRacers[6].Locator = FP_CountryRace_2.PATH .. "main\\LOC_Racer_6"
  self.tStartingRacers[6].Car = "VH_CV_CR_MaterTipo4CL_01"
  self.tStartingRacers[6].Driver = "Human_CV_RaceDriver_Team4"
  self.tStartingRacers[7] = {}
  self.tStartingRacers[7].Name = "Racer7"
  self.tStartingRacers[7].Locator = FP_CountryRace_2.PATH .. "main\\LOC_Racer_7"
  self.tStartingRacers[7].Car = "VH_CV_CR_Allard_01"
  self.tStartingRacers[7].Driver = "Human_CV_RaceDriver_Team4"
  Sound.LoadSoundBank("m_fp_CountryRace_2.bnk")
end

function FP_CountryRace_2:TASK_GetCar()
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

function FP_CountryRace_2:CarCheck()
  if Actor.IsInVehicle(hSab) then
    self:TASK_GetToRace()
  else
    EVENT_PlayerEntersAnyVehicle("FP_CountryRace_2.TASK_GetToRace", self)
  end
end

function FP_CountryRace_2:TASK_GetToRace()
  self:CompleteTaskByName("TASK_GetCar")
  self:CreateTask({
    sName = "TASK_GetToRace",
    sTaskType = "SabTaskObjectiveDeliver",
    Proximity = 5,
    sTaskSubType = "DELIVER",
    sObjectiveTextID = "FP_CountryRace01.TASK_StartingLine",
    tDestProximityObj = {
      FP_CountryRace_2.PATH .. "main\\LOC_Race_Start"
    },
    tDeliverObjs = {hSab},
    bGroundBlip = true,
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

function FP_CountryRace_2:ExitVehicleEvent()
  Vehicle.EnableTraffic(false)
  self.ePreRaceExitVehicle = EVENT_PlayerExitsAnyVehicle("FP_CountryRace_2.CheckRaceObj", self)
end

function FP_CountryRace_2:StartingLineEvent()
  self.eSlowDown = EVENT_ActorEntersTrigger("FP_CountryRace_2.SlowDown", self, hSab, "Missions\\freeplay\\country\\countryrace3\\main\\PT_StartingLine")
end

function FP_CountryRace_2:SlowDown()
  if Actor.IsInVehicle(hSab) then
    local hCar = Actor.GetVehicle(hSab)
    Vehicle.BrakeTo(hCar, 20)
  end
  self.eSpeedUp = EVENT_ActorExitsTrigger("FP_CountryRace_2.SpeedUp", self, hSab, "Missions\\freeplay\\country\\countryrace3\\main\\PT_StartingLine")
end

function FP_CountryRace_2:SpeedUp()
  if Actor.IsInVehicle(hSab) then
    local hCar = Actor.GetVehicle(hSab)
    Vehicle.BrakeTo(hCar, 200)
  end
  self:StartingLineEvent()
end

function FP_CountryRace_2:CheckRaceObj()
  if self:IsMissionTaskActive("TASK_GetToRace") then
    self:ResetTaskByName("TASK_GetToRace", true)
    self:ResetTaskByName("TASK_GetCar")
  end
end

function FP_CountryRace_2:Countdown()
  self.bLost = false
  self.bOver = false
  self.bBoom = false
  Util.SetDisableControls("EnterExitVehicle", true)
  self.hSabCar = Actor.GetVehicle(hSab)
  if self.ePreRaceExitVehicle then
    Util.KillEvent(self.ePreRaceExitVehicle)
  end
  if self.eSpeedUp or self.eSlowDown then
    Trigger.DoNotWaitFor(Handle("Missions\\freeplay\\country\\countryrace3\\main\\PT_StartingLine"), hSab)
    Vehicle.BrakeTo(self.hSabCar, 200)
  end
  HUD.SetGPSCourse("FP_CountryRace_2")
  EVENT_ActorDeath("FP_CountryRace_2.CarDestroyed", self, self.hSabCar)
  Vehicle.HardSetLinVel(Actor.GetVehicle(hSab), 0)
  Vehicle.SetForceAIController(Actor.GetVehicle(hSab), true)
  Vehicle.SetRacing(true, true)
  Vehicle.SetRaceStartCallback("FP_CountryRace_2.StartRace", self)
  Suspicion.EnableEscalation(false)
  Suspicion.EnableGlobal(false)
end

function FP_CountryRace_2:CarDestroyed()
  self.bBoom = true
  self.bLost = true
  self:CleanupRace()
end

function FP_CountryRace_2:StartRace()
  self.bRaceGo = true
  Util.SetDisableControls("EnterExitVehicle", false)
  Sound.SetMusicLocale("fp_CountryRace2")
  Sound.SetMusicLocale("fp_CountryRace2", "startRace")
  Vehicle.SetRaceFinishedCallback("FP_CountryRace_2.WinLose", self)
  Vehicle.SetForceAIController(Actor.GetVehicle(hSab), false)
  for i, v in ipairs(self.tRacerHandles) do
    Vehicle.OverrideHorsepower(v, true, 350 + self.iExtraHP)
  end
  self.Task_Race(self)
end

function FP_CountryRace_2:WinLose(a_tDude)
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

function FP_CountryRace_2:CleanupRace()
  Vehicle.SetRacing(false)
  if self.bLost == false then
    Util.SendPerkMessage("FreeplayRaceWin")
    AchievementsManager.AchievementGrant("ALL_RACES")
    self.CompleteThisMission(self)
  elseif self.bBoom == true then
    self:MissionTaskFail("GenericFail_Text.DESTROYED_Car_Your")
  else
    self:MissionTaskFail("FP_CountryRace01.FAIL_Lost")
  end
end

function FP_CountryRace_2:MISSION_ONRESET()
  Sound.UnloadSoundBank("m_fp_CountryRace_2.bnk")
  Vehicle.SetRacing(false)
  Vehicle.EnableTraffic(true)
  HUD.ClearGPSCourse()
  Suspicion.EnableEscalation(true)
  Suspicion.EnableGlobal(true)
  Sound.ResetMusicLocale()
end

function FP_CountryRace_2:SetupRacers()
  Vehicle.SetupRace("ParisGrandPrix", "StartingLine", 5, -1)
  self.iDifficulty = Util.GetRaceDifficulty()
  if self.iDifficulty == 0 then
    self.iExtraHP = 0
    self.iMinFast = 85
    self.iMaxFast = 110
  elseif self.iDifficulty == 1 then
    self.iExtraHP = 50
    self.iMinFast = 120
    self.iMaxFast = 140
  elseif self.iDifficulty == 2 then
    self.iExtraHP = 150
    self.iMinFast = 135
    self.iMaxFast = 180
  elseif self.iDifficulty == 3 then
    self.iExtraHP = 150
    self.iMinFast = 135
    self.iMaxFast = 185
  end
  self:CreateRacers(self.tStartingRacers, "ParisGrandPrix", -1, self.iMinFast, self.iMaxFast)
  self:SpawnRacers(nil, self.tStartingRacers)
  Vehicle.SetRaceLoadedCallback("FP_CountryRace_2.ProtectRacers", self)
end

function FP_CountryRace_2:ProtectRacers()
  self.tRacerHandles = {
    Util.GetHandleByName("Racer1"),
    Util.GetHandleByName("Racer2"),
    Util.GetHandleByName("Racer3"),
    Util.GetHandleByName("Racer4"),
    Util.GetHandleByName("Racer5"),
    Util.GetHandleByName("Racer6"),
    Util.GetHandleByName("Racer7")
  }
  for i, v in ipairs(self.tRacerHandles) do
    EVENT_ActorDeath("FP_CountryRace_2.RacerDestroyed", self, v)
  end
  self.tDriverHandles = {}
  for i, v in ipairs(self.tRacerHandles) do
    local hDriver = Vehicle.GetPilot(v)
    if hDriver ~= nil then
      table.insert(self.tDriverHandles, hDriver)
    end
  end
  for i, v in ipairs(self.tDriverHandles) do
    EVENT_ActorDeath("FP_CountryRace_2.RacerDestroyed", self, v)
  end
end

function FP_CountryRace_2:RacerDestroyed()
  if self.bRaceGo == false then
    self:MissionTaskFail("FP_CountryRace01.FAIL_OtherCarBoom")
  end
end

function FP_CountryRace_2:CreateRacers(tTestRaceData, a_sTrack, a_iLap, a_fMinSpeed, a_fMaxSpeed)
  for i, v in ipairs(tTestRaceData) do
    local a_tRacer = v
    if a_fMinSpeed ~= nil then
      Vehicle.CreateRacer(a_tRacer.Name, a_tRacer.Car, "PILOT", a_tRacer.Driver, a_sTrack, a_iLap, a_fMinSpeed, a_fMaxSpeed)
    else
      Vehicle.CreateRacer(a_tRacer.Name, a_tRacer.Car, "PILOT", a_tRacer.Driver, a_sTrack, a_iLap)
    end
  end
end

function FP_CountryRace_2:SpawnRacers(tEventArgs, tTestRaceData)
  for i, v in ipairs(tTestRaceData) do
    local a_tRacer = v
    local x, y, z = Object.GetPosition(Util.GetHandleByName(a_tRacer.Locator))
    Vehicle.SpawnRacer(a_tRacer.Name, x, y, z)
  end
end

function FP_CountryRace_2:Task_Race()
  self:CreateTask({
    sName = "Task_Race",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tOnActivate = {},
    tOnComplete = {}
  })
end
