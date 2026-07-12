if P1FP_MadBomber01 == nil then
  P1FP_MadBomber01 = SabTaskObjective:Create()
  gsP1TaxiBomber01 = "Missions\\freeplay\\p1\\mis_lava_east\\"
  P1FP_MadBomber01:Configure({
    TaskCount = 999,
    sStarter = "Veronique_LaVillette_Front",
    sSaveMissionNameID = "MissionNames_Text.P1FP_Madbomber01",
    sConvFile = "213_Con_MadBomb",
    tDependencyList = {},
    tUnlockList = {
      "NOTE_215a",
      "Connect_ST_215b_SkylarRendevous"
    },
    bEscalationDenial = true,
    tSMEDNodes = {
      gsP1TaxiBomber01 .. "main",
      gsP1TaxiBomber01 .. "Vero1_NoBomb"
    },
    tStaticTags = {
      "Bomber01VehicleCollision"
    }
  })
end

function P1FP_MadBomber01:STARTER_Setup()
end

function P1FP_MadBomber01:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
  self.SetupCheckpoint(self, 1)
end

function P1FP_MadBomber01:GENERAL_Setup()
  self.tInfo.Bomber = gsP1TaxiBomber01 .. "Vero1_NoBomb\\Bomber"
  self.tInfo.NaziGuards = {
    gsP1TaxiBomber01 .. "main\\Guard1",
    gsP1TaxiBomber01 .. "main\\Guard2"
  }
  self.tInfo.tSpawnedVehicle = {}
  self.uVeroAbandonEvent = nil
  self.uVeroAbandonEvent2 = nil
  uVeroniqueStuckEvent = nil
  self.tInfo.BomberPt = 1
  self.bEventSetup = true
  self:AddOnCancelCallback(P1FP_MadBomber01.Reset)
  self:AddOnCancelCallback(P1FP_MadBomber01.ResetCancel)
  self:AddOnCompleteCallback(P1FP_MadBomber01.Reset)
  Actor.EnableNeeds(Util.GetHandleByName(self.tInfo.Bomber), false)
end

function P1FP_MadBomber01:SetupCheckpoint(a_nCP)
  self.tSaveInfo.nCheckpointNum = a_nCP
  self.RegisterCheckpoint(self, "P1FP_MadBomber01.DoCheckpoint")
end

function P1FP_MadBomber01:DoCheckpoint()
  local nCP = self.tSaveInfo.nCheckpointNum
  bBuildingExploded = false
  self.tSaveInfo.bEscalationTaskHappened = false
  self.tSaveInfo.bEscalationTaskCarHappened = false
  if nCP == 1 then
    self.Task_Taxi(self)
    self.Task_Exit(self)
  elseif nCP == 2 then
    RewardsManager.HideStarter("Veronique_LaVillette_Front")
    self.tInfo.Bomber = "Missions\\freeplay\\p1\\mis_lava_east\\vero1_nobomb\\Bomber"
    if not self:IsMissionTaskActive("Task_Taxi") then
      self.Task_Taxi(self)
    end
  elseif nCP == 3 then
    RewardsManager.HideStarter("Veronique_LaVillette_Front")
    self.tInfo.Bomber = "Missions\\freeplay\\p1\\mis_lava_east\\Vero2_Bomb\\Bomber_With_Bag"
    self.Task_TaxiDropOff(self)
  end
end

function P1FP_MadBomber01:Task_Exit()
  Nav.FollowObject(Handle("Missions\\paris_1\\characters\\lavillette\\veronique_front\\Veronique_LaVillette_Front"), hSab, 3, true, false, false)
  dprint(self, "Inside Task_Exit.")
  self:CreateTask({
    sName = "Task_Exit",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "ExitInterior",
    sInteriorName = "LaVillette",
    bInteriorTask = true,
    MarkerHeight = 2.5,
    tLocators = {},
    tOnComplete = {
      {
        dprint,
        {
          self,
          "Finished Task Exit."
        }
      },
      {
        EVENT_Timer,
        {
          "P1FP_MadBomber01.AutoTalk",
          self,
          2
        }
      },
      {
        P1FP_MadBomber01.SetupCheckpoint,
        {self, 2}
      }
    }
  })
end

