#!/bin/bash
# Battery notifier for Hyprland
# Sends notifications and dims screen when battery is low

# Configure thresholds
WARN=30
CRITICAL=15
MONITOR="eDP-1"   # Change if your laptop monitor is named differently

# Get battery info
BAT_PERCENT=$(cat /sys/class/power_supply/BAT0/capacity)
BAT_STATUS=$(cat /sys/class/power_supply/BAT0/status) # Charging / Discharging

# Only act when discharging
if [[ "$BAT_STATUS" == "Discharging" ]]; then
    if (( BAT_PERCENT <= CRITICAL )); then
        # Dim the screen
        hyprctl keyword monitor $MONITOR brightness 0.3
        # Critical notification
        notify-send -u critical "Battery Low" "Battery at ${BAT_PERCENT}%! Plug in immediately!"
    elif (( BAT_PERCENT <= WARN )); then
        #notify-send -u normal "Battery Warning" "Battery at ${BAT_PERCENT}%"
    fi
else
    # If charging, restore normal brightness
    hyprctl keyword monitor $MONITOR brightness 0.7
fi

