if SabTaskGameMaster == nil then
  SabTaskGameMaster = SabTask:Create()
  SabTaskGameMaster.bFlagAutoSave = false
  SabTaskGameMaster.tCleanIDTimers = {}
end

function SabTaskGameMaster:BuildMissionStub(MissionX)
  if MissionX and type(MissionX) ~= "string" then
    return
  end
  if MissionX and type(MissionX) == "string" and MissionX == "" then
    return
  end
  if not __UtilFunctions.GetTableFromNameSpace(MissionX) then
    require("Missions\\" .. MissionX)
  end
  local oMissionHeader = __UtilFunctions.GetTableFromNameSpace(MissionX)
  if oMissionHeader then
    local tConfig = oMissionHeader:GetConfig()
    if self.hOntheFlyStarterHandle then
      print("DEBUG:: Mission starter was added on the fly")
      tConfig.sStarter = self.hOntheFlyStarterHandle
      self.hOntheFlyStarterHandle = nil
    end
    local tMissionData = {
      sMissionID = MissionX,
      tDependencyList = SabTask:GetTableFromCopy(tConfig.tDependencyList),
      tUnlockList = SabTask:GetTableFromCopy(tConfig.tUnlockList),
      tDisabledMissionsList = SabTask:GetTableFromCopy(tConfig.tDisabledMissionsList),
      sStarter = tConfig.sStarter,
      sStarterAttrPt = tConfig.sStarterAttrPt,
      sConvFile = tConfig.sConvFile,
      sHintFile = tConfig.sHintFile,
      sStarterNode = tConfig.sStarterNode,
      sObjTextFile = tConfig.sObjTextFile,
      sInteriorScript = tConfig.sInteriorScript,
      bDisableMissionTitle = tConfig.bDisableMissionTitle,
      tSMEDNodes = SabTask:GetTableFromCopy(tConfig.tSMEDNodes),
      tStaticTags = SabTask:GetTableFromCopy(tConfig.tStaticTags),
      sArcID = tConfig.sArcID,
      bArcFinale = tConfig.bArcFinale,
      bArcBegin = tConfig.bArcBegin,
      bRepeatable = tConfig.bRepeatable,
      bFreeplay = tConfig.bFreeplay,
      bWorldEvent = tConfig.bWorldEvent,
      bStarterless = tConfig.bStarterless,
      MCDisplayID = tConfig.MCDisplayID,
      sToolTipID = tConfig.sToolTipID,
      bFinishRebuild = tConfig.bFinishRebuild,
      bMissionBonus = tConfig.bMissionBonus,
      bEscalationDenial = tConfig.bEscalationDenial,
      bCourier = tConfig.bCourier,
      bForceUnloadNodes = tConfig.bForceUnloadNodes,
      sSaveMissionNameID = tConfig.sSaveMissionNameID,
      ProximityStart = tConfig.ProximityStart,
      bUseOldAutofire = tConfig.bUseOldAutofire,
      bAutofireInterior = tConfig.bAutofireInterior,
      sHQStartPoint = tConfig.sHQStartPoint,
      bFreezeTimeScale = tConfig.bFreezeTimeScale,
      bSLOverrideFade = tConfig.bSLOverrideFade,
      bEscalationDenial = tConfig.bEscalationDenial,
      sActNameID = tConfig.sActNameID,
      MarkerHeight = tConfig.MarkerHeight,
      bDelayClean = tConfig.bDelayClean,
      sHQNextMissionStartPoint = tConfig.sHQNextMissionStartPoint,
      StarterIcon = tConfig.StarterIcon
    }
    self:AddToMissionStubList(tMissionData)
  else
    local warning = "WARNING: " .. MissionX .. " does not have a valid mission file"
    print(warning)
    Util.Assert(false, warning)
  end
end

function SabTaskGameMaster:AddOpenMission(sMissionname)
  print("DEBUG:: adding open mission ", sMissionname)
  table.insert(self.tOpenMissionList, sMissionname)
end

function SabTaskGameMaster:RemoveOpenMission(sMissionname)
  for i, v in pairs(self.tOpenMissionList) do
    if self.tOpenMissionList[i] == sMissionname then
      table.remove(self.tOpenMissionList, i)
      break
    end
  end
