if not AmbientRubberStamp then
  AmbientRubberStamp = {}
end

function AmbientRubberStamp:OnEnter()
  AmbientRubberStamp.hController = self.hController
  self.tTypes = {}
  self.tCRCTypes = {
    {},
    {},
    {},
    {},
    {},
    {},
    {},
    {},
    {},
    {},
    {},
    {},
    {},
    {},
    {}
  }
  self.tAmbientTagList = {}
  self.tAreaDestroyTargetList = {}
  self.tAreaDestroyTargetTags = {}
  self.tAreaDestroyTargetBlip = {}
  self.tAmbientMissionTargetTags = {}
  self.tAmbientMissionTargetList = {}
  self.tAmbientFPCompSubIndex = self.tAmbientFPCompSubIndex or {}
  self.tAmbientTagList = Freeplay.GetAllAmbientTags()
  local bTotalsInited = Freeplay.GetAmbientTotalsTable(self.tAmbientTotals)
  local bCompleteInited = Freeplay.GetAmbientCompleteTable(self.tAmbientComplete)
  self.bSetupTrigger = {
    false,
    false,
    false,
    false
  }
  self.tTypes = {
    {
      "AAGun_P1",
      "Armored_P1",
      "Dierker_P1",
      "FuelStation_P1",
      "General_P1",
      "PostCard_P1",
      "PropSpeaker_P1",
      "Radar_P1",
      "Searchlight_P1",
      "SniperNest_P1",
      "SupplyDrop_P1",
      "SweetJump_P1",
      "TopSpot_P1",
      "Tower_P1"
    },
    {
      "AAGun_P2",
      "Armored_P2",
      "Dierker_P2",
      "FuelStation_P2",
      "General_P2",
      "PostCard_P2",
      "PropSpeaker_P2",
      "Radar_P2",
      "Searchlight_P2",
      "SniperNest_P2",
      "SupplyDrop_P2",
      "TopSpot_P2",
      "Tower_P2"
    },
    {
      "AAGun_P3",
      "Armored_P3",
      "Dierker_P3",
      "FuelStation_P3",
      "General_P3",
      "PostCard_P3",
      "PropSpeaker_P3",
      "Radar_P3",
      "Searchlight_P3",
      "SniperNest_P3",
      "SupplyDrop_P3",
      "SweetJump_P3",
      "TopSpot_P3",
      "Tower_P3"
    },
    {
      "AAGun_SB",
      "Armored_SB",
      "General_SB",
      "Radar_SB",
      "Rocket_SB",
      "Searchlight_SB",
      "SweetJump_SB",
      "SupplyDrop_SB",
      "TopSpot_SB",
      "Tower_SB"
    },
    {
      "AAGun_LH",
      "Armored_LH",
      "CoastalGun_LH",
      "FuelStation_LH",
      "General_LH",
      "PostCard_LH",
      "PropSpeaker_LH",
      "Radar_LH",
      "Rocket_LH",
      "Searchlight_LH",
      "SniperNest_LH",
      "SupplyDrop_LH",
      "SweetJump_LH",
      "TopSpot_LH",
      "Tower_LH"
    },
    {
      "AAGun_CA",
      "Armored_CA",
      "CoastalGun_CA",
      "FuelStation_CA",
      "General_CA",
      "PostCard_CA",
      "PropSpeaker_CA",
      "Radar_CA",
      "Rocket_CA",
      "Searchlight_CA",
      "SniperNest_CA",
      "SupplyDrop_CA",
      "SweetJump_CA",
      "TopSpot_CA",
      "Tower_CA"
    },
    {
      "AAGun_LN",
      "Armored_LN",
      "CoastalGun_LN",
      "FuelStation_LN",
      "General_LN",
      "PostCard_LN",
      "PropSpeaker_LN",
      "Radar_LN",
      "Rocket_LN",
      "Searchlight_LN",
      "SniperNest_LN",
      "SupplyDrop_LN",
      "SweetJump_LN",
      "Tower_LN"
    },
    {
      "AAGun_PC",
      "Armored_PC",
      "CoastalGun_PC",
      "FuelStation_PC",
      "General_PC",
      "PostCard_PC",
      "PropSpeaker_PC",
      "Radar_PC",
      "Rocket_PC",
      "Searchlight_PC",
      "SniperNest_PC",
      "SupplyDrop_PC",
      "TopSpot_PC",
      "Tower_PC"
    },
    {
      "AAGun_NM",
      "Armored_NM",
      "FuelStation_NM",
      "General_NM",
      "PropSpeaker_NM",
      "Radar_NM",
      "Rocket_NM",
      "Searchlight_NM",
      "SniperNest_NM",
      "SupplyDrop_NM",
      "Tower_NM"
    },
    {
      "AAGun_CT",
      "Armored_CT",
      "FuelStation_CT",
      "General_CT",
      "PostCard_CT",
      "PropSpeaker_CT",
      "Radar_CT",
      "Rocket_CT",
      "Searchlight_CT",
      "SniperNest_CT",
      "SupplyDrop_CT",
      "Tower_CT"
    },
    {
      "AAGun_BG",
      "Armored_BG",
      "FuelStation_BG",
      "General_BG",
      "PropSpeaker_BG",
      "Radar_BG",
      "Rocket_BG",
      "Searchlight_BG",
      "SniperNest_BG",
      "SupplyDrop_BG",
      "Tower_BG"
    },
    {
      "Converter_CB",
      "Rocket_CB"
    },
    {
      "FuelStation_PR",
      "Rocket_PR",
      "Zeppelin_PR"
    },
    {
      "ChemicalTank_CF"
    },
    {
      "Radar_OS",
      "RadioControl_OS",
      "RadioTower_OS"
    }
  }
  for i, tList in ipairs(self.tTypes) do
    for j, sType in ipairs(tList) do
      self.tCRCTypes[i][j] = sType
    end
  end
  for i, tList in ipairs(self.tCRCTypes) do
    for j, sType in ipairs(tList) do
      self.tCRCTypes[i][j] = Util.GetCRC(sType)
    end
  end
  if not bTotalsInited then
    self.tAmbientTotals = {
      {},
      {},
      {},
      {},
      {},
      {},
      {},
      {},
      {},
      {},
      {},
      {},
      {},
      {},
      {}
    }
    AmbientRubberStamp.GetTotals(self)
  end
  if not bCompleteInited then
    self.tAmbientComplete = {
      {},
      {},
      {},
      {},
      {},
      {},
      {},
      {},
      {},
      {},
      {},
      {},
      {},
      {},
      {}
    }
    for i, tList in ipairs(self.tCRCTypes) do
      for j, hType in ipairs(tList) do
        if self.tAmbientTotals[i][j] ~= nil and self.tAmbientTotals[i][j] > 0 then
          self.tAmbientComplete[i][j] = 0
        end
      end
    end
  end
  AmbientRubberStamp.DoStartupUnlocks()
  Freeplay.SetAmbientOnInitCallback("AmbientRubberStamp.OnInit", self)
  Freeplay.SetAmbientOnCompleteCallback("AmbientRubberStamp.OnComplete", self)
  Freeplay.SetupCollectableCallback("AmbientRubberStamp.CollectablePickedUp", self)
  Freeplay.SetAmbientOnReloadCallback("AmbientRubberStamp.OnEnter", self)
  Freeplay.SetAmbientNamesTable(self.tTypes)
  for i = 12, 15 do
    local nMax = AmbientRubberStamp.GetProgressBarValue(self, 1, i)
    local nCur = AmbientRubberStamp.GetProgressBarValue(self, 2, i)
    if nCur ~= nMax then
      for j, nCompleteEachType in ipairs(self.tAmbientComplete[i]) do
        self.tAmbientComplete[i][j] = 0
      end
    end
  end
  Freeplay.UpdateAmbientCompleteTable(self.tAmbientComplete)
