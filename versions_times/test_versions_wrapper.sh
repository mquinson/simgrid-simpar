version=$1
sgpath=$2 #/usr/local
for thread in 4 8 16; do
  for size in 1000 10000 100000 1000000; do 
    ./test_versions.sh $size $thread $version $sgpath
  done
done
