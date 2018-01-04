FROM ubuntu:xenial
MAINTAINER Andreas Lingenhag <11538311+alingenhag@users.noreply.github.com>

ARG USER_ID
ARG GROUP_ID
ARG VERSION

ENV USER ravencoin
ENV COMPONENT ${USER}
ENV HOME /${USER}

# add user with specified (or default) user/group ids
ENV USER_ID ${USER_ID:-1000}
ENV GROUP_ID ${GROUP_ID:-1000}

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -g ${GROUP_ID} ${USER} \
	&& useradd -u ${USER_ID} -g ${USER} -s /bin/bash -m -d ${HOME} ${USER}

# grab gosu for easy step-down from root
ENV GOSU_VERSION 1.7
RUN set -x \
	&& apt-get update && apt-get install -y --no-install-recommends \
		ca-certificates \
                libevent-dev \
		libboost-all-dev \
		libminiupnpc10 \
		libzmq5 \
		software-properties-common \
		wget \
		qt5-default \
		libqt5network5 \
		libqt5widgets5 \
        && add-apt-repository ppa:bitcoin/bitcoin \
	&& apt-get update && apt-get -y install libdb4.8-dev libdb4.8++-dev libqrencode3 \
	&& wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
	&& wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
	&& gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
	&& rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu \
	&& gosu nobody true

ENV VERSION ${VERSION:-2.2.1}
RUN mkdir -p /opt/ravencoin/bin \
    && wget -O /opt/ravencoin/bin/ravend "https://github.com/RavenProject/Ravencoin/raw/master/binaries/release/linux/ubuntu_16.04/ravend" \
    && wget -O /opt/ravencoin/bin/raven-cli "https://github.com/RavenProject/Ravencoin/raw/master/binaries/release/linux/ubuntu_16.04/raven-cli" \
    && wget -O /opt/ravencoin/bin/raven-qt "https://github.com/RavenProject/Ravencoin/raw/master/binaries/release/linux/ubuntu_16.04/raven-qt" \
    && wget -O /opt/ravencoin/bin/raven-tx "https://github.com/RavenProject/Ravencoin/raw/master/binaries/release/linux/ubuntu_16.04/raven-tx" \
    && cd /opt/ravencoin/bin \
    && chmod +x * 

EXPOSE 8767 8767

RUN set -x && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

VOLUME ["${HOME}"]
WORKDIR ${HOME}
ADD ./bin /usr/local/bin
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["start-unprivileged.sh"]
