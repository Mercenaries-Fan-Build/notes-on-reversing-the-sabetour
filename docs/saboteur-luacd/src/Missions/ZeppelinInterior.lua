if not ZeppelinInterior then
  ZeppelinInterior = {}
end

function ZeppelinInterior.Init()
  local self
  if SOE_Zeppelin then
    self = SOE_Zeppelin
  end
  ZeppelinInterior.sInterior = "LeHavre\\Citadel\\graf_zeppelin\\newzepinterior\\interactive\\"
  ZeppelinInterior.sMission = "Missions\\soe_1\\zeppelin\\"
  Render.HeatShimmerFilter(0.4, 1.5, 1, 0.7)
  EVENT_PlayerEntersTrigger("ZeppelinInterior.Explosion1", self, ZeppelinInterior.sMission .. "zeppelininteriorpieces\\FirstExplosion")
  EVENT_PlayerEntersTrigger("ZeppelinInterior.Explosion2", self, ZeppelinInterior.sMission .. "zeppelininteriorpieces\\FirstExplosion2")
  EVENT_PlayerEntersTrigger("ZeppelinInterior.Explosion3", self, ZeppelinInterior.sMission .. "zeppelininteriorpieces\\FirstExplosion3")
  EVENT_PlayerEntersTrigger("ZeppelinInterior.Explosion4", self, ZeppelinInterior.sMission .. "zeppelininteriorpieces\\FirstExplosion4")
  EVENT_PlayerEntersTrigger("ZeppelinInterior.Explosion4_2", self, ZeppelinInterior.sMission .. "zeppelininteriorpieces\\FirstExplosion4_2")
  EVENT_PlayerEntersTrigger("ZeppelinInterior.Explosion5", self, ZeppelinInterior.sMission .. "zeppelininteriorpieces\\FirstExplosion5")
  EVENT_PlayerEntersTrigger("ZeppelinInterior.Explosion6", self, ZeppelinInterior.sMission .. "zeppelininteriorpieces\\FirstExplosion6")
  EVENT_PlayerEntersTrigger("ZeppelinInterior.Explosion6_1", self, ZeppelinInterior.sMission .. "zeppelininteriorpieces\\FirstExplosion6_1")
  EVENT_PlayerEntersTrigger("ZeppelinInterior.Explosion7", self, ZeppelinInterior.sMission .. "zeppelininteriorpieces\\FirstExplosion7")
  EVENT_PlayerEntersTrigger("ZeppelinInterior.Explosion7_what", self, ZeppelinInterior.sMission .. "zeppelininteriorpieces\\FirstExplosion7_what")
  EVENT_PlayerEntersTrigger("ZeppelinInterior.Explosion7_2", self, ZeppelinInterior.sMission .. "zeppelininteriorpieces\\FirstExplosion7_2")
  EVENT_PlayerEntersTrigger("ZeppelinInterior.Explosion8", self, ZeppelinInterior.sMission .. "zeppelininteriorpieces\\FirstExplosion4_1")
  EVENT_PlayerEntersTrigger("ZeppelinInterior.Test16", self, ZeppelinInterior.sMission .. "zeppelininteriorpieces\\trig_3_1_5")
  EVENT_PlayerEntersTrigger("ZeppelinInterior.Test17", self, ZeppelinInterior.sMission .. "zeppelininteriorpieces\\trig_3_1_6")
  EVENT_PlayerEntersTrigger("ZeppelinInterior.Test18", self, ZeppelinInterior.sMission .. "zeppelininteriorpieces\\trig_3_1_7")
  EVENT_PlayerEntersTrigger("ZeppelinInterior.Test19", self, ZeppelinInterior.sMission .. "zeppelininteriorpieces\\trig_3_1_8")
  EVENT_PlayerEntersTrigger("ZeppelinInterior.Test20", self, ZeppelinInterior.sMission .. "zeppelininteriorpieces\\trig_3_1_9")
end

function ZeppelinInterior.KillTable(tDams)
  for i, Dam in pairs(tDams) do
    local hDam = Util.GetHandleByName(Dam)
    ZeppelinInterior.SaneKill(hDam)
  end
