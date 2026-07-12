if Act_1_BarFight == nil then
  Act_1_BarFight = SabTaskObjective:Create()
  gsA1BarFight = "Missions\\act_1\\barfight\\"
  Act_1_BarFight:Configure({
    TaskCount = "auto",
    MCDisplayID = 2,
    bStarterless = true,
    sSaveMissionNameID = "MissionNames_Text.A1M2",
    tUnlockList = {
      "Act_1_Mission_2B"
    },
    tSMEDNodes = {
      gsA1BarFight .. "main",
      gsA1BarFight .. "Sound"
    }
  })
end

function Act_1_BarFight:STARTER_Setup()
  Render.SetGlobalWTF(true)
  Actor.SetLabel(hSab, "WPOP_RACE_TIME", true)
  Actor.SetDisguise(hSab, "FBS_RS_Sean_Shirt_Sab_Hat_NoBag")
end

function Act_1_BarFight:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
  self.RegisterCheckpoint(self, "Act_1_BarFight.CheckpointStart")
  Sound.LoadSoundBank("m_A1M2_inGame.bnk")
end

function Act_1_BarFight:CheckpointStart()
  Cin.LoadCinematic("106_CinA_BarFight")
  self.bReSetup = false
  EVENT_ActorEntersTrigger("Act_1_BarFight.Planes", self, hSab, "Missions\\act_1\\barfight\\main\\PT_BarFlyover")
  self:DramaticPause(2, "Act_1_BarFight.SprintTut")
  self.TASK_Escalator(self)
  self.Task_OpenDoor(self)
  if Util.GetHandleByName("Missions\\act_1\\characters\\farm_jules\\jules") then
    self.Task_EnterRedOx(self)
    ACTOR_FollowObject("Missions\\act_1\\characters\\farm_jules\\jules", hSab, 2)
    EVENT_ActorDeath("Act_1_BarFight.FailCarDead", self, Util.GetHandleByName("Missions\\act_1\\togermany\\truckaurora\\TruckAurora"), {
      "GenericFail_Text.DESTROYED_Aurora"
    })
    EVENT_ActorToActorProximityNegated("Act_1_BarFight.JulesRuns", self, "Missions\\act_1\\characters\\farm_jules\\jules", "Saboteur", 15)
    Util.UnloadEditNode("Missions\\act_1\\characters\\farm_jules.wsd", false)
  else
    self.Task_EnterRedOx(self)
  end
end

function Act_1_BarFight:SprintTut()
  Saboteur.ShowToolTip("TutorialTip_Text.Objective_Focus", 10)
  HUD.FlashObjectiveMarker()
  Saboteur.ShowToolTip("TutorialTip_Text.Sprinting", 10)
end

function Act_1_BarFight:FailCarDead(sFailString)
  Cin.PlayConversation("A1M0_VehicleDamage_Destroyed")
  self:MissionTaskFail(sFailString)
end

function Act_1_BarFight:FailJulesDead(sFailString)
  self:MissionTaskFail(sFailString)
end

function Act_1_BarFight:Planes()
  ConvoHelper.ClearAll()
  Cin.StopConversation("103_InG_Truck-Drive03")
  Cin.PlayCinematic("A1M1_Barflyby")
end

function Act_1_BarFight:JulesRuns()
  Cin.PlayConversation("A1M2_OMW")
  ACTOR_RunPathOnce("Missions\\act_1\\characters\\farm_jules\\jules", "Missions\\act_1\\barfight\\main\\PATH_Jules2Bar")
end

function Act_1_BarFight:TASK_Escalator()
  self:CreateTask({
    sName = "TASK_Escalator",
    sTaskType = "SabTaskObjectiveEscalation",
    sTaskSubType = "None",
    EscalationLevel = 1,
    bGTE = true,
    tOnComplete = {
      {
        self.OnEscalation,
        {self}
      },
      {
        self.TASK_LostEscalation,
        {self}
      }
    },
    tOnActivate = {}
  })
end

function Act_1_BarFight:TASK_LostEscalation()
  self:CreateTask({
    sName = "TASK_LostEscalation",
    sTaskType = "SabTaskObjectiveEscalation",
    sTaskSubType = "None",
    EscalationLevel = 0,
    sObjectiveTextID = "GenericObjective_Text.Escalation_Lose",
    tOnComplete = {
      {
        self.OnEscalationClear,
        {self}
      },
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
    },
    tOnActivate = {}
  })
end

function Act_1_BarFight:OnEscalation()
  if self:IsMissionTaskActive("Task_EnterRedOx") then
    self:KillTaskByName("Task_EnterRedOx")
    self:TASK_LostEscalation()
  end
end

function Act_1_BarFight:OnEscalationClear()
  if self.bLostEscalationOnce == false then
    self.bLostEscalationOnce = true
    self:TASK_ReturnToBelle()
  else
    self.ResetTaskByName(self, "Task_EnterRedOx")
  end
end

function Act_1_BarFight:GENERAL_Setup()
  self.DEBUGMODE = false
  Util.EnableMiniZep(false)
  Actor.SetLabel(hSab, " WPOP_RACE_TIME ", true)
  self.sJules = gsA1BarFight .. "patrons\\Spore_RS_Jules"
  self.sVeronique = gsA1BarFight .. "patrons\\Spore_RS_Veronique"
  self.sVittore = gsA1BarFight .. "patrons\\Spore_RS_Vittore"
  self.bUpstairs = false
  self.tEvents = {}
  self.tDelayedEvents = {}
  self.bShitNFan = false
  self.sLOCJulesThrow = gsA1BarFight .. "main\\LOC_JulesThrow"
  self.sLOCVictimThrow = gsA1BarFight .. "nazis\\LOC_VictimThrow"
  self.sBodyNet = gsA1BarFight .. "main\\PT_BodyNet"
  self.tBarNazis = {
    gsA1BarFight .. "nazis\\Spore_NZ_DpplzgPit_1",
    gsA1BarFight .. "nazis\\Spore_NZ_DpplzgPit_2",
    gsA1BarFight .. "nazis\\Spore_NZ_DpplzgPit_3",
    gsA1BarFight .. "nazis\\Spore_NZ_DpplzgPit_4",
    gsA1BarFight .. "nazis\\Spore_NZ_DpplzgPit_5",
    gsA1BarFight .. "nazis\\Spore_WM_DrunkHeavy",
    gsA1BarFight .. "nazis\\Spore_NZ_BigMech_1",
    gsA1BarFight .. "nazis\\Spore_NZ_BigMech_2"
  }
  self.sBarNaziStarter = gsA1BarFight .. "nazis\\Spore_NZ_DpplzgPit_1"
  self.sBarNaziJulesVic = gsA1BarFight .. "nazis\\Spore_NZ_DpplzgPit_4"
  self.tBarNaziDownstairs = {
    gsA1BarFight .. "nazis\\Spore_NZ_DpplzgPit_2",
    gsA1BarFight .. "nazis\\Spore_NZ_DpplzgPit_3",
    gsA1BarFight .. "nazis\\Spore_NZ_DpplzgPit_4",
    gsA1BarFight .. "nazis\\Spore_NZ_DpplzgPit_5",
    gsA1BarFight .. "nazis\\Spore_WM_DrunkHeavy",
    gsA1BarFight .. "nazis\\Spore_NZ_BigMech_1",
    gsA1BarFight .. "nazis\\Spore_NZ_BigMech_2"
  }
  self.tBarNaziDownCrowd = {
    gsA1BarFight .. "nazis\\Spore_NZ_DpplzgPit_2",
    gsA1BarFight .. "nazis\\Spore_NZ_DpplzgPit_3",
    gsA1BarFight .. "nazis\\Spore_NZ_DpplzgPit_5",
    gsA1BarFight .. "nazis\\Spore_NZ_BigMech_1",
    gsA1BarFight .. "nazis\\Spore_NZ_BigMech_2",
    gsA1BarFight .. "nazis\\Spore_WM_DrunkHeavy"
  }
  self.tEveryone = {}
  self.tAllYalls = {}
  self.tUpYalls = {}
  self.tGroupies = {
    gsA1BarFight .. "nazis\\RaceGroupie_1",
    gsA1BarFight .. "nazis\\RaceGroupie_2"
  }
  self.tLOCFlirt = {
    gsA1BarFight .. "main\\AttractionPT_Doris_Flirt",
    gsA1BarFight .. "main\\AttractionPT_BalconyCoupleF"
  }
  self.tFightChatter = {
    "A1M2_FightChatter_01",
    "A1M2_FightChatter_02",
    "A1M2_FightChatter_03",
    "A1M2_FightChatter_04",
    "A1M2_FightChatter_05",
    "A1M2_FightChatter_06"
  }
  self.tSeanKnockout = {
    "A1M2_SeanKnockout_01",
    "A1M2_SeanKnockout_02",
    "A1M2_JulesDamaged"
  }
  self.tJulesKnockout = {
    "A1M2_JulesKnockout_01"
  }
  self.bTooSoon = false
  self.bChatterBusy = false
  self.tSaveInfo.bLeaveDelayed = false
  self.sPathUpstairs = gsA1BarFight .. "main\\PATH_Upstairs"
  self.iPunchcount = 0
  self.bDirectional = false
  self.bSkipped = false
  self:AddOnCancelCallback(Act_1_BarFight.Reset)
  self:AddOnCompleteCallback(Act_1_BarFight.Reset)
