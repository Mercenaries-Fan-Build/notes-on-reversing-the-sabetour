if NOTE_P6M1 == nil then
  NOTE_P6M1 = SabTaskObjective:Create()
  NOTE_P6M1:Configure({
    bWorldEvent = true,
    bCourier = true,
    bFastComplete = true,
    MCDisplayID = cNOMISSIONCOMPLETE,
    bFinishRebuild = true,
    tUnlockList = {},
    tSMEDNodes = {}
  })
end

function NOTE_P6M1:STARTER_Setup()
end

function NOTE_P6M1:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
end

function NOTE_P6M1:GENERAL_Setup()
  EVENT_Timer("NOTE_P6M1.Task_Message", self, 5)
end

function NOTE_P6M1:Task_Message()
  self:CreateTask({
    sName = "Task_Message",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "CourierMessage",
    MessageID = "Note_Bryman3_preAmbush.Note_Bryman3_preAmbush_NOTE",
    ConvName = "Note_Bryman3_preAmbush",
    MsgType = cMESSAGETYPE_BRYMAN,
    Priority = cMESSAGEPRIORITY_MEDIUM,
    tOnActivate = {},
    tOnComplete = {
      {
        self.Task_Complete,
        {self}
      }
    }
  })
end

function NOTE_P6M1:Task_Complete()
end
