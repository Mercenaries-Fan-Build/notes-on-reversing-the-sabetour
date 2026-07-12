if not ScriptSequence then
  ScriptSequence = {}
  ScriptSequence.Failsafes = {}
  ScriptSequence.SyncEvents = {}
  ScriptSequence.SyncFailsafes = {}
end

function ScriptSequence.Run(a_vCharacter, a_tSequenceData, a_fCallback, a_tCallbackParams)
  local hCharacter = ScriptSequence.CheckForHandle(a_vCharacter)
  Util.Assert(a_tSequenceData ~= nil, "You're passing a nil sequeNce table to the ScriptSequence!")
  if hCharacter == nil then
    if a_tCallbackParams and type(a_tCallbackParams[1]) == "table" and a_tCallbackParams[1]._SELFTABLE_ID then
      Util.Assert(false, "It's dangerous to pass mission self tables to ScriptSequences!")
      local nSelfTableID = a_tCallbackParams[1]._SELFTABLE_ID
      a_tCallbackParams[1] = nSelfTableID
      Util.CreateEvent({
        EventType = "StreamEvent",
        Objects = {a_vCharacter}
      }, "ScriptSequence.ProcessSelfStreamEvent", nil, {
        a_vCharacter,
        a_tSequenceData,
        a_fCallback,
        a_tCallbackParams
      })
      return
    end
    Util.CreateEvent({
      EventType = "StreamEvent",
      Objects = {a_vCharacter}
    }, "ScriptSequence.ProcessStreamEvent", nil, {
      a_vCharacter,
      a_tSequenceData,
      a_fCallback,
      a_tCallbackParams
    })
    return
  end
  if Util.IsHandleValid(hCharacter) == false then
    return
  end
  local tNewSelf = Actor.GetSelf(hCharacter)
  if tNewSelf.tCurrentSequence ~= nil then
    ScriptSequence.ClearPendingEvents(tNewSelf)
  end
  tNewSelf.tCurrentSequence = {}
  tNewSelf.tCurrentSequence.tSequenceData = a_tSequenceData
  tNewSelf.tCurrentSequence.fCallback = a_fCallback
  tNewSelf.tCurrentSequence.tCallbackParams = a_tCallbackParams
  ScriptSequence._Run(tNewSelf, "NONE", -1)
end

function ScriptSequence.AdvancedRun(a_vCharacter, a_tSequenceData, a_nStartingElement, a_fCallback, a_tCallbackParams)
  local hCharacter = ScriptSequence.CheckForHandle(a_vCharacter)
  Util.Assert(a_tSequenceData ~= nil, "You're passing a nil sequence table to the ScriptSequence!")
  local tNewSelf = Actor.GetSelf(hCharacter)
  if tNewSelf.tCurrentSequence ~= nil then
    ScriptSequence.ClearPendingEvents(tNewSelf)
  end
  tNewSelf.tCurrentSequence = {}
  tNewSelf.tCurrentSequence.tSequenceData = a_tSequenceData
  tNewSelf.tCurrentSequence.fCallback = a_fCallback
  tNewSelf.tCurrentSequence.tCallbackParams = a_tCallbackParams
  ScriptSequence._Run(tNewSelf, "NONE", a_nStartingElement)
end

function ScriptSequence.ProcessStreamEvent(a_tBogusSelf, a_vCharacter, a_tSequenceData, a_fCallback, a_tCallbackParams)
  ScriptSequence.Run(a_vCharacter, a_tSequenceData, a_fCallback, a_tCallbackParams)
end

function ScriptSequence.ProcessSelfStreamEvent(a_tBogusSelf, a_vCharacter, a_tSequenceData, a_fCallback, a_tCallbackParams)
  Util.Assert(false, "Hold on to your butts -- re-inserting the self table into the callbacks!")
  local nSelfTableID = a_tCallbackParams[1]
  a_tCallbackParams[1] = gMasterSelfTable[nSelfTableID]
  ScriptSequence.Run(a_vCharacter, a_tSequenceData, a_fCallback, a_tCallbackParams)
end

