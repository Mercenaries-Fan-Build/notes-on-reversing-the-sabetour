require("Includes\\WRAPPER_Util")

function EVENT_KillEvent(a_hEvent)
  Util.KillEvent(a_hEvent)
end

function EVENT_Timer(a_sCallbackFunction, self, a_nTime, a_tUserTable)
  local tUserTable
  if type(a_tUserTable) == "table" then
    tUserTable = a_tUserTable
  else
    tUserTable = {a_tUserTable}
  end
  local eEvent = Util.CreateEvent({EventType = "TimerEvent", Time = a_nTime}, a_sCallbackFunction, self, tUserTable)
  if self and self._SELFTABLE_ID then
    self:RegisterEvent(eEvent)
  end
  return eEvent
end

function EVENT_ActorDeath(a_sCallbackFunction, self, a_vActor, a_tUserTable)
  a_vActor = WRAPPER_CheckForHandle(a_vActor)
  if not a_vActor then
    print("WARNING: a_vActor is nil in EVENT_ActorDeath")
  end
  local tUserTable
  if type(a_tUserTable) == "table" then
    tUserTable = a_tUserTable
  else
    tUserTable = {a_tUserTable}
  end
  local eEvent
  if Object.IsVehicle(a_vActor) then
    Vehicle.RegisterWaterLoggedCallback(a_vActor, a_sCallbackFunction, self, a_tUserTable)
    if not self or self._SELFTABLE_ID then
    end
  end
  eEvent = Util.CreateEvent({EventType = "DeathEvent", ObjectHandle = a_vActor}, a_sCallbackFunction, self, tUserTable)
  if self and self._SELFTABLE_ID then
    self:RegisterEvent(eEvent)
  end
  return eEvent
end

function EVENT_ActorDamaged(a_sCallbackFunction, self, a_vActor, a_tUserTable, a_bPersistent)
  a_vActor = WRAPPER_CheckForHandle(a_vActor)
  if not a_vActor then
    print("WARNING: a_vActor is nil in EVENT_ActorDamaged")
  end
  local tUserTable
  if type(a_tUserTable) == "table" then
    tUserTable = a_tUserTable
  else
    tUserTable = {a_tUserTable}
  end
  local eEvent = Util.CreateEvent({EventType = "OnDamage", Target = a_vActor}, a_sCallbackFunction, self, tUserTable, a_bPersistent)
  if self and self._SELFTABLE_ID then
    self:RegisterEvent(eEvent)
  end
  return eEvent
end

function EVENT_ActorEntersTrigger(a_sCallbackFunction, self, a_vActor, a_vTriggerRegion, a_tUserTable)
  a_vActor = WRAPPER_CheckForHandle(a_vActor)
  if not a_vActor then
    print("WARNING: a_vActor is nil in EVENT_ActorEntersTrigger")
  end
  local tUserTable
  if type(a_tUserTable) == "table" then
    tUserTable = a_tUserTable
  else
    tUserTable = {a_tUserTable}
  end
  a_vTriggerRegion = WRAPPER_CheckForHandle(a_vTriggerRegion)
  if not a_vTriggerRegion then
    print("WARNING: a_vTriggerRegion is nil in EVENT_ActorEntersTrigger")
  end
  local hTriggerID = Trigger.WaitFor(a_vTriggerRegion, a_vActor, a_sCallbackFunction, self, tUserTable, cTRIGGEREVENT_ONENTER_SMART, false)
  if self and self._SELFTABLE_ID then
    self:RegisterTriggerEvent(hTriggerID, a_vTriggerRegion)
  end
  return hTriggerID
end

