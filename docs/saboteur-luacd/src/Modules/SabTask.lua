if SabTask == nil then
  gMasterSelfTable = {}
  gMSTNextIndex = 1
  _Development = false
  SabTask = {
    tMissionStubList = {},
    tOpenMissionList = {},
    tLoadedNodeList = {},
    _tMissionLoadingNodes = {},
    _tMasterMarkerList = {},
    tCompletedMissionList = {},
    tDisabledMissionsList = {},
    _tMiscSaveTable = {},
    _tPotentialMissionIDList = {},
    _tSpecialCaseUnlockedList = {},
    _tActiveMissionList = {},
    tSelfTableList_Debug = {},
    tGlobalMissionDataSaves = {},
    _saveversion = "SV05",
    _tMASTERSELFIDLISTOFLISTS = {}
  }
end

function SabTask.Create(mModule)
  self = {}
  setmetatable(self, {__index = mModule})
  self._tChildren = {}
  self._tConfig = {}
  self._SELFTABLE_ID = gMSTNextIndex
  gMasterSelfTable[self._SELFTABLE_ID] = self
  gMSTNextIndex = gMSTNextIndex + 1
  local returnself = self
  self = nil
  return returnself
end

function SabTask:DeleteTask()
  print("TEST! --  deleting self task ", self:GetName())
  print("removing self from masterlist ", self._SELFTABLE_ID)
  gMasterSelfTable[self._SELFTABLE_ID] = nil
end

function SabTask.GetSelfFromID(id)
  return gMasterSelfTable[id]
end

function SabTask:CreateTask(tConfig)
  local oTask
  if self:DoesTaskAlreadyExist(tConfig.sName) then
    print("DEBUG :: Attempting to activate an already existing task ", self:GetName(), " ", tConfig.sName)
    return
  end
  if not self:CheckTaskDepends(tConfig.tDependencyList) then
    print("DEBUG :: all task dependencies have not been met for this task to be created ", tConfig.sName)
    return
  end
  if tConfig.sTaskType then
    local oModule = __UtilFunctions.GetTableFromNameSpace(tConfig.sTaskType)
    oTask = oModule:Create()
  else
    oTask = SabTask:Create()
    print("Warning: creating default module, none defined")
  end
  oTask._bDISABLETONCOMPLETETABLE = false
  oTask:Configure(tConfig)
  oTask:Configure({oParent = self})
  oTask:BuildFoundation()
  return oTask
end

function SabTask:Configure(tConfig)
  if type(tConfig) ~= "table" then
    print("Warning: Did not pass a table to SabTask:Configure")
    return false
  end
  local bIsLatent = self:IsLatent()
  local bIsActive = self:IsActive()
  if bIsLatent then
    for key, value in pairs(tConfig) do
      self._tConfig[key] = value
    end
    if tConfig.oParent then
      tConfig.oParent:AddChild(self)
    end
    self:AddToMasterIDList()
    return true
  elseif bIsActive then
    print("Configuring already active task ", self:GetName())
    for k, v in pairs(tConfig) do
      self._tConfig[k] = v
    end
    if tConfig.oParent then
      print("already reattaching task to parent, could be bad times, i don't know , i'm crazy", self:GetName(), " parent ", tConfig.oParent:GetName())
      tConfig.oParent:AddChild(self)
    end
  else
    print("HEY TRYING TO CONFIG SOMETHING WRONG HERE MAYBE COMPLETED? ", self:GetName())
    for key, value in pairs(tConfig) do
      self._tConfig[key] = value
    end
    if tConfig.oParent then
      tConfig.oParent:AddChild(self)
    end
    return true
  end
end

function SabTask:AddToMasterIDList()
  local oAP = self:GetActionPackage()
  if oAP then
    for i, tMissionTable in pairs(SabTask._tMASTERSELFIDLISTOFLISTS) do
      if tMissionTable.Name == oAP:GetID() then
        table.insert(tMissionTable.IDLIST, self._SELFTABLE_ID)
      end
    end
  end
end

function SabTask:IsInMasterIDList()
  local oAP = self:GetActionPackage()
  if oAP then
    for i, tMissionTable in pairs(SabTask._tMASTERSELFIDLISTOFLISTS) do
      if tMissionTable.Name == oAP:GetID() then
        return true
      end
    end
  end
  return false
end

function SabTask:RemoveFromMasterIDList(sName)
  local i = 1
  while i <= #SabTask._tMASTERSELFIDLISTOFLISTS do
    local tMissionTable = SabTask._tMASTERSELFIDLISTOFLISTS[i]
    if tMissionTable and tMissionTable.Name == sName then
      table.remove(SabTask._tMASTERSELFIDLISTOFLISTS, i)
    else
      i = i + 1
    end
  end
end

function SabTask:CleanMasterTableEntry(sName)
  for i, tMissionTable in pairs(SabTask._tMASTERSELFIDLISTOFLISTS) do
    if sName and tMissionTable.Name == sName then
      for x, ID in pairs(tMissionTable.IDLIST) do
        gMasterSelfTable[ID] = -1
      end
      if tMissionTable.APID then
        if gMasterSelfTable[tMissionTable.APID] and gMasterSelfTable[tMissionTable.APID] ~= -1 and gMasterSelfTable[tMissionTable.APID]:IsActive() then
          Util.Assert("i knew this wouldn't work")
        else
          gMasterSelfTable[tMissionTable.APID] = -1
        end
      end
    end
  end
end

function SabTask:CleanMasterTable(bNoNil)
  for i, tMissionTable in pairs(SabTask._tMASTERSELFIDLISTOFLISTS) do
    for x, ID in pairs(tMissionTable.IDLIST) do
      local oTestme = gMasterSelfTable[ID]
      if oTestme and oTestme ~= -1 and bNoNil and type(oTestme) == "table" and oTestme.bActionPackage then
        print("not deleteing action package")
      else
        gMasterSelfTable[ID] = -1
      end
    end
  end
  if not bNoNil then
    SabTask._tMASTERSELFIDLISTOFLISTS = {}
  end
end

function SabTask:BuildFoundation()
  self:CheckForMasterSelf()
  if self:IsActive() then
    print("WARNING:: SabTask:BuildFoundation task is already active!", self:GetName())
    Util.Assert(false, "SabTask:BuildFoundation task is already active get CFrench")
  end
  local tConfig = self:GetConfig()
  self.Nodes2Load = 0
  self.__bCinematicNodeLoaded = false
  self.__bWaitingForCinematicLoad = false
  self:DynamicMemoryManagerVictims()
  self:DynamicMemoryManagerWinners()
  self.Nodes2Load = self:GetTotalLoadingNodeNumber(oGameMaster.tLoadedNodeList, tConfig.tSMEDNodes)
  self._tMissionLoadingNodes = {}
  if Common.IsNotEmptyTable(tConfig.tDeleteNodes) then
    print("** gonna load delete nodes maybe ", self:GetName())
    self:LoadNodes(tConfig.tDeleteNodes, _NODE_DELETETRIGGERS)
  end
  if Common.IsNotEmptyTable(tConfig.tSMEDNodes) then
    self:LoadNodes(tConfig.tSMEDNodes, _NODE_DYNAMIC)
  end
  if Common.IsNotEmptyTable(tConfig.tCinematicNodes) then
    if #tConfig.tCinematicNodes > 1 then
      Util.Assert("SCRIPTER:: Please only load 1 cinematic node", self:GetName())
    end
    self.__bWaitingForCinematicLoad = true
    local tOnlyOneCinematicNode = {
      tConfig.tCinematicNodes[1]
    }
    self:LoadNodes(tOnlyOneCinematicNode, _NODE_CINEMATIC)
  end
  if Common.IsNotEmptyTable(tConfig.tStaticTags) then
    self:LoadNodes(tConfig.tStaticTags, _NODE_COLBY)
  end
  if self.Nodes2Load == 0 and not self.__bWaitingForCinematicLoad then
    self:AllNodesLoaded()
  end
end

function SabTask:DynamicMemoryManagerVictims(bReset)
  local tConfig = self:GetConfig()
  local priority = 30
  if bReset then
    priority = -1
  end
  if tConfig.tMissionBPVictims and Common.IsNotEmptyTable(tConfig.tMissionBPVictims) then
    for _, BP in pairs(tConfig.tMissionBPVictims) do
      Util.SetDynamicPriority(BP, priority)
    end
  end
end

function SabTask:DynamicMemoryManagerWinners(bReset)
  local tConfig = self:GetConfig()
  local priority = 1000
  if bReset then
    priority = -1
  end
  if tConfig.tMissionBPWinners and Common.IsNotEmptyTable(tConfig.tMissionBPWinners) then
    for _, BP in pairs(tConfig.tMissionBPWinners) do
      Util.SetDynamicPriority(BP, priority)
    end
  end
end

function SabTask:Activated()
  self:SetState(_ACTIVE)
end

function SabTask:_Complete()
  local tConfig = self:GetConfig()
  local bForceUnload = false
  if tConfig.bForceUnloadNodes then
    bForceUnload = true
    print("forcing unload node", self:GetName())
  end
  self:_Cleanup(bForceUnload)
  self:SetState(_COMPLETE)
  if tConfig.bRepeatable then
    self:SetState(_LATENT)
  else
  end
