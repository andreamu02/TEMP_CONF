#!/usr/bin/env bash
# battery-notify.sh
# Send one-shot notifications when battery crosses thresholds.
# Works with BAT0 and BAT1 (if present).

set -euo pipefail

# --- Configuration ---
WARN=30
CRITICAL=15
T6=8
T5=6
STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/battery_notify_${USER}.state"

# Helper to read a file if exists, otherwise return empty
read_if_exists() {
  local f="$1"
  [[ -r "$f" ]] && cat "$f" || echo ""
}

# Read battery info safely (handle single-battery laptops)
BAT0_DIR="/sys/class/power_supply/BAT0"
BAT1_DIR="/sys/class/power_supply/BAT1"

BAT_STATUS0=$(read_if_exists "$BAT0_DIR/status")

BAT_STATUS1=$(read_if_exists "$BAT1_DIR/status")

# Normalize empty values to 0
UP_OUT=$(upower -i /org/freedesktop/UPower/devices/DisplayDevice 2>/dev/null || true)

BAT_PERCENT=$(awk -F: '/percentage/ {gsub(/%| /,"",$2); print int($2); exit}' <<<"$UP_OUT")

BAT_STATUS0=${BAT_STATUS0:-}
BAT_STATUS1=${BAT_STATUS1:-}

# Determine overall status: Discharging if any battery is discharging
BAT_STATUS=""
if [[ "$BAT_STATUS0" == "Discharging" ]] || [[ "$BAT_STATUS1" == "Discharging" ]]; then
  BAT_STATUS="Discharging"
fi

# Ensure state file exists
mkdir -p "$(dirname "$STATE_FILE")"
touch "$STATE_FILE"

# Append a tag to state file if not present
mark_notified() {
  local tag="$1"
  grep -qxF "$tag" "$STATE_FILE" 2>/dev/null || echo "$tag" >> "$STATE_FILE"
}

# Check whether a tag is already recorded
is_notified() {
  local tag="$1"
  grep -qxF "$tag" "$STATE_FILE" 2>/dev/null
}

# Reset state (called when charging)
reset_state() {
  rm -f "$STATE_FILE"
  touch "$STATE_FILE"
}

clean() {
  makoctl list 2>/dev/null \
    | awk '/^Notification [0-9]+:/{match($0,/Notification ([0-9]+):/,m); id=m[1]}
           /^\s*App name: (battery-warn|battery-critical|battery-urgent|battery-end)\s*$/ {print id}' \
    | xargs -r -n1 makoctl dismiss -n 2>/dev/null || true
}

# Notification functions
notify_warn() {
  clean
  notify-send -u critical -a "battery-warn" -i ~/.local/share/icons/battery-030.png -h "string:x-canonical-private-synchronous:battery" "Low Battery" "Battery at $BAT_PERCENT%"
}

notify_critical() {
  clean
  # dim on critical
  brightnessctl s 30% 2>/dev/null || true
  notify-send -u critical -a "battery-critical" -i ~/.local/share/icons/battery-010.png -h "string:x-canonical-private-synchronous:battery" "Low Battery" "Battery at $BAT_PERCENT%"
}

notify_6() {
  clean
  notify-send -u critical -a "battery-urgent" -i ~/.local/share/icons/battery-empty.png -h "string:x-canonical-private-synchronous:battery" "Low Battery" "Battery at $BAT_PERCENT%"
}
notify_5() {
  clean
  notify-send -u critical -a "battery-end" -i ~/.local/share/icons/battery-end.png -h "string:x-canonical-private-synchronous:battery" "Low Battery - Recharge Now" "Laptop will power off soon"
}

# Main logic
if [[ "$BAT_STATUS" != "Discharging" ]]; then
  # Charging or full: reset so we'll notify again on next discharge
  reset_state
  # restore brightness if you use brightnessctl
  brightnessctl -r >/dev/null 2>&1 || true
  exit 0
fi

# At this point battery is discharging. Send notifications only when we
# *first* cross each threshold (no duplicates).
#
# If the battery jumped across several thresholds in one check (rare),
# this will send each notification that hasn't yet been sent.

# WARN (60)
if (( BAT_PERCENT <= WARN )); then
  if ! is_notified "WARN"; then
    notify_warn
    mark_notified "WARN"
  fi
fi

# CRITICAL (48)
if (( BAT_PERCENT <= CRITICAL )); then
  if ! is_notified "CRITICAL"; then
    notify_critical
    mark_notified "CRITICAL"
  fi
fi

# 6%
if (( BAT_PERCENT <= T6 )); then
  if ! is_notified "T6"; then
    notify_6
    mark_notified "T6"
  fi
fi

# 5%
if (( BAT_PERCENT <= T5 )); then
  if ! is_notified "T5"; then
    notify_5
    mark_notified "T5"
  fi
fi

# End
exit 0

