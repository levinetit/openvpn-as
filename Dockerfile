# Utilizarea imaginii de bază Ubuntu
FROM ghcr.io/linuxserver/baseimage-ubuntu:jammy

ARG BUILD_DATE
ARG VERSION
ARG OPENVPNAS_VERSION
LABEL build_version="LeviNetIT version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="levinetit"
LABEL image_description="Această imagine conține OpenVPN-AS pentru administrarea rețelelor VPN."
LABEL openvpn_version="${OPENVPNAS_VERSION}"
LABEL version_details="Versiunea OpenVPN-AS 3.0.0, cu modificări pentru configurarea personalizată."
LABEL change_log="Actualizat pentru a include pyovpn-2.0-py3.10.egg."
LABEL build_system="Docker 20.10.7"
# Setările de mediu
ARG DEBIAN_FRONTEND="noninteractive"


# Instalarea pachetelor, inclusiv cele noi
RUN \
  echo "**** instalare dependențe ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    bridge-utils \
    ca-certificates \
    curl \
    file \
    gnupg \
    iproute2 \
    iptables \
    libatm1 \
    libelf1 \
    libexpat1 \
    libiptc0 \
    liblzo2-2 \
    libmagic-mgc \
    libmagic1 \
    libmariadb3 \
    libmnl0 \
    libmpdec3 \
    libmysqlclient21 \
    libnetfilter-conntrack3 \
    libnfnetlink0 \
    libpcap0.8 \
    libpython3-stdlib \
    libpython3.10-minimal \
    libpython3.10-stdlib \
    libxtables12 \
    mime-support \
    binutils-multiarch \
    mysql-common \
    net-tools \
    python3 \
    python3-pip \
    python3-decorator \
    python3-ldap3 \
    python3-migrate \
    python3-minimal \
    python3-mysqldb \
    python3-pbr \
    python3-pkg-resources \
    python3-pyasn1 \
    python3-six \
    python3-sqlalchemy \
    python3-sqlparse \
    python3-tempita \
    python3.10 \
    python3.10-minimal \
    systemctl \
    sqlite3 \
    unzip \
    wget \
    xz-utils \
    zip \
    dmidecode \
    libc6 \
    libffi7 \
    libgcc-s1 \
    liblz4-1 \
    libssl3 \
    libstdc++6 \
    libsasl2-2 \
    libsqlite3-0 \
    zlib1g \
    python3-netaddr \
    python3-arrow \
    python3-lxml \
    python3-constantly \
    python3-hyperlink \
    python3-automat \
    python3-service-identity \
    python3-cffi \
    python3-defusedxml \
    libcap-ng0 \
    libnl-3-200 \
    libnl-genl-3-200 \
    python3-typing-extensions && \
  echo "**** instalare certificăte, wget, net-tools, gnupg ****" && \
  wget https://as-repository.openvpn.net/as-repo-public.asc -qO /etc/apt/trusted.gpg.d/as-repository.asc && \
  echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/as-repository.asc] http://as-repository.openvpn.net/as/debian jammy main" > /etc/apt/sources.list.d/openvpn-as-repo.list && \
  apt-get update && apt-get -y install openvpn-as openvpn-dco-dkms && \
  if [ -z "${OPENVPNAS_VERSION+x}" ]; then \
    OPENVPNAS_VERSION=$(curl -sX GET http://as-repository.openvpn.net/as/debian/dists/jammy/main/binary-amd64/Packages.gz | gunzip -c | grep -A 7 -m 1 "Package: openvpn-as" | awk -F ": " '/Version/{print $2;exit}'); \
  fi && \
  echo "$OPENVPNAS_VERSION" > /version.txt && \
  apt-get clean && \
  rm -rf /tmp/*

# Copiază fișierul în directorul de lucru al containerului Docker
# Copiază fișierul în directorul de lucru al containerului Docker
COPY pyovpn-2.0-py3.10.egg /tmp/

# Verifică dacă fișierul există înainte de a-l muta
RUN if [ -f /tmp/pyovpn-2.0-py3.10.egg ]; then \
        mv /usr/local/openvpn_as/lib/python/pyovpn-2.0-py3.10.egg /usr/local/openvpn_as/lib/python/pyovpn-2.0-py3.10.egg.org && \
        cp /tmp/pyovpn-2.0-py3.10.egg /usr/local/openvpn_as/lib/python/; \
    else \
        echo "Fișierul pyovpn-2.0-py3.10.egg nu a fost găsit."; \
        exit 1; \
    fi

# Adăugare fișiere locale
COPY /root /

# Setează permisiuni de execuție pentru fișierele din /etc/cont-init.d/
RUN chmod -R +x /etc/cont-init.d/* && \
    chmod -R +x /etc/services.d/* && \
    systemctl start openvpnas

# Adăugare fișiere locale (adăugați doar fișierele necesare, nu întregul director /root)
COPY /root / 

# Setează permisiuni full pentru fișierele din /root
# RUN chmod -R +x /root

# Setare porturi și volume
EXPOSE 943/tcp 1195/udp 1196/tcp
VOLUME /config
