#!/usr/bin/env bash
#
### HEADER
# Package Title: preFlight
## VERSION HISTORY
# VERSION 	CONTRIBUTOR					CHANGELOG
#	1.0		conor@mac.com		Initial Development
#
### DEFINITIONS
## VARIABLES
softwareTitle=MacConfig
sectionTitle=Preflight
resourceLocation=$(/usr/bin/dirname "$0")
versionNumber=2.0.160930c
proxyURL=''
filerURL=''
## FUNCTIONS
networkTest(){ /usr/bin/curl -L -s -o /dev/null --silent --head --write-out '%{http_code}' "$1" --location-trusted -X GET; }
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
## INITIALIZATION
echo "========" >> "$logFile"
writeLog info "[$(date)] MacConfig $versionNumber"
echo "========" >> "$logFile"
displayDialog "During this installation, the progress bar and estimated time may not properly reflect the actual status of the installation. This entire setup process should take 7-10 minutes on most systems.\n \nDuring this process, you will be prompted for some information about your account. Please take care that this information is entered correctly, as inaccurate information will prevent this process from completing successfully."
displayNotification "Beginning Mac Prep Operation"
# PROXY CONFIGURATION
displayNotification "Setting initial proxy configuration"
activeInterfaces="$(/usr/sbin/networksetup -listallnetworkservices | /usr/bin/grep -v '*')"
while read; do
  presentInterfaces+=("$REPLY")
done< <(echo "$activeInterfaces")
for eachInterface in "${presentInterfaces[@]}"; do
    isEnabled=
    for eachEntry in "${essentialInterfaces[@]}"; do
        [[ "$eachInterface" == "$eachEntry" ]] && { isEnabled=1; break; }
    done
    [[ -n "$isEnabled" ]] && networkInterfaces+=("$eachInterface")
done
for eachInterface in "${networkInterfaces[@]}"; do
    existingProxy="$(/usr/sbin/networksetup -getautoproxyurl "$eachInterface"| /usr/bin/head -n 1 | /usr/bin/awk '{print $2}')"
    if [[ "$existingProxy" != "$proxyURL" ]]; then
        writeLog info "[$eachInterface] setting proxy URL to $proxyURL"
        /usr/sbin/networksetup -setautoproxyurl "$eachInterface" "$proxyURL"
    fi
done
## TESTS
displayNotification "Performing system verifications"
# NETWORK TEST
if [[ $(networkTest $filerURL) = 200 ]]; then
    writeLog info "Network connection confirmed"
else
    displayDialog "Unable to confirm connection to corporate network.\n \nPlease connect to the network and press OK to continue."
    if [[ $(networkTest $filerURL) != 200 ]]; then
        exitError "This installation cannot proceed over VPN.\n \nPlease connect to the network using Ethernet or WiFi before restarting this process."
    else
        writeLog info "Network connection established"
    fi
fi
# ANYCONNECT TEST
processCount=$(ps aux | /usr/bin/grep -v grep | /usr/bin/grep -c "Cisco AnyConnect Secure Mobility Client.app")
if [[ processCount -ne 0 ]]; then
	ps aux | /usr/bin/grep -v grep | /usr/bin/grep "Cisco AnyConnect Secure Mobility Client.app" >> "$logFile"
	exitError "This installation cannot proceed over VPN.\n \nPlease quit AnyConnect, and connect to the network using Ethernet or WiFi before restarting this process."
fi
# FILEVAULT TEST
encryptionStatus=$(/usr/bin/fdesetup status | /usr/bin/grep -c 'FileVault is On.')
if [[ "$encryptionStatus" -ne 0 ]]; then
	exitError "This installation cannot proceed while FileVault is enabled.\n \nPlease disable FileVault and allow your Mac to decrypt completely before restarting this process."
fi
## USER INFORMATION
displayNotification "Gathering user information"
# USERNAME PROMPT
usernameConfirmed=0
while [[ "$usernameConfirmed" = 0 ]]; do
    enteredUsername=$(promptInput "Please enter your eight-digit User ID:" "te012345")
    [[ "$?" != 0 ]] && exit 1
    if [[ "$enteredUsername" = 'te012345' ]]; then
        enteredUsername=$(promptInput "Default text was entered, please replace the default text with your User ID." "te012345")
        [[ "$?" != 0 ]] && exit 1
        if [[ "$enteredUsername" = 'te012345' ]]; then
            writeLog warning "User entered default text for first username prompt"
        fi
    fi
    confirmUsername=$(promptInput "Please retype your User ID for confirmation." "te012345")
    [[ "$?" != 0 ]] && exit 1
    if [[ "$confirmUsername" = 'te012345' ]]; then
        confirmUsername=$(promptInput "Default text was entered, please retype your User ID for confirmation." "te012345")
        [[ "$?" != 0 ]] && exit 1
        if [[ "$confirmUsername" = 'te012345' ]]; then
            writeLog warning "User entered default text for User ID confirmation"
        fi
    fi
    if [[ "$enteredUsername" = 'te012345' ]] || [[ "$confirmUsername" = 'te012345' ]]; then
        displayDialog "Default text was provided multiple times, please try again."
    elif [[ "$enteredUsername" != "$confirmUsername" ]]; then
        displayDialog "User ID entries did not match, please try again."
    elif [[ "${#enteredUsername}" != 8 ]]; then
        displayDialog "User ID does not appear to be following established TE format, please try again."
    else
        writeLog info "Confirmed User ID: $enteredUsername"
        (( usernameConfirmed++ ))
        break
    fi
