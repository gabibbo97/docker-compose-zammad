#!/bin/sh
set -e
# Infinite loop if needed
if [ "${BACKUP_ENABLED}" != "true" ]; then
  echo 'Backup disabled'
  while true; do sleep 3600; done
fi
# Calculate
WAIT_SECONDS=$(( BACKUP_INTERVAL_HOURS * 60 * 60 ))
# Perform backup
while true; do
  # Cleanup old files
  echo "Cleaning up old backups"
  find /var/lib/zammad-backup -mtime "+${BACKUP_HOLD_DAYS}" -delete
  # Backup
  /usr/local/bin/backup.sh
  # Wait
  echo "Waiting for ${BACKUP_INTERVAL_HOURS} hours (${WAIT_SECONDS} seconds)"
  sleep "${WAIT_SECONDS}"
done