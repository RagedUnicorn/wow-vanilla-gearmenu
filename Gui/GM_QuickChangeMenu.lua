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
mod.quickChangeMenu = me

me.tag = "QuickChangeMenu"

-- id's of the selected item
local changeFromSelectedItem = 0
local changeToSelectedItem = 0
local quickChangeRuleSelectedPos
local quickChangeDelay = 0
local editDelayFocus = false

-- saved lists for left and right quick change scrolllists
local changeFromItemList = {}
local changeToItemList = {}

--[[
  OnLoad callback for quick change options screen
]]--
function me.QuickChangeScrollFrameOnLoad()
  this:SetVerticalScroll(0)
end

--[[
  OnMouseWheel callback for quick change options screen
]]--
function me.QuickChangeScrollFrameOnMouseWheel()
  local pre, maxScroll, scroll, toScroll

  pre = pre or 20
  maxScroll = getglobal(this:GetName() .. "_Child"):GetHeight() - 100

  if spec then
    maxScroll = maxScroll + 100
  end

  scroll = this:GetVerticalScroll()
  toScroll = (scroll - (pre*arg1))

  if toScroll < 0 or maxScroll < 0 then
    this:SetVerticalScroll(0)
  elseif toScroll > maxScroll then
    this:SetVerticalScroll(maxScroll)
  else
    this:SetVerticalScroll(toScroll)
  end
end

--[[
  OnVerticalScroll callback for quick change rule list
]]--
function me.QuickChangeRuleListOnUpdate()
  local offset = FauxScrollFrame_GetOffset(GM_QuickChangeRuleScrollFrame) + this:GetID()
  local rules = GearMenuOptions.QuickChangeRules

  FauxScrollFrame_Update(GM_QuickChangeRuleScrollFrame, rules and table.getn(rules) or 0, 5, 24)

  for i = 1, 5 do
    local item = getglobal(GM_CONSTANTS.ELEMENT_QUICK_CHANGE_RULE_CELL .. i)
    local itemNameLeft = getglobal(GM_CONSTANTS.ELEMENT_QUICK_CHANGE_RULE_CELL .. i .. "NameLeft")
    local itemIconLeft = getglobal(GM_CONSTANTS.ELEMENT_QUICK_CHANGE_RULE_CELL .. i .. "IconLeft")
    local itemNameRight = getglobal(GM_CONSTANTS.ELEMENT_QUICK_CHANGE_RULE_CELL .. i .. "NameRight")
    local itemIconRight = getglobal(GM_CONSTANTS.ELEMENT_QUICK_CHANGE_RULE_CELL .. i .. "IconRight")

    local idx = offset + i

    if idx <= table.getn(rules) then
      -- prepare left items
      local changeFromName, _, itemFromQuality, _, _, _, _, equipFromSlot, itemFromTexture = GetItemInfo(rules[idx].changeFromId)

      itemIconLeft:SetTexture(itemFromTexture)
      itemNameLeft:SetText(rules[idx].changeFromName)
      r, g, b = GetItemQualityColor(itemFromQuality)
      itemNameLeft:SetTextColor(r, g, b)
      itemIconLeft:SetVertexColor(1, 1, 1)
      -- prepare right item
      local changeToName, _, itemToQuality, _, _, _, _, equipToSlot, itemToTexture = GetItemInfo(rules[idx].changeToId)

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

function me.QuickChangeRuleListCellOnClick()
  local idx = FauxScrollFrame_GetOffset(GM_QuickChangeRuleScrollFrame) + this:GetID()

  quickChangeRuleSelectedPos = idx
  -- clear all current highlighting
  me.ClearCellList(GM_CONSTANTS.ELEMENT_QUICK_CHANGE_RULE_CELL, 5)

  this.selectedItem = true
  getglobal(this:GetName() .. "Highlight"):Show()
end

