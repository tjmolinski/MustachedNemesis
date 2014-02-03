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
