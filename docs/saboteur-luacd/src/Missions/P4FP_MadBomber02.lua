if P4FP_MadBomber02 == nil then
  P4FP_MadBomber02 = SabTaskObjective:Create()
  P4FP_MadBomber02.sPATH = "Missions\\freeplay\\p1\\mis_cem_west\\"
  P4FP_MadBomber02:Configure({
    TaskCount = 999,
    sStarter = "Father_Sacre_Interior",
    sConvFile = "P4FP_MadBomber02_Start",
    tDependencyList = {},
    tUnlockList = {
      "NOTE_NaziWedding",
      "P1FP_NaziParty"
    },
    sToolTipID = "P1Freeplay.MadBomber01_Briefing",
    bFreeplay = true,
    bForceUnloadNodes = false,
    sSaveMissionNameID = "MissionNames_Text.P4FP_MadBomber02",
    sActNameID = "MissionNames_Text.ACT_FatherDenis",
    tSMEDNodes = {
      P4FP_MadBomber02.sPATH .. "main"
    },
    tStaticTags = {
      "mis_cem_west_checkpoint",
      "Bomber02VehicleCollision"
    }
  })
end

function P4FP_MadBomber02:STARTER_Setup()
  if not IsMissionCompleted("Paris_1_Mission_1B") then
    Zone.SwitchState("WtF_Zones\\global\\P1M1B_SlaughterhouseLiberate", cZONESTATE_HIGHCOLOR_HIGHTAG, cENT_IMMEDIATE, true)
  end
end

function P4FP_MadBomber02:Activated()
  SabTaskObjective.Activated(self)
  self:GENERAL_Setup()
  P4FP_MadBomber02.SetupCheckpoint(self, 1)
end

function P4FP_MadBomber02:GENERAL_Setup()
end

function P4FP_MadBomber02:SetupVariables()
  self.hSab = self.hSab or Handle("Saboteur")
  self.sBomber = self.sBomber or "Missions\\paris_1\\characters\\sacrecour\\father_denis_sacrecour\\Father_Sacre_Interior"
  self.hBomber = self.hBomber or Handle(self.sBomber)
  self.sBomberNoBag = self.sBomberNoBag or self.sPATH .. "main\\Denis_NoBag"
  self.hBomberNoBag = self.hBomberNoBag or Handle(self.sBomberNoBag)
  self.sDenisExitSeatPath = self.sDenisExitSeatPath or self.sPATH .. "main\\PA_DenisExitSeat"
  self.sDenisExitChurchPath = self.sDenisExitChurchPath or self.sPATH .. "main\\PA_DenisExitChurch"
  self.tGuards = self.tGuards or {
    Handle(self.sPATH .. "main\\Guard3"),
    Handle(self.sPATH .. "main\\Guard4")
  }
  self.tIntGuards = self.tIntGuards or {
    self.sPATH .. "main\\Guard01",
    self.sPATH .. "main\\Guard02",
    self.sPATH .. "main\\Guard03"
  }
  self.tInfo.DrivePointA = self.tInfo.DrivePointA or self.sPATH .. "main\\LOC_DriveA"
  self.tInfo.DrivePointB = self.tInfo.DrivePointB or self.sPATH .. "main\\LOC_DriveB"
  self.tInfo.DrivePointC = self.tInfo.DrivePointC or self.sPATH .. "main\\LOC_DriveC"
  self.tInfo.SpawnPointA = self.tInfo.SpawnPointA or self.sPATH .. "main\\LOC_SpawnA"
  self.tInfo.SpawnPointB = self.tInfo.SpawnPointB or self.sPATH .. "main\\LOC_SpawnB"
  self.tInfo.SpawnPointC = self.tInfo.SpawnPointC or self.sPATH .. "main\\LOC_SpawnC"
  self.tInfo.BomberPt = self.tInfo.BomberPt or 1
  self.sDoorPoint = self.sDoorPoint or self.sPATH .. "main\\DoorTriggerPoint(1)"
  self.sAbandonTrig = self.sAbandonTrig or self.sPATH .. "main\\PT_Abandon"
  self.sDenisExitEmbTrig = self.sDenisExitEmbTrig or self.sPATH .. "main\\PT_DenisExitingEmbassy"
  self.sDoor = self.sDoor or "PARIS\\area04\\placedebastille\\buildings\\Embassy Temp 02\\SpawnerDoor_City1"
  self.sExitLOC = self.sExitLOC or self.sPATH .. "main\\LOC_ExitPoint"
  Actor.SetVehicleAvoidance(self.hBomber, false)
  Actor.SetVehicleAvoidance(self.tGuards[1], false)
  Actor.SetVehicleAvoidance(self.tGuards[2], false)
  local tStreamEvent = {
    EventType = "StreamEvent",
    Objects = self.tIntGuards,
    WaitForGameObject = true
  }
  self:RegisterEvent(Util.CreateEvent(tStreamEvent, "P4FP_MadBomber02.InteriorGuardsStreamed", self))
