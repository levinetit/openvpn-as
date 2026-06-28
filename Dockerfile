FROM ghcr.io/linuxserver/baseimage-ubuntu:resolute

ARG BUILD_DATE
ARG VERSION
ARG OPENVPNAS_VERSION="3.2.1"
# Versiunea exactă a pachetului apt (folosită la build ȘI la instalarea/reinstalarea în /config la runtime)
ARG OPENVPNAS_PKG_VERSION="3.2.1-d0affc91-Ubuntu26"
ARG DEBIAN_FRONTEND="noninteractive"

LABEL build_version="LeviNetIT version:- ${VERSION} Build-date:- ${BUILD_DATE}" \
    maintainer="levinetit" \
    image_description="Imagine Docker pentru OpenVPN Access Server" \
    openvpn_version="${OPENVPNAS_VERSION}"

# Instalare dependențe și OpenVPN AS 3.2.1 (Ubuntu 26.04 Resolute, Python 3.14)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    bridge-utils iproute2 iptables net-tools \
    ca-certificates curl wget gnupg unzip zip \
    python3 python3-lxml \
    sqlite3 && \
    wget -qO /etc/apt/trusted.gpg.d/as-repository.asc \
        https://as-repository.openvpn.net/as-repo-public.asc && \
    echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/as-repository.asc] http://packages.openvpn.net/as/debian resolute main" \
        > /etc/apt/sources.list.d/openvpn-as-repo.list && \
    apt-get update && \
    apt-get install -y openvpn-as="${OPENVPNAS_PKG_VERSION}" && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Egg-uri patched (concurrent_connections = 8888). py3.14 = folosit pe Ubuntu 26.04; py3.12 rezervă.
# Se păstrează o copie în /defaults/pyovpn-eggs/ care SUPRAVIEȚUIEȘTE reinstalării OAS la runtime
# (30-config face `rm -rf /usr/local/openvpn_as`); scriptul 35-egg-patch le re-aplică după instalare.
COPY pyovpn-2.0-py3.12.egg /defaults/pyovpn-eggs/pyovpn-2.0-py3.12.egg
COPY pyovpn-2.0-py3.14.egg /defaults/pyovpn-eggs/pyovpn-2.0-py3.14.egg
COPY pyovpn-2.0-py3.12.egg /usr/local/openvpn_as/lib/python/pyovpn-2.0-py3.12.egg
COPY pyovpn-2.0-py3.14.egg /usr/local/openvpn_as/lib/python/pyovpn-2.0-py3.14.egg

# Activează instalarea/persistența OpenVPN AS în volumul /config la runtime (vezi 30-config).
# 30-config folosește `apt --reinstall` ca să populeze /config chiar dacă pachetul e deja în imagine.
RUN echo "${OPENVPNAS_PKG_VERSION}" > /version.txt

COPY root/ /

RUN if [ -d /etc/cont-init.d ]; then chmod -v +x /etc/cont-init.d/*; fi && \
    if [ -d /etc/services.d ]; then chmod -v +x /etc/services.d/*/*; fi

EXPOSE 943/tcp 1194/udp 1195/tcp 1196/udp

VOLUME ["/config"]

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -fsk https://localhost:943/ -o /dev/null || exit 1
