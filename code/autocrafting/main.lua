local autocraft = require('autocrafting')
local storage  = require('storage') -- TODO: Use

-- TODO persist added recipes.
local recipes = require('recipes')

local env = {}

env.help = function()
  print('lol, read the source code https://github.com/kognise/pwnsquad-modpack')
end

-- takes {itemid, recipe|interactive = True}
-- the reason we don't seperate these into seperate functions, is
-- I can get custom behaveure for recipes[x] = y with metatables, when I want to store to disk, etc...
env.addRecipe = function(t)
  assert(type(t[1]) == 'string', 'argument #1 of addRecipe must be a string of the itemid to add')
  -- TODO: Verify the itemid is of form name/damage
  if t.interactive then
    io.write(('input recipe for %s\n-> '):format(t[1]))
    local table_str = io.read()
    local recipe = assert(load('return ' .. table_str))()
    assert(type(recipe) == 'table', 'inputted recipe must be a table')
    recipes[t[1]] = recipe
  else
    assert(type(t[2] == 'table'))
    recipes[t[1]] = t[2]
  end
end

-- itemid is item name + / + item damage
-- so, opencomputers:material/9
env.craft = function(itemid)
  local recipe = recipes[itemid]
  if not recipe then
    io.write('recipe for ' .. itemid .. ' not found, would you like to import it? (y/n) ')
    local response = io.read()
    if response == 'y' then
      io.write('set up recipe in inventory, or enter table? (1/2) ')
      local r = io.read()
      if r == '1' then
        local recipe = autocraft.importRecipe()
        table.insert(recipes, recipe)
      elseif r == '2' then
        env.addRecipe{itemid, interactive = true}
      else
        error('must be 1 or 2 (got ' .. tostring(r) .. ')')
      end
    end
  end
end

-- basically a lua interpreter
print("type 'help()' for a list of commands.")
while true do
  io.write('-> ')
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
