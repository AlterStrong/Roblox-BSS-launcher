#!/data/data/com.termux/files/usr/bin/bash
cd $HOME
rm -rf Roblox-BSS-launcher
git clone https://github.com/AlterStrong/Roblox-BSS-launcher
cd Roblox-BSS-launcher
cp roblox_monitor.sh start.sh stop.sh ~
chmod +x ~/roblox_monitor.sh ~/start.sh ~/stop.sh
echo "✅ Instalasi selesai. Jalankan:"
echo "bash roblox_monitor.sh setup"
