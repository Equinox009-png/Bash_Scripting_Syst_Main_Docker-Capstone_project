#!/usr/bin/env bash
# log_monitor.sh - simple log watcher that looks for error keywords and writes alerts
set -euo pipefail

TARGET="${1:-/var/log/syslog}"
LOGFILE="${2:-/data/logs/log_monitor.log}"
_keywords=( "error" "fail" "unauthorized" "critical" "panic" )

_timestamp(){ date "+%Y-%m-%d %H:%M:%S"; }
log(){ printf '[%s] %s\n' "$(_timestamp)" "$*" | tee -a "$LOGFILE"; }

if [[ ! -f "$TARGET" ]]; then
  log "Log file $TARGET not found."
  exit 1
fi

log "Scanning $TARGET for keywords: ${_keywords[*]}"

TMP=$(mktemp) || { log "ERROR: cannot create temp file"; exit 2; }
tail -n 500 "$TARGET" > "$TMP" || { log "ERROR: tail failed"; rm -f "$TMP"; exit 3; }

alerts=0
for kw in "${_keywords[@]}"; do
  matches=$(grep -i -n -E "$kw" "$TMP" || true)
  if [[ -n "$matches" ]]; then
    log "Found matches for '$kw':"
    printf '%s\n' "$matches" | tee -a "$LOGFILE"
    ((alerts++))
  fi
done

rm -f "$TMP"

if (( alerts > 0 )); then
  log "Total keyword groups matched: $alerts — writing to /data/logs/alerts.log"
  printf '[%s] Alerts found in %s\n' "$(_timestamp)" "$TARGET" >> /data/logs/alerts.log
  exit 2
else
  log "No alerts found in $TARGET"
  exit 0
fi