end

function AmbientRubberStamp:GetTotals()
  local bBreak
  for i, hTag in ipairs(self.tAmbientTagList) do
    local my_hType = Freeplay.GetAmbientTypeFromTag(hTag)
    bBreak = false
    local bAmbientSix = AmbientRubberStamp.CheckAmbientSixTag(self, hTag)
    if bAmbientSix then
      local x = AmbientRubberStamp.GetAmbientSixSubIndex(self, hTag)
      if not self.tAmbientTotals[1][x] then
        self.tAmbientTotals[1][x] = 0
      end
      self.tAmbientTotals[1][x] = self.tAmbientTotals[1][x] + 1
    else
      for j, tList in ipairs(self.tCRCTypes) do
        for k, hType in ipairs(tList) do
          if my_hType == hType then
            if not self.tAmbientTotals[j][k] then
              self.tAmbientTotals[j][k] = 0
            end
            self.tAmbientTotals[j][k] = self.tAmbientTotals[j][k] + 1
            bBreak = true
            break
          end
        end
        if bBreak then
          break
        end
      end
    end
  end
  Freeplay.UpdateAmbientTotalsTable(self.tAmbientTotals)
end

function AmbientRubberStamp:OnInit(a_tNodeData)
  local hTag = a_tNodeData[1][1]
  local hNode = a_tNodeData[1][2]
  local hType = a_tNodeData[1][3]
  local tTargets = a_tNodeData[1][4]
  local bBreak = false
  local bIsAreaDestroy = false
  for i, tList in ipairs(self.tCRCTypes) do
    for j, hT in ipairs(tList) do
      if hT == hType then
        local sZone = AmbientRubberStamp.GetZone(self.tTypes[i][j])
        if sZone == "CB" or sZone == "PR" or sZone == "CF" or sZone == "OS" then
          bIsAreaDestroy = true
          AmbientRubberStamp.UpdateAmbientMissionData(self, sZone, hTag, tTargets)
          self.tAreaDestroyTargetTags[sZone] = self.tAreaDestroyTargetTags[sZone] or {}
          self.tAreaDestroyTargetList[sZone] = self.tAreaDestroyTargetList[sZone] or {}
          self.tAreaDestroyTargetBlip[sZone] = self.tAreaDestroyTargetBlip[sZone] or {}
          local bExists = false
          local nIndex = 0
          for k, hData in ipairs(self.tAreaDestroyTargetList[sZone]) do
            if hData == tTargets[1] then
              bExists = true
              nIndex = k
              break
            end
          end
          if not bExists then
            table.insert(self.tAreaDestroyTargetList[sZone], tTargets[1])
            table.insert(self.tAreaDestroyTargetTags[sZone], hTag)
            table.insert(self.tAreaDestroyTargetBlip[sZone], false)
          end
          if nIndex == 0 then
            nIndex = #self.tAreaDestroyTargetBlip[sZone]
          end
          if self.hProgressMeter then
            self.tAreaDestroyTargetBlip[sZone][nIndex] = true
            if tTargets[1] and Object.IsAlive(tTargets[1]) then
              HUD.RemoveObjectiveMarker(tTargets[1])
              HUD.SetObjectiveMarker(tTargets[1], cMMI_Destroy, cOM_Destroy, true, false, true)
            end
          end
          bBreak = true
          break
        end
      end
    end
    if bBreak then
      break
    end
  end
  if not bIsAreaDestroy then
    local tTags = {
      "fp_amb_p1_armcar_shop",
      "fp_amb_p1_general_shop",
      "fp_amb_p1_tower_shop"
    }
    for i, sTag in ipairs(tTags) do
      local hT = Util.GetCRC(sTag)
      if hT == hTag then
        AmbientRubberStamp.UpdateAmbientMissionData(self, "P1S", hTag, tTargets)
        break
      end
    end
  end
end

function AmbientRubberStamp:UpdateAmbientMissionData(a_sZone, a_hTag, a_tTargets)
  self.tAmbientMissionTargetTags[a_sZone] = self.tAmbientMissionTargetTags[a_sZone] or {}
  self.tAmbientMissionTargetList[a_sZone] = self.tAmbientMissionTargetList[a_sZone] or {}
  local bExists = false
  for k, hData in ipairs(self.tAmbientMissionTargetTags[a_sZone]) do
    if hData == a_hTag then
      bExists = true
      break
    end
  end
  if not bExists then
    table.insert(self.tAmbientMissionTargetTags[a_sZone], a_hTag)
    table.insert(self.tAmbientMissionTargetList[a_sZone], a_tTargets)
  end
end

function AmbientRubberStamp:OnComplete(a_tCompData)
  local a_hTag = a_tCompData[1]
  local tAreaDestroyZones = {
    "CB",
    "OS",
    "PR",
    "CF"
  }
  for i, sTempZone in ipairs(tAreaDestroyZones) do
    if self.tAmbientMissionTargetTags[sTempZone] then
      for j, hTag in ipairs(self.tAmbientMissionTargetTags[sTempZone]) do
        if hTag == a_hTag then
          local nSizeofTable = #self.tAmbientMissionTargetList[sTempZone][j]
          local tTargets = self.tAmbientMissionTargetList[sTempZone][j]
          self.tAreaDestroyLastKilled = self.tAreaDestroyLastKilled or {}
          self.tAreaDestroyLastKilled[sTempZone] = self.tAreaDestroyLastKilled[sTempZone] or {}
          self.tAreaDestroyLastKilled[sTempZone][a_hTag] = {
            a_hTag,
            nSizeofTable,
            tTargets
          }
          local tTimerEvent = {EventType = "TimerEvent", Time = 0.1}
          self.eTimerEvent = Util.CreateEvent(tTimerEvent, "AmbientRubberStamp.RemoveLastKilledFromQueue", self, {
            a_tCompData,
            sTempZone,
            a_hTag
          })
          return
        end
      end
    end
  end
  AmbientRubberStamp._OnComplete(self, a_tCompData)
end