function EVENT_ActorExitsTrigger(a_sCallbackFunction, self, a_vActor, a_vTriggerRegion, a_tUserTable)
  a_vActor = WRAPPER_CheckForHandle(a_vActor)
  if not a_vActor then
    print("WARNING: a_vActor is nil in EVENT_ActorExitsTrigger")
  end
  local tUserTable
  if type(a_tUserTable) == "table" then
    tUserTable = a_tUserTable
  else
    tUserTable = {a_tUserTable}
  end
  a_vTriggerRegion = WRAPPER_CheckForHandle(a_vTriggerRegion)
  if not a_vTriggerRegion then
    print("WARNING: a_vTriggerRegion is nil in EVENT_ActorExitsTrigger")
  end
  local hTriggerID = Trigger.WaitFor(a_vTriggerRegion, a_vActor, a_sCallbackFunction, self, tUserTable, cTRIGGEREVENT_ONEXIT, false)
  if self and self._SELFTABLE_ID then
    self:RegisterTriggerEvent(hTriggerID, a_vTriggerRegion)
  end
  return hTriggerID
end

function EVENT_ActorToActorProximity(a_sCallbackFunction, self, a_vActor1, a_vActor2, a_nDistance, a_tUserTable, a_bPersistent, a_b2d)
  a_vActor1 = WRAPPER_CheckForHandle(a_vActor1)
  if not a_vActor1 then
    print("WARNING: a_vActor1 is nil in EVENT_ActorToActorProximity")
  end
  local tUserTable
  if type(a_tUserTable) == "table" then
    tUserTable = a_tUserTable
  else
    tUserTable = {a_tUserTable}
  end
  a_vActor2 = WRAPPER_CheckForHandle(a_vActor2)
  if not a_vActor2 then
    print("WARNING: a_vActor2 is nil in EVENT_ActorToActorProximity")
  end
  local eEvent = Util.CreateEvent({
    EventType = "ProximityEvent",
    ObjectA = a_vActor1,
    ObjectB = a_vActor2,
    Proximity = a_nDistance,
    Check3D = not a_b2d
  }, a_sCallbackFunction, self, tUserTable, a_bPersistent)
  if self and self._SELFTABLE_ID then
    self:RegisterEvent(eEvent)
  end
  return eEvent
end

function EVENT_ActorToActorProximityNegated(a_sCallbackFunction, self, a_vActor1, a_vActor2, a_nDistance, a_tUserTable, a_bPersistent, a_b2d)
  a_vActor1 = WRAPPER_CheckForHandle(a_vActor1)
  if not a_vActor1 then
    print("WARNING: a_vActor1 is nil in EVENT_ActorToActorProximityNegated")
  end
  local tUserTable
  if type(a_tUserTable) == "table" then
    tUserTable = a_tUserTable
  else
    tUserTable = {a_tUserTable}
  end
  a_vActor2 = WRAPPER_CheckForHandle(a_vActor2)
  if not a_vActor2 then
    print("WARNING: a_vActor2 is nil in EVENT_ActorToActorProximityNegated")
  end
  local eEvent = Util.CreateEvent({
    EventType = "ProximityEvent",
    ObjectA = a_vActor1,
    ObjectB = a_vActor2,
    Proximity = a_nDistance,
    Check3D = not a_b2d,
    Negate = true
  }, a_sCallbackFunction, self, tUserTable, a_bPersistent)
  if self and self._SELFTABLE_ID then
    self:RegisterEvent(eEvent)
  end
  return eEvent
end

function EVENT_PlayerEntersTrigger(a_sCallbackFunction, self, a_vTriggerRegion, a_bPersistent, a_tUserTable)
  local trig = a_vTriggerRegion
  a_vTriggerRegion = WRAPPER_CheckForHandle(a_vTriggerRegion)
  local hSab = WRAPPER_CheckForHandle("Saboteur")
  a_bPersistent = a_bPersistent or false
  if not a_vTriggerRegion then
    print("WARNING: a_vTriggerRegion is nil in EVENT_PlayerEntersTrigger", trig)
  end
  local tUserTable
  if type(a_tUserTable) == "table" then
    tUserTable = a_tUserTable
  else
    tUserTable = {a_tUserTable}
  end
  local hTriggerID = Trigger.WaitFor(a_vTriggerRegion, hSab, a_sCallbackFunction, self, tUserTable, cTRIGGEREVENT_ONENTER_SMART, a_bPersistent)
  if self and self._SELFTABLE_ID then
    self:RegisterTriggerEvent(hTriggerID, a_vTriggerRegion)
  end
  return hTriggerID
