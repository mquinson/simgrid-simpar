scp -r rtortilopez@rennes.grid5000.fr:~/SimGrid .
apt-get update && apt-get install cmake make gcc git libboost-dev libgct++ libpcre3-dev linux-tools gdb liblua5.1-0-dev
cd SimGrid/
cmake -Denable_compile_optimizations=ON -Denable_supernovae=OFF -Denable_compile_warnings=OFF -Denable_debug=OFF -Denable_gtnets=OFF -Denable_jedule=OFF -Denable_latency_bound_tracking=OFF -Denable_lua=OFF -Denable_model-checking=OFF -Denable_smpi=OFF -Denable_tracing=OFF .
make && make install
cd examples/msg/chord/
scp rtortilopez@rennes.grid5000.fr:~/test_versions* .
python generate_old.py -p -n 5000 -b 32 -e 1000
python generate_old.py -d -n 5000
chmod +x test_versions*
# Uncomment next line if no editing of scripts are needed.
#./test_versions_wrapper.sh 3.11 /usr/local
