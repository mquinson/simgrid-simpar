set terminal svg
set output 'dynamic_threshold.svg'
set title 'Dynamic threshold. SimGrid 3.11, Constant model'
#set xrange [ 1000:1000000]
set xtics (0,1000,3000,5000,10000)
set yrange [ 0:400]

set ylabel 'Nodes'
set ylabel 'Time (sec.)'
set key left top
set size 1,0.5
set origin 0,0.5
set bmargin 0
plot \
'optimization3.dat' using 1:($2) with linespoints lc rgb('dark-blue') lw 2 title '4 threads', \
'optimization3.dat' using 1:($3) with linespoints lc rgb('blue') lw 2 title '8 threads', \
'optimization3.dat' using 1:($4) with linespoints lc rgb('light-blue') lw 2 title '16 threads',\
'optimization3_part2.dat' using 1:($2) with linespoints lc rgb('dark-green') lw 2 title 'opt 4 threads', \
'optimization3_part2.dat' using 1:($3) with linespoints lc rgb('green') lw 2 title 'opt 8 threads', \
'optimization3_part2.dat' using 1:($4) with linespoints lc rgb('light-green') lw 2 title 'opt 16 threads'

set output