end

function ZeppelinInterior.SaneKill(hHandle)
  if hHandle and type(hHandle) == "userdata" then
    Object.Kill(hHandle)
  end
end

function ZeppelinInterior.FirstExplosion_canisters()
  local x, y, z = Object.GetPosition(Util.GetHandleByName("Saboteur"))
  Render.CameraShakeExplosion(x, y, z, 3, 20, 30)
  local tDams = {
    ZeppelinInterior.sInterior .. "OccMed_GasCannister_Cluster_A(2)\\OccMed_GasCannister_Cluster_A(1)",
    ZeppelinInterior.sInterior .. "OccMed_GasCannister_Cluster_A(3)\\OccMed_GasCannister_Cluster_A(1)",
    ZeppelinInterior.sInterior .. "OccMed_GasCannister_A(12)",
    ZeppelinInterior.sInterior .. "OccMed_GasCannister_A(6)",
    ZeppelinInterior.sInterior .. "OccMed_GasCannister_A(14)"
  }
  ZeppelinInterior.KillTable(tDams)
end

function ZeppelinInterior.Explosion1()
  local x, y, z = Object.GetPosition(Util.GetHandleByName("Saboteur"))
  Render.CameraShakeExplosion(x, y, z, 3, 20, 30)
  local tDams = {
    ZeppelinInterior.sInterior .. "Squib_Zep01",
    ZeppelinInterior.sInterior .. "Barrel_of_boom",
    ZeppelinInterior.sInterior .. "OccMed_GasCannister_Cluster_A",
    ZeppelinInterior.sInterior .. "OccMed_GasCannister_Cluster_A(5)\\OccMed_GasCannister_Cluster_A(1)"
  }
  ZeppelinInterior.KillTable(tDams)
end

function ZeppelinInterior.Explosion2()
  local x, y, z = Object.GetPosition(Util.GetHandleByName("Saboteur"))
  Render.CameraShakeExplosion(x, y, z, 3, 20, 30)
  local hPlat3 = Util.GetHandleByName(ZeppelinInterior.sInterior .. "Squib_Zep01(3)")
  ZeppelinInterior.SaneKill(hPlat3)
  local hPlat4 = Util.GetHandleByName(ZeppelinInterior.sInterior .. "Zep_Platform_X3Z8_C_BASE_noDAM")
  ZeppelinInterior.SaneKill(hPlat4)
  local hPlat5 = Util.GetHandleByName(ZeppelinInterior.sInterior .. "Squib_Zep_noExplod")
  ZeppelinInterior.SaneKill(hPlat5)
end

function ZeppelinInterior.Explosion3()
  local x, y, z = Object.GetPosition(Util.GetHandleByName("Saboteur"))
  Render.CameraShakeExplosion(x, y, z, 3, 20, 30)
  local hPlat3 = Util.GetHandleByName(ZeppelinInterior.sInterior .. "Squib_Zep_Expl_noDam")
  ZeppelinInterior.SaneKill(hPlat3)
end

function ZeppelinInterior.Explosion4()
  local x, y, z = Object.GetPosition(Util.GetHandleByName("Saboteur"))
  Render.CameraShakeExplosion(x, y, z, 3, 20, 30)
  local hPlat3 = Util.GetHandleByName(ZeppelinInterior.sInterior .. "Squib_Zep_Expl_noDamrope")
  ZeppelinInterior.SaneKill(hPlat3)
  local hPlat4 = Util.GetHandleByName(ZeppelinInterior.sInterior .. "Zep_Platform_X3Z4_C_Stopper_noDam(1)")
  ZeppelinInterior.SaneKill(hPlat4)
end

function ZeppelinInterior.Explosion4_2()
  local x, y, z = Object.GetPosition(Util.GetHandleByName("Saboteur"))
  Render.CameraShakeExplosion(x, y, z, 3, 20, 30)
  local hPlat3 = Util.GetHandleByName(ZeppelinInterior.sInterior .. "Squib_Zep_Expl_smallradius(9)")
  ZeppelinInterior.SaneKill(hPlat3)
end

