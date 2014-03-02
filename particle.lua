--particle.lua

Particle = {}
Particle.__index = Particle

PARTICLE_HEIGHT = 10
PARTICLE_WIDTH = 10
PARTICLE_FRICTION = 0.01
PARTICLE_GRAVITY = 250

function Particle.create(newX, newY, colorId)
  local self = {}
  setmetatable(self, Particle)
  self.width = 10
  self.height = 10
  self.fallSpeed = 600
  self.x = newX
  self.y = newY
  self.vx = love.math.random(-10, 10)
  self.vy = love.math.random(-10, 0)
  self.color = colorId
  self.id = size(particles)
  return self
end

function Particle:update(dt)
  self:handlePhysics(dt)
end

function Particle:handlePhysics(dt)
  self:move(self.vx * dt, self.vy * dt)

  self.vs = self.vx * math.pow(PARTICLE_FRICTION, dt)
  self.vy = self.vy + (PARTICLE_GRAVITY * dt)

  if self.y >= love.window.getHeight() then
    self:remove()
  end
  if self.x <= -PARTICLE_WIDTH then
    self:remove()
  end
end

function Particle:move(dx, dy)
  self.x = self.x + dx
  self.y = self.y + dy
end

function Particle:draw()
  if self.color == 1 then
    love.graphics.draw(blueBlock, self.x, self.y, 0, .25, .25, 0, 0)
  elseif self.color == 2 then
    love.graphics.draw(greenBlock, self.x, self.y, 0, .25, .25, 0, 0)
  elseif self.color == 3 then
    love.graphics.draw(purpleBlock, self.x, self.y, 0, .25, .25, 0, 0)
  elseif self.color == 4 then
    love.graphics.draw(redBlock, self.x, self.y, 0, .25, .25, 0, 0)
  else
    love.graphics.draw(yellowBlock, self.x, self.y, 0, .25, .25, 0, 0)
  end
end

function Particle:remove()
  for i, particle in ipairs(particles) do
    if self.id == particle.id then
      table.remove(particles, i)
    end
  end
end
