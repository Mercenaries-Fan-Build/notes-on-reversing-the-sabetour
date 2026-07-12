if NOTE_P_Qualifier == nil then
  NOTE_P_Qualifier = SabTaskObjective:Create()
  NOTE_P_Qualifier:Configure({
    bWorldEvent = true,
    bCourier = true,
    bFastComplete = true,
    MCDisplayID = cNOMISSIONCOMPLETE,
    bFinishRebuild = true,
    tDependencyList = {},
    tUnlockList = {
      "FP_Paris_Qualifier"
    },
    tSMEDNodes = {}
  })
end

function NOTE_P_Qualifier:STARTER_Setup()
end

function NOTE_P_Qualifier:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
end

function NOTE_P_Qualifier:GENERAL_Setup()
  EVENT_Timer("NOTE_P_Qualifier.Task_Message", self, 15)
end

function NOTE_P_Qualifier:Task_Message()
  print("$$$$$$$$$Note set up")
  self:CreateTask({
    sName = "Task_Message",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "CourierMessage",
    MessageID = "note_fp_P_Qualifier.line",
    ConvName = "Note_fp_P_Qualifier_Skylar",
    MsgType = cMESSAGETYPE_SKYLAR,
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

function NOTE_P_Qualifier:Task_Complete()
end
