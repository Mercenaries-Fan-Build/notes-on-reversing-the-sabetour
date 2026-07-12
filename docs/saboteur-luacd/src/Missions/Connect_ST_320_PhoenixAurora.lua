if Connect_ST_320_PhoenixAurora == nil then
  Connect_ST_320_PhoenixAurora = SabTaskObjective:Create()
  Connect_ST_320_PhoenixAurora:Configure({
    TaskCount = "auto",
    MCDisplayID = 2,
    tUnlockList = {
      "Note_Bryman1a_FoundMaria"
    },
    bStarterless = true,
    tSMEDNodes = {}
  })
end

function Connect_ST_320_PhoenixAurora:STARTER_Setup()
end

function Connect_ST_320_PhoenixAurora:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
  self.Task_FirstObjective(self)
end

function Connect_ST_320_PhoenixAurora:GENERAL_Setup()
end

function Connect_ST_320_PhoenixAurora:Task_FirstObjective()
  self:CreateTask({
    sName = "Connect_ST_320_PhoenixAurora_Task_FirstObjective",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "empty",
    bCompleteOnActivate = true,
    tOnActivate = {
      {
        self.Task_ShowCinematic,
        {self}
      },
      Render.PrintMessage([[
Connect Mission Stub - Phoenix Aurora 
--------------------
.]]),
      Render.PrintMessage([[

Sean and Vittore build the Phoenix Aurora]])
    },
    tOnComplete = {}
  })
end

function Connect_ST_320_PhoenixAurora:Task_ShowCinematic()
  self:CreateTask({
    sName = "Connect_ST_320_PhoenixAurora_Task_ShowCinematic",
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
