FROM ghcr.io/linuxserver/baseimage-ubuntu:noble

ARG BUILD_DATE
ARG VERSION
ARG OPENVPNAS_VERSION="3.1.0"
ARG DEBIAN_FRONTEND="noninteractive"

LABEL build_version="LeviNetIT version:- ${VERSION} Build-date:- ${BUILD_DATE}" \
    maintainer="levinetit" \
    image_description="Imagine Docker pentru OpenVPN Access Server" \
    openvpn_version="${OPENVPNAS_VERSION}"

# Instalare dependențe și OpenVPN AS 3.1.0 (Ubuntu 24.04 Noble, Python 3.12)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    bridge-utils iproute2 iptables net-tools \
    ca-certificates curl wget gnupg unzip zip \
    python3 python3-lxml \
    sqlite3 && \
    wget -qO /etc/apt/trusted.gpg.d/as-repository.asc \
        https://as-repository.openvpn.net/as-repo-public.asc && \
    echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/as-repository.asc] http://as-repository.openvpn.net/as/debian noble main" \
        > /etc/apt/sources.list.d/openvpn-as-repo.list && \
    apt-get update && \
    apt-get install -y openvpn-as=3.1.0-e22fe316-Ubuntu24 && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copiere egg-uri patched (concurrent_connections = 8888, compatibile Python 3.10 + 3.12)
COPY pyovpn-2.0-py3.10.egg /usr/local/openvpn_as/lib/python/pyovpn-2.0-py3.10.egg
COPY pyovpn-2.0-py3.12.egg /usr/local/openvpn_as/lib/python/pyovpn-2.0-py3.12.egg

COPY root/ /

RUN if [ -d /etc/cont-init.d ]; then chmod -v +x /etc/cont-init.d/*; fi && \
    if [ -d /etc/services.d ]; then chmod -v +x /etc/services.d/*/*; fi

EXPOSE 943/tcp 1194/udp 1195/tcp 1196/udp

VOLUME ["/config"]

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -fsk https://localhost:943/ -o /dev/null || exit 1
