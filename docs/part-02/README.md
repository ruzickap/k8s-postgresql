# Zalando Postgres Operator

![Logo](https://raw.githubusercontent.com/zalando/postgres-operator/f2dddb0f2bea3951181566b30d4560b49c684d08/docs/diagrams/logo.png
"Logo")

The Postgres Operator enables highly-available [PostgreSQL](https://www.postgresql.org/)
clusters on Kubernetes (K8s) powered by [Patroni](https://github.com/zalando/spilo).
It is configured only through manifests to ease integration into automated CI/CD
pipelines with no access to Kubernetes directly.

## Operator features

* Rolling updates on Postgres cluster changes
* Volume resize without Pod restarts
* Cloning Postgres clusters
* Logical Backups to S3 Bucket
* Standby cluster from S3 WAL archive
* Configurable for non-cloud environments
* UI to create and edit Postgres cluster manifests

## PostgreSQL Operator features

* Supports PostgreSQL 9.6+
* Streaming replication cluster via Patroni
* Point-In-Time-Recovery with
  [pg_basebackup](https://www.postgresql.org/docs/11/app-pgbasebackup.html) /
  [WAL-E](https://github.com/wal-e/wal-e) via [Spilo](https://github.com/zalando/spilo)
* Preload libraries: [bg_mon](https://github.com/CyberDem0n/bg_mon),
  [pg_stat_statements](https://www.postgresql.org/docs/9.4/pgstatstatements.html),
  [pgextwlist](https://github.com/dimitri/pgextwlist),
  [pg_auth_mon](https://github.com/RafiaSabih/pg_auth_mon)
* InclUDES popular Postgres extensions such as
  [decoderbufs](https://github.com/debezium/postgres-decoderbufs),
  [hypopg](https://github.com/HypoPG/hypopg),
  [pg_cron](https://github.com/citusdata/pg_cron),
  [pg_partman](https://github.com/pgpartman/pg_partman),
  [pg_stat_kcache](https://github.com/powa-team/pg_stat_kcache),
  [pgq](https://github.com/pgq/pgq),
  [plpgsql_check](https://github.com/okbob/plpgsql_check),
  [postgis](https://postgis.net/),
  [set_user](https://github.com/pgaudit/set_user) and
  [timescaledb](https://github.com/timescale/timescaledb)

The Postgres Operator has been developed at Zalando and is being used in
production for over two years.

## Installation

Clone the repository

```bash
mkdir tmp
git -C tmp clone https://github.com/zalando/postgres-operator.git
git -C tmp/postgres-operator checkout v1.2.0
```

Install the PostgreSQL Operator:

```shell
helm install --name zalando --namespace zalando tmp/postgres-operator/charts/postgres-operator \
  --set configKubernetes.cluster_domain=${MY_DOMAIN} \
  --set configLoadBalancer.db_hosted_zone=db.${MY_DOMAIN} \
  --set
```
