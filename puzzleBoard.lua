--puzzleBoard.lua
require 'block'
require 'boundingBox'

tile = {}
matches = {}

function initPuzzleBoard()
	map = {
	{0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,1,0,0,0},
	{0,0,0,0,0,0,0,0,0,0},
	{0,0,1,0,0,0,0,0,1,0},
	{0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,1,0},
	{0,0,0,0,0,0,1,0,0,0},
	{1,0,0,0,0,0,0,0,0,0},
	{0,0,1,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0},
	{1,0,1,0,1,0,1,0,1,0},
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

function floodFill(x, y, oldColor)
	if map[y][x] == oldColor then
		local _block = getBlockAtTilePos(x, y)
		if not _block.checked then
			table.insert(matches, _block)
			_block.checked = true

			if (x+1) <= mapW then
				floodFill(x+1, y, oldColor) --Check to the right
			end
			if (x-1) > 0 then
				floodFill(x-1, y, oldColor) --Check to the left
			end
			if (y+1) <= mapH then
				floodFill(x, y+1, oldColor) --Check the bottom
			end
			if (y-1) > 0 then
				floodFill(x, y-1, oldColor) --Check the top
			end
		end
	end
end

function createBlocks()
	offsetX = -20
	offsetY = 0

	for y=1, mapH do
		for x=1, mapW do
			if map[y][x] == 1 then
				initBlock(((x-1)*tileW) - offsetX - (tileW/2), ((y-1)*tileH) - offsetY - tileH/2, x, y)
			end
		end
	end
end

function checkForMatches()
	if not dirtyBlocks() then
		for y=1, mapH do
			for x=1, mapW do
				if map[y][x] > 0 then
					floodFill(x, y, map[y][x])
					if size(matches) > 2 then
						for k in pairs(matches) do
							matches[k].state = "matched"
						end	
					end
					for i in pairs(matches) do
						matches[i].checked = false
					end
					matches = {}
				end
			end
		end
	end
end

function dirtyBlocks()
	for i, block in ipairs(blocks) do
		if block.dirty then
			return false
		end
	end
	return true
end

function addRowOfBlocks()
	offsetX = -20--mapX % tileW
	offsetY = 0--mapY % tileH
	for y=1, mapH do
		for x=1, mapW do
			local block = getBlockAtTilePos(x, y);
			if block then
				--startTween(block, block.x, block.y - block.height)
				block.y = block.y - block.height
				map[y][x] = 0;	
				map[y-1][x] = block.mapId;	
				block.mapX = x
				block.mapY = y-1
			end
		end
	end
	for x=1, mapW do
		initBlock(((x-1)*tileW) - offsetX - (tileW/2), ((mapH-1)*tileH) - offsetY - (tileH/2), x, mapH)
	end
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
