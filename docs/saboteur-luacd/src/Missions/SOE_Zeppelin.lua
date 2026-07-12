if SOE_Zeppelin == nil then
  SOE_Zeppelin = SabTaskObjective:Create()
  gsSOEZEP = "Missions\\soe_1\\Zeppelin\\"
  SOE_Zeppelin:Configure({
    TaskCount = 999,
    sStarter = "skylar_lehavre_interior",
    tUnlockList = {
      "Connect_S1_M6b_LaHavreWrapup"
    },
    sHQStartPoint = _cHQe_CHURCH,
    bAutofireInterior = true,
    sSaveMissionNameID = "MissionNames_Text.S1M6",
    tSMEDNodes = {
      gsSOEZEP .. "main_citadel",
      gsSOEZEP .. "zeppelintakeoff",
      gsSOEZEP .. "citadel_nazis",
      gsSOEZEP .. "main_zep",
      gsSOEZEP .. "cinematic",
      "Missions\\cinematics\\wtf\\wtf_zeppelin"
    },
    tStaticTags = {
      "Citadel_Bunkers"
    }
  })
end

function SOE_Zeppelin:STARTER_Setup()
  Util.HQSetAllowedOverride(_cHQ_CHURCH, true)
  Util.SetDynamicPriority("VH_NZ_TR_OpelMed_01", 15000)
end

function SOE_Zeppelin:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
  Cin.LoadCinematic("218_CinB_BoxBack")
  self:RegisterCheckpoint("SOE_Zeppelin.Checkpoint_Interior")
end

function SOE_Zeppelin:GENERAL_Setup()
  self.tInfo.sDierkerInt = gsSOEZEP .. "dierker_int\\Zep_Dierker_int"
  self.tInfo.sDierkerZepExt = gsSOEZEP .. "dierker\\Zep_Dierker"
  self.tInfo.Truck = gsSOEZEP .. "main_zep\\optionaltruck"
  self.tInfo.TruckBuddy = gsSOEZEP .. "main_zep\\TruckBuddy"
  self.tInfo.BigGate = "LeHavre\\citadel\\buildings\\Citadel_Gate_Courtyard"
  self.tInfo.SkylarOutside = gsSOEZEP .. "starter\\Zepp_Master"
  self.tSaveInfo.CheckpointNumber = 0
  self.tInfo.FireNazis = {
    gsSOEZEP .. "zeppelin_nazis\\Nazi_Zep03",
    gsSOEZEP .. "zeppelin_nazis\\Nazi_Zep04"
  }
  self.tSaveInfo.NextDamageRegion = 1
  self.tInfo.TotalDamageRegions = 5
  self.tInfo.DamageRegionLoadTimer = 15
  self.tSaveInfo.bPastCheckpoint = false
  self.tSaveInfo.bCreateTruckTask = false
  self.tSaveInfo.bSaidLowHealth = false
  self.tSaveInfo.bSaidHighHealth = true
  self:AddOnCancelCallback(SOE_Zeppelin.Reset)
  self:AddOnCompleteCallback(SOE_Zeppelin.Reset)
  self.tSaveInfo.bPlayedBuddyConv = false
  self.tSaveInfo.bAllowShake = false
  EVENT_PlayerEntersTrigger("SOE_Zeppelin.SetupRain", self, "LeHavre\\citadel\\design\\restricted areas\\PT_New")
  Util.EnableMiniZep(false)
end

function SOE_Zeppelin:Reset()
  WorldSMEDNodes.UnloadNode("ZeppelinDestruction", true)
  Util.EnableMiniZep(true)
  Sound.ResetMusicLocale()
  Sound.ReleaseSoundBank("m_s1m6_inGame_01.bnk")
  Sound.ReleaseSoundBank("m_s1m6_inGame_02.bnk")
  HUD.ClearGPSTarget()
  Render.HeatShimmerFilter(0, 0, 0, 0)
  self.tSaveInfo.bAllowShake = false
  Util.UnregisterLuaUpdate("SOE_Zeppelin.UpdateLoopTeleport")
end

function SOE_Zeppelin:MISSION_ONCANCEL()
  RewardsManager.ShowStarter("skylar_lehavre_interior")
end

function SOE_Zeppelin:Task_EnterLeHavreHQ()
  self:CreateTask({
    sName = "Task_EnterLeHavreHQ",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "EnterInterior",
    sObjectiveTextID = "P1M6_Text.EnterLeHavreHQ",
    sInteriorName = "LeHavre",
    tLocators = {},
    tOnComplete = {
      {
        self.Task_StartCin,
        {self}
      }
    }
  })
end

function SOE_Zeppelin:Task_StartCin()
  self:CreateTask({
    sName = "Task_StartCin",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "218_CinB_BoxBack",
    tOnActivate = {},
    tOnComplete = {
      {
        self.UnloadTaskNodes,
        {
          self,
          "Task_StartCin"
        }
      },
      {
        Util.LoadStaticENTag,
        {
          "218_cinb_closedBox",
          true
        }
      },
      {
        self.Task_Exit,
        {self}
      }
    },
    tCinematicNodes = {
      "218_cinb_boxback"
    }
  })
end

function SOE_Zeppelin:Task_Exit()
  self:CreateTask({
    sName = "Task_Exit",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "ExitInterior",
    sObjectiveTextID = "GenericObjective_Text.HQ_LH_Exit",
    sInteriorName = "LeHavre",
    bInteriorTask = true,
    tSMEDNodes = {
      gsSOEZEP .. "starter"
    },
    tLocators = {
      "LeHavre\\lehavre_hq\\LOC_LV_Int"
    },
    tOnActivate = {
      {
        self.PostCinFluffers,
        {self}
      },
      {
        Sound.LoadSoundBank,
        {
          "m_s1m6_inGame_01.bnk"
        }
      }
    },
    tOnComplete = {
      {
        Util.UnloadStaticENTag,
        {
          "218_cinb_closedBox",
          true
        }
      },
      {
        self.RegisterCheckpoint,
        {
          self,
          "SOE_Zeppelin.Checkpoint0"
        }
      }
    }
  })
end

function SOE_Zeppelin:PostCinFluffers()
  local hAttrWall = Handle("Missions\\soe_1\\zeppelin\\main_zep\\WallPtLean1")
  local hAttrLean1 = Handle("Missions\\soe_1\\zeppelin\\main_zep\\AttrLean1")
  local hAttrSit = Handle("Missions\\soe_1\\zeppelin\\main_zep\\AttrPtSit")
  local hWilcox = Handle("LeHavre\\characters\\hq\\wilcox_interior\\wilcox_lehavre_interior")
  local hBishop = Handle("LeHavre\\characters\\hq\\bishop_interior\\Bishop_LeHavre_Interior")
  local hSkylar = Handle("LeHavre\\characters\\hq\\skylar_interior\\skylar_lehavre_interior")
  if hSkylar and hAttrWall then
    Combat.SetIdleScripted(hSkylar, true)
    Actor.RequestAttrPt(hSkylar, hAttrWall)
  else
    print("something is broke with hSkylar ", hSkylar, hAttrWall)
  end
  if hBishop and hAttrLean1 then
    Combat.SetIdleScripted(hBishop, true)
    Actor.RequestAttrPt(hBishop, hAttrLean1)
  else
    print("something is broke with hBishop ", hBishop, hAttrSit)
  end
  if hWilcox and hAttrSit then
    Combat.SetIdleScripted(hWilcox, true)
    Actor.RequestAttrPt(hWilcox, hAttrSit)
  else
    print("something is broke with wilcox ", hWilcox, hAttrSit)
  end
