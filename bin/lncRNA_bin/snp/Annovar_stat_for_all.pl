#!/usr/bin/perl -w
use strict;
use lib qw(/ifs4/BC_HDH/PIPE/Exon/cancer/pipeline/pipeline/lib/);
use Text::CSV;
use Getopt::Long;
use File::Basename;
my ($infile,$sample,$dir,$outfile,$thrd,$var,$help,$filter);
GetOptions
(
	"i=s"=>\$infile,
	"s=s"=>\$sample,
	"o=s"=>\$outfile,
	"t=f"=>\$thrd,
	"v=s"=>\$var,
	"filter"=>\$filter,
        "h"=>\$help,
);

my $usage=<<INFO;
Usage:
	perl $0 [options]
Options:

	-i <file>	:input file is the result of annotation by ANNOVAR,name after SampleID.genome_summary.csv 
			example:/ifshk1/BC_CANCER/esophagus/guobh/I_statistics/EC-T05_list/SOAPSNP/EC-T05_list.annoVar.format.filter.genome_summary.csv
	-s <string>	:the sample name 
	-o <string>	:the prefix of output file
	-t <float>	:the threshold of sift,default 0.05
	-filter		:the input file has been filted using snv_filter.R, default off
	-v <string>	:the type of Structural Variation 
				snp	SOAPsnp or samtools mpileup SNP
				indel	samtools mpileup InDel
				snv	SNVs were called by Varscan
				sv	SVs,use breakdancer
				cnv	CNVs,called by CNV detection 
	-h		:get the usage.
INFO


die $usage unless($infile && $var && $outfile);
die $usage if ($help);
my $name = basename $infile;
$name =~ /(.*)\.(genome|exome)_summary\.csv$/;
$sample ||=$1;
$outfile ||=$sample;
$thrd ||=0.05;
my $dbv=138;

my $csv = Text::CSV->new();
my $status;
my $csvoffset=0;

