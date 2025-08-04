#!/data/data/com.termux/files/usr/bin/bash

# === KONFIGURASI ===
GAME_LINK="roblox://placeId=1537690962/"
PKG_NAME="com.roblox.client"
DISCORD_WEBHOOK="https://discord.com/api/webhooks/1363321007389020200/l6y9LMQzwcFu15uiQfC8XawlcqixNLukLcPoREBXyXYNqK9mFwGRW6qbgNJYmCTi9v_f"
INTERVAL=300 # 5 menit
UPTIME_REMINDER_INTERVAL=$((2 * 60 * 60)) # 2 jam (7200 detik)
LOG_FILE="$HOME/roblox_log.txt"
STATE_FILE="$HOME/.roblox_last_state"

# === FUNGSI ===

send_discord() {
  curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"@everyone $1\"}" "$DISCORD_WEBHOOK" > /dev/null 2>&1
}

open_game() {
  am start -a android.intent.action.VIEW -d "$GAME_LINK" > /dev/null 2>&1
  echo "Game dibuka: $GAME_LINK"
}

is_roblox_running() {
  pidof "$PKG_NAME" > /dev/null 2>&1
}

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

start_monitoring() {
  echo "Monitoring dimulai..."
  echo "off" > "$STATE_FILE"
  counter=0

  while true; do
    if is_roblox_running; then
      if [ "$(cat "$STATE_FILE")" != "on" ]; then
        log "Roblox dibuka"
        send_discord "Roblox telah DIBUKA"
        echo "on" > "$STATE_FILE"
        counter=0
      fi
    else
      if [ "$(cat "$STATE_FILE")" != "off" ]; then
        log "Roblox ditutup"
        send_discord "Roblox telah DITUTUP"
        echo "off" > "$STATE_FILE"
        counter=0
      fi
    fi

    counter=$((counter + INTERVAL))

    if (( counter >= UPTIME_REMINDER_INTERVAL )); then
      hours=$((counter / 3600))
      log "Uptime reminder - ${hours} jam"
      send_discord "Reminder: Roblox monitor aktif selama ${hours} jam"
      counter=0
    fi

    sleep "$INTERVAL"
  done
}

# === EKSEKUSI ===

case "$1" in
  start)
    start_monitoring
    ;;
  setup)
    echo "Melakukan setup awal..."
    mkdir -p ~/.shortcuts
    termux-setup-storage
    echo "Selesai setup. Jalankan dengan: bash roblox_monitor.sh start"
    ;;
  *)
    echo "Gunakan: bash roblox_monitor.sh [start|setup]"
    ;;
esac  local minutes=$(( (uptime % 3600) / 60 ))
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
