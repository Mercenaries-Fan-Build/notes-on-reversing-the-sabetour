if Connect_ST_316_VeroDistrustsSkylar == nil then
  Connect_ST_316_VeroDistrustsSkylar = SabTaskObjective:Create()
  Connect_ST_316_VeroDistrustsSkylar:Configure({
    TaskCount = "auto",
    sStarter = "Veronique_LaVillette_Front",
    sSaveMissionNameID = "MissionNames_Text.ST_316",
    bDisableMissionTitle = true,
    MCDisplayID = 2,
    tUnlockList = {
      "Connect_ST_P3_Need"
    },
    sConvFile = "316_Con_GoRadio",
    tSMEDNodes = {}
  })
end

function Connect_ST_316_VeroDistrustsSkylar:GENERAL_Setup()
  self:SayYourOneLineSean()
end

function Connect_ST_316_VeroDistrustsSkylar:STARTER_Setup()
  local hATPT = Handle("Missions\\paris_1\\characters\\lavillette\\veronique_front\\LOC_Vero_Talk")
  if hATPT then
    local hVeronique = Handle("Missions\\paris_1\\characters\\lavillette\\veronique_front\\Veronique_LaVillette_Front")
    if hVeronique then
      Nav.MoveToObject(hVeronique, hATPT, 1, false)
    end
  end
end

function Connect_ST_316_VeroDistrustsSkylar:SayYourOneLineSean()
  Cin.PlayConversation("ST_316_OMW")
end

function Connect_ST_316_VeroDistrustsSkylar:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
end

function Connect_ST_316_VeroDistrustsSkylar:GENERAL_Setup()
  self:CompleteThisMission()
end

function Connect_ST_316_VeroDistrustsSkylar:Task_ShowCinematic()
  self:CreateTask({
    sName = "Task_ShowCinematic",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "316_Con_GoRadio",
    tOnActivate = {},
    tOnComplete = {}
  })
end