function ZeppelinInterior.Explosion5()
  local x, y, z = Object.GetPosition(Util.GetHandleByName("Saboteur"))
  Render.CameraShakeExplosion(x, y, z, 3, 20, 30)
  local hPlat3 = Util.GetHandleByName(ZeppelinInterior.sInterior .. "Squib_Zep_Expl_smallradius")
  ZeppelinInterior.SaneKill(hPlat3)
  local hPlat4 = Util.GetHandleByName(ZeppelinInterior.sInterior .. "Squib_Zep_Expl_smallradius(1)")
  ZeppelinInterior.SaneKill(hPlat4)
end

function ZeppelinInterior.Explosion6()
  local x, y, z = Object.GetPosition(Util.GetHandleByName("Saboteur"))
  Render.CameraShakeExplosion(x, y, z, 3, 20, 30)
  local hPlat3 = Util.GetHandleByName(ZeppelinInterior.sInterior .. "Squib_Zep_Expl_smallradius(3)")
  ZeppelinInterior.SaneKill(hPlat3)
end

function ZeppelinInterior.Explosion6_1()
  local x, y, z = Object.GetPosition(Util.GetHandleByName("Saboteur"))
  Render.CameraShakeExplosion(x, y, z, 3, 20, 30)
  local hPlat3 = Util.GetHandleByName(ZeppelinInterior.sInterior .. "Squib_Zep_Expl_smallradius(8)")
  ZeppelinInterior.SaneKill(hPlat3)
  local hPlat4 = Util.GetHandleByName(ZeppelinInterior.sInterior .. "Squib_Zep_Expl_smallradius(11)")
  ZeppelinInterior.SaneKill(hPlat4)
end

function ZeppelinInterior.Explosion7()
  local x, y, z = Object.GetPosition(Util.GetHandleByName("Saboteur"))
  Render.CameraShakeExplosion(x, y, z, 3, 20, 30)
  local hPlat3 = Util.GetHandleByName(ZeppelinInterior.sInterior .. "Squib_Zep_Expl(2)")
  ZeppelinInterior.SaneKill(hPlat3)
  local hPlat3 = Util.GetHandleByName(ZeppelinInterior.sInterior .. "Squib_Zep_Expl(9)")
  ZeppelinInterior.SaneKill(hPlat3)
  local hPlat3 = Util.GetHandleByName(ZeppelinInterior.sInterior .. "Squib_Zep_Expl(11)")
  ZeppelinInterior.SaneKill(hPlat3)
  local hPlat3 = Util.GetHandleByName(ZeppelinInterior.sInterior .. "Squib_Zep_Expl(13)")
  ZeppelinInterior.SaneKill(hPlat3)
  local hPlat3 = Util.GetHandleByName(ZeppelinInterior.sInterior .. "Squib_Zep_Expl(16)")
  ZeppelinInterior.SaneKill(hPlat3)
  local hPlat4 = Util.GetHandleByName(ZeppelinInterior.sInterior .. "Squib_Zep_Expl(6)")
  ZeppelinInterior.SaneKill(hPlat4)
  local hPlat5 = Util.GetHandleByName(ZeppelinInterior.sInterior .. "Zep_Platform_X3Z2_O_CNR_DAM(4)")
  ZeppelinInterior.SaneKill(hPlat5)
  local hPlat6 = Util.GetHandleByName(ZeppelinInterior.sInterior .. "Zep_Girder_Debris_D_DAM(7)")
  ZeppelinInterior.SaneKill(hPlat6)
  local hPlat7 = Util.GetHandleByName(ZeppelinInterior.sInterior .. "Zep_Girder_Debris_D_DAM(8)")
  ZeppelinInterior.SaneKill(hPlat7)
  local hPlat8 = Util.GetHandleByName(ZeppelinInterior.sInterior .. "Zep_Girder_X2Y08_C_DAM_NEW01")
  ZeppelinInterior.SaneKill(hPlat8)
  local hPlat9 = Util.GetHandleByName(ZeppelinInterior.sInterior .. "Zep_Platform_X3Z4_C_BASE_DAM(4)")
  ZeppelinInterior.SaneKill(hPlat9)
  local hPlat9 = Util.GetHandleByName(ZeppelinInterior.sInterior .. "Zep_Platform_X3Z4_C_BASE_DAM(5)")
  ZeppelinInterior.SaneKill(hPlat9)
  local hPlat9 = Util.GetHandleByName(ZeppelinInterior.sInterior .. "Zep_Platform_X3Z4_C_BASE_DAM(6)")
  ZeppelinInterior.SaneKill(hPlat9)
