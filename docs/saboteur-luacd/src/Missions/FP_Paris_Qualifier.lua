if FP_Paris_Qualifier == nil then
  FP_Paris_Qualifier = SabTaskObjective:Create()
  FP_Paris_Qualifier.PATH = "Missions\\freeplay\\country\\fp_paris_qualifier\\"
  FP_Paris_Qualifier:Configure({
    TaskCount = 19,
    sStarter = "Spore_RS_Renard",
    sConvFile = "FP_ParisQualifier_Start",
    sSaveMissionNameID = "MissionNames_Text.FP_Paris_Qualifier",
    sActNameID = "MissionNames_Text.ACT_Races",
    tUnlockList = {
      "NOTE_FP_C_Race",
      "FP_CountryRace_1"
    },
    tSMEDNodes = {
      FP_Paris_Qualifier.PATH .. "main"
    },
    tStaticTags = {}
  })
end

function FP_Paris_Qualifier:STARTER_Setup()
end

function FP_Paris_Qualifier:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
  self.SetupCheckpoint(self)
end

function FP_Paris_Qualifier:GENERAL_Setup()
  self.iMaxTime = 180
end

function FP_Paris_Qualifier:SetupCheckpoint()
  self.RegisterCheckpoint(self, "FP_Paris_Qualifier.StartCheckpoint")
end

function FP_Paris_Qualifier:StartCheckpoint()
  local iDifficulty = Util.GetRaceDifficulty()
  if iDifficulty == 0 then
    self.fTime2Beat = 125
  elseif iDifficulty == 1 then
    self.fTime2Beat = 105
  elseif iDifficulty == 2 then
    self.fTime2Beat = 95
  elseif iDifficulty == 3 then
    self.fTime2Beat = 80
  end
  self.bTimeUp = false
  self.bLost = false
  self.Task_EnterCar(self)
  Vehicle.ShowRaceTimer(true, self.fTime2Beat)
  WorldSMEDNodes.LoadNode("Missions\\freeplay\\country\\fp_paris_qualifier\\endguy")
end

function FP_Paris_Qualifier:ExitVehicleEvent()
  self.ePreRaceExitVehicle = EVENT_PlayerExitsAnyVehicle("FP_Paris_Qualifier.CheckRaceObj", self)
end

function FP_Paris_Qualifier:CheckRaceObj()
  if self:IsMissionTaskActive("Task_StartingLine") then
    self:ResetTaskByName("Task_StartingLine", true)
    self:ResetTaskByName("TASK_GetCar")
  end
end

function FP_Paris_Qualifier:Task_EnterCar()
  self:CreateTask({
    sName = "TASK_GetCar",
    sTaskType = "SabTaskObjectiveEmpty",
    sObjectiveTextID = "GenericObjective_Text.Vehicle_Find_RaceCar",
    bNoFocus = true,
    bNoHUDBlip = true,
    bNoWorldBlip = true,
    tOnActivate = {
      {
        EVENT_PlayerEntersAnyVehicle,
        {
          "FP_Paris_Qualifier.Task_StartingLine",
          self
        }
      }
    },
    tOnComplete = {}
  })
end

function FP_Paris_Qualifier:StartTimer()
  if self.ePreRaceExitVehicle then
    Util.KillEvent(self.ePreRaceExitVehicle)
  end
  EVENT_Timer("FP_Paris_Qualifier.TimeUp", self, self.iMaxTime)
  Vehicle.StartRaceTimer(true)
end

function FP_Paris_Qualifier:TimeUp()
  if self.bLost == false then
    self.bTimeUp = true
    self:WinLose()
  end
end

function FP_Paris_Qualifier:Task_StartingLine()
  self:CompleteTaskByName("TASK_GetCar")
  self:CreateTask({
    sName = "Task_StartingLine",
    sTaskType = "SabTaskObjectiveDeliver",
    sObjectiveTextID = "FP_TimeTrial01_Text.TASK_Start",
    sTaskSubType = "DELIVER",
    tDestRegion = "Missions\\freeplay\\country\\fp_paris_qualifier\\main\\PT_Start",
    tLocators = {
      "Missions\\freeplay\\country\\fp_paris_qualifier\\main\\LOC_Start"
    },
    tDeliverObjs = {hSab},
    tOnActivate = {
      {
        self.ExitVehicleEvent,
        {self}
      }
    },
    tOnComplete = {
      {
        self.Task_FinishLine,
        {self}
      }
    }
  })
end

function FP_Paris_Qualifier:Task_FinishLine()
  self:CreateTask({
    sName = "Task_FinishLine",
    sTaskType = "SabTaskObjectiveDeliver",
    sObjectiveTextID = "FP_TimeTrial01_Text.TASK_Race",
    sTaskSubType = "GOTO",
    tDestRegion = "Missions\\freeplay\\country\\fp_paris_qualifier\\main\\PT_Finish",
    tLocators = {
      "Missions\\freeplay\\country\\fp_paris_qualifier\\main\\LOC_Finish"
    },
    tDeliverObjs = {hSab},
    tOnActivate = {
      {
        self.StartTimer,
        {self}
      }
    },
    tOnComplete = {
      {
        self.WinLose,
        {self}
      }
    }
  })
end

function FP_Paris_Qualifier:WinLose()
  local fLaptime = Vehicle.StartRaceTimer(false)
  self.bLost = true
  if self.bTimeUp == true or fLaptime > self.fTime2Beat then
    self:MissionTaskFail("FP_ParisQualifier_Start.YouLost")
    self.Cleanup(self)
  else
    Util.SendPerkMessage("TimeTrial")
    self:DramaticPause(5, "FP_Paris_Qualifier.Cleanup")
  end
end

function FP_Paris_Qualifier:DramaticPause(a_nTime, a_sCallbackFunction)
  EVENT_Timer(a_sCallbackFunction, self, a_nTime)
end

function FP_Paris_Qualifier:Cleanup()
  Vehicle.ShowRaceTimer(false)
  WorldSMEDNodes.UnloadNode("Missions\\freeplay\\country\\fp_paris_qualifier\\endguy", false)
  self:CompleteThisMission()
end
