if not VehicleSpawnCondition then
  VehicleSpawnCondition = {}
end

function VehicleSpawnCondition:OnEnter()
  self.t_AllEvents = {}
  self.t_TriggerEvents = {}
  self.t_VehicleLists = {}
  self.t_HumanLists = {}
  self.t_SpawnerLists = {}
  local tPotentialObjects = VehicleSpawnCondition.BuildStreamEventTable(self)
  if 0 < #tPotentialObjects then
    table.insert(self.t_AllEvents, Util.CreateEvent({
      EventType = "StreamEvent",
      Objects = tPotentialObjects,
      WaitForGameObject = true
    }, "VehicleSpawnCondition.Configure", self))
  else
    VehicleSpawnCondition.Configure(self)
  end
end

function VehicleSpawnCondition:BuildStreamEventTable()
  local tCollectedStreamEvents = {}
  for i, v in ipairs(self.SMEDTable.lsSimpleVehicleSpawner) do
    table.insert(tCollectedStreamEvents, v)
  end
  if self.SMEDTable.sUseName then
    table.insert(tCollectedStreamEvents, self.SMEDTable.sUseName)
  end
  if self.SMEDTable.sDeactivateUseName then
    table.insert(tCollectedStreamEvents, self.SMEDTable.sDeactivateUseName)
  end
  if VehicleSpawnCondition.WhichMagicNumberVehicle(self.SMEDTable.sBlueprintName) == nil then
    local hPotentialHandle = Handle(self.SMEDTable.sBlueprintName)
    if hPotentialHandle then
      local hTempSelf = Actor.GetSelf(hPotentialHandle)
      table.insert(tCollectedStreamEvents, hTempSelf.SMEDTable.sBlueprintName)
    end
  end
  return tCollectedStreamEvents
end

function VehicleSpawnCondition.WhichMagicNumberVehicle(sWhat)
  if sWhat == "VH_NZ_TR_OpelCanvas_01" then
    return cVEH_OPEL
  elseif sWhat == "VH_NZ_CR_Kubelwagen_01" then
    return cVEH_KUBEL
  elseif sWhat == "VH_NZ_CR_Kubelwagen_mount" then
    return cVEH_KUBELTURRET
  elseif sWhat == "VH_CV_CR_Peugeot402_01" then
    return cVEH_PEUGEOT
  elseif sWhat == "VH_CV_CR_SilverDart_01" then
    return cVEH_SILVERDART
  elseif sWhat == "VH_CV_CR_SilverDartDierker_01" then
    return cVEH_DIERKERDART
  elseif sWhat == "VH_CV_CR_MaterTipo4CL_01" then
    return cVEH_MATERTIPO
  elseif sWhat == "VH_CV_CR_AlfaRom_12C_01" then
    return cVEH_ALFAROM12C
  elseif sWhat == "VH_CV_CR_AlfaRomera_01" then
    return cVEH_ALFAROMERA
  elseif sWhat == "VH_CV_CR_Allard_01" then
    return cVEH_ALLARD
  elseif sWhat == "VH_NZ_TR_OpelGun_01" then
    return cVEH_OPELGUN
  elseif sWhat == "VH_NZ_TR_HalfTrack_01" then
    return cVEH_HALFTRACK
  elseif sWhat == "VH_NZ_TK_PanzerMk3_01" then
    return cVEH_PANZER
  elseif sWhat == "VH_CV_CR_Aurora_01" then
    return cVEH_AURORA
  elseif sWhat == "VH_NZ_MO_KS750Sidecar-Mount_01" then
    return cVEH_KS750_TURRET
  elseif sWhat == "VH_OP_Peugeot_Escalation" then
    return cVEH_PEUGEOT_TURRET
  else
    return nil
  end
end

