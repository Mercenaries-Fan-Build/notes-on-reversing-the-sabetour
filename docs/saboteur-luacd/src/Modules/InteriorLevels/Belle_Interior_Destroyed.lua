require("Includes\\WRAPPER_Event")
require("Includes\\__UtilFunctions")
require("Managers\\InteriorManager")
if not Belle_Interior_Destroyed then
  Belle_Interior_Destroyed = {}
end
Belle_Interior_Destroyed.sInteriorTableName = "Belle_Destroyed"
Belle_Interior_Destroyed.sInterior = "int_belledestoyed"
Belle_Interior_Destroyed.Nodes = {}
setmetatable(Belle_Interior_Destroyed, {__index = InteriorManager})

function Belle_Interior_Destroyed:OnEnter()
end

function Belle_Interior_Destroyed.OnEnterInterior(sLocator)
  local tSabSelf = Actor.GetSelf(hSab)
  if tSabSelf and tSabSelf.bInInterior == false then
    DisableHQAbilities(true)
  end
  InteriorManager.OnEnterInterior(Belle_Interior_Destroyed.sInteriorTableName)
  Belle_Interior_Destroyed.Nodes = {}
  if sLocator == "PARIS\\area01\\belledenuit\\interior\\hq_int\\LOC_Belle_int_Two" then
    Render.WTFSetOverrideBlueprint("WillToFight_HQ_Belle2")
  elseif sLocator == "PARIS\\area01\\belledenuit\\interior\\hq_int\\LOC_Belle_int" then
    Render.WTFSetOverrideBlueprint("WillToFight_BelleDeNuit_High")
    Render.WTFSetOverrideBlueprint("WillToFight_BelleDeNuit_High")
    Util.Assert(false, "Belle Interior: we are defaulting to WillToFight_BelleDeNuit_High, is this what you want?")
  else
    Render.WTFSetOverrideBlueprint("WillToFight_BelleDeNuit_High")
  end
  Suspicion.EnableGlobal(false)
  Suspicion.ResetEscalation(false)
  Belle_Interior_Destroyed:LoadInteriorNode()
  local bDisableFadeIn = true
  Belle_Interior_Destroyed:LoadWaitingInteriorStarters()
  Sound.ReleaseSoundBank("Explosions.bnk")
  Belle_Interior_Destroyed:LoadMinimapImages("MM_Belle")
  Util.EnableSuperSpores(false)
  Render.EnableHumanHalos(false)
  Sound.SetMusicLocale("Belle_De_Nuit")
  Util.EnterInterior("Belle_Destroyed", sLocator, bDisableFadeIn)
end

function Belle_Interior_Destroyed.OnExitInterior(sLocator)
  InteriorManager.OnExitInterior()
  Suspicion.EnableGlobal(true)
  Util.EnableSuperSpores(true)
  DisableHQAbilities(false)
  Sound.SetMusicLocale("Default")
  InteriorManager.ClearOverrideBluePrint()
  Sound.LoadSoundBank("Explosions.bnk")
  Belle_Interior_Destroyed:UnloadWaitingInteriorStarters()
  Render.EnableHumanHalos(true)
  Actor.SurgeonGeneral(false)
  local bDisableFadeIn = false
  Util.ExitInterior("Belle_Destroyed", sLocator, bDisableFadeIn)
end
