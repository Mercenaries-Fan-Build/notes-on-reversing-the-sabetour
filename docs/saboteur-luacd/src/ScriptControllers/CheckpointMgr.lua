CheckpointMgr = CheckpointMgr or {}

function CheckpointMgr:OnEnter()
  self.bDebugMode = false
  self.sDebugLabel = "CHECKPOINT"
  self.checkpointID = Checkpoint.New(self.hController)
  Checkpoint.SetCheckZone(self.checkpointID, self.SMEDTable.sZoneName)
  Checkpoint.SetExitZone(self.checkpointID, self.SMEDTable.sExitZone)
  if self.SMEDTable.sRequiredVehicle then
    Checkpoint.SetRequiredVehicle(self.checkpointID, self.SMEDTable.sRequiredVehicle)
  else
    Checkpoint.SetPapers(self.checkpointID, self.SMEDTable.sPapers)
  end
  Checkpoint.SetIgnorePedestrians(self.checkpointID, self.SMEDTable.bIgnorePedestrians or false)
  Checkpoint.SetIgnoreVehicles(self.checkpointID, self.SMEDTable.bIgnoreVehicles or false)
  if self.SMEDTable.sCheckpointLeader then
    Checkpoint.SetPaperChecker(self.checkpointID, self.SMEDTable.sCheckpointLeader)
  end
  if self.SMEDTable.sGateKeeperName then
    Checkpoint.SetDoorman(self.checkpointID, self.SMEDTable.sGateKeeperName)
  end
  if self.SMEDTable.sVehicleCheckerName then
    Checkpoint.SetVehicleChecker(self.checkpointID, self.SMEDTable.sVehicleCheckerName)
  end
  if self.SMEDTable.sLinkedCheckpoint then
    Checkpoint.SetLinkedCheckpoint(self.checkpointID, self.SMEDTable.sLinkedCheckpoint)
  end
  if self.SMEDTable.sLinkedEnterZone then
    Checkpoint.SetLinkedEnterZone(self.checkpointID, self.SMEDTable.sLinkedEnterZone)
  end
  if self.SMEDTable.sLinkedExitZone then
    Checkpoint.SetLinkedExitZone(self.checkpointID, self.SMEDTable.sLinkedExitZone)
  end
  if self.SMEDTable.sInteriorRestrictedArea then
    Checkpoint.SetInteriorRestrictedArea(self.checkpointID, self.SMEDTable.sInteriorRestrictedArea)
    if not self.SMEDTable.sLinkedCheckpoint then
      Checkpoint.SetOneSided(self.checkpointID, true)
    end
  end
  if self.SMEDTable.HaltConv then
    Checkpoint.SetHaltConv(self.checkpointID, self.SMEDTable.HaltConv)
  end
  if self.SMEDTable.PapersPleaseConv then
    Checkpoint.SetPapersPleaseConv(self.checkpointID, self.SMEDTable.PapersPleaseConv)
  end
  if self.SMEDTable.PlayerHasPapersConv then
    Checkpoint.SetPlayerHasPapersConv(self.checkpointID, self.SMEDTable.PlayerHasPapersConv)
  end
  if self.SMEDTable.PlayerDoesNotHavePapersConv then
    Checkpoint.SetPlayerDoesNotHavePapersConv(self.checkpointID, self.SMEDTable.PlayerDoesNotHavePapersConv)
  end
  if self.SMEDTable.PaperCheckPassConv then
    Checkpoint.SetPaperCheckPassConv(self.checkpointID, self.SMEDTable.PaperCheckPassConv)
  end
  if self.SMEDTable.PaperCheckFailConv then
    Checkpoint.SetPaperCheckFailConv(self.checkpointID, self.SMEDTable.PaperCheckFailConv)
  end
  self.m_eEvents = {}
  local tStreamObjects = {}
  if self.SMEDTable.sGateSwitchPt then
    table.insert(tStreamObjects, self.SMEDTable.sGateSwitchPt)
  end
  if 0 < #tStreamObjects then
    self.m_eEvents.eGateEvent = Util.CreateEvent({
      EventType = "StreamEvent",
      Objects = tStreamObjects
    }, "CheckpointMgr.Configure", self)
  end
  if self.SMEDTable.lsSearchlights and 0 < #self.SMEDTable.lsSearchlights then
    self.m_eEvents.eSearchlightEvent = Util.CreateEvent({
      EventType = "StreamEvent",
      Objects = self.SMEDTable.lsSearchlights,
      WaitForGameObject = true
    }, "CheckpointMgr.ConfigureSearchlights", self)
  end
end

function CheckpointMgr:OnExit()
  Checkpoint.Kill(self.checkpointID)
  for i, e in pairs(self.m_eEvents) do
    Util.KillEvent(e)
  end
end

function CheckpointMgr:Configure()
  self.m_eEvents.eGateEvent = nil
  if self.SMEDTable.sGateSwitchPt then
    Checkpoint.SetDoor(self.checkpointID, Util.GetHandleByName(self.SMEDTable.sGateSwitchPt))
  end
end

function CheckpointMgr:ConfigureSearchlights()
  self.m_eEvents.eSearchlightEvent = nil
  if self.SMEDTable and self.SMEDTable.lsSearchlights then
    for i, searchlight in ipairs(self.SMEDTable.lsSearchlights) do
      Checkpoint.AddSearchlight(self.checkpointID, Util.GetHandleByName(searchlight))
    end
  end
end
