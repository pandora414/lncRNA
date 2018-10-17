vars.tmp <- commandArgs(T)
vars <- vars.tmp[length(vars.tmp)]
split.vars <- unlist(strsplit(vars,','))
input =split.vars[1]
conname = split.vars[2]
trename = split.vars[3]
reptime = split.vars[4]
out1=split.vars[5]
out2=split.vars[6]
out3=split.vars[7]
out4=split.vars[8]

reads <- read.delim(input,header=T)
reads2 <- reads[,-1]
rownames(reads2)=as.character(reads[,1])
library(RUVSeq)
filter <- apply(reads2, 1, function(x) length(x[x>5])>=2)
filtered <- reads2[filter,]
genes <- rownames(filtered)[grep("^ENS", rownames(filtered))]
spikes <- rownames(filtered)[grep("^ERCC", rownames(filtered))]
x <- as.factor(rep(c(conname,trename),each=reptime))
set <- newSeqExpressionSet(as.matrix(filtered),
phenoData = data.frame(x, row.names=colnames(filtered)))
library(RColorBrewer)
colors <- brewer.pal(3, "Set2")
set <- betweenLaneNormalization(set, which="upper")
set1 <- RUVg(set, spikes, k=1)

pdf(out1)
plotPCA(set1, col=colors[x], cex=1.2) 
dev.off()
png(out2,width=480,height=480)
plotPCA(set1, col=colors[x], cex=1.2)
dev.off()

pdf(out3)
plotRLE(set1, outline=FALSE, ylim=c(-4, 4), col=colors[x])
dev.off()
png(out4, width=480,height=480)
plotRLE(set1, outline=FALSE, ylim=c(-4, 4), col=colors[x])
dev.off()

