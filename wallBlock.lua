--wallBlock.lua

WallBlock = {}
WallBlock.__index = WallBlock

function WallBlock.create(newX, newY, mapX, mapY)
  local self = {}
  setmetatable(self, WallBlock)
  self.width = 40
  self.height = 40
  self.x = newX
  self.y = newY
  self.mapX = mapX
  self.mapY = mapY
  table.insert(wallBlocks, self)
  return self
end

function WallBlock:draw()
  love.graphics.draw(greyBlock, self.x, self.y)
end
