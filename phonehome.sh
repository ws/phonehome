#!/bin/bash

# Collects some very basic info about my laptop and POSTS it back to my home server
# 99% for home automation, 1% for theft tracking
#
# Usage: $ ./phonehome.sh https://example.com/collect
#
# I have it setup to run every 10 minutes and every time I unsleep my Mac

HOME_URL="$1"

get_location () {
    # https://github.com/fulldecent/corelocationcli
    # Make sure you enable it manually in Location Privacy settings in MacOS
    if command -v corelocationcli > /dev/null; then
        echo "$(corelocationcli)";
    else
        echo "Unknown";
    fi
}

timestamp=$(date +"%s")
ssid="$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | sed -e "s/^  *SSID: //p" -e d)";
battery_percent="$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)";
power_source="$(pmset -g batt | awk -F"['|']" '{print $2}')";
location="$(get_location)";
local_ip="$(ifconfig | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}')";

generate_post_data()
{
  cat <<EOF
    {
        "time": $timestamp,
        "ssid": "$ssid",
        "battery_percent": $battery_percent,
        "power_source": "$power_source",
        "location": "$location",
        "local_ip": "$local_ip"
    }
EOF
}

curl -H "Content-Type:application/json" -X POST --data "$(generate_post_data)" $HOME_URL