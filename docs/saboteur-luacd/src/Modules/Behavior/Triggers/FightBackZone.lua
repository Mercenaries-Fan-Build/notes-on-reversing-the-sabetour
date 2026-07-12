FightBackZone = FightBackZone or {}
Trigger = Trigger or {}
setmetatable(FightBackZone, {__index = Trigger})

function FightBackZone.OnEnter(_, a_hTrigger)
  Util.EnableRoadsInRegion(false, a_hTrigger)
end

function FightBackZone.OnExit(_, a_hTrigger)
  Util.EnableRoadsInRegion(true, a_hTrigger)
end
