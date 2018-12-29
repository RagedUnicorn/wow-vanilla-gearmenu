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
  ADDON_SLOTS = 10,

  --[[
    item categories
  ]]--
  CATEGORY_TRINKET = 1,
  CATEGORY_WAIST = 2,
  CATEGORY_OFFHAND = 3,
  CATEGORY_MAINHAND = 4,
  CATEGORY_HEAD = 5,
  CATEGORY_FEET  = 6,

  ITEMS = {
    HEAD = {
      ["id"] = 1,
      ["name"] = "head",
      ["localizationKey"] = "slot_name_head",
      ["slotId"] = 1
    },
    NECK = {
      ["id"] = 2,
      ["name"] = "neck",
      ["localizationKey"] = "slot_name_neck",
      ["slotId"] = 2
    },
    SHOULDER = {
      ["id"] = 3,
      ["name"] = "shoulder",
      ["localizationKey"] = "slot_name_shoulder",
      ["slotId"] = 3
    },
    CHEST = {
      ["id"] = 4,
      ["name"] = "chest",
      ["localizationKey"] = "slot_name_chest",
      ["slotId"] = 5
    },
    WAIST = {
      ["id"] = 5,
      ["name"] = "waist",
      ["localizationKey"] = "slot_name_waist",
      ["slotId"] = 6
    },
    LEGS = {
      ["id"] = 6,
      ["name"] = "legs",
      ["localizationKey"] = "slot_name_legs",
      ["slotId"] = 7
    },
    FEET = {
      ["id"] = 7,
      ["name"] = "feet",
      ["localizationKey"] = "slot_name_feet",
      ["slotId"] = 8
    },
    WRIST = {
      ["id"] = 8,
      ["name"] = "wrist",
      ["localizationKey"] = "slot_name_wrist",
      ["slotId"] = 9
    },
    HANDS = {
      ["id"] = 9,
      ["name"] = "hands",
      ["localizationKey"] = "slot_name_hands",
      ["slotId"] = 10
    },
    -- shares id with lower finger because they are the same category but two different slot exists
    UPPER_FINGER = {
      ["id"] = 10,
      ["name"] = "upperFinger",
      ["localizationKey"] = "slot_name_upper_finger",
      ["localizationShort"] = "slot_name_finger",
      ["slotId"] = 11
    },
    -- shares id with upper finger because they are the same category but two different slot exists
    LOWER_FINGER = {
      ["id"] = 10,
      ["name"] = "lowerFinger",
      ["localizationKey"] = "slot_name_lower_finger",
      ["localizationShort"] = "slot_name_finger",
      ["slotId"] = 12
    },
    -- shares id with lower trinket because they are the same category but two different slot exists
    UPPER_TRINKET = {
      ["id"] = 11,
      ["name"] = "upperTrinket",
      ["localizationKey"] = "slot_name_upper_trinket",
      ["localizationShort"] = "slot_name_trinket",
      ["slotId"] = 13
    },
    -- shares id with upper trinket because they are the same category but two different slot exists
    LOWER_TRINKET = {
      ["id"] = 11,
      ["name"] = "lowerTrinket",
      ["localizationKey"] = "slot_name_lower_trinket",
      ["localizationShort"] = "slot_name_trinket",
      ["slotId"] = 14
    },
    CLOAK = {
      ["id"] = 12,
      ["name"] = "cloak",
      ["localizationKey"] = "slot_name_cloak",
      ["slotId"] = 15
    },
    MAINHAND = {
      ["id"] = 13,
      ["name"] = "mainHand",
      ["localizationKey"] = "slot_name_mainhand",
      ["slotId"] = 16
    },
    OFFHAND = {
      ["id"] = 14,
      ["name"] = "offHand",
      ["localizationKey"] = "slot_name_offhand",
      ["slotId"] = 17
    },
    RANGED = {
      ["id"] = 15,
      ["name"] = "ranged",
      ["localizationKey"] = "slot_name_ranged",
      ["slotId"] = 18
    }
  },
  --[[
    {number} slotId as defined by blizzard
      0 = ammo
      1 = head
      2 = neck
      3 = shoulder
      4 = shirt
      5 = chest
      6 = waist
      7 = legs
      8 = feet
      9 = wrist
      10 = hands
      11 = finger 1
      12 = finger 2
      13 = trinket 1
      14 = trinket 2
      15 = back
      16 = main hand
      17 = off hand
      18 = ranged
      19 = tabard
    [slotId] = {
      ["type"] = {"INVTYPE"}
        {table<string>} type of the slot

        | INVTYPE                  | NAME             | slotId |
        |--------------------------|------------------|--------|
        | "INVTYPE_AMMO"           | Ammo             | 0      |
        | "INVTYPE_HEAD"           | Head             | 1      |
        | "INVTYPE_NECK"           | Neck             | 2      |
        | "INVTYPE_SHOULDER"       | Shoulder         | 3      |
        | "INVTYPE_BODY"           | Shirt            | 4      |
        | "INVTYPE_CHEST"          | Chest            | 5      |
        | "INVTYPE_ROBE"           | Chest            | 5      |
        | "INVTYPE_WAIST"          | Waist            | 6      |
        | "INVTYPE_LEGS"           | Legs             | 7      |
        | "INVTYPE_FEET"           | Feet             | 8      |
        | "INVTYPE_WRIST"          | Wrist            | 9      |
        | "INVTYPE_HAND"           | Hands            | 10     |
        | "INVTYPE_FINGER"         | Fingers          | 11,12  |
        | "INVTYPE_TRINKET"        | Trinkets         | 13,14  |
        | "INVTYPE_CLOAK"          | Cloaks           | 15     |
        | "INVTYPE_WEAPON"         | One-Hand         | 16,17  |
        | "INVTYPE_SHIELD"         | Shield           | 17     |
        | "INVTYPE_2HWEAPON"       | Two-Handed       | 16     |
        | "INVTYPE_WEAPONMAINHAND" | Main-Hand Weapon | 16     |
        | "INVTYPE_WEAPONOFFHAND"  | Off-Hand Weapon  | 17     |
        | "INVTYPE_RANGED"         | Ranged Weapon    | 18     |
      ["name"] = "item name"
        {string} Short name of the slot
      ["slotName"] = "nameSlot"
        {string} Name of the slot as found in the official documentation
      ["slotId"] = {1}
        {table<number>} A table of possible slotIds
    }
  ]]--
  ITEM_CATEGORIES = {
    [1] = {
      ["type"] = {"INVTYPE_HEAD"},
      ["name"] = "Head",
      ["slotName"] = "HeadSlot",
      ["slotId"] = {1}
    },
    [2] = {
      ["type"] = {"INVTYPE_NECK"},
      ["name"] = "Neck",
      ["slotName"] = "NeckSlot",
      ["slotId"] = {2}
    },
    [3] = {
      ["type"] = {"INVTYPE_SHOULDER"},
      ["name"] = "Shoulder",
      ["slotName"] = "ShoulderSlot",
      ["slotId"] = {3}
    },
    [5] = {
      ["type"] = {"INVTYPE_CHEST", "INVTYPE_ROBE"},
      ["name"] = "Chest",
      ["slotName"] = "ChestSlot",
      ["slotId"] = {5}
    },
    [6] = {
      ["type"] = {"INVTYPE_WAIST"},
      ["name"] = "Waist",
      ["slotName"] = "WaistSlot",
      ["slotId"] = {6}
    },
    [7] = {
      ["type"] = {"INVTYPE_LEGS"},
      ["name"] = "Legs",
      ["slotName"] = "LegsSlot",
      ["slotId"] = {7}
    },
    [8] = {
      ["type"] = {"INVTYPE_FEET"},
      ["name"] = "Feet",
      ["slotName"] = "FeetSlot",
      ["slotId"] = {8}
    },
    [9] = {
      ["type"] = {"INVTYPE_WRIST"},
      ["name"] = "Wrist",
      ["slotName"] = "WristSlot",
      ["slotId"] = {9}
    },
    [10] = {
      ["type"] = {"INVTYPE_HAND"},
      ["name"] = "Hands",
      ["slotName"] = "HandsSlot",
      ["slotId"] = {10}
    },
    [11] = {
      ["type"] = {"INVTYPE_FINGER"},
      ["name"] = "UpperFinger",
      ["slotName"] = "Finger0Slot",
      ["slotId"] = {11, 12}
    },
    [12] = {
      ["type"] = {"INVTYPE_FINGER"},
      ["name"] = "LowerFinger",
      ["slotName"] = "Finger1Slot",
      ["slotId"] = {11, 12}
    },
    -- trinket
    [13] = {
      ["type"] = {"INVTYPE_TRINKET"},
      ["name"] = "UpperTrinket",
      ["slotName"] = "Trinket0Slot",
      ["slotId"] = {13, 14}
    },
    -- trinket
    [14] = {
      ["type"] = {"INVTYPE_TRINKET"},
      ["name"] = "LowerTrinket",
      ["slotName"] = "Trinket1Slot",
      ["slotId"] = {13, 14}
    },
    [15] = {
      ["type"] = {"INVTYPE_CLOAK"},
      ["name"] = "Back",
      ["slotName"] = "BackSlot",
      ["slotId"] = {15}
    },
    [16] = {
      ["type"] = {"INVTYPE_WEAPONMAINHAND", "INVTYPE_2HWEAPON", "INVTYPE_WEAPON"},
      ["name"] = "MainHand",
      ["slotName"] = "MainhandSlot",
      ["slotId"] = {16}
    },
    [17] = {
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
      ["slotName"] = "SecondaryHandSlot",
      ["slotId"] = {17}
    },
    [18] = {
      ["type"] = {"INVTYPE_RANGED"},
      ["name"] = "Ranged",
      ["slotName"] = "RangedSlot",
      ["slotId"] = {18}
    }
  },
  --[[
    elements
  ]]--
  ELEMENT_CHATFRAME = "ChatFrame",
  ELEMENT_TOOLTIP = "GameTooltip", -- default blizzard frames tooltip
  ELEMENT_TIMER_FRAME = "GM_TimerFrame",
  ELEMENT_OPTIONS_TITLE = "GM_OptionsTitle",
  ELEMENT_OPT = "GM_Opt",
  ELEMENT_SLOT = "GM_Slot",
  ELEMENT_OPT_SLOT = "GM_OptSlot",
  ELEMENT_OPT_FILTER_ITEM_QUALITY = "GM_OptFilterItemQuality",
  ELEMENT_MENU_ITEM = "GM_MenuItem",
  ELEMENT_SLOT_FRAME = "GM_SlotFrame",
  ELEMENT_MAIN_FRAME = "GM_MainFrame",
  ELEMENT_OPTIONS_FRAME = "GM_OptionsFrame",
  ELEMENT_DRAG_BUTTON = "GM_DragButton",
  ELEMENT_SLOT_TITLE = "GM_TitleSlot",
  ELEMENT_FILTER_ITEM_QUALITY_TITLE = "GM_TitleFilterItemQuality",
  ELEMENT_ABOUT_AUTHOR_LABEL = "GM_AboutAuthor",
  ELEMENT_ABOUT_EMAIL_LABEL = "GM_AboutEmail",
  ELEMENT_ABOUT_VERSION_LABEL = "GM_AboutVersion",
  ELEMENT_ABOUT_ISSUES_LABEL = "GM_AboutIssues",
  --[[
    option navigation
  ]]--
  ELEMENT_NAVIGATION_BUTTON = "GM_Navigation_Button_",
  ELEMENT_CONTENT = "GM_Content",
  --[[
    quick change menu
  ]]--
  ELEMENT_RULE_LIST_LABEL = "GM_RuleListLabel",
  ELEMENT_CHANGE_FROM_LABEL = "GM_ChangeFromLabel",
  ELEMENT_CHANGE_TO_LABEL = "GM_ChangeToLabel",
  ELEMENT_CHOOSE_CATEGORY = "GM_ChooseCategory",
  ELEMENT_QUICK_CHANGE_RULE_CELL = "GM_QuickChangeRuleCell",
  ELEMENT_CHANGE_FROM_CELL = "GM_ChangeFromCell",
  ELEMENT_CHANGE_TO_CELL = "GM_ChangeToCell",
  ELEMENT_QUICK_CHANGE_ADD_RULE = "GM_QuickChangeDelay",
  ELEMENT_QUICK_CHANGE_DELAY_LABEL = "GM_DelayLabel",
  ELEMENT_QUICK_CHANGE_UNIT_DELAY_LABEL = "GM_DelayUnitLabel",
  ELEMENT_QUICK_CHANGE_RULE_SCROLL_FRAME = "GM_QuickChangeRuleScrollFrame",
  ELEMENT_QUICK_CHANGE_FROM_SCROLL_FRAME = "GM_QuickChange_ChangeFromScrollFrame",
  ELEMENT_QUICK_CHANGE_TO_SCROLL_FRAME = "GM_QuickChange_ChangeToScrollFrame",
  QUICKCHANGE_VISIBLE_RULES = 5,
  QUICKCHANGE_VISIBLE_ITEMS = 9,
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
