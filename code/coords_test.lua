package.path = package.path .. ';./test_helpers/?.lua'
local t = require('coords')
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

describe('t.look', function()
  it('should deal turn to the north from the east [regression]', function()
    t.c.ori = 1 -- east
    t.look('north')
    assert_eq(t.c.ori, 0)
  end)
end)

describe('t.moveTo', function()
  it('should not move when it is already at its destination', function()
    t.moveTo({x = 0, y = 0, z = 0, ori = 0})
    assert_eq({x = 0, y = 0, z = 0, ori = 0}, t.c)
  end)

  it('should move to its destination when neeeded', function()
    t.moveTo({x = 3, y = 4, z = -3, ori = 1})
    assert_eq({x = 3, y = 4, z = -3, ori = 1}, t.c)
  end)

  it('should work with positional args too', function()
    t.moveTo({3, 4, -3, 1})
    assert_eq({x = 3, y = 4, z = -3, ori = 1}, t.c)
  end)
end)
