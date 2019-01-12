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
mod.cooldown = me

me.tag = "Cooldown"

--[[
  Update cooldowns
]]--
function me.CooldownUpdate()
  if getglobal(GM_CONSTANTS.ELEMENT_MAIN_FRAME):IsVisible() then
    mod.itemManager.UpdateCooldownForAllWornItems()
  end
end

--[[
  Update cooldown for all bagged items

  @param {table} baggedItems
]]--
function me.UpdateCooldownForBaggedItems(baggedItems)
  if baggedItems == nil or table.getn(baggedItems) == 0 then return end -- no other items available abort

  for i = 1, table.getn(baggedItems) do
    local start, duration, enable = GetContainerItemCooldown(baggedItems[i].bag, baggedItems[i].slot)

    CooldownFrame_SetTimer(
      getglobal(GM_CONSTANTS.ELEMENT_MENU_ITEM .. i .. "Cooldown"),
      start, duration, enable
    )

    if mod.addonOptions.IsShowCooldownsEnabled() then
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

  if mod.addonOptions.IsShowCooldownsEnabled() then
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
