#!/usr/bin/env bash
set -euo pipefail

_timestamp(){ date "+%Y-%m-%d %H:%M:%S"; }
log_to(){ printf '[%s] %s\n' "$(_timestamp)" "$*" | tee -a "$1"; }

while true; do
  clear
  echo "==========================================="
  echo "   🔧 System Maintenance Suite - MENU"
  echo "==========================================="
  echo "1) Run Backup Now"
  echo "2) Run Update & Cleanup"
  echo "3) Run Log Monitor"
  echo "4) Show Scripts Directory"
  echo "5) Run Full Maintenance Suite (with logging & error handling)"
  echo "6) Exit"
  echo "==========================================="
  read -rp "Choose an option [1-6]: " choice

  case "$choice" in
    1)
      read -rp "Enter source dir [/data/source]: " src
      src=${src:-/data/source}
      read -rp "Enter backup dir [/data/backups]: " dest
      dest=${dest:-/data/backups}
      read -rp "Keep how many backups [5]: " keep
      keep=${keep:-5}
      /workspace/scripts/backup.sh "$src" "$dest" "$keep"
      read -rp "Press Enter to continue..." ;;
    2)
      /workspace/scripts/update_cleanup.sh
      read -rp "Press Enter to continue..." ;;
    3)
      read -rp "Enter log file path [/var/log/syslog]: " log
      log=${log:-/var/log/syslog}
      /workspace/scripts/log_monitor.sh "$log"
      read -rp "Press Enter to continue..." ;;
    4)
      echo "Scripts in /workspace/scripts:"
      ls -lah /workspace/scripts
      read -rp "Press Enter to continue..." ;;
    5)
      # Full maintenance with consolidated logging and error handling
      TS=$(date +%Y%m%d_%H%M%S)
      FULL_LOG="/data/logs/full_run_${TS}.log"
      log_to "$FULL_LOG" "=== Starting Full Maintenance Suite ==="
      rc=0

      log_to "$FULL_LOG" "Step 1: Update & Cleanup"
      if /workspace/scripts/update_cleanup.sh "$FULL_LOG" >> "$FULL_LOG" 2>&1; then
        log_to "$FULL_LOG" "Update & Cleanup: SUCCESS"
      else
        log_to "$FULL_LOG" "Update & Cleanup: FAILED (see details above)"
        rc=1
      fi

      log_to "$FULL_LOG" "Step 2: Backup (default /data/source -> /data/backups)"
      if /workspace/scripts/backup.sh /data/source /data/backups 5 "$FULL_LOG" >> "$FULL_LOG" 2>&1; then
        log_to "$FULL_LOG" "Backup: SUCCESS"
      else
        log_to "$FULL_LOG" "Backup: FAILED (see details above)"
        rc=1
      fi

      log_to "$FULL_LOG" "Step 3: Log Monitor (scanning /data/source/sample.log if present)"
      if /workspace/scripts/log_monitor.sh /data/source/sample.log "$FULL_LOG" >> "$FULL_LOG" 2>&1; then
        log_to "$FULL_LOG" "Log Monitor: NO ALERTS"
      else
        log_to "$FULL_LOG" "Log Monitor: ALERTS FOUND or ERROR (see details above)"
        rc=1
      fi

      log_to "$FULL_LOG" "=== Full Maintenance Suite finished (exitcode=$rc) ==="
      echo "Full run log saved to: $FULL_LOG"
      read -rp "Press Enter to continue..."
      # optionally exit with rc to indicate failure to external caller:
      # if (( rc != 0 )); then exit $rc; fi
      ;;
    6)
      echo "Exiting System Maintenance Suite..."
      exit 0 ;;
    *)
      echo "Invalid option, try again."
      sleep 1 ;;
  esac
done
