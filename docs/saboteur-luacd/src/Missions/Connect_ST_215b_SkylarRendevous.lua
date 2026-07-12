if Connect_ST_215b_SkylarRendevous == nil then
  Connect_ST_215b_SkylarRendevous = SabTaskObjective:Create()
  Connect_ST_215b_SkylarRendevous:Configure({
    TaskCount = 999,
    MCDisplayID = 2,
    tUnlockList = {
      "Note_P4M1",
      "Paris_4_Mission_1"
    },
    sSaveMissionNameID = "MissionNames_Text.ST_215b",
    bDisableMissionTitle = true,
    bAutofireInterior = true,
    sHQStartPoint = _cHQe_CHURCH,
    sStarter = "skylar_lehavrehotel_interior",
    bForceUnloadNodes = true,
    tCinematicNodes = {"crypt_set"},
    tSMEDNodes = {}
  })
end

function Connect_ST_215b_SkylarRendevous:STARTER_Setup()
  if not Util.IsBlockLoaded("LeHavre\\lehavre_hotel_ext\\hoteltriggerpoint.wsd") then
    Util.SpawnEditNode("LeHavre\\lehavre_hotel_ext\\hoteltriggerpoint.wsd")
  end
end

function Connect_ST_215b_SkylarRendevous:MISSION_ONRESET()
  __UtilFunctions.UnloadNode("LeHavre\\lehavre_hotel_ext\\hoteltriggerpoint", true)
  if Util.IsBlockLoaded("LeHavre\\lehavre_hotel_ext\\hoteltriggerpoint.wsd") then
    Util.UnloadEditNode("LeHavre\\lehavre_hotel_ext\\hoteltriggerpoint.wsd", true)
  end
end

function Connect_ST_215b_SkylarRendevous:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
  self.Task_ShowCinematic(self)
end

function Connect_ST_215b_SkylarRendevous:GENERAL_Setup()
  self:AddOnCancelCallback(Connect_ST_215b_SkylarRendevous.OnMissionCancel)
end

function Connect_ST_215b_SkylarRendevous:OnMissionCancel()
end

function Connect_ST_215b_SkylarRendevous:Task_ShowCinematic()
  self:CreateTask({
    sName = "Task_ShowCinematic",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "215b_CinB_Skylar",
    tOnActivate = {},
    tOnComplete = {
      {
        self.CleanupAndFinish,
        {self}
      }
    }
  })
end

function Connect_ST_215b_SkylarRendevous:CleanupAndFinish()
  self:CompleteThisMission()
end
