# This Dockerfile contains two images, `builder` and `runtime`.
# `builder` contains all necessary code to build
# `runtime` is stripped down.

FROM debian:stretch-slim as builder
LABEL maintainer="Michel Oosterhof <michel@oosterhof.net>"

ENV COWRIE_GROUP=cowrie \
    COWRIE_USER=cowrie \
    COWRIE_HOME=/cowrie

RUN groupadd -r -g 1000 ${COWRIE_GROUP} && \
    useradd -r -u 1000 -d ${COWRIE_HOME} -m -g ${COWRIE_GROUP} ${COWRIE_USER}

# Set up Debian prereqs
RUN export DEBIAN_FRONTEND=noninteractive; \
    apt-get update && \
    apt-get install -y \
        -o APT::Install-Suggests=false \
        -o APT::Install-Recommends=false \
      python3-pip \
      libssl-dev \
      libffi-dev \
      python3-dev \
      python3-venv \
      python3 \
      gcc \
      git \
      build-essential \
      python3-virtualenv \
      libsnappy-dev \
      default-libmysqlclient-dev

# Build a cowrie environment from github master HEAD.

# pip assert tests no longer compatible with --no-cache-dir
# https://stackoverflow.com/questions/54315938/why-does-pipenv-fail-to-install-a-package-inside-a-docker-container
# --no-cache-dir should be enabled again in the future when this is fixed.

RUN su - ${COWRIE_USER} -c "\
      git clone --separate-git-dir=/tmp/cowrie.git http://github.com/cowrie/cowrie ${COWRIE_HOME}/cowrie-git && \
      cd ${COWRIE_HOME} && \
        python3 -m venv cowrie-env && \
        . cowrie-env/bin/activate && \
        pip install --no-cache-dir --upgrade pip && \
        pip install --upgrade cffi && \
        pip install --upgrade setuptools && \
        pip install --upgrade -r ${COWRIE_HOME}/cowrie-git/requirements.txt && \
        pip install --upgrade -r ${COWRIE_HOME}/cowrie-git/requirements-output.txt"

FROM debian:stretch-slim AS runtime
LABEL maintainer="Michel Oosterhof <michel@oosterhof.net>"

ENV COWRIE_GROUP=cowrie \
    COWRIE_USER=cowrie \
    COWRIE_HOME=/cowrie

RUN groupadd -r -g 1000 ${COWRIE_GROUP} && \
    useradd -r -u 1000 -d ${COWRIE_HOME} -m -g ${COWRIE_GROUP} ${COWRIE_USER}

RUN export DEBIAN_FRONTEND=noninteractive; \
    apt-get update && \
    apt-get install -y \
        -o APT::Install-Suggests=false \
        -o APT::Install-Recommends=false \
      libssl1.1 \
      libffi6 \
      procps \
      python3 && \
    ln -s /usr/bin/python3 /usr/local/bin/python

COPY --from=builder ${COWRIE_HOME} ${COWRIE_HOME}
RUN chown -R ${COWRIE_USER}:${COWRIE_GROUP} ${COWRIE_HOME}

ENV PATH=${COWRIE_HOME}/cowrie-git/bin:${PATH}
ENV STDOUT=yes

USER ${COWRIE_USER}
WORKDIR ${COWRIE_HOME}/cowrie-git
VOLUME [ "/cowrie/cowrie-git/var", "/cowrie/cowrie-git/etc" ]
ENTRYPOINT [ "cowrie" ]
CMD [ "start", "-n" ]
EXPOSE 2222 2223
