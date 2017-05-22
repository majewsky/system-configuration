#!/bin/bash

set -o pipefail

# update package lists and download new packages before starting to interact with the user
if pacman -Syuw --noconfirm > /tmp/pacman-output 2>&1; then
    true # continued below
else
    cat /tmp/pacman-output
    echo ':: Stopping because "pacman -Syuw" exited with non-zero exit code.'
    exit 1
fi

# exit early if no updates were found
if tail -n1 /tmp/pacman-output | grep -q "there is nothing to do"; then
    echo ':: No package upgrades today.'
    rm /tmp/pacman-output
    exit $?
fi

# print the package list reported by pacman
sed -n '/^:: Starting full system upgrade/,/^:: Proceed with download/p' < /tmp/pacman-output | head -n -1
echo ':: Is this okay? Choose a number:'
echo ':: (1) yes, please install'
echo ':: (2) no, please stop'
rm /tmp/pacman-output

while true; do
    read ANSWER
    case "$ANSWER" in
        1)
            echo ':: Okay, going ahead...'
            break
            ;;
        2)
            echo ':: Okay. I will stop, and this job will show up in `systemctl --failed`.'
            exit 1
            ;;
        *)
            echo ':: Please say "1" or "2".'
            ;;
    esac
done

# show update progress live to the user immediately (need to truncate ANSI
# color codes here because they mysteriously cause the xmpp-bridge to see a
# premature EOF and thus exit)
if pacman -Su --noconfirm 2>&1 | sed 's/\x1b\[[0-9;]*m//g; 1,/^:: Processing package changes/d'; then
    true # continued below
else
    echo ':: Stopping because "pacman -Su" exited with non-zero exit code.'
    exit 1
fi

# this is always a good idea after upgrades
systemctl daemon-reload

# offer to reboot or restart services
echo ':: What now? Choose a number:'
echo ':: (1) nothing else'
echo ':: (2) please reboot'
echo ':: (3) please restart one or more services'

while true; do
    read ANSWER
    case "$ANSWER" in
        1)
            echo ':: Okay, good bye.'
            exit 0
            ;;
        2)
            echo ':: Okay, rebooting now...'
            systemctl reboot
            exit 0
            ;;
        3)
            break # continued below
            ;;
        *)
            echo ':: Please say "1", "2" or "3".'
            ;;
    esac
done

# user wants to restart some services - for security reasons, we limit the
# choice to services that are WantedBy=multi-user.target (and we also include
# systemd-* services and dbus for stability reasons)
RESTARTABLE_SERVICES="$(systemctl show multi-user.target | grep Wants | cut -d= -f2- | tr ' ' '\n' | sed -n '/dbus/d;/systemd/d;/\.service$/{s/\.service//;p}' | sort)"
echo ':: The following services are declared as remotely restartable:'
echo $RESTARTABLE_SERVICES | xargs -n1 echo

while true; do
    echo ":: Which services shall I restart? Say \"ok\" when you're done."
    read CHOICE
    case "$CHOICE" in
        "ok")
            echo ':: Okay, good bye.'
            break
            ;;
        *)
            RESTARTED_SOMETHING=0
            for SERVICE in "$(echo "$RESTARTABLE_SERVICES" | grep -w "$CHOICE")"; do
                if [ "$SERVICE" != "" ]; then
                    echo ":: Okay, restarting $SERVICE..."
                    systemctl restart $SERVICE.service
                    RESTARTED_SOMETHING=1
                fi
            done
            if [ $RESTARTED_SOMETHING -eq 0 ]; then
                echo ":: No service matching your choice! The following choices are valid:"
                echo $RESTARTABLE_SERVICES | xargs -n1 echo
            fi
    esac
done