--[[
  OnUpdate callback for quick change from list

  @param {number} slotId
    see gm_constants categories for a reference
]]--
function me.QuickChangeFromListOnUpdate(slotId)
  local itemList, offset

  if slotId == nil then
    slotId = UIDropDownMenu_GetSelectedValue(getglobal(GM_CONSTANTS.ELEMENT_CHOOSE_CATEGORY))
  end

  itemList = mod.itemManager.GetItemsForSlotId(slotId, true)
  changeFromItemList = me.FilterDuplicateItems(itemList)
  FauxScrollFrame_Update(GM_QuickChange_ChangeFromScrollFrame,
    changeFromItemList and table.getn(changeFromItemList) or 0, 9, 24)
  -- clear highlighted cells on scroll
  me.ClearCellList(GM_CONSTANTS.ELEMENT_CHANGE_FROM_CELL, 9, true)
  offset = FauxScrollFrame_GetOffset(GM_QuickChange_ChangeFromScrollFrame)

  for i = 1, 9 do
    local item = getglobal(GM_CONSTANTS.ELEMENT_CHANGE_FROM_CELL .. i)
    local itemName = getglobal(GM_CONSTANTS.ELEMENT_CHANGE_FROM_CELL .. i .. "Name")
    local itemIcon = getglobal(GM_CONSTANTS.ELEMENT_CHANGE_FROM_CELL .. i .. "Icon")

    local idx = offset + i

    if idx <= table.getn(changeFromItemList) then
      itemIcon:SetTexture(changeFromItemList[idx].texture)
      itemName:SetText(changeFromItemList[idx].name)
      r, g, b = GetItemQualityColor(changeFromItemList[idx].quality)
      itemName:SetTextColor(r, g, b)
      itemIcon:SetVertexColor(1, 1, 1)

      if changeFromSelectedItem == changeFromItemList[idx].id then
        -- reapply highlight after scrolling
        getglobal(GM_CONSTANTS.ELEMENT_CHANGE_FROM_CELL .. i .. "Highlight"):Show()
        item.selectedItem = true
      end

      item:Show()
    else
      item:Hide()
    end
  end
end

--[[
  OnUpdate callback for quick change to list

  @param {number} slotId
    see gm_constants categories for a reference
]]--
function me.QuickChangeToListOnUpdate(slotId)
  local itemList, offset

  if slotId == nil then
    slotId = UIDropDownMenu_GetSelectedValue(getglobal(GM_CONSTANTS.ELEMENT_CHOOSE_CATEGORY))
  end

  itemList = mod.itemManager.GetItemsForSlotId(slotId, true)
  changeToItemList = me.FilterDuplicateItems(itemList)
  FauxScrollFrame_Update(GM_QuickChange_ChangeToScrollFrame,
    changeToItemList and table.getn(changeToItemList) or 0, 9, 24)
  -- clear highlighted cells on scroll
  me.ClearCellList(GM_CONSTANTS.ELEMENT_CHANGE_TO_CELL, 9, true)
  offset = FauxScrollFrame_GetOffset(GM_QuickChange_ChangeToScrollFrame)

  for i = 1, 9 do
    local item = getglobal(GM_CONSTANTS.ELEMENT_CHANGE_TO_CELL .. i)
    local itemName = getglobal(GM_CONSTANTS.ELEMENT_CHANGE_TO_CELL .. i .. "Name")
    local itemIcon = getglobal(GM_CONSTANTS.ELEMENT_CHANGE_TO_CELL .. i .. "Icon")

    local idx = offset + i

    if idx <= table.getn(changeToItemList) then
      itemIcon:SetTexture(changeToItemList[idx].texture)
      itemName:SetText(changeToItemList[idx].name)
      r, g, b = GetItemQualityColor(changeToItemList[idx].quality)
      itemName:SetTextColor(r, g, b)
      itemIcon:SetVertexColor(1, 1, 1)

      if changeToSelectedItem == changeToItemList[idx].id then
        -- reapply highlight after scrolling
        getglobal(GM_CONSTANTS.ELEMENT_CHANGE_TO_CELL .. i .. "Highlight"):Show()
        item.selectedItem = true
      end

      item:Show()
    else
      item:Hide()
    end
  end
end

--[[
  OnClick callback for changefrom list
]]--
function me.ChangeFromListCellOnClick()
  local idx = FauxScrollFrame_GetOffset(GM_QuickChange_ChangeFromScrollFrame) + this:GetID()

  -- clear all current highlighting
  me.ClearCellList(GM_CONSTANTS.ELEMENT_CHANGE_FROM_CELL, 9)

  changeFromSelectedItem = changeFromItemList[idx].id
  this.selectedItem = true
  getglobal(this:GetName() .. "Highlight"):Show()
end

