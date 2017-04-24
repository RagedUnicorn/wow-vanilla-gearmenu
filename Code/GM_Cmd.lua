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
mod.cmd = me

me.tag = "Cmd"

--[[
  print cmd options for addon
]]--
local function ShowInfoMessage()
  local show = gm.L["show"] .. GM_CONSTANTS.ADDON_NAME .. "\n"
  local hide = gm.L["hide"] .. GM_CONSTANTS.ADDON_NAME .. "\n"
  local opt = gm.L["opt"]
  local reload = gm.L["reload"]

  DEFAULT_CHAT_FRAME:AddMessage(GM_CONSTANTS.ADDON_NAME .. ":\n")
  DEFAULT_CHAT_FRAME:AddMessage(show)
  DEFAULT_CHAT_FRAME:AddMessage(hide)
  DEFAULT_CHAT_FRAME:AddMessage(opt)
  DEFAULT_CHAT_FRAME:AddMessage(reload)
end

--[[
  setup slash command handler
]]--
function me.SetupSlashCmdList()
  SLASH_GEARMENU1 = "/gm"
  SLASH_GEARMENU2 = "/gearmenu"

  SlashCmdList["GEARMENU"] = function(msg)
    mod.logger.LogDebug(me.tag, "/gm passed argument: " .. msg)

    if msg == "" or msg == "info" then
      ShowInfoMessage()
    elseif msg == "opt" then
      mod.opt.InitOptionsMenu()
      getglobal(GM_CONSTANTS.ELEMENT_GM_OPTIONS_FRAME):Show()
    elseif msg == "show" then
      getglobal(GM_CONSTANTS.ELEMENT_GM_MAIN_FRAME):Show()
    elseif msg == "hide" then
      getglobal(GM_CONSTANTS.ELEMENT_GM_MAIN_FRAME):Hide()
    elseif msg == "rl" or msg == "reload" then
      ReloadUI()
    end
  end
end
