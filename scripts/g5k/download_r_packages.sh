#!/bin/bash

# Useful script to download and install the needed R packages to plot
# everything in the report and to run the performance regression test
# as well.
# May be run with sudo.

wget http://cran.r-project.org/src/contrib/Archive/stringr/stringr_0.6.1.tar.gz
wget http://cran.r-project.org/src/contrib/Archive/scatterplot3d/scatterplot3d_0.3-34.tar.gz
wget http://cran.r-project.org/src/contrib/Archive/Rserve/Rserve_1.7-2.tar.gz
wget http://cran.r-project.org/src/contrib/Archive/colorspace/colorspace_1.2-3.tar.gz
wget http://cran.r-project.org/src/contrib/Archive/RColorBrewer/RColorBrewer_1.0-4.tar.gz
wget http://cran.r-project.org/src/contrib/Archive/dichromat/dichromat_1.2-4.tar.gz
wget http://cran.r-project.org/src/contrib/Archive/munsell/munsell_0.4.tar.gz
wget http://cran.r-project.org/src/contrib/Archive/digest/digest_0.1.0.tar.gz
wget http://cran.r-project.org/src/contrib/Archive/gtable/gtable_0.1.1.tar.gz
wget http://cran.r-project.org/src/contrib/Archive/scales/scales_0.1.0.tar.gz
wget http://cran.r-project.org/src/contrib/Archive/proto/proto_0.3-9.tar.gz
wget http://cran.r-project.org/src/contrib/Archive/Rcpp/Rcpp_0.9.10.tar.gz
wget http://cran.r-project.org/src/contrib/Archive/plyr/plyr_1.8.tar.gz
wget http://cran.r-project.org/src/contrib/Archive/reshape2/reshape2_1.2.tar.gz
wget http://cran.r-project.org/src/contrib/Archive/ggplot2/ggplot2_0.9.3.tar.gz
wget http://cran.r-project.org/src/contrib/Archive/reshape/reshape_0.8.4.tar.gz 
wget http://cran.r-project.org/src/contrib/Archive/data.table/data.table_1.9.2.tar.gz
wget http://cran.r-project.org/src/contrib/Archive/gridExtra/gridExtra_0.9.1.tar.gz

R CMD INSTALL Rcpp_0.9.10.tar.gz
R CMD INSTALL plyr_1.8.tar.gz
R CMD INSTALL stringr_0.6.1.tar.gz 
R CMD INSTALL scatterplot3d_0.3-34.tar.gz
R CMD INSTALL Rserve_1.7-2.tar.gz
R CMD INSTALL colorspace_1.2-3.tar.gz
R CMD INSTALL RColorBrewer_1.0-4.tar.gz
R CMD INSTALL dichromat_1.2-4.tar.gz
R CMD INSTALL digest_0.1.0.tar.gz
R CMD INSTALL gtable_0.1.1.tar.gz
R CMD INSTALL munsell_0.4.tar.gz
R CMD INSTALL scales_0.1.0.tar.gz
R CMD INSTALL proto_0.3-9.tar.gz
R CMD INSTALL reshape2_1.2.tar.gz
R CMD INSTALL ggplot2_0.9.3.tar.gz
R CMD INSTALL reshape_0.8.5.tar.gz
R CMD INSTALL data.table_1.9.2.tar.gz
R CMD INSTALL gridExtra_0.9.1.tar.gz
