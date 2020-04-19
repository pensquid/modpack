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

return {
  inventory_controller = inv,
}

