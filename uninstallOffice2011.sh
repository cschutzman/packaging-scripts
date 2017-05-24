#!/usr/bin/env bash

### HEADER
# Package Title: Remove Office 2011
# Author: Conor Schutzman <conor.schutzman@te.com>

### DEFINITIONS
## VARIABLES
SoftwareTitle=Office2011
SectionTitle=Uninstall
LogFile="/Library/Logs/$SoftwareTitle.log"
ConsoleUser="$(stat -f %Su '/dev/console')"
## ARRAYS
AppFiles=(
	'/Applications/Microsoft Office 2011'
	'/Applications/Microsoft Communicator.app'
	'/Applications/Microsoft Messenger.app'
	'/Library/Application Support/Microsoft'
	'/Library/Fonts/Microsoft'
	'/Library/Internet Plug-Ins/Silverlight.plugin'
	'/Library/LaunchDaemons/com.microsoft.office.licensing.helper.plist'
	'/Library/Preferences/com.microsoft.office.licensing.plist'
	'/Library/PrivilegedHelperTools/com.microsoft.office.licensing.helper'
	'/tmp/Microsoft'
	)
AutomatorActions=()
MicrosoftFonts=()
## FUNCTIONS
writeLog(){ echo "[$(date "+%Y %b %d %T")] [$ConsoleUser] [$SoftwareTitle] [$SectionTitle] $1" >> "$LogFile"; }

### BODY
## LOGGING
[[ -d "$(dirname $LogFile)" ]] || mkdir -p -m 755 "$(dirname $LogFile)"
[[ -e "$LogFile" ]] || touch "$LogFile"
[[ "$(stat -f%z "$LogFile")" -ge 1000000 ]] && rm -rf "$LogFile"
## QUITTING APPS
osascript -e 'tell application "Outlook" to quit'
osascript -e 'tell application "OneNote" to quit'
osascript -e 'tell application "Word" to quit'
osascript -e 'tell application "Excel" to quit'
osascript -e 'tell application "PowerPoint" to quit'
killall "Office365ServiceV2"
## FILES
writeLog "Removing Files:"
for EachFile in "${OfficeFiles[@]}"; do
	[[ -e "$3/$EachFile" ]] && rm -rfv "$3/$EachFile" >> "$LogFile"
	[[ -e "$3/Users/$ConsoleUser/$EachFile" ]] && rm -rfv "$3/Users/$ConsoleUser/$EachFile" >> "$LogFile"
done
## AUTOMATOR ACTIONS
writeLog "Removing Automator actions:"
AutomatorPackages=$(pkgutil --packages $3 | grep microsoft.office | grep automator)
for EachPackage in "${AutomatorPackages[@]}"; do
	while read; do
		AutomatorActions+=("$REPLY")
	done < <(pkgutil --files $EachPackage)
done
for EachAction in "${AutomatorActions[@]}"; do
	if [[ "$EachAction" != "Library" ]] && [[ "$EachAction" != "Library/Automator" ]]; then
		[[ -e "$3/$EachAction" ]] && rm -rfv "$3/$EachAction" >> "$LogFile"
	fi
done
## FONTS
writeLog "Removing Fonts:"
AutomatorPackages=$(pkgutil --packages $3 | grep microsoft.office | grep fonts)
for EachPackage in "${AutomatorPackages[@]}"; do
	while read; do
		MicrosoftFonts+=("$REPLY")
	done < <(pkgutil --files $EachPackage)
done
for EachFont in "${MicrosoftFonts[@]}"; do
	if [[ "$EachFont" != "Library" ]] && [[ "$EachFont" != "Library/Fonts" ]]; then
		[[ -e "$3/$EachFont" ]] && rm -rfv "$3/$EachFont" >> "$LogFile"
	fi
done

### FOOTER
exit 0
