#!/bin/bash
set -xeuo pipefail

NIGHTWATCH_END=360    # 6:00 = 360 minutes after midnight
NIGHTWATCH_START=1380 # 23:00 = 1380 minutes after midnight

# get minutes since midnight (the sed converts "08" and "09" into "8" and "9" because $((...)) would choke on them otherwise)
CURRENT=$(($(date +'%H*3600+%M*60+%S' | sed 's/0\([89]\)/\1/g')))
# if started during the day, sleep until 23:00
if [ $CURRENT -ge $((NIGHTWATCH_END * 60)) -a $CURRENT -lt $((NIGHTWATCH_START * 60)) ]; then
  sleep $((NIGHTWATCH_START * 60 - CURRENT))
fi

if pidof Xorg >/dev/null; then
  sudo -u stefan -g users env DISPLAY=:0 XDG_RUNTIME_DIR=/run/user/1001 sm "Night watch begins in 60 seconds." &
fi
sleep 60
poweroff
