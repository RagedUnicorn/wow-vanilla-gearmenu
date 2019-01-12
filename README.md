# GearMenu

![](/Docs/gm_raged_unicorn_logo.png)

## Installation

WoW-Addons are installed directly in your WoW directory:

`[WoW-installation-directory]\Interface\AddOns`

Make sure to get the newest version of the Addon from the releases tab:

[GearMenu-Releases](https://github.com/RagedUnicorn/wow-vanilla-gearmenu/releases)

> Note: If the Addon is not showing up in your ingame Addonlist make sure that the Addon is named `GearMenu` in your Addons folder

## What is GearMenu?

GearMenu is based on the popular TrinketMenu Addon and its goal is to bring this functionality to other slots including trinkets. Its target is to assist the player in PvP but it has definitely some use in PvE as well.

**Supported slots:**

| Slotname          | Description                  |
|-------------------|------------------------------|
| HeadSlot          | Head/Helmet slot             |
| NeckSlot          | Neck slot                    |
| ShoulderSlot      | Shoulder slot                |
| ChestSlot         | Chest/Robe slot              |
| WaistSlot         | Waist/Belt slot              |
| LegsSlot          | Legs slot                    |
| FeetSlot          | Feet/Boots slot              |
| WristSlot         | Wrist/Bracers slot           |
| HandsSlot         | Hands slot                   |
| Finger0Slot       | First/Upper ring slot        |
| Finger1Slot       | Second/Upper ring slot       |
| Trinket0Slot      | First/Upper trinket slot     |
| Trinket1Slot      | Second/Lower trinket slot    |
| BackSlot          | Back/Cloak slot slot         |
| MainhandSlot      | Main-hand slot               |
| SecondaryHandSlot | Secondary-hand/Off-hand slot |
| RangedSlot        | Ranged slot                  |

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

## FAQ

#### The Addon is not showing up in WoW. What can I do?

Make sure to recheck the installation part of this Readme and check that the Addon is placed inside `[WoW-installation-directory]\Interface\AddOns` and is correctly named as `GearMenu`.

#### I get a red error (Lua Error) on my screen. What is this?

This is what we call a Lua error and it usually happens because of an oversight or error by the developer (in this case me). Take a screenshot off the error and create a Github Issue with it and I will see if I can resolve it. It also helps if you can add any additional information of what you we're doing at the time and what other addons you have active. Also if you are able to reproduce the error make sure to check if it still happens if you disable all others addons.

#### I can't seem to have different settings for my characters. What can I do?

Because of a bug versions before `1.2.0` saved the Addon options not only for the current character but also globally for the Addon. This was not intended and is fixed in the newest version. After updating to version `1.2.0` or newer make sure to delete the following files:

```
 WTF\Account\ACCOUNTNAME\SavedVariables\GearMenu.lua
 WTF\Account\ACCOUNTNAME\SavedVariables\GearMenu.lua.bak
```

#### After updating to a newer version of the Addon I run into Lua errors. What can I do?

When updating from an old version to a newer Addon options usually need to be migrated to the new version. While I intend to do this upgrading automatically there is a possibility that the upgrading didn't work as expected. In this case it usually is the easiest to delete locally stored configuration of GearMenu and start over. This means that your configuration is deleted and that you need to redo setting the options.

Delete the following files for all characters.

```
WTF\Account\ACCOUNTNAME\RealmName\CharacterName\SavedVariables\GearMenu.lua
WTF\Account\ACCOUNTNAME\RealmName\CharacterName\SavedVariables\GearMenu.lua.bak
```

**Note:** If those files do not exist skip the character. This means that you didn't login with that character while the Addon was active.

## Development

### Switching between Environments

Switching between development and release can be achieved with maven.

```
mvn generate-resources -Dgenerate.sources.overwrite=true -P development
```

This generates and overwrites `GM_Environment.lua` and `GearMenu.toc`. You need to specifically specify that you want to overwrite to files to prevent data loss. It is also possible to omit the profile because development is the default profile that will be used.

Switching to release can be done as such:

```
mvn generate-resources -Dgenerate.sources.overwrite=true -P release
```

In this case it is mandatory to add the release profile.

**Note:** Switching environments has the effect changing certain files to match an expected value depending on the environment. To be more specific this means that as an example test and debug files are not included when switching to release. It also means that variables such as loglevel change to match the environment.

As to not change those files all the time the repository should always stay in the development environment. Do not commit `GearMenu.toc` and `GM_Environment.lua` in their release state. Changes to those files should always be done inside `build-resources` and their respective template files marked with `.tpl`.

### Packaging the Addon

To package the addon use the `package` phase.

```
mvn package -Dgenerate.sources.overwrite=true -P development
```

This generates an addon package for development. For generating a release package the release profile can be used.

```
mvn package -Dgenerate.sources.overwrite=true -P release
```

**Note:** This packaging and switching resources can also be done one after another.

```
# switch environment to release
mvn generate-resources -Dgenerate.sources.overwrite=true -P release
# package release
mvn package -P release
```

### Deploy a Release

Before creating a new release update `addon.tag.version` in `pom.xml`. Afterwards to create a new release and deploy to GitHub the `deploy` profile has to be used.

```
# switch environment to release
mvn generate-resources -Dgenerate.sources.overwrite=true -P release
# deploy release to GitHub
mvn package -P deploy
```

For this to work an oauth token for GitHub is required and has to be configured in your `.m2` settings file.

## License

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
