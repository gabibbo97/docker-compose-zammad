#!/bin/sh
set -e

docker volume list -q | while read -r volume; do
  # Find volume name
  if ! docker volume inspect "${volume}" | grep 'com' | grep 'docker' | grep 'compose' | grep 'volume' | grep -q 'zammad_backup'; then
    continue
  fi
  # Find mountpoint
  MOUNTPOINT=$(docker volume inspect -f '{{.Mountpoint}}' "${volume}")
  echo "Backup volume is at ${MOUNTPOINT}"
  # Find latest backup
  LATEST_BACKUP="$(find "${MOUNTPOINT}" -type f -print0 | xargs -r -0 ls -1 -t | head -1)"
  echo "Latest backup is at ${LATEST_BACKUP}"
  # Extract latest backup
  rm -f database.sql files.tar
  tar -xvzf "${LATEST_BACKUP}"
  # Done
  echo 'Grabbed backup'
  break
done
