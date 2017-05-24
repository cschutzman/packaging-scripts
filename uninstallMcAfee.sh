#!/usr/bin/env bash
#
### HEADER
# Distribution Title: McAfee ENS 10.2.1
# Package Title: removeMcAfee
# ScriptTitle: Preflight
## VERSION HISTORY
# Version   Contributor                 Changelog
#   2.0     conor@mac.com		        Initial development of branch.
#
### DEFINITIONS
## VARIABLES
softwareTitle=McAfee
sectionTitle=Uninstall
resourceLocation=$(/usr/bin/dirname "$0")
## IMPORT SHARED VALUES
if [[ -s "${resourceLocation}/sharedLib.sh" ]]; then
    source "${resourceLocation}/sharedLib.sh"
else
    /usr/bin/logger "Shared resources not available, quitting."
    echo "Shared resources not available, quitting."
    exit 1
fi
#
### BODY
## UNINSTALL
/usr/bin/osascript -e 'tell application "MacAfee Security" to quit'
if [[ -e "/usr/local/McAfee/ProductConfig.xml" ]]; then
	displayNotification "Removing existing McAfee EPM Installation"
	[[ -e "/usr/local/McAfee/uninstall" ]] && "/usr/local/McAfee/uninstall" EPM >> "$logFile"
	[[ -e "/usr/local/McAfee/uninstallMSC" ]] && "/usr/local/McAfee/uninstallMSC" >> "$logFile"
	[[ -e "/usr/local/McAfee/MasterUninstallMSC" ]] && "/usr/local/McAfee/MasterUninstallMSC" epm >> "$logFile"
else
	writeLog info "Existing EPM installation not found"
fi
if [[ -e "/Library/McAfee/cma/uninstall.sh" ]]; then
	displayNotification "Removing existing McAfee Agent Installation"
	bash "/Library/McAfee/cma/uninstall.sh" >> "$logFile"
else
	writeLog info "Existing CMA installation not found"
fi
#
### FOOTER
exit 0
