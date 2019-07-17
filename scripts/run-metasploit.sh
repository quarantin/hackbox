#!/bin/bash

cd /opt/msf

. /etc/profile.d/rvm.sh

msfconsole -r /home/hx/bdfproxy/bdfproxy_msf_resource.rc
