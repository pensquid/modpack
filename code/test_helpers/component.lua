inv = {}

inv.internal = {}
inv.external = {}

-- getStackInInternalSlot(slot:number):table
function inv.getStackInInternalSlot(slot)
  assert(type(slot) == 'number', 'slot must be a number')
  return inv.internal[slot]
end

function inv.getStackInSlot(side, slot)
  assert(type(slot) == 'number',
    'slot must be a number (got ' .. tostring(slot) .. ')')
  assert(side >= 0 and side <= 5, 'side must be in range 0-5')

  return inv.external[slot]
end

function inv.getInventorySize(side)
  assert(type(side) == 'number', 'side must be a number')
  assert(side >= 0 and side <= 5, 'side must be in range 0-5')

  if side ~= inv.external.side then
    return nil, 'no inventory'
  end

  return inv.external.size
end

function inv.dropIntoSlot(side, slot, count)
  assert(type(side) == 'number', 'side must be a number')
  assert(side >= 0 and side <= 5, 'side must be in range 0-5')
  count = count or 1 -- not sure if default is 1 or 64, using one here.

  if not inv.internal[_r.slot] then
    return false, ('no item in internal slot %d (robot selected slot)'):format(_r.slot)
  end

  if inv.internal[_r.slot].size < count then
    return false, ('not enough items in internal inventory, have %d need %d'):format(
      inv.internal[_r.slot].size,
      count)
  end


  -- Put N items into the external (chest) from inv.internal[_r.slot]
  inv.external[slot] = {
    size = inv.external[slot]['size'] + count,
    name = inv.internal[_r.slot]['name'],
    maxSize = inv.internal[_r.slot]['maxSize'],
  }

  -- Remove N items from internal slot _r.slot
  inv.internal[_r.slot]['size'] = inv.internal[_r.slot]['size'] - count

  assert(inv.internal[_r.slot]['size'] >= 0,
    ('item count %d is negative, this should be impossible'):format(
    inv.internal[_r.slot]['size']))

  -- If there are 0 items then remove the info from that slot it
  if inv.internal[_r.slot]['size'] == 0 then
    inv.internal[_r.slot] = false
  end

  return true
end

return {
  inventory_controller = inv,
}