end

function P4FP_MadBomber02:SetupCheckpoint(a_nCP)
  self.tSaveInfo.nCheckpointNum = a_nCP
  self.RegisterCheckpoint(self, "P4FP_MadBomber02.DoCheckpoint")
end

function P4FP_MadBomber02:DoCheckpoint()
  local nCP = self.tSaveInfo.nCheckpointNum
  self.SetupVariables(self)
  if nCP == 1 then
    self.Task_Taxi(self)
    self.Task_Exit(self)
    Actor.CancelAttrPtRequest(self.hBomber)
  elseif nCP == 2 then
    if not self:IsMissionTaskActive("Task_Taxi") then
      self.Task_Taxi(self)
      Actor.CancelAttrPtRequest(self.hBomber)
    end
  elseif nCP == 3 then
    Actor.CancelAttrPtRequest(self.hBomber)
    self.Task_EnterCourtyard(self)
  end
end

function P4FP_MadBomber02:Task_Exit()
  self:CreateTask({
    sName = "Task_Exit",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "ExitInterior",
    sObjectiveTextID = "P4FP_MadBomber02_Text.Task_Exit",
    sInteriorName = "LaVillette",
    bInteriorTask = true,
    MarkerHeight = 0.5,
    tOnComplete = {
      {
        EVENT_Timer,
        {
          "P4FP_MadBomber02.AutoTalk",
          self,
          2
        }
      },
      {
        self.SetupCheckpoint,
        {self, 2}
      }
    }
  })
end

function P4FP_MadBomber02:AutoTalk()
  Cin.PlayConversation("P4FP_MadBomber02_FollowA")
end

function P4FP_MadBomber02:FakeyTask()
  self:CreateTask({
    sName = "FakeyTalk",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "TALK",
    sConvFile = "P4FP_MadBomber02_FollowA",
    tTgtInclude = {
      self.sBomber
    },
    bautofire = true,
    bNoFocus = true,
    bNoHUDBlip = true,
    bNoWorldBlip = true,
    bOptional = true,
    tOnComplete = {}
  })
end

function P4FP_MadBomber02:Task_Taxi()
  AttractionPt.EnableUse(Handle(self.sDoorPoint), false)
  self:CreateTask({
    sName = "Task_Taxi",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "TAXI",
    sObjectiveTextID = "P4FP_MadBomber02_Text.Task_Bring_Denis_To_Embassy",
    sPickupTextID = "P4FP_MadBomber02_Text.Task_Pick_Up_Denis",
    sDropoffTextID = "P4FP_MadBomber02_Text.Task_Bring_Denis_To_Embassy",
    sVehicleFetchID = "GenericObjective_Text.Vehicle_GetIn_A",
    sVehicleReturnID = "GenericObjective_Text.Vehicle_GetIn_A",
    tPickupProxObj = {
      self.sBomber
    },
    PickupProximity = 12,
    tDestLocators = {
      self.sPATH .. "main\\LOC_TaxiEnd"
    },
    tDestRegion = {
      self.sPATH .. "main\\REG_DropOff"
    },
    tDeliverObjs = {
      self.sBomber
    },
    bEscalationDenial = true,
    bVehicleIsRequired = true,
    bNoDumping = true,
    bGroundBlip = true,
    sDropOffConv = "P4FP_MadBomber02_DropOff_b",
    tOnEarlyExit = {},
    tOnPickup = {
      {
        self.KillTaskByName,
        {self, "FakeyTalk"}
      },
      {
        self.InCarConvo,
        {self}
      }
    },
    tOnComplete = {
      {
        self.SetupCheckpoint,
        {self, 3}
      }
    },
    tOnActivate = {
      {
        self.DenisExitSeat,
        {self}
      }
    },
    tOnCancel = {
      {
        self.BombOops,
        {self}
      }
    }
  })
end

