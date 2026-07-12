if Connect_ST_P3_Papers == nil then
  Connect_ST_P3_Papers = SabTaskObjective:Create()
  Connect_ST_P3_Papers:Configure({
    TaskCount = "auto",
    MCDisplayID = 2,
    tUnlockList = {},
    bStarterless = true,
    tSMEDNodes = {}
  })
end

function Connect_ST_P3_Papers:STARTER_Setup()
end

function Connect_ST_P3_Papers:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
  self.Task_FirstObjective(self)
end

function Connect_ST_P3_Papers:GENERAL_Setup()
end

function Connect_ST_P3_Papers:Task_FirstObjective()
  self:CreateTask({
    sName = "Connect_ST_P3_Papers_Task_FirstObjective",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "empty",
    bCompleteOnActivate = true,
    tOnActivate = {
      {
        self.Task_ShowCinematic,
        {self}
      },
      Render.PrintMessage([[
Connect Mission Stub - Get P3 Papers 
--------------------
.]]),
      Render.PrintMessage([[

Santos gives Sean P3 Papers.]])
    },
    tOnComplete = {}
  })
end

function Connect_ST_P3_Papers:Task_ShowCinematic()
  self:CreateTask({
    sName = "Connect_ST_P3_Papers_Task_ShowCinematic",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "Sab_Placeholder",
    tOnActivate = {},
    tOnComplete = {
      {
        self.CompleteThisMission,
        {self}
      }
    }
  })
end
