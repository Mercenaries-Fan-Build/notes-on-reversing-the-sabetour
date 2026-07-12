if not Soldier then
  Soldier = {}
end

function Soldier:IdleState_Enter()
  Soldier.PrintToConsole(self, "Entering IDLE State")
  if not self.bIsReinforcement then
    if self.bIsSpawned == nil or self.bIsSpawned == false then
      if self.SMEDTable.sPatrolPathName ~= nil and string.upper(self.SMEDTable.sPatrolPathName) ~= "NONE" then
        if self.SMEDTable.sPathConditions == "None" or self.SMEDTable.sPathConditions == "OnSpawn" then
          Soldier.WalkDefaultPath(self)
        end
      elseif self.vOriginalPos then
        local tGoHomeSequence = {
          {
            "WALKTOPOINT",
            {
              self.vOriginalPos.x,
              self.vOriginalPos.y,
              self.vOriginalPos.z
            }
          },
          {
            "SETFACING",
            {
              self.nOriginalFacingDir
            }
          }
        }
        ScriptSequence.Run(self.hController, tGoHomeSequence)
      end
    end
    if self.SMEDTable.sDefaultMachineGun and self.SMEDTable.sDefaultMachineGun ~= "NONE" then
      Actor.BoardVehicle(self.hController, Util.GetHandleByName(self.SMEDTable.sDefaultMachineGun), "PILOT")
    end
  end
  Util.BroadcastFunction(self.hController, "OnSoldierEntersIdle", {})
end

function Soldier:OnSoldierEntersIdle()
  Soldier.PrintToConsole(self, "OnSoldierEntersIdle()")
end

function Soldier:IdleState_Exit()
  Soldier.PrintToConsole(self, "Exiting IDLE State")
  Soldier.KillDefaultPathEvent(self)
end