function ScriptSequence._Run(a_EntitySelf, a_sStartingElementName, a_nCurrentElement)
  if a_EntitySelf == nil then
    return
  end
  if Object.IsDead(a_EntitySelf.hController) == true then
    return
  end
  if a_EntitySelf.tCurrentSequence == nil then
    return
  end
  if Util.IsHandleValid(a_EntitySelf.hController) == false then
    return
  end
  ScriptSequence.ClearPendingEvents(a_EntitySelf)
  if a_sStartingElementName == "NONE" and a_nCurrentElement == -1 then
    Nav.StopMoving(a_EntitySelf.hController)
    Actor.CancelAnimation(a_EntitySelf.hController)
  end
  Util.Assert(a_EntitySelf.tCurrentSequence ~= nil, "tCurrentSequence is nil?!?")
  Util.Assert(a_EntitySelf.tCurrentSequence.tSequenceData ~= nil, "tSequenceData is nil!?")
  if a_nCurrentElement ~= nil and a_nCurrentElement > #a_EntitySelf.tCurrentSequence.tSequenceData then
    if a_EntitySelf.tCurrentSequence.fCallback == nil then
      a_EntitySelf.tCurrentSequence = nil
      return
    end
    local fCallback = a_EntitySelf.tCurrentSequence.fCallback
    local tCallbackParams = a_EntitySelf.tCurrentSequence.tCallbackParams
    a_EntitySelf.tCurrentSequence = nil
    if tCallbackParams then
      fCallback(unpack(tCallbackParams))
    else
      fCallback()
    end
    return
  end
  if 1 < a_nCurrentElement then
    a_EntitySelf.tCurrentSequence.nLastCompletedCommand = a_nCurrentElement - 1
  else
    a_EntitySelf.tCurrentSequence.nLastCompletedCommand = 0
  end
  local nCurrentElement = 1
  if a_nCurrentElement ~= nil and a_nCurrentElement ~= -1 then
    nCurrentElement = a_nCurrentElement
  end
  if a_sStartingElementName ~= nil and a_sStartingElementName ~= "NONE" then
    local nSearchedIndex = ScriptSequence.FindSequenceElementByName(a_EntitySelf.tCurrentSequence.tSequenceData, a_sStartingElementName)
    if nSearchedIndex ~= nil then
      nCurrentElement = nSearchedIndex
    else
      Util.Assert(false, "ScriptSequence couldn't find element labeled \"" .. a_sStartingElementName .. "\"")
    end
  end
  local tCurrentCommand = a_EntitySelf.tCurrentSequence.tSequenceData[nCurrentElement]
  local sCommandName = string.upper(tCurrentCommand[1])
  local tCommandParameters = tCurrentCommand[2]
  local sElementName = tCurrentCommand[3]
  if sCommandName == "ENDSEQUENCE" then
    if a_EntitySelf.tCurrentSequence.fCallback == nil or a_EntitySelf.tCurrentSequence.tCallbackParams == nil then
      a_EntitySelf.tCurrentSequence = nil
      return
    end
    a_EntitySelf.tCurrentSequence.fCallback(unpack(a_EntitySelf.tCurrentSequence.tCallbackParams))
    a_EntitySelf.tCurrentSequence = nil
    return
  elseif sCommandName == "STREAMEVENT" then
    local e = {
      EventType = "StreamEvent",
      Objects = tCommandParameters[1],
      WaitForGameObject = tCommandParameters[2]
    }
    Util.CreateEvent(e, "ScriptSequence._Run", a_EntitySelf, {
      "NONE",
      nCurrentElement + 1
    })
    return
  elseif sCommandName == "WALKTOOBJECT" then
    local nStoppageDist = 2
    if tCommandParameters[2] ~= nil then
      nStoppageDist = tCommandParameters[2]
    end
    Nav.MoveToObject(a_EntitySelf.hController, ScriptSequence.CheckForHandle(tCommandParameters[1]), nStoppageDist, false, "ScriptSequence._Run", a_EntitySelf, {
      "NONE",
      nCurrentElement + 1
    })
    return
  elseif sCommandName == "RUNTOOBJECT" then
    local nStoppageDist = 2
    if tCommandParameters[2] ~= nil then
      nStoppageDist = tCommandParameters[2]
    end
    Nav.MoveToObject(a_EntitySelf.hController, ScriptSequence.CheckForHandle(tCommandParameters[1]), nStoppageDist, true, "ScriptSequence._Run", a_EntitySelf, {
      "NONE",
      nCurrentElement + 1
    })
    return
  elseif sCommandName == "WALKTOPOINT" then
    Nav.MoveToPoint(a_EntitySelf.hController, tCommandParameters[1], tCommandParameters[2], tCommandParameters[3], false, "ScriptSequence._Run", a_EntitySelf, {
      "NONE",
      nCurrentElement + 1
    })
    return
  elseif sCommandName == "RUNTOPOINT" then
    Nav.MoveToPoint(a_EntitySelf.hController, tCommandParameters[1], tCommandParameters[2], tCommandParameters[3], true, "ScriptSequence._Run", a_EntitySelf, {
      "NONE",
      nCurrentElement + 1
    })
    return
  elseif sCommandName == "WALKTORANDOM" then
    local _x, _y, _z = Object.GetPosition(a_EntitySelf.hController)
    local x, y, z = Util.FindSafeSpawnPoint(_x, _y, _z, tCommandParameters[1], tCommandParameters[2])
    Nav.MoveToPoint(a_EntitySelf.hController, x, y, z, false, "ScriptSequence._Run", a_EntitySelf, {
      "NONE",
      nCurrentElement + 1
    })
    return
  elseif sCommandName == "RUNTORANDOM" then
    local _x, _y, _z = Object.GetPosition(a_EntitySelf.hController)
    local x, y, z = Util.FindSafeSpawnPoint(_x, _y, _z, tCommandParameters[1], tCommandParameters[2])
    Nav.MoveToPoint(a_EntitySelf.hController, x, y, z, true, "ScriptSequence._Run", a_EntitySelf, {
      "NONE",
      nCurrentElement + 1
    })
    return
  elseif sCommandName == "WALKPATHONCE" then
    Nav.SetScriptedPath(a_EntitySelf.hController, tCommandParameters[1], false, "ScriptSequence._Run", a_EntitySelf, {
      "NONE",
      nCurrentElement + 1
    })
    Nav.SetScriptedPathMoveMode(a_EntitySelf.hController, cMOVE_NORMAL)
    return
  elseif sCommandName == "WALKPATHONCE_NOWAIT" then
    Nav.SetScriptedPath(a_EntitySelf.hController, tCommandParameters[1], false)
    Nav.SetScriptedPathMoveMode(a_EntitySelf.hController, cMOVE_NORMAL)
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "RUNPATHONCE" then
    Nav.SetScriptedPath(a_EntitySelf.hController, tCommandParameters[1], true, "ScriptSequence._Run", a_EntitySelf, {
      "NONE",
      nCurrentElement + 1
    })
    Nav.SetScriptedPathMoveMode(a_EntitySelf.hController, cMOVE_FORCERUN)
    return
  elseif sCommandName == "RUNPATHONCE_NOWAIT" then
    Nav.SetScriptedPath(a_EntitySelf.hController, tCommandParameters[1], true)
    Nav.SetScriptedPathMoveMode(a_EntitySelf.hController, cMOVE_FAST)
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "WALKPATH" then
    Nav.SetScriptedPath(a_EntitySelf.hController, tCommandParameters[1], true)
    Nav.SetScriptedPathMoveMode(a_EntitySelf.hController, false)
    Nav.SetScriptedPathType(a_EntitySelf.hController, tCommandParameters[2])
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "FOLLOWOBJECT" then
    local nFollowDistance = 2
    local bFollowUrgent = false
    if tCommandParameters[2] ~= nil then
      nFollowDistance = tCommandParameters[2]
    end
    if tCommandParameters[3] ~= nil then
      bFollowUrgent = tCommandParameters[3]
    end
    Nav.FollowObject(a_EntitySelf.hController, ScriptSequence.CheckForHandle(tCommandParameters[1]), nFollowDistance, bFollowUrgent)
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "CANCELFOLLOW" then
    Nav.CancelFollowObject(a_EntitySelf.hController)
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "STOPMOVING" then
    Nav.StopMoving(a_EntitySelf.hController)
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "MATCHFACING" then
    local nNewFacing = Object.GetAngle(ScriptSequence.CheckForHandle(tCommandParameters[1]))
    Actor.SetFacingDir(a_EntitySelf.hController, nNewFacing)
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "TURNTOFACE" then
    Actor.SetFacingDir(a_EntitySelf.hController, ScriptSequence.CheckForHandle(tCommandParameters[1]))
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "SETFACING" then
    Actor.SetFacingDir(a_EntitySelf.hController, tCommandParameters[1])
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "MATCHIDLEFACING" then
    local nNewFacing = Object.GetAngle(ScriptSequence.CheckForHandle(tCommandParameters[1]))
    Combat.SetIdleAngle(a_EntitySelf.hController, nNewFacing)
    return
  elseif sCommandName == "RETURNTOIDLE" then
    Combat.ReturnToIdlePos(a_EntitySelf.hController)
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "WALKTORANDOM" then
    local x, y, z = Object.GetPosition(a_EntitySelf.hController)
    local destX, destY, destZ = Util.FindSafeSpawnPoint(x, y, z, tCommandParameters[1], tCommandParameters[2])
    Nav.MoveToPoint(a_EntitySelf.hController, destX, destY, destZ, false, "ScriptSequence._Run", a_EntitySelf, {
      "NONE",
      nCurrentElement + 1
    })
    return
  elseif sCommandName == "RUNTORANDOM" then
    local x, y, z = Object.GetPosition(a_EntitySelf.hController)
    local destX, destY, destZ = Util.FindSafeSpawnPoint(x, y, z, tCommandParameters[1], tCommandParameters[2])
    Nav.MoveToPoint(a_EntitySelf.hController, destX, destY, destZ, true, "ScriptSequence._Run", a_EntitySelf, {
      "NONE",
      nCurrentElement + 1
    })
    return
  elseif sCommandName == "HUNTLOCATION" then
    Combat.SetHunt(a_EntitySelf.hController, tCommandParameters[1], tCommandParameters[2], tCommandParameters[3], tCommandParameters[4], tCommandParameters[5], nil, nil, nil, false)
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "ATTACKTARGET" then
    Combat.SetTarget(a_EntitySelf.hController, ScriptSequence.CheckForHandle(tCommandParameters[1]))
    Combat.SetCombat(a_EntitySelf.hController)
    local hEvent = Util.CreateEvent({
      EventType = "DeathEvent",
      ObjectHandle = ScriptSequence.CheckForHandle(tCommandParameters[1])
    }, "ScriptSequence._Run", a_EntitySelf, {
      "NONE",
      nCurrentElement + 1
    })
    ScriptSequence.AddPendingEvent(a_EntitySelf, hEvent)
  elseif sCommandName == "ATTACKTARGET_NOWAIT" then
    Combat.SetTarget(a_EntitySelf.hController, ScriptSequence.CheckForHandle(tCommandParameters[1]))
    Combat.SetCombat(a_EntitySelf.hController)
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "SETTARGET" then
    Combat.SetTarget(a_EntitySelf.hController, ScriptSequence.CheckForHandle(tCommandParameters[1]))
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "FIRECURRENTWEAPON" then
    Actor.FireCurrentWeapon(a_EntitySelf.hController)
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "SETSTATIONARY" then
    Combat.SetStationary(a_EntitySelf.hController, tCommandParameters[1])
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "TETHER_AT_OBJPOS" then
    local nDefaultTetherDist = 5
    if tCommandParameters[2] then
      nDefaultTetherDist = tCommandParameters[2]
    end
    local x, y, z = Object.GetPosition(ScriptSequence.CheckForHandle(tCommandParameters[1]))
    Combat.SetTether(a_EntitySelf.hController, x, y, z, nDefaultTetherDist)
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "TETHER_TO_OBJ" then
    local nDefaultTetherDist = 5
    if tCommandParameters[2] then
      nDefaultTetherDist = tCommandParameters[2]
    end
    Combat.SetTether(a_EntitySelf.hController, ScriptSequence.CheckForHandle(tCommandParameters[1]), nDefaultTetherDist)
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "TETHER_TO_POS" then
    local nDefaultTetherDist = 5
    if tCommandParameters[2] then
      nDefaultTetherDist = tCommandParameters[2]
    end
    Combat.SetTether(a_EntitySelf.hController, tCommandParameters[1], tCommandParameters[2], tCommandParameters[3], nDefaultTetherDist)
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "TETHER_AT_CURRENT" then
    local x, y, z = Object.GetPosition(a_EntitySelf.hController)
    Combat.SetTether(a_EntitySelf.hController, x, y, z, tCommandParameters[1])
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "SETLETHALFORCE" then
    Combat.SetLethalForce(a_EntitySelf.hController, tCommandParameters[1])
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "LOCKINTOCOMBAT" then
    Combat.LockIntoCombat(a_EntitySelf.hController)
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "CLEARCOMBATLOCKS" then
    Combat.ClearStateLock(a_EntitySelf.hController)
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "JOINSQUAD" then
    Squad.AddMember(tCommandParameters[1], a_EntitySelf.hController)
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "LEAVESQUAD" then
    Squad.RemoveMember(tCommandParameters[1], a_EntitySelf.hController)
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "MAKESQUADLEADER" then
    Squad.SetLeader(tCommandParameters[1], a_EntitySelf.hController)
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "PANICFROMOBJ" then
    Actor.AddSafetyNeed(a_EntitySelf.hController, -100, ScriptSequence.CheckForHandle(tCommandParameters[1]))
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "SETWALLHAX" or sCommandName == "SETHAX" then
    Combat.SetAlwaysSeeTarget(a_EntitySelf.hController, tCommandParameters[1])
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "SETCOMBAT" then
    if tCommandParameters[1] == true then
      Combat.SetCombat(a_EntitySelf.hController)
    else
      Combat.Exit(a_EntitySelf.hController)
    end
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "SETBROADCAST_WEAPONFIRE" then
    Combat.SetBroadcastWeaponFire(a_EntitySelf.hController, tCommandParameters[1])
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "SETBROADCAST_ENTEREDCOMBAT" then
    Combat.SetBroadcastEnteredCombat(a_EntitySelf.hController, tCommandParameters[1])
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "SETRESPOND_SOUND" then
    Combat.SetRespondToSound(a_EntitySelf.hController, tCommandParameters[1])
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "SETDRYFIRE" then
    Combat.SetDryFire(a_EntitySelf.hController, tCommandParameters[1])
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "OVERRIDECOMBATAI" then
    Actor.OverrideCombatAI(a_EntitySelf.hController, tCommandParameters[1])
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "SETREACTIMMEDIATELY" then
    Combat.SetReactImmediately(a_EntitySelf.hController, tCommandParameters[1])
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "HOLSTERWEAPON" then
    Combat.SetIdleHoldWeapon(a_EntitySelf.hController, false)
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "UNHOLSTERWEAPON" or sCommandName == "DRAWWEAPON" then
    Combat.SetIdleHoldWeapon(a_EntitySelf.hController, false)
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "SETIDLEPOS" then
    local hObj = ScriptSequence.CheckForHandle(tCommandParameters[1])
    local nRot = Object.GetAngle(hObj)
    local x, y, z = Object.GetPosition(hObj)
    Combat.SetIdlePos(a_EntitySelf.hController, x, y, z)
    Combat.SetIdleAngle(a_EntitySelf.hController, nRot)
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "SETCOMBATFLAGS" then
    local tFlags = tCommandParameters[1]
    if tFlags.RespondsToEvents ~= nil then
      Combat.SetRespondToEvents(a_EntitySelf.hController, tFlags.RespondsToEvents)
    end
    if tFlags.RespondsToDamage ~= nil then
      Combat.SetRespondToDamage(a_EntitySelf.hController, tFlags.RespondsToDamage)
    end
    if tFlags.RespondsToSound ~= nil then
      Combat.SetRespondToSound(a_EntitySelf.hController, tFlags.RespondsToSound)
    end
    if tFlags.RespondsToDeadBodies ~= nil then
      Combat.SetRespondToDeadBodies(a_EntitySelf.hController, tFlags.RespondsToDeadBodies)
    end
    if tFlags.SetIdleScripted ~= nil then
      Combat.SetIdleScripted(a_EntitySelf.hController, tFlags.SetIdleScripted)
    end
    if tFlags.EnableSuspicion ~= nil then
      Suspicion.Enable(a_EntitySelf.hController, tFlags.EnableSuspicion)
    end
    if tFlags.HoldWeapon ~= nil then
      Combat.SetIdleHoldWeapon(a_EntitySelf.hController, tFlags.HoldWeapon)
    end
    if tFlags.NoAutoResponse == true then
      Combat.AddTargetFlag(a_EntitySelf.hController, cTARGET_NOAUTORESPONSE)
    end
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "CLEARCOMBATFLAGS" then
    Combat.SetRespondToEvents(a_EntitySelf.hController, true)
    Combat.SetRespondToDamage(a_EntitySelf.hController, true)
    Combat.SetRespondToDeadBodies(a_EntitySelf.hController, true)
    Combat.SetIdleScripted(a_EntitySelf.hController, false)
    Combat.SetRespondToSound(a_EntitySelf.hController, true)
    Suspicion.Enable(a_EntitySelf.hController, true)
    Combat.SetIdleHoldWeapon(a_EntitySelf.hController, false)
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    Combat.AddTargetFlag(a_EntitySelf.hController, cTARGET_ALLENEMIES)
    return
  elseif sCommandName == "MAKEDUMB" then
    Combat.Exit(a_EntitySelf.hController)
    Combat.SetRespondToEvents(a_EntitySelf.hController, false)
    Combat.SetRespondToDamage(a_EntitySelf.hController, false)
    Combat.SetRespondToDeadBodies(a_EntitySelf.hController, false)
    Combat.SetIdleScripted(a_EntitySelf.hController, true)
    Suspicion.Enable(a_EntitySelf.hController, false)
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "MAKEUNDUMB" then
    Combat.SetRespondToEvents(a_EntitySelf.hController, true)
    Combat.SetRespondToDamage(a_EntitySelf.hController, true)
    Combat.SetRespondToDeadBodies(a_EntitySelf.hController, true)
    Combat.SetIdleScripted(a_EntitySelf.hController, false)
    Suspicion.Enable(a_EntitySelf.hController, true)
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "SETLEADER" then
    Combat.SetLeader(a_EntitySelf.hController, ScriptSequence.CheckForHandle(tCommandParameters[1]))
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "PLAYANIMATION" then
    if tCommandParameters[2] ~= nil then
      if tCommandParameters[2] == true or tCommandParameters[2] == false then
        Actor.PlayAnimation(a_EntitySelf.hController, tCommandParameters[1], 1, tCommandParameters[2])
        ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
        return
      else
        Actor.PlayAnimation(ScriptSequence.CheckForHandle(tCommandParameters[2]), tCommandParameters[1])
        ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
        return
      end
    else
      Actor.PlayAnimation(a_EntitySelf.hController, tCommandParameters[1])
      ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
      return
    end
  elseif sCommandName == "PLAYREMOTEANIMATION" or sCommandName == "PLAYREMOTEANIM" then
    if tCommandParameters[2] ~= string.upper("NONE") then
      Actor.PlayAnimation(ScriptSequence.CheckForHandle(tCommandParameters[1]), tCommandParameters[2])
    end
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "PLAYFACINGANIMATION" then
    Actor.PlayAnimation(a_EntitySelf.hController, tCommandParameters[1], -1, false, Actor.CalcFacingTo(a_EntitySelf.hController, ScriptSequence.CheckForHandle(tCommandParameters[2])))
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "PLAYRANDOMANIMATION" or sCommandName == "PLAYRANDOMANIM" then
    Util.Assert(type(tCommandParameters[1]) == "table", "You must give the PLAYRANDOMANIMATION a list of animations (table).")
    local sAnimName = Tips.GetRandomElement(tCommandParameters[1])
    Actor.PlayAnimation(a_EntitySelf.hController, sAnimName)
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "CANCELANIMATION" then
    Actor.CancelAnimation(a_EntitySelf.hController)
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "ACTIVATEANIMATEDPROP" then
    if tCommandParameters[3] ~= nil then
      Object.EnableAnimatedPropPart(ScriptSequence.CheckForHandle(tCommandParameters[3]), tCommandParameters[1], tCommandParameters[2])
      ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
      return
    elseif tCommandParameters[2] ~= nil then
      Object.EnableAnimatedPropPart(a_EntitySelf.hController, tCommandParameters[1])
      ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
      return
    else
      Object.EnableAnimatedPropPart(a_EntitySelf.hController, tCommandParameters[1], tCommandParameters[2])
      ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
      return
    end
  elseif sCommandName == "STARTFX" then
    if tCommandParameters[3] ~= nil then
      Render.StartFX(ScriptSequence.CheckForHandle(tCommandParameters[3]), tCommandParameters[1], tCommandParameters[2])
      ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
      return
    else
      Render.StartFX(a_EntitySelf.hController, tCommandParameters[1], tCommandParameters[2])
      ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
      return
    end
  elseif sCommandName == "ENDFX" then
    if tCommandParameters[3] ~= nil then
      Render.EndFX(ScriptSequence.CheckForHandle(tCommandParameters[3]), tCommandParameters[1], tCommandParameters[2])
      ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
      return
    else
      Render.EndFX(a_EntitySelf.hController, tCommandParameters[1], tCommandParameters[2])
      ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
      return
    end
  elseif sCommandName == "SPAWNBLOOD_LARGE" then
    Render.StartFX(Handle(tCommandParameters[1]), "0FX_Blood02_Large", nil)
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "PLAYSOUND" or sCommandName == "ATTACHSOUND" then
    Sound.AttachSoundEvent(a_EntitySelf.hController, tCommandParameters[1])
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "PLAYSOUND2D" then
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "PLAYSOUND3D" then
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "SETMUSICSTATE" then
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "SETMUSICLOCALE" then
    Sound.SetMusicLocale(tCommandParameters[1])
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "RELEASEMUSICSTATE" then
    Sound.SetMusicLocale("Default")
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "BROADCASTTOSELF" then
    local tBroadcastParams = {}
    if tCommandParameters[2] ~= nil then
      tBroadcastParams = tCommandParameters[2]
    end
    Util.BroadcastFunction(a_EntitySelf.hController, tCommandParameters[1], tBroadcastParams)
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "BROADCASTTOAREA" then
    local tBroadcastParams = {}
    if tCommandParameters[3] ~= nil then
      tBroadcastParams = tCommandParameters[3]
    end
    Util.BroadcastFunction(a_EntitySelf.hController, tCommandParameters[1], tCommandParameters[2], tCommandParameters[3])
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "USEATTRPT" then
    if AttractionPt.IsAvailable(ScriptSequence.CheckForHandle(tCommandParameters[1])) == true then
      Actor.UseAttrPt(a_EntitySelf.hController, ScriptSequence.CheckForHandle(tCommandParameters[1]), "ScriptSequence._Run", a_EntitySelf, {
        "NONE",
        nCurrentElement + 1
      })
    else
      ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    end
    return
  elseif sCommandName == "USEATTRPT_NOWAIT" then
    if AttractionPt.IsAvailable(ScriptSequence.CheckForHandle(tCommandParameters[1])) == true then
      Actor.UseAttrPt(a_EntitySelf.hController, ScriptSequence.CheckForHandle(tCommandParameters[1]))
      ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    else
      ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    end
    return
  elseif sCommandName == "USEATTRPT_NOCALL" then
    if AttractionPt.IsAvailable(ScriptSequence.CheckForHandle(tCommandParameters[1])) == true then
      Actor.UseAttrPt(a_EntitySelf.hController, ScriptSequence.CheckForHandle(tCommandParameters[1]))
    else
      ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    end
    return
  elseif sCommandName == "USEATTACHEDATTRPT" then
    local hAttrPt = AttractionPt.FindPtInObject(ScriptSequence.CheckForHandle(tCommandParameters[1]), tCommandParameters[2])
    if AttractionPt.IsAvailable(hAttrPt) == true then
      Actor.UseAttrPt(a_EntitySelf.hController, hAttrPt, "ScriptSequence._Run", a_EntitySelf, {
        "NONE",
        nCurrentElement + 1
      })
    else
      ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    end
    return
  elseif sCommandName == "USEATTRPT_IDLEBEGIN" then
    local hAttrPt = ScriptSequence.CheckForHandle(tCommandParameters[1])
    if AttractionPt.IsAvailable(hAttrPt) == true then
      Util.CreateEvent({
        EventType = "OnActorIdleBegin",
        Target = hAttrPt
      }, "ScriptSequence.RunStrippedCallback", a_EntitySelf, {
        "NONE",
        nCurrentElement + 1
      })
      Actor.UseAttrPt(a_EntitySelf.hController, hAttrPt)
    else
      ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    end
    return
  elseif sCommandName == "REQUESTATTRPT" then
    if AttractionPt.IsAvailable(ScriptSequence.CheckForHandle(tCommandParameters[1])) == true then
      Actor.RequestAttrPt(a_EntitySelf.hController, ScriptSequence.CheckForHandle(tCommandParameters[1]), "ScriptSequence._Run", a_EntitySelf, {
        "NONE",
        nCurrentElement + 1
      })
    else
      ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    end
    return
  elseif sCommandName == "REQUESTATTRPT_NOWAIT" then
    if AttractionPt.IsAvailable(ScriptSequence.CheckForHandle(tCommandParameters[1])) == true then
      Actor.RequestAttrPt(a_EntitySelf.hController, ScriptSequence.CheckForHandle(tCommandParameters[1]))
      ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    else
      ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    end
    return
  elseif sCommandName == "CANCELATTRPT" then
    Actor.CancelAttrPt(a_EntitySelf.hController)
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "CANCELATTRPTREQUEST" then
    Actor.CancelAttrPtRequest(a_EntitySelf.hController)
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "SETVAR" then
    Tips.SetVarByString(tCommandParameters[1], tCommandParameters[2])
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "ACTIVATEDOOR" then
    Object.Actuate(ScriptSequence.CheckForHandle(tCommandParameters[1]), true)
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "DESPAWN_IMMEDIATE" then
    if a_EntitySelf.tCurrentSequence.fCallback ~= nil then
      a_EntitySelf.tCurrentSequence.fCallback(unpack(a_EntitySelf.tCurrentSequence.tCallbackParams))
    end
    Object.Despawn(a_EntitySelf.hController, 0, false)
    return
  elseif sCommandName == "DESPAWN" then
    Object.Despawn(ScriptSequence.CheckForHandle(tCommandParameters[1]))
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "MARKFORDESPAWN" then
    Object.Despawn(a_EntitySelf.hController, tCommandParameters[1], true)
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "MARKOTHERFORDESPAWN" then
    Object.Despawn(ScriptSequence.CheckForHandle(tCommandParameters[1]), tCommandParameters[2], true)
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "SETSUSPICION" then
    Suspicion.SetState(a_EntitySelf.hController, tCommandParameters[1])
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "ENABLESUSPICION" then
    Suspicion.Enable(a_EntitySelf.hController, tCommandParameters[1])
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "SETHEALTH" then
    Object.SetHealth(a_EntitySelf.hController, tCommandParameters[1])
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "TELEPORT_TO_OBJ" then
    local x, y, z = Object.GetPosition(ScriptSequence.CheckForHandle(tCommandParameters[1]))
    local nRot = Object.GetAngle(ScriptSequence.CheckForHandle(tCommandParameters[1]))
    Object.Teleport(a_EntitySelf.hController, x, y, z, nRot)
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "PLAYONELINER" then
    Cin.PlayConversationWith(tCommandParameters[1], {
      a_EntitySelf.hController
    }, "ScriptSequence._Run", a_EntitySelf, {
      "NONE",
      nCurrentElement + 1
    })
    return
  elseif sCommandName == "PLAYONELINER_NOWAIT" then
    Cin.PlayConversationWith(tCommandParameters[1], {
      a_EntitySelf.hController
    })
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "PLAYCONVERSATION" then
    Cin.PlayConversation(tCommandParameters[1], "ScriptSequence.RunStrippedCallback", a_EntitySelf, {
      "NONE",
      nCurrentElement + 1
    })
    return
  elseif sCommandName == "PLAYCONVERSATION_NOWAIT" then
    Cin.PlayConversation(tCommandParameters[1])
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "FOCUS_SEARCHER" then
    Searchlight.SetTarget(Handle(tCommandParameters[1]), tCommandParameters[2], Handle(tCommandParameters[3]))
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "ENABLE_SEARCHER" then
    Searchlight.EnableLights(Handle(tCommandParameters[1]), tCommandParameters[2], tCommandParameters[3])
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "ENTERFORMATION" then
    Nav.EnterFormation(a_EntitySelf.hController, Handle(tCommandParameters[1]), tCommandParameters[2], tCommandParameters[3], tCommandParameters[4])
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "EXITFORMATION" then
    Nav.ExitFormation(a_EntitySelf.hController)
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "ENABLESCHEDULE" then
    Actor.EnableSchedule(a_EntitySelf.hController, true)
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "DISABLESCHEDULE" then
    Actor.EnableSchedule(a_EntitySelf.hController, false)
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "ENABLENEEDS" then
    Actor.EnableNeeds(a_EntitySelf.hController, true)
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "DISABLENEEDS" then
    Actor.EnableNeeds(a_EntitySelf.hController, false)
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "BOARDVEHICLE" then
    local hVehicle = ScriptSequence.CheckForHandle(tCommandParameters[1])
    local bUrgent = false
    if tCommandParameters[3] then
      bUrgent = tCommandParameters[3]
    end
    Nav.BoardVehicle(a_EntitySelf.hController, hVehicle, tCommandParameters[2], bUrgent, "ScriptSequence._Run", a_EntitySelf, {
      "NONE",
      nCurrentElement + 1
    })
    return
  elseif sCommandName == "ENTERSEAT" then
    local hVehicle = ScriptSequence.CheckForHandle(tCommandParameters[1])
    local hEvent = Util.CreateEvent({
      EventType = "EnteredVehicleEvent",
      ObjectHandle = a_EntitySelf.hController,
      VehicleHandle = hVehicle
    }, "ScriptSequence._Run", a_EntitySelf, {
      "NONE",
      nCurrentElement + 1
    })
    ScriptSequence.AddPendingEvent(a_EntitySelf, hEvent)
    Actor.BoardVehicle(a_EntitySelf.hController, hVehicle, tCommandParameters[2])
    return
  elseif sCommandName == "DRIVEPATHONCE" then
    Nav.SetScriptedPath(a_EntitySelf.hController, tCommandParameters[1], false, "ScriptSequence._Run", a_EntitySelf, {
      "NONE",
      nCurrentElement + 1
    })
    local nSpeed = 25
    if tCommandParameters[2] ~= nil then
      nSpeed = tCommandParameters[2]
    end
    Nav.SetScriptedPathSpeed(a_EntitySelf.hController, nSpeed)
    Nav.SetScriptedPathType(a_EntitySelf.hController, cPATHTYPE_ONCE)
    return
  elseif sCommandName == "DRIVEPATHLOOP" then
    Nav.SetScriptedPath(a_EntitySelf.hController, tCommandParameters[1])
    Nav.SetScriptedPathSpeed(a_EntitySelf.hController, tCommandParameters[2])
    Nav.SetScriptedPathType(a_EntitySelf.hController, cPATHTYPE_LOOP)
    return
  elseif sCommandName == "DRIVETOOBJECT" then
    Nav.MoveToObject(a_EntitySelf.hController, ScriptSequence.CheckForHandle(tCommandParameters[1]), 2, false, "ScriptSequence._Run", a_EntitySelf, {
      "NONE",
      nCurrentElement + 1
    })
    return
  elseif sCommandName == "DRIVETOPOINT" then
    Nav.MoveToPoint(a_EntitySelf.hController, tCommandParameters[1], tCommandParameters[2], tCommandParameters[3], false, "ScriptSequence._Run", a_EntitySelf, {
      "NONE",
      nCurrentElement + 1
    })
    return
  elseif sCommandName == "UNBOARDVEHICLE" then
    if Actor.IsInVehicle(a_EntitySelf.hController) == true then
      Actor.UnboardVehicle(a_EntitySelf.hController)
    end
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "ADDTOTRAFFIC" then
    local hVeh = Actor.GetVehicle(a_EntitySelf.hController)
    if hVeh ~= nil then
      print("AddingToTraffic")
      Vehicle.AddToTraffic(hVeh)
    end
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "FADETO" then
    Render.FadeTo(tCommandParameters[1], tCommandParameters[2], tCommandParameters[3], tCommandParameters[4], tCommandParameters[5])
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "FADETOBLACK" then
    Render.FadeTo(0, 0, 0, 255, tCommandParameters[1])
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "FADETOWHITE" then
    Render.FadeTo(255, 255, 255, 255, tCommandParameters[1])
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "FADETORED" then
    Render.FadeTo(255, 0, 0, 255, tCommandParameters[1])
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "FADETOCLEAR" then
    Render.FadeTo(0, 0, 0, 0, tCommandParameters[1])
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "ISIDLESEQUENCE" then
    a_EntitySelf.tCurrentSequence.bIsIdle = tCommandParameters[1]
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "JUMPTOELEMENT" then
    ScriptSequence._Run(a_EntitySelf, tCommandParameters[1], -1)
    return
  elseif sCommandName == "JUMPTORANDOM" then
    local sChosenRandomElement = tCommandParameters[math.random(#tCommandParameters)]
    ScriptSequence._Run(a_EntitySelf, sChosenRandomElement, -1)
    return
  elseif sCommandName == "STARTOVER" then
    ScriptSequence._Run(a_EntitySelf, "NONE", -1)
    return
  elseif sCommandName == "PRINTMESSAGE" then
    Render.PrintMessage(tCommandParameters[1])
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "SUBTITLE" then
    HUD.AddSubtitle(tCommandParameters[1], 3)
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "PRINTDIALOGUE" then
    local nPrintDialogueDuration = 2
    if tCommandParameters[2] ~= nil then
      nPrintDialogueDuration = tCommandParameters[2]
    end
    Render.PrintDialogue(a_EntitySelf.hController, tCommandParameters[1], nPrintDialogueDuration)
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "PRINTREMOTEDIALOGUE" then
    local nPrintDialogueDuration = 2
    if tCommandParameters[3] ~= nil then
      nPrintDialogueDuration = tCommandParameters[3]
    end
    Render.PrintDialogue(ScriptSequence.CheckForHandle(tCommandParameters[1]), tCommandParameters[2], nPrintDialogueDuration)
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "DELAY" then
    local hEvent = Util.CreateEvent({
      EventType = "TimerEvent",
      Time = tCommandParameters[1]
    }, "ScriptSequence._Run", a_EntitySelf, {
      "NONE",
      nCurrentElement + 1
    })
    ScriptSequence.AddPendingEvent(a_EntitySelf, hEvent)
    return
  elseif sCommandName == "DELAYFORRANDOM" then
    local hEvent = Util.CreateEvent({
      EventType = "TimerEvent",
      Time = math.random(tCommandParameters[1], tCommandParameters[2])
    }, "ScriptSequence._Run", a_EntitySelf, {
      "NONE",
      nCurrentElement + 1
    })
    ScriptSequence.AddPendingEvent(a_EntitySelf, hEvent)
    return
  elseif sCommandName == "FUNCTION" then
    if tCommandParameters[2] then
      tCommandParameters[1](unpack(tCommandParameters[2]))
    else
      tCommandParameters[1]()
    end
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "SELFFUNC" or sCommandName == "SELFFUNCTION" then
    local nID = tCommandParameters[2][1]
    tCommandParameters[2][1] = GetTableFromID(nID)
    if tCommandParameters[2] then
      tCommandParameters[1](unpack(tCommandParameters[2]))
    else
      tCommandParameters[1]()
    end
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "ADDLABEL" then
    Actor.SetLabel(a_EntitySelf.hController, tCommandParameters[1], true)
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "REMOVELABEL" then
    Actor.SetLabel(a_EntitySelf.hController, tCommandParameters[1], false)
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "SETIDLESCRIPTED" then
    Combat.SetIdleScripted(a_EntitySelf.hController, tCommandParameters[1])
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "GIVEITEMTO" then
    Inventory.GiveItem(Handle(tCommandParameters[1]), tCommandParameters[2], false)
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "IF_TRUE" then
    local tFunctionData = tCommandParameters[1]
    local sSuccessLabel = tCommandParameters[2]
    local sFailureLabel = tCommandParameters[3]
    local fFunction = Tips.StringToFunction(tFunctionData.Function)
    local tFunctionParameters = tFunctionData.Params
    local bEvaluation = false
    if tFunctionData.Params ~= nil then
      bEvaluation = fFunction(unpack(tFunctionParameters))
    else
      bEvaluation = fFunction()
    end
    if bEvaluation == true then
      if sSuccessLabel ~= nil then
        ScriptSequence._Run(a_EntitySelf, sSuccessLabel, -1)
      else
        Util.Assert(false, "IF_TRUE sequence command requires an element label to jump to! Ignoring this eval!")
        ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
      end
    elseif bEvaluation == false then
      if sFailureLabel then
        ScriptSequence._Run(a_EntitySelf, sFailureLabel, -1)
      else
        ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
      end
    else
      Util.Assert(false, "IF_TRUE evaluation function returned something other than TRUE or FALSE! Ignoring this eval!")
      ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    end
    return
  elseif sCommandName == "IF_FALSE" then
    local tFunctionData = tCommandParameters[1]
    local sSuccessLabel = tCommandParameters[2]
    local sFailureLabel = tCommandParameters[3]
    local fFunction = Tips.StringToFunction(tFunctionData.Function)
    local tFunctionParameters = tFunctionData.Params
    local bEvaluation = false
    if tFunctionData.Params ~= nil then
      bEvaluation = fFunction(unpack(tFunctionParameters))
    else
      bEvaluation = fFunction()
    end
    if bEvaluation == false then
      if sSuccessLabel ~= nil then
        ScriptSequence._Run(a_EntitySelf, sSuccessLabel, -1)
      else
        Util.Assert(false, "IF_FALSE sequence command requires an element label to jump to! Ignoring this eval!")
        ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
      end
    elseif bEvaluation == true then
      if sFailureLabel then
        ScriptSequence._Run(a_EntitySelf, sFailureLabel, -1)
      else
        ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
      end
    else
      Util.Assert(false, "IF_FALSE evaluation function returned something other than TRUE or FALSE! Ignoring this eval!")
      ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    end
    return
  elseif sCommandName == "SYNCHRONIZE" then
    if tCommandParameters == nil then
      Util.Assert(false, "The SYNCHRONIZE command requires you to list other objects to synchronize with.")
    end
    if sElementName == nil then
      Util.Assert(false, "The SYNCHRONIZE command requires a command label so the other objects know what to sync to.")
    end
    ScriptSequence.AddSyncEvent(sElementName, tCommandParameters, a_EntitySelf.hController)
    return
  elseif sCommandName == "FAILSAFE_START" then
    ScriptSequence.AddFailsafe(a_EntitySelf, tCommandParameters[1], tCommandParameters[2], tCommandParameters[3], tCommandParameters[4])
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "FAILSAFE_END" then
    ScriptSequence.KillFailsafe(tCommandParameters[1])
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "SYNC_FAILSAFE" then
    ScriptSequence.AddSyncFailsafe(tCommandParameters)
    ScriptSequence._Run(a_EntitySelf, "NONE", nCurrentElement + 1)
    return
  else
    Util.Assert(false, "\"" .. sCommandName .. "\" is an unrecognized ScriptSequence command!")
  end
end

function ScriptSequence.KillFailsafe(a_sLabel)
  if not a_sLabel then
    return
  end
  if ScriptSequence.Failsafes[a_sLabel] then
    Util.KillEvent(a_sLabel .. "_FS")
    ScriptSequence.Failsafes[a_sLabel] = nil
  end
end

function ScriptSequence.AddFailsafe(a_tEntitySelf, a_sElementLabel, a_nTime, a_fCallback, a_tCallbackParams)
  if not ScriptSequence.Failsafes[a_sElementLabel] then
    local tFailsafe = {}
    tFailsafe.fCallback = a_fCallback
    tFailsafe.tCallbackParams = a_tCallbackParams
    tFailsafe.hTarget = a_tEntitySelf.hController
    ScriptSequence.Failsafes[a_sElementLabel] = tFailsafe
    local tEvent = {
      EventType = "TimerEvent",
      Time = a_nTime,
      EventName = a_sElementLabel .. "_FS"
    }
    Util.CreateEvent(tEvent, "ScriptSequence.OnFailsafeTimerComplete", nil, {a_sElementLabel})
  end
end

function ScriptSequence.KillFailsafesByHandle(a_vHandle)
  local hActor = ScriptSequence.CheckForHandle(a_vHandle)
  if hActor == nil then
    return
  end
  for sElementLabel, tFailsafe in pairs(ScriptSequence.Failsafes) do
    if tFailsafe.hTarget == hActor then
      ScriptSequence.KillFailsafe(sElementLabel)
    end
  end
end

function ScriptSequence.OnFailsafeTimerComplete(a_Nil, a_sElementLabel)
  local tFailsafe = ScriptSequence.Failsafes[a_sElementLabel]
  if tFailsafe then
    if tFailsafe.tCallbackParams then
      local tNewCallbackParams = {}
      for i, v in ipairs(tFailsafe.tCallbackParams) do
        table.insert(tNewCallbackParams, v)
      end
      table.insert(tNewCallbackParams, tFailsafe.hTarget)
      table.insert(tNewCallbackParams, a_sElementLabel)
      tFailsafe.fCallback(unpack(tNewCallbackParams))
    else
      tFailsafe.fCallback(tFailsafe.hTarget, a_sElementLabel)
    end
  end
  ScriptSequence.Failsafes[a_sElementLabel] = nil
end

function ScriptSequence.AddSyncEvent(a_sSyncKey, a_tSyncObjects, a_hSyncObject)
  if ScriptSequence.SyncEvents[a_sSyncKey] == nil then
    ScriptSequence.SyncEvents[a_sSyncKey] = {}
    for i, v in ipairs(a_tSyncObjects) do
      ScriptSequence.SyncEvents[a_sSyncKey][Tips.CheckForHandle(v)] = {false, -1}
    end
    ScriptSequence.SyncEvents[a_sSyncKey][a_hSyncObject] = {true, -1}
    ScriptSequence.KeepSyncFailsafeAlive(a_sSyncKey, a_hSyncObject)
  else
    for i, v in ipairs(a_tSyncObjects) do
      if ScriptSequence.SyncEvents[a_sSyncKey][Tips.CheckForHandle(v)] == nil then
        ScriptSequence.SyncEvents[a_sSyncKey][Tips.CheckForHandle(v)] = {false, -1}
      end
    end
    ScriptSequence.SyncEvents[a_sSyncKey][a_hSyncObject] = {true, -1}
    ScriptSequence.KeepSyncFailsafeAlive(a_sSyncKey, a_hSyncObject)
  end
  ScriptSequence.ProcessSyncEvents()
end

function ScriptSequence.KeepSyncFailsafeAlive(a_sSyncKey, a_hSyncObject)
  local tFailsafe = ScriptSequence.SyncFailsafes[a_sSyncKey]
  if tFailsafe and tFailsafe.nKeepAliveTime then
    ScriptSequence.SetSyncFailsafeTimer(tFailsafe, tFailsafe.nKeepAliveTime)
  else
  end
end

function ScriptSequence.ProcessSyncEvents()
  for k, v in pairs(ScriptSequence.SyncEvents) do
    local bAllSyncObjectsReady = true
    for i, j in pairs(v) do
      if j[1] == false then
        bAllSyncObjectsReady = false
      end
    end
    if bAllSyncObjectsReady == false then
    else
      ScriptSequence.OnSyncConditionsMet(k)
    end
  end
end

function ScriptSequence.OnSyncConditionsMet(a_sSyncKey)
  for k, v in pairs(ScriptSequence.SyncEvents[a_sSyncKey]) do
    local tObjectSelf = Actor.GetSelf(k)
    ScriptSequence._Run(tObjectSelf, "NONE", tObjectSelf.tCurrentSequence.nLastCompletedCommand + 2)
  end
  ScriptSequence.SyncEvents[a_sSyncKey] = nil
  ScriptSequence.KillSyncFailsafe(a_sSyncKey, true)
end

function ScriptSequence.GetAllSyncTargets(a_sSyncKey)
  local tSyncTargets = {}
  local tSyncEvent = ScriptSequence.SyncEvents[a_sSyncKey]
  if tSyncEvent ~= nil then
    for k, v in pairs(tSyncEvent) do
      table.insert(tSyncTargets, k)
    end
    return tSyncTargets
  else
    return nil
  end
end

function ScriptSequence.GetSuccessfulSyncTargets(a_sSyncKey)
  local tSyncEvent = ScriptSequence.SyncEvents[a_sSyncKey]
  if tSyncEvent ~= nil then
    local tSyncTargets = {}
    local nSuccessful = 0
    for k, v in pairs(tSyncEvent) do
      if v[1] == true then
        table.insert(tSyncTargets, k)
        nSuccessful = nSuccessful + 1
      end
    end
    if 0 < nSuccessful then
      return tSyncTargets
    else
      return nil
    end
  else
    return nil
  end
end

function ScriptSequence.GetFailedSyncTargets(a_sSyncKey)
  local tSyncEvent = ScriptSequence.SyncEvents[a_sSyncKey]
  if tSyncEvent ~= nil then
    local tSyncTargets = {}
    local nFailed = 0
    for k, v in pairs(tSyncEvent) do
      if v[1] == false then
        table.insert(tSyncTargets, k)
        nFailed = nFailed + 1
      end
    end
    if 0 < nFailed then
      return tSyncTargets
    else
      return nil
    end
  else
    return nil
  end
end

function ScriptSequence.KillSyncFailsafe(a_sSyncKey, a_bKillTimer)
  local bKillTimer = a_bKillTimer or true
  if bKillTimer == true then
    Util.KillEvent(a_sSyncKey .. "_SFS")
  end
  ScriptSequence.SyncFailsafes[a_sSyncKey] = nil
end

function ScriptSequence.AddSyncFailsafe(a_tFSData)
  if not ScriptSequence.SyncFailsafes[a_tFSData.sSyncKey] then
    ScriptSequence.SyncFailsafes[a_tFSData.sSyncKey] = a_tFSData
    local tFailsafe = ScriptSequence.SyncFailsafes[a_tFSData.sSyncKey]
    if a_tFSData.nTimeUntilFirst then
      ScriptSequence.SetSyncFailsafeTimer(a_tFSData, a_tFSData.nTimeUntilFirst)
    end
  end
end

function ScriptSequence.SetSyncFailsafeTimer(a_tFSData, a_nTime)
  local tEvent = {
    EventType = "TimerEvent",
    Time = a_nTime,
    EventName = a_tFSData.sSyncKey .. "_SFS"
  }
  Util.CreateEvent(tEvent, "ScriptSequence.OnSyncFailsafeTimerComplete", nil, {
    a_tFSData.sSyncKey
  })
end

function ScriptSequence.OnSyncFailsafeTimerComplete(a_Nil, a_sSyncKey)
  local tInfo = {
    Fail = ScriptSequence.GetFailedSyncTargets(a_sSyncKey),
    Success = ScriptSequence.GetSuccessfulSyncTargets(a_sSyncKey)
  }
  if ScriptSequence.SyncFailsafes[a_sSyncKey] then
    if ScriptSequence.SyncFailsafes[a_sSyncKey].tCallbackParams ~= nil then
      local tNewCallbackParams = {}
      for i, v in ipairs(ScriptSequence.SyncFailsafes[a_sSyncKey].tCallbackParams) do
        table.insert(tNewCallbackParams, v)
      end
      table.insert(tNewCallbackParams, tInfo)
      ScriptSequence.SyncFailsafes[a_sSyncKey].fCallback(unpack(tNewCallbackParams))
    else
      ScriptSequence.SyncFailsafes[a_sSyncKey].fCallback(tInfo)
    end
  else
  end
end

function ScriptSequence.KillAllFailsafes()
  for k, v in pairs(ScriptSequence.SyncFailsafes) do
    Util.KillEvent(v.sSyncKey .. "_SFS")
    ScriptSequence.SyncFailsafes[k] = nil
  end
  for k, v in pairs(ScriptSequence.Failsafes) do
    Util.KillEvent(k .. "_FS")
    ScriptSequence.Failsafes[k] = nil
  end
end

function ScriptSequence.Pause(a_vCharacter)
  local hChar = ScriptSequence.CheckForHandle(a_vCharacter)
  local tEntitySelf = Actor.GetSelf(hChar)
  if tEntitySelf.tCurrentSequence ~= nil then
    ScriptSequence.KillCharacterActions(hChar)
    ScriptSequence.ClearPendingEvents(hChar)
  end
end

function ScriptSequence.Kill(a_vCharacter)
  if a_vCharacter == nil then
    return
  end
  local hChar = ScriptSequence.CheckForHandle(a_vCharacter)
  if hChar == nil then
    return
  end
  if Util.IsHandleValid(hChar) == true then
    ScriptSequence.KillFailsafesByHandle(hChar)
    local tEntitySelf = Actor.GetSelf(hChar)
    if tEntitySelf ~= nil then
      if tEntitySelf.tCurrentSequence ~= nil then
        ScriptSequence.KillCharacterActions(hChar)
        ScriptSequence.ClearPendingEvents(hChar)
      end
      tEntitySelf.tCurrentSequence = nil
    end
  end
end

function ScriptSequence.Resume(a_vCharacter)
  local tEntitySelf = Actor.GetSelf(ScriptSequence.CheckForHandle(a_vCharacter))
  if tEntitySelf.tCurrentSequence ~= nil then
    ScriptSequence._Run(tEntitySelf, "NONE", tEntitySelf.tCurrentSequence.nLastCompletedCommand + 1)
  end
end

function ScriptSequence.KillCharacterActions(a_vCharacter)
  local hChar = ScriptSequence.CheckForHandle(a_vCharacter)
  if Actor.IsUsingAttrPt(hChar) then
    Actor.CancelAttrPt(hChar)
  end
  Nav.StopMoving(hChar)
  Actor.CancelAnimation(hChar)
end

function ScriptSequence.FindSequenceElementByName(a_tSequence, a_sDesiredElementName)
  local i = 1
  while i <= #a_tSequence do
    local tCommand = a_tSequence[i]
    if tCommand[3] == a_sDesiredElementName then
      return i
    else
      i = i + 1
    end
  end
  return nil
end

function ScriptSequence.CheckForHandle(a_vVariable)
  local sType = type(a_vVariable)
  if sType == "userdata" then
    return a_vVariable
  elseif sType == "string" then
    return Util.GetHandleByName(a_vVariable)
  else
    Util.Assert(false, "ScriptSequence: Waiting for an object that is being identified by neither a HANDLE nor STRING! -Tips")
  end
end

function ScriptSequence.AddPendingEvent(a_EntitySelf, a_hEventID)
  if a_EntitySelf.tCurrentSequence ~= nil then
    if a_EntitySelf.tCurrentSequence.tPendingEvents == nil then
      a_EntitySelf.tCurrentSequence.tPendingEvents = {}
    end
    table.insert(a_EntitySelf.tCurrentSequence.tPendingEvents, a_hEventID)
  end
end

function ScriptSequence.ClearPendingEvents(a_vEntity)
  local sType = type(a_vEntity)
  if sType == "userdata" then
    local tEntitySelf = Actor.GetSelf(a_vEntity)
    if tEntitySelf.tCurrentSequence ~= nil and tEntitySelf.tCurrentSequence.tPendingEvents ~= nil then
      for i, n in ipairs(tEntitySelf.tCurrentSequence.tPendingEvents) do
        Util.KillEvent(n)
      end
      tEntitySelf.tCurrentSequence.tPendingEvents = {}
    end
  elseif sType == "table" then
    if a_vEntity.tCurrentSequence ~= nil and a_vEntity.tCurrentSequence.tPendingEvents ~= nil then
      for i, n in ipairs(a_vEntity.tCurrentSequence.tPendingEvents) do
        Util.KillEvent(n)
      end
      a_vEntity.tCurrentSequence.tPendingEvents = {}
    end
  else
    Util.Assert(false, "ScriptSequence attempting to clear a pending event on something that's not self table or a handle!")
  end
end

function ScriptSequence.RunStrippedCallback(a_EntitySelf, a_tCallbackData, a_sStartingElementName, a_nCurrentElement)
  ScriptSequence._Run(a_EntitySelf, a_sStartingElementName, a_nCurrentElement)
end
