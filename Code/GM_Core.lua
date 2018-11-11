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

gm = {}
local me = gm

-- localization
gm.L = {}

me.tag = "Core"

--[[
  Addon load
]]--
function me.OnLoad()
  me.logger.InitializeLogging()
  me.RegisterEvents()
  me.cmd.SetupSlashCmdList()
end

--[[
  Register addon events
]]--
function me.RegisterEvents()
  -- register to player login event also fires on /reload
  this:RegisterEvent("PLAYER_LOGIN")
  -- register to inventory changed - fires for each change in the inventory
  this:RegisterEvent("UNIT_INVENTORY_CHANGED")
  -- fires when the cooldown for an action bar item begins or ends
  this:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
  -- fires when the player leaves combat status
  this:RegisterEvent("PLAYER_REGEN_ENABLED")
  -- fires when a player resurrects after being in spirit form
  this:RegisterEvent("PLAYER_UNGHOST")
  -- fires when the player's spirit is released after death or when the player accepts a resurrection without releasing
  this:RegisterEvent("PLAYER_ALIVE")
  -- fired when the keybindings are changed
  this:RegisterEvent("UPDATE_BINDINGS")
end

--[[
  MainFrame OnEvent handler
]]--
function me.OnEvent()
  if event == "PLAYER_LOGIN" then
    me.logger.LogEvent(me.tag, "PLAYER_LOGIN")
    me.Initialize()
  elseif event == "UPDATE_BINDINGS" then
    me.gui.ShowKeyBindings()
  elseif event == "ACTIONBAR_UPDATE_COOLDOWN" then
    me.logger.LogEvent(me.tag, "ACTIONBAR_UPDATE_COOLDOWN")
    me.itemManager.UpdateCooldownForAllWornItems()
  elseif event == "UNIT_INVENTORY_CHANGED" and arg1 == "player" then
    me.logger.LogEvent(me.tag, "UNIT_INVENTORY_CHANGED")
    -- update all registered worn items
    me.itemManager.UpdateWornItems()
    if getglobal(GM_CONSTANTS.ELEMENT_SLOT_FRAME):IsVisible() then
      -- rebuild possible changed menu
      me.gui.BuildMenu()
    end
    -- rebuild bagged items menu
  elseif (event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_UNGHOST"
    or event == "PLAYER_ALIVE") and not me.common.IsPlayerReallyDead() then
      if event == "PLAYER_REGEN_ENABLED" then
        me.logger.LogEvent(me.tag, "PLAYER_REGEN_ENABLED")
      elseif event == "PLAYER_UNGHOST" then
        me.logger.LogEvent(me.tag, "PLAYER_UNGHOST")
      elseif event == "PLAYER_ALIVE" then
        me.logger.LogEvent(me.tag, "PLAYER_ALIVE")
      end
      -- player is alive again or left combat - work through all combat queues
      me.combatQueue.ProcessQueue()
  end
end

--[[
  Init function
]]--
function me.Initialize()
  --setup random seed
  math.randomseed(GetTime())
  me.logger.LogDebug(me.tag, "Initialize addon")

  me.addonOptions.SetupConfiguration()
  -- create and start timers
  me.SetupTimers()
  -- register all items
  me.RegisterItems()
  -- update all registered worn items
  me.itemManager.UpdateWornItems()
  -- show keybindings for all registered items
  me.gui.ShowKeyBindings()
  -- load slot positions from configuration
  me.gui.LoadSlotPositions()
  me.opt.ReflectLockState(GearMenuOptions.windowLocked)

  -- show welcome message
  DEFAULT_CHAT_FRAME:AddMessage(
    string.format(GM_ENVIRONMENT.ADDON_NAME .. gm.L["help"], GM_ENVIRONMENT.ADDON_VERSION))
end

--[[
  Setup timer functions
]]--
function me.SetupTimers()
  me.timer.CreateTimer("MenuMouseover", me.gui.SlotFrameMouseOver, .25, true)
  me.timer.CreateTimer("TooltipUpdate", me.tooltip.TooltipUpdate, 1, true)
  me.timer.CreateTimer("CooldownUpdate", me.cooldown.CooldownUpdate, 1, true)

  me.timer.StartTimer("CooldownUpdate")
end

