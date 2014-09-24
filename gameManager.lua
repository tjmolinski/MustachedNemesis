--gameManager.lua
require('block')

GameManager = {}
GameManager.__index = GameManager

purpleBlock = love.graphics.newImage("gfx/block_purple.png")
purpleGhostBlock = love.graphics.newImage("gfx/block_purple_ghost.png")
redBlock = love.graphics.newImage("gfx/block_red.png")
redGhostBlock = love.graphics.newImage("gfx/block_red_ghost.png")
yellowBlock = love.graphics.newImage("gfx/block_yellow.png")
yellowGhostBlock = love.graphics.newImage("gfx/block_yellow_ghost.png")
blueBlock = love.graphics.newImage("gfx/block_blue.png")
blueGhostBlock = love.graphics.newImage("gfx/block_blue_ghost.png")
greenBlock = love.graphics.newImage("gfx/block_green.png")
greenGhostBlock = love.graphics.newImage("gfx/block_green_ghost.png")
hintReticule = love.graphics.newImage("gfx/hint_reticule.png")
greyBlock = love.graphics.newImage("gfx/block_grey.png")

function GameManager.create()
  local self = {}
  setmetatable(self, GameManager)
  self:init()
  self:reset()
  return self
end

function GameManager:init()
  love.window.setMode(800, 600, {})
  love.graphics.setFont(love.graphics.newFont(20))
end

function GameManager:reset()
  self.growBuffer = 0
  self.growTime = 5
  self.paused = false
  self.gameOver = false
  self.elapsedTime = 0
end

function GameManager:update(dt)
  if self.gameOver == true then
    self:updateGameOver(dt)
  else
    self:updateGamePlay(dt)
  end
end

function GameManager:updateGameOver(dt)
  if love.keyboard.isDown(" ") then
    print("reset")
    gameManager:reset()
    puzzleBoard:reset()
    hero:reset()
  end
end

function GameManager:updateGamePlay(dt)
    self.elapsedTime = self.elapsedTime + dt
    if self.growBuffer > self.growTime then
      self.growBuffer = 0
      puzzleBoard:addRowOfBlocks()
    else
      self.growBuffer = self.growBuffer + dt
    end
end

function GameManager:keyPressed(key, isRepeat)
  if key == "p" then
    self.paused = not self.paused
  end
end

function GameManager:drawUI()
  love.graphics.setColor(255,255,255)
  love.graphics.print("Points:", 0, mapY-40)
  love.graphics.print(padPoints(hero.points), getBoardRight()-60, mapY-40)
end

function GameManager.drawGameOver()
  love.graphics.print("GAME OVER", 100, 100)
  love.graphics.print("Spacebar to restart", 100, 200)
end

function GameManager.drawPaused()
  love.graphics.print("PAUSED", 150, 200)
end
