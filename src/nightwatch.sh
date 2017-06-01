#!/bin/bash
set -euo pipefail

NIGHTWATCH_END=360    # 6:00 = 360 minutes after midnight
NIGHTWATCH_START=1380 # 23:00 = 1380 minutes after midnight

# get minutes since midnight
CURRENT=$(($(date +'%H*60+%M')))
echo "CURRENT = $CURRENT"
# if started during the day, sleep until 23:00
if [ $CURRENT -ge $NIGHTWATCH_END -a $CURRENT -lt $NIGHTWATCH_START ]; then
  MINS=$((NIGHTWATCH_START - CURRENT))
  echo "Sleeping for $MINS minutes..."
  sleep $((MINS * 60))
fi

if pidof Xorg >/dev/null; then
  sudo -u stefan -g users env DISPLAY=:0 XDG_RUNTIME_DIR=/run/user/1001 sm "Night watch begins in 60 seconds." &
fi
sleep 60
poweroff
