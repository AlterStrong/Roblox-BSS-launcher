#!/data/data/com.termux/files/usr/bin/bash

# === KONFIGURASI ===
GAME_LINK="roblox://placeId=1537690962"
PKG_NAME="com.roblox.client"
SCRIPT_PATH="$(realpath "$0")"
SHORTCUT_NAME="Start Roblox Monitor"

# === FUNGSI ===

is_roblox_running() {
  pidof "$PKG_NAME" > /dev/null 2>&1
  return $?
}

open_roblox() {
  termux-open-url "$GAME_LINK"
}

monitor_loop() {
  echo "Memulai pemantauan Roblox..."
  while true; do
    if ! is_roblox_running; then
      echo "Roblox tidak berjalan. Membuka kembali..."
      open_roblox
    else
      echo "Roblox masih berjalan."
    fi
    sleep 300  # Cek setiap 5 menit
  done
}

buat_shortcut() {
  termux-create-shortcut \
    --name "$SHORTCUT_NAME" \
    --shortcut-id "roblox-monitor" \
    --icon "🌐" \
    "$SCRIPT_PATH run"
}

setup() {
  echo "Meminta semua izin yang dibutuhkan..."
  termux-setup-storage
  termux-toast "Meminta izin selesai"

  echo "Membuat shortcut widget untuk menjalankan monitoring..."
  buat_shortcut
  echo "Selesai. Gunakan widget 'Start Roblox Monitor' untuk memulai."
}

# === MODE ===

case "$1" in
  setup)
    setup
    ;;
  run)
    monitor_loop
    ;;
  *)
    echo "Gunakan salah satu:"
    echo "  bash roblox_monitor.sh setup  # untuk setup awal"
    echo "  bash roblox_monitor.sh run    # untuk menjalankan monitoring"
    ;;
esac