function AmbientRubberStamp:_OnComplete(a_tCompData, a_tTargets)
  local a_hTag = a_tCompData[1]
  local a_hPath = a_tCompData[2]
  local a_hType = a_tCompData[3]
  local nI, nJ
  local bBreak = false
  local bAmbientSix = AmbientRubberStamp.CheckAmbientSixTag(self, a_hTag)
  if bAmbientSix then
    local x = AmbientRubberStamp.GetAmbientSixSubIndex(self, a_hTag)
    self.tAmbientComplete[1][x] = (self.tAmbientComplete[1][x] or 0) + 1
    nI, nJ = 1, x
    table.insert(self.tAmbientFPCompSubIndex, nJ)
  else
    for i, tList in ipairs(self.tCRCTypes) do
      for j, hType in ipairs(tList) do
        if a_hType == hType then
          self.tAmbientComplete[i][j] = self.tAmbientComplete[i][j] + 1
          nI, nJ = i, j
          bBreak = true
          break
        end
      end
      if bBreak then
        break
      end
    end
  end
  if not nI or not nJ then
    local hT = Util.GetCRC("fp_amb_p3_supplydrop_46")
    if hT == a_hTag then
      return
    end
    Util.Assert(false, "One or more indices on last destroyed ambient node are nil; type probably not defined for this area.")
  end
  AmbientRubberStamp.RunPerkCheck(self, nI, nJ)
  AmbientRubberStamp.UpdateHUDWithCount(self, self.tTypes[nI][nJ], self.tAmbientComplete[nI][nJ], self.tAmbientTotals[nI][nJ])
  local sProgBarZone = AmbientRubberStamp.GetZone(self.tTypes[nI][nJ])
  local tAreaDestroyZones = {
    "CB",
    "PR",
    "CF",
    "OS"
  }
  local bInAreaDestroy = false
  for i, sZ in ipairs(tAreaDestroyZones) do
    if sZ == sProgBarZone then
      bInAreaDestroy = true
      for j, hT in ipairs(self.tAreaDestroyTargetTags[sZ]) do
        if hT == a_hTag then
          if self.tAreaDestroyTargetBlip[sZ][j] == true then
            HUD.RemoveObjectiveMarker(self.tAreaDestroyTargetList[sZ][j])
          end
          table.remove(self.tAreaDestroyTargetList[sZ], j)
          table.remove(self.tAreaDestroyTargetTags[sZ], j)
          table.remove(self.tAreaDestroyTargetBlip[sZ], j)
          break
        end
      end
      break
    end
  end
  if self.hProgressMeter and bInAreaDestroy then
    local nMax = AmbientRubberStamp.GetProgressBarValue(self, 1, nI)
    local nCur = AmbientRubberStamp.GetProgressBarValue(self, 2, nI)
    HUD.SetProgressBarValue(self.hProgressMeter, nCur / nMax * 100)
  end
  local bAreaDone, sZone = AmbientRubberStamp.CheckCompleteInt(self, self.tTypes[nI][nJ])
  if bAreaDone == true then
    if a_tTargets then
    end
    AmbientRubberStamp.RemoveProgressMeter(self, sProgBarZone)
    if sZone == "CB" then
      FP_AMB_ChambordStart.Task_CutsceneOUT(FP_AMB_ChambordStart)
      Util.UnloadStaticENTag("ambient_chambord_props", false)
      Util.UnloadStaticENTag("ambient_chambord_props_Nazis", false)
    elseif sZone == "PR" then
      P1FP_PalaisBombe.Task_CutsceneOUT(P1FP_PalaisBombe)
      Util.UnloadStaticENTag("ambient_palaisroyale_props", false)
    elseif sZone == "CF" then
      FP_AMB_ChemFactoryStart.Task_CutsceneOUT(FP_AMB_ChemFactoryStart)
    elseif sZone == "OS" then
      P2FP_InfiltrateAbbey.Task_CutsceneOUT(P2FP_InfiltrateAbbey)
    end
  end
  AmbientRubberStamp.DoAchievementChecks(self, self.tTypes[nI][nJ], a_hTag)
  Freeplay.UpdateAmbientCompleteTable(self.tAmbientComplete)
end

function AmbientRubberStamp:CollectablePickedUp(a_hPath)
  local nTotal = Freeplay.GetTotalCollectables()
  local nCount = Freeplay.GetNumCollectablesCollected()
  AmbientRubberStamp.UpdateHUDWithCount(self, "PictureCollection", nCount, nTotal)
end

function AmbientRubberStamp:UpdateHUDWithCount(a_sType, a_nNumerator, a_nDenominator)
  local nReward = AmbientRubberStamp.GetReward(self, a_sType)
  local szText = "FP_AMB_Text." .. a_sType
  local sType = AmbientRubberStamp.GetType(a_sType)
  if sType == "BridgeKiller" then
    local tTimerEvent = {EventType = "TimerEvent", Time = 7.5}
    Util.CreateEvent(tTimerEvent, "AmbientRubberStamp.ShowDelayedHUDText", self, {
      nReward,
      szText,
      a_nNumerator,
      a_nDenominator
    })
  else
    local bForce = nReward == 0
    HUD.AddContraband(nReward, szText, 2, a_nNumerator, a_nDenominator, bForce)
  end
end

function AmbientRubberStamp:ShowDelayedHUDText(nMoney, a_sText, a_nNumerator, a_nDenominator)
  local bForce = nMoney == 0
  HUD.AddContraband(nMoney, szText, 2, a_nNumerator, a_nDenominator, bForce)
end

function AmbientRubberStamp.UnlockAllAmbientTags(a_bForceLoadAll)
  local tAmbientTagList = Freeplay.GetAllAmbientTags()
  if a_bForceLoadAll == true then
    for i, hTag in ipairs(tAmbientTagList) do
      Freeplay.UnlockAmbientTag(hTag, true)
    end
    return
  end
end

function AmbientRubberStamp.DoStartupUnlocks()
  AmbientRubberStamp.UnlockAmbientAAGun("SB")
  AmbientRubberStamp.UnlockAmbientArmored("SB")
  AmbientRubberStamp.UnlockAmbientRadar("SB")
  AmbientRubberStamp.UnlockAmbientRocket("SB")
  AmbientRubberStamp.UnlockAmbientSearchlight("SB")
  AmbientRubberStamp.UnlockAmbientTower("SB")
  AmbientRubberStamp.UnlockAmbientAllInZone({
    "P1",
    "P2",
    "P3",
    "LH"
  })
  AmbientRubberStamp.UnlockAmbientSweetJump()
  AmbientRubberStamp.UnlockAmbientTopSpot()
  local hSupDropCatTag = Util.GetCRC("fp_amb_p3_supplydrop_46")
  Freeplay.UnlockAmbientTag(hSupDropCatTag)
end

