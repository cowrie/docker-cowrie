FROM debian:jessie-slim as builder
MAINTAINER Michel Oosterhof <michel@oosterhof.net>
RUN groupadd -r -g 1000 cowrie && \
    useradd -r -u 1000 -d /cowrie -m -g cowrie cowrie

# Set up Debian prereqs
RUN export DEBIAN_FRONTEND=noninteractive; \
    apt-get update && \
    apt-get install -y \
        -o APT::Install-Suggests=false \
        -o APT::Install-Recommends=false \
      python-pip \
      libssl-dev \
      libffi-dev \
      build-essential \
      libpython-dev \
      python2.7 \
      git \
      virtualenv \
      python-virtualenv \
      python-setuptools

    # Build a cowrie environment from github master HEAD.
RUN su - cowrie -c "\
      git clone http://github.com/micheloosterhof/cowrie /cowrie/cowrie-git && \
      cd /cowrie/cowrie-git && \
        virtualenv cowrie-env && \
        . cowrie-env/bin/activate && \
        pip install --upgrade pip && \
        pip install --upgrade cffi && \
        pip install --upgrade setuptools && \
        pip install --upgrade -r /cowrie/cowrie-git/requirements.txt"

FROM debian:jessie-slim
MAINTAINER Michel Oosterhof <michel@oosterhof.net>
RUN groupadd -r -g 1000 cowrie && \
    useradd -r -u 1000 -d /cowrie -m -g cowrie cowrie

RUN export DEBIAN_FRONTEND=noninteractive; \
    apt-get update && \
    apt-get install -y \
        -o APT::Install-Suggests=false \
        -o APT::Install-Recommends=false \
      libssl-dev \
      libffi-dev \
      python2.7

COPY --from=builder --chown=cowrie:cowrie /cowrie/cowrie-git /cowrie/cowrie-git

USER cowrie
WORKDIR /cowrie/cowrie-git
CMD [ "/cowrie/cowrie-git/bin/cowrie", "start", "-n" ]
EXPOSE 2222 2223
VOLUME [ "/cowrie/cowrie-git/etc", "/cowrie/cowrie-git/var" ]
