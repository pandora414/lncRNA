vars.tmp <- commandArgs(T)
vars <- vars.tmp[length(vars.tmp)]
split.vars <- unlist(strsplit(vars,','))
species=split.vars[1]
input =split.vars[2]
num=split.vars[3]
output = split.vars[4]


library(STRINGdb)
string_db <- STRINGdb$new(version = "10",species= as.numeric(species),score_threshold=0, input_directory="/DG/home/yut/database/STRING/species")
string_proteins <- string_db$get_proteins()    ##获取蛋白信息
a <- read.table(input,head=TRUE)
a_mapped <- string_db$map(a,"GeneID",removeUnmappedRows = TRUE)
mygene <- a_mapped$STRING_id[1:num]
#pdf("./test.pdf")
#string_db$plot_network(mygene)
#dev.off()

mygene_p05 <- string_db$add_diff_exp_color(subset(a_mapped,FDR <0.05),logFcColStr="logFC")
payload_id <- string_db$post_payload(mygene_p05$STRING_id,colors = mygene_p05$color)

pdf(paste(output,".network.pdf",sep=""))
string_db$plot_network(mygene_p05$STRING_id,payload_id=payload_id)
dev.off()



