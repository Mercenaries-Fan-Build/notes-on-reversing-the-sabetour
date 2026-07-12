if SabTaskObjective == nil then
  if SabTask == nil then
    require("Includes\\__SabMissionIncludes")
  end
  SabTaskObjective = SabTask:Create()
end

function SabTaskObjective:Activated()
  self._tEvents = {}
  self._tTriggerWaitFors = {}
  self._tVehicleDeaths = {}
  self.tHUDText = {}
  self._CompletedCount = 0
  self.tInfo = {}
  self.tSaveInfo = {}
  self._TaskQuota = 0
  self._Total = 0
  self.bAutoComplete = true
  self.bTaskFailed = false
  self.bTaskComplete = false
  self._tMarkerOldHideState = -1
  self._tFocusPts = {}
  self._tMarkers = {}
  self._tGroundMarkers = {}
  local tConfig = self:GetConfig()
  if self:GetMissionFail() then
    Util.Assert(false, "This mission is in a fail state, not continuing ", self:GetName())
    print("This mission is in a fail state, not continuing")
    return
  end
  if not tConfig.sObjectiveTextID or not tConfig.ParentObjectID then
  end
  if tConfig.bUnloadNodes then
    self.bUnloadNodes = true
  end
  self:SetAIUIBlips(true)
  self:FindTaskQuota()
  self:HUDAudioCheck()
  self:_SetupGPS()
  self:_SetupTimers()
  self:_SetupEscalationCallback()
  SabTask.Activated(self)
  if self._bGameplayTask then
    self._bBonusAchieved = false
    self._DT = 0
    self:SetupHeartbeat()
  end
end

function SabTaskObjective:SetupHeartbeat()
  local oActionPackageConfig = self:GetActionPackage():GetConfig()
  if not oActionPackageConfig.bWorldEvent then
  end
end

function SabTaskObjective:Update(DT)
  self._DT = self._DT + DT[1]
  if self._DT > 0.33 then
    if self.HeartBeat then
      self:HeartBeat(DT[1])
    end
    self._DT = 0
  end
end

function SabTaskObjective:_Cleanup(bForceUnload, bSaveLoad)
  local tConfig = self:GetConfig()
  self:_CleanGeneralEvents()
  self:_CleanVehicleDeaths()
  if self.tAttrPts then
    for _, hAttrPt in pairs(self.tAttrPts) do
      self:CleanUpUsePt(hAttrPt)
    end
  end
  if not _g_b_ImInChargeOfObjectiveVisiblity then
    HUD.KeepObjectivesVisible(false)
  end
  if self._tGroundMarkers then
    for _, hGroundBlip in pairs(self._tGroundMarkers) do
      HUD.RemoveGroundDecal(Handle(hGroundBlip))
    end
    self._tGroundMarkers = {}
  end
  self:_CleanTriggerEvents()
  if self.tInfo then
    self:CleanTable(self.tInfo)
  end
  if self.tSaveInfo then
    self:CleanTable(self.tSaveInfo)
  end
  self:_CleanObjectiveText()
  if self:IsMainObjective() then
    self:SetMainObjectiveID(nil)
  end
  self.tAttrPts = nil
  self.tHUDText = nil
  self:SetAIUIBlips(false)
  if self._tMarkers then
    for i, hParent in pairs(self._tMarkers) do
      self:CleanUpMarkers(hParent)
    end
    self._tMarkers = {}
  end
  self:CleanUpFocusPts()
  if tConfig.sSoundBank then
    Sound.ReleaseSoundBank(tConfig.sSoundBank)
  end
  HUD.RemoveTimer()
  self:_ClearGPS()
  SabTask._Cleanup(self, bForceUnload, bSaveLoad)
end

function SabTaskObjective:_CleanObjectiveText()
  if self.tHUDText then
    for _, tTextInfo in pairs(self.tHUDText) do
      self:CleanUpHUDText(tTextInfo)
    end
    for i, tTextInfo in pairs(self.tHUDText) do
      self.tHUDText[i] = nil
    end
  end
  if self:GetMainObjectiveTask() == self then
    print("clearing main objective task")
    self:SetMainObjectiveTask(true)
    self:SetMainObjectiveID(nil)
  end
  self.tHUDText = {}
end

function SabTaskObjective:_CleanGeneralEvents()
  if self._tEvents then
    for _, uEvent in pairs(self._tEvents) do
      Util.KillEvent(uEvent)
    end
  end
  self._tEvents = {}
end

function SabTaskObjective:_CleanVehicleDeaths()
  if self._tVehicleDeaths then
    for _, eVehicleDeath in pairs(self._tVehicleDeaths) do
      Vehicle.ClearDeathCallback(eVehicleDeath)
    end
  end
  self._tVehicleDeaths = {}
end

function SabTaskObjective:_CleanTriggerEvents()
  if self._tTriggerWaitFors then
    for _, tTriggerInfo in pairs(self._tTriggerWaitFors) do
      if Util.IsHandleValid(tTriggerInfo.TriggerHandle) then
        Trigger.ClearCallback(tTriggerInfo.TriggerHandle, tTriggerInfo.TriggerID)
      end
    end
  end
  self._tTriggerWaitFors = {}
end

function SabTaskObjective:SubObjectiveCompleted()
  local tCallbacks = self:GetConfig().tOnPartComplete
  local tConfig = self:GetConfig()
  if type(tCallbacks) == "table" then
    for _, tCallback in ipairs(tCallbacks) do
      __UtilFunctions.CallWithOptionalArgs(tCallback[1], tCallback[2])
    end
  end
  self._CompletedCount = self._CompletedCount + 1
  if tConfig.sPartialCompleteID ~= nil then
    local sPartialString = self:GetLocalizedText(self:GetConfig().sPartialCompleteID)
    local sString = self._CompletedCount .. "/" .. self:GetQuota() .. " " .. sPartialString
    self:SetUpdateTextOnFly(self:GetName(), sString)
  end
  if tConfig.bObjCounter and not tConfig.tObjVars then
    local hMessage = self:GetTaskObjectiveID()
    local sNewString = self:GetLocalizedText(tConfig.sObjectiveTextID)
    if hMessage and sNewString then
      HUD.SetObjectiveText(hMessage, sNewString, 2, self._CompletedCount, self:GetQuota())
    end
  elseif tConfig.tObjVars and type(tConfig.tObjVars) == "table" then
    local hMessage = self:GetTaskObjectiveID()
    local sNewString = self:GetLocalizedText(tConfig.sObjectiveTextID)
    local NumVars = #tConfig.tObjVars
    if hMessage and sNewString and 0 < NumVars then
      if NumVars == 1 then
        HUD.SetObjectiveText(hMessage, sNewString, NumVars, tConfig.tObjVars[1])
      elseif NumVars == 2 then
        HUD.SetObjectiveText(hMessage, sNewString, NumVars, tConfig.tObjVars[1], tConfig.tObjVars[2])
      elseif NumVars == 3 then
        HUD.SetObjectiveText(hMessage, sNewString, NumVars, tConfig.tObjVars[1], tConfig.tObjVars[2], tConfig.tObjVars[3])
      else
        print("im lazy")
      end
    end
  end
  local bAllComplete = false
  if self._CompletedCount >= self:GetQuota() then
    bAllComplete = true
  end
  if self.bTaskFailed then
  end
  if self:GetMissionFail() then
    print("DEBUG::MISSION FAILED!!!! ", self:GetName())
    return
  end
  if bAllComplete and not self.bTaskFailed and not self:GetMissionFail() and not self:GetMissionTaskFail() then
    print("")
    print("DEBUG:: OBJECTIVE COMPLETE!", self:GetName())
    self.bTaskComplete = true
    if tConfig.sTaskEndConv and tConfig.sTaskEndConv ~= "" then
      Cin.PlayConversation(tConfig.sTaskEndConv)
      self:_ContinueSTOComplete()
    else
      self:_ContinueSTOComplete()
    end
  end
