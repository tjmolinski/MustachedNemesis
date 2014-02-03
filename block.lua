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
	getColor(love.math.random(4))
	table.insert(blocks, block)
	map[block.mapY][block.mapX] = block.mapId
	return block
end

function getColor(id)
	block.mapId = id
end

function startTween(block, tx, ty)
	block.tweenX = tx
	block.tweenY = ty	
	block.startX = block.x
	block.startY = block.y
	block.state = "tween"
end

function isNear(pos1, pos2)
	return pos1-1.0 < pos2 and pos1+1.0 > pos2
end

function updateBlock(block, dt)
	if block.state == "falling" then
		falling(block, dt)
	elseif block.state == "matched" then
		removeBlock(block)
	elseif block.state == "idle" then
		idle(block)
	elseif block.state == "lifted" then
		followAbove(block, hero)
	end
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
		--map[block.mapY][block.mapX] = 0
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

function tween(et, begin, change, duration)
	return change * et / duration + begin
end

function drawBlocks()
	for i, block in ipairs(blocks) do
		drawBlock(block)
	end
end

function drawBlock(block)
	if block.mapId == 0 then
		love.graphics.draw(blueBlock, block.x, block.y)
	elseif block.mapId == 1 then
		love.graphics.draw(greenBlock, block.x, block.y)
	elseif block.mapId == 2 then
		love.graphics.draw(purpleBlock, block.x, block.y)
	elseif block.mapId == 3 then
		love.graphics.draw(redBlock, block.x, block.y)
	else
		love.graphics.draw(yellowBlock, block.x, block.y)
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
