#!/bin/sh
set -e
# Wait database
wait-for-it "${DB_HOST}:${DB_PORT}" -- echo "Database is alive"
# Perform backup
echo 'Starting backup'
TMPFILE=$(mktemp -u)
PGPASSWORD="${DB_PASS}" pg_dump \
  -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" \
  --no-privileges --no-owner --clean \
  zammad_production \
| zstd - -o "${TMPFILE}"
mv "${TMPFILE}" "/var/lib/zammad-backup/zammad-$(date -Iseconds -u).psql.zstd"
echo 'Backup complete'
