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
mod.navigationMenu = me

me.tag = "NavigationMenu"

local mWindows = {
  [1] = {
    ["name"] = "Slots",
    ["text"] = gm.L["navigationslots"],
    ["position"] = 1,
    ["active"] = true,
    ["init"] = function()
      getglobal(GM_CONSTANTS.ELEMENT_GM_SLOT_TITLE .. 1):SetText(gm.L["titleslot1"])
      getglobal(GM_CONSTANTS.ELEMENT_GM_SLOT_TITLE .. 2):SetText(gm.L["titleslot2"])
      getglobal(GM_CONSTANTS.ELEMENT_GM_SLOT_TITLE .. 3):SetText(gm.L["titleslot3"])
      getglobal(GM_CONSTANTS.ELEMENT_GM_SLOT_TITLE .. 4):SetText(gm.L["titleslot4"])
      getglobal(GM_CONSTANTS.ELEMENT_GM_SLOT_TITLE .. 5):SetText(gm.L["titleslot5"])
      getglobal(GM_CONSTANTS.ELEMENT_GM_SLOT_TITLE .. 6):SetText(gm.L["titleslot6"])
      getglobal(GM_CONSTANTS.ELEMENT_GM_SLOT_TITLE .. 7):SetText(gm.L["titleslot7"])
    end
  },
  [2] = {
    ["name"] = "General",
    ["text"] = gm.L["navigationgeneral"],
    ["position"] = 2,
    ["active"] = false,
    ["init"] = function()
      return false
    end
  },
  [3] = {
    ["name"] = "QuickChange",
    ["text"] = gm.L["navigationquickchange"],
    ["position"] = 3,
    ["active"] = false,
    ["init"] = function()
      getglobal(GM_CONSTANTS.ELEMENT_GM_QUICK_CHANGE_DELAY_LABEL):SetText(gm.L["delaylabel"])
      getglobal(GM_CONSTANTS.ELEMENT_GM_QUICK_CHANGE_UNIT_DELAY_LABEL):SetText(gm.L["delayunitlabel"])
      getglobal(GM_CONSTANTS.ELEMENT_GM_RULE_LIST_LABEL):SetText(gm.L["rulelistlabel"])
      getglobal(GM_CONSTANTS.ELEMENT_GM_CHANGE_FROM_LABEL):SetText(gm.L["changefromlabel"])
      getglobal(GM_CONSTANTS.ELEMENT_GM_CHANGE_TO_LABEL):SetText(gm.L["changetolabel"])
    end
  },
  [4] = {
    ["name"] = "About",
    ["text"] = gm.L["navigationabout"],
    ["position"] = 4,
    ["active"] = false,
    ["init"] = function()
      --load texts
      getglobal(GM_CONSTANTS.ELEMENT_GM_ABOUT_AUTHOR_LABEL):SetText(gm.L["author"])
      getglobal(GM_CONSTANTS.ELEMENT_GM_ABOUT_EMAIL_LABEL):SetText(gm.L["email"])
      getglobal(GM_CONSTANTS.ELEMENT_GM_ABOUT_ISSUES_LABEL):SetText(gm.L["issues"])
    end
  }
}

--[[
  Set first navigation point and content frame active in optionsframe
]]--
function GM_LeftNavigationMenu_OnLoad()
  local frames = { this:GetChildren() }

  -- reset tab buttons and content frame
  for i = 1, table.getn(mWindows) do
    mWindows[i].active = false

    -- reset navigation highlight
    getglobal(GM_CONSTANTS.ELEMENT_GM_NAVIGATION_BUTTON .. i .. "Texture"):Hide()
    getglobal(GM_CONSTANTS.ELEMENT_GM_NAVIGATION_BUTTON .. i .. "Text"):SetTextColor(0.94, 0.76, 0, 1)
    -- hide content frame
    getglobal(GM_CONSTANTS.ELEMENT_GM_CONTENT .. mWindows[i].name):Hide()
  end

  for _, framechild in ipairs(frames) do
    -- set first navigation button active and selected
    getglobal(framechild:GetName() .."Texture"):Show()
    getglobal(framechild:GetName() .."Text"):SetTextColor(1, 1, 1, 1)

    break -- break on first element
  end

  -- set first content window active
  getglobal(GM_CONSTANTS.ELEMENT_GM_CONTENT .. mWindows[1].name):Show()
  mWindows[1].init()
end

function GM_Navigation_Button_OnClick()
  local name = this:GetName()
  local position = mod.common.ExtractPositionFromName(name)

  if not mWindows[position].active then
    for i = 1, table.getn(mWindows) do
      if i == position then
        mWindows[i].active = true
        -- set navigation button active
        getglobal(name .. "Texture"):Show()
        getglobal(name .. "Text"):SetTextColor(1, 1, 1, 1)
        -- set content frame active
        getglobal(GM_CONSTANTS.ELEMENT_GM_CONTENT .. mWindows[i].name):Show()
        mWindows[i].init()
      else
        mWindows[i].active = false

        -- reset navigation highlight
        getglobal(GM_CONSTANTS.ELEMENT_GM_NAVIGATION_BUTTON .. i .. "Texture"):Hide()
        getglobal(GM_CONSTANTS.ELEMENT_GM_NAVIGATION_BUTTON .. i .. "Text"):SetTextColor(0.94, 0.76, 0, 1)
        -- hide content frame
        getglobal(GM_CONSTANTS.ELEMENT_GM_CONTENT .. mWindows[i].name):Hide()
      end
    end
  else
    return -- abort nothing todo
  end
end

function GM_Navigation_Button_OnLoad()
  local name = this:GetName()
  local position = mod.common.ExtractPositionFromName(name)

  getglobal(name .."Text"):SetText(mWindows[position].text)
end
