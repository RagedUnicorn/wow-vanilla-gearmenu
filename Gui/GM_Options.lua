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
mod.opt = me

me.tag = "Options"

function GM_CloseButton_OnClick()
  GM_OptionsFrame:Hide()
end

function me.InitOptionsMenu()
  -- set version title
  getglobal(GM_CONSTANTS.ELEMENT_GM_OPTIONS_TITLE):SetText(GM_CONSTANTS.ADDON_NAME ..
    " " .. GM_CONSTANTS.ADDON_VERSION)
end

--[[
  @param {boolean} locked
]]--
function me.ReflectLockState(locked)
  local mainFrame = getglobal(GM_CONSTANTS.ELEMENT_GM_MAIN_FRAME)
  local slotFrame = getglobal(GM_CONSTANTS.ELEMENT_GM_SLOT_FRAME)

  if locked then
    mainFrame:SetBackdropColor(0, 0, 0, 0)
    mainFrame:SetBackdropBorderColor(0, 0, 0, 0 * 2)
    slotFrame:SetBackdropColor(0, 0, 0, 0)
    slotFrame:SetBackdropBorderColor(0, 0, 0, 0 * 2)
    slotFrame:EnableMouse(0 * 2)

    -- hide move button
    getglobal(GM_CONSTANTS.ELEMENT_GM_MOVE_BUTTON):Hide()
  else
    mainFrame:SetBackdropColor(.5, .5, .5, .5)
    mainFrame:SetBackdropBorderColor(.5, .5, .5, .5 * 2)
    slotFrame:SetBackdropColor(.5, .5, .5, .5)
    slotFrame:SetBackdropBorderColor(.5, .5, .5, .5 * 2)
    slotFrame:EnableMouse(.5 * 2)

    -- show move button
    getglobal(GM_CONSTANTS.ELEMENT_GM_MOVE_BUTTON):Show()
  end
end

--[[
  Scroll callback for quick change options screen
]]--
function QuickChangeScrollFrameVerticalScroll()
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
