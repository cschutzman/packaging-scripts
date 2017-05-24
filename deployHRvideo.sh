#!/usr/bin/env bash
videoFile=''
/usr/bin/sudo -u $(/usr/bin/stat -f %Su '/dev/console') /usr/bin/open -a "/Applications/QuickTime Player.app" "$videoFile"
exit 0