function P1FP_MadBomber01:Task_Taxi()
  sDoorPoint = "Missions\\freeplay\\p1\\mis_lava_east\\main\\DoorTriggerPoint"
  AttractionPt.EnableUse(Handle(sDoorPoint), false)
  local hVehicle = Actor.GetVehicle(Handle("Saboteur"))
  local hBomber = Handle(self.tInfo.Bomber)
  self:CreateTask({
    sName = "escalatedbeforecar",
    sTaskType = "SabTaskObjectiveEscalation",
    sTaskSubType = "None",
    EscalationLevel = 1,
    bGTE = true,
    tOnComplete = {
      {
        self.ItHasEscalatedBeforeCar,
        {self}
      }
    }
  })
  self:CreateTask({
    sName = "Task_Taxi",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "TAXI",
    tDeliverObjs = {
      self.tInfo.Bomber
    },
    sObjectiveTextID = "P1FP_MadBomber01_Text.Task_Taxi_sObjectiveTextID",
    sPickupTextID = "P1FP_MadBomber01_Text.Task_Taxi_sPickupTextID",
    sDropoffTextID = "P1FP_MadBomber01_Text.Task_Taxi_sDropOffTextID",
    sVehicleFetchID = "GenericObjective_Text.Vehicle_Getin_A",
    sVehicleReturnID = "GenericObjective_Text.Vehicle_Getin_A",
    bGroundBlip = true,
    bEscalationDenial = true,
    tPickupProxObj = {
      self.tInfo.Bomber
    },
    PickupProximity = 20,
    tDestRegion = {
      gsP1TaxiBomber01 .. "main\\PT_PackagePickup"
    },
    tDestLocators = {
      gsP1TaxiBomber01 .. "main\\LOC_PickUpPackage"
    },
    sDropOffConv = "P1FP_MadBomber01_PickingUp",
    bNoHUDBlip = false,
    bVehicleIsRequired = true,
    tOnEarlyExit = {},
    tOnPickup = {
      {
        ConvoHelper.InterruptReplay,
        {
          "214_InG_MadChat-Drive01",
          "P1FP_MadBomber01-Drive01"
        }
      },
      {
        self.KillTaskByName,
        {self, "FakeyTalk"}
      },
      {
        self.KillTaskByName,
        {
          self,
          "escalatedbeforecar"
        }
      }
    },
    tOnComplete = {
      {
        Actor.OverrideCombatAI,
        {hBomber, true}
      },
      {
        self.VeroniqueGetsPackage,
        {self}
      },
      {
        self.Task_PickUpPackage,
        {self}
      }
    },
    tOnActivate = {
      {
        Combat.SetLeader,
        {
          Handle(self.tInfo.Bomber),
          hSab,
          false,
          5,
          20
        }
      }
    }
  })
end

function P1FP_MadBomber01:AutoTalk()
  Cin.PlayConversation("P1FP_MadBomber01_GetCar")
end

function P1FP_MadBomber01:ItHasEscalatedBeforeCar()
  self:FailTaskByName("Task_Taxi")
  if self.tSaveInfo.bEscalationTaskCarHappened == false then
    self.tSaveInfo.bEscalationTaskCarHappened = true
    self:CreateTask({
      sName = "cooldownbeforecar",
      sTaskType = "SabTaskObjectiveEscalation",
      sTaskSubType = "None",
      sObjectiveTextID = "GenericObjective_Text.Escalation_Lose",
      EscalationLevel = 0,
      tOnComplete = {
        {
          self.ResetCarTasks,
          {self}
        }
      }
    })
  else
    self:ResetTaskByName("cooldownbeforecar")
  end
end

function P1FP_MadBomber01:ResetCarTasks()
  self:ResetTaskByName("Task_Taxi")
  self:ResetTaskByName("escalatedbeforecar")
end

function P1FP_MadBomber01:Task_PickUpPackage()
  self:CreateTask({
    sName = "Task_PickUpPackage",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    sObjectiveTextID = "P1FP_MadBomber01_Text.Task_BomberGo",
    tTgtInclude = {},
    tOnComplete = {
      {
        P1FP_MadBomber01.SetupCheckpoint,
        {self, 3}
      }
    },
    tOnActivate = {
      {
        self.WatchForAbandon,
        {self}
      }
    }
  })
end

function P1FP_MadBomber01:VeroniqueGetsPackage()
  Actor.SetVehicleAvoidance(Handle(self.tInfo.Bomber), false)
  local tSeq = {
    {
      "RUNTOOBJECT",
      {
        "Missions\\freeplay\\p1\\mis_lava_east\\main\\Loc_VeroBombPickup",
        2
      }
    }
  }
  ScriptSequence.Run(self.tInfo.Bomber, tSeq, P1FP_MadBomber01.DespawnVeroSanto, {self})
end

