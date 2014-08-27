library('ggplot2')
library('gridExtra')
library('reshape')
library('plyr')
library('data.table')


temp = list.files(path='./old_sr', pattern="*precise*", full.names = TRUE)

flist <- lapply(temp, read.table)
sr_data <- rbindlist(flist)
sr_data[, "V1"] <- NULL
sr_data = as.data.frame.matrix(sr_data)
#for the mean
df <- ddply(sr_data, .(V3), summarize, mean_value = mean(V2))
saveRDS(df,file="sr-times.Rda")
#ggplot(data=df, geom="histogram", aes(x=V3, y=mean_value)) + xlim(0,2000) + xlab("") + ylab("") + ylim(0,0.005) + geom_point(size = 1)




