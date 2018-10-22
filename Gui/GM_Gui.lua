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
mod.gui = me

me.tag = "Gui"
me.currentSlot = 0
me.currentPosition = 0
me.BaggedItems = {}

function me.ShowMainFrame()
  getglobal(GM_CONSTANTS.ELEMENT_GM_MAIN_FRAME):Show()
end

function me.HideMainFrame()
  getglobal(GM_CONSTANTS.ELEMENT_GM_MAIN_FRAME):Hide()
end

function me.DragButtonOnMouseDown()
  if GearMenuOptions.windowLocked then return end

  getglobal(GM_CONSTANTS.ELEMENT_GM_MAIN_FRAME):StartMoving()
end

function me.DragButtonOnMouseUp()
  if GearMenuOptions.windowLocked then return end

  getglobal(GM_CONSTANTS.ELEMENT_GM_MAIN_FRAME):StopMovingOrSizing()
end

--[[
  Hovering itemslot for worn item
]]--
function me.ItemButtonOnEnter()
  GameTooltip_SetDefaultAnchor(getglobal(GM_CONSTANTS.ELEMENT_GM_TOOLTIP), this)

  local position = mod.common.ExtractPositionFromName(this:GetName())
  local module = mod.itemManager.FindModuleForPosition(position)

  -- abort if no module could be found
  if module == nil then return end

  me.currentSlot = mod[module].id
  me.currentPosition = position
  mod.tooltip.BuildTooltipForWornItem(mod[module].id)
  me.BuildMenu()
end


function me.ItemButtonOnLeave()
  mod.tooltip.TooltipClear()
end

--[[
  Manual click on an itemslot

  @param {string} button
    clicked button RightButton | LeftButton
]]--
function me.ItemButtonOnClick(button)
  local name = this:GetName()
  local module = mod.itemManager.FindModuleForPosition(mod.common.ExtractPositionFromName(name))

  if button == "RightButton" then
    -- rightclick
    local slotID = mod[module].id

    mod.combatQueue.RemoveFromQueue(slotID)
    -- reflect item not in use
    this:SetChecked(0)
  else
    -- leftclick
    if module == nil then return end

    UseInventoryItem(mod[module].id)
    mod.quickChange.CheckItemUse(module)

    -- reflect item use
    this:SetChecked(1)
    mod.timer.StartTimer("ReflectItemUse")
  end
end

--[[
  Allow for drag an drop on itemslots

  With drag and drop it is not possible to figure out any information
  about the item because GetCursorInfo() does not seem to exist. Normal item-
  switches will work but not the edge case where an offhand item should be
  equiped while wearing a twohanded weapon.

  Another reason the switch will not work is because it is not possible to unequip
  the current item without overwriting the cursor.
]]--
function me.ItemButtonOnReceiveDrag()
  -- abort if drag and drop is disabled
  if GearMenuOptions.disableDragAndDrop then return end

  local position = mod.common.ExtractPositionFromName(this:GetName())
  local module = mod.itemManager.FindModuleForPosition(position)

  validItemForSlot = CursorCanGoInSlot(mod[module].id)

  if validItemForSlot == nil then
    mod.logger.LogInfo(me.tag, "Invalid item for slot - " .. mod[module].moduleName)
    ClearCursor() -- clear cursor from item
  else
    EquipCursorItem(mod[module].id)
  end
end

--[[
  Allow drag and drop from one itemslot to another
  (only useful for fast trinketswitch or putting an item in the bag)
]]--
function me.ItemButtonOnDragStart()
  -- abort if drag and drop is disabled
  if GearMenuOptions.disableDragAndDrop then return end

  local position = mod.common.ExtractPositionFromName(this:GetName())
  local module = mod.itemManager.FindModuleForPosition(position)

  PickupInventoryItem(mod[module].id)
end

