blocks = {}

function initBlock(newX, newY)
	block = {}
	block.width = 40
	block.height = 40
	block.x = newX
	block.y = newY
	table.insert(blocks, block)
end

function updateBlocks()
end

function drawBlocks()
	for i, block in ipairs(blocks) do
		drawBlock(block)
	end
end

function drawBlock(block)
	love.graphics.setColor(125, 125, 125)
	love.graphics.rectangle("line", block.x, block.y, block.width, block.height)
	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle("fill", block.x, block.y, block.width, block.height)
end
