#!/bin/bash

# update package lists and download new packages before starting to interact with the user
if yes 2>/dev/null | pacman -Syuw > /tmp/pacman-output 2>&1; then
    true # continued below
else
    cat /tmp/pacman-output
    echo ':: Stopping because "pacman -Syuw" exited with non-zero exit code.'
    exit 1
fi

# exit early if no updates were found
if tail -n1 /tmp/pacman-output | grep -q "there is nothing to do"; then
    echo ':: No package upgrades today'
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

# show update progress live to the user immediately
yes 2>/dev/null | pacman -Su

# TODO: offer to reboot or restart some service