function P1FP_MadBomber01:DespawnVeroSanto()
  local tSeeLoc = {
    EventType = "SeeLocatorEvent",
    InViewTime = 0.5,
    Locator = self.tInfo.Bomber,
    Proximity = 150
  }
  self:RegisterEvent(Util.CreateEvent(tSeeLoc, "P1FP_MadBomber01.FadeOut", self))
  EVENT_Timer("P1FP_MadBomber01.UnloadVeroSantos", self, 1)
end

function P1FP_MadBomber01:UnloadVeroSantos()
  Util.KillEvent(self.uVeroAbandonEvent)
  Util.UnloadEditNode("Missions\\freeplay\\p1\\mis_lava_east\\Vero1_NoBomb.wsd", true)
  EVENT_Timer("P1FP_MadBomber01.LoadVeroSantos", self, 0.5)
end

function P1FP_MadBomber01:LoadVeroSantos()
  self.tInfo.Vero2Loaded = 1
  Util.SpawnEditNode("Missions\\freeplay\\p1\\mis_lava_east\\Vero2_Bomb.wsd", "P1FP_MadBomber01.SantosToCar", self)
end

function P1FP_MadBomber01:SantosToCar()
  self.tInfo.Bomber = "Missions\\freeplay\\p1\\mis_lava_east\\Vero2_Bomb\\Bomber_With_Bag"
  self:ReWatchForAbandon()
  Actor.OverrideCombatAI(Handle(self.tInfo.Bomber), true)
  self.CompleteTaskByName(self, "Task_PickUpPackage")
end

function P1FP_MadBomber01:WatchForAbandon()
  self.uVeroAbandonEvent = EVENT_PlayerToActorProximityNegated("P1FP_MadBomber01.VeroAbandon", self, self.tInfo.Bomber, 60)
end

function P1FP_MadBomber01:ReWatchForAbandon()
  self.uVeroAbandonEvent2 = EVENT_PlayerToActorProximityNegated("P1FP_MadBomber01.VeroAbandon", self, self.tInfo.Bomber, 60)
end

function P1FP_MadBomber01:EndWatchForAbandon()
  Util.KillEvent(self.uVeroAbandonEvent)
end

function P1FP_MadBomber01:Task_TaxiDropOff()
  Util.SetDisableControls("Gas", false)
  Util.SetDisableControls("Break", false)
  Util.SetDisableControls("EnterExitVehicle", false)
  Actor.SetVehicleAvoidance(Util.GetHandleByName(self.tInfo.Bomber), false)
  Util.EnableRoadsInRegion(false, "Missions\\freeplay\\p1\\mis_lava_east\\main\\PT_Traffic")
  Actor.OverrideCombatAI(Handle(self.tInfo.Bomber), false)
  self:CreateTask({
    sName = "Task_TaxiDropOff",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "TAXI",
    sObjectiveTextID = "P1FP_MadBomber01_Text.Task_DeliverBomber",
    sDropoffTextID = "P1FP_MadBomber01_Text.Task_DeliverBomber",
    sVehicleFetchID = "GenericObjective_Text.Vehicle_GetIn_A",
    sPickupTextID = "P1FP_MadBomber01_Text.TASK_Pick_up_Veronique",
    sVehicleReturnID = "GenericObjective_Text.Vehicle_GetIn_A",
    tPickupProxObj = {
      self.tInfo.Bomber
    },
    bEscalationDenial = true,
    bGroundBlip = true,
    PickupProximity = 70,
    tDestLocators = {
      gsP1TaxiBomber01 .. "main\\LOC_TaxiEnd"
    },
    tDestRegion = {
      gsP1TaxiBomber01 .. "main\\REG_DropOff"
    },
    tDeliverObjs = {
      self.tInfo.Bomber
    },
    sDropOffConv = "214_InG_MadChat-DropOff",
    bVehicleIsRequired = true,
    tOnEarlyExit = {},
    tOnPickup = {
      {
        Util.KillEvent,
        {
          self.uVeroAbandonEvent2
        }
      },
      {
        HUD.SetWaypoint,
        {997, -103}
      },
      {
        self.PlayDrive02
      }
    },
    tOnComplete = {
      {
        self.Task_BomberGo,
        {self}
      }
    },
    tOnActivate = {
      {
        Combat.SetLeader,
        {
          Handle(self.tInfo.Bomber),
          hSab,
          false,
          10,
          20
        }
      },
      {
        self.TurnOffWayPoint,
        {self}
      }
    }
  })
end