end

function SabTaskGameMaster:BuildOpenMissionList(bDEBUG)
  print("****************")
  local sActionPackage
  SabTaskGameMaster.tActivationList = {}
  for index, MissionTableX in pairs(self.tMissionStubList) do
    local i = 1
    if MissionTableX.tDependencyList then
      while i <= #MissionTableX.tDependencyList do
        if MissionTableX.tDependencyList[i] then
          local v = MissionTableX.tDependencyList[i]
          sActionPackage = v .. "_ActionPackage"
          if string.find(v, sOrToken) then
            if self:IsCompletedOrDependecy(v) or __gDEBUG then
              if __gDEBUG then
                print("DEBUG:: Removing mission dependency because of debugging")
              end
              table.remove(MissionTableX.tDependencyList, i)
            end
          elseif self:IsCompletedMission(sActionPackage) then
            table.remove(MissionTableX.tDependencyList, i)
          else
            i = i + 1
          end
        else
          i = i + 1
        end
      end
    end
    sActionPackage = MissionTableX.sMissionID .. "_ActionPackage"
    local sID = MissionTableX.sMissionID
    if #MissionTableX.tDependencyList == 0 and not self:IsInOpenList(sID) and not self:IsCompletedMission(sActionPackage) then
      self:AddOpenMission(sID)
      table.insert(SabTaskGameMaster.tActivationList, MissionTableX)
    elseif __gDEBUG then
      print("DEBUG ONLY!!!!!!")
      self:AddOpenMission(sID)
      table.insert(SabTaskGameMaster.tActivationList, MissionTableX)
    else
      print("did not continue activation", sActionPackage)
    end
  end
  for i, MissionTableX in pairs(SabTaskGameMaster.tActivationList) do
    print("SetupActivated from tActivationList list ", MissionTableX.sMissionID)
    self:SetupActivated(MissionTableX)
  end
  local i = 1
  while i <= #self.tMissionStubList do
    if self.tMissionStubList[i] and self.tMissionStubList[i].sMissionID then
      local ap = self.tMissionStubList[i].sMissionID .. "_ActionPackage"
      if self:IsCompletedMission(ap) or self:IsInOpenList(self.tMissionStubList[i].sMissionID) then
        table.remove(self.tMissionStubList, i)
      else
        i = i + 1
      end
    else
      i = i + 1
    end
  end
  if __gDEBUG then
    print("DEBUG MISSION MODE")
    __gDEBUG = false
  end
  if #self.tOpenMissionList == 0 then
    Render.FadeTo(0, 0, 0, 0, 0)
    print("DEBUG:: no more missions available")
  end
  if SabTaskGameMaster.bFlagAutoSave then
    print("**AUTOSAVE**")
    SaveLoad.ClearSnapshot()
    SabTaskGameMaster.bFlagAutoSave = false
    SaveLoad.CreateAutoSave(self)
  else
    SabTaskGameMaster.PostAutoSave(self)
  end
end

function SabTaskGameMaster:PostAutoSave()
  SabTaskGameMaster.tActivationList = nil
  if g_bDEBUG_DISABLE_NEXT_MISSION then
    print("DEBUG:: the mission manager has been told to not startup any more missions!")
  else
    SabTaskGameMaster:WakePotentialMissions()
  end
end

function SabTaskGameMaster:Setup()
  self:Configure({
    sGameName = "Saboteur Game",
    sName = "Saboteur Game"
  })
  self.bDryUpMissions = false
  self.bSOEMissionLockOut = false
  self.bMiniArcLockOut = false
  self.sActiveArc = ""
  self.oActiveGameplayMission = nil
  StarterManager.InitList()
  InteriorManager.InitList()
  RewardsManager.InitList()
  for i, v in pairs(InteriorManager.InteriorList) do
    Util.AddInterior(v)
    if v.tFloors then
      for j, tFloorTable in pairs(v.tFloors) do
        Util.SetInteriorFloorData(v.sName, j - 1, tFloorTable.fRangeLow, tFloorTable.fRangeHi, tFloorTable.fAreaSize, tFloorTable.fPosX, tFloorTable.fPosZ, tFloorTable.fDimension)
      end
    end
  end
  InteriorManager.LoadAllExteriorBlips()
