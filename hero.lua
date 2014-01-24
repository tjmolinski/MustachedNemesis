--hero.lua
require 'block'
require 'puzzleBoard'

hero = {}

function initHero()
	hero.x = 200
	hero.y = 250
	hero.vx = 0
	hero.vy = 0
	hero.width = 20
	hero.height = 20 
	hero.speed = 700
	hero.jumpSpeed = 300
	hero.friction = 0.1
	hero.airFriction = 0.1
	hero.gravity = 280
	hero.direction = 0
	hero.jumping = false
	hero.onGround = false
	hero.state = "idle"
	hero.heldObject = nil
	hero.slamSpeed = 200000
	hero.slamming = false
end

function liftHero()
	hero.y = hero.y - block.height
end

function updateHero(dt)
	if hero.slamming then
		handleSlam(dt)
	else
		handleInput(dt)
		handlePhysics(dt)
	end
end

function handleSlam(dt)
	hero.vx = 0
	hero.vy = hero.slamSpeed * dt

	if hero.y >= love.window.getHeight() - hero.height then
		hero.y = love.window.getHeight() - hero.height
		hero.jumping = false
		hero.onGround = true
	end
	
	if hero.onGround then
		hero.slamming = false
	end

	moveHero(hero.vx * dt, hero.vy * dt)
end

function handlePhysics(dt)
	moveHero(hero.vx * dt, hero.vy * dt)

	hero.vx = hero.vx * math.pow(hero.friction, dt)

	if hero.jumping then
		hero.vy = hero.vy * math.pow(hero.airFriction, dt)
		if hero.vy >= -5.0 then
			hero.jumping = false
		end
	elseif not hero.onGround then
		hero.vy = hero.vy + (hero.gravity * dt)
	end

	if hero.y >= love.window.getHeight() - hero.height then
		hero.y = love.window.getHeight() - hero.height
		if not hero.onGround then
			hero.vx = 0
		end
		hero.jumping = false
		hero.onGround = true
	end
	if hero.x <= 0 then
		hero.x = 0
		hero.vx = 0
	end
	if hero.x >= love.window.getWidth() - hero.width then
		hero.x = love.window.getWidth() - hero.width
		hero.vx = 0
	end
end

function handleInput(dt)
	if love.keyboard.isDown("left") then
		hero.vx = hero.vx - (hero.speed * dt)
		hero.direction = -1
	end
	if love.keyboard.isDown("right") then
		hero.vx = hero.vx + (hero.speed * dt)
		hero.direction = 1
	end
	if love.keyboard.isDown("down") then
		hero.direction = 0
		if not hero.onGround then
			--hero.slamming = true
		end
	end
end

function heroJump()
	if not hero.jumping then
		hero.jumping = true
		hero.onGround = false
		hero.vy = -hero.jumpSpeed
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
	hero.slamming = false
	if block.state == "lifted" then
		--DO BETTER
	elseif(block.y > hero.y) then
		hero.y = block.y - hero.height
		hero.vy = 0
	elseif(block.x < hero.x) then
		hero.x = block.x + block.width
		hero.vx = 0
	elseif(block.x > hero.x) then
		hero.x = block.x - hero.width
		hero.vx = 0
	end
end

function heroAction()
	if hero.state == "idle" then
		if hero.direction == 0 then --lift block below
			grabBelow()
		elseif hero.direction == 1 then --lift block right
			grabRight()
		elseif hero.direction == -1 then --lift block left
			grabLeft()
		end
	elseif hero.state == "holding" then
		if hero.direction == 0 then --drop block below
			dropBelow()
		elseif hero.direction == 1 then --drop block right
			dropRight()
		elseif hero.direction == -1 then --drop block left
			dropLeft()
		end
	end
end

function dropBelow()
	if hero.heldObject then
		dropBlock(hero.heldObject)
		hero.state = "idle"
	end
end

function dropRight()
	local _block = getBlockAtTilePos(getHeroTileX()+1, getHeroTileY())
	if (not _block) and hero.heldObject and getHeroTileX() + 1 <= mapW then
		dropBlockRight(hero.heldObject)
		hero.state = "idle"
	end
end

function dropLeft()
	local _block = getBlockAtTilePos(getHeroTileX()-1, getHeroTileY())
	if (not _block) and hero.heldObject and getHeroTileX() - 1 > 0 then
		dropBlockLeft(hero.heldObject)
		hero.state = "idle"
	end
end

function grabBelow()
	local _block = getBlockAtTilePos(getHeroTileX(), getHeroTileY()+1)
	if _block then
		hero.heldObject = _block
		liftBlock(_block)
		hero.state = "holding"
	end
end

function grabLeft()
	local _block = getBlockAtTilePos(getHeroTileX()-1, getHeroTileY())
	if _block then
		hero.heldObject = _block
		liftBlock(_block)
		hero.state = "holding"
	end
end

function grabRight()
	local _block = getBlockAtTilePos(getHeroTileX()+1, getHeroTileY())
	if _block then
		hero.heldObject = _block
		liftBlock(_block)
		hero.state = "holding"
	end
end

function getHeroTileX()
	return math.floor((hero.x+hero.width/2)/love.window.getWidth()*mapW) + 1
end

function getHeroTileY()
	return math.floor((hero.y+hero.height/2)/love.window.getHeight()*mapH) + 1
end
