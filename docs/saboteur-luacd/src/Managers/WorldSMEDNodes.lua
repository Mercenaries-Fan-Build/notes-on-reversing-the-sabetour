if WorldSMEDNodes == nil then
  WorldSMEDNodes = {}
  WorldSMEDNodes.tWorldNodeList = {}
  WorldSMEDNodes.tWorldCinematicNodeList = {}
  WorldSMEDNodes.tWorldStaticTagList = {}
  WorldSMEDNodes.Loaded = 0
end

function WorldSMEDNodes.LoadNode(sNode, a_sCallbackFunction, self, tData)
  if sNode and sNode ~= "" and not Common.IsNodeLoaded(WorldSMEDNodes.tWorldNodeList, sNode) then
    print("DEBUG:: WS Loading dynamic node ", sNode)
    __UtilFunctions.LoadNode(sNode, a_sCallbackFunction, self, tData)
    __UtilFunctions.AddLoadNode(WorldSMEDNodes.tWorldNodeList, sNode)
    return true
  end
  return false
end

function WorldSMEDNodes.UnloadNode(sNode, bForceUnload)
  if sNode and sNode ~= "" and Common.IsNodeLoaded(WorldSMEDNodes.tWorldNodeList, sNode) then
    print("DEBUG:: WS Unloading dynamic node ", sNode)
    __UtilFunctions.UnloadNode(sNode, bForceUnload)
    __UtilFunctions.RemoveLoadNode(WorldSMEDNodes.tWorldNodeList, sNode)
    return true
  end
  return false
end

function WorldSMEDNodes.LoadCinematicNode(sNode, a_sCallbackFunction, self, tData)
  if sNode and sNode ~= "" and not Common.IsNodeLoaded(WorldSMEDNodes.tWorldCinematicNodeList, sNode) then
    print("DEBUG:: WS Loading cinematic node ", sNode)
    __UtilFunctions.AddLoadNode(WorldSMEDNodes.tWorldCinematicNodeList, sNode)
    if a_sCallbackFunction then
      Util.SpawnCinematicNode(sNode, a_sCallbackFunction, self, tData)
    else
      Util.SpawnCinematicNode(sNode)
    end
    return true
  end
  return false
end

function WorldSMEDNodes.PreLoadCinematicNode(sNode)
  if sNode and sNode ~= "" and not Common.IsNodeLoaded(WorldSMEDNodes.tWorldCinematicNodeList, sNode) then
    print("DEBUG:: WS Pre-loading cinematic node ", sNode)
    __UtilFunctions.AddLoadNode(WorldSMEDNodes.tWorldCinematicNodeList, sNode, cSM_LOADING)
    Util.SpawnCinematicNode(sNode, "WorldSMEDNodes.CallbackCinematicNodeLoaded", nil, {sNode})
    return true
  end
  return false
end

function WorldSMEDNodes:CallbackCinematicNodeLoaded(sNode)
  print("DEBUG:: WS Pre-loading cinematic node done ", sNode)
  for i, tNode in pairs(WorldSMEDNodes.tWorldCinematicNodeList) do
    if string.upper(tNode.sNode) == string.upper(sNode) then
      tNode.state = cSM_LOADED
    end
  end
end

function WorldSMEDNodes.UnloadCinematicNode(sNode, bForceUnload)
  if bForceUnload == nil then
    bForceUnload = false
  end
  if sNode and sNode ~= "" and Common.IsNodeLoaded(WorldSMEDNodes.tWorldCinematicNodeList, sNode) then
    print("DEBUG:: WS Unloading cinematic node ", sNode)
    Util.UnloadCinematicNode(sNode)
    __UtilFunctions.RemoveLoadNode(WorldSMEDNodes.tWorldCinematicNodeList, sNode)
    return true
  end
  return false
end

function WorldSMEDNodes.IsCinematicNodeLoaded(sNode)
  if Common.IsNodeLoaded(WorldSMEDNodes.tWorldCinematicNodeList, sNode) then
    return true
  else
    return false
  end
end

function WorldSMEDNodes.IsCinematicNodeLoading(sNode)
  for i, tNode in pairs(WorldSMEDNodes.tWorldCinematicNodeList) do
    if string.upper(tNode.sNode) == string.upper(sNode) and tNode.state ~= nil and tNode.state == cSM_LOADING then
      print(tNode.sNode, " is loading ...")
      return true
    end
  end
  return false
end

function WorldSMEDNodes.AreCinematicNodeLoading()
  for i, tNode in pairs(WorldSMEDNodes.tWorldCinematicNodeList) do
    if tNode.state ~= nil and tNode.state == cSM_LOADING then
      return true
    end
  end
  return false
end

