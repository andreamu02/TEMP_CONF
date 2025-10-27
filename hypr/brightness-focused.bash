#!/usr/bin/env bash
# ~/.config/hypr/brightness-focused
# Usage: brightness-focused up|down
# Increases/decreases brightness of the currently focused monitor by 5%, never below 5%.

# set -euo pipefail
STEP=5
DDC=/usr/bin/ddcutil
MIN=5
MAX=100
CACHE="$HOME/.cache/monitor_buses"

if [ $# -ne 1 ]; then
  echo "Usage: $0 up|down"
  exit 2
fi

ACTION="$1"

if [ "$ACTION" != "up" ] && [ "$ACTION" != "down" ]; then
  echo "Invalid action: $ACTION"
  exit 2
fi

FOCUS=$(hyprctl -j monitors | jq -r '.[] | select(.focused==true) | .name')
[ -z "$FOCUS" ] && FOCUS=$(hyprctl -j monitors | jq -r '.[0].name')

BUS=$(grep -i "$FOCUS" "$CACHE" | awk '{print $2}')
[ -z "$BUS" ] && BUS=$(awk '{print $2; exit}' "$CACHE")  # fallback first bus


CUR=$($DDC --bus="$BUS" getvcp 10 2>/dev/null | sed -n 's/.*current value *= *\([0-9]*\).*/\1/p')
CUR=${CUR:-50}

# calculate new value
if [[ "$ACTION" == "up" ]]; then
    NEW=$((CUR + STEP))
    [ "$NEW" -gt "$MAX" ] && NEW=$MAX
else
    NEW=$((CUR - STEP))
    [ "$NEW" -lt "$MIN" ] && NEW=$MIN
fi

# set brightness
$DDC --bus="$BUS" setvcp 10 "$NEW"