open IN,"$infile";
open OUT2,">$outfile.all_stat";
open OUT4,">$outfile.novel_stat" unless($var=~/sv|cnv/);
my($k_dbsnp132,$k1000,$rs,$novel,$hom,$het,$intergenic,$UTR,$UTR5,$intronic,$updown,$upstream,$exonic,$UTR3,$downstream,$ncRNA,$count,$exonicsplicing,$splicing,$nonsynonymous,$synonymous,$sift)=(0) x 22;
my($nhom,$nhet,$nintergenic,$nUTR,$nUTR5,$nintronic,$nupdown,$nupstream,$nexonic,$nUTR3,$ndownstream,$nncRNA,$ncount,$nexonicsplicing,$nsplicing,$nnonsynonymous,$nsynonymous,$nsift)=(0) x 22;
my ($del,$ins,$inv,$ctx,$itx,$ndel,$nins,$ninv,$nctx,$nitx)= (0) x 10;
my ($stopg,$stopl,$nstopg,$nstopl)=(0) x 4;
my ($fsd,$fsi,$nfsd,$nfsi,$fss,$nfss,$nofsd,$nofsi,$nonfsd,$nonfsi,$nofss,$nonfss)= (0) x 12;
my ($ti,$tv,$dbti,$dbtv,$nti,$ntv)=(0) x 6;
#Func,Gene,ExonicFunc,AAChange,Conserved,SegDup,1000G_ALL,1000G_ALL,1000G_ALL,dbSNP132,SIFT,Chr,Start,End,Ref,Obs,Otherinfo
#Func,Gene,ExonicFunc,AAChange,Conserved,SegDup,1000G_ALL,1000G_ALL,1000G_ALL,dbSNP132,SIFT,PolyPhen2,LJB_PhyloP,LJB_MutationTaster,LJB_LRT,Chr,Start,End,Ref,Obs,Otherinfo
while(<IN>)
{
	chomp;
	my $anno = $_;
	next if($anno =~ /^\s*$/);
	$status = $csv->parse($_);
	my @line = $csv->fields();
	if($line[5] =~ /Func/)
	{
		if($line[0] ne 'Chr')
		{$csvoffset=-3;}
		next;
	}
	$count++;
	my ($k1,$db,$s)=@line[12,14,15];
	my $base1=$line[3+$csvoffset];
	my $base2=$line[4+$csvoffset];
	
	if ($var =~/snp|snv/)
	{
		if((($base1 eq 'A') && ($base2 eq 'G')) || (($base1 eq 'G') && ($base2 eq 'A')) || (($base1 eq 'C') && ($base2 eq 'T')) || (($base1 eq 'T') && ($base2 eq 'C')))
		{
			$ti++;
			$dbti++ if($db ne 'NA');
			if(defined $filter)
					{$nti++ if($k1 eq 'NA' && !$db);}
			else
			    {$nti++ if(($k1 eq 'NA') && ($db eq 'NA'));}
		}
		else
		{
			$tv++;
			$dbtv++ if($db ne 'NA');
			if(defined $filter)
			{$ntv++ if($k1 eq 'NA' && !$db);}
			else
			{$ntv++ if(($k1 eq 'NA') && ($db eq 'NA'));}
		}
	}
	
  if(($k1 ne 'NA') && ($db ne 'NA'))
	{
		if(defined $filter)
		{$k_dbsnp132++ if($k1 ne 'NA');}
		else
		{$k_dbsnp132++;}
	}
	if(($db eq 'NA') && ($k1 ne 'NA'))
	{
		if(defined $filter)
		{$k1000++ if($k1 ne 'NA');}
		else
		{$k1000++;}
	}
	if(($k1 eq 'NA')&& ($db ne 'NA') )
	{
		$rs++;
	}
	if( ($k1 eq 'NA') && ($db eq 'NA'))
	{
#novel
		$novel++;
		if($s && $s ne 'NA')
			{$nsift++ if($s < $thrd);}
#homozygosis and heterozygosis  "GT:PL:GQ","1/1:255,255,0:99"
		if( ($anno=~/hom/)||($anno=~/\"0\/0\:?/) ||($anno=~/\"1\/1\:?/))
			{$nhom++;}
		else
			{$nhet++;}
#types of SV: DEL INS INV 
		if($anno=~/type=DEL/i){$ndel++;}
		elsif($anno=~/type=INS/i){$nins++;}
		elsif($anno=~/type=INV/i){$ninv++;}
		elsif($anno=~/type=CTX/i){$nctx++;}
		elsif($anno=~/type=ITX/i){$nitx++;}
#exonicFunc
#synonymous and nonsynonymous
		if($line[7]=~/\bsynonymous\b/){$nsynonymous++;}
		if($line[7]=~/nonsynonymous\b/){$nnonsynonymous++;}
#stop gain and stop loss
		if ($line[7] =~ /\bstopgain\b/){$nstopg++;}
		if ($line[7] =~ /\bstoploss\b/){$nstopl++;}
#frameshift insertion/deletion/block substitution ,nonframeshift insertion/deletion/block substitution
		if ($line[7] =~ /\bframeshift\sdeletion\b/){$nofsd++;}
		if ($line[7] =~ /\bframeshift\sinsertion\b/){$nofsi++;}
		if ($line[7] =~ /\bnonframeshift\sdeletion\b/){$nonfsd++;}
		if ($line[7] =~ /\bnonframeshift\sinsertion\b/){$nonfsi++;}
		if ($line[7] =~ /\bframeshift\ssubstitution\b/){$nofss++;}
		if ($line[7] =~ /\bnonframeshift\ssubstitution\b/){$nonfss++;}
#fun
		if($line[5]=~/intergenic/){$nintergenic++;}
		elsif($line[5]=~/\bintronic/){$nintronic++;}
		elsif($line[5]=~/exonic\;splicing/){$nexonicsplicing++;}
		elsif($line[5]=~/\bexonic/){$nexonic++;}
		elsif($line[5]=~/\bsplicing/){$nsplicing++;}
		elsif($line[5]=~/UTR5\;UTR3/){$nUTR++;}
		elsif($line[5]=~/UTR5/){$nUTR5++;}
		elsif($line[5]=~/\bUTR3/){$nUTR3++;}
		elsif($line[5]=~/upstream\;downstream/){$nupdown++}
		elsif($line[5]=~/upstream/){$nupstream++;}
		elsif($line[5]=~/\bdownstream/){$ndownstream++;}
		elsif($line[5]=~/ncRNA/){$nncRNA++;}
		else{print $anno;}	
	}
#	else
#	{$novel++;}
#for dbsnp or novel
	if($s && $s ne 'NA')
		{$sift++ if($s <$thrd);}
#for shift
	if(($anno=~/hom/)||($anno=~/\"0\/0\:?/)||($anno=~/\"1\/1\:?/))
		{$hom++;}
	else
		{$het++;}
#for hom or het
	if($anno=~/type=DEL/i){$del++;}
	elsif($anno=~/type=INS/i){$ins++;}
	elsif($anno=~/type=INV/i){$inv++;}
	elsif($anno=~/type=CTX/i){$ctx++;}
	elsif($anno=~/type=ITX/i){$itx++;}
	
#for SV :DEL INS INV
#exonicFunc
#synonymous and nonsynonymous
	if($line[7]=~/\bsynonymous\b/){$synonymous++;}
	if($line[7]=~/nonsynonymous\b/){$nonsynonymous++;}
#stop gain and stop loss
	if ($line[7] =~ /\bstopgain\b/){$stopg++;}
	if ($line[7] =~ /\bstoploss\b/){$stopl++;}
#frameshift insertion/deletion/block substitution ,nonframeshift insertion/deletion/block substitution
	if ($line[7] =~ /\bframeshift\sdeletion\b/){$fsd++;}
	if ($line[7] =~ /\bframeshift\sinsertion\b/){$fsi++;}
	if ($line[7] =~ /\bnonframeshift\sdeletion\b/){$nfsd++;}
	if ($line[7] =~ /\bnonframeshift\sinsertion\b/){$nfsi++;}
	if ($line[7] =~ /\bframeshift\ssubstitution\b/){$fss++;}
	if ($line[7] =~ /\bnonframeshift\ssubstitution\b/){$nfss++;}
#fun
	if($line[5]=~/intergenic/){$intergenic++;}
	elsif($line[5]=~/\bintronic/){$intronic++;}
	elsif($line[5]=~/exonic\;splicing/){$exonicsplicing++;}
	elsif($line[5]=~/\bexonic/){$exonic++;}
	elsif($line[5]=~/\bsplicing/){$splicing++;}
	elsif($line[5]=~/UTR5\;UTR3/){$UTR++;}
	elsif($line[5]=~/UTR5/){$UTR5++;}
	elsif($line[5]=~/\bUTR3/){$UTR3++;}
	elsif($line[5]=~/upstream\;downstream/){$updown++}
	elsif($line[5]=~/upstream/){$upstream++;}
	elsif($line[5]=~/\bdownstream/){$downstream++;}
	elsif($line[5]=~/ncRNA/){$ncRNA++;}
	else{print $anno;}
#for function
	}
close IN;
#$novel=$count-$k_dbsnp132-$k1000-$rs;
#print OUT "Sample\tcount\tk1000+dbsnp132\tk1000\tdbSNP\tnovel\thom\thet\tsynonymous\tnonsynonymous\tupstream\tdownstream\tUTR5\tUTR3\tncRNA\texonic;splicing\tsplicing\texonic\tintronic\tintergenic\tsift\n";
#print OUT "$sample\t$count\t$k_dbsnp132\t$k1000\t$rs\t$novel\t$hom\t$het\t$synonymous\t$nonsynonymous\t$upstream\t$downstream\t$UTR5\t$UTR3\t$ncRNA\t$exonicsplicing\t$splicing\t$exonic\t$intronic\t$intergenic\t$sift\n";
#print OUT "$sample\t$count\t$k_dbsnp132\t$k1000\t$rs\t$novel\t$hom\t$het\t$synonymous\t$nonsynonymous\t$exonic\t$exonicsplicing\t$splicing\t$ncRNA\t$UTR5\t$UTR3\t$intronic\t$upstream\t$downstream\t$intergenic\t$sift\n";
#print OUT3 "$sample\t$novel\t$nhom\t$nhet\t$nsynonymous\t$nnonsynonymous\t$nupstream\t$ndownstream\t$nUTR5\t$nUTR3\t$nncRNA\t$nexonicsplicing\t$nsplicing\t$nexonic\t$nintronic\t$nintergenic\t$nsift\n";
#print OUT3 "$sample\t$novel\t$nhom\t$nhet\t$nsynonymous\t$nnonsynonymous\t$nexonic\t$nexonicsplicing\t$nsplicing\t$nncRNA\t$nUTR5\t$nUTR3\t$nintronic\t$nupstream\t$ndownstream\t$nintergenic\t$nsift\n";
$tv=1 if($tv==0);
$dbtv=1 if($dbtv==0);
$ntv=1 if($ntv==0);
my $fre1=$ti/$tv;
my $fre2=$dbti/$dbtv;
my $fre3=$nti/$ntv;
#all
my $dbrate = ($k_dbsnp132+$rs)/$count*100;
print OUT2 "Sample\t$sample\n";
print OUT2 "Total\t$count\n";
if( $var eq 'sv' ){
	print OUT2 "Insertion\t$ins\n";
	print OUT2 "Deletion\t$del\n";
	print OUT2 "Inversion\t$inv\n";
	print OUT2 "ITX\t$itx\n";
	print OUT2 "CTX\t$ctx\n";
}
unless( $var =~/sv|cnv/){
	print OUT2 "1000g2012 and dbsnp$dbv\t$k_dbsnp132\n";
	print OUT2 "1000g2012 specific\t$k1000\n";
	print OUT2 "dbSNP$dbv specific\t$rs\n";
	printf OUT2 "dbSNP rate\t%4.2f%%\n",$dbrate;
	print OUT2 "Novel\t$novel\n";
	print OUT2 "Hom\t$hom\n";
	print OUT2 "Het\t$het\n";
	}
if( $var =~/snp|snv/){
	print OUT2 "Synonymous\t$synonymous\n";
	print OUT2 "Missense\t$nonsynonymous\n";
	}
elsif( $var =~/indel/){
	print OUT2 "Frameshift Insertion\t$fsi\n";
	print OUT2 "Non-frameshift Insertion\t$nfsi\n";
	print OUT2 "Frameshift Deletion\t$fsd\n";
	print OUT2 "Non-frameshift Deletion\t$nfsd\n";
	print OUT2 "Frameshift block substitution\t$fss\n";
	print OUT2 "Non-frameshift block substitution\t$nfss\n";
	}
unless ($var =~/sv|cnv/){
	print OUT2 "Stopgain\t$stopg\n";
	print OUT2 "Stoploss\t$stopl\n";	
	}
print OUT2 "Exonic\t$exonic\n";
print OUT2 "Exonic and splicing\t$exonicsplicing\n";
print OUT2 "Splicing\t$splicing\n";
print OUT2 "NcRNA\t$ncRNA\n";
print OUT2 "UTR5\t$UTR5\n";
print OUT2 "UTR5 and UTR3\t$UTR\n";
print OUT2 "UTR3\t$UTR3\n";
print OUT2 "Intronic\t$intronic\n";
print OUT2 "Upstream\t$upstream\n";
print OUT2 "Upstream and downstream\t$updown\n";
print OUT2 "Downstream\t$downstream\n";
print OUT2 "Intergenic\t$intergenic\n";
print OUT2 "SIFT\t$sift\n" if( $var =~/snp|snv/);
if($var =~/snp|snv/){
	printf OUT2 "Ti\/Tv\t%5.4f\n",$fre1;
	printf OUT2 "dbSNP Ti\/Tv\t%5.4f\n",$fre2;
	printf OUT2 "Novel Ti\/Tv\t%5.4f\n",$fre3;
	}
close OUT2;
#novel
unless($var =~/sv|cnv/){
	print OUT4 "Sample\t$sample\n";
	print OUT4 "Novel\t$novel\n";
	print OUT4 "Hom\t$nhom\n";
	print OUT4 "Het\t$nhet\n";
	if( $var =~/snp|snv/){
		print OUT4 "Synonymous\t$nsynonymous\n";
		print OUT4 "Missense\t$nnonsynonymous\n";
		}
	elsif($var =~/indel/){
		print OUT4 "Frameshift Insertion\t$nofsi\n";
		print OUT4 "Non-frameshift Insertion\t$nonfsi\n";
		print OUT4 "Frameshift Deletion\t$nofsd\n";
		print OUT4 "Non-frameshift Deletion\t$nonfsd\n";
		print OUT4 "Frameshift block substitution\t$nofss\n";
		print OUT4 "Non-frameshift block substitution\t$nonfss\n";
		}
	unless ($var =~/sv|cnv/){
		print OUT4 "Stopgain\t$nstopg\n";
		print OUT4 "Stoploss\t$nstopl\n";	
	}
	print OUT4 "Exonic\t$nexonic\n";
	print OUT4 "Exonic and splicing\t$nexonicsplicing\n";
	print OUT4 "Splicing\t$nsplicing\n";
	print OUT4 "NcRNA\t$nncRNA\n";
	print OUT4 "UTR5\t$nUTR5\n";
	print OUT4 "UTR5 and UTR3\t$nUTR\n";
	print OUT4 "UTR3\t$nUTR3\n";
	print OUT4 "Intronic\t$nintronic\n";
	print OUT4 "Upstream\t$nupstream\n";
	print OUT4 "Upstream and downstream\t$nupdown\n";
	print OUT4 "Downstream\t$ndownstream\n";
	print OUT4 "Intergenic\t$nintergenic\n";
	print OUT4 "SIFT\t$nsift\n" if( $var =~/snp|snv/);
	if($var =~/snp|snv/){
		printf OUT4 "Novel Ti\/Tv\t%5.4f\n",$fre3;
		}
}
close OUT4;
