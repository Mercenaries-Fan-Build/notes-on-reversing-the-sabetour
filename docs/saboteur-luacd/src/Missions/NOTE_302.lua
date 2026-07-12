if NOTE_302 == nil then
  NOTE_302 = SabTaskObjective:Create()
  NOTE_302:Configure({
    bWorldEvent = true,
    bCourier = true,
    bFastComplete = true,
    MCDisplayID = cNOMISSIONCOMPLETE,
    bFinishRebuild = true,
    tUnlockList = {},
    tSMEDNodes = {}
  })
end

function NOTE_302:STARTER_Setup()
end

function NOTE_302:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
end

function NOTE_302:GENERAL_Setup()
  EVENT_Timer("NOTE_302.Task_Message", self, 5)
end

function NOTE_302:Task_Message()
  self:CreateTask({
    sName = "Task_Message",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "CourierMessage",
    MessageID = "Note_Vittore1_ParisReturn.Note_Vittore1_ParisReturn_NOTE",
    ConvName = "Note_Vittore1_ParisReturn",
    sBlockingSpore = "Missions\\paris_1\\characters\\belle\\vit_belle_garage",
    MsgType = cMESSAGETYPE_VITTORE,
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

function NOTE_302:Task_Complete()
end
