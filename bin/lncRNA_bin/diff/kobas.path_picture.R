vars.tmp <- commandArgs(T)
vars <- vars.tmp[length(vars.tmp)]
split.vars <- unlist(strsplit(vars,','))
input =split.vars[1]
out=split.vars[2]
name=split.vars[3]
pathdata=read.delim(input,head=F)
n=grep('Term',pathdata[,1])

if(nrow(pathdata)>(20+n)){pathdatasub=pathdata[(n+1):(20+n),]}else{
                 pathdatasub=pathdata[-(1:(n+1)),]}

pathdatasub=as.matrix(pathdatasub)
pathdatasub=data.frame(pathdatasub[,c(1:5,7)],rf=as.numeric(as.character(pathdatasub[,4]))/as.numeric(as.character(pathdatasub[,5])))
max=max(pathdatasub$rf)
library(ggplot2)
pdf(paste(out,'.pdf',sep=''))
p<- ggplot( pathdatasub,aes(x=-log10(as.numeric((as.character(V7)))), y=V1,color=rf,size=as.numeric(as.character(V4))))
p<- p+geom_point()+scale_color_continuous(limits=c(0,max),low = 'green',high ='red',guide = "colorbar",space = "Lab")
    p=p+ labs(title = paste("Pathway Enrichment for ",name,sep=''),color='RichFactor',size='Genenumber')+xlab('-log10(Corrected P-Value)')+ylab('Pathway')
    p+geom_vline(xintercept=-log10(0.05), linetype="longdash",colour='gray')
dev.off()

png(paste(out,'.png',sep=''),width = 500, height = 600)
p<- ggplot( pathdatasub,aes(x=-log10(as.numeric((as.character(V7)))), y=V1,color=rf,size=as.numeric(as.character(V4))))
p<- p+geom_point()+scale_color_continuous(limits=c(0,max),low = 'green',high ='red',guide = "colorbar",space = "Lab")
    p=p+ labs(title = paste("Pathway Enrichment for ",name,sep=''),color='RichFactor',size='Genenumber')+xlab('-log10(Corrected P-Value)')+ylab('Pathway')
    p+geom_vline(xintercept=-log10(0.05), linetype="longdash",colour='gray')
dev.off()
