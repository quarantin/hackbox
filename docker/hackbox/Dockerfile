#
# This Docker image file encapsulates Metasploit Framework, which is distributed
# from https://github.com/rapid7/metasploit-framework
#
# To run this image after installing Docker, use a command like this:
#
# docker run -it quarantin/metasploit
#
# The -p parameter exposes the ports on which you expect to receive inbound connections from
# reverse shells and such. Once the app starts, run the desired Metasploit command, such as
# "msfconsole" inside its container.
#
# After running the image, you'll have files from your Metasploit session in the ~/.msf4 and
# /tmp/msf directories on your host. The next time you run the app, it will pick up from where
# it left off by reading the files in those locations. If you wish to start from scratch,
# remove those directories ("sudo rm -rf ~/.msf4 /tmp/msf").
#
# In addition to including Metasploit Framework, the image also includes Nmap and tmux.
#
FROM ubuntu:16.04
MAINTAINER Corentin Delorme <codelorme@gmail.com>

RUN apt-get update && apt-get --yes install apt-utils autoconf curl git libc6-dev-i386 libcurl4-openssl-dev libffi-dev libjpeg8-dev libssl-dev libtool libxml2-dev libxslt1-dev openssl pkg-config python3 python3-pip python-dev python-pip unzip zlib1g-dev

RUN python -m pip install --upgrade pip
RUN python3 -m pip install --upgrade pip

##############
## BDFProxy ##
##############

# Install required pip packages
RUN python -m pip install capstone pefile configobj mitmproxy==0.16

# Clone main repo
WORKDIR /
RUN git clone https://github.com/secretsquirrel/bdfproxy

# Init sub-modules
WORKDIR /bdfproxy
RUN git submodule init && git submodule update
WORKDIR /bdfproxy/bdf/
RUN git pull origin master

# Build osslsigncode
WORKDIR /bdfproxy/bdf/osslsigncode
RUN ./autogen.sh && ./configure && make && make install

# Install aPLib
WORKDIR /bdfproxy/bdf/aPLib/example
RUN gcc -c -I../lib/elf -m32 -Wall -O2 -s -o appack.o appack.c -v && gcc -m32 -Wall -O2 -s -o appack appack.o ../lib/elf/aplib.a -v && cp ./appack /usr/bin/appack

WORKDIR /bdfproxy

RUN sed -i -e 's/192.168.1.168/192.168.1.32/' -e 's/192.168.1.16/192.168.1.32/' bdfproxy.cfg

################
## Metasploit ##
################

WORKDIR /opt

# Base packages
RUN apt-get -y install \
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
RUN curl -sSL https://github.com/REMnux/docker/raw/master/metasploit/scripts/init.sh --output /usr/local/bin/init.sh && \
  chmod a+xr /usr/local/bin/init.sh && \
  curl -sSL https://github.com/REMnux/docker/raw/master/metasploit/conf/tmux.conf --output /root/.tmux.conf

# Get Metasploit
RUN git clone https://github.com/rapid7/metasploit-framework.git msf
WORKDIR msf

# Install PosgreSQL
RUN curl -sSL https://github.com/REMnux/docker/raw/master/metasploit/scripts/db.sql --output /tmp/db.sql
RUN /etc/init.d/postgresql start && su postgres -c "psql -f /tmp/db.sql"
RUN curl -sSL https://github.com/REMnux/docker/raw/master/metasploit/conf/database.yml --output /opt/msf/config/database.yml

# RVM and dependencies
RUN gpg --keyserver hkp://pool.sks-keyservers.net:80 --recv-keys 0x409B6B1796C275462A1703113804BB82D39DC0E3 0x7D2BAF1CF37B13E2069D6956105BD0E739499BDB
RUN curl -sSL https://rvm.io/mpapis.asc | gpg --import
RUN curl -L https://get.rvm.io | bash -s stable 
RUN /bin/bash -l -c ". /etc/profile.d/rvm.sh && rvm install 2.6.2"
RUN /bin/bash -l -c ". /etc/profile.d/rvm.sh && rvm requirements"
RUN /bin/bash -l -c ". /etc/profile.d/rvm.sh && rvm install 2.6.3"
RUN /bin/bash -l -c ". /etc/profile.d/rvm.sh && rvm use 2.6.3 --default"
RUN /bin/bash -l -c ". /etc/profile.d/rvm.sh && gem install bundler"
RUN /bin/bash -l -c ". /etc/profile.d/rvm.sh && which bundle"
RUN /bin/bash -l -c ". /etc/profile.d/rvm.sh && bundle config --global jobs $(expr $(cat /proc/cpuinfo | grep vendor_id | wc -l) - 1)"
RUN /bin/bash -l -c ". /etc/profile.d/rvm.sh && bundle install"

# Symlink tools to $PATH
RUN for i in `ls /opt/msf/tools/*/*`; do ln -s $i /usr/local/bin/; done
RUN ln -s /opt/msf/msf* /usr/local/bin

# Starting script (DB + updates)
#/usr/local/bin/init.sh

############
## Django ##
############

# Install Django
RUN python3 -m pip install django

#################
## Entry Point ##
#################

RUN cp -a scripts /
RUN chown -R root:root /scripts

WORKDIR /root

ENTRYPOINT ["/bin/bash"]
