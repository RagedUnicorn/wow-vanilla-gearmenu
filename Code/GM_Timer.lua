--[[
  GearMenu - A WoW 1.12.1 Addon to manage quick itemswitching
  Copyright (C) 2018 Michael Wiesendanger <michael.wiesendanger@gmail.com>

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
mod.timer = me

me.tag = "Timer"

--[[
  private variables
]]--
local TimerPool = {}
local Timers = {}

--[[
  @param {string} name
  @param {func} func
  @param {number} delay
  @param {number} rep
]]--
function me.CreateTimer(name, func, delay, rep)
  mod.logger.LogDebug(me.tag, "Created timer with name: " .. name)
  TimerPool[name] = {
    func = func,
    delay = delay,
    rep = rep,
    elapsed = delay
  }
end

--[[
  @param {string} name
  @return {number, nil}
]]--
function me.IsTimerActive(name)
  for i, j in ipairs(Timers) do
    if j == name then
      return i
    end
  end
  return nil
end

--[[
  @param {string} name
  @param {number} delay
]]--
function me.StartTimer(name, delay)
  mod.logger.LogDebug(me.tag, "Started timer with name: " .. name)
  TimerPool[name].elapsed = delay or TimerPool[name].delay

  if not me.IsTimerActive(name) then
    table.insert(Timers, name)
    getglobal(GM_CONSTANTS.ELEMENT_GM_TIMER_FRAME):Show()
  end
end

--[[
  @param {string} name
]]--
function me.StopTimer(name)
  local idx = me.IsTimerActive(name)

  if idx then
    table.remove(Timers, idx)
    mod.logger.LogDebug(me.tag, "Stopped timer with name: " .. name)
    if table.getn(Timers) < 1 then
      getglobal(GM_CONSTANTS.ELEMENT_GM_TIMER_FRAME):Hide()
    end
  end
end

--[[
  onUpdate callback from timersframe
]]--
function me.TimersFrame_OnUpdate()
  local timerPool

  for _, name in ipairs(Timers) do
    timerPool = TimerPool[name]
    timerPool.elapsed = timerPool.elapsed - arg1
    if timerPool.elapsed < 0 then
      timerPool.func()
      if timerPool.rep then
        timerPool.elapsed = timerPool.delay
      else
        me.StopTimer(name)
      end
    end
  end
end
