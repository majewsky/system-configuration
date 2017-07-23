#!/bin/bash
#
# This script is called by hookserve(1) when a Github push event is received.
set -euo pipefail

REPO_OWNER="$1"
REPO_NAME="$2"
BRANCH="$3"
COMMIT_ID="$4"

# a line of output for the log
echo "Branch ${BRANCH} of repo ${REPO_OWNER}/${REPO_NAME} was updated to ${COMMIT_ID}"

case "${REPO_OWNER}/${REPO_NAME}/${BRANCH}" in
    majewsky/blog-data/master)
        sudo systemctl start blog-update
        ;;
    vt6/vt6/master)
        sudo systemctl start vt6-update
        ;;
    *)
        echo "Ignoring this event because no action is configured"
        ;;
esac
