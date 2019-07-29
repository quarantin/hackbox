#!/bin/bash
set -e

HX=hx
HOST=hackbox.local

if [ "$UID" != "0" ]; then
	echo "This script needs root privileges."
	exit
fi


############
## System ##
############

INSTALL_SYSTEM(){

# Create dedicated hx user
getent passwd ${HX} &>/dev/null || useradd -m -k /etc/skel -s /bin/bash ${HX}

# Install needed system packages
apt-get update && apt-get --yes install apt-utils autoconf avahi-daemon bison build-essential curl git git-core inotify-tools libapr1 libaprutil1 libc6-dev-i386 libcurl4-openssl-dev libffi-dev libgmp3-dev libjpeg8-dev libpcap-dev libpq-dev libreadline6-dev libsqlite3-dev libssl-dev libsvn1 libtool libxml2 libxml2-dev libxslt1-dev libyaml-dev locate nasm ncurses-dev netcat net-tools nmap openssl pkg-config postgresql postgresql-client postgresql-contrib python3 python3-pip python-dev python-pip screen unzip vim wget xsel zlib1g zlib1g-dev

# Upgrade pip for both python2 and python3
sudo -u ${HX} python -m pip install --upgrade pip
sudo -u ${HX} python3 -m pip install --upgrade pip

# Disable GNU screen startup message because it's annoying
sed -i "s/#startup_message off/startup_message off/" /etc/screenrc

}


#############
## Hackbox ##
#############

INSTALL_HACKBOX(){

cd /home/${HX}

# Clone this repo
rm -rf hackbox.git
sudo -u ${HX} git clone https://github.com/quarantin/hackbox.git hackbox.git
cd hackbox.git
./scripts/set-hostname.sh ${HOST}
sudo -u ${HX} python3 -m pip install -r requirements.txt
sudo -u ${HX} python3 manage.py makemigrations
sudo -u ${HX} python3 manage.py migrate --run-syncdb
sudo -u ${HX} python3 ./scripts/createsuperuser.py

}


##############
## BDFProxy ##
##############

INSTALL_BDFPROXY(){

cd /home/${HX}

# Clone main repo
rm -rf bdfproxy.git
sudo -u ${HX} git clone https://github.com/secretsquirrel/bdfproxy.git bdfproxy.git
cd bdfproxy.git
sudo -u ${HX} cp ../hackbox.git/bdfproxy-requirements.txt requirements.txt
sudo -u ${HX} python -m pip install -r requirements.txt

# TODO Fix this
# Update BDFProxy configuration
sudo -u ${HX} sed -i -e 's/192.168.1.168/192.168.1.32/' -e 's/192.168.1.16/192.168.1.32/' bdfproxy.cfg

# Patching BDFProxy
echo 'Patching BDFProxy...'
sudo -u ${HX} patch -p1 < ../hackbox.git/patches/bdf-proxy-no-root.patch

# Init sub-modules
sudo -u ${HX} git submodule init && sudo -u ${HX} git submodule update
cd bdf
sudo -u ${HX} git pull origin master

# Build osslsigncode
cd osslsigncode
sudo -u ${HX} ./autogen.sh && sudo -u ${HX} ./configure && sudo -u ${HX} make && make install

# Install aPLib
cd ../aPLib/example
sudo -u ${HX} gcc -c -I../lib/elf -m32 -Wall -O2 -s -o appack.o appack.c -v && gcc -m32 -Wall -O2 -s -o appack appack.o ../lib/elf/aplib.a -v && cp ./appack /usr/bin/appack

}


################
## Metasploit ##
################

INSTALL_METASPLOIT(){
cd /opt

curl -sSL https://github.com/REMnux/docker/raw/master/metasploit/scripts/init.sh --output /usr/local/bin/init.sh && chmod a+xr /usr/local/bin/init.sh
if [ -d '/opt/msf' ]; then
	cd msf
	git fetch && git pull
else
	# Get Metasploit
	git clone https://github.com/rapid7/metasploit-framework.git msf
	cd msf
fi

# Install PosgreSQL
sudo -u postgres curl -sSL https://github.com/REMnux/docker/raw/master/metasploit/scripts/db.sql --output /tmp/db.sql
/etc/init.d/postgresql start && su postgres -c "psql -f /tmp/db.sql"
curl -sSL https://github.com/REMnux/docker/raw/master/metasploit/conf/database.yml --output /opt/msf/config/database.yml

cd /home/${HX}

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

sh -c "echo '. /etc/profile.d/rvm.sh'" >> .bashrc

# Symlink tools to $PATH
for i in `ls /opt/msf/tools/*/*`; do
	ln -f -s $i /usr/local/bin/
done

ln -f -s /opt/msf/msf* /usr/local/bin

# TODO
# Starting script (DB + updates)
#/usr/local/bin/init.sh
}


##########
## Main ##
##########

INSTALL_SYSTEM

INSTALL_HACKBOX

INSTALL_BDFPROXY

INSTALL_METASPLOIT

echo Success.
