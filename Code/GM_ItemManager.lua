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


--[[
  itemmanager manages all items. All itemslots muss register to work properly
]]--
local mod = gm
local me = {}
mod.itemManager = me

me.tag = "ItemManager"

local items = {}

--[[
  register an item to the itemManager
  @param {string} name
]]--
function me.RegisterItem(name)
  mod.logger.LogInfo(me.tag, "Register item with name " .. name .. " in itemManager")
  items[name] = name
end

--[[
  unregister an item from the itemManager
  @param {string} name
]]--
function me.UnregisterItem(name)
  mod.logger.LogInfo(me.tag, "Unregister item with name " .. name .. " from itemManager")
  items[name] = nil
end

--[[
  calls UpdateWornItem for all registered items
]]--
function me.UpdateWornItems()
  for key, value in pairs(items) do
    mod[value].UpdateWornItem()
  end
end

--[[
  retrieve all currently registered items
  @return {table}
]]--
function me.GetAllRegisteredItems()
  return items
end

--[[
  returns the module that is placed at the passed position or nil if none could be found
  @param {number} position
  @return {string | nil}
]]--
function me.FindModuleForPosition(position)
  for key, value in pairs(items) do
    if mod[value].GetPosition() == tonumber(position) then
      return mod[value].moduleName
    end
  end

  mod.logger.LogInfo(me.tag, "No active module in position " .. position .. " could be found")
  return nil
end

--[[
  returns the item that matches the passed itemSlot id or nil if none could be found
  @param {number} position
  @return {string | nil}
]]
function me.FindItemForSlotID(id)
  for key, value in pairs(items) do
    if mod[value].id == id then
      return mod[value].moduleName
    end
  end

  return nil
end

--[[
  create timers for all registered items
]]--
function me.CreateTimersForItems()
  for key, value in pairs(items) do
    mod.timer.CreateTimer(mod[value].timer, mod[value].UpdateWornItem, .75)
  end
  mod.logger.LogInfo(me.tag, "Created timers for registered items")
end

--[[
  update cooldown for all registered items
]]--
function me.UpdateCooldownForAllWornItems()
  for key, value in pairs(items) do
    -- check if item is disabled
    if mod[value].GetDisabled() ~= true then
      mod.cooldown.UpdateCooldownForWornItem(mod[value].id, mod[value].GetPosition())
    end
  end
end

--[[
  check if a position is already used in a slot
  @param {number} id
  @return {boolean | nil}
    false when items is not used
    true if item is already used in a slot
]]--
function me.IsPositionInUse(id)
  if id == 0 then return false end

  for key, value in pairs(items) do
    if mod[value].id == id then
      if mod[value].GetDisabled() then
        return false
      else
        return true
      end
    end
  end

  return nil
end