end

function Act_1_BarFight:Reset()
  Sound.ResetMusicLocale()
  Sound.ReleaseSoundBank("m_A1M2_inGame.bnk")
  Act_1_BarFight:LockDoors(false)
  WorldSMEDNodes.UnloadNode("Missions\\act_1\\togermany\\truckaurora", true)
  WorldSMEDNodes.UnloadNode("Missions\\act_1\\togermany\\javier", true)
end

function Act_1_BarFight:AddEvent(a_eEvent)
  self:RegisterEvent(a_eEvent)
  table.insert(self.tEvents, a_eEvent)
end

function Act_1_BarFight:ClearEvents()
  if self.tEvents then
    for i, e in ipairs(self.tEvents) do
      Util.KillEvent(e)
    end
    self.tEvents = {}
  end
end

function Act_1_BarFight:Shutdown()
  Cin.LoadCinematic("107_CinB_Skylar")
  Actor.SetLabel(hSab, "WPOP_RACE_TIME", false)
  if self.bKillThem == true then
    Object.EnableSpawner(self.hFlameSpawnerTop, false)
    Object.EnableSpawner(self.hFlameSpawner, false)
    Object.SpawnerPurge(self.hFlameSpawnerTop, true)
    Object.SpawnerPurge(self.hFlameSpawner, true)
  end
  Util.EnableMiniZep(true)
  Suspicion.EnableEscalation(true)
  self.CompleteThisMission(self)
end

function Act_1_BarFight:LockDoors(bLocked)
  local hDoor = Util.GetHandleByName("CountrySide\\alsace\\town\\interior\\redox_int\\UsePT_SpawnCloset_inside")
  local hDoor2 = Util.GetHandleByName("CountrySide\\alsace\\town\\interior\\redox_int\\UsePT_SpawnCloset_topinside")
  if hDoor then
    AttractionPt.EnableUse(hDoor, not bLocked)
  end
  if hDoor2 then
    AttractionPt.EnableUse(hDoor2, not bLocked)
  end
end

function Act_1_BarFight:LockdownActor(a_hActor)
  if Combat.IsCombatant(a_hActor) == true then
    Combat.SetIdleScripted(a_hActor, true)
    Combat.SetRespondToEvents(a_hActor, false)
    Combat.SetRespondToSound(a_hActor, false)
    Combat.SetRespondToDamage(a_hActor, false)
    Combat.SetSquadAssist(a_hActor, false)
  end
end

function Act_1_BarFight:UnLockActor(a_hActor)
  if Combat.IsCombatant(a_hActor) == true then
    Combat.SetIdleScripted(a_hActor, false)
    Combat.SetRespondToEvents(a_hActor, true)
    Combat.SetRespondToSound(a_hActor, true)
    Combat.SetRespondToDamage(a_hActor, true)
    Combat.SetSquadAssist(a_hActor, true)
  end
end

function Act_1_BarFight:TeleportFront()
  Object.PlayerTeleportToLocator(Util.GetHandleByName("CountrySide\alsace\towninterior\redox_extLOC_RO_Ext"))
end

function Act_1_BarFight:TeleportBack()
  Actor.UseAttrPt(hSab, Util.GetHandleByName("CountrySide\\alsace\\town\\interior\\redox_int\\TeleporterDoorPoint"))
end

