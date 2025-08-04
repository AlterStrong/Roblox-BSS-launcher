#!/data/data/com.termux/files/usr/bin/bash

# === Setup awal ===
pkg update -y
pkg install -y curl termux-api

cd ~
rm -f roblox_monitor.sh start.sh stop.sh

# Unduh ulang semua file dari GitHub
curl -Lo roblox_monitor.sh https://raw.githubusercontent.com/AlterStrong/Roblox-BSS-launcher/main/roblox_monitor.sh
curl -Lo start.sh https://raw.githubusercontent.com/AlterStrong/Roblox-BSS-launcher/main/start.sh
curl -Lo stop.sh https://raw.githubusercontent.com/AlterStrong/Roblox-BSS-launcher/main/stop.sh

chmod +x roblox_monitor.sh start.sh stop.sh

echo "✅ Instalasi selesai. Jalankan: bash roblox_monitor.sh setup"
