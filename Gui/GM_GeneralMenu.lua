--[[
  GearMenu - A WoW 1.12.1 Addon to manage quick itemswitching
  Copyright (C) 2017 Michael Wiesendanger <michael.wiesendanger@gmail.com>

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
mod.generalMenu = me

me.tag = "GeneralMenu"

--[[
  private
]]
local mOptions = {
  {"LockWindow", gm.L["lockwindow"], gm.L["lockwindowtooltip"]},
  {"ShowCooldowns", gm.L["showcooldowns"], gm.L["showcooldownstooltip"]},
  {"ShowKeyBindings", gm.L["showkeybindings"], gm.L["showkeybindingstooltip"]},
  {"DisableTooltips", gm.L["showtooltips"], gm.L["showtooltipstooltip"]},
  {"SmallTooltips", gm.L["smalltooltips"], gm.L["smalltooltipstooltip"]},
  {"DisableDragAndDrop", gm.L["disabledraganddrop"], gm.L["disabledraganddroptooltip"]}
}

--[[
  tooltip for options
]]--
function GM_Tooltip_OnEnter()
  local name = this:GetName()

  if not name then return end

  for i = 1, table.getn(mOptions) do
    if name == GM_CONSTANTS.ELEMENT_GM_Opt .. mOptions[i][1] then
      mod.tooltip.BuildTooltipForOption(mOptions[i][2], mOptions[i][3])
    end
  end
end

--[[
  hide options tooltip onleave
]]--
function GM_Tooltip_OnLeave()
  getglobal(GM_CONSTANTS.ELEMENT_GM_TOOLTIP):Hide()
end

function GM_LockWindowOption_OnShow()
  -- load status from config-object
  if GearMenuOptions.windowLocked then
    this:SetChecked(true)
  else
    this:SetChecked(false)
  end
end

function GM_LockWindowOption_OnClick()
  local enabled = this:GetChecked()

  if enabled == 1 then
    GearMenuOptions.windowLocked = true
    mod.opt.ReflectLockState(true)
  else
    GearMenuOptions.windowLocked = false
    mod.opt.ReflectLockState(false)
  end
end

function GM_ShowCooldownsOption_OnShow()
  -- load status from config-object
  if GearMenuOptions.showCooldowns then
    this:SetChecked(true)
  else
    this:SetChecked(false)
  end
end

function GM_ShowCooldownsOption_OnClick()
  local enabled = this:GetChecked()

  if enabled == 1 then
    GearMenuOptions.showCooldowns = true
    mod.gui.ShowCooldowns()
  else
    GearMenuOptions.showCooldowns = false
    mod.gui.HideCooldowns()
  end
end

function GM_ShowKeyBindingsOption_OnShow()
  -- load status from config-object
  if GearMenuOptions.showKeyBindings then
    this:SetChecked(true)
  else
    this:SetChecked(false)
  end
end

function GM_ShowKeyBindingsOption_OnClick()
  local enabled = this:GetChecked()

  if enabled == 1 then
    GearMenuOptions.showKeyBindings = true
    mod.gui.ShowKeyBindings()
  else
    GearMenuOptions.showKeyBindings = false
    mod.gui.HideKeyBindings()
  end
end

function GM_Opt_DisableTooltipsOption_OnClick()
  local enabled = this:GetChecked()

  if enabled == 1 then
    GearMenuOptions.disableTooltips = true
  else
    GearMenuOptions.disableTooltips = false
  end
end

function GM_Opt_DisableTooltipsOption_OnShow()
  -- load status from config-object
  if GearMenuOptions.disableTooltips then
    this:SetChecked(true)
  else
    this:SetChecked(false)
  end
end

function GM_Opt_SmallTooltipsOption_OnClick()
  local enabled = this:GetChecked()

  if enabled == 1 then
    GearMenuOptions.smallTooltips = true
  else
    GearMenuOptions.smallTooltips = false
  end
end

function GM_Opt_SmallTooltipsOption_OnShow()
  -- load status from config-object
  if GearMenuOptions.smallTooltips then
    this:SetChecked(true)
  else
    this:SetChecked(false)
  end
end

function GM_Opt_DisableDragAndDropOption_OnClick()
  local enabled = this:GetChecked()

  if enabled == 1 then
    GearMenuOptions.disableDragAndDrop = true
  else
    GearMenuOptions.disableDragAndDrop = false
  end
end

function GM_Opt_DisableDragAndDropOption_OnShow()
  if GearMenuOptions.disableDragAndDrop then
    this:SetChecked(true)
  else
    this:SetChecked(false)
  end
end

function GM_InitGeneralMenu()
  local item

  for i = 1, table.getn(mOptions) do
    item = getglobal(GM_CONSTANTS.ELEMENT_GM_Opt .. mOptions[i][1] .. "Text")
    if item then
      item:SetText(mOptions[i][2])
      item:SetTextColor(.95, .95, .95)
    end
  end
end

--[[
  create a dropwdownbutton for item quality filter selection
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
  initialize dropdownmenus for item quality filter
]]--
function me.InitializeDropdownMenu()
  local button, itemQualityFilter

  itemQualityFilter = GearMenuOptions.filterItemQuality

  if itemQualityFilter == nil then
    mod.logger.LogWarn(me.tag, "Invalid item quality filter - resetting to default value")
    GearMenuOptions.filterItemQuality = 5
  end

  button = me.CreateDropdownButton(gm.L["item_quality_poor"],
    GM_CONSTANTS.ITEMQUALITY.poor, me.DropDownMenuCallback)
  UIDropDownMenu_AddButton(button)

  button = me.CreateDropdownButton(gm.L["item_quality_common"],
    GM_CONSTANTS.ITEMQUALITY.common, me.DropDownMenuCallback)
  UIDropDownMenu_AddButton(button)

  button = me.CreateDropdownButton(gm.L["item_quality_uncommon"],
    GM_CONSTANTS.ITEMQUALITY.uncommon, me.DropDownMenuCallback)
  UIDropDownMenu_AddButton(button)

  button = me.CreateDropdownButton(gm.L["item_quality_rare"],
    GM_CONSTANTS.ITEMQUALITY.rare, me.DropDownMenuCallback)
  UIDropDownMenu_AddButton(button)

  button = me.CreateDropdownButton(gm.L["item_quality_epic"],
    GM_CONSTANTS.ITEMQUALITY.epic, me.DropDownMenuCallback)
  UIDropDownMenu_AddButton(button)

  button = me.CreateDropdownButton(gm.L["item_quality_legendary"],
    GM_CONSTANTS.ITEMQUALITY.legendary, me.DropDownMenuCallback)
  UIDropDownMenu_AddButton(button)

  if (UIDropDownMenu_GetSelectedID(getglobal(GM_CONSTANTS.ELEMENT_GM_OPT_FILTER_ITEM_QUALITY)) == nil) then
    UIDropDownMenu_SetSelectedValue(getglobal(GM_CONSTANTS.ELEMENT_GM_OPT_FILTER_ITEM_QUALITY), itemQualityFilter)
  end
end

--[[
  callback for optionsmenu dropdowns
]]
function me.DropDownMenuCallback()
  local currentValue = UIDropDownMenu_GetSelectedValue(getglobal(UIDROPDOWNMENU_OPEN_MENU))

  -- update addon setting
  GearMenuOptions.filterItemQuality = this.value
  -- UIDROPDOWNMENU_OPEN_MENU is the currently open dropdown menu
  UIDropDownMenu_SetSelectedValue(getglobal(UIDROPDOWNMENU_OPEN_MENU), this.value)
end
