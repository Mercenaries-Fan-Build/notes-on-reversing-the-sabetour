require("Includes\\WRAPPER_Util")

function VEHICLE_UnboardPilot(a_vVehicle, a_sCallback, self, a_tCallbackParams)
  local hVehicle = WRAPPER_CheckForHandle(a_vVehicle)
  local hPilot = Vehicle.GetPilot(hVehicle)
  if hPilot and hVehicle then
    _VEHICLE_Exit(self, hPilot, a_sCallback, hVehicle, a_tCallbackParams)
  end
end

function VEHICLE_UnboardAll(a_vVehicle, a_sCallback, self, a_tCallbackParams, a_sCallbackAll, self2, a_tCallbackParams2)
  local hVehicle = WRAPPER_CheckForHandle(a_vVehicle)
  WRAPPER_SanityCheck(hVehicle, "Invalid vehicle name/handle passed to VEHICLE_UnboardAll!")
  local tPassengers = Vehicle.GetPassengers(hVehicle)
  if not tPassengers then
    return
  end
  Vehicle.UnboardAll(hVehicle, false, a_sCallback, self, a_tCallbackParams, a_sCallbackAll, self2, a_tCallbackParams2)
end

function VEHICLE_UnboardAllPassengers(a_vVehicle, a_sCallback, self, a_tCallbackParams, a_sCallbackAll, self2, a_tCallbackParams2)
  local hVehicle = WRAPPER_CheckForHandle(a_vVehicle)
  WRAPPER_SanityCheck(hVehicle, "Invalid vehicle name/handle passed to VEHICLE_UnboardAll!")
  local tOccupants = Vehicle.GetOccupantList(hVehicle)
  if not tOccupants then
    return
  end
  local tPassengers = tOccupants.Passengers
  if not tPassengers then
    return
  end
  Vehicle.UnboardAll(hVehicle, true, a_sCallback, self, a_tCallbackParams, a_sCallbackAll, self2, a_tCallbackParams2)
end

function VEHICLE_UnboardAllSoldiers(a_vVehicle, a_sCallback, self, a_tCallbackParams, a_sCallbackAll, self2, a_tCallbackParams2)
  local hVehicle = WRAPPER_CheckForHandle(a_vVehicle)
  WRAPPER_SanityCheck(hVehicle, "Invalid vehicle name/handle passed to VEHICLE_UnboardAll!")
  local tOccupants = Vehicle.GetOccupantList(hVehicle)
  if not tOccupants then
    return
  end
  local tPassengers = tOccupants.Passengers
  if not tPassengers then
    return
  end
  Vehicle.UnboardAll(hVehicle, tPassengers, a_sCallback, self, a_tCallbackParams, a_sCallbackAll, self2, a_tCallbackParams2)
end

function VEHICLE_UnboardAllNotGunner(a_vVehicle, a_sCallback, self, a_tCallbackParams, a_sCallbackAll, self2, a_tCallbackParams2)
  local hVehicle = WRAPPER_CheckForHandle(a_vVehicle)
  WRAPPER_SanityCheck(hVehicle, "Invalid vehicle name/handle passed to VEHICLE_UnboardAll!")
  local tOccupants = Vehicle.GetOccupantList(hVehicle)
  if not tOccupants then
    return
  end
  local tPassengers = tOccupants.Passengers
  local tPilot = tOccupants.Passengers
  if tPilot and tPilot[1] then
    table.insert(tPassengers, tPilot[1])
  end
  Vehicle.UnboardAll(hVehicle, tPassengers, a_sCallback, self, a_tCallbackParams, a_sCallbackAll, self2, a_tCallbackParams2)
end

function _VEHICLE_OnSeated(self, a_hVehicle, a_hPassenger, a_sCallback, a_tCallbackParams)
  if Vehicle.CanPassengerGetOut(a_hVehicle, a_hPassenger) then
    _VEHICLE_Exit(self, a_hPassenger, a_sCallback, a_hVehicle, a_tCallbackParams)
  else
    local hNextSeat = Vehicle.GetNextExitSeat(a_hVehicle, a_hPassenger)
    if hNextSeat then
      if Vehicle.CanBoard(a_hVehicle, a_hPassenger, hNextSeat) then
        _VEHICLE_OnSeatEmpty(self, a_hVehicle, a_hPassenger, hNextSeat, a_tCallbackParams)
      else
        local e = {
          EventType = "SeatEmptyEvent",
          Vehicle = a_hVehicle,
          SeatName = hNextSeat
        }
        Util.CreateEvent(e, "_VEHICLE_OnSeatEmpty", self, {
          a_hVehicle,
          a_hPassenger,
          hNextSeat,
          a_sCallback,
          a_tCallbackParams
        })
      end
    else
      print("NoNextSeat!")
    end
  end
end

function _VEHICLE_OnSeatEmpty(self, a_hVehicle, a_hPassenger, a_hNextSeat, a_sCallback, a_tCallbackParams)
  Vehicle.ChangeSeat(a_hVehicle, a_hPassenger, a_hNextSeat)
  local e = {
    EventType = "SeatChangedEvent",
    Vehicle = a_hVehicle,
    SeatName = a_hNextSeat,
    Passenger = a_hPassenger
  }
  Util.CreateEvent(e, "_VEHICLE_OnSeated", self, {
    a_hVehicle,
    a_hPassenger,
    a_sCallback,
    a_tCallbackParams
  })
end

function _VEHICLE_StaggeredExit(self, a_hPassenger, a_sCallback, a_hVehicle)
  EVENT_Timer("_VEHICLE_Exit", self, math.random(1, 4), {
    a_hPassenger,
    a_sCallback,
    a_hVehicle
  })
end

function _VEHICLE_Exit(self, a_hPassenger, a_sCallback, a_hVehicle, a_tCallbackParams)
  if Object.IsAlive(a_hPassenger) then
    Actor.UnboardVehicle(a_hPassenger)
    if not a_sCallback then
      return
    end
    local e = {
      EventType = "OnVehicleExit",
      Target = a_hPassenger
    }
    local tCallbackParams = {}
    if a_tCallbackParams then
      for i, v in ipairs(a_tCallbackParams) do
        table.insert(tCallbackParams, v)
      end
    end
    Util.CreateEvent(e, a_sCallback, self, tCallbackParams)
  end
end

function VEHICLE_MoveToBoardAtPosition(a_actor, a_vehicle, a_sSeatName)
  local hActor, hVehicle
  hActor = WRAPPER_CheckForHandle(a_actor)
  hVehicle = WRAPPER_CheckForHandle(a_vehicle)
  if hVehicle then
    local x, y, z = Vehicle.GetBoardingPosition(hVehicle, a_sSeatName)
    if x or y or z then
      if hActor then
        Nav.MoveToPoint(hActor, x, y, z, true, "_VEHICLE_BoardVehicle", nil, {
          hActor,
          hVehicle,
          a_sSeatName
        }, 15)
      else
        Util.Assert(false, "No handle for ", a_actor, " in VEHICLE_MoveToBoardAtPosition")
      end
    end
  else
    Util.Assert(false, "No handle for ", a_vehicle, " in VEHICLE_MoveToBoardAtPosition")
  end
end

function _VEHICLE_BoardVehicle(self, hActor, hVehicle, a_sSeatName)
  print(" _VEHICLE_BoardVehicle ", hActor, hVehicle, a_sSeatName)
  Actor.BoardVehicle(hActor, hVehicle, a_sSeatName)
end
