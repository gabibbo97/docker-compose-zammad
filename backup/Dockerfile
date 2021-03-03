ARG POSTGRES_VERSION
FROM postgres:${POSTGRES_VERSION}
RUN apt-get update -qq && apt-get install -y \
  wait-for-it \
  tar
#
# Scripts
#
COPY backup.sh /usr/local/bin/backup.sh
RUN chmod +x /usr/local/bin/backup.sh
#
# Entrypoint
#
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
