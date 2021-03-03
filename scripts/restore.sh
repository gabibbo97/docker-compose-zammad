#!/bin/sh
set -e
# Grab backup
[ -f database.sql ] || sh scripts/grab-backup.sh
[ -f files.tar ] || sh scripts/grab-backup.sh
# Perform restore
docker-compose stop zammad-scheduler
docker-compose stop zammad-websocket
until docker-compose exec zammad bundle exec env RAILS_ENV=production DISABLE_DATABASE_ENVIRONMENT_CHECK=1 bundle exec rake db:drop; do
  docker-compose exec -T database env PGPASSWORD=zammad psql -U zammad zammad_production <<EOF
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE pid <> pg_backend_pid() AND datname = 'zammad_production';
EOF
  sleep 1
done
docker-compose exec zammad bundle exec env RAILS_ENV=production bundle exec rake db:create
docker-compose exec -T database env PGPASSWORD=zammad psql -U zammad zammad_production < database.sql
docker-compose exec -T zammad tar -C / --overwrite -xvf - < files.tar
docker-compose exec zammad bundle exec env RAILS_ENV=production rails r "Cache.clear"
docker-compose restart zammad
docker-compose start zammad-scheduler
docker-compose start zammad-websocket
