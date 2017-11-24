#!/bin/bash
set -euo pipefail

SERVER_ROOT="$HOME/servers"
CURRENT_SERVER="$(systemctl --user | awk '$4 == "running" && $1 ~ /minecraft@/ { print $1 }' | sed 's/^minecraft@//;s/\.service$//' || exit 1)"

if [ -n "${SSH_ORIGINAL_COMMAND:-}" ]; then
	set -- $SSH_ORIGINAL_COMMAND
fi
CMD=$1
shift

CMDS_HELP="Available commands: ( stop ) ( start [servername] ) ( logs )"
if [ -z "$CMD" ]; then
	echo "$CMDS_HELP"
	exit 0
fi

case "$CMD" in
	list)
		cd "$SERVER_ROOT"
		ls --quoting-style=literal -1 */Server\ Files/ServerStart.sh | cut -d/ -f1
		;;
	stop)
		if [ -z "$CURRENT_SERVER" ]; then
			echo "No server running."
			exit 0
		fi
		echo "Stopping $CURRENT_SERVER..."
		systemctl --user stop "minecraft@$CURRENT_SERVER"
		;;
	start)
		if [ ! -f "$SERVER_ROOT/$1/Server Files/ServerStart.sh" ]; then
			echo "Invalid server name: $1"
			exit 1
		fi
		if [ -n "$CURRENT_SERVER" ]; then
			if [ "$CURRENT_SERVER" = "$1" ]; then
				echo "Server $1 already running."
				exit 0
			else
				echo "Server $CURRENT_SERVER currently running. Use \`stop\` command first."
				exit 1
			fi
		fi
		systemctl --user start "minecraft@$1"
		echo "Server $1 now starting up."
		;;
	logs)
		if [ -z "$CURRENT_SERVER" ]; then
			echo "No server running."
			exit 1
		fi
		exec journalctl -q --user -u "minecraft@$CURRENT_SERVER" "$@"
		;;
	*)
		echo "$CMDS_HELP"
		exit 1
		;;
esac
