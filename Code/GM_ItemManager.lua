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
  Itemmanager manages all items. All itemslots muss register to work properly
]]--
local mod = gm
local me = {}
mod.itemManager = me

me.tag = "ItemManager"

local items = {}

--[[
  Register an item to the itemManager

  @param {string} name
]]--
function me.RegisterItem(name)
  mod.logger.LogInfo(me.tag, "Register item with name " .. name .. " in itemManager")
  items[name] = name
end

--[[
  Unregister an item from the itemManager

  @param {string} name
]]--
function me.UnregisterItem(name)
  mod.logger.LogInfo(me.tag, "Unregister item with name " .. name .. " from itemManager")
  items[name] = nil
end

--[[
  Calls UpdateWornItem for all registered items
]]--
function me.UpdateWornItems()
  for key, value in pairs(items) do
    mod[value].UpdateWornItem()
  end
end

--[[
  Retrieve all currently registered items

  @return {table}
]]--
function me.GetAllRegisteredItems()
  return items
end

--[[
  Returns the module that is placed at the passed position or nil if none could be found

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
  Returns the item that matches the passed itemSlot id or nil if none could be found

  @param {number} position
  @return {string | nil}
]]
function me.FindItemForSlotId(id)
  for key, value in pairs(items) do
    if mod[value].id == id then
      return mod[value].moduleName
    end
  end

  return nil
end

--[[
  Update cooldown for all registered items
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
  Check if a position is already used in a slot

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
