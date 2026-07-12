if ScriptName == nil then
  ScriptName = SabTaskObjective:Create()
  ScriptName:Configure({
    TaskCount = "auto",
    bStarterless = true,
    MCDisplayID = 2,
    tSMEDNodes = {}
  })
end

function ScriptName:STARTER_Setup()
  self.sDebugLabel = ""
  self.bDebugMode = false
end

function ScriptName:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
end

function ScriptName:GENERAL_Setup()
  local sObjCarriedOver = "Object_String"
  self.sSMEDDynamicNode = ""
  self.sDestinationLocator = ""
  self.sPickupTrigger = ""
  self.sDropOffTrigger = ""
  self.sMasterObjective = ""
  self.sTaxiCarObjective = ""
  self.sTaxiPickupObjective = ""
  self.sTaxiDropOffObjective = ""
  if Util.GetHandleByName(sObjCarriedOver) then
    self.hObjectHandle = Util.GetHandleByName(sObjCarriedOver)
    self.sObjectString = sObjCarriedOver
    self:Ready()
  else
    Util.SpawnEditNode(self.sSMEDDynamicNode, "ScriptName.OnObjectLoad", self)
  end
end

function ScriptName:OnObjectLoad()
  local sObjLoaded = "Object_Loaded_String"
  if Util.GetHandleByName(sObjLoaded) then
    self.hObjectHandle = Util.GetHandleByName(sObjLoaded)
    self.sObjectString = sObjLoaded
  else
  end
  ScriptName:Ready()
end

function ScriptName:Ready()
  self.tTaxiDeliverObjs = {
    self.sObjectString
  }
  self:TASK_FirstTask()
end

function ScriptName:TASK_FirstTask()
  self:CreateTask({
    sName = "TASK_FirstTask",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "empty",
    sObjectiveTextID = self.sMasterObjective,
    tLocators = {},
    tOnActivate = {
      {
        self.TASK_TaxiTask,
        {self}
      }
    },
    tOnComplete = {}
  })
end

function ScriptName:TASK_TaxiTask()
  self:CreateTask({
    sName = "TASK_TaxiTask",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "TAXI",
    ParentObjectID = self:GetTaskObjectiveID("TASK_FirstTask"),
    sObjectiveTextID = "Blah",
    sVehicleFetchID = self.sTaxiCarObjective,
    sPickupTextID = self.sTaxiPickupObjective,
    sDropoffTextID = self.sTaxiDropOffObjective,
    tDestLocators = {
      self.sDestinationLocator
    },
    tPickupRegion = {
      self.sPickupTrigger
    },
    tDestRegion = {
      self.sDropOffTrigger
    },
    tDeliverObjs = self.tTaxiDeliverObjs,
    tOnEarlyExit = {},
    tOnPickup = {},
    tOnComplete = {
      {
        self.Cleanup,
        {self}
      },
      {
        self.CompleteThisMission,
        {self}
      }
    },
    tOnActivate = {},
    tSMEDNodes = {}
  })
end

function ScriptName:Cleanup()
  Util.UnloadEditNode(self.sSMEDDynamicNode, false, false)
end
