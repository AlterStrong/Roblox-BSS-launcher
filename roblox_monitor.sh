#!/data/data/com.termux/files/usr/bin/bash

# === KONFIGURASI ===
GAME_LINK="roblox://placeId=1537690962"
PKG_NAME="com.roblox.client"
DISCORD_WEBHOOK="https://discord.com/api/webhooks/1363321007389020200/l6y9LMQzwcFu15uiQfC8XawlcqixNLukLcPoREBXyXYNqK9mFwGRW6qbgNJYmCTi9v_f"
LOG_FILE="$HOME/roblox_log.txt"
INTERVAL=300 # 5 menit (dalam detik)
REMINDER_INTERVAL=14400 # 2 jam (dalam detik)

# === VARIABEL RUNTIME ===
monitoring=true
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

open_roblox() {
  am start -a android.intent.action.VIEW -d "$GAME_LINK"
  log "Roblox dibuka melalui link."
}

check_roblox_open() {
  dumpsys activity | grep -i "mResumedActivity" | grep -iq "$PKG_NAME"
}

get_uptime_string() {
  local now=$(date +%s)
  local uptime_seconds=$((now - start_time))
  local hours=$((uptime_seconds / 3600))
  local minutes=$(((uptime_seconds % 3600) / 60))
  echo "Uptime: ${hours} jam ${minutes} menit"
}

# === MODE SETUP ===
if [[ "$1" == "setup" ]]; then
  echo "Melakukan setup pertama kali..."
  pkg update -y && pkg install -y termux-api curl
  termux-setup-storage
  chmod +x "$HOME/roblox_monitor.sh"
  echo "Setup selesai. Jalankan 'bash roblox_monitor.sh start'"
  exit 0
fi

# === MODE START ===
if [[ "$1" == "start" ]]; then
  echo "Monitoring dimulai..."

  while $monitoring; do
    if check_roblox_open; then
      if ! $was_open; then
        was_open=true
        send_discord "Roblox telah dibuka."
        log "Roblox terdeteksi terbuka."
      fi
    else
      if $was_open; then
        was_open=false
        send_discord "Roblox telah ditutup."
        log "Roblox terdeteksi tertutup."
      fi
    fi

    now=$(date +%s)
    if (( now - last_reminder >= REMINDER_INTERVAL )); then
      last_reminder=$now
      uptime_message=$(get_uptime_string)
      send_discord "Reminder: $uptime_message"
      log "Mengirim pengingat uptime."
    fi

    sleep $INTERVAL
  done
  exit 0
fi

# === MODE STOP ===
if [[ "$1" == "stop" ]]; then
  echo "Monitoring dihentikan."
  exit 0
fi

# === DEFAULT ===
echo "Gunakan perintah berikut:"
echo "  bash roblox_monitor.sh setup   # Untuk setup awal"
echo "  bash roblox_monitor.sh start   # Untuk memulai monitoring"
echo "  bash roblox_monitor.sh stop    # Untuk menghentikan (tidak digunakan langsung)"
exit 1
