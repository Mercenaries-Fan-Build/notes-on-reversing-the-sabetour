if Connect_ST_109_SkylarSex == nil then
  Connect_ST_109_SkylarSex = SabTaskObjective:Create()
  Connect_ST_109_SkylarSex:Configure({
    TaskCount = 99,
    MCDisplayID = 2,
    tUnlockList = {
      "Connect_A1_M2c_JulesToTrack"
    },
    bStarterless = true,
    bSLOverrideFade = true,
    tSMEDNodes = {}
  })
end

function Connect_ST_109_SkylarSex:STARTER_Setup()
end

function Connect_ST_109_SkylarSex:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
  self:Task_Enter()
end

function Connect_ST_109_SkylarSex:GENERAL_Setup()
end

function Connect_ST_109_SkylarSex:Checkpoint1()
end

function Connect_ST_109_SkylarSex:Task_Enter()
  self:CreateTask({
    sName = "Task_Enter",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "EnterInterior",
    sInteriorName = "SaarHQ",
    tOnActivate = {
      {
        InteriorManager.EnterInterior,
        {"SaarHQ"}
      }
    },
    tOnComplete = {
      {
        self.Task_SexSkinamatic,
        {self}
      }
    }
  })
end

function Connect_ST_109_SkylarSex:Task_SexSkinamatic()
  self:CreateTask({
    sName = "Task_SexSkinamatic",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "109_CinB_SkySex",
    bOverrideFade = true,
    tOnActivate = {},
    tOnComplete = {
      {
        Util.SetOverrideLoadScreenFadeIn,
        {false}
      },
      {
        self.Task_Exit,
        {self}
      }
    }
  })
end

function Connect_ST_109_SkylarSex:Task_Exit()
  self:CreateTask({
    sName = "Task_Exit",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "ExitInterior",
    sInteriorName = "SaarHQ",
    tOnActivate = {
      {
        InteriorManager.ExitInterior,
        {"SaarHQ"}
      }
    },
    tOnComplete = {
      {
        self.CompleteThisMission,
        {self}
      }
    }
  })
end
