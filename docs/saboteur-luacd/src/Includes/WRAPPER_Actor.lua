require("Includes\\WRAPPER_Util")

function ACTOR_WalkToObject(a_vCharacter, a_vTarget)
  local hCharacter = WRAPPER_CheckForHandle(a_vCharacter)
  local hTarget = WRAPPER_CheckForHandle(a_vTarget)
  WRAPPER_SanityCheck(hCharacter, "Invalid character name/handle passed to ACTOR_WalkToObject!")
  WRAPPER_SanityCheck(hTarget, "Invalid target name/handle passed to ACTOR_WalkToObject!")
  Nav.MoveToObject(hCharacter, hTarget, 0.5, false)
end

function ACTOR_RunToObject(a_vCharacter, a_vTarget)
  local hCharacter = WRAPPER_CheckForHandle(a_vCharacter)
  local hTarget = WRAPPER_CheckForHandle(a_vTarget)
  WRAPPER_SanityCheck(hCharacter, "Invalid character name/handle passed to ACTOR_RunToObject!")
  WRAPPER_SanityCheck(hTarget, "Invalid target name/handle passed to ACTOR_RunToObject!")
  Nav.MoveToObject(hCharacter, hTarget, 0.5, true)
end

function ACTOR_WalkToPoint(a_vCharacter, a_x, a_y, a_z)
  local hCharacter = WRAPPER_CheckForHandle(a_vCharacter)
  WRAPPER_SanityCheck(hCharacter, "Invalid character name/handle passed to ACTOR_WalkToPoint!")
  Nav.MoveToPoint(hCharacter, a_x, a_y, a_z, false)
end

function ACTOR_RunToPoint(a_vCharacter, a_x, a_y, a_z)
  local hCharacter = WRAPPER_CheckForHandle(a_vCharacter)
  WRAPPER_SanityCheck(hCharacter, "Invalid character name/handle passed to ACTOR_RunToPoint!")
  Nav.MoveToPoint(hCharacter, a_x, a_y, a_z, true)
end

function ACTOR_FaceObject(a_vCharacter, a_vTarget)
  local hCharacter = WRAPPER_CheckForHandle(a_vCharacter)
  local hTarget = WRAPPER_CheckForHandle(a_vCharacter)
  WRAPPER_SanityCheck(hCharacter, "Invalid character name/handle passed to ACTOR_FaceObject!")
  WRAPPER_SanityCheck(hTarget, "Invalid target name/handle passed to ACTOR_FaceObject!")
  Actor.SetFacingDir(hCharacter, hTarget)
end

function ACTOR_FaceDirection(a_vCharacter, a_nDirection)
  local hCharacter = WRAPPER_CheckForHandle(a_vCharacter)
  WRAPPER_SanityCheck(hCharacter, "Invalid character name/handle passed to ACTOR_FaceDirection!")
  WRAPPER_SanityCheck(a_nDirection, "Invalid facing direction passed to ACTOR_FaceDirection!")
  Actor.SetFacingDir(hCharacter, a_nDirection)
end

function ACTOR_FollowObject(a_vCharacter, a_vTarget, a_nDistance, a_bRun)
  local hCharacter = WRAPPER_CheckForHandle(a_vCharacter)
  local hTarget = WRAPPER_CheckForHandle(a_vTarget)
  WRAPPER_SanityCheck(hCharacter, "Invalid character name/handle passed to ACTOR_FollowObject!")
  WRAPPER_SanityCheck(hTarget, "Invalid target name/handle passed to ACTOR_FollowObject!")
  local nDefaultDist = 2.5
  local bDefaultRun = true
  if a_nDistance ~= nil then
    nDefaultDist = a_nDistance
  end
  if a_bRun ~= nil then
    bDefaultRun = a_bRun
  end
  Nav.FollowObject(hCharacter, hTarget, nDefaultDist, bDefaultRun)
end

function ACTOR_WalkPathOnce(a_vCharacter, a_sPathName)
  local hCharacter = WRAPPER_CheckForHandle(a_vCharacter)
  WRAPPER_SanityCheck(hCharacter, "Invalid character name/handle passed to ACTOR_WalkPathOnce!")
  Nav.SetScriptedPath(hCharacter, a_sPathName, true)
  Nav.SetScriptedPathMoveMode(hCharacter, false)
  Nav.SetScriptedPathType(hCharacter, cPATHTYPE_ONCE)
end

function ACTOR_RunPathOnce(a_vCharacter, a_sPathName)
  local hCharacter = WRAPPER_CheckForHandle(a_vCharacter)
  WRAPPER_SanityCheck(hCharacter, "Invalid character name/handle passed to ACTOR_RunPathOnce!")
  Nav.SetScriptedPath(hCharacter, a_sPathName, true)
  Nav.SetScriptedPathMoveMode(hCharacter, true)
  Nav.SetScriptedPathType(hCharacter, cPATHTYPE_ONCE)
end

