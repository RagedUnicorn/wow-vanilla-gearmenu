gm = gm or {}
gm.L = {}

gm.L["name"] = "GearMenu"

-- console
gm.L["help"] = "|cFFFFFF00(%s)|r: Use |cFFFFFF00/gm|r or |cFFFFFF00/gearmenu|r for a list of options"
gm.L["show"] = "|cFFFFFF00show|r - display GearMenu"
gm.L["hide"] = "|cFFFFFF00hide|r - hide GearMenu"
gm.L["opt"] = "|cFFFFFF00opt|r - display Optionsmenu"
gm.L["reload"] = "|cFFFFFF00reload|r - reload UI"
gm.L["info_title"] = "|cFFFFFF00GearMenu:|r"

-- slot translations
gm.L["slot_name_head"] = "Head"
gm.L["slot_name_neck"] = "Neck"
gm.L["slot_name_shoulder"] = "Shoulder"
gm.L["slot_name_chest"] = "Chest"
gm.L["slot_name_waist"] = "Waist"
gm.L["slot_name_legs"] = "Legs"
gm.L["slot_name_feet"] = "Feet"
gm.L["slot_name_wrist"] = "Wrist"
gm.L["slot_name_hands"] = "Hands"
gm.L["slot_name_upper_finger"] = "Upper Finger"
gm.L["slot_name_lower_finger"] = "Lower Finger"
gm.L["slot_name_finger"] = "Finger"
gm.L["slot_name_upper_trinket"] = "Upper Trinket"
gm.L["slot_name_lower_trinket"] = "Lower Trinket"
gm.L["slot_name_trinket"] = "Trinket"
gm.L["slot_name_cloak"] = "Cloak"
gm.L["slot_name_mainhand"] = "MainHand"
gm.L["slot_name_offhand"] = "OffHand"
gm.L["slot_name_ranged"] = "Ranged"

-- user errors
gm.L["unequip_failed"] = "Unable to find empty bagspace"
gm.L["quick_change_item_select_missing"] = "You have to select an item in both from and to list"
gm.L["quick_change_rule_select_missing"] = "You have to select a rule to delete"

-- gui
gm.L["navigation_slots"] = "Slots"
gm.L["navigation_general"] = "General"
gm.L["navigation_quickchange"] = "Quick Change"
gm.L["navigation_about"] = "About"

-- slots tab
gm.L["titleslot1"] = "Slot 1:"
gm.L["titleslot2"] = "Slot 2:"
gm.L["titleslot3"] = "Slot 3:"
gm.L["titleslot4"] = "Slot 4:"
gm.L["titleslot5"] = "Slot 5:"
gm.L["titleslot6"] = "Slot 6:"
gm.L["titleslot7"] = "Slot 7:"
gm.L["titleslot8"] = "Slot 8:"
gm.L["titleslot9"] = "Slot 9:"
gm.L["titleslot10"] = "Slot 10:"
gm.L["slot_menu_slot_already_in_use"] = "Slot is already used"

-- general tab
gm.L["lock_window"] = "Lock Window"
gm.L["lock_window_tooltip"] = "Prevents GearMenu window from being moved."
gm.L["show_cooldowns"] = "Show Cooldowns"
gm.L["show_cooldowns_tooltip"] = "Display a cooldown for all itemslots."
gm.L["show_keybindings"] = "Show Key Bindings"
gm.L["show_keybindings_tooltip"] = "Display the key bindings over the equipped items."
gm.L["show_tooltips"] = "Disable Tooltips"
gm.L["show_tooltips_tooltip"] = "Disable tooltips for hovering over items."
gm.L["small_tooltips"] = "Display small Tooltips"
gm.L["small_tooltips_tooltip"] = "Show only the title of the item that is currently hovered instead of the full tooltip."
gm.L["disable_drag_and_drop"] = "Disable Drag and Drop"
gm.L["disable_drag_and_drop_tooltip"] = "Disable Drag and Drop for items."
gm.L["filter_item_quality"] = "Filter Item Quality:"
gm.L["item_quality_poor"] = "Poor (Grey)"
gm.L["item_quality_common"] = "Common (White)"
gm.L["item_quality_uncommon"] = "Uncommon (Green)"
gm.L["item_quality_rare"] = "Rare (Blue)"
gm.L["item_quality_epic"] = "Epic (Purple)"
gm.L["item_quality_legendary"] = "Legendary (Orange)"

-- quick change tab
gm.L["rule_list_label"] = "Rules:"
gm.L["change_from_label"] = "From:"
gm.L["change_to_label"] = "To:"
gm.L["delay_label"] = "Delay: "
gm.L["delay_unit_label"] = "sec"
gm.L["add_rule"] = "Add Rule"
gm.L["delete_rule"] = "Delete Rule"

-- about tab
gm.L["author"] = "Author: Michael Wiesendanger"
gm.L["email"] = "E-Mail: michael.wiesendanger@gmail.com"
gm.L["version"] = "Version: " .. GM_ENVIRONMENT.ADDON_VERSION
gm.L["issues"] = "Issues: https://github.com/RagedUnicorn/wow-vanilla-gearmenu/issues"