end

function SabTaskObjective:_ContinueSTOComplete()
  self:_Complete()
end

function SabTaskObjective:_SetupGPS()
  local tConfig = self:GetConfig()
  local hGPSTarget
  if not tConfig.bNoGPS and not tConfig.bInteriorTask and not tConfig.bNoFocus and not tConfig.bNoBlips and not tConfig.bNoHUDBlip then
    if tConfig.vGPSTarget then
      if type(tConfig.vGPSTarget) == "table" and tConfig.vGPSTarget[1] then
        hGPSTarget = WRAPPER_CheckForHandle(tConfig.vGPSTarget[1])
      else
        hGPSTarget = WRAPPER_CheckForHandle(tConfig.vGPSTarget)
      end
    elseif tConfig.tLocators and tConfig.tLocators[1] then
      hGPSTarget = WRAPPER_CheckForHandle(tConfig.tLocators[1])
    elseif tConfig.tTgtInclude and tConfig.tTgtInclude[1] then
      hGPSTarget = WRAPPER_CheckForHandle(tConfig.tTgtInclude[1])
    elseif tConfig.tDestProximityObj and tConfig.tDestProximityObj[1] then
      hGPSTarget = WRAPPER_CheckForHandle(tConfig.tDestProximityObj[1])
    end
    if hGPSTarget then
      self._hGPSTarget = hGPSTarget
      HUD.SetGPSTarget(hGPSTarget)
    else
    end
  end
end

function SabTaskObjective:_ClearGPS()
  if self._hGPSTarget then
    self._hGPSTarget = nil
    HUD.ClearGPSTarget()
  end
end

function SabTaskObjective:_HasGPSAlready()
end

function SabTaskObjective:_SetupEscalationCallback()
  local CurrentEscalation = Suspicion.GetEscalation()
  if 0 < CurrentEscalation then
    self:_CallbackSabTaskObjectiveOnEscalation()
  else
    EVENT_OnEscalation("SabTaskObjective._CallbackSabTaskObjectiveOnEscalation", self, {})
  end
end

function SabTaskObjective:_CallbackSabTaskObjectiveOnEscalation()
  tCallbacks = self:GetConfig().tOnEscalation
  if tCallbacks and type(tCallbacks) == "table" then
    for _, tCallback in ipairs(tCallbacks) do
      __UtilFunctions.CallWithOptionalArgs(tCallback[1], tCallback[2])
    end
  end
  EVENT_EscalationFree("SabTaskObjective._CallbackSabTaskObjectiveEscalationClear", self, {})
end

function SabTaskObjective:_CallbackSabTaskObjectiveEscalationClear()
  tCallbacks = self:GetConfig().tOnEscalationClear
  if tCallbacks and type(tCallbacks) == "table" then
    for _, tCallback in ipairs(tCallbacks) do
      __UtilFunctions.CallWithOptionalArgs(tCallback[1], tCallback[2])
    end
  end
  self:_SetupEscalationCallback()
end

function SabTaskObjective:SubObjectiveCancelled()
  self:Cancel()
end