function AmbientRubberStamp.UnlockAmbientAllInZone(a_vZone)
  AmbientRubberStamp.UnlockAmbientAAGun(a_vZone)
  AmbientRubberStamp.UnlockAmbientArmored(a_vZone)
  AmbientRubberStamp.UnlockAmbientBridgeKiller(a_vZone)
  AmbientRubberStamp.UnlockAmbientChemicalTank(a_vZone)
  AmbientRubberStamp.UnlockAmbientCoastalGun(a_vZone)
  AmbientRubberStamp.UnlockAmbientConverter(a_vZone)
  AmbientRubberStamp.UnlockAmbientDierker(a_vZone)
  AmbientRubberStamp.UnlockAmbientFuelStation(a_vZone)
  AmbientRubberStamp.UnlockAmbientGeneral(a_vZone)
  AmbientRubberStamp.UnlockAmbientPostCard(a_vZone)
  AmbientRubberStamp.UnlockAmbientPropSpeaker(a_vZone)
  AmbientRubberStamp.UnlockAmbientRadar(a_vZone)
  AmbientRubberStamp.UnlockAmbientRadioControl(a_vZone)
  AmbientRubberStamp.UnlockAmbientRadioTower(a_vZone)
  AmbientRubberStamp.UnlockAmbientRocket(a_vZone)
  AmbientRubberStamp.UnlockAmbientSearchlight(a_vZone)
  AmbientRubberStamp.UnlockAmbientSniperNest(a_vZone)
  AmbientRubberStamp.UnlockAmbientSupplyDrop(a_vZone)
  AmbientRubberStamp.UnlockAmbientSweetJump(a_vZone)
  AmbientRubberStamp.UnlockAmbientTopSpot(a_vZone)
  AmbientRubberStamp.UnlockAmbientTower(a_vZone)
  AmbientRubberStamp.UnlockAmbientZeppelin(a_vZone)
end

function AmbientRubberStamp.UnlockAmbientAAGun(a_vZone)
  AmbientRubberStamp.UnlockAmbient("AAGun", a_vZone)
end

function AmbientRubberStamp.UnlockAmbientArmored(a_vZone)
  AmbientRubberStamp.UnlockAmbient("Armored", a_vZone)
end

function AmbientRubberStamp.UnlockAmbientBridgeKiller(a_vZone)
  AmbientRubberStamp.UnlockAmbient("BridgeKiller", a_vZone)
end

function AmbientRubberStamp.UnlockAmbientChemicalTank(a_vZone)
  AmbientRubberStamp.UnlockAmbient("ChemicalTank", a_vZone)
end

function AmbientRubberStamp.UnlockAmbientCoastalGun(a_vZone)
  AmbientRubberStamp.UnlockAmbient("CoastalGun", a_vZone)
end

function AmbientRubberStamp.UnlockAmbientConverter(a_vZone)
  AmbientRubberStamp.UnlockAmbient("Converter", a_vZone)
end

function AmbientRubberStamp.UnlockAmbientDierker(a_vZone)
  AmbientRubberStamp.UnlockAmbient("Dierker", a_vZone)
end

function AmbientRubberStamp.UnlockAmbientFuelStation(a_vZone)
  AmbientRubberStamp.UnlockAmbient("FuelStation", a_vZone)
end

function AmbientRubberStamp.UnlockAmbientGenerals(a_vZone)
  AmbientRubberStamp.UnlockAmbientGeneral(a_vZone)
end

function AmbientRubberStamp.UnlockAmbientGeneral(a_vZone)
  AmbientRubberStamp.UnlockAmbient("General", a_vZone)
end

function AmbientRubberStamp.UnlockAmbientPostCard(a_vZone)
  AmbientRubberStamp.UnlockAmbient("PostCard", a_vZone)
end

function AmbientRubberStamp.UnlockAmbientPropSpeaker(a_vZone)
  AmbientRubberStamp.UnlockAmbient("PropSpeaker", a_vZone)
end

function AmbientRubberStamp.UnlockAmbientRadar(a_vZone)
  AmbientRubberStamp.UnlockAmbient("Radar", a_vZone)
end

function AmbientRubberStamp.UnlockAmbientRadioControl(a_vZone)
  AmbientRubberStamp.UnlockAmbient("RadioControl", a_vZone)
end

function AmbientRubberStamp.UnlockAmbientRadioTower(a_vZone)
  AmbientRubberStamp.UnlockAmbient("RadioTower", a_vZone)
end

function AmbientRubberStamp.UnlockAmbientRocket(a_vZone)
  AmbientRubberStamp.UnlockAmbient("Rocket", a_vZone)
end

function AmbientRubberStamp.UnlockAmbientSearchlight(a_vZone)
  AmbientRubberStamp.UnlockAmbient("Searchlight", a_vZone)
end

function AmbientRubberStamp.UnlockAmbientSniperNest(a_vZone)
  AmbientRubberStamp.UnlockAmbient("SniperNest", a_vZone)
end

function AmbientRubberStamp.UnlockAmbientSupplyDrop(a_vZone)
  AmbientRubberStamp.UnlockAmbient("SupplyDrop", a_vZone)
end

function AmbientRubberStamp.UnlockAmbientSweetJump(a_vZone)
  AmbientRubberStamp.UnlockAmbient("SweetJump", a_vZone)
end

function AmbientRubberStamp.UnlockAmbientTopSpot(a_vZone)
  AmbientRubberStamp.UnlockAmbient("TopSpot", a_vZone)
end

function AmbientRubberStamp.UnlockAmbientTower(a_vZone)
  AmbientRubberStamp.UnlockAmbient("Tower", a_vZone)
end

function AmbientRubberStamp.UnlockAmbientZeppelin(a_vZone)
  AmbientRubberStamp.UnlockAmbient("Zeppelin", a_vZone)
end

function AmbientRubberStamp.LockAmbientAllInZone(a_vZone)
  AmbientRubberStamp.LockAmbient("AAGun", a_vZone)
  AmbientRubberStamp.LockAmbient("Armored", a_vZone)
  AmbientRubberStamp.LockAmbient("BridgeKiller", a_vZone)
  AmbientRubberStamp.LockAmbient("ChemicalTank", a_vZone)
  AmbientRubberStamp.LockAmbient("CoastalGun", a_vZone)
  AmbientRubberStamp.LockAmbient("Converter", a_vZone)
  AmbientRubberStamp.LockAmbient("Dierker", a_vZone)
  AmbientRubberStamp.LockAmbient("FuelStation", a_vZone)
  AmbientRubberStamp.LockAmbient("General", a_vZone)
  AmbientRubberStamp.LockAmbient("PostCard", a_vZone)
  AmbientRubberStamp.LockAmbient("PropSpeaker", a_vZone)
  AmbientRubberStamp.LockAmbient("Radar", a_vZone)
  AmbientRubberStamp.LockAmbient("RadioControl", a_vZone)
  AmbientRubberStamp.LockAmbient("RadioTower", a_vZone)
  AmbientRubberStamp.LockAmbient("Rocket", a_vZone)
  AmbientRubberStamp.LockAmbient("Searchlight", a_vZone)
  AmbientRubberStamp.LockAmbient("SniperNest", a_vZone)
  AmbientRubberStamp.LockAmbient("SupplyDrop", a_vZone)
  AmbientRubberStamp.LockAmbient("SweetJump", a_vZone)
  AmbientRubberStamp.LockAmbient("TopSpot", a_vZone)
  AmbientRubberStamp.LockAmbient("Tower", a_vZone)
  AmbientRubberStamp.LockAmbient("Zeppelin", a_vZone)
end

