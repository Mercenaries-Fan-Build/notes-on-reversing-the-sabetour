if NOTE_Santos01 == nil then
  NOTE_Santos01 = SabTaskObjective:Create()
  NOTE_Santos01:Configure({
    bWorldEvent = true,
    bCourier = true,
    bFastComplete = true,
    MCDisplayID = cNOMISSIONCOMPLETE,
    bFinishRebuild = true,
    tUnlockList = {},
    tSMEDNodes = {}
  })
end

function NOTE_Santos01:STARTER_Setup()
end

function NOTE_Santos01:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
end

function NOTE_Santos01:GENERAL_Setup()
  EVENT_Timer("NOTE_Santos01.Task_Message", self, 5)
end

function NOTE_Santos01:Task_Message()
  self:CreateTask({
    sName = "Task_Message",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "CourierMessage",
    MessageID = "Note_Santos1_preCarbomb.Note_Santos1_preCarbomb_NOTE",
    ConvName = "Note_Santos1_preCarbomb",
    MsgType = cMESSAGETYPE_SANTOS,
    sBlockingSpore = "Missions\\paris_1\\characters\\belle\\santos_hideout",
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

function NOTE_Santos01:Task_Complete()
end
