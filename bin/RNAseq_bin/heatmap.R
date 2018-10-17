vars.tmp <- commandArgs(T)
vars <- vars.tmp[length(vars.tmp)]
split.vars <- unlist(strsplit(vars,','))
input =split.vars[1]
output = split.vars[2]

exp=read.table(input,header=T,check.name=F)
row.names(exp)=exp$GeneID

exp=exp[,-1]
exp_matrix=data.matrix(exp)
library("gplots")

#par(mar=c( 20.1,8.1,8.6,8.1))
pdf(paste(output,".heatmap.pdf",sep=""))#example.pdf为输出文件名
heatmap.2(exp_matrix,col=rev(redgreen(75)),key=TRUE,scale="row",trace="none",cexRow=0.8,cexCol=1,margins =c(8,8),offsetRow=-0.5)

dev.off()

png(paste(output,".heatmap.png",sep=""))#example.pdf为输出文件名
heatmap_exp=heatmap.2(exp_matrix,col=rev(redgreen(75)),key=TRUE,scale="row",trace="none",cexRow=0.8,cexCol=1,margins =c(8,8),offsetRow=-0.5)

dev.off()

