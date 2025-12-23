#!/bin/bash

value=$(pactl get-sink-volume @DEFAULT_SINK@ | sed -n 's/.* \([0-9]\+\)%.*/\1/p')

if [ "$value" -eq 0 ]; then
  pactl set-sink-mute @DEFAULT_SINK@ 1
else
  pactl set-sink-mute @DEFAULT_SINK@ 0
  pactl set-sink-volume @DEFAULT_SINK@ -5%

  value=$(pactl get-sink-volume @DEFAULT_SINK@ | sed -n 's/.* \([0-9]\+\)%.*/\1/p')
  if [ "$value" -eq 0 ]; then
    pactl set-sink-mute @DEFAULT_SINK@ 1
  fi
fi
