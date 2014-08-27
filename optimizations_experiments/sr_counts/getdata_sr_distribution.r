library('ggplot2')
library('gridExtra')
library('reshape')
library('plyr')
library('data.table')

temp = list.files(path='./log_sr/parallel', pattern="*precise*", full.names = TRUE)
flist <- lapply(temp, read.table)
sr_data <- rbindlist(flist)
sr_data[, "V1"] <- NULL
sr_data = as.data.frame.matrix(sr_data)
saveRDS(sr_data, file="sr-distribution.Rda")

#ggplot(data=sr_data, geom="histogram", aes(x=V3)) + ylim(0,0.7)+ xlim(1,13) + geom_histogram(binwidth=0.5,aes(y=..count../sum(..count..)), origin=-0.5) + xlab("Amount of processes") + ylab("Percentage of Scheduling Rounds") + scale_x_continuous(breaks=c(1:13), labels=c(1:13),limits=c(1,13)) + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), panel.background = element_blank()) #, axis.line = element_line(colour = "black"))


