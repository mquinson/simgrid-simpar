#!/bin/bash

# This script is to benchmark the some examples simulations that can be found
# in examples/msg/ folder.
# The benchmark is done with both Constant and Precise mode, using
# different sizes and number of threads (which can be modified).
# This script also generate a table with all the times gathered, that can ease
# the plotting, compatible with gnuplot/R.

###############################################################################
# MODIFIABLE PARAMETERS: SGPATH, SGHASH, sizes, threads, log_folder, file_table
# host_info, timefmt, cp_cmd, dest, example.

# Change this for the example of examples/msg/ you want to try (tested with
# Pastry, Chord, Kademlia).
example="chord"
par_threshold=2

# Path to installation folder needed to recompile the example
# If it is not set, assume that the path is '/usr/local'
if [ -z "$1" ]
then
    SGPATH='/usr/local'
else
    SGPATH=$1
fi

# Save the revision of SimGrid used for the experiment
SGHASH=$(git rev-parse --short HEAD)

# List of sizes to test. Modify this to add different sizes.
sizes=(1000 10000 25000 50000 75000)

# Number of threads to test. 
threads=(1 2 4 8 16 24)

# Path where to store logs, and filenames of times table, host info
log_folder="log/"
if [ ! -d "$log_folder" ]; then
    echo "Creating $log_folder folder"
    mkdir -p $log_folder
fi

file_table="timings_$SGHASH.csv"
host_info="host_info.org"
rm -rf $host_info

# The las %e is just to ease the parsing for table
timefmt="clock:%e user:%U sys:%S telapsed:%e swapped:%W exitval:%x max:%Mk avg:%Kk %e"

# Copy command. This way one can use cp, scp and a local folder or a folder in 
# a cluster.
sep=','
cp_cmd='cp'
dest=$log_folder # change for <user>@<node>.grid5000.fr:~/$log_folder if necessary
###############################################################################

###############################################################################
if [ ! -e $example ]; then
    echo "$example does not exist"
    exit 1;
fi
###############################################################################

###############################################################################
# PRINT HOST INFORMATION IN DIFFERENT FILE
set +e
echo "#+TITLE: Chord experiment on $(eval hostname)" >> $host_info
echo "#+DATE: $(eval date)" >> $host_info
echo "#+AUTHOR: $(eval whoami)" >> $host_info
echo " " >> $host_info 

echo "* People logged when experiment started:" >> $host_info
who >> $host_info
echo "* Hostname" >> $host_info
hostname >> $host_info
echo "* System information" >> $host_info
uname -a >> $host_info
echo "* CPU info" >> $host_info
cat /proc/cpuinfo >> $host_info
echo "* CPU governor" >> $host_info
if [ -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ];
then
    cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor >> $host_info
else
    echo "Unknown (information not available)" >> $host_info
fi
echo "* CPU frequency" >> $host_info
if [ -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq ];
then
    cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq >> $host_info
else
    echo "Unknown (information not available)" >> $host_info
fi
echo "* Meminfo" >> $host_info
cat /proc/meminfo >> $host_info
echo "* Memory hierarchy" >> $host_info
lstopo --of console >> $host_info
echo "* Environment Variables" >> $host_info
printenv >> $host_info
echo "* Tools" >> $host_info
echo "** Linux and gcc versions" >> $host_info
cat /proc/version >> $host_info
echo "** Gcc info" >> $host_info
gcc -v 2>> $host_info 
echo "** Make tool" >> $host_info
make -v >> $host_info
echo "** CMake" >> $host_info
cmake --version >> $host_info
echo "* SimGrid Version" >> $host_info
grep "SIMGRID_VERSION_STRING" ../../../include/simgrid_config.h | sed 's/.*"\(.*\)"[^"]*$/\1/' >> $host_info
echo "* SimGrid commit hash" >> $host_info
git rev-parse --short HEAD >> $host_info
$($cp_cmd $host_info $dest)
###############################################################################

