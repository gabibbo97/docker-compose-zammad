ARG ELASTICSEARCH_VERSION
FROM docker.elastic.co/elasticsearch/elasticsearch:${ELASTICSEARCH_VERSION}
RUN /usr/share/elasticsearch/bin/elasticsearch-plugin install --batch ingest-attachment
