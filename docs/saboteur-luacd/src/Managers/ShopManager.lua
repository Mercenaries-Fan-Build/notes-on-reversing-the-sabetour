if ShopManager == nil then
  ShopManager = {}
  ShopManager.MasterList = {}
  ShopManager.bEscalatedFlag = false
  ShopManager.tEscalationEventTable = {}
  ShopManager.tSetupShopList = {}
  ShopManager.tSetupShopList = {
    Shop_Mobile = {bAlive = true},
    Shop_P1a = {},
    Shop_P1b = {},
    Shop_P1c = {},
    Shop_P2a = {},
    Shop_P2b = {},
    Shop_P2c = {},
    Shop_P3a = {},
    Shop_P3b = {},
    Shop_P3b = {},
    Shop_HQ = {},
    Garage = {}
  }
end
ShopManager.MasterList = {
  Shop_Shared = {
    sName = "Shop_Shared",
    tBlueprintList = {
      "WP_PS_WaltherPPK",
      "WP_RF_Hunting",
      "WP_SAB_DynamiteFuse",
      "WP_SAB_DynamiteTimer"
    },
    tUnlockables = {},
    bIsGarage = false
  },
  {
    sName = "Shop_P1a",
    tBlueprintList = {
      "WP_RF_Karbine",
      "WP_SAB_DynamiteFuse"
    },
    tUnlockables = {
      {
        sItem = "WP_RF_Karbine",
        bUnlocked = false,
        tUnlockList = {
          "WP_RF_Karbine_Scope"
        }
      }
    },
    bIsGarage = false
  },
  {
    sName = "Shop_P1b",
    tBlueprintList = {
      "WP_PS_Luger",
      "WP_SH_12GaugeDouble"
    },
    tUnlockables = {
      {
        sItem = "WP_SH_12GaugeDouble",
        bUnlocked = false,
        tUnlockList = {
          "WP_SH_12GaugeDouble_Sawedoff"
        }
      }
    },
    bIsGarage = false
  },
  {
    sName = "Shop_P1c",
    tBlueprintList = {
      "WP_MG_MP40",
      "WP_GR_StickGrenade"
    },
    tUnlockables = {
      {
        sItem = "WP_MG_MP40",
        bUnlocked = false,
        tUnlockList = {
          "WP_MG_MP40_Stock"
        }
      }
    },
    bIsGarage = false
  },
  {
    sName = "Shop_P2a",
    tBlueprintList = {
      "WP_PS_Mauser"
    },
    tUnlockables = {
      {
        sItem = "WP_PS_Mauser",
        bUnlocked = false,
        tUnlockList = {
          "WP_PS_Mauser_ExtMag"
        }
      }
    },
    bIsGarage = false
  },
  {
    sName = "Shop_P2b",
    tBlueprintList = {
      "WP_SH_12GaugePump"
    },
    tUnlockables = {},
    bIsGarage = false
  },
  {
    sName = "Shop_P2c",
    tBlueprintList = {
      "WP_RF_Gewehr_Scope",
      "WP_RPG_Panzerfaust"
    },
    tUnlockables = {
      {
        sItem = "WP_RF_Gewehr_Scope",
        bUnlocked = false,
        tUnlockList = {
          "WP_RF_Gewehr_Scope_Silencer"
        }
      }
    },
    bIsGarage = false
  },
  {
    sName = "Shop_P3a",
    tBlueprintList = {
      "WP_MG_Sten",
      "WP_SAB_BridgeKiller"
    },
    tUnlockables = {
      {
        sItem = "WP_MG_Sten",
        bUnlocked = false,
        tUnlockList = {
          "WP_MG_Sten_Silencer"
        }
      }
    },
    bIsGarage = false
  },
  {
    sName = "Shop_P3b",
    tBlueprintList = {
      "WP_MG_MP44",
      "WP_SAB_RDX_Charge"
    },
    tUnlockables = {},
    bIsGarage = false
  },
  {
    sName = "Shop_P3c",
    tBlueprintList = {
      "WP_MG_Thompson",
      "WP_RPG_Panzershrek"
    },
    tUnlockables = {
      {
        sItem = "WP_MG_Thompson",
        bUnlocked = false,
        tUnlockList = {
          "WP_MG_Thompson_ExtMag"
        }
      }
    },
    bIsGarage = false
  },
  {
    sName = "Shop_LH",
    tBlueprintList = {
      "WP_PS_WaltherPPK_Silencer"
    },
    tUnlockables = {},
    bIsGarage = false
  },
  {
    sName = "Shop_SB",
    tBlueprintList = {
      "WP_MG_TerrorSquad",
      "WP_SH_TerrorSquad",
      "WP_FT_TerrorSquad",
      "WP_GR_GasGrenade"
    },
    tUnlockables = {},
    bIsGarage = false
  },
  {
    sName = "Shop_HQ",
    tBlueprintList = {},
    tUnlockables = {},
    bIsGarage = false
  },
  {
    sName = "Shop_Mobile",
    tBlueprintList = {},
    tUnlockables = {},
    bIsGarage = false
  },
  {
    sName = "Garage",
    tBlueprintList = {},
    tUnlockables = {},
    bIsGarage = true
  }
}

