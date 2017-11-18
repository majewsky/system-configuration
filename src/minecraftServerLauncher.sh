#!/bin/bash

# CONFDIR="$HOME/.minecraftServerLauncher/"
# if [ ! -d "$CONFDIR" ]; then
# 	mkdir "$CONFDIR"
# fi

CONFFILE="$HOME/.minecraftServerLauncherrc"
if [ -f "$CONFFILE" ]; then
	. "$CONFFILE"
else
	SERVERROOT="$HOME/minecraft"
fi

STATEFILE="$XDG_RUNTIME_DIR/minecraftServerState"
LOCKFILE="$XDG_RUNTIME_DIR/minecraftServerLock"

# always call this when exiting after a lock was aquired to ensure it is
# cleaned-up properly
exitHandler()
{
	rm "$LOCKFILE"
	flock -u 9
	# echo EXIT
	if [ -z "$1" ]; then
		exit 0
	else
		exit $1 || exit 1
	fi
}

showAvail()
{
	echo "Available Servers:"
	ls "$SERVERROOT"
}

lock()
{
	exec 9> "$LOCKFILE"
	if ! flock -n 9 ; then
		echo "Locked by other process."
		exit 1
	fi
}

getState()
{
	if [ ! -f "$STATEFILE" ]; then
		CURRENTSERVER=""
	else
		CURRENTSERVER=$( cat "$STATEFILE" )
		set $CURRENTSERVER
		CS_NAME=$1
		CS_PID=$2
	fi
}

trap exitHandler SIGINT
trap exitHandler SIGTERM

if [ ! -z $SSH_ORIGINAL_COMMAND ]; then
	set $SSH_ORIGINAL_COMMAND
fi
CMD=$1
shift
ARGS=$@

getState

if [ -z "$CURRENTSERVER" ]; then
	echo "No Server running."
else
	echo "Currently running server: $CURRENTSERVER"
fi

showAvail

CMDS_HELP="Available commands: ( stop ) ( start [servername] ) ( logs )"
if [ -z "$CMD" ]; then
	echo "$CMDS_HELP"
	exit 0
fi

case "$CMD" in
	stop)
		if [ "$ARGS" != "-f" ]; then
			lock
		fi
		getState
		if [ -z "$CURRENTSERVER" ]; then
			echo "stop: No server running."
			exitHandler 1
		fi
		echo "stop Shutting down server $CURRENTSERVER"
		kill -s SIGTERM $CS_PID
		rm $STATEFILE
		CURRENTSERVER=""
		;;
	start)
		lock
		getState
		S_NAME="$ARGS"
		if [ ! -d "$SERVERROOT/$S_NAME" ]; then
			echo Invalid server name $S_NAME
			showAvail
			exitHandler 1
		fi
		if [ ! -z "$CURRENTSERVER" ]; then
			if [ "$CS_NAME" = "$S_NAME" ]; then
				echo Server $S_NAME slready running.
				exitHandler 0
			else
				echo Shutting down running server.
				kill -s SIGTERM $CS_PID
			fi
		fi
		cd "$SERVERROOT/$S_NAME/Server Files/" || exit 1
		/bin/sh "ServerStart.sh" >& log  &
		CS_PID=$!
		CS_NAME=$S_NAME
		CURRENTSERVER="$CS_NAME $CS_PID"
		echo "start: $CURRENTSERVER"
		echo "$CURRENTSERVER" > "$STATEFILE"
		;;
	logs)
		if [ -z "$CURRENTSERVER" ]; then
			echo "No Server running"
		else
			tail -f "$SERVERROOT/$CS_NAME/Server Files/log"
		fi
		;;
	*)
		echo "Invalid command: $CMD"
		echo "$CMDS_HELP"
		exit 1
		;;
esac

exitHandler 0
