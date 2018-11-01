--[[
  MIT License

  Copyright (c) 2018 Michael Wiesendanger

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.
]]--

local mod = gm
local me = {}
mod.addonOptions = me

me.tag = "AddonOptions"

--[[
  Saved addon variable
]]--
GearMenuOptions = {
  --[[
    Whether to lock gearmenu window preventing from moving the window
  ]]--
  ["windowLocked"] = true,
  --[[
    Whether to show keybindings on the itemslots
  ]]--
  ["showKeyBindings"] = true,
  --[[
    Whether to show cooldowns on the itemslots
  ]]--
  ["showCooldowns"] = true,
  --[[
    Whether to disable tooltips
  ]]--
  ["disableTooltips"] = false,
  --[[
    Whether to use small tooltips. Small tooltips will only display the name of the item
    nothing more
  ]]--
  ["smallTooltips"] = false,
  --[[
    Whether to disable drag and drop between and onto GearMenu itemslots
  ]]--
  ["disableDragAndDrop"] = false,
  --[[
    Itemquality to filter items by their quality. Everything that is below the settings value
    will not be considered a valid item to display when building the itemcontextmenu.
    By default all items are allowed

    0 Poor (gray)
    1 Common (white)
    2 Uncommon (green)
    3 Rare (blue)
    4 Epic (purple)
    5 Legendary (orange)
  ]]--
  ["filterItemQuality"] = 0,
  ["modules"] = {
    ["mainHand"] = 1,
    ["offHand"] = 2,
    ["waist"] = 3,
    ["feet"] = 4,
    ["head"] = 5,
    ["upperTrinket"] = 6,
    ["lowerTrinket"] = 7
  },
  --[[
    example
    {
      ["slotId"] = {13, 14},
      ["changeFromName"] = "Earthstrike",
      ["changeFromId"] = 21180,
      ["changeToName"] = "Drake Fang Talisman",
      ["changeToId"]  = 19406,
      ["changeDelay"] = 20 -- delay in seconds
    }
  ]]--
  ["QuickChangeRules"] = {}
}


--[[
  Set default values if property is nil. This might happen after an addon upgrade
]]--
function me.SetupConfiguration()
  if GearMenuOptions.windowLocked == nil then
    mod.logger.LogInfo(me.tag, "windowLocked has unexpected nil value")
    GearMenuOptions.windowLocked = true
  end

  if GearMenuOptions.showKeyBindings == nil then
    mod.logger.LogInfo(me.tag, "showKeyBindings has unexpected nil value")
    GearMenuOptions.showKeyBindings = true
  end

  if GearMenuOptions.showCooldowns == nil then
    mod.logger.LogInfo(me.tag, "showCooldowns has unexpected nil value")
    GearMenuOptions.showCooldowns = true
  end

  if GearMenuOptions.disableTooltips == nil then
    mod.logger.LogInfo(me.tag, "disableTooltips has unexpected nil value")
    GearMenuOptions.disableTooltips = false
  end

  if GearMenuOptions.smallTooltips == nil then
    mod.logger.LogInfo(me.tag, "smallTooltips has unexpected nil value")
    GearMenuOptions.smallTooltips = false
  end

  if GearMenuOptions.disableDragAndDrop == nil then
    mod.logger.LogInfo(me.tag, "disableDragAndDrop has unexpected nil value")
    GearMenuOptions.disableDragAndDrop = false
  end

  if GearMenuOptions.filterItemQuality == nil then
    mod.logger.LogInfo(me.tag, "filterItemQuality has unexpected nil value")
    GearMenuOptions.filterItemQuality = 0
  end

  if GearMenuOptions.modules == nil then
    mod.logger.LogInfo(me.tag, "modules has unexpected nil value")
    GearMenuOptions.modules = {
      ["mainHand"] = 1,
      ["offHand"] = 2,
      ["waist"] = 3,
      ["feet"] = 4,
      ["head"] = 5,
      ["upperTrinket"] = 6,
      ["lowerTrinket"] = 7
    }
  end

  if GearMenuOptions.QuickChangeRules == nil then
    mod.logger.LogInfo(me.tag, "QuickChangeRules has unexpected nil value")
    GearMenuOptions.QuickChangeRules = {}
  end

  --[[
    Set saved variables with addon version. This can be used later to determine whether
    a migration path applies to the current saved variables or not
  ]]--
  me.SetAddonVersion()
end

--[[
  Set addon version on addon options. Before setting a new version make sure
  to run through migration paths. As of right now there is no migration path.
]]--
function me.SetAddonVersion()
  -- if no version set so far make sure to set the current one
  if GearMenuOptions.addonVersion == nil then
    GearMenuOptions.addonVersion = GM_ENVIRONMENT.ADDON_VERSION
  end

  me.MigrationPath()
  GearMenuOptions.addonVersion = GM_ENVIRONMENT.ADDON_VERSION
end


