#!/bin/bash

set -e
set -o errexit

rm -f /tmp/.X0-lock

Xvfb :0 -screen 0 1920x1080x16 &
sleep 1

x11vnc -rfbport $VNC_PORT -display :0 -usepw -forever &

# Start this last and directly, so that if the gateway terminates for any reason, the container will stop as well.
# Retry behavior can be implemented by re-running the container.
/opt/ibc/scripts/ibcstart.sh $(ls ~/Jts/) "--mode=$TRADING_MODE" "--user=$TWSUSERID" "--pw=$TWSPASSWORD"
