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

--[[
  Misc Variables
]]--
BINDING_HEADER_GEARMENU = "GearMenu"

GM_CONSTANTS = {
  --[[
    debug logging chatframes
  ]]--
  ADDON_CHATFRAME = "gm_chatframe",
  ADDON_DEBUG_CHATFRAME = "gm_debug_chatframe",
  ADDON_INFO_CHATFRAME = "gm_info_chatframe",
  ADDON_WARN_CHATFRAME = "gm_warn_chatframe",
  ADDON_ERROR_CHATFRAME = "gm_error_chatframe",
  ADDON_EVENT_CHATFRAME = "gm_event_chatframe",


  --[[
    addon config
  ]]--
  ADDON_MAX_ITEMS = 30,
  ADDON_SLOTS = 7,

  --[[
    item categories
  ]]--
  CATEGORY_TRINKET = 1,
  CATEGORY_WAIST = 2,
  CATEGORY_OFFHAND = 3,
  CATEGORY_MAINHAND = 4,
  CATEGORY_HEAD = 5,
  CATEGORY_FEET  = 6,

  CATEGORIES = {
    -- trinket
    [1] = {
      ["type"] = {"INVTYPE_TRINKET"},
      ["name"] = "Trinket",
      ["slotID"] = {13, 14}
    },
    -- waist
    [2] = {
      ["type"] = {"INVTYPE_WAIST"},
      ["name"] = "Waist",
      ["slotID"] = {6}
    },
    -- offHand
    [3] = {
      ["type"] = (function()
        _, class = UnitClass("player")

        if class == "ROGUE" then
          --[[
            e.g. possible itemids
            INVTYPE_HOLDABLE - 4984

            INVTYPE_WEAPONOFFHAND - 19866

            INVTYPE_WEAPON - 19166
          ]]--
          return {"INVTYPE_HOLDABLE", "INVTYPE_WEAPONOFFHAND", "INVTYPE_WEAPON"}
          --[[
            e.g. possible itemids
            INVTYPE_HOLDABLE - 4984
          ]]--
        elseif class == "MAGE" or class == "WARLOCK" or class == "PRIEST" or class == "DRUID" then
          return {"INVTYPE_HOLDABLE"}
          --[[
            e.g. possible itemids
            INVTYPE_HOLDABLE - 4984

            INVTYPE_WEAPONOFFHAND - 19866

            INVTYPE_WEAPON - 19166
          ]]--
        elseif  class == "HUNTER" then
          return {"INVTYPE_WEAPONOFFHAND", "INVTYPE_WEAPON", "INVTYPE_HOLDABLE"}
          --[[
            e.g. possible itemids
            INVTYPE_HOLDABLE - 4984

            INVTYPE_SHIELD - 19862
          ]]--
        elseif class == "PALADIN" or class == "SHAMAN" then
          return {"INVTYPE_HOLDABLE", "INVTYPE_SHIELD"}
          --[[
            e.g. possible itemids
            INVTYPE_HOLDABLE - 4984

            INVTYPE_SHIELD - 19862

            INVTYPE_WEAPON - 19166

            INVTYPE_WEAPONOFFHAND - 19866
          ]]--
        elseif class == "WARRIOR" then
          return {"INVTYPE_HOLDABLE", "INVTYPE_SHIELD", "INVTYPE_WEAPON", "INVTYPE_WEAPONOFFHAND"}
        else
          return {}
        end
      end)(),
      ["name"] = "OffHand",
      ["slotID"] = {17}
    },
    -- mainhand
    [4] = {
      ["type"] = {"INVTYPE_WEAPONMAINHAND", "INVTYPE_2HWEAPON", "INVTYPE_WEAPON"},
      ["name"] = "MainHand",
      ["slotID"] = {16}
    },
    -- head
    [5] = {
      ["type"] = {"INVTYPE_HEAD"},
      ["name"] = "Head",
      ["slotID"] = {1}
    },
    -- feet
    [6] = {
      ["type"] = {"INVTYPE_FEET"},
      ["name"] = "Feet",
      ["slotID"] = {8}
    }
  },

  --[[
    elements
  ]]--
  ELEMENT_CHATFRAME = "ChatFrame",
  ELEMENT_GM_TOOLTIP = "GM_Tooltip",
  ELEMENT_GM_TIMER_FRAME = "GM_TimerFrame",
  ELEMENT_GM_OPTIONS_TITLE = "GM_OptionsTitle",
  ELEMENT_GM_Opt = "GM_Opt",
  ELEMENT_GM_SLOT = "GM_Slot",
  ELEMENT_GM_OPT_SLOT = "GM_OptSlot",
  ELEMENT_GM_OPT_FILTER_ITEM_QUALITY = "GM_OptFilterItemQuality",
  ELEMENT_GM_MENU_ITEM = "GM_MenuItem",
  ELEMENT_GM_SLOT_FRAME = "GM_SlotFrame",
  ELEMENT_GM_MAIN_FRAME = "GM_MainFrame",
  ELEMENT_GM_OPTIONS_FRAME = "GM_OptionsFrame",
  ELEMENT_GM_MOVE_BUTTON = "GM_DragButton",
  ELEMENT_GM_SLOT_TITLE = "GM_TitleSlot",
  ELEMENT_GM_FILTER_ITEM_QUALITY_TITLE = "GM_TitleFilterItemQuality",
  ELEMENT_GM_ABOUT_AUTHOR_LABEL = "GM_AboutAuthor",
  ELEMENT_GM_ABOUT_EMAIL_LABEL = "GM_AboutEmail",
  ELEMENT_GM_ABOUT_VERSION_LABEL = "GM_AboutVersion",
  ELEMENT_GM_ABOUT_ISSUES_LABEL = "GM_AboutIssues",
  ELEMENT_GM_QUICK_CHANGE_DELAY_LABEL = "GM_DelayLabel",
  ELEMENT_GM_QUICK_CHANGE_UNIT_DELAY_LABEL = "GM_DelayUnitLabel",
  --[[
    option navigation
  ]]--
  ELEMENT_GM_NAVIGATION_BUTTON = "GM_Navigation_Button_",
  ELEMENT_GM_CONTENT = "GM_Content",
  --[[
    quick change menu
  ]]--
  ELEMENT_GM_RULE_LIST_LABEL = "GM_RuleListLabel",
  ELEMENT_GM_CHANGE_FROM_LABEL = "GM_ChangeFromLabel",
  ELEMENT_GM_CHANGE_TO_LABEL = "GM_ChangeToLabel",
  ELEMENT_GM_CHOOSE_CATEGORY = "GM_ChooseCategory",
  ELEMENT_GM_QUICK_CHANGE_RULE_CELL = "GM_QuickChangeRuleCell",
  ELEMENT_GM_CHANGE_FROM_CELL = "GM_ChangeFromCell",
  ELEMENT_GM_CHANGE_TO_CELL = "GM_ChangeToCell",
  ELEMENT_GM_QUICK_CHANGE_ADD_RULE = "GM_QuickChangeDelay",

  --[[
    interface
  ]]--
  INTERFACE_COLORS_RED = { r = 1.0, g = 0, b = 0 },
  INTERFACE_ZERO_MARGIN = 0,
  INTERFACE_DEFAULT_MARGIN = 8,
  INTERFACE_DEFAULT_NEGATIVE_MARGIN = -8,
  INTERFACE_SLOT_SPACE = 40,
  INTERFACE_SLOT_WIDTH = 42,
  -- itemmenu
  INTERFACE_ITEM_MENU_DEFAULT_POSITION = 0,
  INTERFACE_ITEM_MENU_MARGIN_BOTTOM = 48,

  ITEMQUALITY = {
    poor = 0,
    common = 1,
    uncommon = 2,
    rare = 3,
    epic = 4,
    legendary = 5
  }
}
