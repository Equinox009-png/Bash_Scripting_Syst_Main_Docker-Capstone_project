#!/usr/bin/env bash
# backup.sh - create timestamped backup and rotate old ones
set -euo pipefail

SRC="${1:-}"
DEST_DIR="${2:-}"
KEEP="${3:-5}"       # default keep 5 backups
LOGFILE="${4:-/data/logs/backup.log}"

_timestamp(){ date "+%Y-%m-%d %H:%M:%S"; }
log(){ printf '[%s] %s\n' "$(_timestamp)" "$*" | tee -a "$LOGFILE"; }

if [[ -z "$SRC" || -z "$DEST_DIR" ]]; then
  log "USAGE: $0 /path/to/source /path/to/backup_dir [keep_count] [optional_logfile]"
  exit 2
fi

if [[ ! -e "$SRC" ]]; then
  log "ERROR: source '$SRC' does not exist."
  exit 3
fi

if [[ -f "$SRC" ]]; then
  log "ERROR: source '$SRC' is a file; expected directory."
  exit 4
fi

mkdir -p "$DEST_DIR" || { log "ERROR: cannot create dest $DEST_DIR"; exit 5; }

TIMESTAMP="$(date +%Y-%m-%d_%H%M%S)"
BASENAME="$(basename "$SRC")"
ARCHIVE="${DEST_DIR}/${BASENAME}_backup_${TIMESTAMP}.tar.gz"

log "Starting backup: '$SRC' -> '$ARCHIVE'"

if tar -C "$(dirname "$SRC")" -czf "$ARCHIVE" "$BASENAME"; then
  log "Archive created: $ARCHIVE"
else
  log "ERROR: tar failed for $SRC"
  rm -f "$ARCHIVE" || true
  exit 6
fi

# rotate
log "Rotating backups, keeping last $KEEP"
shopt -s nullglob
files=( "$DEST_DIR/${BASENAME}_backup_"*.tar.gz )
shopt -u nullglob

if (( ${#files[@]} > KEEP )); then
  mapfile -t sorted < <(ls -1t "$DEST_DIR/${BASENAME}_backup_"*.tar.gz)
  for ((i=KEEP;i<${#sorted[@]};i++)); do
    log "Removing old backup: ${sorted[$i]}"
    rm -f -- "${sorted[$i]}" || log "WARN: couldn't remove ${sorted[$i]}"
  done
else
  log "No old backups to remove (found ${#files[@]})."
fi

log "Backup finished successfully: $ARCHIVE"
exit 0
