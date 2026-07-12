if not AttractionPt_Alarm then
  AttractionPt_Alarm = {}
  if not AttractionPt then
  end
end
setmetatable(AttractionPt_Alarm, {__index = AttractionPt})

function AttractionPt_Alarm:OnEnter()
  AttractionPt_Alarm.PrintToConsole(self, "Configuring...")
  self.bAlarmIsCut = self.SMEDTable.bAlarmIsCut
  self.bAlarmIsCuttable = self.SMEDTable.bIsCuttable
  self.nAlarmTime = self.SMEDTable.fAlarmClaxonTime
  AttractionPt_Alarm.PrintToConsole(self, "Configuration successful!")
end

function AttractionPt_Alarm:OnActorComplete(actorHandle, nState)
  AttractionPt_Alarm.PrintToConsole(self, "Alarm has been used by " .. Util.GetNameFromHandle(actorHandle))
  if actorHandle == Util.GetHandleByName("Saboteur") and self.bAlarmIsCuttable == true then
    if self.bAlarmIsCut == false then
      self.bAlarmIsCut = true
      AttractionPt_Alarm.PrintToConsole(self, "Alarm has been cut")
      Render.PrintDialogue(actorHandle, "I've cut the alarm", 5)
    else
      AttractionPt_Alarm.PrintToConsole(self, "Alarm has already been cut, nothing to do")
      Render.PrintDialogue(actorHandle, "I've already cut the alarm.", 5)
    end
  elseif self.bAlarmIsCut == true then
    AttractionPt_Alarm.PrintToConsole(self, "Human (" .. Util.GetNameFromHandle(actorHandle) .. ") has attempted to use a cut alarm")
    Render.PrintDialogue(actorHandle, "Oh shit! The alarm has been cut!", 5)
    AttractionPt.EnableBroadcast(self.hController, false)
  else
    AttractionPt_Alarm.DisableAlarm(self, self.hController)
    Util.CreateEvent({
      EventType = "TimerEvent",
      Time = self.nAlarmTime
    }, "AttractionPt_Alarm.EnableAlarm", self, {
      self.hController
    })
    Util.BroadcastFunction(self.hController, 50, "OnHeardAlarm", {
      self.hController,
      actorHandle
    })
    Render.PrintMessage("WEEE-OOO! WEEE-OOO!")
    AttractionPt_Alarm.PrintToConsole(self, "Human (" .. Util.GetNameFromHandle(actorHandle) .. ") activated the alarm")
  end
end

function AttractionPt_Alarm:OnActorIdleBegin(actorHandle, nState)
end

function AttractionPt_Alarm:DisableAlarm(a_hAttrPt)
  AttractionPt_Alarm.PrintToConsole(self, "Alarm DISABLED")
  AttractionPt.EnableBroadcast(a_hAttrPt, false)
  Object.Blip(a_hAttrPt, true)
end

function AttractionPt_Alarm:EnableAlarm(a_hAttrPt)
  AttractionPt_Alarm.PrintToConsole(self, "Alarm ENABLED")
  AttractionPt.EnableBroadcast(a_hAttrPt, true)
  Object.Blip(a_hAttrPt, false)
end

function AttractionPt_Alarm:PrintToConsole(a_sMessageString)
  print("::: ALARM (" .. Util.GetNameFromHandle(self.hController) .. "): " .. a_sMessageString)
end
