#!/bin/bash
set -euo pipefail

SERVER_ROOT="$HOME/servers"
CURRENT_SERVER="$(systemctl --user | awk '$4 == "running" && $1 ~ /minecraft@/ { print $1 }' | sed 's/^minecraft@//;s/\.service$//' || exit 1)"

usage() {
cat <<-'EOF'
syntax:
	minecraft-shell list            - List names of available servers.
	                                  The mark indicates the currently running server, if any.

	minecraft-shell start <NAME>    - Start given server.
	minecraft-shell stop            - Stop currently running server, if any.

	minecraft-shell status          - Show status of currently running server, if any.
	minecraft-shell logs [ARG...]   - Show logs for currently running server.#
	                                  Args are passed on to journalctl(1).

	minecraft-shell backup          - Commit and push the current state of the servers directory
	                                  into the backup Git repo.

	minecraft-shell bash            - Log into bash(1) for maintenance.

EOF
}

if [ -n "${SSH_ORIGINAL_COMMAND:-}" ]; then
	set -- ${SSH_ORIGINAL_COMMAND}
fi
if [ $# -eq 0 ]; then
	usage
	exit 0
fi

CMD="$1"
shift

case "$CMD" in
	list)
		if [ $# -ne 0 ]; then
			usage
			exit 1
		fi
		cd "$SERVER_ROOT"
		ls --quoting-style=literal -1 */Server\ Files/ServerStart.sh | cut -d/ -f1 | while read SERVER_NAME; do
			if [ "$CURRENT_SERVER" = "$SERVER_NAME" ]; then
				echo "* $SERVER_NAME"
			else
				echo "  $SERVER_NAME"
			fi
		done
		;;
	stop)
		if [ $# -ne 0 ]; then
			usage
			exit 1
		fi
		if [ -z "$CURRENT_SERVER" ]; then
			echo "No server running."
			exit 0
		fi
		echo "Stopping $CURRENT_SERVER..."
		systemctl --user stop "minecraft@$CURRENT_SERVER"
		;;
	start)
		if [ $# -ne 1 ]; then
			usage
			exit 1
		fi
		if [ ! -f "$SERVER_ROOT/$1/Server Files/ServerStart.sh" ]; then
			echo "No such server: $1"
			exit 1
		fi
		if [ -n "$CURRENT_SERVER" ]; then
			if [ "$CURRENT_SERVER" = "$1" ]; then
				echo "Already running."
				exit 0
			else
				echo "Server $CURRENT_SERVER currently running. Use \`stop\` command first."
				exit 1
			fi
		fi
		systemctl --user start "minecraft@$1"
		echo "Server $1 now starting up."
		;;
	status)
		if [ $# -ne 0 ]; then
			usage
			exit 1
		fi
		if [ -z "$CURRENT_SERVER" ]; then
			echo "No server running."
			exit 1
		fi
		systemctl --user status "minecraft@$CURRENT_SERVER"
		;;
	logs)
		if [ -z "$CURRENT_SERVER" ]; then
			echo "No server running."
			exit 1
		fi
		exec journalctl -q --user -u "minecraft@$CURRENT_SERVER" "$@"
		;;
	bash)
		exec bash -i
		;;
	backup)
		if [ -n "$CURRENT_SERVER" ]; then
			echo "Cannot create backup while server $CURRENT_SERVER is running."
			exit 1
		fi
		cd "$SERVER_ROOT"
		set -x
		git add .
		git commit -m "server backup"
		git remote get-url origin
		git push -f origin master
		set +x
		;;
	*)
		usage
		exit 1
		;;
esac
