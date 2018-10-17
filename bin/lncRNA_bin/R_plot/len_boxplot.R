vars.tmp <- commandArgs(T)
vars <- vars.tmp[length(vars.tmp)]
split.vars <- unlist(strsplit(vars,','))
len=length(split.vars)
output=split.vars[len]

dataall=lapply(1:(len),function(x) { data =read.table(paste(split.vars[x],'.len.txt',sep=''),head=T) 
                                       data=as.numeric(data[,1])} )
#save.image('test.Rdata')

names(dataall)= split.vars 

png("len.boxplot.png")
boxplot(dataall,ylab='Length(log)')
dev.off()

pdf("len.boxplot.pdf")
boxplot(dataall,ylab='Length(log)')
#text(x=1,y=-2,'lincRNA')
#text(x=2,y=-2,'mRNA')
dev.off()

