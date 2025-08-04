#!/data/data/com.termux/files/usr/bin/bash

# === KONFIGURASI ===
GAME_LINK="roblox://placeId=1537690962"
PKG_NAME="com.roblox.client"
DISCORD_WEBHOOK="https://discord.com/api/webhooks/1363321007389020200/l6y9LMQzwcFu15uiQfC8XawlcqixNLukLcPoREBXyXYNqK9mFwGRW6qbgNJYmCTi9v_f"
LOG_FILE="$HOME/roblox_log.txt"
PID_FILE="$HOME/.roblox_monitor_pid"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

send_discord() {
  curl -s -X POST -H "Content-Type: application/json" \
    -d "{\"content\": \"@everyone $1\"}" "$DISCORD_WEBHOOK" > /dev/null
}

is_app_running() {
  dumpsys window windows | grep -q "$PKG_NAME"
}

monitor_loop() {
  local last_status=""
  local counter=0
  local uptime=0

  log "🔄 Memulai monitoring Roblox..."

  while true; do
    if is_app_running; then
      current_status="running"
    else
      current_status="stopped"
    fi

    if [[ "$current_status" != "$last_status" ]]; then
      if [[ "$current_status" == "running" ]]; then
        log "🎮 Roblox sedang berjalan"
        send_discord "✅ Roblox terbuka."
      else
        log "🚫 Roblox tidak aktif, membuka kembali..."
        am start -a android.intent.action.VIEW -d "$GAME_LINK" > /dev/null 2>&1
        send_discord "🔁 Roblox tidak aktif, auto-rejoin ke Bee Swarm Simulator..."
      fi
      last_status="$current_status"
    fi

    # Notifikasi uptime tiap 2 jam
    counter=$((counter + 1))
    if (( counter % 24 == 0 )); then
      uptime=$((counter / 12))
      send_discord "⏰ Reminder: Roblox Monitor masih aktif.\nUptime: ${uptime} jam"
    fi

    sleep 300  # 5 menit
  done
}

start_monitoring(){
  if [ -f "$PID_FILE" ]; then
    echo "⚠️ Monitoring sudah aktif (PID: $(cat $PID_FILE))"
    exit 1
  fi
  nohup bash -c "$(declare -f log send_discord is_app_running monitor_loop); monitor_loop" > /dev/null 2>&1 &
  echo $! > "$PID_FILE"
  echo "🚀 Monitoring dimulai (PID: $(cat $PID_FILE))"
}

stop_monitoring(){
  if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    kill "$PID" && rm -f "$PID_FILE"
    echo "🛑 Monitoring dihentikan (PID: $PID)"
  else
    echo "ℹ️ Monitoring belum aktif."
  fi
}

setup_environment(){
  pkg update -y
  pkg install -y termux-api curl
  termux-setup-storage

  echo ""
  echo "✅ Dependencies terinstal."
  echo ""
  echo "⚠️ Sekarang izinkan permission berikut secara manual:"
  echo "  • Battery info"
  echo "  • Usage/access stats"
  echo "  • Open app via intent"
  echo ""
  echo "Buka: Settings → Apps → Termux → Permissions → izinkan semuanya"
  read -p "Tekan ENTER setelah selesai memberi izin... "
  echo "✅ Setup selesai."
  echo "Gunakan:"
  echo "bash $0 start   # untuk memulai monitoring"
  echo "bash $0 stop    # untuk menghentikan monitoring"
}

case "$1" in
  setup)   setup_environment ;;
  start)   start_monitoring ;;
  stop)    stop_monitoring ;;
  *) echo "Gunakan: $0 {setup|start|stop}" ;;
esac    fi

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
