FROM ghcr.io/linuxserver/baseimage-ubuntu:resolute

ARG BUILD_DATE
ARG VERSION
# Versiunea pachetului apt. Gol = ultima versiune din repo-ul oficial (upgrade automat la fiecare build).
# CI poate trimite o valoare exactă prin --build-arg pentru build-uri reproductibile.
ARG OPENVPNAS_PKG_VERSION=""
ARG OPENVPNAS_VERSION="latest"
ARG DEBIAN_FRONTEND="noninteractive"

LABEL build_version="LeviNetIT version:- ${VERSION} Build-date:- ${BUILD_DATE}" \
    maintainer="levinetit" \
    image_description="Imagine Docker pentru OpenVPN Access Server" \
    openvpn_version="${OPENVPNAS_VERSION}"

# Instalare dependențe și OpenVPN AS (Ubuntu 26.04 Resolute). Versiunea instalată se scrie în
# /version.txt: 30-config o folosește la instalarea/reinstalarea în /config la runtime.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    bridge-utils iproute2 iptables net-tools \
    ca-certificates curl wget gnupg unzip zip \
    python3 python3-lxml \
    sqlite3 && \
    wget -qO /etc/apt/trusted.gpg.d/as-repository.asc \
        https://packages.openvpn.net/as-repo-public.asc && \
    echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/as-repository.asc] https://packages.openvpn.net/as/debian resolute main" \
        > /etc/apt/sources.list.d/openvpn-as-repo.list && \
    apt-get update && \
    PKG_VERSION="${OPENVPNAS_PKG_VERSION:-$(apt-cache policy openvpn-as | awk '/Candidate:/{print $2}')}" && \
    test -n "${PKG_VERSION}" && test "${PKG_VERSION}" != "(none)" && \
    echo "Se instalează openvpn-as=${PKG_VERSION}" && \
    apt-get install -y openvpn-as="${PKG_VERSION}" && \
    echo "${PKG_VERSION}" > /version.txt && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY root/ /

RUN if [ -d /etc/cont-init.d ]; then chmod -v +x /etc/cont-init.d/*; fi && \
    if [ -d /etc/services.d ]; then chmod -v +x /etc/services.d/*/*; fi

EXPOSE 943/tcp 1194/udp 1195/tcp 1196/udp

VOLUME ["/config"]

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -fsk https://localhost:943/ -o /dev/null || \
        curl -fsk "https://$(hostname -i | cut -d' ' -f1):943/" -o /dev/null || exit 1
