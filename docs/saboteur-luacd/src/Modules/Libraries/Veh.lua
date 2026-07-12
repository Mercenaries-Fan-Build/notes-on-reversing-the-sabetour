if not Veh then
  Veh = {}
  require("Includes\\WRAPPER_Vehicle")
end
cVEH_OPEL = 1
cVEH_KUBEL = 2
cVEH_KUBELTURRET = 3
cVEH_PEUGEOT = 4
cVEH_HALFTRACK = 5
cVEH_SILVERDART = 6
cVEH_OPELGUN = 7
cVEH_PANZER = 8
cVEH_MATERTIPO = 9
cVEH_ALFAROM12C = 10
cVEH_ALFAROMERA = 11
cVEH_ALLARD = 12
cVEH_DIERKERDART = 13
cVEH_AURORA = 14
cVEH_LIMO_HARDTOP = 15
cVEH_LIMO_OPENTOP = 16
cVEH_RENAULTVIVA = 17
cVEH_KS750_TURRET = 18
cVEH_PEUGEOT_TURRET = 19
cPRE_DIVERSION = 1
cPRE_WEHROPEL = 2
Veh.Configs = {}
Veh.Configs[cVEH_OPEL] = {
  Pilot = "PILOT",
  Shotgun = "SHOTGUN",
  Passengers = {
    "BACK_LEFT_END",
    "BACK_LEFT_MIDDLE",
    "BACK_RIGHT_END",
    "BACK_RIGHT_MIDDLE"
  },
  Blueprint = "VH_NZ_TR_OpelCanvas_01"
}
Veh.Configs[cVEH_KUBEL] = {
  Pilot = "PILOT",
  Shotgun = "SHOTGUN",
  Passengers = {"BACKSEAT_L", "BACKSEAT_R"},
  Blueprint = "VH_NZ_CR_Kubelwagen_01"
}
Veh.Configs[cVEH_KUBELTURRET] = {
  Pilot = "PILOT",
  Shotgun = "SHOTGUN",
  Gunner = "GUNNER",
  Blueprint = "VH_NZ_CR_Kubelwagen_mount"
}
Veh.Configs[cVEH_PEUGEOT] = {
  Pilot = "PILOT",
  Shotgun = "SHOTGUN",
  Passengers = {"BACKSEAT_R", "BACKSEAT_L"},
  Blueprint = "VH_CV_CR_Peugeot402_01"
}
Veh.Configs[cVEH_SILVERDART] = {
  Pilot = "PILOT",
  Blueprint = "VH_CV_CR_SilverDart_01"
}
Veh.Configs[cVEH_DIERKERDART] = {
  Pilot = "PILOT",
  Blueprint = "VH_CV_CR_SilverDartDierker_01"
}
Veh.Configs[cVEH_MATERTIPO] = {
  Pilot = "PILOT",
  Blueprint = "VH_CV_CR_MaterTipo4CL_01"
}
Veh.Configs[cVEH_ALFAROM12C] = {
  Pilot = "PILOT",
  Blueprint = "VH_CV_CR_AlfaRom_12C_01"
}
Veh.Configs[cVEH_ALFAROMERA] = {
  Pilot = "PILOT",
  Blueprint = "VH_CV_CR_AlfaRomera_01"
}
Veh.Configs[cVEH_ALLARD] = {
  Pilot = "PILOT",
  Blueprint = "VH_CV_CR_Allard_01"
}
Veh.Configs[cVEH_OPELGUN] = {
  Pilot = "PILOT",
  Shotgun = "SHOTGUN",
  Gunner = "GUNNER",
  Blueprint = "VH_NZ_TR_OpelGun_01"
}
Veh.Configs[cVEH_HALFTRACK] = {
  Pilot = "PILOT",
  Shotgun = "SHOTGUN",
  Gunner = "GUNNER",
  Passengers = {
    "REAR_R1",
    "REAR_R2",
    "REAR_R3",
    "REAR_L1",
    "REAR_L2",
    "REAR_L3"
  },
  Blueprint = "VH_NZ_TR_HalfTrack_01"
}
Veh.Configs[cVEH_PANZER] = {
  Pilot = "PILOT",
  Blueprint = "VH_NZ_TK_PanzerMk3_01"
}
Veh.Configs[cVEH_AURORA] = {
  Pilot = "PILOT",
  Blueprint = "VH_CV_CR_Aurora_01"
}
Veh.Configs[cVEH_LIMO_HARDTOP] = {
  Pilot = "PILOT",
  Shotgun = "SHOTGUN",
  Passengers = {"BACKSEAT_L", "BACKSEAT_R"},
  Blueprint = "VH_NZ_CR_6WheelNaziLimo_htop_01"
}
Veh.Configs[cVEH_LIMO_OPENTOP] = {
  Pilot = "PILOT",
  Shotgun = "SHOTGUN",
  Passengers = {"BACKSEAT_L", "BACKSEAT_R"},
  Blueprint = "VH_NZ_CR_6WheelNaziLimo_01"
}
Veh.Configs[cVEH_RENAULTVIVA] = {
  Pilot = "PILOT",
  Shotgun = "SHOTGUN",
  Passengers = {"BACKSEAT_L", "BACKSEAT_R"},
  Blueprint = "VH_CV_CR_RenaultvivaGS_01"
}
Veh.Configs[cVEH_KS750_TURRET] = {
  Pilot = "PILOT",
  Gunner = "GUNNER",
  Blueprint = "VH_NZ_MO_KS750Sidecar-Mount_01"
}
Veh.Configs[cVEH_PEUGEOT_TURRET] = {
  Pilot = "PILOT",
  Shotgun = "SHOTGUN",
  Blueprint = "VH_OP_Peugeot_Escalation"
}
Veh.Presets = {}
Veh.Presets[cPRE_DIVERSION] = {
  Pilot = "CH_RS_Grunt_01"
}
Veh.Presets[cPRE_WEHROPEL] = {
  Pilot = "CH_RS_Grunt_01"
}
Veh.SpawnQueue = {}

