if not InteriorCheckPoint then
  InteriorCheckPoint = {}
  if Trigger == nil then
    Trigger = {}
  end
end
setmetatable(InteriorCheckPoint, {__index = Trigger})