function Act_1_BarFight:SetupBar()
  Suspicion.EnableEscalation(false)
  Util.UnloadStaticENTag("A1M1_RACE_PIT", true)
  Util.SetTime(21, 0)
  self.tTastesGreatSquad = Tips.GetListFromNames(gsA1BarFight .. "patrons\\BarfighterTG_")
  self.tLessFillingSquad = Tips.GetListFromNames(gsA1BarFight .. "patrons\\BarfighterLF_")
  self.tBarPatrons = Tips.GetListFromNames(gsA1BarFight .. "patrons\\Barpatron_")
  table.insert(self.tBarPatrons, Util.GetHandleByName("Missions\\act_1\\barfight\\patrons\\CIN_BarfighterLF"))
  table.insert(self.tBarPatrons, Util.GetHandleByName("Missions\\act_1\\barfight\\patrons\\CIN_BarfighterTG"))
  for i, v in ipairs(self.tBarPatrons) do
    self:AddGroup2All(v)
  end
  self.tUSSquad = Tips.GetListFromNames(gsA1BarFight .. "patrons\\BarfighterUS_")
  self.tThemSquad = Tips.GetListFromNames(gsA1BarFight .. "patrons\\BarfighterTM_")
  for i, v in ipairs(self.tUSSquad) do
    table.insert(self.tUpYalls, v)
  end
  for i, v in ipairs(self.tThemSquad) do
    table.insert(self.tUpYalls, v)
  end
  Squad.Create("TastesGreat")
  Squad.Create("LessFilling")
  Squad.SetEnemy("TastesGreat", "LessFilling")
  self.hJules = Util.GetHandleByName(self.sJules)
  self.hVeronique = Util.GetHandleByName(self.sVeronique)
  self.hVittore = Util.GetHandleByName(self.sVittore)
  self.hDierker = Util.GetHandleByName(gsA1BarFight .. "nazis\\Spore_NZ_Dierker_RaceDriver")
  self.hBarNaziVerVic = Util.GetHandleByName(gsA1BarFight .. "nazis\\Spore_NZ_DpplzgPit_5")
  local sInteriorPath = "CountrySide\\alsace\\town\\interior\\redox_int\\"
  self.tSeats = {}
  self.tExtraSeats = {
    Util.GetHandleByName(sInteriorPath .. "AttractionPT_Bar_lean"),
    Util.GetHandleByName(sInteriorPath .. "AttractionPT_Bar_lean_2"),
    Util.GetHandleByName(gsA1BarFight .. "main\\AttractionPT_WallLean"),
    Util.GetHandleByName(gsA1BarFight .. "nazis\\AttractionPT_drunk_sick"),
    AttractionPt.FindPtInObject(Util.GetHandleByName(sInteriorPath .. "MN_RedOx_BarSetup\\MN_RedOx_seat_1\\MN_RedOx_chair_bar"), "sit"),
    AttractionPt.FindPtInObject(Util.GetHandleByName(sInteriorPath .. "MN_RedOx_BarSetup\\MN_RedOx_seat_2\\MN_RedOx_chair_bar"), "sit")
  }
  self.tUpSeats = {
    AttractionPt.FindPtInObject(Util.GetHandleByName(sInteriorPath .. "MN_RedOx_seatUS_1\\MN_RedOx_chair_table"), "sit"),
    AttractionPt.FindPtInObject(Util.GetHandleByName(sInteriorPath .. "MN_RedOx_seatUS_2\\MN_RedOx_chair_table 2"), "sit"),
    AttractionPt.FindPtInObject(Util.GetHandleByName(sInteriorPath .. "MN_RedOx_seatUS_3\\MN_RedOx_chair_table"), "sit"),
    AttractionPt.FindPtInObject(Util.GetHandleByName(sInteriorPath .. "MN_RedOx_seatUS_4\\MN_RedOx_chair_table 2"), "sit"),
    AttractionPt.FindPtInObject(Util.GetHandleByName(sInteriorPath .. "MN_RedOx_seatUS_5\\MN_RedOx_chair_table"), "sit"),
    Util.GetHandleByName(gsA1BarFight .. "nazis\\AttractionPT_Balcony2"),
    Util.GetHandleByName(gsA1BarFight .. "nazis\\AttractionPT_Balcony"),
    Util.GetHandleByName(gsA1BarFight .. "main\\AttractionPT_BalconyCoupleM")
  }
  self.tSeats = {
    AttractionPt.FindPtInObject(Util.GetHandleByName(sInteriorPath .. "MN_RedOx_Table5\\MN_RedOx_table_tall"), "sit1"),
    AttractionPt.FindPtInObject(Util.GetHandleByName(sInteriorPath .. "MN_RedOx_Table5\\MN_RedOx_table_tall"), "sit2"),
    AttractionPt.FindPtInObject(Util.GetHandleByName(sInteriorPath .. "MN_RedOx_Table5\\MN_RedOx_table_tall"), "sit3"),
    AttractionPt.FindPtInObject(Util.GetHandleByName(sInteriorPath .. "MN_RedOx_Table4\\MN_RedOx_table_tall"), "sit1"),
    AttractionPt.FindPtInObject(Util.GetHandleByName(sInteriorPath .. "MN_RedOx_Table4\\MN_RedOx_table_tall"), "sit2"),
    AttractionPt.FindPtInObject(Util.GetHandleByName(sInteriorPath .. "MN_RedOx_Table4\\MN_RedOx_table_tall"), "sit3"),
    AttractionPt.FindPtInObject(Util.GetHandleByName(sInteriorPath .. "MN_RedOx_Table2\\MN_RedOx_table_tall"), "sit1"),
    AttractionPt.FindPtInObject(Util.GetHandleByName(sInteriorPath .. "MN_RedOx_Table2\\MN_RedOx_table_tall"), "sit4"),
    AttractionPt.FindPtInObject(Util.GetHandleByName(sInteriorPath .. "MN_RedOx_Table1\\MN_RedOx_table_tall"), "sit1"),
    AttractionPt.FindPtInObject(Util.GetHandleByName(sInteriorPath .. "MN_RedOx_Table1\\MN_RedOx_table_tall"), "sit2"),
    AttractionPt.FindPtInObject(Util.GetHandleByName(sInteriorPath .. "MN_RedOx_Table1\\MN_RedOx_table_tall"), "sit3"),
    AttractionPt.FindPtInObject(Util.GetHandleByName(sInteriorPath .. "MN_RedOx_Table1\\MN_RedOx_table_tall"), "sit4"),
    AttractionPt.FindPtInObject(Util.GetHandleByName(sInteriorPath .. "MN_RedOx_Table6\\MN_RedOx_seat_9\\MN_RedOx_chair_table"), "sit"),
    AttractionPt.FindPtInObject(Util.GetHandleByName(sInteriorPath .. "MN_RedOx_Table6\\MN_RedOx_seat_10\\MN_RedOx_chair_table 2"), "sit"),
    AttractionPt.FindPtInObject(Util.GetHandleByName(sInteriorPath .. "MN_RedOx_Table7\\MN_RedOx_seat_9\\MN_RedOx_chair_table"), "sit"),
    AttractionPt.FindPtInObject(Util.GetHandleByName(sInteriorPath .. "MN_RedOx_Table7\\MN_RedOx_seat_10\\MN_RedOx_chair_table 2"), "sit"),
    AttractionPt.FindPtInObject(Util.GetHandleByName(sInteriorPath .. "MN_RedOx_Table8\\MN_RedOx_seat_9\\MN_RedOx_chair_table"), "sit"),
    AttractionPt.FindPtInObject(Util.GetHandleByName(sInteriorPath .. "MN_RedOx_Table8\\MN_RedOx_seat_10\\MN_RedOx_chair_table 2"), "sit"),
    AttractionPt.FindPtInObject(Util.GetHandleByName(sInteriorPath .. "MN_RedOx_Table9\\MN_RedOx_seat_9\\MN_RedOx_chair_table"), "sit"),
    AttractionPt.FindPtInObject(Util.GetHandleByName(sInteriorPath .. "MN_RedOx_Table9\\MN_RedOx_seat_10\\MN_RedOx_chair_table 2"), "sit")
  }
  for i, v in ipairs(self.tSeats) do
    AttractionPt.EnableBroadcast(v, false)
  end
  for i, v in ipairs(self.tTastesGreatSquad) do
    self:AddGroup2All(v)
  end
  for i, v in ipairs(self.tLessFillingSquad) do
    self:AddGroup2All(v)
  end
  for i, v in ipairs(self.tUpYalls) do
    self:AddGroup2All(v)
  end
  for i, v in ipairs(self.tGroupies) do
    self:AddGroup2All(Util.GetHandleByName(v))
  end
  for i, v in ipairs(self.tBarNaziDownstairs) do
    self:AddGroup2All(Util.GetHandleByName(v))
  end
  self.tCivFighters = {}
  self.BuildCivFighters(self, {
    self.tTastesGreatSquad,
    self.tLessFillingSquad,
    self.tUpYalls
  })
  for i, v in ipairs(self.tBarNaziDownCrowd) do
    table.insert(self.tAllYalls, Util.GetHandleByName(v))
  end
  for i, v in ipairs(self.tTastesGreatSquad) do
    local tDamageEvent = {
      EventType = "OnDamage",
      Target = v,
      EventName = "OnDamage" .. i
    }
    self:AddEvent(Util.CreateEvent(tDamageEvent, "Act_1_BarFight.GetOnUp", self, {v}))
  end
  for i, v in ipairs(self.tLessFillingSquad) do
    if v ~= Util.GetHandleByName("Missions\\act_1\\barfight\\patrons\\BarfighterLF_2") then
      table.insert(self.tAllYalls, v)
    end
    local tDamageEvent = {
      EventType = "OnDamage",
      Target = v,
      EventName = "OnDamage" .. i
    }
    self:AddEvent(Util.CreateEvent(tDamageEvent, "Act_1_BarFight.GetOnUp", self, {v}))
  end
  self.hHeavyDrunk = Util.GetHandleByName(gsA1BarFight .. "nazis\\Spore_WM_DrunkHeavy")
  for i, v in ipairs(self.tAllYalls) do
    local hATPT = self.tSeats[i]
    if hATPT ~= nil then
      self:LockdownActor(v)
      local e = Util.CreateEvent({
        EventType = "StreamEvent",
        WaitForGameObject = true,
        Objects = {v}
      }, "Act_1_BarFight.SitDown", self, {v, hATPT})
      self:AddEvent(e)
    end
  end
  for i, v in ipairs(self.tUpYalls) do
    local hATPT = self.tUpSeats[i]
    self:LockdownActor(v)
    local e = Util.CreateEvent({
      EventType = "StreamEvent",
      WaitForGameObject = true,
      Objects = {v}
    }, "Act_1_BarFight.SitDown", self, {v, hATPT})
    self:AddEvent(e)
  end
  for i, v in ipairs(self.tBarPatrons) do
    Actor.EnableNeeds(v, true)
  end
  for i, v in ipairs(self.tGroupies) do
    Actor.UseAttrPt(Util.GetHandleByName(v), Util.GetHandleByName(self.tLOCFlirt[i]))
  end
  self.tAllies = {
    self.hJules,
    self.hVeronique,
    self.hVittore
  }
  Squad.Create("Allies")
  Squad.AddMember("Allies", self.hVittore)
  Squad.AddMember("Allies", self.hVeronique)
end

function Act_1_BarFight:SitDown(a_Dude, a_hATPT)
  if a_hATPT ~= nil then
    Actor.UseAttrPt(a_Dude, a_hATPT)
  end
end

function Act_1_BarFight:SetupEvents()
  self:LockDoors(true)
  self:LockdownActor(self.hDierker)
  Object.SetHealth(self.hDierker, 1)
  Actor.PlayAnimation(self.hDierker, "Civ_lay_ground_sad")
  self.eWTFSean = EVENT_ActorFiresAnyWeapon("Act_1_BarFight.WTFSean", self, hSab)
  self:AddEvent(self.eWTFSean)
  for i, v in ipairs(self.tAllies) do
    Combat.SetReactImmediately(v, true)
    Object.SetInvincibleToAI(v, true)
    Actor.EnableNeeds(v, false)
    Combat.SetIdleScripted(v, true)
    Combat.SetAlwaysSeeTarget(v, true)
    Combat.SetTargetAggressively(v, true)
    self:AddGroup2All(v)
  end
  Actor.OverrideCombatAI(self.hVeronique, true)
  Actor.OverrideCombatAI(self.hVittore, true)
end

function Act_1_BarFight:GunCheck()
  Cin.PlayConversation("A1M2_GunCheck")
end

function Act_1_BarFight:WTFSean()
  Cin.PlayConversation("A1M2_GunFail", "Act_1_BarFight.GunFail", self)
end

function Act_1_BarFight:GunFail()
  self:MissionTaskFail("A1M2_Text.Fail_Gun")
end

function Act_1_BarFight:GodCharacter(a_Dude)
  Object.SetInvincible(a_Dude, true)
end

