#!/usr/bin/env nextflow
import SampleGroup
import Config

params.data_file="$baseDir/test/data.ini"
config=new Config(params.data_file)
Channel.from( config.ReadSamples() ).set{samples}

samples.into{samples0;samples1;samples2}
database="/DG/database/genomes/Homo_sapiens/hg19"

process fastqc{
    tag { sample_name }
    container 'biocontainers/fastqc'
    //conda "fastqc"
    publishDir { "output/fastqc/"+ sample_name }
    input:
        set sample_name,files from samples0
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
process bowtie{
    tag {sample_name}
    conda "bowtie2=2.2.5 samtools=0.1.19"
    validExitStatus 0,1
    input:
        set sample_name,files from samples1

    output:
        set sample_name,file("*.fq.gz") into  samples_remove_rRNA

    script:
    """
        echo \$PWD
        bowtie2 -N 1 --no-unal --phred33 -p 4 -x  /DG/database/genomes/Caenorhabditis_Elegans/WBcel235/rRNA_index/rRNA.fa \
        -1 ${files[0]} -2 ${files[1]} -S sample.sam

        samtools view -bS sample.sam > sample.bam

        echo test
        samtools flagstat sample.bam > sample.bam.rRNA.stat

        extract.unmap_rRNA.fq.pl sample.bam ${files[0]} ${files[1]} sample_1.fq sample_2.fq
    """
}

process soapnuke{
    tag { sample_name }
    container 'registry.cn-hangzhou.aliyuncs.com/bio/soapnuke'
    publishDir path:{"output/soapnuke/"+sample_name} ,mode:'copy',
        saveAs: {filename ->
            if (filename.indexOf(".txt")>0) filename
            else null
        }

    input:
        set sample_name,files from samples_remove_rRNA

    output:
        set sample_name,file("*.fq.gz") into clean_samples
        file "*.txt"

    script:
        """
        echo \$PWD
        SOAPnuke filter -1 ${files[0]} -2 ${files[1]} -l 20 -q 0.5 -Q 2 -G \
            -f GATCGGAAGAGCACACGTCTGAACTCCAGTCAC -r GATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT \
            -o . -C sample_1.clean.fq.gz -D sample_2.clean.fq.gz
        """
}

clean_samples.into{clean_samples1;clean_samples2;}

process hisat{
    tag { sample_name }
    //container 'registry.cn-hangzhou.aliyuncs.com/bio/hisat2'
    conda "hisat2=2.1.0 samtools=0.1.19"

    input:
        set sample_name,files from clean_samples1

    output:
        set sample_name,file('sample.bam') into bam

    script:
    """
        echo \$PWD
        hisat2  -x $database/hisat_index/hg19_tran -1 ${files[0]} -2 ${files[1]} -S sample.sam 2> sample.align_summary.txt
        samtools view -bS sample.sam > sample_unsorted.bam
        samtools sort -@ 8 sample_unsorted.bam -f sample.bam
        samtools index sample.bam sample.bam.bai
    """
}

process stringtie{
    conda "stringtie=1.3.3"

    input:
        set sample_name,file('sample.bam') from bam

    output:
        set sample_name,file('sample.gtf') into gtf

    script:
    """
        echo \$PWD
        stringtie -p 6 --rf -G $database/Ensembl_annot/hg19.GRCh37.74.gtf -o sample.gtf sample.bam
    """
}

process star{
    conda "star=2.6.0c"
    input:
        set sample_name,files from clean_samples2

    output:
        set sample_name,file("sample.Aligned.out.sam") into aligned_sam
    script:
    """
        echo \$PWD
        STAR --genomeDir /DG/database/genomes/Homo_sapiens/hg19/star_index --readFilesIn  ${files[0]} ${files[1]} \
            --outFileNamePrefix sample. --runThreadN 4 --alignMatesGapMax alignIntronMax --readFilesCommand zcat
    """
}

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