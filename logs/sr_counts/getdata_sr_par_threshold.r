library('ggplot2')
library('gridExtra')
library('reshape')
library('plyr')
library('data.table')

#Helper function to plot several ggplot in one window.
require(grid)
vp.layout <- function(x, y) viewport(layout.pos.row=x, layout.pos.col=y)
arrange_ggplot2 <- function(..., nrow=NULL, ncol=NULL, as.table=FALSE) {
dots <- list(...)
n <- length(dots)
if(is.null(nrow) & is.null(ncol)) { nrow = floor(n/2) ; ncol = ceiling(n/nrow)}
if(is.null(nrow)) { nrow = ceiling(n/ncol)}
if(is.null(ncol)) { ncol = ceiling(n/nrow)}
## NOTE see n2mfrow in grDevices for possible alternative
grid.newpage()
pushViewport(viewport(layout=grid.layout(nrow,ncol) ) )
ii.p <- 1
for(ii.row in seq(1, nrow)){
ii.table.row <- ii.row
if(as.table) {ii.table.row <- nrow - ii.table.row + 1}
for(ii.col in seq(1, ncol)){
ii.table <- ii.p
if(ii.p > n) break
print(dots[[ii.table]], vp=vp.layout(ii.table.row, ii.col))
ii.p <- ii.p + 1
}
}
}






#PRECISE MODE
#SEQUENTIAL
temp = list.files(path='./log_sr/sequential', pattern="*5000*", full.names = TRUE)
temp <- temp[grepl("precise", temp)]
flist <- lapply(temp, read.table)
sr_data <- rbindlist(flist) #TODO: SE PUEDE SACAR, CREO
sr_data[, "V1"] <- NULL
sr_data = as.data.frame.matrix(sr_data)
df <- ddply(sr_data, .(V3), summarize, mean_value = mean(V2))

#PARALLEL:
temp2 = list.files(path='./log_sr/parallel', pattern="*5000*", full.names = TRUE)
temp2 <- temp2[grepl("precise", temp2)]
flist2 <- lapply(temp2, read.table)
sr_data2 <- rbindlist(flist2) #TODO: SE PUEDE SACAR, CREO
sr_data2[, "V1"] <- NULL
sr_data2 = as.data.frame.matrix(sr_data2)
df2 <- ddply(sr_data2, .(V3), summarize, mean_value = mean(V2))

#CONSTANT MODE
#SEQUENTIAL
temp3 = list.files(path='./log_sr/sequential', pattern="*5000*", full.names = TRUE)
temp3 <- temp3[grepl("constant", temp3)]
flist <- lapply(temp3, read.table)
sr_data <- rbindlist(flist) #TODO: SE PUEDE SACAR, CREO
sr_data[, "V1"] <- NULL
sr_data = as.data.frame.matrix(sr_data)
df3 <- ddply(sr_data, .(V3), summarize, mean_value = mean(V2))

#PARALLEL:
temp4 = list.files(path='./log_sr/parallel', pattern="*5000*", full.names = TRUE)
temp4 <- temp4[grepl("constant", temp4)]
flist2 <- lapply(temp4, read.table)
sr_data2 <- rbindlist(flist2) #TODO: SE PUEDE SACAR, CREO
sr_data2[, "V1"] <- NULL
sr_data2 = as.data.frame.matrix(sr_data2)
df4 <- ddply(sr_data2, .(V3), summarize, mean_value = mean(V2))


#Merge PRECISE datasets
df5 = merge(df, df2, by.x = 'V3', by.y = 'V3', incomparables = NULL)
df5[, 'speedup'] <- df5[,'mean_value.x'] / df5[, 'mean_value.y']
saveRDS(df5, file="precise.Rda")
#Merge CONSTANT datasets
df6 = merge(df3, df4, by.x = 'V3', by.y = 'V3', incomparables = NULL)
df6[, 'speedup'] <- df6[,'mean_value.x'] / df6[, 'mean_value.y']
saveRDS(df6,file="constant.Rda")
#g1<-ggplot(data=df5, geom="histogram", aes(x=V3, y=speedup)) + xlab("") + ylab("") +geom_line() + xlim(1,400) + stat_smooth(se=FALSE)
#g2<-ggplot(data=df6, geom="histogram", aes(x=V3, y=speedup)) + xlab("") + ylab("") +geom_line() + xlim(1,400) + stat_smooth(se=FALSE)
#pdf('sr-par-threshold.pdf')
#arrange_ggplot2(g2,g1,ncol=1)
#dev.off()



