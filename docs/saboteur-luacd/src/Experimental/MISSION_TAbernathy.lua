if MISSION_TAbernathy == nil then
  MISSION_TAbernathy = SabTaskObjective:Create()
  MISSION_TAbernathy:Configure({
    TaskCount = 1,
    sAreaID = "MISSION_TAbernathy_Area_1",
    WTFValue = 0,
    sStarter = "Starters\\STARTER_TAbernathy",
    tDependencyList = {}
  })
end

function MISSION_TAbernathy:Activated()
  SabTaskObjective.Activated(self)
  MISSION_TAbernathy.InitTask1(self)
end

function MISSION_TAbernathy:InitTask1()
  self:CreateTask({
    sName = "MISSION_TAbernathy_Task1",
    sTaskType = "SabTaskObjectiveDestroy",
    sPartialCompleteMsg = "",
    vTgtInclude = {},
    tOnComplete = {},
    tOnCancel = {},
    tOnActivate = {}
  })
end
