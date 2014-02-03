gameOver = false 
paused = false
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

function initGame()
	love.window.setMode(400, 440, {})
	love.graphics.setFont(love.graphics.newFont(20))
end

function updateGame(dt)
	elapsedTime = elapsedTime + dt
	if growBuffer > growTime then
		growBuffer = 0
		liftHero()
		addRowOfBlocks()
	else
		growBuffer = growBuffer + dt
	end
end

function keyPressedGame(key, isRepeat)
	if key == "p" then
		paused = not paused
	end
end

function drawGameOver()
	love.graphics.print("GAME OVER", 100, 100)
	love.graphics.print("Close and restart", 100, 200)
	love.graphics.print("Yes real intuitive...", 10, 300)
end

function drawPaused()
	love.graphics.print("PAUSED", 150, 200)
end
