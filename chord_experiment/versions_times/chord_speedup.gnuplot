set terminal svg
set output 'chord_speedup.svg'

set multiplot

set xrange [1000:1050000]
set yrange [ 0:70000 ]

# top part
set noxlabel
set format x ""
set ylabel 'Time (Constant model)'
set key left top
set size 1,0.5
set origin 0,0.5
set bmargin 0
plot \
'versions_times.dat' using 1:($2) with linespoints lc rgb('dark-blue') lw 2 title '3.7 4 threads', \
'versions_times.dat' using 1:($3) with linespoints lc rgb('blue') lw 2 title '3.7 8 threads', \
'versions_times.dat' using 1:($4) with linespoints lc rgb('dark-green') lw 2 title '3.7 16 threads',\
'versions_times.dat' using 2:($2) with linespoints lc rgb('brown') lw 2 title '3.11 4 threads', \
'versions_times.dat' using 2:($2/$6) with linespoints lc rgb('dark-green') lw 2 title '3.11 8 threads', \
'versions_times.dat' using 2:($2/$7) with linespoints lc rgb('black') lw 2 title '3.11 16 threads'

set output

