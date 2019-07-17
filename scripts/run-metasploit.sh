#!/bin/bash

. /etc/profile.d/rvm.sh

cd /opt/msf

msfconsole -r /home/hx/bdfproxy/bdfproxy_msf_resource.rc