end

function SabTaskGameMaster:PreActivationCheck(MissionData)
end

function SabTaskGameMaster:SetupActivated(MissionData)
  local oMissionActionPackage = SabTaskMission:Create()
  oMissionActionPackage:Configure({
    sName = MissionData.sMissionID .. "_ActionPackage",
    sID = MissionData.sMissionID,
    oParent = self,
    sTaskType = "SabTaskMission",
    sStarter = MissionData.sStarter,
    sStarterNode = MissionData.sStarterNode,
    tSMEDNodes = SabTask:GetTableFromCopy(MissionData.tSMEDNodes),
    tStaticTags = SabTask:GetTableFromCopy(MissionData.tStaticTags),
    tUnlockList = SabTask:GetTableFromCopy(MissionData.tUnlockList),
    tDisabledMissionsList = SabTask:GetTableFromCopy(MissionData.tDisabledMissionsList),
    sObjTextFile = MissionData.sObjTextFile,
    sArcID = MissionData.sArcID,
    bArcFinale = MissionData.bArcFinale,
    bArcBegin = MissionData.bArcBegin,
    bRepeatable = MissionData.bRepeatable,
    bFreeplay = MissionData.bFreeplay,
    bWorldEvent = MissionData.bWorldEvent,
    bStarterless = MissionData.bStarterless,
    MCDisplayID = MissionData.MCDisplayID,
    bFinishRebuild = MissionData.bFinishRebuild,
    bDisableMissionTitle = MissionData.bDisableMissionTitle,
    bCourier = MissionData.bCourier,
    bForceUnloadNodes = MissionData.bForceUnloadNodes,
    sSaveMissionNameID = MissionData.sSaveMissionNameID,
    sHQStartPoint = MissionData.sHQStartPoint,
    bFreezeTimeScale = MissionData.bFreezeTimeScale,
    bSLOverrideFade = MissionData.bSLOverrideFade,
    sActNameID = MissionData.sActNameID,
    bDelayClean = MissionData.bDelayClean,
    sHQNextMissionStartPoint = MissionData.sHQNextMissionStartPoint,
    StarterIcon = MissionData.StarterIcon,
    tOnComplete = {
      {
        SabTaskGameMaster.SafetyCheck,
        {self}
      },
      {
        SabTaskGameMaster.DelayedRebuild,
        {self, oMissionActionPackage}
      },
      {
        SabTaskGameMaster._FastClean,
        {
          self,
          MissionData.sMissionID,
          false,
          MissionData.bDelayClean
        }
      }
    },
    tBriefingConfig = {
      tTgtInclude = {
        MissionData.sStarter
      },
      sConvFile = MissionData.sConvFile,
      sStarterAttrPt = MissionData.sStarterAttrPt,
      sHintFile = MissionData.sHintFile,
      sToolTipID = MissionData.sToolTipID,
      bEscalationDenial = MissionData.bEscalationDenial,
      ProximityStart = MissionData.ProximityStart,
      bUseOldAutofire = MissionData.bUseOldAutofire,
      bAutofireInterior = MissionData.bAutofireInterior,
      bEscalationDenial = MissionData.bEscalationDenial,
      MarkerHeight = MissionData.MarkerHeight
    },
    tGameplayConfig = {
      sTaskType = MissionData.sMissionID,
      tSMEDNodes = SabTask:GetTableFromCopy(MissionData.tSMEDNodes),
      tStaticTags = SabTask:GetTableFromCopy(MissionData.tStaticTags),
      tDisabledMissionsList = SabTask:GetTableFromCopy(MissionData.tDisabledMissionsList),
      bSLOverrideFade = MissionData.bSLOverrideFade
    },
    tOnCancel = {
      {
        SabTaskGameMaster.ONCANCELMISC,
        {SabTaskGameMaster}
      },
      {
        SabTaskGameMaster.SafetyCheck,
        {self}
      },
      {
        SabTaskGameMaster.DelayedRebuild,
        {
          self,
          oMissionActionPackage,
          true
        }
      },
      {
        SabTaskGameMaster._FastClean,
        {
          self,
          MissionData.sMissionID,
          true,
          false,
          true
        }
      }
    }
  })
  oMissionActionPackage.bActionPackage = true
  if not oGameMaster.oActiveGameplayMission and not MissionData.bWorldEvent then
    oGameMaster:RegisterPotentialMission(oMissionActionPackage)
  elseif MissionData.bWorldEvent or MissionData.bStarterless then
    oGameMaster:RegisterPotentialMission(oMissionActionPackage)
  else
    local errmsg = "ERROR: MISSION DATA IS BUILDING WITHOUT CLEARING oActiveGameplayMission = " .. oGameMaster.oActiveGameplayMission:GetName()
    Util.Assert(false, errmsg)
    oMissionActionPackage:Activated()
  end
