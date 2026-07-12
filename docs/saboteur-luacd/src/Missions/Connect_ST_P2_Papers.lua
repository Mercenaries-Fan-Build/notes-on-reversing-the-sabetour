if Connect_ST_P2_Papers == nil then
  Connect_ST_P2_Papers = SabTaskObjective:Create()
  Connect_ST_P2_Papers:Configure({
    TaskCount = "auto",
    MCDisplayID = 2,
    tUnlockList = {},
    bStarterless = true,
    tSMEDNodes = {}
  })
end

function Connect_ST_P2_Papers:STARTER_Setup()
end

function Connect_ST_P2_Papers:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
  self.Task_FirstObjective(self)
end

function Connect_ST_P2_Papers:GENERAL_Setup()
end

function Connect_ST_P2_Papers:Task_FirstObjective()
  self:CreateTask({
    sName = "Connect_ST_P2_Papers_Task_FirstObjective",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "empty",
    bCompleteOnActivate = true,
    tOnActivate = {
      {
        self.Task_ShowCinematic,
        {self}
      },
      Render.PrintMessage([[
Connect Mission Stub - Area 2 Papers 
--------------------
.]]),
      Render.PrintMessage([[

Get Area 2 Papers from Santos.]])
    },
    tOnComplete = {}
  })
end

function Connect_ST_P2_Papers:Task_ShowCinematic()
  self:CreateTask({
    sName = "Connect_ST_P2_Papers_Task_ShowCinematic",
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
