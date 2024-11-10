ARG TSVERSION=1.76.6
ARG SC_VERSION=0.2.30
ARG OM_VERSION=2.5.1

FROM adguard/adguardhome:latest

ARG TSVERSION
ARG SC_VERSION
ARG OM_VERSION
ARG SC_FILE=supercronic-linux-amd64
ARG TSFILE=tailscale_${TSVERSION}_amd64.tgz
ARG OM_FILE=overmind-v${OM_VERSION}-linux-amd64.gz

WORKDIR /
COPY . .

RUN apk add --no-cache \
    tar \
    gzip \
    restic \
    ca-certificates \
    openssl \
    tzdata \
    iptables \
    ip6tables \
    iputils-ping \
    tmux \
    msmtp \
    mailx \
    tini \
    && wget https://pkgs.tailscale.com/stable/${TSFILE} \
    && tar xzf ${TSFILE} --strip-components=1 \
    && rm -rf ${TSFILE} \
    && mv tailscaled /usr/local/bin/tailscaled \
    && mv tailscale /usr/local/bin/tailscale \
    && wget https://github.com/aptible/supercronic/releases/download/v${SC_VERSION}/${SC_FILE} \
    && chmod +x ${SC_FILE} \
    && mv ${SC_FILE} /usr/local/bin/supercronic \
    && wget https://github.com/DarthSim/overmind/releases/download/v${OM_VERSION}/${OM_FILE} \
    && gunzip -d ${OM_FILE} \
    && chmod +x overmind-v${OM_VERSION}-linux-amd64 \
    && mv overmind-v${OM_VERSION}-linux-amd64 /usr/local/bin/overmind \
    && rm -rf ${OM_FILE} \
    && apk del tar gzip \
    && chmod +x /entrypoint.sh

HEALTHCHECK \
    --interval=30s \
    --timeout=10s \
    --retries=3 \
    CMD [ "/opt/adguardhome/scripts/healthcheck.sh" ]

ENTRYPOINT [ "/sbin/tini", "-s", "--", "/entrypoint.sh" ]
USER root
