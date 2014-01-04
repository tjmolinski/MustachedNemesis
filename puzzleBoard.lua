--puzzleBoard.lua
require 'block'
require 'boundingBox'

tile = {}

function initPuzzleBoard()
	map = {
	{0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,1,0,0,0,0,0},
	{0,0,1,0,1,0,0,0,0,0},
	{1,1,1,1,1,1,0,0,0,0},
	{1,1,1,1,1,1,1,0,1,1},
	}

	mapW = #map[1]
	mapH = #map
	mapX = 0
	mapY = 0

	mapDisplayW = 400
	mapDisplayH = 500 
	tileW = 40
	tileH = 40

	createBlocks()
end

function createBlocks()
	offsetX = -20--mapX % tileW
	offsetY = 0--mapY % tileH

	for y=1, mapH do
		for x=1, mapW do
			if map[y][x] == 1 then
				initBlock(((x-1)*tileW) - offsetX - tileW/2, ((y-1)*tileH) - offsetY - tileH/2, x, y)
			end
		end
	end
end

function checkForMatches()
	for y=1, mapH do
		for x=1, mapW do
			if map[y][x] > 0 then
				checkForVerticalMatches(x, y)
				--checkForHorizontalMatches(x, y)
			end
		end
	end
end

function checkForHorizontalMatches(x, y)
	local matches = {}
	for ty=y, mapH do
		local color = map[ty][x]
		local tempMatches = {}
		for tx=x+1, mapW do
			if color == map[ty][tx] and color > 0 then
				table.insert(tempMatches, tx)
				table.insert(tempMatches, ty)
			else
				break
			end
		end
		for tx=0, x do
			if color == map[ty][x-tx] and color > 0 then
				table.insert(tempMatches, x-tx)
				table.insert(tempMatches, ty)
			else
				break
			end
		end
		if size(tempMatches) > 5 then
			for idx=1, size(tempMatches) do
				if idx % 2 > 0 then
					local tempBlock = getBlockAtTilePos(tempMatches[idx],tempMatches[idx+1])
					--print("pair :"..math.floor((tempMatches[idx]))..":"..(tempMatches[idx+1]))
					removeBlock(tempBlock) 
				end
			end
		end
	end
end

function checkForVerticalMatches(x, y)
	local matches = {}
	for tx=x, mapW do
		local color = map[y][tx]
		local tempMatches = {}
		for ty=y+1, mapH do
			if color == map[ty][tx] and color > 0 then
				table.insert(tempMatches, tx)
				table.insert(tempMatches, ty)
				print("find:"..tx.." "..ty)
			else
				break
			end
		end
		for ty=0, y do
			if color == map[y-ty][tx] and color > 0 then
				table.insert(tempMatches, tx)
				table.insert(tempMatches, y-ty)
				print("find:"..tx.." "..y-ty)
			else
				break
			end
		end
		if size(tempMatches) > 5 then
			for idx=1, size(tempMatches) do
				if idx % 2 > 0 then
					local tempBlock = getBlockAtTilePos(tempMatches[idx],tempMatches[idx+1])
					--print("pair :"..math.floor((tempMatches[idx]))..":"..(tempMatches[idx+1]))
					removeBlock(tempBlock) 
				end
			end
		end
	end
end

function addRowOfBlocks()
	offsetX = -20--mapX % tileW
	offsetY = 0--mapY % tileH
	for y=1, mapH do
		for x=1, mapW do
			local block = getBlockAtTilePos(x, y);
			if block then
				startTween(block, block.x, block.y - block.height)
				map[y][x] = 0;	
				map[y-1][x] = block.mapId;	
				block.mapX = x
				block.mapY = y-1
			end
		end
	end
	for x=1, mapW do
		initBlock(((x-1)*tileW) - offsetX - tileW/2, ((mapH-1)*tileH) - offsetY - tileH/2, x, mapH)
	end
	logBoard()
end

function logBoard()
	for y=1, mapH do
		print(map[y][1].." "..map[y][2].." "..map[y][3].." "..map[y][4].." "..map[y][5].." "..map[y][6].." "..map[y][7].." "..map[y][8].." "..map[y][9].." "..map[y][10])
	end
	print("=======================================")
end

function size(tble)
	local cnt = 0
	for tble in pairs(tble) do
		cnt = 1 + cnt
	end
	return cnt
end
