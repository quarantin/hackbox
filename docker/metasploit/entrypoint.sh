#!/bin/bash

# Start BDFProxy
cd /bdfproxy
./bdf_proxy.py &

# Wait for BDFProxy resource file for metasploit framework
while true; do

	echo "Waiting for /bdfproxy/bdfproxy_msf_resource.rc..."
	stat /bdfproxy/bdfproxy_msf_resource.rc &> /dev/null
	if [ "$?" -eq "0" ]; then
		break
	fi

	sleep 1
done

# Run metasploit
. /etc/profile.d/rvm.sh
msfconsole -r /bdfproxy/bdfproxy_msf_resource.rc

# Fallback to login shell when msfconsole exits
/bin/bash -l