###############################################################################
# ECHO TABLE HEADERS INTO FILE_TABLE
rm -rf $file_table
tabs_needed=""
for thread in "${threads[@]}"; do
thread_line=$thread_line"\t"$thread
done
thread_line=$thread_line$thread_line
for size in $(seq 1 $((${#threads[@]}-1))); do
tabs_needed=$tabs_needed"\t"
done
echo "#SimGrid commit $SGHASH"     >> $file_table 
echo -e "#\t\tconstant${tabs_needed}precise"     >> $file_table
echo -e "#size/thread$thread_line" >> $file_table
###############################################################################

###############################################################################
# START SIMULATION

test -e tmp || mkdir tmp
me=tmp/`hostname -s`

for size in "${sizes[@]}"; do
    line_table=$size
    # CONSTANT MODE
    for thread in "${threads[@]}"; do
        filename="${example}_${size}_threads${thread}_constant.log"
        rm -rf $filename

        if [ ! -f  chord$size.xml ]; then
        ./generate.py -p -n $size -b 32 -e 10000
        fi

        if [ ! -f  One_cluster_nobb_${size}_hosts.xml ]; then
        ./generate.py -d -n $size 
        fi


        echo "$size nodes, constant model, $thread threads"
        cmd="./$example One_cluster_nobb_"$size"_hosts.xml chord$size.xml --cfg=contexts/stack_size:16 --cfg=network/model:Constant --cfg=network/latency_factor:0.1 --log=root.thres:info --cfg=contexts/nthreads:$thread --cfg=contexts/guard_size:0 --cfg=clean_atexit:no --cfg=contexts/parallel_threshold:$par_threshold"

        /usr/bin/time -f "$timefmt" -o $me.timings $cmd $cmd 1>/tmp/stdout-xp 2>/tmp/stderr-xp

        if grep "Command terminated by signal" $me.timings ; then
            echo "Error detected:"
            temp_time="errSig"
        elif grep "Command exited with non-zero status" $me.timings ; then
            echo "Error detected:"
            temp_time="errNonZero"
        else
            temp_time=$(cat $me.timings | awk '{print $(NF)}')
        fi

        # param
        cat $host_info >> $filename
        echo "* Experiment settings" >> $filename
        echo "size:$size, constant network, $thread threads" >> $filename
        echo "cmd:$cmd" >> $filename
        #stderr
        echo "* Stderr output" >> $filename
        cat /tmp/stderr-xp >> $filename
        # time
        echo "* Timings" >> $filename
        cat $me.timings >> $filename
        line_table=$line_table$sep$temp_time
        $($cp_cmd $filename $dest)
        rm -rf $filename
        rm -rf $me.timings
    done    

    #PRECISE MODE    
    for thread in "${threads[@]}"; do
        echo "$size nodes, precise model, $thread threads"
        filename="${example}_${size}_threads${thread}_precise.log"

        cmd="./$example One_cluster_nobb_"$size"_hosts.xml chord$size.xml --cfg=contexts/stack_size:16 --cfg=maxmin/precision:0.00001 --log=root.thres:info --cfg=contexts/nthreads:$thread --cfg=contexts/guard_size:0 --cfg=clean_atexit:no --cfg=contexts/parallel_threshold:$par_threshold"

        /usr/bin/time -f "$timefmt" -o $me.timings $cmd $cmd 1>/tmp/stdout-xp 2>/tmp/stderr-xp

        if grep "Command terminated by signal" $me.timings ; then
            echo "Error detected:"
            temp_time="errSig"
        elif grep "Command exited with non-zero status" $me.timings ; then
            echo "Error detected:"
            temp_time="errNonZero"
        else
            temp_time=$(cat $me.timings | awk '{print $(NF)}')
        fi
        # param
        cat $host_info >> $filename
        echo "* Experiment settings" >> $filename
        echo "size:$size, constant network, $thread threads" >> $filename
        echo "cmd:$cmd" >> $filename
        #stderr
        echo "* Stderr output" >> $filename
        cat /tmp/stderr-xp >> $filename
        # time
        echo "* Timings" >> $filename
        cat $me.timings >> $filename
        line_table=$line_table$sep$temp_time
        $($cp_cmd $filename $dest)
        rm -rf $filename
        rm -rf $me.timings
    done

    echo -e $line_table >> $file_table

done

$($cp_cmd $file_table $dest)
rm -rf $file_table
rm -rf tmp
