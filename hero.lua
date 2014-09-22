--hero.lua
require 'utils'
require 'puzzleBoard'
require 'block'
require 'vector2'

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
  self.y = 400
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
      self.onGround = false
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
    print('jump')
  end
end

function Hero:move(dx, dy)
  for i, block in ipairs(blocks) do
    if checkCollision(self.x, self.y, self.width, self.height, block.x, block.y, block.width, block.height) then
      local heroCenter = Vector2.create(hero.x+(hero.width*0.5), hero.y+(hero.height*0.5))
      local blockCenter = Vector2.create(block.x+(block.width*0.5), block.y+(block.height*0.5))
      local diff = Vector2.create(0,0)
      diff:add(blockCenter)
      diff:sub(heroCenter)
      diff:normalize()
      if diff.y > 0.71 and self.vy > 0 then
	self.y = block.y - self.height
	self.vy = 0;
	dy = 0;
	self.onGround = true
      elseif diff.y < -0.71 and self.vy < 0 then	
	self.y = block.y + block.height 
	self.vy = 0;
	dy = 0;
      end
      if diff.x > 0.71 and self.vx > 0 then
        self.x = block.x - self.width
        self.vx = 0;
        dx = 0;
      elseif diff.x < -0.71 and self.vx < 0 then
        self.x = block.x + block.width
        self.vx = 0;
        dx = 0;
      end
    end
  end
  self.x = self.x + dx
  self.y = self.y + dy
  local myLeftX = getObjectTileLeftMostX(self)
  local myRightX = getObjectTileRightMostX(self)
  local myY = getObjectTileY(self)
  local lBlock = getBlockAtTilePos(myLeftX, myY+1)
  local rBlock = getBlockAtTilePos(myRightX, myY+1)
  if not (myY+1 >= mapH) then
    if not lBlock and not rBlock then
      self.onGround = false
    end
  end

  if self.y > getBoardBottom() - hero.height then
    self.y = getBoardBottom() - hero.height
    self.vy = 0
    self.onGround = true
  end

  if self.x > getBoardRight() - tileW then
    self.x = getBoardRight() - self.width
    self.vx = 0
  end
  if self.x < tileW then
    self.x = tileW
    self.vx = 0
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
  local posX
  local posY

  if _block then
    posX = _block.x
    posY = _block.y - _block.height
  else
    posX = getPixelPositionX(myX + self.direction)
    posY = getBoardBottom() - tileH
  end

  if myX+self.direction < 2 or (myX+self.direction > mapW-1) then
    return
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

  --TODO: TJM
  --Need to remove block checking and check pixel positions
  --and corners against other objects. Could contain this to
  --the same x value and just compare y values
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
  if (not _block) and self.heldObject and getObjectTileX(self) + 1 < mapW then
    self.heldObject:dropBlockRight()
    self.heldObject = nil
    self.state = "idle"
  end
end

function Hero:dropLeft()
  local _block = getBlockAtTilePos(getObjectTileX(self)-1, getObjectTileY(self))
  if (not _block) and self.heldObject and getObjectTileX(self) - 1 > 1 then
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
