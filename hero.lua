--hero.lua
require 'utils'
require 'puzzleBoard'
require 'block'

Hero = {}
Hero.__index = Hero

SPEED = 700
JUMP_POWER = -500
FRICTION = 0.1
AIR_FRICTION = 0.01
GRAVITY = 300
SLAM_POWER = 100000
PRE_SLAM_TIME = 0.25
HERO_WIDTH = 40
HERO_HEIGHT = 40

function Hero.create()
  local self = {}
  setmetatable(self, Hero)
  self:reset()
  return self
end

function Hero:reset()
  self.x = 200
  self.y = 250
  self.vx = 0
  self.vy = 0
  self.direction = 0
  self.jumping = false
  self.onGround = false
  self.state = "idle"
  self.heldObject = nil
  self.slamming = false
  self.slamBuffer = 0
  self.height = HERO_HEIGHT
  self.width = HERO_WIDTH
  self.points = 0
  self.upLeft = -1
  self.downLeft = -1
  self.upRight = -1
  self.downRight = -1
end

function Hero:keyPressed(key, isRepeat)
  if key == ' ' then
    self:action()
  elseif key == 'up' then
    self:jump()
  elseif key == 'down' then
    self:slam()
    self.direction = 0
  end
end

function Hero:update(dt)
  if self.slamming then
    self:handleSlam(dt)
  else
    self:handleInput(dt)
    self:handlePhysics(dt)
  end
end

function Hero:handleSlam(dt)
  self.slamBuffer = self.slamBuffer + dt
  if self.slamBuffer > PRE_SLAM_TIME then
    self.vx = 0
    self.vy = SLAM_POWER * dt

    if self.y >= getBoardBottom() - HERO_HEIGHT then
      self.y = getBoardBottom() - HERO_HEIGHT
      self.jumping = false
    end

    self:move(self.vx * dt, self.vy * dt)
  end
end

function Hero:handlePhysics(dt)
  self:move(self.vx * dt, self.vy * dt)

  self.vx = self.vx * math.pow(FRICTION, dt)

  if self.jumping then
    self.vy = self.vy * math.pow(AIR_FRICTION, dt)
    if self.vy >= -50.0 then
      self.vy = 0
      self.jumping = false
    end
  elseif not self.onGround then
    self.vy = self.vy + (GRAVITY * dt)
  end

  if self.state == "holding" then
    if self.y <= tileH then
      self.y = tileH
    end
  else
    if self.y <= 0 then
      self.y = 0
    end
  end
end

function Hero:handleInput(dt)
  if love.keyboard.isDown('left') then
    self.vx = self.vx - (SPEED * dt)
    self.direction = -1
  end
  if love.keyboard.isDown('right') then
    self.vx = self.vx + (SPEED * dt)
    self.direction = 1
  end
end

function Hero:slam()
  if not self.onGround and not self.heldObject then
    self.slamming = true
  end
end

function Hero:jump()
  if not self.jumping and self.onGround then
    self.jumping = true
    self.vy = JUMP_POWER
    self.onGround = false
  end
end

function Hero:move(dx, dy)
  local myY = getObjectTileY(self)
  local myX = getObjectTileX(self)

  getCorners(self.x, self.y+dy, self)
  if dy < 0 then
    if self.upleft and self.upright then
      self.y = self.y + dy
    else
      self.y = getPixelPositionY(myY)
      self.vy = 0;
    end
  end
  if dy > 0 then
    if self.downleft and self.downright then
      self.y = self.y + dy
    else
      self.y = getPixelPositionY(myY)
      self.vy = 0;
      self:hitSomethingBelow(myX, myY)
    end
  end

  getCorners(self.x+dx, self.y, self)
  if dx < 0 then
    if self.downleft and self.upleft then
      self.x = self.x + dx
    else
      self.x = getPixelPositionX(myX)
      self.vx = 0;
    end
  end
  if dx > 0 then
    if self.upright and self.downright then
      self.x = self.x + dx
    else
      self.x = getPixelPositionX(myX)
      self.vx = 0;
    end
  end
end

function Hero:draw()
  local pr, pg, pb, pa = love.graphics.getColor()
  love.graphics.setColor(255, 0, 0)
  love.graphics.rectangle("fill", self.x, self.y, HERO_WIDTH, HERO_HEIGHT)
  love.graphics.setColor(pr, pg, pb, pa)
  self:drawHintReticule()
end

function Hero:drawHintReticule()
  local myX = getObjectTileX(self)
  local myY = getObjectTileY(self)
  if self.state == "holding" then
    self:drawDropHint(myX, myY)
  else
    self:drawPickUpHint(myX, myY)
  end
