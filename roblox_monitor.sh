#!/data/data/com.termux/files/usr/bin/bash

# === KONFIGURASI ===
GAME_LINK="roblox://placeId=1537690962"
PKG_NAME="com.roblox.client"
WEBHOOK="https://discord.com/api/webhooks/1363321007389020200/l6y9LMQzwcFu15uiQfC8XawlcqixNLukLcPoREBXyXYNqK9mFwGRW6qbgNJYmCTi9v_f"
MONITOR_DIR="$HOME/roblox_monitor"
LOG_FILE="$MONITOR_DIR/log.txt"
PID_FILE="$MONITOR_DIR/monitor.pid"

# === FUNGSI ===
log(){ echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"; }
send_discord(){
  curl -s -X POST -H "Content-Type: application/json" \
    -d "{\"content\": \"$1\"}" "$WEBHOOK" > /dev/null
}
check_battery(){
  battery=$(termux-battery-status)
  percent=$(echo "$battery" | grep -o '"percentage": *[0-9]*' | grep -o '[0-9]*')
  plugged=$(echo "$battery" | grep -i '"plugged":' | grep -o '[a-zA-Z]*$')
}
is_app_running(){
  dumpsys window windows | grep -i "mCurrentFocus" | grep "$PKG_NAME" > /dev/null
  return $?
}

monitor_loop(){
  mkdir -p "$MONITOR_DIR"
  touch "$LOG_FILE"
  log "🔁 Monitoring Roblox dimulai"
  send_discord "📲 Monitoring dimulai. Auto‑join Bee Swarm Simulator aktif."
  lowbat_warned=false

  while true; do
    check_battery
    if [ "$percent" -lt 20 ] && [[ "$plugged" != "AC" && "$plugged" != "USB" ]]; then
      log "⚠️ Baterai rendah: $percent%"
      if ! $lowbat_warned; then
        send_discord "⚠️ Baterai < 20%! Ketik 'Baiklah' di Termux untuk hentikan notifikasi."
        lowbat_warned=true
      else
        read -t 60 -p "Ketik 'Baiklah' untuk hentikan reminder baterai: " input
        if [[ "$input" == "Baiklah" ]]; then
          log "✅ Reminder baterai dihentikan"
          send_discord "✅ Reminder baterai dihentikan oleh pengguna."
          lowbat_warned=false
        else
          send_discord "⚠️ Masih lowbatt ($percent%). Ketik 'Baiklah' jika sudah di-charge."
        fi
      fi
    else
      lowbat_warned=false
    fi

    if is_app_running; then
      log "🎮 Roblox sedang berjalan"
      send_discord "✅ Roblox sedang terbuka."
    else
      log "🚀 Roblox tidak aktif, membuka Bee Swarm Simulator..."
      am start -a android.intent.action.VIEW -d "$GAME_LINK" > /dev/null 2>&1
      send_discord "🔁 Roblox tidak aktif, auto-rejoin ke Bee Swarm Simulator..."
      sleep 10
    fi

    sleep 300
  done
}

start_monitoring(){
  if [ -f "$PID_FILE" ]; then
    echo "⚠️ Monitoring sudah aktif (PID: $(cat $PID_FILE))"
    exit 1
  fi
  nohup bash -c "$(declare -f log send_discord check_battery is_app_running monitor_loop); monitor_loop" > /dev/null 2>&1 &
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

  mkdir -p "$MONITOR_DIR"

  echo ""
  echo "✅ Dependencies terinstal."
  echo ""
  echo "⚠️ Sekarang izinkan permission berikut secara manual:"
  echo "  • Battery info"
  echo "  • Usage/access stats (agar dumpsys window dapat melihat app aktif)"
  echo "  • Draw over apps / buka app via intent"
  echo ""
  echo "Buka: Settings → Apps → Termux → Permissions → izinkan semuanya terkait."
  read -p "Tekan ENTER setelah selesai memberi izin... "
  echo ""
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
esac
