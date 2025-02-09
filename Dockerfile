@@ -1,5 +1,5 @@
# Utilizarea imaginii de bază Ubuntu Noble
FROM ghcr.io/linuxserver/baseimage-ubuntu:noble
# Utilizarea imaginii de bază Ubuntu
FROM ghcr.io/linuxserver/baseimage-ubuntu:jammy

# Setarea etichetei de versiune
ARG BUILD_DATE
@@ -26,20 +26,22 @@ RUN \
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
	libpython3.12-minimal \
	libpython3.12-stdlib \
	libpython3.10-minimal \
	libpython3.10-stdlib \
	libxtables12 \
 	mailcap \
	mime-support \
	binutils-multiarch \
	mysql-common \
	net-tools \
@@ -57,8 +59,8 @@ RUN \
	python3-sqlalchemy \
	python3-sqlparse \
	python3-tempita \
	python3.12 \
	python3.12-minimal \
	python3.10 \
	python3.10-minimal \
	systemctl \
	sqlite3 \
	unzip \
@@ -67,7 +69,7 @@ RUN \
	zip \
	dmidecode \
	libc6 \
	libffi8 \
	libffi7 \
	libgcc-s1 \
	liblz4-1 \
	libssl3 \
@@ -90,10 +92,10 @@ RUN \
	python3-typing-extensions && \
 echo "**** instalare certificăte, wget, net-tools, gnupg ****" && \
 wget https://as-repository.openvpn.net/as-repo-public.asc -qO /etc/apt/trusted.gpg.d/as-repository.asc && \
 echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/as-repository.asc] http://as-repository.openvpn.net/as/debian noble main" > /etc/apt/sources.list.d/openvpn-as-repo.list && \
 echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/as-repository.asc] http://as-repository.openvpn.net/as/debian jammy main" > /etc/apt/sources.list.d/openvpn-as-repo.list && \
 apt-get update && apt-get -y install openvpn-as openvpn-dco-dkms && \
 if [ -z "${OPENVPNAS_VERSION+x}" ]; then \
	OPENVPNAS_VERSION=$(curl -sX GET http://as-repository.openvpn.net/as/debian/dists/noble/main/binary-amd64/Packages.gz | gunzip -c | grep -A 7 -m 1 "Package: openvpn-as" | awk -F ": " '/Version/{print $2;exit}'); \
	OPENVPNAS_VERSION=$(curl -sX GET http://as-repository.openvpn.net/as/debian/dists/jammy/main/binary-amd64/Packages.gz | gunzip -c | grep -A 7 -m 1 "Package: openvpn-as" | awk -F ": " '/Version/{print $2;exit}'); \
 fi && \
 echo "$OPENVPNAS_VERSION" > /version.txt && \
 rm -rf /tmp/*
@@ -107,7 +109,7 @@ RUN mv /usr/local/openvpn_as/lib/python/pyovpn-2.0-py3.10.egg /usr/local/openvpn

# Adăugare fișiere locale
COPY /root / 
    
# Setare porturi și volume
EXPOSE 943/tcp 1194/udp 9443/tcp
VOLUME /config
