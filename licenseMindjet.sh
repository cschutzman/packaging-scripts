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
PrefsFile="/Library/Preferences/com.mindjet.mindmanager.10.plist"
LicenseKey="AS10-M1M-BS7B-DF3E-3928"
BackupFolder="/Library/Backup"
## FUNCTIONS
writeLog(){ echo "[$(date "+%Y %b %d %T")] [$ConsoleUser] [$SoftwareTitle] [$SectionTitle] $1" >> "$LogFile"; }

### BODY
## LOGGING
[[ -d "$(dirname $LogFile)" ]] || mkdir -p -m 755 "$(dirname $LogFile)"
[[ -e "$LogFile" ]] || touch "$LogFile"
[[ "$(stat -f%z "$LogFile")" -ge 1000000 ]] && rm -rf "$LogFile"
## LICENSE
SectionTitle=License
[[ -e "$3/$PrefsFile" ]] && mv -v "$3/$PrefsFile" "$3/$BackupFolder" >> "$LogFile"
if [[ -e "$3/Users/$ConsoleUser/$PrefsFile" ]]; then
	IsLicensed=$(defaults read "$3/Users/$ConsoleUser/$PrefsFile" | grep -c "LicenseKey")
	if [[ "$IsLicensed" > 0 ]]; then
		writeLog "Existing license found, removing."
		writeLog "Previous license key: $(defaults read "$3/Users/$ConsoleUser/$PrefsFile" LicenseKey)"
		defaults delete "$3/Users/$ConsoleUser/$PrefsFile" LicenseKey
	fi
fi
defaults write "$3/Users/$ConsoleUser/$PrefsFile" LicenseKey "$LicenseKey"
## CLEANUP
SectionTitle=Permissions
if [[ -e "$3/Users/$ConsoleUser/$PrefsFile" ]]; then
	chown $ConsoleUser:staff "$3/Users/$ConsoleUser/$PrefsFile" >> "$LogFile"
	chmod -vv 777 "$3/Users/$ConsoleUser/$PrefsFile" >> "$LogFile"
else
	writeLog "File not found: /Users/$ConsoleUser/$PrefsFile"
fi

### FOOTER
exit 0
