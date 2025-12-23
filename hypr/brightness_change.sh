#!/usr/bin/env bash

sign=$1

if [ "$sign" = "plus" ]; then  
  brightnessctl set +5%
elif [ "$sign" = "minus" ]; then
  brightness_control
else
  echo -e "Error: missing argument\nUsage: brightness_control [plus/minus]" >&2
  exit 1
fi
MAX=$(brightnessctl m)
value=$(brightnessctl g)

value=$((value*100/MAX + 1))
if [[ "$value" -gt 100 ]]; then value=100; fi

SYNC="string:x-canonical-private-synchronous:brightness"

pactl set-sink-mute @DEFAULT_SINK@ 0
icon=/usr/share/icons/breeze-dark/status/24/audio-volume-high-danger.svg 


if [ "$value" -lt 50 ]; then
  icon="/usr/share/icons/breeze-dark/actions/24/low-brightness-symbolic.svg"
else
  icon="/usr/share/icons/breeze-dark/actions/24/high-brightness-symbolic.svg"
fi

notify-send -a "brightness-control" -i "$icon" --hint=int:value:"$value" -h "$SYNC" "$value%  " ""

