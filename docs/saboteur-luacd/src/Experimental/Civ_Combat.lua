if Civ_Combat == nil then
  Civ_Combat = {}
end

function Civ_Combat.OnEnter(uThisHandle)
  print("Civ_Combat: OnEnter")
end

function Civ_Combat.OnExit(uThisHandle)
  print("Civ_Combat: OnExit")
end

function Civ_Combat.OnFirstEnemy(uThisHandle, uEnemyHandle)
  print("Civ_Combat: OnFirstEnemy")
end

function Civ_Combat.OnLastEnemy(uThisHandle)
  print("Civ_Combat: OnLastEnemy")
end
