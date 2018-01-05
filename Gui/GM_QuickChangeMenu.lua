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
mod.quickChangeMenu = me

me.tag = "QuickChangeMenu"

-- id's of the selected item
local changeFromSelectedItem = 0
local changeToSelectedItem = 0
local quickChangeRuleSelectedPos = nil
local quickChangeDelay = 0
local editDelayFocus = false

-- saved lists for left and right quick change scrolllists
local changeFromItemList = {}
local changeToItemList = {}

function GM_QuickChangeRulesListUpdate()
  local offset = FauxScrollFrame_GetOffset(GM_QuickChangeRuleScrollFrame) + this:GetID()
  local rules = GearMenuOptions.QuickChangeRules

  FauxScrollFrame_Update(GM_QuickChangeRuleScrollFrame, rules and table.getn(rules) or 0, 5, 24)

  for i = 1, 5 do
    local item = getglobal(GM_CONSTANTS.ELEMENT_GM_QUICK_CHANGE_RULE_CELL .. i)
    local itemNameLeft = getglobal(GM_CONSTANTS.ELEMENT_GM_QUICK_CHANGE_RULE_CELL .. i .. "NameLeft")
    local itemIconLeft = getglobal(GM_CONSTANTS.ELEMENT_GM_QUICK_CHANGE_RULE_CELL .. i .. "IconLeft")
    local itemNameRight= getglobal(GM_CONSTANTS.ELEMENT_GM_QUICK_CHANGE_RULE_CELL .. i .. "NameRight")
    local itemIconRight = getglobal(GM_CONSTANTS.ELEMENT_GM_QUICK_CHANGE_RULE_CELL .. i .. "IconRight")

    local idx = offset + i

    if idx <= table.getn(rules) then
      -- prepare left items
      local changeFromName, _, itemFromQuality, _, _, _, _, equipFromSlot, itemFromTexture = GetItemInfo(rules[idx].changeFromID)

      itemIconLeft:SetTexture(itemFromTexture)
      itemNameLeft:SetText(rules[idx].changeFromName)
      r, g, b = GetItemQualityColor(itemFromQuality)
      itemNameLeft:SetTextColor(r, g, b)
      itemIconLeft:SetVertexColor(1, 1, 1)
      -- prepare right item
      local changeToName, _, itemToQuality, _, _, _, _, equipToSlot, itemToTexture = GetItemInfo(rules[idx].changeToID)

      itemIconRight:SetTexture(itemToTexture)
      itemNameRight:SetText(rules[idx].changeToName)
      r, g, b = GetItemQualityColor(itemToQuality)
      itemNameRight:SetTextColor(r, g, b)
      itemIconRight:SetVertexColor(1, 1, 1)

      item:Show()
    else
      item:Hide()
    end
  end
end

function GM_QuickChangeRuleListCell_OnClick()
  local idx = FauxScrollFrame_GetOffset(GM_QuickChangeRuleScrollFrame) + this:GetID()

  quickChangeRuleSelectedPos = idx
  -- clear all current highlighting
  me.ClearCellList(GM_CONSTANTS.ELEMENT_GM_QUICK_CHANGE_RULE_CELL, 5)

  this.selectedItem = true
  getglobal(this:GetName() .. "Highlight"):Show()
end

function GM_ChangeFromList_Update(itemType)
  local itemList, offset

  if itemType == nil then
    itemType = UIDropDownMenu_GetSelectedValue(getglobal(GM_CONSTANTS.ELEMENT_GM_CHOOSE_CATEGORY))
  end

  itemList = mod.common.GetItemsByType(itemType, true)
  changeFromItemList = me.FilterDuplicateItems(itemList)
  FauxScrollFrame_Update(GM_QuickChange_ChangeFromScrollFrame, changeFromItemList and table.getn(changeFromItemList) or 0, 9, 24)
  -- clear highlighted cells on scroll
  me.ClearCellList(GM_CONSTANTS.ELEMENT_GM_CHANGE_FROM_CELL, 9, true)
  offset = FauxScrollFrame_GetOffset(GM_QuickChange_ChangeFromScrollFrame)

  for i = 1, 9 do
    local item = getglobal(GM_CONSTANTS.ELEMENT_GM_CHANGE_FROM_CELL .. i)
    local itemName = getglobal(GM_CONSTANTS.ELEMENT_GM_CHANGE_FROM_CELL .. i .. "Name")
    local itemIcon = getglobal(GM_CONSTANTS.ELEMENT_GM_CHANGE_FROM_CELL .. i .. "Icon")

    local idx = offset + i

    if idx <= table.getn(changeFromItemList) then
      itemIcon:SetTexture(changeFromItemList[idx].texture)
      itemName:SetText(changeFromItemList[idx].name)
      r, g, b = GetItemQualityColor(changeFromItemList[idx].quality)
      itemName:SetTextColor(r, g, b)
      itemIcon:SetVertexColor(1, 1, 1)

      if changeFromSelectedItem == changeFromItemList[idx].id then
        -- reapply highlight after scrolling
        getglobal(GM_CONSTANTS.ELEMENT_GM_CHANGE_FROM_CELL .. i .. "Highlight"):Show()
        item.selectedItem = true
      end

      item:Show()
    else
      item:Hide()
    end
  end
