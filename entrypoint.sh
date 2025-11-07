#!/usr/bin/env bash
# entrypoint.sh - prepare scripts and optionally start cron or drop to shell
set -euo pipefail

SCRIPTS_DIR="/workspace/scripts"

# Ensure scripts exist and are executable
if [[ -d "$SCRIPTS_DIR" ]]; then
  chmod +x "${SCRIPTS_DIR}"/*.sh || true
fi

# If first arg is "cron", install crontab and start cron in foreground
if [[ "${1:-}" == "cron" ]]; then
  # Clear existing crontab (safe for container)
  crontab -r 2>/dev/null || true

  # Example scheduled jobs: adjust paths if you change volumes
  cat <<'CRON' | crontab -
# m h  dom mon dow command
0 2 * * * /workspace/scripts/backup.sh /data/source /data/backups 7 >> /data/logs/backup.log 2>&1
0 3 * * * /workspace/scripts/update_cleanup.sh >> /data/logs/update_cleanup.log 2>&1
*/5 * * * * /workspace/scripts/log_monitor.sh /var/log/syslog >> /data/logs/log_monitor.log 2>&1
CRON

  echo "Starting cron (foreground). Logs will go to /data/logs if mounted."
  exec cron -f
fi

# If any args provided, run them
if [[ "${#@}" -gt 0 ]]; then
  exec "$@"
fi

# Default: open an interactive shell
exec bash
