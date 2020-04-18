---------
-- Module for managing coordanites in opencomputers.
-- @module coords
-- @author Ulisse Mini
-- @license MIT


-- Imports
local robot = require('robot')

--- The entire API lives in here.
local t = {}
setmetatable(t, { __index = robot })

--- Our current coordanites.
local c = {
  x = 0,   -- Current X
  y = 0,   -- Current Y
  z = 0,   -- Current Z
  ori = 0, -- Current orientation, 0-3
}
t.c = c

-- The delta for different orientations.
local delta = {
  [0] = function() c.z = c.z - 1 end,
  [1] = function() c.x = c.x + 1 end,
  [2] = function() c.z = c.z + 1 end,
  [3] = function() c.x = c.x - 1 end
}

function t.turnRight()
  robot.turnRight()
  c.ori = (c.ori + 1) % 4
end

function t.turnLeft()
  robot.turnLeft()
  c.ori = (c.ori - 1) % 4
end

--- Create a new move function.
-- Afterwards the return value of moveFn will be returned.
-- @tparam function moveFn A function that returns a bool after moving the t.
-- @tparam function fn The function to be called if moveFn returns true.
local function move(moveFn, fn)
  return function(...)
    local b = moveFn(...)

    if b then fn() end
    return b
  end
end

-- Move functions
t.forward = move(robot.forward, function() delta[c.ori]() end)
t.back    = move(robot.back, function() delta[c.ori]() end)
t.up      = move(robot.up,   function() c.y = c.y + 1 end)
t.down    = move(robot.down, function() c.y = c.y - 1 end)

--- Needed for converting the orientation back and forth to strings.
-- if a key does not exist an error is thrown.
t.oris = {
  ["north"] = 0,
  ["east"]  = 1,
  ["south"] = 2,
  ["west"]  = 3
}

--- Look a direction,
-- @param direction can be a string or number
-- if it is a string then it will be converted to a number based
-- on the t.oris table.
function t.look(direction)
  if type(direction) == "string" then
    if t.oris[direction] == nil then
      error(direction .. ' is not in the orientations table')
    end

    direction = t.oris[direction]
  end

  -- Now we turn to the correct orientation
  if c.ori == (direction - 1) % 4 then
    t.turnRight()
  else
    while c.ori ~= direction do
      t.turnLeft()
    end
  end
end

--- return a copy of current coordanites.
function t.dump()
  return { x = c.x, y = c.y, z = c.z, ori = c.ori }
end

--- Helper for t.moveTo
local function moveWith(mv, swing)
  while not mv() do swing() end
end

--- Helper for t.moveTo. is the same as
-- moveWith(t.forward, robot.swing)
local function moveForward()
  moveWith(t.forward, t.swing)
end

--- Move to a set of coordanites.
-- @tparam w table must contain x, y, z and optionally ori
function t.moveTo(w)
  local x, y, z, ori = w.x or w[1], w.y or w[2], w.z or w[3], w.ori or w[4]

  -- check for nil arguments
  if (not x or not y or not z) then
    error(
      ([[t.moveTo Invalid arguments
w.x = %q (want number)
w.y = %q (want number)
w.z = %q (want number)
]]):format(w.x, w.y, w.z))
  end
  ori = ori or t.ori

  while y < c.y do moveWith(t.down, robot.swingDown) end
  while y > c.y do moveWith(t.up,   robot.swingUp) end

  if x < c.x then
    t.look('west')
    while x < c.x do moveForward() end
  elseif x > c.x then
    t.look('east')
    while x > c.x do moveForward() end
  end

  if z < c.z then
    t.look('north')
    while z < c.z do moveForward() end
  elseif z > c.z then
    t.look('south')
    while z > c.z do moveForward() end
  end

  t.look(ori)
end

return t
