if P3FP_RadioSabotage == nil then
  P3FP_RadioSabotage = SabTaskObjective:Create()
  gsRadioSabotage = "Missions\\freeplay\\p3\\Mis_Orsay_S_Radio\\"
  P3FP_RadioSabotage:Configure({
    TaskCount = 999,
    tDependencyList = {},
    tUnlockList = {
      "NOTE_P6M1",
      "Paris_6_Mission_1"
    },
    bFreeplay = true,
    sSaveMissionNameID = "MissionNames_Text.P3FP_RadioSabotage",
    sStarter = "bryman_cat_int",
    sConvFile = "P3FP_RadioSabotage_Start",
    tSMEDNodes = {
      gsRadioSabotage .. "usepts",
      gsRadioSabotage .. "nazis"
    },
    tStaticTags = {
      "fp_orsay_s_radio_props",
      "p3fp_radiosabotage_aifences"
    }
  })
end

function P3FP_RadioSabotage:STARTER_Setup()
end

function P3FP_RadioSabotage:Activated()
  SabTaskObjective.Activated(self)
  self:RegisterCheckpoint("P3FP_RadioSabotage.Checkpoint0")
end

function P3FP_RadioSabotage.SetupGamepadListener()
  local self = P3FP_RadioSabotage
  self.tControllerEvent = {
    EventType = "OnButtonPress",
    Target = Handle("Saboteur")
  }
  local eButtonPress = Util.CreateEvent(self.tControllerEvent, "P3FP_RadioSabotage.OnButtonPress", self, {}, true)
  self:RegisterEvent(eButtonPress)
end

function P3FP_RadioSabotage:OnButtonPress(a_tButtonData)
  local self = P3FP_RadioSabotage
  local tButtons = a_tButtonData[1]
  if tButtons.UP == true then
  elseif tButtons.DOWN == true then
  elseif tButtons.X == true then
  elseif tButtons.B == true then
  end
end

function P3FP_RadioSabotage:GENERAL_Setup()
  self.tAttrPts = {
    gsRadioSabotage .. "usepts\\usept1",
    gsRadioSabotage .. "usepts\\usept2",
    gsRadioSabotage .. "usepts\\usept3",
    gsRadioSabotage .. "usepts\\usept4",
    gsRadioSabotage .. "usepts\\usept5",
    gsRadioSabotage .. "usepts\\usept6",
    gsRadioSabotage .. "usepts\\usept7"
  }
  self.tAttrPts.nPoint = 1
  self.tRadioLightPaths = {
    gsRadioSabotage .. "wtf_zone\\FP_Orsay_Radio_Box(1)\\EXT_Amb_Tiny_Red_wtfOn",
    gsRadioSabotage .. "wtf_zone\\FP_Orsay_Radio_Box(2)\\EXT_Amb_Tiny_Red_wtfOn",
    gsRadioSabotage .. "wtf_zone\\FP_Orsay_Radio_Box(3)\\EXT_Amb_Tiny_Red_wtfOn",
    gsRadioSabotage .. "wtf_zone\\FP_Orsay_Radio_Box(4)\\EXT_Amb_Tiny_Red_wtfOn",
    gsRadioSabotage .. "wtf_zone\\FP_Orsay_Radio_Box(5)\\EXT_Amb_Tiny_Red_wtfOn",
    gsRadioSabotage .. "wtf_zone\\FP_Orsay_Radio_Box(6)\\EXT_Amb_Tiny_Red_wtfOn",
    gsRadioSabotage .. "wtf_zone\\FP_Orsay_Radio_Box\\EXT_Amb_Tiny_Red_wtfOn"
  }
  self.tRadios = {
    gsRadioSabotage .. "wtf_zone\\FP_Orsay_Radio_Box(1)\\OccMed_Radio_B",
    gsRadioSabotage .. "wtf_zone\\FP_Orsay_Radio_Box(2)\\OccMed_Radio_B",
    gsRadioSabotage .. "wtf_zone\\FP_Orsay_Radio_Box(3)\\OccMed_Radio_B",
    gsRadioSabotage .. "wtf_zone\\FP_Orsay_Radio_Box(4)\\OccMed_Radio_B",
    gsRadioSabotage .. "wtf_zone\\FP_Orsay_Radio_Box(5)\\OccMed_Radio_B",
    gsRadioSabotage .. "wtf_zone\\FP_Orsay_Radio_Box(6)\\OccMed_Radio_B",
    gsRadioSabotage .. "wtf_zone\\FP_Orsay_Radio_Box\\OccMed_Radio_B"
  }
  self:AddOnCancelCallback(P3FP_RadioSabotage.Reset)
  self:AddOnCompleteCallback(P3FP_RadioSabotage.Reset)
  Sound.LoadSoundBank("m_P3FP_RadioSabotage.bnk")
