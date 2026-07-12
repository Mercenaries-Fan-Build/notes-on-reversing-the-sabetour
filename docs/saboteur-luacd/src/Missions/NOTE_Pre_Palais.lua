if NOTE_Pre_Palais == nil then
  NOTE_Pre_Palais = SabTaskObjective:Create()
  NOTE_Pre_Palais:Configure({
    bWorldEvent = true,
    bCourier = true,
    bFastComplete = true,
    MCDisplayID = cNOMISSIONCOMPLETE,
    bFinishRebuild = true,
    tDependencyList = {},
    tUnlockList = {
      "P1FP_PalaisBombe"
    },
    tSMEDNodes = {}
  })
end

function NOTE_Pre_Palais:STARTER_Setup()
end

function NOTE_Pre_Palais:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
end

function NOTE_Pre_Palais:GENERAL_Setup()
  EVENT_Timer("NOTE_Pre_Palais.Task_Message", self, 150)
end

function NOTE_Pre_Palais:Task_Message()
  self:CreateTask({
    sName = "Task_Message",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "CourierMessage",
    MessageID = "Note_LeCrochet_General.Note_LeCrochet_General_NOTE",
    ConvName = "Note_LeCrochet_General",
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

function NOTE_Pre_Palais:Task_Complete()
end