function P4FP_MadBomber02:Task_EnterCourtyard()
  self:CreateTask({
    sName = "Task_EnterCourtyard",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "TAXI",
    sObjectiveTextID = "P4FP_MadBomber02_Text.Task_Drop_Off_Denis_At_Embassy",
    sPickupTextID = "P4FP_MadBomber02_Text.Task_Pick_Up_Denis",
    sDropoffTextID = "P4FP_MadBomber02_Text.Task_Drop_Off_Denis_At_Embassy",
    sVehicleFetchID = "GenericObjective_Text.Vehicle_GetIn_A",
    sVehicleReturnID = "GenericObjective_Text.Vehicle_GetIn_A",
    tPickupProxObj = {
      self.sBomber
    },
    PickupProximity = 12,
    tDestLocators = {
      self.sPATH .. "main\\LOC_Embassy"
    },
    tDestRegion = {
      self.sPATH .. "main\\PT_Embassy"
    },
    tDeliverObjs = {
      self.sBomber
    },
    bEscalationDenial = true,
    bVehicleIsRequired = true,
    bGroundBlip = true,
    sDropOffConv = "P4FP_MadBomber02_DropOff_a",
    tOnActivate = {},
    tOnEarlyExit = {},
    tOnPickup = {},
    tOnComplete = {
      {
        self.Task_BomberGo,
        {self}
      }
    },
    tOnCancel = {
      {
        self.BombOops,
        {self}
      }
    }
  })
end

function P4FP_MadBomber02:Task_BomberGo()
  self:CreateTask({
    sName = "P4FP_MadBomber02_Task_BomberGo",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    sObjectiveTextID = "P4FP_MadBomber02_Text.Task_Prepare_To_Escape",
    bNoFocus = true,
    bNoHUDBlip = true,
    bNoWorldBlip = true,
    tTgtInclude = {
      self.sBomber
    },
    tOnActivate = {
      {
        self.MoveToBomb,
        {self}
      }
    },
    tOnComplete = {
      {
        self.KillTaskByName,
        {
          self,
          "TASK_DontEscalate"
        }
      },
      {
        self.Task_GetAway,
        {self}
      },
      {
        self.ExplodeTimer,
        {self}
      },
      {
        self.PlayEscapeConvo,
        {self}
      }
    }
  })
end

function P4FP_MadBomber02:TASK_DontEscalate()
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
          "P4FP_MadBomber02_Text.FAIL_Escalate"
        }
      }
    },
    tOnActivate = {}
  })
  self.tInfo.eAbandonDenis = EVENT_PlayerExitsTrigger("P4FP_MadBomber02.DenisAbandon", self, self.sAbandonTrig)
end

function P4FP_MadBomber02:Task_GetAway()
  self:CreateTask({
    sName = "Task_GetAway",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "TAXI",
    sObjectiveTextID = "P4FP_MadBomber02_Text.Task_Drop_off_Denis",
    sPickupTextID = "P4FP_MadBomber02_Text.Task_Pick_Up_Denis",
    sDropoffTextID = "P4FP_MadBomber02_Text.Task_Drop_off_Denis",
    sVehicleFetchID = "GenericObjective_Text.Vehicle_GetIn_A",
    sVehicleReturnID = "GenericObjective_Text.Vehicle_GetIn_A",
    tDestLocators = {
      self.sPATH .. "main\\LOC_Finish"
    },
    tDestRegion = {
      self.sPATH .. "main\\REG_Finish"
    },
    bEscalationDenial = true,
    tDeliverObjs = {
      self.sBomberNoBag
    },
    tPickupProxObj = {
      self.sBomberNoBag
    },
    PickupProximity = 12,
    sDropOffConv = "P4FP_MadBomber02_Return",
    bGroundBlip = true,
    tOnActivate = {
      {
        self.CheckDistanceFromCar,
        {self}
      }
    },
    tOnPickup = {},
    tOnComplete = {
      {
        self.SetupDenisDespawn,
        {self}
      }
    }
  })
end

function P4FP_MadBomber02.DisableGuardSuspicion()
  local G1 = Handle("Missions\\freeplay\\p1\\mis_cem_west\\main\\Guard3")
  local G2 = Handle("Missions\\freeplay\\p1\\mis_cem_west\\main\\Guard4")
  Suspicion.Enable(G1, false)
  Suspicion.Enable(G2, false)
end

function P4FP_MadBomber02.EnableGuardSuspicion()
  local G1 = Handle("Missions\\freeplay\\p1\\mis_cem_west\\main\\Guard3")
  local G2 = Handle("Missions\\freeplay\\p1\\mis_cem_west\\main\\Guard4")
  Suspicion.Enable(G1, true)
  Suspicion.Enable(G2, true)
end

function P4FP_MadBomber02:InteriorGuardsStreamed()
  for i, sGuard in ipairs(self.tIntGuards) do
    local hGuard = Handle(sGuard)
    Actor.SetVehicleAvoidance(hGuard, false)
  end
