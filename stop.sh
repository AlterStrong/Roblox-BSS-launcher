#!/data/data/com.termux/files/usr/bin/bash

cd "$(dirname "$0")"

FILE="roblox_monitor.sh"
if [ -f "$FILE" ]; then
  bash "$FILE" stop
else
  echo "[ERROR] File roblox_monitor.sh tidak ditemukan!"
fi
