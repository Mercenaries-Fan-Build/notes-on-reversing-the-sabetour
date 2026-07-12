Formation = Formation or {}

function Formation.Spawn(a_vLeader, a_tFormationData, a_nSpacing, a_fCallback, a_tSelf, a_tCallbackParams)
  local tStreamEvent = {
    EventType = "StreamEvent",
    WaitForGameObject = true,
    WaitForPathfinding = true,
    Objects = {a_vLeader}
  }
  Util.CreateEvent(tStreamEvent, "Formation._Spawn", a_tSelf, {
    a_vLeader,
    a_tFormationData,
    a_nSpacing,
    a_fCallback,
    a_tCallbackParams
  })
end

function Formation._Spawn(a_tSelf, a_vLeader, a_tFormationData, a_nSpacing, a_fCallback, a_tCallbackParams)
  local hLeader = Handle(a_vLeader)
  local nLeaderPosX = 0
  local nLeaderPosZ = 0
  local nFormationSize = 1
  Util.Assert(hLeader ~= nil, "Invalid leader (parameter 1) specified for Formation.Spawn!")
  Util.Assert(a_tFormationData ~= nil, "Invalid formation table (parameter 2) sent to Formation.Spawn!")
  if not Formations then
    Formations = {}
    Formations.CurrentID = 1
  end
  local nFormationID = Formations.CurrentID
  Formations[nFormationID] = {}
  Formations.CurrentID = Formations.CurrentID + 1
  for z, row in ipairs(a_tFormationData) do
    for x, blueprint in ipairs(row) do
      if blueprint == "LEADER" then
        nLeaderPosX = x
        nLeaderPosZ = z
        break
      end
    end
  end
  for z, row in ipairs(a_tFormationData) do
    for x, sBlueprint in ipairs(row) do
      if sBlueprint ~= "SPACE" and sBlueprint ~= "_" and sBlueprint ~= " " and sBlueprint ~= 0 and sBlueprint ~= "LEADER" then
        local nPosX, nPosZ = Formation.GetRelativePosToLeader(a_tFormationData, x, z, nLeaderPosX, nLeaderPosZ, a_nSpacing, a_nSpacing)
        local nLeaderX, nLeaderY, nLeaderZ = Object.GetPosition(hLeader)
        local nSpawnX, nSpawnY, nSpawnZ = Util.FindSafeSpawnPoint(nLeaderX, nLeaderY, nLeaderZ, 2, 10)
        Object.Spawn(sBlueprint, nSpawnX, nSpawnY, nSpawnZ, 0, nil, "Formation.OnActorSpawns", nil, {
          hLeader,
          nPosX,
          nPosZ,
          nFormationID
        })
        nFormationSize = nFormationSize + 1
      end
    end
  end
  local tCallbackParams = {}
  if a_tSelf ~= nil and a_tCallbackParams ~= nil then
    table.insert(a_tCallbackParams, 1, a_tSelf)
    for i, v in ipairs(a_tCallbackParams) do
      table.insert(tCallbackParams, v)
    end
  elseif a_tSelf ~= nil and a_tCallbackParams == nil then
    tCallbackParams = {a_tSelf}
  elseif a_tSelf == nil and a_tCallbackParams ~= nil then
    tCallbackParams = a_tCallbackParams
  else
    tCallbackParams = nil
  end
  Formations[nFormationID].Size = nFormationSize
  Formations[nFormationID].Leader = hLeader
  Formations[nFormationID].Callback = a_fCallback
  Formations[nFormationID].CallbackParams = tCallbackParams
  Formations[nFormationID].Actors = {hLeader}
end

