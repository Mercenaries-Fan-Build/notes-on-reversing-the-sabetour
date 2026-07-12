if NOTE_NaziWedding == nil then
  NOTE_NaziWedding = SabTaskObjective:Create()
  NOTE_NaziWedding:Configure({
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

function NOTE_NaziWedding:STARTER_Setup()
end

function NOTE_NaziWedding:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
end

function NOTE_NaziWedding:GENERAL_Setup()
  EVENT_Timer("NOTE_NaziWedding.Task_Message", self, 30)
end

function NOTE_NaziWedding:Task_Message()
  self:CreateTask({
    sName = "Task_Message",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "CourierMessage",
    MessageID = "Note_FatherDenis2_preNaziParty.Note_FatherDenis2_preNaziParty_NOTE",
    ConvName = "Note_FatherDenis2_preNaziParty",
    MsgType = cMESSAGETYPE_RESISTANCE_GENERAL,
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

function NOTE_NaziWedding:Task_Complete()
end
