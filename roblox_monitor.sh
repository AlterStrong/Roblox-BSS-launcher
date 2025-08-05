#!/data/data/com.termux/files/usr/bin/bash

GAME_LINK="roblox://placeId=1537690962/"
PKG_NAME="com.roblox.client"
DISCORD_WEBHOOK="https://discord.com/api/webhooks/1363321007389020200/l6y9LMQzwcFu15uiQfC8XawlcqixNLukLcPoREBXyXYNqK9mFwGRW6qbgNJYmCTi9v_f"
LOG_FILE="$HOME/roblox_log.txt"
PID_FILE="$HOME/.roblox_monitor_pid"
STATE_FILE="$HOME/.roblox_last_state"

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
  # Gunakan dumpsys jika tersedia, jika tidak fallback ke `pidof`
  which dumpsys > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    dumpsys window windows | grep -i "$PKG_NAME" > /dev/null 2>&1
    return $?
  else
    pidof "$PKG_NAME" > /dev/null 2>&1
    return $?
  fi
}

start_monitoring() {
  touch "$LOG_FILE"
  log "Monitoring dimulai."
  send_discord ":rocket: Monitoring dimulai! Roblox akan auto-rejoin jika keluar."

  if [ ! -f "$STATE_FILE" ]; then
    echo "unknown" > "$STATE_FILE"
  fi

  counter=0

  while true; do
    current_state=$(cat "$STATE_FILE")
    is_roblox_open
    if [ $? -eq 0 ]; then
      if [ "$current_state" != "open" ]; then
        log "Roblox dibuka."
        send_discord "@everyone ✅ Roblox telah dibuka!"
        echo "open" > "$STATE_FILE"
      fi
    else
      if [ "$current_state" != "closed" ]; then
        log "Roblox ditutup. Membuka ulang..."
        send_discord ":x: Roblox ditutup! Melakukan auto-rejoin..."
        open_game
        echo "closed" > "$STATE_FILE"
      fi
    fi

    counter=$((counter + 1))
    if [ $((counter % 24)) -eq 0 ]; then
      send_discord "⏰ Reminder: Sudah $((counter / 12)) jam monitoring berjalan."
    fi

    sleep 300
  done
}

stop_monitoring() {
  if [ -f "$PID_FILE" ]; then
    kill "$(cat "$PID_FILE")" && rm -f "$PID_FILE"
    log "Monitoring dihentikan."
    send_discord "🛑 Monitoring dihentikan secara manual."
  else
    echo "Monitoring tidak berjalan."
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
esac      if [ "$last_status" != "open" ]; then
        log "Roblox dibuka."
        send_discord "@everyone :white_check_mark: Roblox telah dibuka kembali!"
        last_status="open"
      fi
    else
      if [ "$last_status" != "closed" ]; then
        log "Roblox ditutup. Membuka ulang..."
        send_discord ":x: Roblox telah ditutup! Melakukan auto-rejoin..."
        open_game
        last_status="closed"
      fi
    fi

    counter=$((counter + 1))
    if [ $((counter % 24)) -eq 0 ]; then
      send_discord ":alarm_clock: Sudah 2 jam sejak monitoring dimulai."
    fi

    sleep 300
  done
}

stop_monitoring() {
  if [ -f "$PID_FILE" ]; then
    kill "$(cat "$PID_FILE")" && rm -f "$PID_FILE"
    log "Monitoring dihentikan."
    send_discord ":stop_sign: Monitoring dihentikan secara manual."
  else
    echo "Monitoring tidak berjalan."
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
esac    current_state=$(cat "$STATE_FILE")
    if is_roblox_open; then
      if [ "$current_state" = "CLOSED" ]; then
        send_discord "@everyone :white_check_mark: Roblox telah dibuka!"
        echo "OPEN" > "$STATE_FILE"
      fi
    else
      if [ "$current_state" = "OPEN" ]; then
        send_discord "@everyone :x: Roblox telah ditutup!"
        echo "CLOSED" > "$STATE_FILE"
      fi
      log "Roblox tidak aktif. Membuka ulang..."
      open_game
      sleep 10
    fi

    now=$(date +%s)
    last_ping=$(cat "$LAST_PING_FILE")
    diff=$((now - last_ping))
    if [ "$diff" -ge 7200 ]; then
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
    SCRIPT_PATH=$(realpath "$0")
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
esac