function AmbientRubberStamp.LockAmbient(a_sType, a_vZone)
  local tAmbientTagList = Freeplay.GetAllAmbientTags()
  local tTypes = {}
  if a_vZone ~= nil then
    if type(a_vZone) == "table" then
      for j, sZone in ipairs(a_vZone) do
        if AmbientRubberStamp.ErrorCheckZone(sZone) == false then
          Util.Assert(false, "JMILLER: (ARS) sZone " .. sZone .. " isn't a valid zone type; affects type " .. a_sType)
        else
          table.insert(tTypes, a_sType .. "_" .. string.upper(sZone))
        end
      end
    elseif type(a_vZone) == "string" then
      if AmbientRubberStamp.ErrorCheckZone(a_vZone) == false then
        Util.Assert(false, "JMILLER: (ARS) sZone " .. a_vZone .. " isn't a valid zone type; affects type " .. a_sType)
      else
        table.insert(tTypes, a_sType .. "_" .. string.upper(a_vZone))
      end
    end
  else
    return -1
  end
  for i, sType in ipairs(tTypes) do
    tTypes[i] = Util.GetCRC(sType)
  end
  if 0 < #tTypes then
    Freeplay.UnlockAmbientType(tTypes, true, true)
  else
    Util.Assert(false, "JMILLER: (ARS) tTypes is empty, cannot lock anything; affects a call to lock " .. a_sType)
  end
end

function AmbientRubberStamp.UnlockAmbient(a_sType, a_vZone)
  local tAmbientTagList = Freeplay.GetAllAmbientTags()
  local tTypes = {}
  if a_vZone ~= nil then
    if type(a_vZone) == "table" then
      for j, sZone in ipairs(a_vZone) do
        if AmbientRubberStamp.ErrorCheckZone(sZone) == false then
          Util.Assert(false, "JMILLER: (ARS) sZone " .. sZone .. " isn't a valid zone type; affects type " .. a_sType)
        else
          table.insert(tTypes, a_sType .. "_" .. string.upper(sZone))
        end
      end
    elseif type(a_vZone) == "string" then
      if AmbientRubberStamp.ErrorCheckZone(a_vZone) == false then
        Util.Assert(false, "JMILLER: (ARS) sZone " .. a_vZone .. " isn't a valid zone type; affects type " .. a_sType)
      else
        table.insert(tTypes, a_sType .. "_" .. string.upper(a_vZone))
      end
    end
  else
    local tZones = {
      "P1",
      "P2",
      "P3",
      "LH",
      "SB",
      "CA",
      "LN",
      "PC",
      "NM",
      "CT",
      "BG",
      "CB",
      "PR",
      "CF",
      "OS"
    }
    for i, sZone in ipairs(tZones) do
      table.insert(tTypes, a_sType .. "_" .. sZone)
    end
  end
  for i, sType in ipairs(tTypes) do
    tTypes[i] = Util.GetCRC(sType)
  end
  if 0 < #tTypes then
    Freeplay.UnlockAmbientType(tTypes, true)
  else
    Util.Assert(false, "JMILLER: (ARS) tTypes is empty, cannot unlock anything; affects a call to unlock " .. a_sType)
  end
end

function AmbientRubberStamp.ErrorCheckZone(a_sZone)
  local tZones = {
    "P1",
    "P2",
    "P3",
    "LH",
    "SB",
    "CA",
    "LN",
    "PC",
    "NM",
    "CT",
    "BG",
    "CB",
    "PR",
    "CF",
    "OS"
  }
  local bPass = false
  for i, sZone in ipairs(tZones) do
    if string.upper(a_sZone) == sZone then
      bPass = true
      break
    end
  end
  return bPass
end

function AmbientRubberStamp:GetReward(a_sType)
  local nLen = string.len(a_sType)
  local sType = string.sub(a_sType, 1, nLen - 3)
  local sZone = AmbientRubberStamp.GetZone(a_sType)
  return RewardsManager.GetAmbReward(sType, sZone)
end

function AmbientRubberStamp:CheckCompleteInt(a_sType)
  local sZone = AmbientRubberStamp.GetZone(a_sType)
  if AmbientRubberStamp.ErrorCheckZone(sZone) == false then
    Util.Assert(false, "JMILLER: (ARS) sZone " .. sZone .. " isn't a valid zone type; CheckCompleteInt passed type " .. a_sType)
    return false
  end
  if sZone == "CB" then
    return AmbientRubberStamp.CheckFinished(self.tAmbientTotals[12], self.tAmbientComplete[12]), "CB"
  elseif sZone == "PR" then
    return AmbientRubberStamp.CheckFinished(self.tAmbientTotals[13], self.tAmbientComplete[13]), "PR"
  elseif sZone == "CF" then
    return AmbientRubberStamp.CheckFinished(self.tAmbientTotals[14], self.tAmbientComplete[14]), "CF"
  elseif sZone == "OS" then
    return AmbientRubberStamp.CheckFinished(self.tAmbientTotals[15], self.tAmbientComplete[15]), "OS"
  end
  return false
end

function AmbientRubberStamp.CheckComplete(a_sType)
  local tAmbientTotals = {}
  local tAmbientComplete = {}
  Freeplay.GetAmbientTotalsTable(tAmbientTotals)
  Freeplay.GetAmbientCompleteTable(tAmbientComplete)
  local sZone = AmbientRubberStamp.GetZone(a_sType)
  if AmbientRubberStamp.ErrorCheckZone(sZone) == false then
    Util.Assert(false, "JMILLER: (ARS) sZone " .. sZone .. " isn't a valid zone type; CheckComplete passed type " .. a_sType)
    return false
  end
  if a_sZone == "CB" then
    return AmbientRubberStamp.CheckFinished(tAmbientTotals[12], tAmbientComplete[12])
  elseif sZone == "PR" then
    return AmbientRubberStamp.CheckFinished(tAmbientTotals[13], tAmbientComplete[13])
  elseif sZone == "CF" then
    return AmbientRubberStamp.CheckFinished(tAmbientTotals[14], tAmbientComplete[14])
  elseif sZone == "OS" then
    return AmbientRubberStamp.CheckFinished(tAmbientTotals[15], tAmbientComplete[15])
  end
  return false
end

function AmbientRubberStamp.GetZone(a_sType)
  local sSub = string.sub(a_sType, -2)
  return string.upper(sSub)
end

function AmbientRubberStamp.GetType(a_sType)
  local nLen = string.len(a_sType)
  local sSub = string.sub(a_sType, 1, nLen - 3)
  return sSub
end

function AmbientRubberStamp.CheckFinished(a_tTotals, a_tComplete)
  for i, nComp in ipairs(a_tComplete) do
    if nComp ~= a_tTotals[i] then
      return false
    end
  end
  return true
end

function AmbientRubberStamp.CheckNotReallyFinished(a_tTotals, a_tComplete)
  local nTotal = 0
  local nComplete = 0
  for i, nComp in ipairs(a_tComplete) do
    nComplete = nComplete + nComp
    nTotal = nTotal + a_tTotals[i]
  end
  if nComplete >= nTotal - 3 then
    return true
  else
    return false
  end
end

