vars.tmp <- commandArgs(T)
vars <- vars.tmp[length(vars.tmp)]
split.vars <- unlist(strsplit(vars,','))
input =split.vars[1]
output = split.vars[2]

library(ggplot2)
library(grid)
a=read.delim(input,header=T)
mylabel=paste(a$Iterm,"(",a$Count,")")
mylabel2=paste(round(a$Count / sum(a$Count) * 100, 2), "%", sep = "")
pdf(paste(output,".edit.pos.pdf",sep=""))
ggplot(a, aes(x = "", y = a$Count, fill = a$Iterm)) +
  geom_bar(stat = "identity", width = 1) + 
  coord_polar(theta = "y") + 
  labs(x = "", y = "", title = "") + 
  theme_bw()+		##将灰色背景去掉 
  theme(panel.border=element_blank())+ ##将白色框框去掉
  theme(axis.ticks = element_blank()) +  ##将左上角的胡子去掉
  theme(panel.grid=element_blank())+  ##去掉白色圆框和中间的坐标线
  theme(legend.margin=unit(-3.5,"cm")) + ##改变图例和图的相对位置
  theme(plot.margin=unit(c(-1,1.5,-1,-1),units="cm")) + ##改变图在画布上的位置，C(上，右，下，左)
  theme(legend.title = element_blank())+ ##去掉图例的标题
  scale_fill_discrete(labels = mylabel) + ## 将原来的图例标签换成现在的myLabel
  theme(axis.text.x = element_blank()) +  ## 白色的外框即是原柱状图的X轴，把X轴的刻度文字去掉即可
  geom_text(aes(y = a$Count/2 + c(0, cumsum(a$Count)[-length(a$Count)]),x=c(1.3,1,1,1.2,1,1), label = mylabel2), size =6)
dev.off()

png(paste(output,".edit.pos.png",sep=""))
ggplot(a, aes(x = "", y = a$Count, fill = a$Iterm)) +
  geom_bar(stat = "identity", width = 1) +
  coord_polar(theta = "y") +
  labs(x = "", y = "", title = "") +
  theme_bw()+           ##将灰色背景去掉
  theme(panel.border=element_blank())+ ##将白色框框去掉
  theme(axis.ticks = element_blank()) +  ##将左上角的胡子去掉
  theme(panel.grid=element_blank())+  ##去掉白色圆框和中间的坐标线
  theme(legend.margin=unit(-3.5,"cm")) + ##改变图例和图的相对位置
  theme(plot.margin=unit(c(-1,1.5,-1,-1),units="cm")) + ##改变图在画布上的位置，C(上，右，下，左)
  theme(legend.title = element_blank())+ ##去掉图例的标题
  scale_fill_discrete(labels = mylabel) + ## 将原来的图例标签换成现在的myLabel
  theme(axis.text.x = element_blank()) +  ## 白色的外框即是原柱状图的X轴，把X轴的刻度文字去掉即可
  geom_text(aes(y = a$Count/2 + c(0, cumsum(a$Count)[-length(a$Count)]),x=c(1.3,1,1,1.2,1,1), label = mylabel2), size =6)
dev.off()



