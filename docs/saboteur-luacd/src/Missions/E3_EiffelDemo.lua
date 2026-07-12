if E3_EiffelDemo == nil then
  E3_EiffelDemo = SabTaskObjective:Create()
  E3_EiffelDemo:Configure({
    bWorldEvent = true,
    bCourier = true,
    bFastComplete = true,
    MCDisplayID = cNOMISSIONCOMPLETE,
    bFinishRebuild = true,
    tUnlockList = {},
    tStaticTags = {
      "E3_EiffelDemoElevator"
    },
    tSMEDNodes = {
      "Missions\\e3_eiffeldemo_objs"
    }
  })
end

function E3_EiffelDemo:STARTER_Setup()
end

function E3_EiffelDemo:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
end

function E3_EiffelDemo:GENERAL_Setup()
  print("$$$$ E3_EiffelDemo.GENERAL_Setup")
  GodMode()
  Sound.DisableSeanChatter()
  Render.SetGlobalWTF(true)
  Freeplay.UnloadAmbientFreeplay(true)
  Util.EnableMiniZep(false)
  Util.SetDisableMessengers(true)
  local hZeppy = Handle("Missions\\e3_eiffeldemo_objs\\VH_OP_MiniZep_SPLINE")
  local tZeppyDeathEvent = {EventType = "DeathEvent", ObjectHandle = hZeppy}
  Util.CreateEvent(tZeppyDeathEvent, "E3_EiffelDemo.DemoOver", self)
  local hMan2 = Handle("Missions\\e3_eiffeldemo_objs\\Spore_SS_Heavy_MG(2)")
  local tMan2DeathEvent = {EventType = "DeathEvent", ObjectHandle = hMan2}
  Util.CreateEvent(tMan2DeathEvent, "E3_EiffelDemo.StartElevator", self)
  local tGrabManDudes = {
    EventType = "OnStateChange",
    EventName = "tGrabManDudes",
    Target = hSab
  }
  self.tGrabManDudes = Util.CreateEvent(tGrabManDudes, "E3_EiffelDemo.DetectGrab", self, nil, true)
end

function E3_EiffelDemo:DetectGrab(a_tVars)
  local a_hState = a_tVars[2]
  if a_hState == Util.GetHandleByName("LapelGrab") then
    print("$$$LapelGrab")
    Suspicion.SetEscalationLevel(4)
    E3_EiffelDemo.StartElevator(self)
  end
end

function E3_EiffelDemo:ElevatorTrigger()
  print("$$$$ E3_EiffelDemo.ElevatorTrigger")
  EVENT_PlayerEntersTrigger("E3_EiffelDemo.StartElevator", self, "Missions\\e3_eiffeldemo_objs\\PT_ElevatorStart")
end

function E3_EiffelDemo:StartElevator()
  print("$$$$ E3_EiffelDemo.StartElevator")
  local hSoldier = Util.GetHandleByName("Missions\\e3_eiffeldemo_objs\\RocketMan")
  Object.SetInvincibleToAI(hSoldier, true)
  Object.ForceOpen(Util.GetHandleByName("Missions\\e3_eiffeldemo\\MN_EifelTower_Elevator_A_Top(1)"))
  EVENT_Timer("E3_EiffelDemo.DummyFire", self, 8)
end

function E3_EiffelDemo:DemoOver()
  print("$$$$ DEMO OVER")
  Sound.EnableSeanChatter()
  Util.SetDisableMessengers(false)
  EVENT_Timer("E3_EiffelDemo.ShowCin", self, 8)
end

function E3_EiffelDemo:SpawnZep()
  print("$$$$E3_EiffelDemo.SpawnZep")
  self:CreateTask({
    sName = "E3_EiffelDemo_Cinematic",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "E3Eiffel_ZepCin",
    tOnActivate = {},
    tOnComplete = {}
  })
end

function E3_EiffelDemo:ShowCin()
  self:CreateTask({
    sName = "E3_EiffelDemo_Cinematic",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "Sab_Placeholder",
    tOnActivate = {},
    tOnComplete = {
      {
        self.CompleteThisMission,
        {self}
      }
    }
  })
end

function E3_EiffelDemo:DummyFire()
  print("$$$$$$$$$$Dummy Fire")
  local hSoldier = WRAPPER_CheckForHandle("Missions\\e3_eiffeldemo_objs\\RocketMan")
  if hSoldier and Object.GetHealth(hSoldier) > 0 then
    local hTarget = WRAPPER_CheckForHandle("Missions\\e3_eiffeldemo_objs\\DummyTarget")
    Object.SetInvincibleToAI(hSoldier, false)
    Combat.SetAlwaysSeeTarget(hSoldier, true)
    Combat.SetBroadcastWeaponFire(hSoldier, false)
    Combat.SetReactImmediately(hSoldier, true)
    Combat.SetTargetAggressively(hSoldier, true)
    Combat.SetLethalForce(hSoldier, true)
    Combat.SetCombat(hSoldier)
    Combat.AddTargetFlag(hSoldier, cTARGET_ENEMYLIST, {
      {hTarget, 0.1},
      {hSab, 100}
    })
  end
end