end

function ZeppelinInterior.Explosion7_what()
  local x, y, z = Object.GetPosition(Util.GetHandleByName("Saboteur"))
  Render.CameraShakeExplosion(x, y, z, 3, 20, 30)
  local hPlat3 = Util.GetHandleByName(ZeppelinInterior.sInterior .. "Squib_Zep_Expl_noDam_small")
  ZeppelinInterior.SaneKill(hPlat3)
  local hPlat4 = Util.GetHandleByName(ZeppelinInterior.sInterior .. "Zep_AirBag_A_noDam")
  ZeppelinInterior.SaneKill(hPlat4)
end

function ZeppelinInterior.Explosion7_1()
  local x, y, z = Object.GetPosition(Util.GetHandleByName("Saboteur"))
  Render.CameraShakeExplosion(x, y, z, 3, 20, 30)
  local tDams = {
    ZeppelinInterior.sInterior .. "Squib_Zep_Expl(2)",
    ZeppelinInterior.sInterior .. "Zep_Girder_X2Y08_E_DAM(47)",
    ZeppelinInterior.sInterior .. "Zep_Girder_X2Y08_D_DAM(2)",
    ZeppelinInterior.sInterior .. "Squib_Zep_Expl_smallradius(16)",
    ZeppelinInterior.sInterior .. "Squib_Zep_Expl_smallradius(15)"
  }
  ZeppelinInterior.KillTable(tDams)
end

function ZeppelinInterior.Explosion7_2()
  local x, y, z = Object.GetPosition(Util.GetHandleByName("Saboteur"))
  Render.CameraShakeExplosion(x, y, z, 3, 20, 30)
  local tDams = {
    ZeppelinInterior.sInterior .. "Zep_Girder_X2Y08_C_DAM_noDam(2)",
    ZeppelinInterior.sInterior .. "Zep_Girder_X2Y08_C_DAM_noDam",
    ZeppelinInterior.sInterior .. "Zep_Girder_X2Y08_C_DAM_noDam(4)",
    ZeppelinInterior.sInterior .. "Zep_Girder_X2Y08_C_DAM_noDam(5)",
    ZeppelinInterior.sInterior .. "Zep_Girder_X2Y08_C_DAM_noDam(1)",
    ZeppelinInterior.sInterior .. "Zep_Girder_X2Y08_C_DAM_noDam(3)",
    ZeppelinInterior.sInterior .. "Squib_Zep_Expl_smallradius(17)",
    ZeppelinInterior.sInterior .. "Squib_Zep_Expl_smallradius(21)",
    ZeppelinInterior.sInterior .. "Squib_Zep_Expl_smallradius(22)",
    ZeppelinInterior.sInterior .. "Squib_Zep_Expl_smallradius(16)",
    ZeppelinInterior.sInterior .. "Zep_Girder_X2Y08_C_DAM_noDam(8)",
    ZeppelinInterior.sInterior .. "Zep_Girder_X2Y08_C_DAM_noDam(6)",
    ZeppelinInterior.sInterior .. "Zep_Girder_X2Y08_C_DAM_noDam(10)",
    ZeppelinInterior.sInterior .. "Zep_Girder_X2Y08_C_DAM_noDam(9)",
    ZeppelinInterior.sInterior .. "Zep_Girder_X2Y08_C_DAM_noDam(7)",
    ZeppelinInterior.sInterior .. "Zep_Girder_X2Y08_C_DAM_noDam(11)"
  }
  ZeppelinInterior.KillTable(tDams)
end