end

function SOE_Zeppelin:Task_LoadExteriorZepp()
  self:CreateTask({
    sName = "Task_LoadExteriorZepp",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    bCompleteOnActivate = true,
    tSMEDNodes = {
      gsSOEZEP .. "zeppelin_move"
    },
    tOnActivate = {
      {
        self.AnimateProps,
        {self}
      }
    },
    tOnComplete = {}
  })
end

function SOE_Zeppelin:Checkpoint_Interior()
  print("__Checkpoint_Interior")
  Sound.SetMusicLocale("m_S1M6_Zeppelin", "S1M6_zeppelinInterior")
  self:Task_StartCin()
end

function SOE_Zeppelin:Checkpoint0()
  print("__Checkpoint0")
  RewardsManager.HideStarter("skylar_lehavre_interior")
  self:Task_GotoCitCourtyard()
  self:SetTruckCritical()
  self:Task_LoadExteriorZepp()
  self:Task_CPCitEntrance()
  self:TASK_TalkToSkylar()
  Util.SetDynamicPriority("VH_NZ_TR_OpelMed_01", 15000)
  EVENT_PlayerEntersTrigger("SOE_Zeppelin.ChangeMusic", self, "Missions\\soe_1\\zeppelin\\main_citadel\\REG_GetPastCheckpoint")
  EVENT_PlayerEntersTrigger("SOE_Zeppelin.CompleteTaskBackCourtyard", self, "Missions\\soe_1\\zeppelin\\main_citadel\\REG_CitadelBackyard")
end

function SOE_Zeppelin:SetTruckCritical()
  local hTruck = Handle(self.tInfo.Truck)
  if hTruck then
    Vehicle.SetAsMissionCritical(hTruck, true)
  end
end

function SOE_Zeppelin:CompleteTaskBackCourtyard()
  self:CompleteTaskByName("Task_GotPastGate")
end

function SOE_Zeppelin:SwitchMusic(sMusic)
  print("cue escalation ", sMusic)
  Sound.SetMusicLocale("S1M6_Zeppelin")
  Sound.SetMusicLocale("m_S1M6_Zeppelin", sMusic)
end

function SOE_Zeppelin:ChangeMusic()
  Sound.SetMusicLocale("S1M6_Zeppelin")
  Sound.SetMusicLocale("m_S1M6_Zeppelin", "S1M6_InfiltrateBase")
end

function SOE_Zeppelin:TASK_Escalator()
  self:CreateTask({
    sName = "TASK_Escalator",
    sTaskType = "SabTaskObjectiveEscalation",
    sTaskSubType = "None",
    EscalationLevel = 1,
    bGTE = true,
    tOnComplete = {
      {
        self.SwitchMusic,
        {
          self,
          "S1M6_InfiltrateBase"
        }
      },
      {
        self.TASK_LostEscalation,
        {self}
      }
    }
  })
end

function SOE_Zeppelin:TASK_LostEscalation()
  self:CreateTask({
    sName = "TASK_LostEscalation",
    sTaskType = "SabTaskObjectiveEscalation",
    sTaskSubType = "None",
    EscalationLevel = 0,
    tOnComplete = {
      {
        self.ResetTaskByName,
        {
          self,
          "TASK_LostEscalation",
          true
        }
      },
      {
        self.ResetTaskByName,
        {
          self,
          "TASK_Escalator"
        }
      }
    }
  })
end

function SOE_Zeppelin:Task_GotoCitCourtyard()
  self:CreateTask({
    sName = "Task_GotoCitCourtyard",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = {
      gsSOEZEP .. "main_citadel\\Reg_CitCourtyard"
    },
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        self.CompleteTaskByName,
        {
          self,
          "Task_EnterCitObj"
        }
      }
    }
  })
end

function SOE_Zeppelin:CheckpointCheckCitFunctionActivation()
  local sCPName = self:GetCheckpointName()
  print("CheckpointCheckFunctionActivation: checkpoint name = ", sCPName)
  if sCPName == "SOE_Zeppelin.Checkpoint_Interior" then
    self:Task_StartCin()
  elseif sCPName == "SOE_Zeppelin.Checkpoint0" then
    self:Task_LoadExteriorZepp()
    self:Task_CPCitEntrance()
    self:TASK_TalkToSkylar()
    self:TASK_Escalator()
  elseif sCPName == "SOE_Zeppelin.Checkpoint_CitEntrance" then
    self:TASK_Escalator()
    self:TruckDamageListeners()
    self:CitEntranceConversationFluff()
  end
end

function SOE_Zeppelin:TASK_TalkToSkylar()
  self:CreateTask({
    sName = "TASK_TalkToSkylar",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "Talk",
    tTgtInclude = {
      self.tInfo.SkylarOutside
    },
    tSMEDNodes = {},
    sConvFile = "S1M6_Truck_Start",
    bAutofire = true,
    Proximity = 50,
    bNoGPS = true,
    tOnActivate = {
      {
        EVENT_PlayerEntersAnyVehicle,
        {
          "SOE_Zeppelin.PlayerEnteredVehicle",
          self,
          {}
        }
      }
    },
    tOnComplete = {
      {
        self.CallbackSkylarConversation,
        {}
      },
      {
        OffWalkingConversationDisables,
        {}
      }
    },
    tOnConversationComplete = {}
  })
end

function SOE_Zeppelin:PlayerEnteredVehicle()
  print("player entered veh")
  if self:IsMissionTaskActive("TASK_TalkToSkylar") then
    print("attempting to stop conversation")
    Cin.StopConversation(S1M6_Truck_Start)
    self:CompleteTaskByName("TASK_TalkToSkylar")
  end
end

function SOE_Zeppelin.CallbackSkylarConversation()
  local self = SOE_Zeppelin
  if not self.tSaveInfo.bCreateTruckTask then
    self.tSaveInfo.bCreateTruckTask = true
    self:Task_FetchTruck()
  end
end

function SOE_Zeppelin.CallbackSkylarFollow()
  local self = SOE_Zeppelin
  print("follow player")
  Nav.FollowObject(Handle(self.tInfo.SkylarOutside), hSab, 0.5, false)
end

function SOE_Zeppelin.CallbackSkylarStopFollow()
  local self = SOE_Zeppelin
  print("stop follow player")
  Nav.CancelFollowObject(Handle(self.tInfo.SkylarOutside))
  OffWalkingConversationDisables()
end

function SOE_Zeppelin:Task_FetchTruck()
  self:CreateTask({
    sName = "Task_FetchTruck",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "Fetch",
    sObjectiveTextID = "S1M6_Text.GetTruck",
    MarkerHeight = 4,
    tDeliverObjs = {
      self.tInfo.Truck
    },
    vGPSTarget = self.tInfo.Truck,
    tOnActivate = {
      {
        self.TruckDamageListeners,
        {self}
      }
    },
    tOnComplete = {
      {
        self.VehicleRetrieved,
        {self}
      },
      {
        self.Task_EnterCitObj,
        {self}
      },
      {
        self.UnloadTaskNodes,
        {
          self,
          "Task_Exit",
          true
        }
      },
      {
        self.SwitchMusic,
        {self, "S1M6_truck"}
      }
    }
  })