function Formation.Set(a_vLeader, a_tFormationData, a_tActors, a_nSpacing)
  local hLeader = Handle(a_vLeader)
  local tOffsets = {}
  local nLeaderPosX = 0
  local nLeaderPosZ = 0
  Util.Assert(hLeader ~= nil, "Invalid leader (parameter 1) specified in Formation.Set!")
  Util.Assert(a_tFormationData ~= nil, "Invalid formation data (parameter 2) sent to Formation.Set!")
  Util.Assert(a_tActors ~= nil, "Invalid actor list (parameter 3) sent to Formation.Set!")
  for z, row in ipairs(a_tFormationData) do
    for x, blueprint in ipairs(row) do
      if blueprint == "LEADER" then
        nLeaderPosX = x
        nLeaderPosZ = z
        break
      end
    end
  end
  for z, row in ipairs(a_tFormationData) do
    for x, sData in ipairs(row) do
      if sData ~= "SPACE" and sData ~= "_" and sData ~= " " and sData ~= 0 and sData ~= "LEADER" then
        local nOffsetX, nOffsetZ = Formation.GetRelativePosToLeader(a_tFormationData, x, z, nLeaderPosX, nLeaderPosZ, a_nSpacing, a_nSpacing)
        table.insert(tOffsets, {x = nOffsetX, z = nOffsetZ})
      end
    end
  end
  local nCurrentOffset = 1
  for i, vActor in ipairs(a_tActors) do
    local hActor = Handle(vActor)
    if 1 < i and (i - 1) % #tOffsets == 0 then
      nCurrentOffset = 1
    end
    if hActor ~= hLeader and Actor.IsAlive(hActor) == true then
      Nav.EnterFormation(hActor, hLeader, tOffsets[nCurrentOffset].x, 0, tOffsets[nCurrentOffset].z)
      nCurrentOffset = nCurrentOffset + 1
    end
  end
end

function Formation:OnActorSpawns(a_tSpawnData, a_hLeader, a_nOffsetX, a_nOffsetZ, a_nFormationID)
  local hActor = a_tSpawnData[1]
  local tFormation = Formations[a_nFormationID]
  tFormation.Actors = tFormation.Actors or {}
  table.insert(tFormation.Actors, hActor)
  if #tFormation.Actors == tFormation.Size then
    local tActors = {}
    for i, v in ipairs(tFormation.Actors) do
      table.insert(tActors, v)
    end
    if tFormation.Callback ~= nil then
      table.insert(tFormation.CallbackParams, tActors)
      tFormation.Callback(unpack(tFormation.CallbackParams))
    end
    Formations[a_nFormationID] = nil
  end
  Nav.EnterFormation(hActor, a_hLeader, a_nOffsetX, 0, a_nOffsetZ)
end

function Formation.GetRelativePosToLeader(a_tFormationData, a_nX, a_nZ, a_nLeaderX, a_nLeaderZ, a_nSpacingX, a_nSpacingZ)
  local nLeaderPosX = a_nLeaderX or 1
  local nLeaderPosZ = a_nLeaderY or 1
  local nSpacingX = a_nSpacingX or 1
  local nSpacingZ = a_nSpacingZ or 1
  local nActorsInRow = #a_tFormationData[a_nZ]
  local nEstimatedX = -(a_nX - a_nLeaderX) * nSpacingX
  local nEstimatedZ = (a_nLeaderZ - a_nZ) * nSpacingZ
  return nEstimatedX, nEstimatedZ
end

function Formation.SetOffset(a_vFollower, a_vLeader, a_x, a_y, a_z)
  local tStreamEvent = {
    EventType = "StreamEvent",
    WaitForGameObject = true,
    WaitForPathfinding = true,
    Objects = {a_vFollower, a_vLeader}
  }
  Util.CreateEvent(tStreamEvent, "Formation._SetOffset", nil, {
    a_vFollower,
    a_vLeader,
    a_x,
    a_y,
    a_z
  })
end

function Formation._SetOffset(a_NIL, a_vFollower, a_vLeader, a_x, a_y, a_z)
  Nav.EnterFormation(Handle(a_vFollower), Handle(a_vLeader), a_x, a_y, a_z)
end

function Formation.Purge()
  for k, v in pairs(Formations) do
    Formations[k] = nil
  end
end