function AmbientRubberStamp:SetupTriggers(a_sTrig)
  local tTrigs = {
    "Missions\\freeplay\\ambient\\cb\\PT_ChamCompTrig",
    "Missions\\freeplay\\ambient\\pr\\PT_PalaisCompTrig",
    "Missions\\freeplay\\ambient\\cf\\PT_ChemCompTrig",
    "Missions\\freeplay\\ambient\\os\\PT_LossCompTrig"
  }
  local nIndex
  if a_sTrig == "CB" then
    nIndex = 1
  elseif a_sTrig == "PR" then
    nIndex = 2
  elseif a_sTrig == "CF" then
    nIndex = 3
  elseif a_sTrig == "OS" then
    nIndex = 4
  end
  if self.bSetupTrigger[nIndex] then
    return
  end
  Trigger.WaitFor(tTrigs[nIndex], Handle("Saboteur"), "AmbientRubberStamp.UpdateProgressMeter", self, {
    tTrigs,
    tTrigs[nIndex],
    nIndex
  }, cTRIGGEREVENT_ONENTER, true)
  Trigger.WaitFor(tTrigs[nIndex], Handle("Saboteur"), "AmbientRubberStamp.RemoveProgressMeter", self, {nIndex}, cTRIGGEREVENT_ONEXIT, true)
  self.bSetupTrigger[nIndex] = true
  local nCount = 0
  for i, bCheck in ipairs(self.bSetupTrigger) do
    if bCheck then
      nCount = nCount + 1
    end
  end
  if nCount == 4 then
    self.bDoneSettingUpTrigs = true
  end
end

function AmbientRubberStamp.UpdateProgressMeter(a_sTrigger, a_nIndex)
  local a_tTriggerList = {
    "Missions\\freeplay\\ambient\\cb\\PT_ChamCompTrig",
    "Missions\\freeplay\\ambient\\pr\\PT_PalaisCompTrig",
    "Missions\\freeplay\\ambient\\cf\\PT_ChemCompTrig",
    "Missions\\freeplay\\ambient\\os\\PT_LossCompTrig"
  }
  local self = Actor.GetSelf(AmbientRubberStamp.hController)
  local nMax, nCur, nIndex
  local tZones = {
    "CB",
    "PR",
    "CF",
    "OS"
  }
  if a_sTrigger == a_tTriggerList[1] then
    nMax = AmbientRubberStamp.GetProgressBarValue(self, 1, 12)
    nCur = AmbientRubberStamp.GetProgressBarValue(self, 2, 12)
  elseif a_sTrigger == a_tTriggerList[2] then
    nMax = AmbientRubberStamp.GetProgressBarValue(self, 1, 13)
    nCur = AmbientRubberStamp.GetProgressBarValue(self, 2, 13)
  elseif a_sTrigger == a_tTriggerList[3] then
    nMax = AmbientRubberStamp.GetProgressBarValue(self, 1, 14)
    nCur = AmbientRubberStamp.GetProgressBarValue(self, 2, 14)
  elseif a_sTrigger == a_tTriggerList[4] then
    nMax = AmbientRubberStamp.GetProgressBarValue(self, 1, 15)
    nCur = AmbientRubberStamp.GetProgressBarValue(self, 2, 15)
  end
  self.hDestroyObj = HUD.AddObjective(eOT_DESTROY, "FP_AMB_Text.AreaDestroy" .. a_nIndex, 1)
  self.hProgressMeter = HUD.AddObjective(eOT_HEART, "FP_AMB_Text.ProgressMeter", 2)
  HUD.SetupProgressBar(self.hProgressMeter, 0, 100, nCur / nMax * 100)
  local sZone = tZones[a_nIndex]
  local i = 1
  while i <= #self.tAreaDestroyTargetList[sZone] do
    local hEntity = self.tAreaDestroyTargetList[sZone][i]
    local bHandleValid = Util.IsHandleValid(hEntity) or Util.IsObjectHandleValid(hEntity)
    if bHandleValid then
      if self.tAreaDestroyTargetBlip[sZone][i] == false then
        self.tAreaDestroyTargetBlip[sZone][i] = true
        if hEntity and Object.IsAlive(hEntity) then
          HUD.SetObjectiveMarker(hEntity, cMMI_Destroy, cOM_Destroy, true, false, true)
        end
      end
      i = i + 1
    else
      table.remove(self.tAreaDestroyTargetList[sZone], i)
      table.remove(self.tAreaDestroyTargetTags[sZone], i)
      table.remove(self.tAreaDestroyTargetBlip[sZone], i)
    end
  end
end

function AmbientRubberStamp:RemoveProgressMeter(a_vIndex)
  local tZones = {
    "CB",
    "PR",
    "CF",
    "OS"
  }
  local nIndex = 0
  if type(a_vIndex) == "string" then
    for i, sZone in ipairs(tZones) do
      if a_vIndex == sZone then
        nIndex = i
        break
      end
    end
  else
    nIndex = a_vIndex
  end
  if self.hProgressMeter then
    HUD.RemoveObjective(self.hDestroyObj)
    HUD.RemoveObjective(self.hProgressMeter)
    self.hDestroyObj = nil
    self.hProgressMeter = nil
    local sZone = tZones[nIndex]
    if 0 < #self.tAreaDestroyTargetList then
      for i, hEntity in ipairs(self.tAreaDestroyTargetList[sZone]) do
        if self.tAreaDestroyTargetBlip[sZone][i] == true then
          self.tAreaDestroyTargetBlip[sZone][i] = false
          HUD.RemoveObjectiveMarker(hEntity)
        end
      end
    end
  end
end

function AmbientRubberStamp.RemoveBlips(a_nIndex)
  local self = Actor.GetSelf(AmbientRubberStamp.hController)
  local tZones = {
    "CB",
    "PR",
    "CF",
    "OS"
  }
  local sZone = tZones[a_nIndex]
  local i = 1
  while i <= #self.tAreaDestroyTargetList[sZone] do
    local hEntity = self.tAreaDestroyTargetList[sZone][i]
    local bHandleValid = Util.IsHandleValid(hEntity) or Util.IsObjectHandleValid(hEntity)
    if bHandleValid then
      self.tAreaDestroyTargetBlip[sZone][i] = false
      HUD.RemoveObjectiveMarker(hEntity)
      i = i + 1
    else
      table.remove(self.tAreaDestroyTargetList[sZone], i)
      table.remove(self.tAreaDestroyTargetTags[sZone], i)
      table.remove(self.tAreaDestroyTargetBlip[sZone], i)
    end
  end
end

function AmbientRubberStamp:GetProgressBarValue(a_nWhich, a_nIndex)
  local nCount = 0
  local i = 1
  if a_nWhich == 1 then
    while i <= #self.tAmbientTotals[a_nIndex] do
      if self.tAmbientTotals[a_nIndex][i] then
        nCount = nCount + self.tAmbientTotals[a_nIndex][i]
      end
      i = i + 1
    end
  elseif a_nWhich == 2 then
    while i <= #self.tAmbientComplete[a_nIndex] do
      if self.tAmbientComplete[a_nIndex][i] then
        nCount = nCount + self.tAmbientComplete[a_nIndex][i]
      end
      i = i + 1
    end
  end
  return nCount
end

