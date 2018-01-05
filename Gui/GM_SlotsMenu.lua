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
mod.slotsMenu = me

me.tag = "SlotsMenu"

--[[
  Create a dropwdownbutton for item slot selection

  @param {string} text
  @param {string} value
  @param {function} callback
  @return {table} button
]]--
function me.CreateDropdownButton(text, value, callback)
  local button = {}

  button.text = text
  button.value = value
  button.func = callback

  return button
end

--[[
  Initialize dropdownmenus for slotpositions
]]--
function me.InitializeDropdownMenu()
  local button, position, moduleName

  position = mod.common.ExtractPositionFromName(this:GetName())
  moduleName = mod.itemManager.FindModuleForPosition(position)

  button = me.CreateDropdownButton(mod.mainHand.tag, mod.mainHand.id, me.DropDownMenuCallback)
  UIDropDownMenu_AddButton(button)

  button = me.CreateDropdownButton(mod.offHand.tag, mod.offHand.id, me.DropDownMenuCallback)
  UIDropDownMenu_AddButton(button)

  button = me.CreateDropdownButton(mod.waist.tag, mod.waist.id, me.DropDownMenuCallback)
  UIDropDownMenu_AddButton(button)

  button = me.CreateDropdownButton(mod.feet.tag, mod.feet.id, me.DropDownMenuCallback)
  UIDropDownMenu_AddButton(button)

  button = me.CreateDropdownButton(mod.head.tag, mod.head.id, me.DropDownMenuCallback)
  UIDropDownMenu_AddButton(button)

  button = me.CreateDropdownButton(mod.upperTrinket.tag, mod.upperTrinket.id, me.DropDownMenuCallback)
  UIDropDownMenu_AddButton(button)

  button = me.CreateDropdownButton(mod.lowerTrinket.tag, mod.lowerTrinket.id, me.DropDownMenuCallback)
  UIDropDownMenu_AddButton(button)

  button = me.CreateDropdownButton("None", 0, me.DropDownMenuCallback)
  UIDropDownMenu_AddButton(button)

  if (UIDropDownMenu_GetSelectedID(getglobal(GM_CONSTANTS.ELEMENT_GM_OPT_SLOT .. position)) == nil) then
    if moduleName then
      UIDropDownMenu_SetSelectedValue(getglobal(GM_CONSTANTS.ELEMENT_GM_OPT_SLOT .. position), mod[moduleName].id)
    else
      UIDropDownMenu_SetSelectedValue(getglobal(GM_CONSTANTS.ELEMENT_GM_OPT_SLOT .. position), 0)
    end
  end
end

--[[
  Callback for optionsmenu dropdowns
]]
function me.DropDownMenuCallback()
  local currentValue = UIDropDownMenu_GetSelectedValue(getglobal(UIDROPDOWNMENU_OPEN_MENU))

  local isUsed = mod.itemManager.IsPositionInUse(this.value)
  if isUsed then
    mod.logger.LogDebug(me.tag, "Abort selection item is already in use in another slot")
    mod.logger.PrintUserError(gm.L["slot_menu_slot_already_in_use"])
    -- abort already in use
    return
  end

  -- when the currentValue is not equal to the selectedValue we need to deactivate the item
  if currentValue ~= 0 and currentValue ~= this.value then
    local moduleName = mod.itemManager.FindItemForSlotID(currentValue)
    mod[moduleName].SetPosition(0)
    mod[moduleName].SetDisabled(true)
  end

  local _, _, slotPosition = strfind(getglobal(UIDROPDOWNMENU_OPEN_MENU):GetName(),
    GM_CONSTANTS.ELEMENT_GM_OPT_SLOT .. "(%d+)")

  -- activate item
  if this.value ~= 0 then
    local moduleName = mod.itemManager.FindItemForSlotID(this.value)
    mod[moduleName].SetPosition(tonumber(slotPosition))
    mod[moduleName].SetDisabled(false)

    mod.gui.ShowSlot(slotPosition)
  end

  if this.value == 0 then
    mod.gui.HideSlot(slotPosition)
  end

  mod.itemManager.UpdateWornItems()

  -- UIDROPDOWNMENU_OPEN_MENU is the currently open dropdown menu
  UIDropDownMenu_SetSelectedValue(getglobal(UIDROPDOWNMENU_OPEN_MENU), this.value)
end
