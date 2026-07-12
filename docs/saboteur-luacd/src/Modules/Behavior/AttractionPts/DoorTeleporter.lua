if not DoorTeleporter then
  DoorTeleporter = {}
end
setmetatable(DoorTeleporter, {__index = AttractionPt})
require("Includes\\WRAPPER_Event")

function DoorTeleporter:OnEnter()
  if self.SMEDTable.InstaProximity then
    EVENT_Stream("DoorTeleporter.SabLoaded", self, "Saboteur", true)
  end
end

function DoorTeleporter:SabLoaded()
  print("insta prox teleporter ", self.hController, " ", self.SMEDTable.ProximityDistance)
  self._eProxEvent = EVENT_PlayerToActorProximity("DoorTeleporter.OnActorEnter", self, self.hController, self.SMEDTable.ProximityDistance, {})
end

function DoorTeleporter:OnExit()
  if self._eProxEvent then
    Util.KillEvent(self._eProxEvent)
  end
  if self._eNegProxEvent then
    Util.KillEvent(self._eNegProxEvent)
  end
  if self._eResetTimer then
    Util.KillEvent(self._eResetTimer)
  end
end

function DoorTeleporter:OnActorEnter(actorHandle, nState)
  local fadeout = self.SMEDTable.FadeOutTime or 0
  local sScript = self.SMEDTable.SetupScript
  if not sScript then
    return
  end
  local interiorname = Util.GetInteriorNameByScript(sScript)
  if Util.IsInteriorEnabled(interiorname) then
  end
  self.TotalNodesToLoad = 0
  self.LoadedNodes = 0
  local sLoadInScript = self.SMEDTable.SetupScript
  local sLoadOutScript = self.SMEDTable.SetupScript
  local interiorname = Util.GetInteriorNameByScript(self.SMEDTable.SetupScript)
  if not Util.IsInteriorEnabled(interiorname) then
    Render.FadeTo(0, 0, 0, 0, 0)
    return
  end
  if self.SMEDTable.InteriorNodes and self.SMEDTable.InteriorNodes[1] ~= "NONE" and self.SMEDTable.LoadingIntoInterior then
    Render.FadeTo(0, 0, 0, 0, 0)
    return
  elseif sLoadInScript and self.SMEDTable.LoadingIntoInterior then
    local sDoorLocator = self.SMEDTable.DoorLocator
    if IsMissionActive("Connect_A3_M1b_ReturnToBelle") and sLoadInScript == "Belle_Interior" then
      print("WARNING: Cfrench is overriding loading into the normal belle with loading into destroyed belle inside of DoorTeleporter.lua")
      sLoadInScript = "Belle_Interior_Destroyed"
      sDoorLocator = "PARIS\\area01\\belledenuit\\interior\\int_belledestoyed\\LOC_Int_Tele1"
    end
    if IsMissionOpen("Connect_ST_215b_SkylarRendevous") and sLoadInScript == "LeHavreHotel_Interior" and oGameMaster.oActiveGameplayMission then
      print("WARNING: Cfrench is blocking loading into lh hotel with church hotel shenanigans DoorTeleporter.lua")
      return
    end
    if IsMissionOpen("Connect_ST_215b_SkylarRendevous") and sLoadInScript == "LeHavreHotel_Interior" then
      print("WARNING: Cfrench is overriding loading into lh hotel with church hotel shenanigans DoorTeleporter.lua")
      sLoadInScript = "LeHavreHQ_Interior"
    end
    InteriorManager.InteriorScriptEnter(sLoadInScript, sDoorLocator)
    if self.SMEDTable.InstaProximity then
      self._eProxEvent = EVENT_PlayerToActorProximityNegated("DoorTeleporter.SabLoaded", self, self.hController, self.SMEDTable.ProximityDistance + 5, {})
    end
    return
  end
  if self.SMEDTable.UnloadInteriorNodes and self.SMEDTable.UnloadInteriorNodes[1] ~= "NONE" and not self.SMEDTable.LoadingIntoInterior then
    Render.FadeTo(0, 0, 0, 0, 0)
    return
  elseif sLoadOutScript and not self.SMEDTable.LoadingIntoInterior then
    InteriorManager.InteriorScriptExit(sLoadOutScript, self.SMEDTable.DoorLocator)
    return
  end
  Render.FadeTo(0, 0, 0, 0, 0)
end

function DoorTeleporter:OnActorIdleBegin(actorHandle, nState)
end

function DoorTeleporter:OnActorOutOfBegin(actorHandle, nState)
end

function DoorTeleporter:OnActorComplete(actorHandle, nState)
end