function Act_1_BarFight:BuildCivFighters(a_tDudeTables)
  for i, a_tDudes in ipairs(a_tDudeTables) do
    for i, v in ipairs(a_tDudes) do
      table.insert(self.tCivFighters, v)
    end
  end
end

function Act_1_BarFight:BarTalk()
  Cin.PlayConversation("A1M2_BarmanChatter")
  local eBartender = Util.CreateEvent({
    EventType = "TimerEvent",
    Time = math.random(35, 95)
  }, "Act_1_BarFight.BarTalk", self, {})
  self:AddEvent(eBartender)
end

function Act_1_BarFight:AddGroup2All(a_hDude)
  table.insert(self.tEveryone, a_hDude)
  Actor.EnableNeeds(a_hDude, false)
  if Combat.IsCombatant(a_hDude) == true then
    Combat.SetReactImmediately(a_hDude, true)
  end
end

function Act_1_BarFight:ItsOn()
  if self.bShitNFan == false then
    if self:IsMissionTaskActive("Task_DefendYourself") then
      self:CompleteTaskByName("Task_DefendYourself")
    end
    table.insert(self.tSecondWave, self.sBarNaziJulesVic)
    table.insert(self.tSecondWave, self.sBarNaziStarter)
    self:Task_KillBottom()
  end
end

function Act_1_BarFight:GetOnUp(a_tVars, a_hDude)
  if self.bShitNFan == false then
    self:GetUpNow(a_hDude)
  end
end

function Act_1_BarFight:GetUpNow(a_hDude)
  self:UnLockActor(a_hDude)
  for i, v in ipairs(self.tTastesGreatSquad) do
    if v == a_hDude then
      Squad.AddMember("TastesGreat", v)
    end
  end
  for i, v in ipairs(self.tLessFillingSquad) do
    if v == a_hDude then
      Squad.AddMember("LessFilling", v)
    end
  end
  for i, v in ipairs(self.tBarPatrons) do
    if v == a_hDude then
      if i < 4 then
        Squad.AddMember("LessFilling", v)
      else
        Squad.AddMember("TastesGreat", v)
      end
    end
  end
  Combat.SetAlwaysSeeTarget(a_hDude, true)
  Combat.SetTargetAggressively(a_hDude, true)
  Combat.SetCombat(a_hDude)
end

function Act_1_BarFight:PatronSit()
  local self = Act_1_BarFight
  if self.bReSetup == false then
    self.bReSetup = true
    local iDudeIndex = 1
    for i, v in ipairs(self.tSeats) do
      if iDudeIndex < 8 then
        local hATPT = v
        if hATPT ~= nil and AttractionPt.IsAvailable(hATPT) then
          local hActor = self.tTastesGreatSquad[iDudeIndex]
          self:LockdownActor(hActor)
          Actor.CancelAnimation(hActor)
          local e = Util.CreateEvent({
            EventType = "StreamEvent",
            WaitForGameObject = true,
            Objects = {hActor}
          }, "Act_1_BarFight.SitDown", self, {hActor, hATPT})
          self:AddEvent(e)
          iDudeIndex = iDudeIndex + 1
        end
      end
    end
    for i, v in ipairs(self.tBarPatrons) do
      local hDude = v
      local bFound = false
      for i, j in ipairs(self.tExtraSeats) do
        if bFound == false and AttractionPt.IsAvailable(j) then
          bFound = true
          Actor.CancelAnimation(hDude)
          Actor.UseAttrPt(hDude, j)
        end
      end
    end
  end
end

function Act_1_BarFight:HaveIt()
  self:PrintDebug("Have It!")
  Cin.PlayConversation("A1M2_GetHerOut", "Act_1_BarFight.ReFight", self)
  EVENT_ActorExitsTrigger("Act_1_BarFight.ItsOn", self, hSab, "Missions\\act_1\\barfight\\main\\PT_ItsOn")
  for i, v in ipairs(self.tBarNaziDownstairs) do
    local hDude = Util.GetHandleByName(v)
    Combat.SetReactImmediately(hDude, true)
    Combat.SetAlwaysSeeTarget(hDude, true)
  end
  for i, v in ipairs(self.tBarNaziDownCrowd) do
    local tDamageEvent = {
      EventType = "OnDamage",
      Target = Util.GetHandleByName(v),
      EventName = "OnDamage" .. i
    }
    self.eItsOn = Util.CreateEvent(tDamageEvent, "Act_1_BarFight.ItsOn", self, {
      Util.GetHandleByName(v)
    })
    self:AddEvent(self.eItsOn)
    Actor.OverrideCombatAI(Util.GetHandleByName(v), true)
  end
  Combat.SetAlwaysSeeTarget(Util.GetHandleByName(self.sBarNaziStarter), true)
  Combat.SetReactImmediately(Util.GetHandleByName(self.sBarNaziStarter), true)
  Combat.SetTarget(Util.GetHandleByName(self.sBarNaziStarter), hSab)
  Combat.SetCombat(Util.GetHandleByName(self.sBarNaziStarter))
  Combat.DoMeleeMove(Util.GetHandleByName(self.sBarNaziStarter), "mel_NZ_RH_Cross_S", hSab, true)
  self:LockdownActor(Util.GetHandleByName(self.sBarNaziJulesVic))
  Combat.SetAlwaysSeeTarget(Util.GetHandleByName(self.sBarNaziJulesVic), true)
  Combat.SetTarget(Util.GetHandleByName(self.sBarNaziJulesVic), self.hJules)
  Combat.SetTarget(self.hJules, Util.GetHandleByName(self.sBarNaziJulesVic))
  local tTargetList = {
    {
      self.sBarNaziJulesVic,
      1
    },
    {
      self.sBarNaziStarter,
      2
    }
  }
  Combat.SetCombat(self.hJules)
  Combat.SetCombat(Util.GetHandleByName(self.sBarNaziJulesVic))
  self:Tutorial_FirstRound()
  for i, v in ipairs(self.tBarNazis) do
    local hDude = Util.GetHandleByName(v)
    if hDude ~= nil then
      self:KillCount(hDude)
    end
  end
end

function Act_1_BarFight:VeroniqueMad()
  Cin.PlayConversation("A1M2_VeroniqueMad")
end

function Act_1_BarFight:GrabTut()
  local tGrabTutEvent = {
    EventType = "OnStateChange",
    EventName = "tGrabTutEvent",
    Target = hSab
  }
  self.GrabTutEvent = Util.CreateEvent(tGrabTutEvent, "Act_1_BarFight.Tutorial_GrabThrow", self, nil, true)
  self:RegisterEvent(self.GrabTutEvent)
  Util.QueueTutorial("TutorialTip_Text.Melee_Grab_Title", "TutorialTip_Text.Melee_Grab", 2, false, "SGA", true, "SGA", true)
end

function Act_1_BarFight:Tutorial_GrabThrow(a_tVars)
  local a_hState = a_tVars[2]
  if a_hState == Util.GetHandleByName("LapelGrab") then
    Util.KillEvent(self.GrabTutEvent)
    Util.QueueTutorial("TutorialTip_Text.Melee_Grab_Title", "TutorialTip_Text.Melee_Grab_Throw", 2, true, "SGA", true, "SWA", false, "SMF", false, "SMB", false, "STL", false, "STR", false)
  end
end

function Act_1_BarFight:PunchTut()
end

function Act_1_BarFight:SecondWaveDelay()
  Cin.PlayCinematic("CIN_A1BF_2ndWave")
end

function Act_1_BarFight:SecondWave()
  self:PrintDebug("SecondWave!")
  Util.ClearAllPendingTutorials()
  self:FightFight()
  for i, v in ipairs(self.tSeats) do
    AttractionPt.FinishNow(v)
  end
  Squad.Create("Mechanics")
  Squad.SetEnemy("Mechanics", "Wingmen", true)
  if Actor.IsUsingAttrPt(self.hBarNaziVerVic) then
    Actor.CancelAttrPt(self.hBarNaziVerVic)
    Actor.OverrideCombatAI(self.hBarNaziVerVic, false)
  end
  self.SwapBprint(self, nil, self.hBarNaziVerVic, "Melee_NaziGrunt")
  for i, v in ipairs(self.tBarNaziDownCrowd) do
    local hDude = Util.GetHandleByName(v)
    local eWave = Util.CreateEvent({
      EventType = "TimerEvent",
      Time = math.random(0.5, 2)
    }, "Act_1_BarFight.WaveMachine", self, {hDude})
    self:AddEvent(eWave)
  end
  Combat.SetTarget(Util.GetHandleByName(self.tBarNaziDownstairs[4]), self.hJules)
  self.eFailTimer = Util.CreateEvent({EventType = "TimerEvent", Time = 300}, "Act_1_BarFight.LeaveTalk", self, {hDude})
  self:AddEvent(self.eFailTimer)
