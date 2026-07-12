if Connect_ST_209_DeliverLucMeds == nil then
  Connect_ST_209_DeliverLucMeds = SabTaskObjective:Create()
  Connect_ST_209_DeliverLucMeds:Configure({
    TaskCount = "auto",
    sStarter = "Veronique_LaVillette_Interior",
    MCDisplayID = 0,
    tUnlockList = {
      "P1FP_Traitor",
      "NOTE_Santos01"
    },
    tSMEDNodes = {}
  })
end

function Connect_ST_209_DeliverLucMeds:STARTER_Setup()
end

function Connect_ST_209_DeliverLucMeds:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
end

function Connect_ST_209_DeliverLucMeds:GENERAL_Setup()
  self:RegisterCheckpoint("Connect_ST_209_DeliverLucMeds.Checkpoint1")
end

function Connect_ST_209_DeliverLucMeds:Checkpoint1()
  if not self:IsMissionTaskActive("Task_FirstObjective") then
    self:Task_FirstObjective()
  end
  HUD.ClearWaypoint()
  HUD.ClearGPSTarget()
end

function Connect_ST_209_DeliverLucMeds:Task_FirstObjective()
  self:CreateTask({
    sName = "Connect_ST_209_DeliverLucMeds_Task_FirstObjective",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "empty",
    bCompleteOnActivate = true,
    tOnActivate = {
      {
        self.Task_Convo,
        {self}
      }
    },
    tOnComplete = {}
  })
end

function Connect_ST_209_DeliverLucMeds:Task_Convo()
  self:CreateTask({
    sName = "Connect_ST_209_DeliverLucMeds.Task_Convo",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "DELIVER",
    tDestProximityObj = {
      "Missions\\paris_1\\characters\\lavillette\\veronique_interior\\Veronique_LaVillette_Interior"
    },
    tDeliverObjs = {hSab},
    Proximity = 3.5,
    tOnComplete = {
      {
        self.Convo_LucDone,
        {self}
      }
    }
  })
end

function Connect_ST_209_DeliverLucMeds:Convo_LucDone()
  Cin.PlayConversation("209_Con_LucDone", "Connect_ST_209_DeliverLucMeds.CompleteThisMission", self, {})
end

function Connect_ST_209_DeliverLucMeds:Task_ShowCinematic()
  self:CreateTask({
    sName = "Connect_ST_209_DeliverLucMeds_Task_ShowCinematic",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "Sab_Placeholder",
    tOnActivate = {},
    tOnComplete = {
      {
        self.CompleteThisMission,
        {self}
      }
    }
  })
end