end

function EVENT_PlayerExitsTrigger(a_sCallbackFunction, self, a_vTriggerRegion, a_bPersistent, a_tUserTable)
  local trig = a_vTriggerRegion
  a_vTriggerRegion = WRAPPER_CheckForHandle(a_vTriggerRegion)
  local hSab = WRAPPER_CheckForHandle("Saboteur")
  a_bPersistent = a_bPersistent or false
  if not a_vTriggerRegion then
    print("WARNING: a_vTriggerRegion is nil in EVENT_PlayerEntersTrigger ", trig)
  end
  local tUserTable
  if type(a_tUserTable) == "table" then
    tUserTable = a_tUserTable
  else
    tUserTable = {a_tUserTable}
  end
  local hTriggerID = Trigger.WaitFor(a_vTriggerRegion, hSab, a_sCallbackFunction, self, tUserTable, cTRIGGEREVENT_ONEXIT, a_bPersistent)
  if self and self._SELFTABLE_ID then
    self:RegisterTriggerEvent(hTriggerID, a_vTriggerRegion)
  end
  return hTriggerID
end

function EVENT_PlayerToActorProximity(a_sCallbackFunction, self, a_vActor, a_nDistance, a_tUserTable, a_bPersistent, a_b2d)
  a_vActor = WRAPPER_CheckForHandle(a_vActor)
  if not a_vActor then
    print("WARNING: a_vActor is nil in EVENT_PlayerToActorProximity")
  end
  local tUserTable
  if type(a_tUserTable) == "table" then
    tUserTable = a_tUserTable
  else
    tUserTable = {a_tUserTable}
  end
  local eEvent = Util.CreateEvent({
    EventType = "ProximityEvent",
    ObjectA = a_vActor,
    ObjectB = hSab,
    Proximity = a_nDistance,
    Check3D = not a_b2d
  }, a_sCallbackFunction, self, tUserTable, a_bPersistent)
  if self and self._SELFTABLE_ID then
    self:RegisterEvent(eEvent)
  end
  return eEvent
end

function EVENT_PlayerToActorProximityNegated(a_sCallbackFunction, self, a_vActor, a_nDistance, a_tUserTable, a_bPersistent, a_b2d)
  a_vActor = WRAPPER_CheckForHandle(a_vActor)
  if not a_vActor then
    print("WARNING: a_vActor is nil in EVENT_PlayerToActorProximityNegated")
  end
  local tUserTable
  if type(a_tUserTable) == "table" then
    tUserTable = a_tUserTable
  else
    tUserTable = {a_tUserTable}
  end
  local eEvent = Util.CreateEvent({
    EventType = "ProximityEvent",
    ObjectA = a_vActor,
    ObjectB = hSab,
    Proximity = a_nDistance,
    Check3D = not a_b2d,
    Negate = true
  }, a_sCallbackFunction, self, tUserTable, a_bPersistent)
  if self and self._SELFTABLE_ID then
    self:RegisterEvent(eEvent)
  end
  return eEvent
end

function EVENT_ActorEntersAnyVehicle(a_sCallbackFunction, self, a_vActor, a_tUserTable, a_bPersistent)
  a_vActor = WRAPPER_CheckForHandle(a_vActor)
  if not a_vActor then
    print("WARNING: a_vActor is nil in EVENT_ActorEntersAnyVehicle")
  end
  local tUserTable
  if type(a_tUserTable) == "table" then
    tUserTable = a_tUserTable
  else
    tUserTable = {a_tUserTable}
  end
  local eEvent = Util.CreateEvent({
    EventType = "OnVehicleEnter",
    Target = a_vActor
  }, a_sCallbackFunction, self, tUserTable, a_bPersistent)
  if self and self._SELFTABLE_ID then
    self:RegisterEvent(eEvent)
  end
  return eEvent
end

