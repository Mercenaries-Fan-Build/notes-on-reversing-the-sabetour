if not LIST_LUA then
  LIST_LUA = 1
  List = {}
  
  function List:New(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.first = 1
    self.last = 0
    return o
  end
  
  function List:pushbottom(value)
    local first = self.first - 1
    self.first = first
    self[first] = value
  end
  
  function List:push(value)
    local last = self.last + 1
    self.last = last
    self[last] = value
  end
  
  function List:popbottom()
    local first = self.first
    if first > self.last then
      error("list is empty")
    end
    local value = self[first]
    self[first] = nil
    self.first = first + 1
    return value
  end
  
  function List:pop()
    local last = self.last
    if last < self.first then
      error("list is empty")
    end
    local value = self[last]
    self[last] = nil
    self.last = last - 1
    return value
  end
  
  function List:printlist()
    for i = self.first, self.last do
      if type(self[i]) == "table" then
        for k, v in pairs(self[i]) do
          print(v)
        end
      else
        print(self[i])
      end
    end
  end
  
  function List:printlistreverse(size)
    local size = size
    local count = 0
    for i = self.last, self.first, -1 do
      if type(self[i]) == "table" then
        print(self[i][1])
      else
        print(self[i])
      end
      count = count + 1
      if size ~= nil and count == size then
        break
      end
    end
  end
  
  function List:reset()
    while self.last ~= 0 do
      self:pop()
    end
  end
  
  function List:isempty()
    if self.last == 0 then
      return true
    else
      return false
    end
  end
  
  function List:size()
    return self.last
  end
  
  function List:copylist(fromlist)
    for i = fromlist.first, fromlist.last do
      self:push(fromlist[i])
    end
  end
end
