#!/usr/bin/env bash
set -euo pipefail

LOCK="${XDG_RUNTIME_DIR:-/tmp}/battery_loop.lock"

exec 9>"$LOCK"
flock -n 9 || exit 0

# give mako / dbus a moment
sleep 2

while true; do
  ~/.config/hypr/battery_notify.sh || true
  sleep 25
done

