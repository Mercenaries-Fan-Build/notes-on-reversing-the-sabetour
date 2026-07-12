if Connect_Cin_301_Act3 == nil then
  print("$$$$ Loading Connect_Cin_301_Act3")
  Connect_Cin_301_Act3 = SabTaskObjective:Create()
  Connect_Cin_301_Act3:Configure({
    TaskCount = 999,
    sStarter = "Veronique_LaVillette_Front",
    bAutofireInterior = true,
    sSaveMissionNameID = "MissionNames_Text.ST_301",
    bDisableMissionTitle = true,
    MCDisplayID = 2,
    tUnlockList = {
      "Connect_301_Luc_Con"
    },
    tCinematicNodes = {
      "301_cinb_act3"
    }
  })
end

function Connect_Cin_301_Act3:STARTER_Setup()
  self.SayYourOneLineSean(self)
  Cin.LoadCinematic("301_CinB_Act3")
end

function Connect_Cin_301_Act3:Activated()
  print("$$$$$$$$$$$Connect_Cin_301_Act3.Activated")
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
end

function Connect_Cin_301_Act3:GENERAL_Setup()
  Cin.PlayCinematic("301_CinB_Act3", false, "Connect_Cin_301_Act3.CompleteThisMission", self)
end

function Connect_Cin_301_Act3:SayYourOneLineSean()
  Cin.PlayConversation("ST_301_OMW")
end
