#!/bin/bash

cd /home/app/pinw

# Use last as a file stating when pinw has been restart for the last time
# If there is a newer commit on master, restart the app
LAST=/tmp/last-restart-pinw
test -f "${LAST}" || touch  "${LAST}"
git pull --all
test .git/ref/heads/master -nt "${LAST}" && passenger-config restart-app /home/app/pinw && touch "${LAST}"
