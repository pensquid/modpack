package.path = package.path .. ';../test_helpers/?.lua'
require('sides')
local storage = require('storage')
local pprint = require('pprint')

--------------- TEST HELPERS

local function equal(a, b)
  if type(a) == 'table' and type(b) == 'table' then
    return pprint.pformat(a) == pprint.pformat(b)
  else
    return a == b
  end
end


local function assert_eq(want, got)
  if not equal(want, got) then
    print('----- WANT')
    pprint(want)
    print('----- GOT')
    pprint(got)
  end
end

-- indent print by 2 spaces while func executes
local function with_indent(func)
  local bp = print
  print = function(...)
    io.write('  ')
    bp(...)
  end

  -- TODO: Handle errors from func
  func()

  print = bp
end

local function it(str, func)
  print('it ' .. str)
  with_indent(func)
  print()
end

local function describe(message, func)
  print('describe ' .. message)
  with_indent(func)
end

--------------- TESTS


describe('chest:new', function()
  it('should be creatable', function();
    inv.external = {
      side = sides.bottom,
      size = 54,
    }

    local chest = storage.chest:new {
      location = {0, 2, 3, 0},
      invsize = 54,
      side = sides.bottom,
      slots = {
        {'minecraft:stone', 63}, -- 63 stone in slot 1
        {'minecraft:stone', 31}, -- 31 stone in slot 2
      },
    }

    assert_eq({
      location = {0, 2, 3, 0},
      side = sides.bottom,
      invsize = 54,
      slots = {
        {'minecraft:stone', 63}, -- 63 stone in slot 1
        {'minecraft:stone', 31}, -- 31 stone in slot 2
      },
    }, chest)
  end)

end)

describe('chest:rescan', function()
  it('should update its internal inventory', function()
    local chest = storage.chest:new {
      location = {0, 2, 3, 0},
      side = sides.bottom,
      slots = {},
      invsize = 54,
    }

    inv.external = {
      side = sides.bottom,
      size = 54,

      { -- NOTE: I omit damage and maxDamage because they are not used.
        size = 12,
        maxSize = 64,
        name = 'minecraft:stone',
      },
    }
    local ok, err = chest:rescan()
    if not ok then
      print('ERROR: ' .. err)
      return
    end

    assert_eq({
        {'minecraft:stone', 12},
    }, chest.slots)
  end)

  it('should fail when the external inventory is not found', function()
    local chest = storage.chest:new {
      location = {0, 2, 3, 0},
      side = sides.top,
      slots = {},
      invsize = 54,
    }
    local ok, err = chest:rescan()
    if ok then
      print('ERROR: expected "no inventory", got ok')
    end
  end)
end)

describe('chest:slots_with', function()
  it('should give me the slots with an item', function()
    local chest = storage.chest:new {
      location = {0, 2, 3, 0},
      side = sides.top,
      slots = {
        {'minecraft:stone', 32},
        nil,
        {'minecraft:stone', 30},
      },
      invsize = 54,
    }

    local slots = chest:slots_with('minecraft:stone')
    assert_eq({1, 3}, slots)
  end)
end)

describe('chest:put', function()
  it('should put items in the chest', function()
    local chest = storage.chest:new {
      location = {0, 2, 3, 0},
      side = sides.bottom,
      slots = {
        {'minecraft:stone', 32},
        nil,
        {'minecraft:stone', 30},
      },
      invsize = 54,
    }

    inv.internal = {
      size = 16,
      {
        name = 'minecraft:stone',
        size = 64,
      }
    }

    local ok, err = chest:put(1, 60)
    if not ok then
      print(err)
    end
  end)
end)