function P1FP_MadBomber01:Task_BomberGo()
  self:CreateTask({
    sName = "P1FP_MadBomber01_Task_BomberGo",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    sObjectiveTextID = "P1FP_MadBomber01_Text.Task_BomberGo",
    tTgtInclude = {},
    tOnComplete = {
      {
        self.Task_GetAway,
        {self}
      },
      {
        self.KillTaskByName,
        {
          self,
          "TASK_DontEscalate"
        }
      }
    },
    tOnActivate = {
      {
        self.RunToBuilding,
        {self}
      },
      {
        self.TASK_DontEscalate,
        {self}
      }
    }
  })
end

function P1FP_MadBomber01:TASK_DontEscalate()
  self:CreateTask({
    sName = "TASK_DontEscalate",
    sTaskType = "SabTaskObjectiveEscalation",
    sTaskSubType = "None",
    EscalationLevel = 1,
    bGTE = true,
    tOnComplete = {
      {
        self.MissionTaskFail,
        {
          self,
          "P1Freeplay.MadBomber01_FailEscalation"
        }
      }
    },
    tOnActivate = {}
  })
  Actor.OverrideCombatAI(Handle(self.tInfo.Bomber), true)
  self.tInfo.eStreamVero = EVENT_StreamOut("P1FP_MadBomber01.VeroAbandon", self, {
    Handle(self.tInfo.Bomber)
  })
  self.tInfo.eAbandonVero = EVENT_PlayerExitsTrigger("P1FP_MadBomber01.VeroAbandon", self, "Missions\\freeplay\\p1\\mis_lava_east\\main\\PT_Abandon")
end

function P1FP_MadBomber01:Task_GetAway()
  Combat.SetLeader(Handle(self.tInfo.Bomber), hSab, false, 1, 20)
  self.LVTrigger = EVENT_PlayerEntersTrigger("P1FP_MadBomber01.CompleteReturnToLV", self, "Missions\\freeplay\\p1\\mis_lava_east\\main\\PT_OutsideHQ")
  self:CreateTask({
    sName = "Task_GetAway",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "TAXI",
    sPickupTextID = "P1FP_MadBomber01_Text.TASK_Pick_up_Veronique",
    sDropoffTextID = "P1FP_MadBomber01_Text.TASK_Veronique_To_LaVillete",
    sVehicleFetchID = "P1FP_MadBomber01_Text.TASK_Veronique_To_LaVillete",
    sObjectiveTextID = "P1FP_MadBomber01_Text.TASK_Veronique_To_LaVillete",
    tDestLocators = {
      gsP1TaxiBomber01 .. "main\\LOC_Finish"
    },
    tDestRegion = {
      gsP1TaxiBomber01 .. "main\\REG_Pickup"
    },
    bEscalationDenial = true,
    tPickupProxObj = {
      self.tInfo.Bomber
    },
    PickupProximity = 50,
    tDeliverObjs = {
      self.tInfo.Bomber
    },
    bGroundBlip = true,
    bNoDumping = true,
    tOnEarlyExit = {},
    tOnWait = {},
    tOnPickup = {
      {
        Util.KillEvent,
        {uVeroniqueStuckEvent}
      },
      {
        self.HandleEscapeVO,
        {self}
      }
    },
    tOnComplete = {
      {
        self.RegisterCheckpoint,
        {
          self,
          "P1FP_MadBomber01.TASK_TalkLuc"
        }
      },
      {
        self.KillNearHQTrigger,
        {self}
      }
    },
    tOnActivate = {
      {
        Util.KillEvent,
        {
          self.tInfo.eStreamVero
        }
      }
    }
  })
end

function P1FP_MadBomber01:KillNearHQTrigger()
  Trigger.ClearCallback(Handle("Missions\\freeplay\\p1\\mis_lava_east\\main\\PT_OutsideHQ"), self.LVTrigger)
end

function P1FP_MadBomber01:CompleteReturnToLV()
  self:CompleteTaskByName("Task_GetAway")
end

function P1FP_MadBomber01:HandleEscapeVO()
  if bBuildingExploded == false then
    Cin.PlayConversation("214_InG_MadChat-Escape01", "P1FP_MadBomber01.ExplodeBuilding", self)
    EVENT_Timer("P1FP_MadBomber01.Escape2VO", self, 5)
  else
    EVENT_Timer("P1FP_MadBomber01.Escape2VO", self, 0.5)
  end
end

