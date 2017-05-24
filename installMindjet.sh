#!/usr/bin/env bash

### HEADER
# Package Title: Mindjet 10.3.605
# Author: Conor Schutzman <conor@mac.com>

### DEFINITIONS
## VARIABLES
SoftwareTitle=Mindjet
SectionTitle=Postflight
LogFile="/Library/Logs/$SoftwareTitle.log"
TimeStamp="$(date "+%Y %b %d %T")"
ConsoleUser="$(stat -f %Su '/dev/console')"
ResourceLocation=$(dirname "$0")
ImageFile='Mindjet_MindManager_Mac_10.3.605.dmg'
## FUNCTIONS
writeLog(){ echo "[$(date "+%Y %b %d %T")] [$ConsoleUser] [$SoftwareTitle] [$SectionTitle] $1" >> "$LogFile"; }

### BODY
## LOGGING
[[ -d "$(dirname $LogFile)" ]] || mkdir -p -m 755 "$(dirname $LogFile)"
[[ -e "$LogFile" ]] || touch "$LogFile"
[[ "$(stat -f%z "$LogFile")" -ge 1000000 ]] && rm -rf "$LogFile"
## INSTALL
SectionTitle=Mount
MountPoint=$(/usr/bin/mktemp -d /tmp/mindjet.XXXX)
if [[ -e "$ResourceLocation/$ImageFile" ]]; then
	hdiutil attach "$ResourceLocation/$ImageFile" -mountpoint "$MountPoint" -nobrowse -noverify -noautoopen
	writeLog "Mounted $ResourceLocation/$ImageFile at $MountPoint"
else
	writeLog "Unable to find DMG at $ResourceLocation"
	ls -la "$ResourceLocation" >> "$LogFile"
	echo "DMG not found, install not successful."
	exit 1
fi
SectionTitle=Install
AppPath="$(find "$MountPoint" -maxdepth 1 \( -iname \*\.app \))"
if [[ -e "$AppPath" ]]; then
	writeLog "Installing application: $AppPath"
	ditto "$AppPath" "$3/Applications/$(basename "$AppPath")"
else
	writeLog "Application not found."
	echo "Application not found, install not successful."
	exit 1
fi
## CLEANUP
SectionTitle=Unmount
writeLog "Unmounting install DMG"
hdiutil detach "$MountPoint" >> "$LogFile"

### FOOTER
exit 0