function ACTOR_WalkPathLoop(a_vCharacter, a_sPathName)
  local hCharacter = WRAPPER_CheckForHandle(a_vCharacter)
  WRAPPER_SanityCheck(hCharacter, "Invalid character name/handle passed to ACTOR_WalkPathLoop!")
  Nav.SetScriptedPath(hCharacter, a_sPathName, true)
  Nav.SetScriptedPathMoveMode(hCharacter, false)
  Nav.SetScriptedPathType(hCharacter, cPATHTYPE_LOOP)
end

function ACTOR_RunPathLoop(a_vCharacter, a_sPathName)
  local hCharacter = WRAPPER_CheckForHandle(a_vCharacter)
  WRAPPER_SanityCheck(hCharacter, "Invalid character name/handle passed to ACTOR_RunPathLoop!")
  Nav.SetScriptedPath(hCharacter, a_sPathName, true)
  Nav.SetScriptedPathMoveMode(hCharacter, true)
  Nav.SetScriptedPathType(hCharacter, cPATHTYPE_LOOP)
end

function ACTOR_WalkPathBounce(a_vCharacter, a_sPathname)
  local hCharacter = WRAPPER_CheckForHandle(a_vCharacter)
  WRAPPER_SanityCheck(hCharacter, "Invalid character name/handle passed to ACTOR_WalkPathBounce!")
  Nav.SetScriptedPath(hCharacter, a_sPathName, true)
  Nav.SetScriptedPathMoveMode(hCharacter, false)
  Nav.SetScriptedPathType(hCharacter, cPATHTYPE_BOUNCE)
end

function ACTOR_RunPathBounce(a_vCharacter, a_sPathName)
  local hCharacter = WRAPPER_CheckForHandle(a_vCharacter)
  WRAPPER_SanityCheck(hCharacter, "Invalid character name/handle passed to ACTOR_RunPathBounce!")
  Nav.SetScriptedPath(hCharacter, a_sPathName, true)
  Nav.SetScriptedPathMoveMode(hCharacter, true)
  Nav.SetScriptedPathType(hCharacter, cPATHTYPE_BOUNCE)
end

function ACTOR_WalkPathRandom(a_vCharacter, a_sPathName)
  local hCharacter = WRAPPER_CheckForHandle(a_vCharacter)
  WRAPPER_SanityCheck(hCharacter, "Invalid character name/handle passed to ACTOR_WalkPathRandom!")
  Nav.SetScriptedPath(hCharacter, a_sPathName, true)
  Nav.SetScriptedPathMoveMode(hCharacter, false)
  Nav.SetScriptedPathType(hCharacter, cPATHTYPE_RANDOM)
end

function ACTOR_RunPathRandom(a_vCharacter, a_sPathName)
  local hCharacter = WRAPPER_CheckForHandle(a_vCharacter)
  WRAPPER_SanityCheck(hCharacter, "Invalid character name/handle passed to ACTOR_RunPathRandom!")
  Nav.SetScriptedPath(hCharacter, a_sPathName, true)
  Nav.SetScriptedPathMoveMode(hCharacter, true)
  Nav.SetScriptedPathType(hCharacter, cPATHTYPE_RANDOM)
end

function ACTOR_AttackTarget(a_vCharacter, a_vTarget)
  local hCharacter = WRAPPER_CheckForHandle(a_vCharacter)
  local hTarget = WRAPPER_CheckForHandle(a_vTarget)
  WRAPPER_SanityCheck(hCharacter, "Invalid character name/handle passed to ACTOR_AttackTarget!")
  WRAPPER_SanityCheck(hTarget, "Invalid target name/handle passed to ACTOR_AttackTarget!")
  Combat.SetTarget(hCharacter, hTarget)
  Combat.SetCombat(hCharacter)
end

function ACTOR_AttackPlayer(a_vCharacter)
  local hCharacter = WRAPPER_CheckForHandle(a_vCharacter)
  local hTarget = Util.GetHandleByName("Saboteur")
  WRAPPER_SanityCheck(hCharacter, "Invalid character name/handle passed to ACTOR_AttackTarget!")
  WRAPPER_SanityCheck(hTarget, "Invalid target name/handle passed to ACTOR_AttackTarget!")
  Combat.SetTarget(hCharacter, hTarget)
  Combat.SetCombat(hCharacter)
end

function ACTOR_ConfrontPlayer(a_vCharacter, a_sRequiredPapers)
  local hCharacter = WRAPPER_CheckForHandle(a_vCharacter)
  WRAPPER_SanityCheck(hCharacter, "Invalid character name/handle passed to ACTOR_ConfrontPlayer!")
  Util.BroadcastFunction(hCharacter, "ConfrontTarget", {
    Util.GetHandleByName("Saboteur"),
    a_sRequiredPapers
  })
end

function ACTOR_UseAttrPt(a_vCharacter, a_vAttrPt)
  local hCharacter = WRAPPER_CheckForHandle(a_vCharacter)
  local hAttrPt = WRAPPER_CheckForHandle(a_vAttrPt)
  WRAPPER_SanityCheck(hCharacter, "Invalid character name/handle passed to ACTOR_UseAttrPt!")
  WRAPPER_SanityCheck(hAttrPt, "Invalid attraction point name/handle passed to ACTOR_UseAttrPt!")
  Actor.UseAttrPt(hCharacter, hAttrPt)
