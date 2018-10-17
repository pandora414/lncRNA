vars.tmp <- commandArgs(T)
vars <- vars.tmp[length(vars.tmp)]
split.vars <- unlist(strsplit(vars,','))
len=length(split.vars)
output=split.vars[len]

dataall=lapply(1:(len),function(x) { data =read.table(paste(split.vars[x],'.repeat.txt',sep=''),head=T)
                                       data=as.numeric(data[,1])} )
names(dataall)= split.vars

#color=rainbow(len)
color=c("black","blue","red","purple","brown","orange","green","yellow","gray")
#save.image('test.Rdata')
pdf("repeat.density.plot.pdf")

plot(density(dataall[[1]],from=0),col=color[1],ylab='density',xlab='repeat content',main='',xaxs='i')

for( i in 2:len) {
  lines(density(dataall[[i]],from=0),col= color[i])
  }
legend("right", legend = split.vars,lty = 1,col=color)

dev.off()


png("repeat.density.plot.png")

plot(density(dataall[[1]],from=0),col=color[1],ylab='density',xlab='repeat content',main='',xaxs='i')

for( i in 2:len) {
  lines(density(dataall[[i]],from=0),col= color[i])
  }
legend("right", legend = split.vars,lty = 1,col=color)

dev.off()


pdf("repeat.cumulative.plot.pdf")
plot(ecdf(dataall[[1]]),verticals = T, do.points = F,col=color[1],xlab='repeat content',ylab='cumulative frequency',main='')
for( i in 2:len) {
  lines(ecdf(dataall[[i]]),col= color[i],do.points = F)
  }
legend("right", legend = split.vars,lty = 1,col=color)

dev.off()


png("repeat.cumulative.plot.png")
plot(ecdf(dataall[[1]]),verticals = T, do.points = F,col=color[1],xlab='repeat content',ylab='cumulative frequency',main='')
for( i in 2:len) {
  lines(ecdf(dataall[[i]]),col= color[i],do.points = F)
  }
legend("right", legend = split.vars,lty = 1,col=color)

dev.off()

