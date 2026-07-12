if CFP_Chambord == nil then
  CFP_Chambord = SabTaskObjective:Create()
  CFP_Chambord.sPATH = "Missions\\freeplay\\country\\mis_chambord\\"
  CFP_Chambord:Configure({
    TaskCount = 99,
    bFreeplay = true,
    bStarterless = true,
    tUnlockList = {},
    tSMEDNodes = {
      CFP_Chambord.sPATH .. "main"
    }
  })
end

function CFP_Chambord:STARTER_Setup()
end

function CFP_Chambord:Activated()
  SabTaskObjective.Activated(self)
  self.sDebugLabel = "CFP_CHAMBORD"
  self.bDebugMode = false
  self.sWTFZone = self.sPATH .. "WTF"
  self.GENERAL_Setup(self)
  self.Task_MainTask(self)
end

function CFP_Chambord:GENERAL_Setup()
  self.bComplete = false
  self.sP = self.sPATH .. "wtf_low\\nazis\\"
  self.hSab = Util.GetHandleByName("Saboteur")
  self.tObjects = {
    self.sP .. "CEM_Chambord_FreeplayProps\\SpawnBunker_Small\\SpawnBunker",
    self.sP .. "CEM_Chambord_FreeplayProps\\Radar",
    self.sP .. "CEM_Chambord_FreeplayProps\\Barrel_of_boom",
    self.sP .. "CEM_Chambord_FreeplayProps\\Barrel_of_boom(3)",
    self.sP .. "CEM_Chambord_FreeplayProps\\Barrel_of_boom(4)",
    self.sP .. "CEM_Chambord_FreeplayProps\\Barrel_of_boom(5)",
    self.sP .. "CEM_Chambord_FreeplayProps\\Barrel_of_boom(6)",
    self.sP .. "CEM_Chambord_FreeplayProps\\Barrel_of_boom(7)",
    self.sP .. "CEM_Chambord_FreeplayProps\\Barrel_of_boom(3)",
    self.sP .. "NZ_BackGateGuardA",
    self.sP .. "NZ_BackGateGuardB",
    self.sP .. "NZ_FrontGateGuardA",
    self.sP .. "NZ_FrontGateGuardB",
    self.sP .. "NZ_OuterBackYardEast",
    self.sP .. "NZ_OuterBackYardWest",
    self.sP .. "NZ_OuterYardEast",
    self.sP .. "NZ_OuterYardWest",
    self.sP .. "NZ_UpperLevel"
  }
  self.nDamageAmount = 100
  self.nDmgVarLow = 0
  self.nDmgVarHigh = 10
  self.nMaxDamage = 1400
  self.nCurDamage = 0
  self:WaitForStream()
end

function CFP_Chambord:Task_MainTask()
  self:CreateTask({
    sName = "CFP_Chambord_Task_MainTask",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "NONE",
    sObjectiveTextID = "CFP_Chambord_Text.Task_MainTask",
    tOnActivate = {
      {
        self.SetupDamageMeter,
        {self}
      }
    },
    tOnComplete = {}
  })
end

function CFP_Chambord:SetupDamageMeter()
  local hParent = self:GetTaskObjectiveID("CFP_Chambord_Task_MainTask")
  self.hHUDObjective = HUD.AddObjective(eOT_DESTROY, "CFP_Chambord_Text.DamageMeter", 1, hParent)
  HUD.SetupProgressBar(self.hHUDObjective, 0, self.nMaxDamage, 0)
end

function CFP_Chambord:WaitForStream()
  for i, sObj in ipairs(self.tObjects) do
    local tStreamEvent = {
      EventType = "StreamEvent",
      Objects = {sObj},
      WaitForGameObject = true,
      WaitForPathfinding = false,
      WaitForPhysics = false
    }
    Util.CreateEvent(tStreamEvent, "CFP_Chambord.SetupDeathEvents", self, {sObj})
  end
end

function CFP_Chambord:SetupDeathEvents(a_sObject)
  tDeathEvent = {
    EventType = "DeathEvent",
    ObjectHandle = Handle(a_sObject)
  }
  Util.CreateEvent(tDeathEvent, "CFP_Chambord.ObjectDeath", self, {a_sObject})
end

function CFP_Chambord:UpdateProxCheck(a_bNegate)
end

function CFP_Chambord:ObjectDeath(a_sObject)
  self.UpdateDamage(self, a_sObject)
end

function CFP_Chambord:UpdateDamage(a_sObject)
  local nBoomBonus = 0
  local sUpObj = string.upper(a_sObject)
  if a_sObject and (string.find(sUpObj, "GENERATOR") or string.find(sUpObj, "TRUCK") or string.find(sUpObj, "OILTANK") or string.find(sUpObj, "WATCHTOWER")) then
    nBoomBonus = 50
  end
  self.nCurDamage = self.nCurDamage + (self.nDamageAmount + math.random(self.nDmgVarLow, self.nDmgVarHigh)) + nBoomBonus
  dprint(self, "self.nCurDamage = " .. self.nCurDamage)
  HUD.SetProgressBarValue(self.hHUDObjective, self.nCurDamage)
  if self.nCurDamage >= self.nMaxDamage and not self.bComplete then
    self.bComplete = true
    HUD.RemoveObjective(self.hHUDObjective)
    local oTask = self:GetMissionTask("CFP_Chambord_Task_MainTask")
    oTask:CompleteEmptyTask()
    self:CompleteThisMission()
  end
end