function ShopManager.MarkShopDead(nilself, hWho, sShopName)
  ShopManager.tSetupShopList[sShopName][hWho].bAlive = false
  HUD.RemoveObjectiveMarker(hWho)
end

function ShopManager.SwitchShops(nilself, bOn)
  for sShopName, tShopData in pairs(ShopManager.tSetupShopList) do
    if sShopName ~= "Shop_Mobile" then
      local tShopTable = ShopManager.GetShopTable(sShopName)
      for hShopKeeper, tShopKeeperData in pairs(tShopData) do
        if Util.IsHandleValid(hShopKeeper) and tShopKeeperData.bAlive == true then
          local tBlueprintTable
          local sShopNamestuff = 0
          if tShopTable then
            tBlueprintTable = tShopTable.tBlueprintList
            if bOn == true then
              sShopNamestuff = sShopName
              Actor.SetupShop(hShopKeeper, sShopNamestuff, tBlueprintTable)
              Actor.AddToShop(hShopKeeper, ShopManager.MasterList[1].tBlueprintList)
              for j, tUnlockTable in pairs(tShopTable.tUnlockables) do
                if tUnlockTable.bUnlocked == true then
                  Actor.AddToShop(hShopKeeper, tUnlockTable.tUnlockList)
                end
              end
              HUD.SetObjectiveMarker(hShopKeeper, cMMI_MissionGiver, cOM_Vendor, true, true, false)
            else
              Actor.SetupShop(hShopKeeper, nil, tBlueprintTable)
              HUD.RemoveObjectiveMarker(hShopKeeper)
            end
          end
        end
      end
    end
  end
end

function ShopManager.ProximityVO(nilself, hWho)
  local tAtpts = Object.GetAttrPtAttachments(hWho)
  Util.CreateEvent({
    EventType = "OnActorUsed",
    Target = hWho
  }, "ShopManager.UseVO", nil)
  if hWho then
  end
end

function ShopManager.UseVO(nilself, hWho)
  Render.PrintMessage("buy stuff!")
end

function ShopManager.EscalationHappened(nilself)
  ShopManager.SwitchShops(nil, false)
  local tEvent = {
    EventType = "OnEscalation0",
    Target = hSab
  }
  Util.CreateEvent(tEvent, "ShopManager.EscalationEnded", nil)
  ShopManager.bEscalatedFlag = true
  for i, v in ipairs(ShopManager.tEscalationEventTable) do
    Util.KillEvent(v)
  end
  ShopManager.tEscalationEventTable = {}
end

function ShopManager.EscalationEnded(nilself)
  ShopManager.bEscalatedFlag = false
  ShopManager.SwitchShops(nil, true)
  local tEvent = {
    EventType = "OnEscalation1",
    Target = hSab
  }
  table.insert(ShopManager.tEscalationEventTable, Util.CreateEvent(tEvent, "ShopManager.EscalationHappened", nil))
  tEvent = {
    EventType = "OnEscalation2",
    Target = hSab
  }
  table.insert(ShopManager.tEscalationEventTable, Util.CreateEvent(tEvent, "ShopManager.EscalationHappened", nil))
  tEvent = {
    EventType = "OnEscalation3",
    Target = hSab
  }
  table.insert(ShopManager.tEscalationEventTable, Util.CreateEvent(tEvent, "ShopManager.EscalationHappened", nil))
  tEvent = {
    EventType = "OnEscalation4",
    Target = hSab
  }
  table.insert(ShopManager.tEscalationEventTable, Util.CreateEvent(tEvent, "ShopManager.EscalationHappened", nil))
  tEvent = {
    EventType = "OnEscalation5",
    Target = hSab
  }
  table.insert(ShopManager.tEscalationEventTable, Util.CreateEvent(tEvent, "ShopManager.EscalationHappened", nil))
end

