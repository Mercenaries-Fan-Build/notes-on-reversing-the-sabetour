require("Includes\\WRAPPER_Event")
require("Includes\\__UtilFunctions")
require("Managers\\InteriorManager")
if not RedOx_Interior then
  RedOx_Interior = {}
end
RedOx_Interior.sInteriorTableName = "RedOx"
RedOx_Interior.sInterior = "RedOx_int"
RedOx_Interior.Nodes = {}
setmetatable(RedOx_Interior, {__index = InteriorManager})

function RedOx_Interior:OnEnter()
end

function RedOx_Interior.OnEnterInterior(sLocator)
  Util.LoadAnimGroup("red_ox")
  InteriorManager.OnEnterInterior(RedOx_Interior.sInteriorTableName)
  Suspicion.EnableGlobal(false)
  Suspicion.ResetMeter()
  RedOx_Interior:LoadInteriorNode()
  RedOx_Interior:LoadWaitingInteriorStarters()
  local bDisableFadeIn = false
  if IsMissionActive("Act_1_BarFight") then
    RedOx_Interior:LoadDynamicNode("Missions\\act_1\\barfight\\nazis", true)
    RedOx_Interior:LoadDynamicNode("Missions\\act_1\\barfight\\patrons")
    bDisableFadeIn = true
  end
  RedOx_Interior:LoadMinimapImages("MM_RedOx")
  Util.EnterInterior("RedOx", sLocator, bDisableFadeIn)
end

function RedOx_Interior.OnExitInterior(sLocator)
  Util.UnloadAnimGroup("red_ox")
  local bDisableFadeIn = false
  local bDisableSuperSpores = false
  local bDisableFadeOut = false
  if IsMissionActive("Act_1_Mission_2B") then
    print("RedOx_Interior.OnExitInterior ,Act_1_Mission_2B")
    bDisableFadeIn = true
    bDisableSuperSpores = true
  end
  InteriorManager.OnExitInterior(bDisableSuperSpores)
  Suspicion.EnableGlobal(true)
  RedOx_Interior:UnloadWaitingInteriorStarters()
  Util.ExitInterior("RedOx", sLocator, bDisableFadeIn, bDisableFadeOut)
end