function P1FP_MadBomber01:TASK_TalkLuc()
  Combat.SetLeader(Handle(self.tInfo.Bomber), hSab, false, 3, 20)
  Actor.UnboardVehicle(hSab)
  Cin.PlayConversation("214_InG_MadChat-Split")
  RewardsManager.ShowStarter("Veronique_LaVillette_Front")
  self:CreateTask({
    sName = "TASK_TalkLuc",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "EnterInterior",
    sInteriorName = "LaVillette",
    sObjectiveTextID = "P1FP_MadBomber01_Text.Task_FindLuc",
    tLocators = {
      "Missions\\freeplay\\p1\\mis_lava_east\\main\\LOC_EnterHQ"
    },
    tOnComplete = {
      {
        Util.UnloadEditNode,
        {
          "Missions\\freeplay\\p1\\mis_lava_east\\Vero3_noBomb.wsd",
          true
        }
      },
      {
        self.TalkLucInterior,
        {self}
      }
    },
    tOnActivate = {}
  })
  self:CreateTask({
    sName = "escalatedbeforetalking",
    sTaskType = "SabTaskObjectiveEscalation",
    sTaskSubType = "None",
    EscalationLevel = 1,
    bGTE = true,
    tOnComplete = {
      {
        self.ItHasEscalatedBeforeTalkingToLuc,
        {self}
      }
    }
  })
end

function P1FP_MadBomber01:TalkLucInterior()
  self.tInfo.Vero3Loaded = 0
  local sVeronique = "Missions\\paris_1\\characters\\lavillette\\veronique_front\\Veronique_LaVillette_Front"
  Object.Teleport(Handle(sVeronique), 767.9237, 293.56552, -715.7162, 90)
  Nav.FollowObject(Handle("Missions\\paris_1\\characters\\lavillette\\veronique_front\\Veronique_LaVillette_Front"), hSab, 1, true, false, false)
  Combat.SetIdleScripted(Handle(sVeronique), true)
  self:CreateTask({
    sName = "TASK_TalkLuc_Interior",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "TALK",
    sConvFile = "215_Con_Resist",
    bAutofire = false,
    bInteriorTask = true,
    bRepeatable = true,
    bNoRepeatAutoRebuild = true,
    sObjectiveTextID = "P1FP_MadBomber01_Text.Task_FindLuc",
    tTgtInclude = {
      "Missions\\paris_1\\characters\\lavillette\\luc_interior\\Luc_LaVillette_Interior"
    },
    tOnComplete = {
      {
        Nav.CancelFollowObject,
        {
          Handle(sVeronique)
        }
      },
      {
        Nav.MoveToObject,
        {
          Handle(sVeronique),
          Handle("Missions\\freeplay\\p1\\mis_lava_east\\main\\LOC_Vero_Final"),
          1
        }
      },
      {
        self.CompleteThisMission,
        {self}
      }
    },
    tOnActivate = {}
  })
  self:CreateTask({
    sName = "Task_ExitLavillette",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "ExitInterior",
    bRepeatable = true,
    bNoRepeatAutoRebuild = true,
    sInteriorName = "LaVillette",
    tOnComplete = {
      {
        self.FailTaskByName,
        {
          self,
          "TASK_TalkLuc_Interior"
        }
      },
      {
        self.ResetTaskByName,
        {
          self,
          "TASK_TalkLuc"
        }
      }
    }
  })
end

function P1FP_MadBomber01:ItHasEscalatedBeforeTalkingToLuc()
  self:FailTaskByName("TASK_TalkLuc")
  if self.tSaveInfo.bEscalationTaskHappened == false then
    self.tSaveInfo.bEscalationTaskHappened = true
    self:CreateTask({
      sName = "cooldownbeforetalking",
      sTaskType = "SabTaskObjectiveEscalation",
      sTaskSubType = "None",
      sObjectiveTextID = "GenericObjective_Text.Escalation_Lose",
      EscalationLevel = 0,
      tOnComplete = {
        {
          self.ResetTasks,
          {self}
        }
      }
    })
  else
    self:ResetTaskByName("cooldownbeforetalking")
  end
end

function P1FP_MadBomber01:BackToItHasEscalatedBeforeTalkingToLuc()
  self:FailTaskByName("TASK_TalkLuc")
  if self.tSaveInfo.bEscalationTaskHappened == false then
    self.tSaveInfo.bEscalationTaskHappened = true
    self:CreateTask({
      sName = "cooldownbeforetalking",
      sTaskType = "SabTaskObjectiveEscalation",
      sTaskSubType = "None",
      sObjectiveTextID = "GenericObjective_Text.Escalation_Lose",
      EscalationLevel = 0,
      tOnComplete = {
        {
          self.BackToResetTasks,
          {self}
        }
      }
    })
  else
    self:ResetTaskByName("cooldownbeforetalking")
  end
