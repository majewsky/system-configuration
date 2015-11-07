#!/bin/sh
echo $PWD >&2
source ./.env
perl replace-env.pl