function Veh.SpawnAtPos(a_cType, a_vSpawnConfig, a_x, a_y, a_z, a_rot, a_bLOSCheck, a_fCallback, a_tCallbackParams)
  if a_cType == nil then
    Util.Assert(false, "This vehicle enum does not exist! Check the configuration tables in Veh.lua!")
  end
  if type(a_bLOSCheck) ~= "boolean" then
    Util.Assert(false, "Argument 7 (bLOSCheck) in Veh.Spawn is not a boolean! Check your parameters!")
  end
  Object.Spawn(Veh.Configs[a_cType].Blueprint, a_x, a_y, a_z, a_rot, nil, "Veh._Spawn", nil, {
    a_cType,
    a_vSpawnConfig,
    a_fCallback,
    a_tCallbackParams
  }, a_bLOSCheck)
end

function Veh.SpawnAtObj(a_cType, a_vSpawnConfig, a_vObj, a_bLOSCheck, a_fCallback, a_tCallbackParams)
  if a_cType == nil then
    Util.Assert(false, "This vehicle enum does not exist! Check the configuration tables in Veh.lua!")
  end
  if type(a_bLOSCheck) ~= "boolean" then
    Util.Assert(false, "Argument 7 (bLOSCheck) in Veh.Spawn is not a boolean! Check your parameters!")
  end
  local hObj = Tips.CheckForHandle(a_vObj)
  local x, y, z = Object.GetPosition(hObj)
  local rot = Object.GetAngle(hObj)
  Object.Spawn(Veh.Configs[a_cType].Blueprint, x, y, z, rot, nil, "Veh._Spawn", nil, {
    a_cType,
    a_vSpawnConfig,
    a_fCallback,
    a_tCallbackParams
  }, a_bLOSCheck)
end

function Veh._Spawn(a_NIL, a_tSpawnInfo, a_cType, a_vSpawnConfig, a_fCallback, a_tCallbackParams)
  local hVehicle = a_tSpawnInfo[1]
  Veh._FillVehicleSeats(hVehicle, a_cType, a_vSpawnConfig, a_fCallback, a_NIL, a_tCallbackParams)
end

function Veh.SafeSpawnAtPos(a_cType, a_vSpawnConfig, a_x, a_y, a_z, a_rot, a_bLOSCheck, a_fCallback, a_tSelf, a_tCallbackParams)
  if a_cType == nil then
    Util.Assert(false, "This vehicle enum does not exist! Check the configuration tables in Veh.lua!")
  end
  if type(a_bLOSCheck) ~= "boolean" then
    Util.Assert(false, "Argument 7 (bLOSCheck) in Veh.Spawn is not a boolean! Check your parameters!")
  end
  Object.Spawn(Veh.Configs[a_cType].Blueprint, a_x, a_y, a_z, a_rot, nil, "Veh._SafeSpawn", a_tSelf, {
    a_cType,
    a_vSpawnConfig,
    a_fCallback,
    a_tCallbackParams
  }, a_bLOSCheck)
end

function Veh.SafeSpawnAtObj(a_cType, a_vObj, a_vSpawnConfig, a_bLOSCheck, a_fCallback, a_tSelf, a_tCallbackParams)
  if a_cType == nil then
    Util.Assert(false, "This vehicle enum does not exist! Check the configuration tables in Veh.lua!")
  end
  if type(a_bLOSCheck) ~= "boolean" then
    Util.Assert(false, "Argument 7 (bLOSCheck) in Veh.Spawn is not a boolean! Check your parameters!")
  end
  local hObj = Tips.CheckForHandle(a_vObj)
  local x, y, z = Object.GetPosition(hObj)
  local rot = Object.GetAngle(hObj)
  local kek = Veh.Configs[a_cType].Blueprint
  Object.Spawn(Veh.Configs[a_cType].Blueprint, x, y, z, rot, nil, "Veh._SafeSpawn", a_tSelf, {
    a_cType,
    a_vSpawnConfig,
    a_fCallback,
    a_tCallbackParams
  }, a_bLOSCheck)
end

