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

local function nameFor(info)
  -- just in case something is borked with OC, or the caller gave us an invalid table.
  assert(type(info.damage) == 'number' and type(info.name) == 'string',
    'info.damage and info.name must exist')
  assert(info.damage % 1 == 0, 'info.damage is floating point, this should not be possible.')

  return info.name .. '/' .. tostring(math.floor(info.damage))
end

local function isCraftSlot(slot)
  -- craft slots
  -- 1, 2, 3,
  -- 5, 6, 7,
  -- 9, 10, 11,

  return
    (slot > 0 and slot < 4) or
    (slot > 4 and slot < 8) or
    (slot > 8 and slot < 12)
end


-- return the slot in which there is 1 or more of itemid, nil if not found.
-- move all items in slot, to a slot outside the crafting grid.
-- returns bool success
local function moveIntoEmptySpace(slot)
  assert(robot.select(slot) == slot)
  local slotInfo = inv.getStackInInternalSlot(slot)
  local slotName = nameFor(slotInfo)

  for i=1,robot.inventorySize() do
    if not isCraftSlot(i) then
      local info = inv.getStackInInternalSlot(i)
      -- TODO: Test this condition
      if not info or (nameFor(info) == slotName and info.size < info.maxSize) then
        robot.select(slot)
        robot.transferTo(i)
        return true
      end
    end
  end
  return false, 'no empty slots could be found (excluding crafting slots)'
end

-- find a slot with at least one of itemid, excluding crafting slots.
local function findOne(itemid)
  for itemSlot=1,robot.inventorySize() do
    if not isCraftSlot(itemSlot) then
      local info = inv.getStackInInternalSlot(itemSlot)
      if info and nameFor(info) == itemid then
        return itemSlot -- found it!
      end
    end
  end
end

local function moveIntoPositionsLoop(slot, want, recipe) -- unexported, I need continue :V
  -- return if this slot is empty.
  if not want then return true end

  -- return if the wanted item is already in this slot
  local info = inv.getStackInInternalSlot(slot)
  if info and nameFor(info) == want then return true end

  -- ok, we don't have the item, but our current slot is empty.
  -- find the item we want!
  local wantSlot = findOne(want)
  if wantSlot then
    robot.select(wantSlot)    -- source
    robot.transferTo(slot, 1) -- destination

    return true
  end

  -- we did not find it ):
  return false, 'could not find ' .. tostring(want)
end

local function moveIntoPositions(recipe)
  if #recipe > 9 then
    return false, 'recipe too large, max length 9'
  end

  -- First we clear out any items in the incorrect places.
  for i=1,9 do
    local slot = craftSlot[i]
    local want = recipe[i]    -- the itemid of what we want in this slot

    -- clear this slot if needed.
    local info = inv.getStackInInternalSlot(slot)
    if info and nameFor(info) ~= want then
      -- we don't want this item here! get rid of it.
      local ok, err = moveIntoEmptySpace(slot)
      if not ok then return false, err end
    end
  end

  -- For every slot in the recipe, make sure it is satisfied.
  for i=1,9 do
    local want = recipe[i]    -- the itemid of what we want in this slot
    local slot = craftSlot[i] -- the slot in robot inventory terms

    local ok, err = moveIntoPositionsLoop(slot, want, recipe)
    if not ok then return false, err end
  end

  return true
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
  if not ok then
    -- TODO: try to craft subcomponent
    return false, err
  end
  return crafting.craft()
end

return {
  craft = craft,
  moveIntoPositions = moveIntoPositions,
  importRecipe = importRecipe,
}