--[[
  Migration path for older version to newest version. For now this migration path
  is running each time the addon starts. Later versions should consider the save addon
  version before running a migration path
]]--
function me.MigrationPath()
  --[[
    Migration path for pre 1.0.4 versions - Update quick change rules to new format
  ]]--
  for i = 1, table.getn(GearMenuOptions.QuickChangeRules) do
    local rule = GearMenuOptions.QuickChangeRules[i]

    if rule.slotID then
      rule.slotId = rule.slotID
      rule.slotID = nil
    end

    if rule.changeFromID then
      rule.changeFromId = rule.changeFromID
      rule.changeFromID = nil
    end

    if rule.changeToID then
      rule.changeToId = rule.changeToID
      rule.changeToID = nil
    end
  end

  GearMenuOptions.addonVersion = GM_ENVIRONMENT.ADDON_VERSION
end

--[[
  Enable moving of GearMenu window
]]--
function me.DisableWindowLocked()
  GearMenuOptions.windowLocked = false
  mod.opt.ReflectLockState(false)
end

--[[
  Disable moving of GearMenu window
]]--
function me.EnableWindowLocked()
  GearMenuOptions.windowLocked = true
  mod.opt.ReflectLockState(true)
end

--[[
  @return {boolean}
    true - if the window is locked and cannot be moved
    false - if the window is not locked and can be moved
]]--
function me.IsWindowLocked()
  return GearMenuOptions.windowLocked
end

--[[
  Disable showing of cooldowns on GearMenu itemslots
]]--
function me.DisableShowCooldowns()
  GearMenuOptions.showCooldowns = false
  mod.gui.HideCooldowns()
end

--[[
  Enable showing of cooldowns on GearMenu itemslots
]]--
function me.EnableShowCooldowns()
  GearMenuOptions.showCooldowns = true
  mod.gui.ShowCooldowns()
end

--[[
  @return {boolean}
    true - if showing of cooldowns is enabled
    false - if showing of cooldowns is disabled
]]--
function me.IsShowCooldownsEnabled()
  return GearMenuOptions.showCooldowns
end

--[[
  Disable showing of keybindings on GearMenu itemslots
]]--
function me.DisableShowKeyBindings()
  GearMenuOptions.showKeyBindings = false
  mod.gui.HideKeyBindings()
end

--[[
  Enable showing of keybindings on GearMenu itemslots
]]--
function me.EnableShowKeyBindings()
  GearMenuOptions.showKeyBindings = true
  mod.gui.ShowKeyBindings()
end

--[[
  @return {boolean}
    true - if showing of keybindings is enabled
    false - if showing of keybindings is disabled
]]--
function me.IsShowKeyBindingsEnabled()
  return GearMenuOptions.showKeyBindings
end

--[[
  Disable showing of tooltips
]]--
function me.DisableTooltips()
  GearMenuOptions.disableTooltips = true
end

--[[
  Enable showing of tooltips
]]--
function me.EnableTooltips()
  GearMenuOptions.disableTooltips = false
end

--[[
  @return {boolean}
    true - if showing of tooltips is disabled
    false - if showing of tooltips is enabled
]]--
function me.IsTooltipsDisabled()
  return GearMenuOptions.disableTooltips
end

--[[
  Disable small tooltips
]]--
function me.DisableSmallTooltips()
  GearMenuOptions.smallTooltips = false
end

--[[
  Enable small tooltips
]]--
function me.EnableSmallTooltips()
  GearMenuOptions.smallTooltips = true
end

--[[
  @return {boolean}
    true - if small tooltips are enabled
    false - if small tooltips are disabled
]]--
function me.IsSmallTooltipsEnabled()
  return GearMenuOptions.smallTooltips
end

--[[
  Disable drag and drop on GearMenu itemslots
]]--
function me.DisableDragAndDrop()
  GearMenuOptions.disableDragAndDrop = true
end

--[[
  Enable drag and drop on GearMenu itemslots
]]--
function me.EnableDragAndDrop()
  GearMenuOptions.disableDragAndDrop = false
end

--[[
  @return {boolean}
    true - if drag and drop on GearMenu itemslots is disabled
    false - if drag and drop on GearMenu itemslots is enabled
]]--
function me.IsDragAndDropDisabled()
  return GearMenuOptions.disableDragAndDrop
end

--[[
  Save itemquality to filter for when building the GearMenu menu on hover

  @param {number} itemQuality
]]--
function me.SetFilterItemQuality(itemQuality)
  assert(type(itemQuality) == "number",
    string.format("bad argument #1 to `SetFilterItemQuality` (expected number got %s)", type(itemQuality)))

  GearMenuOptions.filterItemQuality = itemQuality
end

--[[
  Get the itemquality to filter for when building the GearMenu menu on hover

  @return {number}
]]--
function me.GetFilterItemQuality()
  return GearMenuOptions.filterItemQuality
end
