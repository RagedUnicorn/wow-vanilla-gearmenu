--[[
  MIT License

  Copyright (c) 2019 Michael Wiesendanger

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

  @param {string} itemId
  @param {number} slotId
]]--
function me.AddToQueue(itemId, slotId)
  if not itemId or not slotId then return end

  CombatQueueStore[slotId] = itemId
  mod.logger.LogDebug(me.tag, "Added item with id " .. itemId .. " in slotId "
    .. slotId .. " to CombatQueueStore")
  me.UpdateCombatQueue(slotId)
end

--[[
  Remove item from combatQueue

  @param {number} slotId
]]--
function me.RemoveFromQueue(slotId)
  if not slotId then return end

  -- get item from queue that is about to be removed
  local itemId = CombatQueueStore[slotId]

  -- if no item is registere in queue for that specific slotId
  if itemId == nil then
    mod.logger.LogInfo(me.tag, "No item in queue for slotId - " .. slotId)
    return
  end

  CombatQueueStore[slotId] = nil
  mod.logger.LogDebug(me.tag, "Removed item with id " .. itemId .. " in slotId "
    .. slotId .. " from CombatQueueStore")
  me.UpdateCombatQueue(slotId)
end

--[[
  Update the queue and show small icons for items or hide them if item was removed
  from queue

  @param {number} slotId
]]--
function me.UpdateCombatQueue(slotId)
  local item = mod.itemManager.FindItemForSlotId(slotId)
  local itemId = CombatQueueStore[slotId]
  local icon = getglobal(GM_CONSTANTS.ELEMENT_SLOT .. item.gmSlotPosition .. "Queue")

  if itemId then
    _, bagNumber, bagPos = mod.itemHelper.FindItemById(itemId, true)
    if bagNumber then
      icon:SetTexture(GetContainerItemInfo(bagNumber, bagPos))
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
  -- retrieve all registered items
  local items = mod.itemManager.GetAllRegisteredItems()

  for _, item in pairs(items) do
    -- update queue for all slotpositions
    me.ProcessItem(item)
  end
end

--[[
  Process item in combatqueue

  @param {table} item
]]--

function me.ProcessItem(item)
  if CombatQueueStore[item.slotId] ~= nil then
    _, _, _, _, _, _, _, equipSlot = GetItemInfo(CombatQueueStore[item.slotId])
    mod.itemHelper.EquipItemById(CombatQueueStore[item.slotId], item.slotId, equipSlot)
    me.UpdateCombatQueue(item.slotId)
  end
end
