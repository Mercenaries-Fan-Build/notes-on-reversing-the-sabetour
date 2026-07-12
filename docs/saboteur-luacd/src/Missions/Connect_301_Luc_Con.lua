if Connect_301_Luc_Con == nil then
  Connect_301_Luc_Con = SabTaskObjective:Create()
  Connect_301_Luc_Con:Configure({
    TaskCount = 999,
    sStarter = "Luc_LaVillette_Interior",
    MCDisplayID = 2,
    sSaveMissionNameID = "MissionNames_Text.ST_301",
    bDisableMissionTitle = true,
    tUnlockList = {
      "P1FP_DestroyConvoy",
      "NOTE_302",
      "Connect_ST_302_ParisReturnVittore"
    }
  })
end

function Connect_301_Luc_Con:STARTER_Setup()
end

function Connect_301_Luc_Con:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
end

function Connect_301_Luc_Con:GENERAL_Setup()
  self:RegisterCheckpoint("Connect_301_Luc_Con.Checkpoint1")
end

function Connect_301_Luc_Con:Checkpoint1()
  self:LucConversation()
end

function Connect_301_Luc_Con:LucConversation()
  self:CreateTask({
    sName = "Connect_301_Luc_Con.Task_Talkin",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "TALK",
    bAutofire = true,
    Proximity = 65,
    sConvFile = "301a_Con_WestHQBrief",
    tTgtInclude = {
      "Missions\\paris_1\\characters\\lavillette\\luc_interior\\Luc_LaVillette_Interior"
    },
    tOnComplete = {
      {
        self.CompleteThisMission,
        {self}
      }
    }
  })
end
