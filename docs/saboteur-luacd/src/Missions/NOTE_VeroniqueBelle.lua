if NOTE_VeroniqueBelle == nil then
  NOTE_VeroniqueBelle = SabTaskObjective:Create()
  NOTE_VeroniqueBelle:Configure({
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

function NOTE_VeroniqueBelle:STARTER_Setup()
end

function NOTE_VeroniqueBelle:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
end

function NOTE_VeroniqueBelle:GENERAL_Setup()
  if Util.IsBlockLoaded("Missions\\paris_1\\characters\\belle\\gaspard_interior.wsd") then
    Util.UnloadEditNode("Missions\\paris_1\\characters\\belle\\gaspard_interior.wsd")
  end
  EVENT_Timer("NOTE_VeroniqueBelle.Task_Message", self, 5)
end

function NOTE_VeroniqueBelle:Task_Message()
  self:CreateTask({
    sName = "Task_Message",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "CourierMessage",
    MessageID = "Note_Veronique_Belle.Line",
    ConvName = "Note_Veronique_Belle",
    MsgType = cMESSAGETYPE_VITTORE,
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

function NOTE_VeroniqueBelle:Task_Complete()
end