function SabTaskObjective:SetUIBlips(Value, bOn, bNoFocus, bGroundBlip, sTypeOverride, bGotoOverride)
  local tConfig = self:GetConfig()
  if Value == "" or Value == nil then
    print("WARNING:: SabTaskObjective:SetUIBlips was passed a nil Value ", self:GetName())
    return
  end
  local hValue
  if type(Value) == "string" then
    hValue = Util.GetHandleByName(Value)
  elseif type(Value) == "userdata" then
    hValue = Value
  end
  if hValue ~= nil and hValue ~= hSab then
    local MMType, BlipType, mmStarterIcon
    local bExtStarter = false
    local oParentConfig = self:GetParent():GetConfig()
    local oActionPackageConfig = self:GetActionPackage():GetConfig()
    if tConfig.sTaskSubType and bOn then
      if string.upper(tConfig.sTaskSubType) == "TALK" then
        if tConfig.bStarterFlag and not oActionPackageConfig.bFreeplay then
          self._ObjIcon = eOT_GOTO
          MMType = cMMI_MissionGiver
          BlipType = cOM_MissionGiver
          mmStarterIcon = self:GetStarterIcon()
        elseif tConfig.bStarterFlag and oActionPackageConfig.bFreeplay then
          self._ObjIcon = eOT_GOTO
          MMType = cMMI_MissionGiver
          BlipType = cOM_MissionGiver
          mmStarterIcon = self:GetStarterIcon()
        elseif oActionPackageConfig.bWorldEvent or oActionPackageConfig.bFreeplay then
          self._ObjIcon = eOT_GOTO
          MMType = cMMI_Objective
          BlipType = cOM_Goto
        else
          self._ObjIcon = eOT_GOTO
          MMType = cMMI_Objective
          BlipType = cOM_Goto
        end
        if tConfig.bStarterFlag and not tConfig.bInteriorTask then
          bExtStarter = true
        end
      elseif string.upper(tConfig.sTaskSubType) == "DELIVER" then
        self._ObjIcon = eOT_GOTO
        if not bGotoOverride and Object.IsHuman(hValue) then
          MMType = cMMI_Escort
          BlipType = cOM_Escort
        else
          MMType = cMMI_Objective
          BlipType = cOM_Goto
        end
      elseif string.upper(tConfig.sTaskSubType) == "USE" then
        self._ObjIcon = eOT_USE
        MMType = cMMI_Objective
        BlipType = cOM_Use
      elseif string.upper(tConfig.sTaskSubType) == "DEFAULT_USE" then
        self._ObjIcon = eOT_USE
        MMType = cMMI_Objective
        BlipType = cOM_Use
      elseif string.upper(tConfig.sTaskSubType) == "DEFEND" then
        self._ObjIcon = eOT_DEFEND
        MMType = cMMI_Escort
        BlipType = cOM_Escort
      elseif string.upper(tConfig.sTaskSubType) == "DESTROY" then
        if oActionPackageConfig.bWorldEvent then
          self._ObjIcon = eOT_DESTROY
          MMType = cMMI_Destroy
          BlipType = cOM_Destroy
        else
          self._ObjIcon = eOT_DESTROY
          MMType = cMMI_Destroy
          BlipType = cOM_Destroy
        end
      elseif string.upper(tConfig.sTaskSubType) == "KILL" then
        if oActionPackageConfig.bWorldEvent then
          self._ObjIcon = eOT_KILL
          MMType = cMMI_Destroy
          BlipType = cOM_Kill
        else
          self._ObjIcon = eOT_KILL
          MMType = cMMI_Destroy
          BlipType = cOM_Kill
        end
      elseif string.upper(tConfig.sTaskSubType) == "ESCORT" then
        self._ObjIcon = eOT_GOTO
        if Object.IsHuman(hValue) then
          MMType = cMMI_Escort
          BlipType = cOM_Escort
        else
          MMType = cMMI_Objective
          BlipType = cOM_Goto
        end
      elseif string.upper(tConfig.sTaskSubType) == "FOLLOW" then
        self._ObjIcon = eOT_GOTO
        if Object.IsHuman(hValue) then
          MMType = cMMI_Escort
          BlipType = cOM_Escort
        else
          MMType = cMMI_Objective
          BlipType = cOM_Goto
        end
      elseif string.upper(tConfig.sTaskSubType) == "GOTO" then
        self._ObjIcon = eOT_GOTO
        if not bGotoOverride and Object.IsHuman(hValue) then
          MMType = cMMI_Escort
          BlipType = cOM_Escort
        else
          MMType = cMMI_Objective
          BlipType = cOM_Goto
        end
      elseif string.upper(tConfig.sTaskSubType) == "TAXI" then
        self._ObjIcon = eOT_GOTO
        if Object.IsHuman(hValue) then
          MMType = cMMI_Escort
          BlipType = cOM_Escort
        else
          MMType = cMMI_Objective
          BlipType = cOM_Goto
        end
      elseif string.upper(tConfig.sTaskSubType) == "SABOTAGE" then
        self._ObjIcon = eOT_DESTROY
        MMType = cMMI_Destroy
        BlipType = cOM_Destroy
      elseif string.upper(tConfig.sTaskSubType) == "INVESTIGATE" then
        self._ObjIcon = eOT_GOTO
        MMType = cMMI_Objective
        BlipType = cOM_Objective
      elseif string.upper(tConfig.sTaskSubType) == "FETCH" then
        self._ObjIcon = eOT_GOTO
        MMType = cMMI_Objective
        BlipType = cOM_Objective
      elseif string.upper(tConfig.sTaskSubType) == "ENTERINTERIOR" or string.upper(tConfig.sTaskSubType) == "EXITINTERIOR" then
        self._ObjIcon = eOT_GOTO
        MMType = cMMI_Objective
        BlipType = cOM_Goto
      else
        self._ObjIcon = eOT_DESTROY
        MMType = cMMI_Destroy
        BlipType = cOM_Destroy
      end
    elseif sTypeOverride and string.upper(sTypeOverride) == "KILL" then
      self._ObjIcon = eOT_KILL
      MMType = cMMI_Destroy
      BlipType = cOM_Kill
    elseif sTypeOverride and string.upper(sTypeOverride) == "GOTO" then
      self._ObjIcon = eOT_GOTO
      MMType = cMMI_Objective
      BlipType = cOM_Goto
    else
      self._ObjIcon = eOT_DEFEND
      MMType = cMMI_Escort
      BlipType = cOM_Escort
    end
    if tConfig.ObjIcon then
      self._ObjIcon = tConfig.ObjIcon
    end
    local bTrackOffRadar = true
    if oActionPackageConfig.bFreeplay or oActionPackageConfig.bWorldEvent then
    end
    local bHasMarker = false
    bHasMarker = self:HasMasterMarker(hValue)
    local bRenderMinimapIcon = false
    local bRenderWorldIcon = false
    local bRenderMinimapEdge = true
    if not oActionPackageConfig.bFreeplay or tConfig.bStarterFlag then
    end
    if not bOn then
      if self:HasGroundMarker(hValue) then
        self:RemoveGroundMarker(hValue)
      end
    elseif tConfig.bGroundBlip and not Object.IsHuman(hValue) and not Object.IsVehicle(hValue) and not self:HasGroundMarker(hValue) then
      table.insert(self._tGroundMarkers, hValue)
      HUD.AddGroundDecal(hValue)
    end
    local bSuccess = false
    if not bHasMarker and bOn then
      local bRotate = false
      local MarkerHeight = tConfig.MarkerHeight or 2.5
      if 20 < MarkerHeight then
        MarkerHeight = 2.5
      end
      if mmStarterIcon then
        bSuccess = HUD.SetObjectiveMarker(hValue, MMType, BlipType, false, false, bRenderMinimapEdge, MarkerHeight, mmStarterIcon)
      else
        bSuccess = HUD.SetObjectiveMarker(hValue, MMType, BlipType, false, false, bRenderMinimapEdge, MarkerHeight)
      end
      local bExteriorMarker = true
      if tConfig.bInteriorTask then
        bExteriorMarker = false
      end
      if bSuccess then
        if not self._tMarkers then
          Util.Assert(false, "Freedom:SetUIBlips self._tMarkers doesn't exist. Freedom let us down", self:GetName())
          self._tMarkers = {}
        end
        table.insert(self._tMarkers, hValue)
        SabTask:AddMarker(hValue, Value, bExteriorMarker, bExtStarter, bOn)
      else
        print("ERROR:: Could not successfully create a hud marker SabTaskObjective:SetUIBlips -", self:GetName(), Value)
      end
    end
    if bHasMarker and not self:HasMarker(hValue) then
      if not self._tMarkers then
        self._tMarkers = {}
      end
      table.insert(self._tMarkers, hValue)
    end
    if self:HasMarker(hValue) then
      local priority = 1
      local bToggle = true
      if tConfig.bOptional then
        priority = 50
      end
      if self:IsMarkerInUseByAnother(hValue) and self._tMarkerOldHideState == -1 then
        local tMarkerTable = SabTask:GetMarkerTable(hValue)
        if tMarkerTable and tMarkerTable.bOn then
          self._tMarkerOldHideState = tMarkerTable.bOn
        end
      end
      if priority == 1 then
        self:UpdateMarkerTable(hValue, bOn)
        bToggle = true
      elseif self:IsMarkerInUseByAnother(hValue) then
        bToggle = false
      else
        bToggle = true
      end
      if bToggle then
        self:UpdateMarkerTable(hValue, bOn)
        EVENT_Timer("SabTask.ToggleMarkers", self, 0.3)
      end
    end
    local FocusPointID = self:SetFocusObjective(0, 0, 0, 0, 99, bOn, hValue, bNoFocus)
    if FocusPointID ~= -1 then
      self:ConnectFocusToObjectiveText()
    else
      print("!!! focus point returned -1!!!", Value)
    end
  elseif hValue ~= hSab and not tConfig.bBlueprintFetch and not tConfig.bAutofireInterior and not tConfig.bAutoFireInterior then
    print("hValue is not valid, perhaps you forgot to mark as persistent? ", Value, self:GetName())
  end
end

function SabTaskObjective:SetMarkerToPreviousState(hValue)
  local tMarkerTable = SabTask:GetMarkerTable(hValue)
  local bOn = false
  if self._tMarkerOldHideState ~= -1 then
    bOn = self._tMarkerOldHideState
  end
  self:UpdateMarkerTable(hValue, bOn)
  self._tMarkerOldHideState = -1
  self:ToggleMarkers()
end

function SabTaskObjective:HasFocusPt(hValue)
  if self._tFocusPts then
    for _, v in pairs(self._tFocusPts) do
      if v == hValue then
        print("this obj already has a focus pt", self:GetName())
        return true
      end
    end
  end
  return false
end

