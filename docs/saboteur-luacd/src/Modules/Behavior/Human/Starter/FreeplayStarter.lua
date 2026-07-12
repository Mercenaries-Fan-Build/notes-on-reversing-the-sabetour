FreeplayStarter = FreeplayStarter or {}

function FreeplayStarter:OnEnter()
  AttractionPt.Create("MissionStarterAttrPt", 0, 0, 0, 180, self.hController, nil, "FreeplayStarter.OnAttractionPtLoaded", self, {})
end

function FreeplayStarter:OnAttractionPtLoaded(a_tData)
  local hAttrPt = a_tData[1]
  local tEvent = {
    EventType = "OnActorComplete",
    Target = hAttrPt
  }
  Util.CreateEvent(tEvent, "FreeplayStarter.OnPlayerInteracts", self, {}, true)
end

function FreeplayStarter:OnPlayerInteracts(a_tData)
  local hAttrPt = a_tData[1]
  local hUser = a_tData[2]
  local hSab = Util.GetHandleByName("Saboteur")
  local nTagCount = Inventory.GetCountOfType(hSab, "NaziOfficerTag")
  HUDHY.PrintNumber1(5)
  if 0 < nTagCount then
    if nTagCount < 5 then
      Saboteur.ShowDialogue("dialogue_officertags")
    elseif tSabSelf.bUnlockedBackupStrike == false then
      Saboteur.ShowDialogue("dialogue_officertags_hastags", "strike_earned_backup")
      local tSabSelf = Tips.GetSelf("Saboteur")
      tSabSelf.bUnlockedBackupStrike = true
    end
  else
    Saboteur.ShowDialogue("dialogue_officertags")
  end
end

function FreeplayStarter.OnPaperCheckComplete(_, a_tResponse, a_hActor)
  Combat.SetQuestioningState(a_hActor, a_tResponse[1])
end
