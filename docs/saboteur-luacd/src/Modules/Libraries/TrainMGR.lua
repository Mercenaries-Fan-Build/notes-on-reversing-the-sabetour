if not TrainMGR then
  TrainMGR = {}
end

function TrainMGR.CreateTrain(sID, sRailName, sTrainName)
  if TrainMGR.tTrainStructs == nil then
    TrainMGR.tTrainStructs = {}
  end
  if TrainMGR.tTrainStructs[sID] == nil then
    TrainMGR.tTrainStructs[sID] = {}
  end
  Train.TrainCreate(sRailName, sTrainName)
  TrainMGR.SetupCarriageHandleTable(sID, sRailName)
  Train.TrainRegisterStreamoutCallback(sRailName, "TrainMGR.ReCreateTrainAfterDespawn", nil, {sID})
end

function TrainMGR.ReCreateTrainAfterDespawn(tTrain, tdata, sID)
  TrainMGR.SetupCarriageHandleTable(sID, tdata[1])
  Train.TrainRegisterStreamoutCallback(tdata[1], "TrainMGR.ReCreateTrainAfterDespawn", nil, {sID})
end

function TrainMGR.SetupCarriageHandleTable(sID, sRailName)
  TrainMGR.tTrainStructs[sID] = {}
  TrainMGR.tTrainStructs[sID].PlayerLastLoc = -1
  TrainMGR.nPlayerCarriageLocation = -1
  Train.TrainRegisterCarriageCallback(sRailName, "TrainMGR.AddCarriageHandleToTable", nil, {sID})
  Train.TrainRegisterEngineCallback(sRailName, "TrainMGR.GetEngineHandle", nil, {sID})
  Train.TrainRegisterFinishRegistrationCallback(sRailName, "TrainMGR.RegisterCallbacks", nil, {sID})
end

function TrainMGR:GetEngineHandle(tdata, sID)
  TrainMGR.tTrainStructs[sID].Engine = tdata[2]
end

function TrainMGR:AddCarriageHandleToTable(tdata, sID)
  TrainMGR.tTrainStructs[sID][tdata[2] + 1] = tdata[3]
end

function TrainMGR:RegisterCallbacks(tdata, sID)
  local nSize = #TrainMGR.tTrainStructs[sID]
  for i = 1, nSize do
    Train.TrainRegisterPlayerCarriageTriggerCallback(TrainMGR.tTrainStructs[sID][i], "TrainMGR.UpdatePlayerLocation", self, {i, sID})
  end
end

function TrainMGR:UpdatePlayerLocation(tData, nUserData, sID)
  if TrainMGR.tTrainStructs[sID].PlayerLastLoc ~= nUserData and TrainMGR.tTrainStructs[sID].PlayerLastLoc ~= -1 then
    TrainMGR.ReRegisterCallbacks(self, TrainMGR.tTrainStructs[sID].PlayerLastLoc, sID)
  end
  TrainMGR.tTrainStructs[sID].PlayerLastLoc = nUserData
end

function TrainMGR:ReRegisterCallbacks(nUserData, sID)
  local i = nUserData
  Train.TrainRegisterPlayerCarriageTriggerCallback(TrainMGR.tTrainStructs[sID][i], "TrainMGR.UpdatePlayerLocation", self, {i, sID})
end
