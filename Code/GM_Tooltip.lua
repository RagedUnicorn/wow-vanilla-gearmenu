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
mod.tooltip = me

me.tag = "Tooltip"

--[[
  Private
]]--
local tooltipBag = 0
local tooltipSlot = 0
local tooltipType = ""

local TOOLTIP_TYPE_BAG = "Bag"
local TOOLTIP_TYPE_ITEMSLOT = "ItemSlot"

--[[
  @param {number} id
  @param {table} BaggedItems
]]--
function me.BuildTooltipForBaggedItems(id, BaggedItems)
  tooltipBag = BaggedItems[id].bag
  tooltipSlot = BaggedItems[id].slot
  tooltipType = TOOLTIP_TYPE_BAG

  mod.timer.StartTimer("TooltipUpdate", 0)
end

--[[
  Build tooltip for an items that is worn by the player

  @param {number} slotId
]]--
function me.BuildTooltipForWornItem(slotId)
  tooltipSlot = slotId
  tooltipType = TOOLTIP_TYPE_ITEMSLOT

  mod.timer.StartTimer("TooltipUpdate", 0)
end

--[[
  Build tooltip for general menu options

  @param {string} line1
  @param {string} line2
]]--
function me.BuildTooltipForOption(line1, line2)
  local tooltip = getglobal(GM_CONSTANTS.ELEMENT_TOOLTIP)

  tooltip:AddLine(line1)
  tooltip:AddLine(line2, .8, .8, .8, 1)
  -- set explicit backdrop color fixing display issue for first shown tooltip
  tooltip:SetBackdropColor(0, 0, 0, .7)
  tooltip:Show()
end

--[[
  Update the tooltip
]]--
function me.TooltipUpdate()
  if GearMenuOptions.disableTooltips then return end

  local tooltip = getglobal(GM_CONSTANTS.ELEMENT_TOOLTIP)

  tooltip:ClearLines()

  if tooltipType == TOOLTIP_TYPE_BAG then
    if GearMenuOptions.smallTooltips then
      local itemLink = GetContainerItemLink(tooltipBag, tooltipSlot)
      local _, _, color, id = string.find(itemLink, "^|c([|%a%d]+)|Hitem:(%d+)")
      local _, _, name = string.find(itemLink, "%[([%a%s%d',-:]+)%]")

      tooltip:AddLine("|c" .. color .. name .. "|h|r")
    else
      tooltip:SetBagItem(tooltipBag, tooltipSlot)
    end
  else
    if GearMenuOptions.smallTooltips then
      local itemLink = GetInventoryItemLink("player", tooltipSlot)

      -- if the player has nothing equiped in this slot abort
      if not itemLink then return end

      local _, _, color, id = string.find(itemLink, "^|c([|%a%d]+)|Hitem:(%d+)")
      local _, _, name = string.find(itemLink, "%[([%a%s%d',-:]+)%]")

      tooltip:AddLine("|c" .. color .. name .. "|h|r")
    else
      tooltip:SetInventoryItem("player", tooltipSlot)
    end
  end

  -- set explicit backdrop color fixing display issue for first shown tooltip
  tooltip:SetBackdropColor(0, 0, 0, .7)
  tooltip:Show()
end

--[[
  Remove tooltip after region leave
]]--
function me.TooltipClear()
  mod.logger.LogDebug(me.tag, "Cleared Tooltip")
  mod.timer.StopTimer("TooltipUpdate")
  getglobal(GM_CONSTANTS.ELEMENT_TOOLTIP):Hide()
end
