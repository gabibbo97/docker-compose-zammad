# docker-compose-zammad

Set up quickly a Zammad 3.6.0 helpdesk with TLS via docker-compose.

## Getting started

1. Install `docker` and `docker-compose`
2. [Set up your .env file](#configuring)
3. `docker-compose up --build`

## Configuring

All configuration is done via the `.env` file.

An [example](.env.example) has been provided.

| Variable              | Description                                   | Default                      |
| :-------------------- | :-------------------------------------------- | :--------------------------- |
| BACKUP_ENABLED        | Enable backups                                | true                         |
| BACKUP_HOLD_DAYS      | How many days of backups are held             | 7                            |
| BACKUP_INTERVAL_HOURS | How many hours between backups                | 12                           |
| HOST                  | The hostname of the server                    | zammad.localhost             |
| HTTP_PORT             | The port on which insecure traffic is exposed | 8000                         |
| HTTPS_PORT            | The port on which secure traffic is exposed   | 8443                         |
| ENABLE_TLS            | Enable TLS certificate via ACME               | false                        |
| LETSENCRYPT_API       | The URL of the ACME endpoint                  | Letsencrypt staging endpoint |
| LETSENCRYPT_EMAIL     | The email for the ACME endpoint               | admin@example.com            |
| ZAMMAD_VERSION        | The version of Zammad to use                  | 3.6.0                        |
| RUBY_VERSION          | The version of Ruby to use                    | 2.6.6                        |
| POSTGRES_VERSION      | The version of PostgreSQL to use              | 13.2                         |
| ELASTICSEARCH_VERSION | The version of ElasticSearch to use           | 7.11.1                       |
| TRAEFIK_VERSION       | The version of Traefik to use                 | 2.4.6                        |
| INSECURE_OPENSSL      | Use weaker OpenSSL defaults                   | n                            |

## Troubleshooting

### Obtaining a valid certificate

Replace the `LETSENCRYPT_API` url with the production Letsencrypt url.

If using the defaults, remove `-staging` from the provided address.

### Handling SSL errors while connecting to email hosts

Set `INSECURE_OPENSSL` to `y`.

__BE AWARE THAT THIS SHOULD BE A TEMPORARY WORKAROUND, NOTIFY YOUR PROVIDER ABOUT THIS__
