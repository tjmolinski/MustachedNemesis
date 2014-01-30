-- main.lua
require 'hero'
require 'puzzleBoard'
require 'block'
require 'boundingBox'

elapsedTime = 0;
blocks = {}
purpleBlock = love.graphics.newImage("block_purple.png")
purpleGhostBlock = love.graphics.newImage("block_purple_ghost.png")
redBlock = love.graphics.newImage("block_red.png")
redGhostBlock = love.graphics.newImage("block_red_ghost.png")
yellowBlock = love.graphics.newImage("block_yellow.png")
yellowGhostBlock = love.graphics.newImage("block_yellow_ghost.png")
blueBlock = love.graphics.newImage("block_blue.png")
blueGhostBlock = love.graphics.newImage("block_blue_ghost.png")
greenBlock = love.graphics.newImage("block_green.png")
greenGhostBlock = love.graphics.newImage("block_green_ghost.png")
local growBuffer = 0;
local growTime = 5;

function love.load(args)
	love.window.setMode(400, 500, {} )
	initHero()
	initPuzzleBoard()
end

function love.update(dt)
	elapsedTime = elapsedTime + dt;
	if growBuffer > growTime then
		growBuffer = 0;
		liftHero()
		addRowOfBlocks()
	else
		growBuffer = growBuffer + dt;
	end
	updateHero(dt)
	for i, block in ipairs(blocks) do
		updateBlock(block, dt)
	end
	checkCollisions(dt)
end

function love.draw()
	drawHero()
	drawBlocks()
end

function love.keypressed(key, isRepeat)
	if key == " " then
		heroAction()
	elseif key == "up" then
		heroJump()
	end
end

function checkCollisions(dt)
	for i, block in ipairs(blocks) do
		if checkCollision(hero.x, hero.y, hero.width, hero.height, block.x, block.y, block.width, block.height) then
			heroHitBlock(block)
		end
	end
end
