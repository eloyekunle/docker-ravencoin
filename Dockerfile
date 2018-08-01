FROM ubuntu:bionic

MAINTAINER Andreas Lingenhag <11538311+alingenhag@users.noreply.github.com>

# switch to root, let the entrypoint drop back to configured user
USER root
ENV USER ravencoin
ARG VERSION

RUN apt-get update && apt-get install -y software-properties-common \
 && apt-add-repository ppa:bitcoin/bitcoin \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    wget \
    git \
    libevent-dev \
    libboost-all-dev \
    libminiupnpc10 \
    libzmq5 \
    libdb4.8-dev \
    libdb4.8++-dev \
    libprotobuf-dev \
    protobuf-compiler

WORKDIR /tmp

#install su-exec
RUN git clone https://github.com/ncopa/su-exec.git \
 && cd su-exec && make && cp su-exec /usr/local/bin/ \
 && cd .. && rm -rf su-exec

# add user to the system
RUN useradd -d /home/"${USER}" -s /bin/sh -G users "${USER}"

RUN wget -O /tmp/Ravencoin-"${VERSION}".tar.gz "https://github.com/RavenProject/Ravencoin/releases/download/v${VERSION}/ravencoin-${VERSION}-$(arch)-linux-gnu.tar.gz" \
 && tar xzpvf Ravencoin-"${VERSION}".tar.gz \
 && mv ravencoin-"${VERSION}"/bin/* /usr/local/bin/ \
 && cd ~ \
 && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 8767

WORKDIR /home/"${USER}"

# add startup scripts
ADD ./scripts /usr/local/bin
ENTRYPOINT ["entrypoint.sh"]
CMD ["start-unprivileged.sh"]

