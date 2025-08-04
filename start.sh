#!/data/data/com.termux/files/usr/bin/bash

cd "$(dirname "$0")"

FILE="roblox_monitor.sh"
URL="https://raw.githubusercontent.com/AlterStrong/Roblox-BSS-launcher/main/$FILE"

# Download jika file belum ada
if [ ! -f "$FILE" ]; then
  echo "[INFO] Mengunduh $FILE..."
  curl -s -O "$URL" || { echo "Gagal mengunduh $FILE"; exit 1; }
  chmod +x "$FILE"
fi

# Jalankan skrip
bash "$FILE" start
