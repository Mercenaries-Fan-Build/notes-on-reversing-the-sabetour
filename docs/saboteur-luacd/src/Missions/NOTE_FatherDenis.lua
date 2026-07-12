if NOTE_FatherDenis == nil then
  NOTE_FatherDenis = SabTaskObjective:Create()
  NOTE_FatherDenis:Configure({
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

function NOTE_FatherDenis:STARTER_Setup()
end

function NOTE_FatherDenis:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
end

function NOTE_FatherDenis:GENERAL_Setup()
  EVENT_Timer("NOTE_FatherDenis.Task_Message", self, 5)
end

function NOTE_FatherDenis:Task_Message()
  self:CreateTask({
    sName = "Task_Message",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "CourierMessage",
    MessageID = "Note_FatherDenis_General.Note_FatherDenis_General_NOTE",
    ConvName = "Note_FatherDenis_General",
    MsgType = cMESSAGETYPE_RESISTANCE_GENERAL,
    Priority = cMESSAGEPRIORITY_LOW,
    tOnActivate = {},
    tOnComplete = {}
  })
end

function NOTE_FatherDenis:Task_Complete()
end
