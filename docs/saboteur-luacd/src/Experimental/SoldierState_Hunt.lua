if not Soldier then
  Soldier = {}
end

function Soldier:HuntState_Enter(a_tArgs)
  Soldier.PrintToConsole(self, "Entering HUNT State")
  local bInvestigateFirst = true
  if a_tArgs ~= nil and a_tArgs.bInvestigateFirst ~= nil then
    bInvestigateFirst = a_tArgs.bInvestigateFirst
  end
  if a_tArgs ~= nil then
    if a_tArgs.hTarget ~= nil then
      Combat.SetHunt(self.hController, a_tArgs.hTarget, true, false)
    elseif a_tArgs.vHuntLocation ~= nil then
      Combat.SetHunt(self.hController, a_tArgs.vHuntLocation.x, a_tArgs.vHuntLocation.y, a_tArgs.vHuntLocation.z, true, false, nil, nil, nil, bInvestigateFirst)
    else
      Combat.SetHunt(self.hController, Util.GetHandleByName("Saboteur"), true, false)
    end
  else
    Combat.SetHunt(self.hController, Util.GetHandleByName("Saboteur"), true, false)
  end
end

function Soldier.HuntTarget(a_vSoldier, a_vTarget)
  local hSoldier = Tips.CheckForHandle(a_vSoldier)
  local tSoldierSelf = Actor.GetSelf(hSoldier)
  local tArgs = {}
  tArgs.hTarget = Tips.CheckForHandle(a_vTarget)
  Soldier.EnterState(tSoldierSelf, cSTATE_HUNT, tArgs)
  Suspicion.SetState(hSoldier, "Orange")
end

function Soldier.HuntLocation(a_vSoldier, a_x, a_y, a_z, a_bInvestigateFirst)
  local hSoldier = Tips.CheckForHandle(a_vSoldier)
  local tSoldierSelf = Actor.GetSelf(hSoldier)
  local tArgs = {}
  tArgs.vHuntLocation = {}
  tArgs.vHuntLocation.x = a_x
  tArgs.vHuntLocation.y = a_y
  tArgs.vHuntLocation.z = a_z
  tArgs.bInvestigateFirst = a_bInvestigateFirst
  Soldier.EnterState(tSoldierSelf, cSTATE_HUNT, tArgs)
  Suspicion.SetState(hSoldier, "Orange")
end

function Soldier:HuntState_Exit()
  Soldier.PrintToConsole(self, "Exiting HUNT State")
  Combat.Exit(self.hController)
end
