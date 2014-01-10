-- main.lua
require 'hero'
require 'puzzleBoard'
require 'block'
require 'boundingBox'

elapsedTime = 0;
blocks = {}
purpleBlock = love.graphics.newImage("block_purple.png")
redBlock = love.graphics.newImage("block_red.png")
yellowBlock = love.graphics.newImage("block_yellow.png")
blueBlock = love.graphics.newImage("block_blue.png")
greenBlock = love.graphics.newImage("block_green.png")
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
		checkForMatches()
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
		checkForMatches()
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
