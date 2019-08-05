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
  Itemmanager manages all items. All itemslots must register to work properly
]]--
local mod = gm
local me = {}
mod.itemManager = me

me.tag = "ItemManager"

local items = {}


--[[
  Register an item to the itemManager
  @param {string} name
    Name of the item such as mainHand
  @param {string} localizationKey
    Key reference to the translation
  @param {number} slotId
    Slot number defined by Blizzard - See GM_CONSTANTS.ITEM_CATEGORIES for details
  @param {number} gmSlotPosition
    The position within GearMenu slots
  @param {boolean} gmSlotDisabled
    Whether the GearMenu slot is disabled or not

  @param {string} name
]]--
function me.RegisterItem(name, localizationKey, slotId, gmSlotPosition, gmSlotDisabled)
  if items[name] == nil then
    items[name] = {
      ["slotId"] = slotId,
      ["localizationKey"] = localizationKey,
      ["gmSlotPosition"] = gmSlotPosition,
      ["gmSlotDisabled"] = gmSlotDisabled
    }
  else
    mod.logger.LogError(me.tag, "Item with name " .. name .. " is already registered")
    return
  end
end

--[[
  Unregister an item from the itemManager

  @param {string} name
]]--
function me.UnregisterItem(name)
  mod.logger.LogInfo(me.tag, "Unregister item with name " .. name .. " from itemManager")
  items[name] = nil
end

--[[
  @param {number} slotId
]]--
function me.DisableItem(slotId)
  for itemName, item in pairs(items) do
    if item.slotId == slotId then
      item.gmSlotDisabled = true
      item.gmSlotPosition = nil
      mod.addonOptions.DisableItem(itemName)

      return
    end
  end
end

--[[
  @param {number} slotId
  @param {number} slotPosition
]]--
function me.EnableItem(slotId, slotPosition)
  for itemName, item in pairs(items) do
    if item.slotId == slotId then
      item.gmSlotDisabled = false
      item.gmSlotPosition = slotPosition
      mod.addonOptions.EnableItem(itemName, slotPosition)

      return
    end
  end
end

--[[
  Calls UpdateWornItem for all registered items
]]--
function me.UpdateWornItems()
  for _, item in pairs(items) do
    me.UpdateWornItem(item)
  end
end

--[[
  Update the currently worn item at inventory place {id}

  @param {table} item
]]--
function me.UpdateWornItem(item)
  -- abort when item is disabled
  if item.gmSlotDisabled then return end

  mod.logger.LogDebug(me.tag, "Update worn item")

  getglobal(GM_CONSTANTS.ELEMENT_SLOT .. item.gmSlotPosition .. "Icon"):SetTexture(mod.itemHelper.RetrieveItemInfo(item.slotId))
  getglobal(GM_CONSTANTS.ELEMENT_SLOT .. item.gmSlotPosition .. "Icon"):SetDesaturated(0)
  getglobal(GM_CONSTANTS.ELEMENT_SLOT .. item.gmSlotPosition):SetChecked(0)
  mod.cooldown.UpdateCooldownForWornItem(item.slotId, item.gmSlotPosition)
end

--[[
  @param {number} slotId
  @param {boolean} includeEquiped
    whether the currently equiped item should be included in the result or not

  @return {table}
]]--
function me.GetItemsForSlotId(slotId, includeEquiped)
  mod.logger.LogDebug(me.tag, "Retrieving items for category: " .. GM_CONSTANTS.ITEM_CATEGORIES[slotId].name)
  return me.GetItemsByType(slotId, includeEquiped)
end