function WorldSMEDNodes.LoadInterior(sNode, a_sCallbackFunction, self, tData)
  Util.Assert(false, "WorldSMEDNodes.LoadInterior: Not supported anymore")
  do return end
  if sNode and sNode ~= "" and not Common.IsNodeLoaded(WorldSMEDNodes.tWorldInteriorNodeList, sNode) then
    print("DEBUG:: WS Loading interior node ", sNode, " ", tData[1])
    __UtilFunctions.LoadInteriorNode(sNode, a_sCallbackFunction, self, tData)
    __UtilFunctions.AddLoadNode(WorldSMEDNodes.tWorldInteriorNodeList, sNode)
    return true
  end
  return false
end

function WorldSMEDNodes.UnloadInterior(sNode)
  Util.Assert(false, "WorldSMEDNodes.UnloadInterior: Not supported anymore")
  do return end
  if sNode and sNode ~= "" and Common.IsNodeLoaded(WorldSMEDNodes.tWorldInteriorNodeList, sNode) then
    print("DEBUG:: WS Unloading interior node ", sNode)
    __UtilFunctions.UnloadInteriorNode(sNode)
    __UtilFunctions.RemoveLoadNode(WorldSMEDNodes.tWorldInteriorNodeList, sNode)
    return true
  end
  return false
end

function WorldSMEDNodes.LoadStaticTag(sTag, bForceLoad)
  if sTag and sTag ~= "" and not Common.IsNodeLoaded(WorldSMEDNodes.tWorldStaticTagList, sTag) then
    __UtilFunctions.LoadStaticTag(sTag, bForceLoad)
    __UtilFunctions.AddLoadNode(WorldSMEDNodes.tWorldStaticTagList, sTag)
    return true
  end
  return false
end

function WorldSMEDNodes.UnloadStaticTag(sTag, bForceUnload)
  if sTag and sTag ~= "" and Common.IsNodeLoaded(WorldSMEDNodes.tWorldStaticTagList, sTag) then
    print("DEBUG:: WS Unloading static tag ", sTag)
    __UtilFunctions.UnloadStaticTag(sTag, bForceUnload)
    __UtilFunctions.RemoveLoadNode(WorldSMEDNodes.tWorldStaticTagList, sTag)
    return true
  end
  return false
end

function WorldSMEDNodes.UnloadWorldList(tList, cType)
  if tList and cType then
    if cType == 1 then
      while tList[1] do
        WorldSMEDNodes.UnloadNode(tList[1].sNode, true)
      end
    elseif cType == 2 then
      while tList[1] do
        Util.Assert(false, "WorldSMEDNodes.UnloadWorldList: cType 2 not supported anymore :Interior type")
      end
    elseif cType == 3 then
      while tList[1] do
        WorldSMEDNodes.UnloadStaticTag(tList[1].sNode, true)
      end
    else
      print("incorrect type give for WorldSMEDNodes.UnloadWorldList")
    end
  else
    print("ERROR: bad data passed to WorldSMEDNodes.UnloadWorldList")
  end
end

function WorldSMEDNodes.RestoreWorldList(tList, cType, fCallback)
  if tList and cType then
    if cType == 1 then
      for i, tNode in pairs(tList) do
        if not Common.IsNodeLoaded(WorldSMEDNodes.tWorldNodeList, tNode.sNode) then
          WorldSMEDNodes.LoadNode(tNode.sNode, fCallback, nil, {
            tNode.sNode
          })
        else
          print("this dynamic node is already loaded ", tNode.sNode)
        end
      end
    elseif cType == 2 then
      Util.Assert(false, "WorldSMEDNodes.RestoreWorldList: tWorldInteriorNodeList Not supported anymore")
      do return end
      for i, tNode in pairs(tList) do
        if not Common.IsNodeLoaded(WorldSMEDNodes.tWorldInteriorNodeList, tNode.sNode) then
          WorldSMEDNodes.LoadInterior(tNode.sNode, fCallback, nil, {})
        else
          print("this interior node is already loaded ", tNode.sNode)
        end
      end
    elseif cType == 3 then
      for i, tNode in pairs(tList) do
        WorldSMEDNodes.LoadStaticTag(tNode.sNode, true)
      end
    else
      print("incorrect type give for WorldSMEDNodes.UnloadWorldList")
    end
  else
    print("ERROR: bad data passed to WorldSMEDNodes.UnloadWorldList")
  end
end

function WorldSMEDNodes._AllNodesLoaded()
  WorldSMEDNodes.Loaded = WorldSMEDNodes.Loaded + 1
  if WorldSMEDNodes.Loaded >= WorldSMEDNodes.NeedToLoad then
    WorldSMEDNodes.Loaded = 0
    WorldSMEDNodes.NeedToLoad = 0
    SabTask:CallbackAllWorldNodeTypesUnloaded()
  end
end

function WorldSMEDNodes.Debug_PrintNodeList()
  for i, v in pairs(WorldSMEDNodes.tWorldNodeList) do
    print("DEBUG:: WorldSMEDNodes Loaded: ", v)
  end
end
