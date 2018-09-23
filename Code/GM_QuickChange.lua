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
mod.quickChange = me

me.tag = "QuickChange"

--[[
  Save new quick change rule

  @param (number) changeFromID
    item to switch from
  @param (number) changeToID
    item to switch to
  @param {number} delay
    time to wait before changing an item
  @return (nil)
]]--
function me.AddQuickChangeRule(changeFromID, changeToID, delay)
  local quickChangeRule = {}
  local slotID

  changeFromName, _, itemFromQuality, _, _, _, _, equipFromSlot, itemFromTexture = GetItemInfo(changeFromID)
  changeToName, _, itemToQuality, _, _, _, _, equipToSlot, itemToTexture = GetItemInfo(changeToID)

  for i = 1, table.getn(GM_CONSTANTS.CATEGORIES) do
    for it = 1, table.getn(GM_CONSTANTS.CATEGORIES[i].type) do
      if equipFromSlot == GM_CONSTANTS.CATEGORIES[i].type[it] then
        slotID = GM_CONSTANTS.CATEGORIES[i].slotID
      end
    end
  end

  quickChangeRule.slotID = slotID
  quickChangeRule.changeFromName = changeFromName
  quickChangeRule.changeFromID = tonumber(changeFromID)
  quickChangeRule.changeToName = changeToName
  quickChangeRule.changeToID = tonumber(changeToID)
  quickChangeRule.changeDelay = delay

  table.insert(GearMenuOptions.QuickChangeRules, quickChangeRule)
  -- update rule list
  GM_QuickChangeRulesListUpdate()
end

--[[
  @param {number} position
]]--
function me.RemoveQuickChangeRule(position)
  table.remove(GearMenuOptions.QuickChangeRules, position)
  -- update rule list
  GM_QuickChangeRulesListUpdate()
end

--[[
  @param {number} slotID
]]--
function me.UpdateQuickChange(slotID)
  for i = 1, table.getn(GearMenuOptions.QuickChangeRules) do
    for it = 1, table.getn(GearMenuOptions.QuickChangeRules[i].slotID) do
      if slotID == GearMenuOptions.QuickChangeRules[i].slotID[it] then
        local itemID = mod.common.GetItemIDBySlot(slotID)

        if tonumber(itemID) == GearMenuOptions.QuickChangeRules[i].changeFromID then
          -- found a quick change rule that matches - prepare for switching
          me.SwitchItems(GearMenuOptions.QuickChangeRules[i], slotID)
        end
      end
    end
  end
end

--[[
  Check if an items was successfully used before kicking off Quick Change

  @param {string} module
]]--
function me.CheckItemUse(module)
  -- wait a bit then check if there is a startime for the cooldown on the item
  local checkItemUseStatusCallback = function ()
    local start, duration, enable = GetInventoryItemCooldown("player", mod[module].id)
    -- 1 meaning item has an onUse effect
    if enable == 1 and start ~= 0 then
      -- inform quick change about used item
      mod.quickChange.UpdateQuickChange(mod[module].id)
    elseif enable == 0 then
      mod.quickChange.UpdateQuickChange(mod[module].id)
    end

    mod.timer.StopTimer("checkItemUseStatus")
  end

  mod.timer.CreateTimer("checkItemUseStatus", checkItemUseStatusCallback, 0.25, 0.25)
  mod.timer.StartTimer("checkItemUseStatus")
end

--[[
  Switch items for a found rule

  @param {table} rule
  @param {number} slotID
]]--
function me.SwitchItems(rule, slotID)
  local timerName = "QuickChange_" .. math.floor(math.random() * 100000000000000)

  local quickChangeSwitchCallback = function()
    mod.timer.StopTimer(timerName)
    mod.logger.LogDebug(me.tag, "ChangeToName: " .. rule.changeToName .. " slotID: " .. slotID)
    mod.combatQueue.AddToQueue(rule.changeToID, slotID)
    -- kick off combat queue
    mod.combatQueue.ProcessQueue()
  end

  if rule.changeDelay ~= 0 then
    mod.timer.CreateTimer(timerName, quickChangeSwitchCallback, rule.changeDelay, 0.25)
    mod.timer.StartTimer(timerName)
  else
    mod.timer.CreateTimer(timerName, quickChangeSwitchCallback, 0.25, 0.25)
    -- start a timer before switching the item. An immediate change is blocked by the ui
    mod.timer.StartTimer(timerName) -- default delay
  end
end