function EVENT_ActorExitsAnyVehicle(a_sCallbackFunction, self, a_vActor, a_tUserTable, a_bPersistent)
  a_vActor = WRAPPER_CheckForHandle(a_vActor)
  if not a_vActor then
    print("WARNING: a_vActor is nil in EVENT_ActorExitsAnyVehicle")
  end
  local tUserTable
  if type(a_tUserTable) == "table" then
    tUserTable = a_tUserTable
  else
    tUserTable = {a_tUserTable}
  end
  local eEvent = Util.CreateEvent({
    EventType = "OnVehicleExit",
    Target = a_vActor
  }, a_sCallbackFunction, self, tUserTable, a_bPersistent)
  if self and self._SELFTABLE_ID then
    self:RegisterEvent(eEvent)
  end
  return eEvent
end

function EVENT_PlayerEntersAnyVehicle(a_sCallbackFunction, self, a_tUserTable, a_bPersistent)
  local tUserTable
  if type(a_tUserTable) == "table" then
    tUserTable = a_tUserTable
  else
    tUserTable = {a_tUserTable}
  end
  local eEvent = Util.CreateEvent({
    EventType = "OnVehicleEnter",
    Target = hSab
  }, a_sCallbackFunction, self, tUserTable, a_bPersistent)
  if self and self._SELFTABLE_ID then
    self:RegisterEvent(eEvent)
  end
  return eEvent
end

function EVENT_PlayerExitsAnyVehicle(a_sCallbackFunction, self, a_tUserTable, a_bPersistent)
  local tUserTable
  if type(a_tUserTable) == "table" then
    tUserTable = a_tUserTable
  else
    tUserTable = {a_tUserTable}
  end
  local eEvent = Util.CreateEvent({
    EventType = "OnVehicleExit",
    Target = hSab
  }, a_sCallbackFunction, self, tUserTable, a_bPersistent)
  if self and self._SELFTABLE_ID then
    self:RegisterEvent(eEvent)
  end
  return eEvent
end

function EVENT_PlayerExitsVehicle(a_sCallbackFunction, self, a_tUserTable, a_bPersistent)
  local tUserTable
  if type(a_tUserTable) == "table" then
    tUserTable = a_tUserTable
  else
    tUserTable = {a_tUserTable}
  end
  local eEvent = Util.CreateEvent({
    EventType = "OnVehicleExit",
    Target = hSab
  }, a_sCallbackFunction, self, tUserTable, a_bPersistent)
  if self and self._SELFTABLE_ID then
    self:RegisterEvent(eEvent)
  end
  return eEvent
end

function EVENT_PlayerEntersVehicle(a_sCallbackFunction, self, a_vActor, a_tUserTable, a_bPersistent)
  a_vActor = WRAPPER_CheckForHandle(a_vActor)
  if not a_vActor then
    print("WARNING: a_vActor is nil in EVENT_PlayerEntersVehicle")
  end
  local tUserTable
  if type(a_tUserTable) == "table" then
    tUserTable = a_tUserTable
  else
    tUserTable = {a_tUserTable}
  end
  local eEvent = Util.CreateEvent({
    EventType = "EnteredVehicleEvent",
    ObjectHandle = hSab,
    VehicleHandle = a_vActor
  }, a_sCallbackFunction, self, tUserTable, a_bPersistent)
  if self and self._SELFTABLE_ID then
    self:RegisterEvent(eEvent)
  end
  return eEvent
end

function EVENT_PlayerEntersVehicleBlueprint(a_sCallbackFunction, self, a_sBlueprint, a_tUserTable, a_bPersistent)
  if not a_sBlueprint then
    print("WARNING: a_sBlueprint is nil in EVENT_PlayerEntersVehicleBlueprint")
  end
  local tUserTable
  if type(a_tUserTable) == "table" then
    tUserTable = a_tUserTable
  else
    tUserTable = {a_tUserTable}
  end
  local eEvent = Util.CreateEvent({
    EventType = "EnteredVehicleEvent",
    ObjectHandle = hSab,
    VehicleBlueprint = a_sBlueprint
  }, a_sCallbackFunction, self, tUserTable, a_bPersistent)
  if self and self._SELFTABLE_ID then
    self:RegisterEvent(eEvent)
  end
  return eEvent
