--[[
  GearMenu - A WoW 1.12.1 Addon to manage quick itemswitching
  Copyright (C) 2018 Michael Wiesendanger <michael.wiesendanger@gmail.com>

  This file is part of GearMenu.

  GearMenu is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  GearMenu is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with GearMenu.  If not, see <http://www.gnu.org/licenses/>.
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
  icon = getglobal(GM_CONSTANTS.ELEMENT_GM_SLOT .. mod[module].GetPosition() .. "Queue")

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
