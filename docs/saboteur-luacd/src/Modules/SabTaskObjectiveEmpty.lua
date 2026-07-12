if SabTaskObjectiveEmpty == nil then
  SabTaskObjectiveEmpty = SabTaskObjective:Create()
end

function SabTaskObjectiveEmpty:Activated()
  local tConfig = self:GetConfig()
  if not tConfig.TaskCount then
    tConfig.TaskCount = 1
  end
  SabTaskObjective.Activated(self)
  if tConfig.sToolTipID then
    self:ShowToolTip(tConfig.sToolTipID)
  end
  if tConfig.bCompleteOnActivate then
    EVENT_Timer("SabTaskObjectiveEmpty.CompleteEmptyTask", self, 1)
  end
  if tConfig.sTaskSubType and string.upper(tConfig.sTaskSubType) == "WTFCHANGE" then
    if tConfig.WTFZone then
      Zone.SwitchState(tConfig.WTFZone, cZONESTATE_HIGHWTF, cENT_IMMEDIATE, true, "SabTaskObjectiveEmpty.CompleteEmptyTask", self, {})
    else
      Util.Assert(false, "ERROR: WTFCHANGE task type didnt specify config = WTFZone")
    end
  end
end

function SabTaskObjectiveEmpty:CompleteEmptyTask()
  self:SubObjectiveCompleted()
end

function SabTaskObjectiveEmpty:_CleanEvents()
  self:_CleanGeneralEvents()
  self:_CleanTriggerEvents()
end

function SabTaskObjectiveEmpty:_Cleanup(bForceUnload, bSaveLoad)
  local tConfig = self:GetConfig()
  self:_CleanEvents()
  SabTaskObjective._Cleanup(self, bForceUnload, bSaveLoad)
end
