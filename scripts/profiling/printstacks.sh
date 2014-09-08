#!/bin/bash

# This script is for debugging purposes. It will print the stacks of all
# threads of a simulation, regularly, until the end of execution and
# into a 'backtrace.log' file.
# Taken and adapted from Gabriel Corona's version of "Poor's man profiler" 
# at http://www.gabriel.urdhr.fr/2014/05/23/flamegraph/#flamegraph
# More information about this technique in the oficial website of Poor Man's
# Profiler: http://poormansprofiler.org/ 

### How to use:
# To run the script with default arguments: start the simulation and
# immediately after run this script.
# Example: (<command> &) && ./printstacks.sh -p <pid_of_command>

### Parameters:
# -n : amount of times the script will sample the stacks. 
# -s : amount of seconds the script will sleep between each sample.
# -p : this stores the current pid of the simulation. If not set, then 
#      it asumes you are running a chord simulation.

# Note that the default parameters are intended for a Chord simulation.
# You can get the pid of your own simulation by using:
# 'pidof <your_process_name>'
# Example: 'pidof pastry' will get the pid of a running pastry simulation.

### Usage examples:
# command="./chord One_cluster_nobb_1000_hosts.xml chord1000.xml --cfg=contexts/nthreads:4"
## Run with default options (chord simulation, sleeptime=1, nsamples=10):
# ($command &) && ./printstacks.sh
## Run with personalized options:
## Take 1000 samples:
#      ($command &) && ./printstacks.sh -n1000
## 10000 samples, sleep 4 seconds between each sample, chord simulation:
#      ($command &) && ./printstacks.sh -n10000 -s4 -p$(pidof chord)



# Getting options
while getopts ":n:s:p:" opt;
do
    case $opt in
        n) nsamples="$OPTARG"
        ;;
        s) sleeptime="$OPTARG"
        ;;
        p) pid="$OPTARG"
        ;;
        \?) echo "Valid options:"
            echo "-n : amount of times the script will sample the stacks."
            echo "-s : amount of seconds the script will sleep between each sample."
            echo "-p : the current pid of the simulation. If not set, exit with error" 
            exit 0
        ;;
    esac
done

re=^[0-9]+$
if [ -z "$nsamples" ]; then nsamples=10; fi
if [ -z "$sleeptime" ]; then sleeptime=1; fi
if [ -z "$pid" ]; then echo "pid of the current simulation missing"; exit 1; fi
if [[ ! "$nsamples" =~ $re ]] ||  [[ ! "$sleeptime" =~ $re ]] || [[ ! "$pid" =~ $re ]]
then
    echo "Some of your arguments are not valid numbers" >&2; exit 1;
fi

output_file="backtrace.log"
rm -rf $output_file 

for x in $(seq 1 $nsamples)
do
  gdb -ex "set pagination 0" -ex "thread apply all bt full" -batch -p $pid &>> $output_file
  sleep $sleeptime
done 
