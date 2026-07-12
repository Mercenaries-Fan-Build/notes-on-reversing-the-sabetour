if NOTE_215a == nil then
  NOTE_215a = SabTaskObjective:Create()
  NOTE_215a:Configure({
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

function NOTE_215a:STARTER_Setup()
end

function NOTE_215a:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
end

function NOTE_215a:GENERAL_Setup()
  EVENT_Timer("NOTE_215a.Task_Message", self, 5)
end

function NOTE_215a:Task_Message()
  self:CreateTask({
    sName = "Task_Message",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "CourierMessage",
    MessageID = "Note_Skylar1_215a.Note_Skylar1_215a_NOTE",
    ConvName = "Note_Skylar1_215a",
    sBlockingSpore = "LeHavre\\characters\\hotel\\skylar_interior",
    MsgType = cMESSAGETYPE_SKYLAR,
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

function NOTE_215a:Task_Complete()
end
