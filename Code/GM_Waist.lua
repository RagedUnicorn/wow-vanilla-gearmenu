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
mod.waist = me
me.id = 6
me.moduleName = "waist"
me.tag = "Waist"
me.timer = "UpdateWornWaist"

--[[
  private variables
]]--
local slotDisabled = false
-- default position, use 0 for disabling
local slotPosition = 3

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
  update the currently worn item at inventory place {id}
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
  retrieve all items from inventory bags matching type INVTYPE_WAIST
  @return {table}, {number}
]]--
function me.GetItems()
  mod.logger.LogDebug(me.tag, "Retrieving items for category: " .. GM_CONSTANTS.CATEGORIES[GM_CONSTANTS.CATEGORY_WAIST].name)
  return mod.common.GetItemsByType(GM_CONSTANTS.CATEGORY_WAIST)
end
