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
mod.upperTrinket = me

me.id = 13
me.moduleName = "upperTrinket"
me.tag = "UpperTrinket"

--[[
  Private variables
]]--
local slotDisabled = false
-- default position, use 0 for disabling
local slotPosition = 6

function me.SetPosition(position)
  slotPosition = position

  GearMenuOptions.modules[me.moduleName] = position
end

function me.GetPosition()
  return slotPosition
end

function me.SetDisabled(disabled)
  slotDisabled = disabled
end

function me.GetDisabled()
  return slotDisabled
end

--[[
  Update the currently worn item at inventory place {id}
]]--
function me.UpdateWornItem()
  -- abort when item is disabled
  if slotDisabled then return end

  mod.logger.LogDebug(me.tag, "Update worn item")

  getglobal(GM_CONSTANTS.ELEMENT_GM_SLOT .. slotPosition .. "Icon"):SetTexture(mod.common.RetrieveItemInfo(me.id))
  getglobal(GM_CONSTANTS.ELEMENT_GM_SLOT .. slotPosition .. "Icon"):SetDesaturated(0)
  getglobal(GM_CONSTANTS.ELEMENT_GM_SLOT .. slotPosition):SetChecked(0)
  mod.cooldown.UpdateCooldownForWornItem(me.id, slotPosition)
end

--[[
  Retrieve all items from inventory bags matching type INVTYPE_TRINKET

  @return {table}, {number}
]]--
function me.GetItems()
  mod.logger.LogDebug(me.tag, "Retrieving items for category: " .. GM_CONSTANTS.CATEGORIES[GM_CONSTANTS.CATEGORY_TRINKET].name)
  return mod.common.GetItemsByType(GM_CONSTANTS.CATEGORY_TRINKET)
end
