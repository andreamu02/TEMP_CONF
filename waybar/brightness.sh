#!/usr/bin/env bash
# Show brightness for the focused monitor (5-100)
CACHE="$HOME/.cache/monitor_buses"
FOCUS=$(hyprctl activewindow -j | jq -r '.monitor')
BUS=$(grep "^$FOCUS " "$CACHE" | awk '{print $2}')

if [ -z "$BUS" ]; then
  echo "N/A"
  exit 0
fi

cur=$(ddcutil --bus="$BUS" getvcp 10 2>/dev/null | awk -F= '/current value/ {gsub(/ /,"",$2); print $2}' | awk -F, '{print $1}')
[ -z "$cur" ] && cur="N/A"
echo "$cur%"

