if Connect_S1_M7c_FindFranziska == nil then
  Connect_S1_M7c_FindFranziska = SabTaskObjective:Create()
  Connect_S1_M7c_FindFranziska:Configure({
    TaskCount = "auto",
    MCDisplayID = 2,
    tUnlockList = {
      "Note_Bryman1a_FoundMaria"
    },
    bStarterless = true,
    tSMEDNodes = {}
  })
end

function Connect_S1_M7c_FindFranziska:STARTER_Setup()
end

function Connect_S1_M7c_FindFranziska:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
  self.Task_FirstObjective(self)
end

function Connect_S1_M7c_FindFranziska:GENERAL_Setup()
end

function Connect_S1_M7c_FindFranziska:Task_FirstObjective()
  self:CreateTask({
    sName = "Connect_S1_M7c_FindFranziska_Task_FirstObjective",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "empty",
    bCompleteOnActivate = true,
    tOnActivate = {
      {
        self.Task_ShowCinematic,
        {self}
      },
      Render.PrintMessage([[
Connect Mission Stub - Tell Bryman to Listen for Franziska 
--------------------
.]]),
      Render.PrintMessage([[

Tell Bryman to keep an ear open for word about the location of Franziska.]])
    },
    tOnComplete = {}
  })
end

function Connect_S1_M7c_FindFranziska:Task_ShowCinematic()
  self:CreateTask({
    sName = "Connect_S1_M7c_FindFranziska_Task_ShowCinematic",
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
