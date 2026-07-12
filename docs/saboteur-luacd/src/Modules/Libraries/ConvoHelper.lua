if not ConvoHelper then
  ConvoHelper = {}
  ConvoHelper.tActiveConvoID = {}
end

function ConvoHelper.InterruptReplay(sConv, sID, hCallback, t_Self, t_UserTable)
  if sID then
    ConvoHelper[sID] = {}
    ConvoHelper[sID].hCallback = hCallback
    ConvoHelper[sID].t_Self = t_Self
    ConvoHelper[sID].t_UserTable = t_UserTable
    ConvoHelper[sID].sConv = sConv
    table.insert(ConvoHelper.tActiveConvoID, sID)
    Cin.PlayConversation(sConv, "ConvoHelper.InterruptReplayCheck", nil, {sID})
  end
end

function ConvoHelper.InterruptReplayCheck(anil, tData, sID)
  if tData then
    if tData[1] ~= 3 then
      if Suspicion.GetEscalation() > 0 or Suspicion.IsSomeoneHostile() then
        local tEvent = {
          EventType = "OnEscalation0",
          Target = hSab
        }
        Util.CreateEvent(tEvent, "ConvoHelper.PlayAgainInterruptReplay", nil, {sID})
      end
    else
      if ConvoHelper[sID].hCallback then
        local fFunction = Tips.StringToFunction(ConvoHelper[sID].hCallback)
        fFunction(ConvoHelper[sID].t_Self, ConvoHelper[sID].t_UserTable)
      end
      ConvoHelper.KillConvoEvent(sID)
    end
  end
end

function ConvoHelper.PlayAgainInterruptReplay(anil, tData, sID)
  Cin.PlayConversation(ConvoHelper[sID].sConv, "ConvoHelper.InterruptReplayCheck", nil, {sID})
end

function ConvoHelper.VehicleDamage(hVehicle, tConvos, sID, tFlags)
  if hVehicle and tConvos and 0 < #tConvos then
    if ConvoHelper[sID] and ConvoHelper[sID].hEvent then
      Util.KillEvent(ConvoHelper[sID].hEvent)
    end
    ConvoHelper[sID] = {}
    table.insert(ConvoHelper.tActiveConvoID, sID)
    ConvoHelper[sID].tConvos = tConvos
    ConvoHelper[sID].hVehicle = hVehicle
    ConvoHelper[sID].nMaxHealth = Object.GetMaxHealth(hVehicle)
    ConvoHelper[sID].tFlags = tFlags
    local nSizeOfConvo = #tConvos
    ConvoHelper[sID].tPlayed = {}
    for i = 1, nSizeOfConvo do
      ConvoHelper[sID].tPlayed[i] = false
    end
    local tEvent = {
      EventType = "DamageEvent",
      ObjectHandle = hVehicle
    }
    ConvoHelper[sID].hEvent = Util.CreateEvent(tEvent, "ConvoHelper.VehicleDamageCheck2", nil, {sID}, true)
    return ConvoHelper[sID].hEvent
  end
end

