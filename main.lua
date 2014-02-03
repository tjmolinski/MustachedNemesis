-- main.lua
require 'hero'
require 'puzzleBoard'
require 'block'
require 'boundingBox'
require 'gameManager'
require 'utils'

function love.load(args)
	initGame()
	initHero()
	initPuzzleBoard()
end

function love.update(dt)
	if not paused and not gameOver then
		updateGame(dt)
		updateHero(dt)
		for i, block in ipairs(blocks) do
			updateBlock(block, dt)
		end
	end
end

function love.keypressed(key, isRepeat)
	keyPressedGame(key, isRepeat)
	keyPressedHero(key, isRepeat)
end

function love.draw()
	if gameOver then
		drawGameOver()
	else
		if paused then
			drawPaused()
		end
		drawHero()
		drawBlocks()
	end
end
