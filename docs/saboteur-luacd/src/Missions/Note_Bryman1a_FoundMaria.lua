if Note_Bryman1a_FoundMaria == nil then
  Note_Bryman1a_FoundMaria = SabTaskObjective:Create()
  Note_Bryman1a_FoundMaria:Configure({
    bWorldEvent = true,
    bCourier = true,
    bFastComplete = true,
    MCDisplayID = cNOMISSIONCOMPLETE,
    DelayTimer = 40,
    bFinishRebuild = true,
    tUnlockList = {},
    tSMEDNodes = {}
  })
end

function Note_Bryman1a_FoundMaria:STARTER_Setup()
end

function Note_Bryman1a_FoundMaria:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
end

function Note_Bryman1a_FoundMaria:GENERAL_Setup()
  EVENT_Timer("Note_Bryman1a_FoundMaria.Task_Message", self, 5)
end

function Note_Bryman1a_FoundMaria:Task_Message()
  self:CreateTask({
    sName = "Task_Message",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "CourierMessage",
    MessageID = "Note_Bryman1_AC_321.Note_Bryman1_AC_321_NOTE",
    ConvName = "Note_Bryman1_AC_321",
    MsgType = cMESSAGETYPE_BRYMAN,
    sBlockingSpore = "Missions\\paris_6\\characters\\hdv\\hdv_starter_ext",
    Priority = cMESSAGEPRIORITY_MEDIUM,
    DelayTimer = 240,
    tOnActivate = {},
    tOnComplete = {
      {
        self.Task_Complete,
        {self}
      }
    }
  })
end

function Note_Bryman1a_FoundMaria:Task_Complete()
end