function Veh:_SafeSpawn(a_tSpawnInfo, a_cType, a_vSpawnConfig, a_fCallback, a_tCallbackParams)
  local hVehicle = a_tSpawnInfo[1]
  Veh._FillVehicleSeats(hVehicle, a_cType, a_vSpawnConfig, a_fCallback, self, a_tCallbackParams)
end

function Veh.SpawnOnRoad(a_cType, a_vSpawnConfig, a_x, a_y, a_z, a_nDist, a_bLOSCheck, a_fCallback, a_tCallbackParams)
  if a_cType == nil then
    Util.Assert(false, "This vehicle enum does not exist! Check the configuration tables in Veh.lua!")
    return
  end
  if type(a_bLOSCheck) ~= "boolean" then
    Util.Assert(false, "Argument 7 (bLOSCheck) in Veh.Spawn is not a boolean! Check your parameters!")
    return
  end
  Object.SpawnOnRoad(Veh.Configs[a_cType].Blueprint, a_x, a_y, a_z, a_nDist, nil, "Veh._SpawnOnRoad", nil, {
    a_cType,
    a_vSpawnConfig,
    a_fCallback,
    a_tCallbackParams
  }, a_bLOSCheck)
end

function Veh.SafeSpawnOnRoad(a_cType, a_vSpawnConfig, a_x, a_y, a_z, a_nDist, a_bLOSCheck, a_fCallback, a_tSelf, a_tCallbackParams)
  if a_cType == nil then
    Util.Assert(false, "This vehicle enum does not exist! Check the configuration tables in Veh.lua!")
    return
  end
  if type(a_bLOSCheck) ~= "boolean" then
    Util.Assert(false, "Argument 7 (bLOSCheck) in Veh.Spawn is not a boolean! Check your parameters!")
    return
  end
  Object.SpawnOnRoad(Veh.Configs[a_cType].Blueprint, a_x, a_y, a_z, a_nDist, nil, "Veh._SafeSpawnOnRoad", a_tSelf, {
    a_cType,
    a_vSpawnConfig,
    a_fCallback,
    a_tCallbackParams
  }, a_bLOSCheck)
end

function Veh.SpawnOnRoadFromObj(a_cType, a_vObj, a_vSpawnConfig, a_nDist, a_bLOSCheck, a_fCallback, a_tCallbackParams)
  if a_cType == nil then
    Util.Assert(false, "This vehicle enum does not exist! Check the configuration tables in Veh.lua!")
    return
  end
  if type(a_bLOSCheck) ~= "boolean" then
    Util.Assert(false, "Argument 7 (bLOSCheck) in Veh.Spawn is not a boolean! Check your parameters!")
    return
  end
  local hObj = Tips.CheckForHandle(a_vObj)
  local x, y, z = Object.GetPosition(hObj)
  Object.SpawnOnRoad(Veh.Configs[a_cType].Blueprint, x, y, z, a_nDist, nil, "Veh._SpawnOnRoad", nil, {
    a_cType,
    a_vSpawnConfig,
    a_fCallback,
    a_tCallbackParams
  }, a_bLOSCheck)
end

function Veh._SpawnOnRoad(a_NIL, a_tSpawnInfo, a_cType, a_vSpawnConfig, a_fCallback, a_tCallbackParams)
  local hVehicle = a_tSpawnInfo[1]
  Veh._FillVehicleSeats(hVehicle, a_cType, a_vSpawnConfig, a_fCallback, a_NIL, a_tCallbackParams)
end

function Veh._RunSafeCallbacks(a_fCallback, a_tSelf, a_tCallbackParams, a_hVehicle)
  if a_fCallback then
    if a_tCallbackParams then
      table.insert(a_tCallbackParams, 1, a_tSelf)
      table.insert(a_tCallbackParams, 2, a_hVehicle)
      a_fCallback(unpack(a_tCallbackParams))
    else
      a_fCallback(a_tSelf, a_hVehicle)
    end
  end
end

function Veh._RunCallbacks(a_fCallback, a_tCallbackParams, a_hVehicle)
  if a_fCallback then
    if a_tCallbackParams then
      table.insert(a_tCallbackParams, 1, a_hVehicle)
      a_fCallback(unpack(a_tCallbackParams))
    else
      a_fCallback(a_hVehicle)
    end
  end
end

function Veh:_SafeSpawnOnRoad(a_tSpawnInfo, a_cType, a_vSpawnConfig, a_fCallback, a_tCallbackParams)
  local hVehicle = a_tSpawnInfo[1]
  Veh._FillVehicleSeats(hVehicle, a_cType, a_vSpawnConfig, a_fCallback, self, a_tCallbackParams)
end

