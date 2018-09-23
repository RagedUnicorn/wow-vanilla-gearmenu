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
mod.navigationMenu = me

me.tag = "NavigationMenu"

local navigationEntries = {
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
      getglobal(GM_CONSTANTS.ELEMENT_GM_FILTER_ITEM_QUALITY_TITLE):SetText(gm.L["filteritemquality"])
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
      getglobal(GM_CONSTANTS.ELEMENT_GM_ABOUT_VERSION_LABEL):SetText(gm.L["version"])
    end
  }
}

--[[
  Set first navigation point and content frame active in optionsframe
]]--
function GM_LeftNavigationMenu_OnLoad()
  local frames = { this:GetChildren() }

  -- reset tab buttons and content frame
  for i = 1, table.getn(navigationEntries) do
    navigationEntries[i].active = false

    -- reset navigation highlight
    getglobal(GM_CONSTANTS.ELEMENT_GM_NAVIGATION_BUTTON .. i .. "Texture"):Hide()
    getglobal(GM_CONSTANTS.ELEMENT_GM_NAVIGATION_BUTTON .. i .. "Text"):SetTextColor(0.94, 0.76, 0, 1)
    -- hide content frame
    getglobal(GM_CONSTANTS.ELEMENT_GM_CONTENT .. navigationEntries[i].name):Hide()
  end

  for _, framechild in ipairs(frames) do
    -- set first navigation button active and selected
    getglobal(framechild:GetName() .."Texture"):Show()
    getglobal(framechild:GetName() .."Text"):SetTextColor(1, 1, 1, 1)

    break -- break on first element
  end

  -- set first content window active
  getglobal(GM_CONSTANTS.ELEMENT_GM_CONTENT .. navigationEntries[1].name):Show()
  navigationEntries[1].init()
end

function GM_Navigation_Button_OnClick()
  local name = this:GetName()
  local position = mod.common.ExtractPositionFromName(name)

  if not navigationEntries[position].active then
    for i = 1, table.getn(navigationEntries) do
      if i == position then
        navigationEntries[i].active = true
        -- set navigation button active
        getglobal(name .. "Texture"):Show()
        getglobal(name .. "Text"):SetTextColor(1, 1, 1, 1)
        -- set content frame active
        getglobal(GM_CONSTANTS.ELEMENT_GM_CONTENT .. navigationEntries[i].name):Show()
        navigationEntries[i].init()
      else
        navigationEntries[i].active = false

        -- reset navigation highlight
        getglobal(GM_CONSTANTS.ELEMENT_GM_NAVIGATION_BUTTON .. i .. "Texture"):Hide()
        getglobal(GM_CONSTANTS.ELEMENT_GM_NAVIGATION_BUTTON .. i .. "Text"):SetTextColor(0.94, 0.76, 0, 1)
        -- hide content frame
        getglobal(GM_CONSTANTS.ELEMENT_GM_CONTENT .. navigationEntries[i].name):Hide()
      end
    end
  else
    return -- abort no work left
  end
end

function GM_Navigation_Button_OnLoad()
  local name = this:GetName()
  local position = mod.common.ExtractPositionFromName(name)

  getglobal(name .."Text"):SetText(navigationEntries[position].text)
end
