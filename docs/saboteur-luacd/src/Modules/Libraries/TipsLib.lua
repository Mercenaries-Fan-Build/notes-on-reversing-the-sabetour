if not Tips then
  Tips = {}
end

function Tips.CheckForHandle(a_vVariable)
  local sType = type(a_vVariable)
  if sType == "userdata" then
    return a_vVariable
  elseif sType == "string" then
    local hObject = Util.GetHandleByName(a_vVariable)
    if hObject ~= nil then
      return hObject
    else
      return nil
    end
    return
  else
    if a_vVariable then
      Util.Assert(false, "Passed variable  is neither a HANDLE nor STRING!")
    end
    return nil
  end
end

function Handle(a_vVariable)
  return Tips.CheckForHandle(a_vVariable)
end

function Tips.IsUserdataZero(a_vData)
  if type(a_vData) == "userdata" then
    if Util.GetIntFromHandle(a_vData) == 0 then
      return true
    else
      return false
    end
  else
    return false
  end
end

function Tips.GetRandomElement(a_tList)
  return a_tList[math.random(#a_tList)]
end

function Tips.GetSelf(a_vEntity)
  local hEntity = Tips.CheckForHandle(a_vEntity)
  return Actor.GetSelf(hEntity)
end

function Tips.Assert(a_vEntity, a_sAssert)
  if type(a_vEntity) == "table" then
    if a_vEntity.hController ~= nil then
      Util.Assert(false, Util.GetNameFromHandle(a_vEntity.hController) .. " : " .. a_sAssert)
    end
  elseif type(a_vEntity) == "userdata" then
    Util.Assert(false, Util.GetNameFromHandle(a_vEntity) .. " : " .. a_sAssert)
  end
end

function Tips.GameTimeToString(a_nRawTime)
  if a_nRawTime == 0 then
    return "00:00:00:00"
  else
    local nHours = string.format("%02.f", math.floor(a_nRawTime / 3600))
    local nMins = string.format("%02.f", math.floor(a_nRawTime / 60 - nHours * 60))
    local nSecs = string.format("%02.f", math.floor(a_nRawTime - nHours * 3600 - nMins * 60))
    local nHundredths = string.format("%02.f", (a_nRawTime - math.floor(a_nRawTime)) * 100)
    return nHours .. ":" .. nMins .. ":" .. nSecs .. ":" .. nHundredths
  end
end

function Tips.GetDebugTime()
  return Tips.GameTimeToString(Util.GetGameTime())
end

function Tips.Print(a_tSelf, a_sMessageString)
  if a_tSelf and type(a_tSelf) == "table" and a_tSelf.bDebugMode ~= nil and a_tSelf.bDebugMode == true then
    if a_tSelf.sDebugLabel == nil then
      print("::: " .. Tips.GetDebugTime() .. " : " .. a_sMessageString)
      local sUpdateText = Tips.GetDebugTime() .. " : " .. a_sMessageString
      Render.PrintMessage(sUpdateText)
    else
      print("::: " .. Tips.GetDebugTime() .. " (" .. a_tSelf.sDebugLabel .. ") : " .. a_sMessageString)
      local sUpdateText = Tips.GetDebugTime() .. " (" .. a_tSelf.sDebugLabel .. ") : " .. a_sMessageString
      Render.PrintMessage(sUpdateText)
    end
  end
end

function Tips.GetRelativeFacing(a_hObjectA, a_hObjectB)
  local nCurrentAngle = Actor.GetFacingDir(a_hObjectA)
  local nAngleToTarget = Actor.CalcFacingTo(a_hObjectA, a_hObjectB)
  local nRelativeFacing = nAngleToTarget - nCurrentAngle
  if 180 < nRelativeFacing then
    nRelativeFacing = nRelativeFacing - 360
  elseif nRelativeFacing < -180 then
    nRelativeFacing = nRelativeFacing + 360
  end
  return nRelativeFacing
end

function Tips.GetListFromNames(a_sPrefix)
  local tHandles = {}
  local nCount = 1
  while Util.GetHandleByName(a_sPrefix .. tostring(nCount)) ~= nil do
    table.insert(tHandles, Util.GetHandleByName(a_sPrefix .. tostring(nCount)))
    nCount = nCount + 1
  end
  return tHandles
end

function Tips.SpawnAtLoc(a_sBlueprint, a_vLocator, a_sCallback, a_tSelf, a_tCallbackParams, a_bLOSCheck)
  local bLOS = a_bLOSCheck or false
  local hLocator = Tips.CheckForHandle(a_vLocator)
  local x, y, z = Object.GetPosition(hLocator)
  local rot = Object.GetAngle(hLocator)
  Object.Spawn(a_sBlueprint, x, y, z, rot, nil, a_sCallback, a_tSelf, a_tCallbackParams, bLOS)
end

function Tips.MultiListener(a_vTarget, a_tListenTable, a_sCallback, a_tSelf, a_tCallbackParams)
  local hTarget = Tips.CheckForHandle(a_vTarget)
  Util.Assert(hTarget ~= nil, "You're trying to set up a MultiListener on an object whose handle is nil!")
  tEventHandles = {}
  for i, v in ipairs(a_tListenTable) do
    local tEvent = {EventType = v, Target = hTarget}
    local hEvent = Util.CreateEvent(tEvent, a_sCallback, a_tSelf, a_tCallbackParams)
    table.insert(tEventHandles, hEvent)
  end
  return tEventHandles
end

function Tips.AdvancedMultiListener(a_tData, a_sCallback, a_tSelf)
  local tEventHandles = {}
  for i, tCommand in ipairs(a_tData) do
    local hTarget = Tips.CheckForHandle(tCommand[1])
    Util.Assert(hTarget ~= nil, "Your MultiListener target for the function (" .. tCommand[2] .. ") is nil! Make sure the target is valid!")
    local bPersist = false
    if tCommand[4] ~= nil then
      bPersist = tCommand[4]
    end
    local tEvent = {
      Target = hTarget,
      EventType = tCommand[2]
    }
    local hEvent = Util.CreateEvent(tEvent, a_sCallback, a_tSelf, tCommand[3], bPersist)
    table.insert(tEventHandles, hEvent)
  end
  return tEventHandles
end

function Tips.KillEventTable(a_tEvents)
  if a_tEvents then
    for i, v in ipairs(a_tEvents) do
      Util.KillEvent(v)
    end
  end
end

function Tips.CombineLists(a_ListA, a_ListB)
  local tOutputTable = {}
  for i, v in ipairs(a_ListA) do
    table.insert(tOutputTable, v)
  end
  for i, v in ipairs(a_ListB) do
    table.insert(tOutputTable, v)
  end
  return tOutputTable
end

function Tips.GetRandomlyFilledList(a_List, a_nSize)
  local tNewList = {}
  for i = 1, a_nSize do
    tNewList[i] = Tips.GetRandomElement(a_List)
  end
end

function Tips.GetLivingFromList(a_List)
  local tLiving = {}
  for i, vObject in ipairs(a_List) do
    if Object.IsAlive(Handle(vObject)) == true then
      table.insert(tLiving, vObject)
    end
  end
  return tLiving
end

function Tips.IsTable(a_vObj)
  if type(a_vObj) == "table" then
    return true
  else
    return false
  end
end

function Tips.StringToFunction(a_vFunction)
  if not a_vFunction then
    return
  end
  if type(a_vFunction) == "string" then
    local dotIndex = string.find(a_vFunction, "%.")
    local sFile, sFunction, fFile, fFunction
    if dotIndex then
      sFile = string.sub(a_vFunction, 1, dotIndex - 1)
      sFunction = string.sub(a_vFunction, dotIndex + 1, string.len(a_vFunction))
      fFile = _G[sFile]
      fFunction = fFile[sFunction]
    else
      fFunction = _G[a_vFunction]
    end
    return fFunction
  elseif type(a_vFunction) == "function" then
    return a_vFunction
  end
  return nil
end

function Tips.SetVarByString(a_sVar, a_vValue)
  if not a_sVar then
    return
  end
  if type(a_sVar) == "string" then
    local dotIndex = string.find(a_sVar, "%.")
    local sFile, fFile, sVariable
    sFile = string.sub(a_sVar, 1, dotIndex - 1)
    sVariable = string.sub(a_sVar, dotIndex + 1, string.len(a_sVar))
    fFile = _G[sFile]
    fFile[sVariable] = a_vValue
  end
end

function Tips.GetVarByString(a_sVar)
  if not a_sVar then
    return
  end
  if type(a_sVar) == "string" then
    local dotIndex = string.find(a_sVar, "%.")
    local sFile, fFile, sVariable
    sFile = string.sub(a_sVar, 1, dotIndex - 1)
    sVariable = string.sub(a_sVar, dotIndex + 1, string.len(a_sVar))
    fFile = _G[sFile]
    return fFile[sVariable]
  end
end

function GetTableID(a_tSelf)
  return a_tSelf._SELFTABLE_ID
end

function GetTableFromID(a_nID)
  return gMasterSelfTable[a_nID]
end

function HandleToString(a_hObject)
  if type(a_hObject) == "userdata" then
    local data = Util.GetIntFromHandle(a_hObject)
    return tostring(data)
  else
    Util.Assert(false, "HandleToString() cannot operate on anything but a handle! Make sure you're passing the right type!")
  end
end

function Tips.Delay(a_nDelay, a_fCallback, a_tSelf, a_tParams, a_sName)
  local tTimeDelay = {
    EventType = "TimerEvent",
    Time = a_nDelay,
    EventName = a_sName
  }
  local tPackedData = {a_fCallback, a_tParams}
  Util.CreateEvent(tTimeDelay, "Tips._Delay", a_tSelf, {tPackedData})
end

function Tips:_Delay(a_tUserData)
  if a_tUserData[2] then
    a_tUserData[1](self, unpack(a_tUserData[2]))
  else
    a_tUserData[1](self)
  end
end

function Tips.OnSee(a_vObject, a_nTime, a_nDist, a_fCallback, a_tSelf, a_tParams, a_sName)
  local nTime = a_nTime or 0.5
  local nDist = a_nDist or 100
  local tEvent = {
    EventType = "SeeLocatorEvent",
    Locator = Handle(a_vObject),
    Proximity = nDist,
    InViewTime = nTime,
    EventName = a_sName
  }
  local tPackedData = {a_fCallback, a_tParams}
  return Util.CreateEvent(tEvent, "Tips._OnSee", a_tSelf, {tPackedData})
end

function Tips:_OnSee(a_tUserData)
  if a_tUserData[2] then
    a_tUserData[1](self, unpack(a_tUserData[2]))
  else
    a_tUserData[1](self)
  end
end

function Tips.MarkForDespawn(a_vObjects, a_nDist, a_bVisibilityCheck)
  if not a_vObjects then
    return
  end
  local nDist = a_nDist or 50
  local bVisCheck = a_bVisibilityCheck or true
  if type(a_vObjects) == "table" then
    for i, v in ipairs(a_vObjects) do
      local hObj = Handle(v)
      if hObj then
        Object.Despawn(hObj, nDist, bVisCheck)
      end
    end
  else
    local hObj = Handle(a_vObjects)
    if hObj then
      Object.Despawn(hObj, nDist, bVisCheck)
    end
  end
end

function Tips.On2DProximity(a_vObjA, a_vObjB, a_nProx, a_fCallback, a_tSelf, a_tParams, a_sName)
  local nProx = 0
  local bNegate = false
  if a_nProx < 0 then
    nProx = a_nProx * -1
    bNegate = true
  else
    nProx = a_nProx
  end
  local tEvent = {
    EventType = "ProximityEvent",
    ObjectA = Handle(a_vObjA),
    ObjectB = Handle(a_vObjB),
    Proximity = nProx,
    Negate = bNegate,
    EventName = a_sName
  }
  local tPackedData = {a_fCallback, a_tParams}
  return Util.CreateEvent(tEvent, "Tips._On2DProximity", a_tSelf, {tPackedData})
end

function Tips:_On2DProximity(a_tUserData)
  if a_tUserData[2] then
    a_tUserData[1](self, unpack(a_tUserData[2]))
  else
    a_tUserData[1](self)
  end
end

function Tips.On3DProximity(a_vObjA, a_vObjB, a_nProx, a_fCallback, a_tSelf, a_tParams, a_sName)
  local nProx = 0
  local bNegate = false
  if a_nProx < 0 then
    nProx = a_nProx * -1
    bNegate = true
  else
    nProx = a_nProx
  end
  local tEvent = {
    EventType = "ProximityEvent",
    ObjectA = Handle(a_vObjA),
    ObjectB = Handle(a_vObjB),
    Proximity = nProx,
    Negate = bNegate,
    Check3D = true,
    EventName = a_sName
  }
  local tPackedData = {a_fCallback, a_tParams}
  return Util.CreateEvent(tEvent, "Tips._On3DProximity", a_tSelf, {tPackedData})
end

function Tips:_On3DProximity(a_tUserData)
  if a_tUserData[2] then
    a_tUserData[1](self, unpack(a_tUserData[2]))
  else
    a_tUserData[1](self)
  end
end

function Tips.OnEscalation(a_fCallback, a_tSelf, a_tParams, a_sName, a_bPersist)
  local tEvent = {
    EventType = "OnEscalation1",
    Target = Handle("Saboteur"),
    EventName = a_sName
  }
  local tPackedData = {a_fCallback, a_tParams}
  return Util.CreateEvent(tEvent, "Tips._OnEscalation", a_tSelf, {tPackedData}, a_bPersist)
end

function Tips:_OnEscalation(a_tEscalationData, a_tUserData)
  if a_tUserData[2] then
    a_tUserData[1](self, unpack(a_tUserData[2]))
  else
    a_tUserData[1](self)
  end
end

function Tips.OnDeescalation(a_fCallback, a_tSelf, a_tParams, a_sName, a_bPersist)
  local tEvent = {
    EventType = "OnEscalation0",
    Target = Handle("Saboteur"),
    EventName = a_sName
  }
  local tPackedData = {a_fCallback, a_tParams}
  return Util.CreateEvent(tEvent, "Tips._OnDeescalation", a_tSelf, {tPackedData}, a_bPersist)
end

function Tips:_OnDeescalation(a_tEscalationData, a_tUserData)
  if a_tUserData[2] then
    a_tUserData[1](self, unpack(a_tUserData[2]))
  else
    a_tUserData[1](self)
  end
end

function Tips.OnVehicleExit(a_vActor, a_fCallback, a_tSelf, a_tParams, a_sName, a_bPersist)
  local tEvent = {
    EventType = "OnVehicleExit",
    Target = Handle(a_vActor),
    EventName = a_sName
  }
  local tPackedData = {a_fCallback, a_tParams}
  return Util.CreateEvent(tEvent, "Tips._OnVehicleExit", a_tSelf, {tPackedData}, a_bPersist)
end

function Tips:_OnVehicleExit(a_tCallbackData, a_tUserData)
  a_tUserData[1](self, unpack(a_tUserData[2]))
end

function Tips.OnDeath(a_vActor, a_fCallback, a_tSelf, a_tParams, a_sName)
  local tEvent = {
    EventType = "OnDeath",
    Target = Handle(a_vActor),
    EventName = a_sName
  }
  local tPackedData = {a_fCallback, a_tParams}
  return Util.CreateEvent(tEvent, "Tips._OnDeath", a_tSelf, {tPackedData}, a_bPersist)
end

function Tips:_OnDeath(a_tData, a_tUserData)
  if a_tUserData[2] then
    if a_tData[2] ~= nil then
      table.insert(a_tUserData[2], a_tData[2])
    end
    a_tUserData[1](self, unpack(a_tUserData[2]))
  else
    a_tUserData[1](self, a_tData[2])
  end
end

function Tips.OnStream(a_vObjects, a_fCallback, a_tSelf, a_tParams)
  local tObjects = {}
  if type(a_vObjects) == "table" then
    tObjects = a_vObjects
  else
    table.insert(tObjects, a_vObjects)
  end
  local tPackedData = {a_fCallback, a_tParams}
  local tEvent = {
    EventType = "StreamEvent",
    Objects = tObjects,
    WaitForGameObject = true
  }
  return Util.CreateEvent(tEvent, "Tips._OnStream", a_tSelf, {tPackedData})
end

function Tips:_OnStream(a_tUserData)
  if 1 < #a_tUserData then
    a_tUserData[1](self, unpack(a_tUserData[2]))
  else
    a_tUserData[1](self)
  end
end

function dprint(a_tSelf, a_sMessage)
  Tips.Print(a_tSelf, a_sMessage)
end