end

function SabTask:Cancel(bSaveLoad)
  if not self.bActionPackage then
    self.bTaskFailed = true
  end
  if self._bGameplayTask then
    if self:IsActive() and self.MISSION_ONRESET then
      self.MISSION_ONRESET(self)
    end
    if self:IsActive() and self.MISSION_ONCANCEL then
      self.MISSION_ONCANCEL(self)
    end
    self:_CleanAllEvents()
  end
  local bForceUnload = true
  self:_Cleanup(bForceUnload, bSaveLoad)
  if self.bActionPackage then
    self.bPendingCancel = true
    EVENT_Timer("SabTask.CallbackSetStateCancel", self, 0.3)
  else
    self:CallbackSetStateCancel(_CANCELLED)
  end
end

function SabTask:CancelNow()
  if not self then
    return
  end
  if self and self ~= -1 and not self.bActionPackage then
    Util.Assert(false, "using CancelNow incorrectly, needs to be an actionpackage")
    print("using CancelNow incorrectly, needs to be an actionpackage")
    return
  end
  local oGameplay = GetMissionByName(self:GetID())
  self:_CleanAllEvents()
  self.bSaveLoad = true
  if oGameplay then
    oGameplay:Cancel(self.bSaveLoad)
  else
    print("------ SabTask:CancelNow gameplay task is already gone", self:GetName())
  end
end

function SabTask:_CleanAllEvents()
  local oGameplay = SabTask.GetGameplayTask(self)
  if oGameplay then
    print("SabTask:_CleanAllEvents")
    oGameplay:_CleanGeneralEvents()
    oGameplay:_CleanTriggerEvents()
    oGameplay:_CleanVehicleDeaths()
    local tChildren = oGameplay:GetChildren()
    if tChildren then
      for i, oChild in pairs(tChildren) do
        if oChild._CleanEvents then
          oChild:_CleanEvents()
        end
      end
    end
  else
    print("WARNING:Failed to get oGameplay in SabTask:_CleanAllEvents")
  end
end

function SabTask:CallbackSetStateCancel()
  if self.bActionPackage then
    self.bPendingCancel = false
  end
  self:SetState(_CANCELLED)
  if not self:IsActive() then
    self:ResetState()
  else
  end
end

function SabTask:GetConfig()
  return self._tConfig
end

function SabTask:SetState(newState, bIssueCallbacks)
  local nOldState = self:GetState()
  if nOldState == newState then
    return false
  end
  self.TaskState = newState
  local bIsLatent = self:IsLatent()
  local bIsActive = self:IsActive()
  local bIsCompleted = self:IsCompleted()
  local bIsCancelled = self:IsCancelled()
  if bIsCompleted or bIsCancelled then
    self:_SetChildrenState(newState)
  end
  bIssueCallbacks = __UtilFunctions.SetDefault(bIssueCallbacks, true)
  if bIssueCallbacks and not bIsLatent then
    local tCallbacks
    if bIsActive then
      tCallbacks = self:GetConfig().tOnActivate
    elseif bIsCompleted then
      if not self._bDISABLETONCOMPLETETABLE then
        tCallbacks = self:GetConfig().tOnComplete
      end
    elseif bIsCancelled then
      if self._bRESETTASK then
        tCallbacks = self:GetConfig().tOnReset
        self._bRESETTASK = false
      else
        tCallbacks = self:GetConfig().tOnCancel
      end
    end
    tCallbacks = tCallbacks or {}
    for _, tCallback in ipairs(tCallbacks) do
      __UtilFunctions.CallWithOptionalArgs(tCallback[1], tCallback[2])
    end
  end
  if not self.bActionPackage or bIsCompleted or bIsCancelled then
  end
  self._bDISABLETONCOMPLETETABLE = false
  return true
end

function SabTask:_ClearTables()
  local bIsCompleted = self:IsCompleted()
  local bIsCancelled = self:IsCancelled()
  local tConfig = self:GetConfig()
  if self:MissionGetState() == _COMPLETE then
    local tChildren = self:GetChildren()
    if tChildren then
      for i, oChild in pairs(tChildren) do
        print("clear your table oh my child ", oChild:GetName())
      end
    end
  end
end

function SabTask:ResetState()
  self:SetState(_LATENT)
end

function SabTask:_Cleanup(bForceUnload, bSaveLoad)
  if self:IsActive() then
    local tChildren = self:GetChildren()
    local tConfig = self:GetConfig()
    self:DynamicMemoryManagerVictims(true)
    for sChildName, oChild in pairs(tChildren) do
      if oChild:IsActive() then
        oChild:_Cleanup(bForceUnload)
      end
    end
    if self.bActionPackage then
      local tMissionNodeList = self:GetMissionNodeList()
      if not tConfig.bWorldEvent then
        SabTask.ClearAllObjectiveMarkers()
        HUD.ClearAllObjectives()
      end
      self:ClearAndUnloadNodeList(tMissionNodeList, bForceUnload)
    end
    self._tChildren = {}
  else
  end
end

function SabTask:SuppressTask(bSaveLoad)
  local tChildren = self:GetChildren()
  local bForceUnload = true
  self:_Cleanup(bForceUnload, bSaveLoad)
  self:SetState(_LATENT)
  if self.bActionPackage then
    self:MissionSetState(_SUPPRESSED)
  end
end

function SabTask:AddOnCancelCallback(fCallback)
  local tConfig = self:GetConfig()
  table.insert(tConfig.tOnCancel, {
    fCallback,
    {self}
  })
end

function SabTask:AddOnCompleteCallback(fCallback)
  local tConfig = self:GetConfig()
  table.insert(tConfig.tOnComplete, {
    fCallback,
    {self}
  })
end

function SabTask.AddChild(oParent, oChild)
  local tChildren = oParent:GetChildren()
  local sChildName = oChild:GetName()
  if not sChildName or oParent:GetName() ~= nil then
  end
  tChildren[sChildName] = oChild
end

function SabTask:RemoveChild(sChildName)
  local tChildren = self:GetChildren()
  if tChildren[sChildName] then
    tChildren[sChildName] = nil
  end
end

function SabTask:GetChild(sChildName)
  local tChildren = self:GetChildren()
  return tChildren[sChildName]
end

function SabTask:GetMissionTask(sChildName)
  local tChildren = self:GetChildren()
  return tChildren[sChildName]
end

function SabTask:IsMissionTaskActive(sChildName)
  local tChildren = self:GetChildren()
  local otask = tChildren[sChildName]
  if otask and otask:IsActive() then
    return true
  end
  return false
end

function SabTask:IsMissionTaskComplete(sChildName)
  local tChildren = self:GetChildren()
  local otask = tChildren[sChildName]
  if otask and otask:IsCompleted() then
    return true
  end
  return false
end

function SabTask:CleanMasterList()
  local tChildren = self:GetChildren()
  local tConfig = self:GetConfig()
  for sChildName, oChild in pairs(tChildren) do
    oChild:CleanMasterList()
  end
  if gMasterSelfTable[self._SELFTABLE_ID] then
    print("new removing self from masterlist ", self:GetName(), " ID ", self._SELFTABLE_ID)
    gMasterSelfTable[self._SELFTABLE_ID] = nil
  end
end

function SabTask:FindMissionTask(sTaskName)
  local oThisTask
  if not sTaskName then
    oThisTask = self
    print("No taskname supplied assuming self in SabTask:FindMissionTask , ", self:GetName())
  elseif self:GetName() == sTaskName then
    oThisTask = self
  else
    local oTask = self:GetMissionTask(sTaskName)
    if oTask ~= nil then
      oThisTask = oTask
    else
      oTask = self:GetParent():GetMissionTask(sTaskName)
      if oTask ~= nil then
        print("found a sibling")
        oThisTask = oTask
      else
        print("DEBUG:: Couldn't find task with name ", sTaskName, " in SabTask:FindMissionTask")
      end
    end
  end
  return oThisTask
end

function SabTask:_SetChildrenState(newState)
  local tChildren = self:GetChildren()
  for sChildName, oChild in pairs(tChildren) do
    oChild:SetState(newState, false)
  end
end

function SabTask:AddChildren(tChildren)
  for _, oChild in ipairs(tChildren) do
    self:AddChild(oChild)
  end
end

function SabTask:GetChildren()
  return self._tChildren
end

function SabTask:AllNodesLoaded(sNodeLoad)
  if sNodeLoad then
    self:SetNodeState(sNodeLoad, cSM_LOADED)
  end
  if self.Nodes2Load == nil then
    print("ERROR: why is self.Nodes2Load nil , tell chris french ", self:GetName())
  end
  if sNodeLoad then
    print("DEBUG:: Loading complete for ", sNodeLoad)
  end
  local bStillWaiting = self:AreNodesStillLoading()
  if not bStillWaiting then
    if self.__eLoadingWatcher then
      Util.KillEvent(self.__eLoadingWatcher)
      self.__eLoadingWatcher = nil
    end
    self.Nodes2Load = nil
    self:ReadyActivation()
  end
