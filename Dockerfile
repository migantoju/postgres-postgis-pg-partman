FROM postgres:18.0 AS pg_partman_builder

ARG PARTMAN_VERSION=5.2.4
ENV DEBIAN_FRONTEND=noninteractive

USER root

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    wget \
    unzip \
    postgresql-server-dev-18 \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://github.com/pgpartman/pg_partman/archive/refs/tags/v${PARTMAN_VERSION}.zip -O pg_partman.zip \
    && unzip pg_partman.zip \
    && cd pg_partman-${PARTMAN_VERSION} \
    && make NO_BGW=1 install \
    && cd / \
    && rm -rf pg_partman.zip pg_partman-${PARTMAN_VERSION}

FROM postgres:18.0

USER root

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    postgis \
    postgresql-18-postgis-3 \
    postgresql-18-postgis-3-scripts \
    && rm -rf /var/lib/apt/lists/*

COPY --from=pg_partman_builder /usr/lib/postgresql/18/lib/pg_partman* /usr/lib/postgresql/18/lib/
COPY --from=pg_partman_builder /usr/share/postgresql/18/extension/pg_partman* /usr/share/postgresql/18/extension/

USER postgres
