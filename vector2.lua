--vector2.lua

Vector2 = {}
Vector2.__index = Vector2

function Vector2.create(newX, newY)
  local self = {}
  setmetatable(self, Vector2)
  self.x = newX
  self.y = newY
  return self
end

function Vector2:add(other)
  self.x = self.x + other.x
  self.y = self.y + other.y
end

function Vector2:sub(other)
  self.x = self.x - other.x
  self.y = self.y - other.y
end

function Vector2:normalize()
  local mag = self:magnitude()
  self.x = self.x / mag
  self.y = self.y / mag
end

function Vector2:magnitude()
  return math.sqrt( (self.x*self.x) + (self.y*self.y) )
end
