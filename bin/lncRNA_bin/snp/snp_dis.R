vars.tmp <- commandArgs(T)
vars <- vars.tmp[length(vars.tmp)]
split.vars <- unlist(strsplit(vars,','))
input =split.vars[1]
output = split.vars[2]

library(ggplot2)

cir <- read.delim(input,header=T)

cir$Chr <- factor(as.integer(rownames(cir)),labels=cir$Chr)
pdf(paste(output,'.pdf',sep=''))
ggplot(cir,aes(Chr,count))+
	geom_bar(stat='identity',fill='#A52A2A')+
	facet_grid(Sample~.,scales="free")+
	labs(x='Chromosome',y='Count')+
	theme(axis.text.x=element_text(angle=45,color='black',size=10))+
	theme(legend.position='none')
dev.off()

png(paste(output,'.png',sep=''))
ggplot(cir,aes(Chr,count))+
        geom_bar(stat='identity',fill='#A52A2A')+
        facet_grid(Sample~.,scales="free")+
        labs(x='Chromosome',y='Count')+
        theme(axis.text.x=element_text(angle=45,color='black',size=10))+
        theme(legend.position='none')
dev.off()