--[[
  Hovering itemslot for bagged items
]]--
function me.MenuItemOnEnter()
  GameTooltip_SetDefaultAnchor(getglobal(GM_CONSTANTS.ELEMENT_GM_TOOLTIP), this)
  mod.tooltip.BuildTooltipForBaggedItems(this:GetID(), me.BaggedItems)
end

function me.MenuItemOnLeave()
  mod.tooltip.TooltipClear()
end

--[[
  Choosing an item in slotframe
]]--
function me.MenuItemOnClick()
  -- item that should get equiped
  local item = {
    itemID = me.BaggedItems[this:GetID()].id,
    itemSlotType = me.BaggedItems[this:GetID()].equipSlot
  }

  mod.common.EquipItemByID(item, me.currentSlot)
  getglobal(GM_CONSTANTS.ELEMENT_GM_SLOT_FRAME):Hide()
end

--[[
  Callback for keybindings

  @param {number} position
]]
function me.UseInventoryItem(position)
  local module = mod.itemManager.FindModuleForPosition(position)

  if module == nil then
    mod.logger.LogInfo(me.tag, "Unable to use item - module is deactivated")
    return
  end

  -- check if slot has an equiped item
  local _, id, _ = mod.common.RetrieveItemInfo(mod[module].id)

  if not id then
    -- reflect item use
    getglobal(GM_CONSTANTS.ELEMENT_GM_SLOT .. position):SetChecked(1)
    mod.timer.StartTimer("ReflectItemUse")

    return
  end

  mod.logger.LogDebug(me.tag, "Using item: " .. mod[module].id)

  UseInventoryItem(mod[module].id) -- use item
  mod.quickChange.CheckItemUse(module)

  -- reflect item use
  getglobal(GM_CONSTANTS.ELEMENT_GM_SLOT .. position):SetChecked(1)
  mod.timer.StartTimer("ReflectItemUse")
end

--[[
  Remove checked status from all buttons
]]
function me.ReflectItemUse()
  for i = 1, GM_CONSTANTS.ADDON_SLOTS do
    getglobal(GM_CONSTANTS.ELEMENT_GM_SLOT .. i):SetChecked(0)
  end

  mod.timer.StopTimer("ReflectItemUse")
end