end

function GM_ChangeToList_Update(itemType)
  local itemList, offset

  if itemType == nil then
    itemType = UIDropDownMenu_GetSelectedValue(getglobal(GM_CONSTANTS.ELEMENT_GM_CHOOSE_CATEGORY))
  end

  itemList = mod.common.GetItemsByType(itemType, true)
  changeToItemList = me.FilterDuplicateItems(itemList)
  FauxScrollFrame_Update(GM_QuickChange_ChangeToScrollFrame, changeToItemList and table.getn(changeToItemList) or 0, 9, 24)
  -- clear highlighted cells on scroll
  me.ClearCellList(GM_CONSTANTS.ELEMENT_GM_CHANGE_TO_CELL, 9, true)
  offset = FauxScrollFrame_GetOffset(GM_QuickChange_ChangeToScrollFrame)

  for i = 1, 9 do
    local item = getglobal(GM_CONSTANTS.ELEMENT_GM_CHANGE_TO_CELL .. i)
    local itemName = getglobal(GM_CONSTANTS.ELEMENT_GM_CHANGE_TO_CELL .. i .. "Name")
    local itemIcon = getglobal(GM_CONSTANTS.ELEMENT_GM_CHANGE_TO_CELL .. i .. "Icon")

    local idx = offset + i

    if idx <= table.getn(changeToItemList) then
      itemIcon:SetTexture(changeToItemList[idx].texture)
      itemName:SetText(changeToItemList[idx].name)
      r, g, b = GetItemQualityColor(changeToItemList[idx].quality)
      itemName:SetTextColor(r, g, b)
      itemIcon:SetVertexColor(1, 1, 1)

      if changeToSelectedItem == changeToItemList[idx].id then
        -- reapply highlight after scrolling
        getglobal(GM_CONSTANTS.ELEMENT_GM_CHANGE_TO_CELL .. i .. "Highlight"):Show()
        item.selectedItem = true
      end

      item:Show()
    else
      item:Hide()
    end
  end
end

function GM_ChangeFromListCell_OnClick()
  local idx = FauxScrollFrame_GetOffset(GM_QuickChange_ChangeFromScrollFrame) + this:GetID()

  -- clear all current highlighting
  me.ClearCellList(GM_CONSTANTS.ELEMENT_GM_CHANGE_FROM_CELL, 9)

  -- match clicked id with position in itemList
  local itemName = changeFromItemList[idx].name
  local itemID = changeFromItemList[idx].id

  changeFromSelectedItem = changeFromItemList[idx].id
  this.selectedItem = true
  getglobal(this:GetName() .. "Highlight"):Show()
end

function GM_ChangeToListCell_OnClick()
  local idx = FauxScrollFrame_GetOffset(GM_QuickChange_ChangeToScrollFrame) + this:GetID()

  -- clear all current highlighting
  me.ClearCellList(GM_CONSTANTS.ELEMENT_GM_CHANGE_TO_CELL, 9)

  -- match clicked id with position in itemList
  local itemName = changeToItemList[idx].name
  local itemID = changeToItemList[idx].id

  changeToSelectedItem = changeToItemList[idx].id

  this.selectedItem = true
  getglobal(this:GetName() .. "Highlight"):Show()
end

