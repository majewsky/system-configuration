#!/bin/bash

# This is a simple mirroring script. To save bandwidth it first checks a
# timestamp via HTTP and only runs rsync when the timestamp differs from the
# local copy. As of 2016, a single rsync run without changes transfers roughly
# 6MiB of data which adds up to roughly 250GiB of traffic per month when rsync
# is run every minute. Performing a simple check via HTTP first can thus save a
# lot of traffic.

home="/data/archlinux-mirror"
target="${home}/repo"
tmp="${home}/tmp"
lock="${home}/mirrorsync.lck"
# NOTE: You'll probably want to change this or remove the --bwlimit setting in
# the rsync call below
bwlimit=4096
# NOTE: most people reading this very likely need to change this since
# rsync.archlinux.org requires you to be a tier 1 mirror
source='rsync://mirror.pseudoform.org/packages/'
lastupdate_url="https://mirror.pseudoform.org/lastupdate"

exec 9>"${lock}"
flock -n 9 || exit

# if we are called without a tty (cronjob) only run when there are changes
if ! tty -s && diff -b <(curl -s "$lastupdate_url") "$target/lastupdate" >/dev/null; then
	exit 0
fi

if ! stty &>/dev/null; then
    QUIET="-q"
fi

rsync -rtlvH --safe-links --delete-after --progress -h ${QUIET} --timeout=600 --contimeout=60 -p \
	--delay-updates --no-motd --bwlimit=$bwlimit \
	--temp-dir="${tmp}" \
	--exclude='*.links.tar.gz*' \
	--exclude='/other' \
	--exclude='/sources' \
	--exclude='/iso' \
	${source} \
	"${target}"

#echo "Last sync was $(date -d @$(cat ${target}/lastsync))"

