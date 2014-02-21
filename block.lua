--block.lua
require 'utils'
require 'puzzleBoard'

Block = {}
Block.__index = Block

function Block.create(newX, newY, mapX, mapY)
	local self = {}
	setmetatable(self, Block)
	self.width = 40
	self.height = 40
	self.fallSpeed = 600
	self.x = newX
	self.y = newY
	self.mapX = mapX
	self.mapY = mapY
	self.lerpX = -1
	self.lerpY = -1
	self.lerpingTime = 0
	self.lerpingSpeed = 1.5
	self.lerping = false
	self.dirty = false
	self.state = "idle"
	self.scale = 1
	self.destroySpeed = 1
	self:getColor(love.math.random(1,5))
	table.insert(blocks, self)
	map[self.mapY][self.mapX] = self.mapId
	return self
end

function Block:getColor(id)
	self.mapId = id
end

function Block:update(dt)
	if self.state == "falling" then
		self:falling(dt)
	elseif self.state == "matched" then
		self:matched(dt)
	elseif self.state == "idle" then
		self:idle()
	elseif self.state == "lifted" then
		self:followAbove(hero)
	end

	if self.lerping then
	      self:updateLerp(dt)
	end
end

function Block:updateLerp(dt)
	self.lerpingTime = self.lerpingTime + (self.lerpingSpeed * dt)
	self.x = lerp(self.x, self.lerpX, self.lerpingTime)
	self.y = lerp(self.y, self.lerpY, self.lerpingTime)
	if self.lerpingTime >= 0.8 or (self.x == self.lerpX and self.y == self.lerpY) then
		self.x = self.lerpX
		self.Y = self.lerpY
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
	if self.scale < 0.1 then
		self:remove()
	end

	self.scale = self.scale - (self.destroySpeed * dt)
end

function Block:idle()
	local bx = self.mapX
	local by = self.mapY
	local _block = getBlockAtTilePos(bx, by+1)
	if self.y < getBoardHeight() - self.height then
		if not _block then
			self.state = "falling"
			map[self.mapY][self.mapX] = 0
			self.mapY = -1
		end
	end
end

function Block:falling(dt)
	if self.y >= getBoardHeight() - self.height then
		self.y = getBoardHeight() - self.height
		self.state = "idle"
		self.mapY = mapH
		map[self.mapY][self.mapX] = self.mapId
		puzzleBoard:checkForMatches()
	else
		for i, _block in ipairs(blocks) do
			if not (self.mapX == _block.mapX and self.mapY == _block.mapY) then
				if checkCollision(self.x, self.y, self.width, self.height, _block.x, _block.y, _block.width, _block.height) and _block.state == "idle" then
					self.state = "idle"
					self.dirty = false
					self.y = _block.y - self.height
					self.mapX = _block.mapX
					self.mapY = _block.mapY - 1
					map[self.mapY][self.mapX] = self.mapId
					puzzleBoard:checkForMatches()
					break
				end
			end
		end	
	end

	if self.state == "falling" then
		self.dirty = true
		self.y = self.y + (self.fallSpeed * dt)
	end
end

function Block:followAbove(parent)
	self.x = parent.x - (parent.width * 0.5)
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
	self.x = (getObjectTileX(hero)-1) * tileW
	self.y = hero.y - hero.height
	self.mapX = getObjectTileX(hero)
	self.mapY = getObjectTileY(hero)
	self.dirty = true
	map[self.mapY][self.mapX] = self.mapId
	hero.y = hero.y - self.height
end

function Block:dropBlockLeft()
	self.state = "falling"
	self.x = (getObjectTileX(hero)-2) * tileW
	self.y = hero.y - hero.height
	self.mapX = getObjectTileX(hero) - 1
	self.mapY = getObjectTileY(hero)
	self.dirty = true
	map[self.mapY][self.mapX] = self.mapId
end

function Block:dropBlockRight()
	self.state = "falling"
	self.x = (getObjectTileX(hero)) * tileW
	self.y = hero.y - hero.height
	self.mapX = getObjectTileX(hero) + 1
	self.mapY = getObjectTileY(hero)
	self.dirty = true
	map[self.mapY][self.mapX] = self.mapId
end

function Block:remove()
	for i, block in ipairs(blocks) do
		if(block.mapX == self.mapX and block.mapY == self.mapY) then
			map[block.mapY][block.mapX] = 0
			table.remove(blocks, i)
		end
	end
end
