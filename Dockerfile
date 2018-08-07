FROM debian:stretch-slim as builder
MAINTAINER Michel Oosterhof <michel@oosterhof.net>
RUN groupadd -r -g 1000 cowrie && \
    useradd -r -u 1000 -d /cowrie -m -g cowrie cowrie

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
      python3 \
      gcc \
      git \
      virtualenv \
      python3-virtualenv

# Build a cowrie environment from github master HEAD.
RUN su - cowrie -c "\
      git clone --separate-git-dir=/tmp/cowrie.git http://github.com/micheloosterhof/cowrie /cowrie/cowrie-git && \
      cd /cowrie && \
        virtualenv -p python3 cowrie-env && \
        . cowrie-env/bin/activate && \
        pip install --upgrade pip && \
        pip install --upgrade cffi && \
        pip install --upgrade setuptools && \
        pip install --upgrade -r /cowrie/cowrie-git/requirements.txt"

FROM debian:stretch-slim
MAINTAINER Michel Oosterhof <michel@oosterhof.net>
RUN groupadd -r -g 1000 cowrie && \
    useradd -r -u 1000 -d /cowrie -m -g cowrie cowrie

RUN export DEBIAN_FRONTEND=noninteractive; \
    apt-get update && \
    apt-get install -y \
        -o APT::Install-Suggests=false \
        -o APT::Install-Recommends=false \
      libssl1.1 \
      libffi6 \
      python3

COPY --chown=cowrie:cowrie --from=builder /cowrie /cowrie

USER cowrie
WORKDIR /cowrie/cowrie-git
CMD [ "/cowrie/cowrie-git/bin/cowrie", "start", "-n" ]
EXPOSE 2222 2223