end

function Hero:drawDropHint(myX, myY)
  local _block = self:getClosestBlockBelow(myX+self.direction, myY)
  local _sideBlock = getBlockAtTilePos(myX+self.direction, myY)
  local posX
  local posY

  if _sideBlock then return end

  if _block then
    posX = _block.x
    posY = _block.y - _block.height
  else
    posX = getPixelPositionX(myX + self.direction)
    posY = getBoardBottom() - tileH
  end

  --Why does hero draw hint blocks...
  if self.heldObject.mapId == 1 then
    love.graphics.draw(blueGhostBlock, posX, posY)
  elseif self.heldObject.mapId == 2 then
    love.graphics.draw(greenGhostBlock, posX, posY)
  elseif self.heldObject.mapId == 3 then
    love.graphics.draw(purpleGhostBlock, posX, posY) 
  elseif self.heldObject.mapId == 4 then
    love.graphics.draw(redGhostBlock, posX, posY)
  else
    love.graphics.draw(yellowGhostBlock, posX, posY)
  end
end

function Hero:drawPickUpHint(myX, myY)
  local _block
  if self.direction == 0 then
    _block = getBlockAtTilePos(myX, myY+1)
  else
    _block = getBlockAtTilePos(myX+self.direction, myY)
  end

  if _block then
    love.graphics.draw(hintReticule, _block.x, _block.y)
  end
end

function Hero:getClosestBlockBelow(myX, myY)
  local spaces = mapH - myY
  for i=1, spaces do
    local _block = getBlockAtTilePos(myX, myY+i)
    if _block then 
      return _block
    end
  end	
end

function Hero:hitSomethingBelow(myX, myY)
  if self.slamming then
    screen_shake = 0.1
  end
  self.slamming = false
  self.slamBuffer = 0
  self.onGround = true

  local objBelow = getBlockAtTilePos(myX, myY+1)
  if objBelow then
    self:hitBlock(objBelow)
  end
end

function Hero:hitBlock(block)
  if block.state == "lifted" then
    --DO BETTER
  elseif(block.y > self.y) then
    self.y = block.y - HERO_HEIGHT
    self.vy = 0
  elseif(block.x < self.x) then
    self.x = block.x + block.width
    self.vx = 0
  elseif(block.x > self.x) then
    self.x = block.x - HERO_WIDTH
    self.vx = 0
  end
end

function Hero:action()
  if self.state == "idle" then
    if self.direction == 0 then --lift block below
      self:grabBelow()
    elseif self.direction == 1 then --lift block right
      self:grabRight()
    elseif self.direction == -1 then --lift block left
      self:grabLeft()
    end
  elseif self.state == "holding" then
    if self.direction == 0 then --drop block below
      self:dropBelow()
    elseif self.direction == 1 then --drop block right
      self:dropRight()
    elseif self.direction == -1 then --drop block left
      self:dropLeft()
    end
  end
end

function Hero:dropBelow()
  if self.heldObject then
    self.heldObject:dropBlock()
    self.y = self.y - self.heldObject.height 
    self.heldObject = nil
    self.state = "idle"
  end
end

function Hero:dropRight()
  local _block = getBlockAtTilePos(getObjectTileX(self)+1, getObjectTileY(self))
  if (not _block) and self.heldObject and getObjectTileX(self) + 1 <= mapW then
    self.heldObject:dropBlockRight()
    self.heldObject = nil
    self.state = "idle"
  end
end

function Hero:dropLeft()
  local _block = getBlockAtTilePos(getObjectTileX(self)-1, getObjectTileY(self))
  if (not _block) and self.heldObject and getObjectTileX(self) - 1 > 0 then
    self.heldObject:dropBlockLeft()
    self.heldObject = nil
    self.state = "idle"
  end
end

function Hero:grabBelow()
  local myX = getObjectTileX(self)
  local myY = getObjectTileY(self)

  local _block = getBlockAtTilePos(myX, myY+1)
  self:grabBlock(_block)
end

function Hero:grabLeft()
  local myX = getObjectTileX(self)
  local myY = getObjectTileY(self)

  if myX <= 1 then return end

  local _block = getBlockAtTilePos(myX-1, myY)
  self:grabBlock(_block)
end

function Hero:grabRight()
  local myX = getObjectTileX(self)
  local myY = getObjectTileY(self)

  if myX > mapW then return end

  local _block = getBlockAtTilePos(myX+1, myY)
  self:grabBlock(_block)
end

function Hero:grabBlock(_block)
  if _block and _block.state ~= "matched" then
    self.heldObject = _block
    _block:liftBlock()
    self.state = "holding"
  end
end
