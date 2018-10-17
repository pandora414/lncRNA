vars.tmp <- commandArgs(T)
vars <- vars.tmp[length(vars.tmp)]
split.vars <- unlist(strsplit(vars,','))
input =split.vars[1]
output = split.vars[2]


library(ggplot2)
as <- read.delim(input,header=T)
pdf(paste(output,".stat.pdf",sep=""))
  ggplot(as,aes(Event,Count,fill=Event))+
	geom_bar(stat='identity')+facet_grid(Sig~Group,scales="free")+
	labs(x='AS events category',y='Number of AS events',title='Statistics of AS events')
dev.off()

png(paste(output,".stat.png",sep=""))
  ggplot(as,aes(Event,Count,fill=Event))+
        geom_bar(stat='identity')+facet_grid(Sig~Group,scales="free")+
        labs(x='AS events category',y='Number of AS events',title='Statistics of AS events')
dev.off()

