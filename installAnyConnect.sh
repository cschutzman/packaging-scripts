#!/usr/bin/env bash
#
### HEADER
# Package Title: installAnyConnect
# ScriptTitle: Postflight
## VERSION HISTORY
# Version   Contributor                 Changelog
#   2.0     conor@mac.com 			     Initial development of branch.
#	2.1		conor@mac.com 			 	Added additional hardening to verify installation success.
#
### DEFINITIONS
## VARIABLES
softwareTitle=TEMPO
sectionTitle=AnyConnect
resourceLocation=$(/usr/bin/dirname "$0")
packageName="AnyConnect.pkg"
installOptions='com.anyconnect.install.plist'
pkiFile='te_Clientprofile_pkicap.xml'
rsaFile='te_clientprofile_cap.xml'
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
if [[ -e "${resourceLocation}/${packageName}" ]]; then
	displayNotification "Installing AnyConnect"
	if [[ -e "${resourceLocation}/${installOptions}" ]]; then
		echo "installer -applyChoiceChangesXML $installOptions -pkg ${packageName} -target / -allowUntrusted" >> "$logFile"
		/usr/sbin/installer -applyChoiceChangesXML "${resourceLocation}/${installOptions}" -pkg "${resourceLocation}/${packageName}" -target "/" -allowUntrusted >> "$logFile"
		if [[ "$?" -ne 0 ]]; then
    		exitError "An error occured when running ${packageName}.\n \nThis installation process will need to be repeated."
        fi
	else
		writeLog warning "Installation choice XML file not found, proceeding with default installation."
		echo "/usr/sbin/installer -pkg ${packageName} -target / -allowUntrusted" >> "$logFile"
		/usr/sbin/installer -pkg "${resourceLocation}/${packageName}" -target "/" -allowUntrusted >> "$logFile"
		if [[ "$?" -ne 0 ]]; then
    		exitError "An error occured when running ${packageName}.\n \nThis installation process will need to be repeated."
        fi
	fi
else
	writeLog err "Installer package not found"
	ls "$resourceLocation" >> "$logFile"
	exit 1
fi
## PROFILES
displayNotification "Installing PKI profile"
if [[ -e "${resourceLocation}/$pkiFile" ]]; then
	cp -v "${resourceLocation}/$pkiFile" "/opt/cisco/anyconnect/profile/" >> "$logFile"
	/usr/sbin/chown root:wheel "/opt/cisco/anyconnect/profile/$pkiFile"
	chmod 777 "/opt/cisco/anyconnect/profile/$pkiFile"
else
	writeLog warning "PKI profile not found"
fi
if [[ -e "/opt/cisco/anyconnect/profile/$rsaFile" ]]; then
	writeLog info "Removing non-PKI profile"
	rm -f "/opt/cisco/anyconnect/profile/$rsaFile" >> "$logFile"
else
	writeLog info "non-PKI profile not found"
fi
## WEBSECURITY
displayNotification "Configuring Web Security module"
/usr/bin/pkill -l acwebsecagent 2>&1 >> "$logFile"
/usr/bin/sudo -u "$consoleUser" /usr/bin/pkill -l acwebsecagent 2>&1 >> "$logFile"
if [[ -e "/opt/cisco/hostscan/bin/websecurity_uninstall.sh" ]]; then
	writeLog info "Executing WebSecurity uninstall script."
	"/opt/cisco/hostscan/bin/websecurity_uninstall.sh"
fi
if [[ -e "/opt/cisco/anyconnect/bin/websecurity_uninstall.sh" ]]; then
	writeLog info "Executing WebSecurity uninstall script."
	"/opt/cisco/anyconnect/bin/websecurity_uninstall.sh"
fi
if [[ -f "/opt/cisco/anyconnect/websecurity" ]]; then
	writeLog info "Cleaning up any remaining WebSecurity components."
	rm -rfv "/opt/cisco/anyconnect/websecurity" >> "$logFile"
fi
#
### FOOTER
exit 0
