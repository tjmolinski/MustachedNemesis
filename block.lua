--block.lua
require 'utils'
require 'puzzleBoard'
require 'particle'

Block = {}
Block.__index = Block

GRAVITY = 300

function Block.create(newX, newY, mapX, mapY)
  local self = {}
  setmetatable(self, Block)
  self.width = 40
  self.height = 40
  self.fallSpeed = 600
  self.x = newX
  self.y = newY
  self.vx = 0
  self.vy = 0
  self.mapX = mapX
  self.mapY = mapY
  self.onGround = false
  self.lerpX = -1
  self.lerpY = -1
  self.lerpingTime = 0
  self.lerpingSpeed = 2.0
  self.lerping = false
  self.state = "idle"
  self.scale = 1
  self.destroySpeed = 1
  self.mapId = love.math.random(1,5)
  self.upLeft = -1
  self.downLeft = -1
  self.upRight = -1
  self.downRight = -1
  table.insert(blocks, self)
  map[self.mapY][self.mapX] = self.mapId
  return self
end

function Block:update(dt)
  if self.lerping then
    self:updateLerp(dt)
    return
  end
  self:handlePhysics(dt)
  --self:handleCollisions(dt)
  if self.state == "idle" then
    --self:idle()
  elseif self.state == "falling" then
    self:falling(dt)
  --elseif self.state == "matched" then
   -- self:matched(dt)
  elseif self.state == "lifted" then
    self:followAbove(hero)
  end
end

--TODO: TJM
--This needs to work... as of right now the blocks will fall
--right past all the other blocks. We only need to make checks
--against blocks in the y axis.
function Block:handleCollisions(dt)
  for i, block in ipairs(blocks) do
  	if not (self.state == 'lifted' or block.state == 'lifted') then
		  if checkCollision(self.x, self.y, self.width, self.height, block.x, block.y, block.width, block.height) then
			  self:hitBlock(block)
			end
		end
	end
end

function Block:handlePhysics(dt)
  self:move(self.vx * dt, self.vy * dt)
  
  if not self.onGround then
    --self.vy = self.vy + (GRAVITY * dt)
    self.vy = 100
  end
end

function Block:move(dx, dy)
  local myY = getObjectTileY(self)
  local myX = getObjectTileX(self)

  getCorners(self.x, self.y+dy, self)
  if dy > 0 then
    if self.downleft and self.downright then
      map[myY][myX] = 0
      self.y = self.y + dy
    else
      self.y = getPixelPositionY(myY)
      self.vy = 0;
      self:hitSomethingBelow(myX, myY)
    end
  end
end

function Block:hitSomethingBelow(myX, myY)
  self.onGround = true

  local objBelow = getBlockAtTilePos(myX, myY+1)
  if objBelow then
    self:hitBlock(block)
  end
end

function Block:hitBlock(block)
    self.mapX = getObjectTileX(self)
    self.mapY = getObjectTileY(self)
    map[self.mapY][self.mapX] = self.mapId
    puzzleBoard:checkForMatches()
end

function Block:updateLerp(dt)
  self.lerpingTime = self.lerpingTime + (self.lerpingSpeed * dt)
  self.x = lerp(self.x, self.lerpX, self.lerpingTime)
  self.y = lerp(self.y, self.lerpY, self.lerpingTime)
  if self.lerpingTime >= 0.8 or (self.x == self.lerpX and self.y == self.lerpY) then
    self.x = self.lerpX
    self.y = self.lerpY
    local tX = getObjectTileX(self)
    local tY = getObjectTileY(self)
    self.lerping = false
    map[tY][tX] = self.mapId
    self.mapX = tX
    self.mapY = tY
    self.lerpingTime = 0
    puzzleBoard:checkForMatches()
  end
end

function Block:matched(dt)
  hero.points = hero.points + 10
  self:makeParticles();
  self:remove()
end

function Block:makeParticles()
  for i=0, 3 do
    for k=0, 3 do
      local particle = Particle.create(self.x+(i*10), self.y+(k*10), self.mapId)
      table.insert(particles, particle)
    end
  end
end

function Block:idle()
  if self.mapY+1 <= mapH then
    local block = getBlockAtTilePos(self.mapX, self.mapY+1)
    if not block then
      map[self.mapX][self.mapY] = 0
      self.mapX = 0
      self.mapY = 0
      self.state = 'falling'
    end
  end
end

function Block:falling(dt)
  if self.mapX > 0 and self.mapY > 0 then
    map[self.mapX][self.mapY] = 0
    self.mapX = 0
    self.mapY = 0
  end

  if self.y >= getBoardBottom() - self.height then
    self.y = getBoardBottom() - self.height
    self.state = "idle"
    self.mapX = getObjectTileX(self)
    self.mapY = mapH
    map[self.mapY][self.mapX] = self.mapId
    puzzleBoard:checkForMatches()
  end

  if self.state == "falling" then
    self.y = self.y + (self.fallSpeed * dt)
  end
end

function Block:followAbove(parent)
  self.x = parent.x
  self.y = parent.y - self.height
end

function Block:draw()
  if self.mapId == 1 then
    love.graphics.draw(blueBlock, self.x, self.y, 0, self.scale, self.scale, 0, 0)
  elseif self.mapId == 2 then
    love.graphics.draw(greenBlock, self.x, self.y, 0, self.scale, self.scale, 0, 0)
  elseif self.mapId == 3 then
    love.graphics.draw(purpleBlock, self.x, self.y, 0, self.scale, self.scale, 0, 0)
  elseif self.mapId == 4 then
    love.graphics.draw(redBlock, self.x, self.y, 0, self.scale, self.scale, 0, 0)
  else
    love.graphics.draw(yellowBlock, self.x, self.y, 0, self.scale, self.scale, 0, 0)
  end
end

function Block:liftBlock()
  self.lerping = false
  self.state = "lifted"
  map[self.mapY][self.mapX] = 0
  self.mapY = 0
  self.mapX = 0
end

function Block:dropBlock()
  self.state = "falling"
  self.x = getPixelPositionX(getObjectTileX(hero))
  self.y = hero.y - hero.height
end

function Block:dropBlockLeft()
  self.state = "falling"
  self.x = getPixelPositionX(getObjectTileX(hero)-1)
  self.y = hero.y - hero.height
end

function Block:dropBlockRight()
  self.state = "falling"
  self.x = getPixelPositionX(getObjectTileX(hero)+1)
  self.y = hero.y - hero.height
end

function Block:remove()
  for i, block in ipairs(blocks) do
    if(block.mapX == self.mapX and block.mapY == self.mapY) then
      print('remove at '..self.mapX.." "..self.mapY)
      map[self.mapY][self.mapX] = 0
      table.remove(blocks, i)
    end
  end
end
