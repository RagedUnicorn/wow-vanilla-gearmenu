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
mod.generalMenu = me

me.tag = "GeneralMenu"

--[[
  Private
]]
local options = {
  {"LockWindow", gm.L["lockwindow"], gm.L["lockwindowtooltip"]},
  {"ShowCooldowns", gm.L["showcooldowns"], gm.L["showcooldownstooltip"]},
  {"ShowKeyBindings", gm.L["showkeybindings"], gm.L["showkeybindingstooltip"]},
  {"DisableTooltips", gm.L["showtooltips"], gm.L["showtooltipstooltip"]},
  {"SmallTooltips", gm.L["smalltooltips"], gm.L["smalltooltipstooltip"]},
  {"DisableDragAndDrop", gm.L["disabledraganddrop"], gm.L["disabledraganddroptooltip"]}
}

--[[
  Tooltip for options
]]--
function GM_Tooltip_OnEnter()
  local name = this:GetName()

  if not name then return end

  for i = 1, table.getn(options) do
    if name == GM_CONSTANTS.ELEMENT_GM_Opt .. options[i][1] then
      mod.tooltip.BuildTooltipForOption(options[i][2], options[i][3])
    end
  end
end

--[[
  Hide options tooltip onleave
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

  for i = 1, table.getn(options) do
    item = getglobal(GM_CONSTANTS.ELEMENT_GM_Opt .. options[i][1] .. "Text")
    if item then
      item:SetText(options[i][2])
      item:SetTextColor(.95, .95, .95)
    end
  end
end

--[[
  Create a dropwdownbutton for item quality filter selection

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
  Initialize dropdownmenus for item quality filter
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
  Callback for optionsmenu dropdowns
]]
function me.DropDownMenuCallback()
  -- update addon setting
  GearMenuOptions.filterItemQuality = tonumber(this.value)
  -- UIDROPDOWNMENU_OPEN_MENU is the currently open dropdown menu
  UIDropDownMenu_SetSelectedValue(getglobal(UIDROPDOWNMENU_OPEN_MENU), this.value)
end
