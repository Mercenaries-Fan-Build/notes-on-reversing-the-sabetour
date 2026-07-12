if oGameMaster == nil then
  oGameMaster = {}
end
if Main_Saboteur_Game == nil then
  Main_Saboteur_Game = {}
end

function Main_Saboteur_Game.OnEnter(thisHandle)
end

function Main_Saboteur_Game.CreateGame()
  oGameMaster = SabTaskGameMaster:Create({})
  Main_Saboteur_Game.init_Setup(oGameMaster)
  Main_Saboteur_Game.StartGame(oGameMaster)
end

function Main_Saboteur_Game.init_Setup(o)
  if not gsmission or gsmission == "" then
    if Util.IsLoadingFrance() then
      gsmission = {}
    elseif _DEBUG_ACT2 then
      gsmission = {
        "Paris_1_Mission_1"
      }
    else
      gsmission = {}
    end
  else
    print("DEBUG MODE -- Main_Saboteur_Game v1.5")
    __gDEBUG = true
    __gDEBUG_REWARDS = true
  end
  GenerateDebugList(gtMissionsFile)
  gtMissionsFile = nil
  Main_Saboteur_Game.init_Setup = nil
end

function Main_Saboteur_Game.StartGame(o)
  o:Setup()
  o:UnlockPotentialMissions(gsmission)
  o:BuildOpenMissionList()
end