end

function EVENT_ActorEntersCombat(a_sCallbackFunction, self, a_vActor, a_tUserTable, a_bPersistent)
  a_vActor = WRAPPER_CheckForHandle(a_vActor)
  if not a_vActor then
    print("WARNING: a_vActor is nil in EVENT_ActorEntersCombat")
  end
  local tUserTable
  if type(a_vActor) == "table" then
    tUserTable = a_vActor
  else
    tUserTable = {a_vActor}
  end
  local eEvent = Util.CreateEvent({
    EventType = "OnCombatEnter",
    Target = a_vActor
  }, a_sCallbackFunction, self, tUserTable, a_bPersistent)
  if self and self._SELFTABLE_ID then
    self:RegisterEvent(eEvent)
  end
  return eEvent
end

function EVENT_ActorHuntFail(a_sCallbackFunction, self, a_vActor, a_tUserTable, a_bPersistent)
  a_vActor = WRAPPER_CheckForHandle(a_vActor)
  if not a_vActor then
    print("WARNING: a_vActor is nil in EVENT_ActorHuntFail")
  end
  local eEvent = Util.CreateEvent({EventType = "OnHuntFail", Target = a_vActor}, a_sCallbackFunction, self, {a_tUserTable}, a_bPersistent)
  if self and self._SELFTABLE_ID then
    self:RegisterEvent(eEvent)
  end
  return eEvent
end

function EVENT_ActorHuntSuccess(a_sCallbackFunction, self, a_vActor, a_tUserTable)
  a_vActor = WRAPPER_CheckForHandle(a_vActor)
  if not a_vActor then
    print("WARNING: a_vActor is nil in EVENT_ActorHuntSuccess")
  end
  local eEvent = Util.CreateEvent({
    EventType = "OnHuntSuccess",
    Target = a_vActor
  }, a_sCallbackFunction, self, {a_tUserTable})
  if self and self._SELFTABLE_ID then
    self:RegisterEvent(eEvent)
  end
  return eEvent
end

function EVENT_ActorInvestigateFail(a_sCallbackFunction, self, a_vActor, a_tUserTable)
  a_vActor = WRAPPER_CheckForHandle(a_vActor)
  if not a_vActor then
    print("WARNING: a_vActor is nil in EVENT_ActorInvestigateFail")
  end
  local eEvent = Util.CreateEvent({
    EventType = "OnInvestigateFail",
    Target = a_vActor
  }, a_sCallbackFunction, self, {a_tUserTable})
  if self and self._SELFTABLE_ID then
    self:RegisterEvent(eEvent)
  end
  return eEvent
end

function EVENT_ActorInvestigateSuccess(a_sCallbackFunction, self, a_vActor, a_tUserTable)
  a_vActor = WRAPPER_CheckForHandle(a_vActor)
  if not a_vActor then
    print("WARNING: a_vActor is nil in EVENT_ActorInvestigateSuccess")
  end
  local eEvent = Util.CreateEvent({
    EventType = "OnInvestigateSuccess",
    Target = a_vActor
  }, a_sCallbackFunction, self, {a_tUserTable})
  if self and self._SELFTABLE_ID then
    self:RegisterEvent(eEvent)
  end
  return eEvent
end

function EVENT_ActorFiresAnyWeapon(a_sCallbackFunction, self, a_vActor, a_tUserTable, a_bPersistent)
  a_vActor = WRAPPER_CheckForHandle(a_vActor)
  if not a_vActor then
    print("WARNING: a_vActor is nil in EVENT_ActorFiresAnyWeapon")
  end
  local eEvent = Util.CreateEvent({
    EventType = "OnWeaponFire",
    Target = a_vActor
  }, a_sCallbackFunction, self, {a_tUserTable}, a_bPersistent)
  if self and self._SELFTABLE_ID then
    self:RegisterEvent(eEvent)
  end
  return eEvent
end