function AmbientRubberStamp:UnregisterTrigger(a_nIndex)
  if a_nIndex == 12 then
    Trigger.Enable("Missions\\freeplay\\ambient\\cb\\PT_ChamCompTrig", false)
  elseif a_nIndex == 13 then
    Trigger.Enable("Missions\\freeplay\\ambient\\pr\\PT_PalaisCompTrig", false)
  elseif a_nIndex == 14 then
    Trigger.Enable("Missions\\freeplay\\ambient\\cf\\PT_ChemCompTrig", false)
  elseif a_nIndex == 15 then
    Trigger.Enable("Missions\\freeplay\\ambient\\os\\PT_LossCompTrig", false)
  end
end

function AmbientRubberStamp:UpdateParentZone(a_nParentZone, a_sTableType, a_nIndex, a_nSubIndex)
  local tParentZones
  if a_nParentZone == 1 then
    tParentZones = {"PR", "CF"}
  elseif a_nParentZone == 13 then
    tParentZones = {
      "CB",
      "CA",
      "LN",
      "PC",
      "NM",
      "CT",
      "BG",
      "OS"
    }
  end
  local sZone = AmbientRubberStamp.GetZone(self.tTypes[a_nIndex][a_nSubIndex])
  local sType = AmbientRubberStamp.GetType(self.tTypes[a_nIndex][a_nSubIndex])
  local tTable
  if a_sTableType == "TOTALS" then
    tTable = self.tAmbientTotals
  else
    tTable = self.tAmbientComplete
  end
  for i, sZ in ipairs(tParentZones) do
    if sZone == sZ then
      for j, sT in ipairs(self.tTypes[a_nParentZone]) do
        local my_sType = AmbientRubberStamp.GetType(sT)
        if sType == my_sType then
          if not tTable[a_nParentZone][j] then
            tTable[a_nParentZone][j] = 0
          end
          tTable[a_nParentZone][j] = tTable[a_nParentZone][j] + 1
          return true
        end
      end
    end
  end
  return false
end

function AmbientRubberStamp:DoAchievementChecks(a_sType, a_hTag)
  local bComplete = false
  self.tAchieveTypes = {
    "AAGun",
    "Armored",
    "CoastalGun",
    "Dierker",
    "FuelStation",
    "General",
    "PropSpeaker",
    "PostCard",
    "Radar",
    "Rocket",
    "Searchlight",
    "SniperNest",
    "SupplyDrop",
    "SweetJump",
    "TopSpot",
    "Tower"
  }
  self.tAchieveCount = self.tAchieveCount or {}
  self.tAchievementUnlocked = self.tAchievementUnlocked or {}
  if #self.tAchieveCount <= 0 then
    for i, sType in ipairs(self.tAchieveTypes) do
      local bBreak = false
      self.tAchieveCount[i] = false
      for j, tList in ipairs(self.tTypes) do
        for k, sT in ipairs(tList) do
          local sNewType = AmbientRubberStamp.GetType(sT)
          if sNewType == sType then
            if self.tAmbientComplete[j][k] and 0 < self.tAmbientComplete[j][k] then
              self.tAchieveCount[i] = true
              if not self.tAchievementUnlocked[1] and sNewType ~= "General" and sNewType ~= "SupplyDrop" then
                Freeplay.UnlockFreeplayAchievement("AFP_ANY")
                self.tAchievementUnlocked[1] = true
              end
              bBreak = true
            end
            break
          end
        end
        if bBreak then
          break
        end
      end
    end
  else
    local sType = AmbientRubberStamp.GetType(a_sType)
    for i, sT in ipairs(self.tAchieveTypes) do
      if sType == sT then
        if self.tAchieveCount[i] == false then
          self.tAchieveCount[i] = true
        end
        if not self.tAchievementUnlocked[1] and sType ~= "General" and sType ~= "SupplyDrop" then
          Freeplay.UnlockFreeplayAchievement("AFP_ANY")
          self.tAchievementUnlocked[1] = true
        end
        break
      end
    end
  end
  local bEiffel = Freeplay.IsFreeplayAchievementUnlocked("EIFFEL")
  if not bEiffel then
    AmbientRubberStamp.CheckEiffelTower(a_hTag)
  end
  if not self.tAchievementUnlocked[2] then
    local nCount = 0
    if Freeplay.IsFreeplayAchievementUnlocked("AFP_EACH_TYPE") then
      self.tAchievementUnlocked[2] = true
    else
      for i, bDone in ipairs(self.tAchieveCount) do
        if bDone == true then
          nCount = nCount + 1
        end
      end
      if nCount == #self.tAchieveCount then
        Freeplay.UnlockFreeplayAchievement("AFP_EACH_TYPE")
        self.tAchievementUnlocked[2] = true
      end
    end
  end
  if not self.tAchievementUnlocked[3] then
    if Freeplay.IsFreeplayAchievementUnlocked("AFP_PARIS1") then
      self.tAchievementUnlocked[3] = true
    else
      bComplete = AmbientRubberStamp.CheckNotReallyFinished(self.tAmbientTotals[1], self.tAmbientComplete[1])
      if bComplete == true then
        Freeplay.UnlockFreeplayAchievement("AFP_PARIS1")
        self.tAchievementUnlocked[3] = true
      end
    end
  end
  if not self.tAchievementUnlocked[4] then
    if Freeplay.IsFreeplayAchievementUnlocked("AFP_PARIS2") then
      self.tAchievementUnlocked[4] = true
    else
      bComplete = AmbientRubberStamp.CheckNotReallyFinished(self.tAmbientTotals[2], self.tAmbientComplete[2])
      if bComplete == true then
        Freeplay.UnlockFreeplayAchievement("AFP_PARIS2")
        self.tAchievementUnlocked[4] = true
      end
    end
  end
  if not self.tAchievementUnlocked[5] then
    if Freeplay.IsFreeplayAchievementUnlocked("AFP_PARIS3") then
      self.tAchievementUnlocked[5] = true
    else
      bComplete = AmbientRubberStamp.CheckNotReallyFinished(self.tAmbientTotals[3], self.tAmbientComplete[3])
      if bComplete == true then
        Freeplay.UnlockFreeplayAchievement("AFP_PARIS3")
        self.tAchievementUnlocked[5] = true
      end
    end
  end
  if not self.tAchievementUnlocked[6] then
    if Freeplay.IsFreeplayAchievementUnlocked("AFP_SAAR") then
      self.tAchievementUnlocked[6] = true
    else
      bComplete = AmbientRubberStamp.CheckNotReallyFinished(self.tAmbientTotals[4], self.tAmbientComplete[4])
      if bComplete == true then
        Freeplay.UnlockFreeplayAchievement("AFP_SAAR")
        self.tAchievementUnlocked[6] = true
      end
    end
  end
  if not self.tAchievementUnlocked[7] then
    if Freeplay.IsFreeplayAchievementUnlocked("AFP_LEHAVRE") then
      self.tAchievementUnlocked[7] = true
    else
      bComplete = AmbientRubberStamp.CheckNotReallyFinished(self.tAmbientTotals[5], self.tAmbientComplete[5])
      if bComplete == true then
        Freeplay.UnlockFreeplayAchievement("AFP_LEHAVRE")
        self.tAchievementUnlocked[7] = true
      end
    end
  end
  if not self.tAchievementUnlocked[8] then
    if Freeplay.IsFreeplayAchievementUnlocked("AFP_COUNTRY") then
      self.tAchievementUnlocked[8] = true
    else
      local tFinished = {}
      local bCanGiveAchievement = true
      for i = 6, 11 do
        bComplete = AmbientRubberStamp.CheckNotReallyFinished(self.tAmbientTotals[i], self.tAmbientComplete[i])
        table.insert(tFinished, bComplete)
      end
      for i, bCompleted in ipairs(tFinished) do
        if not bCompleted then
          bCanGiveAchievement = false
          break
        end
      end
      if bCanGiveAchievement == true then
        Freeplay.UnlockFreeplayAchievement("AFP_COUNTRY")
        self.tAchievementUnlocked[8] = true
      end
    end
  end