end

function P1FP_MadBomber01:BackToTASK_TalkLuc()
  self:CreateTask({
    sName = "BackToTASK_TalkLuc",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "EnterInterior",
    bRepeatable = true,
    bNoRepeatAutoRebuild = true,
    sInteriorName = "LaVillette",
    sObjectiveTextID = "P1FP_MadBomber01_Text.Task_FindLuc",
    tLocators = {
      "Missions\\freeplay\\p1\\mis_lava_east\\main\\LOC_EnterHQ"
    },
    tOnComplete = {
      {
        self.TalkLucInterior,
        {self}
      }
    },
    tOnActivate = {}
  })
  self:CreateTask({
    sName = "BackToescalatedbeforetalking",
    sTaskType = "SabTaskObjectiveEscalation",
    sTaskSubType = "None",
    EscalationLevel = 1,
    bGTE = true,
    tOnComplete = {
      {
        self.BackToItHasEscalatedBeforeTalkingToLuc,
        {self}
      }
    }
  })
end

function P1FP_MadBomber01:BackToResetTasks()
  self:ResetTaskByName("BackToTASK_TalkLuc")
  self:ResetTaskByName("BackToescalatedbeforetalking")
end

function P1FP_MadBomber01:ResetTasks()
  self:ResetTaskByName("TASK_TalkLuc")
  self:ResetTaskByName("escalatedbeforetalking")
end

function P1FP_MadBomber01:VeroMoveToLuc()
  Nav.MoveToObject(Handle("Missions\\paris_1\\characters\\lavillette\\veronique_front\\Veronique_LaVillette_Front"), Handle("Missions\\freeplay\\p1\\mis_lava_east\\main\\LOC_Vero_Int_Walk"), 1, true)
end

function P1FP_MadBomber01:SeanExit()
  Actor.UnboardVehicle(hSab)
end

function P1FP_MadBomber01:VeroFollow()
  Nav.FollowObject(Handle(self.tInfo.Bomber), hSab, 3, true, false, false)
end

function P1FP_MadBomber01:PlayDrive02()
  Cin.PlayConversation("P1FP_MadBomber01_Package_Done")
  EVENT_Timer("P1FP_MadBomber01.PlayCinDrive02", self, 15)
end

function P1FP_MadBomber01.PlayCinDrive02()
  ConvoHelper.InterruptReplay("P1FP_MadBomber01_Veron_Car_Bomb", "P1FP_MadBomber01-Drive02")
end

function P1FP_MadBomber01:SetupInterrupt(sFunctionName, sConvName)
  self.ConvEscalEvent_Drive02 = EVENT_OnEscalation("P1FP_MadBomber01.InterruptTriggered", self, {sFunctionName, sConvName})
end

function P1FP_MadBomber01:InterruptTriggered(sFunctionName, sConvName)
  Cin.InterruptConversation(sConvName)
  EVENT_EscalationFree(sFunctionName, self)
end

function P1FP_MadBomber01:ConvoFinished()
  Util.KillEvent(self.ConvEscalEvent_Drive02)
end

function P1FP_MadBomber01:VeroAbandon()
  self.MissionTaskFail(self, "P1Freeplay.MadBomber01_Abandon")
end

function P1FP_MadBomber01:RunToBuilding()
  local hLoc = Util.GetHandleByName(gsP1TaxiBomber01 .. "main\\LOC_Heil")
  if Object.IsAlive(Handle("Missions\\freeplay\\p1\\mis_lava_east\\main\\Guard1")) then
    Nav.MoveToObject(Handle(self.tInfo.Bomber), hLoc, 1, true, "P1FP_MadBomber01.NaziConvo", self, {}, false)
  else
    Nav.MoveToObject(Handle(self.tInfo.Bomber), hLoc, 1, true, "P1FP_MadBomber01.EnterBuilding", self, {}, false)
  end
end

function P1FP_MadBomber01:NaziConvo()
  Cin.StopConversation("214_InG_MadChat-Drive02")
  Cin.StopConversation("214_InG_MadChat-DropOff")
  Cin.PlayConversation("P1FP_MadBomber01_Enter", "P1FP_MadBomber01.EnterBuilding", self)
  Actor.PlayAnimation(Handle(self.tInfo.Bomber), "civ_F_flirt_front")
end