end

function Act_1_BarFight:FailSafe()
  if self:IsMissionTaskActive("Task_DefendYourself") then
    self:KillTaskByName("Task_DefendYourself")
  end
  if self:IsMissionTaskActive("Task_KillBottom") then
    self:KillTaskByName("Task_KillBottom")
  end
  self:LeaveTalk()
end

function Act_1_BarFight:WaveMachine(a_hDude)
  if a_hDude ~= self.hHeavyDrunk then
    self.SwapBprint(self, nil, a_hDude, "Melee_NaziGrunt")
  end
  Squad.AddMember("Mechanics", a_hDude)
  local tTargetList = {}
  for i, v in ipairs(self.tLessFillingSquad) do
    table.insert(tTargetList, {v, 2})
  end
  for i, v in ipairs(self.tTastesGreatSquad) do
    table.insert(tTargetList, {v, 2})
  end
  table.insert(tTargetList, {hSab, 1})
  local iCoin = math.random(1, 3)
  if iCoin == 1 then
    Combat.SetTarget(a_hDude, self.hJules)
  else
    Combat.SetTarget(a_hDude, hSab)
  end
  Combat.SetCombat(a_hDude)
end

function Act_1_BarFight:KillCount(a_hDude)
  if Object.IsAlive(a_hDude) then
    local tLegoGimliEvent = {EventType = "OnDeath", Target = a_hDude}
    self:AddEvent(Util.CreateEvent(tLegoGimliEvent, "Act_1_BarFight.LegolaGimli", self))
  end
end

