#!/bin/sh

action=$1

duty_value_file=~/.config/polybar/scripts/liquidctl_duty.txt

if [[ $action = 'duty' ]]; then
    echo "$(cat $duty_value_file)%"
fi;

if [[ $action = 'speed' ]]; then
    echo $(liquidctl status | grep speed | tr -s ' ' | cut -d ' ' -f 5)
fi;

if [[ $action = 'increment' ]] || [[ $action = 'decrement' ]]; then
    current=50
    if [[ -f "$duty_value_file" ]]; then
        current=$(cat $duty_value_file)
    else
        $(echo $current > $duty_value_file)
    fi

    if [[ $action = 'increment' ]]; then
        new_duty=$((current + 5))
    else
        new_duty=$((current - 5))
    fi;
    
    if [ "$new_duty" -gt "20" ] && [ "$new_duty" -lt "101" ]; then
        $(echo $new_duty > $duty_value_file)
        $(liquidctl set sync speed $new_duty)
    fi;
    
    polybar-msg hook liquidctl 1
fi;
