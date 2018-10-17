#! /usr/bin/perl -w
use strict;
use FindBin qw($Bin);
use lib "$Bin";

die "usage:perl rpkmplot.pl all.rpkm.tmp ./" unless @ARGV==2;
my($rpkm,$out)=@ARGV;
open IN, "$rpkm" or die;
open OUT, ">$out/tmp" or die;

print OUT "Sample\tGeneID\tread_num\tlength\trpkm\n";
while(<IN>)
{
	chomp $_;
	print OUT "$_\n";
}
close IN;
close OUT;

system(" /DG/programs/beta/rel/R-3.0.2/bin/R --slave <$Bin/rpkmplot.Rscript --args -o $out/tmp,$out/all.sample.rpkm.density.pdf,$out/all.sample.rpkm.density.png,$out/all.sample.rpkm.boxplot.pdf,$out/all.sample.rpkm.boxplot.png")


