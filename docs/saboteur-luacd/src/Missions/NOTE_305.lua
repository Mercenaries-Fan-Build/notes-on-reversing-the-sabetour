if NOTE_305 == nil then
  NOTE_305 = SabTaskObjective:Create()
  NOTE_305:Configure({
    bWorldEvent = true,
    bCourier = true,
    bFastComplete = true,
    MCDisplayID = cNOMISSIONCOMPLETE,
    bFinishRebuild = true,
    tUnlockList = {},
    tSMEDNodes = {}
  })
end

function NOTE_305:STARTER_Setup()
end

function NOTE_305:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
end

function NOTE_305:GENERAL_Setup()
  EVENT_Timer("NOTE_305.Task_Message", self, 5)
end

function NOTE_305:Task_Message()
  self:CreateTask({
    sName = "Task_Message",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "CourierMessage",
    MessageID = "Note_Bishop1_305.Note_Bishop1_305_NOTE",
    ConvName = "Note_Bishop1_305",
    sBlockingSpore = "Missions\\act_1\\characters\\wilcox_bishopmeeting_ext",
    MsgType = cMESSAGETYPE_BISHOP,
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

function NOTE_305:Task_Complete()
end