function SabTaskObjective:HasMarker(hValue)
  if self._tMarkers then
    for _, v in pairs(self._tMarkers) do
      if v == hValue then
        return true
      end
    end
  end
  return false
end

function SabTaskObjective:HasGroundMarker(hValue)
  if self._tGroundMarkers then
    for _, v in pairs(self._tGroundMarkers) do
      if v == hValue then
        return true
      end
    end
  end
  return false
end

function SabTaskObjective:RemoveGroundMarker(Value)
  if self._tGroundMarkers then
    for i, v in pairs(self._tGroundMarkers) do
      local hValue = Handle(Value)
      if v == hValue then
        HUD.RemoveGroundDecal(hValue)
        table.remove(self._tGroundMarkers, i)
        return
      end
    end
  end
  return false
end

function SabTaskObjective:SetAIUIBlips(bOn)
  local tConfig = self:GetConfig()
  if tConfig.bNoBlips then
    bOn = false
  end
  if tConfig.bNoWorldBlip and tConfig.bNoHUDBlip then
    bOn = false
  end
  if tConfig.tTgtInclude and not tConfig.bBlipLocatorsOnly then
    for _, Value in ipairs(tConfig.tTgtInclude) do
      self:SetUIBlips(Value, bOn)
    end
  end
  if tConfig.tDestProximityObj and not tConfig.bBlipLocatorsOnly then
    if tConfig.bNoGroundBlip then
      bGroundBlip = false
    end
    for _, Value in ipairs(tConfig.tDestProximityObj) do
      self:SetUIBlips(Value, bOn, false, bGroundBlip, "", true)
    end
  end
  if tConfig.tDeliverObjs and not tConfig.bBlipLocatorsOnly then
    for _, Value in ipairs(tConfig.tDeliverObjs) do
      self:SetUIBlips(Value, bOn)
    end
  end
  if tConfig.tSuccessLocs and not tConfig.bBlipLocatorsOnly then
    local successlocs
    if type(tConfig.tSuccessLocs) == "table" then
      successlocs = tConfig.tSuccessLocs
    else
      successlocs = {
        tConfig.tSuccessLocs
      }
    end
    for _, Value in ipairs(successlocs) do
      self:SetUIBlips(Value, bOn)
    end
  end
  if tConfig.tFailLocs and not tConfig.bBlipLocatorsOnly then
    local faillocs
    if type(tConfig.tFailLocs) == "table" then
      faillocs = tConfig.tFailLocs
    else
      faillocs = {
        tConfig.tFailLocs
      }
    end
    for _, Value in ipairs(faillocs) do
      self:SetUIBlips(Value, bOn)
    end
  end
  if tConfig.tLocators then
    local bGroundBlip = false
    if tConfig.bGroundBlip then
      bGroundBlip = true
    end
    if tConfig.bNoGroundBlip then
      bGroundBlip = false
    end
    for _, Value in ipairs(tConfig.tLocators) do
      self:SetUIBlips(Value, bOn, false, bGroundBlip, "", true)
    end
  end
  if tConfig.tExtraFocusPts then
    for _, Value in ipairs(tConfig.tExtraFocusPts) do
      self:SetUIBlips(Value, bOn)
    end
  end
end

function SabTaskObjective:BlipByTaskName(sTaskName, bOn, bFocus)
  local oTask = self:FindMissionTask(sTaskName)
  if oTask and oTask:IsActive() then
    local tConfig = oTask:GetConfig()
    if bOn then
      tConfig.bNoFocus = not bFocus or false
      tConfig.bNoHUDBlip = false
      tConfig.bNoWorldBlip = false
    end
    oTask:SetAIUIBlips(bOn)
  else
    self:WarningNil("oTask", "SabTaskObjective:BlipByTaskName")
  end
end

function SabTaskObjective:FindTaskQuota()
  local tConfig = self:GetConfig()
  if tConfig.tTgtInclude then
    self._Total = #tConfig.tTgtInclude
  elseif tConfig.tDeliverObjs then
    self._Total = #tConfig.tDeliverObjs
  end
  self:SetQuota(self._Total)
  if type(tConfig.TaskCount) == "number" then
    if tConfig.TaskCount > self._Total then
    end
    self:SetQuota(tConfig.TaskCount)
  elseif tConfig.TaskCount == "auto" then
    local icount = 0
    for i, v in pairs(_G[tConfig.sTaskType]) do
      if type(v) == "function" and string.find(string.upper(i), "TASK") then
        icount = icount + 1
      end
    end
    if icount == 0 then
      print("WARNING: Attempt to set auto task in ", self:GetName(), " has failed. No tasks functions found.")
    end
    self:SetQuota(icount)
  end
end

function SabTaskObjective:SetQuota(vValue)
  if not vValue then
    print("ERROR SabTaskObjective:SetQuota - vValue is not valid", self:GetName())
    return
  end
  self._TaskQuota = vValue
end

function SabTaskObjective:GetQuota()
  return self._TaskQuota
end

function SabTaskObjective:_Complete()
  self.bTaskComplete = true
  local tConfig = self:GetConfig()
  if tConfig.WTFZoneHigh then
    Combat.BroadcastRetreat(hSab, 120)
    Zone.SwitchState(tConfig.WTFZoneHigh, cZONESTATE_HIGHWTF, cENT_DURINGSTREAM, true)
  end
  if tConfig.WTFZoneLow then
    Zone.SwitchState(tConfig.WTFZoneLow, cZONESTATE_LOWWTF, cENT_DURINGSTREAM, true)
  end
  if self._bGameplayTask then
    if self.MISSION_ONRESET then
      self.MISSION_ONRESET(self)
    end
    if self.MISSION_ONCOMPLETE then
      self.MISSION_ONCOMPLETE(self)
    end
  end
  SabTask._Complete(self)
  if self:GetConfig().bRepeatable and not self._bGameplayTask then
    self:ResetState()
    if not tConfig.bNoRepeatAutoRebuild then
      Util.CreateEvent({EventType = "TimerEvent", Time = 0.1}, "SabTask.BuildFoundation", self, {})
    end
  end
  if self.bAutoComplete and not tConfig.bOptional then
    local oParent = self:GetParent()
    if oParent.bAutoComplete then
      if tConfig.bRepeatable and not self._bGameplayTask then
        oParent._CompletedCount = oParent._CompletedCount - 1
      end
      oParent:SubObjectiveCompleted()
    end
  end
end

function SabTaskObjective:CleanUpMarkers(hParent)
  local bInUse = false
  local oParent = self:GetParent()
  local tChildren = oParent:GetChildren()
  bInUse = self:IsMarkerInUseByAnother(hParent)
  if not bInUse then
    self:RemoveMarker(hParent)
    if Util.IsObjectHandleValid(hParent) or Util.IsHandleValid(hParent) then
      HUD.RemoveObjectiveMarker(hParent)
    else
    end
  else
    self:SetMarkerToPreviousState(hParent)
  end
end

function SabTaskObjective:IsMarkerInUseByAnother(hParent)
  local bInUse = false
  local oParent = self:GetParent()
  local tChildren = oParent:GetChildren()
  if tChildren then
    for i, oChild in pairs(tChildren) do
      if oChild and oChild:GetName() ~= self:GetName() and oChild._tMarkers then
        for j, hMarker in pairs(oChild._tMarkers) do
          if hMarker == hParent then
            return true
          end
        end
      end
    end
  end
