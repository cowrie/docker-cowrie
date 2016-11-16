FROM debian
MAINTAINER Michel Oosterhof <michel@oosterhof.net>
ENV DEBIAN_FRONTEND noninteractive
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

RUN git clone -b develop http://github.com/micheloosterhof/cowrie /cowrie/cowrie-git
WORKDIR /cowrie/cowrie-git
RUN virtualenv cowrie-env
RUN . cowrie-env/bin/activate; pip install -r ~cowrie/cowrie-git/requirements.txt
RUN cp ~cowrie/cowrie-git/etc/cowrie.cfg.dist ~cowrie/cowrie-git/etc/cowrie.cfg

CMD /cowrie/cowrie-git/bin/cowrie start -n

VOLUME /cowrie/cowrie-git/var
VOLUME /cowrie/cowrie-git/etc
EXPOSE 2222
EXPOSE 2223
