require("Includes\\WRAPPER_Event")
require("Includes\\__UtilFunctions")
require("Managers\\InteriorManager")
if not Zeppelin_Int then
  Zeppelin_Int = {}
end
Zeppelin_Int.sInteriorTableName = "Zeppelin"
Zeppelin_Int.sInterior = "interactive"
Zeppelin_Int.Nodes = {}
setmetatable(Zeppelin_Int, {__index = InteriorManager})

function Zeppelin_Int:OnEnter()
end

function Zeppelin_Int.OnEnterInterior(sLocator)
  local sDierkerNode = "Missions\\soe_1\\zeppelin\\dierker_int"
  local sInteriorPieces = "Missions\\soe_1\\zeppelin\\zeppelininteriorpieces"
  InteriorManager.OnEnterInterior(Zeppelin_Int.sInteriorTableName)
  Zeppelin_Int:LoadInteriorNode()
  Zeppelin_Int:LoadDynamicNode(sDierkerNode)
  Zeppelin_Int:LoadDynamicNode(sInteriorPieces)
  Render.WTFExitActivePortal()
  Sound.ReleaseSoundBank("m_s1m6_inGame_01.bnk")
  Sound.LoadSoundBank("m_s1m6_inGame_02.bnk")
  Suspicion.ResetEscalation()
  Combat.GlobalAllowGrenades(false)
  __UtilFunctions.LoadStaticTag("Flames", true)
  Zeppelin_Int:LoadMinimapImages("MM_Zeppelin")
  Util.EnterInterior("Zeppelin", sLocator)
end

function Zeppelin_Int.OnExitInterior(sLocator)
  InteriorManager.OnExitInterior()
  __UtilFunctions.UnloadStaticTag("Flames", true)
  Util.ExitInterior("Zeppelin", sLocator, true)
  Combat.GlobalAllowGrenades(true)
  Sound.ReleaseSoundBank("m_s1m6_inGame_02.bnk")
end
