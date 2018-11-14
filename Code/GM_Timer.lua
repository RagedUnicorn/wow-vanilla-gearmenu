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

local timerPool = {}
local timers = {}

--[[
  @param {string} name
  @param {func} func
  @param {number} delay
  @param {boolean} rep
]]--
function me.CreateTimer(name, func, delay, rep)
  mod.logger.LogDebug(me.tag, "Created timer with name: " .. name)
  timerPool[name] = {
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
  for i, j in ipairs(timers) do
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
  timerPool[name].elapsed = delay or timerPool[name].delay

  if not me.IsTimerActive(name) then
    table.insert(timers, name)
    getglobal(GM_CONSTANTS.ELEMENT_TIMER_FRAME):Show()
  end
end

--[[
  @param {string} name
]]--
function me.StopTimer(name)
  local idx = me.IsTimerActive(name)

  if idx then
    table.remove(timers, idx)
    mod.logger.LogDebug(me.tag, "Stopped timer with name: " .. name)
    if table.getn(timers) < 1 then
      getglobal(GM_CONSTANTS.ELEMENT_TIMER_FRAME):Hide()
    end
  end
end

--[[
  OnUpdate callback from timersframe
]]--
function me.TimersFrameOnUpdate()
  local timer

  for _, name in ipairs(timers) do
    timer = timerPool[name]
    timer.elapsed = timer.elapsed - arg1
    if timer.elapsed < 0 then
      timer.func()
      if timer.rep then
        timer.elapsed = timer.delay
      else
        me.StopTimer(name)
      end
    end
  end
end
