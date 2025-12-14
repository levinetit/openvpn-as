# Utilizarea imaginii de bază Ubuntu cu versiune specifică
FROM ghcr.io/linuxserver/baseimage-ubuntu:jammy
# Argumente de build
ARG BUILD_DATE
ARG VERSION
ARG OPENVPNAS_VERSION
ARG DEBIAN_FRONTEND="noninteractive"
# Metadata labels
LABEL build_version="LeviNetIT version:- ${VERSION} Build-date:- ${BUILD_DATE}" \
      maintainer="levinetit" \
      image_description="Imagine Docker pentru OpenVPN Access Server" \
      openvpn_version="${OPENVPNAS_VERSION}" \
      version_details="OpenVPN-AS 3.0.0 cu configurare personalizată" \
      change_log="Actualizat cu pyovpn-2.0-py3.10.egg" \
      build_system="Docker 20.10.7"
# Instalare dependențe și OpenVPN-AS într-un singur layer
RUN echo "**** Instalare dependențe și OpenVPN-AS ****" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        # Networking tools
        bridge-utils \
        iproute2 \
        iptables \
        net-tools \
        libnetfilter-conntrack3 \
        libnfnetlink0 \
        libpcap0.8 \
        libiptc0 \
        libxtables12 \
        libmnl0 \
        # System libraries
        ca-certificates \
        curl \
        wget \
        gnupg \
        file \
        libmagic1 \
        libmagic-mgc \
        mime-support \
        systemctl \
        dmidecode \
        # Compression tools
        unzip \
        xz-utils \
        zip \
        # Core libraries
        libc6 \
        libffi7 \
        libgcc-s1 \
        liblz4-1 \
        libssl3 \
        libstdc++6 \
        libsasl2-2 \
        libsqlite3-0 \
        zlib1g \
        libatm1 \
        libelf1 \
        libexpat1 \
        liblzo2-2 \
        libcap-ng0 \
        libnl-3-200 \
        libnl-genl-3-200 \
        # Python 3.10 și dependențe
        python3 \
        python3-pip \
        python3-minimal \
        python3.10 \
        python3.10-minimal \
        libpython3-stdlib \
        libpython3.10-minimal \
        libpython3.10-stdlib \
        libmpdec3 \
        # Python packages
        python3-decorator \
        python3-ldap3 \
        python3-migrate \
        python3-mysqldb \
        python3-pbr \
        python3-pkg-resources \
        python3-pyasn1 \
        python3-six \
        python3-sqlalchemy \
        python3-sqlparse \
        python3-tempita \
        python3-netaddr \
        python3-arrow \
        python3-lxml \
        python3-constantly \
        python3-hyperlink \
        python3-automat \
        python3-service-identity \
        python3-cffi \
        python3-defusedxml \
        python3-typing-extensions \
        # Database
        mysql-common \
        libmariadb3 \
        libmysqlclient21 \
        sqlite3 \
        # Build tools
        binutils-multiarch && \
    # Adăugare repository OpenVPN-AS
    wget -qO /etc/apt/trusted.gpg.d/as-repository.asc \
        https://as-repository.openvpn.net/as-repo-public.asc && \
    echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/as-repository.asc] http://as-repository.openvpn.net/as/debian jammy main" \
        > /etc/apt/sources.list.d/openvpn-as-repo.list && \
    apt-get update && \
    # Instalare OpenVPN-AS
    apt-get install -y openvpn-as openvpn-dco-dkms && \
    # Salvare versiune
    if [ -z "${OPENVPNAS_VERSION+x}" ]; then \
        OPENVPNAS_VERSION=$(curl -sX GET http://as-repository.openvpn.net/as/debian/dists/jammy/main/binary-amd64/Packages.gz | \
            gunzip -c | grep -A 7 -m 1 "Package: openvpn-as" | awk -F ": " '/Version/{print $2;exit}'); \
    fi && \
    echo "$OPENVPNAS_VERSION" > /version.txt && \
    # Curățare cache și fișiere temporare
    apt-get clean && \
    rm -rf \
        /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/* \
        /var/cache/apt/archives/*
# Copiere fișier pyovpn personalizat
COPY pyovpn-2.0-py3.10.egg /tmp/pyovpn-2.0-py3.10.egg
# Backup și înlocuire pyovpn (opțional - decomentează dacă este necesar)
# RUN if [ -f /tmp/pyovpn-2.0-py3.10.egg ]; then \
#         mv /usr/local/openvpn_as/lib/python/pyovpn-2.0-py3.10.egg \
#            /usr/local/openvpn_as/lib/python/pyovpn-2.0-py3.10.egg.backup && \
#         cp /tmp/pyovpn-2.0-py3.10.egg /usr/local/openvpn_as/lib/python/ && \
#         rm /tmp/pyovpn-2.0-py3.10.egg; \
#     else \
#         echo "EROARE: pyovpn-2.0-py3.10.egg nu a fost găsit!" && exit 1; \
#     fi
# Copiere fișiere de configurare locale
COPY root/ /
# Setare permisiuni pentru scripturi de inițializare
RUN if [ -d /etc/cont-init.d ]; then chmod -v +x /etc/cont-init.d/*; fi && \
    if [ -d /etc/services.d ]; then chmod -v +x /etc/services.d/*/*; fi
# Expunere porturi
EXPOSE 943/tcp 1194/udp 1195/udp 1196/tcp
# Definire volume pentru persistență
VOLUME ["/config"]
# Health check pentru monitorizare
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f https://localhost:943/ || exit 1
