-- local pprint = require 'test_helpers.pprint'
local component = require('component')
local sides = require('sides')
local r = require('coords')
local c = r.c
local inv = component.inventory_controller

--[[ Keep in mind the delta's for different orientations.
     These are modeled off orientation 0 being north
     read coords.lua for more info.

local deltaForward = {
  [0] = function() c.z = c.z - 1 end,
  [1] = function() c.x = c.x + 1 end,
  [2] = function() c.z = c.z + 1 end,
  [3] = function() c.x = c.x - 1 end
}

local deltaBackwards = {
  [0] = function() c.z = c.z + 1 end,
  [1] = function() c.x = c.x - 1 end,
  [2] = function() c.z = c.z - 1 end,
  [3] = function() c.x = c.x + 1 end
}
]]
local chests = {
  {
    x = 0,
    y = 0,
    z = -1,
  },

  {
    x = 0,
    y = 0,
    z = -2,
  }
}

-- itemid -> array {
--   {chest_pointer, slot, count}
--   {chest_pointer, slot, count},
--   ...
--   }
local locations = {
  ['minecraft:stone'] = {
    {chests[1], 1, 63},
    {chests[1], 2, 31},
    {chests[2], 1, 15}
  }
}

local function getItemLocations(item, amount)
  amount = amount or 1
  if locations[item] == nil or #locations[item] == 0 then
    return nil, "Item not in system"
  end

  local got = 0
  local itemLocations = {}

  for _, location in ipairs(locations[item]) do
    got = got + location[3]
    table.insert(itemLocations, location)

    if got >= amount then
      break
    end
  end

  if got < amount then
    return nil, "Not enough items"
  else

    return itemLocations
  end
end

-- We move on the axies in order
-- Z, X, Y
-- if ori is not supplied we retain our existing orientation.
local function moveTo(x, y, z, ori)
  -- Since our initial orientation is 0, it is of paramount importence that
  -- we move on the Z axis first, otherwise we may end up running into the wall
  -- seperating us from the chests.
  ori = ori or c.ori

  if z < c.z then
    r.look('north')
    while z < c.z do r.forward() end
  elseif z > c.z then
    r.look('south')
    while z > c.z do r.forward() end
  end

  if x < c.x then
    r.look('west')
    while x < c.x do r.forward() end
  elseif x > c.x then
    r.look('east')
    while x > c.x do r.forward() end
  end

  while y < c.y do r.down() end
  while y > c.y do r.up()   end

  r.look(ori)
end

-- Functions callable from stdin.
local env = {}
setmetatable(env, { __index = _ENV }) -- if fn not found look in globals

function env.get(item, amount)
  itemLocations, err = getItemLocations(item, amount)
  if itemLocations == nil then
    return nil, err
  end

  for _, location in ipairs(itemLocations) do
    -- pprint(location)
    moveTo(location[1].x, location[1].y, location[1].z)
    inv.suckFromSlot(sides.down, location[2], amount)
  end
end

-- Put item into the database, and into an empty chest.
function env.put()
end

-- eval the input from the user, catch all errors and print instead of failing.
local function main()
  while true do
    io.write('uwu> ')
    local input = io.read()
    if input == nil then break end
    local f, err = load('return ' .. input, '<stdin>', 't', env)
    if err ~= nil then
      print(err)
    else
      local ok, err = pcall(function()
        print(f())
      end)
      if not ok then print(err) end
    end
  end
end

main()
