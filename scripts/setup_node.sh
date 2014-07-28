scp -r rtortilopez@rennes.grid5000.fr:~/SimGrid .
scp rtortilopez@rennes.grid5000.fr:~/.vimrc .
apt-get update && apt-get install cmake make gcc git libboost-dev libgct++ libpcre3-dev linux-tools gdb liblua5.1-0-dev libdwarf-dev libunwind7-dev valgrind libsigc++
cd SimGrid/
cmake -Denable_compile_optimizations=ON -Denable_supernovae=OFF -Denable_compile_warnings=OFF -Denable_debug=OFF -Denable_gtnets=OFF -Denable_jedule=OFF -Denable_latency_bound_tracking=OFF -Denable_lua=OFF -Denable_model-checking=OFF -Denable_smpi=OFF -Denable_tracing=OFF -Denable_documentation=OFF .
make && make install
cd examples/msg/chord/
scp rtortilopez@rennes.grid5000.fr:~/testall.sh .
scp rtortilopez@rennes.grid5000.fr:~/generate.py .
scp rtortilopez@rennes.grid5000.fr:~/testall_sr.sh .
python generate.py -p -n 5000 -b 32 -e 10000
python generate.py -d -n 5000
chmod +x testall.sh
# Uncomment next line if no editing of scripts are needed.
#./test_versions_wrapper.sh 3.11 /usr/local
