if not Human_Null then
  Human_Null = {}
end

function Human_Null:OnEnter()
  if Combat.IsCombatant(self.hController) then
    Suspicion.Enable(self.hController, false)
    Combat.SetRespondToSound(self.hController, false)
    Combat.SetRespondToDeadBodies(self.hController, false)
    Combat.SetRespondToDamage(self.hController, false)
    Combat.SetRespondToEvents(self.hController, false)
    Combat.SetSquadAssist(self.hController, false)
    Combat.SetIdleUseNeeds(self.hController, false)
  end
end

function Human_Null:OnExit()
end
