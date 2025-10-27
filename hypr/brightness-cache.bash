#!/usr/bin/env bash
# ~/.config/hypr/brightness-cache.sh
# Generates monitor -> bus mapping for faster use

CACHE_FILE="$HOME/.cache/monitor_buses"
: > "$CACHE_FILE"  # clear previous cache

ddcutil detect 2>/dev/null | awk '
BEGIN {bus=""; conn=""}
/I2C bus:/ { bus=$3; gsub(/.*i2c-/, "", bus) }
/DRM_connector:/ { conn=$2; gsub(/[[:space:]]/, "", conn) }
bus!="" && conn!="" { print conn " " bus; bus=""; conn="" }
' > "$CACHE_FILE"

