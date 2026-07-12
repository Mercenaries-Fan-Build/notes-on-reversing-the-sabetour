if NOTE_AMB_Finish == nil then
  NOTE_AMB_Finish = SabTaskObjective:Create()
  NOTE_AMB_Finish:Configure({
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

function NOTE_AMB_Finish:STARTER_Setup()
end

function NOTE_AMB_Finish:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
end

function NOTE_AMB_Finish:GENERAL_Setup()
  EVENT_Timer("NOTE_AMB_Finish.Task_Message", self, 5)
end

function NOTE_AMB_Finish:Task_Message()
  self:CreateTask({
    sName = "Task_Message",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "CourierMessage",
    MessageID = "Note_LeCrochet3_Finish.Note_LeCrochet3_Finish",
    ConvName = "Note_LeCrochet3_Finish",
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

function NOTE_AMB_Finish:Task_Complete()
end
