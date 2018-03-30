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
mod.timer = me

me.tag = "Timer"

--[[
  Private variables
]]--
local TimerPool = {}
local Timers = {}

--[[
  @param {string} name
  @param {func} func
  @param {number} delay
  @param {boolean} rep
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
  OnUpdate callback from timersframe
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