--[[
  Retrieve all items from inventory bags matching any type of
    INVTYPE_AMMO
    INVTYPE_HEAD
    INVTYPE_NECK
    INVTYPE_SHOULDER
    INVTYPE_BODY
    INVTYPE_CHEST
    INVTYPE_ROBE
    INVTYPE_WAIST
    INVTYPE_LEGS
    INVTYPE_FEET
    INVTYPE_WRIST
    INVTYPE_HAND
    INVTYPE_FINGER
    INVTYPE_TRINKET
    INVTYPE_CLOAK
    INVTYPE_WEAPON
    INVTYPE_SHIELD
    INVTYPE_2HWEAPON
    INVTYPE_WEAPONMAINHAND
    INVTYPE_WEAPONOFFHAND

  Depending on the type that is passed to the function. For available types see
  GM_CONSTANTS ITEM_CATEGORIES.

  @param {number} slotId
    see GM_CONSTANTS ITEM_CATEGORIES for a reference
  @param {boolean} includeEquiped
    whether the currently equiped item should be included in the result or not
  @return {table}
]]--
function me.GetItemsByType(slotId, includeEquiped)
  local idx = 1
  local itemTypes = GM_CONSTANTS.ITEM_CATEGORIES[slotId].type
  local items = {}

  if itemTypes == nil then
    mod.logger.LogError(me.tag, "Itemtype(s) missing")
    return nil
  end

  for i = 0, 4 do
    for j = 1, GetContainerNumSlots(i) do
      local itemLink = GetContainerItemLink(i, j)

      if itemLink then
        local _, _, itemId, itemName = strfind(GetContainerItemLink(i, j) or "", "item:(%d+).+%[(.+)%]")
        local _, _, itemQuality, _, _, _, _, equipSlot, itemTexture = GetItemInfo(itemId or "")

        for it = 1, table.getn(itemTypes) do
          if equipSlot == itemTypes[it] then
            if itemQuality >= mod.addonOptions.GetFilterItemQuality() then
              if not items[idx] then
                items[idx] = {}
              end

              items[idx].bag = i
              items[idx].slot = j
              items[idx].name = itemName
              items[idx].texture = itemTexture
              items[idx].id = itemId
              items[idx].equipSlot = equipSlot
              items[idx].quality = itemQuality

              idx = idx + 1
            else
              mod.logger.LogDebug(me.tag, "Ignoring item because its quality is lower than setting "
                .. mod.addonOptions.GetFilterItemQuality())
            end
          end
        end
      end
    end
  end

  -- include currently equiped items
  if includeEquiped then
    for i = 1, table.getn(itemTypes) do
      for it = 1, table.getn(GM_CONSTANTS.ITEM_CATEGORIES[slotId].slotId) do
        local _, _, itemId, itemName = strfind(GetInventoryItemLink("player",
          GM_CONSTANTS.ITEM_CATEGORIES[slotId].slotId[it]) or "", "item:(%d+).+%[(.+)%]")

        if itemId then
          local _, _, itemQuality, _, _, _, _, equipSlot, itemTexture = GetItemInfo(itemId or "")

          if itemQuality and itemQuality >= mod.addonOptions.GetFilterItemQuality() then
            if not items[idx] then
              items[idx] = {}
            end

            items[idx].bag = i
            items[idx].slot = j
            items[idx].name = itemName
            items[idx].texture = itemTexture
            items[idx].id = itemId
            items[idx].equipSlot = equipSlot
            items[idx].quality = itemQuality

            idx = idx + 1
          else
            mod.logger.LogDebug(me.tag, "Ignoring item because its quality is lower than setting - "
              .. mod.addonOptions.GetFilterItemQuality())
          end
        else
          mod.logger.LogDebug(me.tag, "Ignoring slot because no item could be found")
        end
      end
    end
  end

  return items
end

--[[
  Retrieve all currently registered items

  @return {table}
]]--
function me.GetAllRegisteredItems()
  return items
end

--[[
  Returns the item that is placed at the passed position or nil if none could be found

  @param {number} gmSlotPosition
  @return {table | nil}
]]--
function me.FindItemForSlotPosition(gmSlotPosition)
  for name, item in pairs(items) do
    if item.gmSlotPosition == gmSlotPosition then
      return item
    end
  end

  mod.logger.LogInfo(me.tag, "No item found for slotPosition: " .. gmSlotPosition)
  return nil
end

--[[
  Returns the item that matches the passed slotId or nil if none could be found

  @param {number} id
  @return {table | nil}
]]
function me.FindItemForSlotId(slotId)
  for _, item in pairs(items) do
    if item.slotId == slotId then
      return item
    end
  end

  return nil
end

--[[
  Update cooldown for all registered items
]]--
function me.UpdateCooldownForAllWornItems()
  for _, item in pairs(items) do
    -- check if item is disabled
    if item.gmSlotDisabled ~= true then
      mod.cooldown.UpdateCooldownForWornItem(item.slotId, item.gmSlotPosition)
    end
  end
end

--[[
  Check if a position is already used in a slot

  @param {number} slotId
  @return {boolean | nil}
    false when item is not used
    true if item is already used in a slot
]]--
function me.IsPositionInUse(slotId)
  if slotId == 0 then return false end

  for _, item in pairs(items) do
    if item.slotId == slotId then
      if item.gmSlotDisabled then
        return false
      else
        return true
      end
    end
  end

  return nil
end
