if NaziTest_Combat == nil then
  NaziTest_Combat = {}
end

function NaziTest_Combat.OnEnter(uThisHandle)
  Render.PrintMessage("NaziTest_Combat: OnEnter")
  local bCoverFound = Combat.TakeCover(uThisHandle)
  if not bCoverFound then
    Combat.DoRandomRangedMovement(uThisHandle)
  end
end

function NaziTest_Combat.OnExit(uThisHandle)
  Render.PrintMessage("NaziTest_Combat: OnExit")
end

function NaziTest_Combat.OnFirstEnemy(uThisHandle, uEnemyHandle)
  Render.PrintMessage("NaziTest_Combat: OnFirstEnemy")
end

function NaziTest_Combat.OnLastEnemy(uThisHandle)
  Render.PrintMessage("NaziTest_Combat: OnLastEnemy")
  Actor.ChangeModule(uThisHandle, "NaziTest_Idle")
end

function NaziTest_Combat.EvaluateLostTarget(tParams)
  if tParams.Handle ~= nil and Object.IsDead(tParams.Handle) ~= true and Sensory.GetVisibleEnemyList(tParams.Handle) == nil then
    Render.PrintDialogue(tParams.Handle, "I've lost my target!", 2)
    Combat.Exit(tParams.Handle)
    Actor.ChangeModule(tParams.Handle, "NaziTest_Idle")
  end
end
