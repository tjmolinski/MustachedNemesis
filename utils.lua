function size(list)
	local amount = 0
	for tble in pairs(list) do
		amount = 1 + amount
	end
	return amount
end

function getObjectTileX(obj)
	return math.floor((obj.x+obj.width/2)/getBoardWidth()*mapW) + 1
end

function getObjectTileY(obj)
	return math.floor((obj.y+obj.height/2)/getBoardHeight()*mapH) + 1
end

function checkCollision(x1, y1, w1, h1, x2, y2, w2, h2)
	return x1 < x2 + w2 and
		x2 < x1 + w1 and
		y1 < y2 + h2 and
		y2 < y1 + h1
end

function getBlockAtTilePos(tX, tY)
	for i, block in ipairs(blocks) do
		if(block.mapX == tX and block.mapY == tY) then
			return block
		end
	end
end
