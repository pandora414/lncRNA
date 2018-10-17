library(cummeRbund)

Args <- commandArgs();
INDIR <- Args[5]
FDR <- Args[6]
CONTROL <- Args[7]
CASE <- Args[8]
OUTDIR <- Args[9]
print (INDIR)
print (FDR)
print (CONTROL)
print (CASE)
print (OUTDIR)
cuff <- readCufflinks(dir=toString(INDIR),
	dbFile="cuffData.db",runInfoFile="run.info",
	repTableFile="read_groups.info",
	geneFPKM="genes.fpkm_tracking",
	geneDiff="gene_exp.diff",
	geneCount="genes.count_tracking",
	isoformFPKM="isoforms.fpkm_tracking",
	iosoformDiff="isoform_exp.diff",
	isoformCount="isoforms.count_tracking",
	driver="SQLite")
#pdf(paste(toString(OUTDIR),"/Dendrograme.pdf",sep = ""))
#dend<-csDendro(genes(cuff),logMode=T,pseudocount=1,replicates=FALSE)
#dend
#dev.off()
#save.image("test.Rdata")
pdf(paste(toString(OUTDIR),"/",toString(CONTROL),"_vs_",toString(CASE),".Boxplot.pdf",sep = ""))
box<- csBoxplot(genes(cuff))
box
dev.off()

png(paste(toString(OUTDIR),"/",toString(CONTROL),"_vs_",toString(CASE),".Boxplot.png",sep = ""))
box<- csBoxplot(genes(cuff))
box
dev.off()

pdf(paste(toString(OUTDIR),"/",toString(CONTROL),"_vs_",toString(CASE),".density.pdf",sep = ""))
den<-csDensity(genes(cuff),logMode=T,pseudocount=0.0001,replicates=FALSE)
den
dev.off()

png(paste(toString(OUTDIR),"/",toString(CONTROL),"_vs_",toString(CASE),".density.png",sep = ""))
den<-csDensity(genes(cuff),logMode=T,pseudocount=0.0001,replicates=FALSE)
den
dev.off()

#pdf("scatterMatrix.pdf")
#scatter<-csScatterMatrix(genes(cuff))
#scatter
#dev.off()
print (toString(CONTROL))
print (toString(CASE))

pdf(paste(toString(OUTDIR),"/",toString(CONTROL),"_vs_",toString(CASE),".scatter.pdf",sep = ""))
s<-csScatter(genes(cuff),toString(CONTROL),toString(CASE),smooth=T)
s
dev.off()

png(paste(toString(OUTDIR),"/",toString(CONTROL),"_vs_",toString(CASE),".scatter.png",sep = ""))
s<-csScatter(genes(cuff),toString(CONTROL),toString(CASE),smooth=T)
s
dev.off()

#pdf("vocanoMatrix.pdf")
#vmatrix<-csVolcanoMatrix(genes(cuff))
#vmatrix
#dev.off()

pdf(paste(toString(OUTDIR),"/",toString(CONTROL),"_vs_",toString(CASE),".vocano.pdf",sep = ""))
v<-csVolcano(genes(cuff),toString(CONTROL),toString(CASE),alpha=toString(FDR), showSignificant=TRUE)
v
dev.off()

png(paste(toString(OUTDIR),"/",toString(CONTROL),"_vs_",toString(CASE),".vocano.png",sep = ""))
v<-csVolcano(genes(cuff),toString(CONTROL),toString(CASE),alpha=toString(FDR), showSignificant=TRUE)
v
dev.off()

#pdf("pca.pdf")
#pca<-PCAplot(genes(cuff))
#pca
#dev.off()

#pdf("mds.pdf")
#mds<-MDSplot(genes(cuff))
#mds
#dev.off()

mySigGeneIds <- getSig(cuff,alpha=toString(FDR),level='genes')
mySigGenes <- getGenes(cuff,mySigGeneIds)
heatmap <- csHeatmap(mySigGenes,cluster='both',labRow=F)
pdf(paste(toString(OUTDIR),"/",toString(CONTROL),"_vs_",toString(CASE),".heatmap.pdf",sep = ""))
heatmap
dev.off()

heatmap <- csHeatmap(mySigGenes,cluster='both',labRow=F)
png(paste(toString(OUTDIR),"/",toString(CONTROL),"_vs_",toString(CASE),".heatmap.png",sep = ""))
heatmap
dev.off()

myexampleGeneIDs <- head(mySigGeneIds)
myexampleGenes <- getGenes(cuff,myexampleGeneIDs)
barplot <- expressionBarplot(myexampleGenes)
pdf(paste(toString(OUTDIR),"/",toString(CONTROL),"_vs_",toString(CASE),".exampleBarPlot.pdf",sep = ""))
barplot
dev.off()

myexampleGenes <- getGenes(cuff,head(mySigGeneIds))
barplot <- expressionBarplot(myexampleGenes)
png(paste(toString(OUTDIR),"/",toString(CONTROL),"_vs_",toString(CASE),".exampleBarPlot.png",sep = ""))
barplot
dev.off()



