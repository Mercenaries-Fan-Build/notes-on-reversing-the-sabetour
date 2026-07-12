if SabTaskObjectiveInteract == nil then
  SabTaskObjectiveInteract = SabTaskObjective:Create()
end

function SabTaskObjectiveInteract:Activated()
  local tConfig = self:GetConfig()
  self._bAcceptDeclined_SabTaskObjectiveInteract = false
  self._bDeclined_SabTaskObjectiveInteract = false
  self._bAccept_SabTaskObjectiveInteract = false
  if tConfig.sTaskSubType and string.upper(tConfig.sTaskSubType) == "CINEMATIC" and tConfig.sCinFile then
    tConfig.TaskCount = 1
  end
  if tConfig.sTaskSubType and string.upper(tConfig.sTaskSubType) == "COURIERMESSAGE" then
    tConfig.TaskCount = 1
    self:_SetupMessage()
  end
  SabTaskObjective.Activated(self)
  local hInterActor, hInteractorUsePt
  self.tInteractAttrPts = {}
  if tConfig.bAutofireInterior or tConfig.bAutoFireInterior then
    print("setting up autofire interior")
    self:SetupAutoFireInterior()
  elseif tConfig.tTgtInclude then
    for _, Value in pairs(tConfig.tTgtInclude) do
      hInterActor = WRAPPER_CheckForHandle(Value)
      if hInterActor ~= nil then
        if tConfig.sTaskSubType then
          if string.upper(tConfig.sTaskSubType) == "TALK" then
            if hInterActor ~= hSab then
              local bIsStarter
              if hInterActor then
                local ActorSelf = Actor.GetSelf(hInterActor)
                local bUsePt, sConversation
                if tConfig.bHelpMode then
                  sConversation = tConfig.sHintFile
                else
                  sConversation = tConfig.sConvFile
                end
                if Object.IsAttrPt(hInterActor) then
                  bUsePt = true
                  AttractionPt.EnableUse(hInterActor, true)
                elseif not tConfig.bAutofire and not tConfig.bAutoFire then
                  Actor.SetTalkable(hInterActor, true, sConversation, tConfig.sStarterAttrPt)
                end
                self.bTalkableConversationReset = true
                if tConfig.bAutofire or tConfig.bAutoFire then
                  self:SetupAutoFire(hInterActor)
                else
                  local eType
                  if bUsePt then
                    eType = "OnActorComplete"
                  else
                    eType = "OnActorUsed"
                  end
                  self:SetupUseActor(hInterActor, eType)
                end
              end
              if tConfig.sConvFile then
                self:SetQuota(self:GetQuota() + 1)
              end
              if tConfig.bStarterFlag and not tConfig.bInteriorTask then
                print("this is a starter that wants escalation denial ", Value)
                EVENT_Timer("SabTaskObjectiveInteract._SetupEscalationDenial", self, 1)
              end
              self:_CheckForExteriorBlipNeed()
            end
          elseif string.upper(tConfig.sTaskSubType) == "DEFAULT_USE" then
            AttractionPt.Create("Generic_Use", 0, 0, 0, 180, hInterActor, nil, "SabTaskObjectiveInteract.AttractionPtLoaded", self)
          elseif string.upper(tConfig.sTaskSubType) == "USE" then
            Util.CreateEvent({
              EventType = "StreamEvent",
              Objects = {Value}
            }, "SabTaskObjectiveInteract.AttractionPtStreamed", self, {Value})
          end
        elseif string.upper(tConfig.sTaskSubType) == "INVESTIGATE" then
        else
          AttractionPt.Create("MissionStarterAttrPt", 0, 0, 0, 180, hInterActor, nil, "SabTaskObjectiveInteract.AttractionPtLoaded", self)
        end
      else
        self:WarningNil("hInteractor", "SabTaskObjectiveInteract:Activated", Value)
      end
    end
  end
  if string.upper(tConfig.sTaskSubType) == "CINEMATIC" then
    if tConfig.sCinFile then
      local bLoop = false
      if tConfig.bLoop then
        bLoop = true
      end
      Cin.PlayCinematic(tConfig.sCinFile, bLoop, "SabTaskObjectiveInteract.CallbackCinematicComplete", self, nil, tConfig.bOverrideFade, tConfig.sMusicLocale)
    else
      print("no cinematic file designated autocompleting ", self:GetName())
      EVENT_Timer("SabTaskObjectiveInteract.CallbackCinematicComplete", self, 1)
    end
  end
  if string.upper(tConfig.sTaskSubType) == "INVESTIGATE" then
    self:SetupInvestigate()
  end
