# Before running this, first do ssh-keygen and add the key to authorized keys of rennes.
set -e
# First set proxys (to allow pull from SimGrid repository)
export http_proxy=http://proxy.rennes.grid5000.fr:3128/ && export https_proxy=https://proxy.rennes.grid5000.fr:3128/
scp rtortilopez@rennes.grid5000.fr:~/ssh_files/* .ssh/.
cd SimGrid/

if [ -z "$1" ]
then
    SG_COMMIT=$1
    git checkout $SG_COMMIT
fi

cmake -Denable_compile_optimizations=ON -Denable_supernovae=OFF -Denable_compile_warnings=OFF -Denable_debug=OFF -Denable_gtnets=OFF -Denable_jedule=OFF -Denable_latency_bound_tracking=OFF -Denable_lua=OFF -Denable_model-checking=OFF -Denable_smpi=OFF -Denable_tracing=OFF -Denable_documentation=OFF .
make install
cd examples/msg/chord/
# Test scripts
scp rtortilopez@rennes.grid5000.fr:~/testall* .
scp rtortilopez@rennes.grid5000.fr:~/generate.py .
# Copy some platform and deployment files
scp rtortilopez@rennes.grid5000.fr:~/platforms/*.xml .
scp rtortilopez@rennes.grid5000.fr:~/deployments/*.xml .
