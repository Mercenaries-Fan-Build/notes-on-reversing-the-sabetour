if NOTE_BrymanRadioSabotage == nil then
  NOTE_BrymanRadioSabotage = SabTaskObjective:Create()
  NOTE_BrymanRadioSabotage:Configure({
    bWorldEvent = true,
    bCourier = true,
    bFastComplete = true,
    MCDisplayID = cNOMISSIONCOMPLETE,
    bFinishRebuild = true,
    tUnlockList = {},
    tSMEDNodes = {}
  })
end

function NOTE_BrymanRadioSabotage:STARTER_Setup()
end

function NOTE_BrymanRadioSabotage:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
end

function NOTE_BrymanRadioSabotage:GENERAL_Setup()
  EVENT_Timer("NOTE_BrymanRadioSabotage.Task_Message", self, 5)
end

function NOTE_BrymanRadioSabotage:Task_Message()
  self:CreateTask({
    sName = "Task_Message",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "CourierMessage",
    MessageID = "Note_Bryman2_HearingReports.Note_Bryman2_HearingReports_NOTE",
    ConvName = "Note_Bryman2_HearingReports",
    MsgType = cMESSAGETYPE_BRYMAN,
    sBlockingSpore = "Missions\\paris_3\\characters\\hq\\bryman_interior",
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

function NOTE_BrymanRadioSabotage:Task_Complete()
end
