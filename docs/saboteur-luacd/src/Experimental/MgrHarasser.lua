MgrHarasser = MgrHarasser or {}

function MgrHarasser.Create(mModule, tConfig)
  print("MgrHarasser:Create()")
  self = {}
  setmetatable(self, {__index = mModule})
  self.sHarasser = tConfig.sHarasser
  Util.CreateEvent({
    EventType = "StreamEvent",
    Objects = {
      self.sHarasser
    }
  }, "MgrHarasser.Init", self)
  return self
end

function MgrHarasser:Init()
  print("MgrHarasser:Init()")
  self.uHarasser = Util.FindObjectHandle(self.sHarasser)
  self.tConvo = {
    "...what are you doing in this area?",
    "*stammers*",
    "...so you were...",
    "...but ...but...",
    "...likely story...",
    "...look, I just...",
    "You expect me to believe...",
    "...you can go ask...",
    "...member of the resistance?",
    "No!"
  }
  self.tSeanConvo = {
    "...what are you doing in this area?",
    "I'm out to see the sights.",
    "I have the urge to arrest you.",
    "Too bad. I'm winning this conversation minigame.",
    "Mini... game?",
    "Yes, I'm dazzling you with expertly-timed button presses.",
    "No, you're not.",
    "I'm not?",
    "You're under arrest."
  }
  self.nMaxConvoLines = #self.tConvo
  self.tEvents = {}
  self.bHarasserIsDead = Object.IsDead(self.uHarasser)
  Util.CreateEvent({
    EventType = "DeathEvent",
    ObjectHandle = self.uHarasser
  }, "MgrHarasser.OnHarasserDeath", self)
  self:Reset()
end

function MgrHarasser:Reset(tParams)
  self:PrintDebug(self.uHarasser, "Reset()")
  self.tEnemyParticipants = {}
  self.tFriendlyParticipants = {}
  self.nCurrentConvoLine = 1
  self.bConvoIsActive = false
  self.bEndedInBlood = false
  self.bFirstTargetReachedHarasser = false
  self.eFirstTargetFailsafeEvent = nil
  if self.uAttemptConfrontEvent ~= nil then
    Util.KillEvent(self.uAttemptConfrontEvent)
    self.uAttemptConfrontEvent = nil
  end
  if self.bHarasserIsDead == true then
    print("MgrHarasser:Reset() - Harasser dead, will not continue")
    return
  end
  for k, v in ipairs(self.tEvents) do
    Util.KillEvent(v)
  end
  self.tEvents = {}
  self.uAttemptConfrontEvent = Util.CreateEvent({
    EventType = "TimerEvent",
    Time = math.random(15, 60)
  }, "MgrHarasser.AttemptConfrontation", self)
end

function MgrHarasser:EngageConfrontation()
  if self.bHarasserIsDead == true then
    return
  end
  self:TakeCommandOfChar(self.uHarasser, true)
  if self:IsSaboteur(self:GetFirstEnemy()) == true then
    self:Disperse()
  else
    Render.PrintDialogue(self.uHarasser, "Citizen, halt!", 2)
    Actor.PlayAnimation(self.uHarasser, "nazi_halt_1")
    Actor.ChangeModule(self.uHarasser, "Human_Null")
    Nav.StopMoving(self:GetFirstEnemy())
    Nav.MoveToObject(self:GetFirstEnemy(), self.uHarasser, 1.5, false, "MgrHarasser.EngageInterrogation", self)
    Util.CreateEvent({EventType = "TimerEvent", Time = 30}, "MgrHarasser.CheckFirstTargetFailsafe", self)
  end
end

function MgrHarasser:DecideOutcome()
  if Render.WTFGetStage() == cWTF_LIBERATION then
    self:ThrowDown()
    self.bEndedInBlood = true
  else
    self:Disperse()
  end
end

function MgrHarasser:CalculateParticipants()
  self:PrintDebug(self.uHarasser, "MgrHarasser:CalculateParticipants()!")
  if Render.WTFGetStage() == cWTF_LIBERATION then
    for i = 1, math.random(1) do
      local uCivHero = self:AddEnemyHero()
      if uCivHero ~= nil and self:IsSaboteur(uCivHero) == false then
        self:EngageNewParticipant(uCivHero, false)
        self:PrintDebug(self.uHarasser, "MgrHarasser:CalculateParticipants() -- Civ hero en route!")
      else
        self:PrintDebug(self.uHarasser, "MgrHarasser:CalculateParticipants() -- Couldn't add civ hero!")
      end
    end
  end
