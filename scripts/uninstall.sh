#!/bin/bash
set -e

if [ "$UID" != "0" ]; then
	echo "This script needs root privileges."
	exit
fi

################
## Metasploit ##
################

if [ -d '/opt/msf' ]; then

	for i in `ls /opt/msf/tools/*/*`; do
		NAME="$(basename $i)"
		rm -f "/usr/local/bin/${NAME}"
	done

	rm -rf /opt/msf /usr/local/bin/msf*

fi

rm -f /root/.tmux.conf /usr/local/bin/init.sh /opt/msf/config/database.yml

##############
## BDFProxy ##
##############

cd /home/hx

rm -rf hackbox.git bdfproxy.git

apt-get --yes remove netcat net-tools screen

apt-get --yes remove apt-utils autoconf curl libc6-dev-i386 libcurl4-openssl-dev libffi-dev libjpeg8-dev libssl-dev libtool libxml2-dev libxslt1-dev openssl pkg-config python3 python3-pip python-dev python-pip unzip zlib1g-dev

# Base packages
apt-get --yes remove \
  build-essential zlib1g-dev \
  libxml2 libxml2-dev libxslt-dev locate curl \
  libreadline6-dev libcurl4-openssl-dev \
  libssl-dev libyaml-dev openssl autoconf libtool \
  ncurses-dev bison curl wget xsel postgresql \
  postgresql-contrib postgresql-client libpq-dev \
  libapr1 libaprutil1 libsvn1 \
  libpcap-dev libsqlite3-dev libgmp3-dev \
  nasm tmux vim nmap inotify-tools