end

function SabTaskObjective:CleanUpFocusPts()
  if self._tFocusPts then
    for _, tFocusTable in pairs(self._tFocusPts) do
      if tFocusTable.FocusHandle then
        FocusPt.Delete(tFocusTable.FocusHandle)
      end
      tFocusTable.FocusHandle = nil
      tFocusTable.Handle = nil
    end
    for _, tFocusTable in pairs(self._tFocusPts) do
      tFocusTable = nil
    end
  end
  self._tFocusPts = nil
end

function SabTaskObjective:CleanTable(tTable)
  if tTable then
    for _, vInfo in pairs(tTable) do
      if type(vInfo) == "table" then
        self:CleanTable(vInfo)
      else
        vInfo = nil
      end
    end
  end
  tTable = nil
end

function SabTaskObjective:CleanUpUsePt(hUsePt)
  if hUsePt then
    AttractionPt.EnableUse(hUsePt, false)
    AttractionPt.Delete(hUsePt)
  else
    self:WarningNil("hUsePt", "SabTaskObjective:CleanUpUsePt")
  end
end

function SabTaskObjective:SetupUsePt(hUsePt)
  tConfig = self:GetConfig()
  if hUsePt then
    AttractionPt.EnableUse(hUsePt, true)
  else
    self:WarningNil("hUsePt", "SabTaskObjective:SetupUsePt")
    return
  end
  local tEvent = {
    EventType = "OnActorComplete",
    Target = hUsePt
  }
  local fCallbackFunction = "SabTaskObjective.CompleteUsePoint"
  self:RegisterEvent(Util.CreateEvent(tEvent, fCallbackFunction, self, {hUsePt}, tConfig.bPlayerOnly))
end

function SabTaskObjective:SetupUseActor(hTarget)
  if not hTarget then
    self:WarningNil("hTarget", "SabTaskObjective:SetupUseActor")
    return
  else
    hTarget = WRAPPER_CheckForHandle(hTarget)
  end
  local tEvent = {
    EventType = "OnActorUsed",
    EventName = self:GetName() .. "_TalkEvent",
    Target = hTarget
  }
  local fCallbackFunction = "SabTaskObjective.CompleteActorUse"
  self:RegisterEvent(Util.CreateEvent(tEvent, fCallbackFunction, self, {hTarget}))
end

function SabTaskObjective:CompleteUsePoint(tArgs)
  local tConfig = self:GetConfig()
  if self:IsActive() then
    if tConfig.bPlayerOnly and not tArgs[2] == hSab then
      print("looking for player only use, returning")
      return
    end
    self:SetUIBlips(tArgs[1], false)
    if tConfig.bUseOnce then
      AttractionPt.EnableUse(WRAPPER_CheckForHandle(tArgs[1]), false)
    end
    if tConfig.sConvFile then
      Cin.PlayConversation(tConfig.sConvFile, "SabTaskObjectiveInteract.CallbackConversationComplete", self)
    elseif tConfig.sToolTipID then
      self:ShowToolTip(tConfig.sToolTipID)
    end
    self:SubObjectiveCompleted()
    return
  end
end

function SabTaskObjective:CompleteActorUse(tArgs)
  local tConfig = self:GetConfig()
  if self:IsActive() then
    self:SetUIBlips(tArgs[1], false)
    if tConfig.sConvFile then
      Cin.PlayConversation(tConfig.sConvFile, "SabTaskObjectiveInteract.CallbackConversationComplete", self)
    elseif tConfig.sToolTipID then
      self:ShowToolTip(tConfig.sToolTipID)
    end
    self:SubObjectiveCompleted()
    return
  end
end

function SabTaskObjective:FireEndCinematic()
  tConfig = self:GetConfig()
  if tConfig.sCinFile then
    local bLoop = false
    if tConfig.bLoop then
      bLoop = true
    end
    if tConfig.bFireForgetCin then
      print("I HAS A fire and forget CINEMATIC", tConfig.sCinFile, self:GetName())
      Cin.PlayCinematic(tConfig.sCinFile, bLoop)
    else
      print("I HAS A CINEMATIC", tConfig.sCinFile, self:GetName())
      Cin.PlayCinematic(tConfig.sCinFile, false, "SabTaskObjective.SubObjectiveCompleted", self)
    end
  end
end

function SabTaskObjective:AcceptTask()
  if self:IsActive() then
    self:SubObjectiveCompleted()
    return
  end
end

function SabTaskObjective:_SetupTimers()
  local tConfig = self:GetConfig()
  if tConfig.VictoryTimer and type(tConfig.VictoryTimer) == "number" then
    self:SetVictoryTimer()
  elseif tConfig.FailureTimer and type(tConfig.FailureTimer) == "number" then
    self:SetFailureTimer()
  end
  if tConfig.AutoCompleteTimer and type(tConfig.AutoCompleteTimer) == "number" then
    self._eSafetyCompleteTimer = EVENT_Timer("SabTaskObjective.SafetyTimerDing", self, tConfig.AutoCompleteTimer, {false})
  elseif tConfig.AutoKillTimer and type(tConfig.AutoKillTimer) == "number" then
    self._eSafetyCompleteTimer = EVENT_Timer("SabTaskObjective.SafetyTimerDing", self, tConfig.AutoKillTimer, {true})
  end
end

function SabTaskObjective:SafetyTimerDing(bKill)
  if self:IsActive() and self._eSafetyCompleteTimer then
    self._eSafetyCompleteTimer = nil
    if bKill then
      print("killing saftey timer task ", self:GetName())
      self:KillTaskByName(self:GetName())
    else
      print("completing saftey timer task ", self:GetName())
      self:CompleteTaskByName(self:GetName())
    end
  end
end

function SabTaskObjective:SetVictoryTimer()
  local tConfig = self:GetConfig()
  if tConfig.bProgressBar then
    local sTask
    HUD.SetupProgressBar(self:GetTaskObjectiveID(), tConfig.VictoryTimer, 0, tConfig.VictoryTimer)
    HUD.AddProgressBarCallback(self:GetTaskObjectiveID(), "SabTaskObjective.VictoryTimerComplete", 0, self, {})
  else
    EVENT_Timer("SabTaskObjective.VictoryTimerComplete", self, tConfig.VictoryTimer)
    if not tConfig.bHideTimer then
    end
  end
end

function SabTaskObjective:VictoryTimerComplete()
  if not self.bTaskFailed then
    self.bVictoryTimerSuccess = true
    self:SubObjectiveCompleted()
  else
  end
  HUD.RemoveTimer()
end

function SabTaskObjective:SetFailureTimer()
  local tConfig = self:GetConfig()
  if tConfig.bProgressBar then
    HUD.SetupProgressBar(self:GetTaskObjectiveID(), 0, tConfig.FailureTimer, 0)
    HUD.AddProgressBarCallback(self:GetTaskObjectiveID(), "SabTaskObjective.FailureTimerComplete", tConfig.FailureTimer, self, {})
  else
    EVENT_Timer("SabTaskObjective.FailureTimerComplete", self, tConfig.FailureTimer)
  end
end

