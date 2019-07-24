FROM ubuntu:18.04

# Install required ubuntu packages
RUN apt-get update && apt-get -y install apt-utils autoconf curl git libc6-dev-i386 libcurl4-openssl-dev libffi-dev libjpeg8-dev libssl-dev libtool libxml2-dev libxslt1-dev openssl pkg-config python-dev python-pip unzip zlib1g-dev 

# Upgrade pip
RUN python -m pip install --upgrade pip

# Install required pip packages
RUN python -m pip install mitmproxy==0.16
