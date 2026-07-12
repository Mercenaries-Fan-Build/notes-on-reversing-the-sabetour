if SabTaskObjectiveDestroy == nil then
  SabTaskObjectiveDestroy = {}
  if SabTaskObjective == nil then
    require("Includes\\__SabMissionIncludes")
  end
  SabTaskObjectiveDestroy = SabTaskObjective:Create()
end

function SabTaskObjectiveDestroy:Activated()
  SabTaskObjective.Activated(self)
  local tConfig = self:GetConfig()
  if tConfig.sToolTipID then
    self:ShowToolTip(tConfig.sToolTipID)
  end
  if tConfig.sTaskSubType then
    if string.upper(tConfig.sTaskSubType) == "DEFEND" then
      self:SetupDefendEvents()
    elseif string.upper(tConfig.sTaskSubType) == "KILL" then
      self:SetupDeathEvents()
    elseif string.upper(tConfig.sTaskSubType) == "DESTROY" then
      self:SetupDeathEvents()
    elseif string.upper(tConfig.sTaskSubType) == "SABOTAGE" then
      self:SetupSabotageEvents()
    else
      self:SetupDeathEvents()
    end
  else
    print("WARNING:: no sTaskSubType given for :", self:GetName())
    self:SetupDeathEvents()
  end
end

function SabTaskObjectiveDestroy:SetupDeathEvents()
  local tConfig = self:GetConfig()
  for _, Value in ipairs(tConfig.tTgtInclude) do
    local tTable = {Name = Value}
    local hObject = WRAPPER_CheckForHandle(Value)
    EVENT_ActorDeath("SabTaskObjectiveDestroy.CallbackTargetDestroyed", self, hObject, {hObject, Value})
    if tConfig.tOnDamage then
      self:SetupOnDamageEvent(Value)
    end
  end
end

function SabTaskObjectiveDestroy:SetupOnDamageEvent(Value)
  local eEvent = Util.CreateEvent({
    EventType = "DamageEvent",
    ObjectName = Value
  }, "SabTaskObjectiveDestroy.OnDamageEventCallback", self, {Value}, true)
  self:RegisterEvent(eEvent)
end

function SabTaskObjectiveDestroy:OnDamageEventCallback(Value, blah)
  local tConfig = self:GetConfig()
  if tConfig.tOnDamage then
    local tCallbacks = tConfig.tOnDamage
    tCallbacks = tCallbacks or {}
    for _, tCallback in ipairs(tCallbacks) do
      __UtilFunctions.CallWithOptionalArgs(tCallback[1], tCallback[2])
    end
  end
end

function SabTaskObjectiveDestroy:SetupDefendEvents()
  local tConfig = self:GetConfig()
  for _, Value in ipairs(tConfig.tTgtInclude) do
    local tTable = {Name = Value}
    local hHandle = WRAPPER_CheckForHandle(Value)
    if tConfig.bProgressBar then
      HUD.SetupProgressBar(self:GetTaskObjectiveID(), hHandle)
    end
    if tConfig.tOnDamage then
      self:SetupOnDamageEvent(Value)
    end
    EVENT_ActorDeath("SabTaskObjectiveDestroy.CallbackDefendTargetLost", self, hHandle, Value)
  end
  if tConfig.VictoryTimer and tConfig.VictoryTimer > 0 then
    self:SetVictoryTimer()
  else
  end
end

function SabTaskObjectiveDestroy:SetupSabotageEvents()
  local tConfig = self:GetConfig()
  print("DEBUG:: in setup sabotage events")
  for _, Value in ipairs(tConfig.tTgtInclude) do
    local hHandle = WRAPPER_CheckForHandle(Value)
    self:SetupUsePt(hHandle)
  end
end

function SabTaskObjectiveDestroy:CallbackTargetDestroyed(Value, sStringValue)
  if self ~= nil and Value ~= nil then
    local tConfig = self:GetConfig()
    SabTaskObjective.SetUIBlips(self, Value, false)
    SabTaskObjective.SubObjectiveCompleted(self)
    if tConfig.bDestroyOneBlipAll then
      tConfig.bNoHUDBlip = false
      if tConfig.tTgtInclude then
        for _, v in pairs(tConfig.tTgtInclude) do
          if Value ~= v then
            self:SetUIBlips(v, true)
          end
        end
      end
      tConfig.bDestroyOneBlipAll = false
    end
  else
    print("WARNING: FREEDOM BROKE IT AGAIN!: SabTaskObjectiveDestroy.CallbackTargetDestroyed")
  end
end

function SabTaskObjectiveDestroy:CallbackDefendTargetLost(Value)
  local tConfig = self:GetConfig()
  local tCallbacks = tConfig.tOnFailure
  if not self.bVictoryTimerSuccess then
    if type(tCallbacks) == "table" then
      for _, tCallback in ipairs(tCallbacks) do
        __UtilFunctions.CallWithOptionalArgs(tCallback[1], tCallback[2])
      end
    end
    HUD.RemoveTimer()
    if tConfig.bFailMissionOnFail then
      local parent = self:GetParent()
      parent:Cancel()
    end
  end
end

function SabTaskObjectiveDestroy:_CleanEvents()
  self:_CleanGeneralEvents()
  self:_CleanTriggerEvents()
  self:_CleanVehicleDeaths()
end

function SabTaskObjectiveDestroy:_Cleanup(bForceUnload, bSaveLoad)
  local tConfig = self:GetConfig()
  self:_CleanEvents()
  SabTaskObjective._Cleanup(self, bForceUnload, bSaveLoad)
end
