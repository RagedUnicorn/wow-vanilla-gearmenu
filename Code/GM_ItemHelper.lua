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


--[[
  Itemhelper is a helper for functions like switching items, unequip items and more
]]--
local mod = gm
local me = {}
mod.itemHelper = me

me.tag = "ItemHelper"

--[[
  Retrieve itemInfo

  @param {number} slotId
  @return {string}, {string}, {string}
]]--
function me.RetrieveItemInfo(slotId)
  local link, id, name, equipSlot, texture = GetInventoryItemLink("player", slotId)

  if link then
    _, _, id = strfind(link, "item:(%d+)")
    name, _, _, _, _, _, _, equipSlot, texture = GetItemInfo(id)
  else
    _, texture = GetInventorySlotInfo(GM_CONSTANTS.ITEM_CATEGORIES[slotId].slotName)
  end

  return texture, id, equipSlot
end

--[[
  Search for an itemId

  @param {number} itemId
  @param {boolean} includeInventory
  @return {number} slotId, {number} bagNumber, {number} bagPos
]]--
function me.FindItemById(itemId, includeInventory)
  -- search equiped items for item
  for i = 0, 19 do
    if strfind(GetInventoryItemLink("player", i) or "", itemId, 1, 1) then
      return i
    end
  end

  -- search inventory for item
  if includeInventory then
    for i = 0, 4 do
      for j = 1, GetContainerNumSlots(i) do
        if strfind(GetContainerItemLink(i, j) or "", itemId, 1, 1) then
          return nil, i, j
        end
      end
    end
  end
end

--[[
  Retrieve itemId from a specific slot

  @param {number} slotId
  @return {string | nil}
]]--
function me.GetItemIdBySlot(slotId)
  local itemLink = GetInventoryItemLink("player", slotId)

  if itemLink then
    local _, _, id = string.find(itemLink, "item:(%d+):(%d+):(%d+)")
    return id
  end

  return nil
end

--[[
  Equip an item into a specific slot identified by it's itemId

  @param {number} itemId
  @param {number} slotId
  @param {string} itemSlotType
]]--
function me.EquipItemById(itemId, slotId, itemSlotType)
  if not itemId or not slotId or not itemSlotType then return end

  if itemId then
    mod.logger.LogDebug(me.tag, "EquipItem: " .. itemId .. " in slot: " .. slotId)
  end

  --[[
    if user is in combat or dead and the slot that is affected is not the mainHand
    or offHand always add the item to the combatQueue. If the player is not in combat
    or dead or the slot is mainHand or offHand immediately perform the swap
  ]]--
  if UnitAffectingCombat("player") or mod.common.IsPlayerReallyDead() then
    -- if not of type weapon add it to queue
    if slotId ~=  GM_CONSTANTS.ITEMS.MAINHAND.slotId and slotId ~= GM_CONSTANTS.ITEMS.OFFHAND.slotId then
      mod.combatQueue.AddToQueue(itemId, slotId)
    -- if type is weapon only add it to queue if the player is dead
  elseif mod.common.IsPlayerReallyDead() then
      mod.combatQueue.AddToQueue(itemId, slotId)
    else
      me.SwitchItems(itemId, slotId, itemSlotType)
    end
  else
    me.SwitchItems(itemId, slotId, itemSlotType)
  end
end

--[[
  Unequip item in a specific slot. The item will be placed in the first
  free bagspace that is found. If no space is found the operation is cancelled

  @param {number} slotId
]]--
function me.UnequipItemBySlotId(slotId)
  local i, j
  local itemLink

  -- loop over bags find empty space
  for i = 0, 4 do
    for j = 1, GetContainerNumSlots(i) do
      itemLink = GetContainerItemLink(i, j)

      if itemLink == nil then
        PickupInventoryItem(slotId)
        PickupContainerItem(i, j)
        return
      end
    end
  end

  -- no empty space found
  mod.logger.PrintUserError(gm.L["unequip_failed"])
end

--[[
  Switch to items from itemSlot and a bag position

  @param {number} itemId
  @param {number} slotId
  @param {string} itemSlotType
]]--
function me.SwitchItems(itemId, slotId, itemSlotType)
  --[[
    special case if main hand is twohand and the item that should be equiped is offhand
    wow does not handle this properly
  ]]--
  if slotId == GM_CONSTANTS.ITEMS.OFFHAND.slotId then
    local _, _, wornType = me.RetrieveItemInfo(GM_CONSTANTS.ITEMS.MAINHAND.slotId)
    if wornType == "INVTYPE_2HWEAPON" and (itemSlotType == "INVTYPE_SHIELD"
      or itemSlotType == "INVTYPE_WEAPON" or itemSlotType == "INVTYPE_WEAPONOFFHAND"
      or itemSlotType == "INVTYPE_HOLDABLE") then
        me.UnequipItemBySlotId(GM_CONSTANTS.ITEMS.MAINHAND.slotId)
      end
  end

  if not CursorHasItem() and not SpellIsTargeting() then
    local _, bagNumber, bagPos = me.FindItemById(itemId, true)

    if bagNumber then
      local _, _, isLocked = GetContainerItemInfo(bagNumber, bagPos)
      if not isLocked and not IsInventoryItemLocked(bagPos) then
        -- neither container item nor inventory item locked, perform swap

        PickupContainerItem(bagNumber, bagPos)
        PickupInventoryItem(slotId)

      end
    end
    -- make sure to clear combatQueue
    mod.combatQueue.RemoveFromQueue(slotId)
  end
end
