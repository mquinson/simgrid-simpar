# compiles latex file and open it
file='report'
pdflatex $file'.tex'
bibtex $file'.aux' 
pdflatex $file'.tex'
pdflatex $file'.tex'

evince $file'.pdf'
