FAN_NUMBER=$1
FAN_STATUS=''
FAN_MODE=''
FAN_DUTY=0
FAN_RPM=0

function readFanStatus(){
    FAN_STATUS=$(liquidctl status -n 0 --json | jq -r ".[] | .status[] | select(.key | contains(\"Fan $FAN_NUMBER\")) | .value | if type==\"string\" then . else .|round end" | tr '\n' ' ')
    FAN_MODE=$(cut -d' ' -f1<<<"$FAN_STATUS")
    FAN_DUTY=$(cut -d' ' -f2<<<"$FAN_STATUS")
    FAN_RPM=$(cut -d' ' -f3<<<"$FAN_STATUS")
}

if (($FAN_NUMBER > 0)); then
    readFanStatus

    NEW_FAN_DUTY=0

    if [ "$2" == "set" ]; then
        NEW_FAN_DUTY=$3
    else
        INCREMENT_VALUE=$3
        if [ "$2" == "inc" ]; then
            NEW_FAN_DUTY=$((FAN_DUTY+INCREMENT_VALUE))
        fi
        if [ "$2" == "dec" ]; then
            NEW_FAN_DUTY=$((FAN_DUTY-INCREMENT_VALUE))
        fi
    fi

    if (($NEW_FAN_DUTY > 0 && $NEW_FAN_DUTY <= 100)); then
        FAN_DUTY=$NEW_FAN_DUTY
        liquidctl -n0 set "fan$FAN_NUMBER" speed $NEW_FAN_DUTY
    fi


    echo "$FAN_DUTY%"

fi;