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
GRAVITY = 280
SLAM_POWER = 100000
PRE_SLAM_TIME = 0.25
HERO_WIDTH = 20
HERO_HEIGHT = 20

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
end

function Hero:keyPressed(key, isRepeat)
	if key == " " then
		self:action()
	elseif key == "up" then
		self:jump()
	end
end

function Hero:update(dt)
	self:checkGround(dt)
	self:handleCollisions(dt)
	if self.slamming then
		self:handleSlam(dt)
	else
		self:handleInput(dt)
		self:handlePhysics(dt)
	end
end

function Hero:checkGround(dt)
	local myCenterX = getObjectTileX(self)
	local myLeftX = getObjectTileLeftMostX(self)
	local myRightX = getObjectTileRightMostX(self)
	local myY = getObjectTileY(self)

	local _CenterBlock = getBlockAtTilePos(myCenterX, myY+1)
	local _LeftBlock = getBlockAtTilePos(myLeftX, myY+1)
	local _RightBlock = getBlockAtTilePos(myRightX, myY+1)

	if _CenterBlock then self.onGround = true end	
	if _LeftBlock then self.onGround = true end	
	if _RightBlock then self.onGround = true end	

	if (not _CenterBlock) and (not _LeftBlock) and (not _RightBlock) then
	    self.onGround = false
	end
end

function Hero:handleSlam(dt)
	self.slamBuffer = self.slamBuffer + dt
	if self.slamBuffer > PRE_SLAM_TIME then
		self.vx = 0
		self.vy = SLAM_POWER * dt

		if self.y >= getBoardHeight() - HERO_HEIGHT then
			self.y = getBoardHeight() - HERO_HEIGHT
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
			self.jumping = false
		end
	elseif not self.onGround then
		self.vy = self.vy + (GRAVITY * dt)
	end

	if self.y >= getBoardHeight() - HERO_HEIGHT then
		self.y = getBoardHeight() - HERO_HEIGHT
		self.jumping = false
	end
	if self.x <= 0 then
		self.x = 0
		self.vx = 0
	end
	if self.x >= getBoardWidth() - HERO_WIDTH then
		self.x = getBoardWidth() - HERO_WIDTH
		self.vx = 0
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
	if love.keyboard.isDown("left") then
		self.vx = self.vx - (SPEED * dt)
		self.direction = -1
	end
	if love.keyboard.isDown("right") then
		self.vx = self.vx + (SPEED * dt)
		self.direction = 1
	end
	if love.keyboard.isDown("down") then
		self.direction = 0
		if not self.onGround and not self.heldObject then
			self.slamming = true
		end
	end
end

function Hero:jump()
	if not self.jumping then
		self.jumping = true
		self.vy = JUMP_POWER
	end
end

function Hero:move(dx, dy)
	self.x = self.x + dx
	self.y = self.y + dy
end

function Hero:draw()
	local pr, pg, pb, pa = love.graphics.getColor()
	love.graphics.setColor(255, 0, 0)
	love.graphics.rectangle("fill", self.x, self.y, HERO_WIDTH, HERO_HEIGHT)
	love.graphics.setColor(pr, pg, pb, pa)
	self:drawHintReticule()
end

function Hero:drawHintReticule()
	if self.state == "holding" then
		local myX = getObjectTileX(self)
		local myY = getObjectTileY(self)
		local _block = self:getClosestBlockBelow(myX+self.direction, myY)
		local posX
		local posY

		if _block then
			posX = _block.x
			posY = _block.y - _block.height
		else
			posX = (myX - 1 + self.direction) * tileW
			posY = getBoardHeight() - tileH
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

function Hero:hitBlock(block)
	if self.slamming then
	  print("Shake")
		screen_shake = 0.1
	end

	self.slamming = false
	self.slamBuffer = 0
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

function Hero:handleCollisions(dt)
	for i, block in ipairs(blocks) do
		if checkCollision(self.x, self.y, HERO_WIDTH, HERO_HEIGHT, block.x, block.y, block.width, block.height) then
			self:hitBlock(block)
		end
	end
end

function Hero:dropBelow()
	if self.heldObject then
		self.heldObject:dropBlock()
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

	if myY <= 1 then return end

	local _block = getBlockAtTilePos(myX, myY+1)
	self:grabBlock(_block)
end

function Hero:grabLeft()
	local myX = getObjectTileX(self)
	local myY = getObjectTileY(self)

	if myY <= 1 then return end

	local _block = getBlockAtTilePos(myX-1, myY)
	self:grabBlock(_block)
end

function Hero:grabRight()
	local myX = getObjectTileX(self)
	local myY = getObjectTileY(self)

	if myY <= 1 then return end

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
