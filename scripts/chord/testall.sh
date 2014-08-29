#!/bin/bash

# This script is to benchmark the Chord simulation that can be found
# in examples/msg/chord folder.
# The benchmark is done with both Constant and Precise mode, using
# different sizes and number of threads (which can be modified).
# This script also generate a table with all the times gathered, that can ease
# the plotting, compatible with gnuplot/R.
# By now, this script copy all data (logs generated an final table) to a 
# personal frontend-node in Grid5000. This should be modified in the near
# future.

# Path to installation folder needed to recompile chord
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
sizes=(3000)
# Number of threads to test. 
threads=(1 2 4 8 16 24)
#The las %U is just to ease parsing for table
timefmt="clock:%e user:%U sys:%S telapsed:%E swapped:%W exitval:%x max:%Mk avg:%Kk %U"

echo "Recompile the binary against $SGPATH"
export LD_LIBRARY_PATH="$SGPATH/lib"
rm -rf chord
gcc chord.c -L$SGPATH/lib -I$SGPATH/include -I$SGPATH/src/include -lsimgrid -o chord

if [ ! -e "chord" ]; then
    echo "chord does not exist"
    exit;
fi

test -e tmp || mkdir tmp
me=tmp/`hostname -s`

# Print host information on different file
setup_info="setup_info.org"
rm -rf $setup_info
echo "* Host" >> $setup_info
uname -a >> $setup_info
echo "* CPU info" >> $setup_info
cat /proc/cpuinfo >> $setup_info
echo "* Mem info" >> $setup_info
cat /proc/meminfo >> $setup_info
echo "* Environment Variables" >> $setup_info
printenv >> $setup_info
echo "* Tools" >> $setup_info
echo "** Compiler" >> $setup_info
gcc -v 2>> $setup_info 
echo "** Make tool" >> $setup_info
make -v >> $setup_info
echo "** CMake" >> $setup_info
cmake --version >> $setup_info
echo "* SimGrid version" >> $setup_info
git rev-parse --short HEAD >> $setup_info
scp $setup_info rtortilopez@rennes.grid5000.fr:~/log/

# Put table headers into file_table
file_table="timings_$SGHASH.dat"
rm -rf $file_table
for thread in "${threads[@]}"; do
thread_line=$thread_line"\t"$thread
done
thread_line=$thread_line$thread_line
for size in ${#threads[@] - 1}; do
tabs_needed=$tabs_needed"\t"
done
echo "#SimGrid commit $SGHASH"               >> $file_table 
echo -e "#\t\tconstant${tabs_needed}precise" >> $file_table
echo -e "#size/thread$thread_line"           >> $file_table


# Start simulation
for size in "${sizes[@]}"; do
    line_table=$size"\t"
    # CONSTANT MODE
    for thread in "${threads[@]}"; do
        filename="chord_${size}_threads${thread}_constant.log"

        rm -rf $filename
        if [ ! -f  chord$size.xml ]; then
        ./generate.py -p -n $size -b 32 -e 10000
        fi

        if [ ! -f  One_cluster_nobb_${size}_hosts.xml ]; then
        ./generate.py -d -n $size 
        fi


        echo "$size nodes, constant model, $thread threads"
        cmd="./chord One_cluster_nobb_"$size"_hosts.xml chord$size.xml --cfg=contexts/stack_size:16 --cfg=network/model:Constant --cfg=network/latency_factor:0.1 --log=root.thres:critical --cfg=contexts/nthreads:$thread"

        /usr/bin/time -f "$timefmt" -o $me.timings $cmd $cmd 1>/tmp/stdout-xp 2>/tmp/stderr-xp

        if grep "Command terminated by signal" $me.timings ; then
            echo "Error detected"
            temp_time="errSig"
        elif grep "Command exited with non-zero status" $me.timings ; then
            echo "Error detected"
            temp_time="errNonZero"
        else
            temp_time=$(cat $me.timings | awk '{print $(NF)}')
        fi

        # param
        echo "size:$size, constant network, $thread threads" >> $filename
        echo "cmd:$cmd" >> $filename
        echo "threads:$thread" >> $filename
        #stderr
        echo "### stderr output" >> $filename
        cat /tmp/stderr-xp >> $filename
        # time
        echo "### timings" >> $filename
        cat $me.timings >> $filename
        line_table=$line_table"\t"$temp_time
        scp $filename  rtortilopez@rennes.grid5000.fr:log/
        rm -rf $filename
        rm -rf $me.timings
    done    

    #PRECISE MODE    
    for thread in "${threads[@]}"; do
        echo "$size nodes, precise model, $thread threads"
        filename="chord_${size}_threads${thread}_precise.log"

        cmd="./chord One_cluster_nobb_"$size"_hosts.xml chord$size.xml --cfg=contexts/stack_size:16 --cfg=maxmin/precision:0.00001 --log=root.thres:critical --cfg=context/nthreads:$thread"

        /usr/bin/time -f "$timefmt" -o $me.timings $cmd $cmd 1>/tmp/stdout-xp 2>/tmp/stderr-xp

        if grep "Command terminated by signal" $me.timings ; then
            echo "Error detected"
            temp_time="errSig"
        elif grep "Command exited with non-zero status" $me.timings ; then
            echo "Error detected"
            temp_time="errNonZero"
        else
            temp_time=$(cat $me.timings | awk '{print $(NF)}')
        fi
        # param
        echo "size:$size, precise network, $thread threads" >> $filename
        echo "cmd:$cmd" >> $filename
        echo "threads:$thread" >> $filename
        #stderr
        echo "### stderr output" >> $filename
        cat /tmp/stderr-xp >> $filename
        # time
        echo "### timings" >> $filename
        cat $me.timings >> $filename
        line_table=$line_table"\t"$temp_time
        scp $filename  rtortilopez@rennes.grid5000.fr:log/
        rm -rf $filename
        rm -rf $me.timings
    done

    echo -e $line_table >> $file_table

done

scp $file_table  rtortilopez@rennes.grid5000.fr:log/
rm -rf tmp
