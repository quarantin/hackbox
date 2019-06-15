#!/bin/bash

cd /bdfproxy
./bdf_proxy.py &> bdfproxy.log &
/bin/bash -l
