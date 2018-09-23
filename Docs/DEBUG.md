# GearMenu debug

> instructions helping with debugging the GearMenu addon

## Logging

Logging can be configured in the logging module GM_Logger.lua. To enable different loglevels change the value of `logLevel`.

`me.logLevel = 4` will enable all logs except events

### Events

Events have to be turned on separately with logEvent set to true

`me.logEvent = true`

### Log windows

Enabling all logs can clutter the default chatframe. To avoid this an extra window for the menu can be created. Creating a new chat window with the name `gm_chatframe` will direct all logging to this window.

![](/Docs/gm_create_addon_chatframe.gif)

![](/Docs/gm_addon_chatframe.gif)

For each logLevel including events can be a separate chatframe. The logs will be additionally logged to those windows making it easier to find a specific log.

![](/Docs/gm_event_log_chatframe.gif)

Available chatframe names are documented in GM_Constants.lua module.

### Error handling

Sadly WoW doesn't do a really good job in cleaning up chat windows when they are deleted in the interface. Sometimes windows are invisible but still somehow there. This might cause the addon to log to an invisible chatframe making it impossible to have a look at the windows.

With `forceLogDefaultChatFrame` it is possible to enforce logging to the default chatframe. Effectively working around this problem. To fix this problem completely one has to delete the `chat-cache.txt` file from the WTF folder for the specific character and restart the WoW client.
