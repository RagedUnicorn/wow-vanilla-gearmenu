--[[
  GearMenu - A WoW 1.12.1 Addon to manage quick itemswitching
  Copyright (C) 2017 Michael Wiesendanger <michael.wiesendanger@gmail.com>

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
mod.debug = me

me.tag = "Debug"

function __GM__DEBUG__PRINTCOMBATQUEUE()
  local items = mod.itemManager.GetAllRegisteredItems()

  for key, moduleName in pairs(items) do
    local itemID = mod.combatQueue.GetCombatQueueStore()[mod[items[moduleName]].id]

    if itemID ~= nil then
      mod.logger.LogDebug(me.tag, "Item with id '" .. itemID .. "' registered for slot '" .. moduleName .."'")
    else
      mod.logger.LogDebug(me.tag, "No item registered for slot: " .. moduleName)
    end
  end
end

function __GM__DEBUG__PRINTQUICKCHANGERULELIST()
  local ruleList = GearMenuOptions.QuickChangeRules
  local ruleNumber = 1

  for key, rule in pairs(ruleList) do
    mod.logger.LogDebug(me.tag, "Rule no." .. ruleNumber)

    for i = 1, table.getn(rule.slotID) do
      mod.logger.LogDebug(me.tag, "slotID: " .. rule.slotID[i])
    end

    mod.logger.LogDebug(me.tag, "changeFromName: " .. rule.changeFromName)
    mod.logger.LogDebug(me.tag, "changeFromID: " .. rule.changeFromID)
    mod.logger.LogDebug(me.tag, "changeToName: " .. rule.changeToName)
    mod.logger.LogDebug(me.tag, "changeToID: " .. rule.changeToID)
    mod.logger.LogDebug(me.tag, "delay: " .. rule.changeDelay)
    ruleNumber = ruleNumber + 1
  end
end
