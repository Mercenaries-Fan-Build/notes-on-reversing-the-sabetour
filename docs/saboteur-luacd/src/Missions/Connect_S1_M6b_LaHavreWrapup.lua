if Connect_S1_M6b_LaHavreWrapup == nil then
  Connect_S1_M6b_LaHavreWrapup = SabTaskObjective:Create()
  Connect_S1_M6b_LaHavreWrapup:Configure({
    TaskCount = "99",
    sStarter = "wilcox_lehavre_interior",
    sConvFile = "S1M6b_Complete",
    sSaveMissionNameID = "MissionNames_Text.S1M6",
    bDisableMissionTitle = true,
    StarterIcon = "mm_MS_Wilcox_1",
    MCDisplayID = 2,
    tUnlockList = {
      "Connect_Cin_301_Act3",
      "P2FP_InfiltrateAbbey"
    },
    tSMEDNodes = {}
  })
end

function Connect_S1_M6b_LaHavreWrapup:STARTER_Setup()
  Vehicle.EnableTraffic(true)
  self.SayYourOneLineSean(self)
end

function Connect_S1_M6b_LaHavreWrapup:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
end

function Connect_S1_M6b_LaHavreWrapup:GENERAL_Setup()
  self:CompleteThisMission()
end

function Connect_S1_M6b_LaHavreWrapup:SayYourOneLineSean()
  Cin.PlayConversation("S1M6b_OMW")
end
