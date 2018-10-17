vars.tmp <- commandArgs(T)
vars <- vars.tmp[length(vars.tmp)]
split.vars <- unlist(strsplit(vars,','))
len=length(split.vars)
output=split.vars[len]

dataall=lapply(1:(len),function(x) { data =read.table(paste(split.vars[x],'.phyloP.txt',sep=''),head=T)
                                       data=as.numeric(data[,1])} )
names(dataall)= split.vars

#color=rainbow(len)
color=c("black","blue","red","purple","brown","orange","green","yellow","gray")

#save.image('test.Rdata')

denall=as.numeric()

for(i in 1:len) {
    den=density(dataall[[i]])
    denall = c(denall,max(den$y))
    }

ymax=max(denall)
#print(ymax)
pdf("conservation.density.plot.pdf")
plot(density(dataall[[1]]),col=color[1],ylab='density',xlab='PhyloP Score',main='',xaxs='i',ylim=c(0,ymax))

for( i in 2:len) {
  lines(density(dataall[[i]]),col= color[i])
  }
legend("right", legend = split.vars,lty = 1,col=color)

dev.off()

pdf("conservation.cumulative.plot.pdf")
plot(ecdf(dataall[[1]]),verticals = T, do.points = F,col=color[1],xlab='PhyloP Score',ylab='cumulative frequency',main='')
for( i in 2:len) {
  lines(ecdf(dataall[[i]]),col= color[i],do.points = F)
  }
legend("right", legend = split.vars,lty = 1,col=color)

dev.off()

png("conservation.density.plot.png")
plot(density(dataall[[1]]),col=color[1],ylab='density',xlab='PhyloP Score',main='',xaxs='i',ylim=c(0,ymax))

for( i in 2:len) {
  lines(density(dataall[[i]]),col= color[i])
  }
legend("right", legend = split.vars,lty = 1,col=color)

dev.off()

png("conservation.cumulative.plot.png")
plot(ecdf(dataall[[1]]),verticals = T, do.points = F,col=color[1],xlab='PhyloP Score',ylab='cumulative frequency',main='')
for( i in 2:len) {
  lines(ecdf(dataall[[i]]),col= color[i],do.points = F)
  }
legend("right", legend = split.vars,lty = 1,col=color)

dev.off()

