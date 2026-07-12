if Connect_ST_P3_Need == nil then
  Connect_ST_P3_Need = SabTaskObjective:Create()
  Connect_ST_P3_Need:Configure({
    TaskCount = 999,
    sStarter = "Luc_LaVillette_Interior",
    sSaveMissionNameID = "MissionNames_Text.Connect_P3Papers",
    bDisableMissionTitle = true,
    MCDisplayID = 2,
    tUnlockList = {
      "Connect_P3PapersIntro"
    },
    sConvFile = "ST_P3_Need_Complete",
    tSMEDNodes = {}
  })
end

function Connect_ST_P3_Need:STARTER_Setup()
end

function Connect_ST_P3_Need:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
end

function Connect_ST_P3_Need:GENERAL_Setup()
  self:CompleteThisMission()
end
