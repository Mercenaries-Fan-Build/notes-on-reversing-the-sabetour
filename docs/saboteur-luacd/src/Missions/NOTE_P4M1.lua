if Note_P4M1 == nil then
  Note_P4M1 = SabTaskObjective:Create()
  Note_P4M1:Configure({
    bWorldEvent = true,
    bCourier = true,
    bFastComplete = true,
    MCDisplayID = cNOMISSIONCOMPLETE,
    bFinishRebuild = true,
    tUnlockList = {},
    tSMEDNodes = {}
  })
end

function Note_P4M1:STARTER_Setup()
end

function Note_P4M1:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
end

function Note_P4M1:GENERAL_Setup()
  EVENT_Timer("Note_P4M1.Task_Message", self, 5)
end

function Note_P4M1:Task_Message()
  self:CreateTask({
    sName = "Task_Message",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "CourierMessage",
    MessageID = "NOTE_P4M1_Dialog.NOTE_P4M1_NOTE",
    ConvName = "NOTE_Skylar4_Cem",
    MsgType = cMESSAGETYPE_SKYLAR,
    sBlockingSpore = "Missions\\paris_4\\characters\\cemetary\\exterior\\moreau",
    Priority = cMESSAGEPRIORITY_HIGH,
    tOnActivate = {},
    tOnComplete = {
      {
        self.Task_Complete,
        {self}
      }
    }
  })
end

function Note_P4M1:Task_Complete()
end