end

function SabTaskObjectiveInteract:_SetupEscalationDenial()
  local CurrentEscalation = Suspicion.GetEscalation()
  print("_SetupEscalationDenial")
  if 0 < CurrentEscalation then
    self:_CallbackStarterEscOnEscalation()
  else
    EVENT_OnEscalation("SabTaskObjectiveInteract._CallbackStarterEscOnEscalation", self, {})
  end
end

function SabTaskObjectiveInteract:_CallbackStarterEscOnEscalation()
  print("_CallbackStarterEscOnEscalation")
  self:_FlipStarterInteractionOff()
  EVENT_EscalationFree("SabTaskObjectiveInteract._CallbackStarterEscOnEscalationFree", self, {}, false)
end

function SabTaskObjectiveInteract:_CallbackStarterEscOnEscalationFree()
  print("_CallbackStarterEscOnEscalationFree")
  self:_FlipStarterInteractionOn()
  self:_SetupEscalationDenial()
end

function SabTaskObjectiveInteract:_CheckForExteriorBlipNeed()
  local tConfig = self:GetConfig()
  if not tConfig then
    return
  end
  if not tConfig.sInterior then
    return
  end
  local tInteriorTable = InteriorManager.GetInteriorTable(tConfig.sInterior)
  if tInteriorTable then
    print("requesting blip for ", tInteriorTable.sName)
    InteriorManager.RequestExteriorBlip(tInteriorTable.sName, self:GetStarterIcon())
  end
  self._UsedExteriorBlipLocation = tConfig.sInterior
end

function SabTaskObjectiveInteract:_CleanupExteriorBlip()
  local tConfig = self:GetConfig()
  if not tConfig then
    return
  end
  if not tConfig.sInterior then
    return
  end
  local tInteriorTable = InteriorManager.GetInteriorTable(tConfig.sInterior)
  if tInteriorTable then
    InteriorManager.FinishedWithExteriorBlip(tInteriorTable.sName, nil)
  end
  self._UsedExteriorBlipLocation = nil
end