end

function AmbientRubberStamp.CheckEiffelTower(a_hTag)
  local hEiffelSpotTag = Util.GetCRC("fp_amb_p3_spot_01")
  if hEiffelSpotTag == a_hTag then
    Freeplay.UnlockFreeplayAchievement("EIFFEL")
  end
end

function AmbientRubberStamp:RunPerkCheck(a_nIndex, a_nSubIndex)
  local sType = AmbientRubberStamp.GetType(self.tTypes[a_nIndex][a_nSubIndex])
  if sType == "Tower" or sType == "SniperNest" then
    Util.SendPerkMessage("TowerBlownUp")
  end
  local tGoodTypes = {
    "AAGun",
    "Armored",
    "BridgeKiller",
    "CoastalGun",
    "Dierker",
    "FuelStation",
    "PropSpeaker",
    "Radar",
    "Rocket",
    "Searchlight",
    "SniperNest",
    "Tower"
  }
  for i, sT in ipairs(tGoodTypes) do
    if sType == sT then
      Util.SendPerkMessage("AmbientFreeplayDestroyed")
      break
    end
  end
end

function AmbientRubberStamp:CheckAmbientSixTag(a_hTag)
  local tTags = {
    "fp_amb_p1_armcar_shop",
    "fp_amb_p1_general_shop",
    "fp_amb_p1_tower_shop"
  }
  local tCRCTags = {}
  for i, sTag in ipairs(tTags) do
    tCRCTags[i] = Util.GetCRC(sTag)
  end
  for i, hTag in ipairs(tCRCTags) do
    if hTag == a_hTag then
      return true
    end
  end
  return false
end

function AmbientRubberStamp:GetAmbientSixSubIndex(a_hTag)
  local tP1TypeSubIndices = {
    2,
    5,
    14
  }
  local tTags = {
    "fp_amb_p1_armcar_shop",
    "fp_amb_p1_general_shop",
    "fp_amb_p1_tower_shop"
  }
  local tCRCTags = {}
  for i, sTag in ipairs(tTags) do
    tCRCTags[i] = Util.GetCRC(sTag)
  end
  for i, hTag in ipairs(tCRCTags) do
    if hTag == a_hTag then
      return tP1TypeSubIndices[i]
    end
  end
end

function AmbientRubberStamp.UnlockAmbientFPMissionNodes()
  local tTags = {
    "fp_amb_p1_tower_shop",
    "fp_amb_p1_general_shop",
    "fp_amb_p1_armcar_shop"
  }
  local tCRCTags = {}
  for i, sTag in ipairs(tTags) do
    tCRCTags[i] = Util.GetCRC(sTag)
  end
  for i, hTag in ipairs(tCRCTags) do
    Freeplay.UnlockAmbientTag(hTag, true)
  end
end

function AmbientRubberStamp.RemoveMissionCountsFromTotals(a_nIndex)
  local self = Actor.GetSelf(AmbientRubberStamp.hController)
  local tZoneNums = {
    12,
    13,
    14,
    15
  }
  local nIndex = tZoneNums[a_nIndex]
  for i, nCompleteEachType in ipairs(self.tAmbientComplete[nIndex]) do
    self.tAmbientComplete[nIndex][i] = 0
  end
  Freeplay.UpdateAmbientCompleteTable(self.tAmbientComplete)
end

function AmbientRubberStamp.RemoveAmbientFPCountsFromTotals()
  local self = Actor.GetSelf(AmbientRubberStamp.hController)
  for i, nSubIndex in ipairs(self.tAmbientFPCompSubIndex) do
    self.tAmbientComplete[1][nSubIndex] = self.tAmbientComplete[1][nSubIndex] - 1
    if self.tAmbientComplete[1][nSubIndex] < 0 then
      self.tAmbientComplete[1][nSubIndex] = 0
    end
  end
  self.tAmbientFPCompSubIndex = {}
end

function AmbientRubberStamp.UnloadMissionNodes(a_sZone)
  local self = Actor.GetSelf(AmbientRubberStamp.hController)
  local hType
  if a_sZone == "PR" or a_sZone == "CB" or a_sZone == "CF" or a_sZone == "OS" then
    if self.tAreaDestroyTargetList and self.tAreaDestroyTargetList[a_sZone] then
      for i, hTarget in ipairs(self.tAreaDestroyTargetList[a_sZone]) do
        if hTarget and Object.IsAlive(hTarget) then
          HUD.RemoveObjectiveMarker(hTarget)
        end
      end
    else
      print("AmbientRubberStamp.UnloadMissionNodes self.tAreaDestroyTargetList[a_sZone] is nil")
    end
    self.tAreaDestroyTargetList = {}
    self.tAreaDestroyTargetTags = {}
    self.tAreaDestroyTargetBlip = {}
  end
  if self.tAmbientMissionTargetTags and self.tAmbientMissionTargetTags[a_sZone] then
    for i, hTag in ipairs(self.tAmbientMissionTargetTags[a_sZone]) do
      local tTargets = self.tAmbientMissionTargetList[a_sZone][i]
      local nSizeofTable = #tTargets
      Freeplay.ResetAmbientTag(hTag, nSizeofTable, tTargets)
    end
  end
  self.tAmbientMissionTargetTags[a_sZone] = {}
  self.tAmbientMissionTargetList[a_sZone] = {}
end

function AmbientRubberStamp:RemoveLastKilledFromQueue(a_tCompData, a_sZone, a_hTag)
  self.eTimerEvent = nil
  local hTag, nSizeofTable, tTargets = unpack(self.tAreaDestroyLastKilled[a_sZone][a_hTag])
  if self.bPlayerDied then
    Freeplay.ResetAmbientTag(hTag, nSizeofTable, tTargets)
    self.bPlayerDied = false
  else
    AmbientRubberStamp._OnComplete(self, a_tCompData, tTargets)
  end
  self.tAreaDestroyLastKilled[a_sZone][a_hTag] = nil
end

function AmbientRubberStamp.SetPlayerDied(a_bDead)
  local self = Actor.GetSelf(AmbientRubberStamp.hController)
  self.bPlayerDied = a_bDead
end

function AmbientRubberStamp.OnExit()
end