end

function SOE_Zeppelin:Setup_GetPastCheckPoint()
  self:CreateTask({
    sName = "Setup_GetPastCheckPoint",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = {
      gsSOEZEP .. "main_citadel\\REG_GetPastCheckpoint"
    },
    sObjectiveTextID = "S1M6_Text.GetToCheckpoint",
    tDeliverObjs = {hSab},
    vGPSTarget = gsSOEZEP .. "main_citadel\\LOC_PassCheckpoint",
    tOnActivate = {},
    tOnComplete = {
      {
        self.Task_GetPastCheckpoint,
        {self}
      }
    }
  })
end

function SOE_Zeppelin:Task_GetPastCheckpoint()
  self:CreateTask({
    sName = "Task_GetPastCheckpoint",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "Goto",
    sObjectiveTextID = "S1M6_Text.PassCheckpoint",
    tDestRegion = {
      gsSOEZEP .. "main_citadel\\REG_GotPastCheckpoint"
    },
    tDeliverObjs = {hSab},
    tLocators = {
      gsSOEZEP .. "main_citadel\\LOC_PassCheckpoint"
    },
    vGPSTarget = gsSOEZEP .. "main_citadel\\LOC_PassCheckpoint",
    sTaskStartConv = "S1M6_NearCheckpoint",
    tOnComplete = {
      {
        self.Task_EnterCitObj,
        {self}
      }
    },
    tOnActivate = {
      {
        self.SwitchMusic,
        {
          self,
          "S1M6_InfiltrateBase"
        }
      }
    }
  })
end

function SOE_Zeppelin:Task_EnterCitObj()
  self:CreateTask({
    sName = "Task_EnterCitObj",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "GOTO",
    sObjectiveTextID = "S1M6_Text.EnterCitadel",
    tLocators = {
      gsSOEZEP .. "main_citadel\\LOC_CitCourtyard"
    },
    vGPSTarget = gsSOEZEP .. "main_citadel\\LOC_CitCourtyard",
    tOnActivate = {},
    tOnComplete = {
      {
        self.Task_GotoZep,
        {self}
      }
    }
  })
end

function SOE_Zeppelin:TruckDamageListeners()
  self.tInfo.eNearTruck = EVENT_PlayerToActorProximity("SOE_Zeppelin.NearTruckConv", self, self.tInfo.TruckBuddy, 8, {}, true)
  self.tInfo.eTruckDeath = EVENT_ActorDeath("SOE_Zeppelin.TruckDied", self, self.tInfo.Truck)
  if not self.tInfo.TruckMaxHealth then
    self.tInfo.TruckMaxHealth = Object.GetHealth(Handle(self.tInfo.Truck))
  end
  print("Truck health = ", self.tInfo.TruckMaxHealth)
  self.tInfo.eTruckDamage = Util.CreateEvent({
    EventType = "DamageEvent",
    ObjectName = self.tInfo.Truck
  }, "SOE_Zeppelin.TruckDamaged", self, {}, true)
  self:RegisterEvent(self.tInfo.eTruckDamage)
end

function SOE_Zeppelin:NearTruckConv()
  if Actor.GetVehicle(hSab) == nil and not self.tSaveInfo.bPlayedBuddyConv then
    if self.tInfo.eNearTruck then
      Util.KillEvent(self.tInfo.eNearTruck)
      self.tInfo.eNearTruck = nil
    end
    self.tSaveInfo.bPlayedBuddyConv = true
    Cin.PlayConversation("S1M6_Truck_ResistanceNear")
  end
end

function SOE_Zeppelin:VehicleRetrieved()
  local vehHealth = Object.GetHealth(Handle(self.tInfo.Truck))
  if 0 < vehHealth then
    Util.DisplayMissionMessage(self:GetLocalizedText("Note_Skylar_Zeppelin.Note_Skylar_Zeppelin_NOTE"), cMESSAGETYPE_SKYLAR, "Note_Skylar_Zeppelin", "SOE_Zeppelin.DisguiseOrama", self)
  end
  self:Task_LoadGateVehicles()
end

function SOE_Zeppelin:DisguiseOrama()
  Actor.SetDisguise(hSab, "FBS_SS_Officer_Disguise", true)
  Cin.PlayConversation("S1M6_Truck_Entered", "SOE_Zeppelin.VehicleNote", self)
end

function SOE_Zeppelin:Task_LoadGateVehicles()
  self:CreateTask({
    sName = "Task_LoadGateVehicles",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    bCompleteOnActivate = true,
    tSMEDNodes = {
      gsSOEZEP .. "gate_vehilces"
    }
  })
end

function SOE_Zeppelin:VehicleNote()
  print("show note")
end

function SOE_Zeppelin:TruckDamaged(tDamageData, tMyData)
  local truckhealth = Object.GetHealth(Handle(self.tInfo.Truck))
  local health75percent = self.tInfo.TruckMaxHealth * 0.75
  local health50percent = self.tInfo.TruckMaxHealth * 0.5
  if not self.tSaveInfo.bPastCheckpoint then
    if truckhealth < health50percent and not self.tSaveInfo.bSaidHighHealth then
      self.tSaveInfo.bSaidHighHealth = true
      if self.tInfo.eTruckDamage then
        Util.KillEvent(self.tInfo.eTruckDamage)
      end
      print("Trucked is thrashed")
      Cin.PlayConversation("S1M6_Truck_Damaged_High")
    elseif truckhealth < health75percent and not self.tSaveInfo.bSaidLowHealth then
      print("Truck has scratches")
      self.tSaveInfo.bSaidLowHealth = true
      Cin.PlayConversation("S1M6_Truck_Damaged_Low")
    end
  end
end

function SOE_Zeppelin:TruckDied()
  print("truck died")
  if not self.tSaveInfo.bPastCheckpoint then
    Cin.PlayConversation("S1M6_Truck_Destroyed")
    self:CompleteTaskByName("Task_FetchTruck")
  end
end

function SOE_Zeppelin:Task_CPCitEntrance()
  self:CreateTask({
    sName = "Task_CPCitEntrance",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = {
      gsSOEZEP .. "main_citadel\\REG_CheckpointCitEntrance"
    },
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        self.UnloadTaskNodes,
        {
          self,
          "Task_Exit",
          true
        }
      },
      {
        self.KillTaskByName,
        {
          self,
          "Task_FetchTruck"
        }
      },
      {
        Util.CreateEvent,
        {
          {
            EventType = "TimerEvent",
            EventName = "VOGetInCitadelVO",
            Time = 7
          },
          "SOE_Zeppelin.GetInCitadelVO",
          self
        }
      },
      {
        self.RegisterCheckpoint,
        {
          self,
          "SOE_Zeppelin.Checkpoint_CitEntrance"
        }
      }
    }
  })
end

function SOE_Zeppelin:GetInCitadelVO()
  Cin.PlayConversation("S1M6_CitadelGate_Hint")
end

function SOE_Zeppelin:Checkpoint_CitEntrance_Alpha()
  self:TASK_Escalator()
  self:TruckDamageListeners()
  self:CitEntranceConversationFluff()
  self:SetupRain()
  EVENT_PlayerEntersTrigger("SOE_Zeppelin.ChangeMusic", self, "Missions\\soe_1\\zeppelin\\main_citadel\\REG_GetPastCheckpoint")
