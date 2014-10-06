-- main.lua
require('hero')
require('puzzleBoard')
require('block')
require('gameManager')
require('utils')

screen_shake = 0
particles = {}
src1 = love.audio.newSource("sfx/main_song.wav")

function love.load(args)
  gameManager = GameManager.create()
  puzzleBoard = PuzzleBoard.create()
  hero = Hero.create()
  src1:setVolume(0.9)
  src1:setLooping(true)
  src1:play()
end

function love.update(dt)
  if gameManager.paused then return end

  if screen_shake > 0 then
    screen_shake = screen_shake - dt
  end

  gameManager:update(dt)
  if not gameManager.gameOver then
    for i, block in ipairs(blocks) do
      block:update(dt)
    end
    for i, particle in ipairs(particles) do
      particle:update(dt)
    end
    hero:update(dt)
  end
end

function love.keypressed(key, isRepeat)
  gameManager:keyPressed(key, isRepeat)
  hero:keyPressed(key, isRepeat)
end

function love.draw()
  if screen_shake > 0 then
    love.graphics.translate(10*(math.random()-0.5),10*(math.random()-0.5))
  end
  if gameManager.gameOver then
    gameManager:drawGameOver()
  else
    if gameManager.paused then
      gameManager:drawPaused()
    end
    gameManager:drawUI()
    for i, block in ipairs(blocks) do
      block:draw()
    end
    for i, wallBlock in ipairs(wallBlocks) do
      wallBlock:draw()
    end
    for i, particle in ipairs(particles) do
      particle:draw()
    end
    hero:draw()
  end
end

function love.quit()
  --saving could go here
end

function love.focus(f)
  --pausing could go here
end
