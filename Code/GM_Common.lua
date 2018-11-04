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
mod.common = me

me.tag = "Common"

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
  Search for an itemId

  @param {number} itemId
  @param {bool} includeInventory
  @return {number}, {number}, {number}
]]--
function me.FindItemById(itemId, includeInventory)
  if includeInventory then
    for i = 0, 19 do
      if strfind(GetInventoryItemLink("player", i) or "", itemId, 1, 1) then
        return i
      end
    end
  end

  for i = 0, 4 do
    for j = 1, GetContainerNumSlots(i) do
      if strfind(GetContainerItemLink(i, j) or "", itemId, 1, 1) then
        return nil, i, j
      end
    end
  end
end

--[[
  Equip an item into a specific slot identified by it's id

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
  if UnitAffectingCombat("player") or me.IsPlayerReallyDead() then
    -- if not of type weapon add it to queue
    if slotId ~=  GM_CONSTANTS.ITEMS.MAINHAND.slotId and slotId ~= GM_CONSTANTS.ITEMS.OFFHAND.slotId then
      mod.combatQueue.AddToQueue(itemId, slotId)
    -- if type is weapon only add it to queue if the player is dead
    elseif me.IsPlayerReallyDead() then
      mod.combatQueue.AddToQueue(itemId, slotId)
    else
      me.SwitchItems(itemId, slotId, itemSlotType)
    end
  else
    me.SwitchItems(itemId, slotId, itemSlotType)
  end
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
    local _, _, wornType = mod.common.RetrieveItemInfo(GM_CONSTANTS.ITEMS.MAINHAND.slotId)
    if wornType == "INVTYPE_2HWEAPON" and (itemSlotType == "INVTYPE_SHIELD"
      or itemSlotType == "INVTYPE_WEAPON" or itemSlotType == "INVTYPE_WEAPONOFFHAND"
      or itemSlotType == "INVTYPE_HOLDABLE") then
        mod.common.UnequipItemBySlotId(GM_CONSTANTS.ITEMS.MAINHAND.slotId)
      end
  end

  if not CursorHasItem() and not SpellIsTargeting() then
    local _, b, s = me.FindItemById(itemId)
    if b then
      local _, _, isLocked = GetContainerItemInfo(b, s)
      if not isLocked and not IsInventoryItemLocked(slotId) then
        -- neither container item nor inventory item locked, perform swap
        PickupContainerItem(b, s)
        PickupInventoryItem(slotId)
      end
    end
    -- make sure to clear combatQueue
    mod.combatQueue.RemoveFromQueue(slotId)
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
  Check if a player is really dead and did not use fakedeath

  @return {1 or nil}
    1   - dead or ghost
    nil - alive
]]--
function me.IsPlayerReallyDead()
  local FEIGN_DEATH = "Interface\\Icons\\Ability_Rogue_FeignDeath"
  local dead = UnitIsDeadOrGhost("player")

  for i = 1, 24 do
    if UnitBuff("player", i) == FEIGN_DEATH then
      dead = nil
    end
  end

  return dead
end

--[[
  @param {string} name
  @return {number}
]]--
function me.ExtractPositionFromName(name)
  _, _, position = strfind(name, "(%d+)")

  return tonumber(position)
end
