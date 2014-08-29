#!/bin/bash

# This is a personalized script used sometimes to setup a node in Grid5000.
# A typical configuration of a node involves installing the required
# packages through apt-get and then compiling a version of SimGrid.

# It can be adapted, for sure, but it has so many links to personal stuff,
# like deployment/platform files, access to personal account (through ssh)
# that it's probably useless to someone else. Anyway, I leave this here if
# it is useful in some way to someone.

mkdir SimGrid 
scp -r rtortilopez@rennes.grid5000.fr:~/SimGridnewest/* SimGrid/
scp rtortilopez@rennes.grid5000.fr:~/.vimrc .
apt-get update && apt-get install cmake make gcc git libboost-dev libgct++ libpcre3-dev linux-tools gdb liblua5.1-0-dev libdwarf-dev libunwind7-dev valgrind libsigc++
cd SimGrid/
cmake -Denable_compile_optimizations=ON -Denable_supernovae=OFF -Denable_compile_warnings=OFF -Denable_debug=OFF -Denable_gtnets=OFF -Denable_jedule=OFF -Denable_latency_bound_tracking=OFF -Denable_lua=OFF -Denable_model-checking=OFF -Denable_smpi=OFF -Denable_tracing=OFF -Denable_documentation=OFF .
make && make install
cd examples/msg/chord/
scp rtortilopez@rennes.grid5000.fr:~/testall.sh .
scp rtortilopez@rennes.grid5000.fr:~/generate.py .
scp rtortilopez@rennes.grid5000.fr:~/testall_sr.sh .
# Uncomment next lines to generate some platform and deployment files
#python generate.py -d -n 3000
#python generate.py -d -n 5000
#python generate.py -d -n 300000
#python generate.py -d -n 1000000
#python generate.py -p -n 5000 -b 32 -e 10000
#python generate.py -p -n 3000 -b 32 -e 10000
chmod +x testall.sh testall_sr.sh
