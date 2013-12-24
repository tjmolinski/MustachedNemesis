blocks = {}

function initBlock(newX, newY)
	block = {}
	block.width = 40
	block.height = 40
	block.x = newX
	block.y = newY
	getColor(love.math.random(4))
	table.insert(blocks, block)
end

function getColor(type)
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

function updateBlocks()
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
		if(getBlockTileX(block) == tX and getBlockTileY(block) == tY) then
			return block
		end
	end
end

function getBlockTileX(block)
	return math.floor((block.x+block.width/2)/love.window.getWidth()*mapW) + 1
end

function getBlockTileY(block)
	return math.floor((block.y+block.height/2)/love.window.getHeight()*mapH) + 1
end
