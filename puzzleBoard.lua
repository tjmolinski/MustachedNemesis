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

function checkForDownMatches(x, y)
	local matches = {}
	for ty=y, mapH do
		local color = map[ty][x]
		local tempMatches = {}
		for tx=x+1, mapW do
			if color == map[ty][tx] then
				table.insert(tempMatches, (ty*mapH)+tx)
			else
				break
			end
		end
		for tx=0, x do
			if color == map[ty][x-tx] then
				table.insert(tempMatches, (ty*mapH)+(x-tx))
			else
				break
			end
		end
		if size(tempMatches) > 2 then
			--table.insert(matches, tempMatches)
			print("Pairs found")
			for idx=1, size(tempMatches) do
				local tempBlock = getBlockAtTilePos(tempMatches[idx]%mapH,math.floor(tempMatches[idx]/mapH))
				removeBlock(tempBlock) 
				print("pair :"..math.floor((tempMatches[idx]/mapH))..":"..(tempMatches[idx]%mapH))
			end
			print("End pairs found")
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
	for x=1, mapH do
		initBlock(((x-1)*tileW) - offsetX - tileW/2, ((mapH-1)*tileH) - offsetY - tileH/2, x, mapH)
	end
end

function size(tble)
	local cnt = 0
	for tble in pairs(tble) do
		cnt = 1 + cnt
	end
	return cnt
end
