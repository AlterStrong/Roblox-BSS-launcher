#!/data/data/com.termux/files/usr/bin/bash

# === KONFIGURASI ===
GAME_LINK="roblox://placeId=1537690962/"
PKG_NAME="com.roblox.client"
DISCORD_WEBHOOK="https://discord.com/api/webhooks/1363321007389020200/l6y9LMQzwcFu15uiQfC8XawlcqixNLukLcPoREBXyXYNqK9mFwGRW6qbgNJYmCTi9v_f"
LOG_FILE="$HOME/roblox_log.txt"
PID_FILE="$HOME/.roblox_monitor_pid"
STATE_FILE="$HOME/.roblox_status"
LAST_PING_FILE="$HOME/.last_ping_time"

# === FUNGSI ===
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
  send_discord "@everyone :rocket: Monitoring dimulai! Roblox akan auto-rejoin jika keluar."
  log "Monitoring dimulai."
  echo "CLOSED" > "$STATE_FILE"
  date +%s > "$LAST_PING_FILE"

  while true; do
    if is_roblox_open; then
      if [ "$(cat "$STATE_FILE")" = "CLOSED" ]; then
        send_discord "@everyone :white_check_mark: Roblox telah dibuka!"
        echo "OPEN" > "$STATE_FILE"
      fi
    else
      if [ "$(cat "$STATE_FILE")" = "OPEN" ]; then
        send_discord "@everyone :x: Roblox telah ditutup!"
        echo "CLOSED" > "$STATE_FILE"
      fi
      log "Roblox tidak aktif. Membuka ulang..."
      open_game
      sleep 10
    fi

    # Notifikasi setiap 2 jam
    now=$(date +%s)
    last_ping=$(cat "$LAST_PING_FILE")
    if [ $((now - last_ping)) -ge 7200 ]; then
      send_discord ":alarm_clock: Sudah 2 jam sejak monitoring berjalan."
      date +%s > "$LAST_PING_FILE"
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
    SCRIPT_PATH="$(realpath "$0")"
    nohup bash "$SCRIPT_PATH" run > /dev/null 2>&1 &
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
    pkg install -y termux-api curl coreutils
    termux-setup-storage
    echo "Setup selesai. Jalankan: bash roblox_monitor.sh start"
    ;;
  *)
    echo "Gunakan: bash roblox_monitor.sh {setup|start|stop}"
    ;;
esac      if [ "$last_status" != "running" ]; then
        send_discord "@everyone :video_game: Roblox dibuka kembali."
        log "Roblox dibuka."
        last_status="running"
        tick=0  # reset uptime saat dibuka kembali
      fi
    else
      if [ "$last_status" != "closed" ]; then
        send_discord ":warning: Roblox tidak aktif. Auto-rejoin dilakukan."
        log "Roblox ditutup. Membuka ulang..."
        last_status="closed"
      fi
      open_game
      sleep 10
    fi

    tick=$((tick + 1))
    if [ $((tick % 24)) -eq 0 ]; then
      uptime_hours=$((tick * 5 / 60))  # setiap 2 jam (24*5 menit)
      send_discord ":alarm_clock: Uptime: ${uptime_hours} jam"
    fi

    sleep 300  # 5 menit
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
    nohup bash "$0" run > /dev/null 2>&1 &
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