end

function MgrHarasser:AttemptConfrontation()
  if self.bHarasserIsDead == true then
    return
  end
  self:PrintDebug(self.uHarasser, "AttemptConfrontation()")
  if self:AddEnemyHero() ~= nil then
    self:EngageConfrontation()
  else
    self:PrintDebug(self.uHarasser, "AttemptConfrontation() -- No targets!")
    self:Reset()
  end
end

function MgrHarasser:EngageSaboteurInterrogation()
  print("MgrHarasser:EngageSaboteurInterrogation()")
  self:Reset()
end

function MgrHarasser:EngageInterrogation()
  self:PrintDebug(self.uHarasser, "Inside EngageInterrogation()")
  if self.bHarasserIsDead == true then
    print("MgrHarasser:EngageInterrogation() - Harasser dead, will not continue")
    return
  end
  if self:GetFirstEnemy() == nil then
    self:Disperse()
    self:PrintDebug(self.uHarasser, "BAD GETFIRSTENEMY()")
    return
  end
  self.bFirstTargetReachedHarasser = true
  Actor.PlayAnimation(self.uHarasser, "nazi_harass_idle")
  if Render.WTFGetStage() > cWTF_OPPRESSION then
    Actor.PlayAnimation(self:GetFirstEnemy(), "civ_cower_idle")
  else
    Actor.PlayAnimation(self:GetFirstEnemy(), "civ_cower_idle")
  end
  self.bConvoIsActive = true
  self:StepConvo()
  self:CalculateParticipants()
  Util.CreateEvent({
    EventType = "TimerEvent",
    Time = math.random(8, 18)
  }, "MgrHarasser.DecideOutcome", self)
end

function MgrHarasser:EngageNewParticipant(uChar, bFriendly)
  self:PrintDebug(self.uHarasser, "EngageNewParticipant()")
  Render.PrintDialogue(uChar, "What's going on over here?!", 2)
  Nav.MoveToObject(uChar, self.uHarasser, 3.5, true, "MgrHarasser.StartArgument", self, {Char = uChar, Animation = "civ_chat1"})
end

function MgrHarasser:StartArgument(tData)
  self:PrintDebug(tData.Char, "StartArgument()")
  Actor.PlayAnimation(tData.Char, tData.Animation)
end

function MgrHarasser:AddFriendlyHero()
  local uHero = self:PickFriendlyParticipant()
  if uHero ~= nil then
    self:PrintDebug(uHero, "AddFriendlyHero() -- I've been picked!")
    self:TakeCommandOfChar(uHero, true)
    return uHero
  else
    return nil
  end
end

function MgrHarasser:AddEnemyHero()
  local uHero = self:PickEnemyParticipant()
  if uHero ~= nil then
    self:PrintDebug(self.uHarasser, "We've found a civilian!")
    self:TakeCommandOfChar(uHero, false)
    return uHero
  else
    return nil
  end
end

function MgrHarasser:GetFirstEnemy()
  if #self.tEnemyParticipants > 0 then
    return self.tEnemyParticipants[1].Handle
  else
    return nil
  end
end