end

function P3FP_RadioSabotage:Sound1()
  Sound.SetMusicLocale("fp_P3FP_RadioSabotage")
  Sound.SetMusicLocale("fp_P3FP_RadioSabotage", "timerStart")
end

function P3FP_RadioSabotage:Checkpoint0()
  self.GENERAL_Setup(self)
  self.Task_GoToMission(self)
  self.Task_ExitCatacombsHQ(self)
end

function P3FP_RadioSabotage:Task_ExitCatacombsHQ()
  self:CreateTask({
    sName = "Task_ExitCatacombsHQ",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "ExitInterior",
    sInteriorName = "Catacombs",
    bInteriorTask = true,
    bNoGPS = true,
    MarkerHeight = 2.5,
    tLocators = {},
    tOnComplete = {
      {
        self.RegisterCheckpoint,
        {
          self,
          "P3FP_RadioSabotage.Checkpoint1"
        }
      }
    }
  })
end

function P3FP_RadioSabotage:Checkpoint1()
  if not self:IsMissionTaskActive("P3FP_RadioSabotage.Task_GoToMission") then
    self:Task_GoToMission()
  end
  self:RainOn()
  self:SetupEvents()
end

function P3FP_RadioSabotage:SetupEvents()
  for i = 1, 7 do
    EVENT_Stream("P3FP_RadioSabotage.DisableUsePt", self, self.tAttrPts[i], false, {
      self.tAttrPts[i]
    })
  end
end

function P3FP_RadioSabotage:DisableUsePt(a_sAttrPt)
  AttractionPt.EnableUse(Handle(a_sAttrPt), false)
end

function P3FP_RadioSabotage:Task_GoToMission()
  self:CreateTask({
    sName = "Task_GoToMission",
    sTaskType = "SabTaskObjectiveDeliver",
    sObjectiveTextID = "P3FP_RadioSabotage_Text.Task_GoToMission",
    tLocators = {
      "Missions\\freeplay\\p3\\mis_orsay_s_radio\\usepts\\LOC_MissionArea"
    },
    tDestRegion = "Missions\\freeplay\\p3\\mis_orsay_s_radio\\usepts\\REG_MissionArea",
    sTaskSubType = "DELIVER",
    tDeliverObjs = {hSab},
    tOnActivate = {
      {
        HUD.SetEnableAllGPSEdgesInTrigger,
        {
          "Missions\\freeplay\\p3\\mis_orsay_s_radio\\usepts\\PT_GPSavoid",
          false
        }
      }
    },
    tOnComplete = {
      {
        self.RegisterCheckpoint,
        {
          self,
          "P3FP_RadioSabotage.Checkpoint2"
        }
      }
    }
  })
end

function P3FP_RadioSabotage:Checkpoint2()
  EVENT_PlayerEntersTrigger("P3FP_RadioSabotage.DestroyCrates", self, "Missions\\freeplay\\p3\\mis_orsay_s_radio\\usepts\\PT_DestroyCrates", false)
  EVENT_PlayerToActorProximity("P3FP_RadioSabotage.PlayThunderVO", self, "Missions\\freeplay\\p3\\mis_orsay_s_radio\\usepts\\LOC_MissionArea", 15)
  self.bPlayedThunderVO = false
  Util.LoadStaticENTag("fp_orsay_s_radio_pfx", true)
  self:Sound1()
  self:RainOn()
  self:InitLightning()
  self.tAttrPts.nPoint = 0
  self.NextUsePoint(self)
end

function P3FP_RadioSabotage:StartFirstTask()
  AttractionPt.EnableUse(Handle("Missions\\freeplay\\p3\\mis_orsay_s_radio\\usepts\\usept" .. self.tAttrPts.nPoint), false)
end

function P3FP_RadioSabotage:PlayThunderVO()
  Cin.PlayConversation("P3FP_RadioSabotage_Thunder")
end

