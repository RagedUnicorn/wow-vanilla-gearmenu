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
mod.cooldown = me

me.tag = "Cooldown"
-- table of used items and their respective cooldown
local itemsUsed = {}

--[[
  Update cooldowns
]]--
function me.CooldownUpdate()
  local inv, bag, slot, start, duration, itemID, remain

  for i in itemsUsed do
    start, itemID = nil
    inv, bag, slot = watch[i].inv, watch[i].bag, watch[i].slot

    if inv then -- if it was last seen in an inv slot, get name in that slot
      _, _, itemID = strfind(GetInventoryItemLink("player", inv) or "", itemID, 1, 1)
    end

    if bag then -- if it was last seen in a container slot, get name in that slot
      _, _, itemID = strfind(GetContainerItemLink("player", bag, slot) or "", itemID, 1, 1)
    end

    if itemID ~= i then -- item has moved
      inv, bag, slot = mod.common.FindItemByID(i, 1)
      watch[i].inv, watch[i].bag, watch[i].slot = inv, bag, slot
    end

    if inv then
      start, duration = GetInventoryItemCooldown("player", inv)
    elseif bag then
      start, duration = GetContainerItemCooldown(bag, slot)
    else
      itemsUsed[i] = nil
    end

    if start and itemsUsed[i] < 3 then
      itemsUsed[i] = itemsUsed[i] + 1 -- count for 3 seconds before seeing if this is a real cooldown
    elseif start then
      if start > 0 then
        remain = duration - (GetTime() - start)
        if itemsUsed[i] < 5 then
          if remain > 29 then
            itemsUsed[i] = 30 -- first actual cooldown greater than 30 seconds, tag it for 30 + 0 notify
          elseif remain > 5 then
            itemsUsed[i] = 5 -- first actual cooldown less than 30 but greater than 5, tag for 0 notify
          end
        end
      end

      -- no cooldown has started - remove from used items
      if start == 0 then
        itemsUsed[i] = nil
      end
    end
  end

  if getglobal(GM_CONSTANTS.ELEMENT_GM_MAIN_FRAME):IsVisible() then
    mod.itemManager.UpdateCooldownForAllWornItems()
  end
end

--[[
  Update cooldown for all bagged items

  @param {number} numberOfItems
  @param {table} BaggedItems
]]--
function me.UpdateCooldownForBaggedItems(numberOfItems, BaggedItems)
  if GearMenuOptions.showCooldowns then
    local start, duration, enable

    for i = 1, numberOfItems do
      start, duration, enable = GetContainerItemCooldown(BaggedItems[i].bag, BaggedItems[i].slot)
      CooldownFrame_SetTimer(getglobal(GM_CONSTANTS.ELEMENT_GM_MENU_ITEM .. i .. "Cooldown"), start, duration, enable)
      me.SetCooldownFont(GM_CONSTANTS.ELEMENT_GM_MENU_ITEM .. i)
      me.SetCooldown(getglobal(GM_CONSTANTS.ELEMENT_GM_MENU_ITEM .. i .. "Time"), start, duration)
    end
  end
end

--[[
  Update cooldown for a worn itemManager

  @param {number} slotID
  @param {number} position
]]--
function me.UpdateCooldownForWornItem(slotID, position)
  if GearMenuOptions.showCooldowns then
    local start, duration, enable
    start, duration, enable = GetInventoryItemCooldown("player", slotID)
    CooldownFrame_SetTimer(getglobal(GM_CONSTANTS.ELEMENT_GM_SLOT .. position .. "Cooldown"), start, duration, enable)

    local frame = getglobal(GM_CONSTANTS.ELEMENT_GM_SLOT .. position .. "Time")
    me.SetCooldownFont(GM_CONSTANTS.ELEMENT_GM_SLOT .. position)
    me.SetCooldown(frame, start, duration)
  end
end

--[[
  @param {widget} frame
  @param {number} start
  @param {number} duration
]]--
function me.SetCooldown(frame, start, duration)
  local cooldown = duration - (GetTime() - start)
  local cooldownText

  if start == 0 then
    -- item has no cooldown
    frame:SetText("")
  elseif cooldown < 3 and not frame:GetText() then
    -- do not display global cooldown
    -- if there is already a text it is just a cooldown that entered into this state
  else
    if cooldown < 60 then
      cooldownText = math.floor(cooldown + .5) .. " s"
    elseif cooldown < 3600 then
      cooldownText = math.ceil(cooldown / 60) .. " m"
    else
      cooldownText = math.ceil(cooldown / 3600) .. " h"
    end

    frame:SetText(cooldownText)
  end
end

--[[
  @param {string} identifier
]]--
function me.SetCooldownFont(identifier)
  local item = getglobal(identifier .. "Time")
  item:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
  item:SetTextColor(1, .82, 0, 1)
  item:ClearAllPoints()
  item:SetPoint("CENTER", getglobal(identifier), "CENTER")
end
