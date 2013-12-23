--puzzleBoard.lua
require 'block'

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
	{0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,1,1,0,0,0,0},
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

	drawMap()
end

function drawMap()
	offsetX = -20--mapX % tileW
	offsetY = 0--mapY % tileH
	firstTileX = math.floor(mapX / tileW)
	firstTileY = math.floor(mapY / tileH)

	for y=1, mapH do
		for x=1, mapW do
			if map[y][x] == 1 then
				initBlock(((x-1)*tileW) - offsetX - tileW/2, ((y-1)*tileH) - offsetY - tileH/2)
			end
		end
	end
end