end

function SOE_Zeppelin:Checkpoint_CitEntrance()
  print("__Checkpoint_CitEntrance")
  if not self:IsMissionTaskActive("Task_GotoCitCourtyard") then
    self:Task_GotoCitCourtyard()
  end
  self:SetTruckCritical()
  if not self:IsMissionTaskActive("Task_EnterCitObj") then
    self:Task_EnterCitObj()
  end
  self.tSaveInfo.bPastCheckpoint = true
  Util.SetDynamicPriority("VH_NZ_TR_OpelMed_01", 15000)
  self:SetupRain()
  self:TASK_Escalator()
  self:TruckDamageListeners()
  self:CitEntranceConversationFluff()
  self:SetupVehicleListener()
  EVENT_PlayerEntersTrigger("SOE_Zeppelin.ChangeMusic", self, "Missions\\soe_1\\zeppelin\\main_citadel\\REG_GetPastCheckpoint")
end

function SOE_Zeppelin:SetupVehicleListener()
  local hTrigger = Util.GetHandleByName("Missions\\soe_1\\zeppelin\\main_citadel\\REG_NoVehiclesAllowed")
  if hTrigger then
    Trigger.SetAllowInVeh(hTrigger, true)
    Trigger.SetAllowOnFoot(hTrigger, false)
  else
    Util.Assert(false, "Couldn't get handle to Missions\\soe_1\\zeppelin\\main_citadel\\REG_NoVehiclesAllowed ")
  end
  EVENT_PlayerEntersTrigger("SOE_Zeppelin.PlayerEnteredCitadelInTruck", self, "Missions\\soe_1\\zeppelin\\main_citadel\\REG_NoVehiclesAllowed")
end

function SOE_Zeppelin:PlayerEnteredCitadelInTruck()
  Actor.RemoveDisguise(hSab)
  Cin.PlayConversation("S1M6_Citadel_GateCrash")
end

function SOE_Zeppelin:CitEntranceConversationFluff()
end

function SOE_Zeppelin:Task_GotoZep()
  self:CreateTask({
    sName = "Task_GotoZep",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = {
      gsSOEZEP .. "main_zep\\Reg_BoardZeppelin"
    },
    tDeliverObjs = {hSab},
    tSMEDNodes = {
      "LeHavre\\citadel\\graf_zeppelin\\newzepinterior\\graf_ai"
    },
    tOnActivate = {
      {
        self.Task_GotPastGate,
        {self}
      }
    },
    tOnComplete = {
      {
        self.CompleteTaskByName,
        {
          self,
          "Task_EnterZepObj"
        }
      }
    }
  })
end

function SOE_Zeppelin:CheckpointGotoZepCheckFunctionActivation()
  local sCPName = self:GetCheckpointName()
  print("CheckpointGotoZepCheckFunctionActivation: checkpoint name = ", sCPName)
  if sCPName == "SOE_Zeppelin.Checkpoint_CitEntrance" then
    self:Task_GotPastGate()
  elseif sCPName == "SOE_Zeppelin.Checkpoint_Backyard" then
  end
end

function SOE_Zeppelin:CheckTowerTasks()
  print("Check Tower Tasks")
  if self:IsMissionTaskActive("Task_GotoCitCourtyard") then
    print("courtyard task active")
    return
  end
  if not self.tInfo.bGotPastGate then
    if not self:IsMissionTaskActive("Task_GotoBackCourtyard") then
      self:Task_GotoBackCourtyard()
    end
  elseif not self.tInfo.bGotPastGate then
    if not self:IsMissionTaskActive("Task_GotoTower") then
      self:Task_GotoTower()
    end
    if self:IsMissionTaskActive("Task_GotoBackCourtyard") then
      self:ResetTaskByName("Task_GotoBackCourtyard", true)
    end
    if self:IsMissionTaskActive("Task_GotoBackCourtyard") then
      self:ResetTaskByName("Task_GotoBackCourtyard", true)
    end
  elseif self.tInfo.bGotPastGate then
    if self:IsMissionTaskActive("Task_GotoTower") then
      self:CompleteTaskByName("Task_GotoTower")
    end
  else
    print("Freedom didn't handle something correctly in SOE_Zeppelin.CheckTowerTasks 2 ", self.tInfo.bGotPastGate)
  end
end

function SOE_Zeppelin:Task_GotPastGate()
  self:CreateTask({
    sName = "Task_GotPastGate",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    sObjectiveTextID = "S1M6_Text.GetPastGate",
    tDestRegion = {
      gsSOEZEP .. "main_citadel\\REG_TowerPastGate"
    },
    tDeliverObjs = {hSab},
    tOnActivate = {
      {
        self.Task_PastGateObj,
        {self}
      },
      {
        self.Task_AlternateRoute,
        {self}
      }
    },
    tOnComplete = {
      {
        self.CompleteTaskByName,
        {
          self,
          "Task_PastGateObj"
        }
      },
      {
        self.KillTaskByName,
        {
          self,
          "Task_AlternateRoute"
        }
      },
      {
        self.KillTaskByName,
        {
          self,
          "Task_GotoTower"
        }
      },
      {
        self.KillTaskByName,
        {
          self,
          "Task_GotoTowerBase"
        }
      },
      {
        self.RegisterCheckpoint,
        {
          self,
          "SOE_Zeppelin.Checkpoint_Backyard"
        }
      }
    }
  })
end

function SOE_Zeppelin:Task_PastGateObj()
  self:CreateTask({
    sName = "Task_PastGateObj",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "GOTO",
    tLocators = {
      gsSOEZEP .. "main_citadel\\LOC_TowerBase"
    }
  })
end

function SOE_Zeppelin:Task_AlternateRoute()
  self:CreateTask({
    sName = "Task_AlternateRoute",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = {
      gsSOEZEP .. "main_citadel\\REG_TowerClimbBottom"
    },
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        self.Task_GotoTower,
        {self}
      }
    }
  })
end

function SOE_Zeppelin:Task_GotoTower()
  self:CreateTask({
    sName = "Task_GotoTower",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = {
      gsSOEZEP .. "main_citadel\\REG_Tower"
    },
    tLocators = {
      gsSOEZEP .. "main_citadel\\LOC_Tower"
    },
    tDeliverObjs = {hSab},
    sTaskEndConv = "S1M6_Tower_Complete",
    tOnActivate = {
      {
        self.ResetTaskByName,
        {
          self,
          "Task_PastGateObj",
          true
        }
      },
      {
        self.SwitchTowerObjective,
        {
          self,
          "S1M6_Text.ClimbTower"
        }
      }
    },
    tOnComplete = {
      {
        self.Task_GotoTowerBase,
        {self}
      }
    }
  })
end

function SOE_Zeppelin:SwitchTowerObjective(textID)
  self:ChangeObjTextByName("Task_GotPastGate", textID)
end

function SOE_Zeppelin:Task_GotoTowerBase()
  self:CreateTask({
    sName = "Task_GotoTowerBase",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDeliverObjs = {hSab},
    tOnActivate = {
      {
        self.SwitchTowerObjective,
        {
          self,
          "S1M6_Text.DescendTower"
        }
      },
      {
        self.Task_PastGateObj,
        {self}
      }
    },
    tOnComplete = {}
  })
end