function Veh._FillVehicleSeats(a_hVehicle, a_cType, a_vSpawnConfig, a_fCallback, a_tSelf, a_tCallbackParams)
  local tVehConfig = Veh.Configs[a_cType]
  Veh.SpawnQueue[a_hVehicle] = {}
  Veh.SpawnQueue[a_hVehicle].nMaxOccupantCount = Veh.GetNumOccupants(a_vSpawnConfig, a_cType)
  Veh.SpawnQueue[a_hVehicle].nCurrentOccupantCount = 0
  Veh.SpawnQueue[a_hVehicle].fCallback = a_fCallback
  Veh.SpawnQueue[a_hVehicle].tSelf = a_tSelf
  Veh.SpawnQueue[a_hVehicle].tCallbackParams = a_tCallbackParams
  if type(a_vSpawnConfig) == "table" then
    local hPilot = Vehicle.GetPilot(a_hVehicle)
    if a_vSpawnConfig.Pilot and tVehConfig.Pilot and not hPilot then
      Object.SpawnInVehicle(a_vSpawnConfig.Pilot, tVehConfig.Pilot, a_hVehicle, "Veh.OnOccupantSpawnsInVehicle", a_tSelf, {a_hVehicle})
    end
    if a_vSpawnConfig.Shotgun and tVehConfig.Shotgun then
      Object.SpawnInVehicle(a_vSpawnConfig.Shotgun, tVehConfig.Shotgun, a_hVehicle, "Veh.OnOccupantSpawnsInVehicle", a_tSelf, {a_hVehicle})
    end
    if a_vSpawnConfig.Gunner and tVehConfig.Gunner then
      Object.SpawnInVehicle(a_vSpawnConfig.Gunner, tVehConfig.Gunner, a_hVehicle, "Veh.OnOccupantSpawnsInVehicle", a_tSelf, {a_hVehicle})
    end
    if a_vSpawnConfig.Passengers and tVehConfig.Passengers then
      if type(a_vSpawnConfig.Passengers) == "table" then
        for i, v in ipairs(tVehConfig.Passengers) do
          if a_vSpawnConfig.Passengers[i] ~= nil and tVehConfig.Passengers[i] ~= nil and a_vSpawnConfig.Passengers[i] ~= "NONE" then
            Object.SpawnInVehicle(a_vSpawnConfig.Passengers[i], v, a_hVehicle, "Veh.OnOccupantSpawnsInVehicle", a_tSelf, {a_hVehicle})
          end
        end
      elseif type(a_vSpawnConfig.Passengers) == "string" then
        for i, v in ipairs(tVehConfig.Passengers) do
          Object.SpawnInVehicle(a_vSpawnConfig.Passengers, v, a_hVehicle, "Veh.OnOccupantSpawnsInVehicle", a_tSelf, {a_hVehicle})
        end
      end
    end
  elseif type(a_vSpawnConfig) == "string" then
    local hPilot = Vehicle.GetPilot(a_hVehicle)
    if tVehConfig.Pilot and not hPilot then
      Object.SpawnInVehicle(a_vSpawnConfig, tVehConfig.Pilot, a_hVehicle, "Veh.OnOccupantSpawnsInVehicle", a_tSelf, {a_hVehicle})
    end
    if tVehConfig.Shotgun then
      Object.SpawnInVehicle(a_vSpawnConfig, tVehConfig.Shotgun, a_hVehicle, "Veh.OnOccupantSpawnsInVehicle", a_tSelf, {a_hVehicle})
    end
    if tVehConfig.Gunner then
      Object.SpawnInVehicle(a_vSpawnConfig, tVehConfig.Gunner, a_hVehicle, "Veh.OnOccupantSpawnsInVehicle", a_tSelf, {a_hVehicle})
    end
    if tVehConfig.Passengers then
      for i, v in ipairs(tVehConfig.Passengers) do
        Object.SpawnInVehicle(a_vSpawnConfig, v, a_hVehicle, "Veh.OnOccupantSpawnsInVehicle", a_tSelf, {a_hVehicle})
      end
    end
  end
end

function Veh:OnOccupantSpawnsInVehicle(a_tSpawnData, a_hVehicle)
  if not Veh.SpawnQueue[a_hVehicle] then
    return
  end
  Veh.SpawnQueue[a_hVehicle].nCurrentOccupantCount = Veh.SpawnQueue[a_hVehicle].nCurrentOccupantCount + 1
  if Veh.SpawnQueue[a_hVehicle].nCurrentOccupantCount == Veh.SpawnQueue[a_hVehicle].nMaxOccupantCount then
    local fCallback = Veh.SpawnQueue[a_hVehicle].fCallback
    local tSelf = Veh.SpawnQueue[a_hVehicle].tSelf
    local tCallbackParams = Veh.SpawnQueue[a_hVehicle].tCallbackParams
    if not tSelf then
      Veh._RunCallbacks(fCallback, tCallbackParams, a_hVehicle)
    else
      Veh._RunSafeCallbacks(fCallback, tSelf, tCallbackParams, a_hVehicle)
    end
    Veh.SpawnQueue[a_hVehicle] = nil
  end
end

