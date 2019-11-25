# This Dockerfile contains three images, `base-image`, `builder` and `runtime`
# `base-image` contains all necessary prereqs and variables for build and runtime
# `builder` contains all necessary code to build
# `runtime` is stripped down

FROM alpine:latest AS base-image
LABEL maintainer="Michel Oosterhof <michel@oosterhof.net>"

ENV COWRIE_VERSION=v2.0.2 \
    COWRIE_GROUP=cowrie \
    COWRIE_USER=cowrie \
    COWRIE_HOME=/cowrie \
    PATH=/cowrie/cowrie-git/bin:$PATH \
    STDOUT=yes

RUN addgroup -S -g 1000 $COWRIE_GROUP \
    && adduser -S -u 1000 -h $COWRIE_HOME -G $COWRIE_GROUP $COWRIE_USER \
    && apk add --no-cache \
        python3 \
        procps \
        bash

FROM base-image AS builder

# Set up prereqs
RUN apk --no-cache add \
    mariadb-connector-c-dev \
    libffi-dev \
    openssl-dev \
    snappy-dev \
    musl-dev \
    python3-dev \
    gcc \
    g++

USER $COWRIE_USER

RUN mkdir -v $COWRIE_HOME/cowrie-git \
    && wget -O- https://github.com/cowrie/cowrie/archive/$COWRIE_VERSION.tar.gz \
        | (tar -xz --strip-components=1 -C $COWRIE_HOME/cowrie-git) \
    && python3 -m venv $COWRIE_HOME/cowrie-env \
    && . $COWRIE_HOME/cowrie-env/bin/activate \
    && pip install --no-cache-dir --upgrade \
        -r $COWRIE_HOME/cowrie-git/requirements.txt \
        -r $COWRIE_HOME/cowrie-git/requirements-output.txt \
        cffi \
        setuptools \
    && rm -rf $COWRIE_HOME/.cache

FROM base-image

COPY --from=builder $COWRIE_HOME $COWRIE_HOME

USER $COWRIE_USER

WORKDIR $COWRIE_HOME/cowrie-git

VOLUME [ "/cowrie/cowrie-git/var", "/cowrie/cowrie-git/etc" ]

CMD [ "cowrie", "start", "-n" ]

EXPOSE 2222 2223