function SOE_Zeppelin:Task_GotoBackCourtyard()
  self:CreateTask({
    sName = "Task_GotoBackCourtyard",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = {
      gsSOEZEP .. "main_citadel\\REG_CitadelBackyard"
    },
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        self.RegisterCheckpoint,
        {
          self,
          "SOE_Zeppelin.Checkpoint_Backyard"
        }
      }
    },
    tOnReset = {
      {
        self.BlipByTaskName,
        {
          self,
          "Task_GotoZep",
          false,
          false
        }
      }
    },
    tOnCancel = {
      {
        self.BlipByTaskName,
        {
          self,
          "Task_GotoZep",
          false,
          false
        }
      }
    }
  })
end

function SOE_Zeppelin:Checkpoint_Backyard_Alpha()
  self:BlipByTaskName("Task_GotoZep", true, true)
end

function SOE_Zeppelin:Checkpoint_Backyard()
  self:SetupRain()
  print("__Checkpoint backyard")
  if not self:IsMissionTaskActive("Task_GotoZep") then
    self:Task_GotoZep()
  end
  self:Task_EnterZepObj()
  self:BlipByTaskName("Task_GotoZep", true, true)
  self:TASK_Escalator()
end

function SOE_Zeppelin:Task_EnterZepObj()
  self:CreateTask({
    sName = "Task_EnterZepObj",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "GOTO",
    sObjectiveTextID = "S1M6_Text.BoardZeppelin",
    tLocators = {
      gsSOEZEP .. "main_zep\\LOC_ZepEntrance"
    },
    tOnActivate = {},
    tOnComplete = {
      {
        self.RegisterCheckpoint,
        {
          self,
          "SOE_Zeppelin.Checkpoint_EnterZeppelin",
          "SOE_Zeppelin.Checkpoint_EnterZeppelin_Alpha"
        }
      }
    }
  })
end

function SOE_Zeppelin:Task_ParentGetDierker()
  self:CreateTask({
    sName = "Task_ParentGetDierker",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    sObjectiveTextID = "S1M6_Text.GetDierker",
    tOnActivate = {},
    tOnComplete = {}
  })
end

function SOE_Zeppelin:Task_FalseGotoCockpit()
  self:CreateTask({
    sName = "Task_FalseGotoCockpit",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "GOTO",
    sObjectiveTextID = "S1M6_Text.SearchCockpit",
    tLocators = {
      gsSOEZEP .. "main_zep\\LOC_Cockpit"
    },
    tOnCancel = {},
    tOnActivate = {
      {
        self.Task_DierkerConTrigger,
        {self}
      }
    }
  })
end

function SOE_Zeppelin:Task_DierkerConTrigger()
  self:CreateTask({
    sName = "Task_DierkerConTrigger",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    Proximity = 3,
    bNoHudBlip = true,
    bNoWorldBlip = true,
    bNoFocus = true,
    tDestProximityObj = {
      gsSOEZEP .. "main_zep\\LOC_DierkerScene"
    },
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.Task_DierkerGondolaConfrontation,
        {self}
      }
    }
  })
end

function SOE_Zeppelin:Task_DierkerGondolaConfrontation()
  self:CreateTask({
    sName = "Task_DierkerGondolaConfrontation",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "219_CinB_Blimp",
    bOverrideFade = true,
    tSMEDNodes = {},
    tCinematicNodes = {
      "219_cinb_blimp"
    },
    tOnActivate = {
      {
        self.SetupCockpitDierker,
        {self}
      },
      {
        Render.Rain,
        {0, 5}
      }
    },
    tOnComplete = {
      {
        self.SetUpCockPitEvent,
        {self}
      },
      {
        self.UnloadTaskNodes,
        {
          self,
          "Task_DierkerGondolaConfrontation",
          true
        }
      },
      {
        self.CompleteTaskByName,
        {
          self,
          "Task_FalseGotoCockpit"
        }
      },
      {
        self.FirePistol,
        {self}
      },
      {
        self.MovingZep,
        {self}
      }
    },
    tOnReset = {
      {
        self.StopZeppCin,
        {self}
      }
    },
    tStaticTags = {}
  })
end

function SOE_Zeppelin:MovingZep()
  self:CreateTask({
    sName = "MovingZep",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "CIN_ZeppelinGondolaFire",
    tSMEDNodes = {
      gsSOEZEP .. "Zep_Flames"
    },
    tOnActivate = {},
    tOnComplete = {},
    tOnReset = {
      {
        self.StopZeppCin,
        {self}
      }
    },
    tStaticTags = {}
  })
end

function SOE_Zeppelin:TASK_LoadBlownGondola()
  self:CreateTask({
    sName = "TASK_LoadBlownGondola",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tSMEDNodes = {},
    tOnActivate = {
      {
        self.RunFireNazis,
        {self}
      }
    },
    tOnComplete = {
      {
        Cin.PlayCinematic,
        {
          "CIN_ZeppelinGondolaFire"
        }
      }
    }
  })
end

function SOE_Zeppelin:SetupFireNazis()
  local hStop = Handle(gsSOEZEP .. "zeppelin_nazis\\LOC_RunTo")
  print("setup fire nazis")
  for i, Nazi in pairs(self.tInfo.FireNazis) do
    local hNazi = Util.GetHandleByName(Nazi)
    if hNazi then
      Combat.SetIdleScripted(hNazi, true)
      Actor.OverrideCombatAI(hNazi, true)
      Actor.SetPanicEnabled(hNazi, false)
    end
  end
end

function SOE_Zeppelin:RunFireNazis()
  local hStop = Handle(gsSOEZEP .. "zeppelin_nazis\\LOC_RunTo")
  print("run fire nazis")
  for i, Nazi in pairs(self.tInfo.FireNazis) do
    local hNazi = Util.GetHandleByName(Nazi)
    if hNazi then
      Combat.SetIdleScripted(hNazi, true)
      Actor.OverrideCombatAI(hNazi, true)
      Actor.SetPanicEnabled(hNazi, false)
      Object.SetHealth(hNazi, 2000)
      print("immolating nazi ,", hNazi)
      Actor.Immolate(hNazi)
      Nav.MoveToObject(hNazi, hStop, 1, cMOVE_PANIC)
      EVENT_Timer("SOE_Zeppelin.KillOnFireNazi", self, 10, hNazi)
    end
  end
end

function SOE_Zeppelin:KillOnFireNazi(hNazi)
  if hNazi and Object.IsAlive(hNazi) then
    Object.Kill(hNazi)
  end
end

function SOE_Zeppelin:StopZeppCin()
  print("---===-- stopping zepp cin  ---===--")
  Cin.StopCinematic("CIN_ZeppelinGondolaFire")
end

function SOE_Zeppelin:SetupCockpitDierker()
  local hDierker = Util.GetHandleByName(self.tInfo.sDierkerZepExt)
  if hDierker then
    Actor.OverrideCombatAI(hDierker, true)
  end
end

function SOE_Zeppelin:Checkpoint_EnterZeppelin_Alpha()
  self:Task_FalseGotoCockpit()
  Cin.LoadCinematic("219_CinB_Blimp")
end

function SOE_Zeppelin:Checkpoint_EnterZeppelin()
  self.tSaveInfo.bAllowShake = false
  self:Task_FalseGotoCockpit()
  Cin.LoadCinematic("219_CinB_Blimp")
end