function SabTaskObjectiveInteract:SetupInvestigate()
  local tConfig = self:GetConfig()
  self._tInvestigateFocusPts = {}
  if tConfig.tSuccessLocs then
    local successlocs = {}
    if type(tConfig.tSuccessLocs) == "table" then
      successlocs = tConfig.tSuccessLocs
      self:SetQuota(#tConfig.tSuccessLocs)
    else
      successlocs = {
        tConfig.tSuccessLocs
      }
      self:SetQuota(1)
    end
    for i, loc in pairs(successlocs) do
      local eSuccess = Util.CreateEvent({
        EventType = "SeeLocatorEvent",
        InViewTime = tConfig.InViewTime or 2,
        Locator = loc,
        Proximity = tConfig.Proximity or 10
      }, "SabTaskObjectiveInteract.InvestigateSuccess", self, {loc})
      self:RegisterEvent(eSuccess)
    end
  else
    Util.Assert("SabTaskObjectiveInteract:SetupInvestigate, There are no success locators specified ", self:GetName())
  end
  if tConfig.tFailLocs then
    local faillocs = {}
    if type(tConfig.tFailLocs) == "table" then
      faillocs = tConfig.tFailLocs
    else
      faillocs = {
        tConfig.tFailLocs
      }
    end
    for i, loc in pairs(faillocs) do
      local eFail = Util.CreateEvent({
        EventType = "SeeLocatorEvent",
        InViewTime = tConfig.InViewTime or 2,
        Locator = loc,
        Proximity = tConfig.Proximity or 10
      }, "SabTaskObjectiveInteract.InvestigateFail", self, {loc})
      self:RegisterEvent(eFail)
    end
  end
end

function SabTaskObjectiveInteract:_FlipStarterInteractionOn()
  local tConfig = self:GetConfig()
  print("flip talky on")
  self:SetUIBlips(tConfig.tTgtInclude[1], true)
  self:_MakeTalkables()
end

function SabTaskObjectiveInteract:_FlipStarterInteractionOff()
  local tConfig = self:GetConfig()
  print("flip talky off")
  self:SetUIBlips(tConfig.tTgtInclude[1], false)
  self:_CleanTalkables()
end

function SabTaskObjectiveInteract:_CleanTalkables()
  local tConfig = self:GetConfig()
  if tConfig.tTgtInclude then
    for _, Value in pairs(tConfig.tTgtInclude) do
      if tConfig.sTaskSubType and string.upper(tConfig.sTaskSubType) == "TALK" then
        local hInterActor = WRAPPER_CheckForHandleNil(Value)
        if hInterActor ~= nil then
          local bIsAttrPt = Object.IsAttrPt(hInterActor)
          if bIsAttrPt then
            AttractionPt.EnableUse(hInterActor, false)
          else
            Actor.SetTalkable(hInterActor, false)
          end
        end
      end
    end
  end
end

function SabTaskObjectiveInteract:_MakeTalkables()
  local tConfig = self:GetConfig()
  if tConfig.tTgtInclude then
    for _, Value in pairs(tConfig.tTgtInclude) do
      if tConfig.sTaskSubType and string.upper(tConfig.sTaskSubType) == "TALK" then
        local hInterActor = WRAPPER_CheckForHandleNil(Value)
        if hInterActor ~= nil then
          local bIsAttrPt = Object.IsAttrPt(hInterActor)
          if bIsAttrPt then
            AttractionPt.EnableUse(hInterActor, true)
          else
            Actor.SetTalkable(hInterActor, true)
          end
        end
      end
    end
  end
end

function SabTaskObjectiveInteract:InvestigateSuccess(loc)
  local tConfig = self:GetConfig()
  if tConfig.sSuccessConv then
    Cin.PlayConversation(tConfig.sSuccessConv)
  end
  local hLoc = Handle(loc)
  if self._tInvestigateFocusPts and hLoc and self._tInvestigateFocusPts[hLoc] then
    FocusPt.Delete(self._tInvestigateFocusPts[hLoc])
    self._tInvestigateFocusPts[hLoc] = nil
  end
  self:SetUIBlips(loc, false)
  self:SubObjectiveCompleted()
end

function SabTaskObjectiveInteract:InvestigateFail(loc)
  local tConfig = self:GetConfig()
  if tConfig.sFailConv then
    Cin.PlayConversation(tConfig.sFailConv)
  end
  local hLoc = Handle(loc)
  if self._tInvestigateFocusPts and hLoc and self._tInvestigateFocusPts[hLoc] then
    FocusPt.Delete(self._tInvestigateFocusPts[hLoc])
    self._tInvestigateFocusPts[hLoc] = nil
  end
  self:SetUIBlips(loc, false)
end

function SabTaskObjectiveInteract:CallbackCinematicComplete(tCinStatus)
  print("cinematic complete")
  local tConfig = self:GetConfig()
  if tCinStatus and type(tCinStatus) == "table" then
    if tCinStatus[1] == cCINEMATIC_FAILED then
      print("ERROR: CINEMATIC FAILED!")
      Render.FadeScreen(false)
      local tCallbacks = self:GetConfig().tOnCinematicFail
      local tConfig = self:GetConfig()
      if type(tCallbacks) == "table" then
        for _, tCallback in ipairs(tCallbacks) do
          __UtilFunctions.CallWithOptionalArgs(tCallback[1], tCallback[2])
        end
      end
    elseif tCinStatus[1] == cCINEMATIC_SKIPPED then
      local tCallbacks = self:GetConfig().tOnSkipped
      local tConfig = self:GetConfig()
      if type(tCallbacks) == "table" then
        for _, tCallback in ipairs(tCallbacks) do
          __UtilFunctions.CallWithOptionalArgs(tCallback[1], tCallback[2])
        end
      end
    end
  end
  self:SubObjectiveCompleted()
end

function SabTaskObjectiveInteract:SetupAutoFire(hInterActor)
  local tConfig = self:GetConfig()
  local tProxEvent = {
    EventType = "ProximityEvent",
    ObjectA = hSab,
    ObjectB = hInterActor,
    Proximity = tConfig.Proximity or 4,
    Check3D = true,
    Negate = tConfig.bNegate
  }
  local sConversation
  if tConfig.bHelpMode then
    sConversation = tConfig.sHintFile
  else
    sConversation = tConfig.sConvFile
  end
  if sConversation and not tConfig.bUseOldAutofire then
    self:RegisterEvent(Util.CreateEvent(tProxEvent, "SabTaskObjectiveInteract.AutofireUsePtConv", self, {hInterActor}))
  else
    self:RegisterEvent(Util.CreateEvent(tProxEvent, "SabTaskObjectiveInteract.CompleteActorUse", self, {hInterActor}))
  end
end

function SabTaskObjectiveInteract:AutofireUsePtConv(tArgs)
  local tConfig = self:GetConfig()
  local hActor, sConversation
  if type(tArgs) == "table" then
    hActor = tArgs[1]
  else
    hActor = tArgs
  end
  if tConfig.bHelpMode then
    sConversation = tConfig.sHintFile
  else
    sConversation = tConfig.sConvFile
  end
  Actor.SetTalkable(hActor, true, sConversation, tConfig.sStarterAttrPt, true)
  self:SetupUseActor(hActor, "OnActorUsed")
end

function SabTaskObjectiveInteract:SetupAutoFireInterior(hInterActor)
  local tConfig = self:GetConfig()
  local sPlayersInt = InteriorManager.GetPlayersInterior()
  local tStarterTable = StarterManager.GetStarterTable(tConfig.sStarter)
  local tInteriorTable
  if not tStarterTable then
    print("Error: SabTaskObjectiveInteract.SetupAutoFireInterior could not find starter table")
    Util.Assert(false, "Cfrench Error: SabTaskObjectiveInteract.SetupAutoFireInterior could not find starter table " .. self.sStarter .. self:GetName())
    return
  end
  if tStarterTable.sParentInterior then
    tInteriorTable = InteriorManager.GetInteriorTable(tStarterTable.sParentInterior)
  else
    tInteriorTable = InteriorManager.GetInteriorTable(tStarterTable.sInterior)
  end
  if not tInteriorTable then
    print("Error: SabTaskObjectiveInteract.SetupAutoFireInterior could not find interiortable table")
    Util.Assert(false, "Cfrench Error: SabTaskObjectiveInteract.SetupAutoFireInterior could not find starter table " .. tInteriorTable .. self:GetName())
    return
  end
  if sPlayersInt and sPlayersInt ~= "" and tInteriorTable.sName == sPlayersInt then
    print("player is already in autostart interior")
    self:CallbackSetupInteriorAutoStart()
  elseif IsMissionOpen("Connect_ST_215b_SkylarRendevous") and sPlayersInt and sPlayersInt == "LeHavreHotel" and tInteriorTable.sName == "LeHavre" then
    print("cfrench hack extravaganza player is already in lehavre hotel autostart interior")
    self:CallbackSetupInteriorAutoStart()
  else
    self:SetupInteriorAutoStart(tInteriorTable.sName)
  end
end

function SabTaskObjectiveInteract:SetupInteriorAutoStart(sInteriorName)
  local tConfig = self:GetConfig()
  tConfig.sInteriorName = sInteriorName
  Util.AddInteriorLoadCallback(sInteriorName, "SabTaskObjectiveInteract.CallbackSetupInteriorAutoStart", self)
  self._bHasInteriorCallbacks = true
end

function SabTaskObjectiveInteract:CallbackSetupInteriorAutoStart()
  local tConfig = self:GetConfig()
  self._bHasInteriorCallbacks = false
  if self:IsActive() then
    EVENT_Timer("SabTaskObjective.SubObjectiveCompleted", self, 0.2)
  end
end

function SabTaskObjectiveInteract:AttractionPtLoaded(tAttrPt)
  local hInteractorUsePt = tAttrPt[1]
  table.insert(self.tInteractAttrPts, hInteractorUsePt)
  if hInteractorUsePt then
    self.bDynamicAttrPt = true
    self:SetupUsePt(hInteractorUsePt)
  else
    self:WarningNil("self.hInteractorUsePt", "SabTaskObjectiveInteract:Activated")
  end
end

function SabTaskObjectiveInteract:AttractionPtStreamed(vAttrPt)
  local hInteractorUsePt = WRAPPER_CheckForHandle(vAttrPt)
  if hInteractorUsePt then
    self.bDynamicAttrPt = false
    self:SetupUsePt(hInteractorUsePt)
  else
    self:WarningNil("self.hInteractorUsePt", "SabTaskObjectiveInteract:Activated")
  end
end

function SabTaskObjectiveInteract:_CleanEvents()
  self:_CleanGeneralEvents()
  self:_CleanTriggerEvents()
  self:_CleanTalkables()
end

function SabTaskObjectiveInteract:_Cleanup(bForceUnload, bSaveLoad)
  local tConfig = self:GetConfig()
  self:_CleanEvents()
  if self._bHasInteriorCallbacks and tConfig and tConfig.sInteriorName then
    Util.CancelInteriorLoadCallback(tConfig.sInteriorName)
  end
  if self._UsedExteriorBlipLocation then
    self:_CleanupExteriorBlip()
  end
  if tConfig.sTaskSubType and string.upper(tConfig.sTaskSubType) == "COURIERMESSAGE" then
    print("cleaning up message ", self:GetMyMissionName())
    Util.RemoveAvailableMissionMessage(self:GetMyMissionName())
  end
  if self._eAutoFire then
    Util.KillEvent(self._eAutoFire)
    self._eAutoFire = nil
  end
  if self:IsActive() then
    if self.tInteractAttrPts and self.bDynamicAttrPt then
      for i, v in pairs(self.tInteractAttrPts) do
        self:CleanUpUsePt(v)
        self.tInteractAttrPts[i] = nil
      end
    end
    if self._tInvestigateFocusPts then
      for key, FPID in pairs(self._tInvestigateFocusPts) do
        if self._tInvestigateFocusPts[key] then
          FocusPt.Delete(FPID)
        end
      end
      self._tInvestigateFocusPts = {}
    end
    SabTaskObjective._Cleanup(self, bForceUnload, bSaveLoad)
  end
end

function SabTaskObjectiveInteract:CallbackConversationCompleteAutoComplete(tResponseData)
  self:SubObjectiveCompleted()
end

function SabTaskObjectiveInteract:CallbackConversationComplete(tResponseData)
  if not self or self == -1 then
    return
  end
  local tConfig = self:GetConfig()
  if tResponseData then
    if tResponseData[1] == cCONVERSATION_ACCEPTED then
      self._bAcceptDeclined_SabTaskObjectiveInteract = true
      self._bAccept_SabTaskObjectiveInteract = true
      self:Positive()
    elseif tResponseData[1] == cCONVERSATION_DECLINED then
      self._bAcceptDeclined_SabTaskObjectiveInteract = true
      self._Declined_SabTaskObjectiveInteract = true
    elseif tResponseData[1] == cCONVERSATION_INTERRUPTED then
      self:Negative()
    elseif tResponseData[1] == cCONVERSATION_FINISHED then
      local tCallbacks = self:GetConfig().tOnConversationComplete
      local tConfig = self:GetConfig()
      if type(tCallbacks) == "table" then
        for _, tCallback in ipairs(tCallbacks) do
          __UtilFunctions.CallWithOptionalArgs(tCallback[1], tCallback[2])
        end
      end
      if not self._bAcceptDeclined_SabTaskObjectiveInteract then
        self:Positive()
      elseif self._Declined_SabTaskObjectiveInteract then
        print("SabTaskObjectiveInteract:CallbackConversationComplete:: declined mission has been cancelled")
        self:Negative()
      elseif self._bAccept_SabTaskObjectiveInteract then
        print("SabTaskObjectiveInteract:CallbackConversationComplete:: accept mission should already be loading")
      else
        print("SabTaskObjectiveInteract:CallbackConversationComplete:: cCONVERSATION_FINISHED not handled in this conversation ", self:GetName())
      end
    elseif tResponseData[1] == cCONVERSATION_NOSTATUS then
      print("WARNING:: Conversation returned No_Status ", self:GetName(), " conversation file", self:GetConfig().sConvFile)
      if not _bAcceptDeclined_SabTaskObjectiveInteract then
        print("SabTaskObjectiveInteract:CallbackConversationComplete:: cCONVERSATION_NOSTATUS from neither an accept or decline", self:GetName())
        if self.bTalkableConversationReset and tConfig.bStarterFlag then
          self:Positive()
        else
          self:Positive()
        end
      end
    else
      Util.Assert(false, "something incorrect has occured in conversation callback ")
      self:Positive()
    end
  else
    print("WARNING:No response data returned for ", self:GetName())
  end
end

function SabTaskObjectiveInteract:Positive()
  local tConfig = self:GetConfig()
  if tConfig.sStarter then
    print("DEBUG SabTaskObjectiveInteract:Positive :: removing interaction for ", tConfig.sStarter, self:GetName())
    StarterManager.RemoveInteractionTask(tConfig.sStarter)
  end
  self:SubObjectiveCompleted()
end

function SabTaskObjectiveInteract:Negative()
  if self.bTalkableConversationReset then
    print("reactivating conversation")
    SabTaskMission.ReActivateInteraction(nil, self)
  else
    print("cancel convervesation from non-starter conversation")
    self:Cancel()
  end
end

function SabTaskObjectiveInteract:SetupUseActor(hTarget, etype)
  local thisEventType = etype or "OnActorUsed"
  if not hTarget then
    self:WarningNil("hTarget", "SabTaskObjectiveInteract:SetupUseActor")
    return
  else
    hTarget = WRAPPER_CheckForHandle(hTarget)
  end
  local tEvent = {
    EventType = thisEventType,
    EventName = self:GetName() .. "_TalkEvent",
    Target = hTarget
  }
  local fCallbackFunction = "SabTaskObjectiveInteract.CompleteActorUse"
  self:RegisterEvent(Util.CreateEvent(tEvent, fCallbackFunction, self, {hTarget}))
end

function SabTaskObjectiveInteract:CompleteActorUse(tArgs, test)
  local tConfig = self:GetConfig()
  local hActor
  if type(tArgs) == "table" then
    hActor = tArgs[1]
  else
    hActor = tArgs
  end
  local bIsAttrPt = Object.IsAttrPt(hActor)
  local HumanHealth = Object.GetHealth(hActor)
  HumanHealth = HumanHealth or 1
  if hActor and self:IsActive() and 0 < HumanHealth then
    if tConfig.bEscalationDenial and not tConfig.bInteriorTask and not IsEscalationFree() then
      self:ResetThisTask()
      return
    else
      local sConversation
      self:SetUIBlips(hActor, false)
      if tConfig.bHelpMode then
        sConversation = tConfig.sHintFile
      else
        sConversation = tConfig.sConvFile
      end
      if sConversation then
        Cin.PlayConversation(sConversation, "SabTaskObjectiveInteract.CallbackConversationComplete", self)
      elseif tConfig.sToolTipID then
        self:ShowToolTip(tConfig.sToolTipID)
      end
      if bIsAttrPt then
        AttractionPt.EnableUse(hActor, false)
      elseif Actor.IsTalkable(hActor) then
        Actor.SetTalkable(hActor, false)
      end
      self:SubObjectiveCompleted()
    end
    return
  elseif hActor and self:IsActive() and HumanHealth < 1 then
    print("TALKABLE IS DEAD...ZOINKS!")
    if Actor.IsTalkable(hActor) then
      Actor.SetTalkable(hActor, false)
    end
    self:SubObjectiveCompleted()
  end
end

function SabTaskObjectiveInteract:ActivateTalk()
end

function SabTaskObjectiveInteract:DeactivateTalk()
  if tConfig.sConvFile then
    self:SetQuota(self:GetQuota() - 1)
  end
end

function SabTaskObjectiveInteract:_SetupMessage()
  local tConfig = self:GetConfig()
  local sMessage = self:GetLocalizedText(tConfig.MessageID)
  local sConvName = tConfig.ConvName or ""
  local MsgType = tConfig.MsgType or cMESSAGETYPE_DEFAULT
  local priority = tConfig.Priority or cMESSAGEPRIORITY_DEFAULT
  local DelayTimer = tConfig.DelayTimer or 3
  local WayPoint = tConfig.WayPoint
  if priority > cMESSAGEPRIORITY_HIGH then
    priority = cMESSAGEPRIORITY_HIGH
  end
  sMessage = sMessage or "Set MessageID in: " .. self:GetName()
  if string.upper(tConfig.sTaskSubType) == "COURIERMESSAGE" then
    Util.AddMissionMessage(self:GetMyMissionName(), sConvName, sMessage, MsgType, priority, DelayTimer, tConfig.sBlockingSpore, "SabTaskObjectiveInteract.OnAttemptMessage", "SabTaskObjectiveInteract.OnDeliveredMessage", "SabTaskObjectiveInteract.OnReadMessage", self, {
      self:GetName()
    })
  else
    Util.Assert(false, "CFrench: no subtype designated for Interact message, i should not have reached here")
  end
end

function SabTaskObjectiveInteract:DisplayMessage(sMessage, sConvNameForVO, MsgType)
  Util.DisplayMissionMessage(sMessage, MsgType, sConvNameForVO)
  EVENT_Timer("SabTaskObjectiveInteract.MessageDelivered", self, 2)
end

function SabTaskObjectiveInteract:OnAttemptMessage(missionname)
  if not self then
    return
  end
  if self and type(self) == "number" then
    Util.Assert(false, "SabTaskObjectiveInteract.OnAttemptMessage self is a number")
    return
  end
  local tCallbacks = self:GetConfig().tOnAttempt
  local tConfig = self:GetConfig()
  if type(tCallbacks) == "table" then
    for _, tCallback in ipairs(tCallbacks) do
      __UtilFunctions.CallWithOptionalArgs(tCallback[1], tCallback[2])
    end
  end
  if self:IsActive() and tConfig.bCompleteOnAttempt then
    self:SubObjectiveCompleted()
  end
end

function SabTaskObjectiveInteract:OnDeliveredMessage(missionname)
  local tCallbacks = self:GetConfig().tOnDelivered
  local tConfig = self:GetConfig()
  if type(tCallbacks) == "table" then
    for _, tCallback in ipairs(tCallbacks) do
      __UtilFunctions.CallWithOptionalArgs(tCallback[1], tCallback[2])
    end
  end
  if self:IsActive() and tConfig.bCompleteOnDelivered then
    self:SubObjectiveCompleted()
  end
end

function SabTaskObjectiveInteract:OnReadMessage(missionname)
  print("OnReadMessage ", missionname)
  if self:IsActive() then
    self:SubObjectiveCompleted()
  end
end
