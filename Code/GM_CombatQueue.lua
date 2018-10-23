--[[
  MIT License

  Copyright (c) 2018 Michael Wiesendanger

  Permission is hereby granted, free of charge, to any person obtaining
  a copy of this software and associated documentation files (the
  "Software"), to deal in the Software without restriction, including
  without limitation the rights to use, copy, modify, merge, publish,
  distribute, sublicense, and/or sell copies of the Software, and to
  permit persons to whom the Software is furnished to do so, subject to
  the following conditions:

  The above copyright notice and this permission notice shall be
  included in all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]--

local mod = gm
local me = {}
mod.combatQueue = me

me.tag = "CombatQueue"
local CombatQueueStore = {}

--[[
  Getter for CombatQueueStore

  @return {table}
]]--
function me.GetCombatQueueStore()
  return CombatQueueStore
end

--[[
  Add item to combatQueue. There can only be one item per slot

  @param {string} itemID
  @param {number} slot
]]--
function me.AddToQueue(itemID, slot)
  if not itemID or not slot then return end

  CombatQueueStore[slot] = itemID
  mod.logger.LogDebug(me.tag, "Added item with id " .. itemID .. " in slot "
    .. slot .. " to CombatQueueStore")
  me.UpdateCombatQueue(slot)
end

--[[
  Remove item from combatQueue

  @param {number} slot
]]--
function me.RemoveFromQueue(slot)
  if not slot then return end

  -- get item from queue that is about to be removed
  local itemID = CombatQueueStore[slot]

  -- if no item is registere in queue for that specific slot
  if itemID == nil then
    mod.logger.LogInfo(me.tag, "No item in queue for slot - " .. slot)
    return
  end

  CombatQueueStore[slot] = nil
  mod.logger.LogDebug(me.tag, "Removed item with id " .. itemID .. " in slot "
    .. slot .. " from CombatQueueStore")
  me.UpdateCombatQueue(slot)
end

--[[
  Update the queue and show small icons for items or hide them if item was removed
  from queue

  @param {number} slot
]]--
function me.UpdateCombatQueue(slot)
  local module, itemID, icon

  module = mod.itemManager.FindItemForSlotID(slot)

  itemID = CombatQueueStore[slot]
  icon = getglobal(GM_CONSTANTS.ELEMENT_SLOT .. mod[module].GetPosition() .. "Queue")

  if itemID then
    _, bag, slot = mod.common.FindItemByID(itemID)
    if bag then
      icon:SetTexture(GetContainerItemInfo(bag, slot))
      icon:Show()
    end
  else
    icon:Hide()
  end
end

--[[
  Process through combat queue and equip item if there is one waiting in the queue.
  Weapons will always be switched immediately because they can be changed while in combat
]]--
function me.ProcessQueue()
  -- retrieve all registered modules
  local items = mod.itemManager.GetAllRegisteredItems()
  --[[
    if both mainHand and offHand are in the queue ensure that those are processed
    with priority and in the correct order. Switch mainHand first to prevent problems
    with 2handed weapons
  ]]--
  me.ProcessItem(items, mod.mainHand.moduleName)
  me.ProcessItem(items, mod.offHand.moduleName)

  for key, moduleName in pairs(items) do
    -- update queue for all slotpositions
    me.ProcessItem(items, moduleName)
  end
end

--[[
  Process items in combatqueue

  @param {table} items
  @param {string} moduleName
]]--
function me.ProcessItem(items, moduleName)
  if mod[items[moduleName]] and CombatQueueStore[mod[items[moduleName]].id] ~= nil then
    _, _, _, _, _, _, _, equipSlot = GetItemInfo(CombatQueueStore[mod[items[moduleName]].id] or "")

    local item = {
      itemID = CombatQueueStore[mod[items[moduleName]].id],
      itemSlotType = equipSlot
    }

    mod.common.EquipItemByID(item, mod[items[moduleName]].id)
    me.UpdateCombatQueue(mod[items[moduleName]].id)
  end
end
