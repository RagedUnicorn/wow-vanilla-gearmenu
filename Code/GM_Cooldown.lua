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
mod.cooldown = me

me.tag = "Cooldown"
-- table of used items and their respective cooldown
local itemsUsed = {}

--[[
  Update cooldowns
]]--
function me.CooldownUpdate()
  local inv, bag, slot, start, duration, itemId, remain

  for i in itemsUsed do
    start, itemId = nil
    inv, bag, slot = watch[i].inv, watch[i].bag, watch[i].slot

    if inv then -- if it was last seen in an inv slot, get name in that slot
      _, _, itemId = strfind(GetInventoryItemLink("player", inv) or "", itemId, 1, 1)
    end

    if bag then -- if it was last seen in a container slot, get name in that slot
      _, _, itemId = strfind(GetContainerItemLink("player", bag, slot) or "", itemId, 1, 1)
    end

    if itemId ~= i then -- item has moved
      inv, bag, slot = mod.itemHelper.FindItemById(i, true)
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

  if getglobal(GM_CONSTANTS.ELEMENT_MAIN_FRAME):IsVisible() then
    mod.itemManager.UpdateCooldownForAllWornItems()
  end
end

--[[
  Update cooldown for all bagged items

  @param {number} numberOfItems
  @param {table} BaggedItems
]]--
function me.UpdateCooldownForBaggedItems(numberOfItems, BaggedItems)
  for i = 1, numberOfItems do
    local start, duration, enable = GetContainerItemCooldown(BaggedItems[i].bag, BaggedItems[i].slot)

    CooldownFrame_SetTimer(
      getglobal(GM_CONSTANTS.ELEMENT_MENU_ITEM .. i .. "Cooldown"),
      start, duration, enable
    )

    if GearMenuOptions.showCooldowns then
      me.SetCooldownFont(GM_CONSTANTS.ELEMENT_MENU_ITEM .. i)
      me.SetCooldown(getglobal(GM_CONSTANTS.ELEMENT_MENU_ITEM .. i .. "Time"), start, duration)
    end
  end
end

--[[
  Update cooldown for a worn itemManager

  @param {number} slotId
  @param {number} position
]]--
function me.UpdateCooldownForWornItem(slotId, position)
  local start, duration, enable = GetInventoryItemCooldown("player", slotId)

  CooldownFrame_SetTimer(
    getglobal(GM_CONSTANTS.ELEMENT_SLOT .. position .. "Cooldown"),
    start, duration, enable
  )

  if GearMenuOptions.showCooldowns then
    local frame = getglobal(GM_CONSTANTS.ELEMENT_SLOT .. position .. "Time")
    me.SetCooldownFont(GM_CONSTANTS.ELEMENT_SLOT .. position)
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
