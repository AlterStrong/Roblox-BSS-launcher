#!/data/data/com.termux/files/usr/bin/bash

# === KONFIGURASI ===
GAME_LINK="roblox://placeId=1537690962"
PKG_NAME="com.roblox.client"
DISCORD_WEBHOOK="https://discord.com/api/webhooks/1363321007389020200/l6y9LMQzwcFu15uiQfC8XawlcqixNLukLcPoREBXyXYNqK9mFwGRW6qbgNJYmCTi9v_f"
LOG_FILE="$HOME/roblox_log.txt"
INTERVAL=300             # 5 menit
REMINDER_INTERVAL=7200   # 2 jam

# === VARIABEL RUNTIME ===
was_open=false
start_time=$(date +%s)
last_reminder=0

# === FUNGSI ===

send_discord() {
  local message="$1"
  curl -s -X POST -H "Content-Type: application/json" \
    -d "{\"content\": \"@everyone $message\"}" \
    "$DISCORD_WEBHOOK" > /dev/null
}

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

check_roblox_open() {
  dumpsys activity | grep -i "mResumedActivity" | grep -iq "$PKG_NAME"
}

get_uptime_string() {
  local now=$(date +%s)
  local uptime=$((now - start_time))
  local hours=$((uptime / 3600))
  local minutes=$(( (uptime % 3600) / 60 ))
  echo "Uptime: ${hours} jam ${minutes} menit"
}

# === MODE SETUP ===
if [[ "$1" == "setup" ]]; then
  echo "Melakukan setup awal..."
  pkg update -y && pkg install -y termux-api curl
  chmod +x "$HOME/roblox_monitor.sh"
  termux-setup-storage
  echo "Setup selesai. Jalankan: bash roblox_monitor.sh start"
  exit 0
fi

# === MODE START ===
if [[ "$1" == "start" ]]; then
  echo "Monitoring dimulai..."

  while true; do
    if check_roblox_open; then
      if ! $was_open; then
        was_open=true
        send_discord "Roblox telah dibuka."
        log "Roblox terbuka."
      fi
    else
      if $was_open; then
        was_open=false
        send_discord "Roblox telah ditutup."
        log "Roblox ditutup."
      fi
    fi

    now=$(date +%s)
    if (( now - last_reminder >= REMINDER_INTERVAL )); then
      last_reminder=$now
      uptime_msg=$(get_uptime_string)
      send_discord "Reminder: $uptime_msg"
      log "Reminder dikirim: $uptime_msg"
    fi

    sleep $INTERVAL
  done
fi

# === MODE STOP ===
if [[ "$1" == "stop" ]]; then
  echo "Gunakan shortcut stop.sh atau hentikan Termux."
  exit 0
fi

# === DEFAULT ===
echo "Gunakan perintah:"
echo "  bash roblox_monitor.sh setup"
echo "  bash roblox_monitor.sh start"
