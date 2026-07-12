if NOTE_FP_Ambient == nil then
  NOTE_FP_Ambient = SabTaskObjective:Create()
  NOTE_FP_Ambient:Configure({
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

function NOTE_FP_Ambient:STARTER_Setup()
end

function NOTE_FP_Ambient:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
end

function NOTE_FP_Ambient:GENERAL_Setup()
  EVENT_Timer("NOTE_FP_Ambient.Task_Message", self, 5)
end

function NOTE_FP_Ambient:Task_Message()
  self:CreateTask({
    sName = "Task_Message",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "CourierMessage",
    MessageID = "NOTE_FP_Ambient.NOTE_FP_Ambient_NOTE",
    ConvName = "NOTE_FP_Ambient",
    MsgType = cMESSAGETYPE_SANTOS,
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

function NOTE_FP_Ambient:Task_Complete()
end
