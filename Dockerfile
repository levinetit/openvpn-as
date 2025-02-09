# Utilizarea imaginii de bază Ubuntu Jammy
FROM ghcr.io/linuxserver/baseimage-ubuntu:jammy

# Setarea etichetei de versiune
ARG BUILD_DATE
ARG OPENVPNAS_VERSION

# Instalare pachete necesare
RUN \
  apt-get update && \
  apt-get install -y \
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
  mailcap \
  mime-support \
  binutils-multiarch \
  mysql-common \
  net-tools \
  python3-certifi \
  python3-pkg-resources \
  python3-pymysql \
  python3-pyotp \
  python3-qrcode \
  python3-requests \
  python3-sqlalchemy \
  python3-sqlparse \
  python3-tempita \
  python3.10 \
  python3.10-minimal \
  systemctl \
  sqlite3 \
  unzip \
  zip \
  dmidecode \
  libc6 \
  libffi7 \
  libgcc-s1 \
  liblz4-1 \
  libssl3 \
  python3-typing-extensions && \
  echo "**** instalare certificăte, wget, net-tools, gnupg ****" && \
  wget https://as-repository.openvpn.net/as-repo-public.asc -qO /etc/apt/trusted.gpg.d/as-repository.asc && \
  echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/as-repository.asc] http://as-repository.openvpn.net/as/debian jammy main" > /etc/apt/sources.list.d/openvpn-as-repo.list && \
  apt-get update && apt-get -y install openvpn-as openvpn-dco-dkms && \
  if [ -z "${OPENVPNAS_VERSION+x}" ]; then \
    OPENVPNAS_VERSION=$(curl -sX GET http://as-repository.openvpn.net/as/debian/dists/jammy/main/binary-amd64/Packages.gz | gunzip -c | grep -A 7 -m 1 "Package: openvpn-as" | awk -F ": " '/Version/{print $2;exit}'); \
  fi && \
  echo "$OPENVPNAS_VERSION" > /version.txt && \
  rm -rf /tmp/*

RUN mv /usr/local/openvpn_as/lib/python/pyovpn-2.0-py3.10.egg /usr/local/openvpn_as/lib/python/pyovpn-2.0-py3.10.egg.bak

# Adăugare fișiere locale
COPY /root / 

# Setare porturi și volume
EXPOSE 943/tcp 1195/udp 1196/tcp
VOLUME /config
