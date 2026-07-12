if Paris_1_Mission_1B_Connect == nil then
  Paris_1_Mission_1B_Connect = SabTaskObjective:Create()
  Paris_1_Mission_1B_Connect:Configure({
    TaskCount = "auto",
    bStarterless = true,
    MCDisplayID = 2,
    tUnlockList = {
      "P1FP_RoofFetch01"
    },
    tSMEDNodes = {}
  })
end

function Paris_1_Mission_1B_Connect:STARTER_Setup()
  self.sDebugLabel = "P1M1BC"
  self.bDebugMode = true
  local hDoorPt = Handle("PARIS\\area01\\lavillette\\interior\\lavillette_int\\TeleporterSwingLeftDoorPoint")
  AttractionPt.EnableUse(hDoorPt, false)
  Suspicion.ResetEscalation()
end

function Paris_1_Mission_1B_Connect:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
end

function Paris_1_Mission_1B_Connect:GENERAL_Setup()
  self.sLuc = "Missions\\paris_1\\characters\\lavillette\\luc_interior\\Luc_LaVillette_Interior"
  self.SetupCheckPoint1(self)
end

function Paris_1_Mission_1B_Connect:SetupCheckPoint1()
  self.RegisterCheckpoint(self, "Paris_1_Mission_1B_Connect.CheckPoint1")
end

function Paris_1_Mission_1B_Connect:CheckPoint1()
  self:TASK_TalkToInjuredLuc()
end

function Paris_1_Mission_1B_Connect:StreamforLuc()
  local tStreamLuc = {
    EventType = "StreamEvent",
    Objects = {
      self.sLuc
    }
  }
  Util.CreateEvent(tStreamLuc, "Paris_1_Mission_1B_Connect.Waitforit", self)
end

function Paris_1_Mission_1B_Connect:Waitforit()
  EVENT_Timer("Paris_1_Mission_1B_Connect.PlayIntConv", self, 5)
end

function Paris_1_Mission_1B_Connect:PlayIntConv()
  Cin.PlayConversation("206_Con_LucHurt", "Paris_1_Mission_1B_Connect.EndThisNow", self)
end

function Paris_1_Mission_1B_Connect:EndThisNow()
  self:CompleteThisMission()
end

function Paris_1_Mission_1B_Connect:TASK_TalkToInjuredLuc()
  self:CreateTask({
    sName = "TASK_TalkToInjuredLuc",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "TALK",
    sObjectiveTextID = "P1M1B_Text.TASK_TalkLuc",
    bAutofire = true,
    Proximity = 1.25,
    bInteriorTask = true,
    sConvFile = "206_Con_LucHurt",
    tTgtInclude = {
      "Missions\\paris_1\\characters\\lavillette\\luc_interior\\Luc_LaVillette_Interior"
    },
    tOnActivate = {},
    tOnConversationComplete = {
      {
        self.CompleteThisMission,
        {self}
      }
    },
    tOnComplete = {}
  })
end
