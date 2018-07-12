#!/usr/bin/env nextflow
import SampleGroup
import Config

/*------------------RNA分析nextflow-pipeline初版-----------------------------

RNA_np_v0.0.1

System： Linux version 3.10.0-693.21.1.el7.x86_64
Tool  ： Nextflow 0.30.2.4867

Sample1: HL = HL.left.fq.gz|HL.right.fq.gz
Sample2: HL_1 = HL_1.left.fq.gz|HL_1.right.fq.gz
Group: group1 = HL,HL_1
example中
HL_1 = HL

                                                 /-> GO
pipeline:SOAPnuke -> hisat_aln -> htseq -> edgeR 
                                                 \-> KEGG
         fastqc

-------------------------------------------------------------------------*/

/*---------------------------定义基本目录-----------------------------------

base pathway

database： 与人hg19相关的数据、工具存储的目录
opd： output pathway本项目的输出文件母目录 
-------------------------------------------------------------------------*/
database="/DG/database/genomes/Homo_sapiens/hg19"
opd =  "/home/zhangbing/lncRNA2/output"

/*-------------------------读取样本及定义组---------------------------------

sample and group

data.ini为样本和组的配置文件，通过congfig.groovy将定义好的样本和组读入pipline中备用

sample = {{sample_name},{sample_file1,sample_file2}}
group = {{group_name},{control_name},{case_name},{control_name,case_name}}

nextflow 同一命名变量只允许一次作为输入变量
sample 扩展成3份 分别用来进行fastqc、SOAPnuke、println 
-------------------------------------------------------------------------*/
params.data_file="$baseDir/test/data.ini"
config=new Config(params.data_file)
Channel.from( config.ReadSamples() ).set{samples}
samples.into{samples0;samples1;sample_2}
Channel.from( config.ReadGroups() ).set{groups0}
sample_2.println()

/*------------------------------fastqc------------------------------------

fastqc

质量控制模块，独立于分析流程的单独模块
input ： sample
output： otp/fastqc/sample_name
-------------------------------------------------------------------------*/
process fastqc{
    tag { sample_name }
    container 'biocontainers/fastqc'
    //conda "fastqc"
    publishDir { "output/fastqc/"+ sample_name }
    input:
        set sample_name , files from samples0
    output:
        file "*_fastqc/Images/*.png"
    script:
    if(files.size == 1){
        """
        echo \$PWD
        fastqc --extract -o . ${files[0]}
        """
    }else{
        """
        echo \$PWD
        fastqc --extract -o . ${files[0]} ${files[1]}
        """
    }
}
//filter

// remove rRNA
// process bowtie{
//     tag {sample_name}
//     conda "bowtie2=2.2.5 samtools=0.1.19"
//     validExitStatus 0,1
//     input:
//         set sample_name , files from samples1

//     output:
//         set sample_name , file("*.fq.gz") into  samples_remove_rRNA

//     script:
//     """
//         echo \$PWD
//         bowtie2 -N 1 --no-unal --phred33 -p 4 -x  /DG/database/genomes/Caenorhabditis_Elegans/WBcel235/rRNA_index/rRNA.fa \
//         -1 ${files[0]} -2 ${files[1]} -S sample.sam

//         samtools view -bS sample.sam > sample.bam

//         echo test
//         samtools flagstat sample.bam > sample.bam.rRNA.stat

//         extract.unmap_rRNA.fq.pl sample.bam ${files[0]} ${files[1]} sample_1.fq sample_2.fq
//     """
// }

/*------------------------------soapnuke------------------------------------

soapnuke

质量控制模块，开始与分析第一步，用来去除引物生成clean sample
input ： sample
output： file otp/soapnuke/sample_name/*.fq.gz  val clean_samples-->{{sample_name},{*.fq.gz}}

clean_samples copy to clean_samples1|clean_samples2
-------------------------------------------------------------------------*/
process soapnuke{
    tag { sample_name }
    container 'registry.cn-hangzhou.aliyuncs.com/bio/soapnuke'
    publishDir path:{"output/soapnuke/"+sample_name} ,mode:'copy',
        saveAs: {filename ->
            if (filename.indexOf(".txt")>0) filename
            else null
        }

    input:
        set sample_name , files from samples1

    output:
        set sample_name , file("*.fq.gz") into clean_samples
        file "*.txt"

    script:
        """
        echo \$PWD
        SOAPnuke filter -1 ${files[0]} -2 ${files[1]} -l 20 -q 0.5 -Q 2 -G \
            -f GATCGGAAGAGCACACGTCTGAACTCCAGTCAC -r GATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT \
            -o . -C ${sample_name}_1.clean.fq.gz -D ${sample_name}_2.clean.fq.gz
        """
}
clean_samples.into{clean_samples1;clean_samples2;}