end

function ACTOR_CancelAttrPt(a_vCharacter)
  local hCharacter = WRAPPER_CheckForHandle(a_vCharacter)
  WRAPPER_SanityCheck(hCharacter, "Invalid character name/handle passed to ACTOR_CancelAttrPt!")
  Actor.CancelAttrPt(hCharacter)
end

function ACTOR_BoardVehicle(a_vCharacter, a_vVehicle, a_sSeatName, a_bRun)
  local hVehicle = WRAPPER_CheckForHandle(a_vVehicle)
  local hCharacter = WRAPPER_CheckForHandle(a_vCharacter)
  WRAPPER_SanityCheck(hVehicle, "Invalid vehicle name/handle passed to ACTOR_BoardVehicleDriverSeat!")
  WRAPPER_SanityCheck(hCharacter, "Invalid character name/handle passed to ACTOR_BoardVehicleDriverSeat!")
  local nBoardPosX, nBoardPosY, nBoardPosZ = Vehicle.GetBoardingPosition(hVehicle, a_sSeatName)
  local sRunType = "WALKTOPOINT"
  if a_bRun ~= nil and a_bRun == true then
    sRunType = "RUNTOPOINT"
  end
  local tVehicleSequence = {
    {
      sRunType,
      {
        nBoardPosX,
        nBoardPosY,
        nBoardPosZ
      }
    },
    {
      "ENTERSEAT",
      {hVehicle, a_sSeatName}
    }
  }
  ScriptSequence.Run(hCharacter, tVehicleSequence)
end

function ACTOR_BoardVehiclePassengerSeat(a_vCharacter, a_vVehicle, a_bRun)
  local hVehicle = WRAPPER_CheckForHandle(a_vVehicle)
  local hCharacter = WRAPPER_CheckForHandle(a_vCharacter)
  WRAPPER_SanityCheck(hVehicle, "Invalid vehicle name/handle passed to ACTOR_BoardVehiclePassengerSeat!")
  WRAPPER_SanityCheck(hCharacter, "Invalid character name/handle passed to ACTOR_BoardVehiclePassengerSeat!")
  local nBoardPosX, nBoardPosY, nBoardPosZ = Vehicle.GetBoardingPosition(hVehicle, cSEAT_SHOTGUN)
  local sRunType = "WALKTOPOINT"
  if a_bRun ~= nil and a_bRun == true then
    sRunType = "RUNTOPOINT"
  end
  local tVehicleSequence = {
    {
      sRunType,
      {
        nBoardPosX,
        nBoardPosY,
        nBoardPosZ
      }
    },
    {
      "ENTERSEAT",
      {hVehicle}
    }
  }
  ScriptSequence.Run(hCharacter, tVehicleSequence)
end

function ACTOR_UnboardVehicle(a_vCharacter)
  local hCharacter = WRAPPER_CheckForHandle(a_vCharacter)
  WRAPPER_SanityCheck(hCharacter, "Invalid character name/handle passed to ACTOR_BoardVehiclePassengerSeat!")
  Actor.UnboardVehicle(hCharacter)
end

function ACTOR_SpawnAtRandomLocatorAndAttack(a_sBlueprintName, a_tLocatorList, a_vTarget)
  local hTarget = WRAPPER_CheckForHandle(a_vTarget)
  Object.SpawnFromList(a_sBlueprintName, 1, a_tLocatorList, false, nil, "_ACTOR_SpawnAtRandomLocatorAndAttack", nil, {hTarget})
end

function _ACTOR_SpawnAtRandomLocatorAndAttack(self, a_tSpawnInfo, a_hTarget)
  local hCharacter = a_tSpawnInfo[1]
  ACTOR_AttackTarget(hCharacter, a_hTarget)
end

function ACTOR_SpawnAtLocatorAndAttack(a_sBlueprintName, a_vLocator, a_vTarget)
  local hSpawnLocation = WRAPPER_CheckForHandle(a_vLocator)
  local hTarget = WRAPPER_CheckForHandle(a_vTarget)
  local x, y, z = Object.GetPosition(hSpawnLocation)
  local nRotation = Actor.GetFacingDir(hSpawnLocation)
  Object.Spawn(a_sBlueprintName, x, y, z, nRotation, nil, "_ACTOR_SpawnAtLocatorAndAttack", nil, {hTarget}, false)
end

function _ACTOR_SpawnAtLocatorAndAttack(self, a_tSpawnInfo, a_hTarget)
  local hCharacter = a_tSpawnInfo[1]
  ACTOR_AttackTarget(hCharacter, a_hTarget)
end

function ACTOR_SpawnAtLocator(a_sBlueprintName, a_vLocator, a_tSelf, a_sCallback, a_tCallbackParams)
  local hSpawnLocation = WRAPPER_CheckForHandle(a_vLocator)
  local x, y, z = Object.GetPosition(hSpawnLocation)
  local nRotation = Object.GetFacingDir(hSpawnLocation)
  Object.Spawn(a_sBlueprintName, x, y, z, nRotation, nil, a_sCallback, a_tSelf, a_tCallbackParams)
end
