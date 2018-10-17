vars.tmp <- commandArgs(T)
vars <- vars.tmp[length(vars.tmp)]
split.vars <- unlist(strsplit(vars,','))
input =split.vars[1]
out = split.vars[2]

library(psych)
data <- read.table(input,header=TRUE,check.names=FALSE)
pdf(paste(out,".cor.person.pdf",sep=""))
pairs.panels(data[2:ncol(data)],smooth=TRUE,density=TRUE,ellipses=TRUE,digits=2,method= "pearson",pch=20,lm=FALSE,cor=TRUE,hist.col="black",show.point=TRUE)
dev.off()
