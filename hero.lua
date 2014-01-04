--hero.lua
require 'block'
require 'puzzleBoard'

hero = {}

function initHero()
	hero.x = 200
	hero.y = 250
	hero.width = 20
	hero.height = 20 
	hero.speed = 150
	hero.jumpSpeed = 40
	hero.gravity = 99.8
	hero.direction = 0
end

function liftHero()
	hero.y = hero.y - block.height
end

function updateHero(dt)
	handleInput(dt)
	handlePhysics(dt)
end

function handlePhysics(dt)
	if(hero.y >= love.window.getHeight() - hero.height) then
		hero.y = love.window.getHeight() - hero.height
	else
		hero.y = hero.y + hero.gravity * dt
	end
end

function handleInput(dt)
	if love.keyboard.isDown("left") then
		moveHero(-hero.speed*dt, 0)
		hero.direction = -1
	end
	if love.keyboard.isDown("right") then
		moveHero(hero.speed*dt, 0)
		hero.direction = 1
	end
	if love.keyboard.isDown("down") then
		hero.direction = 0
	end
end

function heroJump()
	moveHero(0, -hero.jumpSpeed)
end

function moveHero(dx, dy)
	hero.x = hero.x + dx
	hero.y = hero.y + dy
end

function drawHero()
	local pr, pg, pb, pa = love.graphics.getColor()
	love.graphics.setColor(255, 0, 0)
	love.graphics.rectangle("fill", hero.x, hero.y, hero.width, hero.height)
	love.graphics.setColor(pr, pg, pb, pa)
end

function heroHitBlock(block)
	if(block.y > hero.y) then
		hero.y = block.y - hero.height
	elseif(block.x < hero.x) then
		hero.x = block.x + block.width
	elseif(block.x > hero.x) then
		hero.x = block.x - hero.width
	end
end

function punchBlockRight()
	local tX = getHeroTileX()
	local tY = getHeroTileY()

	if(tX+1 < mapW and map[tY][tX+1] > 0) then
		local cnt = mapW-tX+1
		for px = 0, cnt do
			local firstBlock = getBlockAtTilePos(tX+1+px, tY)
			if firstBlock then
				startTween(firstBlock, firstBlock.x - firstBlock.width, firstBlock.y)
				map[tY][tX+1+px] = 0
				map[tY][tX+px] = firstBlock.mapId
				firstBlock.mapX = tX+px
				firstBlock.mapY = tY
			end
		end
		local lastBlock = getBlockAtTilePos(tX, tY)
		startTween(lastBlock, love.window.getWidth() - lastBlock.width, lastBlock.y)
		map[tY][tX] = 0
		map[tY][mapW] = lastBlock.mapId
		lastBlock.mapX = mapW
		lastBlock.mapY = tY

		checkForMatches()
	end
	logBoard()
end

function punchBlockLeft()
	local tX = getHeroTileX()
	local tY = getHeroTileY()

	if(tX-1 > 0 and map[tY][tX-1] > 0) then
		local cnt = tX-1
		for px = 0, cnt do
			local firstBlock = getBlockAtTilePos(tX-1-px, tY)
			if firstBlock then
				startTween(firstBlock, firstBlock.x + firstBlock.width, firstBlock.y)
				map[tY][tX-1-px] = 0
				map[tY][tX-px] = firstBlock.mapId
				firstBlock.mapX = tX-px
				firstBlock.mapY = tY
			end
		end
		local lastBlock = getBlockAtTilePos(tX, tY)
		startTween(lastBlock, 0, lastBlock.y)
		map[tY][tX] = 0
		map[tY][1] = lastBlock.mapId
		lastBlock.mapX = 1
		lastBlock.mapY = tY

		checkForMatches()
	end
	logBoard()
end

function punchBlockDown()
	local tX = getHeroTileX()
	local tY = getHeroTileY()

	if(tY+1 < mapH and map[tY+1][tX] > 0) then
		local cnt = mapH-tY+1
		for px = 0, cnt do
			local firstBlock = getBlockAtTilePos(tX, tY+px+1)
			if firstBlock then
				startTween(firstBlock, firstBlock.x, firstBlock.y - firstBlock.height)
				map[tY+px+1][tX] = 0
				map[tY+px][tX] = firstBlock.mapId
				firstBlock.mapX = tX
				firstBlock.mapY = tY+px
			end
		end
		local lastBlock = getBlockAtTilePos(tX, tY)
		startTween(lastBlock, lastBlock.x, love.window.getHeight() - lastBlock.height)
		map[tY][tX] = 0
		map[mapH][tX] = lastBlock.mapId
		lastBlock.mapX = tX
		lastBlock.mapY = mapH

		checkForMatches()
	end
	logBoard()
end

function getHeroTileX()
	return math.floor((hero.x+hero.width/2)/love.window.getWidth()*mapW) + 1
end

function getHeroTileY()
	return math.floor((hero.y+hero.height/2)/love.window.getHeight()*mapH) + 1
end
