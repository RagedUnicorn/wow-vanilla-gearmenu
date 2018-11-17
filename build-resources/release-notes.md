**Note:** When updating from any previous version to 1.2.0 please make sure to do the following step:

Because of a bug versions before 1.2.0 saved the Addon options not only for the current character but also globally for the Addon. This was not intended and is fixed in the newest version. After updating to version 1.2.0 or newer make sure to delete the following files:

```
WTF\Account\ACCOUNTNAME\SavedVariables\GearMenu.lua
WTF\Account\ACCOUNTNAME\SavedVariables\GearMenu.lua.bak
```

Fore more info carefully read the [FAQ](https://github.com/RagedUnicorn/wow-gearmenu#faq)

* Add support for more slots see [readme](https://github.com/RagedUnicorn/wow-gearmenu#what-is-gearmenu) for all supported slots
* Fix quickchange localization for dropdown options
* Fix addon SavedVariables handling. It is now possible to have different settings between characters
* Improve handling of localization
* Introduce addon options module as single responsible module for everything related to addon options
* Improve display of onuse effect (onuse effect should no longer get stuck when spamming keys)
* Fix quickchange handling of adding/removing a new rule (selected item is now cleared after adding or removing a new rule)
* Replace custom tooltip with default blizzard frames tooltip