function SabTaskObjective:FailureTimerComplete()
  local tConfig = self:GetConfig()
  local tCallbacks = tConfig.tOnFailure
  if not self.bTaskComplete then
    self.bTaskFailed = true
    if self:IsActive() then
      self:Cancel()
    else
    end
  end
  HUD.RemoveTimer()
end

function SabTaskObjective:_SetupPlayerDeath()
  if not self._ePlayerDeath then
    self._ePlayerDeath = EVENT_ActorDeath("SabTaskObjective.PlayerDiedDuringMission", self, hSab)
  end
end

function SabTaskObjective:PlayerDiedDuringMission()
  print("Player died", self:GetName())
  self._ePlayerDeath = nil
  self.bTaskFailed = true
  self:SetMissionFail(true)
  self:SetMissionTaskFail(true)
  self:_CleanAllEvents()
end

function SabTaskObjective:CreateObjCounterString()
  local tConfig = self:GetConfig()
  local sString = self:GetLocalizedText(tConfig.sObjectiveTextID)
  local sCounterString = self._CompletedCount .. "/" .. self:GetQuota()
  sString = sString .. " " .. sCounterString
  return sString
end

function SabTaskObjective:SetFocusObjective(xoffset, yoffset, zoffset, r, p, bOn, hValue, bNoFocus)
  local FocusPointID
  local radius = r or 0
  local priority = p or 0
  local x = xoffset or 0
  local y = yoffset or 0
  local z = zoffset or 0
  local tConfig = self:GetConfig()
  if not hValue then
    self:WarningNil("hValue", "SabTaskObjective:SetFocusObjective")
    return
  end
  if tConfig.bHighPriorityFocus then
    priority = 100
  end
  if tConfig.FocusRadius then
    radius = tConfig.FocusRadius
  end
  if bOn and not tConfig.bNoFocus and not bNoFocus then
    local bExteriorFocusPt = true
    if tConfig.bInteriorTask then
      bExteriorFocusPt = false
    end
    local tSabSelf = Actor.GetSelf(hSab)
    local bStartActive = true
    if tSabSelf.bInInterior and not bExteriorFocusPt then
      bStartActive = true
    elseif tSabSelf.bInInterior and bExteriorFocusPt then
      bStartActive = false
    elseif not tSabSelf.bInInterior and not bExteriorFocusPt then
      bStartActive = false
    else
      bStartActive = true
    end
    local FocusPointID
    if not self:HasFocusPt(hValue) then
      FocusPointID = FocusPt.Create(x, y, z, radius, priority, bStartActive, bExteriorFocusPt, hValue)
    end
    if FocusPointID ~= -1 or FocusPointID ~= nil then
      InteriorManager.ToggleFocus()
      table.insert(self._tFocusPts, {
        FocusHandle = FocusPointID,
        Handle = hValue,
        bConnected = false
      })
    else
      print("SabTaskObjective:SetFocusObjective -  FocusPt.Create returned -1 perhaps we are out of focuspts")
    end
  else
    local tDeleteMe = {}
    local i = 1
    if self._tFocusPts then
      while i <= #self._tFocusPts do
        if self._tFocusPts[i] and self._tFocusPts[i].Handle == hValue and self._tFocusPts[i].FocusHandle ~= nil and self._tFocusPts[i].FocusHandle ~= -1 then
          FocusPt.Delete(self._tFocusPts[i].FocusHandle)
          table.remove(self._tFocusPts, i)
        else
          i = i + 1
        end
      end
    end
  end
  return FocusPointID
end

function SabTaskObjective:ToggleFocus(bOn, sTaskName)
  local oThisTask
  oThisTask = self:FindMissionTask(sTaskName)
  if oThisTask and oThisTask:IsActive() then
    if oThisTask._tFocusPts then
      for i, tFocusTable in pairs(oThisTask._tFocusPts) do
        FocusPt.Enable(tFocusTable.FocusHandle, bOn)
      end
    end
  else
    self:WarningNil("oThisTask", "SabTaskObjective:ToggleFocusByName")
  end
end

function SabTaskObjective:CleanUpFollower(hFollower)
  if not hFollower then
    self:WarningNil("hFollower", "SabTaskObjective:CleanUpFollower")
    return
  end
  Nav.CancelFollowObject(hFollower)
  RemoveSabFollower(self, hFollower)
end

function SabTaskObjective:DelayedCancel()
  print("cancelling from death ", self:GetName())
  self:Cancel()
end

function SabTaskObjective:CancelThisMission(bDontResetEscalation)
  if not self then
    return
  end
  if not string.find(self:GetName(), "_Gameplay") then
    print("ERROR: Trying to cancel a mission without using gameplay task - CancelThisMission -", self:GetName())
    return
  end
  if self:IsActive() then
    SaveLoad.ClearSnapshot()
    __gb_DontResetEscalation = bDontResetEscalation
    self:Cancel()
  end
end

function SabTaskObjective:CompleteThisMission()
  if not self then
    return
  end
  if not string.find(self:GetName(), "_Gameplay") then
    print("ERROR: Trying to complete a mission without using gameplay task - CompleteThisMission -", self:GetName())
    return
  end
  if self:IsActive() and not self:GetMissionFail() and not self:GetMissionTaskFail() then
    EVENT_Timer("SabTaskObjective._Complete", self, 0.2)
  else
    print("SabTaskObjective:CompleteThisMission: complete this mission failed because : Mission isn't active or player has failed something in it")
  end
end

function SabTaskObjective:ResetThisTask(bDoNotActivate, bForceUnloadNodes, bCheckpoint)
  local tConfig = self:GetConfig()
  local tSMEDNodes = tConfig.tSMEDNodes
  local tStaticTags = tConfig.tStaticTags
  local tCinNodes = tConfig.tCinematicNodes
  if self:GetParent():IsActive() then
    print("DEBUG:: resetting Task by hand", self:GetName())
    if self:IsCompleted() and not tConfig.bOptional and self:GetParent()._CompletedCount and type(self:GetParent()._CompletedCount) == "number" then
      self:GetParent()._CompletedCount = self:GetParent()._CompletedCount - 1
    end
    if self:IsActive() then
      self._bRESETTASK = true
      self:Cancel()
      if tSMEDNodes and not bCheckpoint then
        print("reseting active task tsmed", tSMEDNodes)
        self:UnloadMissionNodeTable(tSMEDNodes, _NODE_DYNAMIC, bForceUnloadNodes)
      end
      if tStaticTags and not bCheckpoint then
        self:UnloadMissionNodeTable(tStaticTags, _NODE_COLBY, bForceUnloadNodes)
      end
      if tCinNodes and not bCheckpoint then
        self:UnloadMissionNodeTable(tCinNodes, _NODE_CINEMATIC, bForceUnloadNodes)
      end
      self:ResetState()
      if not bDoNotActivate then
        Util.CreateEvent({EventType = "TimerEvent", Time = 0.1}, "SabTask.BuildFoundation", self, {})
      end
    elseif self.bTaskFailed or not self:IsLatent() then
      if self.bTaskFailed then
        print("ResetThisTask -- task was cancelled, resetting ", self:GetName())
      end
      if tSMEDNodes and not bCheckpoint then
        print("reseting completed task tsmed nodes ", tSMEDNodes)
        self:UnloadMissionNodeTable(tSMEDNodes, _NODE_DYNAMIC, bForceUnloadNodes)
      end
      if tStaticTags and not bCheckpoint then
        self:UnloadMissionNodeTable(tStaticTags, _NODE_COLBY, bForceUnloadNodes)
      end
      if tCinNodes and not bCheckpoint then
        self:UnloadMissionNodeTable(tCinNodes, _NODE_CINEMATIC, bForceUnloadNodes)
      end
      self:ResetState()
      tCallbacks = self:GetConfig().tOnReset
      if tCallbacks and type(tCallbacks) == "table" then
        for _, tCallback in ipairs(tCallbacks) do
          __UtilFunctions.CallWithOptionalArgs(tCallback[1], tCallback[2])
        end
      end
      if not bDoNotActivate then
        Util.CreateEvent({EventType = "TimerEvent", Time = 0.1}, "SabTask.BuildFoundation", self, {})
      else
      end
    end
  end
