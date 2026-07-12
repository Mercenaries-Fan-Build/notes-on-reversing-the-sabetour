MissionStarter = MissionStarter or {}
Shopkeeper = Shopkeeper or {}
setmetatable(Shopkeeper, {__index = MissionStarter})

function Shopkeeper:OnEnter()
  MissionStarter.OnEnter(self)
  Actor.SetupShop(self.hController, self.SMEDTable.sGarageLocatorName, self.SMEDTable.sGarageTankLocatorName, self.SMEDTable.sGarageTriggerColbyTag, self.SMEDTable.sGarageTankTriggerColbyTag, self.SMEDTable.sGarageMCTrigger, self.SMEDTable.sGarageTankMCTrigger)
  local x, y, z = Object.GetPosition(self.hController)
  Combat.SetTether(self.hController, x, y, z, 1.5, 0)
  Object.SetInvincible(self.hController, true)
  Combat.SetRespondToDamage(self.hController, true)
  self.bDebugMode = false
  self.sDebugLabel = "SHOPKEEP"
end

function Shopkeeper:OnActorUsed()
  Tips.Print(self, "Player is interacting with shopkeeper.")
end

function Shopkeeper:OnExit()
  HUD.RemoveObjectiveMarker(self.hController)
end

function Shopkeeper:OnShopEnter()
  Tips.Print(self, "Player has entered shop.")
  print("Player has entered shop.")
  Util.TestTest()
end

function Shopkeeper:OnShopExit()
  Tips.Print(self, "Player has exited shop.")
  print("Player has exited shop.")
end

function Shopkeeper:OnDeath()
  HUD.RemoveObjectiveMarker(self.hController)
end
