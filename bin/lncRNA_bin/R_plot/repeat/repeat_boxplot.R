vars.tmp <- commandArgs(T)
vars <- vars.tmp[length(vars.tmp)]
split.vars <- unlist(strsplit(vars,','))
len=length(split.vars)
output=split.vars[len]

dataall=lapply(1:(len),function(x) { data =read.table(paste(split.vars[x],'.repeat.txt',sep=''),head=T) 
                                       data=as.numeric(data[,1])} )
#save.image('test.Rdata')

names(dataall)= split.vars 

png("repeat.boxplot.png")
boxplot(dataall,ylab='Repeat Content')
dev.off()

pdf("repeat.boxplot.pdf")
boxplot(dataall,ylab='Repeat Content')
#text(x=1,y=-2,'lincRNA')
#text(x=2,y=-2,'mRNA')
dev.off()

