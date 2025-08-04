#!/data/data/com.termux/files/usr/bin/bash

# === KONFIGURASI ===
GAME_LINK="roblox://placeId=1537690962"
DISCORD_WEBHOOK="https://discord.com/api/webhooks/1363321007389020200/l6y9LMQzwcFu15uiQfC8XawlcqixNLukLcPoREBXyXYNqK9mFwGRW6qbgNJYmCTi9v_f"
LOG_FILE="$HOME/roblox_log.txt"

# === FUNGSI ===
log() {
  echo "[$(date '+%F %T')] $1" >> "$LOG_FILE"
}

send_discord() {
  msg="$1"
  curl -s -X POST -H "Content-Type: application/json" \
    -d "{\"content\": \"@everyone $msg\"}" "$DISCORD_WEBHOOK" > /dev/null
}

# === FUNGSI MONITOR ===
start_monitoring() {
  log "Monitoring dimulai..."
  echo "Monitoring dimulai..."
  tick=0
  uptime_counter=0

  while true; do
    tick=$((tick + 1))
    if [ $((tick % 24)) -eq 0 ]; then
      uptime_counter=$((uptime_counter + 2))
      send_discord "Uptime: ${uptime_counter} jam"
    fi
    sleep 300
  done
}

# === MAIN ===
case "$1" in
  setup)
    send_discord "Roblox dimulai."
    am start -a android.intent.action.VIEW -d "$GAME_LINK"
    ;;
  start)
    send_discord "Memulai monitoring Roblox."
    start_monitoring
    ;;
  *)
    echo "Gunakan: bash roblox_monitor.sh start | setup"
    ;;
esac        send_discord "Roblox telah dibuka."
        log "Roblox dibuka"
      else
        send_discord "Roblox telah ditutup."
        log "Roblox ditutup"
      fi
      last_status="$current_status"
    fi

    tick=`expr $tick + 1`
    if [ `expr $tick % 24` -eq 0 ]; then
      uptime=`expr $uptime + 2`
      send_discord "Uptime: $uptime jam"
    fi

    sleep 300
  done
}

if [ "$1" = "start" ]; then
  start_monitoring
elif [ "$1" = "setup" ]; then
  echo "Menjalankan Roblox..."
  am start -a android.intent.action.VIEW -d "$GAME_LINK"
  log "Roblox dijalankan lewat setup."
else
  echo "Gunakan: bash roblox_monitor.sh start | setup"
fi
