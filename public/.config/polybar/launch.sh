#!/usr/bin/bash

# Terminate already running bar instances
# killall -q polybar

# while pgrep -u $UID -x polybar >/dev/null; do sleep 5; done
pkill polybar
polybar -c ~/.config/polybar/polybar.ini --reload main
