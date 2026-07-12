if FP_AMB_PalaisStart == nil then
  FP_AMB_PalaisStart = SabTaskObjective:Create()
  FP_AMB_PalaisStart:Configure({
    TaskCount = 99,
    sSaveMissionNameID = "MissionNames_Text.AMB_PalaisBombe",
    sActNameID = "MissionNames_Text.ACT_LeCrochet",
    MCDisplayID = 2,
    tUnlockList = {},
    bStarterless = true,
    tSMEDNodes = {
      FP_AMB_PalaisStart.sPATH .. "mission"
    },
    tStaticTags = {
      "fp_amb_pr_props_mission"
    }
  })
end

function FP_AMB_PalaisStart:STARTER_Setup()
end

function FP_AMB_PalaisStart:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
end

function FP_AMB_PalaisStart:GENERAL_Setup()
  AmbientRubberStamp.UnlockAmbientAllInZone("PR")
  self:CompleteThisMission()
end
