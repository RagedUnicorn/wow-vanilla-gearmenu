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
mod.quickChange = me

me.tag = "QuickChange"

--[[
  save new quick change rule
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
  check if an items was successfully used before kicking off Quick Change
  @param {string} module
]]--
function me.CheckItemUse(module)
  -- wait a bit then check if there is a startime for the cooldown on the item
  local checkItemUseStatusCallback = function ()
    local start, duration, enable = GetInventoryItemCooldown("player", mod[module].id);
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
  switch items for a found rule
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
