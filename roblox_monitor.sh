#!/data/data/com.termux/files/usr/bin/bash

# === KONFIGURASI ===
GAME_LINK="roblox://placeId=1537690962/"
PKG_NAME="com.roblox.client"
DISCORD_WEBHOOK="https://discord.com/api/webhooks/1363321007389020200/l6y9LMQzwcFu15uiQfC8XawlcqixNLukLcPoREBXyXYNqK9mFwGRW6qbgNJYmCTi9v_f"
LOG_FILE="$HOME/roblox_log.txt"

# === FUNGSI ===
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

send_discord() {
  curl -s -X POST -H "Content-Type: application/json" \
    -d "{\"content\": \"@everyone $1\"}" "$DISCORD_WEBHOOK" > /dev/null
}

start_monitoring() {
  log "Monitoring dimulai..."
  send_discord "📡 Monitoring dimulai!"

  local is_open=0
  local counter=0
  local reminder_interval=24  # 2 jam (24 × 5 menit)
  local uptime_hours=0

  while true; do
    if dumpsys window windows | grep -iq "$PKG_NAME"; then
      if [ "$is_open" -eq 0 ]; then
        log "Roblox baru saja dibuka."
        send_discord "🟢 Roblox baru saja dibuka!"
        is_open=1
        counter=0
        uptime_hours=0
      fi
    else
      if [ "$is_open" -eq 1 ]; then
        log "Roblox ditutup."
        send_discord "🔴 Roblox baru saja ditutup."
        is_open=0
        counter=0
        uptime_hours=0
      fi
    fi

    if [ "$is_open" -eq 1 ]; then
      counter=$((counter + 1))
      if [ "$counter" -ge "$reminder_interval" ]; then
        uptime_hours=$((uptime_hours + 2))
        send_discord "⏰ Reminder: Roblox masih terbuka. Uptime: ${uptime_hours} jam."
        counter=0
      fi
    fi

    sleep 300  # 5 menit
  done
}

# === MAIN ===
case "$1" in
  start)
    start_monitoring
    ;;
  setup)
    echo "📥 Menyiapkan dependensi..."
    pkg update -y
    pkg install -y termux-api curl grep
    chmod +x "$HOME/roblox_monitor.sh"
    echo "✅ Setup selesai. Gunakan: bash start.sh untuk memulai."
    ;;
  *)
    echo "Gunakan: bash roblox_monitor.sh [setup|start]"
    ;;
esac
