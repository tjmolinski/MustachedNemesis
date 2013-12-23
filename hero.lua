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

	if(love.keyboard.isDown(" ")) then
		punchBlock()
	end
end

function moveHero(dx, dy)
	hero.x = hero.x + dx
	hero.y = hero.y + dy
end

function drawHero()
	love.graphics.setColor(255, 0, 0)
	love.graphics.rectangle("fill", hero.x, hero.y, hero.width, hero.height)
	love.graphics.setColor(255, 255, 255)
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
	print("PUNCH")
end