end

function SabTaskObjective:UnloadTaskNodes(sTaskName, bForceUnload)
  local oTask = self:FindMissionTask(sTaskName)
  local tConfig, tSMEDNodes, tStaticTags
  if oTask ~= nil then
    local tConfig = oTask:GetConfig()
    local tSMEDNodes = tConfig.tSMEDNodes
    local tStaticTags = tConfig.tStaticTags
    local tCinNodes = tConfig.tCinematicNodes
    if tSMEDNodes then
      oTask:UnloadMissionNodeTable(tSMEDNodes, _NODE_DYNAMIC, bForceUnload)
    end
    if tStaticTags then
      oTask:UnloadMissionNodeTable(tStaticTags, _NODE_COLBY, bForceUnload)
    end
    if tCinNodes then
      oTask:UnloadMissionNodeTable(tCinNodes, _NODE_CINEMATIC, bForceUnload)
    end
  else
    self:WarningNil("oTask", "SabTaskObjective:GetTaskObjectiveID")
  end
end

function SabTaskObjective:GetTaskObjectiveID(sTaskName)
  if not sTaskName then
    return self._ObjectiveID or -1
  end
  local oTask = self:FindMissionTask(sTaskName)
  if oTask ~= nil then
    return oTask._ObjectiveID or -1
  else
    return -1
  end
end

function SabTaskObjective:CompleteTaskByName(sTaskName)
  local oTask = self:FindMissionTask(sTaskName)
  if oTask ~= nil then
    oTask:GetConfig().bRepeatable = false
    if oTask:IsActive() then
      print("DEBUG:: Completin Task by hand", oTask:GetName())
      oTask:_Complete()
    end
  else
    self:WarningNil("oTask", "SabTaskObjective:CompleteTask")
  end
end

function SabTaskObjective:ResetTaskByName(sTaskName, bDoNotActivate)
  local oTask = self:FindMissionTask(sTaskName)
  if oTask ~= nil then
    local tConfig = oTask:GetConfig()
    if oTask.tHUDText then
      for _, tTextInfo in pairs(oTask.tHUDText) do
        if tTextInfo.MessageID == tConfig.sObjectiveTextID then
          tTextInfo.MessageFail = true
        end
      end
    end
    oTask:ResetThisTask(bDoNotActivate)
  else
    self:WarningNil("oTask", "SabTaskObjective:ResetTaskByName")
  end
end

function SabTaskObjective:ClearRepeatableTaskByName(sTaskName)
  local oTask = self:FindMissionTask(sTaskName)
  local tConfig
  if oTask ~= nil then
    print("DEBUG:: clearing repeatable Task", oTask:GetName())
    oTask:GetConfig().bRepeatable = false
  else
    self:WarningNil("oTask", "SabTaskObjective:CompleteTask")
  end
end

function SabTaskObjective:KillTaskByName(sTaskName)
  local oTask = self:FindMissionTask(sTaskName)
  if oTask ~= nil then
    oTask:GetConfig().bRepeatable = false
    if oTask:IsActive() then
      local tConfig = oTask:GetConfig()
      print("DEBUG:: Killing Task by hand", oTask:GetName())
      oTask._bDISABLETONCOMPLETETABLE = true
      oTask:_Complete()
    else
    end
  else
    self:WarningNil("oTask", "SabTask:CompleteTask")
  end
end

function SabTaskObjective:FailTaskByName(sTaskName)
  local oTask = self:FindMissionTask(sTaskName)
  if oTask ~= nil then
    if oTask:IsActive() then
      local tConfig = oTask:GetConfig()
      print("DEBUG:: fail Task by hand", oTask:GetName())
      if oTask.tHUDText then
        for _, tTextInfo in pairs(oTask.tHUDText) do
          if tTextInfo.MessageID == tConfig.sObjectiveTextID then
            tTextInfo.MessageFail = true
          end
        end
      end
      oTask:Cancel()
    else
    end
  else
    self:WarningNil("oTask", "SabTask:CompleteTask")
  end
end

function SabTaskObjective:HUDAudioCheck()
  local tConfig = self:GetConfig()
  if tConfig.sSoundBank then
    Sound.LoadSoundBank(tConfig.sSoundBank)
  end
  if tConfig.sTaskStartConv then
    Cin.PlayConversation(tConfig.sTaskStartConv)
    self:SetupHudText()
  else
    self:SetupHudText()
  end
end

function SabTaskObjective:SetupHudText()
  local tConfig = self:GetConfig()
  if tConfig.sTaskSubType and string.upper(tConfig.sTaskSubType) == "TAXI" and not tConfig.sObjectiveTextID then
    tConfig.sObjectiveTextID = ""
  end
  if tConfig.sObjectiveTextID then
    self:DisplayHUDText(tConfig.sObjectiveTextID, cOBJECTIVE_TEXT, fDuration, iFontSize, nPosX, nPosY, hPrecursor)
  end
  if tConfig.sToolTipTextID then
    self:DisplayHUDText(tConfig.sObjectiveTextID, cTOOLTIP_TEXT, fDuration, iFontSize, nPosX, nPosY, nil)
  end
  if tConfig.sUpdateTextID then
    self:DisplayHUDText(tConfig.sUpdateTextID, cUPDATE_TEXT, 5, iFontSize, nPosX, nPosY, nil)
  end
end

