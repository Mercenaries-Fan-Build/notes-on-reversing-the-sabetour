if not Locator_MissionLauncher then
  Locator_MissionLauncher = {}
end

function Locator_MissionLauncher.OnEnter(hHandle)
end

function Locator_MissionLauncher.SetMission(sMissionName)
  if sMissionName then
    gsmission = sMissionName
  end
end
