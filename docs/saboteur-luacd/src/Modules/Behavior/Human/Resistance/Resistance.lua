require("Modules\\Behavior\\Human\\Nazi\\Soldier")
Resistance = Resistance or {}
setmetatable(Resistance, {__index = Soldier})

function Resistance:OnEnter()
  Resistance.SetSquad(self)
  Soldier.ConfigureOptions(self)
end

function Resistance:SetSquad()
  Squad.Create("Resistance")
  Squad.AddMember("Resistance", self.hController)
end

function Resistance:OnExit()
  ScriptSequence.Kill(self.hController)
end