function SOE_Zeppelin:FirePistol()
  local hDierker = Util.GetHandleByName(self.tInfo.sDierkerZepExt)
  local x, y, z = Object.GetPosition(hSab)
  self.tSaveInfo.NumberExplode = 0
  local tFX_Locators = {
    gsSOEZEP .. "zeppelin_move\\FX_Loc_Cockpit01",
    gsSOEZEP .. "zeppelin_move\\FX_Loc_Cockpit02",
    gsSOEZEP .. "zeppelin_move\\FX_Loc_Cockpit03"
  }
  local tCockpitLocs = {
    gsSOEZEP .. "zeppelin_move\\FX_Loc_Cockpit03",
    gsSOEZEP .. "zeppelin_move\\FX_Loc_Cockpit04",
    gsSOEZEP .. "zeppelin_move\\FX_Loc_Cockpit05",
    gsSOEZEP .. "zeppelin_move\\FX_Loc_Cockpit06",
    gsSOEZEP .. "zeppelin_move\\FX_Loc_Cockpit07",
    gsSOEZEP .. "zeppelin_move\\FX_Loc_Cockpit08",
    gsSOEZEP .. "zeppelin_move\\FX_Loc_Cockpit09",
    gsSOEZEP .. "zeppelin_move\\FX_Loc_Cockpit10"
  }
  for i, FXLoc in pairs(tCockpitLocs) do
    local tCabinFireSequence = {
      {
        "DELAY",
        {0.5}
      },
      {
        "STARTFX",
        {
          FXLoc,
          "0FX_Fire01_Medium"
        },
        "NewBoom2"
      },
      {
        "STARTFX",
        {
          FXLoc,
          "0FX_Explosion06_Small"
        },
        "NewBoom1"
      }
    }
    DestructionSequence.Run(tCabinFireSequence)
  end
  self:ExplodeInRoom(tFX_Locators)
end

function SOE_Zeppelin:ExplodeInRoom(tFX_Locators)
  Util.KillEvent("TimeExplode")
  if self.tSaveInfo.NumberExplode == 3 then
    return
  else
    self.tSaveInfo.NumberExplode = self.tSaveInfo.NumberExplode + 1
    local hFXloc = Util.GetHandleByName(tFX_Locators[self.tSaveInfo.NumberExplode])
    local x, y, z = Object.GetPosition(hFXloc)
    Util.CreateExplosion("Explosion_Large_NoDmg", x, y, z)
    local tTimeEvent = {
      EventType = "TimerEvent",
      EventName = "TimeExplode",
      Time = math.random(1, 1.75)
    }
    Util.CreateEvent(tTimeEvent, "SOE_Zeppelin.ExplodeInRoom", self, {tFX_Locators})
  end
end

function SOE_Zeppelin:Task_GoUpIntoZep()
  self:CreateTask({
    sName = "Task_GoUpIntoZep",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    sObjectiveTextID = "S1M6_Text.EnterZepHull",
    Proximity = 1,
    tDestProximityObj = {
      gsSOEZEP .. "zeppelin_move\\LOC_ZeppelinPortUp"
    },
    tDeliverObjs = {hSab},
    tOnActivate = {
      {
        self.MovingZepDistanceFailCheck,
        {self}
      }
    },
    tOnComplete = {
      {
        self.TeleLoadZep,
        {self}
      }
    }
  })
end

function SOE_Zeppelin:MovingZepDistanceFailCheck()
  self.LadderFail = EVENT_PlayerToActorProximityNegated("SOE_Zeppelin.MovingZepDistanceFailed", self, Handle(gsSOEZEP .. "zeppelin_move\\LOC_ZeppelinPortUp"), 50, {})
end

function SOE_Zeppelin:MovingZepDistanceFailed()
  print("!!!failing because of distance to teleport locator!!!")
  self:MissionTaskFail("S1M6_Text.FAIL_MovingZepFail")
end

function SOE_Zeppelin:AnimateProps()
  local hZeppelin = Util.GetHandleByName(gsSOEZEP .. "zeppelin_move\\Zeppelin_Moving")
  local tSequence = {
    {
      "ACTIVATEANIMATEDPROP",
      {
        true,
        "KEEP_ANM_Prop_A",
        hZeppelin
      }
    },
    {
      "ACTIVATEANIMATEDPROP",
      {
        true,
        "KEEP_ANM_Prop_E",
        hZeppelin
      }
    },
    {
      "DELAY",
      {4}
    },
    {
      "ACTIVATEANIMATEDPROP",
      {
        true,
        "KEEP_ANM_Prop_B",
        hZeppelin
      }
    },
    {
      "ACTIVATEANIMATEDPROP",
      {
        true,
        "KEEP_ANM_Prop_F",
        hZeppelin
      }
    },
    {
      "DELAY",
      {4}
    },
    {
      "ACTIVATEANIMATEDPROP",
      {
        true,
        "KEEP_ANM_Prop_C",
        hZeppelin
      }
    },
    {
      "ACTIVATEANIMATEDPROP",
      {
        true,
        "KEEP_ANM_Prop_G",
        hZeppelin
      }
    },
    {
      "DELAY",
      {4}
    },
    {
      "ACTIVATEANIMATEDPROP",
      {
        true,
        "KEEP_ANM_Prop_D",
        hZeppelin
      }
    },
    {
      "ACTIVATEANIMATEDPROP",
      {
        true,
        "KEEP_ANM_Prop_H",
        hZeppelin
      }
    },
    {
      "DELAY",
      {10}
    }
  }
  ScriptSequence.Run(hSab, tSequence)
end

function SOE_Zeppelin:TeleLoadZep()
  Util.KillEvent(self.LadderFail)
  Util.AddInteriorLoadCallback("Zeppelin", "SOE_Zeppelin.ZepLoadComplete", self)
  InteriorManager.EnterInterior("Zeppelin", gsSOEZEP .. "main_zep\\LOC_IntZepTele")
end

function SOE_Zeppelin:ZepLoadComplete()
  Render.EnableLightning(false)
  Render.Rain(0, 5)
  self:UnloadTaskNodes("MovingZep", true)
  Render.HeatShimmerFilter(0.4, 1.5, 1, 0.7)
  require("Missions\\ZeppelinInterior")
  Sound.ReleaseSoundBank("m_s1m6_inGame_01.bnk")
  Sound.LoadSoundBank("m_s1m6_inGame_02.bnk")
  Sound.SetMusicLocale("S1M6_Zeppelin")
  Sound.SetMusicLocale("m_S1M6_Zeppelin", "S1M6_zeppelinInterior")
  self:UnloadTaskNodes("Task_LoadExteriorZepp", true)
  self:RegisterCheckpoint("SOE_Zeppelin.Checkpoint_InsideBurningZeppelin")
end

function SOE_Zeppelin:SetUpCockPitEvent()
  local hLoc = Util.GetHandleByName("Missions\\soe_1\\zeppelin\\zeppelin_move\\Zep_Lookat")
  Actor.TurnOnDude(hSab, false)
  Object.SetInvincible(hSab, true)
  EVENT_Timer("SOE_Zeppelin.StartUpdateLoop", self, 3.5)
  self.tSaveInfo.bAllowShake = true
  self.tSaveInfo.hCameraShakeEvent = Util.CreateEvent({
    EventType = "TimerEvent",
    Time = math.random(0.5, 2)
  }, "SOE_Zeppelin.Shake", self)
  self:RegisterEvent(self.tSaveInfo.hCameraShakeEvent)