function VehicleSpawnCondition:ActivateAllVehicles()
  if self.SMEDTable.lsSimpleVehicleSpawner then
    for i, v in ipairs(self.SMEDTable.lsSimpleVehicleSpawner) do
      local hTempSelf = Actor.GetSelf(Tips.CheckForHandle(v))
      if hTempSelf then
        local nTempCounter = 1
        for nTempCounter = 1, #hTempSelf.SMEDTable.lsSpawnLocator do
          local tVehSpawningStruct = {}
          tVehSpawningStruct[1] = {}
          tVehSpawningStruct[1].vSpawnTarget = hTempSelf.SMEDTable.lsSpawnLocator[nTempCounter]
          tVehSpawningStruct[1].cVehicleType = VehicleSpawnCondition.WhichMagicNumberVehicle(hTempSelf.SMEDTable.sBlueprintName)
          if hTempSelf.SMEDTable.bFull == true then
            tVehSpawningStruct[1].tSeatConfig = hTempSelf.SMEDTable.sHumanBlueprint
          else
            tVehSpawningStruct[1].tSeatConfig = {
              Pilot = hTempSelf.SMEDTable.sHumanBlueprint
            }
          end
          tVehSpawningStruct[1].bForceSpawn = true
          tVehSpawningStruct[1].cDespawnType = cDESPAWN_ONEXIT_LOS
          tVehSpawningStruct[1].sDeliveryPath = hTempSelf.SMEDTable.sPathName
          tVehSpawningStruct[1].vDeliveryTarget = hTempSelf.SMEDTable.sFollowObject
          if hTempSelf.SMEDTable.bUnboardAtDestination == true then
            tVehSpawningStruct[1].cUnboardType = cDROPOFF_ALL
          else
            tVehSpawningStruct[1].cUnboardType = cDROPOFF_NONE
          end
          tVehSpawningStruct[1].nPathSpeed = hTempSelf.SMEDTable.nVehicleSpeed
          tVehSpawningStruct[1].bAttackPlayer = hTempSelf.SMEDTable.bHostilePlayer
          tVehSpawningStruct[1].sSquad = hTempSelf.SMEDTable.sSquad
          tVehSpawningStruct[1].bPlowThrough = hTempSelf.SMEDTable.bAvoid
          tVehSpawningStruct[1].bAddToEscalation = hTempSelf.SMEDTable.bAddToEscalation
          if tVehSpawningStruct[1].cVehicleType ~= nil then
            tVehSpawningStruct[1].tOnSpawn = {
              {
                "VehicleSpawnCondition.AddSpawnedStuff",
                {
                  "VehicleExists"
                }
              }
            }
            Veh.SpawnDelivery(self, tVehSpawningStruct[1])
          elseif Util.GetHandleByName(hTempSelf.SMEDTable.sBlueprintName) then
            tVehSpawningStruct[1].tOnSpawn = {
              {
                "VehicleSpawnCondition.AddSpawnedStuff",
                {"NoVehicle"}
              }
            }
            Veh.OnDropoffVehicleSpawned(self, Util.GetHandleByName(hTempSelf.SMEDTable.sBlueprintName), tVehSpawningStruct[1])
          end
        end
      end
    end
  end
end

function VehicleSpawnCondition:AddSpawnedStuff(hVehicle, sString)
  local tList = Vehicle.GetPassengers(hVehicle)
  if tList then
    for i, v in ipairs(tList) do
      if v ~= hSab then
        table.insert(self.t_HumanLists, v)
      end
    end
  end
  if sString == "VehicleExists" then
    table.insert(self.t_VehicleLists, hVehicle)
  end
end

function VehicleSpawnCondition:OnExit()
  for i, v in ipairs(self.t_HumanLists) do
    if Util.IsHandleValid(v) then
      Object.Despawn(v, 10, false)
    end
  end
  for i, v in ipairs(self.t_VehicleLists) do
    if Util.IsHandleValid(v) then
      Object.Despawn(v, 10, false)
    end
  end
  if self.t_AllEvents then
    for i, v in ipairs(self.t_AllEvents) do
      if v then
        Util.KillEvent(v)
      end
    end
  end
  if self.t_TriggerEvents then
    for i, v in ipairs(self.t_TriggerEvents) do
      if v and Handle(v[2]) ~= nil and Util.IsObjectHandleValid(Handle(v[2])) then
        Trigger.DoNotWaitFor(Handle(v[2]), hSab)
        Trigger.ClearCallback(Handle(v[2]), v[1])
      end
    end
  end
end

