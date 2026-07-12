if MISSION_Random == nil then
  MISSION_Random = SabTaskObjective:Create()
  MISSION_Random:Configure({
    TaskCount = 1,
    sStarterNode = "FreePlayMission\\starter",
    sStarter = "FreePlayMission\\starter\\FreePlayMissionGiver",
    tUnlockList = {},
    bRepeatable = true,
    tSMEDNodes = {}
  })
end

function MISSION_Random:Activated()
  SabTaskObjective.Activated(self)
  math.randomseed(Util.GetGameTime())
  Render.PrintMessage("Does it even get activated????!?!?!")
  MISSION_Random.SetPathName(self)
  MISSION_Random.StartRandomTask(self)
end

function MISSION_Random:Task_Kill()
  self:CreateTask({
    sName = "MISSION_Random_Task_Kill_Nazi",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "Kill",
    tSMEDNodes = {
      self.pathname
    },
    tTgtInclude = {
      self.pathname .. "\\RandomMissionObjects\\Nazi2",
      self.pathname .. "\\RandomMissionObjects\\Nazi1"
    }
  })
  Render.PrintMessage(self.pathname .. "\\FreePlayMissionObject\\Nazi2")
end

function MISSION_Random:Task_Fetch()
  self:CreateTask({
    sName = "GetTruck",
    sTaskType = "SabTaskObjectiveDeliver",
    tSMEDNodes = {
      self.pathname
    },
    tDestProximityObj = {
      "FreePlayMission\\starter\\FreePlayMissionGiver"
    },
    Proximity = 10,
    tDeliverObjs = {
      hSab,
      self.pathname .. "\\RandomMissionObjects\\Truck1"
    },
    sTaskSubType = "DELIVER"
  })
end

function MISSION_Random:Task_Destroy()
  self:CreateTask({
    sName = "MISSION_Random_Task_Kill_Nazi",
    sTaskType = "SabTaskObjectiveDestroy",
    tSMEDNodes = {
      self.pathname
    },
    sTaskSubType = "Kill",
    tTgtInclude = {
      self.pathname .. "\\RandomMissionObjects\\Truck1"
    }
  })
end

function MISSION_Random:SetPathName()
  local random1 = math.random(5)
  if random1 == 1 then
    self.pathname = "FreePlayMission\\freeplaymission_location5"
  elseif random1 == 2 then
    self.pathname = "FreePlayMission\\freeplaymission_location2"
  elseif random1 == 3 then
    self.pathname = "FreePlayMission\\freeplaymission_location3"
  elseif random1 == 4 then
    self.pathname = "FreePlayMission\\freeplaymission_location4"
  else
    self.pathname = "FreePlayMission\\freeplaymission_location5"
  end
end

function MISSION_Random:StartRandomTask()
  local random1 = math.random(3)
  MISSION_Random.Task_Fetch(self)
end
