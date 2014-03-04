--puzzleBoard.lua
require 'utils'

blocks = {}
tile = {}
matches = {}

PuzzleBoard = {}
PuzzleBoard.__index = PuzzleBoard

function PuzzleBoard.create()
  local self = {}
  setmetatable(self, PuzzleBoard)
  self:reset()
  return self
end

function PuzzleBoard:reset()
  for i in pairs(blocks) do
    blocks[i] = nil
  end
  for i in pairs(tile) do
    tile[i] = nil
  end
  for i in pairs(matches) do
    matches[i] = nil
  end
  for i in pairs(particles) do
    particles[i] = nil
  end

  map = {
    {0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0},
    {1,1,1,1,1,1,1},
    {1,1,1,1,1,1,1},
  }

  mapW = #map[1]
  mapH = #map

  tileW = 40
  tileH = 40

  mapDisplayW = mapW * tileW
  mapDisplayH = mapH * tileH

  mapX = 20 --Compensating for the outline
  mapY = love.window.getHeight() - mapDisplayH

  self:createBlocks()
end

function getBoardTop()
  return mapY
end

function getBoardBottom()
  return mapY + mapDisplayH
end

function getBoardRight()
  return mapX + mapDisplayW
end

function getBoardLeft()
  return mapX
end

function PuzzleBoard:createBlocks()
  for y=1, mapH do
    for x=1, mapW do
      if map[y][x] == 1 then
	Block.create(getPixelPositionX(x), getPixelPositionY(y), x, y)
      end
    end
  end
end

function PuzzleBoard:floodFill(x, y, oldColor)
  if map[y][x] == oldColor then
    local _block = getBlockAtTilePos(x, y)
    if _block and not _block.checked then
      table.insert(matches, _block)
      _block.checked = true

      if (x+1) <= mapW then
	self:floodFill(x+1, y, oldColor) --Check to the right
      end
      if (x-1) > 0 then
	self:floodFill(x-1, y, oldColor) --Check to the left
      end
      if (y+1) <= mapH then
	self:floodFill(x, y+1, oldColor) --Check the bottom
      end
      if (y-1) > 0 then
	self:floodFill(x, y-1, oldColor) --Check the top
      end
    end
  end
end

function PuzzleBoard:checkForMatches()
  if not self:fallingBlocks() then
    for y=1, mapH do
      for x=1, mapW do
	if map[y][x] > 0 then
	  self:floodFill(x, y, map[y][x])
	  if size(matches) > 3 then
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

function PuzzleBoard:addRowOfBlocks()
  for y=1, mapH do
    for x=1, mapW do
      local block = getBlockAtTilePos(x, y);
      if block and y==1 then
	gameManager.gameOver = true	
      elseif block then
	map[y][x] = 0;	
	block.lerpX = block.x
	block.lerpY = block.y - block.height
	block.lerping = true
      end
    end
  end
  local bottomY = getPixelPositionY(mapH)
  for x=1, mapW do
    local bottomX = getPixelPositionX(x)
    local block = Block.create(bottomX, bottomY+tileH, x, mapH)
    block.lerpX = bottomX
    block.lerpY = bottomY
    block.lerping = true
  end
end

function PuzzleBoard:fallingBlocks()
  for i, block in ipairs(blocks) do
    if block.state == "falling" then
      return true 
    end
  end
  return false
end

function logBoard()
  for i=1, mapH do
    print(map[i][1]..","..map[i][2]..","..map[i][3]..","..map[i][4]..","..map[i][5]..","..map[i][6]..","..map[i][7])
  end
  print('================================')
end