--[[
  Build menu for item selection
]]--
function me.BuildMenu()
  -- clear out all item buttons
  for i = 1, 30 do
    getglobal(GM_CONSTANTS.ELEMENT_GM_MENU_ITEM .. i):Hide()
  end

  local idx, i, j, k, texture = 1, numberOfItems, slotName, module
  local itemLink, itemID, itemName, equipSlot, itemTexture, position

  me.BaggedItems = {}
  slotName = this:GetName()

  position = mod.common.ExtractPositionFromName(this:GetName())

  -- if buildmenu is called manualy position is retrieved from cached position
  if position == nil then
    if me.currentPosition == 0 then
      return
    else
      position = me.currentPosition
    end
  end

  module = mod.itemManager.FindModuleForPosition(tonumber(position))

  -- abort if no module could be found
  if module == nil then return end

  mod.logger.LogDebug(me.tag, "building menu for " .. module)
  me.BaggedItems, numberOfItems = mod[module].GetItems()

  if numberOfItems < 1 then
    -- user has no bagged item of this specific type
    getglobal(GM_CONSTANTS.ELEMENT_GM_SLOT_FRAME):Hide()
  else
    local row = 0
    local max_rows = 2 -- width of 2 items
    local col = 0
    local xpos = 8
    local ypos = 8

    for i = 1, numberOfItems do
      local item = getglobal(GM_CONSTANTS.ELEMENT_GM_MENU_ITEM .. i)
      item:SetChecked(0)
      getglobal(GM_CONSTANTS.ELEMENT_GM_MENU_ITEM .. i .. "Icon"):SetTexture(me.BaggedItems[i].texture)

      if math.mod(i, 2) ~= 0 then
        row = 0 -- left row
        if (GearMenuOptions.windowLocked) then
          ypos = col * GM_CONSTANTS.INTERFACE_SLOT_SPACE + GM_CONSTANTS.INTERFACE_ZERO_MARGIN
        else
          ypos = col * GM_CONSTANTS.INTERFACE_SLOT_SPACE + GM_CONSTANTS.INTERFACE_DEFAULT_MARGIN
        end
        xpos = row * GM_CONSTANTS.INTERFACE_SLOT_SPACE + GM_CONSTANTS.INTERFACE_DEFAULT_MARGIN
        -- special case for uneven numberOfItems, add 1 col
        if i == numberOfItems then
          col = col + 1
        end
      else
        row = 1 -- right row
        if (GearMenuOptions.windowLocked) then
          ypos = col * GM_CONSTANTS.INTERFACE_SLOT_SPACE + GM_CONSTANTS.INTERFACE_ZERO_MARGIN
        else
          ypos = col * GM_CONSTANTS.INTERFACE_SLOT_SPACE + GM_CONSTANTS.INTERFACE_DEFAULT_MARGIN
        end
        xpos = row * GM_CONSTANTS.INTERFACE_SLOT_SPACE + GM_CONSTANTS.INTERFACE_DEFAULT_MARGIN
        col = col + 1
      end

      item:SetPoint("BOTTOMLEFT", GM_CONSTANTS.ELEMENT_GM_SLOT_FRAME, xpos, ypos)
      item:Show()
    end

    local frame = getglobal(GM_CONSTANTS.ELEMENT_GM_SLOT_FRAME)
    frame:ClearAllPoints()

    -- bind to point slot that was hovered
    frame:SetPoint("BOTTOMLEFT", GM_CONSTANTS.ELEMENT_GM_SLOT .. position,
      GM_CONSTANTS.INTERFACE_DEFAULT_NEGATIVE_MARGIN, GM_CONSTANTS.INTERFACE_SLOT_SPACE)

    if col == 0 then
      col = 1
    end

    getglobal(GM_CONSTANTS.ELEMENT_GM_SLOT_FRAME):SetWidth(12 + (max_rows * GM_CONSTANTS.INTERFACE_SLOT_SPACE))
    getglobal(GM_CONSTANTS.ELEMENT_GM_SLOT_FRAME):SetHeight(12 + ((col) * GM_CONSTANTS.INTERFACE_SLOT_SPACE))
    getglobal(GM_CONSTANTS.ELEMENT_GM_SLOT_FRAME):Show()

    mod.cooldown.UpdateCooldownForBaggedItems(numberOfItems, me.BaggedItems)
    mod.timer.StartTimer("MenuMouseover")
  end
end

--[[
  Close slot frame after a delay
]]--
function me.SlotFrameMouseOver()
  if (not MouseIsOver(getglobal(GM_CONSTANTS.ELEMENT_GM_MAIN_FRAME))) and (not MouseIsOver(getglobal(GM_CONSTANTS.ELEMENT_GM_SLOT_FRAME))) then
    mod.timer.StopTimer("MenuMouseover")
    getglobal(GM_CONSTANTS.ELEMENT_GM_SLOT_FRAME):Hide()
  end
end

--[[
  Load slotpositions on addon load
]]--
function me.LoadSlotPositions()
  for module, position in pairs(GearMenuOptions.modules) do
    if position == 0 then
      mod[module].SetDisabled(true)
    else
      mod[module].SetDisabled(false)
    end

    mod[module].SetPosition(position)
  end

  for i = 1, GM_CONSTANTS.ADDON_SLOTS do
    local active = mod.itemManager.FindModuleForPosition(i)

    if active == nil then
      mod.logger.LogDebug(me.tag, "Slot" .. i .. " is inactive")
      me.HideSlot(i)
    end
  end

  -- reflect items that are worn
  mod.itemManager.UpdateWornItems()
end

