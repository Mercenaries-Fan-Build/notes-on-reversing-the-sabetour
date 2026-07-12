if NOTE_FP_C_Race02 == nil then
  NOTE_FP_C_Race02 = SabTaskObjective:Create()
  NOTE_FP_C_Race02:Configure({
    bWorldEvent = true,
    bCourier = true,
    bFastComplete = true,
    MCDisplayID = cNOMISSIONCOMPLETE,
    bFinishRebuild = true,
    tDependencyList = {
      "FP_CountryRace_1",
      "Connect_P3_M1b_KesslerAtDoppelsieg"
    },
    tUnlockList = {},
    tSMEDNodes = {}
  })
end

function NOTE_FP_C_Race02:STARTER_Setup()
end

function NOTE_FP_C_Race02:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
end

function NOTE_FP_C_Race02:GENERAL_Setup()
  EVENT_Timer("NOTE_FP_C_Race02.Task_Message", self, 5)
end

function NOTE_FP_C_Race02:Task_Message()
  self:CreateTask({
    sName = "Task_Message",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "CourierMessage",
    MessageID = "NOTE_FP_C_Race02.NOTE_FP_C_Race02_NOTE",
    ConvName = "NOTE_FP_C_Race02",
    MsgType = cMESSAGETYPE_RACE,
    sBlockingSpore = "Missions\\freeplay\\country\\countryrace3\\starter",
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

function NOTE_FP_C_Race02:Task_Complete()
end
