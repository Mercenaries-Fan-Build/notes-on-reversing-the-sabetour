if NOTE_P2_Papers == nil then
  NOTE_P2_Papers = SabTaskObjective:Create()
  NOTE_P2_Papers:Configure({
    bWorldEvent = true,
    bCourier = true,
    bFastComplete = true,
    MCDisplayID = cNOMISSIONCOMPLETE,
    bFinishRebuild = true,
    tUnlockList = {},
    tSMEDNodes = {}
  })
end

function NOTE_P2_Papers:STARTER_Setup()
end

function NOTE_P2_Papers:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
end

function NOTE_P2_Papers:GENERAL_Setup()
  EVENT_Timer("NOTE_P2_Papers.Task_Message", self, 5)
end

function NOTE_P2_Papers:Task_Message()
  self:CreateTask({
    sName = "Task_Message",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "CourierMessage",
    MessageID = "NOTE_P2_Papers.NOTE_P2_Papers_NOTE",
    ConvName = "NOTE_P2_Papers",
    MsgType = cMESSAGETYPE_LUC,
    sBlockingSpore = "Missions\\paris_1\\characters\\lavillette\\Luc_interior",
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

function NOTE_P2_Papers:Task_Complete()
end