--[[
  Register items with the itemmanager module
]]--
function me.RegisterItems()
  me.itemManager.RegisterItem(
    GM_CONSTANTS.ITEMS.HEAD.name,
    GM_CONSTANTS.ITEMS.HEAD.localizationKey,
    GM_CONSTANTS.ITEMS.HEAD.slotId,
    1,
    false
  )

  me.itemManager.RegisterItem(
    GM_CONSTANTS.ITEMS.NECK.name,
    GM_CONSTANTS.ITEMS.NECK.localizationKey,
    GM_CONSTANTS.ITEMS.NECK.slotId,
    nil,
    true
  )

  me.itemManager.RegisterItem(
    GM_CONSTANTS.ITEMS.SHOULDER.name,
    GM_CONSTANTS.ITEMS.SHOULDER.localizationKey,
    GM_CONSTANTS.ITEMS.SHOULDER.slotId,
    nil,
    true
  )

  me.itemManager.RegisterItem(
    GM_CONSTANTS.ITEMS.CLOAK.name,
    GM_CONSTANTS.ITEMS.CLOAK.localizationKey,
    GM_CONSTANTS.ITEMS.CLOAK.slotId,
    nil,
    true
  )

  me.itemManager.RegisterItem(
    GM_CONSTANTS.ITEMS.CHEST.name,
    GM_CONSTANTS.ITEMS.CHEST.localizationKey,
    GM_CONSTANTS.ITEMS.CHEST.slotId,
    nil,
    true
  )

  me.itemManager.RegisterItem(
    GM_CONSTANTS.ITEMS.WAIST.name,
    GM_CONSTANTS.ITEMS.WAIST.localizationKey,
    GM_CONSTANTS.ITEMS.WAIST.slotId,
    2,
    false
  )

  me.itemManager.RegisterItem(
    GM_CONSTANTS.ITEMS.LEGS.name,
    GM_CONSTANTS.ITEMS.LEGS.localizationKey,
    GM_CONSTANTS.ITEMS.LEGS.slotId,
    nil,
    true
  )

  me.itemManager.RegisterItem(
    GM_CONSTANTS.ITEMS.FEET.name,
    GM_CONSTANTS.ITEMS.FEET.localizationKey,
    GM_CONSTANTS.ITEMS.FEET.slotId,
    3,
    false
  )

  me.itemManager.RegisterItem(
    GM_CONSTANTS.ITEMS.WRIST.name,
    GM_CONSTANTS.ITEMS.WRIST.localizationKey,
    GM_CONSTANTS.ITEMS.WRIST.slotId,
    nil,
    true
  )

  me.itemManager.RegisterItem(
    GM_CONSTANTS.ITEMS.HANDS.name,
    GM_CONSTANTS.ITEMS.HANDS.localizationKey,
    GM_CONSTANTS.ITEMS.HANDS.slotId,
    nil,
    true
  )

  me.itemManager.RegisterItem(
    GM_CONSTANTS.ITEMS.UPPER_FINGER.name,
    GM_CONSTANTS.ITEMS.UPPER_FINGER.localizationKey,
    GM_CONSTANTS.ITEMS.UPPER_FINGER.slotId,
    nil,
    true
  )

  me.itemManager.RegisterItem(
    GM_CONSTANTS.ITEMS.LOWER_FINGER.name,
    GM_CONSTANTS.ITEMS.LOWER_FINGER.localizationKey,
    GM_CONSTANTS.ITEMS.LOWER_FINGER.slotId,
    nil,
    true
  )

  me.itemManager.RegisterItem(
    GM_CONSTANTS.ITEMS.UPPER_TRINKET.name,
    GM_CONSTANTS.ITEMS.UPPER_TRINKET.localizationKey,
    GM_CONSTANTS.ITEMS.UPPER_TRINKET.slotId,
    4,
    false
  )

  me.itemManager.RegisterItem(
    GM_CONSTANTS.ITEMS.LOWER_TRINKET.name,
    GM_CONSTANTS.ITEMS.LOWER_TRINKET.localizationKey,
    GM_CONSTANTS.ITEMS.LOWER_TRINKET.slotId,
    5,
    false
  )

  me.itemManager.RegisterItem(
    GM_CONSTANTS.ITEMS.MAINHAND.name,
    GM_CONSTANTS.ITEMS.MAINHAND.localizationKey,
    GM_CONSTANTS.ITEMS.MAINHAND.slotId,
    6,
    false
  )

  me.itemManager.RegisterItem(
    GM_CONSTANTS.ITEMS.OFFHAND.name,
    GM_CONSTANTS.ITEMS.OFFHAND.localizationKey,
    GM_CONSTANTS.ITEMS.OFFHAND.slotId,
    7,
    false
  )
end