end

function SabTaskGameMaster:SafetyCheck()
  if self.eCleanTimer then
    Util.KillEvent(self.eCleanTimer)
    self.eCleanTimer = nil
  end
end

function SabTaskGameMaster:DelayedRebuild(oMissionActionPackage, bCancelled)
  if not __bHaltRebuildMissions then
    local tConfig = oMissionActionPackage:GetConfig()
    local bRebuild = false
    if not tConfig.bWorldEvent or tConfig.bFinishRebuild and not bCancelled then
      print("rebuild open mission list")
      EVENT_Timer("SabTaskGameMaster.BuildOpenMissionList", self, 0.75)
    else
    end
  else
    print("WARNING:: __bHaltRebuildMissions is set to TRUE no more missions are going to build")
  end
end

function SabTaskGameMaster:DelayedClean(sFileName, bRestore)
  self.eCleanTimer = EVENT_Timer("SabTaskGameMaster.NilMissionFile", self, 20, {sFileName, bRestore})
end

function SabTaskGameMaster:_FastClean(sFileName, bRestore, bDelay, bSaveLoad)
  if bDelay then
    SabTaskGameMaster.DelayedClean(self, sFileName, bRestore)
  else
    local oAP = GetAPByName(sFileName)
    if oAP then
      oAP.bMarkedForNil = true
      print(" ** " .. sFileName .. " marked for deletion")
    end
    Util.CreateEvent({EventType = "TimerEvent", Time = 0.25}, "SabTaskGameMaster.NilMissionFile", self, {
      sFileName,
      bRestore,
      bSaveLoad
    })
  end
end

function SabTaskGameMaster:NilMissionFile(sFileName, bRestore, bSaveLoad)
  local oAP = GetAPByName(sFileName)
  local ID
  if oAP then
    ID = oAP._SELFTABLE_ID
  end
  if bSaveLoad then
    oGameMaster:CleanIDs(sFileName, ID)
  elseif not SabTaskGameMaster.tCleanIDTimers[sFileName] then
    SabTaskGameMaster.tCleanIDTimers[sFileName] = EVENT_Timer("SabTaskGameMaster.CleanIDs", self, 20, {sFileName, ID})
  end
  if oGameMaster then
    oGameMaster:RemoveOpenMission(sFileName)
    oGameMaster:_PostChildClean(sFileName .. "_ActionPackage")
  end
  print(sFileName, " nilling mission file")
  _G[sFileName] = nil
  package.loaded["Missions\\" .. sFileName] = nil
  if bRestore and not __bHaltRebuildMissions then
    print("restoring mission ", sFileName)
    oGameMaster:UnlockPotentialMissions(sFileName)
  end
end

function SabTaskGameMaster:ClearAllIDTimers()
  if SabTaskGameMaster.tCleanIDTimers then
    for sFileName, TIMERID in pairs(SabTaskGameMaster.tCleanIDTimers) do
      Util.KillEvent(TIMERID)
    end
  end
  SabTaskGameMaster.tCleanIDTimers = {}
end

function SabTaskGameMaster:CleanIDs(sName, APID)
  print("cleaning ids ", sName)
  SabTask:CleanMasterTableEntry(sName)
  SabTask:RemoveFromMasterIDList(sName)
  if SabTaskGameMaster.tCleanIDTimers[sName] then
    SabTaskGameMaster.tCleanIDTimers[sName] = nil
  end
end

