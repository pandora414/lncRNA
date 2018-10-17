#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use Cwd qw(abs_path);
use File::Path qw(mkpath);
use File::Basename qw(dirname basename);
=head1 Program Description 
	DESeq.v1.0.pl
	This program is used to screen differencial expressed gene by DESeq.
	it also can plot the disersion,plotMA and pvalue distribution picture.
Options:
	-help 		help info;
	-indir		input dir,contain the htseq results of each sample,default ".";
	-control	control samples,one or more samples,use comma(,) delimited.eg: sampA,sampB,sampC;
	-case		case samples,one or more samples,use comma(,) delimited.eg: samp1,samp2,samp3;
	-groupname	define this compare group name,eg: groupA;
	-padj		The significant padj value threshold. default 0.1;
	-outdir 	output dir,default: ".";
Usage:
	perl DESeq.v1.0.pl -indir . -control sampA,sampB -case samp1,samp2 -groupname groupA -padj 0.1 -outdir .
	
=cut
my ($help,$indir,$control,$case,$outdir,$padj,$group);
GetOptions(
	"help!" => \$help,
	"indir=s" => \$indir,
	"control=s" => \$control,
	"case=s" => \$case,
	"padj=s" => \$padj,
	"groupname=s" => \$group,
	"outdir=s" => \$outdir,
);
die `pod2text $0` if(defined $help || !defined $control || !defined $case);
$padj||= 0.1;
$indir ||= ".";
$outdir ||= ".";
$outdir =~ s/\/$//;
[-d $outdir] || mkdir $outdir || die "can't generate the outdir:$!";
$outdir = abs_path($outdir);
open OUT,">$outdir/$group.DESeq.R" or die "can't open the output file:$!";
my $R = "library(DESeq)\nmyDesign <- data.frame(\n\t";
my ($names,$condition,$metadata);
my ($ctlNames,$ctlData) = split /;;/,&getSampName($control);
my ($caseNames,$caseData) = split /;;/,&getSampName($case);
my $ctlCondition = &condition($control,"control");
my $caseCondition = &condition($case,"case");
$R .= "row.names = c($ctlNames,$caseNames),\n\t";
$R .= "filenames = c($ctlNames,$caseNames),\n\t";
$R .= "metadata = c($ctlData,$caseData),\n\t";
$R .= "condition = c($ctlCondition,$caseCondition)\n)\n";
$R .= "cds <- newCountDataSetFromHTSeqCount(myDesign,directory = \"$indir\")\n";
$R .= "cds <- estimateSizeFactors(cds)\n";
if ($ctlNames =~ /,/ || $caseNames =~ /,/)
{
	$R .= "cds <- estimateDispersions(cds)\n";
}
else {
	$R .= "cds <- estimateDispersions(cds,method=\"blind\",sharingMode=\"fit-only\")\n";
}

$R .= "pdf(\"$outdir/$group.dispersion.pdf\")\n";
$R .= "plotDispEsts(cds)\n";
$R .= "dev.off()\n";
$R .= "png(\"$outdir/$group.dispersion.png\")\n";
$R .= "plotDispEsts(cds)\n";
$R .= "dev.off()\n";

$R .= "res <- nbinomTest(cds,\"control\",\"case\")\n";
$R .= "pdf(\"$outdir/$group.plotMA.pdf\")\n";
$R .= "plotMA(res)\n";
$R .= "dev.off()\n";
$R .= "png(\"$outdir/$group.plotMA.png\")\n";
$R .= "plotMA(res)\n";
$R .= "dev.off()\n";
$R .= "pdf(\"$outdir/$group.pValueDistribution.pdf\")\n";
$R .= "hist(res\$pval,breaks=100,col=\"blue\",border=\"slateblue\",main=\"$group pValue Distribution\")\n";
$R .= "dev.off()\n";
$R .= "png(\"$outdir/$group.pValueDistribution.png\")\n";
$R .= "hist(res\$pval,breaks=100,col=\"blue\",border=\"slateblue\",main=\"$group pValue Distribution\")\n";
$R .= "dev.off()\n";

$R .= "write.table(res,sep=\"\\t\",quote=FALSE,file=\"$outdir/$group.exp.diff.xls\",row.names=F)\n";
$R .= "resSig = res[res\$padj < $padj,]\n";
$R .= "resSig = resSig[(is.na(resSig)==F)[,8],]\n";
$R .= "write.table(resSig,sep=\"\\t\",quote=FALSE,file=\"$outdir/$group.exp.sigDiff.xls\",row.names=F)\n";
$R .= "library(\"RColorBrewer\")\n";
$R .= "library(\"gplots\")\n";

$R .= "vsdFull <- varianceStabilizingTransformation(cds)\n";
$R .= "row_names=rownames(exprs(vsdFull))\n";
$R .= "index=which(row_names%in%resSig[,1])\n";
$R .= "pdf(\"$outdir/$group.cluster.pdf\")\n";
$R .= "heatmap.2(exprs(vsdFull)[index,], col=colorpanel(100,\"green\",\"black\",\"red\"), trace=\"none\",srtCol=45, margin=c(10,10),labRow=\"\")\n";
$R .= "dev.off()\n";
$R .= "png(\"$outdir/$group.cluster.png\")\n";
$R .= "heatmap.2(exprs(vsdFull)[index,], col=colorpanel(100,\"green\",\"black\",\"red\"), trace=\"none\",srtCol=45, margin=c(10,10),labRow=\"\")\n";
$R .= "dev.off()\n";
print OUT "$R";
system ("Rscript $outdir/$group.DESeq.R ");



sub getSampName {
	my $line = shift;
	my @data;
	if($line =~ /,/)
	{
		my @names = split /,/,$line;	
		for (0..$#names)
		{
			$data[$_] = "\"$names[$_].htseq.txt\"";
			$names[$_] = "\"$names[$_]\"";
		}
		my $n = join ",",@names;
		my $d = join ",",@data;
		return $n . ";;" . $d;
	}
	else {
		
		return "\"$line\"" . ";;" . "\"$line.htseq.txt\"";
	}
}
sub condition{
		my $line = shift;
		my $desc = shift;
		my @con;
		if($line =~ /,/)
		{
			my @names = split /,/,$line;
			for (0..$#names)
			{
				$con[$_] = "\"$desc\"";
			}
			return (join ",",@con);
		}
		else {
			return "\"$desc\"";
		}
}
