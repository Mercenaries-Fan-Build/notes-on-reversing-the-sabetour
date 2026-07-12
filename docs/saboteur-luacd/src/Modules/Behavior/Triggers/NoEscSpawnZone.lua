NoEscSpawnZone = NoEscSpawnZone or {}
Trigger = Trigger or {}
setmetatable(NoEscSpawnZone, {__index = Trigger})

function NoEscSpawnZone:OnEnter(a_hController)
  Trigger.AddNoEscSpawnZone(a_hController)
end

function NoEscSpawnZone:OnExit(a_hController)
  Trigger.RemoveNoEscSpawnZone(a_hController)
end
