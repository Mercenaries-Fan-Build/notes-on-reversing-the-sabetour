if MISSION_MTipul == nil then
  MISSION_MTipul = SabTaskObjective:Create()
  MISSION_MTipul:Configure({
    TaskCount = 1,
    sAreaID = "MISSION_MTipul_Area_1",
    WTFValue = 0,
    sStarter = "Starters\\STARTER_MTipul",
    tDependencyList = {}
  })
end

function MISSION_MTipul:Activated()
  SabTaskObjective.Activated(self)
  MISSION_MTipul.InitTask1(self)
end

function MISSION_MTipul:InitTask1()
  self:CreateTask({
    sName = "MISSION_MTipul_Task1",
    sTaskType = "SabTaskObjectiveDestroy",
    sPartialCompleteMsg = "",
    vTgtInclude = {},
    tOnComplete = {},
    tOnCancel = {},
    tOnActivate = {}
  })
end