function P3FP_RadioSabotage:DestroyCrates()
  Object.Kill(Handle("Missions\\freeplay\\p3\\mis_orsay_s_radio\\props\\Crate_GN_Medium_X2YHalf\\Crate"))
  Object.Kill(Handle("Missions\\freeplay\\p3\\mis_orsay_s_radio\\props\\Crate_GN_Large_X3YHalf\\Crate"))
  Object.Kill(Handle("Missions\\freeplay\\p3\\mis_orsay_s_radio\\props\\Crate_GN_Small_X1YHalfA(3)\\Crate"))
  Object.Kill(Handle("Missions\\freeplay\\p3\\mis_orsay_s_radio\\props\\Crate_GN_Small_X1YHalfA(2)\\Crate"))
  Object.Kill(Handle("Missions\\freeplay\\p3\\mis_orsay_s_radio\\props\\Crate_GN_Small_X1YHalfA\\Crate"))
  Object.Kill(Handle("Missions\\freeplay\\p3\\mis_orsay_s_radio\\props\\Crate_GN_Large_X2Y1A\\Crate"))
  Object.Kill(Handle("Missions\\freeplay\\p3\\mis_orsay_s_radio\\props\\Crate_GN_Large_X2Y1B(2)\\Crate"))
  Object.Kill(Handle("Missions\\freeplay\\p3\\mis_orsay_s_radio\\props\\Crate_GN_Large_X2Y1D(2)\\Crate_GN_Large_X2Y1D"))
  Object.Kill(Handle("Missions\\freeplay\\p3\\mis_orsay_s_radio\\props\\Crate_GN_Large_X2Y1B\\Crate"))
  Object.Kill(Handle("Missions\\freeplay\\p3\\mis_orsay_s_radio\\props\\Crate_GN_Small_X1YHalfB\\Crate"))
  Object.Kill(Handle("Missions\\freeplay\\p3\\mis_orsay_s_radio\\props\\Crate_GN_Large_X2Y1D(4)\\Crate_GN_Large_X2Y1D"))
  Object.Kill(Handle("Missions\\freeplay\\p3\\mis_orsay_s_radio\\props\\Crate_GN_Large_X2Y1D\\Crate_GN_Large_X2Y1D"))
end

function P3FP_RadioSabotage:Task_UsePoint()
  self:CreateTask({
    sName = "Task_UsePoint" .. self.tAttrPts.nPoint,
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "USE",
    tTgtInclude = {
      "Missions\\freeplay\\p3\\mis_orsay_s_radio\\usepts\\usept" .. self.tAttrPts.nPoint
    },
    tObjVars = {
      self.tAttrPts.nPoint - 1
    },
    sObjectiveTextID = "P3FP_RadioSabotage_Text.Task_UsePointA",
    tOnActivate = {
      {
        self.NextLight,
        {self}
      },
      {
        self.NextVOEvent,
        {self}
      },
      {
        self.RainOn,
        {self}
      }
    },
    tOnComplete = {
      {
        self.ElectricPFX,
        {self}
      },
      {
        self.NextUsePoint,
        {self}
      }
    }
  })
end

function P3FP_RadioSabotage:ElectricPFX()
  Render.StartFX(Handle("Missions\\freeplay\\p3\\mis_orsay_s_radio\\wtf_zone\\FP_Orsay_Radio_Box(" .. self.tAttrPts.nPoint .. ")\\OccMed_Radio_B"), "0FX_Prop_Radio_Sparks", nil)
end

function P3FP_RadioSabotage:NextVOEvent()
  EVENT_PlayerToActorProximity("P3FP_RadioSabotage.PlayPhoneVO", self, "Missions\\freeplay\\p3\\mis_orsay_s_radio\\usepts\\usept" .. self.tAttrPts.nPoint, 2)
end

function P3FP_RadioSabotage:PlayPhoneVO()
  Cin.PlayConversationWith("P3FP_RadioSabotage_RadioBox", {
    Handle("Missions\\freeplay\\p3\\mis_orsay_s_radio\\usepts\\usept" .. self.tAttrPts.nPoint)
  })
end

function P3FP_RadioSabotage:NextLight()
  self.nThisLight = 600 + self.tAttrPts.nPoint
  self.sThisLight = tostring(600 + self.tAttrPts.nPoint)
  self.sPrevLight = tostring(600 + self.tAttrPts.nPoint - 1)
  Render.ToggleLights(self.sThisLight, true)
  if self.nThisLight <= 610 and self.nThisLight >= 602 then
    Render.ToggleLights(self.sPrevLight, false)
  end
