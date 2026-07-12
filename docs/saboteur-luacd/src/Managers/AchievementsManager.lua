if AchievementsManager == nil then
  AchievementsManager = {}
end
tAchievementsList = {
  {sName = "BAR_FIGHT"},
  {sName = "ESCAPE"},
  {sName = "ZEPPELIN"},
  {sName = "TRAIN"},
  {
    sName = "RECOVER_AURORA"
  },
  {
    sName = "PRISON_BREAK"
  },
  {sName = "RACE_PARIS"},
  {sName = "DOPPELSEIG"},
  {sName = "DIERKER"},
  {sName = "TOURIST"},
  {sName = "ALL_RACES"},
  {
    sName = "ALL_WEAPONS"
  },
  {sName = "ALL_PERKS"},
  {
    sName = "COLLECT_CONTRA"
  },
  {
    sName = "DESTROY_VEH"
  },
  {
    sName = "DIERKER_CRASH"
  },
  {sName = "EIFFEL"},
  {
    sName = "LIBERATE_ALL_WTF"
  },
  {sName = "NAZI_KILL"},
  {sName = "P1_WTF"},
  {sName = "P2_WTF"},
  {sName = "P3_WTF"},
  {
    sName = "RESISTANCE_BORN"
  },
  {sName = "ROADTRIP"},
  {sName = "SKYLAR_SEX"},
  {sName = "SMOKE"},
  {
    sName = "REACH_PARIS"
  },
  {sName = "KISS_WOMEN"},
  {
    sName = "PERK_SILVER"
  },
  {sName = "PERK_GOLD"},
  {sName = "AFP_ANY"},
  {
    sName = "AFP_EACH_TYPE"
  },
  {sName = "AFP_PARIS1"},
  {sName = "AFP_PARIS2"},
  {sName = "AFP_PARIS3"},
  {sName = "AFP_SAAR"},
  {
    sName = "AFP_LEHAVRE"
  },
  {
    sName = "AFP_COUNTRY"
  },
  {sName = "PIGEON"},
  {sName = "ESCALATION"},
  {
    sName = "DISGUISE_MISSION"
  },
  {
    sName = "DISGUISE_NAZI"
  },
  {
    sName = "EIFFEL_JUMP"
  },
  {sName = "FUEL_DEPOT"},
  {sName = "EXECUTION"}
}

function AchievementsManager.AchievementGrant(sAchievementName)
  for i, tAchievement in ipairs(tAchievementsList) do
    if tAchievement.sName == sAchievementName then
      Util.UnlockAchievement(i - 1)
      break
    end
  end
end
