if Connect_ST_Vittore2Belle == nil then
  Connect_ST_Vittore2Belle = SabTaskObjective:Create()
  Connect_ST_Vittore2Belle:Configure({
    TaskCount = "auto",
    MCDisplayID = 2,
    tUnlockList = {
      "P1FP_Suicide",
      "NOTE_215a"
    },
    bStarterless = true,
    tSMEDNodes = {}
  })
end

function Connect_ST_Vittore2Belle:STARTER_Setup()
end

function Connect_ST_Vittore2Belle:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
  self.Task_FirstObjective(self)
end

function Connect_ST_Vittore2Belle:GENERAL_Setup()
end

function Connect_ST_Vittore2Belle:Task_FirstObjective()
  self:CreateTask({
    sName = "Connect_ST_Vittore2Belle_Task_FirstObjective",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "empty",
    bCompleteOnActivate = true,
    tOnActivate = {
      {
        self.Task_ShowCinematic,
        {self}
      },
      Render.PrintMessage([[
Connect Mission Stub - Vittore Back To Belle 
--------------------
.]]),
      Render.PrintMessage([[

Tell Vittore Snitch is dead, he can go back to the Belle.  Vittore says thanks but these people need your help.]])
    },
    tOnComplete = {}
  })
end

function Connect_ST_Vittore2Belle:Task_ShowCinematic()
  self:CreateTask({
    sName = "Connect_ST_Vittore2Belle_Task_ShowCinematic",
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