function ConvoHelper.VehicleDamageCheck2(anil1, anil2, tUserInfo)
  local sID = tUserInfo
  local tThreshold = {}
  local nCounter = 1
  local bFound = false
  local fPercentage = Object.GetHealth(ConvoHelper[sID].hVehicle) / ConvoHelper[sID].nMaxHealth
  local wtf = Vehicle.GetFireThreshold(ConvoHelper[sID].hVehicle)
  local wtf2 = Vehicle.GetSmokeThreshold(ConvoHelper[sID].hVehicle)
  while nCounter <= #ConvoHelper[sID].tConvos do
    if nCounter == 1 then
      tThreshold[1] = 0
    elseif nCounter == 2 then
      tThreshold[2] = Vehicle.GetFireThreshold(ConvoHelper[sID].hVehicle) / ConvoHelper[sID].nMaxHealth
    elseif nCounter == 3 then
      tThreshold[3] = Vehicle.GetSmokeThreshold(ConvoHelper[sID].hVehicle) / ConvoHelper[sID].nMaxHealth
    else
      local nTotalHealth = 1 - tThreshold[3]
      local fIncrementer = 1 / (#ConvoHelper[sID].tConvos - 3)
      tThreshold[nCounter] = tThreshold[3] + (nCounter - 3) * fIncrementer * nTotalHealth
    end
    nCounter = nCounter + 1
  end
  nCounter = 1
  while nCounter < #ConvoHelper[sID].tConvos and bFound == false do
    if fPercentage > tThreshold[nCounter] and fPercentage < tThreshold[nCounter + 1] then
      bFound = true
    else
      nCounter = nCounter + 1
    end
  end
  local nConvoLoc = #ConvoHelper[sID].tConvos - nCounter
  if nConvoLoc <= 0 then
    nConvoLoc = #ConvoHelper[sID].tConvos
  end
  if ConvoHelper.VehicleDamageCheckConditions(sID, nConvoLoc) then
    Cin.PlayConversation(ConvoHelper[sID].tConvos[nConvoLoc])
    ConvoHelper[sID].tPlayed[nConvoLoc] = true
    if nConvoLoc >= #ConvoHelper[sID].tConvos then
      ConvoHelper.KillConvoEvent(sID)
    end
  end
end

function ConvoHelper.VehicleDamageCheck(anil1, anil2, tUserInfo)
  local sID = tUserInfo
  local fPercentage = Object.GetHealth(ConvoHelper[sID].hVehicle) / ConvoHelper[sID].nMaxHealth
  local fIncrementer
  local nConvoLoc = 1
  local bFound = false
  if #ConvoHelper[sID].tConvos == 1 then
    if fPercentage <= 0 then
      Cin.PlayConversation(ConvoHelper[sID].tConvos[1])
      ConvoHelper[sID].tPlayed[1] = true
      ConvoHelper.KillConvoEvent(sID)
    end
  else
    fIncrementer = 1 / (#ConvoHelper[sID].tConvos - 1)
    while nConvoLoc <= #ConvoHelper[sID].tConvos - 1 and bFound == false do
      if fPercentage > fIncrementer * (nConvoLoc - 1) and fPercentage <= fIncrementer * nConvoLoc then
        bFound = true
      else
        nConvoLoc = nConvoLoc + 1
      end
    end
    nConvoLoc = #ConvoHelper[sID].tConvos - nConvoLoc
    if nConvoLoc <= 0 then
      nConvoLoc = #ConvoHelper[sID].tConvos
    end
    if ConvoHelper.VehicleDamageCheckConditions(sID, nConvoLoc) then
      Cin.PlayConversation(ConvoHelper[sID].tConvos[nConvoLoc])
      ConvoHelper[sID].tPlayed[nConvoLoc] = true
      if nConvoLoc >= #ConvoHelper[sID].tConvos then
        ConvoHelper.KillConvoEvent(sID)
      end
    end
  end
end

function ConvoHelper.VehicleDamageCheckConditions(sID, nConvoLoc)
  if ConvoHelper[sID].tPlayed[nConvoLoc] == true then
    return false
  end
  if ConvoHelper[sID].tFlags and ConvoHelper[sID].tFlags.bInCar == true then
    if Actor.IsInVehicle(hSab) then
      if Actor.GetVehicle(hSab) ~= ConvoHelper[sID].hVehicle then
        return false
      end
    else
      return false
    end
  end
  if Cin.IsHumanInConversation(hSab) == true then
    return false
  end
  return true
end

function ConvoHelper.KillConvoEvent(sID)
  if sID and ConvoHelper[sID] then
    if ConvoHelper[sID].hEvent then
      Util.KillEvent(ConvoHelper[sID].hEvent)
    end
    ConvoHelper[sID] = nil
  end
end

function ConvoHelper.ClearAll()
  for i, v in ipairs(ConvoHelper.tActiveConvoID) do
    if ConvoHelper[v] then
      ConvoHelper.KillConvoEvent(v)
    end
  end
  ConvoHelper.tActiveConvoID = {}
end
