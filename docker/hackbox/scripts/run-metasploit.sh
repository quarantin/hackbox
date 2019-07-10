#!/bin/bash

# Wait for BDFProxy resource file for metasploit framework
while true; do

	echo "Waiting for /bdfproxy/bdfproxy_msf_resource.rc..."
	stat /bdfproxy/bdfproxy_msf_resource.rc &> /dev/null
	if [ "$?" -eq "0" ]; then
		break
	fi

	sleep 2
done

# Load Ruby environment
. /etc/profile.d/rvm.sh

# Run metasploit
msfconsole -r /bdfproxy/bdfproxy_msf_resource.rc
