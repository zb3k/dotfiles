#!/bin/sh

# Other common locations for CPU temperature information
# /proc/acpi/thermal_zone/THRM/temperature
# /sys/class/thermal/thermal_zone*/temp
# /sys/class/thermal/cooling_device*/temp
# /sys/devices/platform/f71882fg.1152/temp*_input
# /sys/devices/platform/coretemp.0/hwmon/hwmon*/temp*_input
# paste <(cat /sys/devices/platform/coretemp.0/hwmon/hwmon*/temp*_label) <(cat /sys/devices/platform/coretemp.0/hwmon/hwmon*/temp*_input) | column -s $'\t' -t | sed 's/\(.\)..$/.\1°C/'


action=$1



if [[ $action = '' ]]; then
    temp=$(sensors | grep "Package" | tr -s ' ' | cut -d' ' -f4 | cut -c2- | sed 's/\..*$//')
    # temp=$(cat /sys/devices/platform/coretemp.0/hwmon/hwmon1/temp1_input | sed 's/\(.\)..$//')
    # temp sensors | grep "Package" | tr -s ' ' | cut -d' ' -f4
    echo "${temp}"
    # echo $(liquidctl status | grep speed | tr -s ' ' | cut -d ' ' -f 5)

    if [[ "$temp" -lt "50" ]]; then
        liquidctl set sync speed 30
    else
        if [[ "$temp" -lt "55" ]]; then
            liquidctl set sync speed 40
        fi;
        if [[ "$temp" -lt "60" ]]; then
            liquidctl set sync speed 50
        fi;
        if [[ "$temp" -lt "65" ]]; then
            liquidctl set sync speed 60
        fi;
        if [[ "$temp" -lt "70" ]]; then
            liquidctl set sync speed 70
        else
            liquidctl set sync speed 100
        fi;
    fi;
fi;