--[[
  Rearrange slotpositions after activating or deactivating a slot
]]--
function me.RearrangeSlotPositions()
  local slots = {} -- table for visible slots

  -- make table of active slotswa
  for i = 1, GM_CONSTANTS.ADDON_SLOTS do
    local slotFrame = getglobal(GM_CONSTANTS.ELEMENT_GM_SLOT .. i)

    if slotFrame:IsShown() then
      slots[i] = GM_CONSTANTS.ELEMENT_GM_SLOT .. i
    end
  end

  local i = 0
  -- position active slots
  for index, value in pairs(slots) do
    local slotFrame = getglobal(GM_CONSTANTS.ELEMENT_GM_SLOT .. index)


    slotFrame:SetPoint("TOPLEFT",
      GM_CONSTANTS.INTERFACE_DEFAULT_MARGIN + (GM_CONSTANTS.INTERFACE_SLOT_SPACE * i),
      GM_CONSTANTS.INTERFACE_DEFAULT_NEGATIVE_MARGIN)

    i = i + 1
  end

  if i == 0 then
    i = 1
  end

  -- set size of mainframe
  getglobal(GM_CONSTANTS.ELEMENT_GM_MAIN_FRAME):SetWidth(GM_CONSTANTS.INTERFACE_DEFAULT_MARGIN
    + (GM_CONSTANTS.INTERFACE_SLOT_SPACE * i) + 4)
end

--[[
  Show slot

  @param {number} position
]]--
function me.ShowSlot(position)
  local frame = getglobal(GM_CONSTANTS.ELEMENT_GM_SLOT .. position)
  frame:Show()

  -- recalculate slot positioning
  me.RearrangeSlotPositions()
end

--[[
  Hide slot

  @param {number} position
]]--
function me.HideSlot(position)
  local frame = getglobal(GM_CONSTANTS.ELEMENT_GM_SLOT .. position)
  frame:Hide()
  -- recalculate slot positioning
  me.RearrangeSlotPositions()
end

--[[
  Show keybindings for all registered items
]]--
function me.ShowKeyBindings()
  for i = 1, GM_CONSTANTS.ADDON_SLOTS do
    if GearMenuOptions.showKeyBindings then
      local binding = getglobal(GM_CONSTANTS.ELEMENT_GM_SLOT .. i .. "HotKey")
      binding:SetText(GetBindingText(GetBindingKey("Slot " .. i), "KEY_", 1))
    end
  end
end

--[[
  Hide keybindings for all registered items
]]--
function me.HideKeyBindings()
  for i = 1, GM_CONSTANTS.ADDON_SLOTS do
    local binding = getglobal(GM_CONSTANTS.ELEMENT_GM_SLOT .. i .. "HotKey")
    binding:SetText("")
  end
end

--[[
  Hide cooldowns for both bagged and worn items
]]--
function me.HideCooldowns()
  -- hide slot cooldowns
  for i = 1, GM_CONSTANTS.ADDON_SLOTS do
    local frame = getglobal(GM_CONSTANTS.ELEMENT_GM_SLOT .. i .. "Time")
    frame:Hide()
  end

  -- hide bagged items cooldown
  for i = 1, 30 do
    local frame = getglobal(GM_CONSTANTS.ELEMENT_GM_MENU_ITEM .. i .. "Time")
    frame:Hide()
  end
end

--[[
  Show cooldowns for both bagged and worn items
]]--
function me.ShowCooldowns()
  -- show slot cooldowns
  for i = 1, GM_CONSTANTS.ADDON_SLOTS do
    local frame = getglobal(GM_CONSTANTS.ELEMENT_GM_SLOT .. i .. "Time")
    frame:Show()
  end

  -- show bagged items cooldown
  for i = 1, 30 do
    local frame = getglobal(GM_CONSTANTS.ELEMENT_GM_MENU_ITEM .. i .. "Time")
    frame:Show()
  end
end
