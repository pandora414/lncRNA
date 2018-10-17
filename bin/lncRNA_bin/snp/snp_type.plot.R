vars.tmp <- commandArgs(T)
vars <- vars.tmp[length(vars.tmp)]
split.vars <- unlist(strsplit(vars,','))
input =split.vars[1]
output = split.vars[2]

library(ggplot2)

snp2 <- read.delim(input,header=T)

pdf(paste(output,".pdf",sep=''))
ggplot(snp2,aes(Type,Count,fill=Sample))+
	geom_bar(stat="identity",position='dodge')+
	labs(x='Type',y='Number of SNPs',title='SNP type distribution')+
	theme(axis.text.x = element_text(face="italic",angle=45))
dev.off()


png(paste(output,".png",sep=''))
ggplot(snp2,aes(Type,Count,fill=Sample))+
        geom_bar(stat="identity",position='dodge')+
        labs(x='Type',y='Number of SNPs',title='SNP type distribution')+
        theme(axis.text.x = element_text(face="italic",angle=45))
dev.off()

