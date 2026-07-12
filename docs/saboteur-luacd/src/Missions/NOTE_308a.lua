if NOTE_308a == nil then
  NOTE_308a = SabTaskObjective:Create()
  NOTE_308a:Configure({
    bWorldEvent = true,
    bCourier = true,
    bFastComplete = true,
    MCDisplayID = cNOMISSIONCOMPLETE,
    bFinishRebuild = true,
    tUnlockList = {},
    tSMEDNodes = {}
  })
end

function NOTE_308a:STARTER_Setup()
end

function NOTE_308a:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
  EVENT_Timer("NOTE_308a.Task_Message", self, 120)
end

function NOTE_308a:GENERAL_Setup()
end

function NOTE_308a:Task_Message()
  self:CreateTask({
    sName = "Task_Message",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "CourierMessage",
    MessageID = "Note_Skylar2_308a.Note_Skylar2_308a_NOTE",
    ConvName = "Note_Skylar2_308a",
    MsgType = cMESSAGETYPE_SKYLAR,
    sBlockingSpore = "Missions\\soe_2\\mission_2\\starter",
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

function NOTE_308a:Task_Complete()
end