end

function SOE_Zeppelin:StartUpdateLoop()
  Util.RegisterLuaUpdate("SOE_Zeppelin.UpdateLoopTeleport", self)
end

function SOE_Zeppelin:UpdateLoopTeleport()
  local hLoc = Util.GetHandleByName("Missions\\soe_1\\zeppelin\\zeppelin_move\\Zep_Lookat")
  if not hLoc then
    Util.Assert(false, "Failed to get handle to teleport loc, uh oh , bad times")
    Util.UnregisterLuaUpdate("SOE_Zeppelin.UpdateLoopTeleport")
    return
  end
  if Object.GetDistance(hLoc, hSab) >= 1 then
    print("teleport player")
    local x, y, z = Object.GetPosition(hLoc)
    Object.Teleport(hSab, x, y, z, 0)
  else
    print("clearin update")
    Actor.TurnOnDude(hSab, true)
    Object.SetInvincible(hSab, false)
    self:RagDoll()
    self:Task_GoUpIntoZep()
    EVENT_Timer("SOE_Zeppelin.UnFade", self, 0.5)
    Util.UnregisterLuaUpdate("SOE_Zeppelin.UpdateLoopTeleport")
  end
end

function SOE_Zeppelin:UnFade()
  local hLoc = Util.GetHandleByName("Missions\\soe_1\\zeppelin\\zeppelin_move\\Zep_Lookat")
  local x, y, z = Object.GetPosition(hLoc)
  Object.Teleport(hSab, x, y, z, 0)
  Render.FadeScreen(false)
  Actor.Ragdoll(hSab)
end

function SOE_Zeppelin:RagDoll()
  print("ragdollin sab")
  Actor.Ragdoll(hSab)
end

function SOE_Zeppelin:Shake()
  if self.tSaveInfo.bAllowShake then
    local x, y, z = Object.GetPosition(hSab)
    Render.CameraShakeExplosion(x, y, z, 40, 20, 30)
    Sound.PlayOwnerlessSoundEvent("camerashake_boom")
    self.tSaveInfo.hCameraShakeEvent2 = Util.CreateEvent({
      EventType = "TimerEvent",
      Time = math.random(2, 3)
    }, "SOE_Zeppelin.Shake", self)
    self:RegisterEvent(self.tSaveInfo.hCameraShakeEvent2)
  end
end

function SOE_Zeppelin:Checkpoint_InsideBurningZeppelin()
  if ZeppelinInterior and ZeppelinInterior.Init then
    ZeppelinInterior.Init()
  end
  self:StopZeppCin()
  if not self:IsMissionTaskActive("Task_ParentGetDierker") then
    self:Task_ParentGetDierker()
  end
  EVENT_Stream("SOE_Zeppelin.SetUpDierkerTaunt", self, self.tInfo.sDierkerInt, true)
end

function SOE_Zeppelin:SetupRain()
  Render.EnableLightning(true)
  Render.Rain(0.5, 0.1)
end

function SOE_Zeppelin:E3_END()
end

function SOE_Zeppelin:SetUpDierkerTaunt()
  print("setup dierker taunt")
  Cin.PlayCinematic("CIN_S1M6_GraffChaseIntro", "SOE_Zeppelin.Task_DierkerTaunt", self)
  local hDierker = Util.GetHandleByName(self.tInfo.sDierkerInt)
  if hDierker then
    local x, y, z = Object.GetPosition(hDierker)
    Suspicion.Enable(hDierker, false)
    Object.SetInvincible(hDierker, true)
    Combat.SetGrabbable(hDierker, false)
    Actor.SetUseHitReactions(hDierker, false)
    Actor.OverrideCombatAI(hDierker, true)
  else
    Util.Assert(hDierker, "SOE_Zeppelin.SetUpDierkerTaunt:: Interior Dierker is nil")
    print("SOE_Zeppelin.SetUpDierkerTaunt:: Interior Dierker is nil")
  end
end

function SOE_Zeppelin:Task_DierkerTaunt()
  print("Task_DierkerTaunt")
  self:CreateTask({
    sName = "Task_DierkerTaunt",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "Goto",
    Proximity = 0.5,
    tDestProximityObj = {
      self.tInfo.sDierkerInt
    },
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.Task_KillPlayer,
        {self}
      }
    },
    tOnActivate = {
      {
        self.DierkerTauntSetup,
        {self}
      }
    }
  })
end

function SOE_Zeppelin:DierkerTauntSetup()
  print("dierker taunt setup")
  local hDierker = Util.GetHandleByName(self.tInfo.sDierkerInt)
  Squad.Create("GrafArmy")
  Squad.AddMember("GrafArmy", hDierker)
  local hDummy = Util.GetHandleByName("LeHavre\\Citadel\\graf_zeppelin\\newzepinterior\\graf_ai\\DummyTarget")
  local x, y, z = Object.GetPosition(Util.GetHandleByName("Saboteur"))
  Render.CameraShakeExplosion(x, y, z, 3, 20, 30)
  self:SadTimesKiller("LeHavre\\citadel\\graf_zeppelin\\newzepinterior\\interactive\\NewZepInteriorShell\\Barrel_of_boom")
  self:SadTimesKiller("LeHavre\\citadel\\graf_zeppelin\\newzepinterior\\interactive\\OccMed_GasCannister_A(6)")
  self:SadTimesKiller("LeHavre\\citadel\\graf_zeppelin\\newzepinterior\\interactive\\OccMed_GasCannister_Cluster_A(2)\\OccMed_GasCannister_Cluster_A(1)")
  self:SadTimesKiller("LeHavre\\citadel\\graf_zeppelin\\newzepinterior\\interactive\\OccMed_GasCannister_Cluster_A(3)\\OccMed_GasCannister_Cluster_A(1)")
  self:SadTimesKiller("LeHavre\\citadel\\graf_zeppelin\\newzepinterior\\interactive\\OccMed_GasCannister_A(12)")
  self:SadTimesKiller("LeHavre\\citadel\\graf_zeppelin\\newzepinterior\\interactive\\OccMed_GasCannister_A(14)")
  Combat.SetTarget(hDierker, hDummy)
  Actor.FireCurrentWeapon(hDierker)
  EVENT_Timer("SOE_Zeppelin.GetToDierker", self, 1)
  self:Task_PathThroughZep1()
  self.tSaveInfo.eDamageRegionTimer = EVENT_Timer("SOE_Zeppelin.Task_LoadDamageRegion", self, 15)
end

function SOE_Zeppelin:SadTimesKiller(target)
  local hTarget = Handle(target)
  if hTarget then
    Object.Kill(hTarget)
  end
end

function SOE_Zeppelin:Task_KillPlayer()
  self:CreateTask({
    sName = "Task_KillPlayer",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "goto",
    tDestRegion = {
      "Missions\\soe_1\\zeppelin\\zeppelininteriorpieces\\DeathZone"
    },
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.KillPlayer,
        {self}
      }
    }
  })
end

function SOE_Zeppelin:KillPlayer()
  print("KILL PLAYER")
  Actor.Immolate(hSab)
  Object.Kill(hSab)
end

function SOE_Zeppelin:Task_LoadDamageRegion()
  self:CreateTask({
    sName = "Task_LoadDamageRegion" .. self.tSaveInfo.NextDamageRegion,
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tOnActivate = {},
    tOnCancel = {}
  })
