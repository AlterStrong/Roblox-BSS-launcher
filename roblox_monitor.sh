#!/data/data/com.termux/files/usr/bin/bash

# === KONFIGURASI ===
GAME_LINK="roblox://placeId=1537690962/"
PKG_NAME="com.roblox.client"
DISCORD_WEBHOOK="https://discord.com/api/webhooks/1363321007389020200/l6y9LMQzwcFu15uiQfC8XawlcqixNLukLcPoREBXyXYNqK9mFwGRW6qbgNJYmCTi9v_f"
LOG_FILE="$HOME/roblox_log.txt"
PID_FILE="$HOME/.roblox_monitor_pid"

send_discord() {
  curl -s -H "Content-Type: application/json" -X POST \
    -d "{\"content\": \"$1\"}" "$DISCORD_WEBHOOK" > /dev/null
}

open_game() {
  am start -a android.intent.action.VIEW -d "$GAME_LINK"
}

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

is_roblox_open() {
  dumpsys window windows | grep -i "$PKG_NAME" > /dev/null
}

start_monitoring() {
  send_discord ":rocket: Monitoring dimulai! Roblox akan auto-rejoin jika keluar."
  log "Monitoring dimulai."
  counter=0
  while true; do
    if ! is_roblox_open; then
      log "Roblox belum terbuka. Membuka ulang..."
      open_game
      send_discord ":video_game: Roblox tidak aktif. Auto-rejoin dilakukan."
      sleep 10
    fi

    counter=$((counter + 1))
    if [ $((counter % 60)) -eq 0 ]; then
      send_discord ":alarm_clock: Sudah 5 jam sejak monitoring dimulai."
    fi

    sleep 300
  done
}

stop_monitoring() {
  if [ -f "$PID_FILE" ]; then
    kill "$(cat "$PID_FILE")" && rm -f "$PID_FILE"
    send_discord ":stop_sign: Monitoring dihentikan secara manual."
    log "Monitoring dihentikan."
  else
    echo "Monitoring tidak sedang berjalan."
  fi
}

case "$1" in
  start)
    if [ -f "$PID_FILE" ]; then
      echo "Monitoring sudah berjalan."
      exit 1
    fi
    nohup bash roblox_monitor.sh run > /dev/null 2>&1 &
    echo $! > "$PID_FILE"
    echo "Monitoring dimulai."
    ;;
  run)
    start_monitoring
    ;;
  stop)
    stop_monitoring
    ;;
  setup)
    pkg install -y termux-api curl
    termux-setup-storage
    echo "Setup selesai. Jalankan: bash roblox_monitor.sh start"
    ;;
  *)
    echo "Gunakan: bash roblox_monitor.sh {setup|start|stop}"
    ;;
esac
