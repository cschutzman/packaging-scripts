#!/usr/bin/env bash
#
### HEADER
# Distribution Title: McAfee ENS 10.2.1
# Package Title: installMcAfee
# ScriptTitle: Postflight
## VERSION HISTORY
# VERSION 	CONTRIBUTOR					CHANGELOG
#	1.0		conor@mac.com		Initial Development
#
### DEFINITIONS
## VARIABLES
softwareTitle=McAfee
sectionTitle=ENS
resourceLocation=$(/usr/bin/dirname "$0")
packageName="McAfee-Endpoint-Security-for-Mac-10.2.1-RTW-standalone-2632.pkg"
installOptions=''
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
## INSTALLATION
if [[ -e "${resourceLocation}/${packageName}" ]]; then
	displayNotification "Installing McAfee Security"
	if [[ -e "${resourceLocation}/${installOptions}" ]]; then
		echo "installer -applyChoiceChangesXML $installOptions -pkg ${packageName} -target / -allowUntrusted" >> "$logFile"
		/usr/sbin/installer -applyChoiceChangesXML "${resourceLocation}/${installOptions}" -pkg "${resourceLocation}/${packageName}" -target "$3" -allowUntrusted >> "$logFile"
		if [[ "$?" -ne 0 ]]; then
    		writeLog err "Vendor package exited with error $?"
            writeLog info "Reattempting with verbose logging."
            echo "installer -verboseR -dumplog -applyChoiceChangesXML $installOptions -pkg ${packageName} -target / -allowUntrusted" >> "$logFile"
            /usr/sbin/installer -verboseR -dumplog -applyChoiceChangesXML "${resourceLocation}/${installOptions}" -pkg "${resourceLocation}/${packageName}" -target "$3" -allowUntrusted >> "$logFile" 2>&1
            if [[ "$?" -ne 0 ]]; then
                exit 1
            fi
        fi
	else
		writeLog warning "Installation choice XML file not found, proceeding with default installation."
		echo "/usr/sbin/installer -pkg ${packageName} -target / -allowUntrusted" >> "$logFile"
		/usr/sbin/installer -pkg "${resourceLocation}/${packageName}" -target "$3" -allowUntrusted >> "$logFile"
		if [[ "$?" -ne 0 ]]; then
			writeLog err "Vendor package exited with error $?"
            writeLog info "Reattempting with verbose logging."
            echo "installer -verboseR -dumplog -pkg ${packageName} -target / -allowUntrusted" >> "$logFile"
            /usr/sbin/installer -verboseR -dumplog -pkg "${resourceLocation}/${packageName}" -target "$3" -allowUntrusted >> "$logFile" 2>&1
            if [[ "$?" -ne 0 ]]; then
                exit 1
            fi
        fi
	fi
else
	writeLog err "Installer package not found"
	ls "$resourceLocation" >> "$logFile"
	exit 1
fi
#
### FOOTER
exit 0
