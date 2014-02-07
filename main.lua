-- main.lua
require('hero')
require('puzzleBoard')
require('block')
require('gameManager')
require('utils')

blocks = {}
hero = nil

function love.load(args)
	gameManager = GameManager.create()
	puzzleBoard = PuzzleBoard.create()
	hero = Hero.create()
end

function love.update(dt)
	if gameManager.paused or gameManager.gameOver then
		return
	end

	gameManager:update(dt)
	hero:update(dt)
	for i, block in ipairs(blocks) do
		block:update(dt)
	end
end

function love.keypressed(key, isRepeat)
	gameManager:keyPressed(key, isRepeat)
	hero:keyPressed(key, isRepeat)
end

function love.draw()
	if gameManager.gameOver then
		gameManager:drawGameOver()
	else
		if gameManager.paused then
			gameManager:drawPaused()
		end
		hero:draw()
		for i, block in ipairs(blocks) do
			block:draw()
		end
	end
end

function love.quit()
	--saving could go here
end

function love.focus(f)
	--pausing could go here
end
