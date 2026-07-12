if Connect_ST_318_RaceComing == nil then
  Connect_ST_318_RaceComing = SabTaskObjective:Create()
  Connect_ST_318_RaceComing:Configure({
    TaskCount = "9999",
    sStarter = "luc_cat_int",
    sSaveMissionNameID = "MissionNames_Text.P3FP_Jardin",
    bDisableMissionTitle = true,
    ProximityStart = 13,
    MCDisplayID = 2,
    tUnlockList = {
      "SOE_1_Mission_7",
      "P3FP_MadBomber03",
      "P3FP_Hit"
    },
    tCinematicNodes = {
      "318_cinb_raceintro"
    }
  })
end

function Connect_ST_318_RaceComing:STARTER_Setup()
  Cin.LoadCinematic("318_CinB_RaceIntro")
end

function Connect_ST_318_RaceComing:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
  self.Task_ShowCinematic(self)
end

function Connect_ST_318_RaceComing:GENERAL_Setup()
end

function Connect_ST_318_RaceComing:Task_ShowCinematic()
  self:CreateTask({
    sName = "Task_ShowCinematic",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "318_CinB_RaceIntro",
    tOnActivate = {},
    tOnComplete = {
      {
        self.CompleteThisMission,
        {self}
      }
    }
  })
end