function Veh.GetNumOccupants(a_vSpawnConfig, a_cType)
  local nCount = 0
  if type(a_vSpawnConfig) == "string" then
    a_vSpawnConfig = Veh.Configs[a_cType]
  end
  if a_vSpawnConfig.Pilot then
    nCount = nCount + 1
  end
  if a_vSpawnConfig.Shotgun then
    nCount = nCount + 1
  end
  if a_vSpawnConfig.Gunner then
    nCount = nCount + 1
  end
  if a_vSpawnConfig.Passengers then
    local nMaxPassengers = #Veh.Configs[a_cType].Passengers
    for i = 1, nMaxPassengers do
      local sBlueprint = a_vSpawnConfig.Passengers[i]
      if sBlueprint and sBlueprint ~= "NONE" then
        nCount = nCount + 1
      end
    end
  end
  return nCount
end

function Veh.FillSeats(a_hVehicle, a_cType, a_vSpawnConfig)
  Veh._FillVehicleSeats(Tips.CheckForHandle(a_hVehicle), a_cType, a_vSpawnConfig)
end

function Veh.FillAllSeats(a_hVehicle, a_cType, a_sBlueprint)
  local tConfig = Veh.Configs[a_cType]
  if not tConfig then
    Util.Assert(false, "You're trying to fill seats for a vehicle type that is not in the database! (" .. a_cType .. ")")
    return
  end
  local tSpawnConfig = {}
  if tConfig.Pilot then
    tSpawnConfig.Pilot = a_sBlueprint
  end
  if tConfig.Shotgun then
    tSpawnConfig.Shotgun = a_sBlueprint
  end
  if tConfig.Gunner then
    tSpawnConfig.Gunner = a_sBlueprint
  end
  if tConfig.Passengers then
    local tPassengerSeats = {}
    for i, v in ipairs(tConfig.Passengers) do
      table.insert(tPassengerSeats, a_sBlueprint)
    end
    tSpawnConfig.Passengers = tPassengerSeats
  end
  Veh.FillSeats(a_hVehicle, a_cType, tSpawnConfig)
end

function Veh.Despawn(a_vVehicle, a_nDist, a_bCheckLOS, a_bForcePlayerUnboard)
  local hVehicle = Handle(a_vVehicle)
  if a_bCheckLOS == true then
    local tOnExit = {EventType = "OnExit", Target = hVehicle}
    Util.CreateEvent(tOnExit, "Veh._Despawn", nil, {hVehicle})
    Object.Despawn(hVehicle, a_nDist, true)
  elseif a_bCheckLOS == false then
    Veh.DespawnAllOccupants(hVehicle)
    Object.Despawn(hVehicle, a_nDist, false)
  end
end

function Veh._Despawn(a_NIL, a_hVehicle, a, b)
  Veh.DespawnAllOccupants(a_hVehicle, a_bForcePlayerUnboard)
end

function Veh.DespawnAllOccupants(a_vVehicle, a_bForcePlayerUnboard)
  local hVehicle = Handle(a_vVehicle)
  a_bForcePlayerUnboard = a_bForcePlayerUnboard or false
  local hPilot = Vehicle.GetPilot(hVehicle)
  if hPilot then
    if hPilot == Handle("Saboteur") then
      if a_bForcePlayerUnboard == true then
        Actor.UnboardVehicle(hPilot)
      end
    else
      Object.Despawn(hPilot, 0, false)
    end
  end
  local tPassengers = Vehicle.GetPassengers(hVehicle)
  if tPassengers then
    for i, hPassenger in ipairs(tPassengers) do
      if hPassenger == Handle("Saboteur") then
        if a_bForcePlayerUnboard == true then
          Actor.UnboardVehicle(hPassenger)
        end
      else
        Object.Despawn(hPassenger, 0, false)
      end
    end
  end
end

cDROPOFF_ALL = 1
cDROPOFF_NONE = 2
cDROPOFF_PASSENGERS_ALL = 3
cDROPOFF_PASSENGERS_NOGUNNER = 4
cDROPOFF_PILOT = 5
cDROPOFF_ALL_EXCEPT_GUNNER = 6
cDESPAWN_NONE = 1
cDESPAWN_ADDTOTRAFFIC = 2
cDESPAWN_ONEXIT_LOSCHECK = 3
cDESPAWN_ONEXIT_NOLOSCHECK = 4
cDESPAWN_ONCOMPLETE_LOSCHECK = 5
cDESPAWN_ONCOMPLETE_NOLOSCHECK = 6

function Veh.SpawnDelivery(a_tSelf, a_tConfig)
  local bCheckSpawnLOS = true
  if a_tConfig.bForceSpawn ~= nil and a_tConfig.bForceSpawn == true then
    bCheckSpawnLOS = false
  end
  if a_tConfig.cVehicleType == nil then
    a_tConfig.cVehicleType = cVEH_OPEL
  end
  if a_tConfig.tSeatConfig == nil then
    a_tConfig.tSeatConfig = "RndHuman_WNZ_Guard_Random_Amb"
  end
  if a_tConfig.vSpawnTarget == nil then
    Util.Assert(false, "You need vSpawnTarget set in order to call Veh.SpawnDelivery! Check your config table!")
    return
  end
  if a_tConfig.vDeliveryTarget == nil and a_tConfig.sDeliveryPath == nil then
    Util.Assert(false, "You need a vDeliveryTarget OR an sDeliveryPath to call Veh.SpawnDelivery! Check your config table!")
    return
  end
  Veh.SafeSpawnAtObj(a_tConfig.cVehicleType, a_tConfig.vSpawnTarget, a_tConfig.tSeatConfig, bCheckSpawnLOS, Veh.OnDropoffVehicleSpawned, a_tSelf, {a_tConfig})