--[[
  OnClick callback for changeto list
]]--
function me.ChangeToListCellOnClick()
  local idx = FauxScrollFrame_GetOffset(GM_QuickChange_ChangeToScrollFrame) + this:GetID()

  -- clear all current highlighting
  me.ClearCellList(GM_CONSTANTS.ELEMENT_CHANGE_TO_CELL, 9)

  changeToSelectedItem = changeToItemList[idx].id

  this.selectedItem = true
  getglobal(this:GetName() .. "Highlight"):Show()
end

--[[
  OnClick callback for add quickchange rule
]]--
function me.AddQuickChangeRuleOnClick()
  -- check for selected items
  if changeFromSelectedItem == 0 or changeToSelectedItem == 0 then
    mod.logger.PrintUserError(gm.L["quick_change_item_select_missing"])
    return
  end

  mod.quickChange.AddQuickChangeRule(changeFromSelectedItem, changeToSelectedItem, quickChangeDelay)
  getglobal(GM_CONSTANTS.ELEMENT_QUICK_CHANGE_ADD_RULE):SetText("0")
  me.ClearCellList(GM_CONSTANTS.ELEMENT_CHANGE_FROM_CELL, 9)
  me.ClearCellList(GM_CONSTANTS.ELEMENT_CHANGE_TO_CELL, 9)
end

--[[
  OnClick callback for delete quickchange rule
]]--
function me.DeleteQuickChangeRuleOnClick()
  if quickChangeRuleSelectedPos ~= nil then
    mod.logger.LogDebug(me.tag, "Removing position " .. quickChangeRuleSelectedPos .. " from QuickChange rules")
    mod.quickChange.RemoveQuickChangeRule(quickChangeRuleSelectedPos)
  else
    return nil
  end
end

--[[
  OnTextChanged callback for quick change delay input field
]]--
function me.QuickChangeDelayOnTextChanged()
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
  OnEditFocusGained callback for quick change delay input field
]]--
function me.QuickChangeDelayOnEditFocusGained()
  editDelayFocus = true
end

--[[
  OnEditFocusLost callback for quick change delay input field
]]--
function me.QuickChangeDelayOnEditFocusLost()
  editDelayFocus = false
end

--[[
  OnShow callback for itemlist
]]--
function me.ItemListOnShow()
  if (UIDropDownMenu_GetSelectedID(getglobal(GM_CONSTANTS.ELEMENT_CHOOSE_CATEGORY)) ~= nil) then
    local currentValue = UIDropDownMenu_GetSelectedValue(getglobal(GM_CONSTANTS.ELEMENT_CHOOSE_CATEGORY))

    mod.quickChangeMenu.QuickChangeFromListOnUpdate(currentValue)
    mod.quickChangeMenu.QuickChangeToListOnUpdate(currentValue)
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
  local registeredCategoryIds = {}

  for _, item in pairs(GM_CONSTANTS.ITEMS) do
    -- prevent adding slots with the same id multiple times
    if registeredCategoryIds[item.id] == nil then
      button = me.CreateDropdownButton(gm.L[item.localizationKey], item.slotId, me.DropDownMenuCallback)
      UIDropDownMenu_AddButton(button)
      registeredCategoryIds[item.id] = true
    end
  end

  if (UIDropDownMenu_GetSelectedID(getglobal(GM_CONSTANTS.ELEMENT_CHOOSE_CATEGORY)) == nil) then
    -- set initial state
    UIDropDownMenu_SetSelectedValue(getglobal(GM_CONSTANTS.ELEMENT_CHOOSE_CATEGORY), GM_CONSTANTS.ITEMS.HEAD.slotId)
  end
end

--[[
  Callback for optionsmenu dropdowns
]]
function me.DropDownMenuCallback()
  local newValue = this.value
  -- UIDROPDOWNMENU_OPEN_MENU is the currently open dropdown menu
  UIDropDownMenu_SetSelectedValue(getglobal(UIDROPDOWNMENU_OPEN_MENU), newValue)

  mod.logger.LogDebug(me.tag, "Changing type to: " .. newValue)

  mod.quickChangeMenu.QuickChangeFromListOnUpdate(newValue)
  mod.quickChangeMenu.QuickChangeToListOnUpdate(newValue)
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
  Filter retrieved itemlist by itemId

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