function SabTaskGameMaster:UnlockPotentialMissions(vMission)
  if type(vMission) == "table" then
    for i, sMissionID in pairs(vMission) do
      if sMissionID ~= "" and not self:IsInOpenList(sMissionID) and not self:IsCompletedMission(sMissionID) then
        self:BuildMissionStub(sMissionID)
      end
    end
  elseif sMissionID ~= "" and not self:IsInOpenList(vMission) and not self:IsCompletedMission(vMission) then
    self:BuildMissionStub(vMission)
  end
end

function SabTaskGameMaster:DisableMissions(vMission)
  if type(vMission) == "table" then
    for i, sMissionname in pairs(vMission) do
      if not self:IsInDisabledList(sMissionname) and not self:IsCompletedMission(sMissionname) then
        print("DEBUG:: Disabled Mission", sMissionname)
        table.insert(self.tDisabledMissionsList, sMissionname)
        local oMission = GetAPByName(sMissionname)
        if oMission then
          SabTaskGameMaster:RemovePotentialMission(oMission)
          oMission:MissionSetState(_DISABLED)
        end
      end
    end
  elseif not self:IsInDisabledList(vMission) and not self:IsCompletedMission(sMissionname) then
    table.insert(self.tDisabledMissionsList, vMission)
    local oMission = GetAPByName(vMission)
    print("DEBUG:: Disabled Mission", vMission)
    if oMission then
      SabTaskGameMaster:RemovePotentialMission(oMission)
      oMission:MissionSetState(_DISABLED)
    end
  end
end

function SabTaskGameMaster:AddToMissionStubList(tNewMissionStub)
  if not tNewMissionStub then
    print("Mission:AddToMissionStubList( ) -- no mission provided. ", tNewMissionStub)
  elseif not self:IsInMissionStubList(tNewMissionStub) then
    table.insert(self.tMissionStubList, tNewMissionStub)
  end
end

function SabTaskGameMaster:IsInMissionStubList(tMissionStub)
  for i, v in pairs(self.tMissionStubList) do
    if self.tMissionStubList[i] == tMissionStub.sMissionID then
      return true
    end
  end
  return false
end

function SabTaskGameMaster:RemoveStubMission(sMissionID)
  for i, v in pairs(self.tMissionStubList) do
    if self.tMissionStubList[i] == sMissionID then
      table.remove(self.tMissionStubList, i)
    end
  end
end

function SabTaskGameMaster:SuppressPotentialMissions(oActiveMission, bSaveLoad)
  if oActiveMission then
    SabTaskGameMaster:UnregisterPotentialMission(oActiveMission)
  end
  for i, sMissionName in pairs(self._tPotentialMissionIDList) do
    local oSuppressMission = GetAPByName(sMissionName)
    if not oSuppressMission then
      Util.Assert(false, "SuppressPotentialMissions Broken! ", sMissionName, " does not have an action package")
    end
    if oSuppressMission then
      local tConfig = oSuppressMission:GetConfig()
      if not tConfig.bWorldEvent then
        print("DEBUG:: Suppressing mission :" .. sMissionName)
        oSuppressMission:SuppressTask(bSaveLoad)
      elseif bSaveLoad then
        print("DEBUG:: Suppressing a world event, i hope we're saving ", tConfig.sID)
        oSuppressMission:SuppressTask(bSaveLoad)
      end
    end
  end
end

function SabTaskGameMaster:UnregisterPotentialMission(oMission)
  local sName = oMission:GetName()
  local sID = oMission:GetID()
  local tConfig = oMission:GetConfig()
  Common.RemoveTableItem(self._tPotentialMissionIDList, sID)
  oMission:MissionSetState(_ACTIVE)
end

function SabTaskGameMaster:RemovePotentialMission(oMission)
  local sName = oMission:GetName()
  local sID = oMission:GetID()
  local tConfig = oMission:GetConfig()
  Common.RemoveTableItem(self._tPotentialMissionIDList, sID)
end

function SabTaskGameMaster:RegisterPotentialMission(oMission)
  local sName = oMission:GetName()
  local sID = oMission:GetID()
  local tConfig = oMission:GetConfig()
  Common.InsertTableItem(self._tPotentialMissionIDList, sID, true)
  oMission:MissionSetState(_POTENTIAL)
