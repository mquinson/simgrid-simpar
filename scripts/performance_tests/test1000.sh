version=$1
sgpath=$2 #/usr/local
for thread in 4 8; do
  for size in 10000; do 
    ./test_versions.sh $size $thread $version $sgpath
  done
done
