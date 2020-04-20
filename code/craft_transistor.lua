local component = require('component')
local crafting = component.crafting
local inv = component.inventory_controller
local sides = require('sides')
local robot = require('robot')

local iron = 'minecraft:iron_ingot'
local goldn = 'minecraft:gold_nugget'
local paper = 'minecraft:paper'
local redstone = 'minecraft:redstone'
local recipe = {
  iron, iron, iron,
  goldn, paper, goldn,
  false, redstone, false,
}

for slot = 1,54 do
  local info = inv.getStackInSlot(sides.bottom, slot)
  if info ~= nil then
    print(info['name'])
    for i,v in ipairs(recipe) do
      if v and v == info['name'] then
        print('found ' .. v)
        recipe[i] = false
        i = i + i // 4
        if i > 11 then error('too moch') end
        print('select:', i)
        robot.select(i)
        assert(
          inv.suckFromSlot(sides.bottom, slot, 1))
      end
    end
  end
end

crafting.craft()
