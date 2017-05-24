#!/usr/bin/env bash
#
### HEADER
# Distribution Title: OneDrive for Business
# Package Title: installOneDrive
# ScriptTitle: Postflight
## VERSION HISTORY
# Version 	Contributor 				Changelog
# 1.0		conor@mac.com 		 		Initial Development
# 1.1		conor@mac.com 		 		Removed shared library, simplifying script
# 1.2		conor@mac.com 		 		Added single command line reference comment
### DEFINITIONS
## VARIABLES
softwareTitle=OneDrive
sectionTitle=Install
logFolder="/Library/Logs/TEIS"
logFile="${logFolder}/${softwareTitle}.log"
consoleUser=$(/usr/bin/stat -f %Su '/dev/console')
packageName='OneDrive-17.3.6298'
#
### BODY
## SET PREFERENCES
# enable OD4B support
/usr/bin/sudo -u "$consoleUser" /usr/bin/defaults write "/Users/${consoleUser}/Library/Preferences/com.microsoft.OneDrive-mac" DefaultToBusinessFRE -bool True
# disable consumer support
/usr/bin/sudo -u "$consoleUser" /usr/bin/defaults write "/Users/${consoleUser}/Library/Preferences/com.microsoft.OneDrive-mac" DisablePersonalSync -bool True
# single line option to disable support
# left here for reference in periodic (GPO) scripts
# /usr/bin/sudo -u $(/usr/bin/stat -f %Su '/dev/console') /usr/bin/defaults write "/Users/$(/usr/bin/stat -f %Su '/dev/console')/Library/Preferences/com.microsoft.OneDrive-mac" DisablePersonalSync -bool True
## LAUNCH APPLICATION
# rerun setup assistant on next launch
/usr/bin/sudo -u "$consoleUser" /usr/bin/defaults write "/Users/${consoleUser}/Library/Preferences/com.microsoft.OneDrive-mac" EnableAddAccounts -bool True
# launch app as the user
/usr/bin/sudo -u "$consoleUser" /usr/bin/open -nFg "/Applications/OneDrive.app"
#
### FOOTER
exit 0
