if not Joe then
  Joe = {}
end

function Joe.AssertWith(a_sAssertString)
  Util.Assert(false, a_sAssertString)
end

function Joe.CheckObjectList(a_tObjects)
  local sType = type(a_tObjects)
  if sType == "string" then
    local hObject = Util.GetHandleByName(a_tObjects)
    if hObject ~= nil then
      return true
    else
      return false
    end
  end
  if sType == "table" then
    for i = 1, #a_tObjects do
      local hObject = Util.GetHandleByName(a_tObjects[i])
      if hObject ~= nil then
        local bObjectIsValid = true
        table.insert(tOutputTable, bObjectIsValid)
      else
        Joe.AssertWith("An object in the list is invalid.")
        local bObjectIsValid = false
        table.insert(tOutputTable, bObjectIsValid)
      end
    end
    if #tOutputTable == #a_tObjects then
      return tOutputTable
    end
  end
end

function Joe.MakeSabFollower(a_hActorHandle, b_IsCombat, a_Radius, a_MoveMode, s_SquadName)
  local hActor = a_hActorHandle
  local bIsCombat = b_IsCombat or false
  local fRadius = a_Radius or 3
  local cMoveType = a_MoveMode or cMOVE_FAST
  local sSquadName = s_SquadName or "TEMPSQUAD"
  Actor.SetAutoSeatTransition(hActor, false)
  if bIsCombat == false then
    Nav.FollowObject(hActor, hSab, fRadius, cMoveType, true, false)
  elseif bIsCombat == true then
    Squad.Create(sSquadName)
    Squad.AddMember(sSquadName, hSab)
    Squad.AddMember(sSquadName, hActor)
    Squad.SetLeader(sSquadName, hSab)
    Squad.SetRadius(sSquadName, fRadius)
    Squad.FollowLeader(sSquadName)
    Squad.SetEnemy(sSquadName, "GenericNazi", false)
  end
end

function Joe.ClearSabFollower(a_hActorHandle, b_IsCombat, s_SquadName)
  local hActor = a_hActorHandle
  local bIsCombat = b_IsCombat or false
  local sSquadName = s_SquadName or "TEMPSQUAD"
  if bIsCombat == false then
    Nav.CancelFollowObject(hActor)
  elseif bIsCombat == true then
    Squad.ClearBehavior(sSquadName)
    Squad.ClearLeader(sSquadName)
    Squad.RemoveMember(sSquadName, hActor)
    Squad.RemoveMember(sSquadName, hSab)
    Squad.Delete(sSquadName)
  end
end

function Joe.IsCurrentMission(s_Mission)
  if IsMissionActive(s_Mission) then
    return true
  else
    return false
  end
end

function Joe.GoHail(a_hEntity, a_nHeading)
  Actor.PlayAnimation(a_hEntity, "nazi_hail", 3.7, false, a_nHeading)
end

function Joe.SetFireAtTarget(a_hActor, a_hTarget, nDuration)
  local hActor = a_hActor
  local hTarget = a_hTarget
  local nDur = nDuration or 60
  Combat.SetBroadcastWeaponFire(hActor, false)
  Combat.SetBroadcastEnteredCombat(hActor, false)
  Combat.SetReactImmediately(hActor, false)
  Combat.LockIntoRanged(hActor)
  Combat.SetTarget(hActor, hTarget)
  Combat.SetAlwaysSeeTarget(hActor, true)
  Combat.SetStationary(hActor, true)
  Combat.SetCombat(hActor)
  Actor.FireCurrentWeapon(hActor, nDuration)
end

function Joe.SpawnExplosiononObject(a_sObject, a_nTimer, a_sExplosionBP)
  local hObject = Handle(a_sObject)
  local nTimer = a_nTimer or 0.1
  local sExplosionBP = a_sExplosionBP or "Explosion_SAB_DynamiteFuse"
  local x, y, z = Object.GetPosition(hObject)
  Util.CreateExplosion(sExplosionBP, x, y, z)
end