end

function P4FP_MadBomber02:InCarConvo()
  local tCarTalk = {
    {
      "DELAY",
      {5}
    },
    {
      "PLAYCONVERSATION",
      {
        "P4FP_MadBomber02_EnRouteBanter"
      }
    }
  }
  ScriptSequence.Run(self.hSab, tCarTalk)
end

function P4FP_MadBomber02:PlayEscapeConvo()
  EVENT_PlayerToActorProximity("P4FP_MadBomber02.PlayEscapeConvoProx", self, self.sBomberNoBag, 10)
end

function P4FP_MadBomber02:PlayEscapeConvoProx()
  Cin.PlayConversation("P4FP_MadBomber02_Escape")
end

function P4FP_MadBomber02:DenisExitSeat()
  Actor.CancelAttrPt(self.hBomber)
  Nav.SetScriptedPath(self.hBomber, self.sDenisExitSeatPath, false, "P4FP_MadBomber02.DenisFollow", self)
  Nav.SetScriptedPathMoveMode(self.hBomber, true)
end

function P4FP_MadBomber02:DenisFollow()
  Nav.SetScriptedPath(self.hBomber, self.sDenisExitChurchPath, false, "P4FP_MadBomber02.DenisSetSeanLeader", self)
  Nav.SetScriptedPathMoveMode(self.hBomber, true)
end

function P4FP_MadBomber02:DenisSetSeanLeader()
  Combat.SetLeader(self.hBomber, self.hSab, false, 10, 20)
end

function P4FP_MadBomber02:DenisDespawn()
  Actor.WalkToDespawnLocation(self.hBomberNoBag)
end

function P4FP_MadBomber02:DenisAbandon()
  self:MissionTaskFail("P1Freeplay.MadBomber02_Abandon")
end

function P4FP_MadBomber02:BombOops()
  local x, y, z = Object.GetPosition(self.hBomber)
  Util.CreateExplosion("Explosion_Large", x, y, z)
  EVENT_Timer("SabTaskObjective.CancelThisMission", self, 3)
end

function P4FP_MadBomber02:MoveToBomb()
  local sDoorPoint = self.sPATH .. "main\\DoorTriggerPoint(1)"
  local sDoorPointint = self.sPATH .. "main\\DoorTriggerPoint(2)"
  sDoorTriggerInt = "Missions\\freeplay\\p1\\mis_cem_west\\main\\PT_Door_Int"
  EVENT_ActorEntersTrigger("P4FP_MadBomber02.CloseEmbassyDoor", self, Handle(self.hBomber), sDoorTriggerInt)
  self.TASK_DontEscalate(self)
  local tEnterSequence = {
    {
      "RUNTOOBJECT",
      {sDoorPoint}
    },
    {
      "USEATTRPT",
      {sDoorPoint}
    },
    {
      "DELAY",
      {0.05}
    },
    {
      "WALKTOOBJECT",
      {sDoorPointint, 0.05}
    },
    {
      "DELAY",
      {15}
    }
  }
  ScriptSequence.Run(self.hBomber, tEnterSequence, self.MoveNewDenisIntoPosition, {self})
end

function P4FP_MadBomber02:CloseEmbassyDoor()
  EVENT_Timer("P4FP_MadBomber02.CloseEmbassyDoorDelayed", self, 2)
end

function P4FP_MadBomber02:CloseEmbassyDoorDelayed()
  Object.ForceClose(Handle("PARIS\\area04\\placedebastille\\buildings\\Embassy Temp 02\\SpawnerDoor_City1"))
end

function P4FP_MadBomber02:MoveNewDenisIntoPosition()
  RewardsManager.HideStarter("Father_Sacre_Interior", true)
  self.bOriginalDenisDespawned = true
  Object.Teleport(self.hBomberNoBag, 896.6582, 59.13714, -144.2302, -72)
  self.ForceOpenDoor(self)
end

function P4FP_MadBomber02:ForceOpenDoor()
  local hDoor = Handle(self.sDoor)
  Object.Actuate(hDoor, true)
  self.MoveToCar(self)
  self:RegisterTriggerEvent(Trigger.WaitFor(self.sDenisExitEmbTrig, self.hBomberNoBag, "P4FP_MadBomber02.ForceCloseDoor", self, nil, cTRIGGEREVENT_ONENTER, false), self.sDenisExitEmbTrig)
end

function P4FP_MadBomber02:ForceCloseDoor()
  local hDoor = Handle(self.sDoor)
  Object.ForceClose(hDoor)
