if NaziTest_Idle == nil then
  NaziTest_Idle = {}
end

function NaziTest_Idle.OnEnter(uThisHandle)
  Render.PrintMessage("NaziTest_Idle: OnEnter")
end

function NaziTest_Idle.OnExit(uThisHandle)
  Render.PrintMessage("NaziTest_Idle: OnExit")
end

function NaziTest_Idle.OnFirstEnemy(uThisHandle, uEnemyHandle)
  Render.PrintMessage("NaziTest_Idle: OnFirstEnemy")
  Render.PrintDialogue(uThisHandle, "You're mine now!", 2)
  Combat.Init(uThisHandle)
  Combat.SetTarget(uThisHandle, uEnemyHandle)
  Actor.ChangeModule(uThisHandle, "NaziTest_Combat")
end

function NaziTest_Idle.OnLastEnemy(uThisHandle)
  Render.PrintMessage("NaziTest_Idle: OnLastEnemy")
end
