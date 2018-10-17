#!/usr/bin/perl -w
use strict;
die "perl $0 <diff analysis table> <all gene diff analysis results> <sigdiff file> <sigdiff gene list> " unless @ARGV == 4;
my ($in,$out,$outfile,$sigdifflist) = @ARGV;
open IN,"$in" or die;
open ORI,">$out" or die;
open OUT,">$outfile" or die;
open LIST,">$sigdifflist" or die;
while(<IN>){
	chomp;
	if(/PValue/ || /logFC/)
	{
		print ORI "GeneID\tlogFC\tlogCPM\tPValue\tFDR\n";
		print OUT "GeneID\tlogFC\tlogCPM\tPValue\tFDR\n";
		print LIST "GeneID\tlogFC\n";
		next;
	}
	my ($id,$fc,$cpm,$pval,$fdr) = (split /\t/,$_)[0,-4,-3,-2,-1];
	print ORI "$id\t$fc\t$cpm\t$pval\t$fdr\n";
	print OUT "$id\t$fc\t$cpm\t$pval\t$fdr\n" if ($fdr <= 0.05);
	print LIST "$id\t$fc\n" if ($fdr <= 0.05);
}
close IN;
close OUT;
close LIST;
	
