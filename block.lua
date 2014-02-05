--block.lua
require 'boundingBox'

function initBlock(newX, newY, mapX, mapY)
	block = {}
	block.width = 40
	block.height = 40
	block.fallSpeed = 600
	block.x = newX
	block.y = newY
	block.mapX = mapX
	block.mapY = mapY
	block.dirty = false
	block.state = "idle"
	block.scale = 1
	block.destroySpeed = 1
	getColor(love.math.random(1,5))
	table.insert(blocks, block)
	map[block.mapY][block.mapX] = block.mapId
	return block
end

function getColor(id)
	block.mapId = id
end

function updateBlock(block, dt)
	if block.state == "falling" then
		falling(block, dt)
	elseif block.state == "matched" then
		matched(block, dt)
	elseif block.state == "idle" then
		idle(block)
	elseif block.state == "lifted" then
		followAbove(block, hero)
	end
end

function matched(block, dt)
	if block.scale < 0.1 then
		removeBlock(block)
	end

	block.scale = block.scale - (block.destroySpeed * dt)
end

function idle(block)
	local bx = block.mapX
	local by = block.mapY
	local _block = getBlockAtTilePos(bx, by+1)
	if block.y < getBoardHeight() - block.height then
		if not _block then
			block.state = "falling"
			map[block.mapY][block.mapX] = 0
			block.mapY = -1
		end
	end
end

function falling(block, dt)
	if block.y >= getBoardHeight() - block.height then
		block.y = getBoardHeight() - block.height
		block.state = "idle"
		block.mapY = mapH
		map[block.mapY][block.mapX] = block.mapId
		checkForMatches()
	else
		for i, _block in ipairs(blocks) do
			if not (block.mapX == _block.mapX and block.mapY == _block.mapY) then
				if checkCollision(block.x, block.y, block.width, block.height, _block.x, _block.y, _block.width, _block.height) and _block.state == "idle" then
					block.state = "idle"
					block.dirty = false
					block.y = _block.y - block.height
					block.mapX = _block.mapX
					block.mapY = _block.mapY - 1
					map[block.mapY][block.mapX] = block.mapId
					checkForMatches()
					break
				end
			end
		end	
	end

	if block.state == "falling" then
		block.dirty = true
		block.y = block.y + (block.fallSpeed * dt)
	end
end

function followAbove(block, parent)
	block.x = parent.x - (parent.width * 0.5)
	block.y = parent.y - block.height
end

function drawBlocks()
	for i, block in ipairs(blocks) do
		drawBlock(block)
	end
end

function drawBlock(block)
	if block.mapId == 1 then
		love.graphics.draw(blueBlock, block.x, block.y, 0, block.scale, block.scale, 0, 0)
	elseif block.mapId == 2 then
		love.graphics.draw(greenBlock, block.x, block.y, 0, block.scale, block.scale, 0, 0)
	elseif block.mapId == 3 then
		love.graphics.draw(purpleBlock, block.x, block.y, 0, block.scale, block.scale, 0, 0)
	elseif block.mapId == 4 then
		love.graphics.draw(redBlock, block.x, block.y, 0, block.scale, block.scale, 0, 0)
	else
		love.graphics.draw(yellowBlock, block.x, block.y, 0, block.scale, block.scale, 0, 0)
	end
end

function liftBlock(block)
	block.state = "lifted"
	map[block.mapY][block.mapX] = 0
	block.mapY = 0
	block.mapX = 0
end

function dropBlock(block)
	block.state = "falling"
	block.x = (getObjectTileX(hero)-1) * tileW
	block.y = hero.y - hero.height
	block.mapX = getObjectTileX(hero)
	block.mapY = getObjectTileY(hero)
	block.dirty = true
	map[block.mapY][block.mapX] = block.mapId
	hero.y = hero.y - block.height
end

function dropBlockLeft(block)
	block.state = "falling"
	block.x = (getObjectTileX(hero)-2) * tileW
	block.y = hero.y - hero.height
	block.mapX = getObjectTileX(hero) - 1
	block.mapY = getObjectTileY(hero)
	block.dirty = true
	map[block.mapY][block.mapX] = block.mapId
end

function dropBlockRight(block)
	block.state = "falling"
	block.x = (getObjectTileX(hero)) * tileW
	block.y = hero.y - hero.height
	block.mapX = getObjectTileX(hero) + 1
	block.mapY = getObjectTileY(hero)
	block.dirty = true
	map[block.mapY][block.mapX] = block.mapId
end

function removeBlock(temp)
	--logBoard()
	for i, block in ipairs(blocks) do
		if(block.mapX == temp.mapX and block.mapY == temp.mapY) then
			map[block.mapY][block.mapX] = 0
			table.remove(blocks, i)
		end
	end
end

function getBlockAtTilePos(tX, tY)
	for i, block in ipairs(blocks) do
		if(block.mapX == tX and block.mapY == tY) then
			return block
		end
	end
end
