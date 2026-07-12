MgrVendor = MgrVendor or {}

function MgrVendor.Create(mModule, tConfig)
  self = {}
  setmetatable(self, {__index = mModule})
  self.tConfig = tConfig
  local tTempVendorNames = {}
  for k, v in ipairs(tConfig) do
    table.insert(tTempVendorNames, v.VendorName)
  end
  Util.CreateEvent({
    EventType = "StreamEvent",
    Objects = tTempVendorNames
  }, "MgrVendor.SetupVendors", self)
  return self
end

function MgrVendor:SetupVendors()
  Render.PrintMessage("MgrVendor.SetupVendors()")
  local i = 1
  while i <= #self.tConfig do
    local uPropAttractionPoint = Object.AttractionPtFindPtInObject(Util.FindObjectHandle(self.tConfig[i].VendorCart), "VendorPt")
    local uVendor = Util.FindObjectHandle(self.tConfig[i].VendorName)
    local tVec3 = Object.AttractionPtGetTargetPos(uPropAttractionPoint)
    Nav.MoveToPoint(uVendor, tVec3.x, tVec3.y + 0.5, tVec3.z, false, "MgrVendor.OnVendorArrive", self, {uVendor = uVendor, uPropAttractionPoint = uPropAttractionPoint})
    Actor.SetUserFlag(uVendor, "InvolvedInEvent", true)
    i = i + 1
  end
end

function MgrVendor:OnVendorArrive(tData)
  Actor.UseAttrPt(tData.uVendor, tData.uPropAttractionPoint)
end