end

function P4FP_MadBomber02:MoveToCar()
  local sDoorPointint = self.sPATH .. "main\\DoorTriggerPoint(2)"
  Actor.CancelAnimation(self.hBomberNoBag)
  Actor.CancelAttrPt(self.hBomberNoBag)
  Nav.MoveToObject(self.hBomberNoBag, Handle(self.sExitLOC), 0.5, true, "P4FP_MadBomber02.CompleteBomberTask", self)
end

function P4FP_MadBomber02:CompleteBomberTask()
  self:CompleteTaskByName("P4FP_MadBomber02_Task_BomberGo")
end

function P4FP_MadBomber02:ExplodeTimer()
  for i, sGuard in ipairs(self.tGuards) do
    local hGuard = Handle(sGuard)
    Suspicion.Enable(hGuard, true)
  end
  EVENT_Timer("P4FP_MadBomber02.Explode", self, 7)
end

function P4FP_MadBomber02:Explode()
  Cin.PlayCinematic("P4FP_MadBomber02_Explosion")
  EVENT_Timer("P4FP_MadBomber02.CreateExplosion", self, 0.01, {
    Handle("PARIS\\area04\\placedebastille\\buildings\\Embassy Temp 02\\City1_Embassy_Base_Wnd(1)"),
    60
  })
  EVENT_Timer("P4FP_MadBomber02.CreateExplosion", self, 0.5, {
    Handle("PARIS\\area04\\placedebastille\\buildings\\Embassy Temp 02\\City1_Embassy_Level2_Wnd(1)"),
    65
  })
  EVENT_Timer("P4FP_MadBomber02.CreateExplosion", self, 1, {
    Handle("PARIS\\area04\\placedebastille\\buildings\\Embassy Temp 02\\City1_Embassy_Level_Wnd(1)"),
    71
  })
  EVENT_Timer("P4FP_MadBomber02.TurnOnEscalation", self, 1)
  local hTank = Handle("Missions\\freeplay\\ambient\\p1\\p1_armoredcar_12\\FP_AMB_ArmoredCar\\Target")
  if hTank and Object.IsAlive(hTank) then
    Nav.MoveToObject(hTank, Handle("Missions\\freeplay\\p1\\mis_cem_west\\main\\LOC_Tank"), 0, true)
  end
end

function P4FP_MadBomber02:CreateExplosion(a_hObject, a_nY)
  Object.SetHealth(a_hObject, 10)
end

function P4FP_MadBomber02:TurnOnEscalation()
  self:KillTaskByName("TASK_DontEscalate")
  Trigger.ClearCallback(self.sAbandonTrig, self.tInfo.eAbandonDenis)
  Suspicion.SetFixedEscalationLevel(1)
  Suspicion.SetEscalated()
end

function P4FP_MadBomber02:CheckDistanceFromCar()
  local hObj
  if Actor.IsInVehicle(self.hSab) then
    hObj = Actor.GetVehicle(self.hSab)
  else
    hObj = self.hSab
  end
  local nDist = Object.GetDistance(self.hBomberNoBag, hObj)
  if 10 < nDist and hObj then
    Nav.MoveToObject(self.hBomberNoBag, hObj, 5, true)
  end
end

function P4FP_MadBomber02:SetupDenisDespawn()
  if self.bOriginalDenisDespawned then
    Render.FadeTo(0, 0, 0, 255, 1)
    local tTimerEvent = {EventType = "TimerEvent", Time = 1}
    Util.CreateEvent(tTimerEvent, "P4FP_MadBomber02.ResetDenis", self)
  end
end

function P4FP_MadBomber02:ResetDenis()
  Object.Despawn(self.hBomberNoBag, 0.1, false)
  RewardsManager.ShowStarter("Father_Sacre_Interior")
  Render.FadeTo(0, 0, 0, 0, 1)
  local tTimerEvent = {EventType = "TimerEvent", Time = 1}
  Util.CreateEvent(tTimerEvent, "P4FP_MadBomber02.CompleteMission", self)
end

function P4FP_MadBomber02:CompleteMission()
  self:CompleteThisMission()
end

function P4FP_MadBomber02:MISSION_ONRESET()
  Suspicion.EnableGlobal(true)
  Suspicion.EnableEscalation(true)
  Suspicion.SetFixedEscalationLevel(0)
  Sound.ResetMusicLocale()
end

function P4FP_MadBomber02:MISSION_ONCANCEL()
  RewardsManager.ShowStarter("Father_Sacre_Interior")
end
