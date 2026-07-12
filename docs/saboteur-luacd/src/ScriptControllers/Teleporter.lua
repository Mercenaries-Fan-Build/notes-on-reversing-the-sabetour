if not Teleporter then
  Teleporter = {}
end

function Teleporter:OnEnter()
  self.t_AllEvents = {}
  table.insert(self.t_AllEvents, Util.CreateEvent({
    EventType = "StreamEvent",
    Objects = Teleporter.BuildStreamEventTable(self)
  }, "Teleporter.SetupUsePoint", self))
end

function Teleporter:OnExit()
  Teleporter.CleanUp(self)
end

function Teleporter:BuildStreamEventTable()
  local tCollectedStreamEvents = {}
  if self.SMEDTable.sATPT then
    table.insert(tCollectedStreamEvents, self.SMEDTable.sATPT)
  end
  return tCollectedStreamEvents
end

function Teleporter:SetupUsePoint()
  local hSwitch = Handle(self.SMEDTable.sATPT)
  table.insert(self.t_AllEvents, Util.CreateEvent({
    EventType = "OnActorComplete",
    Target = hSwitch
  }, "Teleporter.TeleportToLocation", self, {nil}, true))
end

function Teleporter:TeleportToLocation()
  local x, y, z, rot
  x = self.SMEDTable.xlocation
  y = self.SMEDTable.ylocation
  z = self.SMEDTable.zlocation
  rot = self.SMEDTable.rot
  Object.PlayerTeleportToPos(x, y, z, rot, true, "Teleporter.CleanUp", self)
  if self.SMEDTable.bCatacombMap ~= nil and self.SMEDTable.bCatacombMap == true then
    HUD.SetPauseMenuPos(-684.3644, 55.297977, 607.72186)
  end
  if self.SMEDTable.bResetMap ~= nil and self.SMEDTable.bResetMap == true then
    HUD.ClearPauseMenuPos()
  end
end

function Teleporter:CleanUp()
  if self.t_AllEvents then
    for i, v in pairs(self.t_AllEvents) do
      if v then
        Util.KillEvent(v)
      end
    end
  end
end