function ZeppelinInterior.Explosion8()
  local x, y, z = Object.GetPosition(Util.GetHandleByName("Saboteur"))
  Render.CameraShakeExplosion(x, y, z, 3, 20, 30)
  local hPlat3 = Util.GetHandleByName(ZeppelinInterior.sInterior .. "Squib_Zep_Expl_smallradius(13)")
  ZeppelinInterior.SaneKill(hPlat3)
end

function ZeppelinInterior.LargeSequence(sLocation)
  local tCabinFireSequence = {
    {
      "DELAY",
      {0}
    },
    {
      "STARTFX",
      {
        sLocation,
        "0FX_Explosion08_Large"
      },
      "NewBoom1"
    },
    {
      "PLAYSOUND2D",
      {"expl_med"}
    },
    {
      "DELAY",
      {9.5}
    },
    {
      "STOPFX",
      {
        sLocation,
        "0FX_Explosion08_Large"
      },
      "NewBoom1"
    }
  }
end

function ZeppelinInterior.MediumSequence(sLocation)
  local tCabinFireSequence = {
    {
      "DELAY",
      {1}
    },
    {
      "STARTFX",
      {
        sLocation,
        "0FX_Fire01_Medium"
      },
      "NewBoom2"
    }
  }
  DestructionSequence.Run(tCabinFireSequence)
end

function ZeppelinInterior.SmallSequence(sLocation)
  local tCabinFireSequence = {
    {
      "DELAY",
      {0.45}
    },
    {
      "STARTFX",
      {
        sLocation,
        "0FX_Explosion09_Small"
      },
      "NewBoom1"
    },
    {
      "PLAYSOUND2D",
      {"expl_big"}
    },
    {
      "DELAY",
      {9.5}
    },
    {
      "STOPFX",
      {
        sLocation,
        "0FX_Explosion09_Small"
      },
      "NewBoom1"
    }
  }
  DestructionSequence.Run(tCabinFireSequence)
end

function ZeppelinInterior.Test16()
  local hPlat3 = Util.GetHandleByName(ZeppelinInterior.sInterior .. "Zep_AirBag_B_noDam")
  ZeppelinInterior.SaneKill(hPlat3)
  local x, y, z = Object.GetPosition(Util.GetHandleByName("Saboteur"))
  Render.CameraShakeExplosion(x, y, z, 3, 20, 30)
  ZeppelinInterior.MediumSequence(ZeppelinInterior.sMission .. "zeppelininteriorpieces\\exp_newhotnes1(1)")
  ZeppelinInterior.MediumSequence(ZeppelinInterior.sMission .. "zeppelininteriorpieces\\exp_newhotnes1")
end

function ZeppelinInterior.Test17()
  ZeppelinInterior.LargeSequence(ZeppelinInterior.sMission .. "zeppelininteriorpieces\\exp_3_6_10")
  ZeppelinInterior.MediumSequence(ZeppelinInterior.sMission .. "zeppelininteriorpieces\\exp_3_6_20")
  ZeppelinInterior.SmallSequence(ZeppelinInterior.sMission .. "zeppelininteriorpieces\\exp_3_6_30")
end

function ZeppelinInterior.Test18()
  ZeppelinInterior.LargeSequence(ZeppelinInterior.sMission .. "zeppelininteriorpieces\\exp_3_6_10")
  ZeppelinInterior.MediumSequence(ZeppelinInterior.sMission .. "zeppelininteriorpieces\\exp_3_6_20")
  ZeppelinInterior.LargeSequence(ZeppelinInterior.sMission .. "zeppelininteriorpieces\\exp_2_3_210")
  ZeppelinInterior.LargeSequence(ZeppelinInterior.sMission .. "zeppelininteriorpieces\\exp_2_3_220")
  ZeppelinInterior.MediumSequence(ZeppelinInterior.sMission .. "zeppelininteriorpieces\\exp_2_3_230")
end

