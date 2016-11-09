FROM debian
MAINTAINER Michel Oosterhof <michel@oosterhof.net>
RUN apt-get update && apt-get install -y \
    -o APT::Install-Suggests=false \
    git \
    python-dev \
    python-pip \
    python-virtualenv \
    libmpfr-dev \
    libssl-dev \
    libmpc-dev \
    libffi-dev 
#    build-essential \
#    libpython-dev
RUN groupadd cowrie
RUN useradd -d /cowrie -m -g cowrie cowrie

USER cowrie
WORKDIR /cowrie

RUN virtualenv venv
RUN git clone http://github.com/micheloosterhof/cowrie ~/cowrie-git
RUN . venv/bin/activate; pip install -r ~cowrie/cowrie-git/requirements.txt
RUN cp ~cowrie/cowrie-git/cowrie.cfg.dist ~cowrie/cowrie-git/cowrie.cfg

CMD XARGS="-n" /cowrie/cowrie-git/start.sh /cowrie/venv
# XARGS="-nodaemon" start.sh

VOLUME /cowrie/cowrie-git/var
#ENTRYPOINT ["cowrie"]
EXPOSE 2222
EXPOSE 2223
