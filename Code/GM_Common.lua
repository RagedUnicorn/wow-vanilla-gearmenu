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
mod.common = me

me.tag = "Common"

--[[
  0 = ammo
  1 = head
  2 = neck
  3 = shoulder
  4 = shirt
  5 = chest
  6 = waist
  7 = legs
  8 = feet
  9 = wrist
  10 = hands
  11 = finger 1
  12 = finger 2
  13 = trinket 1
  14 = trinket 2
  15 = back
  16 = main hand
  17 = off hand
  18 = ranged
  19 = tabard

  "HeadSlot" = Head/helmet slot.
  "NeckSlot" = Necklace slot.
  "ShoulderSlot" = Shoulder slot.
  "BackSlot" = Back/Cape slot.
  "ChestSlot" = Chest slot.
  "ShirtSlot" = Shirt slot.
  "TabardSlot" = Tabard slot.
  "WristSlot" = Wrist/Bracer slot.
  "HandsSlot" = Hand/Gloves slot.
  "WaistSlot" = Waist/Belt slot.
  "LegsSlot" = Legs/Pants slot.
  "FeetSlot" = Feet/Boots slot.
  "Finger0Slot" = First finger/ring slot.
  "Finger1Slot" = Second finger/ring slot.
  "Trinket0Slot" = First trinket slot.
  "Trinket1Slot" = Second trinket slot.
  "MainHandSlot" = Main hand slot.
  "SecondaryHandSlot" = Secondary hand/Off-hand slot.
]]--

local slotName = {
  [1] = "HeadSlot",
  [6] = "WaistSlot",
  [8] = "FeetSlot",
  [13] = "Trinket0Slot",
  [14] = "Trinket1Slot",
  [16] = "MainhandSlot",
  [17] = "SecondaryHandSlot"
}

--[[
  retrieve itemInfo
  @param {number} slotID
  @return {string}, {string}, {string}
]]--
function me.RetrieveItemInfo(slotID)
  local link, id, name, equipSlot, texture = GetInventoryItemLink("player", slotID)

  if link then
    _, _, id = strfind(link, "item:(%d+)")
    name, _, _, _, _, _, _, equipSlot, texture = GetItemInfo(id)
  else
    _, texture = GetInventorySlotInfo(slotName[slotID])
  end

  return texture, id, equipSlot
end

--[[
  retrieve itemID from a specific slot
  @param {number} slotID
  @return {string | nil}
]]--
function me.GetItemIDBySlot(slotID)
  local itemLink = GetInventoryItemLink("player", slotID)

  if itemLink then
    local _, _, id = string.find(itemLink, "item:(%d+):(%d+):(%d+)")
    return id
  end

  return nil
end

--[[
  search for an itemID
  @param {number} itemID
  @param {bool} includeInventory
  @return {number}, {number}, {number}
]]--
function me.FindItemByID(itemID, includeInventory)
  if includeInventory then
    for i = 0, 19 do
      if strfind(GetInventoryItemLink("player", i) or "", itemID, 1, 1) then
        return i
      end
    end
  end

  for i = 0, 4 do
    for j = 1, GetContainerNumSlots(i) do
      if strfind(GetContainerItemLink(i, j) or "", itemID, 1, 1) then
        return nil, i, j
      end
    end
  end
end

--[[
  equip an item into a specific slot identified by it's id
  @param {table} item
  @param {number} slotID
]]--
function me.EquipItemByID(item, slotID)
  if not item or not slotID then return end

  if item.itemID then
    mod.logger.LogDebug(me.tag, "EquipItem: " .. item.itemID .. " in slot: " .. slotID)
  end

  --[[
    if user is in combat or dead and the slot that is affected is not the mainHand
    or offHand always add the item to the combatQueue. If the player is not in combat
    or dead or the slot is mainHand or offHand immediately perform the swap
  ]]--
  if UnitAffectingCombat("player") or me.IsPlayerReallyDead() then
    -- if not of type weapon add it to queue
    if slotID ~= mod.mainHand.id and slotID ~= mod.offHand.id then
      mod.combatQueue.AddToQueue(item.itemID, slotID)
    -- if type is weapon only add it to queue if the player is dead
    elseif me.IsPlayerReallyDead() then
      mod.combatQueue.AddToQueue(item.itemID, slotID)
    else
      me.SwitchItems(item, slotID)
    end
  else
    me.SwitchItems(item, slotID)
  end
end

