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
    -d "{\"content\": \"$1\"}" "$DISCORD_WEBHOOK" > /dev/null
}

is_app_running() {
  dumpsys window windows | grep -q "$PKG_NAME"
}

check_battery() {
  termux-battery-status | jq '.percentage'
}

monitor_loop() {
  local lowbat_warned=false

  log "🔄 Memulai monitoring Roblox..."

  while true; do
    percent=$(check_battery)
    if [[ "$percent" =~ ^[0-9]+$ ]] && [ "$percent" -lt 20 ]; then
      if ! $lowbat_warned; then
        log "⚠️ Baterai rendah: $percent%"
        send_discord "⚠️ Baterai < 20%! Monitoring dihentikan untuk menghemat baterai."
        lowbat_warned=true
        break
      fi
    fi

    if is_app_running; then
      log "🎮 Roblox sedang berjalan"
    else
      log "🚀 Roblox tidak aktif, membuka game..."
      am start -a android.intent.action.VIEW -d "$GAME_LINK" > /dev/null 2>&1
      send_discord "🔁 Auto-rejoin Roblox."
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
  nohup bash "$0" internal_loop > /dev/null 2>&1 &
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
  pkg install -y termux-api jq curl
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
  setup)         setup_environment ;;
  start)         start_monitoring ;;
  stop)          stop_monitoring ;;
  internal_loop) monitor_loop ;;
  *) echo "Gunakan: $0 {setup|start|stop}" ;;
esac      log "⚠️ Baterai rendah: $percent%"
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

start_monitoring() {
  if [ -f "$PID_FILE" ]; then
    echo "⚠️ Monitoring sudah aktif (PID: $(cat $PID_FILE))"
    exit 1
  fi

  nohup bash -c "$(declare -f log send_discord check_battery is_app_running monitor_loop); monitor_loop" > /dev/null 2>&1 &
  echo $! > "$PID_FILE"
  echo "🚀 Monitoring dimulai (PID: $(cat $PID_FILE))"
}

stop_monitoring() {
  if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    kill "$PID" && rm -f "$PID_FILE"
    echo "🛑 Monitoring dihentikan (PID: $PID)"
  else
    echo "ℹ️ Monitoring belum aktif."
  fi
}

setup_environment() {
  pkg update -y
  pkg install -y termux-api curl jq
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

# === HANDLE ARGUMENT ===
case "$1" in
  setup) setup_environment ;;
  start) start_monitoring ;;
  stop)  stop_monitoring ;;
  *)     echo "Gunakan: $0 {setup|start|stop}" ;;
esac        send_discord "⚠️ Baterai < 20%! Ketik 'Baiklah' di Termux untuk hentikan notifikasi."
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
      send_discord "🔁 Roblox tidak aktif, auto‑rejoin ke Bee Swarm Simulator..."
      sleep 10
    fi

    sleep 300
  done
}

start_monitoring() {
  if [ -f "$PID_FILE" ]; then
    echo "⚠️ Monitoring sudah aktif (PID: $(cat "$PID_FILE"))"
    exit 1
  fi
  nohup bash -c "$(declare -f log send_discord check_battery is_app_running monitor_loop); monitor_loop" > /dev/null 2>&1 &
  echo $! > "$PID_FILE"
  echo "🚀 Monitoring dimulai (PID: $(cat "$PID_FILE"))"
}

stop_monitoring() {
  if [ -f "$PID_FILE" ]; then
    kill "$(cat "$PID_FILE")" && rm -f "$PID_FILE"
    echo "🛑 Monitoring dihentikan"
  else
    echo "ℹ️ Monitoring belum aktif."
  fi
}

setup_environment() {
  pkg update -y
  pkg install -y termux-api jq curl
  termux-setup-storage

  echo ""
  echo "✅ Dependencies terinstal."
  echo ""
  echo "⚠️ Pastikan kamu sudah membuka Settings → Apps → Termux → Permissions dan izinkan:"
  echo "   • Battery info"
  echo "   • Usage/access stats"
  echo "   • Open app via intent"
  read -p "Tekan ENTER setelah kamu beri izin... "
  echo "✅ Setup selesai."
  echo "Gunakan:"
  echo "  bash $0 start  # untuk memulai monitoring"
  echo "  bash $0 stop   # untuk menghentikan monitoring"
}

case "$1" in
  setup) setup_environment ;;
  start) start_monitoring ;;
  stop) stop_monitoring ;;
  *) echo "Gunakan: $0 {setup|start|stop}" ;;
