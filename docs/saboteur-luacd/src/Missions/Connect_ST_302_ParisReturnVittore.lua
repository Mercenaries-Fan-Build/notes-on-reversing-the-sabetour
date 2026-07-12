if Connect_ST_302_ParisReturnVittore == nil then
  Connect_ST_302_ParisReturnVittore = SabTaskObjective:Create()
  Connect_ST_302_ParisReturnVittore:Configure({
    TaskCount = 99,
    sStarter = "vittore_garage",
    MCDisplayID = 2,
    sSaveMissionNameID = "MissionNames_Text.ST_302",
    bDisableMissionTitle = true,
    tUnlockList = {
      "NOTE_307",
      "Connect_ST_307_ParkHangingBigGun"
    },
    tSMEDNodes = {}
  })
end

function Connect_ST_302_ParisReturnVittore:STARTER_Setup()
end

function Connect_ST_302_ParisReturnVittore:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
end

function Connect_ST_302_ParisReturnVittore:GENERAL_Setup()
  self:RegisterCheckpoint("Connect_ST_302_ParisReturnVittore.Checkpoint1")
end

function Connect_ST_302_ParisReturnVittore:Checkpoint1()
  self.PlayVittoreConvo(self)
end

function Connect_ST_302_ParisReturnVittore:PlayVittoreConvo()
  self:CreateTask({
    sName = "Task_PlayVittoreConvo",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "TALK",
    sConvFile = "302_Con_Vitto",
    tTgtInclude = {
      "Missions\\paris_1\\characters\\belle\\vit_belle_garage\\vittore_garage"
    },
    bAutofire = true,
    tOnActivate = {},
    tOnComplete = {
      {
        self.CompleteThisMission,
        {self}
      }
    }
  })
end