function Act_1_BarFight:LegolaGimli(a_tArgs)
  if self.bTooSoon == false and self.bChatterBusy == false and self:IsMissionTaskComplete("Task_DefendYourself") and not self:IsMissionTaskComplete("Task_KillBottom") then
    local bKnockConv = false
    local iFlip = 0
    if a_tArgs[2] == hSab then
      iFlip = math.random(1, 2)
      if iFlip == 1 and #self.tSeanKnockout ~= 0 then
        bKnockConv = true
        self.bTooSoon = true
        self.bChatterBusy = true
        Cin.PlayConversation(self.tSeanKnockout[1], "Act_1_BarFight.ResetChatterBusy", self)
        table.remove(self.tSeanKnockout, 1)
      end
    elseif a_tArgs[2] == self.hJules then
      self:PrintDebug("JULES: I'm a lover AND a fighter")
      iFlip = math.random(1, 2)
      if iFlip == 1 and #self.tJulesKnockout ~= 0 then
        bKnockConv = true
        self.bTooSoon = true
        self.bChatterBusy = true
        Cin.PlayConversation(self.tJulesKnockout[1], "Act_1_BarFight.ResetChatterBusy", self)
        table.remove(self.tJulesKnockout, 1)
      end
    end
    iFlip = math.random(1, 3)
    if iFlip == 1 and bKnockConv == false then
      if #self.tFightChatter ~= 0 then
        local iRandConv = math.random(1, #self.tFightChatter)
        self.bTooSoon = true
        self.bChatterBusy = true
        Cin.PlayConversation(self.tFightChatter[iRandConv], "Act_1_BarFight.ResetChatterBusy", self)
        table.remove(self.tFightChatter, iRandConv)
      else
        self.ResetChatterBusy(self)
      end
    end
    iFlip = math.random(1, 3)
    if iFlip == 1 then
      self:DramaticPause(math.random(1, 4), "Act_1_BarFight.DoppelTaunt")
    end
    self:DramaticPause(4, "Act_1_BarFight.ResetTooSoon")
  end
end

function Act_1_BarFight:ResetTooSoon()
  self.bTooSoon = false
end

function Act_1_BarFight:ResetChatterBusy()
  if self.tSaveInfo.bLeaveDelayed == true then
    Cin.PlayConversation("A1M2_Complete")
  end
  if #self.tDelayedEvents ~= 0 then
    local fFunction = self.tDelayedEvents[1]
    table.remove(self.tDelayedEvents, 1)
    fFunction(self)
  else
    self.bChatterBusy = false
  end
end

function Act_1_BarFight:ChatterCheck(a_function)
  if self.bChatterBusy == true then
    table.insert(self.tDelayedEvents, a_function)
  else
    a_function(self)
  end
end

function Act_1_BarFight:DoppelTaunt()
  local tDudes = {}
  for i, v in ipairs(self.tBarNazis) do
    if Object.IsAlive(Util.GetHandleByName(v)) then
      table.insert(tDudes, Util.GetHandleByName(v))
    end
  end
  if 1 < #tDudes then
    local hDude = tDudes[math.random(1, #tDudes)]
    if hDude ~= nil then
      Cin.PlayConversationWith("A1M2_NaziFightChatter", {hDude})
    end
  end
end

function Act_1_BarFight:ThirdWave()
  self:PrintDebug("ThridWave!")
  local t3rdSequence_1 = {
    {
      "RUNTOOBJECT",
      {
        "Missions\\act_1\\barfight\\main\\LOC_EnterSpot",
        1
      }
    },
    {
      "SETCOMBAT",
      {true}
    },
    {
      "ATTACKTARGET",
      {"Saboteur"}
    }
  }
  local t3rdSequence_2 = {
    {
      "DELAY",
      {2}
    },
    {
      "RUNTOOBJECT",
      {
        "Missions\\act_1\\barfight\\main\\LOC_EnterSpot_2",
        1
      }
    },
    {
      "SETCOMBAT",
      {true}
    },
    {
      "ATTACKTARGET",
      {"Saboteur"}
    }
  }
  local t3rdSequence_3 = {
    {
      "DELAY",
      {5}
    },
    {
      "RUNTOOBJECT",
      {
        "Missions\\act_1\\barfight\\main\\LOC_EnterSpot_3",
        1
      }
    },
    {
      "SETCOMBAT",
      {true}
    },
    {
      "ATTACKTARGET",
      {"Saboteur"}
    }
  }
  local t3rdSequence_4 = {
    {
      "DELAY",
      {8}
    },
    {
      "RUNTOOBJECT",
      {"Saboteur", 1}
    },
    {
      "SETCOMBAT",
      {true}
    },
    {
      "ATTACKTARGET",
      {"Saboteur"}
    }
  }
  for i, v in ipairs(self.tBarNaziUpstairs) do
    Squad.AddMember("Mechanics", Util.GetHandleByName(v))
    Combat.SetReactImmediately(Util.GetHandleByName(v), true)
    self:AddGroup2All(Util.GetHandleByName(v))
    self:KillCount(Util.GetHandleByName(v))
    table.insert(self.tFinalNazis, v)
  end
  ScriptSequence.Run(Util.GetHandleByName(self.tBarNaziUpstairs[1]), t3rdSequence_1)
  ScriptSequence.Run(Util.GetHandleByName(self.tBarNaziUpstairs[2]), t3rdSequence_2)
  ScriptSequence.Run(Util.GetHandleByName(self.tBarNaziUpstairs[3]), t3rdSequence_3)
  ScriptSequence.Run(Util.GetHandleByName(self.tBarNaziUpstairs[4]), t3rdSequence_4)
  self.bTooSoon = true
  self.ChatterCheck(self, Act_1_BarFight.MoreGuys)
end

function Act_1_BarFight:MoreGuys()
  if self.bTooSoon ~= true then
    self.bTooSoon = true
    self:DramaticPause(5, "Act_1_BarFight.ResetTooSoon")
  end
  self.bChatterBusy = true
  Cin.PlayConversation("A1M2_MoreGuys", "Act_1_BarFight.ResetChatterBusy", self)
end

function Act_1_BarFight:BottleDelay()
  self.ChatterCheck(self, Act_1_BarFight.Escalate)
end

function Act_1_BarFight:Escalate()
  Actor.OverrideCombatAI(self.hVeronique, false)
  Combat.SetCombat(self.hVeronique)
  Combat.SetTarget(self.hVeronique, self.hBarNaziVerVic)
  Combat.ThrowGrenade(self.hVeronique)
  Combat.SetLeader(self.hVeronique, self.hVittore, true, 5, 5)
  self:Fraulien()
end

function Act_1_BarFight:FraulienFailCheck(a_tStatus)
  self.ResetChatterBusy(self)
  if a_tStatus[1] == -1 then
    self.Fraulien(self)
  end
end

function Act_1_BarFight:Fraulien()
  Combat.SetTarget(self.hBarNaziVerVic, self.hVittore)
  Combat.SetAlwaysSeeTarget(self.hBarNaziVerVic, true)
  Combat.SetCombat(self.hBarNaziVerVic)
  Actor.OverrideCombatAI(self.hVittore, false)
  Combat.SetTarget(self.hVittore, self.hBarNaziVerVic)
  Combat.SetCombat(self.hVittore)
  local tVersVic = {
    EventType = "OnDeath",
    EventName = "tVersVic",
    Target = self.hBarNaziVerVic
  }
  self.VersVicEvent = Util.CreateEvent(tVersVic, "Act_1_BarFight.SoundTheRetreat", self)
  self:AddEvent(self.VersVicEvent)
end

function Act_1_BarFight:SoundTheRetreat()
  self.bChatterBusy = true
  Cin.PlayConversation("A1M2_GetHerOut", "Act_1_BarFight.ReFight", self)
end

function Act_1_BarFight:BottleFetish()
  self:PrintDebug("BottleFetish!")
  local tDudes = {}
  for i, v in ipairs(self.tBarNazis) do
    if Object.IsAlive(v) and Actor.IsInCombat(v) then
      table.insert(tDudes, v)
    end
  end
  if #tDudes ~= 0 then
    local hDude = tDudes[math.random(1, #tDudes)]
    if hDude ~= nil then
      Combat.SetCombat(self.hVeronique)
      Combat.SetTarget(self.hVeronique, v)
      Combat.ThrowGrenade(self.hVeronique)
    end
  end
  self.eBottleFetish = Util.CreateEvent({
    EventType = "TimerEvent",
    Time = math.random(5, 10)
  }, "Act_1_BarFight.BottleFetish", self, {})
  self:AddEvent(eBottleFetish)
end

function Act_1_BarFight:ReFight()
  self.bChatterBusy = false
  local tVittoreUp = {
    {
      "ISIDLESEQUENCE",
      {true}
    },
    {
      "RUNTOPOINT",
      {
        2624.2,
        204.4,
        -2502.35
      }
    }
  }
  local tVeroniqueUp = {
    {
      "ISIDLESEQUENCE",
      {true}
    },
    {
      "RUNTOOBJECT",
      {
        "Missions\\act_1\\barfight\\main\\LOC_VeroniqueBalcony",
        0
      }
    }
  }
  ScriptSequence.Run(self.hVittore, tVittoreUp)
  ScriptSequence.Run(self.hVeronique, tVeroniqueUp)
end

function Act_1_BarFight:BodyNetSetup(a_hDude)
  EVENT_ActorEntersTrigger("Act_1_BarFight.BodyNet", self, a_hDude, self.sBodyNet, {a_hDude})
end

function Act_1_BarFight:BodyNet(a_hDude)
  Object.Kill(a_hDude)
end

function Act_1_BarFight:FightFight(a_tArgs)
  self:PrintDebug("FightFight!")
  self.bShitNFan = true
  for i, v in ipairs(self.tTastesGreatSquad) do
    EVENT_Timer("Act_1_BarFight.GetUpNow", self, math.random(1, 2), {v})
  end
  for i, v in ipairs(self.tLessFillingSquad) do
    EVENT_Timer("Act_1_BarFight.GetUpNow", self, math.random(1, 2), {v})
  end
  for i, v in ipairs(self.tBarPatrons) do
    EVENT_Timer("Act_1_BarFight.GetUpNow", self, math.random(1, 2), {v})
  end
  Squad.Create("UsSquad")
  for i, v in ipairs(self.tUSSquad) do
    Actor.CancelAttrPt(v)
    Squad.AddMember("UsSquad", v)
    Combat.SetAlwaysSeeTarget(v, true)
    Combat.SetTargetAggressively(v, true)
    Combat.SetCombat(v)
  end
  Squad.Create("ThemSquad")
  for i, v in ipairs(self.tThemSquad) do
    Actor.CancelAttrPt(v)
    Squad.AddMember("ThemSquad", v)
    Combat.SetAlwaysSeeTarget(v, true)
    Combat.SetTargetAggressively(v, true)
    Combat.SetCombat(v)
  end
  Squad.SetEnemy("ThemSquad", "UsSquad")
  for i, v in ipairs(self.tGroupies) do
    self:RunAway(Util.GetHandleByName(v))
  end
end

function Act_1_BarFight:Incomming()
  local tDudes = {}
  for i, v in ipairs(self.tCivFighters) do
    if Object.IsAlive(v) and Actor.IsInCombat(v) then
      table.insert(tDudes, v)
    end
  end
  if #tDudes ~= 0 then
    local hDude = tDudes[math.random(1, #tDudes)]
    if hDude ~= nil then
      for i, v in ipairs(tDudes) do
        if Combat.GetTarget(v) == hDude then
          Actor.SetPanicOnceMode(v, true)
        end
      end
      Combat.ThrowGrenade(hDude)
      local iCoin = math.random(1, 5)
      if iCoin == 1 then
        Cin.PlayConversationWith("A1M2_CivFightChatter", {hDude})
      end
    end
  end
  self:DramaticPause(math.random(3, 5), "Act_1_BarFight.Incomming")
end

function Act_1_BarFight:ThrowBottle(a_hDude)
  if Object.IsAlive(a_hDude) then
    Combat.ThrowGrenade(a_hDude)
  end
end

function Act_1_BarFight:RunAway(a_hDude)
  local tRunAwaySequence = {
    {
      "CANCELATTRPTREQUEST"
    },
    {
      "ISIDLESEQUENCE",
      {true}
    },
    {
      "RUNTOOBJECT",
      {
        "CountrySide\\alsace\\town\\interior\\redox_int\\LOC_RO_Int(2)"
      }
    },
    {
      "USEATTRPT",
      {
        "CountrySide\\alsace\\town\\interior\\redox_int\\UsePT_SpawnCloset_topinside"
      }
    },
    {
      "RUNTOOBJECT",
      {
        "Missions\\act_1\\barfight\\main\\LOC_TopCloset"
      }
    }
  }
  Actor.EnableNeeds(a_hDude, true)
  if Actor.IsUsingAttrPt(a_hDude) then
    Actor.CancelAttrPt(a_hDude)
  end
  ScriptSequence.Run(a_hDude, tRunAwaySequence)
end

function Act_1_BarFight:Upstairs()
  self:PrintDebug("Top Floor")
  self.bUpstairs = true
  Nav.MoveToObject(self.hJules, hSab, 2, true)
  Squad.RemoveMember("Allies", self.hVittore)
  Squad.AddMember("Wingmen", self.hVittore)
  Squad.SetEnemy("Wingmen", "Drivers")
  Saboteur.ShowToolTip("TutorialTip_Text.Melee_Grab")
  for i, v in ipairs(self.tBarNazis) do
    local hDude = Util.GetHandleByName(v)
    if hDude ~= nil then
      local e = Util.CreateEvent({
        EventType = "StreamEvent",
        WaitForGameObject = true,
        Objects = {hDude}
      }, "Act_1_BarFight.BodyNetSetup", self, {hDude})
      self:AddEvent(e)
    end
  end
end

function Act_1_BarFight:Task_EnterRedOx()
  self:CreateTask({
    sName = "Task_EnterRedOx",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "EnterInterior",
    sObjectiveTextID = "A1M2_Text.Task_EnterRedOx",
    tLocators = {
      "CountrySide\\alsace\\town\\interior\\redox_ext\\ext_blip_loc\\LOC_RO_Blip_Ext"
    },
    sInteriorName = "RedOx",
    tOnActivate = {
      {
        HUD.SetGPSTarget,
        {
          Util.GetHandleByName("CountrySide\\alsace\\town\\interior\\redox_ext\\ext_blip_loc\\LOC_RO_Blip_Ext")
        }
      }
    },
    tOnComplete = {
      {
        HUD.ClearGPSTarget,
        {}
      },
      {
        Util.ClearAllPendingTutorials,
        {}
      },
      {
        Act_1_BarFight.Task_GotoBar,
        {self}
      }
    }
  })
end

function Act_1_BarFight:Task_OpenDoor()
  self:CreateTask({
    sName = "Task_OpenDoor",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "USE",
    bNoHUDBlip = true,
    bNoWorldBlip = true,
    tTgtInclude = {
      "CountrySide\\alsace\\town\\interior\\redox_ext\\TeleporterDoorPoint"
    },
    tLocators = {},
    tSMEDNodes = {},
    tOnComplete = {
      {
        Act_1_BarFight.EnterThings,
        {self}
      }
    }
  })
end

function Act_1_BarFight:EnterThings()
  WorldSMEDNodes.UnloadNode("Missions\\act_1\\togermany\\truckaurora", true)
  WorldSMEDNodes.UnloadNode("Missions\\act_1\\togermany\\javier", true)
  if self:IsMissionTaskActive("TASK_Escalator") then
    self:KillTaskByName("TASK_Escalator")
  end
  if self:IsMissionTaskActive("TASK_LostEscalation") then
    self:KillTaskByName("TASK_LostEscalation")
  end
end

function Act_1_BarFight:Task_GotoBar()
  self:CreateTask({
    sName = "Task_GotoBar",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "goto",
    sObjectiveTextID = "",
    tSMEDNodes = {},
    bInteriorTask = true,
    tLocators = {},
    Proximity = 1,
    tDestProximityObj = {
      gsA1BarFight .. "main\\LOC_SeanStart"
    },
    tDeliverObjs = {hSab},
    tOnActivate = {
      {
        Inventory.HolsterWeapons,
        {hSab}
      },
      {
        Act_1_BarFight.LockDoors,
        {self, true}
      },
      {
        self.CineMagic,
        {self}
      }
    },
    tOnComplete = {
      {
        self.Task_EntryCinematic,
        {self}
      }
    }
  })
end

function Act_1_BarFight:Task_DefendYourself()
  self:CreateTask({
    sName = "Task_DefendYourself",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "KILL",
    sObjectiveTextID = "A1M2_Text.Task_DefendYourself",
    tTgtInclude = {
      self.sBarNaziStarter,
      self.sBarNaziJulesVic
    },
    bInteriorTask = true,
    bNoWorldBlip = true,
    tOnActivate = {
      {
        self.HaveIt,
        {self}
      },
      {
        Util.QueueTutorial,
        {
          "TutorialTip_Text.Melee_Punch_Title",
          "TutorialTip_Text.Melee_Punch",
          -1,
          true
        }
      },
      {
        Sound.SetMusicLocale,
        {
          "m_A1M2_Barfight",
          "A1M2_start"
        }
      }
    },
    tOnComplete = {
      {
        self.Task_KillBottom,
        {self}
      }
    }
  })
end

function Act_1_BarFight:Task_KillBottom()
  self:CreateTask({
    sName = "Task_KillBottom",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "KILL",
    sObjectiveTextID = "A1M2_Text.TASK_FinishFight",
    bNoWorldBlip = true,
    bObjCounter = true,
    tTgtInclude = self.tSecondWave,
    tOnActivate = {
      {
        self.SecondWave,
        {self}
      }
    },
    tOnComplete = {
      {
        self.LeaveTalk,
        {self}
      }
    }
  })
end

function Act_1_BarFight:Task_ThirdWave()
  self:CreateTask({
    sName = "Task_ThirdWave",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "KILL",
    sObjectiveTextID = "A1M2_Text.TASK_FinishFight",
    bNoWorldBlip = true,
    tTgtInclude = self.tBarNaziUpstairs,
    bObjCounter = true,
    tSMEDNodes = {},
    tOnActivate = {
      {
        self.ThirdWave,
        {self}
      }
    },
    tOnComplete = {
      {
        self.LeaveTalk,
        {self}
      }
    }
  })
end

function Act_1_BarFight:Tutorial_FirstRound(a_tVars)
  Object.SetInvincible(Util.GetHandleByName(self.sBarNaziStarter), false)
  Squad.Create("Wingmen")
  Squad.AddMember("Wingmen", self.hJules)
  Squad.AddMember("Wingmen", hSab)
  Squad.SetLeader("Wingmen", hSab)
  Squad.FollowLeader("Wingmen")
  Squad.SetRadius("Wingmen", 10)
  Combat.SetSquadAssist(self.hJules, true)
  for i, v in ipairs(self.tBarNaziDownstairs) do
    if Util.GetHandleByName(v) ~= self.hBarNaziVerVic then
      Object.SetInvincible(Util.GetHandleByName(v), false)
    end
  end
end

function Act_1_BarFight:Task_EntryCinematic()
  self:CreateTask({
    sName = "Task_EntryCinematic",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "106_CinA_BarFight",
    tCinematicNodes = {
      "106_cina_barfight"
    },
    sMusicLocale = "A1M2_Barfight",
    tOnActivate = {
      {
        self.SetupBar,
        {self}
      }
    },
    tOnSkipped = {
      {
        self.PatronSit,
        {self}
      }
    },
    tOnComplete = {
      {
        Sound.PlayOwnerlessSoundEvent,
        {
          "Fight_Intensity_01"
        }
      },
      {
        self.Checkpoint1_PreDelay,
        {self}
      }
    }
  })
end

function Act_1_BarFight:Checkpoint1_PreDelay()
  self:DramaticPause(1, "Act_1_BarFight.Checkpoint1")
end

function Act_1_BarFight:Checkpoint1()
  self:PrintDebug("Checkpoint1")
  self.RegisterCheckpoint(self, "Act_1_BarFight.Checkpoint1_Delay", nil, true)
end

function Act_1_BarFight:Checkpoint1_Delay()
  self:DramaticPause(1, "Act_1_BarFight.Checkpoint1_Reset")
end

function Act_1_BarFight:Checkpoint1_Reset()
  Render.FadeScreen(false)
  self:PrintDebug("Checkpoint1")
  self:SetupEvents()
  self:Task_DefendYourself()
  self.bUpstairs = false
  self.bShitNFan = false
  self.bTooSoon = false
  self.bChatterBusy = false
  self.sPathUpstairs = gsA1BarFight .. "main\\PATH_Upstairs"
  self.iPunchcount = 0
  self.bDirectional = false
  self.bSkipped = false
  self.tSecondWave = {}
  self.tSecondWave = {
    gsA1BarFight .. "nazis\\Spore_NZ_DpplzgPit_2",
    gsA1BarFight .. "nazis\\Spore_NZ_DpplzgPit_3",
    gsA1BarFight .. "nazis\\Spore_NZ_DpplzgPit_5",
    gsA1BarFight .. "nazis\\Spore_WM_DrunkHeavy",
    gsA1BarFight .. "nazis\\Spore_NZ_BigMech_1",
    gsA1BarFight .. "nazis\\Spore_NZ_BigMech_2"
  }
end

function Act_1_BarFight:CineMagic()
  self:PrintDebug("CineMagic")
  Sound.SetMusicLocale("Silence")
  Object.PlayerTeleportToLocator(Util.GetHandleByName("Missions\\act_1\\barfight\\main\\LOC_SeanStart"), false)
end

function Act_1_BarFight:TASK_FinalFight()
  self:CreateTask({
    sName = "TASK_FinalFight",
    sTaskType = "SabTaskObjectiveDestroy",
    sObjectiveTextID = "A1M2_Text.TASK_FinishFight",
    sTaskSubType = "Kill",
    bInteriorTask = true,
    tSMEDNodes = {
      gsA1BarFight .. "thirdwave"
    },
    tTgtInclude = self.tBarNazis,
    bObjCounter = true,
    bNoWorldBlip = true,
    tOnActivate = {
      {
        self.ThirdWave,
        {self}
      }
    },
    tOnComplete = {}
  })
end

function Act_1_BarFight:BigMechs()
  self:PrintDebug("BigMechs!")
  Object.SetInvincible(self.hVittore, false)
  local tBigMechsSequence = {
    {
      "RUNTOOBJECT",
      {
        "CountrySide\\alsace\\town\\interior\\redox_int\\LOC_TopEnter",
        1
      }
    },
    {
      "RUNTOOBJECT",
      {
        self.sVittore,
        1
      }
    },
    {
      "SETCOMBAT",
      {true}
    },
    {
      "ATTACKTARGET",
      {
        self.sVittore
      }
    }
  }
  local tBigMechsSequence2 = {
    {
      "DELAY",
      {1}
    },
    {
      "RUNTOOBJECT",
      {
        "CountrySide\\alsace\\town\\interior\\redox_int\\LOC_TopEnter_2",
        1
      }
    },
    {
      "RUNTOOBJECT",
      {
        self.sVittore,
        1
      }
    },
    {
      "SETCOMBAT",
      {true}
    },
    {
      "ATTACKTARGET",
      {
        self.sVittore
      }
    }
  }
  Object.Actuate(Util.GetHandleByName("CountrySide\\alsace\\town\\interior\\redox_int\\MN_RedOx_Door_Top"))
  Squad.AddMember("Drivers", Util.GetHandleByName(self.tBigMechs[1]))
  Squad.AddMember("Drivers", Util.GetHandleByName(self.tBigMechs[2]))
  ScriptSequence.Run(Util.GetHandleByName(self.tBigMechs[1]), tBigMechsSequence, {self})
  ScriptSequence.Run(Util.GetHandleByName(self.tBigMechs[2]), tBigMechsSequence2, {self})
end

function Act_1_BarFight:BigMech2()
  local tBigMechsSequence = {
    {
      "USEATTRPT",
      {
        "CountrySide\\alsace\\town\\interior\\redox_int\\UsePT_SpawnCloset_top"
      }
    },
    {
      "RUNTOOBJECT",
      {
        "CountrySide\\alsace\\town\\interior\\redox_int\\LOC_RO_Int(2)"
      }
    },
    {
      "SETCOMBAT",
      {true}
    },
    {
      "ATTACKTARGET",
      {
        self.sJules
      }
    }
  }
  ScriptSequence.Run(self.tBigMechs[2], tBigMechsSequence)
end

function Act_1_BarFight:KillThem()
  if self:IsMissionTaskActive("Task_DefendYourself") then
    self:KillTaskByName("Task_DefendYourself")
  end
  if self:IsMissionTaskActive("Task_KillBottom") then
    self:KillTaskByName("Task_KillBottom")
  end
  if self:IsMissionTaskActive("Task_ExitRedOx") then
    self:KillTaskByName("Task_ExitRedOx")
  end
  self:LockDoors(true)
  Util.KillEvent(self.eWTFSean)
  Squad.Create("Waves")
  self.hFlameSpawner = Util.GetHandleByName(gsA1BarFight .. "main\\FlameWaves")
  self.hFlameSpawnerTop = Util.GetHandleByName(gsA1BarFight .. "main\\FlameWaves(1)")
  self.eFlameWavesEvent = Util.CreateEvent({
    EventType = "OnSpawn",
    Target = self.hFlameSpawner
  }, "Act_1_BarFight.KillerSpawn", self, nil, true)
  Object.EnableSpawner(self.hFlameSpawner, true)
  self.eFlameWavesTopEvent = Util.CreateEvent({
    EventType = "OnSpawn",
    Target = self.hFlameSpawnerTop
  }, "Act_1_BarFight.KillerSpawnTop", self, nil, true)
  Object.EnableSpawner(self.hFlameSpawnerTop, true)
  Squad.SetLethal("Waves")
  self:AddEvent(self.eFlameWavesEvent)
  self:AddEvent(self.eFlameWavesTopEvent)
  self:DramaticPause(math.random(20, 35), "Act_1_BarFight.SetMostlyDead")
  self.bKillThem = true
end

function Act_1_BarFight:SetMostlyDead()
  EVENT_ActorDamaged("Act_1_BarFight.MostlyDead", self, hSab, nil, false)
end

function Act_1_BarFight:MostlyDead()
  Object.SetHealth(hSab, 1)
  self:DramaticPause(math.random(10, 15), "Act_1_BarFight.SetMostlyDead")
end

function Act_1_BarFight:KillerSpawn(a_tVars)
  self:AddGroup2All(a_tVars[2])
  Squad.AddMember("Waves", a_tVars[2])
  Combat.SetLethalForce(a_tVars[2], true)
  local tKillerSequence = {
    {
      "OVERRIDECOMBATAI",
      {true}
    },
    {
      "RUNTOOBJECT",
      {
        "Missions\\act_1\\barfight\\main\\LOC_EnterSpot"
      }
    },
    {
      "OVERRIDECOMBATAI",
      {false}
    },
    {
      "SETLETHALFORCE",
      {true}
    },
    {
      "ATTACKTARGET",
      {hSab}
    }
  }
  Object.ForceOpen(Util.GetHandleByName("CountrySide\\alsace\\town\\interior\\redox_int\\MN_RedOx_Door_Ent"))
  ScriptSequence.Run(a_tVars[2], tKillerSequence, "")
end

function Act_1_BarFight:KillerSpawnTop(a_tVars)
  self:AddGroup2All(a_tVars[2])
  Squad.AddMember("Waves", a_tVars[2])
  Combat.SetLethalForce(a_tVars[2], true)
  local tKillerSequence = {
    {
      "OVERRIDECOMBATAI",
      {true}
    },
    {
      "RUNTOOBJECT",
      {
        "CountrySide\\alsace\\town\\interior\\redox_int\\LOC_TopEnter"
      }
    },
    {
      "OVERRIDECOMBATAI",
      {false}
    },
    {
      "SETLETHALFORCE",
      {true}
    },
    {
      "ATTACKTARGET",
      {hSab}
    }
  }
  Object.ForceOpen(Util.GetHandleByName("CountrySide\\alsace\\town\\interior\\redox_int\\MN_RedOx_Door_Top"))
  ScriptSequence.Run(a_tVars[2], tKillerSequence)
end

function Act_1_BarFight:DramaticPause(a_nTime, a_sCallbackFunction)
  EVENT_Timer(a_sCallbackFunction, self, a_nTime)
end

function Act_1_BarFight:SwapBprint(a_tVargs, a_hDude, a_sBlueprint)
  if Object.IsAlive(a_hDude) then
    Combat.RequestMeleeBP(a_hDude, a_sBlueprint)
    Actor.OverrideCombatAI(a_hDude, false)
  end
end

function Act_1_BarFight:LeaveTalk()
  Util.KillEvent(self.eFailTimer)
  self:Task_ExitRedOx()
  if self.bChatterBusy then
    self.tSaveInfo.bLeaveDelayed = true
  else
    Cin.PlayConversation("A1M2_Complete")
  end
end

function Act_1_BarFight:JulesBails()
  self.bKillThem = false
  local tEvent = {
    EventType = "OnActorEnter",
    EventName = "UseDoor",
    Target = Util.GetHandleByName("CountrySide\\alsace\\town\\interior\\redox_int\\UsePT_SpawnCloset_inside")
  }
  self:RegisterEvent(Util.CreateEvent(tEvent, "Act_1_BarFight.ExitFade", self))
  local tVnVRunAwaySequenceUp = {
    {
      "ISIDLESEQUENCE",
      {true}
    },
    {
      "DELAY",
      {6}
    },
    {
      "RUNTOOBJECT",
      {
        "CountrySide\\alsace\\town\\interior\\redox_int\\LOC_RO_Int(2)"
      }
    },
    {
      "RUNTOOBJECT",
      {
        "Missions\\act_1\\barfight\\main\\LOC_TopCloset"
      }
    }
  }
  local tVerRunAwaySequenceUp = {
    {
      "ISIDLESEQUENCE",
      {true}
    },
    {
      "RUNTOOBJECT",
      {
        "CountrySide\\alsace\\town\\interior\\redox_int\\LOC_RO_Int(2)"
      }
    },
    {
      "USEATTRPT",
      {
        "CountrySide\\alsace\\town\\interior\\redox_int\\UsePT_SpawnCloset_topinside"
      }
    },
    {
      "RUNTOOBJECT",
      {
        "Missions\\act_1\\barfight\\main\\LOC_TopCloset"
      }
    }
  }
  ScriptSequence.Run(self.hVittore, tVnVRunAwaySequenceUp)
  ScriptSequence.Run(self.hVeronique, tVerRunAwaySequenceUp)
  self:DramaticPause(45, "Act_1_BarFight.KillThem")
end

function Act_1_BarFight:ExitFade()
  Sound.SetMusicLocale("A1M2_Barfight")
  Sound.SetMusicLocale("m_A1M2_Barfight", "Cin_to_107")
  Render.FadeScreen(true, 0)
end

function Act_1_BarFight:Task_ExitRedOx()
  self:CreateTask({
    sName = "Task_ExitRedOx",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "USE",
    bInteriorTask = true,
    sObjectiveTextID = "A1M2_Text.Task_ExitRedOx",
    bBlipLocatorsOnly = true,
    tTgtInclude = {
      "CountrySide\\alsace\\town\\interior\\redox_int\\UsePT_SpawnCloset_inside"
    },
    tLocators = {
      "CountrySide\\alsace\\town\\interior\\redox_int\\LOC_RO_Int"
    },
    tSMEDNodes = {},
    tOnActivate = {
      {
        Act_1_BarFight.JulesBails,
        {self}
      }
    },
    tOnComplete = {
      {
        Act_1_BarFight.Shutdown,
        {self}
      },
      {
        self.UnloadTaskNodes,
        {
          self,
          "Task_GotoBar",
          true
        }
      }
    }
  })
end

function Act_1_BarFight:PrintDebug(a_sMessage)
  if self.DEBUGMODE == true then
    Render.PrintMessage(a_sMessage)
  end
end
