#!/usr/bin/bash
set -e
WEATHERCSV="$(curl -s --connect-timeout 10 http://nginx:8001/weather/weather.csv)"
weatherArray=(${WEATHERCSV//,/ })
curl -s -o "/home/tulth/.xmonad/icon/${weatherArray[0]}" "http://nginx:8001/weather/${weatherArray[0]}"
result=""
result+=" <icon=${weatherArray[0]}/>"
echo $result