function ShopManager.SetupTempShops(nilself, hShopkeeper, sShopname, sGarageName)
  if ShopManager.bEscalatedFlag == false then
    local tEvent = {
      EventType = "OnEscalation1",
      Target = hSab
    }
    table.insert(ShopManager.tEscalationEventTable, Util.CreateEvent(tEvent, "ShopManager.EscalationHappened", nil))
    tEvent = {
      EventType = "OnEscalation2",
      Target = hSab
    }
    table.insert(ShopManager.tEscalationEventTable, Util.CreateEvent(tEvent, "ShopManager.EscalationHappened", nil))
    tEvent = {
      EventType = "OnEscalation3",
      Target = hSab
    }
    table.insert(ShopManager.tEscalationEventTable, Util.CreateEvent(tEvent, "ShopManager.EscalationHappened", nil))
    tEvent = {
      EventType = "OnEscalation4",
      Target = hSab
    }
    table.insert(ShopManager.tEscalationEventTable, Util.CreateEvent(tEvent, "ShopManager.EscalationHappened", nil))
    tEvent = {
      EventType = "OnEscalation5",
      Target = hSab
    }
    table.insert(ShopManager.tEscalationEventTable, Util.CreateEvent(tEvent, "ShopManager.EscalationHappened", nil))
    ShopManager.bEscalatedFlag = true
  end
  if not hShopkeeper or not sShopname then
    return
  end
  if not ShopManager.tSetupShopList[sShopname] then
    return
  end
  if not ShopManager.tSetupShopList[sShopname][hShopkeeper] then
    ShopManager.tSetupShopList[sShopname][hShopkeeper] = {}
    ShopManager.tSetupShopList[sShopname][hShopkeeper].bAlive = true
  end
  if ShopManager.tSetupShopList[sShopname][hShopkeeper].bAlive == true or sShopname == "Shop_Mobile" then
    local tShopTable = ShopManager.GetShopTable(sShopname)
    local tBlueprintTable
    if tShopTable then
      tBlueprintTable = tShopTable.tBlueprintList
    end
    if Suspicion.GetEscalation() == 0 then
      Actor.SetupShop(hShopkeeper, sShopname, tBlueprintTable, tShopTable.bIsGarage, sGarageName)
      local tSharedShopTable = ShopManager.GetShopTable("Shop_Shared")
      Actor.AddToShop(hShopkeeper, tSharedShopTable.tBlueprintList)
      for i, tUnlockTable in pairs(tShopTable.tUnlockables) do
        if tUnlockTable.bUnlocked == true then
          Actor.AddToShop(hShopkeeper, tUnlockTable.tUnlockList)
        end
      end
    end
    Util.CreateEvent({
      EventType = "ProximityEvent",
      ObjectA = hSab,
      ObjectB = hShopkeeper,
      Proximity = 5
    }, "ShopManager.ProximityVO", nil, {hShopkeeper}, false)
  else
    local x, y, z = Object.GetPosition(hShopkeeper)
    Object.Teleport(hShopkeeper, x, 0, z, 0)
    HUD.RemoveObjectiveMarker(hShopkeeper)
  end
end

function ShopManager.GetShopTable(sShopName)
  for _, tShopTable in pairs(ShopManager.MasterList) do
    if tShopTable.sName == sShopName then
      local tReturnTable = tShopTable
      if sShopName ~= "Shop_Shared" then
        for i, k in ipairs(ShopManager.MasterList.Shop_Shared.tBlueprintList) do
          table.insert(tReturnTable.tBlueprintList, k)
        end
      end
      return tReturnTable
    end
  end
  return nil
end

function ShopManager.GetUnlockTable(crcShopName, crcWeaponName)
  for i, tShopTable in pairs(ShopManager.MasterList) do
    crcShopTable = Util.GetCRC(tShopTable.sName)
    if crcShopTable == crcShopName then
      for j, tUnlockTable in pairs(tShopTable.tUnlockables) do
        crcUnlockTable = Util.GetCRC(tUnlockTable.sItem)
        if crcUnlockTable == crcWeaponName then
          return tUnlockTable
        end
      end
    end
  end
  return nil
end

function ShopManager:OnPurchase(crcShopName, crcWeaponName)
  print("In ShopManager.OnPurchase")
  local tUnlockTable = ShopManager.GetUnlockTable(crcShopName, crcWeaponName)
  if tUnlockTable then
    tUnlockTable.bUnlocked = true
    Actor.AddToShop(self, tUnlockTable.tUnlockList)
    iSize = getn(ShopManager.MasterList[1].tBlueprintList)
    ShopManager.MasterList[1].tBlueprintList[iSize + 1] = tUnlockTable.sItem
  end
end

function ShopManager.UnlockItemForPurchase(crcItemBprint, bUnlock)
  local tShopTable = ShopManager.GetShopTable("Shop_Shared")
  if bUnlock then
    table.insert(tShopTable.tBlueprintList, crcItemBprint)
  else
    for i, v in ipairs(tShopTable.tBlueprintList) do
      if v == crcItemBprint then
        table.remove(tShopTable.tBlueprintList, i)
      end
    end
  end
end

function ShopManager.JoinTables(t1, t2)
  local tRetTable = t1.tBlueprintList
  for k, v in ipairs(t2.tBlueprintList) do
    table.insert(tRetTable, v)
  end
  return tRetTable
end
