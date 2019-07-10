#!/bin/bash
set -e

if [ "$UID" != "0" ]; then
	echo "This script needs root privileges."
	exit
fi

apt-get update && apt-get --yes install apt-utils autoconf curl git libc6-dev-i386 libcurl4-openssl-dev libffi-dev libjpeg8-dev libssl-dev libtool libxml2-dev libxslt1-dev openssl pkg-config python3 python-dev python-pip unzip zlib1g-dev

pip install --upgrade pip

##############
## BDFProxy ##
##############

# Install required pip packages
python -m pip install capstone pefile configobj mitmproxy==0.16

# Clone main repo
cd /
git clone https://github.com/secretsquirrel/bdfproxy

# Init sub-modules
cd /bdfproxy
git submodule init && git submodule update
cd /bdfproxy/bdf/
git pull origin master

# Build osslsigncode
cd /bdfproxy/bdf/osslsigncode
./autogen.sh && ./configure && make && make install

# Install aPLib
cd /bdfproxy/bdf/aPLib/example
gcc -c -I../lib/elf -m32 -Wall -O2 -s -o appack.o appack.c -v && gcc -m32 -Wall -O2 -s -o appack appack.o ../lib/elf/aplib.a -v && cp ./appack /usr/bin/appack

cd /bdfproxy

sed -i -e 's/192.168.1.168/192.168.1.32/' -e 's/192.168.1.16/192.168.1.32/' bdfproxy.cfg

################
## Metasploit ##
################

cd /opt

# Base packages
apt-get -y install \
  git build-essential zlib1g zlib1g-dev \
  libxml2 libxml2-dev libxslt-dev locate curl \
  libreadline6-dev libcurl4-openssl-dev git-core \
  libssl-dev libyaml-dev openssl autoconf libtool \
  ncurses-dev bison curl wget xsel postgresql \
  postgresql-contrib postgresql-client libpq-dev \
  libapr1 libaprutil1 libsvn1 \
  libpcap-dev libsqlite3-dev libgmp3-dev \
  nasm tmux vim nmap inotify-tools

# startup script and tmux configuration file
curl -sSL https://github.com/REMnux/docker/raw/master/metasploit/scripts/init.sh --output /usr/local/bin/init.sh && \
  chmod a+xr /usr/local/bin/init.sh && \
  curl -sSL https://github.com/REMnux/docker/raw/master/metasploit/conf/tmux.conf --output /root/.tmux.conf

# Get Metasploit
git clone https://github.com/rapid7/metasploit-framework.git msf
cd msf

# Install PosgreSQL
curl -sSL https://github.com/REMnux/docker/raw/master/metasploit/scripts/db.sql --output /tmp/db.sql
/etc/init.d/postgresql start && su postgres -c "psql -f /tmp/db.sql"
curl -sSL https://github.com/REMnux/docker/raw/master/metasploit/conf/database.yml --output /opt/msf/config/database.yml

# RVM and dependencies
gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
curl -sSL https://rvm.io/mpapis.asc | gpg --import
curl -L https://get.rvm.io | bash -s stable 
/bin/bash -l -c ". /etc/profile.d/rvm.sh && rvm install 2.6.2"
/bin/bash -l -c ". /etc/profile.d/rvm.sh && rvm requirements"
/bin/bash -l -c ". /etc/profile.d/rvm.sh && rvm install 2.6.3"
/bin/bash -l -c ". /etc/profile.d/rvm.sh && rvm use 2.6.3 --default"
/bin/bash -l -c ". /etc/profile.d/rvm.sh && gem install bundler"
/bin/bash -l -c ". /etc/profile.d/rvm.sh && which bundle"
/bin/bash -l -c ". /etc/profile.d/rvm.sh && bundle config --global jobs $(expr $(cat /proc/cpuinfo | grep vendor_id | wc -l) - 1)"
/bin/bash -l -c ". /etc/profile.d/rvm.sh && bundle install"

# Symlink tools to $PATH
for i in `ls /opt/msf/tools/*/*`; do ln -s $i /usr/local/bin/; done
ln -s /opt/msf/msf* /usr/local/bin

# Starting script (DB + updates)
#/usr/local/bin/init.sh

############
## Django ##
############

# Install Django
python3 -m pip install django

#############
## Scripts ##
#############

cp -a scripts /
chown -R root:root /scripts
