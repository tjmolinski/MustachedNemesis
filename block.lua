function initBlock(newX, newY, mapX, mapY)
	block = {}
	block.width = 40
	block.height = 40
	block.x = newX
	block.y = newY
	block.mapX = mapX
	block.mapY = mapY
	block.state = "notTween"
	getColor(love.math.random(4))
	table.insert(blocks, block)
	map[block.mapY][block.mapX] = block.mapId
	return block
end

function getColor(type)
	block.mapId = type
	if type == 0 then
		block.cr = 255
		block.cg = 0
		block.cb = 0
	elseif type == 1 then
		block.cr = 0
		block.cg = 255
		block.cb = 0
	elseif type == 2 then
		block.cr = 0
		block.cg = 0
		block.cb = 255
	elseif type == 3 then
		block.cr = 255
		block.cg = 0
		block.cb = 255
	else
		block.cr = 0
		block.cg = 255
		block.cb = 255
	end
end

function startTween(block, tx, ty)
	block.tweenX = tx
	block.tweenY = ty	
	block.startX = block.x
	block.startY = block.y
	block.state = "tween"
end

function isNear(pos1, pos2)
	return pos1-50.0 < pos2 and pos1+50.0 > pos2
end

function updateBlock(block, dt)
	if block.state == "tween" then
		if block.x == block.tweenX and block.y == block.tweenY then
			block.state = "notTween"
		else
			if not isNear(block.x, block.tweenX) then
			block.x = tween(elapsedTime, block.x, block.tweenX - block.startX, 100)
			else
			block.x = block.tweenX
			block.mapX = getBlockTileX(block)
			end
			if not isNear(block.y, block.tweenY) then
			block.y = tween(elapsedTime, block.y, block.tweenY - block.startY, 100)
			else
			block.y = block.tweenY
			block.mapY = getBlockTileY(block)
			end
		end	
	else
		local bx = block.mapX
		local by = block.mapY
		if by+1 <= mapH then
		if not getBlockAtTilePos(bx, by+1) then
			block.y = block.y + block.height
			block.mapY = by + 1
			map[by][bx] = 0
			map[by+1][bx] = block.mapId
		end
		end
	end
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
	local pr, pg, pb, pa = love.graphics.getColor()
	love.graphics.setColor(0,0,0)
	love.graphics.rectangle("line", block.x, block.y, block.width, block.height)
	love.graphics.setColor(block.cr, block.cg, block.cb)
	love.graphics.rectangle("fill", block.x, block.y, block.width, block.height)
	love.graphics.setColor(pr, pg, pb, pa)
end

function getBlockAtTilePos(tX, tY)
	for i, block in ipairs(blocks) do
		if(block.mapX == tX and block.mapY == tY) then
			return block
		end
	end
end

function removeBlock(temp)
	logBoard()
	for i, block in ipairs(blocks) do
		if(block.mapX == temp.mapX and block.mapY == temp.mapY) then
			map[block.mapY][block.mapX] = 0
			table.remove(blocks, i)
		end
	end
end

function getBlockTileX(block)
	return math.floor((block.x+block.width/2)/love.window.getWidth()*mapW) + 1
end

function getBlockTileY(block)
	return math.floor((block.y+block.height/2)/love.window.getHeight()*mapH) + 1
end