end

function SabTask:LoadNodes(tNodeTable, cNODETYPE)
  local tConfig = self:GetConfig()
  local bPrintDebugOnce = false
  if cNODETYPE == _NODE_DYNAMIC then
    self.__eLoadingWatcher = EVENT_Timer("SabTask.DynamicLoadingError", self, 60)
  end
  if tNodeTable then
    local tTableTracker = {}
    for k, v in pairs(tNodeTable) do
      if not Common.IsNodeLoaded(oGameMaster.tLoadedNodeList, tNodeTable[k]) and tNodeTable[k] ~= "" then
        if cNODETYPE == _NODE_COLBY then
          print("DEBUG:: Loading Static Node:", tNodeTable[k])
          __UtilFunctions.LoadStaticTag(tNodeTable[k], true)
        elseif cNODETYPE == _NODE_CINEMATIC then
          if WorldSMEDNodes.IsCinematicNodeLoaded(tNodeTable[k]) then
            print("DEBUG:: Cinematic Node Already Loaded:", tNodeTable[k])
            local tNodeLoding = {
              sNode = tNodeTable[k],
              state = cSM_LOADED,
              cNodeType = cNODETYPE
            }
            table.insert(self._tMissionLoadingNodes, tNodeLoding)
            self:CinematicNodeLoaded(tNodeTable[k])
          elseif WorldSMEDNodes.IsCinematicNodeLoading(tNodeTable[k]) then
            print("DEBUG:: Cinematic Node Is Currently Loading:", tNodeTable[k])
            local tNodeLoding = {
              sNode = tNodeTable[k],
              state = cSM_LOADING,
              cNodeType = cNODETYPE
            }
            table.insert(self._tMissionLoadingNodes, tNodeLoding)
            Util.RegisterLuaUpdate("SabTask.UpdateWaitForCinematicNode", self)
            self._bCinLuaUpdateActive = true
          else
            local tNodeLoding = {
              sNode = tNodeTable[k],
              state = cSM_LOADING,
              cNodeType = cNODETYPE
            }
            table.insert(self._tMissionLoadingNodes, tNodeLoding)
            print("DEBUG:: Loading Cinematic Node:", tNodeTable[k])
            WorldSMEDNodes.LoadCinematicNode(tNodeTable[k], "SabTask.CinematicNodeLoaded", self, {
              tNodeTable[k]
            })
          end
        elseif cNODETYPE == _NODE_DELETETRIGGERS then
          local sFullNode = tNodeTable[k] .. ".wsd"
          print("DEBUG:: ,  spawn delete trigger node ", sFullNode)
          Util.SpawnDeleteNode(sFullNode)
        else
          print("DEBUG:: Loading Dynamic Node:", tNodeTable[k])
          local tNodeLoding = {
            sNode = tNodeTable[k],
            state = cSM_LOADING,
            cNodeType = cNODETYPE
          }
          table.insert(self._tMissionLoadingNodes, tNodeLoding)
          __UtilFunctions.LoadNode(tNodeTable[k], "SabTask.AllNodesLoaded", self, {
            tNodeTable[k]
          })
        end
        table.insert(tTableTracker, tNodeTable[k])
        bPrintDebugOnce = true
        if oGameMaster and cNODETYPE ~= _NODE_DELETETRIGGERS then
          __UtilFunctions.AddLoadNode(oGameMaster.tLoadedNodeList, tNodeTable[k])
        end
      end
    end
    if Common.IsNotEmptyTable(tTableTracker) then
      self:InsertNodeList(self:GetMissionNodeList(), tTableTracker, cNODETYPE)
    end
    if bPrintDebugOnce then
    end
  end
end

function SabTask:UnloadNodes(tNodeTable, cNODETYPE, bForceUnload)
  local tConfig = self:GetConfig()
  if tNodeTable then
    for k, v in pairs(tNodeTable) do
      if Common.IsNodeLoaded(oGameMaster.tLoadedNodeList, tNodeTable[k]) and tNodeTable[k] ~= "" then
        if cNODETYPE == _NODE_COLBY then
          print("unloading static tag", tNodeTable[k], "  - forced=", bForceUnload)
          __UtilFunctions.UnloadStaticTag(tNodeTable[k], bForceUnload)
        elseif cNODETYPE == _NODE_CINEMATIC then
          print("unloading cinematic node ", tNodeTable[k])
          WorldSMEDNodes.UnloadCinematicNode(tNodeTable[k])
        else
          print("unloading dynamic", tNodeTable[k], "  - forced=", bForceUnload)
          self:SetNodeState(tNodeTable[k], cSM_UNLOADING)
          __UtilFunctions.UnloadNode(tNodeTable[k], bForceUnload)
        end
        if oGameMaster then
          __UtilFunctions.RemoveLoadNode(oGameMaster.tLoadedNodeList, tNodeTable[k])
        else
          self:WarningNil("oGameMaster", "SabTask:UnloadNode")
        end
      end
    end
  end
end

function SabTask:DynamicLoadingError()
  if self._tMissionLoadingNodes then
    for _, tNodeTable in pairs(self._tMissionLoadingNodes) do
      if tNodeTable.state == cSM_LOADING then
        if tNodeTable.sNode then
          local sError = "ERROR:Dynamic node:  " .. tNodeTable.sNode .. ".wsd   failed to load"
          Render.PrintMessage(sError, 240)
          print(sError)
          Util.Assert(false, sError)
        else
          print("ERROR::DynamicLoadingError , a nil node failed to load?  Get cfrench")
        end
      end
    end
  end
end

function SabTask:SetNodeState(sNodeName, STATE)
  if not sNodeName and not STATE then
    print("MissionManager Error, failed to pass sNodeName or STATE to SabTask:SetNodeState ", self:GetName())
    return
  end
  if self._tMissionLoadingNodes then
    for _, tNodeTable in pairs(self._tMissionLoadingNodes) do
      if string.upper(tNodeTable.sNode) == string.upper(sNodeName) then
        tNodeTable.state = STATE
        return
      end
    end
  end
end

function SabTask:UpdateWaitForCinematicNode()
  if self._bCinLuaUpdateActive and not WorldSMEDNodes.AreCinematicNodeLoading() then
    print("all cinematic nodes loaded")
    self.__bCinematicNodeLoaded = true
    self:AllNodesLoaded()
    self:_CleanupLuaUpdates()
  end
end

function SabTask:_CleanupLuaUpdates()
  if self._bCinLuaUpdateActive then
    print("Cleaning up lua cinematic updates")
    Util.UnregisterLuaUpdate("SabTask.UpdateWaitForCinematicNode")
    self._bCinLuaUpdateActive = false
  end
end

function SabTask:AreNodesStillLoading()
  if self.__bWaitingForCinematicLoad and not self.__bCinematicNodeLoaded then
    print("DEBUG:: Still waiting on a cinematic node")
    return true
  end
  if self._tMissionLoadingNodes then
    for _, tNodeTable in pairs(self._tMissionLoadingNodes) do
      if tNodeTable.state == cSM_LOADING and tNodeTable.cNodeType == _NODE_CINEMATIC and WorldSMEDNodes.IsCinematicNodeLoaded(tNodeTable.sNode) then
        print("Syncing Cinematic node up to proper state", tNodeTable.sNode)
        self:SetNodeState(tNodeTable.sNode, cSM_LOADED)
      end
      if tNodeTable.state == cSM_LOADING then
        return true
      end
    end
  else
  end
  return false
end

function SabTask:CinematicNodeLoaded(sNode)
  self.__bCinematicNodeLoaded = true
  self:AllNodesLoaded(sNode)
end

function SabTask:GetTotalLoadingNodeNumber(tMasterList, tNodeList)
  local tConfig = self:GetConfig()
  local total = 0
  if Common.IsNotEmptyTable(tNodeList) then
    for k, node in pairs(tNodeList) do
      local pNode
      if node.sNode then
        pNode = node.sNode
      else
        pNode = node
      end
      if pNode ~= "" and not Common.IsNodeLoaded(tMasterList, pNode) then
        total = total + 1
      end
    end
  end
  return total
end

function SabTask:ClearAndUnloadNodeList(tNodeList, bForceUnload)
  local oActionPackageConfig = self:GetActionPackage():GetConfig()
  local bForceStatic = oActionPackageConfig.bForceUnloadStatic
  local bForceDynamic = oActionPackageConfig.bForceUnloadDynamic
  if tNodeList then
    for i, tNodes in pairs(tNodeList) do
      local cNODETYPE
      if tNodeList[i].NodeType == "static" then
        cNODETYPE = _NODE_COLBY
        if bForceStatic then
          bForceUnload = bForceStatic
        end
      elseif tNodeList[i].NodeType == "cinematic" then
        cNODETYPE = _NODE_CINEMATIC
      elseif tNodeList[i].NodeType == "dynamic" then
        if bForceDynamic then
          bForceUnload = bForceDynamic
        end
        cNODETYPE = _NODE_DYNAMIC
      end
      if Common.IsNotEmptyTable(tNodes[1]) then
        self:UnloadNodes(tNodes[1], cNODETYPE, bForceUnload)
      end
    end
    for i, tNodeInfo in pairs(tNodeList) do
      tNodeInfo[1] = {}
    end
  end