end

function P3FP_RadioSabotage:NextUsePoint()
  if self.tAttrPts.nPoint ~= 0 then
    AttractionPt.EnableUse(Handle("Missions\\freeplay\\p3\\mis_orsay_s_radio\\usepts\\usept" .. self.tAttrPts.nPoint), false)
  end
  if self.tAttrPts.nPoint == 1 then
    self.SetupTimer(self)
  end
  self.tAttrPts.nPoint = self.tAttrPts.nPoint + 1
  AttractionPt.EnableUse(Handle("Missions\\freeplay\\p3\\mis_orsay_s_radio\\usepts\\usept" .. self.tAttrPts.nPoint), true)
  if self.tAttrPts.nPoint == 6 then
    local hFixGenNazi = Handle("Missions\\freeplay\\p3\\mis_orsay_s_radio\\nazis\\Sniper_RF_FixGen")
  end
  if self.tAttrPts.nPoint == 7 then
    EVENT_PlayerEntersTrigger("P3FP_RadioSabotage.DestroyOilBarrel", self, "Missions\\freeplay\\p3\\mis_orsay_s_radio\\usepts\\PT_DestroyBarrels", false)
  end
  if self.tAttrPts.nPoint == 8 then
    self.MissionComplete(self)
  else
    self:Task_UsePoint()
  end
end

function P3FP_RadioSabotage:DestroyOilBarrel()
  Object.Kill(Handle("Missions\\freeplay\\p3\\mis_orsay_s_radio\\props\\OccMed_OilTank_A\\OccMed_OilTank_A"))
  Object.Kill(Handle("Missions\\freeplay\\p3\\mis_orsay_s_radio\\props\\BarrelOBoom_wPallete\\Barrel_of_boom(2)\\OccMed_OilTank_B"))
end

function P3FP_RadioSabotage:SetupTimer()
  self.nTimer = 300
  self.TempObjectiveID = HUD.AddObjective(eOT_HEART, SabTask:GetLocalizedText("GenericObjective_Text.BAR_Time_Remaining"), 2, nil)
  HUD.SetupProgressBar(self.TempObjectiveID, 0, self.nTimer, 300)
  self.nSelfCounter = EVENT_Timer("P3FP_RadioSabotage.UpdateTimerInScript", self, 0)
  HUD.ClearGPSTarget()
  self.SetupFailures(self)
end

function P3FP_RadioSabotage:UpdateTimerInScript()
  self.nTimer = self.nTimer - 10
  HUD.SetProgressBarValue(self.TempObjectiveID, self.nTimer)
  self.nSelfCounter = EVENT_Timer("P3FP_RadioSabotage.UpdateTimerInScript", self, 10)
  if self.nTimer < 101 and not self.bPlayedThunderVO then
    Cin.PlayConversation("P3FP_RadioSabotage_Time")
    self.bPlayedThunderVO = true
  end
end

function P3FP_RadioSabotage:SetupFailures()
  self.hTimerID = EVENT_Timer("P3FP_RadioSabotage.MissionFail", self, 300)
end

function P3FP_RadioSabotage:MissionFail()
  self:MissionTaskFail("P3FP_RadioSabotage_Text.Fail_TimeOut")
end

function P3FP_RadioSabotage:DestroyedRadios()
  self:MissionTaskFail("GenericFail_Text.DESTROYED_Critical_RadioBox")
end

function P3FP_RadioSabotage:MissionComplete()
  EVENT_KillEvent(self.hTimerID)
  HUD.RemoveObjective(self.TempObjectiveID)
  Render.ToggleLights("610", false)
  HUD.SetEnableAllGPSEdgesInTrigger("Missions\\freeplay\\p3\\mis_orsay_s_radio\\usepts\\PT_GPSavoid", true)
  self:CompleteThisMission()
end

function P3FP_RadioSabotage:Reset()
  Sound.ResetMusicLocale()
  Render.Rain(0, 0.1)
  Render.EnableLightning(false)
  HUD.SetEnableAllGPSEdgesInTrigger("Missions\\freeplay\\p3\\mis_orsay_s_radio\\usepts\\PT_GPSavoid", true)
  Sound.ReleaseSoundBank("m_P3FP_RadioSabotage.bnk")
end

function P3FP_RadioSabotage:RainOn()
  Render.Rain(1, 0.5)
end

function P3FP_RadioSabotage:InitLightning()
  Render.EnableLightning(true)
end