function SabTaskObjective:DisplayHUDText(sTextID, cType, fDuration, iFontSize, nPosX, nPosY, hPrecursor)
  local r, g, b, fontsize, duration
  r = 255
  g = 255
  b = 0
  if TestTextR and TestTextG and TestTextB then
    r = TestTextR
    g = TestTextG
    b = TestTextB
  end
  duration = fDuration or 7
  fontsize = iFontSize or 18
  local sString, sCounterString
  local tConfig = self:GetConfig()
  if tConfig.bObjCounter then
    sString = self:GetLocalizedText(sTextID)
  else
    sString = self:GetLocalizedText(sTextID)
  end
  if sCounterString then
    print("Warning: i should not be here")
    sString = sString .. " " .. sCounterString
  end
  local hMessage
  local sPre = ""
  if tConfig.bOptional then
  else
  end
  local bAddToTable = false
  if cType == cOBJECTIVE_TEXT then
    local bOptional = tConfig.bOptional
    bOptional = bOptional or false
    local ParentID = tConfig.ParentObjectID or nil
    local ObjIcon = self._ObjIcon or eOT_DEFEND
    local priority = 1
    if self:IsMainObjective() then
      priority = 0
    elseif tConfig.bProgressBar then
      priority = 2
    end
    local MainID = self:GetMainObjectiveID()
    if sTextID == "GenericObjective_Text.Escalation_Lose" then
      print("found global generic objective text, holding objective")
      if not _g_b_ImInChargeOfObjectiveVisiblity then
        HUD.KeepObjectivesVisible(true)
      end
    end
    hMessage = HUD.AddObjective(ObjIcon, sString, priority, MainID, bOptional, 2)
    self._ObjectiveID = hMessage
    if tConfig.bObjCounter and not tConfig.tObjVars then
      sString = self:CreateObjCounterString()
      local sNewString = self:GetLocalizedText(tConfig.sObjectiveTextID)
      if hMessage and sNewString then
        HUD.SetObjectiveText(hMessage, sNewString, 2, self._CompletedCount, self:GetQuota())
      end
    elseif tConfig.tObjVars and type(tConfig.tObjVars) == "table" then
      local hMessage = self:GetTaskObjectiveID()
      local sNewString = self:GetLocalizedText(tConfig.sObjectiveTextID)
      local NumVars = #tConfig.tObjVars
      if hMessage and sNewString and 0 < NumVars then
        if NumVars == 1 then
          HUD.SetObjectiveText(hMessage, sNewString, NumVars, tConfig.tObjVars[1])
        elseif NumVars == 2 then
          HUD.SetObjectiveText(hMessage, sNewString, NumVars, tConfig.tObjVars[1], tConfig.tObjVars[2])
        elseif NumVars == 3 then
          HUD.SetObjectiveText(hMessage, sNewString, NumVars, tConfig.tObjVars[1], tConfig.tObjVars[2], tConfig.tObjVars[3])
        else
          print("im lazy")
        end
      end
    end
    if self:IsMainObjective() then
      self:SetMainObjectiveID(hMessage)
    end
    bAddToTable = true
    self:ConnectFocusToObjectiveText()
  elseif cType == cTOOLTIP_TEXT then
    hMessage = HUD.AddToolTip(sString, duration, r, g, b)
    self._ToolTipID = hMessage
  elseif cType == cUPDATE_TEXT then
    hMessage = HUD.AddUpdateBoxText(sString, duration, r, g, b, true)
    self._UpdateID = hMessage
  end
  local tMessageInfo = {
    MessageHandle = hMessage,
    MessageString = sString,
    MessageID = sTextID,
    MessageType = cType,
    MessageFail = false
  }
  if bAddToTable then
    table.insert(self.tHUDText, tMessageInfo)
  end
  return tMessageInfo
end

function SabTaskObjective:RegisterObjectiveText()
end

function SabTaskObjective:ConnectFocusToObjectiveText()
  local tConfig = self:GetConfig()
  local messagehandle = self:GetTaskObjectiveID()
  if messagehandle and self._tFocusPts then
    for _, tFocusTable in pairs(self._tFocusPts) do
      if not tFocusTable.bConnected and messagehandle and messagehandle ~= -1 and tFocusTable.FocusHandle ~= -1 then
        FocusPt.SetObjective(tFocusTable.FocusHandle, messagehandle)
        tFocusTable.bConnected = true
      end
    end
  end
end

function SabTaskObjective:SetMainObjectiveTask(bClear)
  local oGameplay = GetMissionByName(self:GetMyMissionName())
  if not oGameplay then
    return nil
  end
  if bClear then
    oGameplay._oMainObjectiveTask = nil
  else
    oGameplay._oMainObjectiveTask = self
  end
end

function SabTaskObjective:GetMainObjectiveTask()
  local oGameplay = GetMissionByName(self:GetMyMissionName())
  if not oGameplay then
    return nil
  end
  return oGameplay._oMainObjectiveTask
end

function SabTaskObjective:SetMainObjectiveID(hMessage)
  local oGameplay = GetMissionByName(self:GetMyMissionName())
  if not oGameplay then
    return nil
  end
  if hMessage then
    if oGameplay._ObjectiveID ~= nil then
    end
    print("setting main objective task ", self:GetName(), hMessage)
    oGameplay._ObjectiveID = hMessage
  else
    print("Clearing main objective ", self:GetName())
    oGameplay._ObjectiveID = nil
  end
end

function SabTaskObjective:GetMainObjectiveID()
  local oGameplay = GetMissionByName(self:GetMyMissionName())
  if not oGameplay then
    return nil
  end
  return oGameplay._ObjectiveID
end

function SabTaskObjective:IsMainObjective()
  local mainobj = false
  local oMot = self:GetMainObjectiveTask()
  if oMot and self:GetName() == oMot:GetName() then
    return true
  end
  return false
end

function SabTaskObjective:RemoveHUDText(cType, hMessage)
  if cType == cOBJECTIVE_TEXT then
    HUD.RemoveObjective(hMessage)
  else
    HUD.RemoveMessage(cType, hMessage)
  end
end

function SabTaskObjective:CleanUpHUDText(tTextInfo)
  if tTextInfo.MessageType == cOBJECTIVE_TEXT then
    if tTextInfo.MessageFail ~= nil and tTextInfo.MessageFail == true then
      HUD.RemoveObjective(tTextInfo.MessageHandle, true)
      tTextInfo.MessageFail = false
    else
      HUD.RemoveObjective(tTextInfo.MessageHandle)
    end
  elseif tTextInfo and tTextInfo.MessageType and tTextInfo.MessageHandle then
    HUD.RemoveMessage(tTextInfo.MessageType, tTextInfo.MessageHandle)
  end
end

function SabTaskObjective:SetObjectiveTextOnFly(sTaskName, sStringID)
  local oTask = self:GetMissionTask(sTaskName)
  if self:GetName() == sTaskName then
    self:DisplayHUDText(sStringID, cOBJECTIVE_TEXT)
  elseif oTask then
    oTask:DisplayHUDText(sStringID, cOBJECTIVE_TEXT)
  end
end

function SabTaskObjective:ChangeObjTextByName(sTaskName, sStringID)
  local oTask = self:GetMissionTask(sTaskName)
  if oTask and oTask:IsActive() then
    local hMessage = oTask:GetTaskObjectiveID()
    local sString = oTask:GetLocalizedText(sStringID)
    sString = sString or "FIX ME TEXT" .. self:GetName()
    if hMessage and sString then
      print("change obj text by name ", hMessage, sString)
      HUD.SetObjectiveText(hMessage, sString)
    end
  end
end

function SabTaskObjective:ChangeThisObjText(sStringID)
  if self and self:IsActive() then
    local hMessage = self:GetTaskObjectiveID()
    local sString = self:GetLocalizedText(sStringID)
    sString = sString or "FIX ME TEXT" .. self:GetName()
    if hMessage and sString then
      print("change this obj text ", hMessage, sString)
      HUD.SetObjectiveText(hMessage, sString)
    end
  end
end

function SabTaskObjective:SetUpdateTextOnFly(sTaskName, sStringID)
  local oTask = self:GetMissionTask(sTaskName)
  if self:GetName() == sTaskName then
    self:DisplayHUDText(sStringID, cUPDATE_TEXT)
  elseif oTask then
    oTask:DisplayHUDText(sStringID, cUPDATE_TEXT)
  else
    print("WARNING: No task found for ", sTaskName)
  end
end