end

function Veh:OnDropoffVehicleSpawned(a_hVehicle, a_tConfig)
  local bUrgentDelivery = true
  if a_tConfig.bUrgentDelivery then
    bUrgentDelivery = a_tConfig.bUrgentDelivery
  end
  if a_tConfig.sDeliveryPath then
    Nav.SetScriptedPath(a_hVehicle, a_tConfig.sDeliveryPath, bUrgentDelivery, "Veh.OnDropoffVehicleArrives", self, {a_hVehicle, a_tConfig})
    local nPathSpeed = 20
    if a_tConfig.nPathSpeed then
      nPathSpeed = a_tConfig.nPathSpeed
    end
    Nav.SetScriptedPathSpeed(a_hVehicle, nPathSpeed)
  elseif a_tConfig.cVehicleType == cVEH_KUBELTURRET then
    Nav.FollowObject(a_hVehicle, Handle(a_tConfig.vDeliveryTarget), 0, true)
  else
    Nav.MoveToObject(a_hVehicle, Handle(a_tConfig.vDeliveryTarget), 2, bUrgentDelivery, "Veh.OnDropoffVehicleArrives", self, {a_hVehicle, a_tConfig})
    local nPathSpeed = 20
    if a_tConfig.nPathSpeed then
      nPathSpeed = a_tConfig.nPathSpeed
    end
    Nav.SetScriptedPathSpeed(a_hVehicle, nPathSpeed)
  end
  if a_tConfig.bPlowThrough then
    if a_tConfig.bPlowThrough == true then
      Vehicle.SetCrashThrough(a_hVehicle, true)
    else
      Vehicle.SetCrashThrough(a_hVehicle, false)
    end
  end
  if a_tConfig.bAddToEscalation and a_tConfig.bAddToEscalation == true then
    Vehicle.SetCanJoinEscalation(a_hVehicle)
  end
  if a_tConfig.bAttackPlayer then
    EVENT_Timer("Veh.SetGunnerHostile", self, 3, {a_hVehicle})
  end
  if a_tConfig.cUnboardType == cDROPOFF_PASSENGERS_ALL then
    local hPilot = Vehicle.GetPilot(a_hVehicle)
    if hPilot then
      Combat.SetIgnoreCombatInVehicle(hPilot, true)
    end
    local tPassengers = Vehicle.GetPassengers(a_hVehicle)
    if tPassengers then
      for i, hPassenger in ipairs(tPassengers) do
        Combat.SetIgnoreCombatInVehicle(hPassenger, true)
      end
    end
  end
  Veh.RunCallbackTable(self, a_tConfig.tOnSpawn, {a_hVehicle})
end

function Veh.SetGunnerHostile(t_self, a_hVehicle)
  local tList = Vehicle.GetOccupantList(a_hVehicle)
  if tList ~= nil then
    if tList.Gunners ~= nil then
      local hGunner = tList.Gunners[1]
      Combat.SetStationary(hGunner, true)
      Combat.SetReactImmediately(hGunner, true)
      Combat.SetTarget(hGunner, hSab)
      Combat.LockIntoRanged(hGunner)
      Combat.SetBroadcastEnteredCombat(hGunner, false)
      Combat.SetBroadcastWeaponFire(hGunner, false)
      Combat.SetCombat(hGunner)
      Combat.SetIgnoreCombatInVehicle(hGunner, true)
    end
    if tList.Pilot ~= nil then
      local hGunner = tList.Pilot[1]
      Combat.SetReactImmediately(hGunner, true)
      Combat.SetTarget(hGunner, hSab)
      Combat.LockIntoRanged(hGunner)
      Combat.SetBroadcastEnteredCombat(hGunner, false)
      Combat.SetBroadcastWeaponFire(hGunner, false)
      Combat.SetCombat(hGunner)
    end
  end
end

function Veh:OnDropoffVehicleArrives(a_hVehicle, a_tConfig)
  Nav.StopMoving(a_hVehicle)
  local cUnboardType = a_tConfig.cUnboardType or cDROPOFF_PASSENGERS_ALL
  Veh.RunCallbackTable(self, a_tConfig.tOnArrive, {a_hVehicle})
  if Object.IsAlive(a_hVehicle) then
    if cUnboardType == cDROPOFF_PASSENGERS_ALL then
      VEHICLE_UnboardAllPassengers(a_hVehicle, "Veh.OnPassengerExitsVehicle", self, {a_tConfig})
    elseif cUnboardType == cDROPOFF_ALL then
      VEHICLE_UnboardAll(a_hVehicle, "Veh.OnPassengerExitsVehicle", self, {a_tConfig})
    elseif cUnboardType == cDROPOFF_PILOT then
      VEHICLE_UnboardPilot(a_hVehicle, "Veh.OnPassengerExitsVehicle", self, {a_tConfig})
    elseif cUnboardType == cDROPOFF_PASSENGERS_NOGUNNER then
      VEHICLE_UnboardAllSoldiers(a_hVehicle, "Veh.OnPassengerExitsVehicle", self, {a_tConfig})
    elseif cUnboardType == cDROPOFF_ALL_EXCEPT_GUNNER then
      VEHICLE_UnboardAllNotGunner(a_hVehicle, "Veh.OnPassengerExitsVehicle", self, {a_tConfig})
    end
  end
