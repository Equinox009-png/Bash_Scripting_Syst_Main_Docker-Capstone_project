#!/usr/bin/env bash
# update_cleanup.sh - update package lists and clean cache
set -euo pipefail

LOGFILE="${1:-/data/logs/update_cleanup.log}"
_timestamp(){ date "+%Y-%m-%d %H:%M:%S"; }
log(){ printf '[%s] %s\n' "$(_timestamp)" "$*" | tee -a "$LOGFILE"; }

log "Starting update & cleanup"

# Update package lists
if apt-get update -y >> "$LOGFILE" 2>&1; then
  log "apt-get update completed"
else
  log "ERROR: apt-get update failed"
  exit 2
fi

# Upgrade packages
if DEBIAN_FRONTEND=noninteractive apt-get upgrade -yq >> "$LOGFILE" 2>&1; then
  log "apt-get upgrade completed"
else
  log "ERROR: apt-get upgrade failed"
  exit 3
fi

# Autoremove and autoclean
if apt-get autoremove -yq >> "$LOGFILE" 2>&1 && apt-get autoclean -yq >> "$LOGFILE" 2>&1; then
  log "Cleanup completed"
else
  log "WARN: autoremove/autoclean encountered issues"
fi

log "Update & cleanup finished"
exit 0
