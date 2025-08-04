#!/data/data/com.termux/files/usr/bin/bash

# === KONFIGURASI ===
GAME_LINK="roblox://placeId=1537690962"
PKG_NAME="com.roblox.client"
LOG_FILE="$HOME/roblox_log.txt"
DISCORD_WEBHOOK="https://discord.com/api/webhooks/1363321007389020200/l6y9LMQzwcFu15uiQfC8XawlcqixNLukLcPoREBXyXYNqK9mFwGRW6qbgNJYmCTi9v_f"

# === FUNGSI UMUM ===
log() {
  echo "[$(date '+%F %T')] $1" >> "$LOG_FILE"
}

send_discord() {
  message="$1"
  curl -s -X POST -H "Content-Type: application/json" \
    -d "{\"content\": \"@everyone $message\"}" "$DISCORD_WEBHOOK" > /dev/null
}

# === FUNGSI MONITOR ===
start_monitoring() {
  log "Memulai monitoring Roblox..."
  echo "Monitoring Roblox dimulai..."

  last_status="unknown"
  uptime_counter=0
  interval_check=300  # 5 menit = 300 detik
  interval_uptime=14400  # 2 jam = 7200 detik → karena check setiap 5 menit, berarti 14400 / 300 = 48 kali
  tick=0

  while true; do
    app_running=$(ps | grep "$PKG_NAME" | grep -v "grep" > /dev/null && echo "yes" || echo "no")

    if [ "$app_running" = "yes" ] && [ "$last_status" != "running" ]; then
      log "Roblox telah dibuka"
      send_discord "Roblox telah dibuka."
      last_status="running"
    elif [ "$app_running" = "no" ] && [ "$last_status" != "closed" ]; then
      log "Roblox telah ditutup"
      send_discord "Roblox telah ditutup."
      last_status="closed"
    fi

    tick=$((tick + 1))
    if [ $((tick % 24)) -eq 0 ]; then  # 2 jam sekali (5 menit × 24 = 120 menit = 2 jam)
      uptime_counter=$((uptime_counter + 2))
      send_discord "Uptime: ${uptime_counter} jam"
    fi

    sleep $interval_check
  done
}

# === MAIN ===
case "$1" in
  start)
    start_monitoring
    ;;
  setup)
    echo "Menjalankan Roblox untuk pertama kali..."
    am start -a android.intent.action.VIEW -d "$GAME_LINK"
    ;;
  *)
    echo "Gunakan: bash roblox_monitor.sh start | setup"
    ;;
esac