end

function Veh:OnPassengerExitsVehicle(a_tPassengerData, a_tConfig)
  Veh.RunCallbackTable(self, a_tConfig.tOnUnboard, {a_tPassengerData})
  local hActor = a_tPassengerData[1]
  if a_tConfig and a_tConfig.sSquad then
    Squad.Create(a_tConfig.sSquad)
    Squad.AddMember(a_tConfig.sSquad, hActor)
  end
  if a_tConfig and a_tConfig.tHuntTargets and a_tConfig.bAttackPlayer == nil then
    local vHuntTarget = Tips.GetRandomElement(a_tConfig.tHuntTargets)
    Combat.SetHunt(hActor, Handle(vHuntTarget), true, false, nil, nil, nil, false)
    Combat.SetTarget(hActors, Handle("Saboteur"))
  elseif a_tConfig and a_tConfig.bHuntUnboardLoc == true and a_tConfig.bAttackPlayer == nil then
    local x, y, z = Object.GetPosition(hActor)
    Combat.SetHunt(hActor, x, y, z, true, false, nil, nil, nil, false)
    Combat.SetTarget(hActor, Handle("Saboteur"))
  elseif a_tConfig and a_tConfig.bAttackPlayer ~= nil and a_tConfig.bAttackPlayer == true then
    Combat.SetCombat(hActor)
    Combat.SetTarget(hActor, Handle("Saboteur"))
  end
  local tTimerEvent = {
    EventType = "TimerEvent",
    Time = 5,
    EventName = tostring(a_tPassengerData[2]) .. "_DropoffTimeout"
  }
  Util.CreateEvent(tTimerEvent, "Veh.OnDeliveryComplete", self, {
    a_tPassengerData[2],
    a_tConfig
  })
end

function Veh:OnDeliveryComplete(a_hVehicle, a_tConfig)
  if a_tConfig and a_tConfig.sExitPath then
    Nav.SetScriptedPath(a_hVehicle, a_tConfig.sExitPath, true, "Veh.OnDropoffVehicleExits", self, {a_hVehicle, a_tConfig})
    Veh.RunCallbackTable(self, a_tConfig.tOnComplete, {a_hVehicle})
  elseif a_tConfig and a_tConfig.vExitTarget then
    Nav.MoveToObject(a_hVehicle, Handle(a_tConfig.vExitTarget), 2, true, "Veh.OnDropoffVehicleExits", self, {a_hVehicle, a_tConfig})
    Veh.RunCallbackTable(self, a_tConfig.tOnComplete, {a_hVehicle})
  end
  local cDespawnType = a_tConfig.cDespawnType or cDESPAWN_ONEXIT_LOSCHECK
  if cDespawnType == cDESPAWN_ADDTOTRAFFIC then
    if not a_tConfig.sExitPath and not a_tConfig.vExitTarget then
      Vehicle.AddToTraffic(a_hVehicle)
      Veh.RunCallbackTable(self, a_tConfig.tOnExit, {a_hVehicle})
    end
  elseif cDespawnType == cDESPAWN_ONCOMPLETE_LOSCHECK then
    Veh.RunCallbackTable(self, a_tConfig.tOnExit, {a_hVehicle})
    Veh.Despawn(a_hVehicle, 15, true)
  elseif cDespawnType == cDESPAWN_ONCOMPLETE_NOLOSCHECK then
    Veh.RunCallbackTable(self, a_tConfig.tOnExit, {a_hVehicle})
    Veh.Despawn(a_hVehicle, 0, false)
  end
end

function Veh:OnDropoffVehicleExits(a_hVehicle, a_tConfig)
  local cDespawnType = a_tConfig.cDespawnType or cDESPAWN_ONEXIT_LOSCHECK
  if cDespawnType == cDESPAWN_ADDTOTRAFFIC then
    Vehicle.AddToTraffic(a_hVehicle)
    Veh.RunCallbackTable(self, a_tConfig.tOnExit, {a_hVehicle})
  elseif cDespawnType == cDESPAWN_ONEXIT_LOSCHECK then
    Veh.RunCallbackTable(self, a_tConfig.tOnExit, {a_hVehicle})
    Veh.Despawn(a_hVehicle, 30, true)
  elseif cDespawnType == cDESPAWN_ONEXIT_NOLOSCHECK then
    Veh.RunCallbackTable(self, a_tConfig.tOnExit, {a_hVehicle})
    Veh.Despawn(a_hVehicle, 0, false)
  end
