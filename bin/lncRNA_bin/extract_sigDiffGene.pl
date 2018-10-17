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
		print ORI "GeneID\t$_\n";
		print OUT "GeneID\t$_\n";
		print LIST "GeneID\tlogFC\n";
		next;
	}
	print ORI "$_\n";
	my ($id,$fc,$fdr) = (split /\t/,$_)[0,1,4];
	print OUT "$_\n" if ($fdr <= 0.05);
	print LIST "$id\t$fc\n" if ($fdr <= 0.05);
}
close IN;
close OUT;
close LIST;
	
