#!/data/data/com.termux/files/usr/bin/bash

pkg update -y
pkg install -y curl termux-api git
termux-setup-storage

REPO="https://raw.githubusercontent.com/AlterStrong/Roblox-BSS-launcher/main"

curl -O $REPO/roblox_monitor.sh
curl -O $REPO/start.sh
curl -O $REPO/stop.sh

chmod +x roblox_monitor.sh start.sh stop.sh

echo -e "\n✅ Semua file berhasil diunduh. Gunakan perintah berikut untuk memulai:"
echo "  bash roblox_monitor.sh setup"
echo "  bash start.sh"
