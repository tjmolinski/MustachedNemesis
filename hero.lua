--hero.lua
require 'block'

hero = {}

function initHero()
	hero.x = 200
	hero.y = 250
	hero.width = 20
	hero.height = 20 
	hero.speed = 150
	hero.gravity = 59.8
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
	if(love.keyboard.isDown("left")) then
		moveHero(-hero.speed*dt, 0)
	end
	if(love.keyboard.isDown("right")) then
		moveHero(hero.speed*dt, 0)
	end
	if(love.keyboard.isDown("up")) then
		moveHero(0, -hero.speed*dt)
	end
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

function punchBlock()
	local tX = getHeroTileX()
	local tY = getHeroTileY()

	if(tY+1 < mapH and map[tY+1][tX] == 1) then
		--map[tY+1][tX] = map[mapH][tx]
		local cnt = mapH-tY+1
		for px = 0, cnt do
			local firstBlock = getBlockAtTilePos(tX, tY+1+px)
			if firstBlock then
				firstBlock.y = firstBlock.y - firstBlock.height
			end
		end
		local lastBlock = getBlockAtTilePos(tX, tY)
		lastBlock.y = love.window.getHeight() - lastBlock.height
		--print("Hit block: " .. tX .. ":" .. (tY+1))
	end
end

function getHeroTileX()
	return math.floor((hero.x+hero.width/2)/love.window.getWidth()*mapW) + 1
end

function getHeroTileY()
	return math.floor((hero.y+hero.height/2)/love.window.getHeight()*mapH) + 1
end
