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
	updateBlocks()
	checkCollisions(dt)
end

function love.draw()
	drawHero()
	drawBlocks()
end

function love.keypressed(key, isRepeat)
	if(key == " ") then
		punchBlock()
	end
end

function checkCollisions(dt)
	for i, block in ipairs(blocks) do
		if checkCollision(hero.x, hero.y, hero.width, hero.height, block.x, block.y, block.width, block.height) then
			heroHitBlock(block)
		end
	end
end