end

function SabTask:UnloadMissionNodeTable(tNodeUnloadMeTable, cNODETYPE, bForceUnload)
  local tNodeList = self:GetMissionNodeList()
  if tNodeList and tNodeUnloadMeTable then
    if Common.IsNotEmptyTable(tNodeUnloadMeTable) then
      self:UnloadNodes(tNodeUnloadMeTable, cNODETYPE, bForceUnload)
    end
    for i, sNode in pairs(tNodeUnloadMeTable) do
      self:RemoveFromNodeList(tNodeList, sNode)
    end
  end
end

function SabTask:ReadyActivation()
  local tConfig = self:GetConfig()
  if string.find(self:GetName(), "_StarterInteraction") then
    local oGameplay
    local oAP = self:GetActionPackage()
    if oAP then
      oGameplay = oAP:GetGameplayTask()
      if oGameplay and oGameplay.STARTER_Setup then
        oGameplay:STARTER_Setup()
      end
    end
  end
  if self._bTimeOfDayChange then
    local bInInterior = false
    if InteriorManager.GetPlayersInterior() ~= "" then
      bInInterior = true
    end
    self:FlashToTime(tConfig.sMissionStartTime, bInInterior)
  else
    self:ActivationGreenlight()
  end
end

function SabTask:ActivationGreenlight()
  local tConfig = self:GetConfig()
  if tConfig and tConfig.bInteriorTask then
    print("INTERIOR TASK ActivationGreenlight")
  end
  print("DEBUG:: ALL LOADING COMPLETE...IT'S GO TIME ", self:GetName())
  self:Activated()
end

function SabTask:GetName()
  if not self then
    print("ERROR::No self exists when passed to GetName()")
    return "ERROR NO SELF"
  end
  if self._tConfig and self._tConfig.sName then
    return self._tConfig.sName
  else
    return "NO SELF NAME"
  end
end

function SabTask:GetID()
  if not self then
    print("ERROR::No self exists when passed to GetID()")
    return "ERROR NO SELF"
  end
  if self._tConfig and self._tConfig.sID then
    return self._tConfig.sID
  else
    return "NO SELF ID"
  end
end

function SabTask:GetParent()
  return self:GetConfig().oParent
end

function SabTask:GetActionPackage()
  if not self then
    print("BAD TIMES BOOGS GetActionPackage")
    return nil
  end
  local oPackage
  local tConfig = self:GetConfig()
  if self.bActionPackage then
    oPackage = self
  elseif tConfig and tConfig.oParent then
    oPackage = SabTask.GetActionPackage(tConfig.oParent)
  else
    oPackage = nil
  end
  return oPackage
end

function SabTask:GetGameplayTask()
  if not self then
    print("ERROR:BAD TIMES BOOGS GetGameplayTask self is nil")
    Util.Assert("ERROR:BAD TIMES BOOGS GetGameplayTask self is nil")
    return nil
  end
  local oGameplay
  local tConfig = self:GetConfig()
  if self._bGameplayTask then
    oGameplay = self
  else
    local oAP = self:GetActionPackage()
    if oAP then
      for _, o in pairs(oAP:GetChildren()) do
        if string.find(o:GetName(), "_Gameplay") then
          oGameplay = o
          break
        end
      end
    else
      print("couldn't find gameplaytask :(")
      oGameplay = nil
    end
  end
  return oGameplay
end

function SabTask:GetMyMissionName()
  if not self then
    print("Warning:SabTask:GetMissionName - no self table given , ")
    return nil
  end
  local tConfig = self:GetConfig()
  if tConfig and tConfig.sID then
    return tConfig.sID
  elseif self then
    local oParent = tConfig.oParent
    if oParent:GetConfig().sID then
      return oParent:GetConfig().sID
    elseif oParent then
      local oGrandparent = oParent:GetConfig().oParent
      if oGrandparent and oGrandparent:GetConfig().sID then
        return oGrandparent:GetConfig().sID
      end
    end
  end
  print("Warning:SabTask:GetMissionName - could not find mission name , ", self:GetName())
  return nil
end

function SabTask:GetStarter()
  local thisAP = self:GetActionPackage()
  local tStarter
  if thisAP and thisAP.sStarter then
    return StarterManager.GetFullPath(thisAP.sStarter)
  end
  return nil
end

function SabTask:GetStarterIcon()
  local thisAP = self:GetActionPackage()
  local StarterIcon
  if thisAP and thisAP.sStarter then
    StarterIcon = StarterManager.GetStarterIcon(thisAP.sStarter)
  end
  if thisAP then
    local oGameplay = thisAP:GetGameplayTask()
    local tConfig = thisAP:GetConfig()
    if tConfig and tConfig.StarterIcon then
      print("overriding starter icon from mission script ", tConfig.StarterIcon)
      StarterIcon = tConfig.StarterIcon
    end
  end
  return StarterIcon
end

function SabTask:GetMissionFail()
  local thisAP = self:GetActionPackage()
  if thisAP then
    return thisAP._bMissionFail
  end
  print("WARNING::SabTask:GetMissionFail() Could not get a valid action package returning false ")
  return false
end

function SabTask:SetMissionFail(bFail)
  local thisAP = self:GetActionPackage()
  if thisAP then
    thisAP._bMissionFail = bFail
    return
  end
  print("WARNING::SabTask:SetMissionFail() Could not get a valid action package returning false ")
  return false
end

function SabTask:MissionTaskFail(sFailMessage, bSuppressFail)
  if __g_DisableMissionFail then
    Util.Assert(false, "Debug mission fail is turned off...continue")
    return
  end
  if not self:GetMissionTaskFail() and not self:GetMissionFail() and not __g_MissionFailRebuild then
    print("mission failing ")
    __g_MissionFailRebuild = true
    self:SetMissionTaskFail(true)
    self:SetMissionFail(true)
    local message = sFailMessage
    message = message or "FAIL MESSAGE REQUIRED DESIGNER PLEASE FIX!"
    self:_CleanAllEvents()
    if bSuppressFail == nil then
      Util.MissionFail(message)
    end
  else
    print("MissionTaskFail:: This mission is hitting multiple fail states...ignoring this one ")
  end
  if __g_MissionFailRebuild then
    print("MISSION IS ALREADY IN FAIL STATE")
  end
end

function CodeCallBackMissionTaskFail(sFailMessage)
  local oMission = oGameMaster.oActiveGameplayMission
  if oMission then
    oMission:MissionTaskFail(sFailMessage)
  else
    Util.MissionFail(sFailMessage)
  end
end

function CodeCallBackMissionTaskFailStopScript(sFailMessage)
  local oMission = oGameMaster.oActiveGameplayMission
  if oMission then
    oMission:MissionTaskFail(sFailMessage, true)
  end
end

function CodeCallBackMissionTaskFailMessage(sFailMessage)
  Util.MissionFail(sFailMessage)
end

function SabTask:SetMissionTaskFail(bFail)
  local thisAP = self:GetActionPackage()
  if thisAP then
    thisAP._bMissionTaskFail = bFail
    return
  end
  print("WARNING::SabTask:SetMissionTaskFail() Could not get a valid action package returning false ")
  return false
end

function SabTask:GetMissionTaskFail()
  local thisAP = self:GetActionPackage()
  if thisAP then
    return thisAP._bMissionTaskFail
  end
  print("WARNING::SabTask:GetMissionFail() Could not get a valid action package returning false ")
  return false
end

function SabTask:IsLatent()
  return self:GetState() == _LATENT
end

function SabTask:IsActive()
  return self:GetState() == _ACTIVE
end

function SabTask:IsCompleted()
  return self:GetState() == _COMPLETE
end

function SabTask:IsCancelled()
  return self:GetState() == _CANCELLED
end

function SabTask:GetState()
  local newState
  if self.TaskState then
    newState = self.TaskState
  else
    newState = _LATENT
  end
  return newState
end

function SabTask:GetNodes()
  if self._tConfig.tSMEDNodes then
    return self._tConfig.tSMEDNodes
  end
end

function SabTask:GetInteriorNodes()
  if self._tConfig.tInteriorNodes then
    return self._tConfig.tInteriorNodes
  end
end

function SabTask:RegisterEvent(vEvent)
  if self._tEvents then
    if not vEvent then
      print("WARNING: vEvent is nil in RegisterEvent", vEvent)
      return
    end
    table.insert(self._tEvents, vEvent)
  end
end

function SabTask:RegisterVehicleDeathEvent(vEvent)
  if self._tVehicleDeaths then
    if not vEvent then
      print("WARNING: vEvent is nil in RegisterEvent", vEvent)
      return
    end
    table.insert(self._tVehicleDeaths, vEvent)
  end
end