function Joe.SetFireGroupAtTarget(a_tActors, a_hTarget, a_nDuration)
  local tActors = a_tActors
  local hTarget = a_hTarget
  local nDur = a_nDuration or 60
  for i = 1, #tActors do
    local hActor = Handle(tActors[i])
    Actor.SetIdleScripted(hActor, true)
    Combat.SetBroadcastWeaponFire(hActor, false)
    Combat.SetBroadcastEnteredCombat(hActor, false)
    Combat.SetReactImmediately(hActor, false)
    Combat.LockIntoRanged(hActor)
    Combat.SetTarget(hActor, hTarget)
    Combat.SetAlwaysSeeTarget(hActor, true)
    Combat.SetStationary(hActor, true)
    Combat.SetCombat(hActor)
    Actor.FireCurrentWeapon(hActor, nDur)
  end
end

function Joe.SetFireGroupAtGroupTarget(a_tActors, a_tTargets, nDuration)
  local tActors = a_tActors
  local tTargets = a_tTargets
  local nDur = nDuration or 60
  for i = 1, #tActors do
    local hActor = Handle(tActors[i])
    local j = math.random(1, #tTargets)
    local hTarget = Handle(tTargets[j])
    Combat.SetReactImmediately(hActor, false)
    Combat.LockIntoRanged(hActor)
    Combat.SetTarget(hActor, hTarget)
    Combat.SetAlwaysSeeTarget(hActor, true)
    Combat.SetStationary(hActor, true)
    Combat.SetCombat(hActor)
    Actor.FireCurrentWeapon(hActor, nDur)
  end
end

function Joe.SetFireGroupAtGroup(a_tActors, s_Squad1, a_tTargets, s_Squad2, b_Ranged)
  local tActors = a_tActors
  local tTargets = a_tTargets
  local sSquad1 = s_Squad1 or "Actors"
  local sSquad2 = s_Squad2 or "Targets"
  local bRanged = b_Ranged or true
  for i = 1, #tActors do
    local hActor = Handle(tActors[i])
    Combat.SetCombat(hActor)
    if bRanged == true then
      Combat.LockIntoRanged(hActor)
      Combat.SetStationary(hActor, true)
      Combat.SetAlwaysSeeTarget(hActor, true)
    end
  end
  for j = 1, #tTargets do
    local hTarget = Handle(tTargets[j])
    Combat.SetCombat(hTarget)
    if bRanged == true then
      Combat.LockIntoRanged(hTarget)
      Combat.SetStationary(hTarget, true)
      Combat.SetAlwaysSeeTarget(hTarget, true)
    end
  end
end

function Joe:SetActorAdjustOnDeath(tActors, tTargets)
  Render.PrintMessage("Actor Has Died")
  local tActorHandles = {}
  local tTargetHandles = {}
  for i = 1, #tActors do
    local hAliveActor = Handle(tActors[i])
    if Object.IsAlive(hAliveActor) == true then
      table.insert(tActorHandles, hAliveActor)
    else
    end
  end
  for j = 1, #tTargetHandles do
    local hAliveTarget = Handle(tTargets[j])
    if Object.IsAlive(hAliveTarget) == true then
      table.insert(tTargetHandles, hAliveTarget)
    else
    end
  end
  if 1 < #tActorHandles and 1 < #tTargetHandles then
    Render.PrintMessage("Combatants are Still Alive")
  elseif 1 < #tActorHandles and #tTargetHandles == 0 then
    Render.PrintMessage("Actors are Still Alive")
  elseif 1 < #tTargetHandles and #tActorHandles == 0 then
    Render.PrintMessage("Targets are Still Alive")
  end
end

function Joe.CeaseFire(a_tActors)
  local tActors = a_tActors
end

function Joe.SetEnemyOfTheState(a_hActor, a_sSquad)
  local hEoS = a_hActor
  local sSquadName = a_sSquad
  Squad.Create(a_sSquad)
  Squad.AddMember(a_sSquad, hEoS)
  Squad.SetEnemy(a_sSquad, "GenericNazi", true)
  Combat.SetCombat(hEoS)
end