function EVENT_PlayerFiresAnyWeapon(a_sCallbackFunction, self, a_tUserTable, a_bPersistent)
  a_vActor = WRAPPER_CheckForHandle(a_vActor)
  local eEvent = Util.CreateEvent({
    EventType = "OnWeaponFire",
    Target = hSab
  }, a_sCallbackFunction, self, {a_tUserTable}, a_bPersistent)
  if self and self._SELFTABLE_ID then
    self:RegisterEvent(eEvent)
  end
  return eEvent
end

function EVENT_FadeInOut(a_nSeconds)
  local nInTime = a_nSeconds * 0.1
  local nOutTime = a_nSeconds * 0.1
  local nDarkTime = a_nSeconds * 0.8
  Render.FadeTo(0, 0, 0, 255, nInTime)
  Util.CreateEvent({EventType = "TimerEvent", Time = nDarkTime}, "__UtilFunctions.CallbackFadeInOutHelper", nil, {nOutTime})
end

function EVENT_Stream(a_sCallbackFunction, self, a_vActor, a_bFullStream, a_tUserTable)
  local tUserTable
  if type(a_tUserTable) == "table" then
    tUserTable = a_tUserTable
  else
    tUserTable = {a_tUserTable}
  end
  local tObjects = {}
  local nObjectsIndex = 1
  if type(a_vActor) == "table" then
    for index, V in pairs(a_vActor) do
      if (type(V) == "string" or type(V) == "userdata") and V ~= "" then
        print("DEBUG:: adding ", V, " to EVENT_Stream table")
        tObjects[nObjectsIndex] = V
        nObjectsIndex = nObjectsIndex + 1
      end
    end
  elseif (type(a_vActor) == "string" or type(a_vActor) == "userdata") and a_vActor ~= "" then
    tObjects = {a_vActor}
  else
    return
  end
  if tObjects == {} then
    return
  end
  local bFullStream = true
  if a_bFullStream == nil then
    a_bFullStream = true
  end
  if a_bFullStream == false then
    bFullStream = false
  end
  local eEvent = Util.CreateEvent({
    EventType = "StreamEvent",
    Objects = tObjects,
    WaitForGameObject = bFullStream
  }, a_sCallbackFunction, self, tUserTable)
  if self and self._SELFTABLE_ID then
    self:RegisterEvent(eEvent)
  end
  return eEvent
end

function EVENT_StreamOut(a_sCallbackFunction, self, a_vActor, a_tUserTable)
  local tUserTable
  if type(a_tUserTable) == "table" then
    tUserTable = a_tUserTable
  else
    tUserTable = {a_tUserTable}
  end
  local tObjects = {}
  local nObjectsIndex = 1
  if type(a_vActor) == "table" then
    tObjects = a_vActor
  else
    tObjects = {a_vActor}
  end
  if tObjects == {} then
    return
  end
  local eEvent = Util.CreateEvent({
    EventType = "StreamEvent",
    Objects = tObjects,
    WaitForGameObject = false,
    WaitForPathfinding = false,
    WaitForPhysics = false,
    WaitForStreamOut = true
  }, a_sCallbackFunction, self, tUserTable)
  if self and self._SELFTABLE_ID then
    self:RegisterEvent(eEvent)
  end
  return eEvent
end

function EVENT_EscalationFree(a_sCallbackFunction, self, a_tUserTable, a_bPersistent)
  local tUserTable
  if type(a_tUserTable) == "table" then
    tUserTable = a_tUserTable
  else
    tUserTable = {a_tUserTable}
  end
  local eEvent = Util.CreateEvent({
    EventType = "OnEscalation0",
    Target = hSab
  }, a_sCallbackFunction, self, tUserTable, a_bPersistent)
  if self and self._SELFTABLE_ID then
    self:RegisterEvent(eEvent)
  end
  return eEvent
end

function EVENT_OnEscalation(a_sCallbackFunction, self, a_tUserTable, a_bPersistent)
  local tUserTable
  if type(a_tUserTable) == "table" then
    tUserTable = a_tUserTable
  else
    tUserTable = {a_tUserTable}
  end
  if Suspicion.GetEscalation() ~= 0 then
    Util.MakeEscalationCallback(a_sCallbackFunction, self, a_tUserTable)
    return
  end
  local eEvent = Util.CreateEvent({
    EventType = "OnEscalation",
    Target = hSab
  }, a_sCallbackFunction, self, tUserTable, a_bPersistent)
  if self and self._SELFTABLE_ID then
    self:RegisterEvent(eEvent)
  end
  return eEvent
