if NOTE_405 == nil then
  NOTE_405 = SabTaskObjective:Create()
  NOTE_405:Configure({
    bWorldEvent = true,
    bCourier = true,
    bFastComplete = true,
    MCDisplayID = cNOMISSIONCOMPLETE,
    bFinishRebuild = true,
    tUnlockList = {
      "Connect_ST_405_BackToSaarbruken"
    },
    tSMEDNodes = {}
  })
end

function NOTE_405:STARTER_Setup()
end

function NOTE_405:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
end

function NOTE_405:GENERAL_Setup()
  EVENT_Timer("NOTE_405.Task_Message", self, 5)
end

function NOTE_405:Task_Message()
  self:CreateTask({
    sName = "Task_Message",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "CourierMessage",
    MessageID = "Note_Skylar3_405_PlanesReady.Note_Skylar3_405_PlanesReady_NOTE",
    ConvName = "Note_Skylar3_405_PlanesReady",
    MsgType = cMESSAGETYPE_SKYLAR,
    sBlockingSpore = "Missions\\paris_3\\connect_kessatdopp_p3m1b\\verobishwilc\\skylar_p3m1b",
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

function NOTE_405:Task_Complete()
end
