# GearMenu

![](/Docs/gm_raged_unicorn_logo.png)

## What is GearMenu?

GearMenu is based on the popular TrinketMenu Addon and its goal is to bring this functionality to other slots including trinkets. Its target is to assist the player in PvP but it has definitely some use in PvE as well.

**Supported slots:**

| Slotname          | Description                  |
| ----------------- | ---------------------------- |
| HeadSlot          | Head/Helmet slot             |
| WaistSlot         | Waist/Belt slot              |
| FeetSlot          | Feet/Boots slot              |
| Trinket0Slot      | First/Upper trinket slot     |
| Trinket1Slot      | Second/Lower trinket slot    |
| MainhandSlot      | Main-hand slot               |
| SecondaryHandSlot | Secondary-hand/Off-hand slot |




## Features of GearMenu

### Item switch for certain slots

With GearMenu it is easy to switch between items in supported slots. This is especially useful for engineering items that you wear for a certain amount of time and then switch back to your usual gear.

![](/Docs/gm_switch_items.gif)

### Item switch one-handed to two-handed

Remember the error message you get when you try to switch your one-handed weapon with a two-handed? GearMenu recognizes this and will automatically unequip your offhand weapon or shield as long as there is enough space in your bag to store both weapons. Thus, allowing to switch to a two-handed weapon with a single click.

![](/Docs/gm_switch_mainhand.gif)

### CombatQueue

Certain items cannot be switched while the player is in combat. Weapons will be switched immediately whether the player is in combat or not. Other items that cannot be switched in combat will be enqueued in the CombatQueue and switched as soon as possible. This is especially useful in PvP when you leave combat for a short time.

![](/Docs/gm_combatqueue.gif)

### Quick Change

Quick Change consists of rules that apply when certain items are used. The player can define for items that have a usable effect what should happen after the items has been used. This means that an item is immediately switched after its used. If the user is in combat it will be moved to the combat queue instead.

In the optionsmenu you can define new rules based on the item type

![](/Docs/gm_quick_change_add_rule.gif)

> Note: For items with a buff you will have to manually define a timeframe after which the item should be switched. If an item has a buff effect and you immediately change the item you will also lose its buff.

After adding such a rule you can try it out.

![](/Docs/gm_quick_change_rule_in_action.gif)

> Note: It is also possible to add rules that don't make any sense. If you for example choose an item that has no onuse effect the item will be never switched.

### Keybinding

GearMenu allows to keybind to every slot with a keybinding. Instead of having a keybind for every item that you have to remember you set it directly on the slot itself.

![](/Docs/gm_keybinding.gif)

### Drag and drop support

GearMenu allows to drag and drop items onto slots, remove from slots and slots can even be switched between.

#### Drag and drop between slots
![](/Docs/gm_drag_and_drop_slots.gif)

#### Drag and drop item to GearMenu
![](/Docs/gm_drag_and_drop_onto.gif)

#### Unequip item by drag and drop
![](/Docs/gm_drag_and_drop_unequip.gif)

## Configurability

GearMenu is configurable. Don't need a certain slot? You can hide it.

To show the configuration screen use `/gm opt` while ingame and `/gm info` for an overview of options.

### Hide/Show Cooldowns

![](/Docs/gm_options_cooldown.gif)

### Hide/Show Keybindings

![](/Docs/gm_options_keybindings.gif)

### Lock/Unlock Window

![](/Docs/gm_options_lock_window.gif)

### Filter Items by Quality

Not interested to see items with a quality level below a certain level? Filter them out and only items that meet your set level will be considered to be displayed in GearMenu.

![](/Docs/gm_options_filter_item_quality.gif)

## Installation

WoW-Addons are installed directly in your WoW directory:

`[WoW-installation-directory]\Interface\AddOns`

Make sure to get the newest version of the Addon from the releases tab:

[GearMenu-Releases](https://github.com/RagedUnicorn/wow-gearmenu/releases)

> Note: If the Addon is not showing up in your ingame Addonlist make sure that the Addon is named `GearMenu` in your Addons folder

## License

Copyright (C) 2018 Michael Wiesendanger

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