function P1FP_MadBomber01:EnterBuilding()
  sDoorPoint = "Missions\\freeplay\\p1\\mis_lava_east\\main\\DoorTriggerPoint"
  sDoorPointint = "Missions\\freeplay\\p1\\mis_lava_east\\main\\DoorTriggerPoint(1)"
  sDoorTriggerInt = "Missions\\freeplay\\p1\\mis_lava_east\\main\\PT_Inner"
  EVENT_ActorEntersTrigger("P1FP_MadBomber01.CloseEmbassyDoor", self, Handle(self.tInfo.Bomber), sDoorTriggerInt)
  self.tInfo.bVeroHasBeenSwitched = 1
  self.tInfo.VeroEnterDoorTimer = EVENT_Timer("P1FP_MadBomber01.SpawnVero", self, 20)
  local tEnterSequence = {
    {
      "WALKTOOBJECT",
      {sDoorPoint}
    },
    {
      "REQUESTATTRPT",
      {sDoorPoint}
    },
    {
      "DELAY",
      {0.25}
    },
    {
      "WALKTOOBJECT",
      {
        "Missions\\freeplay\\p1\\mis_lava_east\\main\\LOC_Interior",
        0
      }
    },
    {
      "DELAY",
      {5}
    }
  }
  ScriptSequence.Run(Handle(self.tInfo.Bomber), tEnterSequence, P1FP_MadBomber01.SpawnVero, {self})
end

function P1FP_MadBomber01:SpawnVero()
  if self.tInfo.bVeroHasBeenSwitched == 1 then
    self.tInfo.bVeroHasBeenSwitched = 0
    Util.KillEvent(self.tInfo.eStreamVero)
    if VeroEnterDoorTimer then
      Util.KillEvent(VeroEnterDoorTimer)
    end
    Util.UnloadEditNode("Missions\\freeplay\\p1\\mis_lava_east\\Vero2_Bomb.wsd", true)
    self.tInfo.Vero2Loaded = 0
    Util.SpawnEditNode("Missions\\freeplay\\p1\\mis_lava_east\\Vero3_NoBomb.wsd", "P1FP_MadBomber01.MoveToCar", self)
    self.tInfo.Vero3Loaded = 1
  end
end

function P1FP_MadBomber01:VeroStopFollowing()
  Nav.CancelFollowObject(Handle(self.tInfo.Bomber))
end

function P1FP_MadBomber01:MoveToCar()
  self.tInfo.Bomber = "Missions\\freeplay\\p1\\mis_lava_east\\Vero3_NoBomb\\Bomber_No_Bag"
  self.tInfo.eStreamVero = EVENT_StreamOut("P1FP_MadBomber01.VeroAbandon", self, {
    Handle(self.tInfo.Bomber)
  })
  sDoorPointint = "Missions\\freeplay\\p1\\mis_lava_east\\main\\DoorTriggerPoint(1)"
  uVeroniqueStuckEvent = EVENT_Timer("P1FP_MadBomber01.ExplodeBuilding", self, 15)
  sDoorTriggerExt = "Missions\\freeplay\\p1\\mis_lava_east\\main\\PT_Outer"
  EVENT_ActorEntersTrigger("P1FP_MadBomber01.CloseEmbassyDoor", self, Handle(self.tInfo.Bomber), sDoorTriggerExt)
  local tEnterSequence = {
    {
      "USEATTRPT",
      {sDoorPointint}
    },
    {
      "DELAY",
      {0.25}
    }
  }
  ScriptSequence.Run(Handle(self.tInfo.Bomber), tEnterSequence, self.CompleteTaskByName, {
    self,
    "P1FP_MadBomber01_Task_BomberGo"
  })
end

function P1FP_MadBomber01:ExplodeVO()
  Cin.PlayConversation("214_InG_MadChat-Escape01", "P1FP_MadBomber01.ExplodeBuilding", self)
end

function P1FP_MadBomber01:CloseEmbassyDoor()
  EVENT_Timer("P1FP_MadBomber01.CloseEmbassyDoorDelayed", self, 2)
end

function P1FP_MadBomber01:CloseEmbassyDoorDelayed()
  Object.ForceClose(Handle("PARIS\\area06\\palaisroyal\\buildings\\City1_Embassy_Dam\\City1_AnimDoor_Garage"))
end

