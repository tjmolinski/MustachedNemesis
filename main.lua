-- main.lua
require 'hero'
require 'puzzleBoard'
require 'block'
require 'boundingBox'

function love.load(args)
	love.window.setMode(400, 500, {} )
	initHero()
	initPuzzleBoard()
end

function love.update(dt)
	updateHero(dt)
	checkCollisions(dt)
end

function love.draw()
	drawHero()
	drawBlocks()
end

function checkCollisions(dt)
	for i, block in ipairs(blocks) do
		if checkCollision(hero.x, hero.y, hero.width, hero.height, block.x, block.y, block.width, block.height) then
			heroHitBlock(block)
		end
	end
end
