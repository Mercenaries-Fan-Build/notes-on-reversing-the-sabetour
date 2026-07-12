if Note_Mingo1_OkCorral == nil then
  Note_Mingo1_OkCorral = SabTaskObjective:Create()
  Note_Mingo1_OkCorral:Configure({
    bWorldEvent = true,
    bCourier = true,
    bFastComplete = true,
    MCDisplayID = cNOMISSIONCOMPLETE,
    bFinishRebuild = true,
    tDependencyList = {},
    tUnlockList = {},
    tSMEDNodes = {}
  })
end

function Note_Mingo1_OkCorral:STARTER_Setup()
end

function Note_Mingo1_OkCorral:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
end

function Note_Mingo1_OkCorral:GENERAL_Setup()
  EVENT_Timer("Note_Mingo1_OkCorral.Task_Message", self, 5)
end

function Note_Mingo1_OkCorral:Task_Message()
  self:CreateTask({
    sName = "Task_Message",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "CourierMessage",
    MessageID = "Note_Mingo1_OkCorral.Note_Mingo1_OkCorral_NOTE",
    ConvName = "Note_Mingo1_OkCorral",
    MsgType = cMESSAGETYPE_DUVAL,
    Priority = cMESSAGEPRIORITY_LOW,
    tOnActivate = {},
    tOnComplete = {
      {
        self.Task_Complete,
        {self}
      }
    }
  })
end

function Note_Mingo1_OkCorral:Task_Complete()
end
