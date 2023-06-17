#!/bin/sh


KEY="023aa25986fa935635e4586b59204572"
# CITY="Moscow,RU"
UNITS="metric"
SYMBOL="°"

COLOR_ICON="#617b94"
COLOR_MUTED="#5c6370"

ICON_TREND_UP="󰄿"
ICON_TREND_DOWN="󰄼"

API="https://api.openweathermap.org/data/2.5"

# https://openweathermap.org/weather-conditions
get_icon() {
    case $1 in
        # Material design icons
        01d) icon="󰖙";; # clear sky (day)
        01n) icon="󰖔";; # clear sky (night)
        02d) icon="󰖕";; # few clouds (day)
        02n) icon="󰼱";; # few clouds (night)
        03*) icon="󰖐";; # scattered clouds 
        04*) icon="󰖐";; # broken clouds
        09*) icon="󰖖";; # shower rain 
        10*) icon="󰖗";; # rain
        11*) icon="󰖓";; # thunderstorm
        13*) icon="󰖘";; # snow
        50*) icon="󰖑";; # mist
        *) icon="󰖙";
    esac

    echo $icon
}

get_duration() {

    osname=$(uname -s)

    case $osname in
        *BSD) date -r "$1" -u +%H:%M;;
        *) date --date="@$1" -u +%H:%M;;
    esac

}

# Location
if [ -n "$CITY" ]; then
    if [ "$CITY" -eq "$CITY" ] 2>/dev/null; then
        CITY_PARAM="id=$CITY"
    else
        CITY_PARAM="q=$CITY"
    fi

    current=$(curl -sf "$API/weather?appid=$KEY&$CITY_PARAM&units=$UNITS")
    forecast=$(curl -sf "$API/forecast?appid=$KEY&$CITY_PARAM&units=$UNITS&cnt=1")
else
    location=$(curl -sf https://location.services.mozilla.com/v1/geolocate?key=geoclue)

    if [ -n "$location" ]; then
        location_lat="$(echo "$location" | jq '.location.lat')"
        location_lon="$(echo "$location" | jq '.location.lng')"

        current=$(curl -sf "$API/weather?appid=$KEY&lat=$location_lat&lon=$location_lon&units=$UNITS")
        forecast=$(curl -sf "$API/forecast?appid=$KEY&lat=$location_lat&lon=$location_lon&units=$UNITS&cnt=1")
    fi
fi


if [ -n "$current" ] && [ -n "$forecast" ]; then
    current_temp=$(echo "$current" | jq ".main.temp" | cut -d "." -f 1)
    current_icon=$(get_icon $(echo "$current" | jq -r ".weather[0].icon"))

    forecast_temp=$(echo "$forecast" | jq ".list[].main.temp" | cut -d "." -f 1)
    forecast_icon=$(get_icon $(echo "$forecast" | jq -r ".list[].weather[0].icon"))

    city_name=$(echo "$current" | jq -r ".name")

    # Trend icon
    if [ "$current_temp" -gt "$forecast_temp" ]; then
        trend_icon=$ICON_TREND_DOWN
    elif [ "$forecast_temp" -gt "$current_temp" ]; then
        trend_icon=$ICON_TREND_UP
    else
        trend_icon=""
    fi


    # sun_rise=$(echo "$current" | jq ".sys.sunrise")
    # sun_set=$(echo "$current" | jq ".sys.sunset")
    # now=$(date +%s)
    # if [ "$sun_rise" -gt "$now" ]; then
    #     daytime=" $(get_duration "$((sun_rise-now))")"
    # elif [ "$sun_set" -gt "$now" ]; then
    #     daytime=" $(get_duration "$((sun_set-now))")"
    # else
    #     daytime=" $(get_duration "$((sun_rise-now))")"
    # fi
    
    # echo "%{F$COLOR_ICON}$(get_icon "$current_icon")%{F-}$DEVICES $current_temp$SYMBOL  $trend  $(get_icon "$forecast_icon") $forecast_temp$SYMBOL   $daytime"
    echo "%{F$COLOR_ICON}$current_icon%{F-} $current_temp$SYMBOL$trend_icon %{F$COLOR_MUTED}$city_name%{F-}"
fi
