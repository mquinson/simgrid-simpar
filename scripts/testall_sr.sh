#!/bin/bash
SGPATH=$1
SGHASH=$2 #This should be the commit short hash
log_folder="log_sr"
my_date=`date +%Y-%m-%d`
my_time=`date +%H-%M-%S`
sizes=(1000 10000 30000 100000)
threads=(1 2 4 8 16 24)
#The las %U is just to ease parsing for table
timefmt="clock:%e user:%U sys:%S telapsed:%E swapped:%W exitval:%x max:%Mk avg:%Kk %U"

echo "(recompile the binary against $SGPATH)"
export LD_LIBRARY_PATH="$SGPATH/lib"
rm -rf chord
gcc chord.c -L$SGPATH/lib -I$SGPATH/include -I$SGPATH/src/include -lsimgrid -o chord

if [ ! -e "chord" ]; then
    echo "chord does not exist"
    exit;
fi

test -e tmp || mkdir tmp
me=tmp/`hostname -s`
file_table="timings_$SGHASH.dat"

# echo table headers into file_table
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

# Start simulation
for size in "${sizes[@]}"; do
    line_table=$size"\t"
    # CONSTANT MODE
    for thread in "${threads[@]}"; do
        filename="chord_${size}_threads${thread}_constant.log"
	output="sr_${size}_threads${thread}_constant.log"
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
            echo "Damn, error detected:"
            temp_time="errSig"
        elif grep "Command exited with non-zero status" $me.timings ; then
            echo "Damn, error detected:"
            temp_time="errNonZero"
        else
            temp_time=$(cat $me.timings | awk '{print $(NF)}')
        fi

        # param
        echo "size:$size, constant network, $thread threads" >> $filename
        echo "cmd:$cmd" >> $filename
        #stderr
        echo "###stderr" >> $filename
        cat /tmp/stderr-xp >> $filename
        # time
        echo "### results" >> $filename
        cat $me.timings >> $filename
        line_table=$line_table"\t"$temp_time
	python get_sr_counts.py $filename $output
        scp $output  rtortilopez@rennes.grid5000.fr:$log_folder/
        rm -rf $filename $output
        rm -rf $me.timings
    done    

    #PRECISE MODE    
    for thread in "${threads[@]}"; do
        echo "$size nodes, precise model, $thread threads"
        filename="chord_${size}_threads${thread}_precise.log"
	output="sr_${size}_threads${thread}_precise.log"

        cmd="./chord One_cluster_nobb_"$size"_hosts.xml chord$size.xml --cfg=contexts/stack_size:16 --cfg=maxmin/precision:0.00001 --log=root.thres:critical --cfg=contexts/nthreads:$thread"

        /usr/bin/time -f "$timefmt" -o $me.timings $cmd $cmd 1>/tmp/stdout-xp 2>/tmp/stderr-xp

        if grep "Command terminated by signal" $me.timings ; then
            echo "Damn, error detected:"
            temp_time="errSig"
        elif grep "Command exited with non-zero status" $me.timings ; then
            echo "Damn, error detected:"
            temp_time="errNonZero"
        else
            temp_time=$(cat $me.timings | awk '{print $(NF)}')
        fi
        # param
        echo "size:$size, precise network, $thread threads" >> $filename
        echo "cmd:$cmd" >> $filename
        #stderr
        echo "###stderr" >> $filename
        cat /tmp/stderr-xp >> $filename

        # time
        echo "### results" >> $filename
        cat $me.timings >> $filename
        line_table=$line_table"\t"$temp_time
	python get_sr_counts.py $filename $output
        scp $output  rtortilopez@rennes.grid5000.fr:$log_folder/
        rm -rf $filename $output
        rm -rf $me.timings
    done

    echo -e $line_table >> $file_table

done

scp $file_table  rtortilopez@rennes.grid5000.fr:$log_folder/
rm -rf tmp
