if NOTE_FP_ChemicalFactory == nil then
  NOTE_FP_ChemicalFactory = SabTaskObjective:Create()
  NOTE_FP_ChemicalFactory:Configure({
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

function NOTE_FP_ChemicalFactory:STARTER_Setup()
end

function NOTE_FP_ChemicalFactory:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
end

function NOTE_FP_ChemicalFactory:GENERAL_Setup()
  EVENT_Timer("NOTE_FP_ChemicalFactory.Task_Message", self, 5)
end

function NOTE_FP_ChemicalFactory:Task_Message()
  self:CreateTask({
    sName = "Task_Message",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "CourierMessage",
    MessageID = "NOTE_FP_ChemicalFactory.NOTE_FP_ChemicalFactory_NOTE_Line",
    ConvName = "NOTE_FP_ChemicalFactory",
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

function NOTE_FP_ChemicalFactory:Task_Complete()
end