function P1FP_MadBomber01:ExplodeBuilding()
  if bBuildingExploded == false then
    bBuildingExploded = true
    Cin.PlayCinematic("P1FP_MadBomber_Explosion", false, "P1FP_MadBomber01.TestKillVeronique", self)
    EVENT_Timer("P1FP_MadBomber01.CreateExplosion", self, 0.01, {
      Handle("PARIS\\area06\\palaisroyal\\buildings\\City1_Embassy_Dam\\City1_Embassy_Base_Wnd(1)"),
      43
    })
    EVENT_Timer("P1FP_MadBomber01.CreateExplosion", self, 0.5, {
      Handle("PARIS\\area06\\palaisroyal\\buildings\\City1_Embassy_Dam\\City1_Embassy_Level_Wnd(1)"),
      47
    })
    EVENT_Timer("P1FP_MadBomber01.TurnOnEscalation", self, 0.5)
    EVENT_Timer("P1FP_MadBomber01.CreateExplosion", self, 1, {
      Handle("PARIS\\area06\\palaisroyal\\buildings\\City1_Embassy_Dam\\City1_Embassy_Level2_Wnd(1)"),
      52
    })
    EVENT_Timer("P1FP_MadBomber01.CreateExplosion", self, 1.3, {
      Handle("PARIS\\area06\\palaisroyal\\buildings\\City1_Embassy_Dam\\City1_Embassy_Roof(1)"),
      52
    })
    Util.EnableRoadsInRegion(true, "Missions\\freeplay\\p1\\mis_lava_east\\main\\PT_Traffic")
  end
end

function P1FP_MadBomber01:TestKillVeronique()
  local hLocInsideDoor = Handle("Missions\\freeplay\\p1\\mis_lava_east\\main\\LOC_Interior")
  local nDist = Object.GetDistance(hLocInsideDoor, Handle(self.tInfo.Bomber))
  if nDist <= 3 then
    Object.Kill(Handle(self.tInfo.Bomber))
  end
end

function P1FP_MadBomber01:CreateExplosion(hLevel, y)
  Object.SetHealth(hLevel, 10)
  Util.CreateExplosion("Explosion_Large", 153.4, y, -444.2)
end

function P1FP_MadBomber01:TurnOnEscalation()
  Trigger.ClearCallback(Handle("Missions\\freeplay\\p1\\mis_lava_east\\main\\PT_Abandon"), self.tInfo.eAbandonVero)
  Suspicion.SetFixedEscalationLevel(1)
  Suspicion.SetEscalated()
end

function P1FP_MadBomber01:Escape2VO()
  Cin.PlayConversation("214_InG_MadChat-Escape02")
end

function P1FP_MadBomber01:FinishWait()
  self:CompleteTaskByName("P1FP_MadBomber01_Task_BomberGo")
end

function P1FP_MadBomber01:Reset()
  Suspicion.EnableGlobal(true)
  Suspicion.EnableEscalation(true)
  Suspicion.SetFixedEscalationLevel(0)
  Squad.Create("Bomber_Nazi")
  Sound.ResetMusicLocale()
  gsP1TaxiBomber01 = nil
  bBuildingExploded = nil
  sDoorPoint = nil
  sDoorPointint = nil
  sDoorTriggerInt = nil
  uVeroniqueStuckEvent = nil
  sDoorTriggerExt = nil
end

function P1FP_MadBomber01:TurnOffWayPoint()
  EVENT_PlayerExitsTrigger("HUD.ClearWaypoint", self, "Missions\\freeplay\\p1\\mis_lava_east\\main\\PT_WayPoint")
end

function P1FP_MadBomber01:FadeOut()
  Render.FadeTo(0, 0, 0, 255, 0.25)
  EVENT_Timer("P1FP_MadBomber01.FadeIn", self, 2)
end

function P1FP_MadBomber01:FadeIn()
  Render.FadeTo(0, 0, 0, 0, 0.25)
end

function P1FP_MadBomber01:ResetCancel()
  RewardsManager.ShowStarter("Veronique_LaVillette_Front")
end

function P1FP_MadBomber01:MISSION_ONCANCEL()
  Nav.CancelFollowObject(Handle(self.tInfo.Bomber))
end

function P1FP_MadBomber01:MISSION_ONRESET()
  local hBomber = Handle(self.tInfo.Bomber)
  if hBomber then
    Nav.CancelFollowObject(hBomber)
  end
  RewardsManager.ShowStarter("Veronique_LaVillette_Front")
  if self.tInfo.Vero2Loaded == 1 then
    Util.UnloadEditNode("Missions\\freeplay\\p1\\mis_lava_east\\Vero2_Bomb.wsd", true)
  end
  if self.tInfo.Vero3Loaded == 1 then
    Util.UnloadEditNode("Missions\\freeplay\\p1\\mis_lava_east\\Vero3_NoBomb.wsd", true)
  end
end