// process hisat{
//     tag { sample_name }
//     container 'registry.cn-hangzhou.aliyuncs.com/bio/hisat2'
//     publishDir { "output/hisat/"+ sample_name }
//     input:
//         set sample_name , files from clean_samples1

//     output:
//         set sample_name , file('sample.bam') into bam
//         set sample_name1,file('sample.align_summary.txt') into summary_txt

//     script:
//     """
//         echo \$PWD
//         hisat2  -x $database/hisat_index/hg19_tran -1 ${files[0]} -2 ${files[1]} -S sample.sam 2> sample.align_summary.txt
//         samtools view -bS sample.sam > sample_unsorted.bam
//         samtools sort -@ 8 sample_unsorted.bam -f sample.bam
//         samtools index sample.bam sample.bam.bai
//     """
// }

/*------------------------------hisat------------------------------------

hisat

比对软件，与bowtie和tophat功能相似，将read与基因组作比对
input :  clean_samples1
output:  file otp/hisat/sample_name/${sample_name}.sam  val sam-->{{sample_name},{${sample_name}.sam}}
         file otp/hisat/sample_name/*.align_summary.txt val summary_txt-->{{sample_name},{*.align_summary.txt}}
-------------------------------------------------------------------------*/
process hisat{
    tag { sample_name }
    container 'registry.cn-hangzhou.aliyuncs.com/bio/hisat2'
    publishDir { "output/hisat/"+ sample_name }
    input:
        set sample_name , files from clean_samples1

    output:
        set sample_name , file("${sample_name}.sam") into sam
        set sample_name , file("*.align_summary.txt") into summary_txt

    script:
    """
        echo \$PWD
        hisat2  -x $database/hisat_index/hg19_tran -1 ${files[0]} -2 ${files[1]} -S ${sample_name}.sam 2> ${sample_name}.align_summary.txt
    """
}

/*------------------------------samtools----------------------------------

samtools

工具软件，将sam转为bam格式，并根据染色体定位进行sort和index
input :  val sam 
output:  file otp/samtools/sample_name/${sample_name}.bam  val sam-->{{sample_name},{${sample_name}.bam}}
-------------------------------------------------------------------------*/
process samtools{
    tag { sample_name }
    container 'broadinstitute/genomes-in-the-cloud:2.3.1-1512499786'
    publishDir { "output/samtools/"+ sample_name }
    input:
        set sample_name , file('sample.sam') from sam

    output:
        set sample_name , file("${sample_name}.bam") into bam

    script:
    """
        echo \$PWD
        samtools view -bS sample.sam > ${sample_name}_unsorted.bam
        samtools sort -@ 8  ${sample_name}_unsorted.bam -o ${sample_name}.bam
        samtools index ${sample_name}.bam ${sample_name}.bam.bai
    """
}

/*------------------------------htseq----------------------------------

htseq

转录组表达量分析
input :  val bam 
output:  file otp/htseq/sample_name/${sample_name}.rawCount.txt  val htseq_txt-->{{sample_name},{${sample_name}.rawCount.txt}}

htseq_txt copy to htseq_txt0|htseq_txt1|htseq_txt2
-------------------------------------------------------------------------*/
process htseq{
    tag { sample_name }
    //container 'broadinstitute/genomes-in-the-cloud:2.3.1-1512499786'
    //container "dyndna/docker-for-pcawg14-htseq"
    conda "htseq=0.9.1"
    publishDir { "output/htseq/"+ sample_name }
    input:
        set sample_name , file('bam_files') from bam
    output:
        set sample_name , file("${sample_name}.rawCount.txt") into htseq_txt
    script:
    """
        echo \$PWD
        htseq-count -f bam -m union -s yes -t exon -i gene_id -r pos bam_files \
        $database/Ensembl_annot/hg19.GRCh37.74.gtf >${sample_name}.rawCount.txt
    """
}
htseq_txt.into{htseq_txt0;htseq_txt1;htseq_txt2} 

htseq_txt2.println()