--[[
  switch to items from itemSlot and a bag position
  @param {table} item
  @param {number} slotID
]]--
function me.SwitchItems(item, slotID)
  --[[
    special case if main hand is twohand and the item that should be equiped is offhand
    wow does not handle this properly
  ]]--
  if slotID == mod.offHand.id then
    local _, _, wornType = mod.common.RetrieveItemInfo(mod.mainHand.id)

    if wornType == "INVTYPE_2HWEAPON" and (item.itemSlotType == "INVTYPE_SHIELD"
      or item.itemSlotType == "INVTYPE_WEAPON" or item.itemSlotType == "INVTYPE_WEAPONOFFHAND"
      or item.itemSlotType == "INVTYPE_HOLDABLE") then
        mod.common.UnequipItemBySlotID(mod.mainHand.id)
      end
  end

  if not CursorHasItem() and not SpellIsTargeting() then
    local _, b, s = me.FindItemByID(item.itemID)
    if b then
      local _, _, isLocked = GetContainerItemInfo(b, s)
      if not isLocked and not IsInventoryItemLocked(slotID) then
        -- neither container item nor inventory item locked, perform swap
        PickupContainerItem(b, s)
        PickupInventoryItem(slotID)
      end
    end
    -- make sure to clear combatQueue
    mod.combatQueue.RemoveFromQueue(slotID)
  end
end

--[[
  unequip item in a specific slot. The item will be placed in the first
  free bagspace that is found. If no space is found the operation is cancelled
  @param {number} slotID
]]--
function me.UnequipItemBySlotID(slotID)
  local i, j
  local itemLink

  -- loop over bags find empty space
  for i = 0, 4 do
    for j = 1, GetContainerNumSlots(i) do
      itemLink = GetContainerItemLink(i, j)

      if itemLink == nil then
        PickupInventoryItem(slotID)
        PickupContainerItem(i, j)
        return
      end
    end
  end

  -- no empty space found
  mod.logger.PrintUserError(gm.L["unequip_failed"])
end

--[[
  check if a player is really dead and did not use fakedeath
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


--[[
  retrieve all items from inventory bags matching any type of
    INVTYPE_TRINKET
    INVTYPE_WAIST
    INVTYPE_HOLDABLE
    INVTYPE_WEAPONOFFHAND
    INVTYPE_SHIELD
    INVTYPE_WEAPON
    INVTYPE_WEAPONMAINHAND
    INVTYPE_2HWEAPON
    INVTYPE_WEAPON
    INVTYPE_HEAD
    INVTYPE_FEET
  depending on the type that is passed to the function. For available types see
  constants CATEGORIES.
  @param {number} type
    see gm_constants categories for a reference
  @param {boolean} includeEquiped
    whether the currently equiped item should be included in the result or not
  @return {table | nil}, {number}
]]--
function me.GetItemsByType(type, includeEquiped)
  local idx = 1, i, j
  local itemLink, itemID, itemName, equipSlot, itemTexture, itemQuality, numberOfItems, itemTypes
  local items = {}

  if type == nil then
    mod.logger.LogError(me.tag, "Itemtype missing")
    return nil
  end

  itemTypes = GM_CONSTANTS.CATEGORIES[type].type

  for i = 0, 4 do
    for j = 1, GetContainerNumSlots(i) do
      itemLink = GetContainerItemLink(i, j)

      if itemLink then
        _, _, itemID, itemName = strfind(GetContainerItemLink(i, j) or "", "item:(%d+).+%[(.+)%]")
        _, _, itemQuality, _, _, _, _, equipSlot, itemTexture = GetItemInfo(itemID or "")

        for it = 1, table.getn(itemTypes) do
          if equipSlot == itemTypes[it] then
            if itemQuality >= GearMenuOptions.filterItemQuality then
              if not items[idx] then
                items[idx] = {}
              end

              items[idx].bag = i
              items[idx].slot = j
              items[idx].name = itemName
              items[idx].texture = itemTexture
              items[idx].id = itemID
              items[idx].equipSlot = equipSlot
              items[idx].quality = itemQuality

              idx = idx + 1
            else
              mod.logger.LogDebug(me.tag, "Ignoring item because its quality is lower than setting "
                .. GearMenuOptions.filterItemQuality)
            end
          end
        end
      end
    end
  end

  -- include currently equiped items
  if includeEquiped then
    for i = 1, table.getn(itemTypes) do
      for it = 1, table.getn(GM_CONSTANTS.CATEGORIES[type].slotID) do
        _, _, itemID, itemName = strfind(GetInventoryItemLink("player", GM_CONSTANTS.CATEGORIES[type].slotID[it]) or "", "item:(%d+).+%[(.+)%]")
        _, _, itemQuality, _, _, _, _, equipSlot, itemTexture = GetItemInfo(itemID or "")

        if itemQuality >= GearMenuOptions.filterItemQuality then
          if not items[idx] then
            items[idx] = {}
          end

          items[idx].bag = i
          items[idx].slot = j
          items[idx].name = itemName
          items[idx].texture = itemTexture
          items[idx].id = itemID
          items[idx].equipSlot = equipSlot
          items[idx].quality = itemQuality

          idx = idx + 1
        else
          mod.logger.LogDebug(me.tag, "Ignoring item because its quality is lower than setting "
            .. GearMenuOptions.filterItemQuality)
        end
      end
    end
  end

  numberOfItems = math.min(idx - 1, GM_CONSTANTS.ADDON_MAX_ITEMS)

  return items, numberOfItems
end