function GM_AddQuickChangeRule_OnClick()
  -- check for selected items
  if changeFromSelectedItem == 0 or changeToSelectedItem == 0 then
    mod.logger.PrintUserError(gm.L["quick_change_item_select_missing"])
    return
  end

  mod.quickChange.AddQuickChangeRule(changeFromSelectedItem, changeToSelectedItem, quickChangeDelay)
  getglobal(GM_CONSTANTS.ELEMENT_GM_QUICK_CHANGE_ADD_RULE):SetText("0")
  me.ClearCellList(GM_CONSTANTS.ELEMENT_GM_CHANGE_FROM_CELL, 9)
  me.ClearCellList(GM_CONSTANTS.ELEMENT_GM_CHANGE_TO_CELL, 9)
end

function GM_DeleteQuickChangeRule_OnClick()
  if quickChangeRuleSelectedPos ~= nil then
    mod.logger.LogDebug(me.tag, "Removing position " .. quickChangeRuleSelectedPos .. " from QuickChange rules")
    mod.quickChange.RemoveQuickChangeRule(quickChangeRuleSelectedPos)
  else
    return nil
  end
end

function GM_QuickChangeDelay_OnTextChanged()
  local delay = tonumber(this:GetText())
  -- set default to 0 sek delay
  if delay == nil and not editDelayFocus then
    this:SetText("0")
    delay = 0
  else
    this:SetText(tostring(delay))
  end

  quickChangeDelay = delay or 0
end

--[[
  Track editbox for delay focus gained
]]--
function GM_QuickChangeDelay_OnEditFocusGained()
  editDelayFocus = true
end

--[[
  Track editbox for delay focus lost
]]--
function GM_QuickChangeDelay_OnEditFocusLost()
  editDelayFocus = false
end

function GM_ItemList_OnShow()
  if (UIDropDownMenu_GetSelectedID(getglobal(GM_CONSTANTS.ELEMENT_GM_CHOOSE_CATEGORY)) ~= nil) then
    local currentValue = UIDropDownMenu_GetSelectedValue(getglobal(GM_CONSTANTS.ELEMENT_GM_CHOOSE_CATEGORY))

    GM_ChangeFromList_Update(currentValue)
    GM_ChangeToList_Update(currentValue)
  end
end

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
  Initialize dropdownmenus for quick change itemtypes
]]--
function me.InitializeDropdownMenu()
  local button

  for i = 1, table.getn(GM_CONSTANTS.CATEGORIES) do
    button = me.CreateDropdownButton(GM_CONSTANTS.CATEGORIES[i].name, i, me.DropDownMenuCallback)
    UIDropDownMenu_AddButton(button)
  end

  if (UIDropDownMenu_GetSelectedID(getglobal(GM_CONSTANTS.ELEMENT_GM_CHOOSE_CATEGORY)) == nil) then
    -- set initial state
    UIDropDownMenu_SetSelectedValue(getglobal(GM_CONSTANTS.ELEMENT_GM_CHOOSE_CATEGORY), GM_CONSTANTS.CATEGORY_TRINKET)
  end
end

--[[
  Callback for optionsmenu dropdowns
]]
function me.DropDownMenuCallback()
  -- UIDROPDOWNMENU_OPEN_MENU is the currently open dropdown menu
  UIDropDownMenu_SetSelectedValue(getglobal(UIDROPDOWNMENU_OPEN_MENU), this.value)

  mod.logger.LogDebug(me.tag, "Changing type to: " .. this.value)

  GM_ChangeFromList_Update(this.value)
  GM_ChangeToList_Update(this.value)
end

--[[
  @param {string} baseName
    name of the button to clear
  @param {number} count
    amount of buttons to clear
  @param {boolean} visual
    whether to clear only visual or also logically
]]--
function me.ClearCellList(baseName, count, visual)
  for i = 1, count do
    if not visual then
      getglobal(baseName .. i).selectedItem = false
    end
    getglobal(baseName .. i .. "Highlight"):Hide()
  end
end

--[[
  Filter retrieved itemlist by itemID

  @param {table} itemList
  @return {table}
]]--
function me.FilterDuplicateItems(itemList)
  local filteredItemList = {}

  for _, item in pairs(itemList) do
    local duplicate = false

    if table.getn(filteredItemList) == 0 then
      table.insert(filteredItemList, item)
    end

    for _, filteredItem in pairs(filteredItemList) do
      if filteredItem.id == item.id then
        duplicate = true
        break
      end
    end

    if not duplicate then
      table.insert(filteredItemList, item)
    end
  end

  return filteredItemList
end
