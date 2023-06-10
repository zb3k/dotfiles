#!/bin/sh
if [ $(bluetoothctl show | grep "Powered: yes" | wc -c) -eq 0 ]
then
  echo "%{F#be5046}󰂲%{F-}"
else
  if [ $(echo info | bluetoothctl | grep 'Device' | wc -c) -eq 0 ]
  then 
    echo "%{F#617b94}󰂯%{F-}"
  fi
  echo "%{F#617b94}󰂱%{F-}"
fi