#!/bin/bash

# until proven otherwise
SUCCESS=1

# check `systemctl --failed`
systemctl --failed | sed '/^$/,$d;/loaded units listed/,$d;1d' | cut -d' ' -f2 > /tmp/failed-units
if grep -q '[a-z]' /tmp/failed-units; then
    echo ":: systemctl lists $(wc -l < /tmp/failed-units) unit(s) in an error state:"
    cat /tmp/failed-units
    rm  /tmp/failed-units
    SUCCESS=0
fi

# TODO: check for .pacnew files (with whitelist for passwd, shadow, etc.)

# report summary
if [ $SUCCESS = 0 ]; then
    echo ':: Healthcheck failed.'
else
    echo ':: Healthcheck completed without errors.'
fi
echo "Uptime: $(uptime)"
