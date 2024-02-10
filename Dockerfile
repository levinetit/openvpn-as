FROM ghcr.io/linuxserver/baseimage-ubuntu:jammy

# set version label
ARG BUILD_DATE
ARG VERSION
ARG OPENVPNAS_VERSION 
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="levinetit"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"

RUN \
 echo "**** install dependencies ****" && \
 apt-get update && \
 apt-get install -y \
	bridge-utils \
 	ca-certificates \
	file \
	gnupg \
	iproute2 \
	iptables \
	libatm1 \
	libelf1 \
	libexpat1 \
	libip4tc0 \
	libip6tc0 \
	libiptc0 \
	liblzo2-2 \
	libmagic-mgc \
	libmagic1 \
	libmariadb3 \
	libmnl0 \
	libmpdec2 \
	libmysqlclient20 \
	libnetfilter-conntrack3 \
	libnfnetlink0 \
	libpcap0.8 \
	libpython3-stdlib \
	libpython3.6-minimal \
	libpython3.6-stdlib \
	libxtables12 \
	mime-support \
	multiarch-support \
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
	python3.6 \
 	python3.10 \
 	python3.6-minimal \
	python3.10-minimal \
	sqlite3 \
	systemctl \
 	unzip \
 	wget \
 	xz-utils \
  	zip && \
 echo "**** add openvpn-as repo ****" && \
 wget https://as-repository.openvpn.net/as-repo-public.asc -O /etc/apt/trusted.gpg.d/as-repository.asc && \
 echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/as-repository.asc] http://as-repository.openvpn.net/as/debian jammy main" > /etc/apt/sources.list.d/openvpn-as-repo.list && \
 apt update && apt -y install openvpn-as openvpn-dco-dkms && \
 if [ -z ${OPENVPNAS_VERSION+x} ]; then \
	OPENVPNAS_VERSION=$(curl -sX GET http://as-repository.openvpn.net/as/debian/dists/jammy/main/binary-amd64/Packages.gz | gunzip -c \
	|grep -A 7 -m 1 "Package: openvpn-as" | awk -F ": " '/Version/{print $2;exit}');\
 fi && \
 echo "$OPENVPNAS_VERSION" > /version.txt && \
 echo "**** ensure home folder for abc user set to /config ****" && \
 usermod -d /config abc && \
 echo "**** create admin user and set default password for it ****" && \
 useradd -s /sbin/nologin admin && \
 echo "admin:password" | chpasswd && \
 rm -rf \
	/tmp/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 943/tcp 1194/udp 1195/tcp
VOLUME /config
