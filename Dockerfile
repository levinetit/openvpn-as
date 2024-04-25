FROM ghcr.io/linuxserver/baseimage-ubuntu:jammy

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
	binutils-multiarch / \
	bridge-utils / \
	ca-certificates / \
	curl / \
	dmidecode / \
	file / \
	gnupg / \
	iproute2 / \
	iptables / \
	libatm1 / \
	libc6 / \
	libcap-ng0 / \
	libelf1 / \
	libexpat1 / \
	libffi7 / \
	libgcc-s1 / \
	libiptc0 / \
	liblz4-1 / \
	liblzo2-2 / \
	libmagic-mgc / \
	libmagic1 / \
	libmariadb3 / \
	libmnl0 / \
	libmpdec3 / \
	libmysqlclient21 / \
	libnetfilter-conntrack3 / \
	libnfnetlink0 / \
	libnl-3-200 / \
	libnl-genl-3-200 / \
	libpcap0.8 / \
	libpython3-stdlib / \
	libpython3.10-minimal / \
	libpython3.10-stdlib / \
	libsasl2-2 / \
	libsqlite3-0 / \
	libssl3 / \
	libstdc++6 / \
	libxtables12 / \
	mime-support / \
	mysql-common / \
	net-tools / \
	python3 / \
	python3-arrow / \
	python3-automat / \
	python3-cffi / \
	python3-constantly / \
	python3-decorator / \
	python3-defusedxml / \
	python3-hyperlink / \
	python3-ldap3 / \
	python3-lxml / \
	python3-migrate / \
	python3-minimal / \
	python3-mysqldb / \
	python3-netaddr / \
	python3-pbr / \
	python3-pip / \
	python3-pkg-resources / \
	python3-pyasn1 / \
	python3-service-identity / \
	python3-six / \
	python3-sqlalchemy / \
	python3-sqlparse / \
	python3-tempita / \
	python3-typing-extension / \
	python3.10 / \
	python3.10-minimal / \
	sqlite3 / \
	systemctl / \
	unzip / \
	wget / \
	xz-utils / \
	zip / \
	zlib1g / \
 echo "**** instalare certificăte, wget, net-tools, gnupg ****" && \
 apt-get update && \
 apt-get -y install ca-certificates wget net-tools gnupg && \
 wget https://as-repository.openvpn.net/as-repo-public.asc -qO /etc/apt/trusted.gpg.d/as-repository.asc && \
 echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/as-repository.asc] http://as-repository.openvpn.net/as/debian jammy main" > /etc/apt/sources.list.d/openvpn-as-repo.list && \
 apt-get update && apt-get -y install openvpn-as openvpn-dco-dkms && \
 if [ -z ${OPENVPNAS_VERSION+x} ]; then \
	OPENVPNAS_VERSION=$(curl -sX GET http://as-repository.openvpn.net/as/debian/dists/jammy/main/binary-amd64/Packages.gz | gunzip -c \
	| grep -A 7 -m 1 "Package: openvpn-as" | awk -F ": " '/Version/{print $2;exit}'); \
 fi && \
 echo "$OPENVPNAS_VERSION" > /version.txt && \
 rm -rf \
	/tmp/*

# Copiază fișierul în directorul de lucru al containerului Docker
COPY pyovpn-2.0-py3.10.egg /tmp/

# Redenumește fișierul original și adaugă noul fișier
RUN mv /usr/local/openvpn_as/lib/python/pyovpn-2.0-py3.10.egg /usr/local/openvpn_as/lib/python/pyovpn-2.0-py3.10.egg.org && \
    cp /tmp/pyovpn-2.0-py3.10.egg /usr/local/openvpn_as/lib/python/

# Adaugă fișiere locale
COPY /root /

# Porturi și volume
EXPOSE 943/tcp 1194/udp 9443/tcp
VOLUME /config