end

function EVENT_OnEscalationLite(a_sCallbackFunction, self, a_tUserTable)
  local tUserTable
  if type(a_tUserTable) == "table" then
    tUserTable = a_tUserTable
  else
    tUserTable = {a_tUserTable}
  end
  if Suspicion.IsEscalatedLite() then
    Util.MakeEscalationCallback(a_sCallbackFunction, self, a_tUserTable)
    return
  end
  local eEvent = Util.CreateEvent({
    EventType = "OnEscalationLite",
    Target = hSab
  }, a_sCallbackFunction, self, tUserTable)
  if self and self._SELFTABLE_ID then
    self:RegisterEvent(eEvent)
  end
  return eEvent
end

function EVENT_PlayConversationDelayed(a_sConversation, a_Delay, self)
  local eEvent = Util.CreateEvent({EventType = "TimerEvent", Time = a_Delay}, "_CallbackDelayedConversation", nil, {a_sConversation})
  if self and self._SELFTABLE_ID then
    self:RegisterEvent(eEvent)
  end
  return eEvent
end

function _CallbackDelayedConversation(self, a_sConversation)
  Cin.PlayConversation(a_sConversation)
end

function EVENT_PlayerTriggersConv(self, a_vTriggerRegion, a_sConvFile, a_bPersistent, a_tUserTable)
  local trig = a_vTriggerRegion
  a_vTriggerRegion = WRAPPER_CheckForHandle(a_vTriggerRegion)
  local hSab = WRAPPER_CheckForHandle("Saboteur")
  a_bPersistent = a_bPersistent or false
  if not a_vTriggerRegion then
    print("WARNING: a_vTriggerRegion is nil in EVENT_PlayerTriggersConv", trig)
  end
  if not a_sConvFile then
    print("WARNING: a_sConvFile is nil in EVENT_PlayerTriggersConv", a_sConvFile)
  end
  local tUserTable
  if type(a_tUserTable) == "table" then
    tUserTable = a_tUserTable
  else
    tUserTable = {a_tUserTable}
  end
  local hTriggerID = Trigger.WaitFor(a_vTriggerRegion, hSab, "_CallbackTriggerConversation", nil, {a_sConvFile}, cTRIGGEREVENT_ONENTER_SMART, a_bPersistent)
  if self and self._SELFTABLE_ID then
    self:RegisterTriggerEvent(hTriggerID, a_vTriggerRegion)
  end
  return hTriggerID
end

function _CallbackTriggerConversation(self, tArgs, a_sConversation)
  print("_CallbackTriggerConversation ", a_sConversation)
  Cin.PlayConversation(a_sConversation)
end

function EVENT_OnSeatLocked(a_sCallbackFunction, self, a_tUserTable, a_bPersistent)
  local tUserTable
  if type(a_tUserTable) == "table" then
    tUserTable = a_tUserTable
  else
    tUserTable = {a_tUserTable}
  end
  local eEvent = Util.CreateEvent({
    EventType = "OnSeatLocked",
    Target = hSab
  }, a_sCallbackFunction, self, tUserTable, a_bPersistent)
  if self and self._SELFTABLE_ID then
    self:RegisterEvent(eEvent)
  end
  return eEvent
end

function EVENT_FadeScreenDelayed(bFade, self, a_Delay)
  local eEvent = Util.CreateEvent({EventType = "TimerEvent", Time = a_Delay}, "_CallbackDelayedFadeScreen", nil, {bFade})
  if self and self._SELFTABLE_ID then
    self:RegisterEvent(eEvent)
  end
  return eEvent
end

function _CallbackDelayedFadeScreen(self, bF)
  local bFade
  if bF == nil then
    bFade = false
  else
    bFade = bF
  end
  Render.FadeScreen(bFade)
end
