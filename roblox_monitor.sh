#!/data/data/com.termux/files/usr/bin/bash

GAME_LINK="roblox://placeId=1537690962"
PKG_NAME="com.roblox.client"
LOG_FILE="$HOME/roblox_log.txt"
DISCORD_WEBHOOK="https://discord.com/api/webhooks/1363321007389020200/l6y9LMQzwcFu15uiQfC8XawlcqixNLukLcPoREBXyXYNqK9mFwGRW6qbgNJYmCTi9v_f"

log() {
  echo "[$(date '+%F %T')] $1" >> "$LOG_FILE"
}

send_discord() {
  msg="$1"
  curl -s -X POST -H "Content-Type: application/json" \
    -d "{\"content\": \"@everyone $msg\"}" "$DISCORD_WEBHOOK" > /dev/null
}

start_monitoring() {
  log "Memulai monitoring Roblox..."
  echo "Monitoring Roblox dimulai..."

  last_status="unknown"
  uptime=0
  tick=0

  while true
  do
    ps | grep "$PKG_NAME" | grep -v grep > /dev/null
    if [ $? -eq 0 ]; then
      current_status="running"
    else
      current_status="closed"
    fi

    if [ "$current_status" != "$last_status" ]; then
      if [ "$current_status" = "running" ]; then
        send_discord "Roblox telah dibuka."
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
