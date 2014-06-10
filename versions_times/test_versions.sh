nodes=$1
thread=$2
version=$3
SGPATH=$4
export LD_LIBRARY_PATH="$SGPATH/lib"
gcc chord.c -L$SGPATH/lib -I$SGPATH/include -I$SGPATH/src/include -lsimgrid -o chord
cmd="./chord One_cluster_nobb_"$nodes"_hosts.xml chord$nodes.xml --cfg=contexts/stack_size:16 --log=root.thres:critical"

#save logs in this file  
file="test$nodes.threads$thread.$version.org"

#temporal file for times
test -e tmp || mkdir tmp
me=tmp/`hostname -s`
timefmt="clock:%e user:%U sys:%S telapsed:%E swapped:%W exitval:%x max:%Mk avg:%Kk"

echo "" > $file
echo "* Host" >> $file
uname -a >> $file
echo "* Environment Variables" >> $file
printenv >> $file
echo "* Tools" >> $file
echo "** Compiler" >> $file
gcc -v 2>> $file
echo "** Make tool" >> $file
make -v >> $file
echo "** CMake" >> $file
cmake --version >> $file
echo "*Time" >> $file

#Start measuring times
echo "** Sequential" >> $file
echo "*** Constant" >> $file
cmd1=$cmd" --cfg=network/model:Constant --cfg=network/latency_factor:0.1"
echo $cmd1
/usr/bin/time -f "$timefmt" -o $me.timings $cmd1 $cmd1 2>> $file
cat $me.timings >> $file
rm -rf $me.timings

echo "*** Precise" >> $file
cmd2=$cmd" --cfg=maxmin/precision:0.00001"
echo $cmd2
/usr/bin/time -f "$timefmt"  -o $me.timings $cmd2 $cmd2 2>> $file
cat $me.timings >> $file
rm -rf $me.timings

echo "** Parallel" >> $file
echo "*** Constant" >> $file
cmd3=$cmd1" --cfg=contexts/nthreads:$thread"
echo $cmd3
/usr/bin/time -f "$timefmt" -o $me.timings $cmd3 $cmd3 2>> $file
cat $me.timings >> $file
rm -rf $me.timings

echo "*** Precise" >> $file
cmd4=$cmd2" --cfg=contexts/nthreads:$thread --cfg=maxmin/precision:0.00001"
echo $cmd4
/usr/bin/time -f "$timefmt" -o $me.timings $cmd4 $cmd4 2>> $file
cat $me.timings >> $file
rm -rf $me.timings

scp $file  rtortilopez@rennes.grid5000.fr:logs_versions_tests/
