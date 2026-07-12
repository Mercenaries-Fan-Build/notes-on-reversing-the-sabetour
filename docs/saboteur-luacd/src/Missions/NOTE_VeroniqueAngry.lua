if NOTE_VeroniqueAngry == nil then
  NOTE_VeroniqueAngry = SabTaskObjective:Create()
  NOTE_VeroniqueAngry:Configure({
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

function NOTE_VeroniqueAngry:STARTER_Setup()
end

function NOTE_VeroniqueAngry:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
end

function NOTE_VeroniqueAngry:GENERAL_Setup()
  EVENT_Timer("NOTE_VeroniqueAngry.Task_Message", self, 5)
end

function NOTE_VeroniqueAngry:Task_Message()
  self:CreateTask({
    sName = "Task_Message",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "CourierMessage",
    MessageID = "Note_Veronique_Angry.Line",
    ConvName = "Note_Veronique_Angry",
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

function NOTE_VeroniqueAngry:Task_Complete()
end
