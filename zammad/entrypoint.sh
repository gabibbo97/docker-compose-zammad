#!/bin/sh
set -e
# Helpers
fail() {
  echo "$1" > /dev/stderr
  exit 1
}
# Configure environment
THREADS=$(( $(nproc) * 50 ))
export MIN_THREADS=1
export MAX_THREADS="${THREADS}"
export RAILS_ENV=production
export RAILS_SERVE_STATIC_FILES=true
export RAILS_LOG_TO_STDOUT=true
[ -n "$DB_HOST" ] || fail "DB_HOST is not set"
[ -n "$DB_PORT" ] || fail "DB_PORT is not set"
[ -n "$DB_USER" ] || fail "DB_USER is not set"
[ -n "$DB_PASS" ] || fail "DB_PASS is not set"
# Prepare
waitDB() {
  wait-for-it "${DB_HOST}:${DB_PORT}" -- echo "Database is alive"
}
## Initialize db configuration file
cat > config/database.yml <<EOF
default: &default
  pool: ${THREADS}
  timeout: 5000
  encoding: utf8

  ##### postgresql config #####
  adapter: postgresql
  username: ${DB_USER}
  password: ${DB_PASS}
  host: ${DB_HOST}
  port: ${DB_PORT}

production:
  <<: *default
  database: zammad_production

development:
  <<: *default
  database: zammad_development

test:
  <<: *default
  database: zammad_test
EOF
## Precompile assets
if [ -n "${NO_PRECOMPILE_ASSETS}" ]; then
  sed -ie 's/config.assets.compile = false/config.assets.compile = true/' config/environments/production.rb
else
  waitDB && bundle exec rake assets:precompile
fi
## Database
if [ "$1" = "zammad" ]; then
  if ! (bundle exec rails r 'puts User.any?' 2> /dev/null | grep -q true); then
    echo 'Initializing DB'
    waitDB && bundle exec rake db:create
    waitDB && bundle exec rake db:migrate
    waitDB && bundle exec rake db:seed
  else
    echo 'Migrating DB'
    waitDB && bundle exec rake db:migrate
  fi
fi
## ElasticSearch
if [ "$1" = "zammad" ]; then
  waitElasticSearch() {
    wait-for-it "${ES_HOST}:${ES_PORT}" -- echo "ElasticSearch is alive"
  }
  if [ -n "${ES_HOST}" ]; then
    waitElasticSearch
    bundle exec rails r "Setting.set('es_url', '${ES_SCHEMA}://${ES_HOST}:${ES_PORT}')"
    bundle exec rails r "Setting.set('es_index', 'zammad')"
    if [ -z "${SKIP_ES_REINDEX}" ]; then
      bundle exec rake searchindex:rebuild
    fi
  else
    echo 'ElasticSearch disabled'
    bundle exec rails r "Setting.set('es_url', '')"
  fi
fi
# Start programs
waitZammad() {
  wait-for-it "zammad:3000" -- echo "Zammad is alive"
}
if [ "$1" = "zammad" ]; then
  echo 'Starting Rails'
  ruby --version
  test -f /opt/zammad/tmp/pids/server.pid && rm /opt/zammad/tmp/pids/server.pid
  exec /opt/zammad/bin/bundle exec rails server -b 0.0.0.0 -p 3000
elif [ "$1" = "websocket" ]; then
  waitZammad
  echo 'Starting websocket server'
  exec /opt/zammad/script/websocket-server.rb start -b 0.0.0.0 -p 6042
elif [ "$1" = "scheduler" ]; then
  waitZammad
  echo 'Starting scheduler'
  exec /opt/zammad/script/scheduler.rb run
else
  echo "Unknown argument $1"
  exit 1
fi