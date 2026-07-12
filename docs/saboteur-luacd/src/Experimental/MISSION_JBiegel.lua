if MISSION_JBiegel == nil then
  MISSION_JBiegel = SabTaskObjective:Create()
  MISSION_JBiegel:Configure({
    TaskCount = "auto",
    sAreaID = "",
    WTFValue = 0,
    sStarter = "Starters\\STARTER_CFrench",
    tDependencyList = {},
    tUnlockList = {},
    sStarterNode = "Starters",
    tSMEDNodes = {}
  })
end

function MISSION_JBiegel:Activated()
  SabTaskObjective.Activated(self)
  MISSION_JBiegel.InitTask1(self)
end

function MISSION_JBiegel:InitTask1()
end
