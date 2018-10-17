vars.tmp <- commandArgs(T)
vars <- vars.tmp[length(vars.tmp)]
split.vars <- unlist(strsplit(vars,','))
input =split.vars[1]
output = split.vars[2]

library(ggplot2)
library(scales)

a<- read.delim(input,header=T)
a$Percent=a$Percent/100
a$Iterm <- factor(as.integer(rownames(a)),labels=a$Iterm)
pdf(paste(output,".edit.type.pdf",sep=""))
ggplot(a,aes(Iterm,Percent,fill=Iterm))+
	geom_bar(stat='identity')+
	scale_y_continuous(labels=percent)+
	theme(axis.text.x=element_text(size=6,colour='black'))+
	geom_text(aes(y=a$Percent,label=a$Count),hjust=0.5, vjust=-0.5,size=3,color="black")+
	labs(x='Type',y='Percent')
	
dev.off()

png(paste(output,".edit.type.png",sep=""))
ggplot(a,aes(Iterm,Percent,fill=Iterm))+
        geom_bar(stat='identity')+
        scale_y_continuous(labels=percent)+
        theme(axis.text.x=element_text(size=6,colour='black'))+
        geom_text(aes(y=a$Percent,label=a$Count),hjust=0.5, vjust=-0.5,size=3,color="black")+
        labs(x='Type',y='Percent')

dev.off()