function SabTask:RegisterTriggerEvent(hTriggerID, vTrigger)
  local a_vTriggerRegion = WRAPPER_CheckForHandle(vTrigger)
  if not a_vTriggerRegion then
    print("WARNING: vTrigger is nil in RegisterTriggerEvent", vTrigger)
    return
  end
  if self._tTriggerWaitFors and hTriggerID ~= nil and a_vTriggerRegion then
    table.insert(self._tTriggerWaitFors, {TriggerID = hTriggerID, TriggerHandle = a_vTriggerRegion})
  end
end

function SabTask:RegisterAttrPt(hAttrPt)
  if self._tEvents then
    table.insert(self.tAttrPts, hAttrPt)
  end
end

function SabTask:CompleteOptionalTask(sTaskName)
  local oTask = self:GetChild(sTaskName)
  if oTask ~= nil then
    if oTask:IsActive() then
      local tConfig = oTask:GetConfig()
      oTask._bDISABLETONCOMPLETETABLE = true
      oTask:SubObjectiveCompleted()
    else
    end
  else
    self:WarningNil("oTask", "SabTask:CompleteTask")
  end
end

function SabTask:RunTask(fTask)
  self:fTask()
end

function SabTask:GetMissionNodeList()
  if not self then
    Util.Assert(false, "ERROR:: self is nil in SabTaskGetMissionNodeList")
    return
  end
  local oAP = self:GetActionPackage()
  if not oAP then
    Util.Assert(false, "ERROR:: could not find action package in SabTaskGetMissionNodeList")
  end
  if oAP.tMissionNodeList then
    return oAP.tMissionNodeList
  else
    return
  end
end

function SabTask:SetMissionNodeList(tNewTable)
  local oAP = self:GetActionPackage()
  if not oAP then
    Util.Assert(false, "ERROR:: could not find action package in SabTaskGetMissionNodeList")
  end
  oAP.tMissionNodeList = tNewTable
end

function SabTask:CheckForMasterSelf()
  if self._SELFTABLE_ID and not gMasterSelfTable[self._SELFTABLE_ID] then
    print("ID did not exist in table re-adding ", self._SELFTABLE_ID, " ", self:GetName())
    gMasterSelfTable[self._SELFTABLE_ID] = self
  end
end

function SabTask:InsertNodeList(tNodeList, tNodes, cNODETYPE)
  if not tNodeList then
    print("WARNING:: tNodeList is nil in InsertNodeList ", self:GetName())
    return
  end
  for i, node in pairs(tNodes) do
    if cNODETYPE == _NODE_COLBY then
      table.insert(tNodeList[2][1], node)
    elseif cNODETYPE == _NODE_CINEMATIC then
      table.insert(tNodeList[3][1], node)
    else
      table.insert(tNodeList[1][1], node)
    end
  end
end

function SabTask:RemoveFromNodeList(tNodeList, sNode)
  for i, tNodes in pairs(tNodeList) do
    for j, tNodeType in pairs(tNodes) do
      if type(tNodeType) == "table" then
        for k, sThisNode in pairs(tNodeType) do
          if string.upper(sThisNode) == string.upper(sNode) then
            table.remove(tNodeType, k)
            return
          end
        end
      end
    end
  end
end

function SabTask:IsCompletedMission(Mission)
  local sMissionName
  if not string.find(Mission, "_ActionPackage") then
    sMissionName = Mission .. "_ActionPackage"
  else
    sMissionName = Mission
  end
  for i, v in pairs(self.tCompletedMissionList) do
    if string.upper(self.tCompletedMissionList[i]) == string.upper(sMissionName) then
      return true
    end
  end
  return false
end

function SabTask:IsInOpenList(Mission)
  for i, v in pairs(self.tOpenMissionList) do
    if string.upper(self.tOpenMissionList[i]) == string.upper(Mission) then
      return true
    end
  end
  return false
end

function SabTask:IsInPotentialList(Mission)
  for i, v in pairs(self._tPotentialMissionIDList) do
    if string.upper(self._tPotentialMissionIDList[i]) == string.upper(Mission) then
      return true
    end
  end
  return false
end

function SabTask:IsInActiveMissionList(Mission)
  for i, v in pairs(self._tActiveMissionList) do
    if self._tActiveMissionList[i] == Mission then
      return true
    end
  end
  return false
end

function SabTask:IsInDisabledList(Mission)
  for i, v in pairs(self.tDisabledMissionsList) do
    if self.tDisabledMissionsList[i] == Mission then
      return true
    end
  end
  return false
end

function SabTask:AddMarker(hMarker, sMarker, bExt, bExtStart, bOn, bExtHQStarterBlip, sInt, sStarter)
  local sID
  local bMarkerAlreadyExists = false
  bMarkerAlreadyExists = SabTask:DoesMarkerExist(hMarker)
  if not bMarkerAlreadyExists then
    table.insert(SabTask._tMasterMarkerList, {
      Marker = hMarker,
      sMarker = sMarker,
      bExterior = bExt,
      bExtStarter = bExtStart,
      bMiniMapIcon = false,
      bWorldIcon = false,
      bHide = true,
      bExtHQBlip = bExtHQStarterBlip,
      IconType = "",
      MMIconType = "",
      bOn = bOn,
      sInterior = sInt,
      sIDExtHQBlip = sID
    })
  else
  end
end

function SabTask:DoesMarkerExist(hValue)
  if SabTask._tMasterMarkerList then
    for i, tMarker in pairs(SabTask._tMasterMarkerList) do
      if tMarker.Marker == hValue then
        return true
      end
    end
  end
  return false
end

function SabTask:RemoveMarker(hValue)
  if SabTask._tMasterMarkerList then
    for i, tMarker in pairs(SabTask._tMasterMarkerList) do
      if tMarker.Marker == hValue then
        table.remove(SabTask._tMasterMarkerList, i)
      end
    end
  end
end

function SabTask:RemoveAllMarkers()
  if SabTask._tMasterMarkerList then
    SabTask._tMasterMarkerList = {}
  end
end

function SabTask:HasMasterMarker(hValue)
  if self._tMasterMarkerList then
    for _, tMarker in pairs(self._tMasterMarkerList) do
      if tMarker.Marker == hValue then
        return true
      end
    end
  end
  return false
end

function SabTask:ToggleMarkers()
  local tSabSelf = Actor.GetSelf(hSab)
  local bExteriorActive
  if tSabSelf.bInInterior then
    bExteriorActive = false
  else
    bExteriorActive = true
  end
  if SabTask._tMasterMarkerList then
    for i, tMarker in pairs(SabTask._tMasterMarkerList) do
      if tMarker.bExterior == true and bExteriorActive == true then
        tMarker.bHide = false
      elseif tMarker.bExterior == true and bExteriorActive == false then
        tMarker.bHide = true
      elseif tMarker.bExterior == false and bExteriorActive == false then
        tMarker.bHide = false
      elseif tMarker.bExterior == false and bExteriorActive == true then
        tMarker.bHide = true
      end
      if tMarker.bExtStarter then
        tMarker.bHide = false
      end
      if tMarker.bExtHQBlip and tMarker.sInterior and tMarker.sInterior ~= InteriorManager.GetPlayersInterior() then
        tMarker.bHide = false
      elseif tMarker.bExtHQBlip and tMarker.sInterior and tMarker.sInterior == InteriorManager.GetPlayersInterior() then
        tMarker.bHide = true
      end
    end
  end
  SabTask:UpdateMarkers()
end

function SabTask:ToggleHQBlipMarkers(bOn)
  local tSabSelf = Actor.GetSelf(hSab)
  local bExteriorActive
  if tSabSelf.bInInterior then
    bExteriorActive = false
  else
    bExteriorActive = true
  end
  if SabTask._tMasterMarkerList then
    for i, tMarker in pairs(SabTask._tMasterMarkerList) do
      if tMarker.bExtHQBlip == true and bExteriorActive == true then
        tMarker.bHide = bOn
        tMarker.bMiniMapIcon = bOn
        local hTestMarker = WRAPPER_CheckForHandleNil(tMarker.sMarker)
        if hTestMarker ~= nil and hTestMarker == tMarker.Marker then
          HUD.ShowObjectiveMarker(tMarker.Marker, bOn, bOn)
        end
      end
    end
  end
end

function SabTask:UpdateMarkerTable(hValue, bOn)
  local tConfig
  if self then
    tConfig = self:GetConfig()
  end
  local tMarker = SabTask:GetMarkerTable(hValue)
  if not tMarker then
    return
  end
  local bRenderMinimapIcon, bRenderWorldIcon
  tMarker.bOn = bOn
  if tConfig then
    if not tMarker then
      print("ERROR:: failed to get Marker table ", self:GetName())
      return
    end
    if bOn and not tConfig.bNoHUDBlip then
      bRenderMinimapIcon = true
    elseif not bOn then
      bRenderMinimapIcon = false
    else
      bRenderMinimapIcon = false
    end
    if bOn and (tConfig.bStarterFlag or tConfig.sTaskSubType and string.upper(tConfig.sTaskSubType) == "TALK") and not tConfig.bNoWorldBlip then
      bRenderWorldIcon = true
    elseif tConfig.bNoWorldBlip or not bOn then
      bRenderWorldIcon = false
    elseif tConfig.bWorldBlip then
      bRenderWorldIcon = true
    else
      bRenderWorldIcon = true
    end
    tMarker.bMiniMapIcon = bRenderMinimapIcon
    tMarker.bWorldIcon = bRenderWorldIcon
  else
    if not tMarker then
      return
    end
    tMarker.bMiniMapIcon = bOn
    tMarker.bWorldIcon = not tMarker.bExtHQBlip
  end
