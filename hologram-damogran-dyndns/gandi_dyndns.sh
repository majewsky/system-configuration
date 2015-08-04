#!/bin/sh

# The Python script can only find its config in its current working directory.
cd /etc/gandi_dyndns
python2 /usr/lib/gandi_dyndns.py
