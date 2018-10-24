#!/bin/bash
set -euo pipefail

REPO_URL=github.com/majewsky/devenv
REPO_SHORT_URL=gh:majewsky/devenv
export GOPATH=/x

# clone devenv repo into the (not yet populated) repo tree
REPO_PATH="${GOPATH}/src/${REPO_URL}"
if [ ! -d "${REPO_PATH}/.git" ]; then
    git clone "https://${REPO_URL}" "${REPO_PATH}"
    # this remote URL will become valid as soon as the devenv is installed
    git -C "${REPO_PATH}" remote set-url origin "${REPO_SHORT_URL}"
fi

# run setup script for devenv
"${REPO_PATH}/install.sh"

# add the devenv repo to the rtree index (if not done yet)
rtree get "${REPO_SHORT_URL}" > /dev/null
