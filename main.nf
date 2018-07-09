#!/usr/bin/env nextflow
import SampleGroup
import Config

params.data_file="$baseDir/test/data.ini"
config=new Config(params.data_file)
Channel.from( config.ReadSamples() ).set{samples}
samples.into{samples0;samples1;samples2}
Channel.from( config.ReadGroups() ).set{groups0}

database="/DG/database/genomes/Homo_sapiens/hg19"

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

process hisat{
    tag { sample_name }
    container 'registry.cn-hangzhou.aliyuncs.com/bio/hisat2'
    publishDir { "output/hisat/"+ sample_name }
    input:
        set sample_name , files from clean_samples1

    output:
        set sample_name , file('sample.sam') into sam
        set sample_name , file('*.align_summary.txt') into summary_txt

    script:
    """
        echo \$PWD
        hisat2  -x $database/hisat_index/hg19_tran -1 ${files[0]} -2 ${files[1]} -S sample.sam 2> ${sample_name}.align_summary.txt
    """
}

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
htseq_txt.into{htseq_txt0;htseq_txt1} 
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


process edgeR{
    tag { group_name }
    //container 'registry.cn-hangzhou.aliyuncs.com/bio/hisat2'
    container "bioconductor/release_protmetcore2"
    //conda "perl=5.26.2 bioconductor-edger=3.20.7"
    publishDir {"output/group/" + sample_name}
    input:
        set sample_name , file('sample.rawCount.txt') from htseq_txt1
        set group_name , control_name , case_name, file('sample_files') from groups0
    output:
        set group_name , file("${group_name}.sigDiff.glist") into sigDiff_glist
        set group_name , file("${group_name}.sigDiff.xls") into sigDiff_xls
    script:
    """
        echo \$PWD
        mkdir input_dir
        mkdir output_dir
        cp sample.rawCount.txt input_dir/${control_name}.rawCount.txt
        cp sample.rawCount.txt input_dir/${case_name}.rawCount.txt
        perl /DG/home/wangy/process_upgrading/lncRNA-human/lncRNA_bin/mergeHtseq.pl input_dir $control_name $case_name $control_name $case_name $group_name output_dir
        perl /DG/home/yut/soft/trinityrnaseq_r20140413p1/Analysis/DifferentialExpression/run_DE_analysis.pl --matrix output_dir/${group_name}.rawCount.xls \
        --method edgeR --output output_dir --dispersion 0.05
        perl /DG/home/wangy/process_upgrading/lncRNA-human/lncRNA_bin/extract_sigDiffGene.pl \
        output_dir/${group_name}.rawCount.xls.*.edgeR.DE_results \
        output_dir/${group_name}.rawCount.xls ${group_name}.sigDiff.xls \
        ${group_name}.sigDiff.glist
        perl /DG/home/yut/bin/lncRNA_bin/network/string.network.pl 7955 output_dir/${group_name}.sigDiff.xls 100 output_dir/ $group_name
    """
}
sigDiff_xls.into{sigDiff_xls0;sigDiff_xls1}
process GO{
    tag { group_name }
    container "bioconductor/release_protmetcore2 "
    publishDir { "output/GO/"+ group_name }
    input:
        set group_name , file('sigDiff.xls') from sigDiff_xls0
    output:
        //set sample_name , file("${sample_name}.rpkm.xls") into htseq_xls
    script:
    """
        echo \$PWD
        awk '{print \$1"\t"\$2}' sigDiff.xls |grep -v 'GeneID' > ${group_name}.glist
        perl /DG/home/yut/pipeline/RNA-seq/pipeline_2.0/functional/functional.pl -go -glist ${group_name}.glist \
        -sdir $database/GO -species hg19 -outdir /GO
    """
}

process KEGG{
    tag { group_name }
    container "bioconductor/release_protmetcore2 "
    publishDir { "output/KEGG/"+ group_name }
    input:
        set group_name , file('sigDiff.xls') from sigDiff_xls1
    output:
        //set group_name , file("${group_name}.sigdiff.kobas.annot") into annot
    script:
    """
        echo \$PWD
        awk '{print \$1}' sigDiff.xls |grep -v 'GeneID' > ${group_name}.sigdiff.kobas.glist
        python /DG/programs/beta/rel/kobas-3.0/src/annotate.py -i ${group_name}.sigdiff.kobas.glist \
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
ErrorMessage:   ${workflow.errorMessage?: '-'}
Error report:   ${workflow.errorReport ?: '-'}
"""
}