#!/usr/bin/perl -w
use strict;
use FindBin qw($Bin);
use lib $Bin;
die "perl $0 <species ID> <input file> <gene number> <output dir> <file name prefix>" unless @ARGV == 5;
my($taxid,$input,$num,$outdir,$name) = @ARGV;
my $line = `wc -l $input`;
my $genenum = (split /\s+/,$line)[0];
my $temp = "$outdir/$name.string.txt";
if($genenum > 100)
{
	system("head -100 $input >$temp");
}
	
if ($genenum < $num)
{
	$num = $genenum;
}
if($genenum > 100)
{
	system("Rscript $Bin/stringdb.R -argument $taxid,$temp,$num,$outdir/$name");
}else {
	system("Rscript $Bin/stringdb.R -argument $taxid,$input,$num,$outdir/$name");
}
system("\\rm $temp"); 
