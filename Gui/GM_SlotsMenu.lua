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
  local button, position, item

  position = mod.common.ExtractPositionFromName(this:GetName())
  item = mod.itemManager.FindItemForSlotPosition(position)

  button = me.CreateDropdownButton(
    gm.L[GM_CONSTANTS.ITEMS.HEAD.localizationKey],
    GM_CONSTANTS.ITEMS.HEAD.slotId,
    me.DropDownMenuCallback
  )
  UIDropDownMenu_AddButton(button)

  button = me.CreateDropdownButton(
    gm.L[GM_CONSTANTS.ITEMS.WAIST.localizationKey],
    GM_CONSTANTS.ITEMS.WAIST.slotId,
    me.DropDownMenuCallback
  )
  UIDropDownMenu_AddButton(button)

  button = me.CreateDropdownButton(
    gm.L[GM_CONSTANTS.ITEMS.FEET.localizationKey],
    GM_CONSTANTS.ITEMS.FEET.slotId,
    me.DropDownMenuCallback
  )
  UIDropDownMenu_AddButton(button)

  button = me.CreateDropdownButton(
    gm.L[GM_CONSTANTS.ITEMS.UPPER_TRINKET.localizationKey],
    GM_CONSTANTS.ITEMS.UPPER_TRINKET.slotId,
    me.DropDownMenuCallback
  )
  UIDropDownMenu_AddButton(button)

  button = me.CreateDropdownButton(
    gm.L[GM_CONSTANTS.ITEMS.LOWER_TRINKET.localizationKey],
    GM_CONSTANTS.ITEMS.LOWER_TRINKET.slotId,
    me.DropDownMenuCallback
  )
  UIDropDownMenu_AddButton(button)

  button = me.CreateDropdownButton(
    gm.L[GM_CONSTANTS.ITEMS.MAINHAND.localizationKey],
    GM_CONSTANTS.ITEMS.MAINHAND.slotId,
    me.DropDownMenuCallback
  )
  UIDropDownMenu_AddButton(button)

  button = me.CreateDropdownButton(
    gm.L[GM_CONSTANTS.ITEMS.OFFHAND.localizationKey],
    GM_CONSTANTS.ITEMS.OFFHAND.slotId,
    me.DropDownMenuCallback
  )
  UIDropDownMenu_AddButton(button)

  button = me.CreateDropdownButton("None", 0, me.DropDownMenuCallback)
  UIDropDownMenu_AddButton(button)

  if (UIDropDownMenu_GetSelectedID(getglobal(GM_CONSTANTS.ELEMENT_OPT_SLOT .. position)) == nil) then
    if item then
      UIDropDownMenu_SetSelectedValue(getglobal(GM_CONSTANTS.ELEMENT_OPT_SLOT .. position), item.slotId)
    else
      UIDropDownMenu_SetSelectedValue(getglobal(GM_CONSTANTS.ELEMENT_OPT_SLOT .. position), 0)
    end
  end
end

--[[
  Callback for optionsmenu dropdowns
]]
function me.DropDownMenuCallback()
  local currentValue = UIDropDownMenu_GetSelectedValue(getglobal(UIDROPDOWNMENU_OPEN_MENU))
  local newValue = this.value

  if newValue == 0 then
    -- disabling a slot is always possible
    mod.itemManager.DisableItem(currentValue)

    local _, _, slotPosition = strfind(getglobal(UIDROPDOWNMENU_OPEN_MENU):GetName(),
      GM_CONSTANTS.ELEMENT_OPT_SLOT .. "(%d+)")
    mod.gui.HideSlot(slotPosition)
  else
    if mod.itemManager.IsPositionInUse(newValue) then
      mod.logger.LogDebug(me.tag, "Abort selection item is already in use in another slot")
      mod.logger.PrintUserError(gm.L["slot_menu_slot_already_in_use"])
      -- abort already in use
      return
    else
      -- item is not in use allow change
      local _, _, slotPosition = strfind(getglobal(UIDROPDOWNMENU_OPEN_MENU):GetName(),
        GM_CONSTANTS.ELEMENT_OPT_SLOT .. "(%d+)")
      mod.itemManager.DisableItem(currentValue)
      mod.itemManager.EnableItem(newValue, tonumber(slotPosition))
      mod.gui.ShowSlot(slotPosition)
    end
  end

  -- UIDROPDOWNMENU_OPEN_MENU is the currently open dropdown menu
  UIDropDownMenu_SetSelectedValue(getglobal(UIDROPDOWNMENU_OPEN_MENU), newValue)
  mod.itemManager.UpdateWornItems()
end
