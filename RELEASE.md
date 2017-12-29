# Release

> This document explains how a new release is created for GearMenu


* Update version of Addon
  * Code/Constants.lua - GM_CONSTANTS.ADDON_VERSION
* Create a new git tag
  * git tag v1.0.1
  * git push origin --tags
* Draft new Github release with description
  * Title should be the version e.g. v1.0.0
  * Short description of what was added newly
* Prepare upload of downloadable version to the created release
  * Download full repository
  * Remove Docs folder to keep the footprint small
  * Remove git related files .git folder, .gitignore, .gitattributes
  * Pack to zipfile (make sure that the name of the unpacked folder is GearMenu)
