vars.tmp <- commandArgs(T)
vars <- vars.tmp[length(vars.tmp)]
split.vars <- unlist(strsplit(vars,','))
input =split.vars[1]
output = split.vars[2]

library(ggplot2)

b=read.table(input,header=T)
pdf(paste(output,'.pdf',sep=''))
ggplot(b,aes(Genome_Region,Number,fill=Sample))+       				##x/y/legend的内容
  geom_bar(stat="identity",position='dodge',width=.7,alpha=1)+ 		##不统计画图，柱子宽度0.7倍，透明度为1
 # scale_fill_manual(values=c("#7EC0EE","#F08080","#D8BFD8")) +		##修改柱子颜色
  theme(axis.text.x=element_text(size=9,face='bold'),axis.text.y=element_text(size=9,face='bold')) ##修改xy轴的文字大小，字体
dev.off()

png(paste(output,'.png',sep=''))
ggplot(b,aes(Genome_Region,Number,fill=Sample))+                                ##x/y/legend的内容
  geom_bar(stat="identity",position='dodge',width=.7,alpha=1)+          ##不统计画图，柱子宽度0.7倍，透明度为1
 # scale_fill_manual(values=c("#7EC0EE","#F08080","#D8BFD8")) +         ##修改柱子颜色
  theme(axis.text.x=element_text(size=9,face='bold'),axis.text.y=element_text(size=9,face='bold')) ##修改xy轴的文字大小，字体
dev.off()

