vars.tmp<- commandArgs(T)
vars <- vars.tmp[length(vars.tmp)]
split.vars <- unlist(strsplit(vars,','))
GOdir =split.vars[1]
prefix=split.vars[2]
glist=split.vars[3]
name=split.vars[4]
GOclass=split.vars[5]
outdir=split.vars[6]

require(clusterProfiler)
require("Rgraphviz")
require("topGO")
goclass=read.delim(GOclass,head=F,sep="\t")
diff=read.delim(glist,head=T,sep="\t")
#name_tmp=strsplit(glist,split="/")
#name=unlist(strsplit(unlist(name_tmp)[length(unlist(name_tmp))],split="\\."))[1]
diff=diff[order(diff[,2],decreasing=T),]

class <- c("C","F","P")
onto <- c("CC","MF","BP")
for (i in 1:3)
{
	#data
	data <- read.delim(paste(GOdir,"/",prefix,".",class[i],sep=""),header=F)
	term2gene=data[, c("V5", "V3")]
	names(term2gene)=c("GOterm","GeneID")
	diffList <- factor(as.integer (term2gene$GeneID %in% diff$GeneID))
	names(diffList)=term2gene$GeneID
	ID2GO = by(term2gene$GOterm, term2gene$GeneID, function(x) as.character(x))
	#table
	enrich = enricher(diff$GeneID, pvalueCutoff = 1, pAdjustMethod = "fdr", qvalueCutoff = 1, TERM2GENE=term2gene, TERM2NAME=goclass)
	write.table(summary(enrich),file=paste(outdir,"/",name,".","sigDiff","_",class[i],".","xls",sep=""),sep="\t",quote=F, row.names=F)
	#pic
	res <- new("topGOdata", ontology = onto[i], allGenes = diffList, annot = annFUN.gene2GO, gene2GO = ID2GO)
	resultFisher <- runTest(res, algorithm = "classic", statistic = "fisher")

	pdf(paste(outdir,"/",name,".","sigDiff","_",class[i],".","pdf",sep=""))
	showSigOfNodes(res, score(resultFisher), firstSigNodes = 5, useInfo = 'all')
	dev.off()
}