if not GameTips then
  GameTips = {}
end

function GameTips.Init()
  GameTips.nBlockThreshold = 5
  GameTips.nNotBlocked = 0
  if tutorialmode == nil or tutorialmode == false then
    GameTips.bBlockTipFinished = true
    GameTips.bBulletTipFinished = true
    GameTips.bRunIntoTipFinished = true
    GameTips.bFriendlyFire = true
    GameTips.bSuspicionYellow = true
    GameTips.bSuspicionFlashYellow = true
    GameTips.bSuspicionRed = true
    GameTips.bEscalationLevel1 = true
    GameTips.bEscalationLevel2 = true
    GameTips.bEscalationLevel3 = true
    GameTips.bEscalationLevel4 = true
    GameTips.bEscalationLevel5 = true
    GameTips.bShowTipEscalationLevel1 = false
    GameTips.bShownEscalationTipClear = true
    GameTips.bEscalationNoOneRed = true
    GameTips.bFirstNaziPunch = true
    GameTips.bAlarms = true
    GameTips.bSkipAllTutorials = true
    GameTips.TutorialTutorial = true
  elseif tutorialmode == true then
    GameTips.bBlockTipFinished = false
    GameTips.bBulletTipFinished = false
    GameTips.bRunIntoTipFinished = false
    GameTips.bFriendlyFire = false
    GameTips.bSuspicionYellow = false
    GameTips.bSuspicionFlashYellow = false
    GameTips.bSuspicionRed = false
    GameTips.bEscalationLevel1 = false
    GameTips.bEscalationLevel2 = false
    GameTips.bEscalationLevel3 = false
    GameTips.bEscalationLevel4 = false
    GameTips.bEscalationLevel5 = false
    GameTips.bShowTipEscalationLevel1 = false
    GameTips.bShownEscalationTipClear = false
    GameTips.bEscalationNoOneRed = false
    GameTips.bFirstNaziPunch = false
    GameTips.bAlarms = false
    GameTips.bSkipAllTutorials = false
    GameTips.bTutorialTutorial = true
  end
end

function GameTips.ShowTip(sTip)
  if Actor.IsInVehicle(hSab) == false and GameTips.bSkipAllTutorials == false then
    if GameTips.bTutorialTutorial == false then
      Saboteur.ShowToolTip(Cin.GetLocalizedText("tooltips.Firsttimetip"))
      local tSabSelf = Actor.GetSelf(hSab)
      tSabSelf.sPlayerState = "FirstTimeTutorial"
      GameTips.sFirstTip = sTip
      GameTips.bTutorialTutorial = true
    elseif sTip == "BlockTip" then
      if GameTips.bBlockTipFinished == false then
        GameTips.nNotBlocked = GameTips.nNotBlocked + 1
        if GameTips.nNotBlocked >= GameTips.nBlockThreshold then
          local tSabSelf = Actor.GetSelf(hSab)
          tSabSelf.sPlayerState = "BlockTutorialTips"
          Saboteur.ShowToolTip(Cin.GetLocalizedText("tooltips.Blocktip"))
          Saboteur.ShowCancelTip()
          GameTips.nNotBlocked = 0
          GameTips.nBlockThreshold = GameTips.nBlockThreshold * 3
        end
      end
    elseif sTip == "BulletTip" then
      if GameTips.bBulletTipFinished == false and Object.GetHealth(hSab) < 200 then
        GameTips.bBulletTipFinished = true
        Saboteur.ShowToolTip(Cin.GetLocalizedText("tooltips.Shottip"))
      end
    elseif sTip == "RunIntoTip" then
      if GameTips.bRunIntoTipFinished == false then
        GameTips.bRunIntoTipFinished = true
        Saboteur.ShowToolTip(Cin.GetLocalizedText("tooltips.Falltip"))
      end
    elseif sTip == "FriendlyFireTip" then
      if GameTips.bFriendlyFire == false then
        GameTips.bFriendlyFire = true
        Saboteur.ShowToolTip(Cin.GetLocalizedText("tooltips.Friendlyfiretip"))
      end
    elseif sTip == "SuspicionYellowTip" then
      if GameTips.bSuspicionYellow == false then
        GameTips.bSuspicionYellow = true
        Saboteur.ShowToolTip(Cin.GetLocalizedText("tooltips.Suspicionyellowtip"))
      end
    elseif sTip == "SuspicionYellowFlashTip" then
      if GameTips.bSuspicionFlashYellow == false then
        GameTips.bSuspicionFlashYellow = true
        Saboteur.ShowToolTip(Cin.GetLocalizedText("tooltips.Suspicionyellowflashtip"))
      end
    elseif sTip == "EscalationClear" then
      if GameTips.bShownEscalationTipClear == false then
        GameTips.bShownEscalationTipClear = true
        if 0 < Object.GetHealth(hSab) then
          Saboteur.ShowToolTip(Cin.GetLocalizedText("tooltips.Escalationcleartip"))
        end
      end
    elseif sTip == "EscalationStart" then
      if GameTips.bShowTipEscalationLevel1 == false then
        GameTips.bShowTipEscalationLevel1 = true
        Saboteur.ShowToolTip(Cin.GetLocalizedText("tooltips.Escalationstarttip"))
      end
    elseif sTip == "EscalationNoOneRed" then
      if GameTips.bEscalationNoOneRed == false then
        GameTips.bEscalationNoOneRed = true
        Saboteur.ShowToolTip(Cin.GetLocalizedText("tooltips.Escalationnooneredtip"))
      end
    elseif sTip == "FirstNaziPunch" and GameTips.bFirstNaziPunch == false then
      GameTips.bFirstNaziPunch = true
      Saboteur.ShowToolTip(Cin.GetLocalizedText("tooltips.Firstnazipunchtip"))
    end
  end
end
