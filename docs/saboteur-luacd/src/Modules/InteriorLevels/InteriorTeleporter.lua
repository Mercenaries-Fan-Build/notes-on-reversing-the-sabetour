if not InteriorTeleporter then
  InteriorTeleporter = {}
end

function InteriorTeleporter:OnEnter()
end

function InteriorTeleporter.Main(tInteriorNodes, sScript, sLocator, bInterior, fFadeOutTime)
  Util.Assert(false, "InteriorTeleporter.Main should no longer be getting called please see CFrench for all your interior teleporting needs, thank you")
  do return end
  if bInterior then
    InteriorManager.InteriorScriptEnter(sScript, sLocator)
  end
  if not bInterior then
    InteriorManager.InteriorScriptExit(sScript, sLocator)
  end
end
