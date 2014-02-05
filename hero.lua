--hero.lua
require 'block'
require 'puzzleBoard'
require 'utils'

hero = {}

function initHero()
	hero.x = 200
	hero.y = 250
	hero.vx = 0
	hero.vy = 0
	hero.width = 20
	hero.height = 20 
	hero.speed = 700
	hero.jumpSpeed = 500
	hero.friction = 0.1
	hero.airFriction = 0.01
	hero.gravity = 280
	hero.direction = 0
	hero.jumping = false
	hero.onGround = false
	hero.state = "idle"
	hero.heldObject = nil
	hero.slamSpeed = 100000
	hero.slamming = false
	hero.slamBuffer = 0
	hero.preSlamTime = 0.25
end

function liftHero()
	hero.y = hero.y - block.height
end

function keyPressedHero(key, isRepeat)
	if key == " " then
		heroAction()
	elseif key == "up" then
		heroJump()
	end
end

function updateHero(dt)
	handleCollisions(dt)
	if hero.slamming then
		handleSlam(dt)
	else
		handleInput(dt)
		handlePhysics(dt)
	end
end

function handleSlam(dt)
	hero.slamBuffer = hero.slamBuffer + dt
	if hero.slamBuffer > hero.preSlamTime then
		hero.vx = 0
		hero.vy = hero.slamSpeed * dt

		if hero.y >= getBoardHeight() - hero.height then
			hero.y = getBoardHeight() - hero.height
			hero.jumping = false
			hero.onGround = true
		end
		
		if hero.onGround then
			hero.slamming = false
			hero.slamBuffer = 0
		else
			moveHero(hero.vx * dt, hero.vy * dt)
		end
	end
end

function handlePhysics(dt)
	moveHero(hero.vx * dt, hero.vy * dt)

	hero.vx = hero.vx * math.pow(hero.friction, dt)

	if hero.jumping then
		hero.vy = hero.vy * math.pow(hero.airFriction, dt)
		if hero.vy >= -50.0 then
			hero.jumping = false
		end
	elseif not hero.onGround then
		hero.vy = hero.vy + (hero.gravity * dt)
	end

	if hero.y >= getBoardHeight() - hero.height then
		hero.y = getBoardHeight() - hero.height
		hero.jumping = false
		hero.onGround = true
	end
	if hero.x <= 0 then
		hero.x = 0
		hero.vx = 0
	end
	if hero.x >= getBoardWidth() - hero.width then
		hero.x = getBoardWidth() - hero.width
		hero.vx = 0
	end
	if hero.state == "holding" then
		if hero.y <= tileH then
			hero.y = tileH
		end
	else
		if hero.y <= 0 then
			hero.y = 0
		end
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
			hero.slamming = true
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
	drawHintReticule()
end

function drawHintReticule()
	if hero.state == "holding" then
		local myX = getObjectTileX(hero)
		local myY = getObjectTileY(hero)
		local _block = getClosestBlockBelow(myX+hero.direction, myY)
		local posX
		local posY

		if _block then
			posX = _block.x
			posY = _block.y - _block.height
		else
			posX = (myX - 1 + hero.direction) * tileW
			posY = getBoardHeight() - block.height
		end

		--Why does hero draw hint blocks...
		if hero.heldObject.mapId == 1 then
			love.graphics.draw(blueGhostBlock, posX, posY)
		elseif hero.heldObject.mapId == 2 then
			love.graphics.draw(greenGhostBlock, posX, posY)
		elseif hero.heldObject.mapId == 3 then
			love.graphics.draw(purpleGhostBlock, posX, posY) 
		elseif hero.heldObject.mapId == 4 then
			love.graphics.draw(redGhostBlock, posX, posY)
		else
			love.graphics.draw(yellowGhostBlock, posX, posY)
		end
	end
end

function getClosestBlockBelow(myX, myY)
	local spaces = mapH - myY
	for i=1, spaces do
		local _block = getBlockAtTilePos(myX, myY+i)
		if _block then 
			return _block
		 end
	end	
end

function heroHitBlock(block)
	hero.slamming = false
	hero.slamBuffer = 0
	hero.onGround = true
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

function handleCollisions(dt)
	local hit = false
	for i, block in ipairs(blocks) do
		if checkCollision(hero.x, hero.y, hero.width, hero.height, block.x, block.y, block.width, block.height) then
			heroHitBlock(block)
			hit = true
		end
	end

	if not hit then
		hero.onGround = false
	end
end

function dropBelow()
	if hero.heldObject then
		dropBlock(hero.heldObject)
		hero.state = "idle"
	end
end

function dropRight()
	local _block = getBlockAtTilePos(getObjectTileX(hero)+1, getObjectTileY(hero))
	if (not _block) and hero.heldObject and getObjectTileX(hero) + 1 <= mapW then
		dropBlockRight(hero.heldObject)
		hero.state = "idle"
	end
end

function dropLeft()
	local _block = getBlockAtTilePos(getObjectTileX(hero)-1, getObjectTileY(hero))
	if (not _block) and hero.heldObject and getObjectTileX(hero) - 1 > 0 then
		dropBlockLeft(hero.heldObject)
		hero.state = "idle"
	end
end

function grabBelow()
	local _block = getBlockAtTilePos(getObjectTileX(hero), getObjectTileY(hero)+1)
	if _block then
		hero.heldObject = _block
		liftBlock(_block)
		hero.state = "holding"
	end
end

function grabLeft()
	local _block = getBlockAtTilePos(getObjectTileX(hero)-1, getObjectTileY(hero))
	if _block then
		hero.heldObject = _block
		liftBlock(_block)
		hero.state = "holding"
	end
end

function grabRight()
	local _block = getBlockAtTilePos(getObjectTileX(hero)+1, getObjectTileY(hero))
	if _block then
		hero.heldObject = _block
		liftBlock(_block)
		hero.state = "holding"
	end
end
