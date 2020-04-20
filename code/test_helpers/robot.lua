-- mock for https://ocdoc.cil.li/api:robot to be used in tests.
if _r then return _r end
local r = {}
_r = r

local ret_true = function()
  return true
end

r.forward = ret_true
r.back    = ret_true
r.up      = ret_true
r.down    = ret_true

r.turnRight = function() end
r.turnLeft  = function() end

-- TODO: robot.swing can do more then this, account for that
r.swing     = function() end
r.swingUp   = function() end
r.swingDown = function() end

r.inv = {}
r.slot = 1

function r.select(slot)
  r.slot = slot
  return slot
end

return r
