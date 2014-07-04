scp -r rtortilopez@rennes.grid5000.fr:~/SimGrid .
apt-get update && apt-get install cmake make gcc git libboost-dev libgct++ libpcre3-dev linux-tools gdb liblua5.1-0-dev libdwarf-dev libunwind7-dev
cd SimGrid/examples/msg/chord/
scp rtortilopez@rennes.grid5000.fr:~/test* .
chmod +x test_versions*
cd