end

function SabTask:UpdateMarkers()
  if SabTask._tMasterMarkerList then
    for i, tMarker in pairs(SabTask._tMasterMarkerList) do
      if not tMarker.bHide then
        local hTestMarker = WRAPPER_CheckForHandleNil(tMarker.sMarker)
        if hTestMarker ~= nil and hTestMarker == tMarker.Marker then
          HUD.ShowObjectiveMarker(tMarker.Marker, tMarker.bMiniMapIcon, tMarker.bWorldIcon)
        else
        end
      else
        local hTestMarker = WRAPPER_CheckForHandleNil(tMarker.sMarker)
        if hTestMarker ~= nil and hTestMarker == tMarker.Marker then
          HUD.ShowObjectiveMarker(tMarker.Marker, false, false)
        else
        end
      end
    end
  end
end

function SabTask:GetMarkerTable(hValue)
  if SabTask._tMasterMarkerList then
    for i, tMarker in pairs(SabTask._tMasterMarkerList) do
      if tMarker.Marker == hValue then
        return tMarker
      end
    end
  end
  return nil
end

function SabTask:GetCheckpoint(index)
  local cpindex = index
  local lastindex = self:GetCheckpointCount()
  if self.CheckpointIndex then
    cpindex = self.CheckpointIndex
  end
  if cpindex == nil or cpindex < 1 then
    cpindex = 1
  elseif lastindex < cpindex then
    cpindex = lastindex
  end
  if self.tCheckpointFunctions then
    return self.tCheckpointFunctions[cpindex]
  else
    print("ERROR:: in GetCheckpoint, no checkpoint to return")
  end
end

function SabTask:DoesTaskAlreadyExist(sTaskName)
  for i, oTask in pairs(self:GetChildren()) do
    if sTaskName == i and (oTask:IsActive() or oTask:IsCompleted()) then
      return true
    elseif sTaskName == i and oTask:IsCancelled() then
      Util.Assert(false, "You are trying to activate a cancelled task , you sure about this? " .. oTask:GetName())
      return true
    end
  end
  return false
end

function SabTask:CheckTaskDepends(tDependencyList)
  local tConfig = self:GetConfig()
  local tChildren = self:GetChildren()
  local CompletedDepends = 0
  if tDependencyList == nil or tDependencyList == {} then
    return true
  end
  for i, v in pairs(tDependencyList) do
    for sName, oTask in pairs(tChildren) do
      if tDependencyList[i] == sName and oTask:IsCompleted() then
        CompletedDepends = CompletedDepends + 1
      end
    end
  end
  local TotalDepends = #tDependencyList
  if TotalDepends == CompletedDepends then
    return true
  end
  return false
end

function SabTask:ShowToolTip(sToolTipID, timeroverride)
  if sToolTipID then
    Saboteur.ShowToolTip(sString, timeroverride)
  end
end

function SabTask:GetLocalizedText(sTextID)
  local sString
  if not sTextID or sTextID == "" then
    return sTextID
  end
  sString = sTextID
  if not sString then
    if _Development then
      sString = sTextID .. " **HARD_CODED_STRING**"
    else
      sString = sTextID
    end
  end
  return sString
end

function SabTask:GetTableFromCopy(tTable)
  local tCopyTable
  local tEmptyTable = {}
  if not tTable or tTable == "" or tTable == {} then
    return tEmptyTable
  elseif type(tTable) == "table" and tTable then
    tCopyTable = __UtilFunctions.CopyTable(tTable)
    return tCopyTable
  else
    return tEmptyTable
  end
end

function SabTask:FlashToTime(vTime, bNoFade)
  if not vTime then
    return
  end
  if type(vTime) == "string" and string.len(vTime) == 4 then
    local tCurrentTime = Util.GetTime()
    local CurrentHour = tCurrentTime.Hour
    local CurrentMinute = tCurrentTime.Minute
    local Hour, Minutes
    Hour = tonumber(string.sub(vTime, 1, 2))
    Minutes = tonumber(string.sub(vTime, 3, 4))
    self._flashtimestage = 1
    self._timeflashhour = Hour
    self._timeflashminutes = Minutes
    self:FlashToTimeStage(bNoFade)
  elseif type(vTime) == "number" then
    self._flashtimestage = 1
    self._timeflashhour = vTime
    self._timeflashminutes = 0
    self:FlashToTimeStage(bNoFade)
  else
    Util.Assert(false, "CFrench says: sMissionStartTime variable needs to be a time string 4 chars long ex: \"0630\" ", self:GetName())
  end
end

function SabTask:FlashToTimeStage(bNoFade)
  if self._flashtimestage == 1 then
    self._flashtimestage = self._flashtimestage + 1
    if bNoFade then
      SabTask.FlashToTimeStage(self, bNoFade)
    else
      Render.FadeTo(0, 0, 0, 255, 1)
      EVENT_Timer("SabTask.FlashToTimeStage", self, 1)
    end
  elseif self._flashtimestage == 2 then
    self._flashtimestage = self._flashtimestage + 1
    if self._timeflashhour and self._timeflashminutes then
      Util.SetTime(self._timeflashhour, self._timeflashminutes)
    end
    if bNoFade then
      SabTask.FlashToTimeStage(self, bNoFade)
    else
      Actor.TurnOnDude(hSab, false)
      Object.SetInvincibleToAI(hSab, true)
      EVENT_Timer("SabTask.FlashToTimeStage", self, 2.5)
    end
  elseif self._flashtimestage == 3 then
    self._flashtimestage = self._flashtimestage + 1
    if bNoFade then
      SabTask.FlashToTimeStage(self, bNoFade)
    else
      Actor.TurnOnDude(hSab, true)
      Object.SetInvincibleToAI(hSab, false)
      Render.FadeTo(0, 0, 0, 0, 1)
      EVENT_Timer("SabTask.FlashToTimeStage", self, 1)
    end
  elseif self._flashtimestage == 4 then
    self._flashtimestage = nil
    self._bTimeOfDayChange = nil
    self._timeflashhour = nil
    self._timeflashminutes = nil
    if self.bFreezeTimeScale then
      print("Freezing time scale")
      Util.SetDayTimeScale(0)
    end
    self:ActivationGreenlight()
  else
    Util.Assert(false, "CFrench made this time/space shift bad times, hit him")
    Render.FadeTo(0, 0, 0, 0, 0.5)
    Actor.TurnOnDude(hSab, true)
    self._flashtimestage = nil
    self._bTimeOfDayChange = nil
    self._timeflashhour = nil
    self._timeflashminutes = nil
    self:ActivationGreenlight()
  end
end

function SabTask.SaveGameCallback()
  local sSabInterior = InteriorManager.GetPlayersInterior()
  SaveLoad.SaveString(SabTask._saveversion)
  SaveLoad.SaveTable(SabTask.tOpenMissionList)
  SaveLoad.SaveTable(StarterManager.Save_IsStarterHiddenList)
  SaveLoad.SaveTable(SabTask.tCompletedMissionList)
  SaveLoad.SaveTable(WorldSMEDNodes.tWorldNodeList)
  SaveLoad.SaveTable(WorldSMEDNodes.tWorldCinematicNodeList)
  SaveLoad.SaveTable(WorldSMEDNodes.tWorldStaticTagList)
  SaveLoad.SaveTable(SabTask.tDisabledMissionsList)
  SaveLoad.SaveString(oGameMaster.sActiveArc)
  SaveLoad.SaveTable(SabTask._tPotentialMissionIDList)
  SaveLoad.SaveTable(SabTask._tActiveMissionList)
  SaveLoad.SaveTable(SabTask._tSpecialCaseUnlockedList)
  SaveLoad.SaveTable(RewardsManager.HQPoints)
  SaveLoad.SaveTable(SabTask._tMiscSaveTable)
  SaveLoad.SaveString(sSabInterior)
end

function SabTask.PreLoadGameCallback()
  print("pre load callback")
  __bHaltRebuildMissions = true
  SabTaskGameMaster:ClearAllIDTimers()
  Util.ClearAllInteriorLoadCallbacks()
  CancelCurrentMission(true)
  SabTask:CancelAllPotentialMissions()
  SabTask:CancelAllActiveMissions()
  SaveLoad.ClearSnapshot()
  Actor.TurnOnDude(hSab, false)
  if InteriorManager.GetPlayersInterior() ~= "" then
  end
  InteriorManager._CleanInteriorEscalationEvents()
  Suspicion.ResetEscalation()
end

