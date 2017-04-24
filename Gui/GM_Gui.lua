--[[
  GearMenu - A WoW 1.12.1 Addon to manage quick itemswitching
  Copyright (C) 2016 Michael Wiesendanger <michael.wiesendanger@gmail.com>

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
mod.gui = me

me.tag = "Gui"
me.currentSlot = 0
me.currentPosition = 0
me.BaggedItems = {}

function GM_DragButton_OnMouseUp()
  getglobal(GM_CONSTANTS.ELEMENT_GM_MAIN_FRAME):StopMovingOrSizing()
end

function GM_DragButton_OnMouseDown()
  if GearMenuOptions.windowLocked then return end

  getglobal(GM_CONSTANTS.ELEMENT_GM_MAIN_FRAME):StartMoving()
end

--[[
  hovering itemslot for worn item
]]--
function GM_ItemButton_OnEnter()
  GameTooltip_SetDefaultAnchor(GameTooltip, this)

  local position = mod.common.ExtractPositionFromName(this:GetName())
  local module = mod.itemManager.FindModuleForPosition(position)

  -- abort if no module could be found
  if module == nil then return end

  me.currentSlot = mod[module].id
  me.currentPosition = position
  mod.tooltip.BuildTooltipForWornItem(mod[module].id)
  me.BuildMenu()
end


function GM_ItemButton_OnLeave()
  mod.tooltip.TooltipClear()
end

--[[
  manuall click on an itemslot
  @paran {string} name
    generic name that is not used
  @param {string} button
    clicked button RightButton | LeftButton
]]--
function GM_ItemButton_OnClick(name, button)
  local name, module

  name = this:GetName()
  module = mod.itemManager.FindModuleForPosition(mod.common.ExtractPositionFromName(name))

  if button == "RightButton" then
    -- rightclick
    local slotID = mod[module].id
    local itemID = mod.common.GetItemIDBySlot(slotID)

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
  allow for drag an drop on itemslots

  with drag and drop it is not possible to figure out any information
  about the item because GetCursorInfo() does not seem to exists. Normal item-
  switches will work but not the edge case where an offhand item should be
  equiped while wearing a twohanded weapon.

  another reason the switch will not work is because it is not possible to unequip
  the current item without overwriting the cursor.
]]--
function GM_ItemButton_OnReceiveDrag()
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
  allow drag and drop from one itemslot to another
  (only useful for fast trinketswitch or putting an item in the bag)
]]--
function GM_ItemButton_OnDragStart()
  local position = mod.common.ExtractPositionFromName(this:GetName())
  local module = mod.itemManager.FindModuleForPosition(position)

  PickupInventoryItem(mod[module].id)
end

--[[
  hovering itemslot for bagged items
]]--
function GM_GearMenuItem_OnEnter()
  GameTooltip_SetDefaultAnchor(GameTooltip, this)
  mod.tooltip.BuildTooltipForBaggedItems(this:GetID(), me.BaggedItems)
end

function GM_GearMenuItem_OnLeave()
  mod.tooltip.TooltipClear()
end

--[[
  timersframe onupdate callback
]]--
function GM_TimerFrame_OnUpdate()
  mod.timer.TimersFrame_OnUpdate()
end

--[[
  choosing an item in slotframe
]]--
function GM_GearMenuItem_OnClick()
  -- item that should get equiped
  local item = {
    itemID = me.BaggedItems[this:GetID()].id,
    itemSlotType = me.BaggedItems[this:GetID()].equipSlot
  }

  mod.common.EquipItemByID(item, me.currentSlot)
  getglobal(GM_CONSTANTS.ELEMENT_GM_SLOT_FRAME):Hide()
end

--[[
  callback for keybindings
  @param {number} position
]]
function GM_UseInventoryItem(position)
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

  if slot == mod.mainHand.id then
    getglobal(GM_CONSTANTS.ELEMENT_GM_SLOT .. mod.mainHand.GetPosition()):SetChecked(1)
    mod.timer.StartTimer("UpdateWornMainHand")
  elseif slot == mod.offHand.id then
    getglobal(GM_CONSTANTS.ELEMENT_GM_SLOT .. mod.offHand.GetPosition()):SetChecked(1)
    mod.timer.StartTimer("UpdateWornOffHand")
  elseif slot == mod.feet.id then
    getglobal(GM_CONSTANTS.ELEMENT_GM_SLOT .. mod.feet.GetPosition()):SetChecked(1)
    mod.timer.StartTimer("UpdateWornFeet")
  elseif slot == mod.waist.id then
    getglobal(GM_CONSTANTS.ELEMENT_GM_SLOT .. mod.waist.GetPosition()):SetChecked(1)
    mod.timer.StartTimer("UpdateWornWaist")
  elseif slot == mod.head.id then
    getglobal(GM_CONSTANTS.ELEMENT_GM_SLOT .. mod.head.GetPosition()):SetChecked(1)
    mod.timer.StartTimer("UpdateWornHead")
  end

  -- reflect item use
  getglobal(GM_CONSTANTS.ELEMENT_GM_SLOT .. position):SetChecked(1)
  mod.timer.StartTimer("ReflectItemUse")
end

--[[
  remove checked status from all buttons
]]
function me.ReflectItemUse()
  for i = 1, GM_CONSTANTS.ADDON_SLOTS do
    getglobal(GM_CONSTANTS.ELEMENT_GM_SLOT .. i):SetChecked(0)
  end

  mod.timer.StopTimer("ReflectItemUse")
end

--[[
  build menu for item selection
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
  close slot frame after a delay
]]--
function me.SlotFrameMouseOver()
  if (not MouseIsOver(getglobal(GM_CONSTANTS.ELEMENT_GM_MAIN_FRAME))) and (not MouseIsOver(getglobal(GM_CONSTANTS.ELEMENT_GM_SLOT_FRAME))) then
    mod.timer.StopTimer("MenuMouseover")
    getglobal(GM_CONSTANTS.ELEMENT_GM_SLOT_FRAME):Hide()
  end
end

--[[
  rearrange slotpositions after activating or deactivating a slot
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
  show slot
  @param {number} position
]]--
function me.ShowSlot(position)
  local frame = getglobal(GM_CONSTANTS.ELEMENT_GM_SLOT .. position)
  frame:Show()

  -- recalculate slot positioning
  me.RearrangeSlotPositions()
end

--[[
  hide slot
  @param {number} position
]]--
function me.HideSlot(position)
  local frame = getglobal(GM_CONSTANTS.ELEMENT_GM_SLOT .. position)
  frame:Hide()
  -- recalculate slot positioning
  me.RearrangeSlotPositions()
end

--[[
  show keybindings for all registered items
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
  hide keybindings for all registered items
]]--
function me.HideKeyBindings()
  for i = 1, GM_CONSTANTS.ADDON_SLOTS do
    local binding = getglobal(GM_CONSTANTS.ELEMENT_GM_SLOT .. i .. "HotKey")
    binding:SetText("")
  end
end

--[[
  hide cooldowns for both bagged and worn items
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
  show cooldowns for both bagged and worn items
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
