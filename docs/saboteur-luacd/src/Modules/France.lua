France = {}

function France.OnEnter(thisHandle)
  require("Missions\\GAMESTART")
  France.Init(thisHandle)
end

function France:Init()
  Util.NewMission("AmbientRubberStamp", "AmbientRubberStamp")
end

function France:SetupZeppelin()
end
