function size(list)
  local amount = 0
  for tble in pairs(list) do
    amount = 1 + amount
  end
  return amount
end

function padPoints(val)
  if val < 10 then
    return "00000"..val
  elseif val < 100 then
    return "0000"..val
  elseif val < 1000 then
    return "000"..val
  elseif val < 10000 then
    return "00"..val
  elseif val < 100000 then
    return "0"..val
  else
    return val
  end
end

function getPixelPositionY(y)
  return mapY + ((y-1) * tileH)
end

function getPixelPositionX(x)
  return mapX + ((x-1) * tileW)
end

function getObjectTileLeftMostX(obj)
  return math.floor(((obj.x-mapX)/tileW)+1)
end

function getObjectTileRightMostX(obj)
  return math.floor((((obj.x+obj.width+1)-mapX)/tileW)+1)
end

function getObjectTileX(obj)
  return math.floor((((obj.x+(obj.width/2))-mapX)/tileW)+1)
end

function getObjectTileTopMostY(obj)
  return math.floor(((obj.y-mapY)/tileH)+1)
end

function getObjectTileBottomMostY(obj)
  return math.floor((((obj.y+obj.height-1)-mapY)/tileH)+1)
end

function getObjectTileY(obj)
  return math.floor((((obj.y+(obj.height/2))-mapY)/tileH)+1)
end

function getCorners(x, y, ob)
  local obj = ob
  obj.x = x
  obj.y = y
  local downY = getObjectTileBottomMostY(obj)
  local upY = getObjectTileTopMostY(obj)
  local leftX = getObjectTileLeftMostX(obj)
  local rightX = getObjectTileRightMostX(obj)

  ob.upleft = map[upY][leftX] == 0
  ob.downleft = map[downY][leftX] == 0
  ob.upright = map[upY][rightX] == 0
  ob.downright = map[downY][rightX] == 0
end

function checkCollision(x1, y1, w1, h1, x2, y2, w2, h2)
  return x1 < x2 + w2 and
  x2 < x1 + w1 and
  y1 < y2 + h2 and
  y2 < y1 + h1
end

function getBlockAtTilePos(tX, tY)
  for i, block in ipairs(blocks) do
    if(block.mapX == tX and block.mapY == tY) then
      return block
    end
  end
end

function lerp(start, finish, amount)
  if start == finish then 
    return start
  end
  return ((1 - amount) * start) + (amount * finish)
end
