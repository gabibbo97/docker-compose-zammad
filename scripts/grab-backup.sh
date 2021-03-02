#!/bin/sh
set -e
# Grab latest backup
LATEST_BACKUP_NAME=$(docker-compose exec zammad-backup sh -c "find /var/lib/zammad-backup -type f -print0 | xargs -r -0 ls -l1 -t | head -n 1 | rev | awk '{ print \$1 }' | rev | tr -d '[:space:]'")
echo "Latest backup ${LATEST_BACKUP_NAME}"
docker-compose exec zammad-backup sh -c "cat '${LATEST_BACKUP_NAME}' | zstd -d -" > backup.sql
echo "Grabbed backup"
