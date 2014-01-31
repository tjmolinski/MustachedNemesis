--puzzleBoard.lua
require 'block'
require 'boundingBox'

tile = {}
matches = {}

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
	{1,1,1,1,1,1,1,1,1,1},
	{1,1,1,1,1,1,1,1,1,1},
	{1,1,1,1,1,1,1,1,1,1},
	}

	mapW = #map[1]
	mapH = #map

	tileW = 40
	tileH = 40

	mapDisplayW = mapW * tileW
	mapDisplayH = mapH * tileH

	mapX = 0
	mapY = 0--love.window.getHeight()-mapDisplayH

	createBlocks()
end

function getBoardHeight()
	return mapY + mapDisplayH
end

function getBoardWidth()
	return mapX + mapDisplayW
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
function checkForHorizontalMatches(x, y)
	local tempMatches = {}
        for ty=y, mapH do
                local color = map[ty][x]
                local tempMatches = {}
                for tx=x+1, mapW do
			if ty > 0 then
				if color == map[ty][tx] and color > 0 then
					table.insert(tempMatches, tx)
					table.insert(tempMatches, ty)
				else
					break
				end
			end
                end
                for tx=0, x do
			if y-ty > 0 and y-ty <= mapH then
				if color == map[ty][x-tx] and color > 0 then
					table.insert(tempMatches, x-tx)
					table.insert(tempMatches, ty)
				else
					break
				end
			end
                end
                if size(tempMatches) > 5 then
                        for idx=1, size(tempMatches) do
                                if idx % 2 > 0 then
                                        local _block = getBlockAtTilePos(tempMatches[idx],tempMatches[idx+1])
					table.insert(matches, _block)
                                end
                        end
                end
        end
end

function checkForVerticalMatches(x, y)
	local tempMatches = {}
        for tx=x, mapW do
                local color = map[y][tx]
                local tempMatches = {}
                for ty=y+1, mapH do
			if ty > 0 then
				if color == map[ty][tx] and color > 0 then
					table.insert(tempMatches, tx)
					table.insert(tempMatches, ty)
				else
					break
				end
                        end
                end
                for ty=0, y do
			if y-ty > 0 and y-ty <= mapH then
				if color == map[y-ty][tx] and color > 0 then
					table.insert(tempMatches, tx)
					table.insert(tempMatches, y-ty)
				else
					break
				end
                        end
                end
                if size(tempMatches) > 5 then
                        for idx=1, size(tempMatches) do
                                if idx % 2 ~= 0 then
                                        local _block = getBlockAtTilePos(tempMatches[idx],tempMatches[idx+1])
					table.insert(matches, _block)
                                end
                        end
                end
        end
end

function checkForMatches()
	if not fallingBlocks() then
	--if dirtyBlocks() then
		for y=1, mapH do
			for x=1, mapW do
				if map[y][x] > 0 then
					checkForHorizontalMatches(x, y)
					checkForVerticalMatches(x, y)
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
	--end 
	end
end

function fallingBlocks()
	for i, block in ipairs(blocks) do
		if block.state ~= "idle" and block.state ~= "lifted" then
			return true 
		end
	end
	return false
end

function dirtyBlocks()
	for i, block in ipairs(blocks) do
		if block.dirty then
			return true 
		end
	end
	return false
end

function addRowOfBlocks()
	offsetX = -20--mapX % tileW
	offsetY = 0--mapY % tileH
	for y=1, mapH do
		for x=1, mapW do
			local block = getBlockAtTilePos(x, y);
			if block and y==1 then
				gameOver = true	
			elseif block then
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