esac      sleep 10
    fi

    sleep 300
  done
}

start_monitoring() {
  if [ -f "$PID_FILE" ]; then
    echo "⚠️ Monitoring sudah aktif (PID: $(cat "$PID_FILE"))"
    exit 1
  fi
  nohup bash -c "$(declare -f log send_discord check_battery is_app_running monitor_loop); monitor_loop" > /dev/null 2>&1 &
  echo $! > "$PID_FILE"
  echo "🚀 Monitoring dimulai (PID: $(cat "$PID_FILE"))"
}

stop_monitoring() {
  if [ -f "$PID_FILE" ]; then
    kill "$(cat "$PID_FILE")" && rm -f "$PID_FILE"
    echo "🛑 Monitoring dihentikan"
  else
    echo "ℹ️ Monitoring belum aktif."
  fi
}

setup_environment() {
  pkg update -y
  pkg install -y termux-api jq curl
  termux-setup-storage

  echo ""
  echo "✅ Dependencies terinstal."
  echo ""
  echo "⚠️ Pastikan kamu sudah membuka Settings → Apps → Termux → Permissions dan izinkan:"
  echo "   • Battery info"
  echo "   • Usage/access stats"
  echo "   • Open app via intent"
  read -p "Tekan ENTER setelah kamu beri izin... "
  echo "✅ Setup selesai."
  echo "Gunakan:"
  echo "  bash $0 start  # untuk memulai monitoring"
  echo "  bash $0 stop   # untuk menghentikan monitoring"
}

case "$1" in
  setup) setup_environment ;;
  start) start_monitoring ;;
  stop) stop_monitoring ;;
  *) echo "Gunakan: $0 {setup|start|stop}" ;;
esac  start) start_monitoring ;;
  stop) stop_monitoring ;;
  *) echo "Gunakan: $0 {setup|start|stop}" ;;
esac/data/com.termux/files/usr/bin/bash

# === KONFIGURASI ===
GAME_LINK="roblox://placeId=1537690962"
PKG_NAME="com.roblox.client"
DISCORD_WEBHOOK="https://discord.com/api/webhooks/1363321007389020200/l6y9LMQzwcFu15uiQfC8XawlcqixNLukLcPoREBXyXYNqK9mFwGRW6qbgNJYmCTi9v_f"
LOWBAT_NOTIFY_FILE="$HOME/.roblox_lowbat"
LOG_FILE="$HOME/roblox_log.txt"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

send_discord() {
  curl -s -X POST -H "Content-Type: application/json" \
    -d "{\"content\": \"$1\"}" "$DISCORD_WEBHOOK" > /dev/null
}

launch_game() {
  am start "$GAME_LINK" > /dev/null 2>&1
}

is_roblox_running() {
  dumpsys window windows | grep -q "$PKG_NAME"
}

check_battery_low() {
  local percent
  percent=$(termux-battery-status | grep -o '"percentage": *[0-9]*' | grep -o '[0-9]*')
  [ "$percent" -lt 20 ]
}

monitor_loop() {
  log "Monitoring dimulai"
  while true; do
    if is_roblox_running; then
      log "Roblox dibuka"
      send_discord "🎮 Roblox baru saja dibuka!"
      sleep 300  # Tunggu 5 menit sebelum cek ulang
    elif check_battery_low; then
      log "Baterai < 20%"
      if [ ! -f "$LOWBAT_NOTIFY_FILE" ]; then
        touch "$LOWBAT_NOTIFY_FILE"
      fi
      while check_battery_low; do
        send_discord "⚠️ Baterai kurang dari 20%! Harap isi daya."
        sleep 60
        grep -qi "baiklah" <<< "$(tail -n 1 "$LOG_FILE")" && break
      done
      rm -f "$LOWBAT_NOTIFY_FILE"
    else
      log "Meluncurkan ulang Roblox"
      launch_game
      sleep 10
    fi
  done
}

case "$1" in
  setup)
    termux-setup-storage
    pkg install -y termux-api curl
    log "Setup selesai"
    ;;
  start)
    log "Memulai monitor di background"
    nohup bash "$0" loop > /dev/null 2>&1 &
    ;;
  stop)
    pkill -f "$0 loop"
    log "Monitoring dihentikan"
    ;;
  loop)
    monitor_loop
    ;;
  *)
    echo "Gunakan: $0 [setup|start|stop]"
    ;;
esac      log "⚠️ Baterai rendah: $percent%"
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