function SabTask.LoadGameCallback()
  print("load game callback")
  local saveversion = SaveLoad.LoadString()
  if SabTask._saveversion ~= saveversion then
    Util.Assert(false, "CFrench says: incompatable save/load file types, please create a new save ver.", saveversion)
    print("bad save/file version ", SabTask._saveversion, saveversion)
  end
  SabTask.tOpenMissionList = SaveLoad.LoadTable()
  StarterManager.Save_IsStarterHiddenList = SaveLoad.LoadTable()
  SabTask.tCompletedMissionList = SaveLoad.LoadTable()
  WorldSMEDNodes.tWorldNodeList = SaveLoad.LoadTable()
  WorldSMEDNodes.tWorldCinematicNodeList = SaveLoad.LoadTable()
  WorldSMEDNodes.tWorldStaticTagList = SaveLoad.LoadTable()
  SabTask.tDisabledMissionsList = SaveLoad.LoadTable()
  oGameMaster.sActiveArc = SaveLoad.LoadString()
  SabTask._tPotentialMissionIDList = SaveLoad.LoadTable()
  tempActiveMissionList = SaveLoad.LoadTable()
  SabTask._tSpecialCaseUnlockedList = SaveLoad.LoadTable()
  RewardsManager.HQPoints = SaveLoad.LoadTable()
  SabTask._tMiscSaveTable = SaveLoad.LoadTable()
  tempPlayersInterior = SaveLoad.LoadString()
  RewardsManager.UpdateHQPoints()
  SabTask.ClearAllObjectiveMarkers()
  HUD.ClearAllObjectives()
  ClearAllDisableControls()
  __g_bSAVELOADING = true
end

function SabTask.PostLoadGameCallback()
  print("post load callback")
  if DLC_InteriorManager ~= nil then
    DLC_InteriorManager.LoadDLCColbyNodes()
  end
  SabTask:CallbackContinueRestartManager()
end

function SabTask:CallbackInteriorReloaded()
  tempWorldNodesReloaded = 0
  tempWorldNodes2Reload = 0
  __bInterceptFinishedInterior = nil
  tempWorldNodes2Reload = tempWorldNodes2Reload + SabTask:GetTotalLoadingNodeNumber(WorldSMEDNodes.tWorldNodeList, tempWorldNodeList)
  tempWorldNodes2Reload = tempWorldNodes2Reload + SabTask:GetTotalLoadingNodeNumber(WorldSMEDNodes.tWorldStaticTagList, tempWorldStaticTagList)
  local sfCallback = "SabTask.CallbackAllWorldNodeTypesUnloaded"
  if Common.IsNotEmptyTable(tempWorldNodeList) then
    WorldSMEDNodes.RestoreWorldList(tempWorldNodeList, 1, sfCallback)
  end
  if Common.IsNotEmptyTable(tempWorldStaticTagList) then
    WorldSMEDNodes.RestoreWorldList(tempWorldStaticTagList, 3)
  end
  if tempWorldNodes2Reload == 0 then
    SabTask:CallbackAllWorldNodeTypesUnloaded()
  end
end

function SabTask.CallbackAllWorldNodeTypesUnloaded(a_SelfTable, sNode)
  tempWorldNodesReloaded = tempWorldNodesReloaded + 1
  if sNode then
    print("DEBUG:Finished Loading ", sNode)
  end
  if tempWorldNodes2Reload == 0 or tempWorldNodesReloaded >= tempWorldNodes2Reload then
    tempWorldNodesReloaded = nil
    tempWorldNodes2Reload = nil
    SabTask:CallbackContinueRestartManager()
  else
    SabTask:CallbackContinueRestartManager()
  end
end

function SabTask:CallbackContinueRestartManager()
  print("^^^^^^   continue restart manager   ^^^^^ ")
  __bHaltRebuildMissions = nil
  __g_MissionFailRebuild = false
  StarterManager.CleanStarterList()
  RewardsManager.RestoreStates()
  SabTask:RestoreMissionStateInfo()
  Suspicion.ResetEscalation()
  oGameMaster:UnlockPotentialMissions(SabTask._tPotentialMissionIDList)
  InteriorManager._SetupEscalationDenial()
  oGameMaster:BuildOpenMissionList()
  __g_bSAVELOADING = nil
  Actor.TurnOnDude(hSab, true)
end

function SabTask:CancelAllActiveMissions()
  if SabTask._tActiveMissionList then
    while SabTask._tActiveMissionList[1] do
      SabTask:CancelActiveMissionListMission(SabTask._tActiveMissionList[1])
    end
  end
end

function SabTask:CancelAllPotentialMissions()
  if SabTask._tPotentialMissionIDList then
    for i, v in pairs(SabTask._tPotentialMissionIDList) do
      SabTask:CancelPotentialMissionListMission(SabTask._tPotentialMissionIDList[i])
    end
  end
end

function SabTask:CancelActiveMissionListMission(sMissionName)
  local oMission = GetAPByName(sMissionName)
  if oMission and oMission:IsActive() then
    print("cancelling an active mission", sMissionName)
    oMission:CancelNow()
    Common.RemoveTableItem(self._tActiveMissionList, sMissionName)
  else
    Util.Assert(false, "Bad times in CancelWorldEvent while loop freedumb")
  end
end

function SabTask:CancelPotentialMissionListMission(sMissionName)
  local oAP = GetAPByName(sMissionName)
  if oAP and type(oAP) == "table" and not oAP.bMarkedForNil and not oAP.bPendingCancel then
    print("cancelling an potential mission", sMissionName)
    oAP:CancelNow()
  elseif type(oAP) == "table" and oAP.bMarkedForNil then
    print(sMissionName .. "is already marked for deletion, ignoring")
  elseif type(oAP) == "table" and oAP:IsCancelled() then
    print(sMissionName .. "is already marked for cancellation, ignoring")
  elseif type(oAP) == "table" and oAP.bPendingCancel then
    print(sMissionName .. "is already marked for cancellation, ignoring")
  elseif oAP and type(oAP) == "table" then
    print("== oAP is there but maybe a case i'm missing?")
    Util.Assert(false, "oAP is there but maybe a case i'm missing?")
  elseif not oAP then
    Util.Assert(false, "CancelPotentialMissionListMission oAP is nil")
  end
end

function SabTask.RestoreMissionStateInfo()
  for i, sMissionName in pairs(tempActiveMissionList) do
    Common.InsertTableItem(SabTask._tPotentialMissionIDList, sMissionName, true)
  end
  for i, sMissionName in pairs(SabTask._tSpecialCaseUnlockedList) do
    Common.InsertTableItem(SabTask._tPotentialMissionIDList, sMissionName, true)
  end
  SabTask._tSpecialCaseUnlockedList = {}
  for i, sMissionName in pairs(SabTask._tPotentialMissionIDList) do
    local oRestoreMission = GetAPByName(sMissionName)
    if oRestoreMission then
      print("DEBUG:: Restoring mission :" .. sMissionName)
      oRestoreMission:MissionSetState(_POTENTIAL)
    else
      oGameMaster:RemoveOpenMission(sMissionName)
    end
  end
end

function SabTask:GetCheckpointName()
  if self.tSaveInfo._sCheckpointFunction then
    return self.tSaveInfo._sCheckpointFunction
  else
    return nil
  end
end

function SabTask:RegisterCheckpoint(sFunction, sContFun, bShouldOverrideFadeOnLoad, hLocator)
  local fContinueFunction
  local sContinueFunction = sContFun
  if not sFunction then
    print("SabTask:RegisterCheckpoint:: No checkpoint function designated ABE BAND ON SHIP!!!")
    return
  end
  local bOverrideFade = bShouldOverrideFadeOnLoad
  bOverrideFade = bOverrideFade or false
  local fCheckpoint = StringToFileFunction(sFunction)
  if not fCheckpoint then
    Util.Assert("CFRENCH: could not find checkpoint function that was called in RegisterCheckpoint", self:GetName(), sFunction)
    print("ERROR:: could not find checkpoint function that was called in RegisterCheckpoint", self:GetName(), sFunction)
  end
  self.tSaveInfo._sCheckpointFunction = sFunction
  if not sContinueFunction then
    sContinueFunction = sFunction
    fContinueFunction = fCheckpoint
  else
    fContinueFunction = StringToFileFunction(sContFun)
  end
  if not fContinueFunction then
    Util.Assert("CFRENCH: could not find checkpoint function that was called in RegisterCheckpoint", self:GetName(), sContinueFunction)
    print("ERROR:: could not find checkpoint function that was called in RegisterCheckpoint", self:GetName(), sContinueFunction)
  end
  self.tSaveInfo.__ContinueCheckpointFunction = sContinueFunction
  self.tSaveInfo.__bShouldOverrideFadeScreenOnLoad = bOverrideFade
  if _DEBUG_CP_OFF then
    if fContinueFunction then
      print("Checkpoints disabled continuing next function ", sContinueFunction)
      fContinueFunction(self)
    end
  else
    local hLoc
    if hLocator then
      hLoc = Handle(hLocator)
    end
    SaveLoad.SaveCheckpoint(self, hLoc)
  end
end