function ZeppelinInterior.Test19()
  ZeppelinInterior.LargeSequence(ZeppelinInterior.sMission .. "zeppelininteriorpieces\\exp_3_7_10")
  ZeppelinInterior.LargeSequence(ZeppelinInterior.sMission .. "zeppelininteriorpieces\\exp_3_7_20")
  ZeppelinInterior.MediumSequence(ZeppelinInterior.sMission .. "zeppelininteriorpieces\\exp_3_7_30")
  ZeppelinInterior.LargeSequence(ZeppelinInterior.sMission .. "zeppelininteriorpieces\\exp_2_3_210")
  ZeppelinInterior.LargeSequence(ZeppelinInterior.sMission .. "zeppelininteriorpieces\\exp_2_3_220")
end

function ZeppelinInterior.Test20()
  ZeppelinInterior.LargeSequence(ZeppelinInterior.sMission .. "zeppelininteriorpieces\\exp_3_8_10")
  ZeppelinInterior.LargeSequence(ZeppelinInterior.sMission .. "zeppelininteriorpieces\\exp_3_8_20")
  ZeppelinInterior.MediumSequence(ZeppelinInterior.sMission .. "zeppelininteriorpieces\\exp_3_8_30")
  ZeppelinInterior.SmallSequence(ZeppelinInterior.sMission .. "zeppelininteriorpieces\\exp_3_8_40")
  ZeppelinInterior.LargeSequence(ZeppelinInterior.sMission .. "zeppelininteriorpieces\\exp_3_8_50")
  ZeppelinInterior.SmallSequence(ZeppelinInterior.sMission .. "zeppelininteriorpieces\\exp_3_8_50")
  ZeppelinInterior.MediumSequence(ZeppelinInterior.sMission .. "zeppelininteriorpieces\\exp_3_8_70")
  ZeppelinInterior.LargeSequence(ZeppelinInterior.sMission .. "zeppelininteriorpieces\\exp_2_3_310")
  ZeppelinInterior.MediumSequence(ZeppelinInterior.sMission .. "zeppelininteriorpieces\\exp_2_3_310")
  ZeppelinInterior.LargeSequence(ZeppelinInterior.sMission .. "zeppelininteriorpieces\\exp_2_3_320")
  ZeppelinInterior.MediumSequence(ZeppelinInterior.sMission .. "zeppelininteriorpieces\\exp_2_3_320")
  ZeppelinInterior.LargeSequence(ZeppelinInterior.sMission .. "zeppelininteriorpieces\\exp_2_3_330")
  ZeppelinInterior.MediumSequence(ZeppelinInterior.sMission .. "zeppelininteriorpieces\\exp_2_3_330")
  ZeppelinInterior.LargeSequence(ZeppelinInterior.sMission .. "zeppelininteriorpieces\\exp_2_3_340")
  ZeppelinInterior.MediumSequence(ZeppelinInterior.sMission .. "zeppelininteriorpieces\\exp_2_3_340")
  ZeppelinInterior.LargeSequence(ZeppelinInterior.sMission .. "zeppelininteriorpieces\\exp_2_3_350")
  ZeppelinInterior.MediumSequence(ZeppelinInterior.sMission .. "zeppelininteriorpieces\\exp_2_3_350")
  ZeppelinInterior.LargeSequence(ZeppelinInterior.sMission .. "zeppelininteriorpieces\\exp_2_3_360")
  ZeppelinInterior.MediumSequence(ZeppelinInterior.sMission .. "zeppelininteriorpieces\\exp_2_3_360")
  ZeppelinInterior.LargeSequence(ZeppelinInterior.sMission .. "zeppelininteriorpieces\\exp_2_3_370")
  ZeppelinInterior.MediumSequence(ZeppelinInterior.sMission .. "zeppelininteriorpieces\\exp_2_3_370")
  ZeppelinInterior.LargeSequence(ZeppelinInterior.sMission .. "zeppelininteriorpieces\\exp_2_3_380")
  ZeppelinInterior.MediumSequence(ZeppelinInterior.sMission .. "zeppelininteriorpieces\\exp_2_3_380")
  ZeppelinInterior.LargeSequence(ZeppelinInterior.sMission .. "zeppelininteriorpieces\\exp_2_3_390")
  ZeppelinInterior.MediumSequence(ZeppelinInterior.sMission .. "zeppelininteriorpieces\\exp_2_3_390")
end
