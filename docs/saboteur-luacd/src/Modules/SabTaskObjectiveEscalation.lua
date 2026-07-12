if SabTaskObjectiveEscalation == nil then
  SabTaskObjectiveEscalation = SabTaskObjective:Create()
end

function SabTaskObjectiveEscalation:Activated()
  local tConfig = self:GetConfig()
  tConfig.TaskCount = 1
  SabTaskObjective.Activated(self)
  if tConfig.sToolTipID then
    self:ShowToolTip(tConfig.sToolTipID)
  end
  self._EscalationLevel = 0
  if tConfig.EscalationLevel then
    self._EscalationLevel = tConfig.EscalationLevel
  end
  EVENT_Timer("SabTaskObjectiveEscalation.SetupListener", self, 2.5)
end

function SabTaskObjectiveEscalation:SetupListener()
  local tConfig = self:GetConfig()
  local CurrentEscalation = Suspicion.GetEscalation()
  local sType
  if tConfig.bBaseEscalation then
    sType = "OnBaseEscalation" .. self._EscalationLevel
  else
    sType = "OnEscalation" .. self._EscalationLevel
  end
  local bSetListener = true
  local bGreaterThanEq = tConfig.bGTE
  local bLessThanEq = tConfig.bLTE
  if CurrentEscalation then
    if self._EscalationLevel == 0 then
      if CurrentEscalation == 0 then
        bSetListener = false
        self:EscalationComplete()
      end
    elseif self._EscalationLevel == 1 then
      if CurrentEscalation == 1 then
        bSetListener = false
        self:EscalationComplete()
      end
    elseif self._EscalationLevel == 2 then
      if CurrentEscalation == 2 then
        bSetListener = false
        self:EscalationComplete()
      end
    elseif self._EscalationLevel == 3 then
      if CurrentEscalation == 3 then
        bSetListener = false
        self:EscalationComplete()
      end
    elseif self._EscalationLevel == 4 then
      if CurrentEscalation == 4 then
        bSetListener = false
        self:EscalationComplete()
      end
    elseif self._EscalationLevel == 5 and CurrentEscalation == 5 then
      bSetListener = false
      self:EscalationComplete()
    end
    if bGreaterThanEq and CurrentEscalation > self._EscalationLevel then
      bSetListener = false
      self:EscalationComplete()
    end
    if bLessThanEq and CurrentEscalation < self._EscalationLevel then
      bSetListener = false
      self:EscalationComplete()
    end
    if bSetListener then
      local sEscalation
      if tConfig.bBaseEscalation then
        sEscalation = "OnBaseEscalation"
      else
        sEscalation = "OnEscalation"
      end
      if bGreaterThanEq and self._EscalationLevel <= 5 then
        local ThisLevel = self._EscalationLevel
        while ThisLevel <= 5 do
          local sThisType = sEscalation .. ThisLevel
          self:EscalationListener(sThisType)
          ThisLevel = ThisLevel + 1
        end
      elseif bLessThanEq and self._EscalationLevel >= 0 then
        local ThisLevel = self._EscalationLevel
        while 0 <= ThisLevel do
          local sThisType = sEscalation .. ThisLevel
          self:EscalationListener(sThisType)
          ThisLevel = ThisLevel - 1
        end
      else
        self:EscalationListener(sType)
      end
    end
  else
    print("ERROR:: No escalation level found in SabTaskObjectiveEscalation.SetupListener")
  end
end

function SabTaskObjectiveEscalation:EscalationListener(Level)
  self:RegisterEvent(Util.CreateEvent({EventType = Level, Target = hSab}, "SabTaskObjectiveEscalation.EscalationComplete", self))
end

function SabTaskObjectiveEscalation:EscalationComplete()
  if self:IsActive() and Object.IsAlive(hSab) then
    print("DEBUG:: Escalation Complete")
    self:SubObjectiveCompleted()
  elseif not Object.IsAlive(hSab) then
    print("SabTaskObjectiveEscalation.EscalationComplete:: failed to complete because the player is dead")
  end
end

function SabTaskObjectiveEscalation:_CleanEvents()
  self:_CleanGeneralEvents()
  self:_CleanTriggerEvents()
end

function SabTaskObjectiveEscalation:_Cleanup(bForceUnload, bSaveLoad)
  local tConfig = self:GetConfig()
  self:_CleanEvents()
  SabTaskObjective._Cleanup(self, bForceUnload, bSaveLoad)
end
