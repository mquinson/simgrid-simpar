#!/bin/bash
#Example: (./chord One_cluster_nobb_1000_hosts.xml chord1000.xml --cfg=contexts/stack_size:16 --log=root.thres:critical --cfg=maxmin/precision:0.00001 --cfg=contexts/nthreads:4 --cfg=maxmin/precision:0.00001 &) && ./poorman.sh
nsamples=10
sleeptime=0
pid=$(pidof chord)

for x in $(seq 1 $nsamples)
do
  gdb -ex "set pagination 0" -ex "thread apply all bt full" -batch -p $pid &>> backtrace.txt
  sleep $sleeptime
done 
