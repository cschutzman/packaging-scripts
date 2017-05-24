#!/usr/bin/env bash
#
### HEADER
# Distribution Title: TEMPO 2.0
# Package Title: removeCentrify
# ScriptTitle: Preflight
## VERSION HISTORY
# Version   Contributor                 Changelog
#   2.0     conor@mac.com      Initial development of branch.
#
### DEFINITIONS
## VARIABLES
softwareTitle=Uninstall
sectionTitle=Centrify
resourceLocation=$(/usr/bin/dirname "$0")
## IMPORT SHARED VALUES
if [[ -s "${resourceLocation}/sharedLib.sh" ]]; then
    source "${resourceLocation}/sharedLib.sh"
else
    /usr/bin/logger "Shared resources not available, quitting."
    echo "Shared resources not available, quitting."
    exit 1
fi
## IMPORT STORED VALUES
if [[ -s "$resourceLocation/com.domain.directoryinfo.plist" ]]; then
    directoryUsername=$(/usr/bin/defaults read "$resourceLocation/com.domain.directoryinfo.plist" account)
    directoryPassword=$(/usr/bin/defaults read "$resourceLocation/com.domain.directoryinfo.plist" key | /usr/bin/openssl enc -aes-128-cbc -a -d -salt -pass pass:"$domainSuffix")
else
    ls -la "$resourceLocation" >> "$logFile"
    exitError "Account details not available, quitting."
fi
#
### BODY
# REMOVING EXISTING BIND
if [[ -e "/usr/local/bin/adinfo" ]]; then
    previousDomain=$(/usr/local/bin/adinfo --domain)
    domainCheck="$?"
    if [[ "$domainCheck" = 0 ]]; then
        if [[ -n "$previousDomain" ]]; then
            displayNotification "Leaving $previousDomain"
        fi
        echo "adleave --user XXXXXXXX --password XXXXXXXX --remove --verbose" >> "$logFile"
        /usr/local/sbin/adleave --user "${directoryUsername}@domain.com" --password "$directoryPassword" --remove --verbose >> "$logFile"
        sleep 10
	    /usr/local/bin/adinfo  --domain
	    domainConfirm="$?"
	    if [[ "$domainConfirm" = 10 ]]; then
	        writeLog info "adleave succesful"
	    elif [[ "$domainConfirm" = 0 ]]; then
	        writeLog warning "Forced AD leave required"
	        echo "adleave --forcce --verbose" >> "$logFile"
	        /usr/local/sbin/adleave --force --verbose >> "$logFile"
	    fi
	fi
elif [[ -e "/usr/bin/adinfo" ]]; then
    previousDomain=$(/usr/bin/adinfo --domain)
    domainCheck="$?"
    if [[ "$domainCheck" = 0 ]]; then
        if [[ -n "$previousDomain" ]]; then
            displayNotification "Leaving $previousDomain"
        fi
        echo "adleave --user XXXXXXXX --password XXXXXXXX --remove --verbose" >> "$logFile"
        /usr/sbin/adleave --user "${directoryUsername}@domain.com" --password "$directoryPassword" --remove --verbose >> "$logFile"
        sleep 10
        /usr/bin/adinfo  --domain
        domainConfirm="$?"
        if [[ "$domainConfirm" = 10 ]]; then
            writeLog info "adleave succesful"
        elif [[ "$domainConfirm" = 0 ]]; then
            writeLog warning "Forced AD leave required"
            echo "adleave --forcce --verbose" >> "$logFile"
            /usr/sbin/adleave --force --verbose >> "$logFile"
        fi
    fi
else
    writeLog info "No Centrify installation found."
    exit 0
fi
## UNINSTALL
if [[ -e "/usr/local/share/centrifydc/bin/uninstall.sh" ]]; then
	displayNotification "Removing existing Centrify installation"
	/usr/local/share/centrifydc/bin/uninstall.sh -n -e >> "$logFile"
elif [[ -e "/usr/share/centrifydc/bin/uninstall.sh" ]]; then
    displayNotification "Removing existing Centrify installation"
    /usr/share/centrifydc/bin/uninstall.sh -n -e >> "$logFile"
fi
#
### FOOTER
exit 0
