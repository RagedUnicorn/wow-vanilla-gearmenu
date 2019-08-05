--[[
  MIT License

  Copyright (c) 2019 Michael Wiesendanger

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
-- collection of gathered bagged items
me.baggedItems = {}

--[[
  Show gearmenu mainframe
]]--
function me.ShowMainFrame()
  getglobal(GM_CONSTANTS.ELEMENT_MAIN_FRAME):Show()
end

--[[
  Hide gearmenu mainframe
]]--
function me.HideMainFrame()
  getglobal(GM_CONSTANTS.ELEMENT_MAIN_FRAME):Hide()
end

--[[
  OnMouseDown callback - start dragging gearmenu mainframe
]]--
function me.DragButtonOnMouseDown()
  if mod.addonOptions.IsWindowLocked() then return end

  getglobal(GM_CONSTANTS.ELEMENT_MAIN_FRAME):StartMoving()
end

--[[
  OnMouseUp callback - stop dragging gearmenu mainframe
]]--
function me.DragButtonOnMouseUp()
  if mod.addonOptions.IsWindowLocked() then return end

  getglobal(GM_CONSTANTS.ELEMENT_MAIN_FRAME):StopMovingOrSizing()
end

--[[
  OnEnter callback - hovering itemslot
]]--
function me.ItemButtonOnEnter()
  GameTooltip_SetDefaultAnchor(getglobal(GM_CONSTANTS.ELEMENT_TOOLTIP), this)

  local position = mod.common.ExtractPositionFromName(this:GetName())
  local item = mod.itemManager.FindItemForSlotPosition(position)

  -- abort if no item could be found
  if item == nil then return end

  me.currentSlot = item.slotId
  me.currentPosition = position
  mod.tooltip.BuildTooltipForWornItem(item.slotId)
  me.BuildMenu()
end

--[[
  OnLeave callback - hover leave event on itemslot
]]--
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
  local item = mod.itemManager.FindItemForSlotPosition(mod.common.ExtractPositionFromName(name))

  -- abort if no item could be found
  if item == nil then return end

  if button == "RightButton" then
    -- rightclick
    mod.combatQueue.RemoveFromQueue(item.slotId)
    -- reflect item not in use
    this:SetChecked(0)
  else
    -- leftclick
    UseInventoryItem(item.slotId)
    mod.quickChange.CheckItemUse(item.slotId)
    me.ReflectItemUse(mod.common.ExtractPositionFromName(name))
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
  if mod.addonOptions.IsDragAndDropDisabled() then return end

  local position = mod.common.ExtractPositionFromName(this:GetName())
  local item = mod.itemManager.FindItemForSlotPosition(position)

  -- abort if no item could be found
  if item == nil then return end

  local validItemForSlot = CursorCanGoInSlot(item.slotId)

  if validItemForSlot == nil then
    mod.logger.LogInfo(me.tag, "Invalid item for slotId - " .. item.slotId)
    ClearCursor() -- clear cursor from item
  else
    EquipCursorItem(item.slotId)
  end
end

--[[
  Allow drag and drop from one itemslot to another
  (only useful for fast trinketswitch or putting an item in the bag)
]]--
function me.ItemButtonOnDragStart()
  -- abort if drag and drop is disabled
  if mod.addonOptions.IsDragAndDropDisabled() then return end

  local position = mod.common.ExtractPositionFromName(this:GetName())
  local item = mod.itemManager.FindItemForSlotPosition(position)

  -- abort if no item could be found
  if item == nil then return end

  PickupInventoryItem(item.slotId)
end

--[[
  OnEnter callback - hovering itemslot for bagged items
]]--
function me.MenuItemOnEnter()
  GameTooltip_SetDefaultAnchor(getglobal(GM_CONSTANTS.ELEMENT_TOOLTIP), this)

  mod.tooltip.BuildTooltipForBaggedItem(this:GetID(), me.baggedItems)
end

--[[
  OnLeave callback - hover leave event on itemslot for bagged items
]]--
function me.MenuItemOnLeave()
  mod.tooltip.TooltipClear()
end

--[[
  Choosing an item in slotframe
]]--
function me.MenuItemOnClick()
  mod.itemHelper.EquipItemById(
    me.baggedItems[this:GetID()].id,
    me.currentSlot,
    me.baggedItems[this:GetID()].equipSlot
  )
  getglobal(GM_CONSTANTS.ELEMENT_SLOT_FRAME):Hide()
end

--[[
  Callback for keybindings

  @param {number} position
]]
function me.UseInventoryItem(position)
  local item = mod.itemManager.FindItemForSlotPosition(position)

  -- abort if no item could be found
  if item == nil then
    mod.logger.LogInfo(me.tag, "Unable to use item - item is deactivated")
    return
  end

  -- check if slot has an equiped item
  local _, id, _ = mod.itemHelper.RetrieveItemInfo(item.slotId)

  if not id then
    me.ReflectItemUse(position)
    return
  end

  mod.logger.LogDebug(me.tag, "Using item: " .. item.slotId)

  UseInventoryItem(item.slotId) -- use item
  mod.quickChange.CheckItemUse(item.slotId)
  me.ReflectItemUse(position)
end

--[[
  Reflect the item use on a specific slot by its position

  @param {number} position
]]--
function me.ReflectItemUse(position)
  -- reflect item use
  getglobal(GM_CONSTANTS.ELEMENT_SLOT .. position):SetChecked(1)
  --[[
    Remove checked status from all buttons
  ]]
  local reflectItemUseCallback = function()
    getglobal(GM_CONSTANTS.ELEMENT_SLOT .. position):SetChecked(0)
  end

  local timerName = "ReflectItemUse" .. math.floor(math.random() * 100000000000000)
  mod.timer.CreateTimer(timerName, reflectItemUseCallback, .25, false)
  mod.timer.StartTimer(timerName)
end

--[[
  Build menu for item selection
]]--
function me.BuildMenu()
  -- clear out all item buttons
  for i = 1, 30 do
    getglobal(GM_CONSTANTS.ELEMENT_MENU_ITEM .. i):Hide()
  end

  me.baggedItems = {}

  local position = mod.common.ExtractPositionFromName(this:GetName())

  -- if buildmenu is called manualy position is retrieved from cached position
  if position == nil then
    if me.currentPosition == 0 then
      return
    else
      position = me.currentPosition
    end
  end

  local item = mod.itemManager.FindItemForSlotPosition(tonumber(position))

  -- abort if no item could be found
  if item == nil then return end

  mod.logger.LogDebug(me.tag, "Building menu for slotId: " .. item.slotId)
  me.baggedItems, _ = mod.itemManager.GetItemsForSlotId(item.slotId)

  if table.getn(me.baggedItems) < 1 then
    -- user has no bagged item of this specific type
    getglobal(GM_CONSTANTS.ELEMENT_SLOT_FRAME):Hide()
  else
    local row = 0
    local maxRows = 2 -- width of 2 items
    local col = 0
    local xPos = 8
    local yPos = 8

    for i = 1, table.getn(me.baggedItems) do
      local item = getglobal(GM_CONSTANTS.ELEMENT_MENU_ITEM .. i)
      item:SetChecked(0)
      getglobal(GM_CONSTANTS.ELEMENT_MENU_ITEM .. i .. "Icon"):SetTexture(me.baggedItems[i].texture)

      if math.mod(i, 2) ~= 0 then
        row = 0 -- left row
        if (mod.addonOptions.IsWindowLocked()) then
          yPos = col * GM_CONSTANTS.INTERFACE_SLOT_SPACE + GM_CONSTANTS.INTERFACE_ZERO_MARGIN
        else
          yPos = col * GM_CONSTANTS.INTERFACE_SLOT_SPACE + GM_CONSTANTS.INTERFACE_DEFAULT_MARGIN
        end
        xPos = row * GM_CONSTANTS.INTERFACE_SLOT_SPACE + GM_CONSTANTS.INTERFACE_DEFAULT_MARGIN
        -- special case for uneven numberOfItems, add 1 col
        if i == table.getn(me.baggedItems) then
          col = col + 1
        end
      else
        row = 1 -- right row
        if (mod.addonOptions.IsWindowLocked()) then
          yPos = col * GM_CONSTANTS.INTERFACE_SLOT_SPACE + GM_CONSTANTS.INTERFACE_ZERO_MARGIN
        else
          yPos = col * GM_CONSTANTS.INTERFACE_SLOT_SPACE + GM_CONSTANTS.INTERFACE_DEFAULT_MARGIN
        end
        xPos = row * GM_CONSTANTS.INTERFACE_SLOT_SPACE + GM_CONSTANTS.INTERFACE_DEFAULT_MARGIN
        col = col + 1
      end

      item:SetPoint("BOTTOMLEFT", GM_CONSTANTS.ELEMENT_SLOT_FRAME, xPos, yPos)
      item:Show()
    end

    local frame = getglobal(GM_CONSTANTS.ELEMENT_SLOT_FRAME)
    frame:ClearAllPoints()

    -- bind to point slot that was hovered
    frame:SetPoint("BOTTOMLEFT", GM_CONSTANTS.ELEMENT_SLOT .. position,
      GM_CONSTANTS.INTERFACE_DEFAULT_NEGATIVE_MARGIN, GM_CONSTANTS.INTERFACE_SLOT_SPACE)

    if col == 0 then
      col = 1
    end

    getglobal(GM_CONSTANTS.ELEMENT_SLOT_FRAME):SetWidth(12 + (maxRows * GM_CONSTANTS.INTERFACE_SLOT_SPACE))
    getglobal(GM_CONSTANTS.ELEMENT_SLOT_FRAME):SetHeight(12 + ((col) * GM_CONSTANTS.INTERFACE_SLOT_SPACE))
    getglobal(GM_CONSTANTS.ELEMENT_SLOT_FRAME):Show()

    local callback = function()
      mod.cooldown.UpdateCooldownForBaggedItems(me.baggedItems)
    end

    -- initial manual setting of cooldown timer
    mod.cooldown.UpdateCooldownForBaggedItems(me.baggedItems)

    mod.timer.CreateTimer("BaggedItemCooldownUpdate", callback, .25, true)
    mod.timer.StartTimer("BaggedItemCooldownUpdate")
    mod.timer.StartTimer("MenuMouseover")
  end
end

--[[
  Close slot frame after a delay
]]--
function me.SlotFrameMouseOver()
  if (not MouseIsOver(getglobal(GM_CONSTANTS.ELEMENT_MAIN_FRAME))) and (not MouseIsOver(getglobal(GM_CONSTANTS.ELEMENT_SLOT_FRAME))) then
    mod.timer.StopTimer("BaggedItemCooldownUpdate")
    mod.timer.StopTimer("MenuMouseover")
    getglobal(GM_CONSTANTS.ELEMENT_SLOT_FRAME):Hide()
  end
end

--[[
  Load slotpositions on addon load
]]--
function me.LoadSlotPositions()
  for _, item in pairs(GM_CONSTANTS.ITEMS) do
    if mod.addonOptions.IsItemDisabled(item.name) then
      -- If the item has no position disable it
      mod.itemManager.DisableItem(item.slotId)
    else
      -- Overwrite initial registered position with actual position
      mod.itemManager.EnableItem(item.slotId, mod.addonOptions.GetItemSlotPosition(item.name))
    end
  end

  for i = 1, GM_CONSTANTS.ADDON_SLOTS do
    local item = mod.itemManager.FindItemForSlotPosition(i)

    if item == nil then
      mod.logger.LogDebug(me.tag, "Itemslot" .. i .. " is inactive")
      me.HideSlot(i)
    else
      me.ShowSlot(i)
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

  -- make table of active slots
  for i = 1, GM_CONSTANTS.ADDON_SLOTS do
    local slotFrame = getglobal(GM_CONSTANTS.ELEMENT_SLOT .. i)

    if slotFrame:IsShown() then
      slots[i] = GM_CONSTANTS.ELEMENT_SLOT .. i
    end
  end

  local i = 0
  -- position active slots
  for index, value in pairs(slots) do
    local slotFrame = getglobal(GM_CONSTANTS.ELEMENT_SLOT .. index)

    slotFrame:SetPoint("TOPLEFT",
      GM_CONSTANTS.INTERFACE_DEFAULT_MARGIN + (GM_CONSTANTS.INTERFACE_SLOT_SPACE * i),
      GM_CONSTANTS.INTERFACE_DEFAULT_NEGATIVE_MARGIN)

    i = i + 1
  end

  if i == 0 then
    i = 1
  end

  -- set size of mainframe
  getglobal(GM_CONSTANTS.ELEMENT_MAIN_FRAME):SetWidth(GM_CONSTANTS.INTERFACE_DEFAULT_MARGIN
    + (GM_CONSTANTS.INTERFACE_SLOT_SPACE * i) + 4)
end

--[[
  Show slot

  @param {number} position
]]--
function me.ShowSlot(position)
  local frame = getglobal(GM_CONSTANTS.ELEMENT_SLOT .. position)
  frame:Show()

  -- recalculate slot positioning
  me.RearrangeSlotPositions()
end

--[[
  Hide slot

  @param {number} position
]]--
function me.HideSlot(position)
  local frame = getglobal(GM_CONSTANTS.ELEMENT_SLOT .. position)
  frame:Hide()
  -- recalculate slot positioning
  me.RearrangeSlotPositions()
end

--[[
  Show keybindings for all registered items
]]--
function me.ShowKeyBindings()
  for i = 1, GM_CONSTANTS.ADDON_SLOTS do
    if mod.addonOptions.IsShowKeyBindingsEnabled() then
      local binding = getglobal(GM_CONSTANTS.ELEMENT_SLOT .. i .. "HotKey")
      binding:SetText(GetBindingText(GetBindingKey("Slot " .. i), "KEY_", 1))
    end
  end
end

--[[
  Hide keybindings for all registered items
]]--
function me.HideKeyBindings()
  for i = 1, GM_CONSTANTS.ADDON_SLOTS do
    local binding = getglobal(GM_CONSTANTS.ELEMENT_SLOT .. i .. "HotKey")
    binding:SetText("")
  end
end

--[[
  Hide cooldowns for both bagged and worn items
]]--
function me.HideCooldowns()
  -- hide slot cooldowns
  for i = 1, GM_CONSTANTS.ADDON_SLOTS do
    local frame = getglobal(GM_CONSTANTS.ELEMENT_SLOT .. i .. "Time")
    frame:Hide()
  end

  -- hide bagged items cooldown
  for i = 1, 30 do
    local frame = getglobal(GM_CONSTANTS.ELEMENT_MENU_ITEM .. i .. "Time")
    frame:Hide()
  end
end

--[[
  Show cooldowns for both bagged and worn items
]]--
function me.ShowCooldowns()
  -- show slot cooldowns
  for i = 1, GM_CONSTANTS.ADDON_SLOTS do
    local frame = getglobal(GM_CONSTANTS.ELEMENT_SLOT .. i .. "Time")
    frame:Show()
  end

  -- show bagged items cooldown
  for i = 1, 30 do
    local frame = getglobal(GM_CONSTANTS.ELEMENT_MENU_ITEM .. i .. "Time")
    frame:Show()
  end
end
