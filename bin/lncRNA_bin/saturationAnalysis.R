Args <- commandArgs();
INFILE <- Args[5]
NAME <- Args[6]
OUT <- Args[7]
data=read.table(INFILE)

MAIN =paste("Saturation analysis of",NAME)
pdf(OUT)
plot(data[,1],data[,2],
type="l",
ylim=c(20000,35000),
ylab="Number of genes",
xlab="Percentage of sequencing data",
cex.main=1.8,
cex.lab=1.5,
cex.axis=1.2,

main=MAIN,lwd=3)
dev.off()