/*------------------------------htseq_xls----------------------------------

htseq_xls

转录组表达量分析后，将txt文件转换格式为xls
input :  val summary_txt 
         val htseq_txt0
output:  file otp/htseq_xls/sample_name/${sample_name}.rpkm.xls  val htseq_xls-->{{sample_name},{${sample_name}.rpkm.xls}}
-------------------------------------------------------------------------*/
process htseq_xls{
    tag { sample_name }
    //container 'registry.cn-hangzhou.aliyuncs.com/bio/hisat2'
    container "broadinstitute/genomes-in-the-cloud:2.3.1-1512499786 "
    publishDir { "output/htseq/"+ sample_name }
    input:
        set sample_name , file('txt_files') from summary_txt
        set sample_name , file('sample.rawCount.txt') from htseq_txt0
    output:
        set sample_name , file("${sample_name}.rpkm.xls") into htseq_xls
    script:
    """
        echo \$PWD
        perl /DG/home/qkun/bin/RNAseq_bin/htseq2rpkm_hisat.pl txt_files \
        $database/Ensembl_annot/hg19.GRCh37.74.ncRNA.gene.len \
        sample.rawCount.txt $sample_name ${sample_name}.rpkm.xls
	    sed 's/^/$sample_name\t/' ${sample_name}.rpkm.xls | sed '1d' > ${sample_name}.rpkm.tmp
    """
}

/*------------------------------edgeR----------------------------------

edgeR

基因差异性表达分析
input :  val groups0 
         file ${control_name}.rawCount.txt
         file ${case_name}.rawCount.txt
output:  file otp/group/group_name/${group_name}.sigDiff.glist  val sigDiff_glist-->{{group_name},{${group_name}.sigDiff.glist}}
         file otp/group/group_name/${group_name}.sigDiff.xls  val sigDiff_xls-->{{group_name},{${group_name}.sigDiff.xls}}

sigDiff_xls copy to sigDiff_xls0|sigDiff_xls1

1、由于nextflow没有找到以文件路径作为变量输入的方式，所以采用脚本命令的方式，在工作临时文件夹内
创建输入输出文件夹，将需要输入输出的文件通过cp命令操作到指定目录下

2、测试例中HL_1与HL为相同文件，固输出的差异文件为空，这在后续操作会报错，所以我们在这里用printf写入几行数据
-------------------------------------------------------------------------*/
process edgeR{
    tag { group_name }
    //container 'registry.cn-hangzhou.aliyuncs.com/bio/hisat2'
    container "bioconductor/release_protmetcore2"
    //conda "perl=5.26.2 bioconductor-edger=3.20.7"
    publishDir {"output/group/" + group_name}
    input:
        //set sample_name , file('sample.rawCount.txt') from htseq_txt1
        set group_name , control_name , case_name, file('sample_files') from groups0
    output:
        set group_name , file("${group_name}.sigDiff.glist") into sigDiff_glist
        set group_name , file("${group_name}.sigDiff.xls") into sigDiff_xls
    script:
    """
        echo \$PWD
        mkdir input_dir
        mkdir output_dir
        
        cp $opd/htseq/$control_name/${control_name}.rawCount.txt input_dir/${control_name}.rawCount.txt
        cp $opd/htseq/$case_name/${case_name}.rawCount.txt input_dir/${case_name}.rawCount.txt
        perl /DG/home/wangy/process_upgrading/lncRNA-human/lncRNA_bin/mergeHtseq.pl input_dir $control_name $case_name $control_name $case_name $group_name output_dir
        perl /DG/home/yut/soft/trinityrnaseq_r20140413p1/Analysis/DifferentialExpression/run_DE_analysis.pl --matrix output_dir/${group_name}.rawCount.xls \
        --method edgeR --output output_dir --dispersion 0.05
        perl /DG/home/wangy/process_upgrading/lncRNA-human/lncRNA_bin/extract_sigDiffGene.pl \
        output_dir/${group_name}.rawCount.xls.*.edgeR.DE_results \
        output_dir/${group_name}.rawCount.xls ${group_name}.sigDiff.xls \
        ${group_name}.sigDiff.glist
        perl /DG/home/yut/bin/lncRNA_bin/network/string.network.pl 7955 output_dir/${group_name}.sigDiff.xls 100 output_dir/ $group_name
        
        
        printf 'ENSDARG00000099678\nENSDARG00000053864\nENSDARG00000061737' > ${group_name}.sigDiff.xls
    """
}
sigDiff_xls.into{sigDiff_xls0;sigDiff_xls1}

