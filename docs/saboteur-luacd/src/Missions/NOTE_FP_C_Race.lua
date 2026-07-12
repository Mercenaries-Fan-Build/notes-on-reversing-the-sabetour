if NOTE_FP_C_Race == nil then
  NOTE_FP_C_Race = SabTaskObjective:Create()
  NOTE_FP_C_Race:Configure({
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

function NOTE_FP_C_Race:STARTER_Setup()
end

function NOTE_FP_C_Race:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
end

function NOTE_FP_C_Race:GENERAL_Setup()
  EVENT_Timer("NOTE_FP_C_Race.Task_Message", self, 5)
end

function NOTE_FP_C_Race:Task_Message()
  self:CreateTask({
    sName = "Task_Message",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "CourierMessage",
    MessageID = "NOTE_FP_C_Race.NOTE_FP_C_Race_NOTE",
    ConvName = "NOTE_FP_C_Race",
    MsgType = cMESSAGETYPE_RACE,
    sBlockingSpore = "Missions\\freeplay\\country\\countryrace1\\starter",
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

function NOTE_FP_C_Race:Task_Complete()
end
