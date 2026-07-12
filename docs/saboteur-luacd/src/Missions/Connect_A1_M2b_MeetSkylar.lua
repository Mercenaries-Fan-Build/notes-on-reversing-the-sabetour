if Connect_A1_M2b_MeetSkylar == nil then
  Connect_A1_M2b_MeetSkylar = SabTaskObjective:Create()
  Connect_A1_M2b_MeetSkylar:Configure({
    TaskCount = "auto",
    MCDisplayID = 2,
    tUnlockList = {
      "Connect_A1_M2c_JulesToTrack"
    },
    bStarterless = true,
    tSMEDNodes = {}
  })
end

function Connect_A1_M2b_MeetSkylar:STARTER_Setup()
end

function Connect_A1_M2b_MeetSkylar:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
  self.Task_FirstObjective(self)
end

function Connect_A1_M2b_MeetSkylar:GENERAL_Setup()
end

function Connect_A1_M2b_MeetSkylar:Task_FirstObjective()
  self:CreateTask({
    sName = "Connect_A1_M2b_MeetSkylar_Task_FirstObjective",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "empty",
    bCompleteOnActivate = true,
    tOnActivate = {
      {
        self.Task_ShowCinematic,
        {self}
      },
      Render.PrintMessage([[
Connect Mission Stub - Meet Skylar, Escape 
--------------------
.]]),
      Render.PrintMessage([[

Skylar picks you up. Drive to escape escalation. Return Skylar and Jules to Hotel.]])
    },
    tOnComplete = {}
  })
end

function Connect_A1_M2b_MeetSkylar:Task_ShowCinematic()
  self:CreateTask({
    sName = "Connect_A1_M2b_MeetSkylar_Task_ShowCinematic",
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
