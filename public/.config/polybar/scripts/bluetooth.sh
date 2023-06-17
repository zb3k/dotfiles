#!/bin/sh

BT_HEADSET_ID="40:58:99:31:D6:2A"

BT_DISABLED_ICON=󰂲
BT_ENABLED_ICON=󰂯
BT_CONNECTED_ICON=󰂱
BT_HEADSET_ICON=󰋎

COLOR_DANGER="#be5046"
COLOR_ICON="#617b94"
COLOR_MUTED="#4b5263"

# Disabled
if [ $(bluetoothctl show | grep "Powered: yes" | wc -c) -eq 0 ]; then
  echo "%{F$COLOR_DANGER}$BT_DISABLED_ICON%{F-}"
else
  # Enabled 
  if [ $(bluetoothctl info | grep 'Device' | wc -c) -eq 0 ]; then
    echo "%{F$COLOR_ICON}$BT_ENABLED_ICON%{F-}"
  # Connected
  else
    DEVICES=""
    if [ $(bluetoothctl info | grep $BT_HEADSET_ID | wc -c) -gt 0 ]; then
      DEVICES="$DEVICES%{F$COLOR_MUTED}$BT_HEADSET_ICON%{F-}"
    fi
    echo "%{F$COLOR_ICON}$BT_CONNECTED_ICON%{F-}$DEVICES"
  fi
fi