/*--------------------------------GO------------------------------------

GO

input :  val sigDiff_xls0 
output:  
-------------------------------------------------------------------------*/
process GO{
    tag { group_name }
    //container "bioconductor/release_protmetcore2 "
    //conda "blast=2.7.1"
    publishDir { "output/GO/"+ group_name }
    input:
        set group_name , file('sigDiff.xls') from sigDiff_xls0
    // output:
    //     set sample_name , file("${sample_name}.rpkm.xls") into GO_file
    script:
    """
        echo \$PWD
        awk '{print \$1"\t"\$2}' sigDiff.xls |grep -v 'GeneID' > ${group_name}.glist
        perl /DG/home/yut/pipeline/RNA-seq/pipeline_2.0/functional/functional.pl -go -glist ${group_name}.glist \
        -sdir $database/GO -species hg19 
    """
}

/*------------------------------KEGG----------------------------------

KEGG

input :  val sigDiff_xls1 
output:  file otp/KEGG/group_name/${group_name}.sigdiff.kobas.annot val KEGG_file-->{{group_name},{${group_name}.sigdiff.kobas.annot}}
-------------------------------------------------------------------------*/
process KEGG{
    tag { group_name }
    //container "biocontainers/biocontainers "
    conda "kobas=3.0.3"
    publishDir { "output/KEGG/"+ group_name }
    input:
        set group_name , file('sigDiff.xls') from sigDiff_xls1
    output:
        set group_name , file("${group_name}.sigdiff.kobas.annot") into KEGG_file
    script:
    """
        echo \$PWD
        touch \$HOME/.kobasrc
        
        awk '{print \$1}' sigDiff.xls |grep -v 'GeneID' > ${group_name}.sigdiff.kobas.glist

        kobas-annotate -i ${group_name}.sigdiff.kobas.glist \
        -t id:ensembl -s dre -y /DG/database/pub/KOBAS/3.0/seq_pep -q /DG/database/pub/KOBAS/3.0/sqlite3/ \
        -p /DG/programs/beta/rel/ncbi-blast-2.2.28+/bin/blastp -x /DG/programs/beta/rel/ncbi-blast-2.2.28+/bin/blastx \
        -o ${group_name}.sigdiff.kobas.annot -n 4
    """
}

// process stringtie{
//     conda "stringtie=1.3.3"

//     input:
//         set sample_name , file('sample.bam') from bam

//     output:
//         set sample_name , file('sample.gtf') into gtf

//     script:
//     """
//         echo \$PWD
//         stringtie -p 6 --rf -G $database/Ensembl_annot/hg19.GRCh37.74.gtf -o sample.gtf sample.bam
//     """
// }

// process star{
//     conda "star=2.6.0c"
//     input:
//         set sample_name , files from clean_samples2

//     output:
//         set sample_name , file("sample.Aligned.out.sam") into aligned_sam
//     script:
//     """
//         echo \$PWD
//         STAR --genomeDir /DG/database/genomes/Homo_sapiens/hg19/star_index --readFilesIn  ${files[0]} ${files[1]} \
//             --outFileNamePrefix sample. --runThreadN 4 --alignMatesGapMax alignIntronMax --readFilesCommand zcat
//     """
// }

workflow.onComplete {
    log.info """
Pipeline execution summary
---------------------------
ScriptId    :   ${workflow.scriptId}
ScriptName  :   ${workflow.scriptName}
scriptFile  :   ${workflow.scriptFile}
Repository  :   ${workflow.repository?:'-'}
Revision    :   ${workflow.revision?:'-'}
ProjectDir  :   ${workflow.projectDir}
LaunchDir   :   ${workflow.launchDir}
ConfigFiles :   ${workflow.configFiles}
Container   :   ${workflow.container}
CommandLine :   ${workflow.commandLine}
Profile     :   ${workflow.profile}
RunName     :   ${workflow.runName}
SessionId   :   ${workflow.sessionId}
Resume      :   ${workflow.resume}
Start       :   ${workflow.start}

Completed at:   ${workflow.complete}
Duration    :   ${workflow.duration}
Success     :   ${workflow.success}
Exit status :   ${workflow.exitStatus}
ErrorMessage:   '-'
Error report:   '-'
"""
}