function SabTask:SaveCheckpointCallback()
  local tCompletedTasks = self:GetAllCompletedTasks()
  SaveLoad.SaveTable(self.tSaveInfo)
  SaveLoad.SaveTable(tCompletedTasks)
  SaveLoad.SaveTable(self:GetMissionNodeList())
  SaveLoad.SaveTable(WorldSMEDNodes.tWorldNodeList)
  SaveLoad.SaveTable(WorldSMEDNodes.tWorldStaticTagList)
  SaveLoad.SaveTable(WorldSMEDNodes.tWorldCinematicNodeList)
  SaveLoad.SaveTable(oGameMaster.tLoadedNodeList)
  SaveLoad.SaveTable(StarterManager.Save_IsStarterHiddenList)
  local fContinueCheckpoint = StringToFileFunction(self.tSaveInfo.__ContinueCheckpointFunction)
  if not fContinueCheckpoint then
    Util.Assert("CFRENCH: SabTask.SaveCheckpointCallback could not find checkpoint function on stack for ", self:GetName())
    print("ERROR:: SabTask.SaveCheckpointCallback could not find checkpoint function on stack for ", self:GetName())
  end
  EVENT_Timer(self.tSaveInfo.__ContinueCheckpointFunction, self, 0.13)
end

function SabTask:PreLoadCheckpointCallback()
  print("PreLoadCheckpointCallback ", self:GetName())
  self:_CleanAllEvents()
  Util.ClearAllInteriorLoadCallbacks()
  if self._ePlayerDeath then
    Util.KillEvent(self._ePlayerDeath)
    self._ePlayerDeath = nil
  end
  local oGameplay = GetMissionByName(self:GetMyMissionName())
  if oGameplay and oGameplay.MISSION_PRELOADINGCHECKPOINT then
    oGameplay.MISSION_PRELOADINGCHECKPOINT(oGameplay)
  end
  self:_ResetMissionState()
end

function SabTask:_ResetMissionState()
  print("resetting mission state")
  self:SetMissionTaskFail(false)
  self:SetMissionFail(false)
end

function SabTask:ResetAllActiveTasks()
  local tConfig = self:GetConfig()
  for i, oTask in pairs(self:GetChildren()) do
    if oTask:IsActive() and not oTask:GetConfig().bPersistentParent then
      oTask:ResetThisTask(true, true, true)
    end
  end
end

function SabTask:ResetAllPostCheckpointTasks(tCompletedTaskList)
  local tConfig = self:GetConfig()
  if not tempCompletedTaskList then
    print("ERROR:!!!! tempCompletedTaskList is nil ")
    return
  end
  for i, oTask in pairs(self:GetChildren()) do
    if oTask:IsCompleted() and not oTask:IsInCompletedList(tCompletedTaskList) then
      oTask:ResetThisTask(true, true, true)
    end
  end
end

function SabTask:GetAllCompletedTasks()
  local tCompletedTasks = {}
  for i, oTask in pairs(self:GetChildren()) do
    if oTask:IsCompleted() then
      table.insert(tCompletedTasks, oTask:GetName())
    end
  end
  return tCompletedTasks
end

function SabTask:IsInCompletedList(tCompletedList)
  local tCompletedTasks = {}
  local sName = self:GetName()
  for i, sTaskName in pairs(tCompletedList) do
    if sTaskName == sName then
      return true
    end
  end
  return false
end

function SabTask:LoadCheckpointCallback()
  print("*** *** LoadCheckpointCallback ", self:GetName())
  local tempMissionNodeList = {}
  self.tSaveInfo = SaveLoad.LoadTable()
  tempCompletedTaskList = SaveLoad.LoadTable()
  tempMissionNodeList = SaveLoad.LoadTable()
  self:SetMissionNodeList(tempMissionNodeList)
  WorldSMEDNodes.tWorldNodeList = SaveLoad.LoadTable()
  WorldSMEDNodes.tWorldStaticTagList = SaveLoad.LoadTable()
  WorldSMEDNodes.tWorldCinematicNodeList = SaveLoad.LoadTable()
  oGameMaster.tLoadedNodeList = SaveLoad.LoadTable()
  StarterManager.Save_IsStarterHiddenList = SaveLoad.LoadTable()
  Util.SetOverrideLoadScreenFadeIn(self.tSaveInfo.__bShouldOverrideFadeScreenOnLoad)
  local oGameplay = GetMissionByName(self:GetMyMissionName())
  if oGameplay then
    oGameplay:_SetupPlayerDeath()
  end
  self:ResetAllPostCheckpointTasks(tempCompletedTaskList)
  self:ResetAllActiveTasks()
  SabTask.ClearAllObjectiveMarkers()
  HUD.ClearAllObjectives()
end

function SabTask:PostLoadCheckpointCallback()
  print("** ** PostLoadCheckpoint ", self:GetName())
  tempCompletedTaskList = nil
  __g_MissionFailRebuild = false
  local fCheckpoint = StringToFileFunction(self.tSaveInfo._sCheckpointFunction)
  if not fCheckpoint then
    Util.Assert("CFRENCH: could not find checkpoint function on stack for ", self:GetName())
    print("ERROR:: could not find checkpoint function on stack for ", self:GetName())
  end
  EVENT_Timer(self.tSaveInfo._sCheckpointFunction, self, 0.25, {true})
end

function SabTask:CheckpointReloadClearAllObjectives(tempCompletedTaskList)
  if tempCompletedTaskList then
    for i, oTask in pairs(self:GetChildren()) do
      if oTask:IsActive() and not oTask:GetConfig().bPersistentParent then
        print("Clearing objectives on active task", oTask:GetName())
        oTask:_CleanObjectiveText()
      end
    end
  end
  SabTask.ClearAllObjectiveMarkers()
  HUD.ClearAllObjectives()
end

function SabTask.ReturnToHQ_PreExitInterior()
  print("_SabTask.ReturnToHQ_PreExitInterior()")
  __bHaltRebuildMissions = true
  __RETURNTOHQSTART = true
  Util.ClearAllInteriorLoadCallbacks()
  InteriorManager._CleanInteriorEscalationEvents()
  SabTask:CancelAllPotentialMissions()
  SabTask:CancelAllActiveMissions()
  SabTask.ClearAllObjectiveMarkers()
end

function SabTask.ReturnToHQ_PostExitInterior()
  print("_SabTask.ReturnToHQ_PostExitInterior()")
  ClearAllDisableControls()
  __RETURNTOHQSTART = nil
end

function SabTask.ReturnToHQ_PostLoadHQ()
  print("_SabTask.ReturnToHQ_PostLoadHQ()")
  __bHaltRebuildMissions = nil
  StarterManager.CleanStarterList()
  InteriorManager._SetupEscalationDenial()
  __g_MissionFailRebuild = false
  oGameMaster:UnlockPotentialMissions(SabTask._tPotentialMissionIDList)
  EVENT_Timer("SabTaskGameMaster.BuildOpenMissionList", oGameMaster, 0.3)
end

function SabTask:ClearAllObjectiveMarkers()
  SabTask:RemoveAllMarkers(hValue)
  HUD.ClearAllObjectiveMarkers()
end

function SabTask:WarningNil(sThing, sFunction, arg1, arg2, arg3)
  if self:GetName() then
    print("WARNING: " .. sThing .. " nil in " .. sFunction, self:GetName(), " ", arg1, " ", arg2, " ")
  else
    print("WARNING: " .. sThing .. " nil in " .. sFunction, " ", arg1, " ", arg2, " ")
  end
end

function SabTask:Debug_StringState(state)
  local s
  if self:GetState() == _ACTIVE then
    s = "_ACTIVE"
  elseif self:GetState() == _LATENT then
    s = "_LATENT"
  elseif self:GetState() == _COMPLETE then
    s = "_COMPLETE"
  elseif self:GetState() == _CANCELLED then
    s = "_CANCELLED"
  else
    s = "NO STATE"
  end
  return s
end

function SabTask:Debug_PrintChildren()
  local tChildren = self:GetChildren()
  print("----- Printing children for ", self:GetName())
  for k, v in pairs(tChildren) do
    print("-----   ", v._tConfig.sName)
  end
end

function SabTask:Debug_PrintConfig()
  local tConfig = self:GetConfig()
  print("Printing config for ", self:GetName())
  for k, v in pairs(tConfig) do
    if v ~= "" then
      print("name =", k, " value =", v)
    end
  end
  print("")
end

function SabTask:Debug_PrintOpenMissionList()
  print("Open Missions")
  for i = self.tOpenMissionList.first, self.tOpenMissionList.last do
    print(self.tOpenMissionList[i][1], " in ", self.tOpenMissionList[i][2])
  end
end

function SabTask:Debug_PrintSelfTableList()
  print("**Debug: self table list")
  for i, v in pairs(self.tSelfTableList_Debug) do
    print("--", i, " - ", v, "name = ", self.tSelfTableList_Debug[i]:GetName())
  end
end

function SabTask:Debug_RemoveSelfTableList()
  for i, v in pairs(self.tSelfTableList_Debug) do
    if self.tSelfTableList_Debug[i] == self then
      table.remove(self.tSelfTableList_Debug, i)
    end
  end
  SabTask:Debug_PrintSelfTableList()
end