done
if [[ "$enteredUsername" = 'te012345' ]] || [[ -z "$enteredUsername" ]]; then
    exitError "An error occured during User ID entry.\n \nPlease restart this process."
else
	writeLog info "User entered employee ID: $enteredUsername"
fi
# REGION PROMPT
if [[ -s "${resourceLocation}/regionList.sh" ]]; then
    enteredRegion=0
    source "${resourceLocation}/regionList.sh"
    while [[ "$enteredRegion" = 0 ]]; do
        selectedRegion=$(promptRegion)
        if [[ "$selectedRegion" = false ]]; then
            displayDialog "Installation cannot continue without selecting a region.\n \nPlease click OK to make your selection."
            [[ "$?" != 0 ]] && exit 1
        else
            (( enteredRegion++ ))
            break
        fi
    done
    writeLog info "User selected $selectedRegion"
    for (( i = 0; i < "${#availableRegions[@]}"; i++ )); do
        if [[ "${availableRegions[$i]}" == "$selectedRegion" ]]; then
            regionVariable="${regionCodes[$i]}"
        fi
    done
else
    writeLog info "regionlist.sh not found"
    ls -la "$resourceLocation" >> "$logFile"
    displayNotification "Regional information not available, please provide specifics on your preferred region."
fi
# COUNTRY CODE
if [[ "${#regionVariable}" = 2 ]]; then
    countryCode="$regionVariable"
else
    enteredCountry=0
    while [[ "$enteredCountry" = 0 ]]; do
        countryCode=$(promptInput "Please enter your two-digit country code." "xx")
        [[ "$?" != 0 ]] && exit 1
        if [[ "$countryCode" = 'xx' ]]; then
            countryCode=$(promptInput "Default text was entered, please replace the default text with your two-digit country code." "xx")
            [[ "$?" != 0 ]] && exit 1
        fi
        if [[ "$countryCode" = 'xx' ]]; then
            displayDialog "Default text entered multiple times, please press OK and try again."
        elif [[ "${#countryCode}" != 2 ]]; then
            displayDialog "Country codes must be two digits, please press OK and try again."
        else
            writeLog info "Country Code Entered: $countryCode"
            (( enteredCountry++ ))
            break
        fi
    done
fi
if [[ "$countryCode" = 'xx' ]]; then
    exitError "An error occured during country code.\n \nPlease restart this process."
fi
# "OTHER" SELECTION CATCH
if [[ -z "$regionVariable" ]] || [[ "$regionVariable" = 'other' ]]; then
    enteredDomain=0
    while [[ "$enteredDomain" = 0 ]]; do
        domainController=$(promptInput "Please enter your preferred Active Directory Domain Controller address." "region.domain.com")
        [[ "$?" != 0 ]] && exit 1
        if [[ "$domainController" = "region.domain.com" ]]; then
            domainController=$(promptInput "Default text was entered, please replace the default text with your preferred Active Directory Domain Controller address." "region.domain.com")
            [[ "$?" != 0 ]] && exit 1
        fi
        if [[ "$domainController" = "region.domain.com" ]]; then
            displayDialog "Default text entered multiple times, please press OK and try again."
        elif [[ $(echo "$domainController" | /usr/bin/grep -c 'domain') != 1 ]] || [[ $(echo "$domainController" | /usr/bin/awk -F '.' '{print NF -1 }') != 2 ]]; then
            displayDialog "Domain entered does not seem appear to match any known TE domain, please press OK to try again."
        else
            writeLog info "Domain Entered: $domainController"
            (( enteredDomain++ ))
            break
        fi
    done
    regionVariable=$(echo $domainController | /usr/bin/grep '.domain.com' | /usr/bin/awk -F '.' '{print $1}')
fi
if [[ "$countryCode" = 'region' ]]; then
    exitError "An error occured during region selection.\n \nPlease restart this process."
fi
## STORE VALUES
storedSettings="com.connect.te.userinfo.plist"
if [[-e "${libraryLocation}/${storedSettings}" ]]; then
	writeLog warning "Existing stored settings found, overwriting."
else
	writeLog info "Storing settings at: ${libraryLocation}/${storedSettings}"
fi
/usr/bin/defaults write "${libraryLocation}/${storedSettings}" "enteredUsername" "$enteredUsername"
/usr/bin/defaults write "${libraryLocation}/${storedSettings}" "selectedRegion" "$selectedRegion"
/usr/bin/defaults write "${libraryLocation}/${storedSettings}" "regionVariable" "$regionVariable"
/usr/bin/defaults write "${libraryLocation}/${storedSettings}" "countryCode" "$countryCode"
#
### FOOTER
exit 0
