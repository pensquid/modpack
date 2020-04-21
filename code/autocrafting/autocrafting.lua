local component = require('component')
local crafting = component.crafting
local inv = component.inventory_controller
local sides = require('sides')
local robot = require('robot')

-- so i tried smart stuff like i + i//4 it dident work for 7
-- ahdhhghagha h so i'm doing it the dumb way
-- craftSlot[i] converts a crafting slot (1-9) to the actual robot slot
local craftSlot = {
  1, 2, 3,
  5, 6, 7,
  9, 10, 11,
}

local function moveIntoPositions(recipe)
  if #recipe > 9 then
    return false, 'recipe too large, max length 9'
  end

  for slot = 1, robot.inventorySize() do
    local info = inv.getStackInInternalSlot(slot)

    if info ~= nil then
      for i,v in ipairs(recipe) do
        if v and v == info['name'] then
          recipe[i] = false
          i = craftSlot[i]
          robot.select(slot)
          if not robot.transferTo(i, 1) then
            return false, ('failed to transfer from %d to %d'):format(robot.select(), i)
          else
            break
          end
        end
      end

    end
  end
  return true
end

local function nameFor(info)
    -- just in case something is borked with OC, or the caller gave us an invalid table.
    assert(type(info.damage) == 'number' and type(info.name) == 'string',
      'info.damage and info.name must exist')
    assert(info.damage % 1 == 0, 'info.damage is floating point, this should not be possible.')

    return info.name .. '/' .. tostring(math.floor(info.damage))
end

-- import a recipe from the robot's crafting inventory
-- this returns that recipe, which can be used later.
local function importRecipe()
  local recipe = {}
  for i=1,9 do
    local slot = craftSlot[i]
    local info = inv.getStackInInternalSlot(slot)
    if info then

      table.insert(recipe, nameFor(info))
    else
      table.insert(recipe, false)
    end
  end

  return recipe
end

-- recipe is an array of the minecraft item id for every slot, so for a button
-- craft({'minecraft:stone'})
-- empty slots are denoted as false
-- this function is not recursive.
local function craft(recipe)
  local ok, err = moveIntoPositions(recipe)
  if not ok then return false, err end
  return crafting.craft()
end

-- return the slots with itemid in them, nil if it is not found.
local function slotsWith(itemid)
  for slot = 1, robot.inventorySize() do
    local info = inv.getStackInInternalSlot(slot)
    if info and nameFor(info) == itemid then
      return slot
    end
  end
end

-- craft but recursive, if we don't have an item we try to craft it.
local function recursiveCraft(recipe)
  local ok, err = moveIntoPositions(recipe)
  if not ok then return false, err end
  return crafting.craft()
end

return {
  craft = craft,
  moveIntoPositions = moveIntoPositions,
  importRecipe = importRecipe,
}
