FROM ubuntu:jammy

# set version label
ARG BUILD_DATE
ARG VERSION
ARG OPENVPNAS_VERSION 
LABEL build_version="LeviNetIT version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="levinetit"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"

RUN \
 echo "**** instalare dependențe ****" && \
 apt-get update && \
 apt-get install -y \
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
    zip && \
 echo "**** instalare certificăte, wget, net-tools, gnupg ****" && \
 apt-get -y install ca-certificates wget net-tools gnupg && \
 wget https://as-repository.openvpn.net/as-repo-public.asc -qO /etc/apt/trusted.gpg.d/as-repository.asc && \
 echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/as-repository.asc] http://as-repository.openvpn.net/as/debian jammy main" > /etc/apt/sources.list.d/openvpn-as-repo.list && \
 apt update && apt -y install openvpn-as && \
 if [ -z ${OPENVPNAS_VERSION+x} ]; then \
    OPENVPNAS_VERSION=$(curl -sX GET http://as-repository.openvpn.net/as/debian/dists/jammy/main/binary-amd64/Packages.gz | gunzip -c \
    |grep -A 7 -m 1 "Package: openvpn-as" | awk -F ": " '/Version/{print $2;exit}');\
 fi && \
 echo "$OPENVPNAS_VERSION" > /version.txt && \
 echo "**** asigurați că directorul home pentru utilizatorul abc este setat la /config ****" && \
 usermod -d /config abc && \
 echo "**** creați utilizatorul admin și setați parola implicită pentru acesta ****" && \
 useradd -s /sbin/nologin admin && \
 echo "admin:password" | chpasswd && \
 apt-get upgrade -y && \
 rm -rf \
    /tmp/*

# adaogare fișiere locale
COPY /root /

# porturi și volume
EXPOSE 943/tcp 1194/udp 9443/tcp
VOLUME /config
