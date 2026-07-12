if NaziGeneralBase01_WE == nil then
  NaziGeneralBase01_WE = SabTaskObjective:Create()
  gsNaziBase1 = "Missions\\Paris_1\\Mission_4\\"
  NaziGeneralBase01_WE:Configure({
    TaskCount = "auto",
    bWorldEvent = true,
    tDependencyList = {},
    tUnlockList = {},
    tSMEDNodes = {
      gsNaziBase1 .. "General",
      gsNaziBase1 .. "aa_guns",
      gsNaziBase1 .. "1st_surge",
      gsNaziBase1 .. "2nd_surge",
      gsNaziBase1 .. "nazis",
      gsNaziBase1 .. "main"
    }
  })
end

function NaziGeneralBase01_WE:STARTER_Setup()
end

function NaziGeneralBase01_WE:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
  self.Task_NazisRUs(self)
end

function NaziGeneralBase01_WE:GENERAL_Setup()
  self.tInfo.Tags = {
    "p1m4_props",
    "p1m4_extra_nazis",
    "p1m4_elite_soldiers",
    "p1m4_heavy_weapons"
  }
  for i, tag in pairs(self.tInfo.Tags) do
    WorldSMEDNodes.LoadStaticTag(tag, true)
  end
  self.tInfo.General = gsNaziBase1 .. "General\\General_Base01"
  self.tInfo.hGeneral = Util.GetHandleByName(self.tInfo.General)
end

function NaziGeneralBase01_WE:Task_NazisRUs()
  self:CreateTask({
    sName = "NaziGeneralBase01_WE_Task_NazisRUs",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "Kill",
    tTgtInclude = {
      self.tInfo.General
    }
  })
end
