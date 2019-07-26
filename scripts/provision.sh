#!/bin/bash
set -e

if [ "$UID" != "0" ]; then
	echo "This script needs root privileges."
	exit
fi

apt-get update && apt-get --yes install apt-utils autoconf curl libc6-dev-i386 libcurl4-openssl-dev libffi-dev libjpeg8-dev libssl-dev libtool libxml2-dev libxslt1-dev openssl pkg-config python3 python3-pip python-dev python-pip unzip zlib1g-dev

python -m pip install --upgrade pip
python3 -m pip install --upgrade pip

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

if [ -d '/opt/msf' ]; then
	cd msf
	git fetch && git pull
else
	# Get Metasploit
	git clone https://github.com/rapid7/metasploit-framework.git msf
	cd msf
fi

# Install PosgreSQL
curl -sSL https://github.com/REMnux/docker/raw/master/metasploit/scripts/db.sql --output /tmp/db.sql
/etc/init.d/postgresql start && su postgres -c "psql -f /tmp/db.sql"
curl -sSL https://github.com/REMnux/docker/raw/master/metasploit/conf/database.yml --output /opt/msf/config/database.yml

# RVM and dependencies
gpg --keyserver hkp://pool.sks-keyservers.net:80 --recv-keys 0x409B6B1796C275462A1703113804BB82D39DC0E3 0x7D2BAF1CF37B13E2069D6956105BD0E739499BDB
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
for i in `ls /opt/msf/tools/*/*`; do
	ln -f -s $i /usr/local/bin/
done

ln -f -s /opt/msf/msf* /usr/local/bin

# Starting script (DB + updates)
#/usr/local/bin/init.sh

#############
## Hackbox ##
#############

# Install required pip packages
python -m pip install capstone pefile configobj mitmproxy==0.16

# Install Django
python3 -m pip install django

# Copy scripts
cp -a scripts /
chown -R root:root /scripts
# TODO Move this line to top
apt-get --yes install netcat net-tools screen

sed -i "s/#startup_message off/startup_message off/" /etc/screenrc

# Create user `hx`
useradd -m -k /etc/skel -s /bin/bash hx || true

# Change directory to `hx` home
cd /home/hx

##############
## BDFProxy ##
##############

# Clone main repo
rm -rf bdfproxy.git
git clone https://github.com/secretsquirrel/bdfproxy.git bdfproxy.git

# Init sub-modules
cd bdfproxy.git
git submodule init && git submodule update
cd bdf
git pull origin master

# Build osslsigncode
cd osslsigncode
./autogen.sh && ./configure && make && make install

# Install aPLib
cd ../aPLib/example
gcc -c -I../lib/elf -m32 -Wall -O2 -s -o appack.o appack.c -v && gcc -m32 -Wall -O2 -s -o appack appack.o ../lib/elf/aplib.a -v && cp ./appack /usr/bin/appack

cd ../../..

sed -i -e 's/192.168.1.168/192.168.1.32/' -e 's/192.168.1.16/192.168.1.32/' bdfproxy.cfg

chown -R hx:hx .

cd /home/hx

# Clone this repo
rm -rf hackbox.git
sudo -u hx git clone https://github.com/quarantin/hackbox.git hackbox.git

echo 'Patching BDFProxy...'
cd bdfproxy.git
patch -p1 < ../hackbox.git/patches/bdf-proxy-no-root.patch

cd
echo ". /etc/profile.d/rvm.sh" >> .bashrc