function VehicleSpawnCondition:Configure()
  local t_hAISPAWNERS = {}
  if self.SMEDTable.bByPT == true then
    local hEnteringHandle = Util.GetHandleByName(self.SMEDTable.sHandleEnteringPT)
    if hEnteringHandle == nil then
      table.insert(self.t_AllEvents, Util.CreateEvent({
        EventType = "StreamEvent",
        Objects = {
          self.SMEDTable.sHandleEnteringPT
        }
      }, "VehicleSpawnCondition.PTEventActivate", self))
    elseif Handle(self.SMEDTable.sPTName) ~= nil then
      table.insert(self.t_TriggerEvents, {
        Trigger.WaitFor(self.SMEDTable.sPTName, Util.GetHandleByName(self.SMEDTable.sHandleEnteringPT), "VehicleSpawnCondition.ActivateAllVehicles", self, {1}, cTRIGGEREVENT_ONENTER, false),
        self.SMEDTable.sPTName
      })
    end
  end
  if self.SMEDTable.bPTDeactivate == true then
    local hEnteringHandle = Util.GetHandleByName(self.SMEDTable.sHandleDeactivateEnteringPT)
    if hEnteringHandle == nil then
      table.insert(self.t_AllEvents, Util.CreateEvent({
        EventType = "StreamEvent",
        Objects = {
          self.SMEDTable.sHandleDeactivateEnteringPT
        }
      }, "VehicleSpawnCondition.PTEventDeactivate", self))
    elseif Handle(self.SMEDTable.sPTDeactivateName) ~= nil then
      table.insert(self.t_TriggerEvents, {
        Trigger.WaitFor(self.SMEDTable.sPTDeactivateName, Util.GetHandleByName(self.SMEDTable.sHandleDeactivateEnteringPT), "VehicleSpawnCondition.DeactivateByPT", self, {1}, cTRIGGEREVENT_ONENTER, false),
        self.SMEDTable.sPTDeactivateName
      })
    end
  end
  if self.SMEDTable.bByProximity == true then
    local hHandle1 = Util.GetHandleByName(self.SMEDTable.sHandle1)
    local hHandle2 = Util.GetHandleByName(self.SMEDTable.sHandle2)
    local tStreamObjects = {}
    if hHandle1 == nil then
      tStreamObjects[#tStreamObjects + 1] = self.SMEDTable.sHandle1
    end
    if hHandle2 == nil then
      tStreamObjects[#tStreamObjects + 1] = self.SMEDTable.sHandle2
    end
    if (hHandle1 and hHandle2) == nil and #tStreamObjects <= 0 then
      return
    end
    if 0 < #tStreamObjects then
      table.insert(self.t_AllEvents, Util.CreateEvent({
        EventType = "StreamEvent",
        Objects = tStreamObjects
      }, "VehicleSpawnCondition.ProximityEventActivate", self))
    else
      self.sProx_EVENT = Util.CreateEvent({
        EventType = "ProximityEvent",
        ObjectA = hHandle1,
        ObjectB = hHandle2,
        Proximity = self.SMEDTable.nDistance,
        Negate = false
      }, "VehicleSpawnCondition.ActivateAllVehicles", self, {1})
      table.insert(self.t_AllEvents, self.sProx_EVENT)
    end
  end
  if self.SMEDTable.bProximityDeactivate == true then
    local hHandle1 = Util.GetHandleByName(self.SMEDTable.sHandle1Deactivate)
    local hHandle2 = Util.GetHandleByName(self.SMEDTable.sHandle2Deactivate)
    local tStreamObjects = {}
    if hHandle1 == nil then
      tStreamObjects[#tStreamObjects + 1] = self.SMEDTable.sHandle1Deactivate
    end
    if hHandle2 == nil then
      tStreamObjects[#tStreamObjects + 1] = self.SMEDTable.sHandle2Deactivate
    end
    if 0 < #tStreamObjects then
      table.insert(self.t_AllEvents, Util.CreateEvent({
        EventType = "StreamEvent",
        Objects = tStreamObjects
      }, "VehicleSpawnCondition.ProximityEventDeactivate", self))
    else
      self.sProx_EVENTDeactivate = Util.CreateEvent({
        EventType = "ProximityEvent",
        ObjectA = hHandle1,
        ObjectB = hHandle2,
        Proximity = self.SMEDTable.nDistanceDeactivate,
        Negate = false
      }, "VehicleSpawnCondition.DeactivateALL", self, {1})
      table.insert(self.t_AllEvents, self.sProx_EVENTDeactivate)
    end
  end
  if self.SMEDTable.bByUsePT == true then
    self.sUse_EVENT = Util.CreateEvent({
      EventType = "OnActorComplete",
      Target = Util.GetHandleByName(self.SMEDTable.sUseName)
    }, "VehicleSpawnCondition.ActivateAllVehicles", self)
    table.insert(self.t_AllEvents, self.sUse_EVENT)
  end
  if self.SMEDTable.bUseDeactivate == true then
    self.sUse_EVENTDeactivate = Util.CreateEvent({
      EventType = "OnActorComplete",
      Target = Util.GetHandleByName(self.SMEDTable.sDeactivateUseName)
    }, "VehicleSpawnCondition.DeactivateALL", self)
    table.insert(self.t_AllEvents, self.sUse_EVENTDeactivate)
  end
end

function VehicleSpawnCondition:PTEventActivate()
  if Handle(self.SMEDTable.sPTName) ~= nil then
    table.insert(self.t_TriggerEvents, {
      Trigger.WaitFor(self.SMEDTable.sPTName, Util.GetHandleByName(self.SMEDTable.sHandleEnteringPT), "VehicleSpawnCondition.ActivateAllVehicles", self, {1}, cTRIGGEREVENT_ONENTER, false),
      self.SMEDTable.sPTName
    })
  end
end

function VehicleSpawnCondition:PTEventDeactivate()
  if Handle(self.SMEDTable.sPTDeactivateName) ~= nil then
    table.insert(self.t_TriggerEvents, {
      Trigger.WaitFor(self.SMEDTable.sPTDeactivateName, Util.GetHandleByName(self.SMEDTable.sHandleDeactivateEnteringPT), "VehicleSpawnCondition.DeactivateByPT", self, {1}, cTRIGGEREVENT_ONENTER, false),
      self.SMEDTable.sPTDeactivateName
    })
  end
end

function VehicleSpawnCondition:ProximityEventDeactivate()
  local hHandle1 = Util.GetHandleByName(self.SMEDTable.sHandle1Deactivate)
  local hHandle2 = Util.GetHandleByName(self.SMEDTable.sHandle2Deactivate)
  self.sProx_EVENTDeactivate = Util.CreateEvent({
    EventType = "ProximityEvent",
    ObjectA = hHandle1,
    ObjectB = hHandle2,
    Proximity = self.SMEDTable.nDistanceDeactivate,
    Negate = false
  }, "VehicleSpawnCondition.DeactivateALL", self, {1})
  table.insert(self.t_AllEvents, self.sProx_EVENTDeactivate)
end

function VehicleSpawnCondition:ProximityEventActivate()
  local hHandle1 = Util.GetHandleByName(self.SMEDTable.sHandle1)
  local hHandle2 = Util.GetHandleByName(self.SMEDTable.sHandle2)
  self.sProx_EVENT = Util.CreateEvent({
    EventType = "ProximityEvent",
    ObjectA = hHandle1,
    ObjectB = hHandle2,
    Proximity = self.SMEDTable.nDistance,
    Negate = false
  }, "VehicleSpawnCondition.ActivateAllVehicles", self, {1})
  table.insert(self.t_AllEvents, self.sProx_EVENT)
end

function VehicleSpawnCondition:OnSpawn(hwho, tUserData)
  Nav.SetScriptedPath(hwho[2], tUserData[math.random(#tUserData)])
  if self.SMEDTable.bRun == true then
    Nav.SetScriptedPathMoveMode(hwho[2], true)
  end
end

function VehicleSpawnCondition:ActivateALL()
  VehicleSpawnCondition.KillAllEvents(self)
  for i = 1, #self.t_SpawnerLists do
    Object.EnableSpawner(self.t_SpawnerLists[i], true)
  end
end

function VehicleSpawnCondition:DeactivateALL()
  for i = 1, #self.t_SpawnerLists do
    Object.EnableSpawner(self.t_SpawnerLists[i], true)
  end
end

function VehicleSpawnCondition:KillAllEvents()
  if self.SMEDTable.sPTName and Handle(self.SMEDTable.sPTName) ~= nil then
    Trigger.Enable(self.SMEDTable.sPTName, false)
  end
  if self.sProx_EVENT then
    Util.KillEvent(self.sProx_EVENT)
  end
  if self.sUse_EVENT then
    Util.KillEvent(self.sUse_EVENT)
  end
  if self.sProx_EVENTDeactivate then
    Util.KillEvent(self.sProx_EVENTDeactivate)
  end
  if self.self.sUse_EVENTDeactivate then
    Util.KillEvent(self.self.sUse_EVENTDeactivate)
  end
  if self.SMEDTable.sPTDeactivateName and Handle(self.SMEDTable.sPTDeactivateName) ~= nil then
    Trigger.Enable(self.SMEDTable.sPTDeactivateName, false)
  end
end

function VehicleSpawnCondition:DeactivateByPT(hwho)
  VehicleSpawnCondition.KillAllEvents(self)
  for i = 1, #self.t_SpawnerLists do
    Object.EnableSpawner(self.t_SpawnerLists[i], true)
  end
end

function VehicleSpawnCondition:ActivateByPT(hwho)
  VehicleSpawnCondition.KillAllEvents(self)
  for i = 1, #self.t_SpawnerLists do
    Object.EnableSpawner(self.t_SpawnerLists[i], true)
  end
end