end

function SabTaskGameMaster:WakePotentialMissions()
  local i = 1
  while i <= #self._tPotentialMissionIDList do
    local sMissionName = self._tPotentialMissionIDList[i]
    local sTestArcID = ""
    local bArcIDCheck = false
    local oMission = GetAPByName(sMissionName)
    if not oMission then
      print("WakePotentialMissions: tis broken")
      Util.Assert(false, "WakePotentialMissions:Freedom broke dis ")
    end
    if oMission then
      local tConfig = SabTask.GetConfig(oMission)
      if oGameMaster.sActiveArc and oGameMaster.sActiveArc ~= "" then
        if tConfig.sArcID == oGameMaster.sActiveArc then
          bArcIDCheck = true
        else
        end
      else
        bArcIDCheck = true
      end
      if (oMission:MissionGetState() == _SUPPRESSED or oMission:MissionGetState() == _CANCELLED or oMission:MissionGetState() == _POTENTIAL) and bArcIDCheck and not self:IsInDisabledList(sMissionName) then
        oMission:MissionSetState(_POTENTIAL)
        if not oMission:IsActive() then
          print("activating from potential list ", oMission:GetName())
          local bStarterIsHidden = false
          if tConfig.sStarter and StarterManager.Save_IsStarterHiddenList[tConfig.sStarter] and StarterManager.Save_IsStarterHiddenList[tConfig.sStarter].bHidden and not __gDEBUG_REWARDS then
            bStarterIsHidden = true
          end
          if bStarterIsHidden then
            print("WARNING :: starter " .. tConfig.sStarter .. " is hidden , not activating mission ")
          else
            oMission:Activated()
          end
          i = i + 1
        else
          i = i + 1
        end
      elseif oMission:MissionGetState() == _POTENTIAL then
        print("DEBUG:: THIS IS THE CASE YOU ARE LOOKING FOR FREEDOM , CUPCAKES AND MILK ALL AROUND ", oMission:GetName())
        print("DEBUG:: in wake potential ")
        i = i + 1
      elseif self:IsInDisabledList(sMissionName) or oMission:MissionGetState() == _DISABLED then
        print("ignoring disabled mission ", sMissionName)
        i = i + 1
      else
        print("DEBUG:: i don't understand whats happening right here but that shouldn't really be a big surprise ", oMission:GetName())
        Util.Assert(false, " i don't understand whats happening right here but that shouldn't be a big surprise - cfrench aka freedumb")
        i = i + 1
      end
    else
      i = i + 1
    end
  end
end

function SabTaskGameMaster:_PostChildClean(ap)
  self:RemoveChild(ap)
end

function SabTaskGameMaster:IsCompletedOrDependecy(sOrString)
  local safetyvalve = 0
  local sParsedOrString
  local OrIndex = 0
  local OrTokenSize = string.len(sOrToken)
  local bFound = false
  
  function TestOrComplete(sMission)
    local sActionPackage = sMission .. "_ActionPackage"
    if self:IsCompletedMission(sActionPackage) then
      bFound = bFound or true
    end
  end
  
  while string.find(sOrString, sOrToken) do
    OrIndex = string.find(sOrString, sOrToken)
    sParsedOrString = string.sub(sOrString, 1, OrIndex - 1)
    sOrString = string.sub(sOrString, string.len(sParsedOrString) + OrTokenSize + 1, -1)
    TestOrComplete(sParsedOrString)
    if not string.find(sOrString, sOrToken) then
      sParsedOrString = sOrString
      TestOrComplete(sParsedOrString)
    end
    safetyvalve = safetyvalve + 1
    if 50 < safetyvalve then
      print("WARNING: Dependency parser failed to exit properly")
      break
    end
  end
  return bFound
end

function SabTaskGameMaster:CheckForReset(oMission)
  local oGM = oGameMaster
  if oGM.bResetMission and oMission and oMission:GetName() == oGM.sResetMissionName then
    if oGM.tResetMissionData then
      for _, tCallback in ipairs(oGM.tResetMissionData) do
        __UtilFunctions.CallWithOptionalArgs(tCallback[1], tCallback[2])
      end
    end
    oGM.sResetMissionName = nil
    oGM.tResetMissionData = nil
    oGM.bResetMission = false
  end
