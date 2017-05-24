#!/usr/bin/env bash

### HEADER
# Package Title: Mindjet 10.3.605
# Author: Conor Schutzman <conor@mac.com>

### DEFINITIONS
## VARIABLES
SoftwareTitle=Mindjet
SectionTitle=Uninstall
LogFile="/Library/Logs/$SoftwareTitle.log"
TimeStamp="$(date "+%Y %b %d %T")"
ConsoleUser="$(stat -f %Su '/dev/console')"
## FUNCTIONS
writeLog(){ echo "[$(date "+%Y %b %d %T")] [$ConsoleUser] [$SoftwareTitle] [$SectionTitle] $1" >> "$LogFile"; }

## ARRAYS
AppFiles=(
	'/Applications/Mindjet.app'
	'/Library/Preferences/com.mindjet.mindmanager.10.plist'
	'/Users/Shared/Mindjet MindManager 10'
	)

### BODY
## LOGGING
[[ -d "$(dirname $LogFile)" ]] || mkdir -p -m 755 "$(dirname $LogFile)"
[[ -e "$LogFile" ]] || touch "$LogFile"
[[ "$(stat -f%z "$LogFile")" -ge 1000000 ]] && rm -rf "$LogFile"
## UNINSTALL
osascript -e 'tell application "Mindjet" to quit'
writeLog "Files removed:"
for EachFile in "${AppFiles[@]}"; do
	[[ -e "$3/$EachFile" ]] && rm -rfv "$3/$EachFile" >> "$LogFile"
	[[ -e "$3/Users/$ConsoleUser/$EachFile" ]] && rm -rfv "$3/Users/$ConsoleUser/$EachFile" >> "$LogFile"
done
writeLog "Receipts removed:"
ReceiptList=$(pkgutil --packages | grep "mindjet")
for EachReceipt in "${ReceiptList[@]}"; do
	pkgutil --forget "$EachReceipt" >> "$LogFile"
done
## FOO
SectionTitle=
echo foo

### FOOTER
exit 0
