#!/bin/sh
set -e
if [ ! -d /home/stefan.devenv/repo/.git ]; then
    git clone git://anongit.kde.org/scratch/majewsky/devenv.git /home/stefan.devenv/repo
fi
cd /home/stefan.devenv/repo
./setup.sh install-core