end

function SabTaskGameMaster.AddToMissionPool(sMissionName)
  if not IsRealMissionActive() and not __gDEBUG_SETCOMPLETES then
    oGameMaster:UnlockPotentialMissions(sMissionName)
    oGameMaster:BuildOpenMissionList(bDebug)
  else
    table.insert(SabTask._tSpecialCaseUnlockedList, sMissionName)
  end
end

function SabTaskGameMaster:ONCANCELMISC()
  if not Actor.HasLabel(hSab, "DisableHQReturn") then
    Actor.SetLabel(hSab, "DisableHQReturn", false)
  end
end

function LoadMission(sMissionName, hOntheFlyStarterHandle, bWE, bDebug)
  local oGM = oGameMaster
  print("DEBUG:: LoadMission ", sMissionName)
  oGameMaster.hOntheFlyStarterHandle = hOntheFlyStarterHandle
  if not oGameMaster.hOntheFlyStarterHandle and not bWE then
    bDebug = true
    __gDEBUG = true
    __gDEBUG_REWARDS = true
  end
  local bOtherMissionActive
  if not bWE then
    bOtherMissionActive = CancelCurrentMission()
  else
  end
  if bDebug then
    print("debugging load mission")
  end
  oGM:UnlockPotentialMissions(sMissionName)
  if not bOtherMissionActive then
    oGM:BuildOpenMissionList(bDebug)
  end
end

function CompleteCurrentMission()
  if oGameMaster.oActiveGameplayMission then
    local o = oGameMaster.oActiveGameplayMission
    o:_Complete()
  else
    print("No current active mission")
    return
  end
end

function CompleteCurrentTasks()
  if oGameMaster.oActiveGameplayMission then
    local o = oGameMaster.oActiveGameplayMission
    local tTasks = {}
    local tChildren = o:GetChildren()
    for i, v in pairs(tChildren) do
      tTasks[i] = tChildren[i]
    end
    for i, task in pairs(tTasks) do
      if task:IsActive() then
        task:_Complete()
      end
    end
  else
    print("No current active mission")
    return
  end
end

function CancelCurrentMission(bNow)
  oGameMaster:SafetyCheck()
  if oGameMaster.oActiveGameplayMission then
    local o = oGameMaster.oActiveGameplayMission
    if bNow then
      local oAP = o:GetActionPackage()
      if oAP and o:IsActive() then
        print("cancelling current mission now ", oAP:GetID())
        SaveLoad.ClearSnapshot()
        SabTask.ClearAllObjectiveMarkers()
        HUD.ClearAllObjectives()
        oAP:CancelNow()
      else
        Util.Assert(false, "Bad times in CancelCurrentMission freedumb")
      end
    elseif o:IsActive() then
      SaveLoad.ClearSnapshot()
      SabTask.ClearAllObjectiveMarkers()
      HUD.ClearAllObjectives()
      o:Cancel()
    elseif o._StartLoadGameplayState then
      print("CancelCurrentMission:this mission is in a flux loading state")
    end
    return true
  else
    print("CancelCurrentMission No current active mission ")
    HUD.ClearAllObjectives()
    SabTask.ClearAllObjectiveMarkers()
    SaveLoad.ClearSnapshot()
    return nil
  end
end

function ResetCurrentMission()
  local oGM = oGameMaster
  print("DEBUG:: Reset Mission ")
  local bOtherMissionActive
  if oGM.oActiveGameplayMission then
    local o = oGameMaster.oActiveGameplayMission
    local tConfig = o:GetParent():GetConfig()
    local tNodes = {}
    oGM.bResetMission = true
    oGM.sResetMissionName = o:GetParent():GetName()
    o:Cancel()
  else
    print("ERROR:: No current active mission to reset")
    return nil
  end
end

function IsRealMissionActive()
  if oGameMaster.oActiveGameplayMission then
    return true
  else
    return false
  end
end

function SetDisableNextMission()
  g_bDEBUG_DISABLE_NEXT_MISSION = true
end