end

function SOE_Zeppelin:ContinueDamageRegion()
  self.tSaveInfo.NextDamageRegion = self.tSaveInfo.NextDamageRegion + 1
  if self.tSaveInfo.NextDamageRegion < self.tInfo.TotalDamageRegions then
    if self.tSaveInfo.eDamageRegionTimer then
      Util.KillEvent(self.tSaveInfo.eDamageRegionTimer)
    end
    self.tSaveInfo.eDamageRegionTimer = EVENT_Timer("SOE_Zeppelin.Task_LoadDamageRegion", self, self.tInfo.DamageRegionLoadTimer)
  end
end

function SOE_Zeppelin:KillDamageRegionEvent()
  if self.tSaveInfo.eDamageRegionTimer then
    Util.KillEvent(self.tSaveInfo.eDamageRegionTimer)
  end
end

function SOE_Zeppelin:GetToDierker()
  local hDierker = Util.GetHandleByName(self.tInfo.sDierkerInt)
  local hLoc = Handle("LeHavre\\Citadel\\graf_zeppelin\\newzepinterior\\graf_ai\\LOC_RealFinalPos")
  if hDierker then
    local x, y, z = Object.GetPosition(hLoc)
    Object.Teleport(hDierker, x, y, z, 0)
  end
end

function SOE_Zeppelin:Task_PathThroughZep1()
  self:CreateTask({
    sName = "Task_PathThroughZep1",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = {
      gsSOEZEP .. "main_zep\\Reg_Zep1"
    },
    tLocators = {
      gsSOEZEP .. "main_zep\\LOC_Zep1"
    },
    tDeliverObjs = {hSab},
    bInteriorTask = true,
    sTaskStartConv = "S1M6_Chase_Start",
    tOnActivate = {},
    tOnComplete = {
      {
        self.Task_PathThroughZep2,
        {self}
      }
    }
  })
end

function SOE_Zeppelin:Task_PathThroughZep2()
  self:CreateTask({
    sName = "Task_PathThroughZep2",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = {
      gsSOEZEP .. "main_zep\\Reg_Zep2"
    },
    tLocators = {
      gsSOEZEP .. "main_zep\\LOC_Zep2"
    },
    tDeliverObjs = {hSab},
    bInteriorTask = true,
    tOnActivate = {},
    tOnComplete = {
      {
        self.Task_PathThroughZep3,
        {self}
      }
    }
  })
end

function SOE_Zeppelin:Task_PathThroughZep3()
  self:CreateTask({
    sName = "Task_PathThroughZep3",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = {
      gsSOEZEP .. "main_zep\\Reg_ZepEnd"
    },
    tLocators = {
      gsSOEZEP .. "main_zep\\LOC_ZepEnd"
    },
    tDeliverObjs = {hSab},
    bInteriorTask = true,
    tOnActivate = {},
    tOnComplete = {
      {
        Sound.SetMusicLocale,
        {
          "S1M6_Zeppelin"
        }
      },
      {
        Sound.SetMusicLocale,
        {
          "m_S1M6_Zeppelin",
          "cin221_in"
        }
      },
      {
        self.Task_EndCin,
        {self}
      },
      {
        Util.LoadStaticENTag,
        {
          "destroyed_zeppelin"
        }
      }
    }
  })
end

function SOE_Zeppelin:Task_LoadDestructedZep()
  self:CreateTask({
    sName = "Task_LoadDestructedZep",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tOnActivate = {
      {
        WorldSMEDNodes.LoadNode,
        {
          "ZeppelinDestruction",
          "SOE_Zeppelin.DestructedLoaded",
          self
        }
      },
      {
        self.WaitForDestructionStream,
        {self}
      }
    },
    tOnReset = {
      {
        WorldSMEDNodes.UnloadNode,
        {
          "ZeppelinDestruction",
          true
        }
      }
    },
    tOnCancel = {}
  })
end

function SOE_Zeppelin:DestructedLoaded()
  EVENT_Timer("SOE_Zeppelin.Task_EndCin", self, 3)
end

function SOE_Zeppelin:WaitForDestructionStream()
  Render.FadeTo(0, 0, 0, 255, 0)
  local eEvent = Util.CreateEvent({
    EventType = "StreamEvent",
    Objects = {
      "ZeppelinDestruction\\ZeppDestruction"
    },
    WaitForGameObject = true,
    WaitForPhysics = true
  }, "SOE_Zeppelin.Task_EndCin", self)
  self:RegisterEvent(eEvent)
  self.tInfo.eLoadDZep = eEvent
end

function SOE_Zeppelin:Task_EndCin()
  if self.tInfo.eLoadDZep then
    Util.KillEvent(self.tInfo.eLoadDZep)
  end
  self:CreateTask({
    sName = "Task_EndCin",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "221_CinA_BlimpCrash",
    bOverrideFade = true,
    tOnActivate = {
      {
        Util.LoadStaticENTag,
        {
          "destroyed_zeppelin"
        }
      }
    },
    tOnComplete = {
      {
        self.UnloadZepInt,
        {self}
      }
    }
  })
end

function SOE_Zeppelin:UnloadZepInt()
  self:CompleteTaskByName("Task_ParentGetDierker")
  Util.KillEvent(self.tSaveInfo.hCameraShakeEvent2)
  Util.KillEvent(self.tSaveInfo.hCameraShakeEvent)
  local hLoc = Util.GetHandleByName(gsSOEZEP .. "main_citadel\\LOC_DumpSeanExit")
  Util.AddInteriorLoadCallback("Zeppelin", "SOE_Zeppelin.Task_WTFChange", self)
  InteriorManager.ExitInterior("Zeppelin", gsSOEZEP .. "main_citadel\\LOC_DumpSeanExit")
end

function SOE_Zeppelin:Task_WTFChange()
  self:CreateTask({
    sName = "Task_WTFChange",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "Cinematic",
    tCinematicNodes = {
      "221b_BlimpCrashAfterMath"
    },
    sCinFile = "221b_BlimpCrashAfterMath",
    tOnActivate = {},
    tOnComplete = {
      {
        self.CompleteThisShit,
        {self}
      }
    }
  })
end

function SOE_Zeppelin:CompleteThisShit()
  print("COMPLETE ZEP")
  self:CompleteThisMission()
  AmbientRubberStamp.UnlockAmbientAllInZone({
    "SB",
    "LN",
    "PC",
    "NM",
    "CT",
    "BG"
  })
end

function SOE_Zeppelin:StartDierkerEvent()
  print("start dierker event")
  local hDierker = Util.GetHandleByName(self.tInfo.sDierkerZepExt)
  Inventory.GiveItem(hDierker, "Pistol", true)
  local tDSequence = {
    {
      "PLAYANIMATION",
      {"pistol_aim"}
    },
    {
      "DELAY",
      {0.95}
    }
  }
  ScriptSequence.Run(hDierker, tDSequence, SOE_Zeppelin.FirePistol, {self})
end

function SOE_Zeppelin:Task_LoadDierker()
  self:CreateTask({
    sName = "Task_LoadDierker",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tOnActivate = {
      {
        WorldSMEDNodes.LoadNode,
        {
          gsSOEZEP .. "dierker"
        }
      }
    },
    tOnReset = {
      WorldSMEDNodes.UnloadNode(gsSOEZEP .. "dierker", true)
    },
    tOnCancel = {}
  })
end
