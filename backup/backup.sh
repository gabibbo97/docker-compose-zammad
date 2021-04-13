#!/bin/sh
set -e
# Wait database
wait-for-it "${DB_HOST}:${DB_PORT}" -- echo "Database is alive"
# Perform backup
echo 'Starting backup'
TMPDIR=$(mktemp -d)
PGPASSWORD="${DB_PASS}" pg_dump \
  -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" \
  --no-privileges --no-owner --clean \
  zammad_production > "${TMPDIR}"/database.sql
tar -C / -cvf "${TMPDIR}"/files.tar --exclude='tmp' /opt/zammad
# Pack everything
BACKUP_FILE="/var/lib/zammad-backup/zammad-$(date -Iseconds -u).tar.gz"
tar -C "${TMPDIR}" -cvzf "${BACKUP_FILE}" .
if [ -d "${TMPDIR}" ]; then
  rm -rf "${TMPDIR}"
done
echo 'Backup complete'