end

function Veh:RunCallbackTable(a_tCallbacks, a_tExtraParams)
  if a_tCallbacks then
    for i, v in ipairs(a_tCallbacks) do
      if self then
        local tCallbackParams = {self}
        if a_tExtraParams then
          for a, param in ipairs(a_tExtraParams) do
            table.insert(tCallbackParams, param)
          end
        end
        if v[2] then
          for x, y in ipairs(v[2]) do
            table.insert(tCallbackParams, y)
          end
        end
        local fFunc
        if type(v[1]) == "string" then
          fFunc = Tips.StringToFunction(v[1])
        elseif type(v[1]) == "function" then
          fFunc = v[1]
        end
        fFunc(unpack(tCallbackParams))
      else
        local fFunc
        if type(v[1]) == "string" then
          fFunc = Tips.StringToFunction(v[1])
        elseif type(v[1]) == "function" then
          fFunc = v[1]
        end
        fFunc(unpack(v[2]))
      end
    end
  end
end

function Veh.SpawnerChaser(sLocator, sRegion, cVehicleConst, tCustomConfig, DespawnDistance, fCallback, tMissionSelf)
  if not sLocator then
    Util.Assert(false, "Cfrench SpawnerChaser failed , incorrect params")
    print("ERROR: SpawnerChaser failed, incorrect params")
  end
  local cVEHICLE, tVC
  local tDefaultVehicleConfig = {
    Pilot = "Human_WM_Officer_PS",
    Shotgun = "Human_WM_Grunt_MG"
  }
  cVEHICLE = cVehicleConst or cVEH_KUBEL
  tVC = tCustomConfig or tDefaultVehicleConfig
  local Despawndist = DespawnDistance or 180
  local tUserdata = {}
  local MissionSelfID
  if tMissionSelf and tMissionSelf._SELFTABLE_ID then
    MissionSelfID = tMissionSelf._SELFTABLE_ID
  end
  if sRegion then
    return EVENT_PlayerEntersTrigger("Veh._SpawnChaserTriggerCallback", nil, sRegion, false, {
      sLocator,
      cVEHICLE,
      tVC,
      Despawndist,
      fCallback,
      MissionSelfID
    })
  else
    Veh._SpawnChaserCallback(tUserdata, sLocator, cVEHICLE, tVC, Despawndist, fCallback, MissionSelfID)
  end
end

function Veh:_SpawnChaserTriggerCallback(tUserdata, locator, cVehicleConst, tCustomConfig, DespawnDistance, fCallback, MissionSelfID)
  print("triggered Veh._SpawnChaser ", locator, DespawnDistance, fCallback, MissionSelfID)
  hLoc = Util.GetHandleByName(locator)
  if not hLoc then
    Util.Assert(false, "Cfrench, Veh._SpawnChaser trying to spawn vehicle on nil locator")
    print("ERROR:Veh._SpawnChaser trying to spawn vehicle on nil locator")
    return
  end
  Veh.SafeSpawnAtObj(cVehicleConst, hLoc, tCustomConfig, true, Veh._CarChaseSab, nil, {
    DespawnDistance,
    fCallback,
    MissionSelfID
  })
end

function Veh._SpawnChaserCallback(tUserdata, locator, cVehicleConst, tCustomConfig, DespawnDistance, fCallback, MissionSelfID)
  print("triggered Veh._SpawnChaser ", locator, DespawnDistance, fCallback, MissionSelfID)
  hLoc = Util.GetHandleByName(locator)
  if not hLoc then
    Util.Assert(false, "Cfrench, Veh._SpawnChaser trying to spawn vehicle on nil locator")
    print("ERROR:Veh._SpawnChaser trying to spawn vehicle on nil locator")
    return
  end
  Veh.SafeSpawnAtObj(cVehicleConst, hLoc, tCustomConfig, true, Veh._CarChaseSab, nil, {
    DespawnDistance,
    fCallback,
    MissionSelfID
  })
end

function Veh._CarChaseSab(hVehicle, DespawnDistance, fCallback, MissionSelfID)
  print("vehicle? ", hVehicle, DespawnDistance, fCallback, MissionSelfID)
  local hPilot
  if hVehicle then
    hPilot = Vehicle.GetPilot(hVehicle)
    print("Pilot ? ", hPilot)
    if hPilot then
      print("car chasing sab")
      Nav.FollowObject(hPilot, hSab, 2, true)
    else
      Nav.FollowObject(hVehicle, hSab, 2, true)
    end
    if fCallback then
      if MissionSelfID then
        local tSelf = SabTask.GetSelfFromID(MissionSelfID)
        if not tSelf then
          print("oh noes! error no tSelf in Veh._CarChaseSab:exclamation")
          return
        else
          fCallback(tSelf, hVehicle)
        end
      else
        fCallback(hVehicle)
      end
    end
    Veh.Despawn(hVehicle, DespawnDistance, true)
  end
end