function MgrHarasser:GetAnyStoredFriendly()
  if #self.tFriendlyParticipants > 0 then
    return self.tFriendlyParticipants[math.random(#self.tFriendlyParticipants)].Handle
  else
    return nil
  end
end

function MgrHarasser:GetAnyStoredEnemy()
  if #self.tEnemyParticipants > 0 then
    return self.tEnemyParticipants[math.random(#self.tEnemyParticipants)].Handle
  else
    return nil
  end
end

function MgrHarasser:TakeCommandOfChar(uChar, bFriendly)
  self:PrintDebug(self.uHarasser, "TakeCommandOfChar() -- taking control of " .. Util.GetNameFromHandle(uChar))
  local x, y, z = Object.GetPosition(uChar)
  if Actor.IsUsingAttrPt(uChar) == true then
    Actor.CancelAttrPt(uChar)
  end
  if bFriendly == true then
    local tTempEntry = {
      Handle = uChar,
      sLastModule = Actor.GetCurrentModule(uChar),
      nX = x,
      nY = y,
      nZ = z
    }
    table.insert(self.tFriendlyParticipants, tTempEntry)
    self:PrintDebug(uChar, "Changing module to HUMAN_NULL")
    Actor.ChangeModule(uChar, "Human_Null")
    self:PrintDebug(uChar, "Disabling schedule")
    Actor.EnableSchedule(uChar, false)
    self:PrintDebug(uChar, "Setting flag INVOLVEDINEVENT to TRUE")
    Actor.SetUserFlag(uChar, "InvolvedInEvent", true)
  else
    local tTempEntry = {
      Handle = uChar,
      sLastModule = Actor.GetCurrentModule(uChar),
      nX = x,
      nY = y,
      nZ = z
    }
    table.insert(self.tEnemyParticipants, tTempEntry)
    self:PrintDebug(uChar, "Changing module to HUMAN_NULL")
    Actor.ChangeModule(uChar, "Human_Null")
    self:PrintDebug(uChar, "Disabling schedule")
    Actor.EnableSchedule(uChar, false)
    self:PrintDebug(uChar, "Setting flag INVOLVEDINEVENT to TRUE")
    Actor.SetUserFlag(uChar, "InvolvedInEvent", true)
  end
end

function MgrHarasser:ThrowDown()
  self.bConvoIsActive = false
  for k, v in ipairs(self.tEnemyParticipants) do
    self:MakeCharAggro(v.Handle, true)
  end
  for k, v in ipairs(self.tFriendlyParticipants) do
    self:MakeCharAggro(v.Handle, false)
  end
end

function MgrHarasser:MakeCharAggro(uChar, bTargIsFriendly)
  local uTarget
  if bTargIsFriendly == true then
    uTarget = self:GetAnyStoredFriendly()
  else
    uTarget = self:GetAnyStoredEnemy()
  end
  Nav.StopMoving(uChar)
  Actor.CancelAnimation(uChar)
  Combat.Init(uChar)
  Combat.SetTarget(uChar, uTarget)
  Actor.ChangeModule(uChar, "Civ_Combat")
  local uDeathEvent = Util.CreateEvent({EventType = "DeathEvent", ObjectHandle = uTarget}, "MgrHarasser.ReevaluateTargets", self, {uChar = uChar, bTargIsFriendly = bTargIsFriendly})
  table.insert(self.tEvents, uDeathEvent)
end

function MgrHarasser:ReevaluateTargets(tData)
  self:RemoveDeadParticipants()
  if #self.tFriendlyParticipants == 0 or #self.tEnemyParticipants == 0 then
    self:Disperse()
  else
    self:MakeCharAggro(tData.uChar, tData.bTargIsFriendly)
  end
end

function MgrHarasser:Disperse()
  for k, v in ipairs(self.tEnemyParticipants) do
    if Object.IsDead(v.Handle) == false and self:IsSaboteur(v.Handle) == false then
      self:PrintDebug(v.Handle, "Stopping and canceling animations!")
      Nav.StopMoving(v.Handle)
      Actor.CancelAnimation(v.Handle)
      Combat.Exit(v.Handle)
      self:PrintDebug(v.Handle, "Moving back to original location")
      Nav.MoveToPoint(v.Handle, v.nX, v.nY + 0.5, v.nZ, False, "MgrHarasser.ResumePreviousAction", self, {
        Handle = v.Handle,
        sLastModule = v.sLastModule
      })
    end
  end
  for k, v in ipairs(self.tFriendlyParticipants) do
    if Object.IsDead(v.Handle) == false and self:IsSaboteur(v.Handle) == false then
      self:PrintDebug(v.Handle, "Stopping and canceling animations!")
      Nav.StopMoving(v.Handle)
      Actor.CancelAnimation(v.Handle)
      Combat.Exit(v.Handle)
      self:PrintDebug(v.Handle, "Moving back to original location")
      Nav.MoveToPoint(v.Handle, v.nX, v.nY + 0.5, v.nZ, false, "MgrHarasser.ResumePreviousAction", self, {
        Handle = v.Handle,
        sLastModule = v.sLastModule
      })
    end
  end
  if self.bHarasserIsDead == false and self.bEndedInBlood == false then
    Render.PrintDialogue(self.uHarasser, "You're free to go. I'll be watching you.", 2)
  end
  self:Reset()
end

function MgrHarasser:ResumePreviousAction(tData)
  self:PrintDebug(tData.Handle, "ResumePreviousAction()")
  self:PrintDebug(tData.Handle, "Reenabling schedule")
  Actor.EnableSchedule(tData.Handle, true)
  self:PrintDebug(tData.Handle, "Changing module back to " .. tData.sLastModule)
  Actor.ChangeModule(tData.Handle, tData.sLastModule)
  self:PrintDebug(tData.Handle, "Setting flag INVOLVEDINEVENT to FALSE")
  Actor.SetUserFlag(tData.Handle, "InvolvedInEvent", false)
end

function MgrHarasser:StepConvo()
  if self.bConvoIsActive == false then
    return
  else
    self:PlayConvoLine(self.nCurrentConvoLine)
    self.nCurrentConvoLine = self.nCurrentConvoLine + 1
    if self.nCurrentConvoLine > self.nMaxConvoLines then
      self.bConvoIsActive = false
    end
  end
end

function MgrHarasser:PlayConvoLine(nLine, bSaboteurConvo)
  if self.bConvoIsActive == true then
    if nLine % 2 == 0 then
      Render.PrintDialogue(self:GetFirstEnemy(), self.tConvo[nLine], 2)
      Util.CreateEvent({EventType = "TimerEvent", Time = 2}, "MgrHarasser.StepConvo", self)
    else
      Render.PrintDialogue(self.uHarasser, self.tConvo[nLine], 2)
      Util.CreateEvent({EventType = "TimerEvent", Time = 2}, "MgrHarasser.StepConvo", self)
    end
  end
end

function MgrHarasser:PickEnemyParticipant()
  local tVisibleEnemies = Sensory.GetVisibleEnemyList(self.uHarasser)
  if tVisibleEnemies ~= nil then
    self:PrintDebug(self.uHarasser, "PickEnemyParticipant() -- We have a winner!")
    local uChar = tVisibleEnemies[math.random(#tVisibleEnemies)]
    if Actor.GetUserFlag(uChar, "InvolvedInEvent") == false then
      return uChar
    else
      self:PrintDebug(uChar, "PickEnemyParticipant() -- Participant is busy!")
      return nil
    end
  end
end

function MgrHarasser:PickFriendlyParticipant()
  local tVisibleFriendlies = Sensory.GetVisibleFriendList(self.uHarasser)
  if tVisibleFriendlies ~= nil then
    print("MgrHarasser:PickFriendlyParticipant() -- We have a winner!")
    local uChar = tVisibleFriendlies[math.random(#tVisibleFriendlies)]
    if Actor.GetUserFlag(uChar, "InvolvedInEvent") == false then
      return uChar
    else
      print("MgrHarasser:PickFriendlyParticipant() -- Participant is busy!")
      return nil
    end
  end
end

function MgrHarasser:GoAggro()
  Render.PrintDialogue(self.uHarasser, "Hey! Get back here!", 2)
  self:ThrowDown()
end

function MgrHarasser:IsSaboteur(uChar)
  if uChar == Util.FindObjectHandle("Saboteur") then
    return true
  else
    return false
  end
end

function MgrHarasser:OnHarasserDeath()
  self.bHarasserIsDead = true
  self.bConvoIsActive = false
end

function MgrHarasser:RemoveDeadParticipants()
  local i = 1
  while i <= #self.tEnemyParticipants do
    if Object.IsDead(self.tEnemyParticipants[i].Handle) == true then
      self:PrintDebug(self.tEnemyParticipants[i].Handle, "...is dead! Removing them!")
      table.remove(self.tEnemyParticipants, i)
    else
      self:PrintDebug(self.tEnemyParticipants[i].Handle, "...is not dead! Keeping them!")
      i = i + 1
    end
  end
  local x = 1
  while x <= #self.tFriendlyParticipants do
    if Object.IsDead(self.tFriendlyParticipants[x].Handle) == true then
      self:PrintDebug(self.tFriendlyParticipants[x].Handle, "is dead! Removing them!")
      table.remove(self.tFriendlyParticipants, x)
    else
      self:PrintDebug(self.tFriendlyParticipants[x].Handle, "is not dead! Keeping them!")
      x = x + 1
    end
  end
end

function MgrHarasser:PrintDebug(uChar, sText)
  sCharName = Util.GetNameFromHandle(uChar)
  print("MgrHarasser: " .. sCharName .. " - " .. sText)
end

function MgrHarasser:CheckFirstTargetFailsafe()
  if self.bFirstTargetReachedHarasser == false then
    self:PrintDebug(self.uHarasser, "Target has not made it to me in time! Killing sequence!")
    self:Disperse()
  else
    self:PrintDebug(self.uHarasser, "Target has made it to me in time! Continuing sequence!")
  end
end
